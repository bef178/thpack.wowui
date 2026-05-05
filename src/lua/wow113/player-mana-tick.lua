local getTrueManaRegen_11300 = UnitUtil.getTrueManaRegen_11300

local POWER_TYPE_MANA = 0
local POWER_TYPE_RAGE = 1
local POWER_TYPE_FOCUS_POINT = 2
local POWER_TYPE_ENERGY = 3

local _, classType = UnitClass("player")
if classType == "MAGE" or classType == "PRIEST" or classType == "WARLOCK" or classType == "DRUID" or classType == "HUNTER" or classType == "SHAMAN" or classType == "PALADIN" then
else
    return
end

local MANA_TICK_INTERVAL = 2
local MANA_TICK_COOLDOWN = 5
local MANA_TICK_INTERVAL_IN_5SEC_RULE = (math.ceil(MANA_TICK_COOLDOWN / MANA_TICK_INTERVAL) + 1) * MANA_TICK_INTERVAL

-- mana regen outside 5-second-rule
local function getManaRegenPerTick()
    local _, _, _, interfaceVersion = GetBuildInfo()
    if interfaceVersion < 20000 then
        return getTrueManaRegen_11300() * MANA_TICK_INTERVAL
    else
        return GetManaRegen() * MANA_TICK_INTERVAL
    end
end

-- 原理是，5秒规则吃掉了本应产生的回蓝，而一个5秒最多吃掉3次回蓝
-- 因此，5秒规则内，回蓝的CD视为8秒，五秒规则外，回蓝的CD视为2秒
local function getManaTickProgress(data, castSucceeded)
    local now = GetTime()
    local points = UnitMana(data.unit)

    local elapsedSinceEffectiveTick = math.mod(now - data.lastTickTimestamp, MANA_TICK_INTERVAL)
    if points > data.lastSeenPoints then
        -- mana increased, is it a tick?
        local manaRegenPoints = getManaRegenPerTick()
        if manaRegenPoints > 0 then
            local diff = points - data.lastSeenPoints
            if diff > manaRegenPoints - 1 and diff < manaRegenPoints + 1 then
                data.lastTickTimestamp = now
            end
        end
    elseif castSucceeded and points < data.lastSeenPoints then
        -- mana consumed, start cooldown
        local interval = math.ceil((elapsedSinceEffectiveTick + MANA_TICK_COOLDOWN) / MANA_TICK_INTERVAL) * MANA_TICK_INTERVAL
        data.nextTickTimestamp = now - elapsedSinceEffectiveTick + interval
    end
    data.lastSeenPoints = points

    if now < data.nextTickTimestamp then
        return 1 - (data.lastTickTimestamp - now) / MANA_TICK_INTERVAL_IN_5SEC_RULE
    else
        return elapsedSinceEffectiveTick / MANA_TICK_INTERVAL
    end
end

local function prepareTickBar()
    local f = CreateFrame("Frame", nil, PlayerFrameManaBar, nil)
    f:SetAllPoints()

    f.sparkTextureRegion = f:CreateTexture(nil, "OVERLAY")
    f.sparkTextureRegion:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
    f.sparkTextureRegion:SetWidth(6)
    f.sparkTextureRegion:SetHeight(18)
    f.sparkTextureRegion:SetBlendMode("ADD")

    return f
end

local data = {
    unit = "player",
    lastTickTimestamp = 0,
    nextTickTimestamp = 0,
    lastSeenPoints = 0
}

local f = prepareTickBar()
f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
f:SetScript("OnEvent", function(self, event, ...)
    getManaTickProgress(data, true)
end)
f:SetScript("OnUpdate", function(self, elapsed)
    if UnitPowerType("player") == POWER_TYPE_MANA then
        local progress = getManaTickProgress(data, false)
        self.sparkTextureRegion:ClearAllPoints()
        self.sparkTextureRegion:SetPoint("CENTER", self, "LEFT", self:GetWidth() * progress, 0)
        self.sparkTextureRegion:Show()
    else
        self.sparkTextureRegion:Hide()
    end
end)
