---
-- Megami Tensei Wiki
-- page=Module:Categories
--
-- Licensed under CC BY-SA 3.0
--


local cates = {}

function cates.cate(catename)
    if mw.title.getCurrentTitle():inNamespace('') then
        return '[[Category:' .. catename .. ']]'
    else
        return ''
    end
end

function cates.rarityCategory(rarity, gamen)
    if string.find(rarity, "★") ~= nil then
        local rarityNumber = math.floor(#rarity/3)

        if rarityNumber > 0 then
            return string.format('[[Category:%d★ Demons in %s]]', rarityNumber, gamen)
        else
            return ''
        end
    else
        return string.format('[[Category:%s Demons in %s]]', rarity, gamen)
    end
end

function cates.aligncat(align,gamen)
    local result
    if align == 'Law' or align == 'Light-Law' or align == 'Neutral-Law' or align == 'Dark-Law' then
        result = cate('Law Demons in ' .. gamen)
    elseif align == 'Neutral' or align == 'Light-Neutral' or align == 'Neutral-Neutral' or align == 'Dark-Neutral' then
        result = cate('Neutral Demons in ' .. gamen)
    elseif align == 'Chaos' or align == 'Light-Chaos' or align == 'Neutral-Chaos' or align == 'Dark-Chaos' then
        result = cate('Chaos Demons in ' .. gamen)
    elseif string.lower(align) == "unknown" then
        result = cate('Unknown Demons in ' .. gamen)
    else
        result = ''
    end
    return result
end

function cates.alignnocat(align,nocat,gamen)
    local result
    if nocat then
        result = ''
    elseif align == 'Law' or align == 'Light-Law' or align == 'Neutral-Law' or align == 'Dark-Law' then
        result = cate('Law Demons in ' .. gamen)
    elseif align == 'Neutral' or align == 'Light-Neutral' or align == 'Neutral-Neutral' or align == 'Dark-Neutral' then
        result = cate('Neutral Demons in ' .. gamen)
    elseif align == 'Chaos' or align == 'Light-Chaos' or align == 'Neutral-Chaos' or align == 'Dark-Chaos' then
        result = cate('Chaos Demons in ' .. gamen)
    elseif string.lower(align) == "unknown" then
        result = cate('UNKNOWN Demons in ' .. gamen)
    else
        result = ''
    end
    return result
end

function cates.bossdemonnocat(boss,nocat,gamen)
    local result
    if boss then
        result = cate(gamen .. ' Bosses')
    elseif nocat then
        result = ''
    else result = cate(gamen .. ' Demons')
    end
    return result
end

function cates.bossdemoncat(boss,gamen)
    local result
    if boss then
        result = cate(gamen .. ' Bosses')
    else result = cate(gamen .. ' Demons')
    end
    return result
end

return cates

-- [[Category:Modules]]
-- [[Category:Skills modules]]