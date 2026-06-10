local p = {}

local baseStyles = {
    ["skill"] = '\n|-\n!style="background:#000;color:#fff"|',
    ["skillc"] = '\n!style="background:#000;color:#fff"|',
    ["skill2"] = '\n|-\n!style="background:#000;color:#fff" ',
    ["skill3"] = '\n!style="background:#000;color:#fff;',
    ["skill3m"] = '\n!style="background:transparent"|',
    ["cost1"] = '\n|style="background:#222"|',
    ["cost2"] = '\n|style="background:#282828"|',
    ["cost3"] = '\n|style="background:#222" ',
    ["effect1"] = '\n|style="background:#222;text-align:left;padding-left:5px"|',
    ["effect2"] = '\n|style="background:#282828;text-align:left;padding-left:5px"|',
    ["effect1p"] = '\n|colspan=2 style="background:#222;text-align:left;padding-left:5px"|',
    ["effect2p"] = '\n|colspan=2 style="background:#282828;text-align:left;padding-left:5px"|',
    ["order"] = '\n|style="background:#000;color:#fff;text-align:left;padding-left:5px"|',
    ["order2"] = '\n|-\n|style="background:#000;color:#fff;text-align:left;padding-left:5px"|',
    ["table2h"] = '\n{|width="100%" class="customtable ',
    ["table2"] = '\n{|width="100%" class="customtable"',
    ["table2b"] = '\n{|cellpadding=0 cellspacing=0 style="width:100%;background:transparent" ',
    ["statlow"] = '\n|style="background:#000;color:#fff"|',
    ["statlow2"] = '\n|style="background:#fff;color:#000"|',
    ["statlow3"] = '\n|style="background:#000;',
    ["quote"] = '\n|-\n|style="background:#000;color:#fff;text-align:center;border-radius:3.5px;',
}

-- Build a fresh copy of style constants shared by all games and row renderers.
-- Used by Module:Skills, Module:Skills/Row, and render modules that need base table/cell fragments.
local function newBaseStyles()
    local styles = {}
    for key, value in pairs(baseStyles) do
        styles[key] = value
    end
    return styles
end

-- Build the style table for one stats render.
-- With gameData, adds per-game header colors and stat-bar fragments; without it, returns only game-neutral row styles.
function p.new(gameData)
    local styles = newBaseStyles()

    if gameData then
        styles.h = '\n!style="background: ' .. gameData.colorbg .. ";color: " .. gameData.font .. '" '
        styles.spanc = '<span style="color:' .. gameData.font .. '">'
        local statTextColor = gameData.statt or "#529488"
        styles.barh = '\n|style="color:' .. statTextColor .. '" '
        styles.bart11 = '\n|rowspan=2 style="padding:0" width='
        styles.bart12 = '|\n{|cellspacing=2 cellpadding=0 style="background:transparent;font-size:11px;font-family:monospace;letter-spacing:-1px;line-height:'
        styles.bard = '\n|style="text-align:right;padding:0 3px" '
        styles.bard1 = styles.bard .. "width=12px|"
        styles.bard2 = styles.bard .. "width=17px|"
        if gameData.statb == nil then
            styles.barc = "orange"
        else
            styles.barc = gameData.statb
        end
    end

    return styles
end

return p
