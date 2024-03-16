IntRangeExtension = {};

IntRangeExtension.getIntIntersection = function(a1, a2, b1, b2)
    local inter1 = a1 >= b1 and a1 or b1;
    local inter2 = a2 <= b2 and a2 or b2;
    if (inter1 < inter2) then
        return inter1, inter2;
    end
    return nil;
end;

IntRangeExtension.getIntSubstraction = function(a1, a2, b1, b2)
    local inter1, inter2 = IntRangeExtension.getIntIntersection(a1, a2, b1, b2);
    if (not inter1) then
        return a1, a2;
    elseif (a1 == inter1) then
        if (a2 == inter2) then
            return nil;
        else
            return inter2, a2;
        end
    elseif (a2 == inter2) then
        return a1, inter1;
    else
        return a1, inter1, inter2, a2;
    end
end;

IntRangeExtension.getIntersection = function(r1, r2)
    return IntRangeExtension.op(IntRangeExtension.getIntIntersection, r1, r2);
end;

IntRangeExtension.getSubstraction = function(r1, r2)
    return IntRangeExtension.op(IntRangeExtension.getIntSubstraction, r1, r2);
end;

IntRangeExtension.op = function(op, r1, r2)
    local ranges = {};
    for i = 1, getn(r1), 2 do
        local a1, a2, b1, b2 = op(r1[i], r1[i + 1], r2[1], r2[2]);
        if (a1) then
            table.insert(ranges, a1);
            table.insert(ranges, a2);
        end
        if (b1) then
            table.insert(ranges, b1);
            table.insert(ranges, b2);
        end
    end
    return ranges;
end;
