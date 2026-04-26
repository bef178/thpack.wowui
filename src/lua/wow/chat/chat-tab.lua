-- 空输入时按tab在各个频道中切换
--
local ChatEditUtil = (function()
    local ChatEditUtil = {}

    local CHAT_TYPES = {
        ["SAY"] = {
            isAvailable = function()
                return 1
            end,
            nextType = "PARTY"
        },
        ["PARTY"] = {
            isAvailable = function()
                return GetNumPartyMembers() > 0
            end,
            nextType = "RAID"
        },
        ["RAID"] = {
            isAvailable = function()
                return GetNumRaidMembers() > 0
            end,
            nextType = "GUILD"
        },
        ["GUILD"] = {
            isAvailable = function()
                return IsInGuild()
            end,
            nextType = "SAY"
        }
    }

    function ChatEditUtil._getNextChatType(chatType)
        local o = CHAT_TYPES[chatType]
        return o and o.nextType or "SAY"
    end

    function ChatEditUtil._isAvailable(chatType)
        local o = CHAT_TYPES[chatType]
        return o and o.isAvailable()
    end

    function ChatEditUtil.getNextAvailableChatType(chatType)
        repeat
            chatType = ChatEditUtil._getNextChatType(chatType)
        until ChatEditUtil._isAvailable(chatType)
        return chatType
    end

    function ChatEditUtil.getChatType(f)
        if f.GetAttribute then
            return f:GetAttribute("chatType")
        else
            return ChatFrameEditBox.chatType
        end
    end

    function ChatEditUtil.setChatType(f, chatType)
        if f.SetAttribute then
            f:SetAttribute("chatType", chatType)
        else
            ChatFrameEditBox.chatType = chatType
        end
        ChatEdit_UpdateHeader(f)
    end

    return ChatEditUtil
end)()

local function tabToNextAvailableChatType(f)
    if f:GetText() ~= "" then
        return false
    end
    local currentChatType = ChatEditUtil.getChatType(f)
    local nextChatType = ChatEditUtil.getNextAvailableChatType(currentChatType)
    ChatEditUtil.setChatType(f, nextChatType)
    return true
end

if securecall and ChatEdit_CustomTabPressed then
    ChatEdit_CustomTabPressed = tabToNextAvailableChatType
else
    Util.hookGlobalFunction("ChatEdit_OnTabPressed", "hook", function(original, ...)
        local f = this
        if not tabToNextAvailableChatType(f) then
            original(unpack(arg))
        end
    end)
end

ChatTypeInfo["WHISPER"].sticky = 0

-- arrow keys (rather than alt + arrow keys) to move caret
ChatFrameEditBox:SetAltArrowKeyMode(nil)
