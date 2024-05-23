local hookGlobalFunction = A.hookGlobalFunction;
local getSpellByName = A.getSpellByName;
local getSpellCastStates = A.getSpellCastStates;
local getUnitBuffBySpell = A.getUnitBuffBySpell;
local SlotMan = A.SlotMan;

-- hold buff spells those must be casted on self
local sealSlotMan = SlotMan:new();
sealSlotMan.slot_size = 31;
sealSlotMan.slot_margin = 6;
sealSlotMan.max_x_slots = 10;
sealSlotMan.anchor:SetParent(MainMenuBar);
sealSlotMan.anchor:ClearAllPoints();

function sealSlotMan:updateAnchorPosition()
    local f = self.anchor;

    local xOffset = 33;
    local yOffset = 32;

    if (MultiBarBottomRight:IsShown()) then
        f:ClearAllPoints();
        f:SetPoint("BOTTOMLEFT", MultiBarBottomRight, "TOPLEFT", xOffset, yOffset);
        return;
    end

    if (MultiBarBottomLeft.isShowing) then
        yOffset = yOffset + 45;
    end
    if (ReputationWatchBar:IsShown() and MainMenuExpBar:IsShown()) then
        yOffset = yOffset + 9;
    end
    if (MainMenuBarMaxLevelBar:IsShown()) then
        yOffset = yOffset - 5;
    end
    f:ClearAllPoints();
    f:SetPoint("BOTTOMLEFT", MultiBarBottomRight, "TOPRIGHT", xOffset, yOffset);
end

function sealSlotMan:start(seals)
    local f = self.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(...)
        if (event == "PLAYER_ENTERING_WORLD") then
            sealSlotMan:updateAnchorPosition();
            sealSlotMan:clearAllSlotModels();
            for i, seal in ipairs(seals) do
                sealSlotMan:adopt(seal);
            end
            sealSlotMan:renderAllSlotModels();
        end
    end);

    f:SetScript("OnUpdate", (function()
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (acc < 0.1) then
                return;
            end

            sealSlotMan:renderAllSlotModels(function(model)
                if (model.onElapsed) then
                    model.onElapsed(acc);
                end
            end);

            acc = 0;
        end;
    end)());

    hookGlobalFunction("UIParent_ManageFramePositions", "post_hook", function()
        sealSlotMan:updateAnchorPosition();
    end);
end

function sealSlotMan:adopt(sealName)
    if (not sealName) then
        return;
    end

    local spell = getSpellByName(sealName);
    if (not spell) then
        return;
    end

    local model = self:createSlotModel();
    model.visible = true;
    model.spell = spell;
    model.contentTexture = spell.spellTexture;
    model.onEnter = function(f)
        -- GameTooltip:SetOwner(slot, "ANCHOR_TOPLEFT");
        GameTooltip_SetDefaultAnchor(GameTooltip, f);
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
        model.affectingSpellTarget = not (not getUnitBuffBySpell("player", spell));
        model.timeToCooldown = getSpellCastStates(spell).timeToCooldown;
        model.ready = (model.timeToCooldown == 0);
    end;

    self:addSlotModelAndDock(model);
end

sealSlotMan:start({
    "Seal of Righteousness",
    "Seal of the Crusader",
    "Seal of Justice",
    "Seal of Command",
    "Seal of Light",
    "Seal of Wisdom",
    "Righteous Fury",
    "Battle Cry",
});

local debug = nil;
if (debug) then
    _G.sealSlotMan = sealSlotMan;
end
