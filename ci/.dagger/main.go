package main

import (
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"strings"

	"dagger/webapi-scanner/internal/dagger"
)

//go:embed pipeline.sh
var pipelineScript string

const (
	goVersion        = "1.26.10"
	subfinderVersion = "v2.17.0"
	dnsxVersion      = "v1.3.1"
	httpxVersion     = "v1.12.0"
	katanaVersion    = "v1.8.0"
	nucleiVersion    = "v3.11.1"
	templatesVersion = "v10.5.1"
)

type WebapiScanner struct{}

// Artifacts builds the scanner image and runs the authorized external-asset
// pipeline, returning the six files expected under artifacts/webapi-5.
//
// The scan fails closed: hosts or targets outside the declared scope are
// rejected before any active request is made.
func (m *WebapiScanner) Artifacts(
	ctx context.Context,
	// Authorized apex domain (for example example.com), or lab://<name> for a lab target.
	scope string,
	// +optional
	// +default="unknown"
	commit string,
	// Optional pre-approved subdomain list. Skips subfinder when provided.
	// +optional
	subdomains *dagger.File,
	// Optional local/authorized target URLs. Skips subfinder and dnsx when provided.
	// +optional
	targets *dagger.File,
	// Optional local nuclei templates directory. Defaults to tools/nuclei.
	// +optional
	templates *dagger.Directory,
	// Also load the pinned official technologies/exposures/misconfiguration templates.
	// +optional
	officialTemplates bool,
	// Start the local 127.0.0.1:8080 fixture inside the scanner container (used by Verify).
	// +optional
	localFixture bool,
) (*dagger.Directory, error) {
	if strings.TrimSpace(scope) == "" {
		return nil, fmt.Errorf("scope is required")
	}
	hasSubdomains := hasFile(ctx, subdomains)
	hasTargets := hasFile(ctx, targets)
	if hasSubdomains && hasTargets {
		return nil, fmt.Errorf("pass either subdomains or targets, not both")
	}

	source := dag.CurrentWorkspace().Directory("/", dagger.WorkspaceDirectoryOpts{
		Exclude: []string{
			".git",
			".scanner",
			".cache",
			"artifacts",
			"out",
			"node_modules",
			"__pycache__",
		},
	})

	if !hasDirectory(ctx, templates) {
		templates = source.Directory("tools/nuclei")
	}

	scanner := source.DockerBuild(dagger.DirectoryDockerBuildOpts{
		Dockerfile: "Dockerfile",
		BuildArgs: []dagger.BuildArg{
			{Name: "GO_VERSION", Value: goVersion},
			{Name: "SUBFINDER_VERSION", Value: subfinderVersion},
			{Name: "DNSX_VERSION", Value: dnsxVersion},
			{Name: "HTTPX_VERSION", Value: httpxVersion},
			{Name: "KATANA_VERSION", Value: katanaVersion},
			{Name: "NUCLEI_VERSION", Value: nucleiVersion},
		},
	})

	ctr := scanner.
		WithUser("root").
		WithExec([]string{"sh", "-c", "mkdir -p /work/output /work/run /work/fixture && chown -R scanner:scanner /work/output /work/run /work/fixture"}).
		WithUser("scanner").
		WithMountedDirectory("/work/templates", templates).
		WithNewFile("/work/run-pipeline.sh", pipelineScript).
		WithEnvVariable("SCOPE", scope).
		WithEnvVariable("COMMIT", commit).
		WithEnvVariable("OFFICIAL_TEMPLATES", boolString(officialTemplates)).
		WithEnvVariable("OFFICIAL_TEMPLATES_REF", templatesVersion)

	if hasSubdomains {
		ctr = ctr.WithMountedFile("/work/input/subdomains.txt", subdomains)
	}
	if hasTargets {
		ctr = ctr.WithMountedFile("/work/input/targets.txt", targets)
	}
	if officialTemplates {
		official := dag.Git("https://github.com/projectdiscovery/nuclei-templates.git").
			Tag(templatesVersion).
			Tree()
		ctr = ctr.WithMountedDirectory("/opt/nuclei-templates", official)
	}
	runCommand := []string{"sh", "/work/run-pipeline.sh"}
	if localFixture {
		ctr = ctr.WithNewFile("/work/fixture/index.html", fixtureHTML)
		runCommand = []string{
			"sh", "-c",
			"python3 -m http.server 8080 --directory /work/fixture >/tmp/fixture.log 2>&1 & exec sh /work/run-pipeline.sh",
		}
	}

	// Expect: Any lets the pipeline write run-manifest.json even when a tool
	// exits non-zero; Check() is the gate that turns exit codes into a failure.
	ctr = ctr.WithExec(
		runCommand,
		dagger.ContainerWithExecOpts{Expect: dagger.ReturnTypeAny},
	)
	return ctr.Directory("/work/output"), nil
}

