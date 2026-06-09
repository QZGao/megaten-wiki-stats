local p = {}

-- Resolve a skill code through the selected skill table, falling back to data.aliases.
-- Used by most skill renderers; Metaphor synthesis passes data.syntheses as the source.
local function resolveSkill(data, code, source)
    source = source or data.skills
    local skill = source[code]
    if skill then
        return code, skill
    end

    local alias = data.aliases[code]
    if alias then
        return alias, source[alias]
    end

    return code, nil
end

-- Prefer the explicit display name from game data while preserving the input code fallback.
local function displaySkillName(code, skill)
    return skill.name or code
end

-- Grid skill slots treat blanks and dash placeholders as empty cells.
local function isEmptyGridSkill(code)
    return code == "" or code == "-" or code == "--"
end

-- Tooltips in some three-column grids historically strip wiki-link brackets.
local function stripWikiLinks(text)
    return string.gsub(string.gsub(text, "%[%[", ""), "%]%]", "")
end

-- Append one cell to a three-column skill grid.
-- Some legacy non-boss grids center the seventh skill by padding both sides.
local function appendThreeColumnGridCell(result, styles, index, cell, centerSeventh)
    if index == 7 and centerSeventh then
        return result .. "\n|-" .. styles.skill3m .. cell .. styles.skill3m
    elseif index % 3 == 1 then
        return result .. "\n|-" .. cell
    end
    return result .. cell
end

-- Build one grid cell for normal/passive/auction skill grids.
-- Options: plain skips data lookup; stripLinks removes wiki brackets from tooltip effects.
local function buildThreeColumnSkillCell(ctx, code, options)
    local styles = ctx.styles
    local data = ctx.data

    if options and options.plain then
        if isEmptyGridSkill(code) then
            return ""
        end
        return styles.skill3 .. '"|' .. code
    end

    local skill
    code, skill = resolveSkill(data, code)
    if isEmptyGridSkill(code) then
        return ""
    elseif not skill then
        return styles.skill3 .. '"|' .. code
    end

    local effect = skill.effect
    if options and options.stripLinks then
        effect = stripWikiLinks(effect)
    end
    return styles.skill3 .. '" title="Cost: ' .. skill.cost .. "; " .. effect .. '"|' .. displaySkillName(code, skill)
end

-- Append cells to an already-open three-column row scaffold.
-- Used when multiple parameters share one grid, such as auction + auction passive skills.
local function appendThreeColumnSkillCells(ctx, result, lines, options)
    local styles = ctx.styles

    for index, code in ipairs(mw.text.split(lines, "\n")) do
        result = appendThreeColumnGridCell(result, styles, index, buildThreeColumnSkillCell(ctx, code, options), options and options.centerSeventh)
    end
    return result
end

-- Render the full three-column grid scaffold plus skill cells.
-- Used by compact skill lists, passive skills, and grid-style command skills.
local function renderThreeColumnSkillGrid(ctx, result, lines, options)
    result = result .. '\n|-style="border:0"\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|'
    return appendThreeColumnSkillCells(ctx, result, lines, options)
end

-- Format effect-only rows that may show Combo or Smirk badges.
-- Covers the effect-only schema used by enemy/boss rows and several Persona/DDS/PQ rows.
local function formatTaggedSkillEffect(skill, gameData)
    local effect = skill.effect
    if skill.combo then
        effect = '<div style="background:' .. gameData.colorbg .. ';border-radius:5px;float:left;margin-right:5px">Combo</div> ' .. effect
    elseif skill.smirk then
        effect = effect .. ' <span style="background:' .. gameData.statb .. ';border-radius:5px;padding:3px">Smirk</span> ' .. skill.smirk
    end
    return effect
end

