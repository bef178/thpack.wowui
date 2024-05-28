local hookGlobalFunction = A.hookGlobalFunction;
local getSpellByName = A.getSpellByName;
local getSpellCastStates = A.getSpellCastStates;
local getUnitBuffBySpell = A.getUnitBuffBySpell;
local SlotMan = A.SlotMan;

-- hold buff spells those can be casted on friendly/neutral units
local blessingSlotMan = SlotMan:new();
blessingSlotMan.slot_size = 31;
blessingSlotMan.slot_margin = 6;
blessingSlotMan.anchor:SetParent(MainMenuBar);
blessingSlotMan.anchor:ClearAllPoints();

-- place to the right of ShapeshiftBar
function blessingSlotMan:updateAnchorPosition()
    local f = self.anchor;
    if (ShapeshiftBarFrame:IsShown()) then
        local n = GetNumShapeshiftForms();
        local lastShapeshiftButton = _G["ShapeshiftButton" .. n];
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", lastShapeshiftButton, "TOPRIGHT", 7 + 2 + 7, 0);
        return;
    end

    local xOffset = 30;
    local yOffset = 30;
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
    f:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", xOffset, yOffset);
end

function blessingSlotMan:start(blessings)
    local f = self.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(...)
        if (event == "PLAYER_ENTERING_WORLD") then
            blessingSlotMan:updateAnchorPosition();
            blessingSlotMan:clearAllSlotModels();
            for i, blessing in ipairs(blessings) do
                blessingSlotMan:adoptBlessing(blessing);
            end
            blessingSlotMan:renderAllSlotModels();
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

            blessingSlotMan:renderAllSlotModels(function(model)
                if (model.onElapsed) then
                    model.onElapsed(acc);
                end
            end);

            acc = 0;
        end;
    end)());

    hookGlobalFunction("UIParent_ManageFramePositions", "post_hook", function()
        blessingSlotMan:updateAnchorPosition();
    end);
end

function blessingSlotMan:adoptBlessing(blessing)
    if (not blessing) then
        return;
    end

    local spells = Array.map(blessing, function(v, i, a)
        return getSpellByName(v);
    end);
    if (not spells[1]) then
        return;
    end

    local model = self:createSlotModel();
    model.visible = true;
    model.spells = spells;
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
        CastSpellByName(model.spell.spellNameWithRank, model.spellTargetUnit == "player");
    end;

    model.onElapsed = function(elapsed)
        local spell;
        if (not IsShiftKeyDown()) then
            spell = model.spells[1];
        else
            spell = model.spells[2];
            if (not spell) then
                spell = model.spells[1];
            end
        end

        model.spell = spell;
        model.contentTexture = spell.spellTexture;

        local spellTargetUnit;
        if (IsAltKeyDown()) then
            spellTargetUnit = "player";
        elseif (UnitExists("target")) then
            if (UnitIsEnemy("player", "target")) then
                spellTargetUnit = "player";
            else
                spellTargetUnit = "target";
            end
        else
            spellTargetUnit = "player";
        end
        model.spellTargetUnit = spellTargetUnit;

        model.targetingPlayer = spellTargetUnit == "player";
        model.affectingSpellTarget = not not getUnitBuffBySpell(spellTargetUnit, spell);
        model.timeToCooldown = getSpellCastStates(spell).timeToCooldown;
        model.ready = model.timeToCooldown == 0;
    end;

    self:addSlotModelAndDock(model);
end

blessingSlotMan:start({
    { "Blessing of Might", "Greater Blessing of Might" },
    { "Blessing of Wisdom", "Greater Blessing of Wisdom" },
    { "Blessing of Kings", "Greater Blessing of Kings" },
    { "Blessing of Sanctuary", "Greater Blessing of Sanctuary" },
    { "Blessing of Salvation", "Greater Blessing of Salvation" },
    { "Blessing of Light", "Greater Blessing of Light" },
});

local debug = nil;
if (debug) then
    _G.blessingSlotMan = blessingSlotMan;
end
