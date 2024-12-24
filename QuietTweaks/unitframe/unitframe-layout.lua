(function()
    local function repositionPlayerFrame()
        PlayerFrame:ClearAllPoints();
        PlayerFrame:SetPoint("TOPRIGHT", UIParent, "CENTER", -40, -120);
    end

    local function repositionTargetFrame()
        TargetFrame:ClearAllPoints();
        TargetFrame:SetPoint("TOPLEFT", UIParent, "CENTER", 40, -120);
    end

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents();
        f:Hide();
        repositionPlayerFrame();
        repositionTargetFrame();
    end);
end)();
