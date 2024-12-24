(function()
    SetCVar("profanityFilter", "0");

    local function repositionChatFrame1()
        if (ChatFrame1) then
            ChatFrame1:SetWidth(400);
            ChatFrame1:SetHeight(185);
        end
    end

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents();
        f:Hide();
        repositionChatFrame1();
    end);
end)();
