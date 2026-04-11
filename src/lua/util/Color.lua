Color = (function()
    local w3cExtendedColors = {
        transparent = "#00000000",
        aliceblue = "#F0F8FF",
        antiquewhite = "#FAEBD7",
        aqua = "#00FFFF",
        aquamarine = "#7FFFD4",
        azure = "#F0FFFF",
        beige = "#F5F5DC",
        bisque = "#FFE4C4",
        black = "#000000",
        blanchedalmond = "#FFEBCD",
        blue = "#0000FF",
        blueviolet = "#8A2BE2",
        brown = "#A52A2A",
        burlywood = "#DEB887",
        cadetblue = "#5F9EA0",
        chartreuse = "#7FFF00",
        chocolate = "#D2691E",
        coral = "#FF7F50",
        cornflowerblue = "#6495ED",
        cornsilk = "#FFF8DC",
        crimson = "#DC143C",
        cyan = "#00FFFF",
        darkblue = "#00008B",
        darkcyan = "#008B8B",
        darkgoldenrod = "#B8860B",
        darkgray = "#A9A9A9",
        darkgreen = "#006400",
        darkgrey = "#A9A9A9",
        darkkhaki = "#BDB76B",
        darkmagenta = "#8B008B",
        darkolivegreen = "#556B2F",
        darkorange = "#FF8C00",
        darkorchid = "#9932CC",
        darkred = "#8B0000",
        darksalmon = "#E9967A",
        darkseagreen = "#8FBC8F",
        darkslateblue = "#483D8B",
        darkslategray = "#2F4F4F",
        darkslategrey = "#2F4F4F",
        darkturquoise = "#00CED1",
        darkviolet = "#9400D3",
        deeppink = "#FF1493",
        deepskyblue = "#00BFFF",
        dimgray = "#696969",
        dimgrey = "#696969",
        dodgerblue = "#1E90FF",
        firebrick = "#B22222",
        floralwhite = "#FFFAF0",
        forestgreen = "#228B22",
        fuchsia = "#FF00FF",
        gainsboro = "#DCDCDC",
        ghostwhite = "#F8F8FF",
        gold = "#FFD700",
        goldenrod = "#DAA520",
        gray = "#808080",
        green = "#008000",
        greenyellow = "#ADFF2F",
        grey = "#808080",
        honeydew = "#F0FFF0",
        hotpink = "#FF69B4",
        indianred = "#CD5C5C",
        indigo = "#4B0082",
        ivory = "#FFFFF0",
        khaki = "#F0E68C",
        lavender = "#E6E6FA",
        lavenderblush = "#FFF0F5",
        lawngreen = "#7CFC00",
        lemonchiffon = "#FFFACD",
        lightblue = "#ADD8E6",
        lightcoral = "#F08080",
        lightcyan = "#E0FFFF",
        lightgoldenrodyellow = "#FAFAD2",
        lightgray = "#D3D3D3",
        lightgreen = "#90EE90",
        lightgrey = "#D3D3D3",
        lightpink = "#FFB6C1",
        lightsalmon = "#FFA07A",
        lightseagreen = "#20B2AA",
        lightskyblue = "#87CEFA",
        lightslategray = "#778899",
        lightslategrey = "#778899",
        lightsteelblue = "#B0C4DE",
        lightyellow = "#FFFFE0",
        lime = "#00FF00",
        limegreen = "#32CD32",
        linen = "#FAF0E6",
        magenta = "#FF00FF",
        maroon = "#800000",
        mediumaquamarine = "#66CDAA",
        mediumblue = "#0000CD",
        mediumorchid = "#BA55D3",
        mediumpurple = "#9370DB",
        mediumseagreen = "#3CB371",
        mediumslateblue = "#7B68EE",
        mediumspringgreen = "#00FA9A",
        mediumturquoise = "#48D1CC",
        mediumvioletred = "#C71585",
        midnightblue = "#191970",
        mintcream = "#F5FFFA",
        mistyrose = "#FFE4E1",
        moccasin = "#FFE4B5",
        navajowhite = "#FFDEAD",
        navy = "#000080",
        oldlace = "#FDF5E6",
        olive = "#808000",
        olivedrab = "#6B8E23",
        orange = "#FFA500",
        orangered = "#FF4500",
        orchid = "#DA70D6",
        palegoldenrod = "#EEE8AA",
        palegreen = "#98FD98",
        paleturquoise = "#AFEEEE",
        palevioletred = "#DB7093",
        papayawhip = "#FFEFD5",
        peachpuff = "#FFDAB9",
        peru = "#CD853F",
        pink = "#FFC0CD",
        plum = "#DDA0DD",
        powderblue = "#B0E0E6",
        purple = "#800080",
        red = "#FF0000",
        rosybrown = "#BC8F8F",
        royalblue = "#4169E1",
        saddlebrown = "#8B4513",
        salmon = "#FA8072",
        sandybrown = "#F4A460",
        seagreen = "#2E8B57",
        seashell = "#FFF5EE",
        sienna = "#A0522D",
        silver = "#C0C0C0",
        skyblue = "#87CEEB",
        slateblue = "#6A5ACD",
        slategray = "#708090",
        slategrey = "#708090",
        snow = "#FFFAFA",
        springgreen = "#00FF7F",
        steelblue = "#4682B4",
        tan = "#D2B48C",
        teal = "#008080",
        thistle = "#D8BFD8",
        tomato = "#FF6347",
        turquoise = "#40E0D0",
        violet = "#EE82EE",
        wheat = "#F5DEB3",
        white = "#FFFFFF",
        whitesmoke = "#F5F5F5",
        yellow = "#FFFF00",
        yellowgreen = "#9ACD32"
    };

    local ansiColorCodes = {
        ["transparent"] = "#00000000",
        ["black"] = "#000000",
        ["red"] = "#FF0000",
        ["green"] = "#00FF00",
        ["blue"] = "#0000FF",
        ["yellow"] = "#FFFF00",
        ["magenta"] = "#FF00FF",
        ["cyan"] = "#00FFFF",
        ["white"] = "#FFFFFF"
    };

    local htmlColorCodes = {
        -- Red color names
        ["IndianRed"] = "#CD5C5C",
        ["LightCoral"] = "#F08080",
        ["Salmon"] = "#FA8072",
        ["DarkSalmon"] = "#E9967A",
        ["Crimson"] = "#DC143C",
        ["Red"] = "#FF0000",
        ["FireBrick"] = "#B22222",
        ["DarkRed"] = "#8B0000",

        -- Pink color names
        ["Pink"] = "#FFC0CB",
        ["LightPink"] = "#FFB6C1",
        ["HotPink"] = "#FF69B4",
        ["DeepPink"] = "#FF1493",
        ["MediumVioletRed"] = "#C71585",
        ["PaleVioletRed"] = "#DB7093",

        -- Orange color names
        ["LightSalmon"] = "#FFA07A",
        ["Coral"] = "#FF7F50",
        ["Tomato"] = "#FF6347",
        ["OrangeRed"] = "#FF4500",
        ["DarkOrange"] = "#FF8C00",
        ["Orange"] = "#FFA500",

        -- Yellow color names
        ["Gold"] = "#FFD700",
        ["Yellow"] = "#FFFF00",
        ["LightYellow"] = "#FFFFE0",
        ["LemonChiffon"] = "#FFFACD",
        ["LightGoldenrodYellow"] = "#FAFAD2",
        ["PapayaWhip"] = "#FFEFD5",
        ["Moccasin"] = "#FFE4B5",
        ["PeachPuff"] = "#FFDAB9",
        ["PaleGoldenrod"] = "#EEE8AA",
        ["Khaki"] = "#F0E68C",
        ["DarkKhaki"] = "#BDB76B",

        -- Purple color names
        ["Lavender"] = "#E6E6FA",
        ["Thistle"] = "#D8BFD8",
        ["Plum"] = "#DDA0DD",
        ["Violet"] = "#EE82EE",
        ["Orchid"] = "#DA70D6",
        ["Fuchsia"] = "#FF00FF",
        ["Magenta"] = "#FF00FF",
        ["MediumOrchid"] = "#BA55D3",
        ["MediumPurple"] = "#9370DB",
        ["Amethyst"] = "#9966CC",
        ["BlueViolet"] = "#8A2BE2",
        ["DarkViolet"] = "#9400D3",
        ["DarkOrchid"] = "#9932CC",
        ["DarkMagenta"] = "#8B008B",
        ["Purple"] = "#800080",
        ["Indigo"] = "#4B0082",
        ["SlateBlue"] = "#6A5ACD",
        ["DarkSlateBlue"] = "#483D8B",
        ["MediumSlateBlue"] = "#7B68EE",

        -- Green color names
        ["GreenYellow"] = "#ADFF2F",
        ["Chartreuse"] = "#7FFF00",
        ["LawnGreen"] = "#7CFC00",
        ["Lime"] = "#00FF00",
        ["LimeGreen"] = "#32CD32",
        ["PaleGreen"] = "#98FB98",
        ["LightGreen"] = "#90EE90",
        ["MediumSpringGreen"] = "#00FA9A",
        ["SpringGreen"] = "#00FF7F",
        ["MediumSeaGreen"] = "#3CB371",
        ["SeaGreen"] = "#2E8B57",
        ["ForestGreen"] = "#228B22",
        ["Green"] = "#008000",
        ["DarkGreen"] = "#006400",
        ["YellowGreen"] = "#9ACD32",
        ["OliveDrab"] = "#6B8E23",
        ["Olive"] = "#808000",
        ["DarkOliveGreen"] = "#556B2F",
        ["MediumAquamarine"] = "#66CDAA",
        ["DarkSeaGreen"] = "#8FBC8F",
        ["LightSeaGreen"] = "#20B2AA",
        ["DarkCyan"] = "#008B8B",
        ["Teal"] = "#008080",

        -- Blue color names
        ["Aqua"] = "#00FFFF",
        ["Cyan"] = "#00FFFF",
        ["LightCyan"] = "#E0FFFF",
        ["PaleTurquoise"] = "#AFEEEE",
        ["Aquamarine"] = "#7FFFD4",
        ["Turquoise"] = "#40E0D0",
        ["MediumTurquoise"] = "#48D1CC",
        ["DarkTurquoise"] = "#00CED1",
        ["CadetBlue"] = "#5F9EA0",
        ["SteelBlue"] = "#4682B4",
        ["LightSteelBlue"] = "#B0C4DE",
        ["PowderBlue"] = "#B0E0E6",
        ["LightBlue"] = "#ADD8E6",
        ["SkyBlue"] = "#87CEEB",
        ["LightSkyBlue"] = "#87CEFA",
        ["DeepSkyBlue"] = "#00BFFF",
        ["DodgerBlue"] = "#1E90FF",
        ["CornflowerBlue"] = "#6495ED",
        ["RoyalBlue"] = "#4169E1",
        ["Blue"] = "#0000FF",
        ["MediumBlue"] = "#0000CD",
        ["DarkBlue"] = "#00008B",
        ["Navy"] = "#000080",
        ["MidnightBlue"] = "#191970",

        -- Brown color names
        ["Cornsilk"] = "#FFF8DC",
        ["BlanchedAlmond"] = "#FFEBCD",
        ["Bisque"] = "#FFE4C4",
        ["NavajoWhite"] = "#FFDEAD",
        ["Wheat"] = "#F5DEB3",
        ["BurlyWood"] = "#DEB887",
        ["Tan"] = "#D2B48C",
        ["RosyBrown"] = "#BC8F8F",
        ["SandyBrown"] = "#F4A460",
        ["Goldenrod"] = "#DAA520",
        ["DarkGoldenrod"] = "#B8860B",
        ["Peru"] = "#CD853F",
        ["Chocolate"] = "#D2691E",
        ["SaddleBrown"] = "#8B4513",
        ["Sienna"] = "#A0522D",
        ["Brown"] = "#A52A2A",
        ["Maroon"] = "#800000",

        -- White color names
        ["White"] = "#FFFFFF",
        ["Snow"] = "#FFFAFA",
        ["Honeydew"] = "#F0FFF0",
        ["MintCream"] = "#F5FFFA",
        ["Azure"] = "#F0FFFF",
        ["AliceBlue"] = "#F0F8FF",
        ["GhostWhite"] = "#F8F8FF",
        ["WhiteSmoke"] = "#F5F5F5",
        ["Seashell"] = "#FFF5EE",
        ["Beige"] = "#F5F5DC",
        ["OldLace"] = "#FDF5E6",
        ["FloralWhite"] = "#FFFAF0",
        ["Ivory"] = "#FFFFF0",
        ["AntiqueWhite"] = "#FAEBD7",
        ["Linen"] = "#FAF0E6",
        ["LavenderBlush"] = "#FFF0F5",
        ["MistyRose"] = "#FFE4E1",

        -- Grey color names
        ["Gainsboro"] = "#DCDCDC",
        ["LightGrey"] = "#D3D3D3",
        ["Silver"] = "#C0C0C0",
        ["DarkGray"] = "#A9A9A9",
        ["Gray"] = "#808080",
        ["DimGray"] = "#696969",
        ["LightSlateGray"] = "#778899",
        ["SlateGray"] = "#708090",
        ["DarkSlateGray"] = "#2F4F4F",
        ["Black"] = "#000000"
    };

    local heroClassColors = {
        ["DEATHKNIGHT"] = "#c31d39",
        ["DEMONHUNTER"] = "#a22fc8",
        ["DRUID"] = "#fe7b09",
        ["HUNTER"] = "#a9d271",
        ["MAGE"] = "#3ec5e9",
        ["MONK"] = "#00fe95",
        ["PALADIN"] = "#f38bb9",
        ["PRIEST"] = "#fefefe",
        ["ROGUE"] = "#fef367",
        ["SHAMAN"] = "#006fdc",
        ["WARLOCK"] = "#8686ec",
        ["WARRIOR"] = "#c59a6c"
    };

    -- color string default to rrggbbaa
    -- r/g/b default to 0x00 but `a` default to 0xFF
    local Color = {};

    function Color.toInt24(s)
        if s == nil or type(s) ~= "string" or string.sub(s, 1, 1) ~= "#" then
            return;
        end
        local r8 = tonumber(string.sub(s, 2, 3), 16);
        local g8 = tonumber(string.sub(s, 4, 5), 16);
        local b8 = tonumber(string.sub(s, 6, 7), 16);
        return r8 * 256 * 256 + g8 * 256 + b8;
    end

    local function align33(i)
        local index = i / 51;
        if (index >= 4.5) then
            return 255;
        else
            return math.floor(index + 0.5) * 51;
        end
    end

    function Color.toWebSafe(s)
        local r8, g8, b8, a8 = Color.toRgba(s)
        return Color.fromRgba(align33(r8), align33(g8), align33(b8), align33(a8))
    end

    function Color.fromRgba(r8, g8, b8, a8)
        local s = nil
        if (r8 >= 0 and r8 <= 255 and g8 >= 0 and g8 <= 255 and b8 >= 0 and b8 <= 255) then
            s = string.format("#%02x%02x%02x", r8, g8, b8)
        else
            return
        end
        if (a8 ~= nil) then
            if (a8 >= 0 and a8 <= 255) then
                s = s .. string.format("%02x", a8)
            else
                return
            end
        end
        return s
    end

    -- e.g. "#FF0000" => 255, 0, 0, 255
    function Color.toRgba(s)
        if s == nil or string.sub(s, 1, 1) ~= "#" then
            return
        end
        local r8 = tonumber(string.sub(s, 2, 3), 16)
        local g8 = tonumber(string.sub(s, 4, 5), 16)
        local b8 = tonumber(string.sub(s, 6, 7), 16)
        local a8 = tonumber(string.sub(s, 8, 9), 16) or 255
        return r8, g8, b8, a8;
    end

    function Color.fromVertex(r, g, b, a)
        local r8 = math.floor(r * 255 + 0.5)
        local g8 = math.floor(g * 255 + 0.5)
        local b8 = math.floor(b * 255 + 0.5)
        local a8 = a and math.floor(a * 255 + 0.5)
        return Color.fromRgba(r8, g8, b8, a8)
    end

    -- e.g. "#FF0000FF" => 1, 0, 0, 1
    function Color.toVertex(s)
        if s == nil or string.sub(s, 1, 1) ~= "#" then
            return
        end
        local r8, g8, b8, a8 = Color.toRgba(s);
        return r8 / 255, g8 / 255, b8 / 255, a8 / 255;
    end

    Color.pick = function(s)
        if s == nil then
            return
        end
        return w3cExtendedColors[String.toLower(s)] or htmlColorCodes[s] or heroClassColors[s];
    end

    return Color
end)()
