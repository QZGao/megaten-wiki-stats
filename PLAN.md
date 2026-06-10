# Skills Module Cleanup Plan

## Priorities

- Preserve exact rendered output unless a behavior change or bug fix is explicitly requested.
- Prefer efficiency improvements over file splitting or cosmetic refactors.
- Keep batches small enough that sandbox2 vs sandbox3 exact render parity can isolate regressions quickly.
- Avoid distant predicate helpers and one-use locals unless they remove repeated work in a hot path.
- Keep helpers close to the renderer that uses them.
- Isolate visible output fixes from parity-preserving cleanup.

## Verification

After each local cleanup batch:

1. Run Lua parse checks for changed Lua modules.
2. Run `git diff --check`.
3. Report changed upload targets.
4. Wait for on-wiki sandbox upload.
5. Run `python .\compare_sandbox_render.py`.
6. Stop immediately if exact HTML comparison shows any difference.

## Cleanup Order

### 1. Hot-path low-risk efficiency

- In `Skills.Module.lua`, cache the article-namespace check used by `cate()`.
  - Current issue: `mw.title.getCurrentTitle():inNamespace("")` is called every time a category is emitted.
  - Expected benefit: removes repeated title lookups across all category-heavy render paths.
  - Risk: very low if cached lazily inside `cate()`.

- In `Skills.Module.lua`, build a module-level race alias index for `getRace()`.
  - Current issue: every `getRace()` call scans all `race_names` entries and their aliases.
  - Expected benefit: constant-time lookup for the common race/category path.
  - Notes: no duplicate positional race aliases were found. Preserve the existing special-case branches before index lookup.
  - Risk: low if output construction keeps the same metadata fields and ordering.

- In `Skills.Module.lua`, cache numeric conversions inside `bar()`.
  - Current issue: `tonumber(stat)` and `tonumber(stat2)` are called repeatedly per stat bar.
  - Expected benefit: cheaper stat-bar rendering across most top stat tables.
  - Risk: low if `i`, non-numeric, comparison, and old/new cases stay in the same order.

- In `Skills/Render/Affinity.Module.lua`, cache numeric conversion inside `formatResistance()`.
  - Current issue: `tonumber(v)` is called repeatedly for every resistance cell.
  - Expected benefit: cheaper `restype` rendering.
  - Risk: low if symbolic values still short-circuit before numeric comparisons.

- In `Skills/Render/Stats.Module.lua`, move the SMT4 specialty icon table out of the inner loop.
  - Current issue: `prop.skilltypes = { ... }` is allocated inside the per-specialty inner loop.
  - Expected benefit: removes repeated table allocation and avoids unnecessary mutation of `prop`.
  - Risk: low if the table contents and output order are unchanged.

### 2. Loop parsing efficiency

- In `Skills/Render/Stats.Module.lua`, replace `mw.text.split(v1 .. "\\", "\\")` pair parsing in specialty handling with direct two-field parsing.
  - Affected areas: SMT4 specialty and SMT5 skill potential.
  - Expected benefit: avoids per-line split-table allocation when only two fields are used.
  - Risk: moderate because malformed specialty lines must preserve legacy behavior.

- In `Skills/Render/Affinity.Module.lua`, replace `mw.text.split(v1 .. "\\", "\\")` pair parsing in SMT9 resistance levels with direct two-field parsing.
  - Expected benefit: avoids per-line split-table allocation.
  - Risk: moderate for malformed lines and trailing separators.

- In `Skills/Render.Module.lua`, reduce split allocation for P3R Theurgy characteristics and P5R Persona traits.
  - Current issue: branches split once to count rows, then split individual lines again.
  - Expected benefit: small but local cleanup.
  - Risk: low if single-row and multi-row behavior stays distinct.

### 3. SkillTable row-loop efficiency

- In `Skills/Render/SkillTable.Module.lua`, consider a newline iterator for long skill-list parameters.
  - Current issue: every renderer uses `mw.text.split(..., "\n")`, allocating a table of all rows before rendering.
  - Expected benefit: lower memory churn for long skill lists.
  - Risk: moderate because trailing empty lines and empty skill-name errors must remain exact.

- In `Skills/Render/SkillTable.Module.lua`, continue replacing split-table parsing with direct field parsing where only the first two fields are used.
  - Current status: `splitBackslashPair()` already handles several row types.
  - Remaining target: combo attack parsing still uses `mw.text.split(v1, "\\")` because it needs all fields.
  - Risk: low for two-field formats, higher for combo attacks.

- In `Skills/Render/SkillTable.Module.lua`, audit shared row assembly for repeated `skillcell`, `cost`, and `effect` setup.
  - Goal: reduce duplicate per-row work only where it does not hide game-specific behavior.
  - Risk: moderate. Avoid broad generic row builders unless they remove real repeated work.

### 4. Metadata lookup cleanup

