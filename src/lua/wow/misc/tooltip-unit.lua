local Color = Color
local hookScript = Util.hookScript
local buildColoredString = Util.buildColoredString
local getClassColor = Util.getClassColor
local getUnitNameColor = UnitUtil.getUnitNameColor

-- 1.12 缺乏 OnTooltipCleared，新增组件无合适的清除时机
local function tooltipAddUnitFactionIcon(tooltip, unit)
    if not tooltip.factionTextureRegion then
        local size = 32
        local factionTextureRegion = tooltip:CreateTexture(nil, "OVERLAY")
        factionTextureRegion:SetWidth(size)
        factionTextureRegion:SetHeight(size)
        -- factionTextureRegion:SetPoint("TOPLEFT", _G[tooltip:GetName() .. "TextLeft1"], "TOPRIGHT", 0, (size - 14) / 2)
        factionTextureRegion:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", 0, -5)
        factionTextureRegion:SetTexCoord(0, 5 / 8, 0, 5 / 8)
        tooltip.factionTextureRegion = factionTextureRegion
    end
    if UnitPlayerControlled(unit) then
        local _, unitFactionType = UnitFactionGroup(unit)
        -- tooltip.factionTextureRegion:SetTexture([[Interface\GroupFrame\UI-Group-PVP-]] .. unitFactionType) -- 32x32
        tooltip.factionTextureRegion:SetTexture([[Interface\TargetingFrame\UI-PVP-]] .. unitFactionType) -- 64x64
    else
        tooltip.factionTextureRegion:SetTexture()
    end
end

local function tooltipAddUnitTarget(tooltip, unit)
    local unitTarget = unit .. "target"
    if UnitExists(unitTarget) then
        local prefix = "=> "
        if UnitIsUnit(unitTarget, "player") then
            tooltip:AddLine(" ")
            tooltip:AddLine(prefix .. buildColoredString(Color.pick("Red"), "!!!"), 1, 1, 1)
        else
            tooltip:AddLine(" ")
            local unitTargetColoredName = buildColoredString(getUnitNameColor(unitTarget), UnitName(unitTarget))
            tooltip:AddLine(string.format("%s%s", prefix, unitTargetColoredName), 1, 1, 1)
        end
        tooltip:Show()
    end
end

local function tooltipPrepareUnitHealthBar(tooltip)
    local healthBar = _G[tooltip:GetName() .. "StatusBar"]
    if not healthBar then
        return
    end

    healthBar:SetHeight(10)
    healthBar:ClearAllPoints()
    healthBar:SetPoint("TOPLEFT", tooltip, "BOTTOMLEFT", 4, -4)
    healthBar:SetPoint("TOPRIGHT", tooltip, "BOTTOMRIGHT", -4, -4)

    local backgroundTextureRegion = healthBar:CreateTexture(nil, "BACKGROUND")
    backgroundTextureRegion:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
    backgroundTextureRegion:SetVertexColor(Color.toVertex("#1A1A00CC"))
    backgroundTextureRegion:SetAllPoints()
    healthBar.backgroundTextureRegion = backgroundTextureRegion

    local borderFrame = CreateFrame("Frame", nil, healthBar, nil)
    borderFrame:SetBackdrop({
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        edgeSize = 12,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3
        }
    })
    borderFrame:SetPoint("TOPLEFT", -3, 3)
    borderFrame:SetPoint("BOTTOMRIGHT", 3, -3)
    healthBar.borderFrame = borderFrame

    -- text over the border
    local healthTextRegion = healthBar.borderFrame:CreateFontString(nil, "OVERLAY")
    healthTextRegion:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    -- healthFontString:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    healthTextRegion:SetPoint("TOP", 0, 3)
    healthBar.healthTextRegion = healthTextRegion

    hookScript(healthBar, "OnUpdate", "post_hook", function()
        local hp = healthBar:GetValue()
        local _, maxHp = healthBar:GetMinMaxValues()
        healthBar.healthTextRegion:SetText(string.format("%s/%s", hp, maxHp))
    end)

    return healthBar
end

local function tooltipSetUnitHealthBarClassColor(tooltip, unit)
    if UnitIsPlayer(unit) then
        local _, className = UnitClass(unit)
        local classColorString = getClassColor(className) or "#808080"
        tooltip.healthBar:SetStatusBarColor(Color.toVertex(classColorString))
    end
end

local function getTooltipUnit(tooltip)
    local titleString = _G[tooltip:GetName() .. "TextLeft1"]:GetText()
    if (not titleString) then
        return
    end
    if (UnitExists("mouseover")) then
        return "mouseover"
    end
    for _, u in ipairs({"player", "pet", "target"}) do
        if (UnitExists(u) and (UnitName(u) == titleString or UnitPVPName(u) == titleString)) then
            return u
        end
    end
    if (GetNumPartyMembers() > 0) then
        for _, u in ipairs({"party", "partypet"}) do
            for i = 1, 4, 1 do
                local unit = u .. i
                if (UnitExists(unit) and (UnitName(unit) == titleString or UnitPVPName(unit) == titleString)) then
                    return unit
                end
            end
        end
    end
    if (GetNumRaidMembers() > 0) then
        for _, u in ipairs({"raid", "raidpet"}) do
            for i = 1, 40, 1 do
                local unit = u .. i
                if UnitExists(unit) and (UnitName(unit) == titleString or UnitPVPName(unit) == titleString) then
                    return unit
                end
            end
        end
    end
end

GameTooltip.healthBar = tooltipPrepareUnitHealthBar(GameTooltip)

local f = CreateFrame("Frame", nil, GameTooltipStatusBar, nil)
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:SetScript("OnEvent", function()
    local tooltip = GameTooltip
    local unit = getTooltipUnit(tooltip)

    tooltipAddUnitTarget(tooltip, unit)
    tooltipSetUnitHealthBarClassColor(tooltip, unit)
end)