-- Format expanded default-row effects without mutating data.skills.
-- Handles Smirk, chain effects, conditional effects, and boost-level descriptions.
local function formatExpandedSkillEffect(skill, gameData)
    local effect = skill.effect

    if skill.smirk then effect = effect .. ' <span style="background:' .. gameData.statb .. ';border-radius:5px;padding:3px">Smirk</span> ' .. skill.smirk end
    if skill.chaineffect then
        for _, child in ipairs(skill.chaineffect) do
            effect = effect .. string.format('\n<span style="background:' .. gameData.colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">%s:</span>', child[1]) .. " " .. child[2] .. "\n"
        end
    end
    if skill.conditional then
        for _, child in ipairs(skill.conditional) do
            effect = effect .. string.format('\n<span style="background:' .. gameData.colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">%s:</span>', child[1]) .. " " .. child[2] .. "\n"
            if child.chaineffect then
                for _, value in ipairs(child.chaineffect) do
                    effect = effect .. string.format('<br><span style="background:' .. gameData.colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">%s:</span>', value[1]) .. " " .. value[2] .. "\n"
                end
            end
        end
    end
    if skill.boostlevel then
        for level, value in ipairs(skill.boostlevel) do
            if string.len(value) > 0 then effect = effect .. string.format('<br><span style="background:' .. gameData.colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">Level %d:</span>', level - 1) .. " " .. value end
        end
    end

    return effect
end

-- Learning-level/archetype labels for the default skill row schema.
-- Includes innate aliases and Dx2 archetype shorthand.
local levelLabels = {
    i = "Innate",
    I = "Innate",
    innate = "Innate",
    default = "Innate",
    Default = "Innate",
    Ac = '<span style="font-weight:bold">Common</span>',
    Aa = '<span style="color:red;font-weight:bold;">Aragami<br>(Awaken)</span>',
    Ap = '<span style="color:yellow;font-weight:bold;">Protector<br>(Awaken)</span>',
    Ay = '<span style="color:#f5f;font-weight:bold;">Psychic<br>(Awaken)</span>',
    Ae = '<span style="color:#5ff;font-weight:bold;">Elementalist<br>(Awaken)</span>',
    Ga = '<span style="color:red;font-weight:bold;">Aragami<br>(Gacha)</span>',
    Gp = '<span style="color:yellow;font-weight:bold;">Protector<br>(Gacha)</span>',
    Gy = '<span style="color:#f5f;font-weight:bold;">Psychic<br>(Gacha)</span>',
    Ge = '<span style="color:#5ff;font-weight:bold;">Elementalist<br>(Gacha)</span>',
}

-- Convert level/archetype shorthand from the skill parameter into display text.
local function formatLevelLabel(level)
    return levelLabels[level] or level
end

-- Convert rank markers used by SMTIM/AB/P1/P2 rank-style rows.
local function formatRankLabel(rank)
    if rank == "M" or rank == "m" then
        return '[[Mutation|<span style="color:#fff">Mutation</span>]]'
    elseif rank == "R" or rank == "r" then
        return '[[Misc Skills#Rumor Magic|<span style="color:#fff">Rumor</span>]]'
    end
    return rank
end

-- Games that render prop.skills as a data-backed three-column grid.
-- Covers MT1/MT2, Giten, Strange Journey, Soul Hackers, DemiKids, and Devil Survivor.
local function isNormalThreeColumnGrid(game, gameg)
    return game == "mt1" or game == "mt2" or gameg == "giten" or gameg == "smtsj" or gameg == "smtds" or gameg == "sh" or gameg == "childred" or gameg == "childblack" or gameg == "childps" or gameg == "childfire" or gameg == "childice" or gameg == "desu1" or gameg == "desu2"
end

-- Games that render prop.skills as a plain three-column grid without skill data lookup.
-- Covers SMT9, 20XX, Last Bible variants, Ronde, and Card Summoner.
local function isPlainThreeColumnGrid(gameg)
    return gameg == "smt9" or gameg == "20xx" or gameg == "lb3" or gameg == "lbs" or gameg == "ronde" or gameg == "cs"
end

-- Format costs for the default Skill / Cost / Effect / Level schema.
-- Preserves SMT3 conversation labels and P5-family HP/SP color tinting.
local function formatDefaultSkillCost(skill, gameg, gameData)
    local cost
    if gameg == "smt3" then
        if skill.cost == "Convo" then
            cost = '<abbr title="Active conversational skill without HP or MP cost. Ineffective to Corpus, Haunt, Wilder, Foul, Light-tendency demons, bosses and all enemies in Labyrinth of Amala.">Convo</abbr>'
        elseif skill.cost == "Interrupt" then
            cost = '<abbr title="Interruption skill is only triggered when certain conversational effect occurs.">Interrupt</abbr>'
        else
            cost = skill.cost
        end
    else
        cost = skill.cost
    end

    if gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
        if string.match(skill.cost, "HP") then
            return '<span style="color:' .. gameData.hp2 .. '">' .. skill.cost .. "</span>"
        elseif string.match(skill.cost, "SP") then
            return '<span style="color:' .. gameData.mp2 .. '">' .. skill.cost .. "</span>"
        end
    end
    return cost
end

-- Render the header row for prop.skills before the schema-specific rows.
-- Chooses colspan/title by game, including the P5-family gradient header.
local function renderNormalSkillsHeader(ctx, result)
    local getGames = ctx.getGames
    local styles = ctx.styles
    local prop = ctx.prop
    local game = ctx.game
    local gameg = ctx.gameg
    local gamegn = ctx.gamegn

    result = result .. styles.table2h
    if game == "mt1" or game == "mt2" or game == "kmt1" or game == "kmt2" then
        return result .. '"' .. styles.h .. "colspan=4|[[List of Megami Tensei Spells|" .. styles.spanc .. "List of Spells</span>]]"
    elseif game == "smtim" then
        return result .. 'mw-collapsible mw-collapsed"' .. styles.h .. "colspan=4|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Learned Skills</span>]]"
    elseif gameg == "smtsj" and not (prop.enemy or prop.boss) then
        return result .. '"' .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Natural Skills</span>]]"
    elseif gameg == "ab" then
        return result .. '"' .. styles.h .. "colspan=7|[[List of " .. gamegn .. " Skills#Magic|" .. styles.spanc .. "Natural Skills</span>]]"
    elseif gameg == "majin1" then
        return result .. '"' .. styles.h .. "colspan=7|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Magic Skills</span>]]"
    elseif gameg == "majin2" then
        return result .. '"' .. styles.h .. "colspan=6|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "List of Skills</span>]]"
    elseif gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
        local gameData = getGames.games[gameg]
        return result .. '"\n!colspan=4 style="background-color: ' .. gameData.colorb .. ";background: linear-gradient(120deg, " .. gameData.colorb .. " 42%, #000 42.1%, #000 43%, #fff 43.1%, #fff 57%, #000 57.1%, #000 58%, " .. gameData.colorb .. ' 58.1%"|[[List of ' .. gamegn .. ' Skills|<span style="color:black;text-shadow:-3px 3px 3px #0ff">List of Skills</span>]]'
    elseif gameg == "desu1" or gameg == "desu2" then
        return result .. '"' .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Command Skills</span>]]"
    end
    return result .. '"' .. styles.h .. "colspan=4|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "List of Skills</span>]]"
