local hookGlobalFunction = A.hookGlobalFunction;
local getPlayerSpell = A.getPlayerSpell;
local getPlayerSpellCooldownTime = A.getPlayerSpellCooldownTime;
local getUnitBuff = A.getUnitBuff;
local SlotMan = A.SlotMan;

local auraSlotMan = SlotMan:new();
auraSlotMan.slot_size = 31;
auraSlotMan.slot_margin = 6;
auraSlotMan.max_x_slots = 10;
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

function auraSlotMan:start(seals)
    local f = self.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("SPELLS_CHANGED");
    f:SetScript("OnEvent", function(...)
        auraSlotMan:updateAnchorPosition();
        auraSlotMan:clearAllSlotModels();
        for i, seal in ipairs(seals) do
            auraSlotMan:adopt(seal);
        end
        auraSlotMan:renderAllSlotModels();
    end);

    f:SetScript("OnUpdate", (function()
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (acc < 0.1) then
                return;
            end

            auraSlotMan:renderAllSlotModels(function(model)
                if (model.onElapsed) then
                    model.onElapsed(acc);
                end
            end);

            acc = 0;
        end;
    end)());

    hookGlobalFunction("UIParent_ManageFramePositions", "post_hook", function()
        auraSlotMan:updateAnchorPosition();
    end);
end

function auraSlotMan:adopt(sealName)
    if (not sealName) then
        return;
    end

    local spell = getPlayerSpell(sealName);
    if (not spell) then
        return;
    end

    local model = self:createSlotModel();
    model.visible = true;
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
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
        model.affectingSpellTarget = not (not getUnitBuff("player", spell));
        model.timeToCooldown = getPlayerSpellCooldownTime(spell);
        model.ready = (model.timeToCooldown == 0);
    end;

    self:addSlotModelAndDock(model);
end

auraSlotMan:start({
    -- spells placing long-term buffs only to self
    "Righteous Fury",
});

local debug = nil;
if (debug) then
    _G.auraSlotMan = auraSlotMan;
end
