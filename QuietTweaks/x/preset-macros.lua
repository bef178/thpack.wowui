local macros = {
    ["PALADIN"] = {
        {
            name = ">1",
            content = [[
#showtooltip
/stand
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] []  Flash of Light
]],
        },
        {
            name = ">2",
            content = [[
#showtooltip
/stand
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] [] Cleanse
]],
        },
        {
            name = ">3",
            content = [[
#showtooltip
/stand
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] [] Holy Light
]],
        },
        {
            name = ">c",
            content = [[
#showtooltip Crusader Strike
/startattack
/cast [nomod] Holy Strike
/cast [nomod] Crusader Strike
/cast [mod] Holy Strike(Rank 1)
/cast [mod] Crusader Strike(Rank 1)
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
/startattack
/cast [nomod] Judgement
/stopmacro [nomod]
/castsequence reset=26 Seal of Righteousness, Judgement
]],
        },
        {
            name = ">g",
            content = [[
#showtooltip
/cast [harm,@target,exists] Hammer of Justice; [help,@target,exists] Blessing of Protection
]],
        },
        {
            name = ">q",
            content = [[
#showtooltip
/cast [nomod] Hammer of Wrath
/cast [mod] Divine Shield
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
            comment = "",
        },
        {
            name = ">r",
            content = [[
#showtooltip
/cast Holy Shield
/cast Holy Shock
]],
        },
        {
            name = ">t",
            icon = "Spell_Nature_Reincarnation",
            iconIndex = 531,
            content = [[
#showtooltip
/castsequence reset=6 Seal of Justice, Judgement, Judgement
]],
        },
        {
            name = ">ham",
            content = [[
/run local cs=CastSpellByName; for i=1,32 do if(UnitBuff("player",i)) then if(string.find(UnitBuff("player",i),"ThunderBolt")) then cs("Judgement");break;end;else cs("Seal of Righteousness");break;end;end
]],
        },
        {
            name = ">ty",
            icon = "Spell_Holy_SpellWarding",
            iconIndex = 442,
            content = [[
/run local bom="Blessing of Might"; local bow="Blessing of Wisdom"; local cs=CastSpellByName; local p=UnitIsPlayer("target");local _,c=UnitClass("target"); if not p or c=="ROGUE" or c=="WARRIOR" then cs(bom) else cs(bow) end
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
    local _, className = UnitClass("player");
    for i, v in ipairs(macros[className] or {}) do
        getOrCreateOrUpdateMacro(v.name, v.iconIndex or 1, v.content, 1, 1, overwrites);
    end
end

(function()
    A.addSlashCommand("aLoadPresetMacros", "/loadpresetmacros", function(x)
        loadPresetMacros(x == "force" or x == "overwrite");
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
