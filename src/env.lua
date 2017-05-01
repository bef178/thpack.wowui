T.ask("VARIABLES_LOADED").answer("env", function()

    SetCVar("screenshotQuality", 10);
    SetCVar("ShowClassColorInNameplate", 1);

    RegisterCVar("bloatnameplates", 0);
    SetCVar("bloatnameplates", 0);

    RegisterCVar("bloatthreat", 0);
    SetCVar("bloatthreat", 0);

    -- 语言过滤器
    RegisterCVar("profanityFilter", 0);
    SetCVar("profanityFilter", 0);

    RegisterCVar("targetNearestDistance", 50);
    SetCVar("targetNearestDistance", 50);

    RegisterCVar("targetNearestDistanceRadius", 50);
    SetCVar("targetNearestDistanceRadius", 50);

    RegisterCVar("CombatLogRangeCreature", 50);
    SetCVar("CombatLogRangeCreature", 50);

    RegisterCVar("CombatLogRangeHostilePlayers", 50);
    SetCVar("CombatLogRangeHostilePlayers", 50);

    RegisterCVar("taintLog", 1);
    SetCVar("taintLog", 1);

    local uiScale = 0.85;
    SetCVar("useUiScale", 1);
    SetCVar("uiScale", uiScale);

    -- I'm easily pleasured with pixel for pixel art
    -- for tooltips I like 1 px border and 1 px margin
    -- but uiScale is magic
    -- when set to 1, UIParent's height appears 768
    -- and the width is on screen aspect ratio, i.e. in 16:9 machine it is around 1366
    -- then UIParent is the *canvas*
    -- note within canvas, all number's unit is anonymous, let's say it "dot"
    -- so it comes: 768 / uiScale (dot) == physicalHeight (pixel)
    -- once upon a time physicalHeight == string.match(GetCVar("gxResolution"), "%d+x(%d+)")
    -- but now I have to ask for it
    -- although it might be too late - every frame have been settled when user types something

    -- save to wtf may work
    local physicalHeight = 1024
    if RES_HEIGHT ~= nil then
        physicalHeight = RES_HEIGHT;
    end
    L.logi("loaded screen height [" .. physicalHeight .. "]");

    _G["SLASH_thScreenHeight1"] = "/screenHeight";
    SlashCmdList["thScreenHeight"] = function(x)
        local h = math.floor(tonumber(x))
        if (h < 768) then
            L.logi("ignored invalid screen height [" .. x .. "]")
            return
        end
        RES_HEIGHT = h;
        L.logi("saved screen height [" .. h .."], reload to take effect")
    end;

    function round6(number)
        return math.floor(number * 1000000 + 0.5) / 1000000;
    end

    function dot2pixel(x)
        return physicalHeight * uiScale / 768;
    end

    function pixel2dot(x)
        -- more percisely, uiScale would be:
        -- self:GetScale() * self:GetParent():GetScale() * ... * UIParent():GetEffectiveScale()
        return 768 / (uiScale * physicalHeight);
    end

    -- sometimes I want to keep the ratio of size against the screen
    -- the ratio designed in a 1024-heighted *design canvas*
    -- thus I have to introduce the unit, name it "spot"
    function spot2dot(x)
        return 768 / (uiScale * 1024);
    end

    return {
        -- for anyone parenting to UIParent
        pixel2dot = function(x) return round6(pixel2dot(x)); end,
        dotsPerPixel = round6(pixel2dot(1)),
        dotsRelative = round6(spot2dot(1))
    };
end);
