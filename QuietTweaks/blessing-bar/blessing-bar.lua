local A = A;

----------------------------------------

local blessingSlotMan = A.SlotMan:new();
blessingSlotMan.leading_margin = 32;
blessingSlotMan.slot_size = 31;
blessingSlotMan.slot_margin = 6;
blessingSlotMan.slot_models = {};
blessingSlotMan.anchor:SetParent(MainMenuBar);

function blessingSlotMan:updateAnchorPosition()
    local f = self.anchor;
    if (MultiBarBottomRight:IsShown()) then
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", MultiBarBottomRight, "TOPLEFT", blessingSlotMan.leading_margin, 36);
    else
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", MultiBarBottomRight, "TOPLEFT", blessingSlotMan.leading_margin, 0);
    end
end

function blessingSlotMan:buildSlotModel(blessing, greatBlessing)
    if (not blessing) then
        return;
    end

    blessing = blessing and A.getPlayerSpell(blessing);
    if (not blessing) then
        return;
    end

    greatBlessing = greatBlessing and A.getPlayerSpell(greatBlessing);

    local model = self:newSlotModel();
    model.visible = true;
    model.spells = { blessing, greatBlessing };
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
        A.cast(model.spell, model.spellTargetUnit);
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
        model.spellTexture = spell.spellTexture;

        local spellTargetUnit;
        if (IsAltKeyDown()) then
            spellTargetUnit = "player";
        elseif (UnitExists("target")) then
            if (UnitCanAssist("player", "target")) then
                spellTargetUnit = "target";
            else
                spellTargetUnit = "player";
            end
        else
            spellTargetUnit = "player";
        end
        model.spellTargetUnit = spellTargetUnit;

        model.spellTargetUnit = spellTargetUnit;
        model.spellTargetBuffed = not (not A.getUnitBuff(spellTargetUnit, spell));
        model.spellTimeToCooldown = A.getPlayerSpellCooldownTime(spell);
        model.spellReadyToCast = model.spellTimeToCooldown == 0;
    end;

    return model;
end

function blessingSlotMan:start(blessingPairs)
    local f = blessingSlotMan.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("SPELLS_CHANGED");
    f:SetScript("OnEvent", function(...)
        blessingSlotMan:updateAnchorPosition();

        local models = blessingSlotMan.slot_models;
        Array.clear(models);
        for _, p in ipairs(blessingPairs) do
            local model = blessingSlotMan:buildSlotModel(p[1], p[2]);
            if (model) then
                Array.add(models, model);
            end
        end
        blessingSlotMan:render(models);
    end);
    f:SetScript("OnUpdate", (function()
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (acc > 0.1) then
                for _, model in ipairs(blessingSlotMan.slot_models) do
                    if (model.onElapsed) then
                        model.onElapsed(elapsed);
                    end
                end
                blessingSlotMan:render();
                acc = 0;
            end
        end;
    end)());
end

----------------------------------------

-- think it is a trailer
local sealSlotMan = A.SlotMan:new();
sealSlotMan.leading_margin = blessingSlotMan.leading_margin; -- as the margin between the two bars
sealSlotMan.slot_size = blessingSlotMan.slot_size;
sealSlotMan.slot_margin = blessingSlotMan.slot_margin;
sealSlotMan.slot_models = {};
sealSlotMan.anchor:SetParent(MainMenuBar);

function sealSlotMan:updateAnchorPosition()
    local w;
    do
        local n = Array.size(blessingSlotMan.slot_models);
        if (n == 0) then
            w = 0;
        else
            local x = blessingSlotMan.slot_size;
            local y = blessingSlotMan.slot_margin;
            w = x + (y + x) * (n - 1) + sealSlotMan.leading_margin;
        end
    end

    self.anchor:ClearAllPoints();
    self.anchor:SetPoint("TOPLEFT", blessingSlotMan.anchor, "TOPLEFT", w, 0);
end

function sealSlotMan:buildSlotModel(sealName)
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
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
        -- GameTooltip_SetDefaultAnchor(GameTooltip, f);
        GameTooltip:SetSpell(model.spell.spellIndex, model.spell.spellBookType);
        GameTooltip:Show();
    end;
    model.onLeave = function(f)
        GameTooltip:Hide();
    end;
    model.onClick = function(f, button)
        A.cast(model.spell, model.spellTargetUnit);
    end;

    model.onElapsed = function(elapsed)
        model.spellTargetBuffed = not (not A.getUnitBuff("player", spell));
        model.spellTimeToCooldown = A.getPlayerSpellCooldownTime(spell);
        model.spellReadyToCast = (model.spellTimeToCooldown == 0);
    end;

    return model;
end

function sealSlotMan:start(seals)
    local f = sealSlotMan.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("SPELLS_CHANGED");
    f:SetScript("OnEvent", function(...)
        sealSlotMan:updateAnchorPosition();

        local models = sealSlotMan.slot_models;
        Array.clear(models);
        for _, p in ipairs(seals) do
            local model = sealSlotMan:buildSlotModel(p);
            if (model) then
                Array.add(models, model);
            end
        end
        sealSlotMan:render(models);
    end);
    f:SetScript("OnUpdate", (function()
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (acc > 0.1) then
                for _, slotModel in ipairs(sealSlotMan.slot_models) do
                    if (slotModel.onElapsed) then
                        slotModel.onElapsed(elapsed);
                    end
                end
                sealSlotMan:render();
                acc = 0;
            end
        end;
    end)());
end

----------------------------------------

(function(blessingPairs, seals)
    blessingSlotMan:start(blessingPairs);
    sealSlotMan:start(seals);

    A.hookGlobalFunction("UIParent_ManageFramePositions", "post_hook", function()
        blessingSlotMan:updateAnchorPosition();
        sealSlotMan:updateAnchorPosition();
    end);
end)(
    {
        -- spells granting buffs to others
        { "Blessing of Might", "Greater Blessing of Might" },
        { "Blessing of Wisdom", "Greater Blessing of Wisdom" },
        { "Blessing of Light", "Greater Blessing of Light" },
        { "Blessing of Salvation", "Greater Blessing of Salvation" },
        { "Blessing of Sanctuary", "Greater Blessing of Sanctuary" },
        { "Blessing of Kings", "Greater Blessing of Kings" },
    },
    {
        -- spells granting short-term buffs to self
        "Seal of Righteousness",
        "Seal of the Crusader",
        "Seal of Justice",
        "Seal of Light",
        "Seal of Wisdom",
        "Seal of Command",
    }
);
