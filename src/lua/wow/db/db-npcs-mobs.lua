local mobs = {
    {
        name = "Forest Boar",
        levels = { 24, 25 },
        respawn = 120,
        locations = {
            ["Hillsbrad Foothills"] = {
                x = 0.727,
                y = 0.458,
            },
        },
    },
    {
        name = "Elder Forest Boar",
        levels = { 26, 27 },
        respawn = 120,
        locations = {
            ["Hillsbrad Foothills"] = {
                x = 0.679,
                y = 0.770,
            },
        },
    },
    {
        name = "Elder Forest Boar",
        levels = { 26, 27 },
        respawn = 300,
        locations = {
            ["Hillsbrad Foothills"] = {
                x = 0.688,
                y = 0.838,
            },
        },
    },
    {
        name = "Elder Forest Boar",
        levels = { 26, 27 },
        respawn = 300,
        locations = {
            ["Hillsbrad Foothills"] = {
                x = 0.714,
                y = 0.713,
            },
        },
    },
    {
        name = "Elder Forest Boar",
        levels = { 26, 27 },
        respawn = 300,
        locations = {
            ["Hillsbrad Foothills"] = {
                x = 0.728,
                y = 0.639,
            },
        },
    },
}

db = db or {}
local db = db
db.npcs = db.npcs or {}
for i, npc in ipairs(mobs) do
    db.npcs[npc.id or (1000000 + i)] = npc
end
