local p = {}

local smt4_skilltypes = {
    ["phys"] = "[[File:PhysIcon_SMTIV.png|alt=Physical|Physical|link=Physical Skills]] Physical",
    ["gun"] = "[[File:GunIcon2.png|alt=Gun|Gun|link=Gun Skills]] Gun",
    ["fire"] = "[[File:FireIcon_SMTIV.png|alt=Fire|Fire|link=Fire Skills]] Fire",
    ["ice"] = "[[File:IceIcon_SMTIV.png|alt=Ice|Ice|link=Ice Skills]] Ice",
    ["elec"] = "[[File:ElecIcon_SMTIV.png|alt=Electricity|Electricity|link=Electric Skills]] Electricity",
    ["force"] = "[[File:ForceIcon.png|alt=Force|Force|link=Wind Skills]] Force",
    ["light"] = "[[File:ExpelIcon_SMTIV.png|alt=Light|Light|link=Expel Skills]] Light",
    ["dark"] = "[[File:CurseIcon_SMTIV.png|alt=Dark|Dark|link=Death Skills]] Dark",
    ["almighty"] = "[[File:AlmightyIcon_SMTIV.png|alt=Almighty|Almighty|link=Almighty Skills]] Almighty",
    ["ailment"] = "[[File:AilmentIcon_SMTIV.png|alt=Ailment|Ailment|link=Ailment Skills]] Ailment",
    ["heal"] = "[[File:HealIcon_SMTIV.png|alt=Healing|Healing|link=Healing Skills]] Healing",
    ["support"] = "[[File:SupportIcon_SMTIV.png|alt=Support|Support|link=Support Skills]] Support",
}

-- Return the first two backslash-separated fields used by SMT4/SMT5 specialty rows.
-- Missing modifiers intentionally become empty strings to match the legacy `v1 .. "\\"` split behavior.
local function splitSpecialtyPair(text)
    local firstSlash = string.find(text, "\\", 1, true)
    if not firstSlash then
        return text, ""
    end

    local secondSlash = string.find(text, "\\", firstSlash + 1, true)
    if not secondSlash then
        return string.sub(text, 1, firstSlash - 1), string.sub(text, firstSlash + 1)
    end

    return string.sub(text, 1, firstSlash - 1), string.sub(text, firstSlash + 1, secondSlash - 1)
end

-- Iterate newline-separated specialty parameters without allocating a split table.
-- Used by SMT4 skill affinities and SMT5 skill potential; preserves trailing empty lines.
local function eachLine(text)
    local index = 0
    local position = 1
    local done = false

    return function()
        if done then
            return nil
        end

        index = index + 1
        local newline = string.find(text, "\n", position, true)
        if newline then
            local line = string.sub(text, position, newline - 1)
            position = newline + 1
            return index, line, true
        end

        done = true
        return index, string.sub(text, position), false
    end
end

