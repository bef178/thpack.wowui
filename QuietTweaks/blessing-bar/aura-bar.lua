local A = A;

local auraSlotMan = A.SlotMan:new();
auraSlotMan.slot_size = 31;
auraSlotMan.slot_margin = 6;
auraSlotMan.slot_models = {};
auraSlotMan.anchor:SetParent(MainMenuBar);
auraSlotMan.anchor:ClearAllPoints();

-- place to the right of ShapeshiftBar
function auraSlotMan:updateAnchorPosition()
    local f = self.anchor;
    if (ShapeshiftBarFrame:IsShown()) then
        local n = GetNumShapeshiftForms();
        local lastShapeshiftButton = _G["ShapeshiftButton" .. n];
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", lastShapeshiftButton, "TOPRIGHT", 32, 0);
    elseif (MultiBarBottomLeft:IsShown()) then
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", MultiBarBottomLeft, "TOPLEFT", 32, 36);
    else
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", MultiBarBottomLeft, "TOPLEFT", 32, 0);
    end
end

function auraSlotMan:buildSlotModel(sealName)
    if (not sealName) then
        return;
    end

    local spell = A.getPlayerSpell(sealName);
    if (not spell) then
        return;
    end

    local model = self:newSlotModel();
    model.visible = true;
    model.spell = spell;
    model.spellTexture = spell.spellTexture;
    model.onEnter = function(f)
        GameTooltip:SetOwner(f, "ANCHOR_TOPLEFT");
        -- GameTooltip_SetDefaultAnchor(GameTooltip, f);
        GameTooltip:SetSpell(model.spell.spellIndex, model.spell.spellBookType);
        GameTooltip:Show();
    end;
    model.onLeave = function(f)
        GameTooltip:Hide();
    end;
    model.onClick = function(f, button)
        CastSpellByName(model.spell.spellNameWithRank, 1);
    end;

    model.onElapsed = function(elapsed)
        model.spellTargetUnitAffected = not (not A.getUnitBuff("player", spell));
        model.spellTimeToCooldown = A.getPlayerSpellCooldownTime(spell);
        model.spellReadyToCast = (model.spellTimeToCooldown == 0);
    end;

    return model;
end

function auraSlotMan:start(seals)
    local f = self.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("SPELLS_CHANGED");
    f:SetScript("OnEvent", function(...)
        auraSlotMan:updateAnchorPosition();

        local models = auraSlotMan.slot_models;
        Array.clear(models);
        for _, seal in ipairs(seals) do
            local model = auraSlotMan:buildSlotModel(seal);
            if (model) then
                Array.add(models, model);
            end
        end
        auraSlotMan:render(models);
    end);
    f:SetScript("OnUpdate", (function()
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (acc > 0.1) then
                for _, model in ipairs(auraSlotMan.slot_models) do
                    if (model.onElapsed) then
                        model.onElapsed(elapsed);
                    end
                end
                auraSlotMan:render();
                acc = 0;
            end
        end;
    end)());

    A.hookGlobalFunction("UIParent_ManageFramePositions", "post_hook", function()
        auraSlotMan:updateAnchorPosition();
    end);
end

auraSlotMan:start({
    -- spells creating last-until-cancelled buffs
    "Righteous Fury",
});

local debug = nil;
if (debug) then
    _G.auraSlotMan = auraSlotMan;
end
