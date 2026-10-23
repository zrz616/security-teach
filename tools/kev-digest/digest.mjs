#!/usr/bin/env node
// 漏洞情报日报：CISA KEV（已被在野利用）× FIRST EPSS（未来 30 天被利用概率）
//   → 归一化 → 打分排序 → Markdown 简报 / JSON / RSS
// 零依赖，Node >= 20（内置 fetch、zlib）。
//
//   用法:  node tools/kev-digest/digest.mjs [--refresh] [--limit 5]
//          --refresh  忽略 .cache/ 重新下载
//          --limit N  控制台只打印前 N 条（产出文件始终完整）
//
// 设计约束（见 docs/roadmap.md「项目 1」）：
//   * 只用有官方 feed 的数据源，不爬 HTML。
//   * 打分规则固定且可解释；不做「AI 风险评分」这类不可复核的黑箱。
//   * 增量：state/seen.json 记录首次见到某 CVE 的日期，用于标 🆕。

import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { gunzipSync } from 'node:zlib';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const CACHE_DIR = path.join(ROOT, '.cache');
const OUT_DIR = path.join(ROOT, 'out');
const STATE_DIR = path.join(ROOT, 'state');

const KEV_URL =
  'https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json';
// 该 URL 会 302 到 epss_scores-YYYY-MM-DD.csv.gz，fetch 默认跟随重定向。
const EPSS_URL = 'https://epss.empiricalsecurity.com/epss_scores-current.csv.gz';

const argv = new Set(process.argv.slice(2));
const REFRESH = argv.has('--refresh');
const limitFlag = process.argv.indexOf('--limit');
const CONSOLE_LIMIT = limitFlag > -1 ? Number(process.argv[limitFlag + 1]) : 5;
const daysFlag = process.argv.indexOf('--days');
/** 「近期新增」窗口。KEV 是累积清单，日报的主体必须是窗口内的新增。 */
const WINDOW_DAYS = daysFlag > -1 ? Number(process.argv[daysFlag + 1]) : 30;

const DAY = 86_400_000;
const today = new Date();

// ---------------------------------------------------------------- 抓取与缓存

/** 带磁盘缓存的 GET。binary=true 时返回 Buffer，否则返回 utf8 文本。 */
async function fetchCached(url, cacheName, { binary = false } = {}) {
  await mkdir(CACHE_DIR, { recursive: true });
  const cachePath = path.join(CACHE_DIR, cacheName);
  if (!REFRESH) {
    try {
      const hit = await readFile(cachePath);
      return binary ? hit : hit.toString('utf8');
    } catch {
      /* 未命中，继续下载 */
    }
  }
  const res = await fetch(url, {
    headers: { 'user-agent': 'security-teach/kev-digest (+learning project)' },
    redirect: 'follow',
  });
  if (!res.ok) throw new Error(`GET ${url} -> HTTP ${res.status}`);
  const body = Buffer.from(await res.arrayBuffer());
  await writeFile(cachePath, body);
  console.error(`↓ ${cacheName} (${(body.length / 1024).toFixed(0)} KiB)`);
  return binary ? body : body.toString('utf8');
}

// ------------------------------------------------------------------ 解析层

/** KEV JSON → 精简记录数组。 */
function parseKev(text) {
  const doc = JSON.parse(text);
  return {
    catalogVersion: doc.catalogVersion,
    dateReleased: doc.dateReleased,
    entries: (doc.vulnerabilities ?? []).map((v) => ({
      cve: v.cveID,
      vendor: v.vendorProject,
      product: v.product,
      name: v.vulnerabilityName,
      dateAdded: v.dateAdded,
      dueDate: v.dueDate,
      ransomware: v.knownRansomwareCampaignUse === 'Known',
      action: v.requiredAction,
      description: v.shortDescription,
      cwes: v.cwes ?? [],
    })),
  };
}

/**
 * EPSS 批量 CSV → Map<cve, {epss, percentile}>。
 * 文件首行是形如 `#model_version:v2025.03.14,score_date:2025-03-14T00:00:00Z` 的注释，
 * 第二行才是 cve,epss,percentile 表头。只保留 KEV 命中的 CVE，避免 25 万行全量驻留。
 */
