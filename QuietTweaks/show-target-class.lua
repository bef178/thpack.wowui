local getResource = A.getResource;

(function()
    local function createRoundButton(parent, size)
        local button = CreateFrame("Button", nil, parent, nil);
        button:SetWidth(size);
        button:SetHeight(size);

        local highlightTexture = button:CreateTexture(nil, "HIGHLIGHT");
        highlightTexture:SetTexture([[Interface/Minimap/UI-Minimap-ZoomButton-Highlight]]);
        highlightTexture:SetPoint("TOPLEFT", size * -1/64, size * 1/64);
        highlightTexture:SetPoint("BOTTOMRIGHT", size * -1/64, size * 1/64);
        button:SetHighlightTexture(highlightTexture);

        local backgroundTexture = button:CreateTexture(nil, "BACKGROUND");
        backgroundTexture:SetTexture([[Interface/Minimap/UI-Minimap-Background]]);
        backgroundTexture:SetVertexColor(0, 0, 0, 0.6);
        backgroundTexture:SetPoint("TOPLEFT", size * 4/64, "TOPLEFT", size * -4/64);
        backgroundTexture:SetPoint("BOTTOMRIGHT", size * -4/64, "TOPLEFT", size * 4/64);

        local borderTexture = button:CreateTexture(nil, "OVERLAY");
        borderTexture:SetTexture([[Interface/Minimap/MiniMap-TrackingBorder]]);
        borderTexture:SetTexCoord(0, 38/64, 0, 38/64);
        borderTexture:SetAllPoints();

        local artworkTexture = button:CreateTexture(nil, "ARTWORK");
        artworkTexture:SetPoint("TOPLEFT", size * 12/64, size * -10/64);
        artworkTexture:SetPoint("BOTTOMRIGHT", size * -12/64, size * 14/64);
        button.artworkTexture = artworkTexture;

        return button;
    end

    local f = createRoundButton(TargetFrame, 40);
    f:SetPoint("TOPLEFT", 115, -3);
    RaiseFrameLevel(f);

    -- click to inspect
    f:SetScript("OnMouseDown", function()
        local button = arg1;
        if (button == "LeftButton") then
            local unit = "target";
            if (UnitIsPlayer(unit)) and not UnitCanAttack("player", unit) then
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

    f:refresh();
end)();
