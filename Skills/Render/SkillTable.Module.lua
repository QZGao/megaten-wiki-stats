local p = {}

function p.render(ctx, result)
    local getGames = ctx.getGames
    local styles = ctx.styles
    local prop = ctx.prop
    local data = ctx.data
    local game = ctx.game
    local gameg = ctx.gameg
    local gamegn = ctx.gamegn
    local gamed = ctx.gamed
    local noskill = ctx.noskill
    local wikitext = ctx.wikitext
    local skill, alias, skillcell, skille, cost, effect, pre, range, power, target
    if prop.dskills then
        result = result .. styles.table2 .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Default Skills</span>]]" .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
        for k, v in ipairs(mw.text.split(prop.dskills, "\n")) do
            skill = data.skills[v]
            if not skill then
                alias = data.aliases[v]
                if alias then
                    v = alias
                    skill = data.skills[v]
                end
            end
            if v == "" then
                skillcell = ""
                cost = ""
                effect = noskill()
            elseif not skill then
                skillcell = ""
                cost = ""
                effect = noskill(v, gamed)
            elseif skill then
                cost = skill.cost
                effect = skill.effect
                if k % 2 == 0 then
                    cost = styles.cost2 .. cost
                    effect = styles.effect2 .. effect
                else
                    cost = styles.cost1 .. cost
                    effect = styles.effect1 .. effect
                end
                if skill.name then v = skill.name end
                skillcell = styles.skill .. v
            end
            result = result .. skillcell .. cost .. effect
        end
        result = result .. "\n|}"
    end

    -- List of skills starts here
    if prop.skills then
        -- List of skills table header
        result = result .. styles.table2h
        if game == "mt1" or game == "mt2" or game == "kmt1" or game == "kmt2" then
            result = result .. '"' .. styles.h .. "colspan=4|[[List of Megami Tensei Spells|" .. styles.spanc .. "List of Spells</span>]]"
        elseif game == "smtim" then
            result = result .. 'mw-collapsible mw-collapsed"' .. styles.h .. "colspan=4|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Learned Skills</span>]]"
        elseif gameg == "smtsj" and not (prop.enemy or prop.boss) then
            result = result .. '"' .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Natural Skills</span>]]"
        elseif gameg == "ab" then
            result = result .. '"' .. styles.h .. "colspan=7|[[List of " .. gamegn .. " Skills#Magic|" .. styles.spanc .. "Natural Skills</span>]]"
        elseif gameg == "majin1" then
            result = result .. '"' .. styles.h .. "colspan=7|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Magic Skills</span>]]"
        elseif gameg == "majin2" then
            result = result .. '"' .. styles.h .. "colspan=6|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "List of Skills</span>]]"
        elseif gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
            result = result .. '"\n!colspan=4 style="background-color: ' .. getGames.games[gameg].colorb .. ";background: linear-gradient(120deg, " .. getGames.games[gameg].colorb .. " 42%, #000 42.1%, #000 43%, #fff 43.1%, #fff 57%, #000 57.1%, #000 58%, " .. getGames.games[gameg].colorb .. ' 58.1%"|[[List of ' .. gamegn .. ' Skills|<span style="color:black;text-shadow:-3px 3px 3px #0ff">List of Skills</span>]]'
        elseif gameg == "desu1" or gameg == "desu2" then
            result = result .. '"' .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "Command Skills</span>]]"
        else
            result = result .. '"' .. styles.h .. "colspan=4|[[List of " .. gamegn .. " Skills|" .. styles.spanc .. "List of Skills</span>]]"
        end

        -- List of skills table content
        if game == "mt1" or game == "mt2" or gameg == "giten" or gameg == "smtsj" or gameg == "smtds" or gameg == "sh" or gameg == "childred" or gameg == "childblack" or gameg == "childps" or gameg == "childblack" or gameg == "childfire" or gameg == "childice" or gameg == "desu1" or gameg == "desu2" then
            result = result .. '\n|-style="border:0"\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|'
            for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" or v == "-" or v == "--" then
                    skillcell = ""
                elseif not skill then
                    skillcell = styles.skill3 .. '"|' .. v
                else
                    if skill.name then v = skill.name end
                    skillcell = styles.skill3 .. '" title="Cost: ' .. skill.cost .. "; " .. string.gsub(string.gsub(skill.effect, "%[%[", ""), "%]%]", "") .. '"|' .. v
                end
                if k == 7 then
                    if prop.boss or prop.enemy then
                        result = result .. "\n|-" .. skillcell
                    else
                        result = result .. "\n|-" .. styles.skill3m .. skillcell .. styles.skill3m
                    end
                elseif k % 3 == 1 then
                    result = result .. "\n|-" .. skillcell
                else
                    result = result .. skillcell
                end
            end
        elseif gameg == "majin2" then
            result = result .. styles.skill .. "Skill" .. styles.skillc .. "Power" .. styles.skillc .. "Range" .. styles.skillc .. "Cost" .. styles.skillc .. "Target" .. styles.skillc .. "Effect"
            for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" then
                    skillcell = ""
                    power = ""
                    range = ""
                    cost = ""
                    target = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    power = ""
                    range = ""
                    cost = ""
                    target = ""
                    effect = noskill(v, gamed)
                elseif skill then
                    if skill.cost == "extra" then
                        skill.cost = '<abbr title="No cost. Can only be used once until next full moon phase.">Extra</abbr>'
                    elseif skill.cost == "sextra" then
                        skill.cost = '<abbr title="No cost. Power relative to physical attack power. Can only be used once until next full moon phase.">P. Extra</abbr>'
                    elseif skill.cost == "mextra" then
                        skill.cost = '<abbr title="No cost. Power relative to magical attack power. Can only be used once until next full moon phase.">M. Extra</abbr>'
                    end
                    if k % 2 == 0 then
                        power = styles.cost2 .. skill.power
                        range = styles.cost2 .. skill.range
                        cost = styles.cost2 .. skill.cost
                        target = styles.cost2 .. skill.target
                        effect = styles.effect2 .. skill.effect
                    else
                        power = styles.cost1 .. skill.power
                        range = styles.cost1 .. skill.range
                        cost = styles.cost1 .. skill.cost
                        target = styles.cost1 .. skill.target
                        effect = styles.effect1 .. skill.effect
                    end
                    if skill.name then v = skill.name end
                    skillcell = styles.skill .. v
                end
                result = result .. skillcell .. power .. range .. cost .. target .. effect
            end
        elseif gameg == "smt9" or gameg == "20xx" or gameg == "lb3" or gameg == "lbs" or gameg == "ronde" or gameg == "cs" then
            result = result .. '\n|-style="border:0"\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|'
            for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
                if v == "" or v == "-" or v == "--" then
                    skillcell = ""
                else
                    skillcell = styles.skill3 .. '"|' .. v
                end
                if k == 7 then
                    result = result .. "\n|-" .. styles.skill3m .. skillcell .. styles.skill3m
                elseif k % 3 == 1 then
                    result = result .. "\n|-" .. skillcell
                else
                    result = result .. skillcell
                end
            end
        elseif (game == "kmt1" and not (prop.enemy or prop.boss)) or (game == "kmt2" and not (prop.enemy or prop.boss)) or (gameg == "smt1" and not (prop.enemy or prop.boss)) or (gameg == "smt2" and not (prop.enemy or prop.boss)) or (gameg == "smtif" and not (prop.enemy or prop.boss)) or (gameg == "smt3" and (prop.enemy or prop.boss)) or ((gameg == "smt4a" or gameg == "smt5" or gameg == "smt5v" or gameg == "sh2") and prop.guest == "2") or (game == "lb1" and not (prop.enemy or prop.boss)) or (game == "lb2" and not (prop.enemy or prop.boss)) then -- skill - cost - effect
            result = result .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
            for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" then
                    skillcell = ""
                    cost = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    cost = ""
                    effect = noskill(v, gamed)
                elseif skill then
                    if skill.phy then
                        cost = "none"
                    --[[elseif gameg == 'p5' or gameg == 'p5r' or gameg == 'p5s' or gameg == 'p5x' then
                        cost = '<span style="color:' .. getGames.games[gameg].mp2 .. '">' .. skill.cost .. '</span>' -- tints pink for magic skill]]
                    --
                    else
                        cost = skill.cost
                    end
                    effect = skill.effect
                    if k % 2 == 0 then
                        cost = styles.cost2 .. cost
                        effect = styles.effect2 .. effect
                    else
                        cost = styles.cost1 .. cost
                        effect = styles.effect1 .. effect
                    end
                    if skill.name then v = skill.name end
                    if skill.magatsuhi then effect = '<div style="background:#DC143C;border-radius:5px;float:left;margin-right:5px">Magatsuhi</div> ' .. effect end
                    skillcell = styles.skill .. v
                end
                result = result .. skillcell .. cost .. effect
            end
        elseif (gameg == "smt4" and prop.guest == "2") or ((gameg == "p1" or gameg == "p2is" or gameg == "p2ep" or gameg == "p3" or gameg == "p3re" or gameg == "p4" or gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" or gameg == "metaphor") and prop.hp) or gameg == "ddsaga1" or gameg == "ddsaga2" or ((gameg == "pq" or gameg == "pq2") and not prop.arcana) or prop.boss or prop.enemy then -- skill - effect (optional: Inheritable Skill or Rumor Skill)
            result = result .. styles.skill .. "Skill" .. styles.skillc .. "Effect"
            for k1, v1 in ipairs(mw.text.split(prop.skills, "\n")) do
                for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do
                    if k2 > 2 then
                        break
                    elseif k2 % 2 == 1 then
                        skill = data.skills[v2]
                        if not skill then
                            alias = data.aliases[v2]
                            if alias then
                                v2 = alias
                                skill = data.skills[v2]
                            end
                        end
                        if skill then
                            if skill.combo then
                                skill.effect = '<div style="background:' .. getGames.games[gameg].colorbg .. ';border-radius:5px;float:left;margin-right:5px">Combo</div> ' .. skill.effect
                            elseif skill.smirk then
                                skill.effect = skill.effect .. ' <span style="background:' .. getGames.games[gameg].statb .. ';border-radius:5px;padding:3px">Smirk</span> ' .. skill.smirk
                            end
                        end
                        if v2 == "" then
                            skillcell = ""
                            effect = noskill()
                        elseif not skill then
                            skillcell = ""
                            effect = noskill(v2, gamed)
                        elseif skill then
                            if k1 % 2 == 0 then
                                effect = styles.effect2 .. skill.effect
                            else
                                effect = styles.effect1 .. skill.effect
                            end
                            if skill.name then v2 = skill.name end
                            skillcell = styles.skill .. v2
                        end
                        result = result .. skillcell .. effect
                    elseif k2 % 2 == 0 then
                        if v2 == "I" or v2 == "i" then
                            result = result .. '<div style="float:right;background:#696969;border-radius:15px;padding:0 10px">Inheritable Skill</div>'
                        elseif v2 == "R" or v2 == "r" then
                            result = result .. '<div style="float:right;background:#8E283D;border-radius:15px;padding:0 10px">[[Misc Skills#Rumor Magic|<span style="color:#fff">Rumor Skill</span>]]</div>'
                        else
                            result = result
                        end
                    end
                end
            end
        elseif gameg == "dcbrb" or gameg == "childlight" or gameg == "childwhite" then -- skill - element - cost - effect
            result = result .. styles.skill .. "Skill" .. styles.skillc .. "Element" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
            for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" then
                    skillcell = ""
                    skille = ""
                    cost = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    skille = ""
                    cost = ""
                    effect = noskill(v, gamed)
                elseif skill then
                    if k % 2 == 0 then
                        effect = styles.effect2 .. skill.effect
                        skille = styles.cost2 .. skill.element
                        cost = styles.cost2 .. skill.cost
                    else
                        effect = styles.effect1 .. skill.effect
                        skille = styles.cost1 .. skill.element
                        cost = styles.cost1 .. skill.cost
                    end
                    if skill.name then v = skill.name end
                    skillcell = styles.skill .. v
                end
                result = result .. skillcell .. skille .. cost .. effect
            end
        elseif gameg == "smtim" or gameg == "ab" or gameg == "p1" or gameg == "p2is" or gameg == "p2ep" then -- rank - skill - cost - effect
            result = result .. styles.skill
            if gameg == "smtim" then
                result = result .. "Level" .. styles.skillc .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect"
            elseif gameg == "ab" then
                result = result .. "Level" .. styles.skillc .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Range" .. styles.skillc .. "Power" .. styles.skillc .. "Target" .. styles.skillc .. "Effect"
            else
                result = result .. "Rank" .. styles.skillc .. "Skill" .. styles.skillc .. "Effect"
            end
            for k1, v1 in ipairs(mw.text.split(prop.skills, "\n")) do
                for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do
                    if k2 > 2 then
                        break
                    elseif k2 % 2 == 1 then
                        if v2 == "M" or v2 == "m" then
                            v2 = '[[Mutation|<span style="color:#fff">Mutation</span>]]'
                        elseif v2 == "R" or v2 == "r" then
                            v2 = '[[Misc Skills#Rumor Magic|<span style="color:#fff">Rumor</span>]]'
                        else
                            v2 = v2
                        end
                        result = result .. styles.skill .. v2
                    elseif k2 % 2 == 0 then
                        skill = data.skills[v2]
                        if not skill then
                            alias = data.aliases[v2]
                            if alias then
                                v2 = alias
                                skill = data.skills[v2]
                            end
                        end
                        if v2 == "" then
                            skillcell = ""
                            cost = ""
                            range = ""
                            power = ""
                            target = ""
                            effect = noskill()
                        elseif not skill then
                            skillcell = ""
                            cost = ""
                            range = ""
                            power = ""
                            target = ""
                            effect = noskill(v2, gamed)
                        elseif skill then
                            if k1 % 2 == 0 then
                                if gameg == "smtim" or gameg == "ab" then
                                    cost = styles.cost2 .. skill.cost
                                else
                                    cost = ""
                                end
                                if gameg == "ab" then
                                    range = styles.cost2 .. skill.range
                                    power = styles.cost2 .. skill.power
                                    target = styles.cost2 .. skill.target
                                else
                                    range = ""
                                    power = ""
                                    target = ""
                                end
                                effect = styles.effect2 .. skill.effect
                            else
                                if gameg == "smtim" or gameg == "ab" then
                                    cost = styles.cost1 .. skill.cost
                                else
                                    cost = ""
                                end
                                if gameg == "ab" then
                                    range = styles.cost1 .. skill.range
                                    power = styles.cost1 .. skill.power
                                    target = styles.cost1 .. skill.target
                                else
                                    range = ""
                                    power = ""
                                    target = ""
                                end
                                effect = styles.effect1 .. skill.effect
                            end
                            if skill.name then v2 = skill.name end
                            skillcell = styles.skillc .. v2
                        end
                        result = result .. skillcell .. cost .. range .. power .. target .. effect
                    end
                end
            end
        elseif gameg == "majin1" then -- skill - cost - power - range - target - effect
            result = result .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Power" .. styles.skillc .. "Range" .. styles.skillc .. "Target" .. styles.skillc .. "Effect"
            for k, v in ipairs(mw.text.split(prop.skills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" then
                    skillcell = ""
                    cost = ""
                    power = ""
                    range = ""
                    target = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    cost = ""
                    power = ""
                    range = ""
                    target = ""
                    effect = noskill(v, gamed)
                elseif skill then
                    if k % 2 == 0 then
                        cost = styles.cost2 .. skill.cost
                        power = styles.cost2 .. skill.power
                        range = styles.cost2 .. skill.range
                        target = styles.cost2 .. skill.target
                        effect = styles.effect2 .. skill.effect
                    else
                        cost = styles.cost1 .. skill.cost
                        power = styles.cost1 .. skill.power
                        range = styles.cost1 .. skill.range
                        target = styles.cost1 .. skill.target
                        effect = styles.effect1 .. skill.effect
                    end
                    if skill.name then v = skill.name end
                    skillcell = styles.skill .. v
                end
                result = result .. skillcell .. cost .. power .. range .. target .. effect
            end
        else -- skill - cost - effect - level (default List of skills table order)
            result = result .. styles.skill .. "Skill"
            if (gameg == "smt4" or gameg == "smt4a" or gameg == "smt5" or gameg == "smt5v" or gameg == "sh2") and prop.guest == "1" then
                result = result .. styles.skillc .. "Effect" .. styles.skillc .. "Level"
            elseif gameg == "ldx2" then
                result = result .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Archetype"
            elseif gameg == "metaphor" then
                result = result .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Rank"
            else
                result = result .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Level"
            end
            for k1, v1 in ipairs(mw.text.split(prop.skills, "\n")) do -- Any entry on new line within "Skills" parameter is treated as new skill name.
                for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do -- Entry after backslash after skill name is treated as "level" for learning new skill per level gain. Any entry starting from second backslash on the same line is ignored until a new line.
                    if k2 > 2 then
                        break
                    elseif k2 % 2 == 1 then -- this checks level (false) or skill name (true) divided by the backslash.
                        skill = data.skills[v2] -- now v2 represents skill name.
                        if not skill then
                            alias = data.aliases[v2]
                            if alias then
                                v2 = alias
                                skill = data.skills[v2]
                            end
                        end
                        if v2 == "" then
                            skillcell = ""
                            cost = ""
                            effect = noskill()
                        elseif not skill then
                            skillcell = ""
                            cost = ""
                            effect = noskill(v2, gamed)
                        elseif skill then
                            if gameg == "smt3" then
                                if skill.cost == "Convo" then
                                    cost = '<abbr title="Active conversational skill without HP or MP cost. Ineffective to Corpus, Haunt, Wilder, Foul, Light-tendency demons, bosses and all enemies in Labyrinth of Amala.">Convo</abbr>'
                                elseif skill.cost == "Interrupt" then
                                    cost = '<abbr title="Interruption skill is only triggered when certain conversational effect occurs.">Interrupt</abbr>'
                                else
                                    cost = skill.cost
                                end
                            else
                                cost = skill.cost
                            end
                            if gameg == "p5" or gameg == "p5r" or gameg == "p5s" or gameg == "p5x" then
                                if string.match(skill.cost, "HP") then
                                    cost = '<span style="color:' .. getGames.games[gameg].hp2 .. '">' .. skill.cost .. "</span>" -- tints cyan for phys skill
                                elseif string.match(skill.cost, "SP") then
                                    cost = '<span style="color:' .. getGames.games[gameg].mp2 .. '">' .. skill.cost .. "</span>" -- tints pink for magic skill
                                end
                            end
                            if skill.smirk then skill.effect = skill.effect .. ' <span style="background:' .. getGames.games[gameg].statb .. ';border-radius:5px;padding:3px">Smirk</span> ' .. skill.smirk end
                            if skill.chaineffect then
                                for index, child in ipairs(skill.chaineffect) do
                                    skill.effect = skill.effect .. string.format('\n<span style="background:' .. getGames.games[gameg].colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">%s:</span>', child[1]) .. " " .. child[2] .. "\n"
                                end
                            end
                            if skill.conditional then
                                for index, child in ipairs(skill.conditional) do
                                    skill.effect = skill.effect .. string.format('\n<span style="background:' .. getGames.games[gameg].colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">%s:</span>', child[1]) .. " " .. child[2] .. "\n"
                                    if child.chaineffect then
                                        for index, value in ipairs(child.chaineffect) do
                                            skill.effect = skill.effect .. string.format('<br><span style="background:' .. getGames.games[gameg].colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">%s:</span>', value[1]) .. " " .. value[2] .. "\n"
                                        end
                                    end
                                end
                            end
                            if skill.boostlevel then
                                for level, value in ipairs(skill.boostlevel) do
                                    if string.len(value) > 0 then skill.effect = skill.effect .. string.format('<br><span style="background:' .. getGames.games[gameg].colorb .. ';border-radius:5px;padding:3px;font-weight:bold;">Level %d:</span>', level - 1) .. " " .. value end
                                end
                            end
                            if k1 % 2 == 0 then
                                cost = styles.cost2 .. cost
                                effect = styles.effect2 .. skill.effect
                            else
                                cost = styles.cost1 .. cost
                                effect = styles.effect1 .. skill.effect
                            end
                            if skill.name then v2 = skill.name end
                            skillcell = styles.skill .. v2
                        end
                        if not ((gameg == "smt4" or gameg == "smt4a" or gameg == "smt5" or gameg == "smt5v" or gameg == "sh2") and prop.guest == "1") then
                            result = result .. skillcell .. cost .. effect
                        else
                            result = result .. skillcell .. effect
                        end
                    elseif k2 % 2 == 0 then -- this checks level (ture) or skill name (false) divided by the backslash.
                        if
                            v2 == "i"
                            or v2 == "I"
                            or v2 == "innate"
                            or v2 == "default"
                            or v2 == "Default" -- now v2 represents skill level.
                        then
                            v2 = "Innate"
                        elseif v2 == "Ac" then
                            v2 = '<span style="font-weight:bold">Common</span>'
                        elseif v2 == "Aa" then
                            v2 = '<span style="color:red;font-weight:bold;">Aragami<br>(Awaken)</span>'
                        elseif v2 == "Ap" then
                            v2 = '<span style="color:yellow;font-weight:bold;">Protector<br>(Awaken)</span>'
                        elseif v2 == "Ay" then
                            v2 = '<span style="color:#f5f;font-weight:bold;">Psychic<br>(Awaken)</span>'
                        elseif v2 == "Ae" then
                            v2 = '<span style="color:#5ff;font-weight:bold;">Elementalist<br>(Awaken)</span>'
                        elseif v2 == "Ga" then
                            v2 = '<span style="color:red;font-weight:bold;">Aragami<br>(Gacha)</span>'
                        elseif v2 == "Gp" then
                            v2 = '<span style="color:yellow;font-weight:bold;">Protector<br>(Gacha)</span>'
                        elseif v2 == "Gy" then
                            v2 = '<span style="color:#f5f;font-weight:bold;">Psychic<br>(Gacha)</span>'
                        elseif v2 == "Ge" then
                            v2 = '<span style="color:#5ff;font-weight:bold;">Elementalist<br>(Gacha)</span>'
                        end
                        if k1 % 2 == 0 then -- this checks even (true) or odd (false) number row.
                            result = result .. styles.cost2 .. v2 -- "v2" represents "Level" within "Skills" parameter on each new line after the backslash.
                        else
                            result = result .. styles.cost1 .. v2
                        end
                    end
                end
            end
        end
        result = result .. "\n|}"
    end
    if prop.fskills then
        result = result .. styles.table2 .. styles.h
        if gameg == "metaphor" then
            result = result .. 'colspan="6"'
        else
            result = result .. 'colspan="5"'
        end
        if gameg == "p2is" or gameg == "p2ep" then
            result = result .. "|[[List of " .. gamegn .. " Fusion Spells|" .. styles.spanc .. "Unique Fusion Spells</span>]]" .. styles.skill .. "Skill" .. styles.skillc .. "Effect" .. styles.skillc .. "Order/Skill/Persona"
            for k, v in ipairs(mw.text.split(prop.fskills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" then
                    skillcell = ""
                    cost = ""
                    effect = noskill()
                elseif not skill then
                    skillcell = ""
                    cost = ""
                    effect = noskill(v, gamed)
                elseif skill then
                    if k % 2 == 0 then
                        effect = styles.effect2 .. skill.effect
                    else
                        effect = styles.effect1 .. skill.effect
                    end
                    if skill.name then v = skill.name end
                    skillcell = styles.skill .. v
                    cost = styles.order .. skill.cost
                end
                result = result .. skillcell .. effect .. cost
            end
        elseif gameg == "p3" or gameg == "p3re" then
            local cost, effect, pre
            if not data.skills[prop.fskills] then
                cost = ""
                effect = noskill(prop.fskills, gamed)
                pre = ""
                fskills = ""
            else
                cost = styles.cost1 .. data.skills[prop.fskills].cost
                effect = styles.effect1 .. data.skills[prop.fskills].effect
                pre = styles.cost1 .. data.skills[prop.fskills].pre
                prop.fskills = styles.skill .. prop.fskills
            end
            result = result .. "|[[List of Persona 3 Skills#Fusion Spells|" .. styles.spanc .. 'Fusion Spell</span>]] <abbr title="Persona 3, FES and Reload only; Portable uses items and does not require the participating Personas to be in stock">*</abbr>' .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. '<abbr title="Persona 3, FES and Reload only">Prerequisite</abbr>' .. prop.fskills .. cost .. effect .. pre
        elseif gameg == "metaphor" then
            result = result .. "|[[List of Metaphor: ReFantazio Skills#Synthesis Skills|" .. styles.spanc .. "Synthesis Skills</span>]]" .. styles.skill .. "Skill" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Skill prerequisite" .. styles.skillc .. "First ally" .. styles.skillc .. "Second ally"
            for k, v in ipairs(mw.text.split(prop.fskills, "\n")) do
                skill = data.syntheses[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.syntheses[v]
                    end
                end
                if v == "" then
                    result = result .. noskill()
                elseif not skill then
                    result = result .. noskill(v, gamed)
                elseif skill then
                    if skill.name then v = skill.name end
                    if k % 2 == 0 then
                        result = result .. styles.skill .. v .. styles.cost2 .. skill.cost .. styles.effect2 .. skill.effect .. styles.cost2 .. skill.required .. styles.cost2 .. skill.first .. styles.cost2 .. skill.second
                    else
                        result = result .. styles.skill .. v .. styles.cost1 .. skill.cost .. styles.effect1 .. skill.effect .. styles.cost1 .. skill.required .. styles.cost1 .. skill.first .. styles.cost1 .. skill.second
                    end
                end
            end
        elseif gameg == "childlight" then
            result = result .. "|[[List of DemiKids Light/Dark Version Skills#Combos|" .. styles.spanc .. "Combos</span>]]" .. styles.skill .. "Combo" .. styles.skillc .. "Element" .. styles.skillc .. "Cost" .. styles.skillc .. "Effect" .. styles.skillc .. "Partner"
            for k1, v1 in ipairs(mw.text.split(prop.fskills, "\n")) do
                for k2, v2 in ipairs(mw.text.split(v1 .. "\\", "\\")) do -- Entry after backslash after skill name is treated as "partner"
                    if k2 > 2 then
                        break
                    elseif k2 % 2 == 1 then -- this checks partner (false) or skill name (true) divided by the backslash.
                        skill = data.skills[v2] -- now v2 represents skill name.
                        if not skill then
                            alias = data.aliases[v2]
                            if alias then
                                v2 = calias
                                skill = data.skills[v2]
                            end
                        end
                        if v2 == "" then
                            skillcell = ""
                            skille = ""
                            cost = ""
                            effect = noskill()
                        elseif not skill then
                            skillcell = ""
                            skille = ""
                            cost = ""
                            effect = noskill(v2, gamed)
                        elseif skill then
                            skille = skill.element
                            cost = skill.cost
                            effect = skill.effect
                            if k1 % 2 == 0 then
                                skille = styles.cost2 .. skille
                                cost = styles.cost2 .. cost
                                effect = styles.effect2 .. effect
                            else
                                skille = styles.cost1 .. skille
                                cost = styles.cost1 .. cost
                                effect = styles.effect1 .. effect
                            end
                            if skill.name then v2 = skill.name end
                            skillcell = styles.skill .. v2
                        end
                        result = result .. skillcell .. skille .. cost .. effect
                    elseif k2 % 2 == 0 then -- this checks partner (ture) or skill name (false) divided by the backslash.
                        if v2 == "" or not v2 then -- now v2 represents partner.
                            v2 = ""
                        end
                        if k1 % 2 == 0 then -- this checks even (true) or odd (false) number row.
                            result = result .. styles.cost2 .. v2 -- "v2" represents "partner" within "Skills" parameter on each new line after the backslash.
                        else
                            result = result .. styles.cost1 .. v2
                        end
                    end
                end
            end
        end
        result = result .. "\n|}"
    end
    if prop.pskills then
        if gameg == "smtsj" then
            result = result .. styles.table2 .. styles.h .. "colspan=3|D-Source Skills"
        else
            result = result .. styles.table2 .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills#Passive Skills|" .. styles.spanc .. "Passive Skills</span>]]"
        end
        result = result .. '\n|-style="border:0"\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|'
        for k, v in ipairs(mw.text.split(prop.pskills, "\n")) do
            skill = data.skills[v]
            if not skill then
                alias = data.aliases[v]
                if alias then
                    v = alias
                    skill = data.skills[v]
                end
            end
            if v == "" or v == "-" or v == "--" then
                skillcell = ""
            elseif not skill then
                skillcell = styles.skill3 .. '"|' .. v
            else
                if skill.name then v = skill.name end
                skillcell = styles.skill3 .. '" title="Cost: ' .. skill.cost .. "; " .. skill.effect .. '"|' .. v
            end
            if k % 3 == 1 then
                result = result .. "\n|-" .. skillcell
            else
                result = result .. skillcell
            end
        end
        result = result .. "\n|}"
    end
    if (gameg == "smtsj" or gameg == "desu1" or gameg == "desu2") and (prop.askills or prop.apskills) then
        if gameg == "smtsj" then
            result = result .. styles.table2 .. styles.h .. "colspan=3|Item Drops"
        else
            result = result .. styles.table2 .. styles.h .. "colspan=3|List of Auction Skills"
        end
        result = result .. '\n|-style="border:0"\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|\n|style="padding:0;width:33%"|'
        if prop.askills then
            for k, v in ipairs(mw.text.split(prop.askills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" or v == "-" or v == "--" then
                    skillcell = ""
                elseif not skill then
                    skillcell = styles.skill3 .. '"|' .. v
                else
                    if skill.name then v = skill.name end
                    skillcell = styles.skill3 .. '" title="Cost: ' .. skill.cost .. "; " .. skill.effect .. '"|' .. v
                end
                if k % 3 == 1 then
                    result = result .. "\n|-" .. skillcell
                else
                    result = result .. skillcell
                end
            end
        end
        if prop.apskills then
            for k, v in ipairs(mw.text.split(prop.apskills, "\n")) do
                skill = data.skills[v]
                if not skill then
                    alias = data.aliases[v]
                    if alias then
                        v = alias
                        skill = data.skills[v]
                    end
                end
                if v == "" or v == "-" or v == "--" then
                    skillcell = ""
                elseif not skill then
                    skillcell = styles.skill3 .. '"|' .. v
                else
                    if skill.name then v = skill.name end
                    skillcell = styles.skill3 .. '" title="Cost: ' .. skill.cost .. "; " .. skill.effect .. '"|' .. v
                end
                if k % 3 == 1 then
                    result = result .. "\n|-" .. skillcell
                else
                    result = result .. skillcell
                end
            end
        end
        result = result .. "\n|}"
    end
    if gameg == "p2ep" and prop.unknown then
        result = result .. styles.table2 .. styles.h .. 'colspan="2"|[[Unknown Power|' .. styles.spanc .. "Unknown Power</span>]]" .. styles.skill
        prop.unknown = prop.unknown:lower()
        if prop.unknown == "attack type" or prop.unknown == "attack-type" or prop.unknown == "attack" then
            result = result .. "Attack Type" .. styles.cost1 .. 'Deals <abbr title="Equipper has ' .. "'Great'" .. ' affinity with the Persona">500</abbr> or <abbr title="Equipper has ' .. "'Good'" .. ' affinity with the Persona">250</abbr> non-elemental damage to all enemies.'
        elseif prop.unknown == "defense type" or prop.unknown == "defense-type" or prop.unknown == "defense" then
            result = result .. "Defense Type" .. styles.cost1 .. '<abbr title="Equipper has ' .. "'Great'" .. ' affinity with the Persona">Reflects</abbr> or <abbr title="Equipper has ' .. "'Good'" .. ' affinity with the Persona">nullifies</abbr> the incoming attack.'
        elseif prop.unknown == "assist type" or prop.unknown == "assist-type" or prop.unknown == "assist" then
            result = result .. "Assist Type" .. styles.cost1 .. 'Bestows Tarukaja + Makakaja <abbr title="Only applicable when the equipper has ' .. "'Great'" .. ' affinity with the Persona">(or Rakukaja + Samakaja in addition)</abbr>'
        elseif prop.unknown == "recovery type" or prop.unknown == "recovery-type" or prop.unknown == "recovery" then
            result = result .. "Recovery Type" .. styles.cost1 .. 'Fully recovers HP <abbr title="Only applicable when the equipper has ' .. "'Great'" .. ' affinity with the Persona">(or removes ailment in addition)</abbr>.'
        elseif prop.unknown == "revival type" or prop.unknown == "revival-type" or prop.unknown == "revival" then
            result = result .. "Revival Type" .. styles.cost1 .. 'Revives from unconscious with <abbr title="Equipper has ' .. "'Great'" .. ' affinity with the Persona">full</abbr> or <abbr title="Equipper has ' .. "'Good'" .. ' affinity with the Persona">1/4</abbr> HP.'
        elseif prop.unknown == "special type" or prop.unknown == "special-type" or prop.unknown == "special" then
            result = result .. "Special Type" .. styles.cost1 .. "Eliminates all enemies when the user is unconscious."
        end
        result = result .. "\n|}"
    end
    if gameg == "p5s" and prop.cskills then
        result = result .. styles.table2 .. styles.h .. 'colspan="4" style="background-color: ' .. getGames.games[gameg].colorb .. ";background: linear-gradient(120deg, " .. getGames.games[gameg].colorb .. " 40%, #000 40.1%, #000 41%, #fff 41.1%, #fff 59%, #000 59.1%, #000 60%, " .. getGames.games[gameg].colorb .. ' 60.1%"|[[Combo Attacks|<span style="color:black;text-shadow:-3px 3px 3px #0ff">Combo Attacks</span>]]'
        result = result .. styles.skill .. "Combo Attack" .. styles.skillc .. "Button Input" .. styles.skill3 .. '" colspan=2|Skills'
        for k1, v1 in ipairs(mw.text.split(prop.cskills, "\n")) do
            skillcell = ""
            local v_cnt = 0
            for k in string.gmatch(v1, "\\") do
                v_cnt = v_cnt + 1
            end
            for k2, v2 in ipairs(mw.text.split(v1, "\\")) do
                if k2 > 1 then
                    skill = data.skills[v2]
                    if not skill then
                        alias = data.aliases[v2]
                        if alias then
                            v2 = alias
                            skill = data.skills[v2]
                        end
                    end
                    local resv2, resdec
                    if v2 == "" or v2 == "-" or v2 == "--" then
                        resv2 = '<span style="font-weight:bold;">-</span>'
                    elseif not skill then
                        resv2 = '<span style="color:red;font-weight:bold;font-size:1.2em">Invalid skill name of "' .. v2 .. '". You may correct the skill name or modify [[module:Skills/' .. gamed .. "]] if needed.</span>"
                    else
                        if skill.name then v2 = skill.name end
                        resv2 = '<span style="font-weight:bold;>' .. v2 .. "</span>"
                        resdec = skill.effect
                    end
                    if k2 > 2 then
                        if k2 % 2 == 0 then
                            if resdec then
                                skillcell = skillcell .. "\n|-" .. styles.effect1 .. resv2 .. styles.effect1 .. resdec
                            else
                                skillcell = skillcell .. "\n|-" .. styles.effect1p .. resv2
                            end
                        else
                            if resdec then
                                skillcell = skillcell .. "\n|-" .. styles.effect2 .. resv2 .. styles.effect2 .. resdec
                            else
                                skillcell = skillcell .. "\n|-" .. styles.effect2p .. resv2
                            end
                        end
                    else
                        if resdec then
                            skillcell = skillcell .. styles.effect1 .. resv2 .. styles.effect1 .. resdec
                        else
                            skillcell = skillcell .. styles.effect1p .. resv2
                        end
                    end
                else
                    v2 = v2:gsub("^%l", string.upper)
                    if not v2 then v2 = "" end
                    local ca = data.cattacks[v2]
                    result = result .. styles.skill2 .. 'rowspan="' .. v_cnt .. '"|' .. v2 .. styles.cost3 .. 'rowspan="' .. v_cnt .. '"|' .. wikitext(ca.buttons)
                end
            end
            result = result .. skillcell
        end
        result = result .. "\n|}"
    end
    if gameg == "childlight" and prop.power ~= "" then
        local pelement, peffect
        if not data.skills[prop.power] then
            prop.power = noskill(prop.power, gamed)
            pelement = ""
            peffect = ""
        else
            pelement = styles.cost1 .. data.skills[prop.power].element
            peffect = styles.effect1 .. data.skills[prop.power].effect
            prop.power = styles.skill .. prop.power
        end
        result = result .. styles.table2 .. styles.h .. "colspan=3|[[List of " .. gamegn .. " Skills##Powers|" .. styles.spanc .. "Power</span>]]\n|-" .. styles.skill .. "Power" .. styles.skillc .. "Type" .. styles.skillc .. "Effect" .. prop.power .. pelement .. peffect .. "\n|}"
    end
    return result
end

return p
