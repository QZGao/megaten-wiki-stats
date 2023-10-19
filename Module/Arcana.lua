---
-- Megami Tensei Wiki
-- page=Module:Arcana
--
-- Licensed under CC BY-SA 3.0
--


local arcana = {}

function arcana.getArcana(arcana,game,gamen)
    local result
    if not arcana or arcana == '' or arcana == '-' or arcana == 'Unclassified' or arcana == 'None' or arcana == 'none'
        then result = '-'
    elseif arcana == 'Coin' or arcana == 'Coins' then result = '[[Suit of Coins|Coin]]' .. cate('Coin Arcana')
    elseif arcana == 'Pentacle' then result = '[[Suit of Coins|Pentacle]]' .. cate('Coin Arcana')
    elseif arcana == 'Sword' or arcana == 'Swords' then result = '[[Suit of Swords|Sword]]' .. cate('Sword Arcana')
    elseif arcana == 'Cup' or arcana == 'Cups' then result = '[[Suit of Cups|Cup]]' .. cate('Cup Arcana')
    elseif arcana == 'Wand' or arcana == 'Wands' then result = '[[Suit of Wands|Wand]]' .. cate('Wand Arcana')
    elseif arcana == 'Rod' then result = '[[Suit of Wands|Rod]]' .. cate('Wand Arcana')
    elseif arcana == 'Rumor' then result = '[[Rumor]] [[List of ' .. gamen .. ' Rumors|*]]' .. cate('Rumor Demon')
    elseif arcana == 'Taurus' or arcana == 'Aquarius' or arcana == 'Leo' or arcana == 'Scorpio' or arcana == 'Masquerade' then
        result = '[[Masked Circle|' .. arcana .. ']]' .. cate('Masked Circle')
    elseif arcana == 'Reich' then result = '[[Last Battalion|' .. arcana .. ']]'
    elseif arcana == 'Grave' or arcana == 'Zonbie' or arcana == 'Zombie' then result = '[[Undead|' .. arcana .. ']]' .. cate('Undead Race')
    elseif arcana == 'Human' then result = '[[Human]]' .. cate('Human Race')
    elseif arcana == 'Machine' then result = '[[Machine]]' .. cate('Machine Race')
    else result = '[[' .. arcana .. ' Arcana|' .. arcana .. ']]' .. cate(arcana .. ' Arcana')
    end
    return result
end

return arcana

-- [[Category:Skills modules]]