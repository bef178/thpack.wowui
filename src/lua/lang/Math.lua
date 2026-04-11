Math = (function()
    local Math = {}

    function Math.max(a, b)
        return a >= b and a or b
    end

    function Math.min(a, b)
        return a <= b and a or b
    end

    function Math.modf(number)
        local fraction = math.mod(number, 1)
        return number - fraction, fraction
    end

    -- e.g. round(0.1234567, 0.000001) => 0.123457
    function Math.round(number, measurement)
        if (not number or not measurement) then
            error("InvalidArgumentException")
        end
        return math.floor(number / measurement + 0.5) * measurement
    end

    return Math
end)()
