# Skills Module Cleanup Plan

## Priorities

- Preserve exact rendered output unless a behavior change or bug fix is explicitly requested.
- Prefer efficiency improvements over file splitting or cosmetic refactors.
- Keep batches small enough that sandbox2 vs sandbox3 exact render parity can isolate regressions quickly.
- Avoid distant predicate helpers and one-use locals unless they remove repeated work in a hot path.
- Keep helpers close to the renderer that uses them.
- Isolate visible output fixes from parity-preserving cleanup.
- Use the local pywikibot scripts for sandbox upload and render comparison; do not pause for manual sandbox uploads.

## Automation Scripts

- `scripts/sync_from_live.py`
  - Purpose: maintainer-run reset tool for refreshing local `src/` files and sandbox module pages from live module pages.
  - Default: dry-run only.
  - `--write`: replaces local `src/` files with live source and replaces sandbox pages with live source plus scoped `/sandbox` module references.

- `scripts/upload_modules.py`
  - Purpose: upload local `src/` files to wiki module pages.
  - Default destination: sandbox pages, with scoped references to the tracked module set rewritten to `/sandbox`.
  - `--live`: publish exact local source to live module pages instead of sandbox pages.
  - Default: dry-run only.
  - `--write`: saves changed target pages.
  - Live publish should still be explicit; use `--live --write` only when the user asks to publish live.

- `scripts/compare_sandbox_render.py`
  - Purpose: compare `User:Greykid/sandbox2` and `User:Greykid/sandbox3` rendered parser HTML.
  - Uses pywikibot only.
  - For each page, purges, queries rendered HTML, retries purge/query once if Lua timeout text appears, then compares exact HTML by default.

## Verification

After each local cleanup batch:

1. Run Lua parse checks for changed Lua modules.
2. Run `git diff --check`.
3. Upload local source to sandbox pages:
   - `.\.venv\Scripts\python.exe .\scripts\upload_modules.py --write`
4. Run exact sandbox render comparison:
   - `.\.venv\Scripts\python.exe .\scripts\compare_sandbox_render.py`
5. Stop immediately if exact HTML comparison shows any unexpected difference.
6. Report changed files, sandbox upload result, and comparison result.

## Cleanup Order

### 1. Property argument normalization

- In `Skills.Module.lua`, investigate replacing the per-render nested loop in `get_prop()` with a module-level property alias index.
  - Current issue: every render loops through every `Module:Property_names` canonical key and every alias name.
  - Expected benefit: constant-time lookup for each supplied argument, instead of scanning all aliases.
  - Required audit: confirm duplicate aliases, default handling, and current precedence when multiple aliases for the same property are provided.
  - Risk: moderate. This is entry-point behavior for every game, so exact parity must be checked broadly.

### 2. Game alias normalization

- In `Skills.Module.lua`, consider replacing the long independent `if` chain that normalizes `game` with a local alias table.
  - Current issue: many string comparisons run on every render.
  - Expected benefit: cheaper and easier to audit game alias handling.
  - Required audit: preserve current independent-`if` quirks, especially `smti`, which currently resolves to `giten` after passing both `smti` checks.
  - Risk: moderate. Do only after property normalization, or as a separate batch.

### 3. Coordinator low-risk cleanup

- In `Skills/Render.Module.lua`, build the root wrapper table string once.
  - Current issue: the default root table string is built, then rebuilt for `sh2`.
  - Expected benefit: small but very safe allocation reduction.
  - Approach: choose the border color first, then concatenate one root string.
  - Risk: very low.

- In `Skills/Render.Module.lua`, reduce repeated title lookup for SMTIM `seealso`.
  - Current issue: `mw.title.getCurrentTitle().text` is read inside the SMTIM branch.
  - Expected benefit: small.
  - Risk: low. Keep this branch-local unless another title-text lookup is also being touched.

- In `Skills/Render.Module.lua`, leave the `appendTopAffinityTable` closure alone unless touching top-stat coordination.
  - Current issue: one closure is created per render.
  - Expected benefit: tiny.
  - Risk: low, but not worth API churn before hotter work.

### 4. P3RE and P5R trait parsing

- In `Skills/Render.Module.lua`, remove `mw.text.split()` from P3RE Theurgy characteristic rows.
  - Current issue: multi-row P3RE `ptraits` allocates a split table.
  - Expected benefit: lower allocation and parity with the manual scan already used by P5R Persona traits.
  - Approach: count newline rows with `string.find`, then iterate by slice.
  - Risk: low to moderate. Preserve single-row versus multi-row output and invalid-name messages.

- In `Skills/Render.Module.lua`, consider extracting only local trait-row formatting after parity passes.
  - Current issue: P3RE and P5R single-row and multi-row branches duplicate invalid/valid trait rendering.
  - Expected benefit: small clarity improvement.
  - Risk: low if kept local and not generalized across unrelated games.

### 5. SMT9 resistance level parsing

- In `Skills/Render/Affinity.Module.lua`, remove `mw.text.split()` from SMT9 `reslevels`.
  - Current issue: `prop.reslevels` is replaced with a split table and then iterated.
  - Expected benefit: lower allocation and no mutation of `prop.reslevels`.
  - Approach: use the existing direct pair parser plus a local newline iterator.
  - Risk: moderate. Preserve malformed-line and trailing-line behavior exactly.

- In `Skills/Render/Affinity.Module.lua`, stop writing `prop.resleveltypes`.
  - Current issue: resistance level defaults are stored on `prop`, even though they are branch-local rendering state.
  - Expected benefit: cleaner data flow and less mutation.
  - Approach: use a local `resleveltypes` table with the same default values.
  - Risk: low if final output references are unchanged.

