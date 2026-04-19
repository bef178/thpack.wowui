local String = String
local Timer = Timer
local Color = Color

Messenger = (function()
    local Messenger = {}

    Messenger._normalSize = 32
    Messenger._variableSize = 0.6 * Messenger._normalSize
    Messenger._f = (function()
        local f = CreateFrame("Frame", nil, UIParent, nil)
        f:SetFrameStrata("HIGH")
        f:SetToplevel(true)
        f:SetPoint("TOPLEFT", 0, -100)
        f:SetPoint("TOPRIGHT", 0, -100)
        f:SetHeight(Messenger._normalSize + Messenger._variableSize)

        local warnTextRegion = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        warnTextRegion:SetJustifyH("CENTER")
        warnTextRegion:SetAllPoints()
        f.warnTextRegion = warnTextRegion

        return f
    end)()
    Messenger._timer = Timer:new(Messenger._f)

    function Messenger.notify(message, colorString, enteringSeconds, holdingSeconds, leavingSeconds)
        if not message or message == "" then
            return
        end

        colorString = colorString or Color.pick("White")

        -- or 0.15, 1.5, 0.4
        enteringSeconds = enteringSeconds or 0.1
        holdingSeconds = holdingSeconds or 1.2
        leavingSeconds = leavingSeconds or 0.2

        local t1 = enteringSeconds
        local t11 = t1 + enteringSeconds
        local t2 = t1 + holdingSeconds
        local t3 = t2 + leavingSeconds
        local fontSizeFixed = false
        local fontAlphaFixed = false

        local warnTextRegion = Messenger._f.warnTextRegion
        warnTextRegion:SetText(message)
        warnTextRegion:SetVertexColor(Color.toVertex(colorString))
        warnTextRegion:SetAlpha(0)

        Messenger._timer:start(t3, function(progress, t, isEnd)
            if isEnd then
                warnTextRegion:SetAlpha(0)
                return
            end

            -- font size animation
            if t < t1 then
                -- enlarge
                warnTextRegion:SetTextHeight(Messenger._normalSize + Messenger._variableSize * t / t1)
            elseif t < t11 then
                -- back to normal
                warnTextRegion:SetTextHeight(Messenger._normalSize + Messenger._variableSize * (t11 - t) / (t11 - t1))
            elseif not fontSizeFixed then
                fontSizeFixed = true
                warnTextRegion:SetTextHeight(Messenger._normalSize)
            end

            -- font alpha animation
            if t < t1 then
                warnTextRegion:SetAlpha(t / t1)
            elseif t < t2 then
                if not fontAlphaFixed then
                    fontAlphaFixed = true
                    warnTextRegion:SetAlpha(1)
                end
            elseif t < t3 then
                warnTextRegion:SetAlpha((t3 - t) / (t3 - t2))
            end
        end)
    end

    function Messenger.postMessage(message, channel)
        if channel then
            channel = String.toUpper(channel)
        else
            channel = "NOTIFY"
        end
        if channel == "NOTIFY" then
            Messenger.notify(message)
            Messenger.playSound()
        else
            SendChatMessage(message, channel)
        end
    end

    function Messenger.playSound(soundFile)
        -- 8959: RAID_WARNING
        -- PlaySound(soundFile or 8959)
        PlaySound("RaidWarning")
    end

    return Messenger
end)()
