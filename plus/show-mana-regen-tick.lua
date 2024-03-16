local POWER_TYPE_MANA = 0;
    -- 0 mana
    -- 1 rage
    -- 2 focus point
    -- 3 energy
    -- 4 happiness point

local usesMana = function()
    local powerType = UnitPowerType("player");
    local _, unitClass = UnitClass("player");
    return powerType == POWER_TYPE_MANA or unitClass == "DRUID";
end;

if (not usesMana()) then
    return;
end

local findManaPulseProgress = function(model, onCastSucc)
    local PULSE_COOLDOWN = 5;
    local PULSE_INTERVAL = 2;
    local PULSE_MAX_INTERVAL = (math.ceil(PULSE_COOLDOWN / PULSE_INTERVAL) + 1) * PULSE_INTERVAL;

    local now = GetTime();
    local mana = UnitMana(model.unit);

    if (mana > model.mana) then
        -- increased mana, is it a pulse?
        local baseRegen = A.getManaRegenPerTick();
        if (baseRegen > 0) then
            local diff = mana - model.mana;
            if (diff > baseRegen - 1 and diff < baseRegen + 1) then
                model.lastPulseTimestamp = now;
            end
        end
    elseif (onCastSucc and mana < model.mana) then
        -- mana consumed, start cooldown
        local sinceLastPulse = math.fmod(now - model.lastPulseTimestamp, PULSE_INTERVAL);
        local pulseInterval = math.ceil((sinceLastPulse + PULSE_COOLDOWN) / PULSE_INTERVAL) * PULSE_INTERVAL;
        local lastPulseTimeAsIf = now - sinceLastPulse - (PULSE_MAX_INTERVAL - pulseInterval);
        model.lastPulseTimestamp = lastPulseTimeAsIf;
        model.nextPulseTime = lastPulseTimeAsIf + PULSE_MAX_INTERVAL;
    end
    model.mana = mana;

    if (now < model.nextPulseTime) then
        return (now - model.lastPulseTimestamp) / PULSE_MAX_INTERVAL;
    else
        return math.fmod(((now - model.lastPulseTimestamp) / PULSE_INTERVAL), 1);
    end
end;

--------

local f = CreateFrame("Frame", nil, PlayerFrameManaBar, nil);
f:SetAllPoints();

f.spark = f:CreateTexture(nil, "OVERLAY");
f.spark:SetTexture("Interface/CastingBar/UI-CastingBar-Spark");
f.spark:SetWidth(6);
f.spark:SetHeight(18);
f.spark:SetBlendMode("ADD");

f.manaModel = {
    unit = "player",
    lastPulseTimestamp = 0,
    nextPulseTime = 0,
    mana = 0,
};

f:RegisterEvent("SPELLCAST_STOP");
f:SetScript("OnEvent", function()
    local self = f;
    if (event == "SPELLCAST_STOP") then
        findManaPulseProgress(self.manaModel, true);
    end
end);

f:SetScript("OnUpdate", function()
    local self = f;
    if (UnitPowerType("player") == POWER_TYPE_MANA) then
        local manaProgress = findManaPulseProgress(self.manaModel, false);
        self.spark:ClearAllPoints();
        self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * manaProgress, 0);
        self.spark:Show();
    else
        self.spark:Hide();
    end
end);