- In `Skills.Module.lua`, compute and pass `gameData` and `baseGameData` through context.
  - Current issue: render modules repeatedly index `getGames.games[gameg]` and `getGames.games[game]`.
  - Expected benefit: cheaper and clearer access to game metadata.
  - Risk: low if existing `getGames` remains available during migration.

- In `Skills/Render.Module.lua`, stop mutating shared SMT3 game metadata for `colorbg`.
  - Current issue: `getGames.games[gameg].colorbg = getGames.games[gameg].colorbg2` mutates shared metadata.
  - Expected benefit: safer style construction.
  - Risk: moderate because output color behavior must remain exact.

- In `Skills/Style.Module.lua`, avoid mutating `gameData.statt` while building styles.
  - Current issue: defaulting `gameData.statt` writes to shared metadata.
  - Expected benefit: cleaner style isolation.
  - Risk: low if `styles.barh` still receives `#529488` as the fallback.

### 5. Stats render cleanup

- In `Skills/Render/Stats.Module.lua`, reduce repeated default assignment clusters where local defaults are clearer and do not change behavior.
  - Examples: SMT4/SMT5/SH2 affinity defaults, PQ drop defaults, Devil Children defaults.
  - Risk: low to moderate depending on whether `nil` and empty string must remain distinct.

- In `Skills/Render/Stats.Module.lua`, keep cleaning high-traffic shared layouts before rare branches.
  - Priority: SMT4/SMT5, Persona/P5X, Metaphor, Devil Survivor.
  - Goal: remove repeated metadata lookups and repeated string fragments without splitting more modules.

- In `Skills/Render/Stats.Module.lua`, leave branch extraction for later unless it directly improves runtime behavior.
  - The module is large, but pure movement does not help performance.
  - Any function extraction should be justified by repeated work, not line count.

### 6. Affinity render cleanup

- In `Skills/Render/Affinity.Module.lua`, remove local wrapper closures inside `renderPost()`.
  - Current issue: `resoutput()` and `outputResAsPercent()` are recreated per render and only forward to module-level helpers.
  - Expected benefit: small allocation reduction.
  - Risk: low.

- In `Skills/Render/Affinity.Module.lua`, consolidate repeated P2 element label setup only if kept local to the P2 branches.
  - Current issue: P2 labels are built in both the regular P2 affinity branch and the `restype` branch.
  - Expected benefit: less duplication.
  - Risk: moderate because helper distance can hurt maintainability. Keep it close.

- In `Skills/Render/Affinity.Module.lua`, audit branch condition precedence.
  - Example: `gameg == "pq" or gameg == "pq2" and (...)` relies on Lua precedence.
  - This may be intentional. Do not change behavior without a dedicated parity check.

### 7. Drops and coordinator cleanup

- In `Skills/Render/Drops.Module.lua`, reduce repeated defaulting where it is branch-local and parity-safe.
  - P4 and P5-family reward rows are candidates.
  - P5X hidden-row behavior must remain unchanged.

- In `Skills/Render.Module.lua`, consider localizing long SMT3 recruit text mapping.
  - Current issue: a long `elseif` chain maps normalized recruit strings to output text.
  - Expected benefit: faster lookup and easier maintenance.
  - Risk: moderate. Preserve exact aliases and output strings.

- In `Skills/Render.Module.lua`, avoid repeated title lookup for SMTIM and Dx2 `seealso` defaults after `cate()` caching is done.
  - Expected benefit: small.
  - Risk: low.

### 8. Correctness fixes to isolate

- In `Skills/Render/Stats.Module.lua`, fix the Another Bible invalid `tech` fallback.
  - Current issue: when a tech is missing and has no alias, code appears to assign `prop.techc.effect` while `prop.techc` is nil.
  - This is a bug fix, not parity cleanup.
  - Test with an invalid Another Bible technique sample.

- In `Skills/Render/Stats.Module.lua`, remove the duplicate Catherine `mp` default line.
  - Current issue: `if not prop.mp then prop.mp = "?" end` appears twice.
  - Risk: very low, but keep it in a dead-code batch.

- In `Skills/Render/Stats.Module.lua`, remove the no-op `if not prop.spell then prop.spell = prop.spell end`.
  - Current issue: no behavior effect.
  - Risk: very low.

- In `Skills/Render/SkillTable.Module.lua`, fix the malformed P5S combo attack span style.
  - Current issue: `<span style="font-weight:bold;>` is missing a quote.
  - This changes visible HTML and must be isolated as a bug fix.
  - Test with a P5S combo attack sample.

### 9. Later structural cleanup

- Do not split more files unless a module becomes difficult to verify after efficiency work.
- If splitting resumes, prefer the existing structure:
  - `Module:Skills`
  - `Module:Skills/Style`
  - `Module:Skills/Row`
  - `Module:Skills/Render`
  - `Module:Skills/Render/Stats`
  - `Module:Skills/Render/Affinity`
  - `Module:Skills/Render/Drops`
  - `Module:Skills/Render/SkillTable`
- Avoid creating small one-purpose modules for miscellaneous sections.
- Keep exact render parity as the gate after each batch.
