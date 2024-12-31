local A = A;

A.checkPlayerAttacking = (function()
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

A.getPlayerSpell = function(name)
    if (not name) then
        return;
    end
    for tabIndex = GetNumSpellTabs(), 1, -1 do
        local tabName, tabTexture, offset, size = GetSpellTabInfo(tabIndex);
        for i = offset + size, offset + 1, -1 do
            local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL);
            local spellNameWithRank = spellRank and (spellName .. "(" .. spellRank .. ")");
            if (name == spellName or name == spellNameWithRank) then
                -- TODO spell mana
                -- TODO spell reagent
                return {
                    spellId = nil,
                    spellBookType = BOOKTYPE_SPELL,
                    spellIndex = i,
                    spellName = spellName,
                    spellRank = spellRank,
                    spellNameWithRank = spellRank and (spellName .. "(" .. spellRank .. ")"),
                    spellTexture = GetSpellTexture(i, "spell"),
                };
            end
        end
    end
end;

-- list all temporary states
A.getPlayerSpellCastingState = function(spell)
    if (not spell) then
        return;
    end

    local startTime, duration, enabled = GetSpellCooldown(spell.spellIndex, spell.spellBookType);

    local spellTimeToCooldown;
    if (enabled) then
        spellTimeToCooldown = startTime + duration - GetTime();
        if (spellTimeToCooldown < 0) then
            spellTimeToCooldown = 0;
        end
    else
        spellTimeToCooldown = 0;
    end

    -- TODO queuing, casting, channeling
    -- TODO num charges
    return {
        type = "casting",
        spellTimeToCooldown = spellTimeToCooldown,
    };
end;

A.getPlayerSpellCooldownTime = function(spell)
    local stat = A.getPlayerSpellCastingState(spell);
    return stat and stat.spellTimeToCooldown or 14 * 24 * 60 * 60;
end;

A.getPlayerActiveStance = function()
    local n = GetNumShapeshiftForms(); -- NUM_SHAPESHIFT_SLOTS
    for i = 1, n, 1 do
        local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
        if (isActive) then
            return {
                type = "stance",
                stanceIndex = i,
                stanceName = name,
                stanceTexture = texture,
            };
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
    if (unit == "player") then
        for i = 0, 63, 1 do
            local j, lastsUntilCancelled = GetPlayerBuff(i, "HELPFUL");
            if (j < 0) then
                break;
            end
            local buffTexture = GetPlayerBuffTexture(j);
            if (buffTexture and buffTexture == spell.spellTexture) then
                local buff = {
                    type = "buff",
                    playerBuffIndex = j,
                    buffTexture = buffTexture,
                    buffNumStacks = GetPlayerBuffApplications(j),
                    buffTimeToLive = GetPlayerBuffTimeLeft(j),
                    buffLastsUntilCancelled = lastsUntilCancelled,
                };
                return buff;
            end
        end
        return;
    end
    for i = 1, 64, 1 do
        local buffTexture, buffNumStacks = UnitBuff(unit, i);
        if (buffTexture and buffTexture == spell.spellTexture) then
            return {
                type = "buff",
                buffIndex = i,
                buffTexture = buffTexture,
                buffNumStacks = buffNumStacks,
            };
        end
    end
end;

A.getUnitDebuff = function(unit, spell)
    if (not unit) then
        unit = "player"
    end
    if (not spell) then
        return;
    end
    for i = 1, 64, 1 do
        local buffTexture, buffNumStacks = UnitDebuff(unit, i);
        if (buffTexture and buffTexture == spell.spellTexture) then
            return {
                type = "debuff",
                buffIndex = i,
                buffTexture = buffTexture,
            };
        end
    end
end;

A.getUnitHp = function(unit)
    local hp = UnitHealth(unit);
    local maxHp = UnitHealthMax(unit);
    return hp, maxHp, hp / maxHp;
end;

A.getUnitMp = function(unit)
    local mp = UnitMana(unit);
    local maxMp = UnitManaMax(unit);
    return mp, maxMp, mp / maxMp;
end;

-- TargetFrame_CheckFaction()
-- UnitIsEnemy()
-- UnitIsFriend()
-- UnitIsDead()
-- UnitIsGhost()
-- UnitReaction()
-- UnitSelectionColor()
A.getUnitNameColor = function(unit)
    if (not UnitPlayerControlled(unit) and UnitIsTapped(unit)) then
        return Color.pick("darkgray");
    end

    -- tuned color as text fore color
    local red = "#cc3333";
    local green = "#339933";
    local blue = "#5582fa";
    local yellow = "#eeee11";

    if (UnitIsPlayer(unit)) then
        -- horde against alliance
        if (UnitCanAttack(unit, "player")) then
            if (UnitCanAttack("player", unit)) then
                return red;
            else
                -- only he can attack! (in enemy-occupied territory)
                return Color.pick("darkorange");
            end
        elseif (UnitCanAttack("player", unit)) then
            -- i feel safe
            return yellow;
        else
            -- friend
            if (UnitIsPVP(unit)) then
                return green;
            else
                return blue;
            end
        end
    else
        -- npc or pet or summonee
        if (UnitIsEnemy("player", unit)) then
            return red;
        elseif (UnitIsFriend("player", unit)) then
            return green;
        else
            return yellow;
        end
    end
end;

------------------------------------------------------------

A.inCombat = function(unit)
    if (not unit) then
        unit = "player";
    end
    return UnitAffectingCombat(unit);
end;

A.inCooldown = function(spell)
    return A.getPlayerSpellCooldownTime(spell) >= 0;
end;

A.buffed = function(spell, unit)
    return A.getUnitBuff(unit, spell);
end;

A.debuffed = function(spell, unit)
    return A.getUnitDebuff(unit, spell);
end;

A.canAssist = function(unit)
    if (not unit) then
        unit = "target";
    end
    if (not UnitExists(unit)) then
        return;
    end
    return UnitCanAssist("player", unit);
end;

A.canAttack = function(unit)
    if (not unit) then
        unit = "target";
    end
    if (not UnitExists(unit)) then
        return;
    end
    return UnitCanAttack("player", unit);
end;

A.cast = function(spell, spellTargetUnit)
    CastSpellByName(spell.spellNameWithRank, spellTargetUnit == "player");
end;
