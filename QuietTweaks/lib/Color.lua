Color = Color or (function()

    local Color = {};

    function Color.fromVertex(r, g, b, a)
        local r8 = math.floor(r * 255);
        local g8 = math.floor(g * 255);
        local b8 = math.floor(b * 255);
        local a8 = a and math.floor(a * 255) or 255;
        return string.format("#%02x%02x%02x%02x", r8, g8, b8, a8);
    end

    function Color.toVertex(colorString)
        if (not colorString) then
            return;
        end
        local r8 = tonumber(String.substring(colorString, 2, 3), 16);
        local g8 = tonumber(String.substring(colorString, 4, 5), 16);
        local b8 = tonumber(String.substring(colorString, 6, 7), 16);
        local a8 = tonumber(String.substring(colorString, 8, 9), 16);
        return r8 / 255, g8 / 255, b8 / 255, a8 / 255;
    end

    return Color;
end)();
