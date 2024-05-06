local getResource = A.getResource;

-- manage rounded square action buttons
A.SlotMan = A.SlotMan or (function()
    local SlotMan = {};

    -- public
    function SlotMan:createSlotModel()
        local model = {};
        model.visible = true;
        model.hovered = false;
        model.pressed = false;
        model.checked = false; -- true iff casting as of action button
        model.enabledTopLeftSpotTexture = false;
        model.glowing = false;
        model.contentTexture = nil;
        model.contentVariant = nil; -- color change as of action button, e.g. when out of mana
        model.numStacks = nil;
        model.timeToLive = nil;
        model.timeToCooldown = nil;
        return model;
    end

    -- rounded square button
    function SlotMan:createSlot()
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
        -- borderPressedTexture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress");
        borderPressedTexture:SetTexture(getResource("slot\\slot32,border,pressed,yellow"));
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
        local countText = f:CreateFontString(nil, "OVERLAY", nil);
        countText:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE");
        countText:SetShadowColor(0, 0, 0, 1);
        countText:SetShadowOffset(1, 1);
        countText:SetJustifyH("RIGHT");
        countText:SetPoint("BOTTOMRIGHT", timeToLiveBar, "TOPRIGHT", -1, 2);
        f.countText = countText;

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

        local glowWidth = 8;
        local glowFrame = CreateFrame("Frame", nil, f, nil);
        glowFrame:SetFrameStrata("BACKGROUND");
        glowFrame:SetFrameLevel(1);
        glowFrame:SetBackdrop({
            edgeFile = getResource("glow.tga"),
            edgeSize = glowWidth,
        });
        local glowOffset = glowWidth + 1;
        glowFrame:SetPoint("TOPLEFT", -glowOffset, glowOffset);
        glowFrame:SetPoint("BOTTOMRIGHT", glowOffset, -glowOffset);
        glowFrame:Hide();
        f.glowFrame = glowFrame;

        return f;
    end

    function SlotMan:createSharpSquareSlot()
        local f = self:createSlot();

        local backgroundTexture = f:CreateTexture(nil, "BACKGROUND", nil, 1);
        backgroundTexture:SetTexture(getResource("tile32"));
        backgroundTexture:SetVertexColor(0, 0, 0, 0.7);
        backgroundTexture:SetAllPoints();
        f.backgroundTexture = backgroundTexture;

        f.borderTexture:SetTexture(nil);
        f.borderPressedTexture:SetTexture(nil);

        return f;
    end

    function SlotMan:attachSlotScripts(f, model)
        f:SetScript("OnEnter", function()
            model.hovered = true;
            if (model.onEnter) then
                model.onEnter(f);
            end
            SlotMan:renderSlot(f, model);
        end);
        f:SetScript("OnLeave", function()
            model.hovered = false;
            if (model.onLeave) then
                model.onLeave(f);
            end
            SlotMan:renderSlot(f, model);
        end);
        f:SetScript("OnMouseDown", function()
            model.pressed = true;
            if (model.onMouseDown) then
                model.onMouseDown(f, arg1);
            end
            SlotMan:renderSlot(f, model);
        end);
        f:SetScript("OnMouseUp", function()
            model.pressed = false;
            if (model.onMouseUp) then
                model.onMouseUp(f, arg1);
            end
            SlotMan:renderSlot(f, model);
        end);
        f:SetScript("OnClick", function()
            if (model.onClick) then
                model.onClick(f, arg1);
            end
            SlotMan:renderSlot(f, model);
        end);

        f:SetScript("OnUpdate", function()
            if (model.onUpdate) then
                model.onUpdate(f, arg1);
            end
            SlotMan:renderSlot(f, model);
        end);
    end

    function SlotMan:renderSlot(f, model)
        if (model.visible) then
            f:Show();
        else
            f:Hide();
            return;
        end

        if (model.contentTexture) then
            f.contentTexture:SetTexture(model.contentTexture);
        end

        if (not model.contentVariant) then
            f.contentTexture:SetVertexColor(1, 1, 1);
            f.borderTexture:SetVertexColor(1, 1, 1);
        elseif (model.contentVariant == "no_mana") then
            f.contentTexture:SetVertexColor(0.5, 0.5, 1.0);
            f.borderTexture:SetVertexColor(0.5, 0.5, 1.0);
        else
            -- invalid target, out of range, etc
            f.contentTexture:SetVertexColor(0.5, 0.5, 0.5);
            f.borderTexture:SetVertexColor(1.0, 1.0, 1.0);
        end

        -- if (model.enabled) then
        --     f.contentTexture:SetDesaturated(false);
        -- else
        --     f.contentTexture:SetDesaturated(true);
        -- end

        if (model.enabledTopLeftSpotTexture) then
            f.topLeftSpotTexture:Show();
        else
            f.topLeftSpotTexture:Hide();
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

        if (model.numStacks and model.numStacks > 1) then
            f.countText:SetText(model.numStacks);
        else
            f.countText:SetText(nil);
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
    function SlotMan:new()
        local o = {
            slot_size = 32,
            slot_margin = 4,
            max_x_slots = 6,
            models = {},
            anchor = nil,
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
    function SlotMan:addSlotModel(model)
        Array.add(self.models, model);
        return Array.size(self.models);
    end

    -- public
    function SlotMan:clearAllSlotModels()
        Array.clear(self.models);
    end

    -- public
    function SlotMan:renderAllSlots()
        for i, model in ipairs(self.models) do
            local slot = self.slots[i];
            if (not slot) then
                slot = self:createSlot();
                self:attachSlotScripts(slot, model);
                self:updateSlotPosition(slot, i);
                Array.add(self.slots, slot);
            end
            self:renderSlot(slot, model);
        end
        for i = Array.size(self.models) + 1, Array.size(self.slots), 1 do
            local slot = self.slots[i];
            slot:Hide();
        end
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

    local model = slotManTest:createAndAddSlotModel();
    model.contentTexture = "Interface//Icons//Spell_Holy_Light";
    model.contextVariant = "no_mana";

    model = slotManTest:createAndAddSlotModel();
    model.contentTexture = "Interface//Icons//Spell_Holy_Light";
    model.contextVariant = "out_of_range";

    slotManTest:renderAllSlots();
end
