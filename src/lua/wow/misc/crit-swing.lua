local tonumber = tonumber
local PlaySoundFile = PlaySoundFile

local Map = Map
local String = String
local getResource = Util.getResource

local function onCombatEvent(event)
    if not event then
        return
    end
    if event.category == "SWING_DAMAGE" then
        if event.source == "You" and event.spell == "SWING" and event.isCritical then
            PlaySoundFile(getResource("fight.ogg"))
        end
    end
end

local function parseTrailerMessage(s)
    if not s then
        return
    end
    local amount
    -- ABSORB_TRAILER = " (%d absorbed)"
    amount = String.match(s, " %((%d+) absorbed%)")
    if amount then
        return {
            absorbed = tonumber(amount)
        }
    end

    -- BLOCK_TRAILER = " (%d blocked)"
    amount = String.match(s, " %((%d+) blocked%)")
    if amount then
        return {
            blocked = tonumber(amount)
        }
    end

    -- RESIST_TRAILER = " (%d resisted)"
    amount = String.match(s, " %((%d+) resisted%)")
    if amount then
        return {
            resisted = tonumber(amount)
        }
    end

    -- VULNERABLE_TRAILER = " (+%d vulnerability bonus)"
    amount = String.match(s, " %(%+(%d+) vulnerability bonus%)")
    if amount then
        return {
            vulnerability = tonumber(amount)
        }
    end

    -- CRUSHING_TRAILER = " (crushing)"
    if s == " (crushing)" then
        return {
            isCrushing = true
        }
    end

    -- GLANCING_TRAILER = " (glancing)"
    if s == " (glancing)" then
        return {
            isGlancing = true
        }
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
f:SetScript("OnEvent", function()
    local eventName = event
    if eventName == "CHAT_MSG_COMBAT_SELF_HITS" then
        local message = arg1
        local target, damage

        -- "You miss Expert Training Dummy."
        -- "You attack. Expert Training Dummy dodges."
        -- "You attack. Expert Training Dummy parries."
        -- "You hit Expert Training Dummy for 98. (glancing)"
        -- "You hit Expert Training Dummy for 87. (36 blocked)"
        -- "xxx. (crushing)"
        -- "You crit Expert Training Dummy for 254."
        -- "You hit Expert Training Dummy for 111."
        target, damage = String.match(message, "You crit (.+) for (%d+)%.")
        if target then
            onCombatEvent({
                category = "SWING_DAMAGE",
                origin = message,
                source = "You",
                target = target,
                spell = "SWING",
                damage = tonumber(damage),
                isCritical = true
            })
            return
        end
    end
end)
