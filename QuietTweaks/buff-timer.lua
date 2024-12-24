local hookGlobalFunction = A.hookGlobalFunction;
local buildTimeString = A.buildTimeString;

(function()
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
