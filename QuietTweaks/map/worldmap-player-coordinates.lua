-- player & cursor coordinates
(function()
    local GetPlayerMapPosition = GetPlayerMapPosition;
    local WorldMapButton = WorldMapButton;

    local f = CreateFrame("Frame", nil, WorldMapButton, nil);

    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents();

        f.playerCoordinatesText = f:CreateFontString(nil, "OVERLAY");
        f.playerCoordinatesText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
        f.playerCoordinatesText:SetTextColor(0.8, 0.8, 0.8);
        f.playerCoordinatesText:SetJustifyH("LEFT");
        f.playerCoordinatesText:SetWidth(150);
        f.playerCoordinatesText:SetHeight(14);
        f.playerCoordinatesText:SetPoint("BOTTOMLEFT", WorldMapButton, "BOTTOMLEFT", 3, 0);

        f.cursorCoordinatesText = f:CreateFontString(nil, "OVERLAY");
        f.cursorCoordinatesText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
        f.cursorCoordinatesText:SetTextColor(0.8, 0.8, 0.8);
        f.cursorCoordinatesText:SetJustifyH("LEFT");
        f.cursorCoordinatesText:SetWidth(150);
        f.cursorCoordinatesText:SetHeight(14);
        f.cursorCoordinatesText:SetPoint("BOTTOMLEFT", WorldMapButton, "BOTTOMLEFT", 154, 0);
    end);

    f:SetScript("OnUpdate", function()
        -- it is said the very top left is (0, 0) while the very bottom right is (1, 1)

        local playerX, playerY = GetPlayerMapPosition("player");
        if (playerX > 0 and playerY > 0) then
            f.playerCoordinatesText:SetText(string.format("Player: (%.3f, %.3f)", playerX, playerY));
        else
            f.playerCoordinatesText:SetText();
        end

        local l = WorldMapButton:GetLeft();
        local r = WorldMapButton:GetRight();
        local t = WorldMapButton:GetTop();
        local b = WorldMapButton:GetBottom();
        local scale = WorldMapButton:GetEffectiveScale();

        local x, y = GetCursorPosition();
        x = x / scale;
        y = y / scale;

        if (x >= l and x <= r and y >= b and y <= t) then
            local cursorX = (x - l) / (r - l);
            local cursorY = (t - y) / (t - b);
            f.cursorCoordinatesText:SetText(string.format("Cursor: (%.3f, %.3f)", cursorX, cursorY));
        else
            f.cursorCoordinatesText:SetText();
        end
    end);
end)();
