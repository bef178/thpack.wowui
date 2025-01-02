local flightMasters = {
    {
        id = 523,
        name = "Thor",
        title = "Gryphon Master",
        locations = {
            ["Eastern Kingdoms"] = {
                x = 0.425095,
                y = 0.771117,
            },
            ["Westfall"] = {
                x = 0.566,
                y = 0.526,
            },
            ["Sentinel Hill, Westfall"] = {
                x = 0.407,
                y = 0.245,
            },
        },
    },
};

local A = A;

A.db = A.db or {};
A.db.npcs = A.db.npcs or {};

-- use map for easy override
A.db.flightMasterIds = {};

for _, npc in ipairs(flightMasters) do
    A.db.npcs[npc.id] = npc;
    A.db.flightMasterIds[npc.id] = 1;
end
flightMasters = nil;
