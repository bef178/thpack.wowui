local function repositionPlayerFrame()
    PlayerFrame:ClearAllPoints()
    -- PlayerFrame:SetPoint("CENTER", -265, -150)
    PlayerFrame:SetPoint("TOPRIGHT", UIParent, "CENTER", -40, -120)
end

local function repositionTargetFrame()
    TargetFrame:ClearAllPoints()
    -- TargetFrame:SetPoint("CENTER", 265, -150)
    TargetFrame:SetPoint("TOPLEFT", UIParent, "CENTER", 40, -120)
end

-- FocusFrame:ClearAllPoints()
-- FocusFrame:SetPoint("LEFT", 260, -215)
-- PartyMemberFrame1:ClearAllPoints()
-- PartyMemberFrame1:SetPoint("LEFT", 175, 125)

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
    f:UnregisterAllEvents()
    f:Hide()
    repositionPlayerFrame()
    repositionTargetFrame()
end)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
