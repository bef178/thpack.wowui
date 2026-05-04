local lastReportMessage = nil
local lastReportTimestamp = 0

Util.hookScript(UIErrorsFrame, "OnEvent", "hook", function(origin, ...)
    local f = UIErrorsFrame
    local eventName = event
    local message = unpack(arg)
    if eventName == "UI_ERROR_MESSAGE" then
        local now = GetTime()
        if message == lastReportMessage and now - lastReportTimestamp < 2 then
            return
        end
        lastReportMessage = message
        lastReportTimestamp = now
        -- ERR_ABILITY_COOLDOWN
        -- ERR_SPELL_COOLDOWN
        -- ERR_OUT_OF_ENERGY
        -- ERR_OUT_OF_FOCUS
        -- ERR_OUT_OF_MANA
        -- ERR_OUT_OF_RAGE
        -- ERR_OUT_OF_RANGE
    end
    origin(unpack(arg))
end)
