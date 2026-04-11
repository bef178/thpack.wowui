String = (function()
    local String = {}

    function String.join(sep, ...)
        local s = arg[1]
        for i = 2, table.getn(arg), 1 do
            s = s .. sep .. arg[i]
        end
        return s
    end

    function String.match(s, pattern, startIndex)
        -- matchStart, matchEnd, capture1, capture2, ... captureN
        local a = {string.find(s, pattern, startIndex)}
        if a[1] == nil then
            return nil
        end
        if a[3] then
            return unpack(a, 3)
        end
        return string.sub(s, a[1], a[2])
    end

    function String.substring(s, i, j)
        return string.sub(s, i, j)
    end

    function String.split(s, pattern)
        local startIndex = 1
        local a = {}
        while true do
            local endIndex = string.find(s, pattern, startIndex, true)
            if endIndex == nil then
                local s1 = String.substring(s, startIndex)
                Array.add(a, s1)
                break
            end
            local s1 = String.substring(s, startIndex, endIndex - 1)
            Array.add(a, s1)
            startIndex = endIndex + string.len(pattern)
        end
        return a
    end

    function String.trim(s)
        return string.gsub(s, '^%s*(.-)%s*$', '%1')
    end

    function String.toLower(s)
        return string.lower(s)
    end

    function String.toUpper(s)
        return string.upper(s)
    end

    return String
end)()
