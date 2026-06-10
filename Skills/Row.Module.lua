local Style = require("Module:Skills/Style")

local p = {}

local styles = Style.new()

-- Normalize the optional level marker used by #invoke:row.
-- Shared by all row formats; "i"/"default" aliases are displayed as Innate.
local function normalizeLevel(level)
    level = level or ""
    if level == "i" or level == "I" or level == "innate" or level == "default" or level == "Default" then
        return "Innate"
    end
    return level
end

-- Resolve a skill code for one game data module, honoring that module's aliases.
-- Used by all #invoke:row formats before row-specific rendering.
local function resolveSkill(data, code)
    local skill = data.skills[code]
    if skill then
        return code, skill
    end

    local alias = data.aliases[code]
    if alias then
        return alias, data.skills[alias]
    end

    return code, nil
end

-- Normalize the displayed cost for one #invoke:row skill.
-- Used by all row handlers; SMT3 conversation rows and Interrupt skills have special display text.
local function getRowCost(game, skill)
    if game == "SMT3" then
        return '<abbr title="Active conversational skill without HP or MP cost. Ineffective to Corpus, Haunt, Wilder, Foul, Light-tendency demons, bosses and all enemies in Labyrinth of Amala.">Convo</abbr>'
    elseif skill.cost == "Interrupt" then
        return '<abbr title="Interruption skill is only triggered when certain conversational effect occurs.">Interrupt</abbr>'
    end

    return skill.cost
end

-- Build the odd-row level cell for #invoke:row formats with learned levels.
-- Used by generic r21/r31 and DemiKids combo rows; skill.pre overrides the supplied level for every game.
local function levelCell1(skill, level)
    if skill.pre then
        return "\n||" .. skill.pre
    elseif level == "" then
        return "\n||"
    end

    return "\n||" .. level
end

-- Build the even-row level cell for #invoke:row formats with learned levels.
-- Used by generic r22/r32 and DemiKids combo rows; skill.pre overrides the supplied level for every game.
local function levelCell2(skill, level)
    if skill.pre then
        return styles.cost2 .. skill.pre
    elseif level == "" then
        return styles.cost2
    end

    return styles.cost2 .. level
end

-- Dispatch legacy #invoke:row row codes to their exact renderer.
-- Covers generic skill rows, Persona 1/2 persona rows, Persona fusion rows, SMT3 physical-cost exceptions, and DemiKids rows.
local rowHandlers = {
    -- Odd enemy row where skill cost is irrelevant; used by generic enemy skill lists.
    r01 = function(skillcell, skill)
        return skillcell .. styles.effect1 .. skill.effect
    end,

    -- Even enemy row where skill cost is irrelevant; used by generic enemy skill lists.
    r02 = function(skillcell, skill)
        return skillcell .. styles.effect2 .. skill.effect
    end,

    -- Odd demon row without learned-level output; SMT3 physical skills omit HP cost.
    r11 = function(skillcell, skill, code, level, game)
        if game == "SMT3" and skill.phy then
            return skillcell .. styles.effect1p .. skill.effect
        end
        local cost = getRowCost(game, skill)
        return skillcell .. "\n||" .. cost .. styles.effect1 .. skill.effect
    end,

    -- Even demon row without learned-level output; SMT3 physical skills omit HP cost.
    r12 = function(skillcell, skill, code, level, game)
        if game == "SMT3" and skill.phy then
            return skillcell .. styles.effect2p .. skill.effect
        end
        local cost = getRowCost(game, skill)
        return skillcell .. styles.cost2 .. cost .. styles.effect2 .. skill.effect
    end,

    -- Odd demon/persona row with learned-level output.
    r21 = function(skillcell, skill, code, level, game)
        local cost = getRowCost(game, skill)
        return skillcell .. "\n||" .. cost .. styles.effect1 .. skill.effect .. levelCell1(skill, level)
    end,

    -- Even demon/persona row with learned-level output.
    r22 = function(skillcell, skill, code, level, game)
        local cost = getRowCost(game, skill)
        return skillcell .. styles.cost2 .. cost .. styles.effect2 .. skill.effect .. levelCell2(skill, level)
    end,

    -- Odd guest row with learned-level output and no cost column.
    r31 = function(skillcell, skill, code, level)
        return skillcell .. styles.effect1 .. skill.effect .. levelCell1(skill, level)
    end,

    -- Even guest row with learned-level output and no cost column.
    r32 = function(skillcell, skill, code, level)
        return skillcell .. styles.effect2 .. skill.effect .. levelCell2(skill, level)
    end,

    -- Persona 1/2 persona row, where level is rendered before the skill name.
    p12 = function(skillcell, skill, code, level)
        return styles.skill .. level .. styles.skillc .. code .. styles.effect1 .. skill.effect
    end,

    -- Persona-specific fusion spell row.
    rf = function(skillcell, skill)
        return skillcell .. styles.effect1 .. skill.effect .. styles.order .. skill.cost
    end,

    -- Odd DemiKids stats skill row with element and cost.
    dk1 = function(skillcell, skill, code, level, game)
        local cost = getRowCost(game, skill)
        return skillcell .. "\n||" .. skill.element .. "\n||" .. cost .. styles.effect1 .. skill.effect
    end,

    -- Even DemiKids stats skill row with element and cost.
    dk2 = function(skillcell, skill, code, level, game)
        local cost = getRowCost(game, skill)
        return skillcell .. styles.cost2 .. skill.element .. styles.cost2 .. cost .. styles.effect2 .. skill.effect
    end,

    -- Odd DemiKids combo skill row with learned-level, element, and cost.
    dkc1 = function(skillcell, skill, code, level, game)
        local cost = getRowCost(game, skill)
        return skillcell .. levelCell1(skill, level) .. "\n||" .. skill.element .. "\n||" .. cost .. styles.effect1 .. skill.effect
    end,

    -- Even DemiKids combo skill row with learned-level, element, and cost.
    dkc2 = function(skillcell, skill, code, level, game)
        local cost = getRowCost(game, skill)
        return skillcell .. levelCell2(skill, level) .. styles.cost2 .. skill.element .. styles.cost2 .. cost .. styles.effect2 .. skill.effect
    end,

    -- DemiKids power row with element and no cost column.
    dkp = function(skillcell, skill)
        return skillcell .. styles.cost2 .. skill.element .. styles.effect2 .. skill.effect
    end,
}

-- Render one legacy #invoke:row output fragment.
-- Covers generic r01-r32 rows, Persona 1/2 persona rows, fusion rows, SMT3 physical-cost exceptions, and DemiKids rows.
function p.render(args, noskill, cate)
    local row = args[1]
    local game = args[2]
    local code = args[3]
    if not code or code == "" then return "" end

    local level = normalizeLevel(args[4])
    local data = require("Module:Skills/" .. game)
    local skill
    code, skill = resolveSkill(data, code)
    if not skill then
        return noskill(code, game)
    end

    if skill.name then code = skill.name end
    local skillcell = styles.skill .. code

    local renderRow = rowHandlers[row]
    if renderRow then
        return renderRow(skillcell, skill, code, level, game)
    end

    return '<strong style="color:red;font-size:150%">Invalid parameter 1 of ' .. '"' .. row .. '".</strong>' .. cate("Templates with unrecognizable row value for Module:Skills")
end

return p
