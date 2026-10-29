export const meta = {
  name: 'kit-refresh',
  description: 'Check Spec Kit, Claude models, Claude Code, Lovable and AGENTS.md sources for changes since the last refresh, verify what matters, and write a dated refresh report for cclv-specboot',
  whenToUse: 'Monthly, or after a Claude Code / Lovable / Spec Kit release. Args (all optional): {today: "YYYY-MM-DD", maxVerifyPerArea: 2, areas: ["lovable", ...] to force research of those areas}',
  phases: [
    { title: 'Diff', detail: 'machine checks vs docs/maintenance/last-refresh.md' },
    { title: 'Research', detail: 'one agent per changed area, retried once if it returns nothing' },
    { title: 'Verify', detail: 'one skeptic per high-impact finding, capped per area' },
    { title: 'Report', detail: 'write docs/maintenance/refresh-<date>.md and update the snapshot' },
  ],
}

// Lessons from the 2026-10-28 refresh (5+ hours, two tracks lost to API timeouts):
// diff first and research only what changed, retry a failed track once, verify
// only high-impact findings that drive an edit, and log whatever a cap drops.

const opts = args || {}
const MAX_VERIFY = Number.isInteger(opts.maxVerifyPerArea) && opts.maxVerifyPerArea >= 0 ? opts.maxVerifyPerArea : 2
const AREAS = ['spec-kit', 'claude-models', 'claude-code', 'lovable', 'lovable-scaffold', 'agents-md']
const FORCED = Array.isArray(opts.areas) ? opts.areas.filter(x => AREAS.includes(x)) : []

const COMMON = `You work on the cclv-specboot kit; the current working directory is its repo root. The kit sets up a multi-agent workflow: Claude Code (CC) as architect and frontend, Lovable (LV) as backend, a QA subagent (CW), with GitHub Spec Kit as the optional spec layer. Its docs are README.md, INSTALL.md, PHILOSOPHY.md, CONTRIBUTING.md, BOOTSTRAP-PROMPT.md, template/ and stacks/. Read docs/maintenance/watch-sources.md (what to check) and docs/maintenance/last-refresh.md (the previous snapshot) first.
Rules: never call mcp__lovable__* tools (they act on a real Lovable account and spend credits); reading their schemas through ToolSearch is fine. Load WebFetch/WebSearch with ToolSearch "select:WebFetch,WebSearch" if they aren't loaded. Report nothing from memory: every claim needs a URL or command output you actually saw.`

const DIFF = {
  type: 'object',
  properties: {
    today: { type: 'string' },
    since: { type: 'string' },
    areas: { type: 'array', items: { type: 'object', properties: {
      area: { type: 'string', enum: AREAS },
      changed: { type: 'boolean' },
      summary: { type: 'string' },
      evidence: { type: 'array', items: { type: 'string' } },
    }, required: ['area', 'changed', 'summary', 'evidence'] } },
    snapshot_now: { type: 'string' },
  },
  required: ['today', 'since', 'areas', 'snapshot_now'],
}

const FINDINGS = {
  type: 'object',
  properties: {
    area: { type: 'string' },
    findings: { type: 'array', items: { type: 'object', properties: {
      claim: { type: 'string' },
      source_urls: { type: 'array', items: { type: 'string' } },
      impact: { type: 'string', enum: ['high', 'medium', 'low'] },
      repo_refs: { type: 'array', items: { type: 'string' } },
      proposed_edit: { type: 'string' },
    }, required: ['claim', 'source_urls', 'impact', 'repo_refs', 'proposed_edit'] } },
  },
  required: ['area', 'findings'],
}

const VERDICT = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['confirmed', 'corrected', 'refuted'] },
    corrected_claim: { type: 'string' },
    reasoning: { type: 'string' },
  },
  required: ['verdict', 'reasoning'],
}

phase('Diff')
const diff = await agent(`${COMMON}

Run the machine checks in docs/maintenance/watch-sources.md and compare each with docs/maintenance/last-refresh.md. ${opts.today ? `Today is ${opts.today}.` : 'Get today\'s date with `date +%F`.'}
For each area (${AREAS.join(', ')}) say whether anything changed that could affect the kit, with a one-paragraph summary and evidence (URLs or command output lines). Be conservative: a new release counts as changed only if its notes touch something the kit documents (installation, commands, file conventions, model names or aliases, effort, MCP tools and their semantics, git sync, scaffold layout, which tools read AGENTS.md).
Also return snapshot_now: the bullet list of last-refresh.md updated with what you observed (keep unchanged bullets as they are, and keep the "Open, unverified" bullet current).`,
  { label: 'diff', phase: 'Diff', schema: DIFF, effort: 'medium' })

if (!diff) return { error: 'The diff agent returned nothing. Re-run the workflow (or resume it with resumeFromRunId).' }

// One entry per area, even if the diff agent left some out.
const areas = AREAS.map(name => diff.areas.find(x => x.area === name)
  || { area: name, changed: false, summary: 'not reported by the diff agent', evidence: [] })
