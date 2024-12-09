local CastSpellByName = CastSpellByName;

local A = A;
local getPlayerSpell = A.getPlayerSpell;
local getPlayerSpellCooldownTime = A.getPlayerSpellCooldownTime;
local getUnitBuff = A.getUnitBuff;
local pda = pda;

local targetsAliveEnemy = function()
    return UnitExists("target") and not UnitIsDead("target") and UnitIsEnemy("player", "target");
end;

local getTargetHealthProportion = function()
    if (not UnitExists("target")) then
        return;
    end
    return UnitHealth("target") / UnitHealthMax("target");
end;

local hasActiveShapeshiftForm = function()
    local n = GetNumShapeshiftForms(); -- NUM_SHAPESHIFT_SLOTS
    for i = 1, n, 1 do
        local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
        if (isActive) then
            return true;
        end
    end
    return false;
end;

local build = pda:newBuild();
build.name = "pala-a";
build.description = "prot pala solo aoe, for turtle wow";
build.slotModels = {};
build.creators = {};

function build:createSlotModels()
    Array.clear(build.slotModels);
    for _, fn in ipairs(build.creators) do
        if (fn) then
            local a = fn();
            if (a) then
                for _, slotModel in ipairs(a) do
                    Array.add(build.slotModels, slotModel);
                end
            end
        end
    end
    return build.slotModels;
end

function build:updateSlotModels()
    for _, slotModel in ipairs(build.slotModels) do
        if (slotModel.onElapsed) then
            slotModel.onElapsed();
        end
    end
end

-- 惩罚光环/庇护祝福/神圣之盾
-- 这三者是最主要的反伤手段，合一为第一顺位
-- 另，A怪时惩罚光环优于圣洁光环
Array.add(build.creators, function()
    local spellRetributionAura = getPlayerSpell("Retribution Aura");
    local spellBlessingOfSanctuary = getPlayerSpell("Blessing of Sanctuary");
    local spellHolyShield = getPlayerSpell("Holy Shield");
    if (not spellRetributionAura and not spellBlessingOfSanctuary and not spellHolyShield) then
        return;
    end

    local model = pda:newSlotModel();
    model.targetingPlayer = true;
    model.onClick = function(f, button)
        CastSpellByName(model.spell.spellNameWithRank, 1);
    end;

    local function onElapsedWithRetributionAura(model, elapsed)
        if (not spellRetributionAura) then
            model.visible = false;
            return;
        end

        local spell = spellRetributionAura;
        model.spell = spell;
        model.contentTexture = spell.spellTexture;

        if (hasActiveShapeshiftForm()) then
            model.visible = false;
            return;
        end

        local inCombat = UnitAffectingCombat("player");
        local onTarget = targetsAliveEnemy();
        if (not inCombat and not onTarget) then
            model.visible = false;
            return;
        end

        model.visible = true;

        local timeToCooldown = getPlayerSpellCooldownTime(spell);

        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.highlighted = (inCombat or onTarget) and (timeToCooldown < 0.1);
        return true;
    end

    local function onElapsedWithBlessingOfSanctuary(model, elapsed)
        if (not spellBlessingOfSanctuary) then
            model.visible = false;
            return;
        end

        local spell = spellBlessingOfSanctuary;
        model.spell = spell;
        model.contentTexture = spell.spellTexture;

        local buff = getUnitBuff("player", spell);
        if (buff and ((buff.buffTimeToLive or 0) > 10)) then
            -- safe active
            model.visible = false;
            return;
        end

        local inCombat = UnitAffectingCombat("player");
        local onTarget = targetsAliveEnemy();
        if (not inCombat and not onTarget) then
            model.visible = false;
            return;
        end

        model.visible = true;

        local timeToCooldown = getPlayerSpellCooldownTime(spell);

        model.affectingSpellTarget = not (not buff);
        model.timeToCooldown = timeToCooldown;
        model.ready = (timeToCooldown == 0);
        model.highlighted = (inCombat or onTarget) and (timeToCooldown < 0.1);
        return true;
    end

    local function onElapsedWithHolyShield(model, elapsed)
        if (not spellHolyShield) then
            model.visible = false;
            return;
        end

        local spell = spellHolyShield;
        model.spell = spell;
        model.contentTexture = spell.spellTexture;

        -- TODO check equipped shield

        local timeToCooldown = getPlayerSpellCooldownTime(spell);
        if (timeToCooldown > 1.5) then
            model.visible = false;
            return;
        end

        local inCombat = UnitAffectingCombat("player");
        local onTarget = targetsAliveEnemy();
        if (not inCombat and not onTarget) then
            model.visible = false;
            return;
        end

        model.visible = true;

        local buff = getUnitBuff("player", spell);

        model.affectingSpellTarget = not (not buff);
        model.timeToCooldown = timeToCooldown;
        model.ready = model.timeToCooldown == 0;
        model.highlighted = (inCombat or onTarget) and (timeToCooldown < 0.1);
        return true;
    end

    model.onElapsed = function(elapsed)
        return onElapsedWithRetributionAura(model, elapsed)
            or onElapsedWithBlessingOfSanctuary(model, elapsed)
            or onElapsedWithHolyShield(model, elapsed);
    end;

    local a = {};
    Array.add(a, model);
    return a;
end);

