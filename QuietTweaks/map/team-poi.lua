local A = A;

(function()
    local function alignPoi(poi)
        if (not poi) then
            return;
        end

        _G[poi:GetName() .. "Icon"]:SetTexture();

        local texture = poi:CreateTexture(nil, "OVERLAY");
        texture:SetTexture(A.getResource("circle"));
        texture:SetPoint("TOPLEFT", poi, "TOPLEFT", 15, -15);
        texture:SetPoint("BOTTOMRIGHT", poi, "BOTTOMRIGHT", -15, 15);
        poi.teamTexture = texture;

        local text = poi:CreateFontString(nil, "OVERLAY");
        text:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE");
        text:SetJustifyH("CENTER");
        text:SetJustifyV("MIDDLE");
        text:SetPoint("CENTER", texture, "CENTER", -1, 1);
        poi.teamText = text;
    end

    local function updatePoi(poi, unit)
        if (poi and UnitExists(unit)) then
            local _, className = UnitClass(unit);
            local classColor = A.getClassColor(className) or "#808080";
            poi.teamTexture:SetVertexColor(Color.toVertex(classColor));

            local raidIndex, found = string.gsub(unit, "raid([0-9]+)", "%1");
            if (found == 1) then
                local _, _, raidPartyIndex = GetRaidRosterInfo(tonumber(raidIndex));
                poi.teamText:SetText(raidPartyIndex);
            else
                poi.teamText:SetText();
            end
        end
    end

    local poiNameToUnits = {};
    do
        for i = 1, MAX_PARTY_MEMBERS do
            poiNameToUnits["WorldMapParty" .. i] = "party" .. i;
        end
        for i = 1, MAX_RAID_MEMBERS do
            poiNameToUnits["WorldMapRaid" .. i] = "raid" .. i;
        end
        for i = 1, MAX_PARTY_MEMBERS do
            poiNameToUnits["BattlefieldMinimapParty" .. i] = "party" .. i;
        end
        for i = 1, MAX_RAID_MEMBERS do
            poiNameToUnits["BattlefieldMinimapRaid" .. i] = "raid" .. i;
        end

        for name, _ in pairs(poiNameToUnits) do
            alignPoi(_G[name]);
        end
    end

    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("PARTY_LEADER_CHANGED");
    f:RegisterEvent("PARTY_MEMBERS_CHANGED");
    f:RegisterEvent("RAID_ROSTER_UPDATE");
    f:RegisterEvent("RAID_TARGET_UPDATE");
    f:SetScript("OnEvent", function()
        for name, unit in pairs(poiNameToUnits) do
            updatePoi(_G[name], unit);
        end
    end);
end)();
