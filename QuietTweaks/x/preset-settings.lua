(function()
    SetCVar("cameraDistanceMax", 50);

    local function repositionPlayerFrame()
        PlayerFrame:ClearAllPoints();
        PlayerFrame:SetPoint("TOPRIGHT", UIParent, "CENTER", -40, -120);
    end

    local function repositionTargetFrame()
        TargetFrame:ClearAllPoints();
        TargetFrame:SetPoint("TOPLEFT", UIParent, "CENTER", 40, -120);
    end

    local function showMultiActionBars()
        SHOW_MULTI_ACTIONBAR_1 = 1;
        SHOW_MULTI_ACTIONBAR_2 = 1;
        SHOW_MULTI_ACTIONBAR_3 = nil;
        SHOW_MULTI_ACTIONBAR_4 = nil;
        MultiActionBar_Update();
        UIParent_ManageFramePositions();

        ALWAYS_SHOW_MULTIBARS = 1;
        MultiActionBar_UpdateGridVisibility();
    end

    (function()
        local f = CreateFrame("Frame");
        f:RegisterEvent("PLAYER_ENTERING_WORLD");
        f:SetScript("OnEvent", function()
            f:UnregisterAllEvents();
            f:Hide();
            repositionPlayerFrame();
            repositionTargetFrame();
            showMultiActionBars();
        end);
    end)();
end)();
