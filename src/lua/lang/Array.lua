Array = (function()
    local Array = {}

    function Array.add(a, value)
        table.insert(a, value)
    end

    function Array.clear(a)
        for i = Array.size(a), 1, -1 do
            Array.remove(a, i)
        end
    end

    function Array.contains(a, value)
        for i, v in ipairs(a) do
            if (v == value) then
                return true
            end
        end
        return false
    end

    function Array.insert(a, index, value)
        table.insert(a, index, value)
    end

    function Array.map(a, func)
        local a1 = {}
        for i, v in ipairs(a) do
            Array.add(a1, func(v, i, a))
        end
        return a1
    end

    -- concat
    function Array.merge(a, a1)
        for i, v1 in ipairs(a1) do
            table.insert(a, v1)
        end
    end

    function Array.remove(a, index)
        table.remove(a, index)
    end

    function Array.size(a)
        return table.getn(a)
    end

    return Array
end)()
