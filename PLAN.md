# Skills Module Refactor Plan

## Target Module Structure

- `Module:Skills`
  - Public entry points.
  - Argument parsing.
  - Game alias normalization.
  - Property loading.
  - Context creation.
  - Shared helper wiring.

- `Module:Skills/Style`
  - CSS and wiki-table style strings.
  - Builds a fresh per-render style table so render calls do not mutate shared global style state.

- `Module:Skills/Row`
  - Reusable row and cell render utilities.
  - Likely home for the implementation behind `p._row`, while `p.row` remains exposed from `Module:Skills` for compatibility.

- `Module:Skills/Render`
  - Central render coordinator.
  - Owns wrapper table start/end and miscellaneous render sections that do not justify their own module.
  - Calls `Stats`, `Affinity`, `Drops`, and `SkillTable` in legacy output order.

- `Module:Skills/Render/Stats`
  - Main stat/header blocks.
  - Race, arcana, level, HP/MP/SP, stat bars, and game-specific top stat layouts.

- `Module:Skills/Render/Affinity`
  - Element and weapon affinity tables.
  - Resistance/weakness/block/absorb/reflect sections.
  - Resistance formatting helpers such as fraction and percent output, if they are only used here.

- `Module:Skills/Render/Drops`
  - EXP, Yen, drops, negotiation items, material cards, tarot cards, and other loot/reward sections.

- `Module:Skills/Render/SkillTable`
  - Existing skill-list rendering.
  - Normal skills, fusion/synthesis/combo skills, passive skills, auction skills, unknown powers, combo attacks, and power sections.

## Local File Names

- `Skills.Module.lua`
- `Skills/Style.Module.lua`
- `Skills/Row.Module.lua`
- `Skills/Render.Module.lua`
- `Skills/Render/Stats.Module.lua`
- `Skills/Render/Affinity.Module.lua`
- `Skills/Render/Drops.Module.lua`
- `Skills/Render/SkillTable.Module.lua`

## Implementation Order

1. Add `Skills/Style.Module.lua` and move style construction only.
2. Add `Skills/Row.Module.lua` and move low-level row helpers plus `_row` internals.
3. Add `Skills/Render.Module.lua` as the central render coordinator.
4. Extract top stat rendering into `Skills/Render/Stats.Module.lua`.
5. Extract affinity/resistance rendering into `Skills/Render/Affinity.Module.lua`.
6. Extract drop/reward rendering into `Skills/Render/Drops.Module.lua`.
7. Clean inside each module only after exact render parity passes.

## Refactor Rules

- Preserve behavior first. Initial splits should be mostly mechanical moves.
- Preserve legacy output order.
- Avoid one-use boolean locals when an inline condition is clearer.
- Avoid distant `uses...` predicate helpers.
- Do not create vague catch-all modules such as `Core`, `Extra`, or `DetailTable`.
- Move helpers into the module that owns their use. If multiple modules need a helper, wire it explicitly through context before creating another shared module.
- Keep `Module:Skills` as the stable public entry point throughout the refactor.

## Verification

After each local split:

1. Run Lua parsing checks.
2. Run `git diff --check`.
3. Update the corresponding on-wiki sandbox modules.
4. Run the sandbox2 vs sandbox3 exact HTML comparison.

