-- statistics of player's current status
--
local GetInventoryItemTexture = GetInventoryItemTexture

local Array = Array
local Map = Map
local ItemUtil = ItemUtil
local StatsUtil = StatsUtil

local StatsBoard = Proto.newProto(nil, function(o, parentFrame, x, y, unit)
    local f = CreateFrame("Frame", nil, parentFrame, nil)
    f:SetWidth(1)
    f:SetHeight(1)
    f:SetPoint("TOPLEFT", x, y)
    o._f = f
    o._views = {}
    o._unit = unit
end)

function StatsBoard:render(rows)
    for i, row in ipairs(rows) do
        local view = self:_getOrCreateRowView(i)
        view.iconRegion:SetTexture(row.icon)
        view.textRegion:SetText(row.text)
    end
    for i = Array.size(rows) + 1, Array.size(self._views) do
        local view = self._views[i]
        view.iconRegion:SetTexture(nil)
        view.textRegion:SetText(nil)
    end
end

function StatsBoard:_getOrCreateRowView(index)
    for i = Array.size(self._views) + 1, index do
        local ICON_HEIGHT = 20
        local LINE_WIDTH = 60
        local LINE_HEIGHT = 14
        local FONT_SIZE = 9

        local n = Array.size(self._views)

        local iconRegion = self._f:CreateTexture(nil, "OVERLAY")
        iconRegion:SetPoint("TOPLEFT", 0, -(ICON_HEIGHT + 2) * n)
        iconRegion:SetWidth(ICON_HEIGHT)
        iconRegion:SetHeight(ICON_HEIGHT)

        local textRegion = self._f:CreateFontString(nil, "OVERLAY")
        textRegion:SetFont(STANDARD_TEXT_FONT, FONT_SIZE, "OUTLINE")
        textRegion:SetJustifyH("LEFT")
        textRegion:SetPoint("LEFT", iconRegion, "RIGHT", 2, 0)
        textRegion:SetWidth(LINE_WIDTH)
        textRegion:SetHeight(LINE_HEIGHT)

        Array.add(self._views, {
            iconRegion = iconRegion,
            textRegion = textRegion
        })
    end
    return self._views[index]
end

----------------------------------------

local MIGHT_AND_MAGIC = {
    attack = {
        -- 132223:ability_meleedamage
        -- 132333:ability_warrior_battleshout
        -- 132090:ability_backstab
        -- 132222:ability_marksmanship
        -- 132329:ability_trueshot
        -- 132169:ability_hunter_criticalshot
        {
            key = "dps",
            icon = function(unit)
                return GetInventoryItemTexture(unit, 16) or [[interface\icons\ability_meleedamage]] -- 132223
            end,
            text = function(data)
                return string.format("%.01f/%d", data.dps, data.ap)
            end
        }, {
            key = "critChance",
            icon = [[interface\icons\ability_backstab]], -- 132090
            text = function(data)
                local value = data.critChance
                if not value or value == 0 then
                    return
                end
                return string.format("%.02f%%", value)
            end
        }, {
            key = "rangedDps",
            icon = function(unit)
                return GetInventoryItemTexture(unit, 18)
            end,
            text = function(data, unit)
                local hasRelic = UnitHasRelicSlot(unit)
                local rangedSlotEquipped = not not GetInventoryItemTexture(unit, 18)
                if not hasRelic and rangedSlotEquipped then
                    return string.format("%.01f/%d", data.rangedDps, data.rangedAp)
                end
            end
        }, {
            key = "rangedCritChance",
            icon = [[interface\icons\ability_hunter_criticalshot]], -- 132169
            text = function(data)
                local value = data.rangedCritChance
                if not value or value == 0 then
                    return
                end
                return string.format("%.02f%%", value)
            end
        }, {
            key = "hitChance",
            icon = [[interface\icons\ability_marksmanship]], -- 132222
            text = function(data)
                local value = data.hitChance
                if not value or value == 0 then
                    return
                end
                return string.format("+%.01f%%", value)
            end
        }
    },
    defense = {
        -- 132341:ability_warrior_defensivestance
        -- 135893:spell_holy_devotionaura
        -- 136047:spell_nature_invisibilty
        -- 132269:ability_parry
        -- 132110:ability_defend
        {
            key = "defenseRank",
            icon = [[interface\icons\ability_warrior_defensivestance]], -- 132341
            text = function(data)
                return string.format("%d/%d", data.defenseRank, data.armor)
            end
        }, {
            key = "dodgeChance",
            icon = [[interface\icons\spell_nature_invisibilty]], -- 136047
            text = function(data)
                local value = data.dodgeChance
                if not value or value == 0 then
                    return
                end
                return string.format("%.01f%%", value)
            end
        }, {
            key = "parryChance",
            icon = [[interface\icons\ability_parry]], -- 132269
            text = function(data, unit)
                if not GetInventoryItemTexture(unit, 16) then
                    return
                end
                local value = data.parryChance
                if not value or value == 0 then
                    return
                end
                return string.format("%.01f%%", value)
            end
        }, {
            key = "block",
            icon = [[interface\icons\ability_defend]], -- 132110
            text = function(data, unit)
                local item = ItemUtil.getEquippedItem(unit, 17)
                if not item or item.itemEquipSlot ~= "INVTYPE_SHIELD" then
                    return
                end
                local blockChance = data.blockChance
                if not blockChance or blockChance == 0 then
                    return
                end
                local blockValue = data.blockValue or 0
                if not blockValue or blockValue == 0 then
                    return string.format("%.01f%%", blockChance)
                end
                return string.format("%.01f%%/%d", blockChance, data.blockValue)
            end
        }
    },
    spell = {
        -- 136096:spell_nature_starfall
        {
            key = "spellBonusDamage",
            icon = [[interface\icons\spell_nature_starfall]] -- 136096
        }, {
            key = "spellBonusHealing"
        }, {
            key = "spellCritChance",
            icon = 132090,
            text = function(data)
                local value = data.spellCritChance
                if not value or value == 0 then
                    return
                end
                return string.format("%.02f%%", value)
            end
        }, {
            key = "spellHitChance",
            icon = 132222,
            text = function(data)
                local value = data.spellHitChance
                if not value or value == 0 then
                    return
                end
                return string.format("+%.01f%%", value)
            end
        }, {
            key = "holyBonus"
        }, {
            key = "holyResistance"
        }, {
            key = "fireBonus"
        }, {
            key = "fireResistance"
        }, {
            key = "natureBonus"
        }, {
            key = "natureResistance"
        }, {
            key = "frostBonus"
        }, {
            key = "frostResistance"
        }, {
            key = "shadowBonus"
        }, {
            key = "shadowResistance"
        }, {
            key = "arcaneBonus"
        }, {
            key = "arcaneResistance"
        }
    }
}

