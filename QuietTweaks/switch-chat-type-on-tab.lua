-- tab to switch chat type

local hookGlobalFunction = A.hookGlobalFunction;

local ChatTypeExtension = {};

ChatTypeExtension.getNext = (function()
    local nexts = {
        ["SAY"] = "PARTY",
        ["PARTY"] = "RAID",
        ["RAID"] = "INSTANCE_CHAT",
        ["INSTANCE_CHAT"] = "GUILD",
        ["GUILD"] = "SAY",
    };
    return function(chatType)
        return nexts[chatType] or "SAY";
    end;
end)();

ChatTypeExtension.isAvailable = (function()
    local validators = {
        ["SAY"] = function()
            return 1;
        end,
        ["PARTY"] = function()
            return GetNumPartyMembers() > 0;
        end,
        ["RAID"] = function()
            return GetNumRaidMembers() > 0;
        end,
        ["INSTANCE_CHAT"] = function()
            return IsInInstance();
        end,
        ["GUILD"] = function()
            return IsInGuild();
        end,
    };
    return function(chatType)
        return validators[chatType]();
    end;
end)();

ChatTypeExtension.getNextAvailable = function(chatType)
    repeat
        chatType = ChatTypeExtension.getNext(chatType);
    until ChatTypeExtension.isAvailable(chatType);
    return chatType;
end;

(function()
    local function getCurrentChatType(f)
        -- return self:GetAttribute("chatType");
        return ChatFrameEditBox.chatType;
    end

    local function setCurrentChatType(f, chatType)
        -- f:SetAttribute("chatType", chatType);
        ChatFrameEditBox.chatType = chatType;
    end

    hookGlobalFunction("ChatEdit_OnTabPressed", "hook", function(original, ...)
        local self = this;
        if (self:GetText() == "") then
            local currentChatType = getCurrentChatType(self);
            local nextChatType = ChatTypeExtension.getNextAvailable(currentChatType);
            setCurrentChatType(self, nextChatType);
            ChatEdit_UpdateHeader(self);
            return;
        end
        original(unpack(arg));
    end);
end)();

(function()
    ChatTypeInfo["WHISPER"].sticky = 0;
    ChatFrameEditBox:SetAltArrowKeyMode(nil);
end)();
