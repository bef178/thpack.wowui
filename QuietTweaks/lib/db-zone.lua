-- GetMapContinents() =>
--  1: Kalimdor
--  2: Eastern Kingdoms
-- GetMapZones(2) =>
--  1: Alterac Mountains
--  2: Arathi Highlands
--  25: Wetlands
-- GetCurrentMapContinent => continentIndex
-- GetCurrentMapZone => zoneIndex
local continents, zones = (function()
    local continents = {};
    local zones = {};
    for continentIndex, continentName in ipairs({ GetMapContinents() }) do
        Array.add(continents, {
            continentIndex = continentIndex,
            continentName = continentName,
        });
        for zoneIndex, zoneName in ipairs({ GetMapZones(continentIndex) }) do
            Array.add(zones, {
                continentIndex = continentIndex,
                zoneIndex = zoneIndex,
                zoneName = zoneName,
            });
        end
    end
    return continents, zones;
end)();

local A = A;
A.db = A.db or {};
A.db.continents = A.db.continents or {};
A.db.zones = A.db.zones or {};

for _, continent in ipairs(continents) do
    A.db.continents[continent.continentIndex] = continent;
end
for _, zone in ipairs(zones) do
    A.db.zones[zone.zoneIndex] = zone;
end
continents = nil;
zones = nil;
