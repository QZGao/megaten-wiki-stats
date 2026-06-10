local Style = require("Module:Skills/Style")
local Stats = require("Module:Skills/Render/Stats")
local Affinity = require("Module:Skills/Render/Affinity")
local Drops = require("Module:Skills/Render/Drops")
local SkillTable = require("Module:Skills/Render/SkillTable")

local p = {}

-- Return per-render game metadata without mutating Module:Gamedata.
-- SMT3 historically rendered `colorbg` as `colorbg2` after overwriting the shared metadata table.
local function getEffectiveGameData(gameg, gameData)
    if gameg ~= "smt3" then
        return gameData
    end

    local effectiveGameData = {}
    for key, value in pairs(gameData) do
        effectiveGameData[key] = value
    end
    effectiveGameData.colorbg = gameData.colorbg2

    return effectiveGameData
end

-- Return the name and optional type for Persona 3 Reload Theurgy characteristic rows.
-- Missing type stays nil so the badge is omitted, matching the legacy single-field behavior.
local function splitTheurgyTrait(text)
    local firstSlash = string.find(text, "\\", 1, true)
    if not firstSlash then
        return text, nil
    end

    local secondSlash = string.find(text, "\\", firstSlash + 1, true)
    if not secondSlash then
        return string.sub(text, 1, firstSlash - 1), string.sub(text, firstSlash + 1)
    end

    return string.sub(text, 1, firstSlash - 1), string.sub(text, firstSlash + 1, secondSlash - 1)
end

