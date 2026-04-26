local function openAllBags()
    for i = 0, 10 do
        -- keep bags sorted
        CloseBag(i)
        OpenBag(i)
    end
    -- `backpackWasOpen` works as a flag of sticky: with it, bags keep open when merchant closed
    ContainerFrame1.backpackWasOpen = 1
end

local function closeAllBags()
    for i = 0, 10 do
        CloseBag(i)
    end
end

local function toggleAllBags()
    if IsOptionFrameOpen() then
        return
    end
    if IsBagOpen(0) then
        closeAllBags()
    else
        openAllBags()
    end
end

-- click backpack to toggle all bags
local f = CreateFrame("Button", nil, MainMenuBarBackpackButton, SecureButtonTemplate)
f:SetAllPoints()
f:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
f:SetScript("OnEnter", function()
    MainMenuBarBackpackButton:GetScript("OnEnter")(MainMenuBarBackpackButton)
end)
f:SetScript("OnLeave", function()
    MainMenuBarBackpackButton:GetScript("OnLeave")(MainMenuBarBackpackButton)
end)
f:SetScript("OnClick", function()
    toggleAllBags()
end)

-- f is a sentinel as well
-- bank, mail and merchant
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("MAIL_SHOW")
-- f:RegisterEvent("MAIL_CLOSED")
f:RegisterEvent("MERCHANT_SHOW")
-- f:RegisterEvent("MERCHANT_CLOSED")
f:SetScript("OnEvent", function()
    openAllBags()
end)
