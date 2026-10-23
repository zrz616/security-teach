# syntax=docker/dockerfile:1

ARG GO_VERSION=1.24

FROM golang:${GO_VERSION}-bookworm AS projectdiscovery-builder

ARG SUBFINDER_VERSION=latest
ARG HTTPX_VERSION=latest
ARG NUCLEI_VERSION=latest

ENV CGO_ENABLED=0

RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@${SUBFINDER_VERSION} \
    && go install github.com/projectdiscovery/httpx/cmd/httpx@${HTTPX_VERSION} \
    && go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@${NUCLEI_VERSION}

FROM python:3.12-slim-bookworm

ARG SCANNER_UID=10001
ARG SCANNER_GID=10001

LABEL org.opencontainers.image.title="Driftholm ProjectDiscovery scanner" \
      org.opencontainers.image.description="Python and ProjectDiscovery tools for authorized, read-only asset discovery" \
      org.opencontainers.image.source="https://github.com/projectdiscovery"

RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates curl dnsutils jq \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid "${SCANNER_GID}" scanner \
    && useradd --uid "${SCANNER_UID}" --gid "${SCANNER_GID}" --create-home --shell /bin/sh scanner \
    && mkdir -p /work/input /work/output /work/templates /tmp/nuclei-templates \
    && chown -R scanner:scanner /work /tmp/nuclei-templates

COPY --from=projectdiscovery-builder /go/bin/subfinder /usr/local/bin/subfinder
COPY --from=projectdiscovery-builder /go/bin/httpx /usr/local/bin/httpx
COPY --from=projectdiscovery-builder /go/bin/nuclei /usr/local/bin/nuclei

ENV HOME=/tmp \
    XDG_CONFIG_HOME=/tmp/.config \
    TMPDIR=/tmp \
    PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /work
USER scanner

# Keep the default useful for an interactive `docker compose run` shell.
CMD ["sh"]
