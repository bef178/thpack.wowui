local buildTimeString = A.buildTimeString;

local ExpTimer = {};

function ExpTimer:new(timeWindow)
    local o = {
        timeWindow = timeWindow or (15 * 60), -- in seconds
        numRecent = 10,
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

function ExpTimer:estimateExpSpeed()
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

-- show ETA of level up
-- show recent gains
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
                local pps = expTimer:estimateExpSpeed();
                if (pps > 0) then
                    local secondsToLevelUp = (UnitXPMax("player") - UnitXP("player")) / pps;
                    fontString:SetText("ETA:" .. buildTimeString(secondsToLevelUp));
                else
                    fontString:SetText("ETA: ...");
                end
            end
        end;
    end)());

    f:SetScript("OnEnter", function()
        expTimer:shrink();
        local now = GetTime();
        local a = expTimer.q;
        if (Array.size(a) > 0) then
            local totalPoints = 0;
            local j = 0;
            GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
            GameTooltip:AddLine("Recent Exp", 0.8, 0.8, 0.8);
            for i = Array.size(a), 1, -1 do
                totalPoints = totalPoints + a[i].points;
                if (j < expTimer.numRecent) then
                    GameTooltip:AddDoubleLine("-" .. buildTimeString(now - a[i].timestamp), a[i].points,
                            0.7, 0.7, 0.7, 0.7, 0.7, 0.7);
                    j = j + 1;
                end
            end
            GameTooltip:AddLine("Total " .. totalPoints .. " in " .. buildTimeString(expTimer.timeWindow), 0.9, 0.9, 0);
            GameTooltip:AddLine("(shift click to reset)", 0.5, 0.5, 0.5);
            GameTooltip:Show();
        end
    end);
    f:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    f:SetScript("OnClick", function()
        if (IsShiftKeyDown()) then
            expTimer:clear();
            invalidated = true;
            GameTooltip:Hide();
        end
    end);
end)();
