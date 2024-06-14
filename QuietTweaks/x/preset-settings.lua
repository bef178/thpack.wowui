(function()
    SetCVar("profanityFilter", "0");
    SetCVar("cameraDistanceMax", 50);

    local function repositionPlayerFrame()
        PlayerFrame:ClearAllPoints();
        PlayerFrame:SetPoint("TOPRIGHT", UIParent, "CENTER", -40, -120);
    end

    local function repositionTargetFrame()
        TargetFrame:ClearAllPoints();
        TargetFrame:SetPoint("TOPLEFT", UIParent, "CENTER", 40, -120);
    end

    (function()
        local f = CreateFrame("Frame");
        f:RegisterEvent("PLAYER_ENTERING_WORLD");
        f:SetScript("OnEvent", function()
            f:UnregisterAllEvents();
            f:Hide();
            repositionPlayerFrame();
            repositionTargetFrame();
        end);
    end)();
end)();
