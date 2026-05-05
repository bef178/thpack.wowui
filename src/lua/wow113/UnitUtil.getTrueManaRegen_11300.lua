local STAT_KEY_MP5 = "ITEM_MOD_POWER_REGEN0_SHORT"

local db = {
    gearSets_11300 = {
        ["Augur's Regalia"] = {
            itemIds = {19609, 19956, 19830, 19829, 19828},
            effects = {
                [2] = {
                    [STAT_KEY_MP5] = 3
                }
            }
        },
        ["Freethinker's Armor"] = {
            itemIds = {19952, 19588, 19827, 19826, 19825},
            effects = {
                [2] = {
                    [STAT_KEY_MP5] = 3
                }
            }
        },
        ["Haruspex's Garb"] = {
            itemIds = {19613, 19955, 19840, 19839, 19838},
            effects = {
                [2] = {
                    [STAT_KEY_MP5] = 3
                }
            }
        }
    },
    enchants_11300 = {
        ["2624"] = {
            -- Minor Mana Oil
            [STAT_KEY_MP5] = 4
        },
        ["2625"] = {
            -- Lesser Mana Oil
            [STAT_KEY_MP5] = 8
        },
        ["2629"] = {
            -- Brilliant Mana Oil
            [STAT_KEY_MP5] = 12
        },
        ["2565"] = {
            -- Enchant Bracer - Mana Regeneration
            [STAT_KEY_MP5] = 4
        },
        ["2590"] = {
            -- Prophetic Aura
            [STAT_KEY_MP5] = 4
        }
    }
}

local function getUnitGearSetsEffectiveBonusMp5_11300(unit)
    local counts = {}
    for i = 1, 18 do
        local itemId = GetInventoryItemID(unit, i)
        for k, v in pairs(db.gearSets_11300) do
            if (Array.contains(v.itemIds, itemId)) then
                local n = (counts[k] or 0) + 1
                counts[k] = n
            end
        end
    end
    local mp5 = 0
    for k, count in pairs(counts) do
        local itemSet = db.gearSets_11300[k]
        for i = 1, count do
            local bonusMp5 = itemSet.effects[i] and itemSet.effects[i][STAT_KEY_MP5]
            if (bonusMp5) then
                mp5 = mp5 + bonusMp5 + 1
            end
        end
    end
    return mp5
end

local function getEquippedItemEnchantMp5_11300(itemLink)
    local _, _, enchantId = string.find(itemLink, "item:%d+:(%d*)")
    local effects = enchantId and db.enchants_11300[enchantId]
    return effects and effects[STAT_KEY_MP5] or 0
end

-- mp5
local function getUnitEquippedItemsMp5_11300(unit)
    local mp5 = 0
    for i = 1, 18 do
        local itemLink = GetInventoryItemLink(unit, i)
        if itemLink then
            local itemStats = GetItemStats(itemLink)
            local itemMp5 = itemStats and itemStats[STAT_KEY_MP5]
            if itemMp5 then
                mp5 = mp5 + itemMp5 + 1
            end
            mp5 = mp5 + getEquippedItemEnchantMp5_11300(itemLink)
        end
    end
    mp5 = mp5 + getUnitGearSetsEffectiveBonusMp5_11300(unit)
    return mp5
end

local function getManaRegenMultiplierByTalent113()
    local _, classType = UnitClass("player")
    local mul = 1
    if classType == "PRIEST" then
        -- Meditation
        local name, fileId, y, x, points, maxPoints = GetTalentInfo(1, 8)
        mul = mul + points * 0.05
    elseif classType == "MAGE" then
        -- Arcane Meditation
        local _, _, _, _, points = GetTalentInfo(1, 12)
        mul = mul + points * 0.05
    elseif classType == "DRUID" then
        -- Reflection
        local _, _, _, _, points = GetTalentInfo(3, 6)
        mul = mul + points * 0.05
    end
    return mul
end

local NUM_SECONDS_PER_TICK = 2

function UnitUtil.getTrueManaRegen_11300()
    -- GetManaRegen() gives 0.00xxx inside 5-second-rule
    local manaRegenPoints = GetManaRegen()
    if manaRegenPoints >= 1 then
        manaRegenPoints = manaRegenPoints * getManaRegenMultiplierByTalent113()
    else
        manaRegenPoints = 0
    end
    return manaRegenPoints + getUnitEquippedItemsMp5_11300("player") / 5
end
