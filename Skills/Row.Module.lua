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
    local cost = skill.cost
    if game == "SMT3" then
        cost = '<abbr title="Active conversational skill without HP or MP cost. Ineffective to Corpus, Haunt, Wilder, Foul, Light-tendency demons, bosses and all enemies in Labyrinth of Amala.">Convo</abbr>'
    elseif skill.cost == "Interrupt" then
        cost = '<abbr title="Interruption skill is only triggered when certain conversational effect occurs.">Interrupt</abbr>'
    end

    local cost1 = "\n||" .. cost
    local cost2 = styles.cost2 .. cost
    local effect1 = styles.effect1 .. skill.effect
    local effect2 = styles.effect2 .. skill.effect
    local order = styles.order .. skill.cost
    local element1, element2
    if skill.element then
        element1 = "\n||" .. skill.element or ""
        element2 = styles.cost2 .. skill.element or ""
    end

    local level1, level2
    if skill.pre then
        level1 = "\n||" .. skill.pre
        level2 = styles.cost2 .. skill.pre
    elseif level == "" then
        level1 = "\n||"
        level2 = styles.cost2
    elseif level then
        level1 = "\n||" .. level
        level2 = styles.cost2 .. level
    end

    if row == "r01" then
        return skillcell .. effect1 -- Odd number row for enemy whose skill cost is irrelevant.
    elseif row == "r02" then
        return skillcell .. effect2 -- Even number row for enemy whose skill cost is irrelevant.
    elseif row == "r11" then
        if game == "SMT3" and skill.phy then
            return skillcell .. styles.effect1p .. skill.effect -- Odd number row for enemy whose physical skills cost no HP.
        end
        return skillcell .. cost1 .. effect1 -- Odd number row for demon which does not learn new skill on level gain.
    elseif row == "r12" then
        if game == "SMT3" and skill.phy then
            return skillcell .. styles.effect2p .. skill.effect -- Even number row for enemy whose physical skills cost no HP.
        end
        return skillcell .. cost2 .. effect2 -- Even number row for demon which does not learn new skill on level gain.
    elseif row == "r21" then
        return skillcell .. cost1 .. effect1 .. level1 -- Odd number row for demon/persona which learn new skill on level gain.
    elseif row == "r22" then
        return skillcell .. cost2 .. effect2 .. level2 -- Even number row for demon/persona which learn new skill on level gain.
    elseif row == "r31" then
        return skillcell .. effect1 .. level1 -- Odd number row for guest who learn new skill on level gain.
    elseif row == "r32" then
        return skillcell .. effect2 .. level2 -- Even number row for guest who learn new skill on level gain.
    elseif row == "p12" then
        return styles.skill .. level .. styles.skillc .. code .. effect1 -- Row for Persona 1 and 2 persona
    elseif row == "rf" then
        return skillcell .. effect1 .. order -- Row for Persona-specific fusion spell.
    elseif row == "dk1" then
        return skillcell .. element1 .. cost1 .. effect1 -- Odd number row for DemiKids stats skill list.
    elseif row == "dk2" then
        return skillcell .. element2 .. cost2 .. effect2 -- Odd number row for DemiKids stats skill list.
    elseif row == "dkc1" then
        return skillcell .. level1 .. element1 .. cost1 .. effect1 -- Odd number row for DemiKids stats combo skill list.
    elseif row == "dkc2" then
        return skillcell .. level2 .. element2 .. cost2 .. effect2 -- Odd number row for DemiKids stats combo skill list.
    elseif row == "dkp" then
        return skillcell .. element2 .. effect2 -- row for DemiKids powers.
    end

    return '<strong style="color:red;font-size:150%">Invalid parameter 1 of ' .. '"' .. row .. '".</strong>' .. cate("Templates with unrecognizable row value for Module:Skills")
end

return p