-- Render top stat/header sections inside the image-span table.
-- Covers main stat layouts for MT/KMT/SMT, Persona, Devil Summoner, Devil Survivor, Last Bible, DemiKids, DDS, PQ, Metaphor, and related games.
function p.renderTop(ctx, result)
    local gameData = ctx.gameData
    local baseGameData = ctx.baseGameData
    local args = ctx.args
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local game = ctx.game
    local gameg = ctx.gameg
    local render_game = gameg
    local gamen = ctx.gamen
    local gamegn = ctx.gamegn
    local gamed = ctx.gamed
    local rarityCategory = ctx.rarityCategory
    local cate = ctx.cate
    local noskill = ctx.noskill
    local getRace = ctx.getRace
    local getArcana = ctx.getArcana
    local aligncat = ctx.aligncat
    local alignnocat = ctx.alignnocat
    local bossdemoncat = ctx.bossdemoncat
    local bossdemonnocat = ctx.bossdemonnocat
    local bar = ctx.bar
    local hasFilledValue = ctx.hasFilledValue
    if game == "mt1" or game == "mt2" or game == "kmt1" or game == "kmt2" then
        render_game = game
    end
    if prop.location then
        prop.location = "[[" .. prop.location .. "]]"
    else
        prop.location = ""
    end
    if (gameg == "p2is" or gameg == "p2ep" or gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x") and prop.quote then result = result .. styles.table2b .. styles.quote .. 'font-style:italic"|' .. string.gsub(prop.quote, "!!", "‼") .. "\n|}" end -- replace exclamation mark otherwise it will be interpreted as wiki table seperator.
    if render_game == "mt1" then
        if not prop.hp then prop.hp = "" end
        if not prop.xp then prop.xp = "" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        if not prop.yen then prop.yen = "" end
        if prop.xp ~= "" and prop.mag ~= "" then
            result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|EXP" .. styles.h .. "|[[Macca|" .. styles.spanc .. "Macca</span>]]" .. styles.h .. "|[[Magnetite|" .. styles.spanc .. "MAG</span>]]\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.xp .. styles.statlow .. prop.yen .. styles.statlow .. prop.mag .. "\n|}"
        elseif prop.mp ~= "" and prop.cp ~= "" then
            result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Cost Point - MAG Cost per 10 steps"|<abbr>CP</abbr>' .. styles.h .. "|[[Macca|" .. styles.spanc .. "Macca</span>]]\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.cp .. styles.statlow .. prop.yen .. "\n|}"
        end
        result = result .. styles.table2 .. styles.h .. "|Strength" .. styles.h .. "|Intelligence" .. styles.h .. "|Hit" .. styles.h .. "|Agility" .. styles.h .. "|Defense" .. styles.h .. "|[[Daimakyuu|" .. styles.spanc .. "Location</span>]]\n|-" .. styles.statlow .. prop.str .. styles.statlow .. prop.int .. styles.statlow .. prop.hit .. prop.luc .. styles.statlow .. prop.agl .. styles.statlow .. prop.def .. prop.vit .. styles.statlow .. prop.location .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    elseif render_game == "mt2" then
        if not prop.hp then prop.hp = "" end
        if not prop.mp then prop.mp = "" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        if not prop.yen then prop.yen = "" end
        if not prop.normal then prop.normal = "" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Cost Point - MAG Cost per 10 Steps"|<abbr>CP</abbr>\n|-' .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.cp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. 'title="Number appearing in battle"|<abbr>Formations</abbr>' .. styles.h .. "|[[Magnetite|" .. styles.spanc .. "MAG]]" .. styles.h .. "|[[Macca|" .. styles.spanc .. "Macca</span>]]" .. styles.h .. "|[[List of Megami Tensei II Items|" .. styles.spanc .. "Item Drops</span>]]\n|-" .. styles.statlow .. prop.formation .. styles.statlow .. prop.mag .. styles.statlow .. prop.yen .. styles.statlow .. prop.normal .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Stamina" .. styles.h .. "|Intelligence" .. styles.h .. "|Attack" .. styles.h .. "|Agility" .. styles.h .. "|Luck" .. styles.h .. "|Defense\n|-" .. styles.statlow .. prop.vit .. styles.statlow .. prop.int .. styles.statlow .. prop.atk .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. styles.statlow .. prop.def .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    elseif render_game == "kmt1" or render_game == "kmt2" then
        if not prop.hp then prop.hp = "" end
        if not prop.mp then prop.mp = "" end
        if prop.noa == "" then prop.noa = "1" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        if not prop.xp then prop.xp = "" end
        if not prop.yen then prop.yen = "" end
        if not prop.normal then prop.normal = "" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Vitality"|VIT' .. styles.h .. 'title="Intellect"|INT' .. styles.h .. 'title="Strength"|STR' .. styles.h .. 'title="Speed"|SPD' .. styles.h .. 'title="Luck"|LUC' .. styles.h .. 'title="Defense"|DEF\n|-' .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.vit .. styles.statlow .. prop.int .. styles.statlow .. prop.str .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. styles.statlow .. prop.def .. "\n|}" .. bossdemoncat(prop.boss, gamen)
        result = result .. styles.table2 .. styles.h .. 'title="Cost Point - MAG Cost per 10 steps"|<abbr>CP</abbr>' .. styles.h .. 'title="Number of Attacks"|<abbr>NOA</abbr>' .. styles.h .. "|EXP" .. styles.h .. "|[[Macca|" .. styles.spanc .. "Macca</span>]]" .. styles.h .. 'title="Magnetite dropped"|[[Magnetite|' .. styles.spanc .. "<abbr>MAG</abbr></span>]]" .. styles.h
        if game == "kmt1" then
            result = result .. "|[[Daimakyuu|" .. styles.spanc .. "Location</span>]]"
        elseif game == "kmt2" then
            result = result .. "|[[List of Megami Tensei II Items|" .. styles.spanc .. "Item Drops</span>]]"
        end
        result = result .. "\n|-" .. styles.statlow .. prop.cp .. styles.statlow .. prop.noa .. styles.statlow .. prop.xp .. styles.statlow .. prop.yen .. styles.statlow .. prop.mag .. styles.statlow
        if game == "kmt1" then
            result = result .. prop.location .. "\n|}"
        elseif game == "kmt2" then
            result = result .. prop.normal .. "\n|}"
        end
    elseif render_game == "smt1" or render_game == "smt2" or render_game == "smtif" or render_game == "20xx" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        result = result .. styles.table2b .. "\n|" .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|[[Alignment|" .. styles.spanc .. "Alignment</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}"
        result = result .. styles.table2 .. styles.h
        if prop.boss or prop.enemy then
            result = result .. "|[[Magnetite|" .. styles.spanc .. "MAG</span>]]"
        else
            result = result .. 'title="Cost Point - MAG Cost per 10 steps"|<abbr>CP</abbr>'
        end
        result = result .. styles.h .. 'title="Number of Attacks"|<abbr>NOA</abbr>' .. styles.h .. 'title="Physical Attack Power"|ATK' .. styles.h .. 'title="Physical Attack Accuracy"|ACC' .. styles.h .. 'title="Defenses"|DEF' .. styles.h .. 'title="Evasion"|EVA' .. styles.h .. 'title="Magical Attack Power"|M.ATK' .. styles.h .. 'title="Magical Hit-rate"|M.EFC'
        result = result .. "\n|-" .. styles.statlow .. prop.mag .. prop.cp .. styles.statlow .. prop.noa .. styles.statlow .. prop.atk .. styles.statlow .. prop.hit .. styles.statlow .. prop.def .. styles.statlow .. prop.avd .. styles.statlow .. prop.mpw .. styles.statlow .. prop.mef .. "\n|}\n|}" .. styles.bart11 .. "200px" .. styles.bart12 .. '1.4"' .. styles.barh .. 'title="Strength"|St' .. styles.bard1 .. bar(styles.barc, prop.str, 4, 40) .. styles.barh .. 'title="Intelligence"|In' .. styles.bard1 .. bar(styles.barc, prop.int, 4, 40) .. styles.barh .. 'title="Magic"|Ma' .. styles.bard1 .. bar(styles.barc, prop.magic, 4, 40) .. styles.barh .. 'title="Vitality"|Vi' .. styles.bard1 .. bar(styles.barc, prop.vit, 4, 40) .. styles.barh .. 'title="Agility"|Ag' .. styles.bard1 .. bar(styles.barc, prop.agl, 4, 40) .. styles.barh .. 'title="Luck"|Lu' .. styles.bard1 .. bar(styles.barc, prop.luc, 4, 40) .. "\n|}" .. bossdemonnocat(prop.boss, prop.nocat, gamen)
        if game == "smtifhc" or gameg == "20xx" then
        else
            result = result .. alignnocat(prop.alignment, prop.nocat, gamen)
        end
    elseif render_game == "smt9" then
        local magCostLabel = 'title="Cost Point - MAG Cost per 10 steps"|<abbr>CP</abbr>'
        local capbuilddestroy = styles.h .. "|Capacity" .. styles.h .. "|Build Speed" .. styles.h .. 'title="Destruction Speed"|Dest. Speed\n|-'
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        if not prop.capacity then prop.capacity = "" end
        if not prop.buildspeed then prop.buildspeed = "" end
        if not prop.destroyspeed then prop.destroyspeed = "" end

        result = result .. styles.table2b .. "\n|" .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|[[Alignment|" .. styles.spanc .. "Alignment</span>]]" .. styles.h .. "|Level\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. styles.statlow .. prop.level .. "\n|}"
        if prop.boss or prop.enemy then
            magCostLabel = "|[[Magnetite|" .. styles.spanc .. "MAG</span>]]"
            capbuilddestroy = "\n|-"
        end
        result = result .. styles.table2 .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. magCostLabel .. capbuilddestroy .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.mag .. prop.cp
        if prop.boss or prop.enemy then
            result = result .. "\n|}"
        else
            result = result .. styles.statlow .. prop.capacity .. styles.statlow .. prop.buildspeed .. styles.statlow .. prop.destroyspeed .. "\n|}"
        end
        result = result .. styles.table2 .. styles.h .. 'title="Physical Attack Power"|ATK' .. styles.h .. 'title="Physical Attack Accuracy"|ACC' .. styles.h .. 'title="Number of Attacks"|<abbr>NOA</abbr>' .. styles.h .. 'title="Physical Defense"|DEF' .. styles.h .. 'title="Evasion"|EVA' .. styles.h .. 'title="Magical Attack Power"|M.ATK' .. styles.h .. 'title="Magical Hit-rate"|M.EFC' .. styles.h .. 'title="Magical Defense"|M.DEF\n|-' .. styles.statlow .. prop.atk .. styles.statlow .. prop.hit .. styles.statlow .. prop.noa .. styles.statlow .. prop.def .. styles.statlow .. prop.avd .. styles.statlow .. prop.mpw .. styles.statlow .. prop.mef .. styles.statlow .. prop.mdef .. "\n|}\n|}" .. styles.bart11 .. "200px" .. styles.bart12 .. '1.4"' .. styles.barh .. 'title="Strength"|St' .. styles.bard1 .. bar(styles.barc, prop.str, 4, 40) .. styles.barh .. 'title="Intelligence"|In' .. styles.bard1 .. bar(styles.barc, prop.int, 4, 40) .. styles.barh .. 'title="Magic"|Ma' .. styles.bard1 .. bar(styles.barc, prop.magic, 4, 40) .. styles.barh .. 'title="Vitality"|Vi' .. styles.bard1 .. bar(styles.barc, prop.vit, 4, 40) .. styles.barh .. 'title="Agility"|Ag' .. styles.bard1 .. bar(styles.barc, prop.agl, 4, 40) .. styles.barh .. 'title="Luck"|Lu' .. styles.bard1 .. bar(styles.barc, prop.luc, 4, 40) .. "\n|}" .. bossdemonnocat(prop.boss, prop.nocat, gamen) .. alignnocat(prop.alignment, prop.nocat, gamen)
    elseif render_game == "smt3" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h
        if prop.element then
            result = result .. "|Element" .. styles.h .. "|Wild Effects" .. cate("Magatama")
            styles.barc = gameData.statb2
        else
            result = result .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. bossdemoncat(prop.boss, gamen) .. styles.h .. "width=9%|Level" .. styles.h .. 'width=9%|<span style="color:' .. gameData.hp .. '">HP</span>' .. styles.h .. 'width=9%|<span style="color:' .. gameData.mp .. '">MP</span>'
        end
        result = result .. styles.bart11 .. "319px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 6, 40) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 6, 40) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 6, 40) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 6, 40) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 6, 40) .. "\n|}\n|-" .. styles.statlow
        if prop.element then
            result = result .. prop.element .. styles.statlow .. prop.wild
        else
            result = result .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. gameData.hp2 .. ';border-radius:3px"></div>' .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. gameData.mp2 .. ';border-radius:3px"></div>'
        end
        result = result .. "\n|}"
    elseif render_game == "smtim" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|[[Alignment|" .. styles.spanc .. "Alignment</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Growth" .. styles.h .. "|Inherit" .. styles.h .. 'title="Strength"|St' .. styles.h .. 'title="Magic"|Ma' .. styles.h .. 'title="Vitality"|Vi' .. styles.h .. 'title="Intelligence"|In' .. styles.h .. 'title="Speed"|Sp' .. styles.h .. 'title="Luck"|Lu'
        result = result .. "\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. aligncat(prop.alignment, gamen) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.growth .. styles.statlow .. prop.inherit .. styles.statlow .. prop.str .. styles.statlow .. prop.magic .. styles.statlow .. prop.vit .. styles.statlow .. prop.int .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Force Slot" .. styles.h .. 'title="Close Range"|<abbr>Close</abbr>' .. styles.h .. 'title="Long Range"|<abbr>Long</abbr>' .. styles.h .. "|Spell" .. styles.h .. "|Support" .. styles.h .. 'title="Physical Defense"|P.Def' .. styles.h .. 'title="Magical Defense"|M.Def' .. styles.h .. "|Critical" .. styles.h .. 'title="Critical Defense"|Crt.Def\n|-'
        result = result .. styles.statlow .. prop.forceslot .. styles.statlow .. prop.closerange .. styles.statlow .. prop.longrange .. styles.statlow .. prop.spell .. styles.statlow .. prop.support .. styles.statlow .. prop.def .. styles.statlow .. prop.mdef .. styles.statlow .. prop.critical .. styles.statlow .. prop.critdef .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    elseif render_game == "smtsj" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|[[Alignment|" .. styles.spanc .. "Alignment</span>]]" .. styles.h .. "|Level" .. styles.h .. 'width=7%|<span style="color:' .. gameData.hp .. '">HP</span>' .. styles.h .. 'width=7%|<span style="color:' .. gameData.mp .. '">MP</span>' .. styles.bart11 .. "274px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard1 .. bar(styles.barc, prop.str, 2, 99) .. styles.barh .. "|Magic" .. styles.bard1 .. bar(styles.barc, prop.magic, 2, 99) .. styles.barh .. "|Vitality" .. styles.bard1 .. bar(styles.barc, prop.vit, 2, 99) .. styles.barh .. "|Agility" .. styles.bard1 .. bar(styles.barc, prop.agl, 2, 99) .. styles.barh .. "|Luck" .. styles.bard1 .. bar(styles.barc, prop.luc, 2, 99) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px outset #ddbf77;border-radius:3px"></div>' .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px outset #85bd64;border-radius:3px"></div>' .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. aligncat(prop.alignment, gamen)
    elseif render_game == "smt4" or render_game == "smt4a" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        styles.h = '\n!style="color:' .. gameData.colorbg2 .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style="color:' .. gameData.font2 .. '">Level</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.hp .. '">HP</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.mp .. '">MP</span>' .. styles.bart11 .. "387px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 1.5, 200) .. styles.barh .. "|Dexterity" .. styles.bard2 .. bar(styles.barc, prop.dex, 1.5, 200) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 1.5, 200) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 1.5, 200) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 1.5, 200) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}" .. bossdemoncat(prop.boss, gamen)
        if not prop.phys then prop.phys = "-" end
        if not prop.gun then prop.gun = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.curse then prop.curse = "-" end
        styles.h = '\n!style="background:' .. gameData.colorbg2
        local statlow = '\n|style="background:' .. gameData.colorbg2
        if gameg == "smt4a" then
            styles.h = styles.h .. ';color:#fff" '
            statlow = statlow .. ';color:#fff"|'
        elseif gameg == "smt4" then
            styles.h = styles.h .. ';color:#000" '
            statlow = statlow .. ';color:#000"|'
        end
        result = result .. styles.table2 .. styles.h .. 'width=12.5% title="Physical"|[[File:PhysIcon_SMTIV.png|alt=Physical|Physical|link=Physical Skills]] Phys' .. styles.h .. 'width=12.5% title="Gun"|[[File:GunIcon2.png|alt=Gun|Gun|link=Gun Skills]] Gun' .. styles.h .. 'width=12.5% title="Fire"|[[File:FireIcon_SMTIV.png|alt=Fire|Fire|link=Fire Skills]] Fire' .. styles.h .. 'width=12.5% title="Ice"|[[File:IceIcon_SMTIV.png|alt=Ice|Ice|link=Ice Skills]] Ice' .. styles.h .. 'width=12.5% title="Electricity"|[[File:ElecIcon_SMTIV.png|alt=Electricity|Electricity|link=Electric Skills]] Elec' .. styles.h .. 'width=12.5% title="Force"|[[File:ForceIcon.png|alt=Force|Force|link=Wind Skills]] Force' .. styles.h .. 'width=12.5% title="Light"|[[File:ExpelIcon_SMTIV.png|alt=Light|Light|link=Expel Skills]] Light' .. styles.h .. 'width=12.5% title="Dark"|[[File:CurseIcon_SMTIV.png|alt=Dark|Dark|link=Death Skills]] Dark\n|-\n' .. statlow .. prop.phys .. statlow .. prop.gun .. statlow .. prop.fire .. statlow .. prop.ice .. statlow .. prop.elec .. statlow .. prop.force .. statlow .. prop.expel .. statlow .. prop.curse .. "\n|}"
        styles.h = '\n!style="background: ' .. gameData.colorbg .. ";color: " .. gameData.font .. '" '
        result = result .. styles.table2 .. styles.h .. 'width=130px title="All enemies and guest allies are immune to ' .. "'Lost'" .. ' ailment"|<abbr>'
        if prop.almres ~= "" then
            result = result .. "Other"
        else
            result = result .. "Ailment"
        end
        result = result .. " Resistance</abbr>" .. styles.order .. prop.almres .. prop.res .. "\n|}" .. styles.table2 .. styles.h .. "width=100px|Normal Attack" .. styles.order .. prop.noa
        if prop.turnicon then result = result .. styles.h .. "width=70px|[[Press Turn|" .. styles.spanc .. "Turn Icon</span>]]" .. styles.order .. prop.turnicon end
        result = result .. "\n|}"
        if prop.requiredquest or prop.relatedquest or prop.normal then
            result = result .. styles.table2
            if prop.requiredquest then
                result = result .. styles.h .. "width=100px|[[Challenge Quests|" .. styles.spanc .. "Required quest</span>]]" .. styles.order .. prop.requiredquest
            elseif prop.relatedquest then
                result = result .. styles.h .. "width=100px|[[Challenge Quests|" .. styles.spanc .. "Related quest</span>]]" .. styles.order .. prop.relatedquest
            end
            if prop.normal then result = result .. styles.h .. "width=70px|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Drop</span>]]" .. styles.order .. prop.normal end
            result = result .. "\n|}"
        end
        if prop.evolvef or prop.evolvet then
            result = result .. styles.table2
            if prop.evolvef then result = result .. styles.h .. "width=100px|[[Evolution#" .. gamegn .. "|" .. styles.spanc .. "Evolved from</span>]]" .. styles.order .. prop.evolvef .. " (" .. prop.evolvefl .. ")" end
            if prop.evolvet then result = result .. styles.h .. "width=100px|[[Evolution#" .. gamegn .. "|" .. styles.spanc .. "Evolves into</span>]]" .. styles.order .. prop.evolvet .. " (" .. prop.evolvetl .. ")" end
            result = result .. "\n|}"
        end
        if prop.specialty then
            result = result .. styles.table2 .. styles.h .. 'width=100px|[[Skill Affinities|<span style="color:#000">Skill Affinities</span>]]' .. styles.order
            for k1, v1, hasNext in eachLine(prop.specialty) do
                local skilltype, modifier = splitSpecialtyPair(v1)
                result = result .. '<span style="white-space:nowrap">' .. smt4_skilltypes[skilltype:lower()]
                if string.sub(modifier, 1, 1) == "+" then
                    result = result .. ' <span style="color:#5f5">' .. modifier .. "</span></span>"
                else
                    result = result .. ' <span style="color:#f55">' .. modifier .. "</span></span>"
                end
                if hasNext then -- add dot separator if it's not the last entry
                    result = result .. " · "
                    if k1 == 6 then result = result .. "<br/>" end
                end
            end
            result = result .. "\n|}"
        end
    elseif render_game == "smt5" or render_game == "smt5v" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        styles.h = '\n!style="color:' .. gameData.colorbg2 .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style="color:' .. gameData.font2 .. '">Level</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.hp .. '">HP</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.mp .. '">MP</span>' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 100) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 100) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 2.4, 100) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 100) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 100) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. aligncat(prop.alignment, gamen)
        if not prop.phys then prop.phys = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.curse then prop.curse = "-" end
        styles.h = '\n!style="background:' .. gameData.colorbg2 .. ';color:#fff" '
        local statlow = '\n|style="background:' .. gameData.colorbg2 .. ';color:#fff"|'
        result = result .. styles.table2 .. styles.h .. 'width=14.8% title="Physical"|[[File:PhysIcon_SMTV.png|24px|alt=Physical|Physical|link=Physical Skills]] [[Physical Skills|<span style="color:white">Phys</span>]]' .. styles.h .. 'width=14.2% title="Fire"|[[File:FireIcon_SMTV.png|24px|alt=Fire|Fire|link=Fire Skills]] [[Fire Skills|<span style="color:white">Fire</span>]]' .. styles.h .. 'width=14.2% title="Ice"|[[File:IceIcon_SMTV.png|24px|Ice|link=Ice Skills]] [[Ice Skills|<span style="color:white">Ice</span>]]' .. styles.h .. 'width=14.2% title="Electricity"|[[File:ElecIcon_SMTV.png|24px|alt=Electricity|Electricity|link=Electric Skills]] [[Electric Skills|<span style="color:white">Elec</span>]]' .. styles.h .. 'width=14.2% title="Force"|[[File:ForceIcon_SMTV.png|24px|alt=Force|Force|link=Force Skills]] [[Force Skills|<span style="color:white">Force</span>]]' .. styles.h .. 'width=14.2% title="Light"|[[File:LightIcon_SMTV.png|24px|alt=Light|Light|link=Light Skills (Affinity)]] [[Light Skills (Affinity)|<span style="color:white">Light</span>]]' .. styles.h .. 'width=14.2% title="Dark"|[[File:DarkIcon_SMTV.png|24px|Dark|link=Dark Skills (Affinity)]] [[Dark Skills (Affinity)|<span style="color:white">Dark</span>]]\n|-\n' .. statlow .. prop.phys .. statlow .. prop.fire .. statlow .. prop.ice .. statlow .. prop.elec .. statlow .. prop.force .. statlow .. prop.expel .. statlow .. prop.curse .. "\n|}"
        styles.h = '\n!style="background: ' .. gameData.colorbg .. ";color: " .. gameData.font .. '" '
        result = result .. styles.table2 .. styles.h .. 'width=130px title="All enemies and guest allies are immune to ' .. "'Lost'" .. ' ailment"|<abbr>'
        if prop.almres ~= "" then
            result = result .. "Other"
        else
            result = result .. "Ailment"
        end
        result = result .. " Resistance</abbr>" .. styles.order .. prop.almres .. prop.res .. "\n|}"
        if prop.turnicon then result = result .. styles.table2 .. styles.h .. "width=70px|[[Press Turn|" .. styles.spanc .. "Turn Icon</span>]]" .. styles.order .. prop.turnicon .. "\n|}" end
        if prop.requiredquest or prop.relatedquest or prop.normal then
            result = result .. styles.table2
            if prop.requiredquest then
                result = result .. styles.h .. "width=100px|[[Challenge Quests|" .. styles.spanc .. "Required quest</span>]]" .. styles.order .. prop.requiredquest
            elseif prop.relatedquest then
                result = result .. styles.h .. "width=100px|[[Challenge Quests|" .. styles.spanc .. "Related quest</span>]]" .. styles.order .. prop.relatedquest
            end
            if prop.normal then result = result .. styles.h .. "width=70px|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Drop</span>]]" .. styles.order .. prop.normal end
            result = result .. "\n|}"
        end
        if prop.specialty then
            styles.h = '\n!style="background:' .. gameData.colorbg2 .. ';color:#fff" '
            local skilltypes = {
                ["phys"] = "-",
                ["fire"] = "-",
                ["ice"] = "-",
                ["elec"] = "-",
                ["force"] = "-",
                ["light"] = "-",
                ["dark"] = "-",
                ["almighty"] = "-",
                ["ailment"] = "-",
                ["heal"] = "-",
                ["support"] = "-",
            }
            result = result .. styles.table2h .. '"' .. styles.h .. "colspan=4|[[Skill Affinities|" .. styles.spanc .. "Skill Potential</span>]]"
            local restemp
            for _, v1 in eachLine(prop.specialty) do
                local modifier
                restemp, modifier = splitSpecialtyPair(v1)
                restemp = restemp:lower()
                if string.sub(modifier, 1, 1) == "+" then
                    skilltypes[restemp] = ' <span style="color:#5f5">' .. modifier .. "</span></span>"
                else
                    skilltypes[restemp] = ' <span style="color:#f55">' .. modifier .. "</span></span>"
                end
            end
            result = result .. styles.table2 .. styles.cost3 .. 'width=10% title="Physical"|[[File:PhysIcon_SMTV.png|24px|alt=Physical|Physical|link=Physical Skills]]<br>[[Physical Skills|<span style="color:white">Phys</span>]]' .. styles.cost3 .. 'width=9% title="Fire"|[[File:FireIcon_SMTV.png|24px|alt=Fire|Fire|link=Fire Skills]]<br>[[Fire Skills|<span style="color:white">Fire</span>]]' .. styles.cost3 .. 'width=9% title="Ice"|[[File:IceIcon_SMTV.png|24px|alt=Ice|Ice|link=Ice Skills]] <br>[[Ice Skills|<span style="color:white">Ice</span>]]' .. styles.cost3 .. 'width=9% title="Electricity"|[[File:ElecIcon_SMTV.png|24px|alt=Electricity|Electricity|link=Electric Skills]]<br>[[Electric Skills|<span style="color:white">Elec</span>]]' .. styles.cost3 .. 'width=9% title="Force"|[[File:ForceIcon_SMTV.png|24px|alt=Force|Force|link=Force Skills]]<br>[[Force Skills|<span style="color:white">Force</span>]]' .. styles.cost3 .. 'width=9% title="Light"|[[File:LightIcon_SMTV.png|24px|alt=Light|Light|link=Light Skills (Affinity)]]<br>[[Light Skills (Affinity)|<span style="color:white">Light</span>]]' .. styles.cost3 .. 'width=9% title="Dark"|[[File:DarkIcon_SMTV.png|24px|alt=Dark|Dark|link=Dark Skills (Affinity)]]<br>[[Dark Skills (Affinity)|<span style="color:white">Dark</span>]]' .. styles.cost3 .. 'width=9% title="Almighty"|[[File:AlmightyIcon_SMTV.png|24px|alt=Almighty|Almighty|link=Almighty Skills]]<br>[[Almighty Skills|<span style="color:white">Almi.</span>]]' .. styles.cost3 .. 'width=9% title="Ailment"|[[File:AilmentIcon_SMTV.png|24px|alt=Ailment|Ailment|link=Ailment Skills]]<br>[[Ailment Skills|<span style="color:white">Ailm.</span>]]' .. styles.cost3 .. 'width=9% title="Healing"|[[File:HealIcon_SMTV.png|24px|alt=Healing|Healing|link=Healing Skills]]<br>[[Healing Skills|<span style="color:white">Heal.</span>]]' .. styles.cost3 .. 'width=9% title="Support"|[[File:SupportIcon_SMTV.png|24px|alt=Support|Support|link=Support Skills]]<br>[[Support Skills|<span style="color:white">Supp.</span>]]\n|-\n' .. styles.cost3 .. "width=9%|" .. skilltypes["phys"] .. styles.cost3 .. "width=9%|" .. skilltypes["fire"] .. styles.cost3 .. "width=9%|" .. skilltypes["ice"] .. styles.cost3 .. "width=9%|" .. skilltypes["elec"] .. styles.cost3 .. "width=9%|" .. skilltypes["force"] .. styles.cost3 .. "width=9%|" .. skilltypes["light"] .. styles.cost3 .. "width=9%|" .. skilltypes["dark"] .. styles.cost3 .. "width=9%|" .. skilltypes["almighty"] .. styles.cost3 .. "width=9%|" .. skilltypes["ailment"] .. styles.cost3 .. "width=9%|" .. skilltypes["heal"] .. styles.cost3 .. "width=9%|" .. skilltypes["support"] .. "\n|}" .. "\n|}"
        end
    elseif render_game == "ldx2" then
        if not prop.hp then prop.hp = "?" end
        if not prop.rarity then prop.rarity = string.rep("★", math.ceil((tonumber(prop.level) + 1) / 20)) end

        styles.h = '\n!style="color:' .. gameData.colorbg .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style="color:' .. gameData.font .. '">Rarity</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.font .. '">Grade</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.hp .. '">HP</span>' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. '\n|+<span style="font-weight:bold">6★ Stats</span>' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 1, 255) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 1, 255) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 1, 255) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 1, 255) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 1, 255) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.rarity .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. rarityCategory(prop.rarity, gamen)
        if not prop.seealso then prop.seealso = mw.title.getCurrentTitle().text end
        result = result .. styles.table2 .. styles.h .. 'title="Physical Attack"|Phys ATK' .. styles.h .. 'title="Physical Defense"|Phys DEF' .. styles.h .. 'title="Magical Attack"|Mag ATK' .. styles.h .. 'title="Magical Defense"|Mag DEF' .. styles.h .. "|See Also" .. "\n|-" .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.matk .. styles.statlow .. prop.mdef .. styles.statlow .. "[https://dx2wiki.com/index.php/" .. string.gsub(prop.seealso, " ", "_") .. "]\n|}"
        if not prop.phys then prop.phys = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.dark then prop.dark = "-" end
        styles.h = '\n!style="background:' .. gameData.colorbg .. ';color:#fff" '
        local statlow = '\n|style="background:' .. gameData.colorbg .. ';color:#fff"|'
        result = result .. styles.table2 .. styles.h .. 'width=14.8% title="Physical"|[[File:SMT_Dx2_Physical_Skill_Icon.png|24px|alt=Physical|Physical|link=Physical Skills]] [[Physical Skills|<span style="color:white">Phys</span>]]' .. styles.h .. 'width=14.2% title="Fire"|[[File:SMT_Dx2_Fire_Skill_Icon.png|24px|alt=Fire|Fire|link=Fire Skills]] [[Fire Skills|<span style="color:white">Fire</span>]]' .. styles.h .. 'width=14.2% title="Ice"|[[File:SMT_Dx2_Ice_Skill_Icon.png|24px|Ice|link=Ice Skills]] [[Ice Skills|<span style="color:white">Ice</span>]]' .. styles.h .. 'width=14.2% title="Electricity"|[[File:SMT_Dx2_Electricity_Skill_Icon.png|24px|alt=Electricity|Electricity|link=Electric Skills]] [[Electric Skills|<span style="color:white">Elec</span>]]' .. styles.h .. 'width=14.2% title="Force"|[[File:SMT_Dx2_Force_Skill_Icon.png|24px|alt=Force|Force|link=Force Skills]] [[Force Skills|<span style="color:white">Force</span>]]' .. styles.h .. 'width=14.2% title="Light"|[[File:SMT_Dx2_Light_Skill_Icon.png|24px|alt=Light|Light|link=Light Skills (Affinity)]] [[Light Skills (Affinity)|<span style="color:white">Light</span>]]' .. styles.h .. 'width=14.2% title="Dark"|[[File:SMT_Dx2_Dark_Skill_Icon.png|24px|Dark|link=Dark Skills (Affinity)]] [[Dark Skills (Affinity)|<span style="color:white">Dark</span>]]\n|-\n' .. statlow .. prop.phys .. statlow .. prop.fire .. statlow .. prop.ice .. statlow .. prop.elec .. statlow .. prop.force .. statlow .. prop.expel .. statlow .. prop.dark .. "\n|}"
    elseif render_game == "lb1" or render_game == "lb2" or render_game == "lb3" or render_game == "lbs" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        if gameg == "lb1" and prop.atk == "" then prop.atk = "1" end
        result = result .. styles.table2 .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP"
        if gameg == "lb1" then
            result = result .. styles.h .. 'title="Number of Attacks"|NOA' .. styles.h .. 'title="Defense"|DEF'
        else
            result = result .. styles.h .. 'title="Attack Power"|ATK' .. styles.h .. 'title="Defense"|DEF'
        end
        result = result .. styles.h .. 'title="Strength"|STR' .. styles.h .. 'title="Intelligence"|INT' .. styles.h .. 'title="Endurance"|END' .. styles.h .. 'title="Speed"|SPD' .. styles.h .. 'title="Luck"|LUC\n|-' .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.str .. styles.statlow .. prop.int .. styles.statlow .. prop.vit .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}" .. bossdemoncat(prop.boss, gamen)
        if prop.resist or prop.extra then
            result = result .. styles.table2
            if prop.resist then result = result .. styles.h .. "|Resistances" .. styles.order .. prop.resist end
            if prop.extra then result = result .. styles.h .. "|Special" .. styles.order .. prop.extra end
            result = result .. "\n|}"
        end
        if prop.equip ~= "" or prop.card then
            if prop.equip == "Pteros" or prop.equip == "pteros" or prop.equip == "Bird" then
                prop.equip = "Claws"
            elseif prop.equip == "Kobold" or prop.equip == "kobold" or prop.equip == "Jaki" then
                prop.equip = "Claws, Hammers, Tornado, Axes, Shields"
            elseif prop.equip == "Dwarf" or prop.equip == "dwarf" or prop.equip == "Jirae" then
                prop.equip = "Claws, Swords, Armour, Shields"
            elseif prop.equip == "Pixie" or prop.equip == "pixie" or prop.equip == "Fairy" then
                prop.equip = "Claws, Hammers, Shurikens, Tornado, Axes, Swords, Armour, Shields"
            else
                if gameg == "lb2" then prop.equip = "None" end
            end
            result = result .. styles.table2
            if prop.equip ~= "" then result = result .. styles.h .. "width=70|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Equipment</span>]]" .. styles.order .. prop.equip end
            if prop.card then result = result .. styles.h .. "width=100|Card Location" .. styles.order .. prop.card end
            result = result .. "\n|}"
        end
    elseif render_game == "ab" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Rank" .. styles.h .. "|HP" .. styles.h .. "|PP" .. styles.h .. "|Move" .. styles.h .. "|Power" .. styles.h .. 'title="Defensive Power"|<abbr>Might</abbr>' .. styles.h .. "|Magic" .. styles.h .. "|Speed" .. styles.h .. "|Luck\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.move .. styles.statlow .. prop.power .. styles.statlow .. prop.might .. styles.statlow .. prop.magic .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}" .. bossdemoncat(prop.boss, gamen)
        if prop.weapon ~= "" then result = result .. styles.table2 .. styles.h .. "width=80px|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Weapon</span>]]" .. styles.effect1 .. prop.weapon .. "\n|}" end
        if prop.tech then
            prop.techc = data.skills[prop.tech]
            if not prop.techc then
                local alias = data.aliases[prop.tech]
                if alias then
                    prop.tech = alias
                    prop.techc = data.skills[prop.tech]
                else
                    prop.techc = {
                        cost = "",
                        range = "",
                        target = "",
                        effect = noskill(prop.tech, gamed),
                    }
                end
            end
            result = result .. styles.table2 .. styles.h .. "colspan=5|[[List of " .. gamegn .. " Skills#Techniques|" .. styles.spanc .. "Technique</span>]]" .. styles.skill .. "Technique" .. styles.skillc .. "Cost" .. styles.skillc .. "Range" .. styles.skillc .. "Target" .. styles.skillc .. "Description" .. styles.skill .. prop.tech .. styles.cost1 .. prop.techc.cost .. styles.cost1 .. prop.techc.range .. styles.cost1 .. prop.techc.target .. styles.effect1 .. prop.techc.effect .. "\n|}"
        end
    elseif render_game == "majin1" or render_game == "majin2" or render_game == "ronde" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        result = result .. bossdemoncat(prop.boss, gamen) .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Mv Range" .. styles.h .. "|Mv Type" .. styles.h
        if gameg == "majin1" then
            result = result .. "|Atk Type" .. styles.h .. 'title="Cost Point - MAG cost per 10 steps"|<abbr>CP</abbr>'
        elseif gameg == "majin2" then
            result = result .. "|Atk Range" .. styles.h .. "|[[Magnetite|" .. styles.spanc .. "MAG]]"
        elseif gameg == "ronde" then
            result = result .. "|Atk Range" .. styles.h .. "|Arcana"
        end
        result = result .. "\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.move .. styles.statlow .. prop.movetype .. styles.statlow .. prop.noa .. styles.statlow
        if gameg == "ronde" then
            result = result .. prop.arcana .. "\n|}"
        else
            result = result .. prop.cp .. prop.mag .. "\n|}"
        end
        if gameg == "majin1" then
            result = result .. styles.table2 .. styles.h .. "|Strength" .. styles.h .. "|Magic" .. styles.h .. "|Technique" .. styles.h .. "|Defense" .. styles.h .. "|Agility" .. styles.h .. "|Luck\n|-" .. styles.statlow .. prop.str .. styles.statlow .. prop.magic .. styles.statlow .. prop.dex .. styles.statlow .. prop.def .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
        else
            result = result .. styles.table2 .. styles.h .. 'title="Strength"|St' .. styles.h .. 'title="Magic|Ma' .. styles.h .. 'title="Intelligence"|In' .. styles.h .. 'title="Agility"|Ag' .. styles.h .. 'title="Luck|Lu' .. styles.h .. 'title="Attack Power"|Atk' .. styles.h .. 'title="Physical Defense"|P.Def' .. styles.h
            if gameg == "majin2" then
                result = result .. 'title="Magical Attack Power"|M.Atk' .. styles.h .. 'title="Magical Defense"|M.Def' .. styles.h .. 'title="Hit-rate"|Hit' .. styles.h .. 'title="Evasion"|Eva' .. styles.h .. 'title="Critical Rate"|Crt\n|-'
            else
                result = result .. 'title="Magical Defense"|M.Def\n|-'
            end
            result = result .. styles.statlow .. prop.str .. styles.statlow .. prop.magic .. styles.statlow .. prop.int .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow
            if gameg == "majin2" then
                result = result .. prop.matk .. styles.statlow .. prop.mdef .. styles.statlow .. prop.hit .. styles.statlow .. prop.avd .. styles.statlow .. prop.critical .. "\n|}"
            else
                result = result .. prop.mdef .. "\n|}"
            end
        end
        if gameg == "ronde" then
            if not prop.askills then prop.askills = "-" end
            result = result .. styles.table2 .. styles.h .. "width=100px|Equipment" .. styles.order .. prop.equip .. styles.h .. "width=100px|Item" .. styles.order .. prop.askills .. "\n|}"
        end
    elseif render_game == "smtds" or render_game == "sh" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Strength"|St' .. styles.h .. 'title="Intelligence"|In' .. styles.h .. 'title="Magic"|Ma' .. styles.h
        if gameg == "smtds" then result = result .. 'title="Vitality"|Vi' .. styles.h end
        if gameg == "sh" then result = result .. 'title="Endurance"|En' .. styles.h end
        result = result .. 'title="Agility"|Ag' .. styles.h .. 'title="Luck"|Lu'
        result = result .. "\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.str .. styles.statlow .. prop.int .. styles.statlow .. prop.magic .. styles.statlow
        result = result .. prop.vit .. styles.statlow
        result = result .. prop.agl .. styles.statlow .. prop.luc
        result = result .. "\n|}" .. styles.table2 .. styles.h
        if not (prop.boss or prop.enemy) then result = result .. 'title="Cost Point - Magnetite cost per 10 steps"|<abbr>CP</abbr>' .. styles.h end
        if gameg == "smtds" then
            result = result .. 'title="Number of Attacks"|<abbr>NOA</abbr>' .. styles.h
        elseif gameg == "sh" and not (prop.boss or prop.enemy) then
            result = result .. "|MAG Summon" .. styles.h
        end
        if not prop.traits or prop.traits == "" or prop.traits == "-" or prop.traits == "--" or prop.boss or prop.enemy then
        else
            result = result .. "|[[Personality|" .. styles.spanc .. "Personality<span>]]" .. styles.h
        end
        result = result .. 'title="Physical Attack Power"|P.ATK' .. styles.h .. 'title="Physical Attack Hit-rate"|P.HIT' .. styles.h .. 'title="Base Defenses"|B.DEF' .. styles.h .. 'title="Avoidance"|AVD' .. styles.h .. 'title="Magical Power"|M.ATK' .. styles.h
        if gameg == "smtds" then
            result = result .. 'title="Magical Defense"|M.DEF'
        elseif gameg == "sh" then
            result = result .. 'title="Magical Hit-rate"|M.HIT'
        end
        result = result .. "\n|-" .. styles.statlow
        if not (prop.boss or prop.enemy) then result = result .. prop.mag .. prop.cp .. styles.statlow end
        if gameg == "smtds" then
            result = result .. prop.noa .. styles.statlow
        elseif gameg == "sh" and not (prop.boss or prop.enemy) then
            result = result .. prop.summoncost .. styles.statlow
        end
        if not prop.traits or prop.traits == "" or prop.traits == "-" or prop.traits == "--" then
        else
            result = result .. prop.traits .. styles.statlow
        end
        result = result .. prop.atk .. styles.statlow .. prop.hit .. styles.statlow .. prop.def .. styles.statlow .. prop.avd .. styles.statlow .. prop.matk .. styles.statlow
        if gameg == "smtds" then
            result = result .. prop.mdef
        elseif gameg == "sh" then
            result = result .. prop.mef
        end
        result = result .. bossdemoncat(prop.boss, gamen) .. "\n|}"
    elseif render_game == "sh2" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        styles.h = '\n!style="color:' .. gameData.colorbg2 .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style="color:' .. gameData.font2 .. '">Level</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.hp .. '">HP</span>' .. styles.h .. 'width=45px|<span style="color:' .. gameData.mp .. '">MP</span>' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 100) .. styles.barh .. "|Intelligence" .. styles.bard2 .. bar(styles.barc, prop.int, 2.4, 100) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 100) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 100) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 100) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. aligncat(prop.alignment, gamen)
        if not prop.phys then prop.phys = "-" end
        if not prop.gun then prop.gun = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.ruin then prop.ruin = "-" end
        if not prop.alm then prop.alm = "-" end
        styles.h = '\n!style="background:#000;color:#fff" '
        local statlow = '\n|style="background:#000;color:#fff"|'
        result = result .. styles.table2 .. styles.h .. 'width=12.5% title="Physical"|[[File:SH2_Physical.png|24px|alt=Physical|Physical|link=Physical Skills]] [[Physical Skills|<span style="color:#fff">Phys</span>]]' .. styles.h .. 'width=12.5% title="Gunfire"|[[File:SH2_Gun.png|24px|alt=Gun|Gun|link=Gun Skills]] [[Gun Skills|<span style="color:#fff">Gun.</span>]]' .. styles.h .. 'width=12.5% title="Fire"|[[File:SH2_Fire.png|24px|alt=Fire|Fire|link=Fire Skills]] [[Fire Skills|<span style="color:#fff">Fire</span>]]' .. styles.h .. 'width=12.5% title="Ice"|[[File:SH2_Ice.png|24px|Ice|link=Ice Skills]] [[Ice Skills|<span style="color:#fff">Ice</span>]]' .. styles.h .. 'width=12.5% title="Electricity"|[[File:SH2_Elec.png|24px|alt=Electricity|Electricity|link=Electric Skills]] [[Electric Skills|<span style="color:#fff">Elec</span>]]' .. styles.h .. 'width=12.5% title="Force"|[[File:SH2_Force.png|24px|alt=Force|Force|link=Force Skills]] [[Force Skills|<span style="color:#fff">Force</span>]]' .. styles.h .. 'width=12.5% title="Ruin"|[[File:SH2_Ailment.png|24px|alt=Ruin|Ruin|link=Ailment Skills]] [[Ailment Skills|<span style="color:#fff">Ruin</span>]]' .. styles.h .. 'width=12.5% title="Almighty"|[[File:SH2_Almighty.png|24px|Almighty|link=Almighty Skills]] [[Almighty Skills|<span style="color:#fff">Almi.</span>]]\n|-\n' .. statlow .. prop.phys .. statlow .. prop.gun .. statlow .. prop.fire .. statlow .. prop.ice .. statlow .. prop.elec .. statlow .. prop.force .. statlow .. prop.ruin .. statlow .. prop.alm .. "\n|}"
        styles.h = '\n!style="background: ' .. gameData.colorbg .. ";color: " .. gameData.font .. '" '
        if prop.gift then result = result .. styles.table2 .. styles.h .. "width=70px|[[Gift|" .. styles.spanc .. "Gift</span>]]" .. styles.order .. prop.gift .. "\n|}" end
    elseif render_game == "raidou1" or render_game == "raidou2" then
        if prop.str == "" then prop.str = "-" end
        if prop.magic == "" then prop.magic = "-" end
        if prop.vit == "" then prop.vit = "-" end
        if prop.luc == "" then prop.luc = "-" end
        if not prop.condition then prop.condition = "-" end
        if not prop.convo then prop.convo = "-" end
        if not prop.investigate then prop.investigate = "-" end
        if not prop.drop then prop.drop = "-" end
        if not prop.recruit then
            prop.recruit = "?"
        elseif prop.boss then
            prop.recruit = "No"
        end
        if not prop.resist then prop.resist = "-" end
        if not prop.block then prop.block = "-" end
        if not prop.absorb then prop.absorb = "-" end
        if not prop.reflect then prop.reflect = "-" end
        if not prop.weak then
            prop.weak = "-"
        else
            if gameg == "raidou1" then
                prop.weak = '<span style="color:#f22">' .. prop.weak .. "</span>"
            else
                prop.weak = '<span style="color:#f72">' .. prop.weak .. "</span>"
            end
        end
        if not prop.frail then
            prop.frail = "-"
        else
            prop.frail = '<span style="color:#f22">' .. prop.frail .. "</span>"
        end
        result = result .. styles.table2 .. styles.h .. "|[[List of " .. gamegn .. " Demons|" .. styles.spanc .. "Order</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP"
        if gameg == "raidou1" then result = result .. styles.h .. "|MP" end
        result = result .. styles.h .. 'title="Strength"|St' .. styles.h .. 'title="Magic"|Ma' .. styles.h .. 'title="Vitality"|Vi' .. styles.h .. 'title="Luck"|Lu' .. styles.h
        if prop.boss then
            result = result .. "|Item drop"
        else
            if gameg == "raidou1" then
                result = result .. "|MAG Cost"
            else
                result = result .. 'title="Conversation skill of the demon"|<abbr>Conversation</abbr>'
            end
        end
        if prop.boss == nil then result = result .. styles.h .. 'title="Demon' .. "'s" .. ' Investigation Skill"|<abbr>Investigation</abbr>' end
        result = result .. "\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp
        if gameg == "raidou1" then result = result .. styles.statlow .. prop.mp end
        result = result .. styles.statlow .. prop.str .. styles.statlow .. prop.magic .. styles.statlow .. prop.vit .. styles.statlow .. prop.luc .. styles.statlow
        if prop.boss then
            result = result .. prop.drop
        else
            if gameg == "raidou1" then
                result = result .. prop.condition
            else
                result = result .. prop.convo
            end
        end
        if prop.boss == nil then result = result .. styles.statlow .. prop.investigate end
        result = result .. "\n|}" .. styles.table2
        if gameg == "raidou1" then result = result .. styles.h .. 'title="Whether the demon can be subdued as ally or not."|Confinable' end
        result = result .. styles.h .. "|Reflects" .. styles.h .. "|Absorbs" .. styles.h .. "|Block" .. styles.h .. "|Resists" .. styles.h
        if gameg == "raidou2" then
            result = result .. 'title="Unit takes extra damage without being staggered."|<abbr>Weak</abbr>' .. styles.h .. 'title="Unit will be staggered by the said element(s). Whether the element does extra damage or not varies."|<abbr>Frail</abbr>\n|-'
        else
            result = result .. "|Weak\n|-" .. styles.statlow .. prop.recruit
        end
        result = result .. styles.statlow .. prop.reflect .. styles.statlow .. prop.absorb .. styles.statlow .. prop.block .. styles.statlow .. prop.resist .. styles.statlow .. prop.weak
        if gameg == "raidou2" then result = result .. styles.statlow .. prop.frail end
        result = result .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    elseif render_game == "giten" then
        if not prop.condition then prop.condition = "" end
        if not prop.equiptype then prop.equiptype = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Alignment" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Cost Point. Magnetite per 10 steps"|<abbr>CP</abbr>' .. styles.h .. "|[[Equip Type|" .. styles.spanc .. "Equip Type</span>]]\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.condition .. styles.statlow .. prop.equiptype .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Intuition" .. styles.h .. "|Will Power" .. styles.h .. "|Magic" .. styles.h .. "|Intelligence" .. styles.h .. "|Divine Protection\n|-" .. styles.statlow .. prop.itin .. styles.statlow .. prop.wllpow .. styles.statlow .. prop.magic .. styles.statlow .. prop.int .. styles.statlow .. prop.dvnprt .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Strength" .. styles.h .. "|Stamina" .. styles.h .. "|Agility" .. styles.h .. "|Dexterity" .. styles.h .. "|Charm\n|-" .. styles.statlow .. prop.str .. styles.statlow .. prop.vit .. styles.statlow .. prop.agl .. styles.statlow .. prop.dex .. styles.statlow .. prop.chm .. "\n|}" .. aligncat(prop.alignment, gamen) .. bossdemoncat(prop.boss, gamegn)
    elseif render_game == "p1" then
        if prop.vit2 then
            prop.p1vi = '|<span style="color:#aff;cursor:help" title="Values of PSX and PSP versions differ.">Vitality</span>' .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99, prop.vit2, "PSX version", "PSP version")
        else
            prop.p1vi = "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99)
        end
        if prop.dex2 then
            prop.p1dx = '|<span style="color:#aff;cursor:help" title="Values of PSX and PSP versions differ.">Dexterity</span>' .. styles.bard2 .. bar(styles.barc, prop.dex, 2.4, 99, prop.dex2, "PSX version", "PSP version")
        else
            prop.p1dx = "|Dexterity" .. styles.bard2 .. bar(styles.barc, prop.dex, 2.4, 99)
        end
        if prop.boss or prop.enemy or prop.hp then
            if prop.order2 then
                prop.p1order = getRace(prop.race, gameg, "PSX version") .. " / " .. getRace(prop.order2, gameg, "PSP version")
            else
                prop.p1order = getRace(prop.race, gameg)
            end
            if not prop.etype then prop.etype = "" end
            if not prop.element then prop.element = "" end
            if not prop.hp then prop.hp = "" end
            if not prop.mp then prop.mp = "" end
            result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Order</span>]]" .. styles.h .. "|Type" .. styles.h .. "|Subtype" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|SP"
            if prop.normal then result = result .. styles.h .. "|[[List of " .. gamen .. " Items|" .. styles.spanc .. "Drops</span>]]" end
            result = result .. "\n|-" .. styles.statlow .. prop.p1order .. styles.statlow .. prop.etype .. styles.statlow .. prop.element .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp
            if prop.normal then result = result .. styles.statlow .. prop.normal end
            result = result .. "\n|}" .. bossdemoncat(prop.boss, gamen)
            if prop.matk == "" and prop.mdef == "" and prop.str == "" and prop.vit == "" and prop.dex == "" and prop.agl == "" and prop.luc == "" then
            else
                result = result .. styles.table2 .. styles.h .. 'title="Magical Power"|MAtk' .. styles.h .. 'title="Magical Defense"|MDef' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. prop.p1vi .. styles.barh .. prop.p1dx .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-" .. styles.statlow .. prop.matk .. styles.statlow .. prop.mdef .. "\n|}"
            end
            if prop.traits or prop.convo then
                result = result .. styles.table2
                if prop.traits then result = result .. styles.h .. "width=50px|[[Personality|" .. styles.spanc .. "Traits</span>]]" .. styles.order .. prop.traits end
                if prop.convo then result = result .. styles.h .. "width=50px|[[Special conversation|" .. styles.spanc .. '<abbr title="If equipped with the listed Persona, there is a chance it will talk to this demon if encountered.">Ptalk</abbr>]]' .. styles.order .. prop.convo end
                result = result .. "\n|}"
            end
        else
            if not prop.etype then prop.etype = "" end
            if not prop.element then prop.element = "" end
            if not prop.mp then prop.mp = "" end
            result = result .. styles.table2 .. styles.h .. "|[[Arcana|" .. styles.spanc .. "Arcana</span>]]" .. styles.h .. "|Type" .. styles.h .. "|Subtype" .. styles.h .. "|Level" .. styles.h .. "|SP cost"
            if prop.totem then result = result .. styles.h .. "|[[Totem|" .. styles.spanc .. "Totem</span>]]" end
            if prop.preturn then result = result .. styles.h .. "|[[Mystic Change|" .. styles.spanc .. "Returns</span>]] [[List of " .. gamen .. " Items|" .. styles.spanc .. "°</span>]]" end
            result = result .. "\n|-" .. styles.statlow .. getArcana(prop.arcana, gameg, gamen) .. styles.statlow .. prop.etype .. styles.statlow .. prop.element .. styles.statlow .. prop.level .. styles.statlow .. prop.mp
            if prop.totem then result = result .. styles.statlow .. prop.totem end
            if prop.preturn then result = result .. styles.statlow .. prop.preturn end
            result = result .. "\n|}" .. styles.table2 .. styles.h .. 'title="Magical Power"|MAtk' .. styles.h .. 'title="Magical Defense"|MDef' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99) .. styles.barh .. prop.p1dx .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-" .. styles.statlow .. prop.matk .. styles.statlow .. prop.mdef .. "\n|}"
            if args.Affinity or prop.convo then
                result = result .. styles.table2
                if args.Affinity then result = result .. styles.h .. 'width=60px title="Characters with ' .. "'Best'" .. ' Affinity"|[[Affinity (Persona)|' .. styles.spanc .. "<abbr>Affinity</abbr></span>]]" .. styles.order .. args.Affinity end
                if prop.convo then result = result .. styles.h .. "width=50px|[[Special conversation|" .. styles.spanc .. '<abbr title="If equipped with this Persona, there is a chance it will talk to listed demon if encountered.">Ptalk</abbr>]]' .. styles.order .. prop.convo end
                result = result .. "\n|}" .. cate(gamen .. " Personas")
            end
        end
    elseif render_game == "p2is" or render_game == "p2ep" then
        result = result .. styles.table2 .. styles.h .. "|[[Arcana|" .. styles.spanc .. "Arcana</span>]]"
        if prop.enemy or prop.boss or prop.hp then
            if prop.etype then result = result .. styles.h .. "|Type" end
            result = result .. styles.h .. "|Level"
            if prop.hp then result = result .. styles.h .. "|HP" end
            if prop.normal then result = result .. styles.h .. "|[[List of " .. gamen .. " Items|" .. styles.spanc .. "Normal Drop]]" end
            if prop.rare then result = result .. styles.h .. 'style="background:#8E283D"|Rare Drop' end
            result = result .. "\n|-" .. styles.statlow .. getArcana(prop.arcana, gameg, gamen)
            if prop.etype then result = result .. styles.statlow .. prop.etype end
            result = result .. styles.statlow .. prop.level
            if prop.hp then result = result .. styles.statlow .. prop.hp end
            if prop.normal then result = result .. styles.statlow .. prop.normal end
            if prop.rare then result = result .. styles.statlow .. prop.rare end
            result = result .. bossdemoncat(prop.boss, gamen)
        else
            if not prop.etype then prop.etype = "" end
            if not prop.mp then prop.mp = "" end
            if not prop.bonus then prop.bonus = "" end
            if not prop.preturn then prop.preturn = "" end
            result = result .. styles.h .. "|Type" .. styles.h .. "|Level" .. styles.h .. "|SP cost" .. styles.h .. 'title="Extra stats that are conferred upon every level up with the Persona equipped"|Bonus' .. styles.h .. "|[[Mystic Change|" .. styles.spanc .. "Returns</span>]] " .. "[[List of " .. gamen .. " Items|" .. styles.spanc .. "°</span>]]" .. "\n|-" .. styles.statlow .. getArcana(prop.arcana, gameg, gamen) .. styles.statlow .. prop.etype .. styles.statlow .. prop.level .. styles.statlow .. prop.mp .. styles.statlow .. prop.bonus .. styles.statlow .. prop.preturn .. cate(gamegn .. " Personas")
        end
        result = result .. "\n|}"
    elseif (render_game == "p3" or render_game == "p3re") or render_game == "p4" or (render_game == "p5" or render_game == "p5r" or render_game == "p5s" or render_game == "p5x") then
        local isP5Family = gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x"
        local has_arcana = not ((gameg == "p5" or gameg == "p5r" or gameg == "p5x") and not hasFilledValue(prop.arcana))
        local str = prop.str
        local magic = prop.magic
        local vit = prop.vit
        local agl = prop.agl
        local luc = prop.luc
        local has_stat_bars = str == "i" or tonumber(str) ~= nil
            or magic == "i" or tonumber(magic) ~= nil
            or vit == "i" or tonumber(vit) ~= nil
            or agl == "i" or tonumber(agl) ~= nil
            or luc == "i" or tonumber(luc) ~= nil
        local stat_table = styles.table2
        local stat_categories = ""
        if has_arcana then
            stat_table = stat_table .. styles.h .. "|[[Arcana|" .. styles.spanc .. "Arcana</span>]]"
        end
        stat_table = stat_table .. styles.h .. 'width="50px"|[[Level (stat)|' .. styles.spanc .. "Level</span>]]"
        if prop.hp then stat_table = stat_table .. styles.h .. 'width="40px"|HP' end
        if prop.mp then stat_table = stat_table .. styles.h .. 'width="40px"|SP' end
        if prop.maxhp then stat_table = stat_table .. styles.h .. 'width="40px"|HP' end
        if prop.maxmp then stat_table = stat_table .. styles.h .. 'width="40px"|SP' end
        if gameg == "p5s" and prop.stagger then stat_table = stat_table .. styles.h .. '|[[Stagger Gauge|<span style="color:#fff">Stagger Gauge</span>]]' end
        if prop.traits then stat_table = stat_table .. styles.h .. '|[[Personality|<span style="color:#fff">Type</span>]]' end
        if has_stat_bars then
            stat_table = stat_table .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, str, 2.4, 99) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, magic, 2.4, 99) .. styles.barh .. "|Endurance" .. styles.bard2 .. bar(styles.barc, vit, 2.4, 99) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, luc, 2.4, 99) .. "\n|}"
        end
        stat_table = stat_table .. "\n|-"
        if has_arcana then
            stat_table = stat_table .. styles.statlow .. getArcana(prop.arcana, gameg, gamegn)
        end
        local hp_border = (prop.hp or prop.maxhp) and '<div style="position:relative;top:-4px;border:2.5px solid ' .. gameData.hp2 .. '"></div>' or nil
        local mp_border = (prop.mp or prop.maxmp) and '<div style="position:relative;top:-4px;border:2.5px solid ' .. gameData.mp2 .. '"></div>' or nil
        stat_table = stat_table .. styles.statlow .. prop.level
        if prop.hp then stat_table = stat_table .. styles.statlow .. prop.hp .. hp_border end
        if prop.mp then stat_table = stat_table .. styles.statlow .. prop.mp .. mp_border end
        if prop.maxhp then stat_table = stat_table .. styles.statlow .. prop.maxhp .. hp_border end
        if prop.maxmp then stat_table = stat_table .. styles.statlow .. prop.maxmp .. mp_border end
        if gameg == "p5s" and prop.stagger then stat_table = stat_table .. styles.statlow .. prop.stagger end
        if prop.traits then stat_table = stat_table .. styles.statlow .. prop.traits end
        stat_table = stat_table .. "\n|}"
        if gameg == "p3" or gameg == "p3re" then
            if prop.hp then
                if prop.boss then
                    if game == "p3p" then
                        stat_categories = stat_categories .. cate("Persona 3 Portable Bosses")
                    elseif game == "p3f" then
                        stat_categories = stat_categories .. cate(gamegn .. " Bosses")
                    else
                        stat_categories = stat_categories .. cate(gamegn .. " Bosses") .. cate("Persona 3 Portable Bosses")
                    end
                else
                    stat_categories = stat_categories .. cate(gamegn .. " Shadows")
                end
            else
                if game == "p3p" or game == "p3f" then
                    stat_categories = stat_categories .. cate("Persona 3 FES Personas") .. cate("Persona 3 Portable Personas")
                else
                    stat_categories = stat_categories .. cate(gamegn .. " Personas") .. cate("Persona 3 FES Personas") .. cate("Persona 3 Portable Personas")
                end
            end
        end
        if gameg == "p4" then
            if prop.hp then
                if prop.boss then
                    if prop.vanilla then
                        stat_categories = stat_categories .. cate(gamen .. " Bosses")
                    elseif game == "p4g" then
                        stat_categories = stat_categories .. cate(gamen .. " Bosses")
                    else
                        stat_categories = stat_categories .. cate(gamegn .. " Bosses") .. cate("Persona 4 Golden Bosses")
                    end
                else
                    if prop.vanilla then
                        stat_categories = stat_categories .. cate(gamen .. " Shadows")
                    elseif game == "p4g" then
                        stat_categories = stat_categories .. cate(gamen .. " Shadows")
                    else
                        stat_categories = stat_categories .. cate(gamegn .. " Shadows") .. cate("Persona 4 Golden Shadows")
                    end
                end
            else
                if game == "p4g" then
                    stat_categories = stat_categories .. cate(gamen .. " Personas")
                else
                    stat_categories = stat_categories .. cate(gamegn .. " Personas") .. cate("Persona 4 Golden Personas")
                end
            end
        end
        if isP5Family then
            if prop.hp then
                if prop.boss then
                    stat_categories = stat_categories .. cate(gamen .. " Bosses")
                elseif prop.shadow then
                    stat_categories = stat_categories .. cate(gamen .. " Shadows")
                else
                    stat_categories = stat_categories .. cate(gamen .. " Enemies")
                end
            else
                stat_categories = stat_categories .. cate(gamen .. " Personas")
            end
        end
        if has_stat_bars then
            result = result .. stat_table .. stat_categories
        else
            ctx.pending_top_stats = stat_table
            ctx.pending_top_stats_categories = stat_categories
        end
    elseif render_game == "metaphor" then
        result = result .. styles.table2
        if not prop.hp then result = result .. styles.h .. "|[[Archetype|" .. styles.spanc .. "Lineage</span>]]" end
        result = result .. styles.h .. 'width="50px"|[[Level (stat)|' .. styles.spanc .. "Rank</span>]]"
        if prop.hp then result = result .. styles.h .. 'width="40px"|HP' end
        if prop.mp then result = result .. styles.h .. 'width="40px"|MP' end
        if prop.maxhp then result = result .. styles.h .. 'width="40px"|HP' end
        if prop.maxmp then result = result .. styles.h .. 'width="40px"|MP' end
        result = result .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 2.4, 99) .. styles.barh .. "|Endurance" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-"
        if not prop.hp then result = result .. styles.statlow .. "[[" .. prop.archetype .. " (Archetype)|" .. prop.archetype .. "]]" end
        local hp_border = (prop.hp or prop.maxhp) and '<div style="position:relative;top:-4px;border:2.5px solid ' .. gameData.hp2 .. '"></div>' or nil
        local mp_border = (prop.mp or prop.maxmp) and '<div style="position:relative;top:-4px;border:2.5px solid ' .. gameData.mp2 .. '"></div>' or nil
        result = result .. styles.statlow .. prop.level
        if prop.hp then result = result .. styles.statlow .. prop.hp .. hp_border end
        if prop.mp then result = result .. styles.statlow .. prop.mp .. mp_border end
        if prop.maxhp then result = result .. styles.statlow .. prop.maxhp .. hp_border end
        if prop.maxmp then result = result .. styles.statlow .. prop.maxmp .. mp_border end
        result = result .. "\n|}"
        if prop.hp then
            if prop.boss then
                result = result .. cate(gamen .. " Bosses")
            else
                result = result .. cate(gamen .. " Enemies")
            end
        else
            result = result .. cate(gamen .. " Archetypes")
        end
    elseif render_game == "pq" or render_game == "pq2" then
        if not prop.arcana then
            if not prop.drop1 then prop.drop1 = "-" end
            if not prop.drop2 then prop.drop2 = "-" end
            if not prop.drop3 then prop.drop3 = "-" end
            result = result .. styles.table2 .. styles.h .. "width=12%|Level" .. styles.h .. "width=12%|HP" .. styles.h .. "width=12%|Attack" .. styles.h .. "width=12%|Defense"
            result = result .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 2.4, 99) .. styles.barh .. "|Endurance" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-" .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. "\n|}"
            result = result .. styles.table2 .. styles.h .. "width=16%|Exp" .. styles.h .. "width=28%|Drop 1" .. styles.h .. "width=28%|Drop 2" .. styles.h
            if prop.dropc and prop.condition then
                result = result .. "width=28%|Conditional"
            else
                result = result .. "width=28%|Drop 3"
            end
            result = result .. "\n|-\n" .. styles.statlow .. prop.xp .. styles.statlow .. prop.drop1 .. styles.statlow .. prop.drop2 .. styles.statlow
            if prop.dropc and prop.condition then
                result = result .. '<abbr title="' .. prop.condition .. '">' .. prop.dropc .. "</abbr>"
            else
                result = result .. prop.drop3
            end
            if prop.boss then
                result = result .. cate(gamegn .. " Bosses")
            else
                result = result .. cate(gamegn .. " Shadows")
            end
        elseif prop.hp or prop.mp then -- sub-persona
            if not prop.inherit then prop.inherit = "-" end
            if not prop.card then prop.card = "-" end
            if not prop.fragment then prop.fragment = "-" end
            if gameg == "pq" then
                result = result .. styles.table2 .. styles.h .. "|[[Arcana|" .. styles.spanc .. "Arcana</span>]]" .. styles.h .. "width=10%|Level" .. styles.h .. 'title="HP bonus. Replenishes after battle." width=10%|HP +' .. styles.h .. 'title="SP bonus. Replenishes after battle." width=10%|SP +' .. styles.h .. "|Inherit" .. styles.h .. "|[[Skill Card|" .. styles.spanc .. "Extract</span>]]" .. styles.h .. "|[[Sacrificial fusion|" .. styles.spanc .. "Fragment]]\n|-\n"
                result = result .. styles.statlow .. getArcana(prop.arcana, gameg, gamen) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.inherit .. styles.statlow .. prop.card .. styles.statlow .. prop.fragment .. cate(gamegn .. " Personas")
            else
                result = result .. styles.table2 .. styles.h .. "|[[Arcana|" .. styles.spanc .. "Arcana</span>]]" .. styles.h .. "width=10%|Level" .. styles.h .. 'title="HP bonus. Replenishes after battle." width=10%|HP +' .. styles.h .. 'title="SP bonus. Replenishes after battle." width=10%|SP +' .. styles.h .. "|Type" .. styles.h .. "|[[Skill Card|" .. styles.spanc .. "Extract</span>]]\n|-\n"
                result = result .. styles.statlow .. getArcana(prop.arcana, gameg, gamen) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.inherit .. styles.statlow .. prop.card .. cate(gamegn .. " Personas")
            end
        else -- main persona
            result = result .. styles.table2 .. styles.h .. "|[[Arcana|" .. styles.spanc .. "Arcana</span>]]" .. styles.h .. "width=10%|Level"
            result = result .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 2.4, 99) .. styles.barh .. "|Endurance" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-" .. styles.statlow .. getArcana(prop.arcana, gameg, gamegn) .. styles.statlow .. prop.level
            if not prop.nocat then result = result .. cate(gamegn .. " Personas") end
        end
        result = result .. "\n|}"
    elseif render_game == "cs" then
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Strength"|St' .. styles.h .. 'title="Endurance"|En' .. styles.h .. 'title="Magic"|Ma' .. styles.h .. 'title="Agility"|Ag\n|-\n' .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.str .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.agl .. "\n|}" .. cate(gameData.name2 .. " Demons")
    elseif render_game == "ddsaga1" or render_game == "ddsaga2" then
        if gameg == "ddsaga2" and prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        if not prop.normal then prop.normal = "-" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Drops\n|-\n" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.normal .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    elseif render_game == "desu1" or render_game == "desu2" then
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "width=10%|Level" .. styles.h .. "width=10%|HP" .. styles.h .. "width=10%|MP" .. styles.bart11 .. "315px" .. styles.bart12 .. '1"' .. styles.barh .. "|Strength" .. styles.bard1 .. bar(styles.barc, prop.str, 6, 40) .. styles.barh .. "|Magic" .. styles.bard1 .. bar(styles.barc, prop.magic, 6, 40) .. styles.barh .. "|Vitality" .. styles.bard1 .. bar(styles.barc, prop.vit, 6, 40) .. styles.barh .. "|Agility" .. styles.bard1 .. bar(styles.barc, prop.agl, 6, 40) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. gameData.hp2 .. ';border-radius:3px"></div>' .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. gameData.mp2 .. ';border-radius:3px"></div>\n|}'
        if prop.boss then
            if gameg == "desu1" and game ~= "desu1oc" then
                result = result .. cate(gamegn .. " Bosses") .. cate("Devil Survivor Overclocked Bosses")
            elseif gameg == "desu2" and game ~= "desu2rb" then
                result = result .. cate(gamegn .. " Bosses") .. cate("Devil Survivor 2 Record Breaker Bosses")
            else
                result = result .. cate(gamen .. " Bosses")
            end
        else
            if prop.race == "Human" or prop.race == "???" or prop.race == "Foreigner" then
                if gameg == "desu1" and game ~= "desu1oc" then
                    result = result .. cate(gamegn .. " Characters") .. cate("Devil Survivor Overclocked Characters")
                elseif gameg == "desu2" and game ~= "desu2rb" then
                    result = result .. cate(gamegn .. " Characters") .. cate("Devil Survivor 2 Record Breaker Characters")
                else
                    result = result .. cate(gamegn .. " Characters")
                end
            elseif gameg == "desu1" and game ~= "desu1oc" then
                result = result .. cate(gamegn .. " Demons") .. cate("Devil Survivor Overclocked Demons")
            elseif gameg == "desu2" and game ~= "desu2rb" then
                result = result .. cate(gamegn .. " Demons") .. cate("Devil Survivor 2 Record Breaker Demons")
            else
                result = result .. cate(gamen .. " Demons")
            end
        end
    elseif render_game == "dcbrb" then
        if not prop.xp then prop.xp = "" end
        if not prop.etype then prop.etype = "" end
        result = result .. styles.table2 .. styles.h .. "|Class" .. styles.h .. "|Type" .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Exp\n|-" .. styles.statlow .. prop.class .. styles.statlow .. prop.etype .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.xp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "width=16.67% |Attack" .. styles.h .. "width=16.67% |Guard" .. styles.h .. "width=16.67% |Magic" .. styles.h .. "width=16.67% |M Guard" .. styles.h .. "width=16.67% |Speed" .. styles.h .. "width=16.67% |Luck\n|-\n" .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
        if prop.boss then
            result = result .. cate(gamen .. " Bosses")
        else
            if game == "dcbrp" then
                result = result .. cate("Devil Children PS demons")
            elseif game == "dcwb" then
                result = result .. cate(gamen .. " Demons")
            elseif gameg == "dcbrb" then
                result = result .. cate(gameData.name1 .. " Demons") .. cate(gameData.name2 .. " Demons")
            end
        end
        result = result .. cate(prop.race .. " Race")
    elseif render_game == "childred" or render_game == "childps" or render_game == "childwhite" or render_game == "childfire" then
        if not prop.xp then prop.xp = "" end
        if not prop.etype then prop.etype = "" end
        result = result .. styles.table2 .. styles.h .. "|Class" .. styles.h .. "|Type" .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Exp\n|-" .. styles.statlow .. prop.class .. styles.statlow .. prop.etype .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.xp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "width=16.67% |Attack" .. styles.h .. "width=16.67% |Guard" .. styles.h .. "width=16.67% |Magic" .. styles.h .. "width=16.67% |M Guard" .. styles.h .. "width=16.67% |Speed" .. styles.h .. "width=16.67% |Luck\n|-\n" .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
    elseif render_game == "childlight" then
        if not prop.xp then prop.xp = "" end
        result = result .. styles.table2 .. styles.h .. "|Class" .. styles.h .. "|Element" .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Type]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Exp\n|-" .. styles.statlow .. prop.class .. styles.statlow .. prop.etype .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.xp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. 'width=16.67% title="Attack Power"|ATK' .. styles.h .. 'width=16.67% title="Defense"|DEF' .. styles.h .. 'width=16.67% title="Magic"|MGC' .. styles.h .. 'width=16.67% title="Resistance"|RES' .. styles.h .. 'width=16.67% title="Speed"|SPD' .. styles.h .. 'width=16.67% title="Luck"|LCK\n|-\n' .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
        if prop.boss then
            if gameg == "childlight" then
                result = result .. cate(gameData.name3 .. " Bosses")
            else
                result = result .. cate(gamen .. " Bosses")
            end
        else
            if game == "childblack" or gameg == "childps" then
                result = result .. cate("Devil Children PS demons")
            elseif gameg == "childwhite" then
                result = result .. cate(gamen .. " Demons")
            elseif gameg == "childred" then
                result = result .. cate(gameData.name1 .. " Demons") .. cate(gameData.name2 .. " Demons")
            elseif gameg == "childfire" then
                result = result .. cate(gameData.name1 .. " Demons") .. cate(gameData.name2 .. " Demons")
            elseif gameg == "childlight" then
                result = result .. cate(gameData.name1 .. " Demons") .. cate(gameData.name2 .. " Demons")
            end
        end
        result = result .. cate(prop.race .. " Type")
    elseif render_game == "childmessiah" then
        if not prop.number then prop.number = "-" end
        if not prop.element then prop.element = "-" end
        if not prop.weak then prop.weak = "-" end
        if not prop.race then prop.race = "-" end
        if not prop.level then prop.level = "-" end
        if not prop.hp then prop.hp = "-" end
        if not prop.mp then prop.mp = "-" end
        if not prop.call then prop.call = "-" end
        if not prop.spell then
            prop.spell = "-"
        elseif data.skills[prop.spell] then
            prop.spell = '<abbr title="' .. data.skills[prop.spell].effect .. '">' .. prop.spell .. "</abbr>"
        end
        result = result .. styles.table2 .. styles.h .. "|Number" .. styles.h .. "|Element" .. styles.h .. "|Weakness" .. styles.h .. "|Type" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP\n|-" .. styles.statlow .. prop.number .. styles.statlow .. prop.element .. styles.statlow .. prop.weak .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. 'title="Attack"|ATK' .. styles.h .. 'title="Magic"|MGC' .. styles.h .. 'title="Defense"|DEF' .. styles.h .. 'title="Resistance"|RES' .. styles.h .. 'title="Speed"|SPD' .. styles.h .. "|Quick" .. styles.h .. "|Call" .. styles.h .. "|Spell\n|-" .. styles.statlow .. prop.atk .. styles.statlow .. prop.magic .. styles.statlow .. prop.def .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.quick .. styles.statlow .. prop.call .. styles.statlow .. prop.spell .. "\n|}" .. cate(prop.race .. " Type") .. bossdemoncat(prop.boss, baseGameData.name2)
    end
    return result
end

return p
