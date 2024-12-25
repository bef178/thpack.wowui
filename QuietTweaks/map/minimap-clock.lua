local Color = Color;

(function()
    local f = CreateFrame("Frame", nil, Minimap, nil);
    f:SetFrameLevel(64);
    f:SetPoint("BOTTOM", MinimapCluster, "BOTTOM", 8, 16);
    f:SetWidth(48);
    f:SetHeight(23);
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 16,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3
        }
    });
    f:SetBackdropColor(Color.toVertex("#666666"));
    f:SetBackdropBorderColor(Color.toVertex("#e6cc80"));
    f:EnableMouse(true);

    local fontString = f:CreateFontString();
    fontString:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    fontString:SetJustifyH("CENTER");
    fontString:SetPoint("CENTER", 0, 0);
    f.fontString = fontString;

    f:SetScript("OnUpdate", function()
        f.fontString:SetText(date("%H:%M"));
    end);

    f:SetScript("OnEnter", function()
        local timeString = date("%Y-%m-%d %H:%M:%S");
        local hours, minutes = GetGameTime();
        local serverTimeString = string.format("%.2d:%.2d", hours, minutes);

        GameTooltip:SetOwner(f, ANCHOR_BOTTOMLEFT);
        GameTooltip:ClearLines();
        GameTooltip:AddDoubleLine("Date", timeString, 1, 1, 1, 1, 1, 1);
        GameTooltip:AddDoubleLine("Server time", serverTimeString, 1, 1, 1, 1, 1, 1);
        GameTooltip:Show();
    end);
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end);
end)();
