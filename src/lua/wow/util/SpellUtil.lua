local GetTime = GetTime
local GetSpellName = GetSpellName
local Map = Map
local String = String

SpellUtil = (function()
    local SpellUtil = {}

    -- index via search player's spellbook
    function SpellUtil.getSpellId(spellName, spellRank)
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

    function SpellUtil.getSpellTexture(spellId)
        return GetSpellTexture(spellId, BOOKTYPE_SPELL)
    end

    return SpellUtil
end)()
