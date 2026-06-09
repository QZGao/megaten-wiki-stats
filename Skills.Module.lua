local getArgs = require("Module:Arguments").getArgs
local getGames = require("Module:Gamedata")
local SkillTable = require("Module:Skills/Render/SkillTable")

local p = {}

local function makeInvokeFunction(funcName)
    -- makes a function that can be returned from #invoke, using
    -- [[Module:Arguments]].
    return function(frame)
        local args = getArgs(frame, { parentOnly = true })
        return p[funcName](args)
    end
end

local styles = {
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

local function frac(numerator, denominator)
    return '<span style="font-size:9px;position:relative;top:2px"><span style="position:relative;top:-5px;right:-3px">' .. numerator .. '</span><span style="position:relative;top:-2px">／</span>' .. denominator .. "</span>"
end

local function resoutput(v, denominator, game)
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
    elseif tonumber(v) == 0 then
        v = 'color:white" title="Null"|Nu'
    elseif tonumber(v) == 1 then
        v = '" title="Normal"| -'
    elseif tonumber(v) < 1 then
        v = 'color:teal"  title="Resist"|' .. frac((tonumber(v) * denominator), denominator)
    elseif tonumber(v) > 2 then
        v = 'color:red" title="Weak"|' .. v .. "×"
    elseif tonumber(v) > 1.3 then
        if game == "smt1" or game == "smt2" or game == "smtif" then
            v = 'color:orange" title="Vulnerable"|' .. v .. "×"
        else
            v = 'color:red" title="Weak"|' .. v .. "×"
        end
    elseif tonumber(v) > 1.1 then
        v = 'color:orange" title="Vulnerable"|' .. v .. "×"
    end
    return styles.statlow3 .. v
end

local function outputResAsPercent(v)
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

local function rarityCategory(rarity, gamen)
    if string.find(rarity, "★") ~= nil then
        local rarityNumber = math.floor(#rarity / 3)

        if rarityNumber > 0 then
            return string.format("[[Category:%d★ Demons in %s]]", rarityNumber, gamen)
        else
            return ""
        end
    else
        return string.format("[[Category:%s Demons in %s]]", rarity, gamen)
    end
end

local function createEquipTable(base)
    local equiptable = {
        ["sword"] = "=",
        ["gun"] = "-",
        ["ammo"] = "-",
        ["accessory"] = "-",
        ["head"] = "-",
        ["body"] = "-",
        ["arms"] = "-",
        ["legs"] = "-",
    }

    local basetable = mw.text.split(base, "\n")

    for k, v in ipairs(basetable) do
        local kvPair = mx.text.split(v, "\\")
        local key = string.lower(kvPair[1])

        if equiptable[key] ~= nil then equiptable[key] = kvPair[2] end
    end

    return equiptable
end

local function cate(catename)
    if mw.title.getCurrentTitle():inNamespace("") then
        return "[[Category:" .. catename .. "]]"
    else
        return ""
    end
end

local function noskill(skill, gamed)
    local result = "\n|-\n!"
    if gamed == "METAPHOR" then
        result = result .. "colspan=6"
    else
        result = result .. "colspan=5"
    end
    result = result .. ' style="background:#300;width:600px"|<strong style="color:red;font-size:150%">'
    if skill and gamed then
        result = result .. 'Invalid skill name of "' .. skill .. '". You may correct the skill name or modify [[module:Skills/' .. gamed .. "]] if needed"
    else
        result = result .. "No empty line or empty skill name is allowed. You should either remove the empty line or add some proper skill name"
    end
    return result .. ".</strong>" .. cate("Articles with unrecognizable skill name for Module:Skills") .. '\n|-style="display:none"\n'
end

local function wikitext(text)
    return mw.getCurrentFrame():preprocess(text)
end

local race_names = {
    --Gods
    ["Deity"] = { "Deity", "Demon God" },
    ["Megami"] = { "Megami", "Goddess" },
    ["Amatsu"] = { "Amatsu", "Heavenly God", "Tenjin" },
    ["Enigma"] = { "Enigma" },
    ["Entity"] = { "Entity", "Geist" },
    ["Godly"] = { "Godly", "Godly Spirit" },
    ["Soshin"] = { "Soshin" },
    ["Chaos"] = { "Chaos", linkdab = true },
    --Guardians
    ["Tenma"] = { "Tenma" },
    ["Fury"] = { "Fury", "Destroyer", "Omega", linkdab = true },
    ["Lady"] = { "Lady", "Earth Mother" },
    ["Kunitsu"] = { "Kunitsu", "Nation Ruler", "Chigi" },
    ["Kishin"] = { "Kishin", "Guardian" },
    ["Vile"] = { "Vile" },
    ["Reaper"] = { "Reaper", linkdab = true },
    ["Shinshou"] = { "Shinshou" },
    ["Wargod"] = { "Wargod" },
    ["Zealot"] = { "Zealot", linkdab = true },
    --Aerials
    ["Herald"] = { "Herald", "Seraph", "Hallel" },
    ["Divine"] = { "Divine" },
    ["Fallen"] = { "Fallen", "Fallen Angel", "Futenshi" },
    --Birds
    ["Avian"] = { "Avian" },
    ["Flight"] = { "Flight", "Wild Bird" },
    ["Raptor"] = { "Raptor" },
    --Dragons
    ["Dragon"] = { "Dragon", "Dragon God" },
    ["Snake"] = { "Snake", "Dragon King" },
    ["Drake"] = { "Drake", "Evil Dragon" },
    ["Hiryu"] = { "Hiryu" },
    --Beasts
    ["Avatar"] = { "Avatar", "Godly Beast" },
    ["Holy"] = { "Holy", "Holy Beast" },
    ["Beast"] = { "Beast", linkdab = true },
    ["Wilder"] = { "Wilder" },
    ["UMA"] = { "UMA" },
    ["Kaijuu"] = { "Kaijuu" },
    --Onis
    ["Touki"] = { "Touki" },
    ["Brute"] = { "Brute" },
    ["Jirae"] = { "Jirae", "Earth Spirit" },
    ["Femme"] = { "Femme", "Joma" },
    ["Jaki"] = { "Jaki", "Evil Demon" },
    ["Akuma"] = { "Akuma" },
    ["Shinoma"] = { "Shinoma" },
    ["Henii"] = { "Henii", catename = false },
    --Magicas
    ["Tyrant"] = { "Tyrant", "Demon Lord" },
    ["Genma"] = { "Genma", "Demigod" },
    ["Fairy"] = { "Fairy" },
    ["Yoma"] = { "Yoma" },
    ["Night"] = { "Night", "Nocturne" },
    ["Shin Akuma"] = { "Shin Akuma" },
    --Vegetations
    ["Tree"] = { "Tree" },
    ["Wood"] = { "Wood" },
    ["Jusei"] = { "Jusei" },
    --Elementals
    ["Element"] = { "Element", "Prime", linkdab = true },
    ["Mitama"] = { "Mitama" },
    --Evil Spirits
    ["Haunt"] = { "Haunt" },
    ["Spirit"] = { "Spirit", "Jarei" },
    ["Undead"] = { "Undead", "Grave" },
    --Humans
    ["Human"] = { "Human" },
    ["Gaean"] = { "Gaean", "Gaian", link = "Ring of Gaea", catename = "Ring of Gaea" },
    ["Messian"] = { "Messian", link = "Order of Messiah", catename = "Order of Messiah" },
    ["Summoner"] = { "Summoner", link = "Devil Summoner (race)" },
    ["Kyojin"] = { "Kyojin" },
    ["Shinja"] = { "Ishtar Shinja", "Bael Shinja" },
    ["Meta"] = { "Meta" },
    ["Ranger"] = { "Ranger" },
    ["Hero"] = { "Hero" },
    ["General"] = { "General" },
    ["Therian"] = { "Therian" },
    ["Foreigner"] = { "Foreigner" },
    ["Fiend"] = { "Fiend" },
    --Fouls
    ["Foul"] = { "Foul" },
    ["Vermin"] = { "Vermin" },
    ["Demonoid"] = { "Demonoid" },
    ["Rumor"] = { "Rumor" },
    ["Karma"] = { "Karma", link = "Karma (race)" },
    --Machine
    ["Machine"] = { "Machine", "Device" },
    ["Virus"] = { "Virus", exclusive = "#Virus and Vaccine" },
    ["Vaccine"] = { "Vaccine", exclusive = "#Virus and Vaccine" },
    --Unclassified
    ["Zoma"] = { "Zoma" },
    ["Fake"] = { "Fake" },
    ["Famed"] = { "Famed" },
    ["Suiyou"] = { "Suiyou" },
    ["Nymph"] = { "Nymph" },
    ["Food"] = { "Food" },
    --Enemy-exclusive
    ["Horde"] = { "Horde", catename = false },
    ["Yuiitsukami"] = { "Yuiitsukami", exclusive = "Yuiitsukami / Kami", catename = false },
    ["Kami"] = { "Kami", exclusive = "Yuiitsukami / Kami", catename = false },
    ["Himitsu"] = { "Himitsu", exclusive = "Himitsu", catename = false },
    ["Teacher"] = { "Teacher", exclusive = "Kyoushi and Kaizou Kyoushi", catename = false },
    ["Demon God Emperor"] = { "Demon God Emperor", "Majinou", "Majin Ou", "Majinō", "Majinnou", "Majinnō", exclusive = "Majinou / Demon God Emperor", catename = false },
    ["Boutoko"] = { "Boutoko", exclusive = "Boutoko / Violent Guy", catename = false },
    ["Corpus"] = { "Corpus", link = "Manikin", catename = false },
    ["Zoa"] = { "Zoa", exclusive = "Bunrei / Zoa" },
    ["Light"] = { "Light", exclusive = "Mujinkou / Light", catename = false },
    ["Devil"] = { "Devil", exclusive = "Daimaou / Devil", catename = false },
    ["Archaic"] = { "Archaic", exclusive = "Archaic", catename = false },
    ["King"] = { "King", exclusive = "King", catename = false },
    ["Koki"] = { "Koki", exclusive = "Koki", catename = false },
    ["Great"] = { "Great", exclusive = "Great", catename = false },
    ["Awake"] = { "Awake", exclusive = "Awake and Soil", catename = false },
    ["Soil"] = { "Soil", exclusive = "Awake and Soil", catename = false },
    ["Judge"] = { "Judge", exclusive = "Judge and Pillar", catename = false },
    ["Pillar"] = { "Pillar", exclusive = "Judge and Pillar", catename = false },
    ["Mother"] = { "Mother", exclusive = "Mother and Empty", catename = false },
    ["Empty"] = { "Empty", exclusive = "Mother and Empty", catename = false },
    ["Onmyo"] = { "Onmyo", exclusive = "Onmyo", catename = false },
    ["God"] = { "God", exclusive = "Bonten / God", catename = false },
    ["Bel"] = { "Bel", link = "King of Bel", catename = false },
    ["Star"] = { "Star", link = "Septentriones" },
    ["Energy"] = { "Energy", exclusive = "Jiryuu / Energy", catename = false },
    ["King Abaddon"] = { "King Abaddon", catename = false },
    ["Fukoshi"] = { "Fukoshi", catename = false },
    ["Locust"] = { "Locust", "Soldier Bug", link = "Soldier Bug", catename = false },
    ["Tokyogami"] = { "Tokyogami", exclusive = "Tokyogami", catename = false },
    ["Rebel God"] = { "Rebel God", exclusive = "Rebel God", catename = false },
}

local function getRace(race, game, abbr)
    local result
    if not race or race == "" or race == "-" or race == "Unclassified" or race == "None" or race == "none" then
        result = "-"
    elseif game == "ddsaga1" or game == "ddsaga2" then
        if race == "Deity" then
            result = "[[Gods|" .. race .. "]]"
        elseif race == "Evil" or race == "Icon" then
            result = "[[Guardians|" .. race .. "]]"
        elseif race == "Fiend" or race == "Nether" then
            result = "[[Magica|" .. race .. "]]"
        elseif race == "Aerial" then
            result = "[[Aerials|" .. race .. "]]"
        elseif race == "Aerial2" then
            result = "[[Birds|Aerial]]"
        elseif race == "Dragon" then
            result = "[[Dragons|" .. race .. "]]"
        elseif race == "Demon" or race == "Brute" then
            result = "[[Demoniacs|" .. race .. "]]"
        elseif race == "Beast" then
            result = "[[Beasts|" .. race .. "]]"
        elseif race == "Device" then
            result = "[[Machine|" .. race .. "]]"
        elseif race == "Light" then
            result = "[[Herald|" .. race .. "]]"
        else
            result = race
        end
    elseif game == "raidou1" or game == "raidou2" then
        if race == "Element" then
            result = "[[Element]]" .. cate("Element Race")
        elseif race == "Spirit" then
            result = "[[Mitama|Spirit]]" .. cate("Mitama Race")
        elseif race == "Destroyer" or race == "King Abaddon" or race == "Fukoshi" or race == "Locust" or race == "Tokyogami" or race == "Rebel God" then
            result = "[[Enemy exclusive race#" .. race .. "|" .. race .. "]]"
        elseif race == "Fiend" then
            result = "[[Fiend]]" .. cate("Fiend Race")
        elseif race == "Pyro" or race == "Frost" or race == "Volt" or race == "Wind" or race == "Fury" or race == "Pagan" or race == "Skill" or race == "Evil" then
            result = "[[" .. race .. " Order|" .. race .. "]]" .. cate(race .. " Order")
        else
            result = race
        end
    elseif race == "Therian" then
        if game == "mt1" then
            result = "[[Yoma|Therian]]" .. cate("Yoma Race")
        else
            result = "[[Therian]]" .. cate("Therian Race")
        end
    elseif race == "Ghost" then
        if game == "sh" or game == "smtds" then
            result = "[[Ghost (race)|Ghost]]" .. cate("Ghost Race")
        else
            result = "[[Haunt|Ghost]]" .. cate("Haunt Race")
        end
    elseif race == "Cyber" then
        if game == "smt4" then
            result = "[[Machine|Cyber]]" .. cate("Machine Race")
        else
            result = "[[Enemy exclusive race#Denrei / Cyber|Cyber]]"
        end
    elseif race == "Star 2" then
        result = "[[Triangulum|Star]]" .. cate("Star Race")
    end
    for k, v in pairs(race_names) do
        for _, name in ipairs(v) do
            if race == name then
                if abbr then
                    abbr = '<abbr title="' .. abbr .. '">' .. name .. "</abbr>"
                else
                    abbr = name
                end
                if v.exclusive then
                    result = "[[Enemy exclusive race#" .. v.exclusive .. "|" .. abbr .. "]]"
                elseif v.linkdab then
                    result = "[[" .. k .. " (race)|" .. abbr .. "]]"
                elseif v.link then
                    result = "[[" .. v.link .. "|" .. abbr .. "]]"
                else
                    result = "[[" .. k .. "|" .. abbr .. "]]"
                end
                if v.catename == false then
                elseif v.catename then
                    result = result .. cate(v.catename)
                else
                    result = result .. cate(k .. " Race")
                end
            end
        end
    end
    if not result then return race end
    return result
end

local function aligncat(align, gamen)
    local result
    if align == "Law" or align == "Light-Law" or align == "Neutral-Law" or align == "Dark-Law" then
        result = cate("Law Demons in " .. gamen)
    elseif align == "Neutral" or align == "Light-Neutral" or align == "Neutral-Neutral" or align == "Dark-Neutral" then
        result = cate("Neutral Demons in " .. gamen)
    elseif align == "Chaos" or align == "Light-Chaos" or align == "Neutral-Chaos" or align == "Dark-Chaos" then
        result = cate("Chaos Demons in " .. gamen)
    elseif string.lower(align) == "unknown" then
        result = cate("Unknown Demons in " .. gamen)
    else
        result = ""
    end
    return result
end

local function alignnocat(align, nocat, gamen)
    local result
    if nocat then
        result = ""
    elseif align == "Law" or align == "Light-Law" or align == "Neutral-Law" or align == "Dark-Law" then
        result = cate("Law Demons in " .. gamen)
    elseif align == "Neutral" or align == "Light-Neutral" or align == "Neutral-Neutral" or align == "Dark-Neutral" then
        result = cate("Neutral Demons in " .. gamen)
    elseif align == "Chaos" or align == "Light-Chaos" or align == "Neutral-Chaos" or align == "Dark-Chaos" then
        result = cate("Chaos Demons in " .. gamen)
    elseif string.lower(align) == "unknown" then
        result = cate("UNKNOWN Demons in " .. gamen)
    else
        result = ""
    end
    return result
end

local function bossdemonnocat(boss, nocat, gamen)
    local result
    if boss then
        result = cate(gamen .. " Bosses")
    elseif nocat then
        result = ""
    else
        result = cate(gamen .. " Demons")
    end
    return result
end

local function bossdemoncat(boss, gamen)
    local result
    if boss then
        result = cate(gamen .. " Bosses")
    else
        result = cate(gamen .. " Demons")
    end
    return result
end

local function getArcana(arcana, game, gamen)
    local result
    if not arcana or arcana == "" or arcana == "-" or arcana == "Unclassified" or arcana == "None" or arcana == "none" then
        result = "-"
    elseif arcana == "Coin" or arcana == "Coins" then
        result = "[[Suit of Coins|Coin]]" .. cate("Coin Arcana")
    elseif arcana == "Pentacle" then
        result = "[[Suit of Coins|Pentacle]]" .. cate("Coin Arcana")
    elseif arcana == "Sword" or arcana == "Swords" then
        result = "[[Suit of Swords|Sword]]" .. cate("Sword Arcana")
    elseif arcana == "Cup" or arcana == "Cups" then
        result = "[[Suit of Cups|Cup]]" .. cate("Cup Arcana")
    elseif arcana == "Wand" or arcana == "Wands" then
        result = "[[Suit of Wands|Wand]]" .. cate("Wand Arcana")
    elseif arcana == "Rod" then
        result = "[[Suit of Wands|Rod]]" .. cate("Wand Arcana")
    elseif arcana == "Rumor" then
        result = "[[Rumor]] [[List of " .. gamen .. " Rumors|*]]" .. cate("Rumor Demon")
    elseif arcana == "Taurus" or arcana == "Aquarius" or arcana == "Leo" or arcana == "Scorpio" or arcana == "Masquerade" then
        result = "[[Masked Circle|" .. arcana .. "]]" .. cate("Masked Circle")
    elseif arcana == "Reich" then
        result = "[[Last Battalion|" .. arcana .. "]]"
    elseif arcana == "Grave" or arcana == "Zonbie" or arcana == "Zombie" then
        result = "[[Undead|" .. arcana .. "]]" .. cate("Undead Race")
    elseif arcana == "Human" then
        result = "[[Human]]" .. cate("Human Race")
    elseif arcana == "Machine" then
        result = "[[Machine]]" .. cate("Machine Race")
    else
        result = "[[" .. arcana .. " Arcana|" .. arcana .. "]]" .. cate(arcana .. " Arcana")
    end
    return result
end

local function bar(color, stat, ratio, cap, stat2, old, new) -- ratio is the length (in pixel) of each point. Cap times ratio equals max length of the stat bar.
    local stat_st, stat_width
    if stat == "i" then
        stat = "i"
    elseif not tonumber(stat) then
        stat_st = '<span style="color:#666">--</span>'
        stat = 0
        stat_width = 0
    elseif stat2 then
        stat_st = '<span style="color:#aff;cursor:help" title="' .. old .. ": " .. stat .. "; " .. new .. ": " .. stat2 .. '">' .. stat2 .. "</span>"
    else
        stat_st = stat
    end
    if stat == "i" then
    elseif tonumber(stat) > cap then
        stat_width = cap * ratio
        color = "#aaf"
    elseif stat_width ~= 0 then
        stat_width = tonumber(stat) * ratio
    end
    inherit = "Inherit"
    if tostring(stat_st) == "+0" then stat_st = '<span style="color:#666">--</span>' end
    if stat == "i" then
        return "--\n|Inherit\n|-"
    elseif stat2 then
        return stat_st .. '\n|style="border-radius:10px;background-color:#000;background:linear-gradient(90deg, #2c2a46, #000);width:' .. cap * ratio + 3 .. 'px"|<div style="overflow:hidden"><div style="cursor:help;float:left;border-top:5px solid ' .. color .. ";width:" .. stat_width .. 'px" title="' .. old .. ": " .. stat .. '"></div><div style="cursor:help;float:left;border-top:5px solid #aff;width:' .. tonumber(stat2) * ratio - stat_width .. 'px" title="' .. new .. ": " .. stat2 .. '"></div></div>\n|-'
    else
        return stat_st .. '\n|style="border-radius:10px;background-color:#000;background:linear-gradient(90deg, #2c2a46, #000);width:' .. cap * ratio + 3 .. 'px"|<div style="overflow:hidden"><div style="float:left;border-top:5px solid ' .. color .. ";width:" .. stat_width .. 'px"></div><div style="float:left;border-top:5px solid transparent;width:' .. (cap - tonumber(stat)) * ratio .. 'px"></div></div>\n|-'
    end
end

local function get_prop(args)
    local prop = {}
    for k, v in pairs(require("Module:Property_names")) do
        for _, name in ipairs(v) do
            if args[name] then
                prop[k] = args[name]
                break
            end
        end
        prop[k] = prop[k] or v.default
    end
    return prop
end

local function hasAnyStatBarValue(prop, statKeys)
    for _, key in ipairs(statKeys) do
        local value = prop[key]
        if value == "i" or tonumber(value) ~= nil then
            return true
        end
    end
    return false
end

local function hasFilledValue(value)
    return value ~= nil and value ~= "-"
end

p.stats = makeInvokeFunction("_stats")

function p._stats(args)
    local game = args[1] or args.game or args.Game or ""
    game = game:lower()
    if game == "mt" then game = "mt1" end
    if game == "kmt" then game = "kmt1" end
    if game == "smt" then game = "smt1" end
    if game == "smtii" then game = "smt2" end
    if game == "if" or game == "if..." then game = "smtif" end
    if game == "smtn" or game == "smt3n" then game = "smt3" end
    if game == "smtiv" then game = "smt4" end
    if game == "imagine" or game == "smti" then game = "smtim" end
    if game == "gmt" or game == "smti" then game = "giten" end
    if game == "lb" then game = "lb1" end
    if game == "majin" or game == "mjt" then game = "majin1" end
    if game == "majin2sn" or game == "mt2sn" then game = "majin2" end
    if game == "dssh" then game = "sh" end
    if game == "dsrksa" then game = "raidou1" end
    if game == "dsrkka" then game = "raidou2" end
    if game == "desu" or game == "smtdesur" or game == "desur" then game = "desu1" end
    if game == "smtdesur2" or game == "desur2" then game = "desu2" end
    if args.HazamaCh then game = "smtifhc" end
    if args.FES then game = "p3f" end
    if args.P3P then game = "p3p" end
    if args.P4G then game = "p4g" end
    if args.P5R then game = "p5r" end
    if args.P5S then game = "p5s" end
	if args.P5X then game = "p5x" end
    if args.BR or args.RB then game = "desu2rb" end
    if args.DC then game = "20xxdc" end
    if args.TMSFE then game = "tmsfe" end
    local gameg -- Game general style
    if getGames.games[game].fallback then
        gameg = getGames.games[game].fallback -- e.g. 'p3f' and 'p3p' will fall back to 'p3' if applicable.
    else
        gameg = game
    end
    local gamen = getGames.games[game].name -- Full game name
    local gamegn = getGames.games[gameg].name -- e.g. 'Persona 3 FES' will fall back to 'Persona 3' if applicable.
    local gamed
    if gameg == "mt1" or gameg == "mt2" then
        gamed = "KMT"
    elseif gameg == "smtif" then
        gamed = "if..."
    elseif gameg == "raidou1" then
        gamed = "DSRKSA"
    elseif gameg == "raidou2" then
        gamed = "DSRKKA"
    elseif gameg == "childps" then
        gamed = "CHILDRED"
    elseif gameg == "childlight" then
        gamed = "DMK"
    elseif gameg then
        gamed = gameg:upper()
    end
    local data
    if not (gameg == "smt9" or gameg == "20xx" or game == "lb3" or game == "lbs" or game == "ronde" or game == "cs") then data = require("Module:Skills/" .. gamed) end
    local prop = get_prop(args)
    if gameg == "smt3" then getGames.games[gameg].colorbg = getGames.games[gameg].colorbg2 end
    styles.h = '\n!style="background: ' .. getGames.games[gameg].colorbg .. ";color: " .. getGames.games[gameg].font .. '" '
    styles.spanc = '<span style="color:' .. getGames.games[gameg].font .. '">'
    if not getGames.games[gameg].statt then getGames.games[gameg].statt = "#529488" end
    styles.barh = '\n|style="color:' .. getGames.games[gameg].statt .. '" '
    styles.bart11 = '\n|rowspan=2 style="padding:0" width='
    styles.bart12 = '|\n{|cellspacing=2 cellpadding=0 style="background:transparent;font-size:11px;font-family:monospace;letter-spacing:-1px;line-height:'
    styles.bard = '\n|style="text-align:right;padding:0 3px" '
    styles.bard1 = styles.bard .. "width=12px|"
    styles.bard2 = styles.bard .. "width=17px|"
    local result = '{|align="center" style="min-width:650px;text-align:center; background: #222; border:2px solid ' .. getGames.games[gameg].colorb .. '; border-radius:10px; font-size:75%; font-family:verdana;"\n|-\n|' .. styles.table2b
    if gameg == "sh2" then result = '{|align="center" style="min-width:650px;text-align:center; background: #222; border:2px solid ' .. getGames.games[gameg].colorbg .. '; border-radius:10px; font-size:75%; font-family:verdana;"\n|-\n|' .. styles.table2b end
    local pending_top_stats, pending_top_stats_categories
    local function flushPendingTopStats()
        if pending_top_stats then
            result = result .. pending_top_stats .. (pending_top_stats_categories or "")
            pending_top_stats = nil
            pending_top_stats_categories = nil
        end
    end
    local function appendTopAffinityTable(affinity_table)
        if pending_top_stats then
            result = result .. styles.table2b .. '\n|style="padding:0;width:24%;vertical-align:top"|' .. pending_top_stats .. '\n|style="padding:0;width:76%;vertical-align:top"|' .. affinity_table .. "\n|}" .. (pending_top_stats_categories or "")
            pending_top_stats = nil
            pending_top_stats_categories = nil
        else
            result = result .. affinity_table
        end
    end
    if getGames.games[gameg].statb == nil then
        styles.barc = "orange"
    else
        styles.barc = getGames.games[gameg].statb
    end
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
    if prop.location then
        prop.location = "[[" .. prop.location .. "]]"
    else
        prop.location = ""
    end
    if game == "mt1" then
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
    end
    if game == "mt2" then
        if not prop.hp then prop.hp = "" end
        if not prop.mp then prop.mp = "" end
        if not prop.cp then prop.cp = "" end
        if not prop.mag then prop.mag = "" end
        if not prop.yen then prop.yen = "" end
        if not prop.normal then prop.normal = "" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Cost Point - MAG Cost per 10 Steps"|<abbr>CP</abbr>\n|-' .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.cp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. 'title="Number appearing in battle"|<abbr>Formations</abbr>' .. styles.h .. "|[[Magnetite|" .. styles.spanc .. "MAG]]" .. styles.h .. "|[[Macca|" .. styles.spanc .. "Macca</span>]]" .. styles.h .. "|[[List of Megami Tensei II Items|" .. styles.spanc .. "Item Drops</span>]]\n|-" .. styles.statlow .. prop.formation .. styles.statlow .. prop.mag .. styles.statlow .. prop.yen .. styles.statlow .. prop.normal .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Stamina" .. styles.h .. "|Intelligence" .. styles.h .. "|Attack" .. styles.h .. "|Agility" .. styles.h .. "|Luck" .. styles.h .. "|Defense\n|-" .. styles.statlow .. prop.vit .. styles.statlow .. prop.int .. styles.statlow .. prop.atk .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. styles.statlow .. prop.def .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    end
    if game == "kmt1" or game == "kmt2" then
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
    end
    if gameg == "smt1" or gameg == "smt2" or gameg == "smtif" or gameg == "20xx" then
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
    end
    if gameg == "smt9" then
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
    end
    if gameg == "smt3" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h
        if prop.element then
            result = result .. "|Element" .. styles.h .. "|Wild Effects" .. cate("Magatama")
            styles.barc = getGames.games[gameg].statb2
        else
            result = result .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. bossdemoncat(prop.boss, gamen) .. styles.h .. "width=9%|Level" .. styles.h .. 'width=9%|<span style="color:' .. getGames.games[gameg].hp .. '">HP</span>' .. styles.h .. 'width=9%|<span style="color:' .. getGames.games[gameg].mp .. '">MP</span>'
        end
        result = result .. styles.bart11 .. "319px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 6, 40) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 6, 40) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 6, 40) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 6, 40) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 6, 40) .. "\n|}\n|-" .. styles.statlow
        if prop.element then
            result = result .. prop.element .. styles.statlow .. prop.wild
        else
            result = result .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. getGames.games[gameg].hp2 .. ';border-radius:3px"></div>' .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. getGames.games[gameg].mp2 .. ';border-radius:3px"></div>'
        end
        result = result .. "\n|}"
    end
    if gameg == "smtim" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|[[Alignment|" .. styles.spanc .. "Alignment</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Growth" .. styles.h .. "|Inherit" .. styles.h .. 'title="Strength"|St' .. styles.h .. 'title="Magic"|Ma' .. styles.h .. 'title="Vitality"|Vi' .. styles.h .. 'title="Intelligence"|In' .. styles.h .. 'title="Speed"|Sp' .. styles.h .. 'title="Luck"|Lu'
        result = result .. "\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. aligncat(prop.alignment, gamen) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.growth .. styles.statlow .. prop.inherit .. styles.statlow .. prop.str .. styles.statlow .. prop.magic .. styles.statlow .. prop.vit .. styles.statlow .. prop.int .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Force Slot" .. styles.h .. 'title="Close Range"|<abbr>Close</abbr>' .. styles.h .. 'title="Long Range"|<abbr>Long</abbr>' .. styles.h .. "|Spell" .. styles.h .. "|Support" .. styles.h .. 'title="Physical Defense"|P.Def' .. styles.h .. 'title="Magical Defense"|M.Def' .. styles.h .. "|Critical" .. styles.h .. 'title="Critical Defense"|Crt.Def\n|-'
        result = result .. styles.statlow .. prop.forceslot .. styles.statlow .. prop.closerange .. styles.statlow .. prop.longrange .. styles.statlow .. prop.spell .. styles.statlow .. prop.support .. styles.statlow .. prop.def .. styles.statlow .. prop.mdef .. styles.statlow .. prop.critical .. styles.statlow .. prop.critdef .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    end
    if gameg == "smtsj" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|[[Alignment|" .. styles.spanc .. "Alignment</span>]]" .. styles.h .. "|Level" .. styles.h .. 'width=7%|<span style="color:' .. getGames.games[gameg].hp .. '">HP</span>' .. styles.h .. 'width=7%|<span style="color:' .. getGames.games[gameg].mp .. '">MP</span>' .. styles.bart11 .. "274px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard1 .. bar(styles.barc, prop.str, 2, 99) .. styles.barh .. "|Magic" .. styles.bard1 .. bar(styles.barc, prop.magic, 2, 99) .. styles.barh .. "|Vitality" .. styles.bard1 .. bar(styles.barc, prop.vit, 2, 99) .. styles.barh .. "|Agility" .. styles.bard1 .. bar(styles.barc, prop.agl, 2, 99) .. styles.barh .. "|Luck" .. styles.bard1 .. bar(styles.barc, prop.luc, 2, 99) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px outset #ddbf77;border-radius:3px"></div>' .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px outset #85bd64;border-radius:3px"></div>' .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. aligncat(prop.alignment, gamen)
    end
    if gameg == "smt4" or gameg == "smt4a" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        styles.h = '\n!style="color:' .. getGames.games[gameg].colorbg2 .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].font2 .. '">Level</span>' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].hp .. '">HP</span>' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].mp .. '">MP</span>' .. styles.bart11 .. "387px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 1.5, 200) .. styles.barh .. "|Dexterity" .. styles.bard2 .. bar(styles.barc, prop.dex, 1.5, 200) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 1.5, 200) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 1.5, 200) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 1.5, 200) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}" .. bossdemoncat(prop.boss, gamen)
        if not prop.phys then prop.phys = "-" end
        if not prop.gun then prop.gun = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.curse then prop.curse = "-" end
        styles.h = '\n!style="background:' .. getGames.games[gameg].colorbg2
        local statlow = '\n|style="background:' .. getGames.games[gameg].colorbg2
        if gameg == "smt4a" then
            styles.h = styles.h .. ';color:#fff" '
            statlow = statlow .. ';color:#fff"|'
        elseif gameg == "smt4" then
            styles.h = styles.h .. ';color:#000" '
            statlow = statlow .. ';color:#000"|'
        end
        result = result .. styles.table2 .. styles.h .. 'width=12.5% title="Physical"|[[File:PhysIcon_SMTIV.png|alt=Physical|Physical|link=Physical Skills]] Phys' .. styles.h .. 'width=12.5% title="Gun"|[[File:GunIcon2.png|alt=Gun|Gun|link=Gun Skills]] Gun' .. styles.h .. 'width=12.5% title="Fire"|[[File:FireIcon_SMTIV.png|alt=Fire|Fire|link=Fire Skills]] Fire' .. styles.h .. 'width=12.5% title="Ice"|[[File:IceIcon_SMTIV.png|alt=Ice|Ice|link=Ice Skills]] Ice' .. styles.h .. 'width=12.5% title="Electricity"|[[File:ElecIcon_SMTIV.png|alt=Electricity|Electricity|link=Electric Skills]] Elec' .. styles.h .. 'width=12.5% title="Force"|[[File:ForceIcon.png|alt=Force|Force|link=Wind Skills]] Force' .. styles.h .. 'width=12.5% title="Light"|[[File:ExpelIcon_SMTIV.png|alt=Light|Light|link=Expel Skills]] Light' .. styles.h .. 'width=12.5% title="Dark"|[[File:CurseIcon_SMTIV.png|alt=Dark|Dark|link=Death Skills]] Dark\n|-\n' .. statlow .. prop.phys .. statlow .. prop.gun .. statlow .. prop.fire .. statlow .. prop.ice .. statlow .. prop.elec .. statlow .. prop.force .. statlow .. prop.expel .. statlow .. prop.curse .. "\n|}"
        styles.h = '\n!style="background: ' .. getGames.games[gameg].colorbg .. ";color: " .. getGames.games[gameg].font .. '" '
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
            prop.specialty = mw.text.split(prop.specialty, "\n")
            for k1, v1 in ipairs(prop.specialty) do
                for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do
                    if k2 > 2 then
                        break
                    elseif k2 % 2 == 1 then -- skill type
                        prop.skilltypes = {
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
                        result = result .. '<span style="white-space:nowrap">' .. prop.skilltypes[v2:lower()]
                    elseif k2 % 2 == 0 then -- modifier
                        if string.sub(v2, 1, 1) == "+" then
                            result = result .. ' <span style="color:#5f5">' .. v2 .. "</span></span>"
                        else
                            result = result .. ' <span style="color:#f55">' .. v2 .. "</span></span>"
                        end
                        if next(prop.specialty, k1) then -- add dot separator if it's not the last entry
                            result = result .. " · "
                            if k1 == 6 then result = result .. "<br/>" end
                        end
                    end
                end
            end
            result = result .. "\n|}"
        end
    end
    if gameg == "smt5" or gameg == "smt5v" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        styles.h = '\n!style="color:' .. getGames.games[gameg].colorbg2 .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].font2 .. '">Level</span>' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].hp .. '">HP</span>' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].mp .. '">MP</span>' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 100) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 100) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 2.4, 100) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 100) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 100) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. aligncat(prop.alignment, gamen)
        if not prop.phys then prop.phys = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.curse then prop.curse = "-" end
        styles.h = '\n!style="background:' .. getGames.games[gameg].colorbg2 .. ';color:#fff" '
        local statlow = '\n|style="background:' .. getGames.games[gameg].colorbg2 .. ';color:#fff"|'
        result = result .. styles.table2 .. styles.h .. 'width=14.8% title="Physical"|[[File:PhysIcon_SMTV.png|24px|alt=Physical|Physical|link=Physical Skills]] [[Physical Skills|<span style="color:white">Phys</span>]]' .. styles.h .. 'width=14.2% title="Fire"|[[File:FireIcon_SMTV.png|24px|alt=Fire|Fire|link=Fire Skills]] [[Fire Skills|<span style="color:white">Fire</span>]]' .. styles.h .. 'width=14.2% title="Ice"|[[File:IceIcon_SMTV.png|24px|Ice|link=Ice Skills]] [[Ice Skills|<span style="color:white">Ice</span>]]' .. styles.h .. 'width=14.2% title="Electricity"|[[File:ElecIcon_SMTV.png|24px|alt=Electricity|Electricity|link=Electric Skills]] [[Electric Skills|<span style="color:white">Elec</span>]]' .. styles.h .. 'width=14.2% title="Force"|[[File:ForceIcon_SMTV.png|24px|alt=Force|Force|link=Force Skills]] [[Force Skills|<span style="color:white">Force</span>]]' .. styles.h .. 'width=14.2% title="Light"|[[File:LightIcon_SMTV.png|24px|alt=Light|Light|link=Light Skills (Affinity)]] [[Light Skills (Affinity)|<span style="color:white">Light</span>]]' .. styles.h .. 'width=14.2% title="Dark"|[[File:DarkIcon_SMTV.png|24px|Dark|link=Dark Skills (Affinity)]] [[Dark Skills (Affinity)|<span style="color:white">Dark</span>]]\n|-\n' .. statlow .. prop.phys .. statlow .. prop.fire .. statlow .. prop.ice .. statlow .. prop.elec .. statlow .. prop.force .. statlow .. prop.expel .. statlow .. prop.curse .. "\n|}"
        styles.h = '\n!style="background: ' .. getGames.games[gameg].colorbg .. ";color: " .. getGames.games[gameg].font .. '" '
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
            styles.h = '\n!style="background:' .. getGames.games[gameg].colorbg2 .. ';color:#fff" '
            result = result .. styles.table2h .. '"' .. styles.h .. "colspan=4|[[Skill Affinities|" .. styles.spanc .. "Skill Potential</span>]]"
            prop.specialty = mw.text.split(prop.specialty, "\n")
            prop.skilltypes = {
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
            local restemp
            for k1, v1 in ipairs(prop.specialty) do
                for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do
                    if k2 > 2 then
                        break
                    elseif k2 % 2 == 1 then -- skill type
                        restemp = v2:lower()
                    elseif k2 % 2 == 0 then -- modifier
                        if string.sub(v2, 1, 1) == "+" then
                            prop.skilltypes[restemp] = ' <span style="color:#5f5">' .. v2 .. "</span></span>"
                        else
                            prop.skilltypes[restemp] = ' <span style="color:#f55">' .. v2 .. "</span></span>"
                        end
                    end
                end
            end
            result = result .. styles.table2 .. styles.cost3 .. 'width=10% title="Physical"|[[File:PhysIcon_SMTV.png|24px|alt=Physical|Physical|link=Physical Skills]]<br>[[Physical Skills|<span style="color:white">Phys</span>]]' .. styles.cost3 .. 'width=9% title="Fire"|[[File:FireIcon_SMTV.png|24px|alt=Fire|Fire|link=Fire Skills]]<br>[[Fire Skills|<span style="color:white">Fire</span>]]' .. styles.cost3 .. 'width=9% title="Ice"|[[File:IceIcon_SMTV.png|24px|alt=Ice|Ice|link=Ice Skills]] <br>[[Ice Skills|<span style="color:white">Ice</span>]]' .. styles.cost3 .. 'width=9% title="Electricity"|[[File:ElecIcon_SMTV.png|24px|alt=Electricity|Electricity|link=Electric Skills]]<br>[[Electric Skills|<span style="color:white">Elec</span>]]' .. styles.cost3 .. 'width=9% title="Force"|[[File:ForceIcon_SMTV.png|24px|alt=Force|Force|link=Force Skills]]<br>[[Force Skills|<span style="color:white">Force</span>]]' .. styles.cost3 .. 'width=9% title="Light"|[[File:LightIcon_SMTV.png|24px|alt=Light|Light|link=Light Skills (Affinity)]]<br>[[Light Skills (Affinity)|<span style="color:white">Light</span>]]' .. styles.cost3 .. 'width=9% title="Dark"|[[File:DarkIcon_SMTV.png|24px|alt=Dark|Dark|link=Dark Skills (Affinity)]]<br>[[Dark Skills (Affinity)|<span style="color:white">Dark</span>]]' .. styles.cost3 .. 'width=9% title="Almighty"|[[File:AlmightyIcon_SMTV.png|24px|alt=Almighty|Almighty|link=Almighty Skills]]<br>[[Almighty Skills|<span style="color:white">Almi.</span>]]' .. styles.cost3 .. 'width=9% title="Ailment"|[[File:AilmentIcon_SMTV.png|24px|alt=Ailment|Ailment|link=Ailment Skills]]<br>[[Ailment Skills|<span style="color:white">Ailm.</span>]]' .. styles.cost3 .. 'width=9% title="Healing"|[[File:HealIcon_SMTV.png|24px|alt=Healing|Healing|link=Healing Skills]]<br>[[Healing Skills|<span style="color:white">Heal.</span>]]' .. styles.cost3 .. 'width=9% title="Support"|[[File:SupportIcon_SMTV.png|24px|alt=Support|Support|link=Support Skills]]<br>[[Support Skills|<span style="color:white">Supp.</span>]]\n|-\n' .. styles.cost3 .. "width=9%|" .. prop.skilltypes["phys"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["fire"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["ice"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["elec"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["force"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["light"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["dark"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["almighty"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["ailment"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["heal"] .. styles.cost3 .. "width=9%|" .. prop.skilltypes["support"] .. "\n|}" .. "\n|}"
        end
    end
    if gameg == "ldx2" then
        if not prop.hp then prop.hp = "?" end
        if not prop.rarity then prop.rarity = string.rep("★", math.ceil((tonumber(prop.level) + 1) / 20)) end

        styles.h = '\n!style="color:' .. getGames.games[gameg].colorbg .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style"color:' .. getGames.games[gameg].font .. '">Rarity</span>' .. styles.h .. '"width=45px|<span style="color:' .. getGames.games[gameg].font .. '">Grade</span>' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].hp .. '">HP</span>' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. '\n|+<span style="font-weight:bold">6★ Stats</span>' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 1, 255) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 1, 255) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 1, 255) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 1, 255) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 1, 255) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.rarity .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. rarityCategory(prop.rarity, gamen)
        if not prop.seealso then prop.seealso = mw.title.getCurrentTitle().text end
        result = result .. styles.table2 .. styles.h .. 'title="Physical Attack"|Phys ATK' .. styles.h .. 'title="Physical Defense"|Phys DEF' .. styles.h .. 'title="Magical Attack"|Mag ATK' .. styles.h .. 'title="Magical Defense"|Mag DEF' .. styles.h .. "|See Also" .. "\n|-" .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.matk .. styles.statlow .. prop.mdef .. styles.statlow .. "[https://dx2wiki.com/index.php/" .. string.gsub(prop.seealso, " ", "_") .. "]\n|}"
        if not prop.phys then prop.phys = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.dark then prop.dark = "-" end
        styles.h = '\n!style="background:' .. getGames.games[gameg].colorbg .. ';color:#fff" '
        local statlow = '\n|style="background:' .. getGames.games[gameg].colorbg .. ';color:#fff"|'
        result = result .. styles.table2 .. styles.h .. 'width=14.8% title="Physical"|[[File:SMT_Dx2_Physical_Skill_Icon.png|24px|alt=Physical|Physical|link=Physical Skills]] [[Physical Skills|<span style="color:white">Phys</span>]]' .. styles.h .. 'width=14.2% title="Fire"|[[File:SMT_Dx2_Fire_Skill_Icon.png|24px|alt=Fire|Fire|link=Fire Skills]] [[Fire Skills|<span style="color:white">Fire</span>]]' .. styles.h .. 'width=14.2% title="Ice"|[[File:SMT_Dx2_Ice_Skill_Icon.png|24px|Ice|link=Ice Skills]] [[Ice Skills|<span style="color:white">Ice</span>]]' .. styles.h .. 'width=14.2% title="Electricity"|[[File:SMT_Dx2_Electricity_Skill_Icon.png|24px|alt=Electricity|Electricity|link=Electric Skills]] [[Electric Skills|<span style="color:white">Elec</span>]]' .. styles.h .. 'width=14.2% title="Force"|[[File:SMT_Dx2_Force_Skill_Icon.png|24px|alt=Force|Force|link=Force Skills]] [[Force Skills|<span style="color:white">Force</span>]]' .. styles.h .. 'width=14.2% title="Light"|[[File:SMT_Dx2_Light_Skill_Icon.png|24px|alt=Light|Light|link=Light Skills (Affinity)]] [[Light Skills (Affinity)|<span style="color:white">Light</span>]]' .. styles.h .. 'width=14.2% title="Dark"|[[File:SMT_Dx2_Dark_Skill_Icon.png|24px|Dark|link=Dark Skills (Affinity)]] [[Dark Skills (Affinity)|<span style="color:white">Dark</span>]]\n|-\n' .. statlow .. prop.phys .. statlow .. prop.fire .. statlow .. prop.ice .. statlow .. prop.elec .. statlow .. prop.force .. statlow .. prop.expel .. statlow .. prop.dark .. "\n|}"
    end
    if gameg == "lb1" or gameg == "lb2" or gameg == "lb3" or gameg == "lbs" then
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
    end
    if gameg == "ab" then
        if not prop.hp then prop.hp = "?" end
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Rank" .. styles.h .. "|HP" .. styles.h .. "|PP" .. styles.h .. "|Move" .. styles.h .. "|Power" .. styles.h .. 'title="Defensive Power"|<abbr>Might</abbr>' .. styles.h .. "|Magic" .. styles.h .. "|Speed" .. styles.h .. "|Luck\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.move .. styles.statlow .. prop.power .. styles.statlow .. prop.might .. styles.statlow .. prop.magic .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}" .. bossdemoncat(prop.boss, gamen)
        if prop.weapon ~= "" then result = result .. styles.table2 .. styles.h .. "width=80px|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Weapon</span>]]" .. styles.effect1 .. prop.weapon .. "\n|}" end
        if prop.tech then
            prop.techc = data.skills[prop.tech]
            if not prop.techc then
                alias = data.aliases[prop.tech]
                if alias then
                    prop.tech = alias
                    prop.techc = data.skills[prop.tech]
                else
                    prop.techc.effect = noskill(prop.tech, gamed)
                end
            end
            result = result .. styles.table2 .. styles.h .. "colspan=5|[[List of " .. gamegn .. " Skills#Techniques|" .. styles.spanc .. "Technique</span>]]" .. styles.skill .. "Technique" .. styles.skillc .. "Cost" .. styles.skillc .. "Range" .. styles.skillc .. "Target" .. styles.skillc .. "Description" .. styles.skill .. prop.tech .. styles.cost1 .. prop.techc.cost .. styles.cost1 .. prop.techc.range .. styles.cost1 .. prop.techc.target .. styles.effect1 .. prop.techc.effect .. "\n|}"
        end
    end
    if gameg == "majin1" or gameg == "majin2" or gameg == "ronde" then
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
    end
    if gameg == "smtds" or gameg == "sh" then
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
    end

    if gameg == "sh2" then
        if not prop.hp then prop.hp = "?" end
        if prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        styles.h = '\n!style="color:' .. getGames.games[gameg].colorbg2 .. ';background:#000" '
        result = result .. styles.table2 .. styles.h .. '|[[Race and species|<span style="color:#fff">Race</span>]]' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].font2 .. '">Level</span>' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].hp .. '">HP</span>' .. styles.h .. 'width=45px|<span style="color:' .. getGames.games[gameg].mp .. '">MP</span>' .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 100) .. styles.barh .. "|Intelligence" .. styles.bard2 .. bar(styles.barc, prop.int, 2.4, 100) .. styles.barh .. "|Vitality" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 100) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 100) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 100) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}" .. bossdemoncat(prop.boss, gamen) .. aligncat(prop.alignment, gamen)
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
        styles.h = '\n!style="background: ' .. getGames.games[gameg].colorbg .. ";color: " .. getGames.games[gameg].font .. '" '
        if prop.gift then result = result .. styles.table2 .. styles.h .. "width=70px|[[Gift|" .. styles.spanc .. "Gift</span>]]" .. styles.order .. prop.gift .. "\n|}" end
    end
    if gameg == "raidou1" or gameg == "raidou2" then
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
    end
    if gameg == "giten" then
        if not prop.condition then prop.condition = "" end
        if not prop.equiptype then prop.equiptype = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Alignment" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Cost Point. Magnetite per 10 steps"|<abbr>CP</abbr>' .. styles.h .. "|[[Equip Type|" .. styles.spanc .. "Equip Type</span>]]\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.alignment .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.condition .. styles.statlow .. prop.equiptype .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Intuition" .. styles.h .. "|Will Power" .. styles.h .. "|Magic" .. styles.h .. "|Intelligence" .. styles.h .. "|Divine Protection\n|-" .. styles.statlow .. prop.itin .. styles.statlow .. prop.wllpow .. styles.statlow .. prop.magic .. styles.statlow .. prop.int .. styles.statlow .. prop.dvnprt .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "|Strength" .. styles.h .. "|Stamina" .. styles.h .. "|Agility" .. styles.h .. "|Dexterity" .. styles.h .. "|Charm\n|-" .. styles.statlow .. prop.str .. styles.statlow .. prop.vit .. styles.statlow .. prop.agl .. styles.statlow .. prop.dex .. styles.statlow .. prop.chm .. "\n|}" .. aligncat(prop.alignment, gamen) .. bossdemoncat(prop.boss, gamegn)
    end
    if gameg == "p1" then
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
    end
    if (gameg == "p2is" or gameg == "p2ep" or gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x") and prop.quote then result = result .. styles.table2b .. styles.quote .. 'font-style:italic"|' .. string.gsub(prop.quote, "!!", "‼") .. "\n|}" end -- replace exclamation mark otherwise it will be interpreted as wiki table seperator.
    if gameg == "p2is" or gameg == "p2ep" then
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
    end
    if (gameg == "p3" or gameg == "p3re") or gameg == "p4" or (gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x") then
        local has_arcana = not ((gameg == "p5" or gameg == "p5r" or gameg == "p5x") and not hasFilledValue(prop.arcana))
        local has_stat_bars = hasAnyStatBarValue(prop, { "str", "magic", "vit", "agl", "luc" })
        local stat_table = styles.table2
        local stat_categories = ""
        if has_stat_bars then
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
            stat_table = stat_table .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 2.4, 99) .. styles.barh .. "|Endurance" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-"
            if has_arcana then
                stat_table = stat_table .. styles.statlow .. getArcana(prop.arcana, gameg, gamegn)
            end
            stat_table = stat_table .. styles.statlow .. prop.level
            if prop.hp then stat_table = stat_table .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].hp2 .. '"></div>' end
            if prop.mp then stat_table = stat_table .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].mp2 .. '"></div>' end
            if prop.maxhp then stat_table = stat_table .. styles.statlow .. prop.maxhp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].hp2 .. '"></div>' end
            if prop.maxmp then stat_table = stat_table .. styles.statlow .. prop.maxmp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].mp2 .. '"></div>' end
            if gameg == "p5s" and prop.stagger then stat_table = stat_table .. styles.statlow .. prop.stagger end
            if prop.traits then stat_table = stat_table .. styles.statlow .. prop.traits end
        else
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
            stat_table = stat_table .. "\n|-"
            if has_arcana then
                stat_table = stat_table .. styles.statlow .. getArcana(prop.arcana, gameg, gamegn)
            end
            stat_table = stat_table .. styles.statlow .. prop.level
            if prop.hp then stat_table = stat_table .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].hp2 .. '"></div>' end
            if prop.mp then stat_table = stat_table .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].mp2 .. '"></div>' end
            if prop.maxhp then stat_table = stat_table .. styles.statlow .. prop.maxhp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].hp2 .. '"></div>' end
            if prop.maxmp then stat_table = stat_table .. styles.statlow .. prop.maxmp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].mp2 .. '"></div>' end
            if gameg == "p5s" and prop.stagger then stat_table = stat_table .. styles.statlow .. prop.stagger end
            if prop.traits then stat_table = stat_table .. styles.statlow .. prop.traits end
        end
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
        if gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
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
            pending_top_stats = stat_table
            pending_top_stats_categories = stat_categories
        end
    end
    if gameg == "metaphor" then
        result = result .. styles.table2
        if not prop.hp then result = result .. styles.h .. "|[[Archetype|" .. styles.spanc .. "Lineage</span>]]" end
        result = result .. styles.h .. 'width="50px"|[[Level (stat)|' .. styles.spanc .. "Rank</span>]]"
        if prop.hp then result = result .. styles.h .. 'width="40px"|HP' end
        if prop.mp then result = result .. styles.h .. 'width="40px"|MP' end
        if prop.maxhp then result = result .. styles.h .. 'width="40px"|HP' end
        if prop.maxmp then result = result .. styles.h .. 'width="40px"|MP' end
        result = result .. styles.bart11 .. "324px" .. styles.bart12 .. '0.8"' .. styles.barh .. "|Strength" .. styles.bard2 .. bar(styles.barc, prop.str, 2.4, 99) .. styles.barh .. "|Magic" .. styles.bard2 .. bar(styles.barc, prop.magic, 2.4, 99) .. styles.barh .. "|Endurance" .. styles.bard2 .. bar(styles.barc, prop.vit, 2.4, 99) .. styles.barh .. "|Agility" .. styles.bard2 .. bar(styles.barc, prop.agl, 2.4, 99) .. styles.barh .. "|Luck" .. styles.bard2 .. bar(styles.barc, prop.luc, 2.4, 99) .. "\n|}\n|-"
        if not prop.hp then result = result .. styles.statlow .. "[[" .. prop.archetype .. " (Archetype)|" .. prop.archetype .. "]]" end
        result = result .. styles.statlow .. prop.level
        if prop.hp then result = result .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].hp2 .. '"></div>' end
        if prop.mp then result = result .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].mp2 .. '"></div>' end
        if prop.maxhp then result = result .. styles.statlow .. prop.maxhp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].hp2 .. '"></div>' end
        if prop.maxmp then result = result .. styles.statlow .. prop.maxmp .. '<div style="position:relative;top:-4px;border:2.5px solid ' .. getGames.games[gameg].mp2 .. '"></div>' end
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
    end
    if gameg == "pq" or gameg == "pq2" then
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
    end
    if gameg == "cs" then
        if not prop.mp then prop.mp = "?" end
        if not prop.mp then prop.mp = "?" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. 'title="Strength"|St' .. styles.h .. 'title="Endurance"|En' .. styles.h .. 'title="Magic"|Ma' .. styles.h .. 'title="Agility"|Ag\n|-\n' .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.str .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.agl .. "\n|}" .. cate(getGames.games[gameg].name2 .. " Demons")
    end
    if gameg == "ddsaga1" or gameg == "ddsaga2" then
        if gameg == "ddsaga2" and prop.boss then
            prop.mp = "∞"
        elseif not prop.mp then
            prop.mp = "?"
        end
        if not prop.normal then prop.normal = "-" end
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Drops\n|-\n" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.normal .. "\n|}" .. bossdemoncat(prop.boss, gamen)
    end
    if gameg == "desu1" or gameg == "desu2" then
        result = result .. styles.table2 .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race</span>]]" .. styles.h .. "width=10%|Level" .. styles.h .. "width=10%|HP" .. styles.h .. "width=10%|MP" .. styles.bart11 .. "315px" .. styles.bart12 .. '1"' .. styles.barh .. "|Strength" .. styles.bard1 .. bar(styles.barc, prop.str, 6, 40) .. styles.barh .. "|Magic" .. styles.bard1 .. bar(styles.barc, prop.magic, 6, 40) .. styles.barh .. "|Vitality" .. styles.bard1 .. bar(styles.barc, prop.vit, 6, 40) .. styles.barh .. "|Agility" .. styles.bard1 .. bar(styles.barc, prop.agl, 6, 40) .. "\n|}\n|-" .. styles.statlow .. getRace(prop.race, gameg) .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. getGames.games[gameg].hp2 .. ';border-radius:3px"></div>' .. styles.statlow .. prop.mp .. '<div style="position:relative;top:-4px;border:2.5px outset ' .. getGames.games[gameg].mp2 .. ';border-radius:3px"></div>\n|}'
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
    end
    if gameg == "dcbrb" then
        if not prop.xp then prop.xp = "" end
        if not prop.etype then prop.etype = "" end
        result = result .. styles.table2 .. styles.h .. "|Class" .. styles.h .. "|Type" .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Exp\n|-" .. styles.statlow .. prop.class .. styles.statlow .. prop.etype .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.xp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "width=16.67% |Attack" .. styles.h .. "width=16.67% |Guard" .. styles.h .. "width=16.67% |Magic" .. styles.h .. "width=16.67% |M Guard" .. styles.h .. "width=16.67% |Speed" .. styles.h .. "width=16.67% |Luck\n|-\n" .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
        if prop.boss or race == "Boss" then
            result = result .. cate(gamen .. " Bosses")
        else
            if game == "dcbrp" then
                result = result .. cate("Devil Children PS demons")
            elseif game == "dcwb" then
                result = result .. cate(gamen .. " Demons")
            elseif gameg == "dcbrb" then
                result = result .. cate(getGames.games[gameg].name1 .. " Demons") .. cate(getGames.games[gameg].name2 .. " Demons")
            end
        end
        result = result .. cate(prop.race .. " Race")
    end
    if gameg == "childred" or gameg == "childps" or gameg == "childwhite" or gameg == "childfire" then
        if not prop.xp then prop.xp = "" end
        if not prop.etype then prop.etype = "" end
        result = result .. styles.table2 .. styles.h .. "|Class" .. styles.h .. "|Type" .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Race]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Exp\n|-" .. styles.statlow .. prop.class .. styles.statlow .. prop.etype .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.xp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "width=16.67% |Attack" .. styles.h .. "width=16.67% |Guard" .. styles.h .. "width=16.67% |Magic" .. styles.h .. "width=16.67% |M Guard" .. styles.h .. "width=16.67% |Speed" .. styles.h .. "width=16.67% |Luck\n|-\n" .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
    end
    if gameg == "childlight" then
        if not prop.xp then prop.xp = "" end
        result = result .. styles.table2 .. styles.h .. "|Class" .. styles.h .. "|Element" .. styles.h .. "|[[Race and species|" .. styles.spanc .. "Type]]" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP" .. styles.h .. "|Exp\n|-" .. styles.statlow .. prop.class .. styles.statlow .. prop.etype .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. styles.statlow .. prop.xp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. 'width=16.67% title="Attack Power"|ATK' .. styles.h .. 'width=16.67% title="Defense"|DEF' .. styles.h .. 'width=16.67% title="Magic"|MGC' .. styles.h .. 'width=16.67% title="Resistance"|RES' .. styles.h .. 'width=16.67% title="Speed"|SPD' .. styles.h .. 'width=16.67% title="Luck"|LCK\n|-\n' .. styles.statlow .. prop.atk .. styles.statlow .. prop.def .. styles.statlow .. prop.magic .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.luc .. "\n|}"
        if prop.boss or race == "Boss" then
            if gameg == "childlight" then
                result = result .. cate(getGames.games[gameg].name3 .. " Bosses")
            else
                result = result .. cate(gamen .. " Bosses")
            end
        else
            if game == "childblack" or gameg == "childps" then
                result = result .. cate("Devil Children PS demons")
            elseif gameg == "childwhite" then
                result = result .. cate(gamen .. " Demons")
            elseif gameg == "childred" then
                result = result .. cate(getGames.games[gameg].name1 .. " Demons") .. cate(getGames.games[gameg].name2 .. " Demons")
            elseif gameg == "childfire" then
                result = result .. cate(getGames.games[gameg].name1 .. " Demons") .. cate(getGames.games[gameg].name2 .. " Demons")
            elseif gameg == "childlight" then
                result = result .. cate(getGames.games[gameg].name1 .. " Demons") .. cate(getGames.games[gameg].name2 .. " Demons")
            end
        end
        result = result .. cate(prop.race .. " Type")
    end
    if gameg == "childmessiah" then
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
        else
            if not data.skills[prop.spell] then
                prop.spell = prop.spell
            else
                prop.spell = '<abbr title="' .. data.skills[prop.spell].effect .. '">' .. prop.spell .. "</abbr>"
            end
        end
        if not prop.spell then prop.spell = prop.spell end
        result = result .. styles.table2 .. styles.h .. "|Number" .. styles.h .. "|Element" .. styles.h .. "|Weakness" .. styles.h .. "|Type" .. styles.h .. "|Level" .. styles.h .. "|HP" .. styles.h .. "|MP\n|-" .. styles.statlow .. prop.number .. styles.statlow .. prop.element .. styles.statlow .. prop.weak .. styles.statlow .. prop.race .. styles.statlow .. prop.level .. styles.statlow .. prop.hp .. styles.statlow .. prop.mp .. "\n|}"
        result = result .. styles.table2 .. styles.h .. 'title="Attack"|ATK' .. styles.h .. 'title="Magic"|MGC' .. styles.h .. 'title="Defense"|DEF' .. styles.h .. 'title="Resistance"|RES' .. styles.h .. 'title="Speed"|SPD' .. styles.h .. "|Quick" .. styles.h .. "|Call" .. styles.h .. "|Spell\n|-" .. styles.statlow .. prop.atk .. styles.statlow .. prop.magic .. styles.statlow .. prop.def .. styles.statlow .. prop.res .. styles.statlow .. prop.agl .. styles.statlow .. prop.quick .. styles.statlow .. prop.call .. styles.statlow .. prop.spell .. "\n|}" .. cate(prop.race .. " Type") .. bossdemoncat(prop.boss, getGames.games[game].name2)
    end
    if gameg == "smtsj" then
        if not prop.noa then prop.noa = "-" end
        if not prop.phys then prop.phys = "-" end
        if not prop.gun then prop.gun = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.wind then prop.wind = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.curse then prop.curse = "-" end
        if not prop.alm then prop.alm = "-" end
        if not prop.poison then prop.poison = "-" end
        if not prop.paralyze then prop.paralyze = "-" end
        if not prop.stone then prop.stone = "-" end
        if not prop.strain then prop.strain = "-" end
        if not prop.sleep then prop.sleep = "-" end
        if not prop.charm then prop.charm = "-" end
        if not prop.mute then prop.mute = "-" end
        if not prop.fear then prop.fear = "-" end
        if not prop.bomb then prop.bomb = "-" end
        if not prop.rage then prop.rage = "-" end
        result = result .. styles.table2 .. styles.h .. "|Attack Type" .. styles.h .. 'width=7% title="Physical"|[[File:PhysIcon.png|alt=Physical|Physical|link=Physical Skills]]' .. styles.h .. 'width=7% title="Gun"|[[File:GunIcon.png|alt=Gun|Gun|link=Gun Skills]]' .. styles.h .. 'width=7% title="Fire"|[[File:FireIcon.png|alt=Fire|Fire|link=Fire Skills]]' .. styles.h .. 'width=7% title="Ice"|[[File:IceIcon.png|alt=Ice|Ice|link=Ice Skills]]' .. styles.h .. 'width=7% title="Electricity"|[[File:ElecIcon.png|alt=Electricity|Electricity|link=Electric Skills]]' .. styles.h .. 'width=7% title="Wind"|[[File:WindIcon.png|alt=Wind|Wind|link=Wind Skills]]' .. styles.h .. 'width=7% title="Expel"|[[File:ExpelIcon.png|alt=Expel|Expel|link=Expel Skills]]' .. styles.h .. 'width=7% title="Curse"|[[File:CurseIcon.png|alt=Curse|Curse|link=Death Skills]]' .. styles.h .. 'width=7% title="Almighty"|[[File:AlmightyIcon.png|alt=Almighty|Almighty|link=Almighty Skills]]\n|-\n'
        result = result .. styles.statlow .. prop.noa .. styles.statlow .. prop.phys .. styles.statlow .. prop.gun .. styles.statlow .. prop.fire .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec .. styles.statlow .. prop.wind .. styles.statlow .. prop.expel .. styles.statlow .. prop.curse .. styles.statlow .. prop.alm .. "\n|}"
        result = result .. styles.table2 .. styles.h .. "width=10%|Poison" .. styles.h .. "width=10%|Paralyze" .. styles.h .. "width=10%|Stone" .. styles.h .. "width=10%|Strain" .. styles.h .. "width=10%|Sleep" .. styles.h .. "width=10%|Charm" .. styles.h .. "width=10%|Mute" .. styles.h .. "width=10%|Fear" .. styles.h .. "width=10%|Bomb" .. styles.h .. "width=10%|Rage\n|-\n"
        result = result .. styles.statlow .. prop.poison .. styles.statlow .. prop.paralyze .. styles.statlow .. prop.stone .. styles.statlow .. prop.strain .. styles.statlow .. prop.sleep .. styles.statlow .. prop.charm .. styles.statlow .. prop.mute .. styles.statlow .. prop.fear .. styles.statlow .. prop.bomb .. styles.statlow .. prop.rage .. "\n|}"
    end
    if gameg == "desu1" or gameg == "desu2" then
        if not prop.racial then prop.racial = "-" end
        if not prop.phys then prop.phys = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.force then prop.force = "-" end
        if not prop.mystic then prop.mystic = "-" end
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
            if not prop.sword then prop.sword = "-" end
            if not prop.strike then prop.strike = "-" end
            if not prop.pierce then prop.pierce = "-" end
            if not prop.phys then prop.phys = "-" end
            if not prop.gun then prop.gun = "-" end
            if not prop.fire then prop.fire = "-" end
            if not prop.ice then prop.ice = "-" end
            if not prop.elec then prop.elec = "-" end
            if not prop.wind then prop.wind = "-" end
            if not prop.psy then prop.psy = "-" end
            if not prop.nuclear then prop.nuclear = "-" end
            if not prop.expel then prop.expel = "-" end
            if not prop.dark then prop.dark = "-" end
            if not prop.alm then prop.alm = "-" end
            if not prop.down then prop.down = "-" end
            if not prop.dizzy then prop.dizzy = "-" end
            if not prop.freeze then prop.freeze = "?" end
            if not prop.paralyze then prop.paralyze = "?" end
            if not prop.poison then prop.poison = "?" end
            if not prop.charm then prop.charm = "?" end
            if not prop.distress then prop.distress = "?" end
            if not prop.panic then prop.panic = "?" end
            if not prop.fear then prop.fear = "?" end
            if not prop.rage then prop.rage = "?" end
            if gameg == "ronde" then
                affinity_table = affinity_table .. styles.h .. "width=11%|[[Slash Skills|" .. styles.spanc .. "Slash</span>]]" .. styles.h .. "width=11%|[[Strike Skills|" .. styles.spanc .. "Strike</span>]]" .. styles.h .. "width=11%|[[Ranged Skills|" .. styles.spanc .. "Ranged</span>]]" .. styles.h .. "width=11%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=11%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=11%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=11%|[[Light Skills|" .. styles.spanc .. "Light</span>]]" .. styles.h .. "width=11%|[[Dark Skills|" .. styles.spanc .. "Dark</span>]]" .. styles.h .. 'title="Almighty" width=12%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            elseif gameg == "p3" or gameg == "p3re" then
                affinity_table = affinity_table .. styles.h .. "width=10%|[[Slash Skills|" .. styles.spanc .. "Slash</span>]]" .. styles.h .. "width=10%|[[Strike Skills|" .. styles.spanc .. "Strike</span>]]" .. styles.h .. "width=10%|[[Pierce Skills|" .. styles.spanc .. "Pierce</span>]]" .. styles.h .. "width=10%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=10%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=10%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=10%|[[Wind Skills|" .. styles.spanc .. "Wind</span>]]" .. styles.h .. "width=10%|[[Light Skills (Affinity)|" .. styles.spanc .. "Light</span>]]" .. styles.h .. "width=10%|[[Dark Skills (Affinity)|" .. styles.spanc .. "Dark</span>]]" .. styles.h .. 'title="Almighty" width=10%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            elseif gameg == "p4" then
                affinity_table = affinity_table .. styles.h .. 'title="Physical" width=14%|[[Physical Skills|' .. styles.spanc .. "Phys</span>]]" .. styles.h .. "width=12%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=12%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=12%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=12%|[[Wind Skills|" .. styles.spanc .. "Wind</span>]]" .. styles.h .. "width=12%|[[Light Skills (Affinity)|" .. styles.spanc .. "Light</span>]]" .. styles.h .. "width=12%|[[Dark Skills (Affinity)|" .. styles.spanc .. "Dark</span>]]" .. styles.h .. 'title="Almighty" width=14%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
            elseif gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
                affinity_table = affinity_table .. styles.h .. 'title="Physical" width=9%|[[Physical Skills|' .. styles.spanc .. "Phys</span>]]" .. styles.h .. "width=9%|[[Gun Skills|" .. styles.spanc .. "Gun</span>]]" .. styles.h .. "width=9%|[[Fire Skills|" .. styles.spanc .. "Fire</span>]]" .. styles.h .. "width=9%|[[Ice Skills|" .. styles.spanc .. "Ice</span>]]" .. styles.h .. 'title="Electricity" width=9%|[[Electricity Skills|' .. styles.spanc .. "Elec</span>]]" .. styles.h .. "width=9%|[[Wind Skills|" .. styles.spanc .. "Wind</span>]]" .. styles.h .. 'title="Psychokinesis" widht=9%|[[Psychokinesis Skills|' .. styles.spanc .. "Psy</span>]]" .. styles.h .. 'title="Nuclear" width=9%|[[Nuclear Skills|' .. styles.spanc .. "Nuke</span>]]" .. styles.h .. "width=9%|[[Light Skills (Affinity)|" .. styles.spanc .. "Bless</span>]]" .. styles.h .. "width=9%|[[Dark Skills (Affinity)|" .. styles.spanc .. "Curse</span>]]" .. styles.h .. 'title="Almighty" width=10%|[[Almighty Skills|' .. styles.spanc .. "Almi</span>]]" .. "\n|-\n"
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
            appendTopAffinityTable(affinity_table)
        elseif prop.inherit or prop.resist or prop.block or prop.absorb or prop.reflect or prop.weak then
            local affinity_table = styles.table2
            if not prop.inherit then prop.inherit = "-" end
            if not prop.resist then prop.resist = "-" end
            if not prop.block then prop.block = "-" end
            if not prop.absorb then prop.absorb = "-" end
            if not prop.reflect then prop.reflect = "-" end
            if not prop.weak then
                prop.weak = "-"
            else
                prop.weak = '<span style="color:#f22">' .. prop.weak .. "</span>"
            end
            if gameg ~= "metaphor" then affinity_table = affinity_table .. styles.h .. "|[[Skill Inheritance|" .. styles.spanc .. "Inherit</span>]]" end
            affinity_table = affinity_table .. styles.h .. "|Reflects" .. styles.h .. "|Absorbs" .. styles.h .. "|Block" .. styles.h .. "|Resists" .. styles.h .. "|Weak\n|-\n" .. styles.statlow .. prop.inherit .. styles.statlow .. prop.reflect .. styles.statlow .. prop.absorb .. styles.statlow .. prop.block .. styles.statlow .. prop.resist .. styles.statlow .. prop.weak .. "\n|}"
            appendTopAffinityTable(affinity_table)
        end
    end
    flushPendingTopStats()
    if (gameg == "p2is" or gameg == "p2ep") and (prop.exclusive or prop.traits or prop.convo) then
        result = result .. styles.table2
        if prop.exclusive then result = result .. styles.h .. "width=90px|Exclusive to" .. styles.order .. prop.exclusive end
        if prop.traits then result = result .. styles.h .. "width=50px|[[Personality|" .. styles.spanc .. "Traits</span>]]" .. styles.order .. prop.traits end
        if prop.convo then result = result .. styles.h .. "width=50px|[[Special conversation|" .. styles.spanc .. '<abbr style="border-bottom:1px dotted black;" title="if equipped with this Persona, there is a chance it will talk to this demon if encountered">Ptalk</abbr>]]' .. styles.order .. prop.convo end
        result = result .. "\n|}"
    end
    if (gameg == "p2is" or gameg == "p2ep") and prop.profile then result = result .. styles.table2b .. styles.quote .. '"|' .. string.gsub(prop.profile, "!!", "‼") .. "\n|}" end
    if (gameg == "p3" or gameg == "p3re") and (prop.card or prop.preturn or prop.normal) then
        result = result .. styles.table2
        if prop.card then result = result .. styles.h .. "width=100px|[[Skill Card|" .. styles.spanc .. "Skill Card</span>]]" .. styles.order .. '<abbr title="Portable only">' .. prop.card .. "</abbr>" end
        if prop.preturn then result = result .. styles.h .. "width=100px|[[Heart Item|" .. styles.spanc .. "Heart Item</span>]]" .. styles.order .. prop.preturn end
        if prop.normal then result = result .. styles.h .. "width=100px|[[Battle Drops|" .. styles.spanc .. "Battle Drop</span>]]" .. styles.order .. prop.normal end
        result = result .. "\n|}"
    end
    if gameg == "p3re" and prop.theurgia then
        result = result .. styles.table2
        result = result .. styles.h .. "width=100px|[[Theurgy|" .. styles.spanc .. "Gauge Condition</span>]]" .. styles.order .. prop.theurgia
        result = result .. "\n|}"
    end
    if gameg == "p3re" and prop.ptraits then
        if string.find(prop.ptraits, "\n") then
            local pt_cnt = 0
            for k in string.gmatch(prop.ptraits, "\n") do
                pt_cnt = pt_cnt + 1
            end
            result = result .. styles.table2
            result = result .. styles.h .. 'width=100px rowspan="' .. (pt_cnt + 1) .. '"|[[Theurgy|' .. styles.spanc .. "Characteristics</span>]]" .. styles.order
            for k, v in ipairs(mw.text.split(prop.ptraits, "\n")) do
                if k > 1 then result = result .. styles.order2 end
                local traitLine = mw.text.split(v, "\\"), traitName, traitType
                if #traitLine > 1 then
                    traitName = traitLine[1]
                    traitType = traitLine[2]
                else
                    traitName = v
                    traitType = nil
                end
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
            local traitLine = mw.text.split(prop.ptraits, "\\"), traitName, traitType
            if #traitLine > 1 then
                traitName = traitLine[1]
                traitType = traitLine[2]
            else
                traitName = prop.ptraits
                traitType = nil
            end
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
    if (gameg == "p4") and prop.hp then
        result = result .. styles.table2
        if not prop.xp then prop.xp = "-" end
        if not prop.yen then prop.yen = "-" end
        if not prop.normal then prop.normal = "-" end
        if not prop.rare then prop.rare = "-" end
        result = result .. styles.h .. "|EXP" .. styles.h .. "|Yen" .. styles.h .. "|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Normal Drop</span>]]" .. styles.h .. "|[[List of " .. gamegn .. " Items|" .. styles.spanc .. "Rare Drop</span>]]" .. "\n|-\n"
        result = result .. styles.statlow .. prop.xp .. styles.statlow .. prop.yen .. styles.statlow .. prop.normal .. styles.statlow .. prop.rare
        result = result .. "\n|}"
    end
    if gameg == "p5r" and prop.ptraits then
        if string.find(prop.ptraits, "\\") then
            local pt_cnt = 0
            for k in string.gmatch(prop.ptraits, "\\") do
                pt_cnt = pt_cnt + 1
            end
            result = result .. styles.table2
            result = result .. styles.h .. 'width=100px rowspan="' .. (pt_cnt + 1) .. '"|[[Persona Traits|' .. styles.spanc .. "Persona Trait</span>]]" .. styles.order
            for k, v in ipairs(mw.text.split(prop.ptraits, "\\")) do
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
    if (gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x") and prop.hp then
        local has_drop_row = gameg ~= "p5x" or hasFilledValue(prop.xp) or hasFilledValue(prop.yen) or hasFilledValue(prop.normal) or hasFilledValue(prop.material) or hasFilledValue(prop.drop1) or hasFilledValue(prop.drop2) or hasFilledValue(prop.drop3) or hasFilledValue(prop.card) or hasFilledValue(prop.dropc)
        if has_drop_row then
            result = result .. styles.table2
            if not prop.xp then prop.xp = "-" end
            if not prop.yen then prop.yen = "-" end
            if not prop.normal then prop.normal = "-" end
            if not prop.material then prop.material = prop.normal end
            if not prop.drop1 then prop.drop1 = "-" end
            if not prop.card then prop.card = "-" end
            if not prop.dropc then prop.dropc = prop.card end
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
        if not prop.xp then prop.xp = "-" end
        if not prop.yen then prop.yen = "-" end
        if not prop.normal then prop.normal = "-" end
        result = result .. styles.h .. "|EXP" .. styles.h .. "|Yen" .. styles.h .. "|[[Battle Drops|" .. styles.spanc .. "Battle Drop</span>]]" .. "\n|-\n"
        result = result .. styles.statlow .. prop.xp .. styles.statlow .. prop.yen .. styles.statlow .. prop.normal
        result = result .. "\n|}"
    end
    result = result .. "\n|}"
    -- End of image span.
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
    if gameg == "smtif" and prop.resist then result = result .. styles.table2 .. styles.h .. "width=90px|Resistances" .. styles.order .. prop.resist .. "\n|}" end
    if game == "smtim" then
        if not prop.seealso then prop.seealso = mw.title.getCurrentTitle().text end
        result = result .. styles.table2 .. styles.h .. "width=50px|Features" .. styles.order .. prop.feature .. styles.h .. "width=60px|See also" .. styles.order .. "[https://web.archive.org/web/megaten.sesshou.com/wiki/index.php/" .. string.gsub(prop.seealso, " ", "_") .. "]\n|}"
    end
    if gameg == "p1" and (prop.onehand or prop.twohand or prop.spear or prop.axe or prop.whip or prop.thrown or prop.arrow or prop.fist or prop.handgun or prop.machinegun or prop.shotgun or prop.rifle or prop.tech or prop.rush or prop.fire or prop.ice or prop.wind or prop.earth or prop.elec or prop.nuclear or prop.blast or prop.gravity or prop.expel or prop.miracle or prop.death or prop.curse or prop.nerve or prop.hiero) then
        if not prop.onehand then prop.onehand = "-" end
        if not prop.twohand then prop.twohand = "-" end
        if not prop.spear then prop.spear = "-" end
        if not prop.axe then prop.axe = "-" end
        if not prop.whip then prop.whip = "-" end
        if not prop.thrown then prop.thrown = "-" end
        if not prop.arrow then prop.arrow = "-" end
        if not prop.fist then prop.fist = "-" end
        if not prop.handgun then prop.handgun = "-" end
        if not prop.machinegun then prop.machinegun = "-" end
        if not prop.shotgun then prop.shotgun = "-" end
        if not prop.rifle then prop.rifle = "-" end
        if not prop.tech then prop.tech = "-" end
        if not prop.rush then prop.rush = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.wind then prop.wind = "-" end
        if not prop.earth then prop.earth = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.nuclear then prop.nuclear = "-" end
        if not prop.blast then prop.blast = "-" end
        if not prop.gravity then prop.gravity = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.miracle then prop.miracle = "-" end
        if not prop.death then prop.death = "-" end
        if not prop.curse then prop.curse = "-" end
        if not prop.nerve then prop.nerve = "-" end
        if not prop.hiero then prop.hiero = "-" end
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
        if not prop.resist then prop.resist = "-" end
        if not prop.block then prop.block = "-" end
        if not prop.absorb then prop.absorb = "-" end
        if not prop.reflect then prop.reflect = "-" end
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
        if not prop.sword then prop.sword = "-" end
        if not prop.pierce then prop.pierce = "-" end
        if not prop.strike then prop.strike = "-" end
        if not prop.thrown then prop.thrown = "-" end
        if not prop.rush then prop.rush = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.water then prop.water = "-" end
        if not prop.wind then prop.wind = "-" end
        if not prop.earth then prop.earth = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.nuclear then prop.nuclear = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.dark then prop.dark = "-" end
        if not prop.alm then prop.alm = "-" end
        if not prop.nerve then prop.nerve = "-" end
        if not prop.mind then prop.mind = "-" end
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
        result = result .. styles.h .. 'title="Sword"|Sw' .. styles.h .. prop.name_Rn .. styles.h .. 'title="Strike"|Sk' .. styles.h .. 'title="Thrown"|Th' .. styles.h .. prop.name_Hv .. styles.h .. 'style="background:#8E283D" title="Fire"|' .. prop.Fi .. styles.h .. 'style="background:#8E283D" title="Water"|' .. prop.Wt .. styles.h .. 'style="background:#8E283D" title="Wind"|' .. prop.Wi .. styles.h .. 'style="background:#8E283D" title="Earth"|' .. prop.Er .. styles.h .. 'title="Ice"|Ic' .. styles.h .. prop.name_El .. styles.h .. 'title="Nuclear"|Nc' .. styles.h .. prop.name_Li .. styles.h .. 'title="Dark"|Dk' .. styles.h .. 'title="Almighty"|Al' .. styles.h .. 'title="Nerve"|Nr' .. styles.h .. 'title="Mind"|Mn\n|-\n'
        result = result .. styles.statlow .. prop.sword .. styles.statlow .. prop.pierce .. styles.statlow .. prop.strike .. styles.statlow .. prop.thrown .. styles.statlow .. prop.rush .. styles.statlow .. prop.fire .. styles.statlow .. prop.water .. styles.statlow .. prop.wind .. styles.statlow .. prop.earth .. styles.statlow .. prop.ice .. styles.statlow .. prop.elec .. styles.statlow .. prop.nuclear .. styles.statlow .. prop.expel .. styles.statlow .. prop.dark .. styles.statlow .. prop.alm .. styles.statlow .. prop.nerve .. styles.statlow .. prop.mind .. "\n|}"
    end
    if gameg == "pq" or gameg == "pq2" and (prop.sword or prop.pierce or prop.strike or prop.phys or prop.fire or prop.water or prop.elec or prop.wind or prop.nuclear or prop.psy or prop.expel or prop.dark or prop.alm or prop.ko or prop.sleep or prop.panic or prop.poison or prop.paralyze or prop.down or prop.stbind or prop.mabind or prop.agbind) then
        result = result .. styles.table2
        if not prop.sword then prop.sword = "-" end
        if not prop.pierce then prop.pierce = "-" end
        if not prop.strike then prop.strike = "-" end
        if not prop.phys then prop.phys = "-" end
        if not prop.fire then prop.fire = "-" end
        if not prop.ice then prop.ice = "-" end
        if not prop.elec then prop.elec = "-" end
        if not prop.wind then prop.wind = "-" end
        if not prop.nuclear then prop.nuclear = "-" end
        if not prop.psy then prop.psy = "-" end
        if not prop.expel then prop.expel = "-" end
        if not prop.dark then prop.dark = "-" end
        if not prop.alm then prop.alm = "-" end
        if not prop.sleep then prop.sleep = "-" end
        if not prop.panic then prop.panic = "-" end
        if not prop.poison then prop.poison = "-" end
        if not prop.curse then prop.curse = "-" end
        if not prop.paralyze then prop.paralyze = "-" end
        if not prop.stbind then prop.stbind = "-" end
        if not prop.mabind then prop.mabind = "-" end
        if not prop.agbind then prop.agbind = "-" end
        if not prop.down then prop.down = "-" end
        if not prop.ko then prop.ko = "-" end
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
            result = result .. styles.table2 .. styles.h .. 'title="Sword"|Swd' .. styles.h .. 'title="Havoc"|Hvc' .. styles.h .. 'title="Fire"|Fir' .. styles.h .. 'title="Ice|Ice' .. styles.h .. 'title="Electricity"|Elc' .. styles.h .. 'title="Force|For' .. styles.h .. 'title="Expel"|Exp' .. styles.h .. 'title="Death"|Dth' .. styles.h .. 'title="Mystic"|Mys' .. styles.h .. 'title="Nerve"|Nrv\n|-'
        elseif game == "p1" then
            result = result .. styles.table2 .. '\n!style="background:#a9a9a9" title="Weapons" colspan="8"|\n!title="Firearms" style="background:#898989" colspan="4"|\n!style="background:#a9a9a9" title="Havoc" colspan="2"|\n|-' .. styles.h .. 'title="Weapons"|<abbr title="1-handed Sword">1h</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="2-handed Sword">2h</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Spear">Sp</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Axe">Ax</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Whip">Wp</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Thrown">Th</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Arrows">Ar</abbr>' .. styles.h .. 'title="Weapons"|<abbr title="Fist">Fs</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Handgun">HG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Machinegun">MG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Shotgun">SG</abbr>' .. styles.h .. 'title="Firearms" style="background:#898989;width:7.12%"|<abbr title="Rifle">Ri</abbr>' .. styles.h .. 'title="Havoc"|<abbr title="Tech">Te</abbr>' .. styles.h .. 'title="Havoc"|<abbr title="Rush">Ru</abbr>\n|-'
        elseif game == "p2is" or game == "p2ep" then
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
            result = result .. styles.table2 .. styles.h .. 'title="Sword"|Sw' .. styles.h .. prop.name_Rn .. styles.h .. 'title="Strike"|Sk' .. styles.h .. 'title="Thrown"|Th' .. styles.h .. prop.name_Hv .. styles.h .. 'style="background:#8E283D" title="Fire"|' .. prop.Fi .. styles.h .. 'style="background:#8E283D" title="Water"|' .. prop.Wt .. styles.h .. 'style="background:#8E283D" title="Wind"|' .. prop.Wi .. styles.h .. 'style="background:#8E283D" title="Earth"|' .. prop.Er .. styles.h .. 'title="Ice"|Ic' .. styles.h .. prop.name_El .. styles.h .. 'title="Nuclear"|Nc' .. styles.h .. prop.name_Li .. styles.h .. 'title="Dark"|Dk' .. styles.h .. 'title="Almighty"|Al' .. styles.h .. 'title="Nerve"|Nr' .. styles.h .. 'title="Mind"|Mn\n|-'
        end
        if require("Module:Skills/" .. gameg .. "/res").restypes[prop.restype] == nil then
            result = result .. '\n|colspan=16 align=center style="color:#f00;font-size:120%;font-weight:bold"|Invalid value of "' .. prop.restype .. '" for restype. Correct value or edit [[Module:Skills/' .. gameg .. "/res]]."
        else
            for i, v in ipairs(require("Module:Skills/" .. gameg .. "/res").restypes[prop.restype]) do
                if game == "p1" then
                    if i > 14 then break end
                    result = result .. resoutput(v, 4, gameg)
                elseif game == "p2is" or game == "p2ep" then
                    result = result .. resoutput(v, 4, gameg)
                elseif game == "giten" or game == "gmt" then
                    result = result .. outputResAsPercent(v)
                else
                    result = result .. resoutput(v, 8, gameg)
                end
            end
        end
        result = result .. "\n|}"
        if game == "p1" then
            result = result .. styles.table2 .. '\n|-\n!style="background:#a9a9a9" title="Element" colspan="4"|\n!style="background:#898989" title="Force" colspan="4"|\n!style="background:#a9a9a9" title="Light" colspan="2"|\n!style="background:#898989" title="Dark" colspan="3"|\n!style="background:#a9a9a9" title="Special" colspan="1"|\n|-' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Fire">Fi</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Ice">Ic</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Wind">Wi</abbr>' .. styles.h .. 'width="7.12%" title="Element"|<abbr title="Earth">Er</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Electricity">El</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Nuclear">Nc</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Blast">Bl</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Force"|<abbr title="Gravity">Gr</abbr>' .. styles.h .. 'title="Light"|<abbr title="Expel">Ex</abbr>' .. styles.h .. 'title="Light"|<abbr title="Miracle">Mi</abbr>' .. styles.h .. 'style="background:#898989" title="Dark"|<abbr title="Death">De</abbr>' .. styles.h .. 'style="background:#898989" title="Dark"|<abbr title="Curse">Cu</abbr>' .. styles.h .. 'style="background:#898989;width:7.12%" title="Dark (Ailments)"|<abbr title="Nerve">Nr</abbr>' .. styles.h .. 'width="7.12%" title="Special"|<abbr title="Resistance to Hieroglyphein">???</abbr>\n|-'
            for i, v in ipairs(require("Module:Skills/" .. gameg .. "/res").restypes[prop.restype]) do
                if i < 15 then
                else
                    result = result .. resoutput(v, 4, gameg)
                end
            end
            result = result .. "\n|}"
        end
    end
    if game == "smt9" and prop.reslevels then
        styles.h = '\n!style="background:' .. getGames.games[gameg].colorbg .. ';color:#fff" '
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
            for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do
                if k2 > 2 then
                    break
                elseif k2 % 2 == 1 then
                    resleveltemp = v2:lower()
                elseif k2 % 2 == 0 then --modifier
                    if string.sub(v2, 1, 1) == "+" then
                        if string.find(v2, "rf") then
                            prop.resleveltypes[resleveltemp] = ' <span style="color:#5ff">' .. v2 .. "</span></span>"
                        elseif string.find(v2, "dr") then
                            prop.resleveltypes[resleveltemp] = ' <span style="color:#f5f">' .. v2 .. "</span></span>"
                        else
                            prop.resleveltypes[resleveltemp] = ' <span style="color:#5f5">' .. v2 .. "</span></span>"
                        end
                    else
                        prop.resleveltypes[resleveltemp] = ' <span style="color:#f55">' .. v2 .. "</span></span>"
                    end
                end
            end
        end
        result = result .. styles.table2 .. styles.h .. 'title="Strike"|St' .. styles.h .. 'title="Slash"|Sl' .. styles.h .. 'title="Tech"|Te' .. styles.h .. 'title="Gun"|Gu' .. styles.h .. 'title="Thrown"|Th' .. styles.h .. 'title="Fire"|Fi' .. styles.h .. 'title="Ice"|Ic' .. styles.h .. 'title="Electricity"|El' .. styles.h .. 'title="Force"|Fo' .. styles.h .. 'title="Expel"|Ex' .. styles.h .. 'title="Death"|De' .. styles.h .. 'title="Mind"|Mi' .. styles.h .. 'title="Nerve"|Ne' .. styles.h .. 'title="Almighty"|Al' .. styles.h .. 'title="Healing|He\n|-' .. styles.statlow3 .. '"|' .. prop.resleveltypes.strike .. styles.statlow3 .. '"|' .. prop.resleveltypes.slash .. styles.statlow3 .. '"|' .. prop.resleveltypes.tech .. styles.statlow3 .. '"|' .. prop.resleveltypes.gun .. styles.statlow3 .. '"|' .. prop.resleveltypes.thrown .. styles.statlow3 .. '"|' .. prop.resleveltypes.fire .. styles.statlow3 .. '"|' .. prop.resleveltypes.ice .. styles.statlow3 .. '"|' .. prop.resleveltypes.elec .. styles.statlow3 .. '"|' .. prop.resleveltypes.force .. styles.statlow3 .. '"|' .. prop.resleveltypes.expel .. styles.statlow3 .. '"|' .. prop.resleveltypes.death .. styles.statlow3 .. '"|' .. prop.resleveltypes.mind .. styles.statlow3 .. '"|' .. prop.resleveltypes.nerve .. styles.statlow3 .. '"|' .. prop.resleveltypes.almighty .. styles.statlow3 .. '"|' .. prop.resleveltypes.heal
        result = result .. "\n|}" .. "\n|}"
    end
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
    if gameg == "smt3" and (prop.recruit ~= "" or prop.obtain ~= "" or prop.evolvef or prop.evolvet) then
        prop.recruit = prop.recruit:lower()
        if prop.recruit == "yes" or prop.recruit == "recruit" then
            prop.recruit = '<abbr title="Can be recruited in normal battle or obtained from conventional fusion.">Normal recruit or fusion</abbr>'
        elseif prop.recruit == "dark recruit" then
            prop.recruit = '<abbr title="Can be obtained via conventional fusion or recruited in normal battle under Full Kagutsuchi with fair chance.">[[Moon Phase System#Shin Megami Tensei III: Nocturne|Full Kagutsuchi]] recruitment or [[fusion]]</abbr>'
        elseif prop.recruit == "dark" then
            prop.recruit = '<abbr title="Can only be obtained via fusion. Open to non-recruitment conversation in normal battle.">[[Fusion]] only. Open to trading.</abbr>'
        elseif prop.recruit == "fusion" then
            prop.recruit = '<abbr title="Can only be obtained via conventional fusion.">[[Fusion]] only</abbr>'
        elseif prop.recruit == "special" or prop.recruit == "special fusion" then
            prop.recruit = '<abbr title="Can only be obtained via special fusion.">[[Special fusion#Shin Megami Tensei III: Nocturne|Special fusion]] only</abbr>'
        elseif prop.recruit == "evolve" or prop.recruit == "evolution" then
            prop.recruit = '<abbr title="Can only be obtained via evolution from another demon.">[[Evolution#Shin Megami Tensei III: Nocturne|Evolution]] only</abbr>'
        elseif prop.recruit == "evolve neutral" or prop.recruit == "neutral evolution" then
            prop.recruit = '<abbr title="Can be recruited in normal battle or obtained via evolution from another demon. Cannot be created via fusion.">Normal recruit or [[Evolution#Shin Megami Tensei III: Nocturne|evolution]]</abbr>'
        elseif prop.recruit == "evolve dark" or prop.recruit == "dark evolution" then
            prop.recruit = '<abbr title="Can only be obtained via evolution from another demon. Cannot be created via fusion. Open to non-recruitment conversation in normal battle.">[[Evolution#Shin Megami Tensei III: Nocturne|Evolution]] only. Open to trading.</abbr>'
        elseif prop.recruit == "boss fusion" then
            prop.recruit = '<abbr title="Can only be obtained via fusion after defeating it in boss battle.">[[Fusion]] only after boss battle</abbr>'
        elseif prop.recruit == "boss special" or prop.recruit == "boss special fusion" then
            prop.recruit = '<abbr title="Can only be obtained via special fusion after defeating it in boss battle.">[[Special fusion#Shin Megami Tensei III: Nocturne|Special fusion]] only after boss battle</abbr>'
        elseif prop.recruit == "boss evolve" or prop.recruit == "boss evolution" then
            prop.recruit = '<abbr title="Can only be obtained via evolution after defeating it in battle.">[[evolution#Shin Megami Tensei III: Nocturne|Evolution]] only after boss battle</abbr>'
        elseif prop.recruit == "dark boss fusion" then
            prop.recruit = '<abbr title="Can only be obtained via fusion after defeating it in boss battle. Open to non-recruitment conversation in normal battle.">[[Fusion]] only after boss battle. Open to trading.</abbr>'
        elseif prop.recruit == "dark boss special fusion" then
            prop.recruit = '<abbr title="Can only be obtained via special fusion after defeating it in boss battle. Open to non-recruitment conversation in normal battle.">[[Special fusion#Shin Megami Tensei III: Nocturne|Special fusion]] only after boss battle. Open to trading.</abbr>'
        elseif prop.recruit == "dark boss evolve" then
            prop.recruit = '<abbr title="Can only be obtained via evolution after defeating it in battle. Open to non-recruitment conversation in normal battle.">[[evolution#Shin Megami Tensei III: Nocturne|Evolution]] only after boss battle. Open to trading.</abbr>'
        elseif prop.recruit == "samael" then
            prop.recruit = '<abbr title="Can only be obtained via special fusion after defeating it in boss battle or choosing Shijima Reason after meeting with Ahriman in Kagutsuchi Tower.">Choose Shijima Reason or perform [[Special fusion#Shin Megami Tensei III: Nocturne|special fusion]] only after boss battle.</abbr>'
        elseif prop.recruit == "thor" then
            prop.recruit = '<abbr title="Can only be obtained via fusion after defeating him at Tower of Kagutsuchi.">[[Fusion]] only after boss battle at [[Tower of Kagutsuchi]]</abbr>'
        elseif prop.recruit == "bishamon" then
            prop.recruit = '<abbr title="Can only be obtained via fusion after defeating him at Bandou Shrine.">[[Fusion]] only after boss battle at [[Bandou Shrine]]</abbr>'
        elseif prop.recruit == "futomimi" or prop.recruit == "sakahagi" then
            prop.recruit = "[[Fusion]] only after boss battle and completing the revival side quest."
        elseif prop.recruit == "raidou" or prop.recruit == "dante" then
            prop.recruit = '<abbr title="Can only be recruited in story plot.">Plot related</abbr>'
        elseif prop.recruit == "unique" or prop.recruit == "exclusive" or prop.recruit == "enemy" or prop.recruit == "enemy only" or prop.recruit == "enemy exclusive" then
            prop.recruit = "Enemy only"
        end
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
    if prop.fusion then result = result .. styles.table2 .. styles.h .. "width=100px|[[Special fusion#" .. gamegn .. "|" .. styles.spanc .. "Special fusion</span>]]" .. styles.order .. prop.fusion .. "\n|}" end
    if prop.elecchair then result = result .. styles.table2 .. styles.h .. "width=180px|Electric chair execution" .. styles.order .. prop.elecchair .. "\n|}" end
    result = SkillTable.render({
        getGames = getGames,
        styles = styles,
        prop = prop,
        data = data,
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

p.row = makeInvokeFunction("_row")

function p._row(args)
    local row = args[1]
    local game = args[2]
    local code = args[3]
    if not code or code == "" then return "" end
    local level = args[4]
    if not level then level = "" end
    if level == "i" or level == "I" or level == "innate" or level == "default" or level == "Default" then level = "Innate" end
    local data = require("Module:Skills/" .. game)
    skill = data.skills[code]
    if not skill then
        alias = data.aliases[code]
        if alias then
            code = alias
            skill = data.skills[code]
        else
            return noskill(code, game)
        end
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
    local result
    if row == "r01" then
        result = skillcell .. effect1 -- Odd number row for enemy whose skill cost is irrelevant.
    elseif row == "r02" then
        result = skillcell .. effect2 -- Even number row for enemy whose skill cost is irrelevant.
    elseif row == "r11" then
        if game == "SMT3" and skill.phy then
            result = skillcell .. styles.effect1p .. skill.effect -- Odd number row for enemy whose physical skills cost no HP.
        else
            result = skillcell .. cost1 .. effect1 -- Odd number row for demon which does not learn new skill on level gain.
        end
    elseif row == "r12" then
        if game == "SMT3" and skill.phy then
            result = skillcell .. styles.effect2p .. skill.effect -- Even number row for enemy whose physical skills cost no HP.
        else
            result = skillcell .. cost2 .. effect2 -- Even number row for demon which does not learn new skill on level gain.
        end
    elseif row == "r21" then
        result = skillcell .. cost1 .. effect1 .. level1 -- Odd number row for demon/persona which learn new skill on level gain.
    elseif row == "r22" then
        result = skillcell .. cost2 .. effect2 .. level2 -- Even number row for demon/persona which learn new skill on level gain.
    elseif row == "r31" then
        result = skillcell .. effect1 .. level1 -- Odd number row for guest who learn new skill on level gain.
    elseif row == "r32" then
        result = skillcell .. effect2 .. level2 -- Even number row for guest who learn new skill on level gain.
    elseif row == "p12" then
        result = styles.skill .. level .. styles.skillc .. code .. effect1 -- Row for Persona 1 and 2 persona
    elseif row == "rf" then
        result = skillcell .. effect1 .. order -- Row for Persona-specific fusion spell.
    elseif row == "dk1" then
        result = skillcell .. element1 .. cost1 .. effect1 -- Odd number row for DemiKids stats skill list.
    elseif row == "dk2" then
        result = skillcell .. element2 .. cost2 .. effect2 -- Odd number row for DemiKids stats skill list.
    elseif row == "dkc1" then
        result = skillcell .. level1 .. element1 .. cost1 .. effect1 -- Odd number row for DemiKids stats combo skill list.
    elseif row == "dkc2" then
        result = skillcell .. level2 .. element2 .. cost2 .. effect2 -- Odd number row for DemiKids stats combo skill list.
    elseif row == "dkp" then
        result = skillcell .. element2 .. effect2 -- row for DemiKids powers.
    else
        result = '<strong style="color:red;font-size:150%">Invalid parameter 1 of ' .. '"' .. row .. '".</strong>' .. cate("Templates with unrecognizable row value for Module:Skills")
    end
    return result
end

return p
--[[Category:Skills modules|!]]
--[[Category:Stat Templates|!]]
