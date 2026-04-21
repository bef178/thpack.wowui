local Array = Array
local Map = Map
local logi = Util.logi
local Timer = Timer

P = (function()
    local P = {
        _ttl = 4,
        _mods = {}, -- { name1: mod1, name2: mod2 }
        _blockerQueues = {}, -- { blockerName1: [ blockedName1, blockedName2 ] }
        -- _mayReadyQueue = {}, -- [ name1, name2 ]
        -- _loopingTimer = Timer:new(),
        _monitorTimer = Timer:new()
    }

    local mods = P._mods
    local blockerQueues = P._blockerQueues
    -- local mayReadyQueue = P._mayReadyQueue

    local genName = (function()
        local i = 0
        return function()
            i = i + 1
            return "noname-" .. i
        end
    end)()

    function P.ask(...)
        local depNames = arg
        return {
            answer = function(name, fn)
                P._register(name, fn, depNames)
            end
        }
    end

    function P._register(name, fn, depNames)
        if name == nil then
            name = genName() -- for debugging
        elseif type(name) ~= "string" then
            error(string.format("E: invalid name: string or nil expected"))
            return
        end
        if mods[name] ~= nil then
            error(string.format("E: name [%s] already exists", name))
            return
        end

        if fn ~= nil and type(fn) ~= "function" then
            error(string.format("E: invalid fn: function or nil expected"))
            return
        end

        mods[name] = {
            name = name,
            fn = fn,
            depNames = depNames or {},
            statusCode = 0, -- 0:created; 200:OK; 500:error
            result = nil
        }

        for i, depName in ipairs(depNames) do
            local q = blockerQueues[depName]
            if q == nil then
                q = {}
                blockerQueues[depName] = q
            end
            Array.add(q, name)
        end

        -- P._startLooping(name)
        P._triggerAndPropagate(name)
        P._startMonitor()
    end

    function P._startLooping(name)
        Array.add(mayReadyQueue, name)

        if P._loopingTimer:isRunning() then
            return
        end

        P._loopingTimer:interval(0.015, P._ttl, function(progress, elapsedSeconds, isEnd)
            if isEnd then
                return
            end
            P._pickAndCalculate()
        end)
    end

    function P._pickAndCalculate()
        if Array.size(mayReadyQueue) == 0 then
            return
        end

        local mod = mods[Array.remove(mayReadyQueue, 1)]

        local awakingNames = P._calculate(mod)
        if awakingNames ~= nil then
            -- notify downstream mods
            Array.addAll(mayReadyQueue, awakingNames)
        end
    end

    -- return its downstream mods if actually calculated
    function P._calculate(mod)
        if mod == nil then
            return
        end

        -- already done
        if mod.statusCode == 200 then
            return
        end

        -- collect results of upstream mods
        local depResults = {}
        for i, depName in ipairs(mod.depNames) do
            local depMod = mods[depName]
            if depMod == nil or depMod.statusCode ~= 200 then
                return
            end
            Array.add(depResults, depMod.result)
        end

        -- calculate current mod
        -- lua单线程执行，无并发，因此无法从外部中止当前的执行。监控mod执行时间无意义
        if type(mod.fn) == "function" then
            mod.result = mod.fn(unpack(depResults)) or true
        else
            mod.result = true
        end
        mod.statusCode = 200

        return Array.addAll({}, blockerQueues[mod.name] or {})
    end

    function P._triggerAndPropagate(name)
        local changed = true
        local q = {name}
        while changed do
            changed = false
            local q1 = {}
            for i, name in ipairs(q) do
                local mod = mods[name]
                local awakingNames = P._calculate(mod)
                if awakingNames ~= nil then
                    changed = true
                    Array.addAll(q1, awakingNames)
                end
            end
            q = q1
        end
    end

    function P._startMonitor()
        if (P._monitorTimer:isRunning()) then
            return
        end
        P._monitorTimer:interval(1, P._ttl, function(progress, elapsedSeconds, isEnd)
            if isEnd then
                local blockedNames = P._getBlockedNames()
                if Array.size(blockedNames) > 0 then
                    logi(string.format("W: Monitor timeout: Not executed: %s", Array.join(blockedNames, ", ")))
                end
                return
            end
            local blockedNames = P._getBlockedNames()
            if Array.size(blockedNames) > 0 then
                logi(string.format("W: Monitor: Not executed: %s", Array.join(blockedNames, ", ")))
            end
        end)
    end

    function P._getBlockedNames()
        local a = {}
        for name, _ in pairs(blockerQueues) do
            local mod = mods[name]
            if mod == nil or mod.statusCode ~= 200 then
                Array.add(a, name)
            end
        end
        return a
    end

    return P
end)()
