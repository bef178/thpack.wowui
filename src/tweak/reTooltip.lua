P.ask("pp").answer("reTooltip", function(pp)

    local px = pp.px;

    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.edgeFile = A.Res.tile32;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.edgeSize = px;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.tile = false;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.tileSize = 0;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.insets = {
        left = -px,
        right = -px,
        top = -px,
        bottom = -px,
    };

    GameTooltip:SetBackdropColor(
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)

    -- tooltip status bar

    GameTooltipStatusBar:ClearAllPoints();
    GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, -px);
    GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", 0, -px);

    GameTooltipStatusBar:SetBackdrop({
        bgFile = nil,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            left = 0,
        },
        tile = false,
        tileSize = 0,
        edgeFile = A.Res.tile32,
        edgeSize = px,
    });
    GameTooltipStatusBar:SetStatusBarTexture(A.Res.tile32);

    local hpPercentage = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpPercentage:SetWidth(60);
    hpPercentage:SetJustifyH("RIGHT");
    hpPercentage:SetPoint("LEFT", -8, 0);

    local hpValue = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpValue:SetJustifyH("RIGHT");
    hpValue:SetPoint("RIGHT", -2 * px, 0);

    function updateStatusBarText(self)
        local currentValue = self:GetValue();
        local _, maxValue = self:GetMinMaxValues();
        hpPercentage:SetFormattedText("%.1f%%", currentValue / maxValue * 100);
        if currentValue <= 1 and maxValue == 1 then
            hpValue:SetText("");
        else
            hpValue:SetFormattedText("%d", currentValue);
        end
    end

    GameTooltipStatusBar:HookScript("OnShow", updateStatusBarText);
    GameTooltipStatusBar:HookScript("OnValueChanged", updateStatusBarText);
end);
