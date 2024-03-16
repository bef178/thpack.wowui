array = array or {};

array.merge = function(a, a1)
    for _, v1 in ipairs(a1) do
        array.insert(a, v1);
    end
    return a;
end;

array.contains = function(a, value)
    for i, v in ipairs(a) do
        if (v == value) then
            return true;
        end
    end
    return false;
end;

array.foreach = function(a, callback)
    for i, v in ipairs(a) do
        callback(i, v);
    end
end;

array.insert = table.insert;

array.remove = table.remove;

array.clear = table.clear;

array.size = function(a)
    return #a;
end;
