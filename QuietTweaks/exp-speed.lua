local buildTimeString = A.buildTimeString;

local ExpTimer = {};

function ExpTimer:new(timeWindow)
    local o = {
        timeWindow = timeWindow or (15 * 60), -- in seconds
        q = {},
    };
    return setmetatable(o, { __index = self });
end

function ExpTimer:addExpPoints(points)
    Array.add(self.q, {
        timestamp = GetTime(),
        points = points,
    });
end

function ExpTimer:clear()
    Array.clear(self.q);
end

function ExpTimer:shrink()
    local startTime = GetTime() - self.timeWindow;
    while (Array.size(self.q) > 0 and self.q[1].timestamp < startTime) do
        Array.remove(self.q, 1);
    end
end

function ExpTimer:totalExpPoints()
    local points = 0;
    for i, v in ipairs(self.q) do
        points = points + v.points;
    end
    return points;
end

function ExpTimer:estimate()
    local n = Array.size(self.q);
    if (n > 3) then
        local startTime = self.q[1].timestamp;
        local endTime = self.q[n].timestamp;
        local seconds = endTime - startTime;
        if (seconds > 3) then
            local points = 0;
            for i = 2, n, 1 do
                points = points + self.q[i].points;
            end
            if (points > 0) then
                return math.floor(points / seconds);
            end
        end
    end
    return 0;
end

-- show exp speed
-- show ETA of level up
(function()
    if (UnitLevel("player") == MAX_PLAYER_LEVEL) then
        return;
    end

    local expTimer = ExpTimer:new();
    local invalidated = true;

    local f = CreateFrame("Button", nil, MainMenuExpBar, nil);
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
            expTimer:shrink();
            expTimer:addExpPoints(points);
            invalidated = true;
        end
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
                local expSpeed = expTimer:estimate();
                if (expSpeed > 0) then
                    local secondsToLevelUp = (UnitXPMax("player") - UnitXP("player")) / expSpeed;
                    fontString:SetText("eta:" .. buildTimeString(secondsToLevelUp));
                else
                    fontString:SetText("eta: ...");
                end
            end
        end;
    end)());

    f:SetScript("OnEnter", function()
        expTimer:shrink();
        local points = expTimer:totalExpPoints();
        if (points > 0) then
            GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
            GameTooltip:SetText(points .. " points over last " .. expTimer.timeWindow .. " seconds",
                    NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
        end
    end);

    f:SetScript("OnClick", function()
        expTimer:clear();
        invalidated = true;
    end);
end)();