-- SMT3 recruit/obtain labels keyed by normalized template input.
-- Used only by the coordinator's SMT3 post-affinity block; unknown inputs remain lowercased like the legacy elseif chain.
local smt3RecruitText = {
    yes = '<abbr title="Can be recruited in normal battle or obtained from conventional fusion.">Normal recruit or fusion</abbr>',
    ["dark recruit"] = '<abbr title="Can be obtained via conventional fusion or recruited in normal battle under Full Kagutsuchi with fair chance.">[[Moon Phase System#Shin Megami Tensei III: Nocturne|Full Kagutsuchi]] recruitment or [[fusion]]</abbr>',
    dark = '<abbr title="Can only be obtained via fusion. Open to non-recruitment conversation in normal battle.">[[Fusion]] only. Open to trading.</abbr>',
    fusion = '<abbr title="Can only be obtained via conventional fusion.">[[Fusion]] only</abbr>',
    special = '<abbr title="Can only be obtained via special fusion.">[[Special fusion#Shin Megami Tensei III: Nocturne|Special fusion]] only</abbr>',
    evolve = '<abbr title="Can only be obtained via evolution from another demon.">[[Evolution#Shin Megami Tensei III: Nocturne|Evolution]] only</abbr>',
    ["evolve neutral"] = '<abbr title="Can be recruited in normal battle or obtained via evolution from another demon. Cannot be created via fusion.">Normal recruit or [[Evolution#Shin Megami Tensei III: Nocturne|evolution]]</abbr>',
    ["evolve dark"] = '<abbr title="Can only be obtained via evolution from another demon. Cannot be created via fusion. Open to non-recruitment conversation in normal battle.">[[Evolution#Shin Megami Tensei III: Nocturne|Evolution]] only. Open to trading.</abbr>',
    ["boss fusion"] = '<abbr title="Can only be obtained via fusion after defeating it in boss battle.">[[Fusion]] only after boss battle</abbr>',
    ["boss special"] = '<abbr title="Can only be obtained via special fusion after defeating it in boss battle.">[[Special fusion#Shin Megami Tensei III: Nocturne|Special fusion]] only after boss battle</abbr>',
    ["boss evolve"] = '<abbr title="Can only be obtained via evolution after defeating it in battle.">[[evolution#Shin Megami Tensei III: Nocturne|Evolution]] only after boss battle</abbr>',
    ["dark boss fusion"] = '<abbr title="Can only be obtained via fusion after defeating it in boss battle. Open to non-recruitment conversation in normal battle.">[[Fusion]] only after boss battle. Open to trading.</abbr>',
    ["dark boss special fusion"] = '<abbr title="Can only be obtained via special fusion after defeating it in boss battle. Open to non-recruitment conversation in normal battle.">[[Special fusion#Shin Megami Tensei III: Nocturne|Special fusion]] only after boss battle. Open to trading.</abbr>',
    ["dark boss evolve"] = '<abbr title="Can only be obtained via evolution after defeating it in battle. Open to non-recruitment conversation in normal battle.">[[evolution#Shin Megami Tensei III: Nocturne|Evolution]] only after boss battle. Open to trading.</abbr>',
    samael = '<abbr title="Can only be obtained via special fusion after defeating it in boss battle or choosing Shijima Reason after meeting with Ahriman in Kagutsuchi Tower.">Choose Shijima Reason or perform [[Special fusion#Shin Megami Tensei III: Nocturne|special fusion]] only after boss battle.</abbr>',
    thor = '<abbr title="Can only be obtained via fusion after defeating him at Tower of Kagutsuchi.">[[Fusion]] only after boss battle at [[Tower of Kagutsuchi]]</abbr>',
    bishamon = '<abbr title="Can only be obtained via fusion after defeating him at Bandou Shrine.">[[Fusion]] only after boss battle at [[Bandou Shrine]]</abbr>',
    futomimi = "[[Fusion]] only after boss battle and completing the revival side quest.",
    raidou = '<abbr title="Can only be recruited in story plot.">Plot related</abbr>',
    unique = "Enemy only",
}
smt3RecruitText.recruit = smt3RecruitText.yes
smt3RecruitText["special fusion"] = smt3RecruitText.special
smt3RecruitText.evolution = smt3RecruitText.evolve
smt3RecruitText["neutral evolution"] = smt3RecruitText["evolve neutral"]
smt3RecruitText["dark evolution"] = smt3RecruitText["evolve dark"]
smt3RecruitText["boss special fusion"] = smt3RecruitText["boss special"]
smt3RecruitText["boss evolution"] = smt3RecruitText["boss evolve"]
smt3RecruitText.sakahagi = smt3RecruitText.futomimi
smt3RecruitText.dante = smt3RecruitText.raidou
smt3RecruitText.exclusive = smt3RecruitText.unique
smt3RecruitText.enemy = smt3RecruitText.unique
smt3RecruitText["enemy only"] = smt3RecruitText.unique
smt3RecruitText["enemy exclusive"] = smt3RecruitText.unique

-- Flush a queued top stat table when no matching top affinity table consumed it.
-- Used for Persona/P5X layouts where stat rows may merge horizontally with affinity rows.
local function flushPendingTopStats(ctx, result)
    if ctx.pending_top_stats then
        result = result .. ctx.pending_top_stats .. (ctx.pending_top_stats_categories or "")
        ctx.pending_top_stats = nil
        ctx.pending_top_stats_categories = nil
    end
    return result
end

-- Merge a pending top stat table with a top affinity table, or append the affinity table alone.
-- Used by Persona 3-5/P5X/Metaphor/Ronde top affinity rendering.
local function appendTopAffinityTable(ctx, result, affinity_table)
    if ctx.pending_top_stats then
        result = result .. ctx.styles.table2b .. '\n|style="padding:0;width:24%;vertical-align:top"|' .. ctx.pending_top_stats .. '\n|style="padding:0;width:76%;vertical-align:top"|' .. affinity_table .. "\n|}" .. (ctx.pending_top_stats_categories or "")
        ctx.pending_top_stats = nil
        ctx.pending_top_stats_categories = nil
    else
        result = result .. affinity_table
    end
    return result
end