end

-- Render prop.dskills as a Default Skills table.
-- Used for games/entities that list initial skills separately from learned skills.
local function renderDefaultSkills(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamegn = ctx.gamegn
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, cost, effect

    result = result .. styles.table2 .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Default Skills</span>]]" .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
    for k, v in ipairs(mw.text.split(prop.dskills, "\n")) do
        v, skill = resolveSkill(data, v)
        if v == "" then
            skillcell = ""
            cost = ""
            effect = noskill()
        elseif not skill then
            skillcell = ""
            cost = ""
            effect = noskill(v, gamed)
        elseif skill then
            cost = skill.cost
            effect = skill.effect
            if k % 2 == 0 then
                cost = styles.cost2 .. cost
                effect = styles.effect2 .. effect
            else
                cost = styles.cost1 .. cost
                effect = styles.effect1 .. effect
            end
            if skill.name then v = skill.name end
            skillcell = styles.skill .. v
        end
        result = result .. skillcell .. cost .. effect
    end
    return result .. "\n|}"
end

-- Render Majin Tensei II rows: Skill / Power / Range / Cost / Target / Effect.
-- Also expands the special extra/sextra/mextra cost codes without mutating skill data.
local function renderMajin2SkillRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, cost, effect, power, range, target

    result = result .. styles.skill .. "Skill" .. styles.skillc .. "Power" .. styles.skillc .. "Range" .. styles.skillc .. "Cost" .. styles.skillc .. "Target" .. styles.skillc .. "Effect"
    for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
        v, skill = resolveSkill(data, v)
        if v == "" then
            skillcell = ""
            power = ""
            range = ""
            cost = ""
            target = ""
            effect = noskill()
        elseif not skill then
            skillcell = ""
            power = ""
            range = ""
            cost = ""
            target = ""
            effect = noskill(v, gamed)
        elseif skill then
            local skillCost = skill.cost
            if skillCost == "extra" then
                skillCost = '<abbr title="No cost. Can only be used once until next full moon phase.">Extra</abbr>'
            elseif skillCost == "sextra" then
                skillCost = '<abbr title="No cost. Power relative to physical attack power. Can only be used once until next full moon phase.">P. Extra</abbr>'
            elseif skillCost == "mextra" then
                skillCost = '<abbr title="No cost. Power relative to magical attack power. Can only be used once until next full moon phase.">M. Extra</abbr>'
            end
            if k % 2 == 0 then
                power = styles.cost2 .. skill.power
                range = styles.cost2 .. skill.range
                cost = styles.cost2 .. skillCost
                target = styles.cost2 .. skill.target
                effect = styles.effect2 .. skill.effect
            else
                power = styles.cost1 .. skill.power
                range = styles.cost1 .. skill.range
                cost = styles.cost1 .. skillCost
                target = styles.cost1 .. skill.target
                effect = styles.effect1 .. skill.effect
            end
            skillcell = styles.skill .. displaySkillName(v, skill)
        end
        result = result .. skillcell .. power .. range .. cost .. target .. effect
    end
    return result
end

-- Render Skill / Cost / Effect rows.
-- Used by early SMT/KMT/Last Bible rows and selected guest/enemy schemas.
local function renderSkillCostEffectRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, cost, effect

    result = result .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
    for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
        v, skill = resolveSkill(data, v)
        if v == "" then
            skillcell = ""
            cost = ""
            effect = noskill()
        elseif not skill then
            skillcell = ""
            cost = ""
            effect = noskill(v, gamed)
        elseif skill then
            if skill.phy then
                cost = "none"
            --[[elseif gameg == 'p5' or gameg == 'p5r' or gameg == 'p5s' or gameg == 'p5x' then
                cost = '<span style="color:' .. getGames.games[gameg].mp2 .. '">' .. skill.cost .. '</span>' -- tints pink for magic skill]]
            --
            else
                cost = skill.cost
            end
            effect = skill.effect
            if k % 2 == 0 then
                cost = styles.cost2 .. cost
                effect = styles.effect2 .. effect
            else
                cost = styles.cost1 .. cost
                effect = styles.effect1 .. effect
            end
            if skill.magatsuhi then effect = '<div style="background:#DC143C;border-radius:5px;float:left;margin-right:5px">Magatsuhi</div> ' .. effect end
            skillcell = styles.skill .. displaySkillName(v, skill)
        end
        result = result .. skillcell .. cost .. effect
    end
    return result
end

