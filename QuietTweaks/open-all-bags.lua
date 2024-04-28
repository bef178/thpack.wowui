-- single click on backpack to toggle all bags

local openAllBags = function()
    for i = 0, 10 do
        -- keep bags order
        CloseBag(i);
        OpenBag(i);
    end
    -- `backpackWasOpen` works as a flag of sticky: on set, bags keep open when merchant closed
    ContainerFrame1.backpackWasOpen = 1;
end

local closeAllBags = function()
    for i = 0, 10 do
        CloseBag(i);
    end
end;

local toggleAllBags = function()
    if (IsOptionFrameOpen()) then
        return;
    end
    if (IsBagOpen(0)) then
        closeAllBags();
    else
        openAllBags();
    end
end;

(function()
    -- mask button
    local f = CreateFrame("Button", nil, MainMenuBarBackpackButton, SecureButtonTemplate);
    f:SetAllPoints();
    f:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD");
    f:SetScript("OnEnter", function()
        MainMenuBarBackpackButton:GetScript("OnEnter")(MainMenuBarBackpackButton);
    end);
    f:SetScript("OnLeave", function()
        MainMenuBarBackpackButton:GetScript("OnLeave")(MainMenuBarBackpackButton);
    end);
    f:SetScript("OnClick", function()
        toggleAllBags();
    end);
end)();

-- bank
(function()
    local f = CreateFrame("Frame");
    f:RegisterEvent("BANKFRAME_OPENED");
    f:SetScript("OnEvent", function()
        openAllBags();
    end);
end)();

-- mail
(function()
    local f = CreateFrame("Frame");
    f:RegisterEvent("MAIL_SHOW");
    -- f:RegisterEvent("MAIL_CLOSED");
    f:SetScript("OnEvent", function()
        openAllBags();
    end);
end)();

-- merchant
(function()
    local f = CreateFrame("Frame");
    f:RegisterEvent("MERCHANT_SHOW");
    -- f:RegisterEvent("MERCHANT_CLOSED");
    f:SetScript("OnEvent", function()
        openAllBags();
    end);
end)();
