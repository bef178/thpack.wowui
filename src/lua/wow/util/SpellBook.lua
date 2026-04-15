local GetTime = GetTime
local GetSpellName = GetSpellName
local Map = Map
local String = String

SpellBook = (function()
    local SpellBook = {}

    -- via search player's spellbook
    function SpellBook.getSpellIndex(spellName, spellRank)
        local i = 1
        while true do
            local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
            if not name then
                break
            end
            if name == spellName and (not spellRank or rank == spellRank) then
                return i
            end
            i = i + 1
        end
        return nil
    end

    -- return {
    --     timestamp = nil, -- GetTime()
    --     source = nil, -- "You"
    --     target = nil, -- name of target
    --     spellId = nil, -- index in spellbook, for 1.12
    --     spellName = nil, -- e.g. "SWING"
    --     spellRank = nil,
    --     spellType = nil, -- "CASTING" or "CHANNEL" or "INSTANT"
    --     spellStage = nil, -- "STARTED" or "DONE" or "FAILED" or "TICK"
    --     effect = nil, -- "DAMAGE" or "HEAL" or "BUFF" or "DEBUFF" or "DISPEL"
    --     damage = nil,
    --     damageAbsorbed = nil,
    --     damageBlocked = nil,
    --     damageResisted = nil,
    --     damageVulnerability = nil,
    --     isMissed = false,
    --     isDodged = false,
    --     isParried = false,
    --     isGlancing = false,
    --     isCrushing = false,
    --     isCritical = false
    -- }
    function SpellBook.parseCombatChatMessage(message)
        -- "You miss Expert Training Dummy."
        -- "You attack. Expert Training Dummy dodges."
        -- "You attack. Expert Training Dummy parries."
        -- "You hit Expert Training Dummy for 98. (glancing)"
        -- "You hit Expert Training Dummy for 87. (36 blocked)"
        -- "Xxx hit xxx for xxx. (crushing)"
        -- "You crit Expert Training Dummy for 254."
        -- "You hit Expert Training Dummy for 111."
        local target, spellName, damage, heal, critically, trailerMessage

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

        target, damage, trailerMessage = String.match(message, "You hit (.+) for (%d+)%.(.*)")
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
                damage = tonumber(damage)
            }, SpellBook._parseCombatChatTrailerMessage(trailerMessage) or {});
        end

        target, damage = String.match(message, "You crit (.+) for (%d+)%.")
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
                damage = tonumber(damage),
                isCritical = true
            }
        end

        spellName, critically, target, heal = String.match(message, "Your (.+) (critically )?heals (.+) for (%d+)%.")
        if spellName then
            return {
                timestamp = GetTime(),
                origin = message,
                source = "You",
                target = target,
                spellName = spellName,
                spellType = "INSTANT",
                spellStage = "TICK",
                effect = "HEAL",
                heal = tonumber(heal),
                isCritical = not not critically
            }
        end
    end

    function SpellBook._parseCombatChatTrailerMessage(trailerMessage)
        if not trailerMessage or trailerMessage == "" then
            return
        end

        local amount
        -- ABSORB_TRAILER = " (%d absorbed)"
        amount = String.match(trailerMessage, " %((%d+) absorbed%)")
        if amount then
            return {
                damageAbsorbed = tonumber(amount)
            }
        end

        -- BLOCK_TRAILER = " (%d blocked)"
        amount = String.match(trailerMessage, " %((%d+) blocked%)")
        if amount then
            return {
                damageBlocked = tonumber(amount)
            }
        end

        -- RESIST_TRAILER = " (%d resisted)"
        amount = String.match(trailerMessage, " %((%d+) resisted%)")
        if amount then
            return {
                damageResisted = tonumber(amount)
            }
        end

        -- VULNERABLE_TRAILER = " (+%d vulnerability bonus)"
        amount = String.match(trailerMessage, " %(%+(%d+) vulnerability bonus%)")
        if amount then
            return {
                damageVulnerability = tonumber(amount)
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

    return SpellBook
end)()