-- Render Skill / Effect rows with optional inherit/rumor markers after the backslash.
-- Used by Persona-style HP rows, DDS, PQ, SMT4 guest=2, and enemy/boss rows.
local function renderSkillEffectRows(ctx, result)
    local getGames = ctx.getGames
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gameg = ctx.gameg
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local gameData = getGames.games[gameg]
    local skill, skillcell, effect

    result = result .. styles.skill .. "Skill" .. styles.skillc .. "Effect"
    for k1, v1 in ipairs(mw.text.split(prop.skills, "\n")) do
        for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do
            if k2 > 2 then
                break
            elseif k2 % 2 == 1 then
                v2, skill = resolveSkill(data, v2)
                if v2 == "" then
                    skillcell = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    effect = noskill(v2, gamed)
                elseif skill then
                    local effectText = formatTaggedSkillEffect(skill, gameData)
                    if k1 % 2 == 0 then
                        effect = styles.effect2 .. effectText
                    else
                        effect = styles.effect1 .. effectText
                    end
                    skillcell = styles.skill .. displaySkillName(v2, skill)
                end
                result = result .. skillcell .. effect
            elseif k2 % 2 == 0 then
                if v2 == "I" or v2 == "i" then
                    result = result .. '<div style="float:right;background:#696969;border-radius:15px;padding:0 10px">Inheritable Skill</div>'
                elseif v2 == "R" or v2 == "r" then
                    result = result .. '<div style="float:right;background:#8E283D;border-radius:15px;padding:0 10px">[[Misc Skills#Rumor Magic|<span style="color:#fff">Rumor Skill</span>]]</div>'
                else
                    result = result
                end
            end
        end
    end
    return result
end

-- Render Skill / Element / Cost / Effect rows.
-- Covers Devil Children Red/Black Book and DemiKids Light/White variants.
local function renderSkillElementCostEffectRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, skille, cost, effect

    result = result .. styles.skill .. "Skill" .. styles.skillc .. "Element" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
    for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
        v, skill = resolveSkill(data, v)
        if v == "" then
            skillcell = ""
            skille = ""
            cost = ""
            effect = noskill()
        elseif not skill then
            skillcell = ""
            skille = ""
            cost = ""
            effect = noskill(v, gamed)
        elseif skill then
            if k % 2 == 0 then
                effect = styles.effect2 .. skill.effect
                skille = styles.cost2 .. skill.element
                cost = styles.cost2 .. skill.cost
            else
                effect = styles.effect1 .. skill.effect
                skille = styles.cost1 .. skill.element
                cost = styles.cost1 .. skill.cost
            end
            skillcell = styles.skill .. displaySkillName(v, skill)
        end
        result = result .. skillcell .. skille .. cost .. effect
    end
    return result
end

-- Render rank/level-prefixed skill rows.
-- Covers SMT Imagine, Another Bible, Persona 1, and Persona 2 row formats.
local function renderRankSkillRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gameg = ctx.gameg
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, cost, effect, range, power, target

    result = result .. styles.skill
    if gameg == "smtim" then
        result = result .. "Level" .. styles.skillc .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
    elseif gameg == "ab" then
        result = result .. "Level" .. styles.skillc .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Range" .. styles.skillc .. "Power" .. styles.skillc .. "Target" .. styles.skillc .. "Effect"
    else
        result = result .. "Rank" .. styles.skillc .. "Skill" .. styles.skillc .. "Effect"
    end
    for k1, v1 in ipairs(mw.text.split(prop.skills, "\n")) do
        for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do
            if k2 > 2 then
                break
            elseif k2 % 2 == 1 then
                result = result .. styles.skill .. formatRankLabel(v2)
            elseif k2 % 2 == 0 then
                v2, skill = resolveSkill(data, v2)
                if v2 == "" then
                    skillcell = ""
                    cost = ""
                    range = ""
                    power = ""
                    target = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    cost = ""
                    range = ""
                    power = ""
                    target = ""
                    effect = noskill(v2, gamed)
                elseif skill then
                    if k1 % 2 == 0 then
                        if gameg == "smtim" or gameg == "ab" then
                            cost = styles.cost2 .. skill.cost
                        else
                            cost = ""
                        end
                        if gameg == "ab" then
                            range = styles.cost2 .. skill.range
                            power = styles.cost2 .. skill.power
                            target = styles.cost2 .. skill.target
                        else
                            range = ""
                            power = ""
                            target = ""
                        end
                        effect = styles.effect2 .. skill.effect
                    else
                        if gameg == "smtim" or gameg == "ab" then
                            cost = styles.cost1 .. skill.cost
                        else
                            cost = ""
                        end
                        if gameg == "ab" then
                            range = styles.cost1 .. skill.range
                            power = styles.cost1 .. skill.power
                            target = styles.cost1 .. skill.target
                        else
                            range = ""
                            power = ""
                            target = ""
                        end
                        effect = styles.effect1 .. skill.effect
                    end
                    skillcell = styles.skillc .. displaySkillName(v2, skill)
                end
                result = result .. skillcell .. cost .. range .. power .. target .. effect
            end
        end
    end
    return result
end

-- Render Majin Tensei I rows: Skill / Cost / Power / Range / Target / Effect.
local function renderMajin1SkillRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, cost, effect, power, range, target

    result = result .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Power" .. styles.skillc .. "Range" .. styles.skillc .. "Target" .. styles.skillc .. "Effect"
    for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
        v, skill = resolveSkill(data, v)
        if v == "" then
            skillcell = ""
            cost = ""
            power = ""
            range = ""
            target = ""
            effect = noskill()
        elseif not skill then
            skillcell = ""
            cost = ""
            power = ""
            range = ""
            target = ""
            effect = noskill(v, gamed)
        elseif skill then
            if k % 2 == 0 then
                cost = styles.cost2 .. skill.cost
                power = styles.cost2 .. skill.power
                range = styles.cost2 .. skill.range
                target = styles.cost2 .. skill.target
                effect = styles.effect2 .. skill.effect
            else
                cost = styles.cost1 .. skill.cost
                power = styles.cost1 .. skill.power
                range = styles.cost1 .. skill.range
                target = styles.cost1 .. skill.target
                effect = styles.effect1 .. skill.effect
            end
            skillcell = styles.skill .. displaySkillName(v, skill)
        end
        result = result .. skillcell .. cost .. power .. range .. target .. effect
    end
    return result
