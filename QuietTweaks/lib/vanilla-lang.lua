-- I believe wow vanilla uses lua 5.0

if (not _G and setglobal) then
    setglobal('_G', getfenv(0));
end

if (not _G.select) then
    _G.select = function(n, ...)
        if (n == "#") then
            return table.getn(arg);
        end

        n = tonumber(n);
        if (not n) then
            error("InvalidArgumentException");
        end

        if (n <= 0) then
            error("IndexOutOfBoundsException");
        end

        for i = 1, n - 1 do
            table.remove(arg, 1);
        end
        return unpack(arg);
    end
end

------------------------------------------------------------

String = String or {};

String.join = String.join or function(sep, ...)
    local s = arg[1];
    for i = 2, table.getn(arg), 1 do
        s = s .. sep .. arg[i];
    end
    return s;
end;

String.match = String.match or function(s, pattern, startIndex)
    local matchStart, matchEnd, capture = string.find(s, pattern, startIndex);
    if (not matchStart) then
        return;
    end

    if (capture) then
        return capture;
    end
    return string.sub(s, matchStart, matchEnd);
end;

String.substring = String.substring or function(s, i, j)
    return string.sub(s, i, j);
end;

String.split = String.split or function(s, pattern)
    local startIndex = 1;
    local a = {};
    while (true) do
        local endIndex = string.find(s, pattern, startIndex, true);
        if (endIndex == nil) then
            local s1 = String.substring(s, startIndex);
            Array.add(a, s1);
            break;
        end
        local s1 = String.substring(s, startIndex, endIndex - 1);
        Array.add(a, s1);
        startIndex = endIndex + string.len(pattern);
    end
    return a;
end;

String.trim = String.trim or function(s)
    return string.gsub(s, '^%s*(.-)%s*$', '%1')
end;

String.toLower = function(s)
    return string.lower(s);
end;

String.toUpper = function(s)
    return string.upper(s);
end;

------------------------------------------------------------

Map = Map or {};

Map.clear = Map.clear or function(m)
    for k in next, m do
        rawset(m, k, nil);
    end
end;

Map.containsKey = Map.containsKey or function(m, key)
    return m[key] ~= nil;
end;

Map.containsValue = Map.containsValue or function(m, value)
    for k, v in pairs(m) do
        if (v == value) then
            return true;
        end
    end
    return false;
end;

Map.keys = Map.keys or function(m)
    local keys = {};
    for k, v in pairs(m) do
        table.insert(keys, k);
    end
    return keys;
end;

Map.merge = Map.merge or function(m, m1)
    if (type(m1) ~= "table") then
        error("InvalidArgumentException");
    end
    for k, v in pairs(m1) do
        if (m[k] == nil) then
            m[k] = v;
        end
    end
end;

Map.size = Map.size or function(m)
    local n = 0;
    for k, v in pairs(m) do
        n = n + 1;
    end
    return n;
end;

------------------------------------------------------------

Array = Array or {};

Array.add = Array.add or function(a, value)
    table.insert(a, value);
end;

Array.clear = Array.clear or function(a)
    for i = Array.size(a), 1, -1 do
        Array.remove(a, i);
    end
end;

Array.contains = Array.contains or function(a, value)
    for i, v in ipairs(a) do
        if (v == value) then
            return true;
        end
    end
    return false;
end;

Array.insert = Array.insert or function(a, index, value)
    table.insert(a, index, value);
end;

Array.map = Array.map or function(a, func)
    local a1 = {};
    for i, v in ipairs(a) do
        Array.add(a1, func(v, i, a));
    end
    return a1;
end;

-- concat
Array.merge = Array.merge or function(a, a1)
    for i, v1 in ipairs(a1) do
        table.insert(a, v1);
    end
end;

Array.remove = Array.remove or function(a, index)
    table.remove(a, index);
end;

Array.size = Array.size or function(a)
    return table.getn(a);
end;

------------------------------------------------------------

Math = Math or {};

Math.min = function(a, b)
    return a <= b and a or b;
end;

Math.modf = Math.modf or function(number)
    local fraction = math.mod(number, 1)
    return number - fraction, fraction
end;

-- e.g. round(0.1234567, 0.000001) => 0.123457
Math.round = Math.round or function(number, measurement)
    if (not number or not measurement) then
        error("InvalidArgumentException");
    end
    return math.floor(number / measurement + 0.5) * measurement
end;
