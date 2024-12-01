local A = A;
local WorldMapFrame = WorldMapFrame;

(function(enabled)
    if (not enabled) then
        return;
    end

    Array.add(UISpecialFrames, "WorldMapFrame");

    ToggleWorldMap = function()
        if WorldMapFrame:IsShown() then
            WorldMapFrame:Hide()
        else
            WorldMapFrame:Show()
        end
    end;

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents();

        UIPanelWindows["WorldMapFrame"] = {
            area = "center"
        };

        WorldMapFrame:SetWidth(WorldMapButton:GetWidth() + 20);
        WorldMapFrame:SetHeight(WorldMapButton:GetHeight() + 100);
        WorldMapFrame:ClearAllPoints();
        WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 8);
    end);

    BlackoutWorld:SetTexture();
    BlackoutWorld:Hide();

    A.hookScript(WorldMapFrame, "OnShow", "post_hook", function()
        WorldMapFrame:EnableKeyboard(false);
        WorldMapFrame:SetScale(0.7);

        -- WorldMapPositioningGuide:ClearAllPoints();
        -- WorldMapPositioningGuide:SetAllPoints(WorldMapFrame);

        -- WorldMapDetailFrame:ClearAllPoints();
        -- WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOPLEFT", 10, -69);
        -- WorldMapDetailFrame:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -10, -69);
        -- WorldMapDetailFrame:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 10, 31);
        -- WorldMapDetailFrame:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -10, 31);

        -- WorldMapButton:ClearAllPoints();
        -- WorldMapButton:SetAllPoints(WorldMapDetailFrame);
    end);
end)(true);
