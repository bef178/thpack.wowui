local repositionPlayerFrameAndTargetFrame = function()
    PlayerFrame:ClearAllPoints();
    PlayerFrame:SetPoint("TOPRIGHT", UIParent, "CENTER", -40, -120);
    TargetFrame:ClearAllPoints();
    TargetFrame:SetPoint("TOPLEFT", UIParent, "CENTER", 40, -120);
end;

(function()
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents();
        repositionPlayerFrameAndTargetFrame();
        f:Hide();
    end);
end)();
