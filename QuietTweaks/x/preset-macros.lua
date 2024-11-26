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

local castIf = function(spell, additionalCondition)
    if (additionalCondition == nil) then
        additionalCondition = true;
    end
    if (spell and A.getPlayerSpellCooldownTime(spell) == 0 and additionalCondition) then
        A.cast(spell);
    end
end;

local palBless = function(defaultBlessName)
    local migBless = A.getPlayerSpell("Blessing of Might");
    local wisBless = A.getPlayerSpell("Blessing of Wisdom");
    local ligBless = A.getPlayerSpell("Blessing of Light");
    local sanBless = A.getPlayerSpell("Blessing of Sanctuary");
    local kinBless = A.getPlayerSpell("Blessing of Kings");

    -- XXX how to get buff source
    local blessBuff = nil;
    for i, v in ipairs({ migBless, wisBless, ligBless, sanBless, kinBless }) do
        blessBuff = A.buffed(v);
        if (blessBuff) then
            break;
        end
    end

    local bless = defaultBlessName and A.getPlayerSpell(defaultBlessName) or migBless;
    if ((not blessBuff or blessBuff.buffTimeToLive < 30) and bless) then
        A.cast(bless);
    end
end;

-- cannot cast [Seal of Righteousness] right after [Judgement], even with delay via OnUpdate
local palSeal = function()
    local rigSeal = A.getPlayerSpell("Seal of Righteousness");
    local cruSeal = A.getPlayerSpell("Seal of Crusader");
    local wisSeal = A.getPlayerSpell("Seal of Wisdom");
    local ligSeal = A.getPlayerSpell("Seal of Light");
    local jusSeal = A.getPlayerSpell("Seal of Justice");
    local comSeal = A.getPlayerSpell("Seal of Command");
    local jud = A.getPlayerSpell("Judgement");
    local hoStrk = A.getPlayerSpell("Holy Strike");
    local cruStrk = A.getPlayerSpell("Crusader Strike");

    local strike = hoStrk or cruStrk;

    local which;
    for i, spell in ipairs({ rigSeal, cruSeal, wisSeal, ligSeal, jusSeal, comSeal }) do
        if (A.buffed(spell)) then
            which = i;
            break;
        end
    end
    if (which) then
        if (which == 1 or which == 6) then
            -- in close combat [Holy Strike] is piror to [Judgement]
            castIf(strike);
            -- no [Judgement] if [Seal of Righteousness] is not ready, or may lose the incidental holy damage
            castIf(jud, A.getPlayerSpellCooldownTime(rigSeal) < 0.05);
        else
            castIf(jud, A.getPlayerSpellCooldownTime(rigSeal) < 0.05);
            castIf(strike);
        end
    else
        castIf(comSeal or rigSeal);
    end
end;

_G.palHam = function()
    if (not A.inCombat()) then
        palBless();
    end
    palSeal();
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
        {
            name = ">ham",
            content = [[
#showtooltip Judgement
/run palHam()
/run startAttacking()
]],
        },
        {
            name = ">emp",
            icon = "Spell_Holy_SpellWarding",
            iconIndex = 448,
            content = [[
/run local csbn=CastSpellByName; local _,tc=UnitClass("target"); if not UnitIsPlayer("target") or tc=="ROGUE" or tc=="WARRIOR" then csbn("Blessing of Might") else csbn("Blessing of Wisdom") end
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