### 6. SkillTable effect formatting

- In `Skills/Render/SkillTable.Module.lua`, replace repeated `string.format()` calls in `formatExpandedSkillEffect()` with direct concatenation.
  - Current issue: the format strings are dynamically concatenated before `string.format()` is called.
  - Expected benefit: cheaper effect formatting for long learned-skill tables.
  - Risk: low if whitespace and newline placement stay exact.

- In `Skills/Render/SkillTable.Module.lua`, cache repeated visual fragments inside `formatExpandedSkillEffect()`.
  - Current issue: the same badge span prefix is rebuilt for smirk, chain, conditional, nested chain, and boost-level effects.
  - Expected benefit: small repeated-string construction reduction.
  - Risk: low if kept inside the function.

### 7. SkillTable small lookup cleanup

- In `Skills/Render/SkillTable.Module.lua`, cache the P3/P3RE fusion skill lookup.
  - Current issue: `data.skills[prop.fskills]` is indexed repeatedly in `renderPersona3FusionRows()`.
  - Expected benefit: tiny but very safe.
  - Risk: very low.

- In `Skills/Render/SkillTable.Module.lua`, audit similar repeated lookups only where the same key is indexed several times in one branch.
  - Expected benefit: small hot-path clarity and speed.
  - Risk: low. Avoid broad helper extraction.

### 8. P5S combo parsing

- In `Skills/Render/SkillTable.Module.lua`, consider replacing `mw.text.split(v1, "\\")` in P5S combo attacks.
  - Current issue: each combo row allocates all fields as a table.
  - Expected benefit: lower allocation for combo-heavy P5S rows.
  - Risk: higher than other parsing work because this branch needs all fields and rowspans depend on the field count.
  - Recommendation: defer until lower-risk parsing cleanup has passed exact parity.

### 9. Affinity defaulting and branch cleanup

- In `Skills/Render/Affinity.Module.lua`, reduce repeated default assignment clusters only when branch-local and parity-safe.
  - Current issue: top and post affinity branches assign many `prop.* = prop.* or "-"` values.
  - Expected benefit: mostly clarity, limited runtime impact.
  - Risk: moderate because nil and empty-string behavior can differ.

- In `Skills/Render/Affinity.Module.lua`, review the PQ/PQ2 condition precedence.
  - Current issue: `gameg == "pq" or gameg == "pq2" and (...)` relies on Lua precedence.
  - Expected benefit: correctness clarity only.
  - Risk: do not change behavior unless isolated as a correctness fix.

### 10. Stats render local cleanup

- In `Skills/Render/Stats.Module.lua`, keep Persona/P5X HP/SP cell cleanup local.
  - Current issue: HP/SP/max HP/max SP header and value cells are duplicated across Persona-family and Metaphor branches.
  - Expected benefit: small clarity improvement and less repeated string construction.
  - Risk: low to moderate. Do not introduce distant helpers.

- In `Skills/Render/Stats.Module.lua`, keep Metaphor stat cleanup local.
  - Current issue: Metaphor repeats the Persona-family HP/MP/max HP/max MP row shape.
  - Expected benefit: small clarity improvement.
  - Risk: low if exact output stays unchanged.

- In `Skills/Render/Stats.Module.lua`, avoid large branch extraction unless it directly removes repeated runtime work.
  - Current issue: the file remains large, but pure movement does not help performance.
  - Recommendation: leave broad splitting alone.

### 11. Drops render cleanup

- In `Skills/Render/Drops.Module.lua`, reduce repeated reward defaulting where branch-local and parity-safe.
  - Current issue: P4, P5-family, and SH2 reward rows repeat `xp`, `yen`, and drop defaults.
  - Expected benefit: small clarity improvement.
  - Risk: low if P5X hidden-row behavior remains unchanged.

- In `Skills/Render/Drops.Module.lua`, keep P5X hidden reward-row checks untouched unless directly testing that branch.
  - Current issue: this behavior was recently fixed and is easy to regress.
  - Recommendation: avoid mixing with unrelated cleanup.

### 12. Correctness fixes to isolate

- In `Skills/Render/Stats.Module.lua`, fix malformed Dx2 stat header markup.
  - Current issue: `style"color` and `'"width=45px` appear in the Dx2 rarity/grade header.
  - This is a visible output fix, not parity cleanup.
  - Test with a Dx2 sample.

- In `Skills/Render/Affinity.Module.lua`, fix malformed Giten/GMT restype headers.
  - Current issue: `title="Ice|Ice` and `title="Force|For` are missing closing quotes.
  - This is a visible output fix, not parity cleanup.
  - Test with a Giten/GMT `restype` sample.

- In `Skills/Render/Affinity.Module.lua`, fix malformed SMT9 resistance-level header.
  - Current issue: `title="Healing|He` is missing the closing quote.
  - This is a visible output fix, not parity cleanup.
  - Test with an SMT9 `reslevels` sample.

- In `Skills/Render/Affinity.Module.lua`, fix the P5-family Psy header typo.
  - Current issue: `widht=9%` should be `width=9%`.
  - This is a visible output fix, not parity cleanup.
  - Test with a P5/P5R/P5S/P5X affinity sample.

- In `Skills.Module.lua`, decide whether to keep the `Zonbie` Arcana alias.
  - Current issue: `Zonbie` looks like a typo but may be a compatibility alias for old template input.
  - Recommendation: do not remove unless a search confirms it is unused or intentionally replaced.

### 13. Later structural cleanup

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