function parseEpss(gzBuffer, wanted) {
  const text = gunzipSync(gzBuffer).toString('utf8');
  const lines = text.split('\n');
  let modelVersion = null;
  let scoreDate = null;
  let start = 0;
  if (lines[0]?.startsWith('#')) {
    // 形如 `#model_version:v2026.06.15,score_date:2026-10-12T12:00:26Z`。
    // 只按**第一个**冒号切分：score_date 的值本身含冒号。
    for (const part of lines[0].slice(1).split(',')) {
      const idx = part.indexOf(':');
      if (idx < 0) continue;
      const k = part.slice(0, idx);
      const v = part.slice(idx + 1);
      if (k === 'model_version') modelVersion = v;
      if (k === 'score_date') scoreDate = v;
    }
    start = 1;
  }
  const header = lines[start].split(',');
  const colCve = header.indexOf('cve');
  const colEpss = header.indexOf('epss');
  const colPct = header.indexOf('percentile');
  if (colCve < 0 || colEpss < 0) throw new Error('EPSS CSV 表头不符合预期');

  const scores = new Map();
  for (let i = start + 1; i < lines.length; i++) {
    const row = lines[i];
    if (!row) continue;
    const cells = row.split(',');
    const cve = cells[colCve];
    if (!wanted.has(cve)) continue;
    scores.set(cve, { epss: Number(cells[colEpss]), percentile: Number(cells[colPct]) });
  }
  return { scores, modelVersion, scoreDate };
}

// ------------------------------------------------------------------ 打分层

/**
 * 分档：日报要回答的是「今天先动哪个」，所以档位由**时效**决定。
 * KEV 是累积清单（当前 1700+ 条），按分数全局排序只会把 2008 年的老漏洞顶上来；
 * 而且 KEV 条目天然 EPSS 偏高，用概率设阈值会导致一半清单都成「P0」。
 *
 *   P0  窗口内新增 且（勒索团伙在用 或 EPSS ≥ 0.5）—— 立刻排
 *   P1  窗口内新增 —— 本周排
 *   P2  存量 —— 情报只能排到这里；要不要修取决于你有没有这个资产
 *
 * 刻意不做「存量是否逾期」的分档：CISA 给的修复期限对绝大多数历史条目早已过去
 * （实测 1739/1739 全部逾期），拿它分档等于把整张清单压成一个桶。
 */
function tierOf(entry, epss, now) {
  const p = epss?.epss ?? 0;
  const ageDays = (now - new Date(`${entry.dateAdded}T00:00:00Z`)) / DAY;
  if (ageDays <= WINDOW_DAYS) return entry.ransomware || p >= 0.5 ? 'P0' : 'P1';
  return 'P2';
}

const TIER_ORDER = { P0: 0, P1: 1, P2: 2 };

/**
 * 档内排序分（0–100）。只在同一档内部比较，跨档不比较。
 *   40  勒索团伙在用
 *   30  EPSS 概率线性折算
 *   20  新鲜度：窗口内线性衰减到 0
 *   10  已过 CISA 修复期限
 * 这是启发式排序，**不是**风险评分，也不能替代 CISA 的 SSVC 决策模型：
 * SSVC 需要资产暴露面与业务影响，这里没有资产上下文。
 */
function score(entry, epss, now) {
  const p = epss?.epss ?? 0;
  const ageDays = (now - new Date(`${entry.dateAdded}T00:00:00Z`)) / DAY;
  const parts = {
    ransomware: entry.ransomware ? 40 : 0,
    epss: Math.round(Math.min(1, p) * 30),
    fresh: Math.round(20 * Math.max(0, 1 - ageDays / WINDOW_DAYS)),
    overdue: entry.dueDate && new Date(`${entry.dueDate}T00:00:00Z`) < now ? 10 : 0,
  };
  return { total: Object.values(parts).reduce((a, b) => a + b, 0), parts };
}

const TIER_MEANING = {
  P0: `近 ${WINDOW_DAYS} 天新增，且勒索团伙在用或 EPSS ≥ 0.5 — 立刻安排修复`,
  P1: `近 ${WINDOW_DAYS} 天新增 — 本周内安排`,
  P2: '存量——情报只能给你排到这里，是否有这个资产得靠资产测绘',
};

// ------------------------------------------------------------------ 渲染层

const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c]);
// 上游字段缺失/改格式时不要把整条流水线炸掉，降级成原样输出。
const isoDay = (d) => {
  const t = new Date(d);
  return Number.isNaN(t.getTime()) ? String(d ?? '未知') : t.toISOString().slice(0, 10);
};

