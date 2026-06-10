local p = {}

-- Render a small inline fraction for numeric resistance multipliers.
-- Used by resistance-type tables for KMT/SMT/Persona/Giten style affinity values.
local function frac(numerator, denominator)
    return '<span style="font-size:9px;position:relative;top:2px"><span style="position:relative;top:-5px;right:-3px">' .. numerator .. '</span><span style="position:relative;top:-2px">／</span>' .. denominator .. "</span>"
end

-- Format one resistance-type value as a table cell.
-- Covers drain/reflect/null/resist/weak multipliers for legacy resistance tables.
local function formatResistance(styles, v, denominator, game)
    if not denominator then denominator = 8 end
    if v == "dr" or v == "ab" then
        v = 'color:lime" title="Drain"|Dr'
    elseif v == ".5dr" or v == ".5ab" or v == "50dr" or v == "50ab" or v == "dr50" or v == "ab50" then
        v = 'color:lime" title="50% Drain"|<span style="color:white">½</span>Dr'
    elseif v == "2dr" or v == "2ab" then
        v = 'color:lime" title="Double Drain"|<span style="color:white">2×</span>Dr'
    elseif v == "rp" or v == "rf" then
        v = 'color:cyan" title="Reflect"|Rf'
    elseif v == ".5rp" or v == ".5rf" or v == "50rp" or v == "50rf" or v == "rp50" or v == "rf50" then
        v = 'color:cyan" title="50% Reflect"|<span style="color:white">½</span>Rf'
    elseif v == "1.5rp" or v == "1.5rf" or v == "150rp" or v == "150rf" or v == "rp150" or v == "rf150" then
        v = 'color:cyan" title="150% Reflect"|<span style="color:white">1.5×</span>Rf'
    elseif v == "2rp" or v == "2rf" then
        v = 'color:cyan" title="Double Reflect"|<span style="color:white">2×</span>Rf'
    else
        local resistance_number = tonumber(v)
        if resistance_number == 0 then
            v = 'color:white" title="Null"|Nu'
        elseif resistance_number == 1 then
            v = '" title="Normal"| -'
        elseif resistance_number < 1 then
            v = 'color:teal"  title="Resist"|' .. frac((resistance_number * denominator), denominator)
        elseif resistance_number > 2 then
            v = 'color:red" title="Weak"|' .. v .. "×"
        elseif resistance_number > 1.3 then
            if game == "smt1" or game == "smt2" or game == "smtif" then
                v = 'color:orange" title="Vulnerable"|' .. v .. "×"
            else
                v = 'color:red" title="Weak"|' .. v .. "×"
            end
        elseif resistance_number > 1.1 then
            v = 'color:orange" title="Vulnerable"|' .. v .. "×"
        end
    end
    return styles.statlow3 .. v
end

-- Format Giten-style resistance values as percentages.
-- Used only by resistance-type tables that store numeric percent multipliers.
local function formatResistancePercent(styles, v)
    if type(v) == "number" then
        local result = string.format("%3d%%", v * 100)

        if v == 0 then
            v = 'font-weight:bold"|Null'
        elseif v <= 1 then
            v = 'color:#669c92"|' .. result
        elseif v > 1 then
            v = 'color:#e32636"|' .. result
        end
    elseif v == "dr" then
        v = 'color:pink;font-weight:bold"|Drain'
    elseif v == "rf" then
        v = 'color:cyan;font-weight:bold"|Repel'
    else
        v = 'color:#e32636"|100%'
    end

    return styles.statlow3 .. v
end

-- Return the first two backslash-separated fields used by SMT9 resistance-level rows.
-- Missing modifiers intentionally become empty strings to match the legacy `v1 .. "\\"` split behavior.
local function splitReslevelPair(text)
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

