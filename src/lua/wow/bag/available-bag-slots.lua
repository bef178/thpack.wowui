local function getNumAvailableSlots(bagId)
    local n = 0
    for i = 1, GetContainerNumSlots(bagId) do
        local texture = GetContainerItemInfo(bagId, i)
        if not texture then
            n = n + 1
        end
    end
    return n
end

local textRegion = MainMenuBarBackpackButton:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
textRegion:SetTextColor(1, 1, 1)
textRegion:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -5, 2)
textRegion:SetDrawLayer("OVERLAY", 2)

local f = CreateFrame("Frame")
f:RegisterEvent("BAG_UPDATE")
f:SetScript("OnEvent", function()
    local n = 0
    for i = 0, NUM_CONTAINER_FRAMES do
        n = n + getNumAvailableSlots(i)
    end
    textRegion:SetText(string.format("(%d)", n))
end)
