local getResource = A.getResource;

(function()
    local function createRoundIcon(parent, size)
        local f = CreateFrame("Button", nil, parent, nil);
        f:SetWidth(size);
        f:SetHeight(size);

        local highlightTexture = f:CreateTexture(nil, "HIGHLIGHT");
        highlightTexture:SetTexture([[Interface/Minimap/UI-Minimap-ZoomButton-Highlight]]);
        highlightTexture:SetPoint("TOPLEFT", size * -1 / 64, size * 1 / 64);
        highlightTexture:SetPoint("BOTTOMRIGHT", size * -1 / 64, size * 1 / 64);
        f:SetHighlightTexture(highlightTexture);

        local backgroundTexture = f:CreateTexture(nil, "BACKGROUND");
        backgroundTexture:SetTexture([[Interface/Minimap/UI-Minimap-Background]]);
        backgroundTexture:SetVertexColor(0, 0, 0, 0.6);
        backgroundTexture:SetPoint("TOPLEFT", size * 4 / 64, "TOPLEFT", size * -4 / 64);
        backgroundTexture:SetPoint("BOTTOMRIGHT", size * -4 / 64, "TOPLEFT", size * 4 / 64);

        local borderTexture = f:CreateTexture(nil, "OVERLAY");
        borderTexture:SetTexture([[Interface/Minimap/MiniMap-TrackingBorder]]);
        borderTexture:SetTexCoord(0, 38 / 64, 0, 38 / 64);
        borderTexture:SetAllPoints();

        local artworkTexture = f:CreateTexture(nil, "ARTWORK");
        artworkTexture:SetPoint("TOPLEFT", size * 12 / 64, size * -10 / 64);
        artworkTexture:SetPoint("BOTTOMRIGHT", size * -12 / 64, size * 14 / 64);
        f.artworkTexture = artworkTexture;

        return f;
    end

    local f = createRoundIcon(TargetFrame, 40);
    f:SetPoint("TOPLEFT", 115, -3);
    RaiseFrameLevel(f);

    -- click to inspect
    f:SetScript("OnMouseDown", function()
        local button = arg1;
        if (button == "LeftButton") then
            local unit = "target";
            if (UnitIsPlayer(unit) and not UnitCanAttack("player", unit)) then
                if (InspectFrame and InspectFrame:IsShown()) then
                    InspectFrameCloseButton:Click();
                else
                    InspectUnit(unit);
                end
            end
        end
    end);

    function f:refresh()
        local self = f;
        local unit = "target";
        if (UnitIsPlayer(unit)) then
            local _, unitClass = UnitClass(unit);
            -- not case-sensitive
            self.artworkTexture:SetTexture(getResource("class\\ClassIcon_" .. unitClass));
            self:Show();
        else
            self:Hide();
        end
    end

    f:RegisterEvent("PLAYER_TARGET_CHANGED");
    f:SetScript("OnEvent", f.refresh);

    -- in case of ReloadUI()
    f:refresh();
end)();
