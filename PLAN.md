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

- Convert the top-level independent `if game...` / `if gameg...` chain in `Skills/Render/Stats.Module.lua` into a mutually exclusive dispatch where safe.
- Prioritize high-traffic game families first.
- Do not split into many new files unless performance or maintainability clearly benefits.

Notes:

- This is the largest runtime cleanup and the highest parity risk.
- Preserve legacy ordering for any branch that can intentionally emit alongside another branch.

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
