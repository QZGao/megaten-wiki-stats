---
-- Megami Tensei Wiki
-- page=Module:Races
--
-- Licensed under CC BY-SA 3.0
---


local cate = require('Module:Categories').cate


local race = {}

local race_names = {
--Gods
    ['Deity'] = { 'Deity', 'Demon God', },
    ['Megami'] = { 'Megami', 'Goddess', },
    ['Amatsu'] = { 'Amatsu', 'Heavenly God', 'Tenjin', },
    ['Enigma'] = { 'Enigma', },
    ['Entity'] = { 'Entity', 'Geist', },
    ['Godly'] = { 'Godly', 'Godly Spirit', },
    ['Soshin'] = { 'Soshin', },
    ['Chaos'] = { 'Chaos', linkdab=true, },
--Guardians
    ['Tenma'] = { 'Tenma', },
    ['Fury'] = { 'Fury', 'Destroyer', 'Omega', linkdab=true, },
    ['Lady'] = { 'Lady', 'Earth Mother', },
    ['Kunitsu'] = { 'Kunitsu', 'Nation Ruler', 'Chigi', },
    ['Kishin'] = { 'Kishin', 'Guardian', },
    ['Vile'] = { 'Vile', },
    ['Reaper'] = { 'Reaper', linkdab=true, },
    ['Shinshou'] = { 'Shinshou', },
    ['Wargod'] = { 'Wargod', },
    ['Zealot'] = { 'Zealot', linkdab=true, },
--Aerials
    ['Herald'] = { 'Herald', 'Seraph', 'Hallel', },
    ['Divine'] = { 'Divine', },
    ['Fallen'] = { 'Fallen', 'Fallen Angel', 'Futenshi', },
--Birds
    ['Avian'] = { 'Avian', },
    ['Flight'] = { 'Flight', 'Wild Bird', },
    ['Raptor'] = { 'Raptor', },
--Dragons
    ['Dragon'] = { 'Dragon', 'Dragon God', },
    ['Snake'] = { 'Snake', 'Dragon King', },
    ['Drake'] = { 'Drake', 'Evil Dragon', },
    ['Hiryu'] = { 'Hiryu', },
--Beasts
    ['Avatar'] = { 'Avatar', 'Godly Beast', },
    ['Holy'] = { 'Holy', 'Holy Beast', },
    ['Beast'] = { 'Beast', linkdab=true, },
    ['Wilder'] = { 'Wilder', },
    ['UMA'] = { 'UMA', },
    ['Kaijuu'] = { 'Kaijuu', },
--Onis
    ['Touki'] = { 'Touki', },
    ['Brute'] = { 'Brute', },
    ['Jirae'] = { 'Jirae', 'Earth Spirit', },
    ['Femme'] = { 'Femme', 'Joma', },
    ['Jaki'] = { 'Jaki', 'Evil Demon', },
    ['Akuma'] = { 'Akuma', },
    ['Shinoma'] = { 'Shinoma', },
    ['Henii'] = { 'Henii', catename=false, },
--Magicas
    ['Tyrant'] = { 'Tyrant', 'Demon Lord', },
    ['Genma'] = { 'Genma', 'Demigod', },
    ['Fairy'] = { 'Fairy', },
    ['Yoma'] = { 'Yoma', },
    ['Night'] = { 'Night', 'Nocturne', },
    ['Shin Akuma'] = { 'Shin Akuma', },
--Vegetations
    ['Tree'] = { 'Tree', },
    ['Wood'] = { 'Wood', },
    ['Jusei'] = { 'Jusei', },
--Elementals
    ['Element'] = { 'Element', 'Prime', linkdab=true, },
    ['Mitama'] = { 'Mitama', },
--Evil Spirits
    ['Haunt'] = { 'Haunt', },
    ['Spirit'] = { 'Spirit', 'Jarei', },
    ['Undead'] = { 'Undead', 'Grave' },
--Humans
    ['Human'] = { 'Human', },
    ['Gaean'] = { 'Gaean', 'Gaian', link='Ring of Gaea', catename='Ring of Gaea', },
    ['Messian'] = { 'Messian', link='Order of Messiah', catename='Order of Messiah', },
    ['Summoner'] = { 'Summoner', link='Devil Summoner (race)', },
    ['Kyojin'] = { 'Kyojin', },
    ['Shinja'] = { 'Ishtar Shinja', 'Bael Shinja', },
    ['Meta'] = { 'Meta', },
    ['Ranger'] = { 'Ranger', },
    ['Hero'] = { 'Hero', },
    ['General'] = { 'General', },
    ['Therian'] = { 'Therian', },
    ['Foreigner'] = { 'Foreigner', },
    ['Fiend'] = { 'Fiend', },
--Fouls
    ['Foul'] = { 'Foul', },
    ['Vermin'] = { 'Vermin', },
    ['Demonoid'] = { 'Demonoid', },
    ['Rumor'] = { 'Rumor', },
    ['Karma'] = { 'Karma', link='Karma (race)', },
--Machine
    ['Machine'] = { 'Machine', 'Device' },
    ['Virus'] = { 'Virus', exclusive='#Virus and Vaccine', },
    ['Vaccine'] = { 'Vaccine', exclusive='#Virus and Vaccine', },
--Unclassified
    ['Zoma'] = { 'Zoma', },
    ['Fake'] = { 'Fake', },
    ['Famed'] = { 'Famed', },
    ['Suiyou'] = { 'Suiyou', },
    ['Nymph'] = { 'Nymph', },
    ['Food'] = { 'Food', },
--Enemy-exclusive
    ['Horde'] = { 'Horde', catename=false, },
    ['Yuiitsukami'] = { 'Yuiitsukami', exclusive='Yuiitsukami / Kami', catename=false, },
    ['Kami'] = { 'Kami', exclusive='Yuiitsukami / Kami', catename=false, },
    ['Himitsu'] = { 'Himitsu', exclusive='Himitsu', catename=false, },
    ['Teacher'] = { 'Teacher', exclusive='Kyoushi and Kaizou Kyoushi', catename=false, },
    ['Demon God Emperor'] = { 'Demon God Emperor', 'Majinou', 'Majin Ou', 'Majinō', 'Majinnou', 'Majinnō', exclusive='Majinou / Demon God Emperor', catename=false, },
    ['Boutoko'] = { 'Boutoko', exclusive='Boutoko / Violent Guy', catename=false, },
    ['Corpus'] = { 'Corpus', link='Manikin', catename=false, },
    ['Zoa'] = { 'Zoa', exclusive='Bunrei / Zoa', },
    ['Light'] = { 'Light', exclusive='Mujinkou / Light', catename=false, },
    ['Devil'] = { 'Devil', exclusive='Daimaou / Devil', catename=false, },
    ['Archaic'] = { 'Archaic', exclusive='Archaic', catename=false, },
    ['King'] = { 'King', exclusive='King', catename=false, },
    ['Koki'] = { 'Koki', exclusive='Koki', catename=false, },
    ['Great'] = { 'Great', exclusive='Great', catename=false, },
    ['Awake'] = { 'Awake', exclusive='Awake and Soil', catename=false, },
    ['Soil'] = { 'Soil', exclusive='Awake and Soil', catename=false, },
    ['Judge'] = { 'Judge', exclusive='Judge and Pillar', catename=false, },
    ['Pillar'] = { 'Pillar', exclusive='Judge and Pillar', catename=false, },
    ['Mother'] = { 'Mother', exclusive='Mother and Empty', catename=false, },
    ['Empty'] = { 'Empty', exclusive='Mother and Empty', catename=false, },
    ['Onmyo'] = { 'Onmyo', exclusive='Onmyo', catename=false, },
    ['God'] = { 'God', exclusive='Bonten / God', catename=false, },
    ['Bel'] = { 'Bel', link='King of Bel', catename=false, },
    ['Star'] = { 'Star', link='Septentriones', },
    ['Energy'] = { 'Energy', exclusive='Jiryuu / Energy', catename=false, },
    ['King Abaddon'] = { 'King Abaddon', catename=false, },
    ['Fukoshi'] = { 'Fukoshi', catename=false, },
    ['Locust'] = { 'Locust', 'Soldier Bug', link='Soldier Bug', catename=false, },
    ['Tokyogami'] = { 'Tokyogami', exclusive='Tokyogami', catename=false, },
    ['Rebel God'] = { 'Rebel God', exclusive='Rebel God', catename=false, },
}

