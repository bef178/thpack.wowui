local GetTime = GetTime
local Map = Map
local String = String

CastUtil = (function()
    --[[
    aCastEvent = {
        timestamp = nil, -- GetTime()
        source = nil, -- "You"
        target = nil, -- name of target
        spellId = nil, -- index in spellbook, for 1.12
        spellName = nil, -- e.g. "SWING"
        spellRank = nil,
        spellType = nil, -- "CASTING" or "CHANNELING" or "INSTANT"
        spellStage = nil, -- "STARTED" or "DONE" or "FAILED" or "TICK"
        effect = nil, -- "DAMAGE" or "HEAL" or "BUFF" or "DEBUFF" or "DISPEL"
        amount = nil,
        absorbed = nil,
        blocked = nil,
        resisted = nil,
        vulnerability = nil,
        isMissed = false,
        isDodged = false,
        isParried = false,
        isGlancing = false,
        isCrushing = false,
        isCritical = false,
        school = nil -- "Holy" etc
    }
    ]]

    local CastUtil = {
        _fSpellCast = nil,
        _fChatMsg = nil,
        _subscribers = {}
    }

    function CastUtil.register(callback)
        local key = tostring(callback)
        CastUtil._subscribers[key] = callback
    end

    function CastUtil.unregister(key)
        if typeof(key) == "function" then
            key = tostring(key)
        end
        CastUtil._subscribers[key] = nil
    end

    function CastUtil._dispatch(castEvent)
        if not castEvent then
            return
        end
        for k, v in pairs(CastUtil._subscribers) do
            if type(v) == "function" then
                v(castEvent)
            end
        end
    end

    function CastUtil._listenToSpellCast()
        local function onCastingStart(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellRank = data.spellRank,
                spellType = "CASTING",
                spellStage = "STARTED"
            })
        end

        local function onCastingSucceeded(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellRank = data.spellRank,
                spellType = "CASTING",
                spellStage = "DONE"
            })
        end

        local function onCastingFailed(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellRank = data.spellRank,
                spellType = "CASTING",
                spellStage = "FAILED"
            })
        end

        local function onChannelingStart(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellRank = data.spellRank,
                spellType = "CHANNELING",
                spellStage = "STARTED"
            })
        end

        local function onChannelingDone(state)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = state.spellName,
                spellRank = state.spellRank,
                spellType = "CHANNELING",
                spellStage = "DONE"
            })
        end

        local function onChannelingFailed(state)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = state.spellName,
                spellRank = state.spellRank,
                spellType = "CHANNELING",
                spellStage = "FAILED"
            })
        end

        local f = CreateFrame("Frame")

        -- casting
        f:RegisterEvent("SPELLCAST_START")
        f:RegisterEvent("SPELLCAST_STOP")
        f:RegisterEvent("SPELLCAST_DELAYED")
        f:RegisterEvent("SPELLCAST_FAILED")
        f:RegisterEvent("SPELLCAST_INTERRUPTED")

        -- channeling
        f:RegisterEvent("SPELLCAST_CHANNEL_START")
        f:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
        f:RegisterEvent("SPELLCAST_CHANNEL_STOP")

        f._data = {}
        f:SetScript("OnEvent", function()
            if Map.size(CastUtil._subscribers) == 0 then
                return
            end
            local eventName = event
            local state = f._data
            if eventName == "SPELLCAST_START" then
                state.casting = true
                state.castingStopWaiting = nil
                state.spellName = arg1
                state.spellRank = arg2
                onCastingStart(state)
            elseif eventName == "SPELLCAST_DELAYED" then
                -- dummy
            elseif eventName == "SPELLCAST_STOP" then
                if state.casting then
                    state.castingStopWaiting = 1
                end
            elseif eventName == "SPELLCAST_FAILED" or eventName == "SPELLCAST_INTERRUPTED" then
                local state1 = Map.merge({}, state)
                state.casting = false
                state.castingStopWaiting = nil
                state.spellRank = nil
                state.spellName = nil
                onCastingFailed(state1)
            elseif eventName == "SPELLCAST_CHANNEL_START" then
                state.channeling = true
                state.spellName = arg2
                state.channelingEndTime = GetTime() + arg1 / 1000
                onChannelingStart(state)
            elseif eventName == "SPELLCAST_CHANNEL_UPDATE" then
                -- dummy
            elseif eventName == "SPELLCAST_CHANNEL_STOP" then
                if state.channeling then
                    local state1 = Map.merge({}, state)
                    state.channeling = false
                    state.spellName = nil
                    state.channelingEndTime = nil
                    if GetTime() > state1.channelingEndTime - 0.1 then
                        onChannelingDone(state1)
                    else
                        onChannelingFailed(state1)
                    end
                end
            end
        end)

        f:SetScript("OnUpdate", function()
            local elapsed = arg1
            local state = f._data
            -- delay a bit to confirm whether it is succeeded or cancelled
            if state.castingStopWaiting == 1 then
                state.castingStopWaiting = 2
            elseif state.castingStopWaiting == 2 then
                if state.casting then
                    local state1 = Map.merge({}, state)
                    state.casting = false
                    state.castingStopWaiting = nil
                    state.spellRank = nil
                    state.spellName = nil
                    onCastingSucceeded(state1)
                end
            else
                state.castingStopWaiting = nil
            end
        end)

        return f
    end

    function CastUtil._listenToChatMsg()
        local f = CreateFrame("Frame")

        -- register CHAT_MSG_* events
        do
            local combatA1 = {
                "SELF",
                "PET",
                "PARTY",
                "FRIENDLYPLAYER",
                "HOSTILEPLAYER",
                "CREATURE_VS_SELF",
                "CREATURE_VS_PARTY",
                "CREATURE_VS_CREATURE"
            }
            local combatA2 = {
                "HITS",
                "MISSES"
            }
            for i, v in ipairs(combatA1) do
                for _, v2 in ipairs(combatA2) do
                    local eventName = "CHAT_MSG_COMBAT_" .. v .. "_" .. v2
                    f:RegisterEvent(eventName)
                end
            end
            f:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
            f:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
            f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
            f:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
            f:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
            f:RegisterEvent("CHAT_MSG_COMBAT_ERROR")
            f:RegisterEvent("CHAT_MSG_COMBAT_MISC_INFO")

            local spellA1 = combatA1
            local spellA2 = {
                "DAMAGE",
                "BUFF"
            }
            for i, v in ipairs(spellA1) do
                for _, v2 in ipairs(spellA2) do
                    local eventName = "CHAT_MSG_SPELL_" .. v .. "_" .. v2
                    f:RegisterEvent(eventName)
                end
            end
            f:RegisterEvent("CHAT_MSG_SPELL_TRADESKILLS")
            f:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
            f:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS")
            f:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
            f:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
            f:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
            f:RegisterEvent("CHAT_MSG_SPELL_ITEM_ENCHANTMENTS")
            f:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
            f:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")

            local spellPeriodicA1 = {
                "SELF",
                "PARTY",
                "FRIENDLYPLAYER",
                "HOSTILEPLAYER",
                "CREATURE"
            }
            local spellPeriodicA2 = {
                "DAMAGE",
                "BUFFS"
            }
            for i, v in ipairs(spellPeriodicA1) do
                for _, v2 in ipairs(spellPeriodicA2) do
                    local eventName = "CHAT_MSG_SPELL_PERIODIC" .. v .. "_" .. v2
                    f:RegisterEvent(eventName)
                end
            end
        end

        f:SetScript("OnEvent", function()
            if Map.size(CastUtil._subscribers) == 0 then
                return
            end
            local message = arg1
            CastUtil._dispatch(CastUtil.parseChatMsg(message))
        end)
    end

    function CastUtil.parseChatMsg(message)
        return CastUtil._parseChatMsgCombat(message) or CastUtil._parseChatMsgSpell(message)
    end

    function CastUtil._parseChatMsgCombat(message)
        -- "You miss Expert Training Dummy."
        -- "You attack. Expert Training Dummy dodges."
        -- "You attack. Expert Training Dummy parries."
        -- "You hit Expert Training Dummy for 98. (glancing)"
        -- "You hit Expert Training Dummy for 87. (36 blocked)"
        -- "Xxx hit xxx for xxx. (crushing)"
        -- "You crit Expert Training Dummy for 254."
        -- "You hit Expert Training Dummy for 111."
        local target, spellName, amount, trailerMessage

        target = String.match(message, "You miss (.+)%.")
        if target then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = "SWING",
                spellType = "INSTANT",
                spellStage = "TICK",
                effect = "DAMAGE",
                isMissed = true
            }
        end

        target = String.match(message, "You attack. (.+) dodges%.")
        if target then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = "SWING",
                spellType = "INSTANT",
                spellStage = "TICK",
                effect = "DAMAGE",
                isDodged = true
            }
        end

        target = String.match(message, "You attack. (.+) parries%.")
        if target then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = "SWING",
                spellType = "INSTANT",
                spellStage = "TICK",
                effect = "DAMAGE",
                isParried = true
            }
        end

        target, amount, trailerMessage = String.match(message, "You hit (.+) for (%d+)%.(.*)")
        if target then
            return Map.merge({
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = "SWING",
                spellType = "INSTANT",
                spellStage = "TICK",
                effect = "DAMAGE",
                amount = tonumber(amount)
            }, CastUtil._parseChatMsgTrailer(trailerMessage) or {});
        end

        target, amount = String.match(message, "You crit (.+) for (%d+)%.")
        if target then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = "SWING",
                spellType = "INSTANT",
                spellStage = "TICK",
                effect = "DAMAGE",
                amount = tonumber(amount),
                isCritical = true
            }
        end
    end

    function CastUtil._parseChatMsgTrailer(trailerMessage)
        if not trailerMessage or trailerMessage == "" then
            return
        end

        local amount
        -- ABSORB_TRAILER = " (%d absorbed)"
        amount = String.match(trailerMessage, " %((%d+) absorbed%)")
        if amount then
            return {
                absorbed = tonumber(amount)
            }
        end

        -- BLOCK_TRAILER = " (%d blocked)"
        amount = String.match(trailerMessage, " %((%d+) blocked%)")
        if amount then
            return {
                blocked = tonumber(amount)
            }
        end

        -- RESIST_TRAILER = " (%d resisted)"
        amount = String.match(trailerMessage, " %((%d+) resisted%)")
        if amount then
            return {
                resisted = tonumber(amount)
            }
        end

        -- VULNERABLE_TRAILER = " (+%d vulnerability bonus)"
        amount = String.match(trailerMessage, " %(%+(%d+) vulnerability bonus%)")
        if amount then
            return {
                vulnerability = tonumber(amount)
            }
        end

        -- CRUSHING_TRAILER = " (crushing)"
        if trailerMessage == " (crushing)" then
            return {
                isCrushing = true
            }
        end

        -- GLANCING_TRAILER = " (glancing)"
        if trailerMessage == " (glancing)" then
            return {
                isGlancing = true
            }
        end
    end

    function CastUtil._parseChatMsgSpell(message)
        local target, spellName, amount, school, critically, trailerMessage

        -- "Your Holy Strike missed Expert Training Dummy."
        spellName, target = String.match(message, "Your (.+) missed (.+)%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "DAMAGE",
                isMissed = true
            }
        end

        -- "Your Holy Strike was dodged by Expert Training Dummy."
        spellName, target = String.match(message, "Your (.+) was dodged by (.+)%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "DAMAGE",
                idDodged = true
            }
        end

        -- "Your Holy Strike is parried by Expert Training Dummy."
        spellName, target = String.match(message, "Your (.+) is parried by (.+)%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "DAMAGE",
                isParried = true
            }
        end

        -- "Your Lightning Strike was resisted by Heroic Training Dummy."
        spellName, target = String.match(message, "Your (.+) was resisted by (.+)%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "DAMAGE",
                isResisted = true
            }
        end

        -- "Your Holy Strike hits Expert Training Dummy for 228 Holy damage."
        spellName, target, amount, school, trailerMessage = String.match(message, "Your (.+) hits (.+) for (%d+) (.+) damage%.(.*)")
        if spellName then
            return Map.merge({
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "DAMAGE",
                amount = tonumber(amount),
                school = school
            }, CastUtil._parseChatMsgTrailer(trailerMessage) or {});
        end

        -- "Your Holy Strike crits Expert Training Dummy for 432 Holy damage."
        spellName, target, amount, school = String.match(message, "Your (.+) crits (.+) for (%d+) (.+) damage%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "DAMAGE",
                amount = tonumber(amount),
                isCritical = true,
                school = school
            }
        end

        -- "Your Flash of Light critically heals you for 648."
        spellName, target, amount = String.match(message, "Your (.+) critically heals (.+) for (%d+)%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "HEAL",
                amount = tonumber(amount),
                isCritical = true
            }
        end

        -- "Your Flash of Light heals you for 433."
        spellName, target, amount = String.match(message, "Your (.+) heals (.+) for (%d+)%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellStage = "TICK",
                effect = "HEAL",
                amount = tonumber(amount)
            }
        end
    end

    CastUtil._fSpellCast = CastUtil._listenToSpellCast()
    CastUtil._fChatMsg = CastUtil._listenToChatMsg()

    return CastUtil
end)()
