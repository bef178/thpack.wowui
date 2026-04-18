local tonumber = tonumber
local PlaySoundFile = PlaySoundFile

local Map = Map
local String = String
local getResource = Util.getResource
local CastUtil = CastUtil

local function onCombatChatEvent(event)
    if not event then
        return
    end
    if event.source == "You" and event.spellName == "SWING" and event.effect == "DAMAGE" and event.isCritical then
        PlaySoundFile(getResource("fight.ogg"))
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
f:SetScript("OnEvent", function()
    local eventName = event
    local message = arg1
    onCombatChatEvent(CastUtil.parseChatMsg(message))
end)
