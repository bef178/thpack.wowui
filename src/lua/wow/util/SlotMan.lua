local Array = Array
local UnitIsUnit = UnitIsUnit
local getResource = Util.getResource

SlotMan = (function()
    local SlotMan = {}

    -- public
    function SlotMan:new()
        local o = {
            anchor = nil,
            max_x_slots = 6,
            slot_style = "rounded_square",
            slot_size = 32,
            slot_margin = 4,
            slot_interactable = true,
            slots = {}
        }

        local f = CreateFrame("Frame", nil, UIParent, nil)
        f:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 0)
        f:SetWidth(4)
        f:SetHeight(4)
        o.anchor = f

        return setmetatable(o, {
            __index = self
        })
    end

    -- public
    function SlotMan:render(slotModels)
        if slotModels then
            for i, slotModel in ipairs(slotModels) do
                local f = self:_getOrCreateSlot(i)
                f.slotModel = slotModel
                self:_updateSlotPosition(f, i)
            end
            for i = Array.size(slotModels) + 1, Array.size(self.slots), 1 do
                local f = self.slots[i]
                f.slotModel = nil
            end
        end
        for _, f in ipairs(self.slots) do
            self:_renderSlot(f)
        end
    end

    -- public
    function SlotMan:newSlotModel()
        local model = {}

        model.hovered = false
        model.pressed = false

        model.spellTexture = nil
        model.spellTimeToLive = nil
        model.spellTimeToCooldown = nil
        model.spellStacks = nil
        model.spellTargetUnit = nil
        model.selfBuffed = false
        model.targetBuffed = false
        model.targetDebuffed = false

        -- 空，无须关注。如长CD，无施法材料(含buff、连击点、物品)，或机制不满足(触发压制视为获得buff)
        -- 暗，施放条件不具备，但可能即将具备(如斩杀)
        -- 亮，可以施放
        -- 高亮，应立即施放
        model.visible = false
        model.dim = false
        model.glowing = false
        model.casting = false -- 正在读条(如治疗术)或正在排队(如英勇打击)

        return model
    end

    function SlotMan:_getOrCreateSlot(index)
        for i = Array.size(self.slots) + 1, index do
            local f = self:_newSlot()
            if self.slot_interactable then
                self:_attachSlotScripts(f)
            end
            Array.add(self.slots, f)
        end
        return self.slots[index]
    end

    function SlotMan:_newSlot()
        if self.slot_style == "rounded_square" then
            return self:_newRoundedSquareSlot()
        elseif self.slot_style == "sharp_square" then
            return self:_newSharpSquareSlot()
        end
    end

    function SlotMan:_newRoundedSquareSlot()
        local f = CreateFrame("Button", nil, self.anchor)
        f:SetWidth(self.slot_size)
        f:SetHeight(self.slot_size)
        -- f:EnableKeyboard(true)
        -- f:SetPropagateKeyboardInput(true)

        local contentTexture = f:CreateTexture(nil, "BORDER", nil, 1)
        contentTexture:SetTexCoord(5 / 64, 59 / 64, 5 / 64, 59 / 64)
        contentTexture:SetPoint("TOPLEFT", 2, -2)
        contentTexture:SetPoint("BOTTOMRIGHT", -2, 2)
        f.contentTexture = contentTexture

        local borderTexture = f:CreateTexture(nil, "BORDER", nil, 2)
        -- borderTexture:SetTexture(getResource("Interface\\Buttons\\UI-Quickslot2"))
        borderTexture:SetTexture(getResource("slot\\slot32,border"))
        borderTexture:SetAllPoints()
        f.borderTexture = borderTexture

        local borderPressedTexture = f:CreateTexture(nil, "BORDER", nil, 2)
        borderPressedTexture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
        -- borderPressedTexture:SetTexture(getResource("slot\\slot32,border,pressed,yellow"))
        borderPressedTexture:SetAllPoints()
        borderPressedTexture:Hide()
        f.borderPressedTexture = borderPressedTexture

        local checkedTexture = f:CreateTexture(nil, "OVERLAY", nil, 1)
        checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        checkedTexture:SetBlendMode("ADD")
        checkedTexture:SetAllPoints()
        checkedTexture:Hide()
        f.checkedTexture = checkedTexture

        -- -- auto-repeat, flip every 0.4s
        -- local redoutTexture = f:CreateTexture(nil, "OVERLAY", nil, 2)
        -- redoutTexture:SetTexture("slot\\slot64,mask,red")
        -- redoutTexture:SetAllPoints()
        -- redoutTexture:Hide()
        -- f.redoutTexture = redoutTexture

        local hoveredTexture = f:CreateTexture(nil, "OVERLAY", nil, 3)
        -- hoveredTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        hoveredTexture:SetTexture(getResource("slot\\slot32,inner-glow,white"))
        hoveredTexture:SetBlendMode("ADD")
        hoveredTexture:SetVertexColor(0.3, 0.3, 0.3)
        hoveredTexture:SetAllPoints()
        hoveredTexture:Hide()
        f.hoveredTexture = hoveredTexture

        local selfBuffedTextureRegion = f:CreateTexture(nil, "OVERLAY", nil, 4)
        selfBuffedTextureRegion:SetTexture(getResource("tile32"))
        selfBuffedTextureRegion:SetVertexColor(0.85, 0.85, 0.3)
        selfBuffedTextureRegion:SetPoint("TOPLEFT", 4, 2)
        selfBuffedTextureRegion:SetWidth(4)
        selfBuffedTextureRegion:SetHeight(4)
        f.selfBuffedTextureRegion = selfBuffedTextureRegion

        local selfTargetedTextureRegion = f:CreateTexture(nil, "OVERLAY", nil, 4)
        selfTargetedTextureRegion:SetTexture(getResource("tile32"))
        selfTargetedTextureRegion:SetVertexColor(0.3, 0.85, 0.85)
        selfTargetedTextureRegion:SetPoint("TOPLEFT", 4, -4)
        selfTargetedTextureRegion:SetWidth(4)
        selfTargetedTextureRegion:SetHeight(4)
        f.selfTargetedTextureRegion = selfTargetedTextureRegion

        local targetBuffedTextureRegion = f:CreateTexture(nil, "OVERLAY", nil, 5)
        targetBuffedTextureRegion:SetTexture(getResource("tile32"))
        targetBuffedTextureRegion:SetVertexColor(0.3, 0.8, 0)
        targetBuffedTextureRegion:SetPoint("TOPLEFT", 10, 2)
        targetBuffedTextureRegion:SetWidth(4)
        targetBuffedTextureRegion:SetHeight(4)
        f.targetBuffedTextureRegion = targetBuffedTextureRegion

        local targetDebuffedTextureRegion = f:CreateTexture(nil, "OVERLAY", nil, 5)
        targetDebuffedTextureRegion:SetTexture(getResource("tile32"))
        targetDebuffedTextureRegion:SetVertexColor(0.85, 0.3, 0.3)
        targetDebuffedTextureRegion:SetPoint("TOPLEFT", targetBuffedTextureRegion, "TOPLEFT")
        targetDebuffedTextureRegion:SetWidth(4)
        targetDebuffedTextureRegion:SetHeight(4)
        f.targetDebuffedTextureRegion = targetDebuffedTextureRegion

        local timeToLiveBar = CreateFrame("StatusBar", nil, f, nil)
        timeToLiveBar:SetStatusBarTexture(getResource("tile32"))
        timeToLiveBar:SetStatusBarColor(0, 1, 0, 0.85)
        timeToLiveBar:SetHeight(4)
        timeToLiveBar:SetPoint("BOTTOMLEFT", 0, 0)
        timeToLiveBar:SetPoint("BOTTOMRIGHT", 0, 0)
        timeToLiveBar:SetMinMaxValues(0, 6)
        timeToLiveBar:SetValue(0)
        f.timeToLiveBar = timeToLiveBar

        -- stack count for buff or recharge count for action
        local numStacksText = f:CreateFontString(nil, "OVERLAY", nil)
        numStacksText:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
        numStacksText:SetShadowColor(0, 0, 0, 1)
        numStacksText:SetShadowOffset(1, 1)
        numStacksText:SetJustifyH("RIGHT")
        numStacksText:SetPoint("BOTTOMRIGHT", timeToLiveBar, "TOPRIGHT", -1, 2)
        f.numStacksText = numStacksText

        local timeToCooldownBar = CreateFrame("StatusBar", nil, f, nil)
        timeToCooldownBar:SetStatusBarTexture(getResource("tile32"))
        timeToCooldownBar:SetStatusBarColor(1, 1, 1, 0.85)
        timeToCooldownBar:SetHeight(4)
        timeToCooldownBar:SetPoint("BOTTOMLEFT", 0, 0)
        timeToCooldownBar:SetPoint("BOTTOMRIGHT", 0, 0)
        timeToCooldownBar:SetMinMaxValues(0, 6)
        timeToCooldownBar:SetValue(0)
        timeToCooldownBar:SetFrameLevel(timeToLiveBar:GetFrameLevel() + 1)
        f.timeToCooldownBar = timeToCooldownBar

        local glowWidth = 4
        local glowFrame = CreateFrame("Frame", nil, f, nil)
        glowFrame:SetFrameStrata("BACKGROUND")
        glowFrame:SetFrameLevel(1)
        glowFrame:SetBackdrop({
            edgeFile = getResource("glow"),
            edgeSize = glowWidth
        })
        local glowOffset = glowWidth - 1
        glowFrame:SetPoint("TOPLEFT", -glowOffset, glowOffset)
        glowFrame:SetPoint("BOTTOMRIGHT", glowOffset, -glowOffset)
        glowFrame:Hide()
        f.glowFrame = glowFrame

        return f
    end

    function SlotMan:_newSharpSquareSlot()
        local f = self:_newRoundedSquareSlot()

        local backgroundTexture = f:CreateTexture(nil, "BACKGROUND", nil, 1)
        backgroundTexture:SetTexture(getResource("tile32"))
        backgroundTexture:SetVertexColor(0, 0, 0, 0.7)
        backgroundTexture:SetAllPoints()
        f.backgroundTexture = backgroundTexture

        f.borderTexture:SetTexture(nil)
        f.borderPressedTexture:SetTexture(nil)

        return f
    end

    function SlotMan:_renderSlot(f)
        local model = f.slotModel
        if not model then
            f:Hide()
            return
        end
        if model.visible then
            f:Show()
        else
            f:Hide()
            return
        end

        if model.casting then
            f.checkedTexture:Show()
        else
            f.checkedTexture:Hide()
        end

        if model.pressed then
            f.borderTexture:Hide()
            f.borderPressedTexture:Show()
        else
            f.borderTexture:Show()
            f.borderPressedTexture:Hide()
        end

        if model.hovered then
            f.hoveredTexture:Show()
        else
            f.hoveredTexture:Hide()
        end

        if model.spellTexture then
            f.contentTexture:SetTexture(model.spellTexture)
        end

        -- f.contentTexture:SetDesaturated(model.dim)
        if model.dim then
            f.contentTexture:SetVertexColor(0.5, 0.5, 0.5)
            -- f.borderTexture:SetVertexColor(1, 1, 1)
        else
            f.contentTexture:SetVertexColor(1, 1, 1)
            -- f.borderTexture:SetVertexColor(1, 1, 1)
        end
        -- elseif no_mana then
        --     f.contentTexture:SetVertexColor(0.5, 0.5, 1.0)
        --     f.borderTexture:SetVertexColor(0.5, 0.5, 1.0)

        if model.selfBuffed then
            f.selfBuffedTextureRegion:Show()
        else
            f.selfBuffedTextureRegion:Hide()
        end

        if model.spellTargetUnit and UnitIsUnit(model.spellTargetUnit, "player") then
            f.selfTargetedTextureRegion:Show()
        else
            f.selfTargetedTextureRegion:Hide()
        end

        if model.targetBuffed then
            f.targetBuffedTextureRegion:Show()
        else
            f.targetBuffedTextureRegion:Hide()
        end

        if model.targetDebuffed then
            f.targetDebuffedTextureRegion:Show()
        else
            f.targetDebuffedTextureRegion:Hide()
        end

        if model.spellStacks and model.spellStacks ~= 1 then
            f.numStacksText:SetText(model.spellStacks)
        else
            f.numStacksText:SetText(nil)
        end

        f.timeToLiveBar:SetValue(model.spellTimeToLive or 0)
        f.timeToCooldownBar:SetValue(model.spellTimeToCooldown or 0)

        if model.glowing then
            f.glowFrame:SetBackdropBorderColor(1, 1, 1, 0.8)
            f.glowFrame:Show()
        else
            f.glowFrame:Hide()
        end
    end

    function SlotMan:_attachSlotScripts(f)
        local slotMan = self
        f:SetScript("OnHide", function()
            if f.slotModel then
                f.slotModel.hovered = false
                f.slotModel.pressed = false
            end
        end)
        f:SetScript("OnEnter", function()
            f.slotModel.hovered = true
            if f.slotModel.onEnter then
                f.slotModel.onEnter(f)
            end
            slotMan:_renderSlot(f)
        end)
        f:SetScript("OnLeave", function()
            f.slotModel.hovered = false
            if f.slotModel.onLeave then
                f.slotModel.onLeave(f)
            end
            slotMan:_renderSlot(f)
        end)
        f:SetScript("OnMouseDown", function()
            f.slotModel.pressed = true
            if f.slotModel.onMouseDown then
                f.slotModel.onMouseDown(f, arg1)
            end
            slotMan:_renderSlot(f)
        end)
        f:SetScript("OnMouseUp", function()
            f.slotModel.pressed = false
            if f.slotModel.onMouseUp then
                f.slotModel.onMouseUp(f, arg1)
            end
            slotMan:_renderSlot(f)
        end)
        f:SetScript("OnClick", function()
            if f.slotModel.onClick then
                f.slotModel.onClick(f, arg1)
            end
            slotMan:_renderSlot(f)
        end)
    end

    function SlotMan:_updateSlotPosition(f, index)
        local y = f.slotModel.y or (math.floor((index - 1) / self.max_x_slots))
        local x = f.slotModel.x or (index - 1 - y * self.max_x_slots)
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", self.anchor, "TOPLEFT", x * (self.slot_size + self.slot_margin), y * (self.slot_size + self.slot_margin))
    end

    return SlotMan
end)()

local debug = nil
if debug then
    local SlotMan = SlotMan

    local slotManDemo = SlotMan:new()

    local model = slotManDemo:newSlotModel()
    model.spellTexture = "Interface//Icons//Spell_Holy_Light"

    local model2 = slotManDemo:newSlotModel()
    model2.spellTexture = "Interface//Icons//Spell_Holy_Light"

    slotManDemo:render({model, model2})
end
