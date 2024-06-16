local buildTimeString = A.buildTimeString;

-- show exp points per hour
-- show ETA of level up
(function()
    if (UnitLevel("player") == MAX_PLAYER_LEVEL) then
        return;
    end

    local expQueue = {};
    local invalidated = true;

    local function addExpPoints(points)
        Array.add(expQueue, {
            timestamp = GetTime(),
            points = points
        });
    end

    local function estimateExpPerHour()
        local now = GetTime();
        while (Array.size(expQueue) > 0 and (now - expQueue[1].timestamp > 3600)) do
            Array.remove(expQueue, 1);
        end
        local n = Array.size(expQueue);
        if (n > 3) then
            local startTime = expQueue[1].timestamp;
            local endTime = expQueue[n].timestamp;
            local points = 0;
            for i = 2, n, 1 do
                points = points + expQueue[i].points;
            end
            return math.floor(points / (endTime - startTime) * 3600);
        end
    end

    local f = CreateFrame("Frame", nil, MainMenuExpBar, nil);
    f:SetPoint("RIGHT", 0, 0);
    f:SetWidth(MainMenuExpBar:GetWidth() / 20);
    f:SetHeight(12);
    f:EnableMouse(true);

    local fontString = f:CreateFontString(nil, "OVERLAY", nil);
    fontString:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE");
    fontString:SetPoint("RIGHT", -5, 1);

    f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
    f:RegisterEvent("UNIT_LEVEL");
    f:SetScript("OnEvent", function()
        if (event == "CHAT_MSG_COMBAT_XP_GAIN") then
            local message = arg1;
            local startIndex, endIndex, pointsString = string.find(message, '(%d+)')
            local points = tonumber(pointsString);
            addExpPoints(points);
        end
        invalidated = true;
    end);

    f:SetScript("OnUpdate", (function()
        local REFRESH_INTERVAL = 6;
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (invalidated or (acc > REFRESH_INTERVAL)) then
                invalidated = false;
                acc = 0;
                local expPerHour = estimateExpPerHour();
                if (expPerHour) then
                    local secondsToLevelUp = (UnitXPMax("player") - UnitXP("player")) / expPerHour * 3600;
                    fontString:SetText("eta:" .. buildTimeString(secondsToLevelUp));
                else
                    fontString:SetText("eta: ...");
                end
            end
        end;
    end)());

    f:SetScript("OnEnter", function()
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:SetText((estimateExpPerHour() or 0) .. "/h", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
    end);
end)();
