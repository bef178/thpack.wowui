local Array = Array

if INVSLOT_AMMO == nil then
    INVSLOT_AMMO = 0
    INVSLOT_HEAD = 1
    INVSLOT_NECK = 2
    INVSLOT_SHOULDER = 3
    INVSLOT_BODY = 4
    INVSLOT_CHEST = 5
    INVSLOT_WAIST = 6
    INVSLOT_LEGS = 7
    INVSLOT_FEET = 8
    INVSLOT_WRIST = 9
    INVSLOT_HAND = 10
    INVSLOT_FINGER1 = 11
    INVSLOT_FINGER2 = 12
    INVSLOT_TRINKET1 = 13
    INVSLOT_TRINKET2 = 14
    INVSLOT_BACK = 15
    INVSLOT_MAINHAND = 16
    INVSLOT_OFFHAND = 17
    INVSLOT_RANGED = 18
    INVSLOT_TABARD = 19
end

EquipUtil = (function()
    local EquipUtil = {}

    local _aEquipTooltip = CreateFrame("GameTooltip", "aEquipTooltip", UIParent, "GameTooltipTemplate")
    _aEquipTooltip:SetOwner(UIParent, "ANCHOR_NONE")

    local function _getTooltipLines(tooltip)
        local lines = {}
        local tooltipName = tooltip:GetName()
        for i = 3, tooltip:NumLines() do
            local region = _G[tooltipName .. "TextLeft" .. i]
            if region then
                local line = region:GetText()
                if line then
                    Array.add(lines, line)
                end
            end
        end
        return lines
    end

    local function _parseTooltipLine(line, result)
        result = result or {}
        local school, amount

        -- "+14 Strength"
        amount = String.match(line, "^+(%d+) Strength$")
        if amount then
            result.equipStrength = (result.equipStrength or 0) + tonumber(amount)
            return true
        end

        -- "+4 Agility"
        amount = String.match(line, "^+(%d+) Agility$")
        if amount then
            result.equipAgility = (result.equipAgility or 0) + tonumber(amount)
            return true
        end

        -- "+9 Stamina"
        amount = String.match(line, "^+(%d+) Stamina$")
        if amount then
            result.equipStamina = (result.equipStamina or 0) + tonumber(amount)
            return true
        end

        -- "+15 Intellect"
        amount = String.match(line, "^+(%d+) Intellect$")
        if amount then
            result.equipIntellect = (result.equipIntellect or 0) + tonumber(amount)
            return true
        end

        -- "+14 Spirit"
        amount = String.match(line, "^+(%d+) Spirit$")
        if amount then
            result.equipSpirit = (result.equipSpirit or 0) + tonumber(amount)
            return true
        end

        -- "386 Armor"
        amount = String.match(line, "^(%d+) Armor$")
        if amount then
            result.equipArmor = (result.equipArmor or 0) + tonumber(amount)
            return true
        end

        -- "31 Block"
        amount = String.match(line, "^(%d+) Block$")
        if amount then
            result.equipBlockValue = (result.equipBlockValue or 0) + tonumber(amount)
            return true
        end

        -- "Equip: Improves your chance to hit by %d%%."
        amount = String.match(line, "^Equip: Improves your chance to hit by (%d+)%%")
        if amount then
            result.equipHitChance = (result.equipHitChance or 0) + tonumber(amount)
            return true
        end

        -- "Equip: Increases the block value of your shield by %d."
        amount = String.match(line, "^Equip: Increases the block value of your shield by (%d+)")
        if amount then
            result.equipBlockValue = (result.equipBlockValue or 0) + tonumber(amount)
            return true
        end

        -- "Equip: Increases damage and healing done by magical spells and effects by up to %d."
        amount = String.match(line, "^Equip: Increases damage and healing done by magical spells and effects by up to (%d+)%.$")
        if amount then
            result.equipSpellBonusDamage = (result.equipSpellBonusDamage or 0) + tonumber(amount)
            result.equipSpellBonusHealing = (result.equipSpellBonusHealing or 0) + tonumber(amount)
            return true
        end

        -- "Equip: Increases healing done by spells and effects by up to %d."
        amount = String.match(line, "^Equip: Increases healing done by spells and effects by up to (%d+)")
        if amount then
            result.equipSpellBonusHealing = (result.equipSpellBonusHealing or 0) + tonumber(amount)
            return true
        end

        -- "Equip: Increases damage done by <School> spells and effects by up to %d."
        school, amount = String.match(line, "^Equip: Increases damage done by (%a+) spells and effects by up to (%d+)")
        if school then
            local key = "equip" .. school .. "Bonus"
            result[key] = (result[key] or 0) + tonumber(amount)
            return true
        end

        -- "Equip: Improves your chance to hit with spells by %d%%."
        amount = String.match(line, "^Equip: Improves your chance to hit with spells by (%d+)%%")
        if amount then
            result.equipSpellHitChance = (result.equipSpellHitChance or 0) + tonumber(amount)
            return true
        end

        -- "Equip: Improves your chance to get a critical strike with spells by %d%%."
        amount = String.match(line, "^Equip: Improves your chance to get a critical strike with spells by (%d+)%%")
        if amount then
            result.equipSpellCritChance = (result.equipSpellCritChance or 0) + tonumber(amount)
            return true
        end

        return false
    end

    function EquipUtil.scanEquippedItem(unit, slotId, result)
        unit = unit or "player"
        if not slotId then
            return
        end
        result = result or {}
        if GetInventoryItemLink(unit, slotId) then
            _aEquipTooltip:ClearLines()
            _aEquipTooltip:SetInventoryItem(unit, slotId)
            local lines = _getTooltipLines(_aEquipTooltip)
            for _, line in ipairs(lines) do
                if not _parseTooltipLine(line, result) then
                    if not result.equipUnrecogizedLines then
                        result.equipUnrecogizedLines = {}
                    end
                    Array.add(result.equipUnrecogizedLines, "slot" .. slotId .. ":" .. line)
                end
            end
        end
        return result
    end

    function EquipUtil.scanAllEquippedItems(unit)
        if not unit then
            return
        end
        local result = {}
        for slotId = 1, 18 do
            EquipUtil.scanEquippedItem(unit, slotId, result)
        end
        return result
    end

    return EquipUtil
end)()
