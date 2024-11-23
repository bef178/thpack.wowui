local A = A;

A.getClassColor = (function()
    local classColors = {
        ["MAGE"] = "#3ec5e9",
        ["PRIEST"] = "#fefefe",
        ["WARLOCK"] = "#8686ec",
        ["DRUID"] = "#fe7b09",
        ["ROGUE"] = "#fef367",
        ["HUNTER"] = "#a9d271",
        ["SHAMAN"] = "#006fdc",
        ["PALADIN"] = "#f38bb9",
        ["WARRIOR"] = "#c59a6c",
    };
    return function(className)
        return classColors[String.toUpper(className)];
    end;
end)();

-- A.checkPlayerAttacking
A.getAttacking = (function()
    local isAttacking = false;
    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTER_COMBAT");
    f:RegisterEvent("PLAYER_LEAVE_COMBAT");
    f:SetScript("OnEvent", function()
        local event = event;
        if (event == "PLAYER_ENTER_COMBAT") then
            isAttacking = true;
        elseif (event == "PLAYER_LEAVE_COMBAT") then
            isAttacking = false;
        end
    end);
    return function()
        return isAttacking;
    end;
end)();

-- A.getPlayerSpell
A.getSpellByName = function(name)
    local getSpellIndexByName = function(name)
        for tabIndex = GetNumSpellTabs(), 1, -1 do
            local tabName, tabTexture, spellOffset, spellCount = GetSpellTabInfo(tabIndex)
            for i = spellOffset + spellCount, spellOffset + 1, -1 do
                local spellName, spellRank = GetSpellName(i, 'spell');
                local spellNameWithRank = nil;
                if (spellRank) then
                    spellNameWithRank = spellName .. "(" .. spellRank .. ")";
                end
                if (name == spellName or (spellNameWithRank and name == spellNameWithRank)) then
                    return i, spellName, spellRank, spellNameWithRank;
                end
            end
        end
    end;

    local spellIndex, spellName, spellRank, spellNameWithRank = getSpellIndexByName(name);
    if (not spellIndex) then
        return;
    end

    -- TODO spell mana
    -- TODO spell reagent
    return {
        spellId = nil,
        spellIndex = spellIndex,
        spellBookType = "spell",
        spellName = spellName,
        spellRank = spellRank,
        spellNameWithRank = spellNameWithRank,
        spellTexture = GetSpellTexture(spellIndex, "spell"),
    };
end;

-- all temporary states listed
A.getSpellCastStates = function(spell)
    if (not spell) then
        return;
    end

    local startTime, duration, enabled = GetSpellCooldown(spell.spellIndex, spell.spellBookType);

    local timeToCooldown;
    if (enabled) then
        timeToCooldown = startTime + duration - GetTime();
        if (timeToCooldown < 0) then
            timeToCooldown = 0;
        end
    else
        timeToCooldown = 0;
    end

    -- TODO queuing, casting, channeling
    -- TODO num charges
    return {
        timeToCooldown = timeToCooldown,
    };
end;

A.getUnitBuffBySpell = function(unit, spell)
    if (not spell or not spell.spellTexture) then
        return;
    end
    if (unit == "player") then
        for i = 0, 63, 1 do
            local buffTexture = GetPlayerBuffTexture(i);
            if (buffTexture and buffTexture == spell.spellTexture) then
                -- return i;
                local buff = {
                    playerBuffIndex = i,
                    buffTexture = buffTexture,
                    buffNumStacks = GetPlayerBuffApplications(i),
                    buffTimeToLive = GetPlayerBuffTimeLeft(i) or 0,
                };
                local _, lastsUntilCancelled = GetPlayerBuff(i);
                buff.buffLastsUntilCancelled = lastsUntilCancelled;
                return buff;
            end
        end
    else
        for i = 1, 64, 1 do
            local buffTexture, buffNumStacks = UnitBuff(unit, i);
            if (buffTexture and buffTexture == spell.spellTexture) then
                local buff = {
                    buffIndex = i,
                    buffTexture = buffTexture,
                    buffNumStacks = buffNumStacks,
                };
                return buff;
            end
        end
        for i = 1, 64, 1 do
            local buffTexture, buffNumStacks = UnitDebuff(unit, i);
            if (buffTexture and buffTexture == spell.spellTexture) then
                local buff = {
                    debuffIndex = i,
                    buffTexture = buffTexture,
                    buffNumStacks = buffNumStacks,
                };
                return buff;
            end
        end
    end
end;

A.getUnitBuff = function(unit, spell)
    if (not unit) then
        unit = "player"
    end
    if (not spell) then
        return;
    end
    for i = 1, 64, 1 do
        local buffTexture, buffNumStacks = UnitBuff(unit, i);
        if (buffTexture and buffTexture == spell.spellTexture) then
            local buff = {
                type = "buff",
                buffIndex = i,
                buffTexture = buffTexture,
                buffNumStacks = buffNumStacks,
            };
            return buff;
        end
    end
end;
