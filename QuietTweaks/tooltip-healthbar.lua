local Color = Color;
local getClassColor = A.getClassColor;

(function()
    local f = GameTooltipStatusBar;
    f:SetHeight(10);
    f:ClearAllPoints();
    f:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 4, -4);
    f:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -4, -4);

    local backgroundTexture = f:CreateTexture(nil, "BACKGROUND");
    backgroundTexture:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
    backgroundTexture:SetVertexColor(Color.toVertex("#1a1a00cc"));
    backgroundTexture:SetAllPoints();

    -- for border
    local backdropFrame = CreateFrame("Frame", nil, f, nil);
    backdropFrame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3
        }
    });
    backdropFrame:SetPoint("TOPLEFT", f, "TOPLEFT", -3, 3);
    backdropFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 3, -3);

    -- text over the border
    local healthFontString = backdropFrame:CreateFontString();
    healthFontString:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    -- healthFontString:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE");
    healthFontString:SetPoint("TOP", 0, 3);

    f:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
    f:SetScript("OnEvent", function()
        if (UnitIsPlayer("mouseover")) then
            local _, className = UnitClass("mouseover");
            local classColor = getClassColor(className) or "#808080";
            f:SetStatusBarColor(Color.toVertex(classColor));
        end
    end);

    f:SetScript("OnUpdate", function()
        local hp = f:GetValue();
        local _, maxHp = f:GetMinMaxValues();
        healthFontString:SetText(string.format("%s/%s", hp, maxHp));
    end);
end)();
