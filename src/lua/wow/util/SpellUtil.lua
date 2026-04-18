local GetTime = GetTime
local GetSpellName = GetSpellName
local Map = Map
local String = String

SpellUtil = (function()
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

    return SpellBook
end)()
