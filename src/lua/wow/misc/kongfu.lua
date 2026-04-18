-- notify the player when cast succeed
local String = String
local logi = Util.logi
local addSlashCommand = Util.addSlashCommand
local Messenger = Messenger

local translations = {
    ["寒冰屏障"] = "冰箱！",
    ["圣盾术"] = "无敌！",
    ["圣疗术"] = "圣疗！",
    ["SWING"] = "blacked",
    ["Seal of Righteousness"] = "blacked"
}

local enabled = false
local lastValidEventTimestamp = 0

CastUtil.register(function(event)
    if not event or not enabled then
        return
    end
    if event.source == "You" and event.spellName and event.spellStage == "TICK" then
        -- 平A或技能可能带出多效果(e.g.电戒平A带电伤，神圣打击带回血回蓝)，这些效果通常在3ms内出尽。只取第一个效果
        -- 平A带出多个效果中，观察到白字伤害最后出。这里不好做延时，直接忽略小额伤害更优
        -- 但是又有个问题：小额伤害被完全抵抗时，就无法判断它原本是小额还是大额。所以被完全抵抗的都不报
        -- 经常说话或者说同样的话会被禁言，但是正义圣印这种又不易分辨，就黑名单罢
        local s = translations[event.spellName] or event.spellName
        if s == "blacked" or event.isResisted or (event.effect == "DAMAGE" and event.amount and event.amount < 10) then
            return
        end
        if event.timestamp - lastValidEventTimestamp < 0.01 then
            return
        end
        lastValidEventTimestamp = event.timestamp
        local channel, message = String.match(s, "(.-):(.+)")
        if not channel then
            message = s
        end
        Messenger.postMessage(message, channel)
    end
end)

addSlashCommand("aKongfu", "/kongfu", function(x)
    x = String.trim(x)
    if (x == "on") then
        enabled = true
        logi("You are now kongfu master")
    elseif (x == "off") then
        enabled = false
        logi("You are no longer kongfu master")
    else
        logi("Kongfu masters always call out names of their moves.")
        logi("Usage: /kongfu on | off")
    end
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    f:Hide()
    logi("Kongfu masters always call out names of their moves. Type \"/kongfu\" to learn more.")
end)
