local flightMasters = {
    {
        id = 352,
        name = "Dungar Longdrink",
        title = "Gryphon Master",
        locations = {
            ["Stormwind City"] = {
                x = 0.710,
                y = 0.725,
            },
            ["Stormwind, Elwynn"] = {
                x = 0.433,
                y = 0.328,
            },
        },
    },
    {
        id = 3615,
        name = "Devrak",
        title = "Wind Rider Master",
        locations = {
            ["The Barrens"] = {
                x = 0.515,
                y = 0.303,
            },
        },
    },
    {
        id = 4319,
        name = "Thyssiana",
        title = "Hippogryph Master",
        locations = {
            ["Feralas"] = {
                x = 0.895,
                y = 0.459,
            },
            ["Thousand Needles"] = {
                x = 0.780,
                y = 0.179,
            },
        },
    },
    {
        id = 52093,
        name = "Falok Thurden",
        title = "Gryphon Master",
        locations = {
            ["Dun Morogh"] = {
                x = 0.686,
                y = 0.187,
            },
            ["Ironforge Airfields, Dun Morogh"] = {
                x = 0.528,
                y = 0.527,
            },
        },
    },
    {
        id = 52094,
        name = "Greta Stonehammer",
        title = "Gryphon Master",
        locations = {
            ["Wetlands"] = {
                x = 0.227,
                y = 0.653,
            },
            ["Dun Agrath, Wetlands"] = {
                x = 0.516,
                y = 0.552,
            },
        },
    },
    {
        id = 61532,
        name = "Levenda Skytalon",
        title = "Hippogryph Master",
        locations = {
            ["Winterspring"] = {
                x = 0.475,
                y = 0.641,
            },
        },
    },
    {
        id = 61623,
        name = "Orrik Thunderbeard",
        title = "Gryphon Master",
        locations = {
            ["The Barrens"] = {
                x = 0.341,
                y = 0.109,
            },
        },
    },
};

local A = A;

for _, npc in ipairs(flightMasters) do
    A.db.npcs[npc.id] = npc;
    A.db.flightMasterIds[npc.id] = 1;
end
flightMasters = nil;
