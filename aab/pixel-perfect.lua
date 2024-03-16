-- pixel perfect
(function()

    WTF = WTF or {}; -- used to be saved variables

    local function getClientResolution()
        if (WTF and WTF.clientResolution) then
            local clientResolution = WTF.clientResolution;
            return clientResolution, "loaded";
        end

        local clientResolution = nil;
        if (GetCurrentResolution) then
            local i = GetCurrentResolution();
            if (i and i > 0) then
                local allResolutions = {GetScreenResolutions()};
                clientResolution = allResolutions[i];
            end
        end

        if (not clientResolution) then
            -- clientResolution = GetCVar("gxWindowedResolution");
        end

        if (not clientResolution) then
            clientResolution = GetCVar("gxResolution");
        end

        return clientResolution, "detected";
    end

    local function findProperScale(clientHeightInPixels)
        if (not clientHeightInPixels) then
            return;
        end

        -- keep 6 digits after the decimal point
        local function round6(number)
            return math.floor(number * 1000000 + 0.5) / 1000000;
        end

        -- fact: client area is actually 768/scale points
        -- fact: client area is forced aspect ratio of 1024:768, based on height
        -- thus: clientHeightInPixels == numPixelsPerPoint * (768 / scale)
        -- expect: numPixelsPerPoint is 1 or 2

        local expectedPixelsPerPoint;
        if (clientHeightInPixels == 1440) then
            -- expectedPixelsPerPoint = 1.6875; -- scale == 0.9
            return;
        else
            expectedPixelsPerPoint = math.floor(clientHeightInPixels / 768 + 0.1);
            if (expectedPixelsPerPoint < 1) then
                expectedPixelsPerPoint = 1;
            end
        end

        local scaleToSet = expectedPixelsPerPoint * 768 / clientHeightInPixels
        local pointsPerPx = round6(1 / expectedPixelsPerPoint);

        -- clientHeight = 1024 dp;
        -- pointsPerDp = 768 / scaleToSet / 1024
        --  = 768 / (expectedNumPixelsPerPoint * 768 / clientHeightInPixels) / 1024
        --  = 1 / expectedNumPixelsPerPoint * clientHeightInPixels / 1024
        --  = clientHeightInPixels / expectedNumPixelsPerPoint / 1024
        local pointsPerDp = round6(clientHeightInPixels / expectedPixelsPerPoint / 1024);

        return scaleToSet, expectedPixelsPerPoint, pointsPerPx, pointsPerDp;
    end

    local function setup()
        local function getHeightFromResolution(resolution)
            local g = {string.find(resolution, "%d+x(%d+)")};
            return g and g[3] and tonumber(g[3]);
        end

        local clientResolution, source = getClientResolution();
        A.logi(string.format("Resolution [%s] %s. (see %s)", clientResolution, source, "/resolution"));

        local clientHeightInPixels = getHeightFromResolution(clientResolution);
        local scale, pixelsPerPoint, pointsPerPx, pointsPerDp = findProperScale(clientHeightInPixels);

        if (scale) then
            SetCVar("useUiScale", 0); -- uiScale must be in [0.64, 1] so discarded
            A.logi(string.format("Setting scale to %.06f i.e. 1 point = %d pixel(s)", scale, pixelsPerPoint));
            UIParent:SetScale(scale);

            A.px = pointsPerPx;
            A.px2point = function(numPx)
                return numPx * pointsPerPx;
            end;

            A.dp = pointsPerDp;
            A.dp2point = function(numDp)
                return numDp * pointsPerDp;
            end;
        end
    end

    -- extra command for user to force his client resolution
    -- this is necessary for those mods using A.px or A.dp
    A.addSlashCommand("aClientResolution", "/resolution", function(x)
        if (x == nil or x == "") then
            A.logi("Pixel-perfect depends on correct resolution.");
            A.logi("  e.g. /resolution reset");
            A.logi("  e.g. /resolution 1024x768");
        elseif (x == "unset" or x == "reset" or x == "clear" or x == "nil") then
            if (not WTF.clientResolution) then
                A.logi("Resolution is not set yet.");
            else
                WTF.clientResolution = nil;
                A.logi("Resolution has been reset. Reload to apply.");
            end
        else
            WTF.clientResolution = x;
            A.logi(string.format("Resolution [%s] is saved. Reload to apply.", x));
        end
    end);

    local f = CreateFrame("Frame");
    -- f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("DISPLAY_SIZE_CHANGED");
    f:SetScript("OnEvent", function()
        if (event == "DISPLAY_SIZE_CHANGED") then
            setup();
        end
    end);
end)();