-- Render the full stats box after Module:Skills has normalized args and built context.
-- Coordinates top stats, affinities, drops/rewards, miscellaneous rows, and the skill table in legacy output order.
function p.render(ctx)
    local prop = ctx.prop
    local data = ctx.data
    local game = ctx.game
    local gameg = ctx.gameg
    local gameData = getEffectiveGameData(gameg, ctx.gameData)
    local gamegn = ctx.gamegn
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local wikitext = ctx.wikitext

    ctx.gameData = gameData

    -- Let top affinity rendering merge with pending Persona/P5X/Metaphor stat rows.
    -- The child module stays focused on affinity markup while this coordinator owns row placement.
    ctx.appendTopAffinityTable = function(result, affinity_table)
        return appendTopAffinityTable(ctx, result, affinity_table)
    end
    local styles = Style.new(gameData)
    local root_border = gameg == "sh2" and gameData.colorbg or gameData.colorb
    local result = '{|align="center" style="min-width:650px;text-align:center; background: #222; border:2px solid ' .. root_border .. '; border-radius:10px; font-size:75%; font-family:verdana;"\n|-\n|' .. styles.table2b
    if prop.image then
        result = result .. '\n!style="width:20px;border:#333 solid 2px;border-radius:7px;background:'
        if game == "smt1" then
            result = result .. "#637373"
        elseif gameg == "smtif" then
            result = result .. "#3018b8"
        elseif game == "majin2" then
            result = result .. "#31315a"
        elseif gameg == "p1" or gameg == "p2is" or gameg == "p2ep" or (gameg == "p3" or gameg == "p3re") or gameg == "dcbrb" or gameg == "dcbrp" or gameg == "dcwb" or gameg == "childred" or gameg == "childps" or gameg == "childwhite" or gameg == "childfire" or gameg == "childlight" then
            result = result .. "transparent"
        else
            result = result .. "#000"
        end
        result = result .. '"|' .. prop.image
    end
    result = result .. "\n|"
    ctx.styles = styles
    result = Stats.renderTop(ctx, result)
    result = Affinity.renderTop(ctx, result)
    result = flushPendingTopStats(ctx, result)
    if (gameg == "p2is" or gameg == "p2ep") and (prop.exclusive or prop.traits or prop.convo) then
        result = result .. styles.table2
        if prop.exclusive then result = result .. styles.h .. "width=90px|Exclusive to" .. styles.order .. prop.exclusive end
        if prop.traits then result = result .. styles.h .. "width=50px|[[Personality|" .. styles.spanc .. "Traits</span>]]" .. styles.order .. prop.traits end
        if prop.convo then result = result .. styles.h .. "width=50px|[[Special conversation|" .. styles.spanc .. '<abbr style="border-bottom:1px dotted black;" title="if equipped with this Persona, there is a chance it will talk to this demon if encountered">Ptalk</abbr>]]' .. styles.order .. prop.convo end
        result = result .. "\n|}"
    end
    if (gameg == "p2is" or gameg == "p2ep") and prop.profile then result = result .. styles.table2b .. styles.quote .. '"|' .. string.gsub(prop.profile, "!!", "‼") .. "\n|}" end
    result = Drops.renderPersona3Rewards(ctx, result)
    if gameg == "p3re" and prop.theurgia then
        result = result .. styles.table2
        result = result .. styles.h .. "width=100px|[[Theurgy|" .. styles.spanc .. "Gauge Condition</span>]]" .. styles.order .. prop.theurgia
        result = result .. "\n|}"
    end
    if gameg == "p3re" and prop.ptraits then
        if string.find(prop.ptraits, "\n") then
            local traitRowCount = 1
            local traitStart = 1
            while true do
                local traitNewline = string.find(prop.ptraits, "\n", traitStart, true)
                if not traitNewline then break end
                traitRowCount = traitRowCount + 1
                traitStart = traitNewline + 1
            end

            result = result .. styles.table2
            result = result .. styles.h .. 'width=100px rowspan="' .. traitRowCount .. '"|[[Theurgy|' .. styles.spanc .. "Characteristics</span>]]" .. styles.order
            traitStart = 1
            for k = 1, traitRowCount do
                local traitNewline = string.find(prop.ptraits, "\n", traitStart, true)
                local v
                if traitNewline then
                    v = string.sub(prop.ptraits, traitStart, traitNewline - 1)
                    traitStart = traitNewline + 1
                else
                    v = string.sub(prop.ptraits, traitStart)
                end
                if k > 1 then result = result .. styles.order2 end
                local traitName, traitType = splitTheurgyTrait(v)
                local traitEffect = data.theurgies[traitName]

                if not traitEffect then
                    result = result .. '<span style="font-weight:bold;color:red">Invalid Theurgy name of "' .. traitName .. '". You may correct the Theurgy name or modify [[Module:Skills/' .. gamed .. "]] if needed</span>"
                else
                    result = result .. '<span style="font-weight:bold">' .. traitName .. ":</span> " .. traitEffect
                    if traitType then result = result .. '<div style="float:right;background:#696969;border-radius:15px;padding:0 10px">' .. traitType .. "</div>" end
                end
            end
            result = result .. "\n|}"
        else
            result = result .. styles.table2
            result = result .. styles.h .. "width=100px|[[Theurgy|" .. styles.spanc .. "Characteristics</span>]]" .. styles.order
            local traitName, traitType = splitTheurgyTrait(prop.ptraits)
            local traitEffect = data.theurgies[traitName]

            if not traitEffect then
                result = result .. '<span style="font-weight:bold;color:red">Invalid Theurgy name of "' .. traitName .. '". You may correct the Theurgy name or modify [[Module:Skills/' .. gamed .. "]] if needed</span>"
            else
                result = result .. '<span style="font-weight:bold">' .. traitName .. ":</span> " .. traitEffect
                if traitType then result = result .. '<div style="float:right;background:#696969;border-radius:15px;padding:0 10px">' .. traitType .. "</div>" end
            end
            result = result .. "\n|}"
        end
    end
    result = Drops.renderPersona4Rewards(ctx, result)
    if gameg == "p5r" and prop.ptraits then
        if string.find(prop.ptraits, "\\") then
            local traitRowCount = 1
            local traitStart = 1
            while true do
                local traitSlash = string.find(prop.ptraits, "\\", traitStart, true)
                if not traitSlash then break end
                traitRowCount = traitRowCount + 1
                traitStart = traitSlash + 1
            end

            result = result .. styles.table2
            result = result .. styles.h .. 'width=100px rowspan="' .. traitRowCount .. '"|[[Persona Traits|' .. styles.spanc .. "Persona Trait</span>]]" .. styles.order
            traitStart = 1
            for k = 1, traitRowCount do
                local traitSlash = string.find(prop.ptraits, "\\", traitStart, true)
                local v
                if traitSlash then
                    v = string.sub(prop.ptraits, traitStart, traitSlash - 1)
                    traitStart = traitSlash + 1
                else
                    v = string.sub(prop.ptraits, traitStart)
                end
                if k > 1 then result = result .. styles.order2 end
                local ptrait = data.traits[v]
                if not ptrait then
                    result = result .. '<span style="font-weight:bold;color:red">Invalid trait name of "' .. v .. '". You may correct the trait name or modify [[Module:Skills/' .. gamed .. "]] if needed</span>"
                else
                    if ptrait.exclusive then
                        result = result .. '<span style="font-weight:bold"><abbr title="' .. ptrait.exclusive .. '">' .. v .. "</abbr>:</span> " .. ptrait.effect
                    else
                        result = result .. '<span style="font-weight:bold">' .. v .. ":</span> " .. ptrait.effect
                    end
                end
            end
            result = result .. "\n|}"
        else
            result = result .. styles.table2
            result = result .. styles.h .. "width=100px|[[Persona Traits|" .. styles.spanc .. "Persona Trait</span>]]" .. styles.order
            local ptrait = data.traits[prop.ptraits]
            if not ptrait then
                result = result .. '<span style="font-weight:bold;color:red">Invalid trait name of "' .. prop.ptraits .. '". You may correct the trait name or modify [[Module:Skills/' .. gamed .. "]] if needed</span>"
            else
                if ptrait.exclusive then
                    result = result .. '<span style="font-weight:bold"><abbr title="' .. ptrait.exclusive .. '">' .. prop.ptraits .. "</abbr>:</span> " .. ptrait.effect
                else
                    result = result .. '<span style="font-weight:bold">' .. prop.ptraits .. ":</span> " .. ptrait.effect
                end
            end
            result = result .. "\n|}"
        end
    end
    result = Drops.renderPersona5Rewards(ctx, result)
    result = result .. "\n|}"
    -- End of image span.
    result = Drops.renderLegacyRewards(ctx, result)
    result = Affinity.renderSmtIfLegacy(ctx, result)
    if game == "smtim" then
        local seealso = prop.seealso or mw.title.getCurrentTitle().text
        result = result .. styles.table2 .. styles.h .. "width=50px|Features" .. styles.order .. prop.feature .. styles.h .. "width=60px|See also" .. styles.order .. "[https://web.archive.org/web/megaten.sesshou.com/wiki/index.php/" .. string.gsub(seealso, " ", "_") .. "]\n|}"
    end
    result = Affinity.renderPost(ctx, result)
    result = Drops.renderPersona2Summon(ctx, result)
    if gameg == "smt3" and (prop.recruit ~= "" or prop.obtain ~= "" or prop.evolvef or prop.evolvet) then
        prop.recruit = prop.recruit:lower()
        prop.recruit = smt3RecruitText[prop.recruit] or prop.recruit
        if prop.recruit or prop.obtain or prop.convo then
            result = result .. styles.table2 .. styles.h
            if prop.recruit or prop.obtain then result = result .. "width=80px|Obtainable" .. styles.order .. prop.recruit .. prop.obtain end
            if prop.convo then result = result .. styles.h .. "width=146px|[[Special conversation|" .. styles.spanc .. "Special conversation</span>]]" .. styles.order .. prop.convo end
            result = result .. "\n|}"
        end
        if prop.evolvef or prop.evolvet then
            result = result .. styles.table2
            if prop.evolvef then result = result .. styles.h .. "width=100px|[[Evolution#" .. gamegn .. "|" .. styles.spanc .. "Evolved from</span>]]" .. styles.order .. prop.evolvef end
            if prop.evolvet then result = result .. styles.h .. "width=100px|[[Evolution#" .. gamegn .. "|" .. styles.spanc .. "Evolves into</span>]]" .. styles.order .. prop.evolvet end
            result = result .. "\n|}"
        end
    end
    result = Drops.renderFusionRewards(ctx, result)
    result = SkillTable.render({
        styles = styles,
        prop = prop,
        data = data,
        gameData = gameData,
        game = game,
        gameg = gameg,
        gamegn = gamegn,
        gamed = gamed,
        noskill = noskill,
        wikitext = wikitext,
    }, result)
    if (gameg == "desu1" or gameg == "desu2") and (prop.quote or prop.profile) then
        result = result .. styles.table2
        if prop.quote then result = result .. styles.quote .. 'font-style:italic"|' .. string.gsub(prop.quote, "!!", "‼") end
        if prop.profile then result = result .. "\n|-" .. styles.quote .. 'font-style:italic"|' .. string.gsub(prop.profile, "!!", "‼") end
        result = result .. "\n|}"
    end
    if game == "smtsj" and prop.profile then result = result .. styles.table2 .. styles.h .. "|Password" .. styles.quote .. 'font-weight:bold;font-family:Courier New,sans-serif;font-size:1.6em"|' .. prop.profile .. "\n|}" end
    result = result .. "\n|}"
    return result
end

return p
--[[Category:Skills modules|!]]