function renderMarkdown(report) {
  const { generatedAt, sources, items, counts } = report;
  const out = [];
  out.push(`# 漏洞情报日报 ${isoDay(generatedAt)}`);
  out.push('');
  out.push(
    `数据源：CISA KEV 目录版本 \`${sources.kevCatalogVersion}\`（${sources.kevDateReleased}）· ` +
      `FIRST EPSS 模型 \`${sources.epssModelVersion}\`（评分日 ${isoDay(sources.epssScoreDate)}）`,
  );
  out.push('');
  out.push(
    `KEV 全量 ${counts.kevTotal} 条，其中近 ${WINDOW_DAYS} 天新增 ${counts.inWindow} 条` +
      `（已过 CISA 修复期限 ${counts.overdueInWindow} 条）、勒索团伙在用 ${counts.ransomware} 条。`,
  );
  out.push('');
  out.push(
    `分档：P0 ${counts.P0} / P1 ${counts.P1} / P2 ${counts.P2}。EPSS 命中 ${sources.epssMatched}/${counts.kevTotal} 条。` +
      (counts.firstRun ? '（首次运行：state/seen.json 为空，尚无可比的增量基线）' : `本次本地新增 ${counts.newThisRun} 条。`),
  );
  out.push('');
  for (const tier of ['P0', 'P1', 'P2']) {
    const bucket = items.filter((i) => i.tier === tier);
    if (!bucket.length) continue;
    const cap = tier === 'P2' ? 10 : 25;
    out.push(`## ${tier} — ${TIER_MEANING[tier]}（${bucket.length} 条）`);
    out.push('');
    if (tier === 'P2') {
      out.push(
        '_这里只是存量中信号最强的前 10 条，**不是待办清单**：' +
          '只有当你环境里真的跑着对应产品时才需要处理。_',
        '',
      );
    }
    for (const it of bucket.slice(0, cap)) {
      const inWindow = it.ageDays <= WINDOW_DAYS;
      const flags = [
        it.isNew && inWindow ? '🆕' : null,
        it.ransomware ? '💰勒索在用' : null,
        it.overdue && inWindow ? '⏰已过期限' : null,
      ]
        .filter(Boolean)
        .join(' ');
      out.push(`### ${it.cve} — ${it.vendor} ${it.product} ${flags}`);
      out.push('');
      out.push(`- 名称：${it.name}`);
      out.push(
        `- EPSS ${(it.epss * 100).toFixed(2)}%（分位 ${(it.percentile * 100).toFixed(1)}%）· ` +
          `加入 KEV ${it.dateAdded} · 修复期限 ${it.dueDate} · 档内排序分 ${it.score}`,
      );
      out.push(`- 要求动作：${it.action}`);
      const refs = [
        `[NVD ${it.cve}](https://nvd.nist.gov/vuln/detail/${it.cve})`,
        `[EPSS 查询](https://api.first.org/data/v1/epss?cve=${it.cve})`,
        `[KEV 目录](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)`,
      ];
      out.push(`- 参考：${refs.join(' · ')}`);
      out.push('');
    }
    if (bucket.length > cap) {
      out.push(`_（本档共 ${bucket.length} 条，此处只列前 ${cap} 条；完整数据见 digest.json）_`, '');
    }
  }
  out.push('---');
  out.push('');
  out.push(
    '排序分只在档内比较，用来决定「先看哪条」，**不代表资产风险**。' +
      '真实优先级需要资产上下文（暴露面、业务影响），见 CISA SSVC 决策模型。',
  );
  return out.join('\n');
}

const rfc822 = (d) => new Date(d).toUTCString();

function renderRss(report) {
  const items = report.items
    .slice(0, 50)
    .map(
      (it) => `    <item>
      <title>${esc(`[${it.tier}] ${it.cve} ${it.vendor} ${it.product}`)}</title>
      <link>https://nvd.nist.gov/vuln/detail/${it.cve}</link>
      <guid isPermaLink="false">kev:${it.cve}</guid>
      <pubDate>${rfc822(`${it.dateAdded}T00:00:00Z`)}</pubDate>
      <description>${esc(`EPSS ${(it.epss * 100).toFixed(2)}% · ${it.name} · ${it.action}`)}</description>
    </item>`,
    )
    .join('\n');
  return `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>漏洞情报日报（KEV × EPSS）</title>
    <link>https://www.cisa.gov/known-exploited-vulnerabilities-catalog</link>
    <description>已被在野利用的漏洞，按 EPSS 与修复期限排序</description>
    <lastBuildDate>${rfc822(report.generatedAt)}</lastBuildDate>
${items}
  </channel>
</rss>`;
}

// ------------------------------------------------------------------ 主流程

