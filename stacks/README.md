# Stacks

Lovable changed its default scaffold on 2026-05-13 (2026-06-22 for Enterprise). Where LV writes backend code depends on which one a project uses, so the lane map does too.

| Stack | Detected when | LV's backend lives in |
|-------|---------------|-----------------------|
| `tanstack-start` | `@tanstack/react-start` in `package.json`, `src/routes/__root.tsx`, or a `.lovable/project.json` naming a `tanstack` template. Also the default for an empty project. | `**/*.functions.ts`, `**/*.server.ts`, `src/routes/api/**`, `drizzle/**` |
| `vite-edge` | `vite.config.*` plus `src/pages/`, `src/App.tsx` or `index.html`, without TanStack Start | `supabase/functions/**`, `supabase/migrations/**` |

`bin/install.sh` detects the stack (override with `--stack <name>`) and uses three files from the matching folder:

- `OWNERSHIP.md` → copied to the project root. Scripts parse its table, so it is the single source of the lane map.
- `cc-stack.md` → inserted into `CLAUDE.md` at `<!-- cclv:stack cc-stack -->` (tech stack, key paths, how LV consumes contracts).
- `lv-lanes.md` → inserted into `control-center/lovable-knowledge.md` at `<!-- cclv:stack lv-lanes -->` (LV's lane, contracts, backend rules).

Inserts only happen in files the installer creates; it never edits a file that already existed.
