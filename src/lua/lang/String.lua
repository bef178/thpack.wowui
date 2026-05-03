local Array = Array

String = (function()
    local String = {}

    function String.indexOf(s, pattern, from)
        return string.find(s, pattern, from, true)
    end

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
            -- on vanilla, `unpack` does not take the 2nd parameter
            Array.remove(a, 1)
            Array.remove(a, 1)
            return unpack(a)
        end
        return string.sub(s, a[1], a[2])
    end

    function String.substring(s, i, j)
        return string.sub(s, i, j)
    end

    function String.split(s, pattern, from)
        from = from or 1
        if from < 0 then
            from = sLen + from + 1
        end
        if from < 1 then
            -- [1, 10], -1000 => 1
            from = 1
        end

        local sLen = string.len(s)
        local patternLen = string.len(pattern)

        if patternLen == 0 then
            local a = {}
            for i = from, sLen do
                Array.add(a, string.sub(s, i, i))
            end
            return a
        end

        local sBytes = {}
        for i = 1, sLen do
            sBytes[i] = string.sub(s, i, i)
        end
        local patternBytes = {}
        for i = 1, patternLen do
            patternBytes[i] = string.sub(pattern, i, i)
        end

        local a = {}
        local i = from
        while i <= sLen - patternLen + 1 do
            local matched = true
            for j = 1, patternLen do
                if sBytes[i + j - 1] ~= patternBytes[j] then
                    matched = false
                    break
                end
            end
            if matched then
                Array.add(a, string.sub(s, from, i - 1))
                from = i + patternLen
                i = from
            else
                i = i + 1
            end
        end
        Array.add(a, string.sub(s, from))
        return a
    end

    function String.trim(s)
        return string.gsub(s, "^%s*(.-)%s*$", "%1")
    end

    function String.toLower(s)
        return string.lower(s)
    end

    function String.toUpper(s)
        return string.upper(s)
    end

    return String
end)()
