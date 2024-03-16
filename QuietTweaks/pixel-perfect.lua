-- pixel perfect
(function()

    WTF = WTF or {}; -- used to be saved variables

    local function getClientResolution()
        if (WTF and WTF.clientResolution) then
            local clientResolution = WTF.clientResolution;
            return clientResolution, "loaded";
        end

        local clientResolution;
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
        -- fact: client area is 768/scale points
        -- fact: client area is clientHeightInPixels pixels
        -- => (768 / scale) * pixelsPerPoint == clientHeightInPixels
        -- scale and pixelsPerPoint are related

        if (not clientHeightInPixels) then
            return;
        end

        if (clientHeightInPixels == 1440) then
            -- on 1440, if pixelsPerPoint being 1 the UI is too small while if 2 it is too large
            -- let it as it is
            -- pixelsPerPoint = 1.6875; scale == 0.9
            return;
        end

        -- expect: pixelsPerPoint is 1 or 2
        local pixelsPerPoint = math.floor(clientHeightInPixels / 768 + 0.1);
        if (pixelsPerPoint < 1) then
            pixelsPerPoint = 1;
        end

        local scale = pixelsPerPoint * 768 / clientHeightInPixels
        local pointsPerPx = Math.round(1 / pixelsPerPoint, 0.000001);

        -- clientHeight = 1024 dp;
        -- pointsPerDp = 768 / scale / 1024
        --  = 768 / (pixelsPerPoint * 768 / clientHeightInPixels) / 1024
        --  = 1 / pixelsPerPoint * clientHeightInPixels / 1024
        --  = clientHeightInPixels / pixelsPerPoint / 1024
        local pointsPerDp = Math.round(clientHeightInPixels / pixelsPerPoint / 1024, 0.000001);

        return scale, pixelsPerPoint, pointsPerPx, pointsPerDp;
    end

    local function setup()
        local function getHeightFromResolution(resolution)
            local g = {string.find(resolution, "%d+x(%d+)")};
            return g and g[3] and tonumber(g[3]);
        end

        local clientResolution, source = getClientResolution();
        A.logi(string.format("PixelPerfect: resolution [%s] %s.", clientResolution, source));

        local clientHeightInPixels = getHeightFromResolution(clientResolution);
        local scale, pixelsPerPoint, pointsPerPx, pointsPerDp = findProperScale(clientHeightInPixels);

        if (not scale) then
            A.logi("PixelPerfect: nothing to do.");
        else
            SetCVar("useUiScale", 0); -- uiScale must be in [0.64, 1] so discarded
            A.logi(string.format("PixelPerfect: setting scale to %.06f i.e. 1 point = %d pixel(s)", scale, pixelsPerPoint));
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