function race.getRace(race,game,abbr)
    local result
    if not race or race == '' or race == '-' or race == 'Unclassified' or race == 'None' or race == 'none' then result = '-'
    elseif game == 'ddsaga1' or game == 'ddsaga2' then
        if race == 'Deity' then result = '[[Gods|' .. race .. ']]'
        elseif race == 'Evil' or race == 'Icon' then result = '[[Guardians|' .. race .. ']]'
        elseif race == 'Fiend' or race == 'Nether'  then result = '[[Magica|' .. race .. ']]'
        elseif race == 'Aerial' then result = '[[Aerials|' .. race .. ']]'
        elseif race == 'Aerial2' then result = '[[Birds|Aerial]]'
        elseif race == 'Dragon' then result = '[[Dragons|' .. race .. ']]'
        elseif race == 'Demon' or race == 'Brute' then result = '[[Demoniacs|' .. race .. ']]'
        elseif race == 'Beast' then result = '[[Beasts|' .. race .. ']]'
        elseif race == 'Device' then result = '[[Machine|' .. race .. ']]'
        elseif race == 'Light' then result = '[[Herald|' .. race .. ']]'
        else result = race
        end
    elseif game == 'raidou1' or game == 'raidou2' then
        if race == 'Element' then result = '[[Element]]' .. cate('Element Race')
        elseif race == 'Spirit' then result = '[[Mitama|Spirit]]' .. cate('Mitama Race')
        elseif race == 'Destroyer' or race == 'King Abaddon' or race == 'Fukoshi' or race == 'Locust' or race == 'Tokyogami' or race == 'Rebel God' then result = '[[Enemy exclusive race#' .. race .. '|' .. race ..']]'
        elseif race == 'Fiend' then result = '[[Fiend]]' .. cate('Fiend Race')
        elseif race == 'Pyro' or race == 'Frost' or race == 'Volt' or race == 'Wind' or race == 'Fury' or race == 'Pagan' or race == 'Skill' or race == 'Evil' then result = '[[' .. race .. ' Order|' .. race .. ']]' .. cate(race .. ' Order')
        else result = race
        end
    elseif race == 'Therian' then
        if game == 'mt1' then result = '[[Yoma|Therian]]' .. cate('Yoma Race')
        else result = '[[Therian]]' .. cate('Therian Race')
        end
    elseif race == 'Ghost' then
        if game == 'sh' or game == 'smtds' then
            result = '[[Ghost (race)|Ghost]]' .. cate('Ghost Race')
        else result = '[[Haunt|Ghost]]' .. cate('Haunt Race')
        end
    elseif race == 'Cyber' then
        if game == 'smt4' then
            result = '[[Machine|Cyber]]' .. cate('Machine Race')
        else result = '[[Enemy exclusive race#Denrei / Cyber|Cyber]]'
        end
    elseif race == 'Star 2' then
        result = '[[Triangulum|Star]]' .. cate('Star Race')
    end
    for k, v in pairs(race_names) do
        for _, name in ipairs(v) do
            if race == name then
                if abbr then
                    abbr = '<abbr title="' .. abbr .. '">' .. name .. '</abbr>'
                else abbr = name
                end
                if v.exclusive then
                    result = '[[Enemy exclusive race#' .. v.exclusive .. '|' .. abbr .. ']]'
                elseif v.linkdab then
                    result = '[[' .. k .. ' (race)|' .. abbr .. ']]'
                elseif v.link then
                    result = '[[' .. v.link .. '|' .. abbr .. ']]'
                else
                    result = '[[' .. k .. '|' .. abbr .. ']]'
                end
                if v.catename==false then
                elseif v.catename then
                    result = result .. cate(v.catename)
                else
                    result = result .. cate(k .. ' Race')
                end
            end
        end
    end
    if not result then return race end
    return result
end

return race

-- [[Category:Skills modules]]