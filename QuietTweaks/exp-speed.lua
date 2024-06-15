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

    local function getExpPointsOfLastHour()
        local now = GetTime();
        while (Array.size(expQueue) > 0 and (now - expQueue[1].timestamp > 3600)) do
            Array.remove(expQueue, 1);
        end
        local pointsOfLastHour = 0;
        for i, item in ipairs(expQueue) do
            pointsOfLastHour = pointsOfLastHour + item.points;
        end
        return pointsOfLastHour;
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
                local pointsOfLastHour = getExpPointsOfLastHour();
                if (pointsOfLastHour == 0) then
                    fontString:SetText("eta: ...");
                else
                    local secondsToLevelUp = (UnitXPMax("player") - UnitXP("player")) / pointsOfLastHour * 3600
                    fontString:SetText("eta:" .. buildTimeString(secondsToLevelUp));
                end
            end
        end;
    end)());

    f:SetScript("OnEnter", function()
        local pointsOfLastHour = getExpPointsOfLastHour();
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:SetText(pointsOfLastHour .. "/h", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
    end);
end)();
