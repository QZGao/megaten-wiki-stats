local p = {}

-- Render Persona 3/P3 Reload reward rows before Theurgy sections.
-- Covers skill cards, heart items, and battle drops tied to Persona 3 enemies/personas.
function p.renderPersona3Rewards(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg
    if (gameg == "p3" or gameg == "p3re") and (prop.card or prop.preturn or prop.normal) then
        result = result .. styles.table2
        if prop.card then result = result .. styles.h .. "width=100px|[[Skill Card|" .. styles.spanc .. "Skill Card</span>]]" .. styles.order .. '<abbr title="Portable only">' .. prop.card .. "</abbr>" end
        if prop.preturn then result = result .. styles.h .. "width=100px|[[Heart Item|" .. styles.spanc .. "Heart Item</span>]]" .. styles.order .. prop.preturn end
        if prop.normal then result = result .. styles.h .. "width=100px|[[Battle Drops|" .. styles.spanc .. "Battle Drop</span>]]" .. styles.order .. prop.normal end
        result = result .. "\n|}"
    end
    return result
end

-- Render Persona 4 enemy drop rows.
-- Covers EXP, Yen, normal drops, and rare drops for P4/P4G enemy stat tables.
function p.renderPersona4Rewards(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg
    local gamegn = ctx.gamegn
    if (gameg == "p4") and prop.hp then
        result = result .. styles.table2
        prop.xp = prop.xp or "-"
        prop.yen = prop.yen or "-"
        prop.normal = prop.normal or "-"
        prop.rare = prop.rare or "-"
        result = result .. styles.h .. "|EXP" .. styles.h .. "|Yen" .. styles.h .. "|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Normal Drop</span>]]" .. styles.h .. "|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Rare Drop</span>]]" .. "\n|-\n"
        result = result .. styles.statlow .. prop.xp .. styles.statlow .. prop.yen .. styles.statlow .. prop.normal .. styles.statlow .. prop.rare
        result = result .. "\n|}"
    end
    return result
end

-- Render Persona 5-family and Soul Hackers 2 enemy reward rows.
-- Covers EXP, Yen, battle drops, negotiation items, P5X empty-row hiding, and SH2 battle drops.
function p.renderPersona5Rewards(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg
    local hasFilledValue = ctx.hasFilledValue
    if (gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x") and prop.hp then
        local has_drop_row = gameg ~= "p5x" or hasFilledValue(prop.xp) or hasFilledValue(prop.yen) or hasFilledValue(prop.normal) or hasFilledValue(prop.material) or hasFilledValue(prop.drop1) or hasFilledValue(prop.drop2) or hasFilledValue(prop.drop3) or hasFilledValue(prop.card) or hasFilledValue(prop.dropc)
        if has_drop_row then
            result = result .. styles.table2
            prop.xp = prop.xp or "-"
            prop.yen = prop.yen or "-"
            prop.normal = prop.normal or "-"
            prop.material = prop.material or prop.normal
            prop.drop1 = prop.drop1 or "-"
            prop.card = prop.card or "-"
            prop.dropc = prop.dropc or prop.card
            local cnt_drops = 2
            if prop.drop3 then
                cnt_drops = 4
            elseif prop.drop2 then
                cnt_drops = 3
            end
            if prop.drop1 == "-" and prop.dropc == "-" then cnt_drops = 1 end
            result = result .. styles.h .. "|EXP" .. styles.h .. "|Yen" .. styles.h .. "|[[Battle Drops|" .. styles.spanc .. "Battle Drop</span>]]" .. styles.h .. "colspan=" .. cnt_drops .. "|[[Negotiation|" .. styles.spanc .. "Negotiation Items</span>]]" .. "\n|-\n"
            result = result .. styles.statlow .. prop.xp .. styles.statlow .. prop.yen .. styles.statlow .. prop.material .. styles.statlow .. prop.drop1
            if prop.drop2 then result = result .. styles.statlow .. prop.drop2 end
            if prop.drop3 then result = result .. styles.statlow .. prop.drop3 .. " (Rare)" end
            if prop.dropc ~= "-" then result = result .. styles.statlow .. prop.dropc .. " ([[Skill Card|" .. styles.spanc .. "Skill Card</span>]])" end
            result = result .. "\n|}"
        end
    end
    if (gameg == "sh2") and (prop.xp or prop.yen or prop.normal) then
        result = result .. styles.table2
        prop.xp = prop.xp or "-"
        prop.yen = prop.yen or "-"
        prop.normal = prop.normal or "-"
        result = result .. styles.h .. "|EXP" .. styles.h .. "|Yen" .. styles.h .. "|[[Battle Drops|" .. styles.spanc .. "Battle Drop</span>]]" .. "\n|-\n"
        result = result .. styles.statlow .. prop.xp .. styles.statlow .. prop.yen .. styles.statlow .. prop.normal
        result = result .. "\n|}"
    end
    return result
end

-- Render legacy KMT/SMT drop-related rows after the image-span table closes.
-- Includes older mixed rows where drops, resistances, inherit, and moon affinity share one table.
function p.renderLegacyRewards(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local game = ctx.game
    local gameg = ctx.gameg
    local gamegn = ctx.gamegn
    if game == "kmt1" and prop.normal ~= "" then result = result .. styles.table2 .. styles.h .. "width=60px|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Drop</span>]]" .. styles.order .. prop.normal .. "\n|}" end
    if game == "smt1" and (prop.resist or prop.normal) then
        result = result .. styles.table2
        if prop.resist then result = result .. styles.h .. "width=100px|Resistances" .. styles.order .. prop.resist end
        if prop.normal then result = result .. styles.h .. "width=60px|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Drop</span>]]" .. styles.order .. prop.normal end
        result = result .. "\n|}"
    end
    if (game == "smt2" or gameg == "smtif") and (prop.normal or prop.inherit or prop.moon) then
        result = result .. styles.table2
        if prop.normal then result = result .. styles.h .. "width=60px|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Drop</span>]]" .. styles.order .. prop.normal end
        if prop.inherit then result = result .. styles.h .. "width=70px|Inherit" .. styles.order .. prop.inherit end
        if prop.moon then result = result .. styles.h .. "width=80px|[[Moon Phase System#Shin Megami Tensei II|" .. styles.spanc .. '<abbr title="Moon Phase Affinity Type">Moon Aff</abbr>]]' .. styles.order .. prop.moon end
        result = result .. "\n|}"
    end
    return result
end

-- Render Persona 2 summon/reward information.
-- Covers material cards, tarot cards, and summon-condition descriptions for P2IS/P2EP.
function p.renderPersona2Summon(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg
    if gameg == "p2is" or gameg == "p2ep" then
        if prop.card or prop.material or prop.type1 or prop.type2 or prop.type3 then
            result = result .. styles.table2 .. styles.h .. "colspan=4|Summon Information\n|-"
            if prop.material then result = result .. styles.skill .. "[[Material Card|" .. styles.spanc .. "Material Card</span>]]" .. styles.effect1 .. '[[File:Material_Card_Icon_(P2ISP).png|alt=|link=]] <span style="color:yellow;font-weight:bold">' .. prop.material .. "</span> Card" end
            if prop.card then result = result .. styles.skillc .. "[[Tarot Card|" .. styles.spanc .. "Tarot Cards</span>]]" .. styles.effect1 .. '<span style="color:yellow;font-weight:bold">' .. prop.card .. " [[File:Tarot_Card_Symbol_2.png|alt=|link=]] " .. prop.arcana .. "</span> Cards" end
            local effect1
            if prop.material then
                effect1 = '\n|colspan=3 style="background:#222;text-align:left"|'
            else
                effect1 = styles.effect1
            end
            if prop.type1 then result = result .. styles.skill .. prop.type1 .. effect1 .. prop.desc1 end
            if prop.type2 then result = result .. styles.skill .. prop.type2 .. effect1 .. prop.desc2 end
            if prop.type3 then result = result .. styles.skill .. prop.type3 .. effect1 .. prop.desc3 end
            result = result .. "\n|}"
        end
    end
    return result
end

-- Render generic fusion reward rows before the skill table.
-- Covers special fusion and electric-chair execution rows used by Persona-family pages.
function p.renderFusionRewards(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gamegn = ctx.gamegn
    if prop.fusion then result = result .. styles.table2 .. styles.h .. "width=100px|[[Special fusion#" .. gamegn .. "|" .. styles.spanc .. "Special fusion</span>]]" .. styles.order .. prop.fusion .. "\n|}" end
    if prop.elecchair then result = result .. styles.table2 .. styles.h .. "width=180px|Electric chair execution" .. styles.order .. prop.elecchair .. "\n|}" end
    return result
end

return p
