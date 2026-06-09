# Skills Module Cleanup Plan

## Priorities

- Preserve exact rendered output unless a behavior change is explicitly requested.
- Prefer efficiency improvements over purely aesthetic refactors.
- Keep cleanup batches small enough that sandbox2 vs sandbox3 exact render parity can identify regressions quickly.
- Avoid distant predicate helpers and one-use boolean locals unless they remove real repeated work.
- Keep helpers close to the renderer that uses them.

## Cleanup Order

### 1. Low-risk efficiency cleanup

- In `Skills/Render/Affinity.Module.lua`, load `Module:Skills/<game>/res` once inside the `restype` branch and reuse the local `restypes` table.
- In `Skills/Render.Module.lua`, split P3R Theurgy characteristics and P5R Persona traits once, then reuse the resulting table for row count and iteration.
- Remove unused local bindings from `Skills/Render.Module.lua`.
- Remove unused context fields passed from `Skills.Module.lua` after confirming no child module consumes them.

Verification:

- Run Lua parse checks.
- Run `git diff --check`.
- Upload changed modules.
- Run sandbox exact HTML comparison.

### 2. Remove dead or accidental code

- Remove unused `createEquipTable` from `Skills.Module.lua` if still unreferenced.
- Remove its context plumbing.
- Audit accidental globals, especially `inherit = "Inherit"` in `bar`.
- Audit bare `race == "Boss"` checks in `Skills/Render/Stats.Module.lua`.

Notes:

- Accidental global fixes can technically alter behavior. Keep them isolated from unrelated cleanup.
- If a questionable legacy branch may depend on a bug, verify with sandbox output before continuing.

### 3. SkillTable parsing efficiency

- In `Skills/Render/SkillTable.Module.lua`, replace repeated `mw.text.split(v1 .. "\\", "\\")` patterns when only the first two parts are needed.
- Avoid table allocation per skill row where direct string matching can extract `skill` and `level` or metadata.
- Keep row renderers separate enough that game-specific behavior remains visible.

Verification:

- Compare after each renderer family, not after rewriting the whole file.

### 4. Persona top stat block cleanup

- In `Skills/Render/Stats.Module.lua`, clean the Persona 3/4/5/P5X top stat block.
- Remove the per-render table allocation in `hasAnyStatBarValue(prop, { "str", "magic", "vit", "agl", "luc" })`.
- Unify duplicated header/value assembly between stat-bar and no-stat-bar branches.
- Keep the pending top stat merge behavior unchanged.

Verification:

- Use P3, P4, P5, P5X, and no-stat-bar cases in the sandbox comparison pages.

### 5. Stats render dispatch

Goal:

- Reduce the number of top-level game checks in `Skills/Render/Stats.Module.lua` without changing rendered output.
- Keep high-traffic game families earlier and cheaper to reach.
- Preserve every branch that intentionally emits supplemental output in addition to the main top-stat table.

Scope:

- Work inside `Skills/Render/Stats.Module.lua` only unless unused context plumbing becomes obvious after the cleanup.
- Do not split more modules during this step.
- Do not rewrite individual game render bodies unless the change directly supports mutually exclusive dispatch.

Branch classification:

- Main render branches should be mutually exclusive because each page has one normalized `game` and one fallback `gameg`.
- Supplemental branches must stay separate from the main dispatch:
  - Persona 2/P5-family `prop.quote` rendering can emit before the main stat table.
  - Any pending top-stat handoff through `ctx.pending_top_stats` must keep its current timing relative to affinity and drop rendering.
- Category-only or side-effect-heavy branches should not be moved until their output ordering is understood from exact HTML comparison.

Implementation phases:

1. Add a local dispatch key near the top of `p.renderTop`.
   - Use `gameg` for fallback-family renderers by default.
   - Use `game` only for game-specific pages that cannot be represented by `gameg`, such as `mt1`, `mt2`, `kmt1`, and `kmt2`.
   - Avoid allocating a handler table per render.

2. Convert the clearly exclusive early branches first.
   - Start with `mt1`, `mt2`, `kmt1/kmt2`.
   - Then convert SMT-family branches: `smt1/smt2/smtif/20xx`, `smt9`, `smt3`, `smtim`, `smtsj`, `smt4/smt4a`, `smt5/smt5v`, and `ldx2`.
   - After each conversion group, run parser and exact sandbox comparison before continuing.

3. Convert mid-file families after the SMT group passes.
   - Last Bible and Another Bible.
   - Majin Tensei/Ronde.
   - Devil Summoner/Soul Hackers/Soul Hackers 2.
   - Raidou and Giten.

4. Convert Persona-like families only after the earlier groups pass.
   - Keep the quote block outside dispatch.
   - Keep `p2is/p2ep` as its own main branch.
   - Keep the shared `p3/p3re/p4/p5/p5r/p5s/p5x` top-stat branch as one dispatch target.
   - Keep `pq/pq2` separate because its table shape is unrelated to the shared Persona top-stat branch.

5. Convert remaining smaller families last.
   - Catherine.
   - Digital Devil Saga.
   - Devil Survivor.
   - Devil Children groups.
   - Metaphor can be converted after Persona because it also participates in top-stat merge behavior.

Preferred structure:

- Use an `if` / `elseif` dispatch chain at the top level, not a per-render table of closures.
- Group related games in compact branch conditions when they share a renderer body.
- Keep local variables close to the branch that uses them.
- Do not introduce generic helpers just to shorten branch conditions unless they remove repeated work in multiple branches.

Verification checkpoints:

- Before implementation, confirm the sandbox pages include at least one sample from:
  - MT/KMT.
  - SMT mainline.
  - Persona with stat bars.
  - Persona without stat bars.
  - P5X with hidden Arcana/reward rows.
  - Metaphor.
  - Devil Children or another late-file branch.
- After each implementation phase:
  - Run Lua parse checks.
  - Run `git diff --check`.
  - Upload changed modules.
  - Run exact sandbox comparison.
  - Stop immediately if the comparison shows any HTML difference.

Notes:

- This is the largest runtime cleanup and the highest parity risk.
- Preserve legacy ordering for any branch that can intentionally emit alongside another branch.
- Do not optimize by changing category order, quote placement, or pending top-stat timing.

### 6. Affinity defaulting cleanup

- Reduce repeated `if not prop.x then prop.x = "-" end` clusters where a nearby local table loop is clearer and does not hide behavior.
- Keep default values local to the game branch that owns them.
- Avoid a shared defaulting helper unless multiple branches truly share the same field set and default value.

### 7. Row renderer cleanup

- Consider replacing the `Skills/Row.Module.lua` row-code `elseif` chain with a local row-handler map.
- Keep this late because `#invoke:row` is smaller and lower impact than full stats rendering.

## Ongoing Verification

After each local cleanup batch:

1. Run Lua parsing checks.
2. Run `git diff --check`.
3. Update the corresponding on-wiki sandbox modules.
4. Run the sandbox2 vs sandbox3 exact HTML comparison.

Do not begin the next cleanup batch until exact render parity passes.
