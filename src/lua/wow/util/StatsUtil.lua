local UnitDamage = UnitDamage
local UnitAttackPower = UnitAttackPower
local UnitAttackSpeed = UnitAttackSpeed
local GetCritChance = GetCritChance
local GetHitModifier = GetHitModifier
local UnitRangedDamage = UnitRangedDamage
local UnitRangedAttackPower = UnitRangedAttackPower
local GetRangedCritChance = GetRangedCritChance
local UnitDefense = UnitDefense
local UnitArmor = UnitArmor
local GetDodgeChance = GetDodgeChance
local GetParryChance = GetParryChance
local GetBlockChance = GetBlockChance
local GetShieldBlock = GetShieldBlock
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local GetSpellCritChance = GetSpellCritChance
local GetSpellHitModifier = GetSpellHitModifier
local UnitResistance = UnitResistance
local Map = Map

StatsUtil = (function()
    local StatsUtil = {}

    function StatsUtil.getAttackSheet(unit)
        local ap
        do
            local base, posBuff, negBuff = UnitAttackPower(unit)
            ap = (base + posBuff + negBuff) or 0
        end

        local rangedAp
        do
            local base, posBuff, negBuff = UnitRangedAttackPower(unit)
            rangedAp = (base + posBuff + negBuff) or 0
        end

        return {
            dps = StatsUtil._getMeleeDps(unit),
            ap = ap,
            critChance = GetCritChance and GetCritChance(), -- not on 1.12
            hitChance = GetHitModifier and GetHitModifier(), -- not on 1.12
            rangedDps = StatsUtil._getRangedDps(unit),
            rangedAp = rangedAp,
            rangedCritChance = GetRangedCritChance and GetRangedCritChance() -- not on 1.12
        }
    end

    function StatsUtil._getMeleeDps(unit)
        local mainHandMinDamage, mainHandMaxDamage, offhandMinDamage, offhandMaxDamage, posBuff, negBuff, multiplier = UnitDamage(unit)
        local mainHandCooldown, offhandCooldown = UnitAttackSpeed(unit) -- fist cooldown = 2.0
        local mainHandDph = ((mainHandMinDamage + mainHandMaxDamage) / 2 + posBuff + negBuff) * multiplier
        local buffedMeleeDps = mainHandDph / mainHandCooldown
        if offhandCooldown then
            local offhandDph = ((offhandMinDamage + offhandMaxDamage) / 2 + posBuff + negBuff) * multiplier
            local offhandDps = offhandDph / offhandCooldown
            local offhandMultiplier = 0.5 -- TODO may changed by talent
            buffedMeleeDps = buffedMeleeDps + offhandDps * offhandMultiplier
        end
        return buffedMeleeDps
    end

    function StatsUtil._getRangedDps(unit)
        -- including wand
        local buffedRangedDps
        local cooldown, minDamage, maxDamage, posBuff, negBuff, multiplier = UnitRangedDamage(unit)
        if cooldown and cooldown > 0 then
            local rangedDph = ((minDamage + maxDamage) / 2 + posBuff + negBuff) * multiplier
            buffedRangedDps = rangedDph / cooldown
        end

        return buffedRangedDps
    end

    function StatsUtil.getDefenseSheet(unit)
        local defenseRank = StatsUtil._getSheetDefenseRank(unit)
        local _, effectiveArmor, _, _, _ = UnitArmor(unit)
        return {
            defenseRank = defenseRank,
            armor = effectiveArmor,
            dodgeChance = GetDodgeChance(),
            parryChance = GetParryChance(),
            blockChance = GetBlockChance(),
            blockValue = GetShieldBlock and GetShieldBlock() -- not on 1.12
        }
    end

    function StatsUtil._getSheetDefenseRank(unit)
        local rank = 0
        for i = 1, GetNumSkillLines(), 1 do
            local skillName, _, _, base, _, bonus = GetSkillLineInfo(i)
            if (skillName == DEFENSE) then
                rank = base + bonus
                break
            end
        end
        if (rank == 0) then
            local baseRank, bonusRank = UnitDefense(unit)
            rank = baseRank + bonusRank
        end
        return rank
    end

    function StatsUtil.getSpellSheet(unit)
        return Map.merge(StatsUtil._getSpellDamages(unit), StatsUtil._getSpellResistances(unit))
    end

    function StatsUtil._getSpellDamages(unit)
        local holyBonus = GetSpellBonusDamage and GetSpellBonusDamage(2) -- not on 1.12
        local fireBonus = GetSpellBonusDamage and GetSpellBonusDamage(3)
        local natureBonus = GetSpellBonusDamage and GetSpellBonusDamage(4)
        local frostBonus = GetSpellBonusDamage and GetSpellBonusDamage(5)
        local shadowBonus = GetSpellBonusDamage and GetSpellBonusDamage(6)
        local arcaneBonus = GetSpellBonusDamage and GetSpellBonusDamage(7)
        local spellBonusDamage = math.min(holyBonus or 0, fireBonus or 0, natureBonus or 0, frostBonus or 0, shadowBonus or 0, arcaneBonus or 0)
        if spellBonusDamage == 0 then
            spellBonusDamage = nil
        end
        local spellBonusHealing = GetSpellBonusHealing and GetSpellBonusHealing() -- not on 1.12
        local spellCritChance = GetSpellCritChance and GetSpellCritChance() -- not on 1.12
        local spellHitChance = GetSpellHitModifier and GetSpellHitModifier() -- not on 1.12
        return {
            spellBonusDamage = spellBonusDamage,
            spellBonusHealing = spellBonusHealing,
            spellCritChance = spellCritChance,
            spellHitChance = spellHitChance,
            holyBonus = holyBonus,
            fireBonus = fireBonus,
            natureBonus = natureBonus,
            frostBonus = frostBonus,
            shadowBonus = shadowBonus,
            arcaneBonus = arcaneBonus
        }
    end

    function StatsUtil._getSpellResistances(unit)
        local holyResistance = UnitResistance(unit, 1)
        local fireResistance = UnitResistance(unit, 2)
        local natureResistance = UnitResistance(unit, 3)
        local frostResistance = UnitResistance(unit, 4)
        local shadowResistance = UnitResistance(unit, 5)
        local arcaneResistance = UnitResistance(unit, 6)
        return {
            holyResistance = holyResistance,
            fireResistance = fireResistance,
            natureResistance = natureResistance,
            frostResistance = frostResistance,
            shadowResistance = shadowResistance,
            arcaneResistance = arcaneResistance
        }
    end

    function StatsUtil.getSheet(unit, sheetName)
        if not unit then
            return
        end
        if sheetName == "attack" then
            return StatsUtil.getAttackSheet(unit)
        elseif sheetName == "defense" then
            return StatsUtil.getDefenseSheet(unit)
        elseif sheetName == "spell" then
            return StatsUtil.getSpellSheet(unit)
        end
    end

    return StatsUtil
end)()
