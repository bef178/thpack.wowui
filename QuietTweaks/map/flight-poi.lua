local db = A.db;

local memory = {};
if (not memory.knownFlightMasters) then
    memory.knownFlightMasters = {};
end
local knownFlightMasters = memory.knownFlightMasters;

local function getCurrentMap()
    local continentIndex = GetCurrentMapContinent();
    local zoneIndex = GetCurrentMapZone();
    if (not zoneIndex or zoneIndex == 0) then
        return db.maps[tostring(continentIndex)];
    else
        return db.maps[continentIndex .. "/" .. zoneIndex];
    end
end

local function getFlightMasters(map)
    if (not map) then
        return;
    end
    local flightMasters = {};
    for _, flightMasterId in ipairs(db.flightMasters) do
        local npc = db.npcs[flightMasterId];
        if (npc.locations[map.name]) then
            local faction, color;
            if (npc.title == "Flight Master") then
                faction = "neutral";
                color = { 0.9, 0.9, 0.3 };
            elseif (npc.title == "Gryphon Master" or npc.title == "Hippogryph Master") then
                faction = "alliance";
                color = { 0.3, 0.3, 0.9 };
            elseif (npc.title == "Wind Rider Master" or npc.title == "Bat Handler") then
                faction = "horde";
                color = { 0.9, 0.3, 0.3 };
            end
            Array.add(flightMasters, {
                id = npc.id,
                name = npc.name,
                title = npc.title,
                location = npc.locations[map.name],
                faction = faction,
                color = color,
                discovered = Array.contains(knownFlightMasters, npc.id),
            });
        end
    end
    return flightMasters;
end

local function createPoi()
    local f = CreateFrame("Frame", nil, WorldMapButton, nil);
    f:EnableMouse(true);
    f:SetWidth(12);
    f:SetHeight(12);
    f.texture = f:CreateTexture(nil, "OVERLAY", nil);
    f.texture:SetAllPoints();
    f:SetScript("OnEnter", function()
        local flightMaster = f.flightMaster;
        if (flightMaster) then
            GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
            GameTooltip:AddLine(flightMaster.name, unpack(flightMaster.color));
            GameTooltip:AddLine("<" .. flightMaster.title .. ">", 0.8, 0.8, 0.8);
            GameTooltip:Show();
        end
    end);
    f:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);
    return f;
end

local function updatePoi(poi, flightMaster)
    if (not poi) then
        return;
    end
    poi.flightMaster = flightMaster; -- for tooltip
    if (flightMaster) then
        if (flightMaster.faction == "neutral") then
            poi.texture:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Gray");
            if (flightMaster.discovered) then
                poi.texture:SetVertexColor(1, 1, 0);
            end
        elseif (flightMaster.faction == "alliance") then
            poi.texture:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Gray");
        elseif (flightMaster.faction == "horde") then
            poi.texture:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Gray");
        end
        local x = poi:GetParent():GetWidth() * flightMaster.location.x;
        local y = poi:GetParent():GetHeight() * (1 - flightMaster.location.y);
        poi:SetPoint("CENTER", poi:GetParent(), "BOTTOMLEFT", x, y);
        poi:Show();
    else
        poi.texture:SetTexture(nil);
        poi.texture:SetVertexColor(1, 1, 1);
        poi:ClearAllPoints();
        poi:Hide();
    end
end

local pois = {};

local f = CreateFrame("Frame");
f:RegisterEvent("TAXIMAP_OPENED");
f:RegisterEvent("WORLD_MAP_UPDATE");
f:SetScript("OnEvent", function()
    if (event == "TAXIMAP_OPENED") then
        -- scan for known flight points
        -- TODO
    elseif (event == "WORLD_MAP_UPDATE") then
        if (WorldMapFrame:IsVisible()) then
            local flightMasters = getFlightMasters(getCurrentMap() or {});
            for i, flightMaster in ipairs(flightMasters) do
                local poi = pois[i];
                if (not poi) then
                    poi = createPoi();
                    Array.add(pois, poi);
                end
                updatePoi(poi, flightMaster);
            end
            for i = Array.size(flightMasters) + 1, Array.size(pois), 1 do
                local poi = pois[i];
                updatePoi(poi, nil);
            end
        else
            for _, poi in ipairs(pois) do
                updatePoi(poi, nil);
            end
        end
    end
end);
