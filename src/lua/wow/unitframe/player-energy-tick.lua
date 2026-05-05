local _, classType = UnitClass("player")
if classType ~= "ROGUE" and classType ~= "DRUID" then
    return
end

local ENERGY_TICK_INTERVAL = 2
local ENERGY_TICK_POINTS = 20

local function getEnergyTickProgress(data)
    local now = GetTime()
    local points = UnitMana(data.unit)
    local diff = points - data.lastSeenPoints
    -- exclude [Thistle Tea] and [Adrenaline Rush]
    if diff > ENERGY_TICK_POINTS - 1 and diff < ENERGY_TICK_POINTS + 1 then
        data.lastTickTimestamp = now
    end
    data.lastSeenPoints = points
    return math.mod(now - data.lastTickTimestamp, ENERGY_TICK_INTERVAL) / ENERGY_TICK_INTERVAL
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
    lastSeenPoints = 0
}

local f = prepareTickBar()
f:SetScript("OnUpdate", function()
    local self = f
    local elapsed = arg1
    if UnitPowerType("player") == 3 then
        local progress = getEnergyTickProgress(data)
        self.sparkTextureRegion:ClearAllPoints()
        self.sparkTextureRegion:SetPoint("CENTER", self, "LEFT", self:GetWidth() * progress, 0)
        self.sparkTextureRegion:Show()
    else
        self.sparkTextureRegion:Hide()
    end
end)
