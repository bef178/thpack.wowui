local hookGlobalFunction = A.hookGlobalFunction;

(function()
    local function buildTimeString(seconds)
        if (seconds <= 0) then
            return;
        end

        local d, h, m, s = ChatFrame_TimeBreakDown(seconds);
        if (d > 0) then
            if (d > 9) then
                return string.format("%dd", d);
            else
                return string.format("%dd%02d", d, h);
            end
        elseif (h > 0) then
            if (h > 9) then
                return string.format("%dh", h);
            elseif (h > 2) then
                return string.format("%dh%02d", h, m);
            else
                return string.format("%d\'", h * 60 + m);
            end
        elseif (m > 9) then
            return string.format("%d\'", m);
        else
            return string.format("%d:%02d", m, s);
        end
    end

    hookGlobalFunction("BuffFrame_UpdateDuration", "post_hook", function(buffButton, remainingSeconds)
        if (SHOW_BUFF_DURATIONS ~= "1") then
            return;
        end

        if (not remainingSeconds) then
            return;
        end

        local timeString = buildTimeString(remainingSeconds);
        if (not timeString) then
            return;
        end

        local countdownTextView = _G[buffButton:GetName() .. "Duration"];
        countdownTextView:SetFont(STANDARD_TEXT_FONT, 12);
        countdownTextView:SetText(timeString);
    end);
end)();
