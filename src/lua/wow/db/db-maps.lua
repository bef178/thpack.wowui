-- GetMapContinents() =>
--  1: Kalimdor
--  2: Eastern Kingdoms
-- GetMapZones(2) =>
--  1: Alterac Mountains
--  2: Arathi Highlands
--  ...
--  25: Wetlands
local function getMaps()
    local maps = {}
    for continentIndex, continentName in ipairs({
        GetMapContinents()
    }) do
        local m = {
            id = tostring(continentIndex),
            name = continentName,
            continentIndex = continentIndex
        }
        maps[m.id] = m
        for zoneIndex, zoneName in ipairs({
            GetMapZones(continentIndex)
        }) do
            local m2 = {
                id = continentIndex .. "/" .. zoneIndex,
                name = zoneName,
                continentIndex = continentIndex,
                zoneIndex = zoneIndex
            }
            maps[m2.id] = m2
        end
    end
    return maps
end

db = db or {}
db.maps = getMaps()
