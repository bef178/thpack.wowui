local A = A;

_G.startAttacking = function(b)
    if (b == nil) then
        b = true;
    end
    if (A.checkPlayerAttacking()) then
        if (not b) then
            CastSpellByName("Attack");
        end
    else
        if (b) then
            CastSpellByName("Attack");
        end
    end
end;

----------------------------------------

local macros = {
    ["PALADIN"] = {
        {
            name = ">1",
            content = [[
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] []  Flash of Light
]],
        },
        {
            name = ">2",
            content = [[
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] [] Cleanse
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] [] Purify
]],
        },
        {
            name = ">3",
            content = [[
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] [] Holy Light
]],
        },
        {
            name = ">c",
            content = [[
#showtooltip
/dismount
/cast [nomod] Holy Strike; Crusader Strike
/run startAttacking()
]],
        },
        {
            name = ">b",
            content = [[
#showtooltip
/cast [nomod] Exorcism; Holy Wrath
]],
        },
        {
            name = ">f",
            content = [[
#showtooltip
/dismount
/cast [nomod] Judgement; Seal of Righteousness
/run startAttacking()
]],
        },
        {
            name = ">g",
            content = [[
#showtooltip
/cast [mod,@mouseover,exists,harm] [@target,exists,harm] Hammer of Justice
/cast [mod,@mouseover,exists,help] [@target,exists,help] Hand of Protection
]],
        },
        {
            name = ">q",
            content = [[
#showtooltip
/cast [nomod] Hammer of Wrath
/cast [mod] Divine Shield
/cast [mod] Divine Protection
/use [mod] Hearthstone
]],
        },
        {
            id = 0,
            name = ">e",
            icon = "INV_MISC_QUESTIONMARK",
            content = [[
#showtooltip
/cast [nomod] Consecration; Consecration(Rank 1)
]],
        },
        {
            name = ">r",
            content = [[
#showtooltip
/cast Holy Shield
/cast Holy Shock
]],
        },
    }
};

local function getOrCreateOrUpdateMacro(name, iconIndex, content, isLocal, isPerCharacter, overwrites)
    local index = GetMacroIndexByName(name);
    if (index > 0) then
        if (overwrites) then
            return EditMacro(index, name, iconIndex, content, isLocal, isPerCharacter);
        else
            return index;
        end
    else
        return CreateMacro(name, iconIndex, content, isLocal, isPerCharacter);
    end
end

local function loadPresetMacros(overwrites)
    local _, c = UnitClass("player");
    for i, v in ipairs(macros[c] or {}) do
        getOrCreateOrUpdateMacro(v.name, v.iconIndex or 1, v.content, 1, 1, overwrites);
    end
end

(function()
    A.addSlashCommand("aLoadPresetMacros", "/loadpresetmacros", function(x)
        loadPresetMacros(true);
        A.logi("Preset macros loaded.");
    end);

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents();
        f:Hide();
        A.logi("To load preset macros, type \"/loadpresetmacros\".");
    end);
end)();
