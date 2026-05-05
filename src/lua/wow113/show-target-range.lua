local Array = Array

local SpellBook = {}

function SpellBook.getSpellName(spellIdOrName, noCheck)
    local name = GetSpellInfo(spellIdOrName)
    if noCheck then
        return name
    end
    if name then
        return GetSpellInfo(name)
    end
end

function SpellBook.getSpellRange(spellIdOrName)
    local name, _, _, _, minRange, maxRange = GetSpellInfo(spellIdOrName)
    if name then
        return minRange, maxRange
    end
end

local RangeBook = {
    sentinelSpells = {
        "攻击",
        "射击",
        2764, -- throw [8,30]
        -- mage
        "火球术",
        "寒冰箭",
        "冰枪术",
        "奥术冲击",
        "变形术",
        -- paladin
        "制裁之锤", -- [0,10]
        "驱邪术", -- [0,30]
        "审判", -- [0,10]
        "圣光术", -- [0,40]
        "保护祝福" -- [0,30]
    }
}

function RangeBook.init()
    local spellRanges = {}
    for _, v in pairs(RangeBook.sentinelSpells) do
        local spellName = SpellBook.getSpellName(v)
        if spellName then
            local minRange, maxRange = SpellBook.getSpellRange(spellName)
            if maxRange then
                if maxRange == 0 then
                    -- melee
                    maxRange = 5
                end
                spellRanges[spellName] = {minRange, maxRange}
            end
        end
    end
    RangeBook.spellRanges = spellRanges
end

function RangeBook.getUnitRange(unit)
    if not UnitExists(unit) then
        return
    end

    if UnitIsUnit(unit, "player") then
        return {0, 0}
    end

    local resultRanges = {0, 99}
    for spellName, range in pairs(RangeBook.spellRanges) do
        if IsSpellInRange(spellName, unit) then
            resultRanges = IntRangeExtension.getIntersection(resultRanges, range)
        else
            resultRanges = IntRangeExtension.getSubstraction(resultRanges, range)
        end
    end
    return resultRanges
end

function RangeBook.buildRangeString(ranges)
    if not ranges then
        return
    end

    if ranges[2] == 0 then
        return "*"
    end
    if ranges[2] == 99 then
        return "*"
    end

    if Array.size(ranges) == 2 then
        if ranges[2] == 0 then
            return 0
        elseif ranges[2] >= 99 then
            return "*"
        elseif ranges[1] == 0 or ranges[1] >= 10 then
            return ranges[2] .. "yd"
        end
    end

    local s = ""
    for i = 1, Array.size(ranges), 2 do
        s = s .. ranges[i] .. "-" .. ranges[i + 1]
        if i + 1 < Array.size(ranges) then
            s = s .. ","
        end
    end
    return s .. "yd"
end

--------

local f = CreateFrame("Frame", nil, TargetFrame, nil)
f:SetPoint("BOTTOMLEFT", TargetFrame, "BOTTOMRIGHT", -40, 33)

local rangeText = f:CreateFontString()
rangeText:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
rangeText:SetTextColor(0, 1, 0)
-- rangeText:SetJustifyH("RIGHT")
-- rangeText:SetPoint("TOP", TargetFrame, "TOPLEFT", 112, -6)
rangeText:SetJustifyH("LEFT")
rangeText:SetPoint("BOTTOMLEFT", 0, 0)
f.rangeText = rangeText

local _, _, _, interfaceVersion = GetBuildInfo()
if interfaceVersion and interfaceVersion >= 21000 then
    f:RegisterEvent("PLAYER_TALENT_UPDATE")
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
end
f:RegisterEvent("LEARNED_SPELL_IN_TAB")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")

f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        RangeBook.init()
    elseif event == "PLAYER_REGEN_ENABLED" then
        self.rangeText:SetTextColor(0, 1, 0)
    elseif event == "PLAYER_REGEN_DISABLED" then
        self.rangeText:SetTextColor(1, 0, 0)
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- update immediately
        self:GetScript("OnUpdate")(self, 99)
    end
end)

f:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed > 0.1 then
        self.elapsed = 0
        local resultRanges = RangeBook.getUnitRange("target")
        local rangeString = RangeBook.buildRangeString(resultRanges)
        self.rangeText:SetText(rangeString)
    end
end)
