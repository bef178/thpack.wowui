--------
-- gear mp5

local STAT_KEY_MP5 = "ITEM_MOD_POWER_REGEN0_SHORT";

-- lv60, p5
local GEAR_SETS_11300 = {
    ["Augur's Regalia"] = {
        itemIds = { 19609, 19956, 19830, 19829,19828 },
        effects = {
            [2] = {
                [STAT_KEY_MP5] = 3,
            },
        }
    },
    ["Freethinker's Armor"] = {
        itemIds = { 19952, 19588, 19827, 19826, 19825 },
        effects = {
            [2] = {
                [STAT_KEY_MP5] = 3,
            },
        }
    },
    ["Haruspex's Garb"] = {
        itemIds = { 19613, 19955, 19840, 19839, 19838 },
        effects = {
            [2] = {
                [STAT_KEY_MP5] = 3,
            },
        }
    },
};

local ENCHANTS_11300 = {
    ["2624"] = {
        -- Minor Mana Oil
        [STAT_KEY_MP5] = 4,
    },
    ["2625"] = {
        -- Lesser Mana Oil
        [STAT_KEY_MP5] = 8,
    },
    ["2629"] = {
        -- Brilliant Mana Oil
        [STAT_KEY_MP5] = 12,
    },
    ["2565"] = {
        -- Enchant Bracer - Mana Regeneration
        [STAT_KEY_MP5] = 4,
    },
    ["2590"] = {
        -- Prophetic Aura
        [STAT_KEY_MP5] = 4,
    },
};

local getUnitGearSetEligibleBonusMp5_11300 = function(unit)
    local statKey = STAT_KEY_MP5;
    local counts = {};
    for i = 1, 18 do
        local itemId = GetInventoryItemID(unit, i);
        for k, v in pairs(GEAR_SETS_11300) do
            if (array.contains(v.itemIds, itemId)) then
                local n = (counts[k] or 0) + 1;
                counts[k] = n;
            end
        end
    end
    local mp5 = 0;
    for k, count in pairs(counts) do
        local itemSet = GEAR_SETS_11300[k];
        for i = 1, count do
            local bonusMp5 = itemSet.effects[i] and itemSet.effects[i][statKey];
            if (bonusMp5) then
                mp5 = mp5 + bonusMp5 + 1;
            end
        end
    end
    return mp5;
end;

local getGearEnchantMp5_11300 = function(itemLink)
    local statKey = STAT_KEY_MP5;
    local _, _, enchantId = string.find(itemLink, "item:%d+:(%d*)");
    local effects = enchantId and ENCHANTS_11300[enchantId];
    return effects and effects[statKey] or 0;
end

A.getUnitEquippedGearsMp5_11300 = function(unit)
    local statKey = STAT_KEY_MP5;
    local mp5 = 0;
    for i = 1, 18 do
        local itemLink = GetInventoryItemLink(unit, i);
        if (itemLink) then
            local itemStats = GetItemStats(itemLink);
            local itemMp5 = itemStats and itemStats[statKey];
            if (itemMp5) then
                mp5 = mp5 + itemMp5 + 1;
            end
            mp5 = mp5 + getGearEnchantMp5_11300(itemLink);
        end
    end
    mp5 = mp5 + getUnitGearSetEligibleBonusMp5_11300(unit);
    return mp5;
end;

--------

local getSpiritManaRegenTalentMultiplier_11300 = function()
    local _, className = UnitClass("player");
    local mul = 1;
    if (className == "PRIEST") then
        -- Meditation
        local _, _, _, _, points = GetTalentInfo(1, 8);
        mul = mul + points * 0.05;
    elseif (className == "MAGE") then
        -- Arcane Meditation
        local _, _, _, _, points = GetTalentInfo(1, 12);
        mul = mul + points * 0.05;
    elseif (className == "DRUID") then
        -- Reflection
        local _, _, _, _, points = GetTalentInfo(3, 6);
        mul = mul + points * 0.05;
    end
    return mul;
end;

-- in the 60's, GetManaRegen() has serious bug; it requires a lot of enumeration work to get the correct value
A.getManaRegenPerTick_11300 = function()
    local baseManaRegen = GetManaRegen();
    if (baseManaRegen < 1) then
        -- GetManaRegen() gives 0.00xxx inside 5-seconds-rule
        baseManaRegen = 0;
    else
        baseManaRegen = baseManaRegen * getSpiritManaRegenTalentMultiplier_11300();
    end
    local mp5 = A.getUnitEquippedGearsMp5_11300("player");
    local numSecondsPerTick = 2;
    return (baseManaRegen + mp5 / 5) * numSecondsPerTick, mp5;
end;

-- mana regen outside 5-second-rule
A.getManaRegenPerTick = function()
    local _, _, _, interfaceVersion = GetBuildInfo();
    if (not interfaceVersion or interfaceVersion < 20000) then
        return A.getManaRegenPerTick_11300();
    else
        local numSecondsPerTick = 2;
        return GetManaRegen() * numSecondsPerTick;
    end
end
