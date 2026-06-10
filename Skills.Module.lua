local getArgs = require("Module:Arguments").getArgs
local getGames = require("Module:Gamedata")
local Row = require("Module:Skills/Row")
local Render = require("Module:Skills/Render")

local p = {}
local isArticleNamespace

-- Build a public #invoke wrapper that parses template arguments before calling an implementation.
-- Used by the exported stats and row entry points for every supported game.
local function makeInvokeFunction(funcName)
    -- makes a function that can be returned from #invoke, using
    -- [[Module:Arguments]].
    return function(frame)
        local args = getArgs(frame, { parentOnly = true })
        return p[funcName](args)
    end
end

-- Build rarity category wikitext for demon rarity labels.
-- Used by the Dx2 stat renderer, including star-rarity demon categories.
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

-- Emit a category only when rendering in the article namespace.
-- Used by all game renderers that attach maintenance, race, alignment, boss, demon, Persona, or item categories.
local function cate(catename)
    if isArticleNamespace == nil then
        isArticleNamespace = mw.title.getCurrentTitle():inNamespace("")
    end

    if isArticleNamespace then
        return "[[Category:" .. catename .. "]]"
    else
        return ""
    end
end

-- Render the standard invalid-skill or empty-skill error row.
-- Used by skill table and row renderers for all games; Metaphor uses a wider synthesis row.
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

-- Preprocess raw wiki markup through the current frame.
-- Used by P5S combo attack rendering for button-input markup.
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

local race_name_index = {}
for key, race_data in pairs(race_names) do
    for _, name in ipairs(race_data) do
        race_name_index[name] = { key = key, data = race_data }
    end
end

-- Convert a race name into linked display text plus race categories.
-- Used by top stat renderers across MT/KMT/SMT, Devil Summoner/Raidou, Persona, Devil Survivor, DemiKids, DDS, and related games.
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

    local race_entry = race_name_index[race]
    if race_entry then
        local k = race_entry.key
        local v = race_entry.data
        if abbr then
            abbr = '<abbr title="' .. abbr .. '">' .. race .. "</abbr>"
        else
            abbr = race
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
    if not result then return race end
    return result
end

-- Emit alignment categories without a nocat override.
-- Used by older MT/SMT-style stat blocks where alignment categories are always attached.
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

-- Emit alignment categories while respecting nocat.
-- Used by SMT/DDS-style stat blocks that allow category suppression.
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

-- Emit boss or demon categories while respecting nocat.
-- Used by stat renderers where boss/demon categorization can be suppressed.
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

-- Emit boss or demon categories.
-- Used by stat renderers across most demon/enemy game layouts.
local function bossdemoncat(boss, gamen)
    local result
    if boss then
        result = cate(gamen .. " Bosses")
    else
        result = cate(gamen .. " Demons")
    end
    return result
end

-- Convert an Arcana or Persona 2 enemy group into linked display text plus categories.
-- Used by Persona 1/2/3/4/5/P5X/PQ stat and summon rows.
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

-- Render one numeric stat bar cell pair, including inherited and old/new comparison cases.
-- Used by stat blocks with visible stat bars across SMT, Persona, Devil Summoner, Devil Survivor, Metaphor, and related games.
local function bar(color, stat, ratio, cap, stat2, old, new)
	-- ratio is the length (in pixel) of each point. Cap times ratio equals max length of the stat bar.
    local stat_st, stat_width
    local stat_number, stat2_number
    if stat ~= "i" then stat_number = tonumber(stat) end
    if stat2 then stat2_number = tonumber(stat2) end
    if stat == "i" then
        stat = "i"
    elseif not stat_number then
        stat_st = '<span style="color:#666">--</span>'
        stat = 0
        stat_number = 0
        stat_width = 0
    elseif stat2 then
        stat_st = '<span style="color:#aff;cursor:help" title="' .. old .. ": " .. stat .. "; " .. new .. ": " .. stat2 .. '">' .. stat2 .. "</span>"
    else
        stat_st = stat
    end
    if stat == "i" then
    elseif stat_number > cap then
        stat_width = cap * ratio
        color = "#aaf"
    elseif stat_width ~= 0 then
        stat_width = stat_number * ratio
    end
    if tostring(stat_st) == "+0" then stat_st = '<span style="color:#666">--</span>' end
    if stat == "i" then
        return "--\n|Inherit\n|-"
    elseif stat2 then
        return stat_st .. '\n|style="border-radius:10px;background-color:#000;background:linear-gradient(90deg, #2c2a46, #000);width:' .. cap * ratio + 3 .. 'px"|<div style="overflow:hidden"><div style="cursor:help;float:left;border-top:5px solid ' .. color .. ";width:" .. stat_width .. 'px" title="' .. old .. ": " .. stat .. '"></div><div style="cursor:help;float:left;border-top:5px solid #aff;width:' .. stat2_number * ratio - stat_width .. 'px" title="' .. new .. ": " .. stat2 .. '"></div></div>\n|-'
    else
        return stat_st .. '\n|style="border-radius:10px;background-color:#000;background:linear-gradient(90deg, #2c2a46, #000);width:' .. cap * ratio + 3 .. 'px"|<div style="overflow:hidden"><div style="float:left;border-top:5px solid ' .. color .. ";width:" .. stat_width .. 'px"></div><div style="float:left;border-top:5px solid transparent;width:' .. (cap - stat_number) * ratio .. 'px"></div></div>\n|-'
    end
end

-- Normalize template arguments into canonical property names from Module:Property_names.
-- Used by the main stats entry point before dispatching any game renderer.
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

-- Test whether an optional value is present and not an explicit dash placeholder.
-- Used by P5/P5X Arcana and reward-row hiding logic.
local function hasFilledValue(value)
    return value ~= nil and value ~= "-"
end

p.stats = makeInvokeFunction("_stats")

-- Main stats template implementation: normalize game aliases, load game data, and dispatch rendering.
-- Supports every game handled by Template:Stats, including MT/KMT/SMT, Persona, Devil Summoner/Raidou, DemiKids, DDS, Devil Survivor, Metaphor, and spinoffs.
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
    local baseGameData = getGames.games[game]
    local gameg -- Game general style
    if baseGameData.fallback then
        gameg = baseGameData.fallback -- e.g. 'p3f' and 'p3p' will fall back to 'p3' if applicable.
    else
        gameg = game
    end
    local gameData = getGames.games[gameg]
    local gamen = baseGameData.name -- Full game name
    local gamegn = gameData.name -- e.g. 'Persona 3 FES' will fall back to 'Persona 3' if applicable.
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
    return Render.render({
        args = args,
        data = data,
        prop = prop,
        baseGameData = baseGameData,
        gameData = gameData,
        game = game,
        gameg = gameg,
        gamen = gamen,
        gamegn = gamegn,
        gamed = gamed,
        rarityCategory = rarityCategory,
        cate = cate,
        noskill = noskill,
        wikitext = wikitext,
        getRace = getRace,
        getArcana = getArcana,
        aligncat = aligncat,
        alignnocat = alignnocat,
        bossdemonnocat = bossdemonnocat,
        bossdemoncat = bossdemoncat,
        bar = bar,
        hasFilledValue = hasFilledValue,
    })
end

p.row = makeInvokeFunction("_row")

-- Public row-template implementation for legacy skill-row fragments.
-- Used by all games that still call #invoke:row; row-specific game handling lives in Module:Skills/Row.
function p._row(args)
    return Row.render(args, noskill, cate)
end

return p
--[[Category:Skills modules|!]]
--[[Category:Stat Templates|!]]
