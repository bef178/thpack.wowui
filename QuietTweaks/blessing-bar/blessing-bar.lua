local hookGlobalFunction = A.hookGlobalFunction;
local getSpellByName = A.getSpellByName;
local getSpellCastStates = A.getSpellCastStates;
local getUnitBuffIndexByTexture = A.getUnitBuffIndexByTexture;
local SlotMan = A.SlotMan;

-- place blessings to the right of ShapeshiftBar
local blessingSlotMan = SlotMan:new();
blessingSlotMan.slot_size = 31;
blessingSlotMan.slot_margin = 6;
blessingSlotMan.anchor:SetParent(MainMenuBar);
blessingSlotMan.anchor:ClearAllPoints();

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
        model.affectingPlayer = getUnitBuffIndexByTexture("player", spell.spellTexture) > 0;
        model.affectingTarget = getUnitBuffIndexByTexture("target", spell.spellTexture) > 0;

        local spellCastStates = getSpellCastStates(spell);
        model.timeToCooldown = spellCastStates.timeToCooldown or 0;
    end;

    self:addSlotModelAndDock(model);
end

blessingSlotMan:start({
    -- spells casting on friendly/neutral units
    { "Blessing of Might", "Great Blessing of Might" },
    { "Blessing of Wisdom", "Great Blessing of Wisdom" },
    { "Blessing of Kings", "Great Blessing of Kings" },
    { "Blessing of Sanctuary", "Great Blessing of Sanctuary" },
    { "Blessing of Salvation", "Great Blessing of Salvation" },
    { "Blessing of Light", "Great Blessing of Light" },
    { "Blessing of Sacrifice", "Great Blessing of Sacrifice" },
    { "Power Word: Fortitude", "Prayer of Fortitude" },
    { "Divine Spirit", "Prayer of Spirit" },
});

local debug = nil;
if (debug) then
    _G.blessingSlotMan = blessingSlotMan;
end
