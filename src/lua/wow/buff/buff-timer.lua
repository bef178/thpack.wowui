local hookGlobalFunction = Util.hookGlobalFunction
local buildTimeString = Util.buildTimeString

local function updateBuffTimer(buffButton, remainingSeconds)
    if SHOW_BUFF_DURATIONS ~= "1" then
        return
    end

    if not remainingSeconds then
        return
    end

    local timeString = buildTimeString(remainingSeconds)
    if not timeString then
        return
    end

    local textRegion = _G[buffButton:GetName() .. "Duration"]
    textRegion:SetFont(STANDARD_TEXT_FONT, 12)
    textRegion:SetText(timeString)
end

if hooksecurefunc and AuraButton_UpdateDuration then
    hooksecurefunc("AuraButton_UpdateDuration", updateBuffTimer)
end

if BuffFrame_UpdateDuration then
    hookGlobalFunction("BuffFrame_UpdateDuration", "post_hook", updateBuffTimer)
end
