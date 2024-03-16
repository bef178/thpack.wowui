table = table or {};

table.clear = function(o)
    for k in next, o do
        rawset(o, k, nil);
    end
    return o;
end;

table.containsKey = function(o, key)
    return o[key] ~= nil;
end;

table.containsValue = function(o, value)
    for i, v in pairs(o) do
        if (v == value) then
            return true;
        end
    end
    return false;
end;

table.getOrAdd = function(o, key, value)
    if (o[key] == nil) then
        o[key] = value;
    end
    return o[key];
end;

table.keys = function(o)
    local keys = {};
    for k, v in pairs(o) do
        table.insert(keys, k);
    end
    return keys;
end;

table.merge = function(o, o1)
    if type(o1) ~= "table" then
        error("E: invalid argument: expect a table");
    end
    for k, v in pairs(o1) do
        if o[k] == nil then
            o[k] = v;
        end
    end
    return o;
end;

table.size = function(o)
    local n = 0;
    for k, v in pairs(o) do
        n = n + 1;
    end
    return n;
end;
