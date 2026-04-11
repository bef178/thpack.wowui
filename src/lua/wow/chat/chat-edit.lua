local hookGlobalFunction = Util.hookGlobalFunction

local ChatTypeExtension = (function()
    local ChatTypeExtension = {}

    local chatTypes = {
        ["SAY"] = {
            nextType = "PARTY",
            isAvailable = function()
                return 1
            end
        },
        ["PARTY"] = {
            nextType = "RAID",
            isAvailable = function()
                return GetNumPartyMembers() > 0
            end
        },
        ["RAID"] = {
            nextType = "GUILD",
            isAvailable = function()
                return GetNumRaidMembers() > 0
            end
        },
        ["GUILD"] = {
            nextType = "SAY",
            isAvailable = function()
                return IsInGuild()
            end
        }
    }

    function ChatTypeExtension.getNext(chatType)
        local o = chatTypes[chatType]
        return o and o.nextType or "SAY"
    end

    function ChatTypeExtension.isAvailable(chatType)
        local o = chatTypes[chatType]
        return o and o.isAvailable()
    end

    function ChatTypeExtension.getNextAvailable(chatType)
        repeat
            chatType = ChatTypeExtension.getNext(chatType)
        until ChatTypeExtension.isAvailable(chatType)
        return chatType
    end

    function ChatTypeExtension.getCurrentChatType(f)
        -- return self:GetAttribute("chatType")
        return ChatFrameEditBox.chatType
    end

    function ChatTypeExtension.setCurrentChatType(f, chatType)
        -- f:SetAttribute("chatType", chatType)
        ChatFrameEditBox.chatType = chatType
    end

    return ChatTypeExtension
end)()

-- tab to switch chat channel
hookGlobalFunction("ChatEdit_OnTabPressed", "hook", function(original, ...)
    local self = this
    if self:GetText() == "" then
        local currentChatType = ChatTypeExtension.getCurrentChatType(self)
        local nextChatType = ChatTypeExtension.getNextAvailable(currentChatType)
        ChatTypeExtension.setCurrentChatType(self, nextChatType)
        ChatEdit_UpdateHeader(self)
        return
    end
    original(unpack(arg))
end)

ChatTypeInfo["WHISPER"].sticky = 0

-- direct arrow keys to move caret (rather than alt + arrow keys)
ChatFrameEditBox:SetAltArrowKeyMode(nil)
