local _, classNameEn = UnitClass("player");

local isEpClass = false;
if (classNameEn == "ROGUE"
        or classNameEn == "DRUID") then
    isEpClass = true;
end

local isMpClass = false;
if (classNameEn == "MAGE"
        or classNameEn == "PRIEST"
        or classNameEn == "WARLOCK"
        or classNameEn == "DRUID"
        or classNameEn == "HUNTER"
        or classNameEn == "SHAMAN"
        or classNameEn == "PALADIN") then
    isMpClass = true;
end

if (not isEpClass and not isMpClass) then
    return;
end

--------

local energyData = {
    unit = "player",
    pulseTime = 0,
    energy = 0,
};

local function findEnergyPulseProgress(data)
    local PULSE_INTERVAL = 2;
    local PULSE_AMOUNT = 20;
    local now = GetTime();
    local energy = UnitPower(data.unit, Enum.PowerType.Energy);
    local diff = energy - data.energy;
    -- exclude [Thistle Tea] and [Adrenaline Rush]
    if (diff > PULSE_AMOUNT - 1 and diff < PULSE_AMOUNT + 1) then
        data.pulseTime = now;
    end
    data.energy = energy;
    return (now - data.pulseTime) / PULSE_INTERVAL % 1;
end

local manaData = {
    unit = "player",
    pulseTime = 0,
    nextPulseTime = 0,
    mana = 0,
};

local function findManaPulseProgress(data, onCastSucc)
    local PULSE_COOLDOWN = 5;
    local PULSE_INTERVAL = 2;
    local PULSE_MAX_INTERVAL = (math.ceil(PULSE_COOLDOWN / PULSE_INTERVAL) + 1) * PULSE_INTERVAL;

    local now = GetTime();
    local mana = UnitPower(data.unit, Enum.PowerType.Mana);

    if (mana > data.mana) then
        -- increased mana, is it a pulse?
        local baseRegen, castRegen = CharacterBook.getManaRegenPerPulse();
        if (baseRegen > 0) then
            local regen = baseRegen + castRegen;
            local diff = mana - data.mana;
            if (diff > regen - 1 and diff < regen + 1) then
                data.pulseTime = now;
            end
        end
    elseif (onCastSucc and mana < data.mana) then
        -- mp consumed, start cooldown
        local sinceLastPulse = (now - data.pulseTime) % PULSE_INTERVAL;
        local pulseInterval = math.ceil((sinceLastPulse + PULSE_COOLDOWN) / PULSE_INTERVAL) * PULSE_INTERVAL;
        local lastPulseTimeAsIf = now - sinceLastPulse - (PULSE_MAX_INTERVAL - pulseInterval);
        data.pulseTime = lastPulseTimeAsIf;
        data.nextPulseTime = lastPulseTimeAsIf + PULSE_MAX_INTERVAL;
    end
    data.mana = mana;

    if (now < data.nextPulseTime) then
        return (now - data.pulseTime) / PULSE_MAX_INTERVAL;
    else
        return (now - data.pulseTime) / PULSE_INTERVAL % 1;
    end
end

--------

local f = CreateFrame("Frame", nil, PlayerFrameManaBar, nil);
f:SetAllPoints();

f.energyData = energyData;
f.manaData = manaData;

f.spark = f:CreateTexture(nil, "OVERLAY");
f.spark:SetTexture("Interface/CastingBar/UI-CastingBar-Spark");
f.spark:SetSize(6, 18);
f.spark:SetBlendMode("ADD");

f:SetScript("OnUpdate", function(self, elapsed)
    local powerType = UnitPowerType("player");
    if (powerType == Enum.PowerType.Energy) then
        local energyProgress = findEnergyPulseProgress(self.energyData);
        self.spark:ClearAllPoints();
        self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * energyProgress, 0);
        self.spark:Show();
    elseif (powerType == Enum.PowerType.Mana) then
        local manaProgress = findManaPulseProgress(self.manaData, false);
        self.spark:ClearAllPoints();
        self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * manaProgress, 0);
        self.spark:Show();
    else
        self.spark:Hide();
    end
end);

if (isMpClass) then
    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "UNIT_SPELLCAST_SUCCEEDED") then
            findManaPulseProgress(self.manaData, true);
        end
    end);
end
