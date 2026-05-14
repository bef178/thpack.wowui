local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local GetUnitName = GetUnitName
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
local UnitIsEnemy = UnitIsEnemy
local UnitClass = UnitClass
local UnitAffectingCombat = UnitAffectingCombat
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

local Color = Color
local getResource = Util.getResource
local getClassColor = Util.getClassColor
local UnitUtil = UnitUtil

local MAX_PLAYER_LEVEL = 60

-- for nameplate
FlatUnitFrame = (function()
    local FlatUnitFrame = {}

    function FlatUnitFrame.createUnitFrame(parent)
        local w = 72
        local h = 20
        local uf = CreateFrame("Button", nil, parent, nil)
        uf:SetScale(UIParent:GetScale())
        uf:SetWidth(w)
        uf:SetHeight(h)
        uf:EnableMouse(false)

        FlatUnitFrame._enableNameFrame(uf)
        FlatUnitFrame._enableHealthBar(uf, w, 4)
        FlatUnitFrame._enableSelectionFrame(uf)
        FlatUnitFrame._enableRaidFrame(uf)

        return uf
    end

    -- unit name, level
    function FlatUnitFrame._enableNameFrame(uf)
        local nameFrame = CreateFrame("Frame", nil, uf, nil)
        nameFrame:SetAllPoints()
        uf.nameFrame = nameFrame

        local nameTextRegion = uf:CreateFontString(nil, "BACKGROUND")
        nameTextRegion:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        nameTextRegion:SetShadowOffset(0, 0)
        nameTextRegion:SetJustifyH("CENTER")
        nameTextRegion:SetPoint("BOTTOM", uf, "BOTTOM", 0, 8)
        nameFrame.nameTextRegion = nameTextRegion

        local levelTextRegion = uf:CreateFontString(nil, "BACKGROUND")
        levelTextRegion:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        levelTextRegion:SetShadowOffset(0, 0)
        levelTextRegion:SetJustifyH("RIGHT")
        levelTextRegion:SetPoint("BOTTOMRIGHT", uf, "BOTTOMLEFT", -4, -3)
        nameFrame.levelTextRegion = levelTextRegion

        nameFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        nameFrame:RegisterEvent("UNIT_NAME_UPDATE")
        nameFrame:RegisterEvent("UNIT_LEVEL")
        nameFrame:RegisterEvent("UNIT_FACTION")
        nameFrame:SetScript("OnEvent", function()
            local event = event
            local unit = arg1
            if event == "PLAYER_ENTERING_WORLD" then
                FlatUnitFrame._invalidateNameFrame(nameFrame, uf.unit)
            else
                if not unit or unit ~= uf.unit then
                    return
                end
                FlatUnitFrame._invalidateNameFrame(nameFrame, unit)
            end
        end)
    end

    function FlatUnitFrame._invalidateNameFrame(nameFrame, unit)
        if not unit then
            return
        end

        local name = GetUnitName(unit)
        local nameColor = UnitUtil.getUnitNameColor(unit)

        local level
        do
            local playerLevel = UnitLevel("player")
            local unitLevel = UnitLevel(unit)
            local unitLevelSuffix = UnitUtil.getUnitLevelSuffix(unit)
            if unitLevel == -1 then
                level = "??"
            elseif playerLevel == MAX_PLAYER_LEVEL and unitLevel == MAX_PLAYER_LEVEL and unitLevelSuffix == "" then
                level = ""
            else
                level = unitLevel .. unitLevelSuffix
            end
        end

        FlatUnitFrame._renderNameFrame(nameFrame, name, nameColor, level, UnitUtil.getUnitLevelColor(unit))
    end

    function FlatUnitFrame._renderNameFrame(nameFrame, name, nameColor, level, levelColor)
        if not nameFrame or not name then
            return
        end

        if nameFrame.nameTextRegion then
            local nameTextRegion = nameFrame.nameTextRegion
            nameTextRegion:SetText(name)
            nameTextRegion:SetVertexColor(Color.toVertex(nameColor))
        end

        if nameFrame.levelTextRegion then
            local levelTextRegion = nameFrame.levelTextRegion
            if not level or level == "" then
                levelTextRegion:SetText()
            else
                levelTextRegion:SetText(level)
                levelTextRegion:SetVertexColor(Color.toVertex(levelColor))
            end
        end
    end

    function FlatUnitFrame._enableHealthBar(uf, w, h)
        local healthBar = CreateFrame("StatusBar", nil, uf, nil)
        healthBar:SetStatusBarTexture(getResource("healthbar32"))
        healthBar:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8X8]]
        })
        healthBar:SetBackdropColor(0, 0, 0, 0.7)
        healthBar:SetMinMaxValues(0, 1)
        healthBar:SetWidth(w)
        healthBar:SetHeight(h)
        healthBar:SetPoint("BOTTOM", uf, "BOTTOM", 0, 0)
        uf.healthBar = healthBar

        local glowFrame = CreateFrame("Frame", nil, healthBar, nil)
        glowFrame:SetBackdrop({
            edgeFile = getResource("glow"),
            edgeSize = 5
        })
        glowFrame:SetBackdropBorderColor(0, 0, 0, 0.7)
        glowFrame:SetPoint("TOPLEFT", -5, 5)
        glowFrame:SetPoint("BOTTOMRIGHT", 5, -5)
        healthBar.glowFrame = glowFrame

        local valueTextRegion = healthBar:CreateFontString(nil, "ARTWORK")
        valueTextRegion:SetFont(getResource([[font\impact.ttf]]), 12, "OUTLINE")
        valueTextRegion:SetVertexColor(1, 1, 1)
        valueTextRegion:SetShadowOffset(0, 0)
        valueTextRegion:SetJustifyH("LEFT")
        valueTextRegion:SetPoint("LEFT", healthBar, "RIGHT", 4, 1)
        healthBar.valueTextRegion = valueTextRegion

        healthBar:RegisterEvent("PLAYER_ENTERING_WORLD")
        healthBar:RegisterEvent("PLAYER_REGEN_ENABLED")
        healthBar:RegisterEvent("PLAYER_REGEN_DISABLED")
        healthBar:RegisterEvent("UNIT_HEALTH")
        healthBar:RegisterEvent("UNIT_MAXHEALTH")
        healthBar:SetScript("OnEvent", function()
            local event = event
            if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
                FlatUnitFrame._invalidateHealthBar(healthBar, uf.unit)
            else
                local unit = arg1
                if not unit or unit ~= uf.unit then
                    return
                end
                FlatUnitFrame._invalidateHealthBar(healthBar, unit)
            end
        end)
    end

    function FlatUnitFrame._invalidateHealthBar(healthBar, unit)
        if not unit then
            return
        end

        local fraction
        do
            local health = UnitHealth(unit)
            local maxHealth = UnitHealthMax(unit)
            if not maxHealth or maxHealth == 0 then
                maxHealth = 1
            end
            fraction = health / maxHealth
        end

        local barColor
        do
            if UnitIsPlayer(unit) then
                local _, classType = UnitClass(unit)
                barColor = getClassColor(classType)
            else
                barColor = UnitUtil.getUnitNameColor(unit)
            end
        end

        FlatUnitFrame._renderHealthBar(healthBar, fraction, barColor, UnitAffectingCombat("player"))
    end

    function FlatUnitFrame._renderHealthBar(healthBar, fraction, barColor, inCombat)
        if not healthBar then
            return
        end

        fraction = fraction or 0
        if fraction < 0.001 then
            fraction = 0
        elseif fraction > 0.999 then
            fraction = 1
        end
        healthBar:SetValue(fraction)
        healthBar:SetStatusBarColor(Color.toVertex(barColor))

        local valueTextRegion = healthBar.valueTextRegion
        if healthBar.valueTextRegion then
            local valueTextRegion = healthBar.valueTextRegion
            if fraction == 1 and not inCombat then
                valueTextRegion:SetText()
            else
                if fraction < 0.01 then
                    local value = math.floor(fraction * 1000) / 10
                    valueTextRegion:SetText(value .. "%")
                else
                    local value = math.floor(fraction * 100)
                    valueTextRegion:SetText(value .. "%")
                end
                if fraction > 0.5 then
                    valueTextRegion:SetVertexColor(0, 1, 0)
                elseif fraction > 0.215 then
                    valueTextRegion:SetVertexColor(1, 0.82, 0)
                else
                    valueTextRegion:SetVertexColor(1, 0, 0)
                end
            end
        end
    end

    function FlatUnitFrame._enableSelectionFrame(uf)
        local selectionFrame = CreateFrame("Frame", nil, uf, nil)
        selectionFrame:SetAllPoints()
        uf.selectionFrame = selectionFrame

        local selectionTexture = selectionFrame:CreateTexture(nil, "BACKGROUND")
        selectionTexture:SetTexture(getResource("highlight"))
        selectionTexture:SetVertexColor(1, 1, 1)
        selectionTexture:SetBlendMode("ADD")
        selectionTexture:SetPoint("TOPLEFT", selectionFrame, "BOTTOMLEFT", 0, 4)
        selectionTexture:SetPoint("TOPRIGHT", selectionFrame, "BOTTOMRIGHT", 0, 4)
        selectionFrame.selectionTexture = selectionTexture

        selectionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        selectionFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        selectionFrame:SetScript("OnEvent", function()
            FlatUnitFrame._invalidateSelectionFrame(selectionFrame, uf.unit)
        end)
    end

    function FlatUnitFrame._invalidateSelectionFrame(selectionFrame, unit)
        if not unit then
            return
        end

        FlatUnitFrame._renderSelectionFrame(selectionFrame, UnitIsUnit(unit, "target"))
    end

    function FlatUnitFrame._renderSelectionFrame(selectionFrame, isSelected)
        if not selectionFrame then
            return
        end

        if selectionFrame.selectionTexture then
            local selectionTexture = selectionFrame.selectionTexture
            if isSelected then
                selectionTexture:SetVertexColor(1, 1, 1, 0.2)
                selectionTexture:Show()
            else
                selectionTexture:Hide()
            end
        end
    end

    function FlatUnitFrame._enableRaidFrame(uf)
        local raidFrame = CreateFrame("Frame", nil, uf, nil)
        raidFrame:SetWidth(32)
        raidFrame:SetHeight(32)
        raidFrame:SetPoint("BOTTOM", uf, "TOP", 0, 0)
        uf.raidFrame = raidFrame

        local raidMarkTextureRegion = raidFrame:CreateTexture(nil, "ARTWORK")
        raidMarkTextureRegion:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        raidMarkTextureRegion:SetAllPoints()
        raidMarkTextureRegion:Hide()
        raidFrame.raidMarkTextureRegion = raidMarkTextureRegion

        raidFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        raidFrame:RegisterEvent("RAID_TARGET_UPDATE")
        raidFrame:SetScript("OnEvent", function()
            FlatUnitFrame._invalidateRaidFrame(raidFrame, uf.unit)
        end)
    end

    function FlatUnitFrame._invalidateRaidFrame(raidFrame, unit)
        if not raidFrame or not unit then
            return
        end

        if raidFrame.raidMarkTextureRegion then
            local raidMarkTextureRegion = raidFrame.raidMarkTextureRegion
            local index = GetRaidTargetIndex(unit)
            if index then
                SetRaidTargetIconTexture(raidMarkTextureRegion, index)
                raidMarkTextureRegion:Show()
            else
                raidMarkTextureRegion:Hide()
            end
        end
    end

    function FlatUnitFrame._invalidate(uf)
        local unit = uf.unit
        if not unit or not UnitExists(unit) then
            return
        end

        FlatUnitFrame._invalidateNameFrame(uf.nameFrame, unit)
        FlatUnitFrame._invalidateHealthBar(uf.healthBar, unit)
        FlatUnitFrame._invalidateRaidFrame(uf.raidFrame, unit)
        FlatUnitFrame._invalidateSelectionFrame(uf.selectionFrame, unit)
    end

    function FlatUnitFrame.getUnit(uf)
        return uf.unit
    end

    function FlatUnitFrame.setUnit(uf, unit)
        unit = unit and string.lower(unit)
        uf.unit = unit
        FlatUnitFrame._invalidate(uf)
    end

    function FlatUnitFrame.start(uf)
        uf:Show()
        FlatUnitFrame._invalidate(uf)
    end

    function FlatUnitFrame.stop(uf)
        uf:Hide()
    end

    function FlatUnitFrame.refresh(uf, data)
        FlatUnitFrame._renderNameFrame(uf.nameFrame, data.name, data.nameColor, data.level, data.levelColor)
        FlatUnitFrame._renderHealthBar(uf.healthBar, data.fraction, data.barColor, data.inCombat)
        FlatUnitFrame._renderSelectionFrame(uf.selectionFrame, data.isTarget)
    end

    return FlatUnitFrame
end)()

local debug = nil
if debug then
    local FlatUnitFrame = FlatUnitFrame
    local f = CreateFrame("Frame", nil, UIParent, nil)
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents()

        local uf = FlatUnitFrame.createUnitFrame(UIParent)
        uf:SetPoint("CENTER", UIParent, "CENTER", 0, -60)
        FlatUnitFrame.setUnit(uf, "player")
        FlatUnitFrame.start(uf)

        local uf2 = FlatUnitFrame.createUnitFrame(UIParent)
        uf2:SetPoint("CENTER", UIParent, "CENTER", 0, -90)
        FlatUnitFrame.setUnit(uf2, "target")
        FlatUnitFrame.start(uf2)

        local uf3 = FlatUnitFrame.createUnitFrame(UIParent)
        uf3:SetPoint("CENTER", UIParent, "CENTER", 0, -120)
        FlatUnitFrame.setUnit(uf3, "mouseover")
        FlatUnitFrame.start(uf3)
    end)
end