const missing = areas.filter(x => x.summary === 'not reported by the diff agent').map(x => x.area)
if (missing.length) log(`Diff agent did not report: ${missing.join(', ')} (treated as unchanged unless forced)`)
const targets = areas.filter(x => x.changed || FORCED.includes(x.area))
log(`Since ${diff.since}: ${targets.length ? targets.map(t => t.area).join(', ') : 'nothing'} to research; unchanged: ${areas.filter(x => !targets.includes(x)).map(x => x.area).join(', ') || 'none'}`)

async function retryOnce(run, label) {
  const first = await run()
  if (first) return first
  log(`${label} returned nothing (API timeout?); retrying once`)
  return run()
}

const research = await pipeline(
  targets,
  t => retryOnce(() => agent(`${COMMON}

Area: ${t.area}. What the machine checks found: ${t.summary}
Evidence: ${t.evidence.join(' | ')}

Read the docs listed for this area in watch-sources.md and pin down exactly what changed. Then grep the repo (README.md, INSTALL.md, PHILOSOPHY.md, BOOTSTRAP-PROMPT.md, CONTRIBUTING.md, template/, stacks/, bin/) for every statement about this area, and report each one that is now wrong, outdated or incomplete. Each finding gives: the claim (what is true now), its sources, its impact (high = an instruction in the kit is wrong today, or a big speed win for the CC↔LV loop; medium = a useful addition; low = trivia), the repo file:line refs it affects, and the concrete edit you propose. Leave dated history (CHANGELOG entries, docs/decisions/, docs/superpowers/specs/) alone, except to propose a dated note. Return an empty list if nothing in the kit is affected.`,
    { label: `research:${t.area}`, phase: 'Research', schema: FINDINGS }), `research:${t.area}`),
  (r, t) => {
    if (!r) return { area: t.area, failed: true, findings: [] }
    const findings = r.findings.map((f, i) => ({ ...f, id: `${t.area}-${i + 1}` }))
    const high = findings.filter(f => f.impact === 'high')
    const checked = high.slice(0, MAX_VERIFY)
    if (high.length > checked.length) {
      log(`${t.area}: ${high.length - checked.length} high-impact finding(s) over the verify cap (${MAX_VERIFY}) stay unverified`)
    }
    return parallel(checked.map(f => () => agent(`${COMMON}

Adversarially fact-check this claim as of ${diff.today}: "${f.claim}"
Cited sources: ${f.source_urls.join(' , ')}
Open the sources and look for anything newer that contradicts them. Try hard to refute the claim. Return "confirmed" only if a primary source you opened supports it as true today, "corrected" (with corrected_claim) if it is partly wrong, and "refuted" otherwise.`,
      { label: `verify:${f.id}`, phase: 'Verify', schema: VERDICT }).then(v => ({ id: f.id, v }))))
      .then(votes => ({
        area: t.area,
        findings: findings.map(f => {
          const hit = votes.filter(Boolean).find(x => x.id === f.id && x.v)
          return hit
            ? { ...f, verdict: hit.v.verdict, corrected_claim: hit.v.corrected_claim, verifier_note: hit.v.reasoning }
            : { ...f, verdict: 'unverified' }
        }),
      }))
  },
)

phase('Report')
const failed = targets.filter((t, i) => !research[i] || research[i].failed).map(t => t.area)
if (failed.length) log(`Research failed for: ${failed.join(', ')} — the report lists them`)

const summary = await agent(`${COMMON}

Write docs/maintenance/refresh-${diff.today}.md, then replace the bullet list in docs/maintenance/last-refresh.md with the snapshot below (set its Date bullet to ${diff.today}; keep the file's header paragraph). Exceptions to the snapshot: for areas whose research failed (${failed.join(', ') || 'none'}), keep their previous bullets unchanged so the next run sees them as changed again; and don't record anything a verifier refuted. Do not edit any other file: proposed edits go in the report for the maintainer to apply.

Report structure:
1. Summary: what changed since ${diff.since}, per area.
2. Proposed edits, highest impact first. For each: file:line, the edit, the claim, its verdict (confirmed / corrected → use the corrected claim / unverified — say so plainly), and sources.
3. Dropped: refuted findings, one line each with the reason.
4. Checked with no change: the unchanged areas.
5. Failed: research tracks that returned nothing (${failed.join(', ') || 'none'}); re-run with areas: [...] to retry them.

Diff:
${JSON.stringify(areas)}

Findings:
${JSON.stringify(research.filter(r => r && !r.failed))}

Snapshot now:
${diff.snapshot_now}

End with a five-line summary of the report as your final message.`,
  { label: 'report', phase: 'Report' })

return {
  today: diff.today,
  since: diff.since,
  researched: targets.map(t => t.area),
  failed,
  report: `docs/maintenance/refresh-${diff.today}.md`,
  summary,
}
