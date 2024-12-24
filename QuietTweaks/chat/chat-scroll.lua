(function()
    local function onMouseWheel()
        local NUM_LINES_AT_A_TIME = 1;
        local f = this;
        local dir = arg1;
        if (dir > 0) then
            if (IsShiftKeyDown()) then
                f:ScrollToTop();
            else
                for i = 1, NUM_LINES_AT_A_TIME do
                    f:ScrollUp();
                end
            end
        elseif (dir < 0) then
            if (IsShiftKeyDown()) then
                f:ScrollToBottom();
            else
                for i = 1, NUM_LINES_AT_A_TIME do
                    f:ScrollDown();
                end
            end
        end
    end

    for i = 1, NUM_CHAT_WINDOWS, 1 do
        local chatFrame = _G["ChatFrame" .. i];
        if (chatFrame) then
            chatFrame:EnableMouseWheel(true);
            chatFrame:SetScript("OnMouseWheel", onMouseWheel);
        end
    end
end)();