end

-- Render the fallback learned-skill table: Skill / Cost / Effect / Level.
-- Covers most remaining skill lists, including P3-P5, Dx2 archetypes, and Metaphor ranks.
local function renderDefaultSkillRows(ctx, result)
    local getGames = ctx.getGames
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gameg = ctx.gameg
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local gameData = getGames.games[gameg]
    local skill, skillcell, cost, effect
    -- Guest rows for SMT4/4A/5/5V and Soul Hackers 2 omit cost.
    local guestEffectLevelRows = (gameg == "smt4" or gameg == "smt4a" or gameg == "smt5" or gameg == "smt5v" or gameg == "sh2") and prop.guest == "1"

    result = result .. styles.skill .. "Skill"
    if guestEffectLevelRows then
        result = result .. styles.skillc .. "Effect" .. styles.skillc .. "Level"
    elseif gameg == "ldx2" then
        result = result .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Archetype"
    elseif gameg == "metaphor" then
        result = result .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Rank"
    else
        result = result .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Level"
    end
    for k1, v1 in ipairs(mw.text.split(prop.skills, "\n")) do -- Any entry on new line within "Skills" parameter is treated as new skill name.
        for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do -- Entry after backslash after skill name is treated as "level" for learning new skill per level gain. Any entry starting from second backslash on the same line is ignored until a new line.
            if k2 > 2 then
                break
            elseif k2 % 2 == 1 then -- this checks level (false) or skill name (true) divided by the backslash.
                v2, skill = resolveSkill(data, v2) -- now v2 represents skill name.
                if v2 == "" then
                    skillcell = ""
                    cost = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    cost = ""
                    effect = noskill(v2, gamed)
                elseif skill then
                    cost = formatDefaultSkillCost(skill, gameg, gameData)
                    local effectText = formatExpandedSkillEffect(skill, gameData)
                    if k1 % 2 == 0 then
                        cost = styles.cost2 .. cost
                        effect = styles.effect2 .. effectText
                    else
                        cost = styles.cost1 .. cost
                        effect = styles.effect1 .. effectText
                    end
                    skillcell = styles.skill .. displaySkillName(v2, skill)
                end
                if not guestEffectLevelRows then
                    result = result .. skillcell .. cost .. effect
                else
                    result = result .. skillcell .. effect
                end
            elseif k2 % 2 == 0 then -- this checks level (true) or skill name (false) divided by the backslash.
                v2 = formatLevelLabel(v2)
                if k1 % 2 == 0 then -- this checks even (true) or odd (false) number row.
                    result = result .. styles.cost2 .. v2 -- "v2" represents "Level" within "Skills" parameter on each new line after the backslash.
                else
                    result = result .. styles.cost1 .. v2
                end
            end
        end
    end
    return result
end