-- 奉献
-- 最主要的伤害手段，为第二顺位
Array.add(build.creators, function()
    local spell = getPlayerSpell("Consecration");
    if (not spell) then
        return;
    end

    local model = pda:newSlotModel();
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
    model.onClick = function(f, button)
        CastSpellByName(model.spell.spellNameWithRank);
    end;
    model.onElapsed = function(elapsed)
        local timeToCooldown = getPlayerSpellCooldownTime(spell);
        if (timeToCooldown > 1.5) then
            model.visible = false;
            return;
        end

        local inCombat = UnitAffectingCombat("player");
        if (not inCombat) then
            model.visible = false;
            return;
        end

        model.visible = true;

        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.highlighted = inCombat and (timeToCooldown < 0.1);
    end;

    local a = {};
    Array.add(a, model);
    return a;
end);

-- 光明圣印/智慧圣印/审判
-- 最主要的战时回复手段，为第三顺位
Array.add(build.creators, function()
    local function updateModelWithSeal(model, spell)
        local inCombat = UnitAffectingCombat("player");
        local onTarget = targetsAliveEnemy();
        if (not inCombat and not onTarget) then
            model.visible = false;
            return;
        end

        model.visible = true;

        local timeToCooldown = getPlayerSpellCooldownTime(spell);

        model.spell = spell;
        model.contentTexture = spell.spellTexture;
        model.targetingPlayer = true;
        model.timeToLive = nil;
        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.highlighted = false;
    end

    local function updateModelWithJudgement(model, spell, buff)
        if (not buff) then
            model.visible = false;
            return;
        end

        local timeToCooldown = getPlayerSpellCooldownTime(spell);
        if (timeToCooldown > 1.5) then
            model.visible = false;
            return;
        end

        local inCombat = UnitAffectingCombat("player");
        local onTarget = targetsAliveEnemy();
        if (not inCombat and not onTarget) then
            model.visible = false;
            return;
        end

        model.visible = true;

        -- TODO also show the seal icon
        model.spell = spell;
        model.contentTexture = spell.spellTexture;
        model.targetingPlayer = false;
        model.timeToLive = buff.buffTimeToLive;
        model.timeToCooldown = timeToCooldown;
        model.ready = onTarget and (timeToCooldown == 0);
        model.highlighted = false;
    end

    local spellJudgement = getPlayerSpell("Judgement");
    if (not spellJudgement) then
        return;
    end

    local spellSealOfLight = getPlayerSpell("Seal of Light"); -- lv 30
    local spellSealOfWisdom = getPlayerSpell("Seal of Wisdom"); -- lv 38
    if (spellSealOfLight and spellSealOfWisdom) then
        -- dual recovery strategy
        local sealOfLightModel = (function()
            local spell = spellSealOfLight;

            local model = pda:newSlotModel();
            model.spell = spell;
            model.contentTexture = spell.spellTexture;
            model.onClick = function(f, button)
                CastSpellByName(model.spell.spellNameWithRank, model.targetingPlayer);
            end;
            model.onElapsed = function(elapsed)
                local buff = getUnitBuff("player", spell);
                local targetDebuff = getUnitBuff("target", spell);
                local sowBuff = getUnitBuff("player", spellSealOfWisdom);
                local targetSowDebuff = getUnitBuff("target", spellSealOfWisdom);

                if (targetDebuff) then
                    if (buff) then
                        if (buff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = true;
                            -- TODO check health proportion and mana proportion then make recommendation
                        else
                            model.visible = false;
                            return;
                        end
                    elseif (sowBuff) then
                        if (sowBuff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = false;
                        else
                            model.visible = false;
                            return;
                        end
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                    end
                elseif (targetSowDebuff) then
                    if (buff) then
                        if (buff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = true;
                            model.highlighted = true;
                        else
                            model.visible = false;
                            return;
                        end
                    elseif (sowBuff) then
                        if (sowBuff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = false;
                            model.highlighted = true;
                        else
                            model.visible = false;
                            return;
                        end
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                        model.highlighted = true;
                    end
                else
                    if (buff) then
                        updateModelWithJudgement(model, spellJudgement, buff);
                        model.affectingSpellTarget = false;
                        model.highlighted = true;
                    elseif (sowBuff) then
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                    end
                end
            end;

            return model;
        end)();

        local sealOfWisdomModel = (function()
            local spell = spellSealOfWisdom;

            local model = pda:newSlotModel();
            model.spell = spell;
            model.contentTexture = spell.spellTexture;
            model.onClick = function(f, button)
                CastSpellByName(model.spell.spellNameWithRank, model.targetingPlayer);
            end;
            model.onElapsed = function(elapsed)
                local buff = getUnitBuff("player", spell);
                local targetDebuff = getUnitBuff("target", spell);
                local solBuff = getUnitBuff("player", spellSealOfLight);
                local targetSolDebuff = getUnitBuff("target", spellSealOfLight);

                if (targetDebuff) then
                    if (buff) then
                        if (buff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = true;
                        else
                            model.visible = false;
                            return;
                        end
                    elseif (solBuff) then
                        if (solBuff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = false;
                        else
                            model.visible = false;
                            return;
                        end
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                    end
                elseif (targetSolDebuff) then
                    if (buff) then
                        if (buff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = true;
                            model.highlighted = true;
                        else
                            model.visible = false;
                            return;
                        end
                    elseif (solBuff) then
                        if (solBuff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = false;
                            model.highlighted = true;
                        else
                            model.visible = false;
                            return;
                        end
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                        model.highlighted = true;
                    end
                else
                    if (buff) then
                        updateModelWithJudgement(model, spellJudgement, buff);
                        model.affectingSpellTarget = false;
                        model.highlighted = true;
                    elseif (solBuff) then
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                        model.highlighted = true;
                    end
                end
            end;

            return model;
        end)();

        local a = {};
        Array.add(a, sealOfLightModel);
        Array.add(a, sealOfWisdomModel);
        return a;
    elseif (spellSealOfLight or spellSealOfWisdom) then
        -- health or mana recovery strategy
        local spell = spellSealOfLight or spellSealOfWisdom;

        local model = pda:newSlotModel();
        model.spell = spell;
        model.contentTexture = spell.spellTexture;
        model.onClick = function(f, button)
            CastSpellByName(model.spell.spellNameWithRank, model.targetingPlayer);
        end;
        model.onElapsed = function(elapsed)
            local buff = getUnitBuff("player", spell);
            local targetDebuff = getUnitBuff("target", spell);

            if (not buff) then
                updateModelWithSeal(model, spell);
                model.affectingSpellTarget = false;
                model.highlighted = true;
            elseif (targetDebuff) then
                if (buff.buffTimeToLive < 5) then
                    updateModelWithSeal(model, spell);
                    model.affectingSpellTarget = true;
                    model.highlighted = true;
                else
                    model.visible = false;
                    return;
                end
            else
                updateModelWithJudgement(model, spellJudgement, buff);
                model.affectingSpellTarget = false;
                model.highlighted = true;
            end
        end;

        local a = {};
        Array.add(a, model);
        return a;
    end
end);

-- 十字军打击 + 神圣打击
-- 十字军打击作为填充技能，毛回蓝
-- 神圣打击将物理转化神圣法术伤害，无公共CD，不与其它技能共CD
-- 都用1级，省蓝
-- turtle wow
Array.add(build.creators, function()
    local spell = getPlayerSpell("Crusader Strike(Rank 1)");
    if (not spell) then
        return;
    end

    local spellHolyStrike = getPlayerSpell("Holy Strike(Rank 1)");

    local model = pda:newSlotModel();
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
    model.onClick = function(f, button)
        if (spellHolyStrike) then
            local timeToCooldown = getPlayerSpellCooldownTime(spellHolyStrike);
            if (timeToCooldown == 0) then
                CastSpellByName(spellHolyStrike.spellNameWithRank);
            end
        end
        CastSpellByName(model.spell.spellNameWithRank);
    end;
    model.onElapsed = function(elapsed)
        local inCombat = UnitAffectingCombat("player");
        local onTarget = targetsAliveEnemy();
        if (not inCombat and not onTarget) then
            model.visible = false;
            return;
        else
            model.visible = true;
        end

        local timeToCooldown = getPlayerSpellCooldownTime(spell);
        local holyStrikeTimeToCooldown = spellHolyStrike and getPlayerSpellCooldownTime(spellHolyStrike) or 86400;
        -- TODO check holy strike casting

        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.highlighted = onTarget and (holyStrikeTimeToCooldown < 0.1);
    end;

    local a = {};
    Array.add(a, model);
    return a;
end);

-- 飞锤
Array.add(build.creators, function()
    local spell = getPlayerSpell("Hammer of Wrath");
    if (not spell) then
        return;
    end

    local model = pda:newSlotModel();
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
    model.onClick = function(f, button)
        CastSpellByName(model.spell.spellNameWithRank);
    end;
    model.onElapsed = function(elapsed)
        local timeToCooldown = getPlayerSpellCooldownTime(spell);
        if (timeToCooldown > 1.5) then
            model.visible = false;
            return;
        end

        local onTarget = targetsAliveEnemy();
        if (not onTarget) then
            model.visible = false;
            return;
        end

        local acceptableTargetHealth = (getTargetHealthProportion() or 1) < 0.215;
        if (not acceptableTargetHealth) then
            model.visible = false;
            return;
        end

        model.visible = true;

        local inCombat = UnitAffectingCombat("player");

        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.highlighted = inCombat and (timeToCooldown < 0.1);
    end;

    local a = {};
    Array.add(a, model);
    return a;
end);

pda:register(build);
