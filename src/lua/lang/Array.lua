Array = (function()
    local Array = {}

    function Array.add(a, value)
        table.insert(a, value)
    end

    function Array.addAll(a, a1)
        for i, v1 in ipairs(a1) do
            Array.add(a, v1)
        end
        return a
    end

    function Array.insert(a, index, value)
        table.insert(a, index, value)
    end

    function Array.remove(a, index)
        return table.remove(a, index)
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

    function Array.size(a)
        return table.getn(a)
    end

    function Array.join(a, separatorString)
        return table.concat(a, separatorString)
    end

    function Array.map(a, func)
        local a1 = {}
        for i, v in ipairs(a) do
            Array.add(a1, func(v, i, a))
        end
        return a1
    end

    return Array
end)()
