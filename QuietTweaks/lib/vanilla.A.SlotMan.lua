local getResource = A.getResource;

A.SlotMan = A.SlotMan or (function()
    local SlotMan = {};

    -- public
    function SlotMan:new()
        local o = {
            slot_size = 32,
            slot_margin = 4,
            slot_interactive = true,
            max_x_slots = 6,
            anchor = nil,
            slotModels = {},
            slots = {},
        };

        local anchorFrame = CreateFrame("Frame", nil, UIParent, nil);
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 0);
        anchorFrame:SetWidth(4);
        anchorFrame:SetHeight(4);
        o.anchor = anchorFrame;

        return setmetatable(o, { __index = self });
    end

    -- public
    function SlotMan:createSlotModel()
        local model = {};
        model.visible = true;
        model.hovered = false;
        model.pressed = false;
        model.checked = false; -- true iff casting as of action button
        model.enabledTopLeftSpot = false;
        model.glowColor = nil;
        model.contentTexture = nil;
        model.numStacks = nil;
        model.timeToLive = nil;
        model.timeToCooldown = nil;
        return model;
    end

    function SlotMan:createSlotView()
        if (self.slot_style == "sharp_square") then
            return self:createSharpSquareSlotView();
        else
            return self:createRoundedSquareSlotView();
        end
    end

    function SlotMan:createRoundedSquareSlotView()
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

        -- indicates spell targeting
        -- e.g. "player", "target", etc
        local topLeftSpotTexture = f:CreateTexture(nil, "OVERLAY", nil, 4);
        topLeftSpotTexture:SetTexture(getResource("tile32"));
        topLeftSpotTexture:SetVertexColor(0.3, 0.85, 0.85);
        topLeftSpotTexture:SetPoint("TOPLEFT", 4, -4);
        topLeftSpotTexture:SetWidth(4);
        topLeftSpotTexture:SetHeight(4);
        f.topLeftSpotTexture = topLeftSpotTexture;

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

    function SlotMan:createSharpSquareSlotView()
        local f = self:createRoundedSquareSlotView();

        local backgroundTexture = f:CreateTexture(nil, "BACKGROUND", nil, 1);
        backgroundTexture:SetTexture(getResource("tile32"));
        backgroundTexture:SetVertexColor(0, 0, 0, 0.7);
        backgroundTexture:SetAllPoints();
        f.backgroundTexture = backgroundTexture;

        f.borderTexture:SetTexture(nil);
        f.borderPressedTexture:SetTexture(nil);

        return f;
    end

    -- public
    function SlotMan:clearAllSlotModels()
        Array.clear(self.slotModels);
    end

    -- public
    function SlotMan:renderAllSlotModels(callbackToUpdateModel)
        for i, model in ipairs(self.slotModels) do
            if (callbackToUpdateModel) then
                callbackToUpdateModel(model);
            end
            local f = self.slots[i];
            self:renderSlotModel(model, f);
        end
        for i = Array.size(self.slotModels) + 1, Array.size(self.slots), 1 do
            local f = self.slots[i];
            f:Hide();
        end
    end

    function SlotMan:renderSlotModel(model, f)
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

        if (model.contentTexture) then
            f.contentTexture:SetTexture(model.contentTexture);
        end

        if ((model.timeToCooldown or 0) > 0) then
            f.contentTexture:SetVertexColor(0.5, 0.5, 0.5);
            f.borderTexture:SetVertexColor(1.0, 1.0, 1.0);
        -- elseif no_mana then
        --     f.contentTexture:SetVertexColor(0.5, 0.5, 1.0);
        --     f.borderTexture:SetVertexColor(0.5, 0.5, 1.0);
        else
            f.contentTexture:SetVertexColor(1, 1, 1);
            f.borderTexture:SetVertexColor(1, 1, 1);
        end

        -- if (model.enabled) then
        --     f.contentTexture:SetDesaturated(false);
        -- else
        --     f.contentTexture:SetDesaturated(true);
        -- end

        if (model.enabledTopLeftSpot) then
            f.topLeftSpotTexture:Show();
        else
            f.topLeftSpotTexture:Hide();
        end

        if (model.numStacks and model.numStacks > 1) then
            f.numStacksText:SetText(model.numStacks);
        else
            f.numStacksText:SetText(nil);
        end

        f.timeToLiveBar:SetValue(model.timeToLive or 0);
        f.timeToCooldownBar:SetValue(model.timeToCooldown or 0);

        if (model.glowColor) then
            f.glowFrame:SetBackdropBorderColor(Color.toVertex(model.glowColor));
            f.glowFrame:Show();
        else
            f.glowFrame:Hide();
        end
    end

    -- public
    function SlotMan:addSlotModelAndDock(model)
        Array.add(self.slotModels, model);
        local i = Array.size(self.slotModels);
        if (i > Array.size(self.slots)) then
            Array.add(self.slots, self:createSlotView());
        end
        local f = self.slots[i];
        if (self.slot_interactive) then
            self:attachSlotScripts(f, model);
        end
        self:updateSlotPosition(f, i);
    end

    function SlotMan:attachSlotScripts(f, model)
        f:SetScript("OnHide", function()
            model.hovered = false;
            model.pressed = false;
        end);
        f:SetScript("OnEnter", function()
            model.hovered = true;
            if (model.onEnter) then
                model.onEnter(f);
            end
            SlotMan:renderSlotModel(model, f);
        end);
        f:SetScript("OnLeave", function()
            model.hovered = false;
            if (model.onLeave) then
                model.onLeave(f);
            end
            SlotMan:renderSlotModel(model, f);
        end);
        f:SetScript("OnMouseDown", function()
            model.pressed = true;
            if (model.onMouseDown) then
                model.onMouseDown(f, arg1);
            end
            SlotMan:renderSlotModel(model, f);
        end);
        f:SetScript("OnMouseUp", function()
            model.pressed = false;
            if (model.onMouseUp) then
                model.onMouseUp(f, arg1);
            end
            SlotMan:renderSlotModel(model, f);
        end);
        f:SetScript("OnClick", function()
            if (model.onClick) then
                model.onClick(f, arg1);
            end
            SlotMan:renderSlotModel(model, f);
        end);
    end

    function SlotMan:updateSlotPosition(slot, index)
        local i = index - 1;
        local y = math.floor(i / self.max_x_slots);
        local x = i - y * self.max_x_slots;
        slot:ClearAllPoints();
        slot:SetPoint("TOPLEFT", self.anchor, "TOPLEFT",
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

    local model = slotManTest:createSlotModel();
    model.contentTexture = "Interface//Icons//Spell_Holy_Light";
    slotManTest:addSlotModelAndDock(model);

    model = slotManTest:createSlotModel();
    model.contentTexture = "Interface//Icons//Spell_Holy_Light";
    slotManTest:addSlotModelAndDock(model);

    slotManTest:renderAllSlotModels();
end
