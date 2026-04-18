Map = (function()
    local Map = {}

    function Map.clear(m)
        for k in next, m do
            rawset(m, k, nil)
        end
    end

    function Map.containsKey(m, key)
        return m[key] ~= nil
    end

    function Map.containsValue(m, value)
        for k, v in pairs(m) do
            if (v == value) then
                return true
            end
        end
        return false
    end

    function Map.keys(m)
        local keys = {}
        for k, v in pairs(m) do
            table.insert(keys, k)
        end
        return keys
    end

    function Map.merge(m, m1)
        if (type(m1) ~= "table") then
            error("InvalidArgumentException")
        end
        for k1, v1 in pairs(m1) do
            if (m[k1] == nil) then
                m[k1] = v1
            end
        end
        return m
    end

    function Map.size(m)
        local n = 0
        for k, v in pairs(m) do
            n = n + 1
        end
        return n
    end

    return Map
end)()
