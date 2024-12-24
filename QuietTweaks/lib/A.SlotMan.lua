local A = A;
local getResource = A.getResource;

A.SlotMan = A.SlotMan or (function()
    local SlotMan = {};

    -- public
    function SlotMan:new()
        local o = {
            slot_size = 32,
            slot_margin = 4,
            slot_interactable = true,
            max_x_slots = 6,
            anchor = nil,
            slots = {},
        };

        local f = CreateFrame("Frame", nil, UIParent, nil);
        f:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 0);
        f:SetWidth(4);
        f:SetHeight(4);
        o.anchor = f;

        return setmetatable(o, { __index = self });
    end

    -- public
    function SlotMan:newSlotModel()
        local model = {};

        model.visible = false;
        model.hovered = false;
        model.pressed = false;
        model.checked = false; -- true iff casting as of action button
        model.glowing = false;

        model.numStacks = nil;

        model.spellTexture = nil;
        model.spellReadyToCast = false;
        model.spellTimeToLive = nil;
        model.spellTimeToCooldown = nil;
        model.spellTargetUnit = nil;
        model.spellTargetUnitAffected = false;

        return model;
    end

    -- public
    function SlotMan:render(slotModels)
        if (slotModels) then
            for i, slotModel in ipairs(slotModels) do
                if (i > Array.size(self.slots)) then
                    local slot = self:_slotNew();
                    if (self.slot_interactable) then
                        self:_slotAttachScripts(slot);
                    end
                    Array.add(self.slots, slot);
                end
                local slot = self.slots[i];
                slot.slotModel = slotModel;
                self:_slotUpdatePosition(slot, i - 1);
            end
            for i = Array.size(slotModels) + 1, Array.size(self.slots), 1 do
                local slot = self.slots[i];
                slot.slotModel = nil;
            end
        end
        for _, slot in ipairs(self.slots) do
            self:_slotRender(slot);
        end
    end

    function SlotMan:_slotNew()
        if (self.slot_style == "sharp_square") then
            return self:_slotNewSharpSquareButton();
        else
            return self:_slotNewRoundedSquareButton();
        end
    end

    function SlotMan:_slotNewRoundedSquareButton()
        local f = CreateFrame("Button", nil, self.anchor);
        f:SetWidth(self.slot_size);
        f:SetHeight(self.slot_size);
        -- f:EnableKeyboard(true);
        -- f:SetPropagateKeyboardInput(true);

        local contentTexture = f:CreateTexture(nil, "BORDER", nil, 1);
        contentTexture:SetTexCoord(5 / 64, 59 / 64, 5 / 64, 59 / 64);
        contentTexture:SetPoint("TOPLEFT", 2, -2);
        contentTexture:SetPoint("BOTTOMRIGHT", -2, 2);
        f.contentTexture = contentTexture;

        local borderTexture = f:CreateTexture(nil, "BORDER", nil, 2);
        -- borderTexture:SetTexture(getResource("Interface\\Buttons\\UI-Quickslot2"));
        borderTexture:SetTexture(getResource("slot\\slot32,border"));
        borderTexture:SetAllPoints();
        f.borderTexture = borderTexture;

        local borderPressedTexture = f:CreateTexture(nil, "BORDER", nil, 2);
        borderPressedTexture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress");
        -- borderPressedTexture:SetTexture(getResource("slot\\slot32,border,pressed,yellow"));
        borderPressedTexture:SetAllPoints();
        borderPressedTexture:Hide();
        f.borderPressedTexture = borderPressedTexture;

        local checkedTexture = f:CreateTexture(nil, "OVERLAY", nil, 1);
        checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight");
        checkedTexture:SetBlendMode("ADD");
        checkedTexture:SetAllPoints();
        checkedTexture:Hide();
        f.checkedTexture = checkedTexture;

        -- -- auto-repeat, flip every 0.4s
        -- local redoutTexture = f:CreateTexture(nil, "OVERLAY", nil, 2);
        -- redoutTexture:SetTexture("slot\\slot64,mask,red");
        -- redoutTexture:SetAllPoints();
        -- redoutTexture:Hide();
        -- f.redoutTexture = redoutTexture;

        local hoveredTexture = f:CreateTexture(nil, "OVERLAY", nil, 3);
        -- hoveredTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
        hoveredTexture:SetTexture(getResource("slot\\slot32,inner-glow,white"));
        hoveredTexture:SetBlendMode("ADD");
        hoveredTexture:SetVertexColor(0.3, 0.3, 0.3);
        hoveredTexture:SetAllPoints();
        hoveredTexture:Hide();
        f.hoveredTexture = hoveredTexture;

        local cyanSpotTexture = f:CreateTexture(nil, "OVERLAY", nil, 4);
        cyanSpotTexture:SetTexture(getResource("tile32"));
        cyanSpotTexture:SetVertexColor(0.3, 0.85, 0.85);
        cyanSpotTexture:SetPoint("TOPLEFT", 4, -4);
        cyanSpotTexture:SetWidth(4);
        cyanSpotTexture:SetHeight(4);
        f.cyanSpotTexture = cyanSpotTexture;

        local yellowSpotTexture = f:CreateTexture(nil, "OVERLAY", nil, 5);
        yellowSpotTexture:SetTexture(getResource("tile32"));
        yellowSpotTexture:SetVertexColor(1, 0.8, 0);
        yellowSpotTexture:SetPoint("TOPLEFT", 4, 2);
        yellowSpotTexture:SetWidth(4);
        yellowSpotTexture:SetHeight(4);
        f.yellowSpotTexture = yellowSpotTexture;

        local timeToLiveBar = CreateFrame("StatusBar", nil, f, nil);
        timeToLiveBar:SetStatusBarTexture(getResource("tile32"));
        timeToLiveBar:SetStatusBarColor(0, 1, 0, 0.85);
        timeToLiveBar:SetHeight(4);
        timeToLiveBar:SetPoint("BOTTOMLEFT", 0, 0);
        timeToLiveBar:SetPoint("BOTTOMRIGHT", 0, 0);
        timeToLiveBar:SetMinMaxValues(0, 6);
        timeToLiveBar:SetValue(0);
        f.timeToLiveBar = timeToLiveBar;

        -- stack count for buff or recharge count for action
        local numStacksText = f:CreateFontString(nil, "OVERLAY", nil);
        numStacksText:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE");
        numStacksText:SetShadowColor(0, 0, 0, 1);
        numStacksText:SetShadowOffset(1, 1);
        numStacksText:SetJustifyH("RIGHT");
        numStacksText:SetPoint("BOTTOMRIGHT", timeToLiveBar, "TOPRIGHT", -1, 2);
        f.numStacksText = numStacksText;

        local timeToCooldownBar = CreateFrame("StatusBar", nil, f, nil);
        timeToCooldownBar:SetStatusBarTexture(getResource("tile32"));
        timeToCooldownBar:SetStatusBarColor(1, 1, 1, 0.85);
        timeToCooldownBar:SetHeight(4);
        timeToCooldownBar:SetPoint("BOTTOMLEFT", 0, 0);
        timeToCooldownBar:SetPoint("BOTTOMRIGHT", 0, 0);
        timeToCooldownBar:SetMinMaxValues(0, 6);
        timeToCooldownBar:SetValue(0);
        timeToCooldownBar:SetFrameLevel(timeToLiveBar:GetFrameLevel() + 1);
        f.timeToCooldownBar = timeToCooldownBar;

        local glowWidth = 4;
        local glowFrame = CreateFrame("Frame", nil, f, nil);
        glowFrame:SetFrameStrata("BACKGROUND");
        glowFrame:SetFrameLevel(1);
        glowFrame:SetBackdrop({
            edgeFile = getResource("glow.tga"),
            edgeSize = glowWidth,
        });
        local glowOffset = glowWidth - 1;
        glowFrame:SetPoint("TOPLEFT", -glowOffset, glowOffset);
        glowFrame:SetPoint("BOTTOMRIGHT", glowOffset, -glowOffset);
        glowFrame:Hide();
        f.glowFrame = glowFrame;

        return f;
    end

    function SlotMan:_slotNewSharpSquareButton()
        local f = self:_slotNewRoundedSquareButton();

        local backgroundTexture = f:CreateTexture(nil, "BACKGROUND", nil, 1);
        backgroundTexture:SetTexture(getResource("tile32"));
        backgroundTexture:SetVertexColor(0, 0, 0, 0.7);
        backgroundTexture:SetAllPoints();
        f.backgroundTexture = backgroundTexture;

        f.borderTexture:SetTexture(nil);
        f.borderPressedTexture:SetTexture(nil);

        return f;
    end

    function SlotMan:_slotRender(f)
        local model = f.slotModel;
        if (not model) then
            f:Hide();
            return;
        end
        if (model.visible) then
            f:Show();
        else
            f:Hide();
            return;
        end

        if (model.checked) then
            f.checkedTexture:Show();
        else
            f.checkedTexture:Hide();
        end

        if (model.pressed) then
            f.borderTexture:Hide();
            f.borderPressedTexture:Show();
        else
            f.borderTexture:Show();
            f.borderPressedTexture:Hide();
        end

        if (model.hovered) then
            f.hoveredTexture:Show();
        else
            f.hoveredTexture:Hide();
        end

        if (model.spellTexture) then
            f.contentTexture:SetTexture(model.spellTexture);
        end

        -- f.contentTexture:SetDesaturated(not model.spellReadyToCast);
        if (model.spellReadyToCast) then
            f.contentTexture:SetVertexColor(1, 1, 1);
            f.borderTexture:SetVertexColor(1, 1, 1);
        else
            f.contentTexture:SetVertexColor(0.5, 0.5, 0.5);
            f.borderTexture:SetVertexColor(1.0, 1.0, 1.0);
        end
        -- elseif no_mana then
        --     f.contentTexture:SetVertexColor(0.5, 0.5, 1.0);
        --     f.borderTexture:SetVertexColor(0.5, 0.5, 1.0);

        if (model.spellTargetUnit == "player") then
            f.cyanSpotTexture:Show();
        else
            f.cyanSpotTexture:Hide();
        end

        if (model.spellTargetUnitAffected) then
            f.yellowSpotTexture:Show();
        else
            f.yellowSpotTexture:Hide();
        end

        if (model.numStacks and model.numStacks ~= 1) then
            f.numStacksText:SetText(model.numStacks);
        else
            f.numStacksText:SetText(nil);
        end

        f.timeToLiveBar:SetValue(model.spellTimeToLive or 0);
        f.timeToCooldownBar:SetValue(model.spellTimeToCooldown or 0);

        if (model.glowing) then
            f.glowFrame:SetBackdropBorderColor(1, 1, 1, 0.8);
            f.glowFrame:Show();
        else
            f.glowFrame:Hide();
        end
    end

    function SlotMan:_slotAttachScripts(f)
        local slotMan = self;
        f:SetScript("OnHide", function()
            f.slotModel.hovered = false;
            f.slotModel.pressed = false;
        end);
        f:SetScript("OnEnter", function()
            f.slotModel.hovered = true;
            if (f.slotModel.onEnter) then
                f.slotModel.onEnter(f);
            end
            slotMan:_slotRender(f);
        end);
        f:SetScript("OnLeave", function()
            f.slotModel.hovered = false;
            if (f.slotModel.onLeave) then
                f.slotModel.onLeave(f);
            end
            slotMan:_slotRender(f);
        end);
        f:SetScript("OnMouseDown", function()
            f.slotModel.pressed = true;
            if (f.slotModel.onMouseDown) then
                f.slotModel.onMouseDown(f, arg1);
            end
            slotMan:_slotRender(f);
        end);
        f:SetScript("OnMouseUp", function()
            f.slotModel.pressed = false;
            if (f.slotModel.onMouseUp) then
                f.slotModel.onMouseUp(f, arg1);
            end
            slotMan:_slotRender(f);
        end);
        f:SetScript("OnClick", function()
            if (f.slotModel.onClick) then
                f.slotModel.onClick(f, arg1);
            end
            slotMan:_slotRender(f);
        end);
    end

    function SlotMan:_slotUpdatePosition(f, index)
        local y = f.slotModel.y or (math.floor(index / self.max_x_slots));
        local x = f.slotModel.x or (index - y * self.max_x_slots);
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", self.anchor, "TOPLEFT",
            x * (self.slot_size + self.slot_margin),
            y * (self.slot_size + self.slot_margin));
    end

    return SlotMan;
end)();

local debug = nil;
if (debug) then
    local SlotMan = A.SlotMan;

    local slotManTest = SlotMan:new();
    A.slotManTest = slotManTest;

    local model = slotManTest:newSlotModel();
    model.spellTexture = "Interface//Icons//Spell_Holy_Light";

    local model2 = slotManTest:newSlotModel();
    model2.spellTexture = "Interface//Icons//Spell_Holy_Light";

    slotManTest:render({ model, model2 });
end