-- Dispatch prop.skills to the schema renderer selected by game/row shape.
-- This keeps the legacy branch order visible while isolating each row implementation.
local function renderNormalSkills(ctx, result)
    local prop = ctx.prop
    local game = ctx.game
    local gameg = ctx.gameg

    result = renderNormalSkillsHeader(ctx, result)

    if isNormalThreeColumnGrid(game, gameg) then
        result = renderThreeColumnSkillGrid(ctx, result, prop.skills, {
            stripLinks = true,
            centerSeventh = not (prop.boss or prop.enemy),
        })
    elseif gameg == "majin2" then
        result = renderMajin2SkillRows(ctx, result)
    elseif isPlainThreeColumnGrid(gameg) then
        result = renderThreeColumnSkillGrid(ctx, result, prop.skills, {
            plain = true,
            centerSeventh = true,
        })
    -- Skill / Cost / Effect: KMT, early SMT player rows, selected guest/enemy rows, and Last Bible.
    elseif (game == "kmt1" and not (prop.enemy or prop.boss))
        or (game == "kmt2" and not (prop.enemy or prop.boss))
        or (gameg == "smt1" and not (prop.enemy or prop.boss))
        or (gameg == "smt2" and not (prop.enemy or prop.boss))
        or (gameg == "smtif" and not (prop.enemy or prop.boss))
        or (gameg == "smt3" and (prop.enemy or prop.boss))
        or ((gameg == "smt4a" or gameg == "smt5" or gameg == "smt5v" or gameg == "sh2") and prop.guest == "2")
        or (game == "lb1" and not (prop.enemy or prop.boss))
        or (game == "lb2" and not (prop.enemy or prop.boss)) then
        result = renderSkillCostEffectRows(ctx, result)
    -- Skill / Effect: SMT4 guest rows, Persona HP rows, DDS, PQ without arcana, and enemy/boss rows.
    elseif (gameg == "smt4" and prop.guest == "2")
        or ((gameg == "p1" or gameg == "p2is" or gameg == "p2ep" or gameg == "p3" or gameg == "p3re" or gameg == "p4" or gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" or gameg == "metaphor") and prop.hp)
        or gameg == "ddsaga1"
        or gameg == "ddsaga2"
        or ((gameg == "pq" or gameg == "pq2") and not prop.arcana)
        or prop.boss
        or prop.enemy then
        result = renderSkillEffectRows(ctx, result)
    elseif gameg == "dcbrb" or gameg == "childlight" or gameg == "childwhite" then -- skill - element - cost - effect
        result = renderSkillElementCostEffectRows(ctx, result)
    -- Rank / Skill rows: SMT Imagine, Another Bible, Persona 1, and Persona 2.
    elseif gameg == "smtim" or gameg == "ab" or gameg == "p1" or gameg == "p2is" or gameg == "p2ep" then
        result = renderRankSkillRows(ctx, result)
    elseif gameg == "majin1" then -- skill - cost - power - range - target - effect
        result = renderMajin1SkillRows(ctx, result)
    else -- skill - cost - effect - level (default List of skills table order)
        result = renderDefaultSkillRows(ctx, result)
    end
    return result .. "\n|}"
end

-- Render Persona 2 Innocent Sin/Eternal Punishment fusion spell rows.
-- Uses prop.fskills as Unique Fusion Spells with order/skill/persona metadata in cost.
local function renderPersona2FusionRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamegn = ctx.gamegn
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, cost, effect

    result = result .. "|[[List of " .. gamegn .. " Fusion Spells|" .. styles.spanc .. "Unique Fusion Spells</span>]]" .. styles.skill .. "Skill" .. styles.skillc .. "Effect" .. styles.skillc .. "Order/Skill/Persona"
    for k, v in ipairs(mw.text.split(prop.fskills, "\n")) do
        v, skill = resolveSkill(data, v)
        if v == "" then
            skillcell = ""
            cost = ""
            effect = noskill()
        elseif not skill then
            skillcell = ""
            cost = ""
            effect = noskill(v, gamed)
        elseif skill then
            if k % 2 == 0 then
                effect = styles.effect2 .. skill.effect
            else
                effect = styles.effect1 .. skill.effect
            end
            skillcell = styles.skill .. displaySkillName(v, skill)
            cost = styles.order .. skill.cost
        end
        result = result .. skillcell .. effect .. cost
    end
    return result
end

-- Render Persona 3/P3 Reload single Fusion Spell rows.
-- This branch preserves the legacy P3/FES/Reload prerequisite note.
local function renderPersona3FusionRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local cost, effect, fskillCell, pre

    if not data.skills[prop.fskills] then
        cost = ""
        effect = noskill(prop.fskills, gamed)
        fskillCell = prop.fskills
        pre = ""
    else
        cost = styles.cost1 .. data.skills[prop.fskills].cost
        effect = styles.effect1 .. data.skills[prop.fskills].effect
        fskillCell = styles.skill .. prop.fskills
        pre = styles.cost1 .. data.skills[prop.fskills].pre
    end
    return result .. "|[[List of Persona 3 Skills#Fusion Spells|" .. styles.spanc .. 'Fusion Spell</span>]] <abbr title="Persona 3, FES and Reload only; Portable uses items and does not require the participating Personas to be in stock">*</abbr>' .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. '<abbr title="Persona 3, FES and Reload only">Prerequisite</abbr>' .. fskillCell .. cost .. effect .. pre
end

-- Render Metaphor: ReFantazio synthesis skill rows.
-- Uses data.syntheses instead of data.skills, while still honoring aliases.
local function renderMetaphorSynthesisRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill

    result = result .. "|[[List of Metaphor: ReFantazio Skills#Synthesis Skills|" .. styles.spanc .. "Synthesis Skills</span>]]" .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Skill prerequisite" .. styles.skillc .. "First ally" .. styles.skillc .. "Second ally"
    for k, v in ipairs(mw.text.split(prop.fskills, "\n")) do
        v, skill = resolveSkill(data, v, data.syntheses)
        if v == "" then
            result = result .. noskill()
        elseif not skill then
            result = result .. noskill(v, gamed)
        elseif skill then
            v = displaySkillName(v, skill)
            if k % 2 == 0 then
                result = result .. styles.skill .. v .. styles.cost2 .. skill.cost .. styles.effect2 .. skill.effect .. styles.cost2 .. skill.required .. styles.cost2 .. skill.first .. styles.cost2 .. skill.second
            else
                result = result .. styles.skill .. v .. styles.cost1 .. skill.cost .. styles.effect1 .. skill.effect .. styles.cost1 .. skill.required .. styles.cost1 .. skill.first .. styles.cost1 .. skill.second
            end
        end
    end
    return result
end

-- Render DemiKids Light/Dark combo rows from prop.fskills.
-- The value after the backslash is displayed as the combo partner.
local function renderChildLightFusionRows(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local skill, skillcell, skille, cost, effect

    result = result .. "|[[List of DemiKids Light/Dark Version Skills#Combos|" .. styles.spanc .. "Combos</span>]]" .. styles.skill .. "Combo" .. styles.skillc .. "Element" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Partner"
    for k1, v1 in ipairs(mw.text.split(prop.fskills, "\n")) do
        for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do -- Entry after backslash after skill name is treated as "partner"
            if k2 > 2 then
                break
            elseif k2 % 2 == 1 then -- this checks partner (false) or skill name (true) divided by the backslash.
                v2, skill = resolveSkill(data, v2) -- now v2 represents skill name.
                if v2 == "" then
                    skillcell = ""
                    skille = ""
                    cost = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    skille = ""
                    cost = ""
                    effect = noskill(v2, gamed)
                elseif skill then
                    skille = skill.element
                    cost = skill.cost
                    effect = skill.effect
                    if k1 % 2 == 0 then
                        skille = styles.cost2 .. skille
                        cost = styles.cost2 .. cost
                        effect = styles.effect2 .. effect
                    else
                        skille = styles.cost1 .. skille
                        cost = styles.cost1 .. cost
                        effect = styles.effect1 .. effect
                    end
                    skillcell = styles.skill .. displaySkillName(v2, skill)
                end
                result = result .. skillcell .. skille .. cost .. effect
            elseif k2 % 2 == 0 then -- this checks partner (true) or skill name (false) divided by the backslash.
                if v2 == "" or not v2 then -- now v2 represents partner.
                    v2 = ""
                end
                if k1 % 2 == 0 then -- this checks even (true) or odd (false) number row.
                    result = result .. styles.cost2 .. v2 -- "v2" represents "partner" within "Skills" parameter on each new line after the backslash.
                else
                    result = result .. styles.cost1 .. v2
                end
            end
        end
    end
    return result
end

-- Dispatch prop.fskills to the fusion/synthesis/combo schema for the current game.
-- Covers P2, P3/P3RE, Metaphor, and DemiKids Light/Dark.
local function renderFusionSkills(ctx, result)
    local styles = ctx.styles
    local gameg = ctx.gameg

    result = result .. styles.table2 .. styles.h
    if gameg == "metaphor" then
        result = result .. 'colspan="6"'
    else
        result = result .. 'colspan="5"'
    end

    if gameg == "p2is" or gameg == "p2ep" then
        result = renderPersona2FusionRows(ctx, result)
    elseif gameg == "p3" or gameg == "p3re" then
        result = renderPersona3FusionRows(ctx, result)
    elseif gameg == "metaphor" then
        result = renderMetaphorSynthesisRows(ctx, result)
    elseif gameg == "childlight" then
        result = renderChildLightFusionRows(ctx, result)
    end
    return result .. "\n|}"
end

-- Render prop.pskills as Passive Skills or Strange Journey D-Source Skills.
-- Uses the shared three-column skill grid.
local function renderPassiveSkills(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg
    local gamegn = ctx.gamegn

    if gameg == "smtsj" then
        result = result .. styles.table2 .. styles.h .. "colspan=3|D-Source Skills"
    else
        result = result .. styles.table2 .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills#Passive Skills|" .. styles.spanc .. "Passive Skills</span>]]"
    end
    return renderThreeColumnSkillGrid(ctx, result, prop.pskills) .. "\n|}"
end

-- Render auction/drop grids for Strange Journey and Devil Survivor.
-- prop.askills and prop.apskills share one three-column grid body.
local function renderAuctionSkills(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg

    if gameg == "smtsj" then
        result = result .. styles.table2 .. styles.h .. "colspan=3|Item Drops"
    else
        result = result .. styles.table2 .. styles.h .. "colspan=3|List of Auction Skills"
    end
    result = result .. '\n|-style="border:0"\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|'
    if prop.askills then
        result = appendThreeColumnSkillCells(ctx, result, prop.askills)
    end
    if prop.apskills then
        result = appendThreeColumnSkillCells(ctx, result, prop.apskills)
    end
    return result .. "\n|}"
end

-- Render Persona 2 Eternal Punishment Unknown Power descriptions.
-- Accepts several text aliases such as "attack", "attack type", and "attack-type".
local function renderUnknownPower(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop

    result = result .. styles.table2 .. styles.h .. 'colspan="2"|[[Unknown Power|' .. styles.spanc .. "Unknown Power</span>]]" .. styles.skill
    local unknown = prop.unknown:lower()
    if unknown == "attack type" or unknown == "attack-type" or unknown == "attack" then
        result = result .. "Attack Type" .. styles.cost1 .. 'Deals <abbr title="Equipper has ' .. "'Great'" .. ' affinity with the Persona">500</abbr> or <abbr title="Equipper has ' .. "'Good'" .. ' affinity with the Persona">250</abbr> non-elemental damage to all enemies.'
    elseif unknown == "defense type" or unknown == "defense-type" or unknown == "defense" then
        result = result .. "Defense Type" .. styles.cost1 .. '<abbr title="Equipper has ' .. "'Great'" .. ' affinity with the Persona">Reflects</abbr> or <abbr title="Equipper has ' .. "'Good'" .. ' affinity with the Persona">nullifies</abbr> the incoming attack.'
    elseif unknown == "assist type" or unknown == "assist-type" or unknown == "assist" then
        result = result .. "Assist Type" .. styles.cost1 .. 'Bestows Tarukaja + Makakaja <abbr title="Only applicable when the equipper has ' .. "'Great'" .. ' affinity with the Persona">(or Rakukaja + Samakaja in addition)</abbr>'
    elseif unknown == "recovery type" or unknown == "recovery-type" or unknown == "recovery" then
        result = result .. "Recovery Type" .. styles.cost1 .. 'Fully recovers HP <abbr title="Only applicable when the equipper has ' .. "'Great'" .. ' affinity with the Persona">(or removes ailment in addition)</abbr>.'
    elseif unknown == "revival type" or unknown == "revival-type" or unknown == "revival" then
        result = result .. "Revival Type" .. styles.cost1 .. 'Revives from unconscious with <abbr title="Equipper has ' .. "'Great'" .. ' affinity with the Persona">full</abbr> or <abbr title="Equipper has ' .. "'Good'" .. ' affinity with the Persona">1/4</abbr> HP.'
    elseif unknown == "special type" or unknown == "special-type" or unknown == "special" then
        result = result .. "Special Type" .. styles.cost1 .. "Eliminates all enemies when the user is unconscious."
    end
    return result .. "\n|}"
end

-- Render Persona 5 Strikers combo attacks from prop.cskills.
-- First field is the combo input key; following fields are paired skill/effect rows.
local function renderComboAttacks(ctx, result)
    local getGames = ctx.getGames
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gameg = ctx.gameg
    local gamed = ctx.gamed
    local wikitext = ctx.wikitext
    local gameData = getGames.games[gameg]
    local skill, skillcell

    result = result .. styles.table2 .. styles.h .. 'colspan="4" style="background-color: ' .. gameData.colorb .. ";background: linear-gradient(120deg, " .. gameData.colorb .. " 40%, #000 40.1%, #000 41%, #fff 41.1%, #fff 59%, #000 59.1%, #000 60%, " .. gameData.colorb .. ' 60.1%"|[[Combo Attacks|<span style="color:black;text-shadow:-3px 3px 3px #0ff">Combo Attacks</span>]]'
    result = result .. styles.skill .. "Combo Attack" .. styles.skillc .. "Button Input" .. styles.skill3 .. '" colspan=2|Skills'
    for _, v1 in ipairs(mw.text.split(prop.cskills, "\n")) do
        skillcell = ""
        local v_cnt = 0
        for _ in string.gmatch(v1, "\\") do
            v_cnt = v_cnt + 1
        end
        for k2, v2 in ipairs(mw.text.split(v1, "\\")) do
            if k2 > 1 then
                v2, skill = resolveSkill(data, v2)
                local resv2, resdec
                if v2 == "" or v2 == "-" or v2 == "--" then
                    resv2 = '<span style="font-weight:bold;">-</span>'
                elseif not skill then
                    resv2 = '<span style="color:red;font-weight:bold;font-size:1.2em">Invalid skill name of "' .. v2 .. '". You may correct the skill name or modify [[module:Skills/' .. gamed .. "]] if needed.</span>"
                else
                    resv2 = '<span style="font-weight:bold;>' .. displaySkillName(v2, skill) .. "</span>"
                    resdec = skill.effect
                end
                if k2 > 2 then
                    if k2 % 2 == 0 then
                        if resdec then
                            skillcell = skillcell .. "\n|-" .. styles.effect1 .. resv2 .. styles.effect1 .. resdec
                        else
                            skillcell = skillcell .. "\n|-" .. styles.effect1p .. resv2
                        end
                    else
                        if resdec then
                            skillcell = skillcell .. "\n|-" .. styles.effect2 .. resv2 .. styles.effect2 .. resdec
                        else
                            skillcell = skillcell .. "\n|-" .. styles.effect2p .. resv2
                        end
                    end
                else
                    if resdec then
                        skillcell = skillcell .. styles.effect1 .. resv2 .. styles.effect1 .. resdec
                    else
                        skillcell = skillcell .. styles.effect1p .. resv2
                    end
                end
            else
                v2 = v2:gsub("^%l", string.upper)
                if not v2 then v2 = "" end
                local ca = data.cattacks[v2]
                result = result .. styles.skill2 .. 'rowspan="' .. v_cnt .. '"|' .. v2 .. styles.cost3 .. 'rowspan="' .. v_cnt .. '"|' .. wikitext(ca.buttons)
            end
        end
        result = result .. skillcell
    end
    return result .. "\n|}"
end

-- Render DemiKids Light/Dark Power rows from prop.power.
-- Kept separate from prop.fskills combos because it is a single Power / Type / Effect table.
local function renderChildLightPower(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local gamegn = ctx.gamegn
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local powerCell = prop.power
    local pelement, peffect
    local skill = data.skills[powerCell]

    if not skill then
        powerCell = noskill(powerCell, gamed)
        pelement = ""
        peffect = ""
    else
        pelement = styles.cost1 .. skill.element
        peffect = styles.effect1 .. skill.effect
        powerCell = styles.skill .. powerCell
    end
    return result .. styles.table2 .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills##Powers|" .. styles.spanc .. "Power</span>]]\n|-" .. styles.skill .. "Power" .. styles.skillc .. "Type" .. styles.skillc .. "Effect" .. powerCell .. pelement .. peffect .. "\n|}"
end

-- Main entry point called by Module:Skills.
-- Section guards avoid no-op renderer calls and preserve the legacy output order.
function p.render(ctx, result)
    local prop = ctx.prop
    local gameg = ctx.gameg

    if prop.dskills then
        result = renderDefaultSkills(ctx, result)
    end
    if prop.skills then
        result = renderNormalSkills(ctx, result)
    end
    if prop.fskills then
        result = renderFusionSkills(ctx, result)
    end
    if prop.pskills then
        result = renderPassiveSkills(ctx, result)
    end
    if (gameg == "smtsj" or gameg == "desu1" or gameg == "desu2") and (prop.askills or prop.apskills) then
        result = renderAuctionSkills(ctx, result)
    end
    if gameg == "p2ep" and prop.unknown then
        result = renderUnknownPower(ctx, result)
    end
    if gameg == "p5s" and prop.cskills then
        result = renderComboAttacks(ctx, result)
    end
    if gameg == "childlight" and prop.power ~= "" then
        result = renderChildLightPower(ctx, result)
    end

    return result
end

return p
