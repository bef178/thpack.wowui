local blackList = {
    ["伦鲁迪洛尔"] = {
        ["威尼斯狗哥"] = 1,
        ["威尼斯密码"] = 1,
        ["青龙于樂"] = 1,
        ["青龙余熱"] = 1,
        ["小野猫典丶楽"] = 1,
        ["龙五鱼乐漏丶"] = 1,
        ["心花阁渝勒"] = 1,
        ["叶星城于叻"] = 1,
        ["叶星城小大点"] = 1,
        ["拉斯维加余乐"] = 1,
        ["富贵柔丶丶"] = 1,
    },
};

local realmName = GetRealmName();

-- true to skip message; false to keep message
function filterOutChatMessage(chatFrame, event, message, author, ...)
    local authorGuid = select(12, ...);

    local authorName = author;
    local serverName = realmName;
    local i = string.find(author, "-", 1, true);
    if (i and i > 0) then
        authorName = string.sub(author, 1, i - 1);
        serverName = string.sub(author, i + 1);
    end

    local names = blackList[serverName];
    if (names and names[authorName]) then
        return true;
    end
    return false, message, author, ...;
end

local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:SetScript("OnEvent", function(self, event, ...)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filterOutChatMessage);
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filterOutChatMessage);
    self:UnregisterAllEvents();
end);