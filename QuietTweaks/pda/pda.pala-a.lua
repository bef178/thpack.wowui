local getSpellByName = A.getSpellByName;
local getSpellCastStates = A.getSpellCastStates;
local getUnitBuffBySpell = A.getUnitBuffBySpell;

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

local build = {
    id = "pala-a",
    description = "prot pala solo aoe, for turtle wow",
    initializers = {},
    slotModels = {},
};

build.prepareSlotModels = function(createSlotModel)
    Array.clear(build.slotModels);
    for i, fn in ipairs(build.initializers) do
        local a = fn(createSlotModel);
        if (a) then
            for j, model in ipairs(a) do
                Array.add(build.slotModels, model);
            end
        end
    end
    return build.slotModels;
end;

build.onElapsed = function(elapsed)
    for i, model in ipairs(build.slotModels) do
        if (model.onElapsed) then
            model.onElapsed(elapsed);
        end
    end
end;

-- 惩罚光环/庇护祝福/神圣之盾
-- 这三者是最主要的反伤手段，集成为第一顺位
-- 另，A怪时惩罚光环优于圣洁光环
Array.add(build.initializers, function(createSlotModel)
    local spellRetributionAura = getSpellByName("Retribution Aura");
    local spellBlessingOfSanctuary = getSpellByName("Blessing of Sanctuary");
    local spellHolyShield = getSpellByName("Holy Shield");
    if (not spellRetributionAura and not spellBlessingOfSanctuary and not spellHolyShield) then
        return;
    end

    local model = createSlotModel();
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

        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;

        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.recommended = (inCombat or onTarget) and (timeToCooldown < 0.1);
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

        local buff = getUnitBuffBySpell("player", spell);
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

        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;

        model.affectingSpellTarget = not (not buff);
        model.timeToCooldown = timeToCooldown;
        model.ready = (timeToCooldown == 0);
        model.recommended = (inCombat or onTarget) and (timeToCooldown < 0.1);
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

        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;
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

        local buff = getUnitBuffBySpell("player", spell);

        model.affectingSpellTarget = not (not buff);
        model.timeToCooldown = timeToCooldown;
        model.ready = model.timeToCooldown == 0;
        model.recommended = (inCombat or onTarget) and (timeToCooldown < 0.1);
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
Array.add(build.initializers, function(createSlotModel)
    local spell = getSpellByName("Consecration");
    if (not spell) then
        return;
    end

    local model = createSlotModel();
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
    model.onClick = function(f, button)
        CastSpellByName(model.spell.spellNameWithRank);
    end;
    model.onElapsed = function(elapsed)
        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;
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
        model.recommended = inCombat and (timeToCooldown < 0.1);
    end;

    local a = {};
    Array.add(a, model);
    return a;
end);

-- 光明圣印/智慧圣印/审判
-- 最主要的战时回复手段，为第三顺位
Array.add(build.initializers, function(createSlotModel)
    local function updateModelWithSeal(model, spell)
        local inCombat = UnitAffectingCombat("player");
        local onTarget = targetsAliveEnemy();
        if (not inCombat and not onTarget) then
            model.visible = false;
            return;
        end

        model.visible = true;

        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;

        model.spell = spell;
        model.contentTexture = spell.spellTexture;
        model.targetingPlayer = true;
        model.timeToLive = nil;
        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.recommended = false;
    end

    local function updateModelWithJudgement(model, spell, buff)
        if (not buff) then
            model.visible = false;
            return;
        end

        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;
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
        model.recommended = false;
    end

    local spellJudgement = getSpellByName("Judgement");
    if (not spellJudgement) then
        return;
    end

    local spellSealOfLight = getSpellByName("Seal of Light"); -- lv 30
    local spellSealOfWisdom = getSpellByName("Seal of Wisdom"); -- lv 38
    if (spellSealOfLight and spellSealOfWisdom) then
        -- dual recovery strategy
        local sealOfLightModel = (function()
            local spell = spellSealOfLight;

            local model = createSlotModel();
            model.spell = spell;
            model.contentTexture = spell.spellTexture;
            model.onClick = function(f, button)
                CastSpellByName(model.spell.spellNameWithRank, model.targetingPlayer);
            end;
            model.onElapsed = function(elapsed)
                local buff = getUnitBuffBySpell("player", spell);
                local targetDebuff = getUnitBuffBySpell("target", spell);
                local sowBuff = getUnitBuffBySpell("player", spellSealOfWisdom);
                local targetSowDebuff = getUnitBuffBySpell("target", spellSealOfWisdom);

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
                            model.recommended = true;
                        else
                            model.visible = false;
                            return;
                        end
                    elseif (sowBuff) then
                        if (sowBuff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = false;
                            model.recommended = true;
                        else
                            model.visible = false;
                            return;
                        end
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                        model.recommended = true;
                    end
                else
                    if (buff) then
                        updateModelWithJudgement(model, spellJudgement, buff);
                        model.affectingSpellTarget = false;
                        model.recommended = true;
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

            local model = createSlotModel();
            model.spell = spell;
            model.contentTexture = spell.spellTexture;
            model.onClick = function(f, button)
                CastSpellByName(model.spell.spellNameWithRank, model.targetingPlayer);
            end;
            model.onElapsed = function(elapsed)
                local buff = getUnitBuffBySpell("player", spell);
                local targetDebuff = getUnitBuffBySpell("target", spell);
                local solBuff = getUnitBuffBySpell("player", spellSealOfLight);
                local targetSolDebuff = getUnitBuffBySpell("target", spellSealOfLight);

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
                            model.recommended = true;
                        else
                            model.visible = false;
                            return;
                        end
                    elseif (solBuff) then
                        if (solBuff.buffTimeToLive < 5) then
                            updateModelWithSeal(model, spell);
                            model.affectingSpellTarget = false;
                            model.recommended = true;
                        else
                            model.visible = false;
                            return;
                        end
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                        model.recommended = true;
                    end
                else
                    if (buff) then
                        updateModelWithJudgement(model, spellJudgement, buff);
                        model.affectingSpellTarget = false;
                        model.recommended = true;
                    elseif (solBuff) then
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                    else
                        updateModelWithSeal(model, spell);
                        model.affectingSpellTarget = false;
                        model.recommended = true;
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

        local model = createSlotModel();
        model.spell = spell;
        model.contentTexture = spell.spellTexture;
        model.onClick = function(f, button)
            CastSpellByName(model.spell.spellNameWithRank, 1);
        end;
        model.onElapsed = function(elapsed)
            local buff = getUnitBuffBySpell("player", spell);
            local targetDebuff = getUnitBuffBySpell("target", spell);

            if (not buff) then
                updateModelWithSeal(model, spell);
                model.affectingSpellTarget = false;
                model.recommended = true;
            elseif (targetDebuff) then
                if (buff.buffTimeToLive < 5) then
                    updateModelWithSeal(model, spell);
                    model.affectingSpellTarget = true;
                    model.recommended = true;
                else
                    model.visible = false;
                    return;
                end
            else
                updateModelWithJudgement(model, spellJudgement, buff);
                model.affectingSpellTarget = false;
                model.recommended = true;
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
Array.add(build.initializers, function(createSlotModel)
    local spell = getSpellByName("Crusader Strike(Rank 1)");
    if (not spell) then
        return;
    end

    local spellHolyStrike = getSpellByName("Holy Strike(Rank 1)");

    local model = createSlotModel();
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
    model.onClick = function(f, button)
        if (spellHolyStrike) then
            local timeToCooldown = getSpellCastStates(spellHolyStrike).timeToCooldown;
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

        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;
        local holyStrikeTimeToCooldown = spellHolyStrike and getSpellCastStates(spellHolyStrike).timeToCooldown or nil;
        -- TODO check holy strike casting

        model.timeToCooldown = timeToCooldown;
        model.ready = timeToCooldown == 0;
        model.recommended = onTarget and (holyStrikeTimeToCooldown < 0.1);
    end;

    local a = {};
    Array.add(a, model);
    return a;
end);

-- 飞锤
Array.add(build.initializers, function(createSlotModel)
    local spell = getSpellByName("Hammer of Wrath");
    if (not spell) then
        return;
    end

    local model = createSlotModel();
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
    model.onClick = function(f, button)
        CastSpellByName(model.spell.spellNameWithRank);
    end;
    model.onElapsed = function(elapsed)
        local timeToCooldown = getSpellCastStates(spell).timeToCooldown;
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
        model.recommended = inCombat and (timeToCooldown < 0.1);
    end;

    local a = {};
    Array.add(a, model);
    return a;
end);

pda:register(build);
