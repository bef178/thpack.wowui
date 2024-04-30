local hookGlobalFunction = A.hookGlobalFunction;
local getSpellByName = A.getSpellByName;
local SlotMan = A.SlotMan;

local function getUnitBuffIndexByTexture(unit, texture)
    for i = 1, 64, 1 do
        local buffTexture, buffCount = UnitBuff(unit, i);
        if (not buffTexture) then
            break;
        end
        if (buffTexture == texture) then
            return i;
        end
    end
end

local function hasBuffByTexture(unit, texture)
    local i = getUnitBuffIndexByTexture(unit, texture);
    return i and i > 0;
end

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
            blessingSlotMan:renderAllSlots();
        end
    end);

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

    model.onUpdate = function(f, elapsed)
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

        model.enabledTopLeftSpotTexture = spellTargetUnit == "player";

        -- checked: if that unit has corresponding buff
        model.checked = hasBuffByTexture(spellTargetUnit, spell.spellTexture);

        local startTime, duration, enabled = GetSpellCooldown(spell.spellIndex, spell.spellBookType);
        if (enabled) then
            model.timeToCooldown = startTime + duration - GetTime();
        else
            model.timeToCooldown = 0;
        end
    end;

    self:addSlotModel(model);
end

blessingSlotMan:start({
    -- spells casting on friendly/neutral units
    { "Blessing of Might", "Great Blessing of Might" },
    { "Blessing of Wisdom", "Great Blessing of Wisdom" },
    { "Blessing of Kings", "Great Blessing of Kings" },
    { "Blessing of Sanctuary", "Great Blessing of Sanctuary" },
    { "Blessing of Salvation", "Great Blessing of Salvation" },
    { "Blessing of Light", "Great Blessing of Light" },
    { "Power Word: Fortitude", "Prayer of Fortitude" },
    { "Divine Spirit", "Prayer of Spirit" },
});

local debug = nil;
if (debug) then
    _G.blessingSlotMan = blessingSlotMan;
end
