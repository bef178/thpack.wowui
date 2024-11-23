-- GetMapContinents() =>
--  1: Kalimdor
--  2: Eastern Kingdoms
-- GetMapZones(2) =>
--  1: Alterac Mountains
--  2: Arathi Highlands
--  ...
--  25: Wetlands
local maps = (function()
    local maps = {};
    for continentIndex, continentName in ipairs({ GetMapContinents() }) do
        Array.add(maps, {
            id = tostring(continentIndex),
            name = continentName,
            continentIndex = continentIndex,
        });
        for zoneIndex, zoneName in ipairs({ GetMapZones(continentIndex) }) do
            Array.add(maps, {
                id = continentIndex .. "/" .. zoneIndex,
                name = zoneName,
                continentIndex = continentIndex,
                zoneIndex = zoneIndex,
            });
        end
    end
    return maps;
end)();

local A = A;
A.db = A.db or {};
A.db.maps = A.db.maps or {};

for _, map in ipairs(maps) do
    A.db.maps[map.id] = map;
end
maps = nil;