local CLASS_BOARDS = {
    ["MAGE"] = {"spell"},
    ["PRIEST"] = {"spell"},
    ["WARLOCK"] = {"spell"},
    ["ROGUE"] = {"attack"},
    ["DRUID"] = {"attack", "defense", "spell"},
    ["HUNTER"] = {"attack", "spell"},
    ["SHAMAN"] = {"attack", "spell"},
    ["WARRIOR"] = {"attack", "defense"},
    ["PALADIN"] = {"attack", "defense", "spell"}
}

local function getRowText(itemKey, itemText, data, unit)
    if itemText == nil then
        local value = data[itemKey]
        if value and value ~= 0 then
            return value
        end
    elseif type(itemText) == "function" then
        return itemText(data, unit)
    end
end

local function getBoardRows(boardName, unit)
    unit = unit or "player"
    local _, className = UnitClass(unit)
    if not Array.contains(CLASS_BOARDS[className] or {}, boardName) then
        return {}
    end

    local data = StatsUtil.getSheet(unit, boardName)
    local rows = {}
    for _, item in ipairs(MIGHT_AND_MAGIC[boardName] or {}) do
        local icon = type(item.icon) == "function" and item.icon(unit) or item.icon
        local text = getRowText(item.key, item.text, data, unit)
        if text then
            Array.add(rows, {
                key = item.key,
                icon = icon,
                text = text
            })
        end
    end
    return rows
end

local mightBoard = StatsBoard:new(CharacterModelFrame, 6, -76) -- 6, -212
-- local magicBoard = StatsBoard:new(CharacterModelFrame, 160, -146)

local timer = Timer:new()
local function delayedRender()
    timer:start(0.5, function(progress, totalElapsedSeconds, isEnd)
        if isEnd then
            local mightRows = getBoardRows("attack")
            Array.addAll(mightRows, getBoardRows("defense"))
            mightBoard:render(mightRows)
            -- local magicRows = getBoardRows("spell")
            -- magicBoard:render(magicRows)
        end
    end)
end

mightBoard._f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
mightBoard._f:RegisterEvent("SKILL_LINES_CHANGED")
mightBoard._f:RegisterEvent("UNIT_ATTACK")
mightBoard._f:RegisterEvent("UNIT_ATTACK_POWER")
mightBoard._f:RegisterEvent("UNIT_ATTACK_SPEED")
mightBoard._f:RegisterEvent("UNIT_AURA")
mightBoard._f:RegisterEvent("UNIT_RANGED_ATTACK_POWER")
mightBoard._f:RegisterEvent("UNIT_RANGEDDAMAGE")
mightBoard._f:RegisterEvent("UNIT_STATS")
mightBoard._f:SetScript("OnEvent", delayedRender)

CharacterModelFrame:SetScript("OnShow", delayedRender)

-- CharacterResistanceFrame:Hide()
-- CharacterAttributesFrame:Hide()
-- CharacterModelFrame:SetHeight(302)
