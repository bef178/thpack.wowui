local hookGlobalFunction = A.hookGlobalFunction;
local getSpellByName = A.getSpellByName;
local getSpellCastStates = A.getSpellCastStates;
local getUnitBuffBySpell = A.getUnitBuffBySpell;
local SlotMan = A.SlotMan;

----------------------------------------

local blessingSlotMan = SlotMan:new();
blessingSlotMan.slot_size = 31;
blessingSlotMan.slot_margin = 6;
blessingSlotMan.anchor:SetParent(MainMenuBar);
blessingSlotMan.anchor:SetScript("OnUpdate", (function()
    local acc = 0;
    return function(...)
        local elapsed = arg1;
        acc = acc + elapsed;
        if (acc > 0.1) then
            blessingSlotMan:renderAllSlotModels(function(model)
                if (model.onElapsed) then
                    model.onElapsed(acc);
                end
            end);
            acc = 0;
        end
    end;
end)());

function blessingSlotMan:updateAnchorPosition()
    local f = self.anchor;

    local xOffset = 32;
    local yOffset = 32;

    if (MultiBarBottomRight:IsShown()) then
        f:ClearAllPoints();
        f:SetPoint("BOTTOMLEFT", MultiBarBottomRight, "TOPLEFT", xOffset, yOffset);
    else
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
end

function blessingSlotMan:redial(a)
    self:clearAllSlotModels();
    for i, a1 in ipairs(a) do
        self:adopt(a1);
    end
    self:renderAllSlotModels();
end

function blessingSlotMan:adopt(blessing)
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
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
        -- GameTooltip_SetDefaultAnchor(GameTooltip, f);
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
        model.affectingSpellTarget = not (not getUnitBuffBySpell(spellTargetUnit, spell));
        model.timeToCooldown = getSpellCastStates(spell).timeToCooldown;
        model.ready = model.timeToCooldown == 0;
    end;

    self:addSlotModelAndDock(model);
end

----------------------------------------

local sealSlotMan = SlotMan:new();
sealSlotMan.slot_size = blessingSlotMan.slot_size;
sealSlotMan.slot_margin = blessingSlotMan.slot_margin;
sealSlotMan.anchor:SetParent(MainMenuBar);
sealSlotMan.anchor:SetScript("OnUpdate", (function()
    local acc = 0;
    return function(...)
        local elapsed = arg1;
        acc = acc + elapsed;
        if (acc > 0.1) then
            sealSlotMan:renderAllSlotModels(function(model)
                if (model.onElapsed) then
                    model.onElapsed(acc);
                end
            end);
            acc = 0;
        end
    end;
end)());

function sealSlotMan:updateAnchorPosition()
    local size = blessingSlotMan.slot_size;
    local margin = blessingSlotMan.slot_margin;
    local n = blessingSlotMan:getNumSlotModels();
    local blessingBarWidth = (n == 0) and 0 or (n * size + (n - 1) * margin);
    local gap = (blessingBarWidth == 0) and 0 or 32;
    self.anchor:ClearAllPoints();
    self.anchor:SetPoint("TOPLEFT", blessingSlotMan.anchor, "TOPLEFT", blessingBarWidth + gap, 0);
end

function sealSlotMan:redial(a)
    self:clearAllSlotModels();
    for i, a1 in ipairs(a) do
        self:adopt(a1);
    end
    self:renderAllSlotModels();
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
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
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
        model.affectingSpellTarget = not (not getUnitBuffBySpell("player", spell));
        model.timeToCooldown = getSpellCastStates(spell).timeToCooldown;
        model.ready = (model.timeToCooldown == 0);
    end;

    self:addSlotModelAndDock(model);
end

----------------------------------------

(function(blessings, seals)
    local f = blessingSlotMan.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("SPELLS_CHANGED");
    f:SetScript("OnEvent", function(...)
        blessingSlotMan:updateAnchorPosition();
        blessingSlotMan:redial(blessings);

        sealSlotMan:updateAnchorPosition();
        sealSlotMan:redial(seals);
    end);

    hookGlobalFunction("UIParent_ManageFramePositions", "post_hook", function()
        blessingSlotMan:updateAnchorPosition();
        sealSlotMan:updateAnchorPosition();
    end);
end)(
    {
        -- spells placing buffs to others
        { "Blessing of Might", "Greater Blessing of Might" },
        { "Blessing of Wisdom", "Greater Blessing of Wisdom" },
        { "Blessing of Salvation", "Greater Blessing of Salvation" },
        { "Blessing of Light", "Greater Blessing of Light" },
        { "Blessing of Sanctuary", "Greater Blessing of Sanctuary" },
        { "Blessing of Kings", "Greater Blessing of Kings" },
    },
    {
        -- spells placing short-term buffs only to self
        "Seal of Righteousness",
        "Seal of the Crusader",
        "Seal of Justice",
        "Seal of Light",
        "Seal of Wisdom",
        "Seal of Command",
    }
);