async function main() {
  const now = new Date();

  const kevRaw = await fetchCached(KEV_URL, 'kev.json');
  const { entries, catalogVersion, dateReleased } = parseKev(kevRaw);
  const wanted = new Set(entries.map((e) => e.cve));

  const epssGz = await fetchCached(EPSS_URL, 'epss-current.csv.gz', { binary: true });
  const { scores, modelVersion, scoreDate } = parseEpss(epssGz, wanted);
  const matched = entries.filter((e) => scores.has(e.cve)).length;

  // 增量状态：第一次见到的 CVE 就是「今天的新增」。
  await mkdir(STATE_DIR, { recursive: true });
  const statePath = path.join(STATE_DIR, 'seen.json');
  let seen = {};
  try {
    seen = JSON.parse(await readFile(statePath, 'utf8'));
  } catch {
    /* 首次运行 */
  }

  const items = entries
    .map((e) => {
      const epss = scores.get(e.cve) ?? { epss: 0, percentile: 0 };
      const s = score(e, epss, now);
      const overdue = Boolean(e.dueDate) && new Date(`${e.dueDate}T00:00:00Z`) < now;
      const ageDays = (now - new Date(`${e.dateAdded}T00:00:00Z`)) / DAY;
      return {
        cve: e.cve,
        vendor: e.vendor,
        product: e.product,
        name: e.name,
        dateAdded: e.dateAdded,
        dueDate: e.dueDate,
        ransomware: e.ransomware,
        action: e.action,
        epss: epss.epss,
        percentile: epss.percentile,
        cwes: e.cwes,
        ageDays: Math.round(ageDays),
        score: s.total,
        scoreParts: s.parts,
        overdue,
        tier: tierOf(e, epss, now),
        isNew: !(e.cve in seen),
      };
    })
    .sort(
      (a, b) =>
        TIER_ORDER[a.tier] - TIER_ORDER[b.tier] ||
        b.score - a.score ||
        b.dateAdded.localeCompare(a.dateAdded) ||
        a.cve.localeCompare(b.cve),
    );

  const counts = {
    kevTotal: entries.length,
    inWindow: items.filter((i) => i.ageDays <= WINDOW_DAYS).length,
    newThisRun: items.filter((i) => i.isNew).length,
    firstRun: Object.keys(seen).length === 0,
    ransomware: items.filter((i) => i.ransomware).length,
    overdue: items.filter((i) => i.overdue).length,
    overdueInWindow: items.filter((i) => i.overdue && i.ageDays <= WINDOW_DAYS).length,
    matchedEpss: matched,
    P0: items.filter((i) => i.tier === 'P0').length,
    P1: items.filter((i) => i.tier === 'P1').length,
    P2: items.filter((i) => i.tier === 'P2').length,
  };

  const report = {
    generatedAt: now.toISOString(),
    sources: {
      kevUrl: KEV_URL,
      kevCatalogVersion: catalogVersion,
      kevDateReleased: dateReleased,
      epssUrl: EPSS_URL,
      epssModelVersion: modelVersion,
      epssScoreDate: scoreDate,
      epssMatched: matched,
    },
    counts,
    items,
  };

  await mkdir(OUT_DIR, { recursive: true });
  const day = isoDay(now);
  await writeFile(path.join(OUT_DIR, `${day}.md`), renderMarkdown(report));
  await writeFile(path.join(OUT_DIR, `${day}.json`), JSON.stringify(report, null, 2));
  await writeFile(path.join(OUT_DIR, 'feed.xml'), renderRss(report));
  await writeFile(statePath, JSON.stringify(Object.fromEntries(items.map((i) => [i.cve, day])), null, 2));

  console.error(
    `KEV ${counts.kevTotal} 条｜近 ${WINDOW_DAYS} 天新增 ${counts.inWindow}｜EPSS 命中 ${matched}` +
      `｜P0 ${counts.P0} P1 ${counts.P1} P2 ${counts.P2}`,
  );
  console.error(`→ out/${day}.md · out/${day}.json · out/feed.xml`);
  for (const it of items.slice(0, CONSOLE_LIMIT)) {
    console.log(
      `${it.tier} ${String(it.score).padStart(3)} ${it.cve.padEnd(16)} ` +
        `+${String(it.ageDays).padStart(4)}d  EPSS ${(it.epss * 100).toFixed(2).padStart(6)}%  ` +
        `${it.vendor} ${it.product}${it.ransomware ? '  💰' : ''}`,
    );
  }
}

main().catch((err) => {
  console.error(`失败：${err.message}`);
  process.exitCode = 1;
});