// Verify runs the pipeline against a loopback HTTP fixture started inside the
// scanner container. It makes no public network requests and is intended for CI
// and local smoke tests.
func (m *WebapiScanner) Verify(ctx context.Context) (*dagger.Directory, error) {
	targets := dag.Directory().
		WithNewFile("targets.txt", "http://127.0.0.1:8080\n").
		File("targets.txt")

	return m.Artifacts(
		ctx,
		"lab://webapi-5-fixture",
		"local-verify-v9",
		nil,
		targets,
		nil,
		false,
		true,
	)
}

// Check validates the run manifest and fails when any recorded command failed
// or a required artifact is missing.
func (m *WebapiScanner) Check(
	ctx context.Context,
	// Directory containing run-manifest.json and the five data artifacts.
	artifacts *dagger.Directory,
) error {
	raw, err := artifacts.File("run-manifest.json").Contents(ctx)
	if err != nil {
		return fmt.Errorf("read run-manifest.json: %w", err)
	}

	var envelope map[string]json.RawMessage
	if err := json.Unmarshal([]byte(raw), &envelope); err != nil {
		return fmt.Errorf("parse run-manifest.json: %w", err)
	}
	for _, key := range []string{
		"scope", "commit", "tools", "templates", "commands", "inputs",
		"outputs", "exit_codes", "started_at", "finished_at",
	} {
		if _, ok := envelope[key]; !ok {
			return fmt.Errorf("run-manifest.json is missing %q", key)
		}
	}

	var manifest struct {
		Tools     map[string]struct{ Version string } `json:"tools"`
		ExitCodes map[string]int                      `json:"exit_codes"`
		Outputs   map[string]struct{ Bytes int64 }    `json:"outputs"`
	}
	if err := json.Unmarshal([]byte(raw), &manifest); err != nil {
		return fmt.Errorf("parse run-manifest fields: %w", err)
	}

	for name, code := range manifest.ExitCodes {
		if code != 0 {
			return fmt.Errorf("command %q exited %d", name, code)
		}
	}
	for _, name := range []string{"subfinder", "dnsx", "httpx", "katana", "nuclei"} {
		tool, ok := manifest.Tools[name]
		if !ok || strings.TrimSpace(tool.Version) == "" {
			return fmt.Errorf("tool %q has no recorded version", name)
		}
	}
	for _, name := range []string{
		"subdomains.txt",
		"live-assets.jsonl",
		"katana-input.txt",
		"crawled-urls.txt",
	} {
		out, ok := manifest.Outputs[name]
		if !ok || out.Bytes == 0 {
			return fmt.Errorf("artifact %q is missing or empty", name)
		}
	}
	if _, ok := manifest.Outputs["nuclei-output.jsonl"]; !ok {
		return fmt.Errorf("artifact %q is missing", "nuclei-output.jsonl")
	}
	return nil
}

func hasFile(ctx context.Context, f *dagger.File) bool {
	if f == nil {
		return false
	}
	_, err := f.ID(ctx)
	return err == nil
}

func hasDirectory(ctx context.Context, d *dagger.Directory) bool {
	if d == nil {
		return false
	}
	_, err := d.ID(ctx)
	return err == nil
}

func boolString(v bool) string {
	if v {
		return "1"
	}
	return "0"
}

const fixtureHTML = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="generator" content="Astro v5.0.0">
    <title>WebAPI-5 fixture</title>
  </head>
  <body>
    <main data-astro-cid-fixture>
      <h1>Authorized local fixture</h1>
      <a href="/about/">about</a>
    </main>
  </body>
</html>
`
