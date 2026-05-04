local Color = Color

local function minimapCreateTimeFrame()
    local f = CreateFrame("Button", nil, Minimap, nil)
    f:SetFrameLevel(3)
    f:SetPoint("BOTTOM", MinimapCluster, "BOTTOM", 8, 16)
    f:SetWidth(48)
    f:SetHeight(23)
    f:SetBackdrop({
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        tile = true,
        tileSize = 8,
        edgeSize = 16,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3
        }
    })
    f:SetBackdropColor(Color.toVertex("#666666"))
    f:SetBackdropBorderColor(Color.toVertex("#e6cc80"))

    local timeTextRegion = f:CreateFontString()
    timeTextRegion:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    timeTextRegion:SetJustifyH("CENTER")
    timeTextRegion:SetPoint("CENTER", 0, 0)
    f.timeTextRegion = timeTextRegion

    return f
end

local function tooltipAddAddonMemoryDetails(tooltip)
    if not UpdateAddOnMemoryUsage or not GetAddOnMemoryUsage then
        -- not work on 1.12
        return
    end

    local totalMemory = 0
    local addons = {}
    UpdateAddOnMemoryUsage()
    for i = 1, GetNumAddOns() do
        local addonName, _, _, enabled = GetAddOnInfo(i)
        if enabled then
            local addonMemory = GetAddOnMemoryUsage(i)
            table.insert(addons, {
                addonName = addonName,
                addonMemory = addonMemory
            })
            totalMemory = totalMemory + addonMemory
        end
    end

    tooltip:AddDoubleLine("Total Memory", string.format("|cff00ff00%.1f KB|r", totalMemory))
    tooltip:AddLine("------------------------")
    for _, v in ipairs(addons) do
        tooltip:AddDoubleLine(v.addonName, string.format("|cff00ff00%.1f KB|r", v.addonMemory))
    end
end

local function tooltipAddTime(tooltip)
    local timeString = date("%Y-%m-%d %H:%M:%S")
    local hours, minutes = GetGameTime()
    local serverTimeString = string.format("%.2d:%.2d", hours, minutes)

    tooltip:AddLine(timeString, 1, 1, 1, 1, 1, 1)
    tooltip:AddDoubleLine("Server time", serverTimeString, 1, 1, 1, 1, 1, 1)
end

local f = minimapCreateTimeFrame()

f:SetScript("OnUpdate", function()
    f.timeTextRegion:SetText(date("%H:%M"))
end)

f:SetScript("OnEnter", function()
    local tooltip = GameTooltip
    tooltip:SetOwner(f, ANCHOR_BOTTOMLEFT)
    tooltip:ClearLines()
    tooltipAddTime(tooltip)
    tooltipAddAddonMemoryDetails(tooltip)
    tooltip:AddLine(" ")
    tooltip:AddLine("(shift click to gc)", 0.5, 0.5, 0.5)
    tooltip:Show()
end)
f:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
f:SetScript("OnClick", function()
    local tooltip = GameTooltip
    if IsShiftKeyDown() then
        collectgarbage()
        f:GetScript("OnEnter")()
    end
end)
