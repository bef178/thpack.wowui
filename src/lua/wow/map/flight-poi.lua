local Array = Array
local Math = Math
local db = db

local function memorizeFlightMasters(flightStopsMemory)
    local oldContinentIndex = GetCurrentMapContinent()
    local oldZoneIndex = GetCurrentMapZone()

    SetMapToCurrentZone()

    local continentIndex = GetCurrentMapContinent()
    local stops = {}
    for i = 1, NumTaxiNodes(), 1 do
        local t = TaxiNodeGetType(i)
        local name = TaxiNodeName(i)
        local x, y = TaxiNodePosition(i)
        stops[name] = {
            continentIndex = continentIndex,
            name = name,
            x = Math.round(x, 0.001),
            y = Math.round(y, 0.001),
            reachable = t == "CURRENT" or t == "REACHABLE"
        }
    end

    SetMapZoom(oldContinentIndex, oldZoneIndex)

    flightStopsMemory[continentIndex] = stops
end

local function findNpcByLocation(db, locationName, x, y)
    local minX = x - 0.001
    local maxX = x + 0.001
    local minY = y - 0.001
    local maxY = y + 0.001
    for flightMasterId, npc in pairs(db.flightMasters) do
        if npc then
            local location = npc.locations[locationName]
            if location and location.x >= minX and location.x <= maxX and location.y >= minY and location.y <= maxY then
                return npc
            end
        end
    end
end

local function discoverFlightMasters(db, flightStopsMemory)
    if not flightStopsMemory then
        return
    end
    for _, nodes in pairs(flightStopsMemory) do
        for _, node in pairs(nodes or {}) do
            if node.reachable then
                local npc = findNpcByLocation(db, node.name, node.x, node.y)
                if npc then
                    npc.discovered = true
                end
            end
        end
    end
end

local function getCurrentMap()
    local continentIndex = GetCurrentMapContinent()
    local zoneIndex = GetCurrentMapZone()
    if not zoneIndex or zoneIndex == 0 then
        return db.maps[tostring(continentIndex)]
    else
        return db.maps[continentIndex .. "/" .. zoneIndex]
    end
end

-- return array
local function getCurrentMapFlightMasters()
    local map = getCurrentMap()
    if not map then
        return
    end

    local flightMasters = {}
    for flightMasterId, npc in pairs(db.flightMasters) do
        if npc and npc.locations[map.name] then
            local color
            if npc.title == "Flight Master" then
                color = {
                    0.9,
                    0.9,
                    0.3
                }
            elseif (npc.title == "Gryphon Master" or npc.title == "Hippogryph Master") then
                color = {
                    0.3,
                    0.3,
                    0.9
                }
            elseif (npc.title == "Wind Rider Master" or npc.title == "Bat Handler") then
                color = {
                    0.9,
                    0.3,
                    0.3
                }
            end
            Array.add(flightMasters, {
                id = npc.id,
                name = npc.name,
                title = npc.title,
                location = npc.locations[map.name],
                color = color,
                discovered = npc.discovered
            })
        end
    end
    return flightMasters
end

local function createPoi()
    local f = CreateFrame("Frame", nil, WorldMapButton, nil)
    f:EnableMouse(true)
    f:SetWidth(12)
    f:SetHeight(12)
    f.texture = f:CreateTexture(nil, "OVERLAY", nil)
    f.texture:SetAllPoints()
    f:SetScript("OnEnter", function()
        local flightMaster = f.flightMaster
        if flightMaster then
            GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
            GameTooltip:AddLine(flightMaster.name, unpack(flightMaster.color))
            GameTooltip:AddLine("<" .. flightMaster.title .. ">", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end
    end)
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return f
end

local function updatePoi(poi, flightMaster)
    if not poi then
        return
    end
    poi.flightMaster = flightMaster -- for tooltip
    if flightMaster then
        if flightMaster.discovered then
            poi.texture:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Green")
        else
            poi.texture:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Gray")
        end
        local x = poi:GetParent():GetWidth() * flightMaster.location.x
        local y = poi:GetParent():GetHeight() * (1 - flightMaster.location.y)
        poi:SetPoint("CENTER", poi:GetParent(), "BOTTOMLEFT", x, y)
        poi:Show()
    else
        poi.texture:SetTexture(nil)
        poi.texture:SetVertexColor(1, 1, 1)
        poi:ClearAllPoints()
        poi:Hide()
    end
end

local pois = {}

local f = CreateFrame("Frame")
f:RegisterEvent("TAXIMAP_OPENED")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("WORLD_MAP_UPDATE")
f:SetScript("OnEvent", function()
    if event == "TAXIMAP_OPENED" then
        -- refresh flight stops in this continent
        if not MEMORY.flightStops then
            MEMORY.flightStops = {}
        end
        memorizeFlightMasters(MEMORY.flightStops)
        discoverFlightMasters(db, MEMORY.flightStops)
    elseif event == "VARIABLES_LOADED" then
        if not MEMORY then
            MEMORY = {}
        end
        discoverFlightMasters(db, MEMORY.flightStops)
    elseif event == "WORLD_MAP_UPDATE" then
        if WorldMapFrame:IsVisible() then
            local flightMasters = getCurrentMapFlightMasters() or {}
            for i, flightMaster in ipairs(flightMasters) do
                local poi = pois[i]
                if not poi then
                    poi = createPoi()
                    Array.add(pois, poi)
                end
                updatePoi(poi, flightMaster)
            end
            for i = Array.size(flightMasters) + 1, Array.size(pois), 1 do
                local poi = pois[i]
                updatePoi(poi, nil)
            end
        else
            for _, poi in ipairs(pois) do
                updatePoi(poi, nil)
            end
        end
    end
end)
