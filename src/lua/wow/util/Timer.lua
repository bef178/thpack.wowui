local GetTime = GetTime

Timer = (function()
    local Timer = Proto.newProto(nil, function(o, f)
        o._data = nil
        if not f then
            f = CreateFrame("Frame")
        end
        o._f = f
        o._f:Hide()
        o._f:SetScript("OnUpdate", function()
            local data = o._data
            if not data then
                o._f:Hide()
                return
            end
            local elapsedSeconds = GetTime() - data.t0
            local isEnd = data.stopRequested or elapsedSeconds > data.totalSeconds
            if isEnd then
                o._data = nil
                o._f:Hide()
            end
            if data.onTick then
                data.onTick(elapsedSeconds / data.totalSeconds, elapsedSeconds, isEnd)
            end
        end)
    end)

    -- restarting before prev completion will skip the prev onTick(isEnd=true) callback
    function Timer:start(totalSeconds, onTick)
        local now = GetTime()
        self._data = {
            totalSeconds = totalSeconds,
            t0 = now,
            onTick = onTick
        }
        self._f:Show()
    end

    function Timer:stop()
        if self._data then
            self._data.stopRequested = true
        end
    end

    function Timer:isRunning()
        return self._data ~= nil
    end

    return Timer
end)()
