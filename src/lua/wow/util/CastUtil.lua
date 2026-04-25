local GetTime = GetTime
local Map = Map
local String = String
local Color = Color

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
        spellStage = nil, -- "STARTED" or "CHANGED" or "SUCCEEDED" or "FAILED" or "TICK"
        startTime = nil,
        totalSeconds = nil,
        changedSeconds = nil,
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
        _subscribers = {},
        _numSubscribers = 0
    }

    function CastUtil.register(callback)
        local key = tostring(callback)
        CastUtil._subscribers[key] = callback
        CastUtil._numSubscribers = Map.size(CastUtil._subscribers)
        return key
    end

    function CastUtil.unregister(key)
        if typeof(key) == "function" then
            key = tostring(key)
        end
        CastUtil._subscribers[key] = nil
        CastUtil._numSubscribers = Map.size(CastUtil._subscribers)
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

    CastUtil._fSpellCast = (function()
        local function onCastingStarted(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellType = "CASTING",
                spellStage = "STARTED",
                startTime = data.casting,
                totalSeconds = data.castingTotalSeconds,
                changedSeconds = data.castingDelayedSeconds
            })
        end

        local function onCastingChanged(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellType = "CASTING",
                spellStage = "CHANGED",
                startTime = data.casting,
                totalSeconds = data.castingTotalSeconds,
                changedSeconds = data.castingDelayedSeconds
            })
        end

        local function onCastingSucceeded(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellType = "CASTING",
                spellStage = "SUCCEEDED",
                startTime = data.casting,
                totalSeconds = data.castingTotalSeconds,
                changedSeconds = data.castingDelayedSeconds
            })
        end

        local function onCastingFailed(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellType = "CASTING",
                spellStage = "FAILED",
                startTime = data.casting,
                totalSeconds = data.castingTotalSeconds,
                changedSeconds = data.castingDelayedSeconds
            })
        end

        local function onChannelingStarted(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellType = "CHANNELING",
                spellStage = "STARTED",
                startTime = data.channeling,
                totalSeconds = data.channelingTotalSeconds,
                changedSeconds = data.channelingAdvanceSeconds
            })
        end

        local function onChannelingChanged(data)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = data.spellName,
                spellType = "CHANNELING",
                spellStage = "CHANGED",
                startTime = data.channeling,
                totalSeconds = data.channelingTotalSeconds,
                changedSeconds = data.channelingAdvanceSeconds
            })
        end

        local function onChannelingSucceeded(state)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = state.spellName,
                spellType = "CHANNELING",
                spellStage = "SUCCEEDED",
                startTime = state.channeling,
                totalSeconds = state.channelingTotalSeconds,
                changedSeconds = state.channelingAdvanceSeconds
            })
        end

        local function onChannelingFailed(state)
            CastUtil._dispatch({
                timestamp = GetTime(),
                source = "You",
                spellName = state.spellName,
                spellType = "CHANNELING",
                spellStage = "FAILED",
                startTime = state.channeling,
                totalSeconds = state.channelingTotalSeconds,
                changedSeconds = state.channelingAdvanceSeconds
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
            if CastUtil._numSubscribers == 0 then
                return
            end
            local eventName = event
            local state = f._data
            if eventName == "SPELLCAST_START" then
                state.casting = GetTime()
                state.castingStopWaiting = nil
                state.castingTotalSeconds = arg2 / 1000
                state.castingDelayedSeconds = 0
                state.spellName = arg1
                onCastingStarted(state)
            elseif eventName == "SPELLCAST_DELAYED" then
                state.castingDelayedSeconds = state.castingDelayedSeconds + arg1 / 1000
                onCastingChanged(state)
            elseif eventName == "SPELLCAST_STOP" then
                -- if state.casting then
                --     state.castingStopWaiting = 1
                -- end
                local state1 = Map.merge({}, state)
                state.casting = nil
                state.castingStopWaiting = nil
                state.castingTotalSeconds = nil
                state.castingDelayedSeconds = nil
                state.spellName = nil
                onCastingSucceeded(state1)
            elseif eventName == "SPELLCAST_FAILED" or eventName == "SPELLCAST_INTERRUPTED" then
                local state1 = Map.merge({}, state)
                state.casting = nil
                state.castingStopWaiting = nil
                state.castingTotalSeconds = nil
                state.castingDelayedSeconds = nil
                state.spellName = nil
                onCastingFailed(state1)
            elseif eventName == "SPELLCAST_CHANNEL_START" then
                state.channeling = GetTime()
                state.channelingStartTime = GetTime()
                state.channelingTotalSeconds = arg1 / 1000
                state.channelingAdvanceSeconds = 0
                state.spellName = arg2
                onChannelingStarted(state)
            elseif eventName == "SPELLCAST_CHANNEL_UPDATE" then
                local oldEndTime = state.channelingStartTime + state.channelingTotalSeconds
                local nowEndTime = GetTime() + arg1 / 1000
                state.channelingAdvanceSeconds = oldEndTime - nowEndTime
                onChannelingChanged(state)
            elseif eventName == "SPELLCAST_CHANNEL_STOP" then
                if state.channeling then
                    local state1 = Map.merge({}, state)
                    state.channeling = nil
                    state.channelingStartTime = nil
                    state.channelingTotalSeconds = nil
                    state.channelingAdvanceSeconds = nil
                    state.spellName = nil
                    local endTime = state1.channelingStartTime + state1.channelingTotalSeconds
                    if GetTime() > endTime - 0.1 then
                        onChannelingSucceeded(state1)
                    else
                        onChannelingFailed(state1)
                    end
                end
            end
        end)

        -- f:SetScript("OnUpdate", function()
        --     local state = f._data
        --     -- delay a bit to confirm whether it is succeeded or cancelled
        --     -- 约15ms调用一次。在网络不好的时候，延几个tick意义不大
        --     if state.castingStopWaiting then
        --         if state.castingStopWaiting < 2 then
        --             state.castingStopWaiting = state.castingStopWaiting + 1
        --         else
        --             local state1 = Map.merge({}, state)
        --             state.casting = nil
        --             state.castingStopWaiting = nil
        --             state.castingTotalSeconds = nil
        --             state.castingDelayedSeconds = nil
        --             state.spellName = nil
        --             onCastingSucceeded(state1)
        --         end
        --     end
        -- end)

        return f
    end)()

    CastUtil._fChatMsg = (function()
        local f = CreateFrame("Frame")

        -- register CHAT_MSG_* events
        do
            local combatA1 = {"SELF", "PET", "PARTY", "FRIENDLYPLAYER", "HOSTILEPLAYER", "CREATURE_VS_SELF", "CREATURE_VS_PARTY", "CREATURE_VS_CREATURE"}
            local combatA2 = {"HITS", "MISSES"}
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
            local spellA2 = {"DAMAGE", "BUFF"}
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

            local spellPeriodicA1 = {"SELF", "PARTY", "FRIENDLYPLAYER", "HOSTILEPLAYER", "CREATURE"}
            local spellPeriodicA2 = {"DAMAGE", "BUFFS"}
            for i, v in ipairs(spellPeriodicA1) do
                for _, v2 in ipairs(spellPeriodicA2) do
                    local eventName = "CHAT_MSG_SPELL_PERIODIC" .. v .. "_" .. v2
                    f:RegisterEvent(eventName)
                end
            end
        end

        f:SetScript("OnEvent", function()
            if CastUtil._numSubscribers == 0 then
                return
            end
            local message = arg1
            CastUtil._dispatch(CastUtil.parseChatMsg(message))
        end)
    end)()

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
            }, CastUtil._parseChatMsgTrailer(trailerMessage) or {})
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
            }, CastUtil._parseChatMsgTrailer(trailerMessage) or {})
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

    function CastUtil.enableCastBar(castBar, unit)
        -- 1.12: SPELLCAST_* events only fire for player
        if unit ~= "player" then
            return
        end

        local data = {}

        local function reset()
            data.mode = nil
            data.startTime = nil
            data.totalSeconds = nil
            data.changedSeconds = nil
            data.flashing = nil
            data.holding = nil
            data.fading = nil

            castBar:SetValue(0)
            castBar:SetAlpha(1)
            castBar:SetStatusBarColor(Color.toVertex(Color.pick("Cyan")))
            if castBar.sparkTextureRegion then
                castBar.sparkTextureRegion:Show()
            end
            if castBar.flashTextureRegion then
                castBar.flashTextureRegion:SetAlpha(0)
            end
            if castBar.nameTextRegion then
                castBar.nameTextRegion:SetText()
            end
            if castBar.remainingTimeTextRegion then
                castBar.remainingTimeTextRegion:SetText()
            end
            castBar:Hide()
        end

        castBar:SetScript("OnUpdate", function()
            local elapsed = arg1
            local now = GetTime()
            if data.mode == "CASTING" then
                local effectiveElapsedSeconds = now - data.startTime - data.changedSeconds
                if effectiveElapsedSeconds < 0 then
                    effectiveElapsedSeconds = 0
                elseif effectiveElapsedSeconds > data.totalSeconds then
                    effectiveElapsedSeconds = data.totalSeconds
                end
                local fraction = effectiveElapsedSeconds / data.totalSeconds
                castBar:SetValue(fraction)
                if castBar.sparkTextureRegion then
                    castBar.sparkTextureRegion:SetPoint("CENTER", castBar, "LEFT", fraction * castBar:GetWidth(), 0)
                end
                if castBar.remainingTimeTextRegion then
                    castBar.remainingTimeTextRegion:SetText(string.format("%.1f", data.totalSeconds - effectiveElapsedSeconds))
                end
            elseif data.mode == "CHANNELING" then
                local effectiveElapsedSeconds = now - data.startTime + data.changedSeconds
                if effectiveElapsedSeconds < 0 then
                    effectiveElapsedSeconds = 0
                elseif effectiveElapsedSeconds > data.totalSeconds then
                    effectiveElapsedSeconds = data.totalSeconds
                end
                local fraction = 1 - effectiveElapsedSeconds / data.totalSeconds
                if castBar.sparkTextureRegion then
                    castBar.sparkTextureRegion:SetPoint("CENTER", castBar, "LEFT", fraction * castBar:GetWidth(), 0)
                end
                castBar:SetValue(fraction)
                if castBar.remainingTimeTextRegion then
                    castBar.remainingTimeTextRegion:SetFormattedText("%.1f", data.totalSeconds - effectiveElapsedSeconds)
                end
            elseif data.mode == "ENDING" then
                if castBar.flashTextureRegion and data.flashing then
                    local alpha = castBar.flashTextureRegion:GetAlpha() + 0.1
                    if alpha >= 1 then
                        castBar.flashTextureRegion:SetAlpha(1)
                        data.flashing = nil
                    else
                        castBar.flashTextureRegion:SetAlpha(alpha)
                    end
                elseif data.holding then
                    data.holding = data.holding - elapsed * 3
                    if data.holding <= 0 then
                        data.holding = nil
                    end
                elseif data.fading then
                    local alpha = castBar:GetAlpha() - 0.05
                    if alpha <= 0 then
                        castBar:SetAlpha(0)
                        data.fading = nil
                    else
                        castBar:SetAlpha(alpha)
                    end
                else
                    reset()
                end
            end
        end)

        CastUtil.register(function(event)
            if event.source == "You" then
                if event.spellType == "CASTING" then
                    if event.spellStage == "STARTED" then
                        data.mode = event.spellType
                        data.startTime = event.startTime
                        data.totalSeconds = event.totalSeconds
                        data.changedSeconds = event.changedSeconds
                        castBar:SetValue(0)
                        castBar:SetAlpha(1)
                        castBar:SetStatusBarColor(Color.toVertex(Color.pick("Gold")))
                        if castBar.sparkTextureRegion then
                            castBar.sparkTextureRegion:Show()
                        end
                        if castBar.flashTextureRegion then
                            castBar.flashTextureRegion:SetAlpha(0)
                        end
                        if castBar.nameTextRegion then
                            castBar.nameTextRegion:SetText(event.spellName)
                        end
                        castBar:Show()
                    elseif event.spellStage == "CHANGED" then
                        data.changedSeconds = event.changedSeconds
                    elseif event.spellStage == "SUCCEEDED" or event.spellStage == "FAILED" then
                        local isSucceeded = event.spellStage == "SUCCEEDED"
                        castBar:SetValue(1)
                        castBar:SetAlpha(1) -- 1.12
                        castBar:SetStatusBarColor(Color.toVertex(Color.pick(isSucceeded and "Green" or "Red")))
                        if castBar.sparkTextureRegion then
                            castBar.sparkTextureRegion:Hide()
                        end
                        data.mode = "ENDING"
                        if isSucceeded and castBar.flashTextureRegion then
                            data.flashing = 1
                        else
                            data.holding = 1
                        end
                        data.fading = 1
                    end
                elseif event.spellType == "CHANNELING" then
                    if event.spellStage == "STARTED" then
                        data.mode = event.spellType
                        data.startTime = event.startTime
                        data.totalSeconds = event.totalSeconds
                        data.changedSeconds = event.changedSeconds
                        castBar:SetValue(1)
                        castBar:SetAlpha(1)
                        castBar:SetStatusBarColor(Color.toVertex(Color.pick("Green")))
                        if castBar.sparkTextureRegion then
                            castBar.sparkTextureRegion:Show()
                        end
                        if castBar.flashTextureRegion then
                            castBar.flashTextureRegion:SetAlpha(0)
                        end
                        if castBar.nameTextRegion then
                            castBar.nameTextRegion:Show()
                        end
                        castBar:Show()
                    elseif event.spellStage == "CHANGED" then
                        data.changedSeconds = event.changedSeconds
                    elseif event.spellStage == "SUCCEEDED" or event.spellStage == "FAILED" then
                        local isSucceeded = event.spellStage == "SUCCEEDED"
                        castBar:SetValue(0)
                        castBar:SetStatusBarColor(Color.toVertex(Color.pick(isSucceeded and "Green" or "Red")))
                        if castBar.sparkTextureRegion then
                            castBar.sparkTextureRegion:Hide()
                        end
                        data.mode = "ENDING"
                        if isSucceeded and castBar.flashTextureRegion then
                            data.flashing = 1
                        else
                            data.holding = 1
                        end
                        data.fading = 1
                    end
                end
            end
        end)
    end

    return CastUtil
end)()
