-- pixel perfect
(function()

    local function detectClientResolution()
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
            clientResolution = GetCVar("gxResolution");
        end

        return clientResolution;
    end

    local function getClientHeight(resolution)
        local g = {string.find(resolution, "%d+x(%d+)")};
        return g and g[3] and tonumber(g[3]);
    end

    local function findProperScale(clientHeightInPixels)
        -- fact: client area is 768/scale points
        -- fact: client area is clientHeightInPixels pixels
        -- formula: (768 / scale) * pixelsPerPoint == clientHeightInPixels
        -- expect: pixelsPerPoint is 1 or 2 or 3

        if (not clientHeightInPixels) then
            return;
        end

        if (clientHeightInPixels >= 1440 * 0.95 and clientHeightInPixels <= 1440 / 0.95) then
            -- around 1440, if pixelsPerPoint being 1 the UI is too small while if 2 it is too large
            -- have to let it as it is
            -- 768 / 0.9 * 1.6875 = 1440
            -- pixelsPerPoint is 1.6875; scale is 0.9
            return;
        end

        local pixelsPerPoint = math.floor(clientHeightInPixels / 768 + 0.1);
        if (pixelsPerPoint < 1) then
            pixelsPerPoint = 1;
        end

        local scale = pixelsPerPoint * 768 / clientHeightInPixels;

        return scale, pixelsPerPoint;
    end

    local f = CreateFrame("Frame");
    -- f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("DISPLAY_SIZE_CHANGED");
    f:SetScript("OnEvent", function()
        if (event == "DISPLAY_SIZE_CHANGED") then
            local clientResolution = detectClientResolution();
            A.logi(string.format("PixelPerfect: resolution [%s] detected.", clientResolution));

            local clientHeightInPixels = getClientHeight(clientResolution);
            local scale, pixelsPerPoint = findProperScale(clientHeightInPixels);

            if (not scale) then
                A.logi("PixelPerfect: nothing to do.");
            else
                SetCVar("useUiScale", 0); -- uiScale must be in [0.64, 1] so discarded
                A.logi(string.format("PixelPerfect: setting scale to %.06f i.e. 1 point = %d pixel(s)", scale, pixelsPerPoint));
                UIParent:SetScale(scale);
            end
        end
    end);
end)();