-- Render top affinity tables that may merge beside pending Persona/P5X stat rows.
-- Covers Strange Journey, Devil Survivor, Ronde, Persona 3-5, P5X, and Metaphor top affinity layouts.
function p.renderTop(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg
    local appendTopAffinityTable = ctx.appendTopAffinityTable
    if gameg == "smtsj" then
        prop.noa = prop.noa or "-"
        prop.phys = prop.phys or "-"
        prop.gun = prop.gun or "-"
        prop.fire = prop.fire or "-"
        prop.ice = prop.ice or "-"
        prop.elec = prop.elec or "-"
        prop.wind = prop.wind or "-"
        prop.expel = prop.expel or "-"
        prop.curse = prop.curse or "-"
        prop.alm = prop.alm or "-"
        prop.poison = prop.poison or "-"
        prop.paralyze = prop.paralyze or "-"
        prop.stone = prop.stone or "-"
        prop.strain = prop.strain or "-"
        prop.sleep = prop.sleep or "-"
        prop.charm = prop.charm or "-"
        prop.mute = prop.mute or "-"
        prop.fear = prop.fear or "-"
        prop.bomb = prop.bomb or "-"
        prop.rage = prop.rage or "-"
        result = result .. styles.table2 .. styles.h .. "|Attack Type" .. styles.h .. 'width=7% title="Physical"|[[File:PhysIcon.png|alt=Physical|Physical|link=Physical Skills]]' .. styles.h .. 'width=7% title="Gun"|[[File:GunIcon.png|alt=Gun|Gun|link=Gun Skills]]' .. styles.h .. 'width=7% title="Fire"|[[File:FireIcon.png|alt=Fire|Fire|link=Fire Skills]]' .. styles.h .. 'width=7% title="Ice"|[[File:IceIcon.png|alt=Ice|Ice|link=Ice Skills]]' .. styles.h .. 'width=7% title="Electricity"|[[File:ElecIcon.png|alt=Electricity|Electricity|link=Electric Skills]]' .. styles.h .. 'width=7% title="Wind"|[[File:WindIcon.png|alt=Wind|Wind|link=Wind Skills]]' .. styles.h .. 'width=7% title="Expel"|[[File:ExpelIcon.png|alt=Expel|Expel|link=Expel Skills]]' .. styles.h .. 'width=7% title="Curse"|[[File:CurseIcon.png|alt=Curse|Curse|link=Death Skills]]' .. styles.h .. 'width=7% title="Almighty"|[[File:AlmightyIcon.png|alt=Almighty|Almighty|link=Almighty Skills]]\n|-\n'
        result = result .. styles.statlow .. prop.noa .. styles.statlow .. prop.phys .. styles.statlow .. prop.gun .. styles.statlow .. prop.fire .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec .. styles.statlow .. prop.wind .. styles.statlow .. prop.expel .. styles.statlow .. prop.curse .. styles.statlow .. prop.alm .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "width=10%|Poison" .. styles.h .. "width=10%|Paralyze" .. styles.h .. "width=10%|Stone" .. styles.h .. "width=10%|Strain" .. styles.h .. "width=10%|Sleep" .. styles.h .. "width=10%|Charm" .. styles.h .. "width=10%|Mute" .. styles.h .. "width=10%|Fear" .. styles.h .. "width=10%|Bomb" .. styles.h .. "width=10%|Rage\n|-\n"
        result = result .. styles.statlow .. prop.poison .. styles.statlow .. prop.paralyze .. styles.statlow .. prop.stone .. styles.statlow .. prop.strain .. styles.statlow .. prop.sleep .. styles.statlow .. prop.charm .. styles.statlow .. prop.mute .. styles.statlow .. prop.fear .. styles.statlow .. prop.bomb .. styles.statlow .. prop.rage .. "\n|}"
    end
    if gameg == "desu1" or gameg == "desu2" then
        prop.racial = prop.racial or "-"
        prop.phys = prop.phys or "-"
        prop.fire = prop.fire or "-"
        prop.ice = prop.ice or "-"
        prop.elec = prop.elec or "-"
        prop.force = prop.force or "-"
        prop.mystic = prop.mystic or "-"
        result = result .. styles.table2 .. styles.h .. "|[[Racial Skill|" .. styles.spanc .. "Racial</span>]] / [[Auto Skill|" .. styles.spanc .. "Auto]] Skill" .. styles.h .. 'width=12% title="Physical"|[[File:PhysIcon.png|alt=Physical|Physical|link=Physical Skills]] Phys' .. styles.h .. 'width=12% title="Fire"|[[File:FireIcon.png|alt=Fire|Fire|link=Fire Skills]] Fire' .. styles.h .. 'width=12% title="Ice"|[[File:IceIcon.png|alt=Ice|Ice|link=Ice Skills]] Ice' .. styles.h .. 'width=12% title="Electricity"|[[File:ElecIcon.png|alt=Electricity|Electricity|link=Electric Skills]] Elec' .. styles.h .. 'width=12% title="Force"|[[File:ForceIcon.png|alt=Force|Force|link=Force Skills]] Force' .. styles.h .. "width=12% title="
        if gameg == "desu1" then
            result = result .. '"Mystic"|[[File:Curse DESU2.png|alt=Mystic|Mystic|link=Curse Skills]] Mystic'
        elseif gameg == "desu2" then
            result = result .. '"Curse"|[[File:Curse DESU2.png|alt=Curse|Curse|link=Curse Skills]] Curse'
        end
        result = result .. "\n|-\n" .. styles.statlow .. prop.racial .. styles.statlow .. prop.phys .. styles.statlow .. prop.fire .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec .. styles.statlow .. prop.force .. styles.statlow .. prop.mystic .. "\n|}"
    end
    if gameg == "ronde" or (gameg == "p3" or gameg == "p3re") or gameg == "p4" or (gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x") or gameg == "metaphor" then
        if prop.sword or prop.strike or prop.pierce or prop.phys or prop.fire or prop.ice or prop.elec or prop.wind or prop.expel or prop.dark or prop.alm or prop.down or prop.dizzy or prop.freeze or prop.paralyze or prop.poison or prop.charm or prop.distress or prop.panic or prop.fear or prop.rage or prop.xp or prop.yen then
            local affinity_table = styles.table2
            prop.sword = prop.sword or "-"
            prop.strike = prop.strike or "-"
            prop.pierce = prop.pierce or "-"
            prop.phys = prop.phys or "-"
            prop.gun = prop.gun or "-"
            prop.fire = prop.fire or "-"
            prop.ice = prop.ice or "-"
            prop.elec = prop.elec or "-"
            prop.wind = prop.wind or "-"
            prop.psy = prop.psy or "-"
            prop.nuclear = prop.nuclear or "-"
            prop.expel = prop.expel or "-"
            prop.dark = prop.dark or "-"
            prop.alm = prop.alm or "-"
            prop.down = prop.down or "-"
            prop.dizzy = prop.dizzy or "-"
            prop.freeze = prop.freeze or "?"
            prop.paralyze = prop.paralyze or "?"
            prop.poison = prop.poison or "?"
            prop.charm = prop.charm or "?"
            prop.distress = prop.distress or "?"
            prop.panic = prop.panic or "?"
            prop.fear = prop.fear or "?"
            prop.rage = prop.rage or "?"
            if gameg == "ronde" then
                affinity_table = affinity_table .. styles.h .. "width=11%|[[Slash Skills|" .. styles.spanc .. "Slash</span>]]" .. styles.h .. "width=11%|[[Strike Skills|" .. styles.spanc .. "Strike</span>]]" .. styles.h .. "width=11%|[[Ranged Skills|" .. styles.spanc .. "Ranged</span>]]" .. styles.h .. "width=11%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=11%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=11%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=11%|[[Light Skills|" .. styles.spanc .. "Light</span>]]" .. styles.h .. "width=11%|[[Dark Skills|" .. styles.spanc .. "Dark</span>]]" .. styles.h .. 'title="Almighty" width=12%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            elseif gameg == "p3" or gameg == "p3re" then
                affinity_table = affinity_table .. styles.h .. "width=10%|[[Slash Skills|" .. styles.spanc .. "Slash</span>]]" .. styles.h .. "width=10%|[[Strike Skills|" .. styles.spanc .. "Strike</span>]]" .. styles.h .. "width=10%|[[Pierce Skills|" .. styles.spanc .. "Pierce</span>]]" .. styles.h .. "width=10%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=10%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=10%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=10%|[[Wind Skills|" .. styles.spanc .. "Wind</span>]]" .. styles.h .. "width=10%|[[Light Skills (Affinity)|" .. styles.spanc .. "Light</span>]]" .. styles.h .. "width=10%|[[Dark Skills (Affinity)|" .. styles.spanc .. "Dark</span>]]" .. styles.h .. 'title="Almighty" width=10%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            elseif gameg == "p4" then
                affinity_table = affinity_table .. styles.h .. 'title="Physical" width=14%|[[Physical Skills|' .. styles.spanc .. "Phys</span>]]" .. styles.h .. "width=12%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=12%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=12%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=12%|[[Wind Skills|" .. styles.spanc .. "Wind</span>]]" .. styles.h .. "width=12%|[[Light Skills (Affinity)|" .. styles.spanc .. "Light</span>]]" .. styles.h .. "width=12%|[[Dark Skills (Affinity)|" .. styles.spanc .. "Dark</span>]]" .. styles.h .. 'title="Almighty" width=14%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            elseif gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
                affinity_table = affinity_table .. styles.h .. 'title="Physical" width=9%|[[Physical Skills|' .. styles.spanc .. "Phys</span>]]" .. styles.h .. "width=9%|[[Gun Skills|" .. styles.spanc .. "Gun</span>]]" .. styles.h .. "width=9%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=9%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=9%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=9%|[[Wind Skills|" .. styles.spanc .. "Wind</span>]]" .. styles.h .. 'title="Psychokinesis" width=9%|[[Psychokinesis Skills|' .. styles.spanc .. "Psy</span>]]" .. styles.h .. 'title="Nuclear" width=9%|[[Nuclear Skills|' .. styles.spanc .. "Nuke</span>]]" .. styles.h .. "width=9%|[[Light Skills (Affinity)|" .. styles.spanc .. "Bless</span>]]" .. styles.h .. "width=9%|[[Dark Skills (Affinity)|" .. styles.spanc .. "Curse</span>]]" .. styles.h .. 'title="Almighty" width=10%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            elseif gameg == "metaphor" then
                affinity_table = affinity_table .. styles.h .. "width=10%|[[Slash Skills|" .. styles.spanc .. "Slash</span>]]" .. styles.h .. "width=10%|[[Pierce Skills|" .. styles.spanc .. "Pierce</span>]]" .. styles.h .. "width=10%|[[Strike Skills|" .. styles.spanc .. "Strike</span>]]" .. styles.h .. "width=10%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=10%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=10%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=10%|[[Wind Skills|" .. styles.spanc .. "Wind</span>]]" .. styles.h .. "width=10%|[[Light Skills (Affinity)|" .. styles.spanc .. "Light</span>]]" .. styles.h .. "width=10%|[[Dark Skills (Affinity)|" .. styles.spanc .. "Dark</span>]]" .. styles.h .. 'title="Almighty" width=10%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            end
            if gameg == "ronde" or (gameg == "p3" or gameg == "p3re") then
                affinity_table = affinity_table .. styles.statlow .. prop.sword .. styles.statlow .. prop.strike .. styles.statlow .. prop.pierce
            elseif gameg == "metaphor" then
                affinity_table = affinity_table .. styles.statlow .. prop.sword .. styles.statlow .. prop.pierce .. styles.statlow .. prop.strike
            elseif gameg == "p4" then
                affinity_table = affinity_table .. styles.statlow .. prop.phys
            elseif gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
                affinity_table = affinity_table .. styles.statlow .. prop.phys .. styles.statlow .. prop.gun
            end
            affinity_table = affinity_table .. styles.statlow .. prop.fire .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec
            if (gameg == "p3" or gameg == "p3re") or gameg == "p4" or (gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x") or gameg == "metaphor" then affinity_table = affinity_table .. styles.statlow .. prop.wind end
            if gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then affinity_table = affinity_table .. styles.statlow .. prop.psy .. styles.statlow .. prop.nuclear end
            affinity_table = affinity_table .. styles.statlow .. prop.expel .. styles.statlow .. prop.dark .. styles.statlow .. prop.alm

            if gameg == "p3re" then affinity_table = affinity_table .. "\n|-\n" .. styles.h .. "width=10%|Down" .. styles.h .. "width=10%|Dizzy" .. styles.h .. "width=10%|[[Ice Skills|" .. styles.spanc .. "Freeze</span>]]" .. styles.h .. "width=10%|[[Electricity Skills|" .. styles.spanc .. "Shock</span>]]" .. styles.h .. "width=10%|Poison" .. styles.h .. "width=10%|Charm" .. styles.h .. "width=10%|Distress" .. styles.h .. "width=10%|Confuse" .. styles.h .. "width=10%|Fear" .. styles.h .. "width=10%|Rage" .. "\n|-\n" .. styles.statlow .. prop.down .. styles.statlow .. prop.dizzy .. styles.statlow .. prop.freeze .. styles.statlow .. prop.paralyze .. styles.statlow .. prop.poison .. styles.statlow .. prop.charm .. styles.statlow .. prop.distress .. styles.statlow .. prop.panic .. styles.statlow .. prop.fear .. styles.statlow .. prop.rage end

            affinity_table = affinity_table .. "\n|}"
            result = appendTopAffinityTable(result, affinity_table)
        elseif prop.inherit or prop.resist or prop.block or prop.absorb or prop.reflect or prop.weak then
            local affinity_table = styles.table2
            prop.inherit = prop.inherit or "-"
            prop.resist = prop.resist or "-"
            prop.block = prop.block or "-"
            prop.absorb = prop.absorb or "-"
            prop.reflect = prop.reflect or "-"
            if not prop.weak then
                prop.weak = "-"
            else
                prop.weak = '<span style="color:#f22">' .. prop.weak .. "</span>"
            end
            if gameg ~= "metaphor" then affinity_table = affinity_table .. styles.h .. "|[[Skill Inheritance|" .. styles.spanc .. "Inherit</span>]]" end
            affinity_table = affinity_table .. styles.h .. "|Reflects" .. styles.h .. "|Absorbs" .. styles.h .. "|Block" .. styles.h .. "|Resists" .. styles.h .. "|Weak\n|-\n" .. styles.statlow .. prop.inherit .. styles.statlow .. prop.reflect .. styles.statlow .. prop.absorb .. styles.statlow .. prop.block .. styles.statlow .. prop.resist .. styles.statlow .. prop.weak .. "\n|}"
            result = appendTopAffinityTable(result, affinity_table)
        end
    end
    return result
end

-- Render the legacy SMT if... resistance row that appears after the image-span table closes.
-- Kept separate because KMT/SMT drop rows render immediately before it.
function p.renderSmtIfLegacy(ctx, result)
    local styles = ctx.styles
    local prop = ctx.prop
    local gameg = ctx.gameg
    if gameg == "smtif" and prop.resist then result = result .. styles.table2 .. styles.h .. "width=90px|Resistances" .. styles.order .. prop.resist .. "\n|}" end
    return result
end

-- Prepare Persona 2 element/header labels shared by weapon affinity and restype tables.
-- Covers P2IS/P2EP only; mutates the legacy temporary prop fields used by the adjacent render branches.
local function setPersona2AffinityLabels(prop, gameg)
    if prop.etype == "Fire" then
        prop.Fi = '<span style="color:#8B668B">Fi</span>'
    else
        prop.Fi = "Fi"
    end
    if prop.etype == "Water" then
        prop.Wt = '<span style="color:#8B668B">Wt</span>'
    else
        prop.Wt = "Wt"
    end
    if prop.etype == "Wind" then
        prop.Wi = '<span style="color:#8B668B">Wi</span>'
    else
        prop.Wi = "Wi"
    end
    if prop.etype == "Earth" then
        prop.Er = '<span style="color:#8B668B">Er</span>'
    else
        prop.Er = "Er"
    end
    if gameg == "p2ep" then
        prop.name_Rn = 'title="Shot"|Sh'
        prop.name_Hv = 'title="Attack"|Ak'
        prop.name_El = 'title="Lightning"|Ln'
        prop.name_Li = 'title="Holy"|Ho'
    else
        prop.name_Rn = 'title="Ranged"|Rn'
        prop.name_Hv = 'title="Havoc"|Hv'
        prop.name_El = 'title="Electricity"|El'
        prop.name_Li = 'title="Light"|Li'
    end
end

-- Render lower affinity/resistance sections after legacy drop and feature rows.
-- Covers Persona 1/2 weapon affinities, SMT/DDS/PQ resistance blocks, restype tables, and SMT9 resistance levels.
function p.renderPost(ctx, result)
    local gameData = ctx.gameData
    local styles = ctx.styles
    local prop = ctx.prop
    local game = ctx.game
    local gameg = ctx.gameg
    local bar = ctx.bar
    if gameg == "p1" and (prop.onehand or prop.twohand or prop.spear or prop.axe or prop.whip or prop.thrown or prop.arrow or prop.fist or prop.handgun or prop.machinegun or prop.shotgun or prop.rifle or prop.tech or prop.rush or prop.fire or prop.ice or prop.wind or prop.earth or prop.elec or prop.nuclear or prop.blast or prop.gravity or prop.expel or prop.miracle or prop.death or prop.curse or prop.nerve or prop.hiero) then
        prop.onehand = prop.onehand or "-"
        prop.twohand = prop.twohand or "-"
        prop.spear = prop.spear or "-"
        prop.axe = prop.axe or "-"
        prop.whip = prop.whip or "-"
        prop.thrown = prop.thrown or "-"
        prop.arrow = prop.arrow or "-"
        prop.fist = prop.fist or "-"
        prop.handgun = prop.handgun or "-"
        prop.machinegun = prop.machinegun or "-"
        prop.shotgun = prop.shotgun or "-"
        prop.rifle = prop.rifle or "-"
        prop.tech = prop.tech or "-"
        prop.rush = prop.rush or "-"
        prop.fire = prop.fire or "-"
        prop.ice = prop.ice or "-"
        prop.wind = prop.wind or "-"
        prop.earth = prop.earth or "-"
        prop.elec = prop.elec or "-"
        prop.nuclear = prop.nuclear or "-"
        prop.blast = prop.blast or "-"
        prop.gravity = prop.gravity or "-"
        prop.expel = prop.expel or "-"
        prop.miracle = prop.miracle or "-"
        prop.death = prop.death or "-"
        prop.curse = prop.curse or "-"
        prop.nerve = prop.nerve or "-"
        prop.hiero = prop.hiero or "-"
        result = result .. styles.table2 .. '\n!style="background:#a9a9a9" title="Weapons" colspan="8"|\n!title="Firearms" style="background:#898989" colspan="4"|\n!style="background:#a9a9a9" title="Havoc" colspan="2"|\n|-' .. styles.h .. 'title="Weapons"|<abbr title="1-handed Sword">1h</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="2-handed Sword">2h</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Spear">Sp</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Axe">Ax</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Whip">Wp</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Thrown">Th</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Arrows">Ar</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Fist">Fs</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Handgun">HG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Machinegun">MG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Shotgun">SG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Rifle">Ri</abbr>' .. styles.h .. 'title="Havoc"|<abbr title="Tech">Te</abbr>' .. styles.h .. 'title="Havoc"|<abbr title="Rush">Ru</abbr>\n|-\n' .. styles.statlow .. prop.onehand .. styles.statlow .. prop.twohand .. styles.statlow .. prop.spear .. styles.statlow .. prop.axe .. styles.statlow .. prop.whip .. styles.statlow .. prop.thrown .. styles.statlow .. prop.arrow .. styles.statlow .. prop.fist .. styles.statlow .. prop.handgun .. styles.statlow .. prop.machinegun .. styles.statlow .. prop.shotgun .. styles.statlow .. prop.rifle .. styles.statlow .. prop.tech .. styles.statlow .. prop.rush
        result = result .. '\n|-\n!style="background:#a9a9a9" title="Element" colspan="4"|\n!style="background:#898989" title="Force" colspan="4"|\n!style="background:#a9a9a9" title="Light" colspan="2"|\n!style="background:#898989" title="Dark" colspan="3"|\n!style="background:#a9a9a9" title="Special" colspan="1"|\n|-' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Fire">Fi</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Ice">Ic</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Wind">Wi</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Earth">Er</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Electricity">El</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Nuclear">Nc</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Blast">Bl</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Gravity">Gr</abbr>' .. styles.h .. 'title="Light"|<abbr title="Expel">Ex</abbr>' .. styles.h .. 'title="Light"|<abbr title="Miracle">Mi</abbr>' .. styles.h .. 'style="background:#898989" title="Dark"|<abbr title="Death">De</abbr>' .. styles.h .. 'style="background:#898989" title="Dark"|<abbr title="Curse">Cu</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Dark (Ailments)"|<abbr title="Nerve">Nr</abbr>' .. styles.h .. 'width="7.12%" title="Special"|<abbr title="Resistance to Hieroglyphein">???</abbr>\n|-\n' .. styles.statlow .. prop.fire .. styles.statlow .. prop.ice .. styles.statlow .. prop.wind .. styles.statlow .. prop.earth .. styles.statlow .. prop.elec .. styles.statlow .. prop.nuclear .. styles.statlow .. prop.blast .. styles.statlow .. prop.gravity .. styles.statlow .. prop.expel .. styles.statlow .. prop.miracle .. styles.statlow .. prop.death .. styles.statlow .. prop.curse .. styles.statlow .. prop.nerve .. styles.statlow .. prop.hiero .. "\n|}"
    end
    if (gameg == "p2is" or gameg == "p2ep") and (prop.atk or prop.def or prop.matk or prop.mdef or prop.str or prop.vit or prop.dex or prop.agl or prop.luc) then
        if gameg == "p2is" then
            prop.dx_h = "|Dexterity"
        else
            prop.dx_h = "|Technique"
        end
        result = result .. styles.table2 .. styles.h .. 'title="Physical Attack Power"|Atk' .. styles.h .. 'title="Physical Defense"|Def' .. styles.h .. 'title="Magical Power"|Matk' .. styles.h .. 'title="Magical Defense"|Mdef' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99) .. styles.barh .. prop.dx_h .. styles.bard2 .. bar(styles.barc, prop.dex, 2.4, 99) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-"
        if not prop.atk or prop.atk == "" then prop.atk = "?" end
        if not prop.def or prop.def == "" then prop.def = "?" end
        if not prop.matk or prop.matk == "" then prop.matk = "?" end
        if not prop.mdef or prop.mdef == "" then prop.mdef = "?" end
        result = result .. "\n|-\n" .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.matk .. styles.statlow .. prop.mdef .. "\n|}"
    end
    if (gameg == "smt3" or gameg == "smtds" or gameg == "sh" or gameg == "p2is" or gameg == "p2ep" or gameg == "pq" or gameg == "pq2" or gameg == "ddsaga1" or gameg == "ddsaga2") and (prop.resist or prop.block or prop.absorb or prop.reflect or prop.weak or prop.boost or prop.wild) then
        result = result .. styles.table2
        prop.resist = prop.resist or "-"
        prop.block = prop.block or "-"
        prop.absorb = prop.absorb or "-"
        prop.reflect = prop.reflect or "-"
        if not prop.weak then
            prop.weak = "-"
        else
            prop.weak = '<span style="color:#f22">' .. prop.weak .. "</span>"
        end
        result = result .. styles.h .. "|Reflects" .. styles.h .. "|Absorbs" .. styles.h .. "|Void" .. styles.h .. "|Resists" .. styles.h .. "|Weak"
        if prop.boost then result = result .. styles.h .. "|Boost" end
        result = result .. "\n|-\n" .. styles.statlow .. prop.reflect .. styles.statlow .. prop.absorb .. styles.statlow .. prop.block .. styles.statlow .. prop.resist .. styles.statlow .. prop.weak
        if prop.boost then result = result .. styles.statlow .. prop.boost end
        result = result .. "\n|}"
    end
    if (gameg == "p2is" or gameg == "p2ep") and (prop.sword or prop.pierce or prop.strike or prop.thrown or prop.rush or prop.fire or prop.water or prop.wind or prop.earth or prop.ice or prop.elec or prop.nuclear or prop.expel or prop.dark or prop.alm or prop.nerve or prop.mind) then
        result = result .. styles.table2
        prop.sword = prop.sword or "-"
        prop.pierce = prop.pierce or "-"
        prop.strike = prop.strike or "-"
        prop.thrown = prop.thrown or "-"
        prop.rush = prop.rush or "-"
        prop.fire = prop.fire or "-"
        prop.water = prop.water or "-"
        prop.wind = prop.wind or "-"
        prop.earth = prop.earth or "-"
        prop.ice = prop.ice or "-"
        prop.elec = prop.elec or "-"
        prop.nuclear = prop.nuclear or "-"
        prop.expel = prop.expel or "-"
        prop.dark = prop.dark or "-"
        prop.alm = prop.alm or "-"
        prop.nerve = prop.nerve or "-"
        prop.mind = prop.mind or "-"
        setPersona2AffinityLabels(prop, gameg)
        result = result .. styles.h .. 'title="Sword"|Sw' .. styles.h .. prop.name_Rn .. styles.h .. 'title="Strike"|Sk' .. styles.h .. 'title="Thrown"|Th' .. styles.h .. prop.name_Hv .. styles.h .. 'style="background:#8E283D" title="Fire"|' .. prop.Fi .. styles.h .. 'style="background:#8E283D" title="Water"|' .. prop.Wt .. styles.h .. 'style="background:#8E283D" title="Wind"|' .. prop.Wi .. styles.h .. 'style="background:#8E283D" title="Earth"|' .. prop.Er .. styles.h .. 'title="Ice"|Ic' .. styles.h .. prop.name_El .. styles.h .. 'title="Nuclear"|Nc' .. styles.h .. prop.name_Li .. styles.h .. 'title="Dark"|Dk' .. styles.h .. 'title="Almighty"|Al' .. styles.h .. 'title="Nerve"|Nr' .. styles.h .. 'title="Mind"|Mn\n|-\n'
        result = result .. styles.statlow .. prop.sword .. styles.statlow .. prop.pierce .. styles.statlow .. prop.strike .. styles.statlow .. prop.thrown .. styles.statlow .. prop.rush .. styles.statlow .. prop.fire .. styles.statlow .. prop.water .. styles.statlow .. prop.wind .. styles.statlow .. prop.earth .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec .. styles.statlow .. prop.nuclear .. styles.statlow .. prop.expel .. styles.statlow .. prop.dark .. styles.statlow .. prop.alm .. styles.statlow .. prop.nerve .. styles.statlow .. prop.mind .. "\n|}"
    end
    if gameg == "pq" or gameg == "pq2" and (prop.sword or prop.pierce or prop.strike or prop.phys or prop.fire or prop.water or prop.elec or prop.wind or prop.nuclear or prop.psy or prop.expel or prop.dark or prop.alm or prop.ko or prop.sleep or prop.panic or prop.poison or prop.paralyze or prop.down or prop.stbind or prop.mabind or prop.agbind) then
        result = result .. styles.table2
        prop.sword = prop.sword or "-"
        prop.pierce = prop.pierce or "-"
        prop.strike = prop.strike or "-"
        prop.phys = prop.phys or "-"
        prop.fire = prop.fire or "-"
        prop.ice = prop.ice or "-"
        prop.elec = prop.elec or "-"
        prop.wind = prop.wind or "-"
        prop.nuclear = prop.nuclear or "-"
        prop.psy = prop.psy or "-"
        prop.expel = prop.expel or "-"
        prop.dark = prop.dark or "-"
        prop.alm = prop.alm or "-"
        prop.sleep = prop.sleep or "-"
        prop.panic = prop.panic or "-"
        prop.poison = prop.poison or "-"
        prop.curse = prop.curse or "-"
        prop.paralyze = prop.paralyze or "-"
        prop.stbind = prop.stbind or "-"
        prop.mabind = prop.mabind or "-"
        prop.agbind = prop.agbind or "-"
        prop.down = prop.down or "-"
        prop.ko = prop.ko or "-"
        if not (prop.arcana and (prop.hp or prop.mp)) then
            if gameg == "pq" then
                result = result .. styles.h .. "width=10%|Cut" .. styles.h .. "width=10%|Stab" .. styles.h .. "width=10%|Bash" .. styles.h .. "width=10%|Fire" .. styles.h .. "width=10%|Ice" .. styles.h .. 'width=10% title="Electricity"|Elec' .. styles.h .. "width=10%|Wind" .. styles.h .. "width=10%|Light" .. styles.h .. "width=10%|Dark" .. styles.h .. 'width=10% title="Almighty"|Alm\n|-\n' .. styles.statlow .. prop.sword .. styles.statlow .. prop.pierce .. styles.statlow .. prop.strike .. styles.statlow .. prop.fire .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec .. styles.statlow .. prop.wind .. styles.statlow .. prop.expel .. styles.statlow .. prop.dark .. styles.statlow .. prop.alm .. "\n|}"
            else
                result = result .. styles.h .. "width=10%|Phys" .. styles.h .. "width=10%|Fire" .. styles.h .. "width=10%|Ice" .. styles.h .. 'width=10% title="Electricity"|Elec' .. styles.h .. "width=10%|Wind" .. styles.h .. 'width=10% title="Psychokinesis"|Psy' .. styles.h .. 'width=10% title="Nuclear"|Nuke' .. styles.h .. "width=10%|Bless" .. styles.h .. "width=10%|Curse" .. styles.h .. 'width=10% title="Almighty"|Alm\n|-\n' .. styles.statlow .. prop.phys .. styles.statlow .. prop.fire .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec .. styles.statlow .. prop.wind .. styles.statlow .. prop.psy .. styles.statlow .. prop.nuclear .. styles.statlow .. prop.expel .. styles.statlow .. prop.dark .. styles.statlow .. prop.alm .. "\n|}"
            end
        end
        if not prop.arcana then --enemy only
            if gameg == "pq" then
                result = result .. styles.table2 .. styles.h .. "width=10%|Sleep" .. styles.h .. "width=10%|Panic" .. styles.h .. "width=10%|Poison" .. styles.h .. "width=10%|Curse" .. styles.h .. "width=10%|Paralysis" .. styles.h .. 'width=10% title="Strength Bind"|S-Bind' .. styles.h .. 'width=10% title="Magic Bind"|M-Bind' .. styles.h .. 'width=10% title="Agility Bind"|A-Bind' .. styles.h .. "width=10%|Down" .. styles.h .. 'width=10% title="Instant Kill"|KO\n|-' .. styles.statlow .. prop.sleep .. styles.statlow .. prop.panic .. styles.statlow .. prop.poison .. styles.statlow .. prop.curse .. styles.statlow .. prop.paralyze .. styles.statlow .. prop.stbind .. styles.statlow .. prop.mabind .. styles.statlow .. prop.agbind .. styles.statlow .. prop.down .. styles.statlow .. prop.ko .. "\n|}"
            else
                result = result .. styles.table2 .. styles.h .. "width=10%|Sleep" .. styles.h .. "width=10%|Confuse" .. styles.h .. "width=10%|Poison" .. styles.h .. "width=10%|Hex" .. styles.h .. "width=10%|Paralysis" .. styles.h .. 'width=10% title="Strength Bind"|S-Bind' .. styles.h .. 'width=10% title="Magic Bind"|M-Bind' .. styles.h .. 'width=10% title="Agility Bind"|A-Bind' .. styles.h .. "width=10%|Down" .. styles.h .. 'width=10% title="Instant Kill"|KO\n|-' .. styles.statlow .. prop.sleep .. styles.statlow .. prop.panic .. styles.statlow .. prop.poison .. styles.statlow .. prop.curse .. styles.statlow .. prop.paralyze .. styles.statlow .. prop.stbind .. styles.statlow .. prop.mabind .. styles.statlow .. prop.agbind .. styles.statlow .. prop.down .. styles.statlow .. prop.ko .. "\n|}"
            end
        end
    end
    if prop.restype then
        if gameg == "mt1" or gameg == "mt2" then
            gameg = "kmt"
            result = result .. styles.table2 .. styles.h .. 'title="Sword"|Swd' .. styles.h .. 'title="Gun"|Gun' .. styles.h .. 'title="Fire"|Fir' .. styles.h .. 'title="Ice"|Ice' .. styles.h .. 'title="Electricity"|Elc' .. styles.h .. 'title="Expel"|Exp' .. styles.h .. 'title="Force"|For' .. styles.h .. 'title="Bind"|Bnd' .. styles.h .. 'title="Curse"|Crs' .. styles.h .. 'title="Nerve"|Nrv' .. styles.h .. 'title="Mind"|Mnd\n|-'
        elseif game == "smt1" then
            result = result .. styles.table2 .. styles.h .. 'title="Sword"|Swd' .. styles.h .. 'title="Gun"|Gun' .. styles.h .. 'title="Fire"|Fir' .. styles.h .. 'title="Ice"|Ice' .. styles.h .. 'title="Electricity"|Elc' .. styles.h .. 'title="Force"|For' .. styles.h .. 'title="Nerve"|Nrv' .. styles.h .. 'title="Expel"|Exp' .. styles.h .. 'title="Curse"|Crs' .. styles.h .. 'title="Magical"|Mgc' .. styles.h .. 'title="Bind"|Bnd' .. styles.h .. 'title="Charge"|Chg' .. styles.h .. 'title="Dex"|Dex' .. styles.h .. 'title="Needle"|Ndl' .. styles.h .. 'title="Almighty"|Alm\n|-'
        elseif game == "smt2" or game == "smtif" then
            result = result .. styles.table2 .. styles.h .. 'title="Sword"|Swd' .. styles.h .. 'title="Gun"|Gun' .. styles.h .. 'title="Fire"|Fir' .. styles.h .. 'title="Ice"|Ice' .. styles.h .. 'title="Electricity"|Elc' .. styles.h .. 'title="Force"|For' .. styles.h .. 'title="Nerve"|Nrv' .. styles.h .. 'title="Expel"|Exp' .. styles.h .. 'title="Curse"|Crs' .. styles.h .. 'title="Magical"|Mgc' .. styles.h .. 'title="Bind"|Bnd' .. styles.h .. 'title="Rush"|Rsh' .. styles.h .. 'title="Hand/Punch Techniques"|Hnd' .. styles.h .. 'title="Leg/Kick Techniques"|Leg' .. styles.h .. 'title="Flying/Throwing Techniques"|Fly' .. styles.h .. 'title="Almighty"|Alm\n|-'
        elseif game == "giten" or game == "gmt" then
            result = result .. styles.table2 .. styles.h .. 'title="Sword"|Swd' .. styles.h .. 'title="Havoc"|Hvc' .. styles.h .. 'title="Fire"|Fir' .. styles.h .. 'title="Ice"|Ice' .. styles.h .. 'title="Electricity"|Elc' .. styles.h .. 'title="Force"|For' .. styles.h .. 'title="Expel"|Exp' .. styles.h .. 'title="Death"|Dth' .. styles.h .. 'title="Mystic"|Mys' .. styles.h .. 'title="Nerve"|Nrv\n|-'
        elseif game == "p1" then
            result = result .. styles.table2 .. '\n!style="background:#a9a9a9" title="Weapons" colspan="8"|\n!title="Firearms" style="background:#898989" colspan="4"|\n!style="background:#a9a9a9" title="Havoc" colspan="2"|\n|-' .. styles.h .. 'title="Weapons"|<abbr title="1-handed Sword">1h</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="2-handed Sword">2h</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Spear">Sp</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Axe">Ax</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Whip">Wp</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Thrown">Th</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Arrows">Ar</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Fist">Fs</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Handgun">HG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Machinegun">MG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Shotgun">SG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Rifle">Ri</abbr>' .. styles.h .. 'title="Havoc"|<abbr title="Tech">Te</abbr>' .. styles.h .. 'title="Havoc"|<abbr title="Rush">Ru</abbr>\n|-'
        elseif game == "p2is" or game == "p2ep" then
            setPersona2AffinityLabels(prop, gameg)
            result = result .. styles.table2 .. styles.h .. 'title="Sword"|Sw' .. styles.h .. prop.name_Rn .. styles.h .. 'title="Strike"|Sk' .. styles.h .. 'title="Thrown"|Th' .. styles.h .. prop.name_Hv .. styles.h .. 'style="background:#8E283D" title="Fire"|' .. prop.Fi .. styles.h .. 'style="background:#8E283D" title="Water"|' .. prop.Wt .. styles.h .. 'style="background:#8E283D" title="Wind"|' .. prop.Wi .. styles.h .. 'style="background:#8E283D" title="Earth"|' .. prop.Er .. styles.h .. 'title="Ice"|Ic' .. styles.h .. prop.name_El .. styles.h .. 'title="Nuclear"|Nc' .. styles.h .. prop.name_Li .. styles.h .. 'title="Dark"|Dk' .. styles.h .. 'title="Almighty"|Al' .. styles.h .. 'title="Nerve"|Nr' .. styles.h .. 'title="Mind"|Mn\n|-'
        end
        local restypes = require("Module:Skills/" .. gameg .. "/res").restypes
        local restype = restypes[prop.restype]
        if restype == nil then
            result = result .. '\n|colspan=16 align=center style="color:#f00;font-size:120%;font-weight:bold"|Invalid value of "' .. prop.restype .. '" for restype. Correct value or edit [[Module:Skills/' .. gameg .. "/res]]."
        else
            for i, v in ipairs(restype) do
                if game == "p1" then
                    if i > 14 then break end
                    result = result .. formatResistance(styles, v, 4, gameg)
                elseif game == "p2is" or game == "p2ep" then
                    result = result .. formatResistance(styles, v, 4, gameg)
                elseif game == "giten" or game == "gmt" then
                    result = result .. formatResistancePercent(styles, v)
                else
                    result = result .. formatResistance(styles, v, 8, gameg)
                end
            end
        end
        result = result .. "\n|}"
        if game == "p1" then
            result = result .. styles.table2 .. '\n|-\n!style="background:#a9a9a9" title="Element" colspan="4"|\n!style="background:#898989" title="Force" colspan="4"|\n!style="background:#a9a9a9" title="Light" colspan="2"|\n!style="background:#898989" title="Dark" colspan="3"|\n!style="background:#a9a9a9" title="Special" colspan="1"|\n|-' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Fire">Fi</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Ice">Ic</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Wind">Wi</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Earth">Er</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Electricity">El</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Nuclear">Nc</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Blast">Bl</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Gravity">Gr</abbr>' .. styles.h .. 'title="Light"|<abbr title="Expel">Ex</abbr>' .. styles.h .. 'title="Light"|<abbr title="Miracle">Mi</abbr>' .. styles.h .. 'style="background:#898989" title="Dark"|<abbr title="Death">De</abbr>' .. styles.h .. 'style="background:#898989" title="Dark"|<abbr title="Curse">Cu</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Dark (Ailments)"|<abbr title="Nerve">Nr</abbr>' .. styles.h .. 'width="7.12%" title="Special"|<abbr title="Resistance to Hieroglyphein">???</abbr>\n|-'
            for i, v in ipairs(restype) do
                if i < 15 then
                else
                    result = result .. formatResistance(styles, v, 4, gameg)
                end
            end
            result = result .. "\n|}"
        end
    end
    if game == "smt9" and prop.reslevels then
        styles.h = '\n!style="background:' .. gameData.colorbg .. ';color:#fff" '
        result = result .. styles.table2h .. '"' .. styles.h .. "colspan=4|" .. styles.spanc .. "[[Resistance Level]]s</span>"
        prop.reslevels = mw.text.split(prop.reslevels, "\n")
        prop.resleveltypes = {
            ["strike"] = ' <span style="color:#5f5">+1</span></span>',
            ["slash"] = ' <span style="color:#5f5">+1</span></span>',
            ["tech"] = ' <span style="color:#5f5">+1</span></span>',
            ["gun"] = ' <span style="color:#5f5">+1</span></span>',
            ["thrown"] = ' <span style="color:#5f5">+1</span></span>',
            ["fire"] = ' <span style="color:#5f5">+1</span></span>',
            ["ice"] = ' <span style="color:#5f5">+1</span></span>',
            ["elec"] = ' <span style="color:#5f5">+1</span></span>',
            ["force"] = ' <span style="color:#5f5">+1</span></span>',
            ["expel"] = ' <span style="color:#5f5">+1</span></span>',
            ["death"] = ' <span style="color:#5f5">+1</span></span>',
            ["mind"] = ' <span style="color:#5f5">+1</span></span>',
            ["nerve"] = ' <span style="color:#5f5">+1</span></span>',
            ["almighty"] = ' <span style="color:#5f5">+1</span></span>',
            ["heal"] = ' <span style="color:#5f5">+1</span></span>',
        }
        local resleveltemp
        for k1, v1 in ipairs(prop.reslevels) do
            local modifier
            resleveltemp, modifier = splitReslevelPair(v1)
            resleveltemp = resleveltemp:lower()
            if string.sub(modifier, 1, 1) == "+" then
                if string.find(modifier, "rf") then
                    prop.resleveltypes[resleveltemp] = ' <span style="color:#5ff">' .. modifier .. "</span></span>"
                elseif string.find(modifier, "dr") then
                    prop.resleveltypes[resleveltemp] = ' <span style="color:#f5f">' .. modifier .. "</span></span>"
                else
                    prop.resleveltypes[resleveltemp] = ' <span style="color:#5f5">' .. modifier .. "</span></span>"
                end
            else
                prop.resleveltypes[resleveltemp] = ' <span style="color:#f55">' .. modifier .. "</span></span>"
            end
        end
        result = result .. styles.table2 .. styles.h .. 'title="Strike"|St' .. styles.h .. 'title="Slash"|Sl' .. styles.h .. 'title="Tech"|Te' .. styles.h .. 'title="Gun"|Gu' .. styles.h .. 'title="Thrown"|Th' .. styles.h .. 'title="Fire"|Fi' .. styles.h .. 'title="Ice"|Ic' .. styles.h .. 'title="Electricity"|El' .. styles.h .. 'title="Force"|Fo' .. styles.h .. 'title="Expel"|Ex' .. styles.h .. 'title="Death"|De' .. styles.h .. 'title="Mind"|Mi' .. styles.h .. 'title="Nerve"|Ne' .. styles.h .. 'title="Almighty"|Al' .. styles.h .. 'title="Healing"|He\n|-' .. styles.statlow3 .. '"|' .. prop.resleveltypes.strike .. styles.statlow3 .. '"|' .. prop.resleveltypes.slash .. styles.statlow3 .. '"|' .. prop.resleveltypes.tech .. styles.statlow3 .. '"|' .. prop.resleveltypes.gun .. styles.statlow3 .. '"|' .. prop.resleveltypes.thrown .. styles.statlow3 .. '"|' .. prop.resleveltypes.fire .. styles.statlow3 .. '"|' .. prop.resleveltypes.ice .. styles.statlow3 .. '"|' .. prop.resleveltypes.elec .. styles.statlow3 .. '"|' .. prop.resleveltypes.force .. styles.statlow3 .. '"|' .. prop.resleveltypes.expel .. styles.statlow3 .. '"|' .. prop.resleveltypes.death .. styles.statlow3 .. '"|' .. prop.resleveltypes.mind .. styles.statlow3 .. '"|' .. prop.resleveltypes.nerve .. styles.statlow3 .. '"|' .. prop.resleveltypes.almighty .. styles.statlow3 .. '"|' .. prop.resleveltypes.heal
        result = result .. "\n|}" .. "\n|}"
    end
    return result
end

return p
