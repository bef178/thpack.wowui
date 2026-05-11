local getPlayerSpell = UnitUtil.getPlayerSpell
local getPlayerSpellCooldownTime = UnitUtil.getPlayerSpellCooldownTime
local buffed = UnitUtil.buffed
local debuffed = UnitUtil.debuffed
local inCombat = UnitUtil.inCombat
local canAttack = UnitUtil.canAttack
local canAssist = UnitUtil.canAssist
local getUnitHp = UnitUtil.getUnitHp
local getPlayerActiveStance = UnitUtil.getPlayerActiveStance
local cast = UnitUtil.cast

local pda = pda

local _, classType = UnitClass("player")
if classType ~= "PALADIN" then
    return
end

-- protection paladin solo aoe
-- 输出有二。其一为「一键」，其二为奉献
-- 「一键」只讲光明圣印、智慧圣印、审判及神圣打击；飞锤、驱邪等需随机应变
local build = pda:newBuild()
build.name = "prot-pal-solo"
build.description = "prot pal solo aoe, for turtle wow"
build.spells = {}
build.slotModels = {}

function build:createSlotModels()
    self:_updateSpells()

    Array.clear(build.slotModels)

    for i = 1, 3 do
        local model = pda:newSlotModel()
        model.onClick = function(f, button)
            if model.spellTimeToCooldown == 0 then
                cast(model.spell, model.spellTargetUnit)
            end
        end
        Array.add(build.slotModels, model)
    end
    build.slotModels[3].y = -2
    build.slotModels[3].x = 0

    self:updateSlotModels()

    return build.slotModels
end

function build:_updateSpells()
    self.spells.protAura = getPlayerSpell("Devotion Aura")
    self.spells.retAura = getPlayerSpell("Retribution Aura")

    self.spells.mightBless = getPlayerSpell("Blessing of Might")
    self.spells.wisBless = getPlayerSpell("Blessing of Wisdom")
    -- self.spells.lightBless = getPlayerSpell("Blessing of Light")
    -- self.spells.salvationBless = getPlayerSpell("Blessing of Salvation") -- 拯救祝福
    self.spells.sanBless = getPlayerSpell("Blessing of Sanctuary") -- 庇护祝福
    self.spells.kingsBless = getPlayerSpell("Blessing of Kings")

    self.spells.rigSeal = getPlayerSpell("Seal of Righteousness")
    self.spells.cruSeal = getPlayerSpell("Seal of the Crusader")
    self.spells.wisSeal = getPlayerSpell("Seal of Wisdom")
    self.spells.ligSeal = getPlayerSpell("Seal of Light")
    self.spells.jusSeal = getPlayerSpell("Seal of Justice")
    self.spells.comSeal = getPlayerSpell("Seal of Command")
    self.spells.jud = getPlayerSpell("Judgement")

    self.spells.holyStrike = getPlayerSpell("Holy Strike")
    self.spells.crusaderStrike = getPlayerSpell("Crusader Strike")

    self.spells.holyShield = getPlayerSpell("Holy Shield")

    self.spells.consecration = getPlayerSpell("Consecration")
end

function build:updateSlotModels()
    self:_updateSlotModel(self.slotModels[1], self:_perStrategyCounterAttack())
    self:_updateSlotModel(self.slotModels[2], self:_recommendConsecration())
    self:_updateSlotModel(self.slotModels[3], self:_perStrategyRighteousnessStrike())
end

function build:_updateSlotModel(model, recommended)
    if not model then
        return
    end
    if not recommended then
        model.visible = false
        return
    end

    model.visible = recommended.spellTimeToCooldown < 2
    if not model.visible then
        return
    end

    model.spell = recommended.spell
    model.spellTexture = recommended.spell.spellTexture
    model.spellTargetUnit = recommended.spellTargetUnit
    model.spellTimeToCooldown = recommended.spellTimeToCooldown
    model.dim = recommended.spellTimeToCooldown > 0
    model.glowing = recommended.spellTimeToCooldown < 0.1
end

function build:_recommendAura()
    local protAura = build.spells.protAura
    local retAura = build.spells.retAura

    if not protAura and not retAura then
        return
    end

    local stance = getPlayerActiveStance()
    if not stance then
        local auraSpell = retAura or protAura
        return {
            spell = auraSpell,
            spellTimeToCooldown = getPlayerSpellCooldownTime(auraSpell)
        }
    end
end

-- XXX how to get buff source
function build:_recommendBless(preferredBless)
    local mightBless = build.spells.mightBless
    local wisBless = build.spells.wisBless
    local sanBless = build.spells.sanBless
    local kingsBless = build.spells.kingsBless

    if not UnitExists("target") or UnitIsUnit("target", "player") or canAttack("target") then
        -- targets myself

        local blessSpell = preferredBless or mightBless
        local buff = buffed(blessSpell)

        if inCombat() then
            if not buff or buff.buffTimeToLive < 5 then
                if blessSpell then
                    return {
                        spell = blessSpell,
                        spellTargetUnit = "player",
                        spellTimeToCooldown = getPlayerSpellCooldownTime(blessSpell)
                    }
                end
            end
        else
            if not buff or buff.buffTimeToLive < 30 then
                if blessSpell then
                    return {
                        spell = blessSpell,
                        spellTargetUnit = "player",
                        spellTimeToCooldown = getPlayerSpellCooldownTime(blessSpell)
                    }
                end
            end
        end
    elseif canAssist("target") and not UnitIsUnit("player", "target") then
        -- targets other friendly
        local blessSpell = nil
        do
            local a
            if UnitIsPlayer("target") then
                local _, c = UnitClass("target")
                if c == "WARRIOR" or c == "ROGUE" then
                    a = {kingsBless, mightBless, sanBless}
                elseif c == "MAGE" or c == "PRIEST" or c == "WARLOCK" then
                    a = {kingsBless, wisBless, sanBless}
                else
                    a = {kingsBless, wisBless, mightBless, sanBless}
                end
            elseif UnitPlayerControlled("target") then
                local t = UnitCreatureType("target")
                if t == "Beast" then
                    a = {kingsBless, mightBless, sanBless}
                end
            else
                local targetPowerType = UnitPowerType("target")
                if targetPowerType and targetPowerType == 0 then
                    a = {kingsBless, wisBless, sanBless}
                else
                    a = {kingsBless, mightBless, sanBless}
                end
            end
            if a then
                for _, v in ipairs(a) do
                    if v and not buffed(v, "target") then
                        blessSpell = v
                        break
                    end
                end
            end
        end
        if blessSpell then
            return {
                spell = blessSpell,
                spellTargetUnit = "target",
                spellTimeToCooldown = getPlayerSpellCooldownTime(blessSpell)
            }
        end
    end
end

function build:_recommendWisdomSeal()
    local rigSeal = build.spells.rigSeal
    local cruSeal = build.spells.cruSeal
    local wisSeal = build.spells.wisSeal
    local ligSeal = build.spells.ligSeal
    local jusSeal = build.spells.jusSeal
    local comSeal = build.spells.comSeal
    local jud = build.spells.jud

    if not wisSeal or not ligSeal then
        return
    end

    local playerInCombat = inCombat()
    local targetAttackable = canAttack("target")

    local wisBuff = buffed(wisSeal)
    local ligBuff = buffed(ligSeal)
    local wisTargetDebuff = debuffed(wisSeal, "target")
    local ligTargetDebuff = debuffed(ligSeal, "target")

    local otherSealBuff
    do
        for i, v in ipairs({rigSeal, cruSeal, jusSeal, comSeal}) do
            if buffed(v) then
                otherSealBuff = i
                break
            end
        end
    end

    if otherSealBuff or ligTargetDebuff and wisTargetDebuff then
        return build:_recommendRighteousnessSeal()
    elseif ligTargetDebuff then
        if ligBuff then
            if ligBuff.buffTimeToLive < 2 then
                -- TODO do recommend after checking health fraction and mana fraction
                if wisSeal then
                    return {
                        spell = wisSeal,
                        spellTimeToCooldown = getPlayerSpellCooldownTime(wisSeal)
                    }
                end
            else
            end
        elseif wisBuff then
            if wisBuff.buffTimeToLive < 2 then
                if wisSeal then
                    return {
                        spell = wisSeal,
                        spellTimeToCooldown = getPlayerSpellCooldownTime(wisSeal)
                    }
                end
            else
            end
        else
            if wisSeal then
                return {
                    spell = wisSeal,
                    spellTimeToCooldown = getPlayerSpellCooldownTime(wisSeal)
                }
            end
        end
    elseif wisTargetDebuff then
        if ligBuff then
            if ligBuff.buffTimeToLive < 2 then
                if ligSeal then
                    return {
                        spell = ligSeal,
                        spellTimeToCooldown = getPlayerSpellCooldownTime(ligSeal)
                    }
                end
            else
            end
        elseif wisBuff then
            if wisBuff.buffTimeToLive < 2 then
                if ligSeal then
                    return {
                        spell = ligSeal,
                        spellTimeToCooldown = getPlayerSpellCooldownTime(ligSeal)
                    }
                end
            else
            end
        else
            if ligSeal then
                return {
                    spell = ligSeal,
                    spellTimeToCooldown = getPlayerSpellCooldownTime(ligSeal)
                }
            end
        end
    else
        if ligBuff then
            if jud then
                if playerInCombat or targetAttackable then
                    return {
                        spell = jud,
                        spellTargetUnit = "target",
                        spellTimeToCooldown = getPlayerSpellCooldownTime(jud)
                    }
                end
            end
        elseif wisBuff then
            if jud then
                if playerInCombat or targetAttackable then
                    return {
                        spell = jud,
                        spellTargetUnit = "target",
                        spellTimeToCooldown = getPlayerSpellCooldownTime(jud)
                    }
                end
            end
        else
            if wisSeal then
                return {
                    spell = wisSeal,
                    spellTimeToCooldown = getPlayerSpellCooldownTime(wisSeal)
                }
            end
        end
    end
end

function build:_recommendRighteousnessSeal()
    local rigSeal = build.spells.rigSeal
    local cruSeal = build.spells.cruSeal
    local wisSeal = build.spells.wisSeal
    local ligSeal = build.spells.ligSeal
    local jusSeal = build.spells.jusSeal
    local comSeal = build.spells.comSeal
    local jud = build.spells.jud

    if not rigSeal then
        return
    end

    if not canAttack("target") then
        return
    end

    local which = nil
    do
        for i, v in ipairs({rigSeal, cruSeal, wisSeal, ligSeal, jusSeal, comSeal}) do
            if buffed(v) then
                which = i
                break
            end
        end
    end

    if which == nil then
        if rigSeal then
            return {
                spell = rigSeal,
                spellTimeToCooldown = getPlayerSpellCooldownTime(rigSeal)
            }
        end
    elseif jud and which == 1 then
        local rigTimeToCooldown = getPlayerSpellCooldownTime(rigSeal)
        local judTimeToCooldown = getPlayerSpellCooldownTime(jud)

        -- keep Righteousness Seal always
        return {
            spell = jud,
            spellTargetUnit = "target",
            spellTimeToCooldown = Math.max(judTimeToCooldown, rigTimeToCooldown)
        }
    end
end

-- TODO check equipped shield
function build:_recommendHolyShield()
    local spell = build.spells.holyShield

    if not spell then
        return
    end

    local _, _, proportion = getUnitHp("player")
    if proportion < 0.85 then
        if inCombat() or canAttack("target") then
            -- should check both buff time and cooldown time
            -- but buff time is always less than or equal to cooldown time
            -- so, it is OK to ignore buff time
            return {
                spell = spell,
                spellTimeToCooldown = getPlayerSpellCooldownTime(spell)
            }
        end
    end
end

function build:_recommendStrike(preferredStrike)
    local strikeSpell = preferredStrike or build.spells.holyStrike
    if strikeSpell then
        if inCombat() or canAttack("target") then
            return {
                spell = strikeSpell,
                spellTargetUnit = "target",
                spellTimeToCooldown = getPlayerSpellCooldownTime(strikeSpell)
            }
        end
    end
end

function build:_recommendConsecration()
    local spell = build.spells.consecration

    if not spell then
        return
    end

    if inCombat() then
        return {
            spell = spell,
            spellTimeToCooldown = getPlayerSpellCooldownTime(spell)
        }
    end
end

function build:_oneBest(candidates)
    if not candidates then
        return
    end
    local best
    for _, candidate in ipairs(candidates) do
        if candidate then
            if not best then
                best = candidate
                if best.spellTimeToCooldown == 0 then
                    break
                end
            else
                if best.spellTimeToCooldown > candidate.spellTimeToCooldown then
                    best = candidate
                    if best.spellTimeToCooldown == 0 then
                        break
                    end
                end
            end
        end
    end
    if best then
        return best
    end
end

function build:_perStrategyCounterAttack()
    return build:_oneBest({
        build:_recommendAura() or false,
        build:_recommendBless(build.spells.sanBless) or false,
        build:_recommendWisdomSeal() or false,
        build:_recommendHolyShield() or false,
        build:_recommendStrike() or false
    })
end

function build:_perStrategyRighteousnessStrike()
    return build:_oneBest({
        build:_recommendAura() or false,
        build:_recommendBless() or false,
        build:_recommendRighteousnessSeal() or false,
        build:_recommendStrike(build.spells.crusaderStrike) or false
    })
end

pda:register(build)

Util.addSlashCommand("aPdaProtPaladinCounterAttack", "/pdaportpaladincounterattack", function()
    local o = build:_perStrategyCounterAttack()
    if o and o.spellTimeToCooldown == 0 then
        cast(o.spell, o.spellTargetUnit)
    end
end)

Util.addSlashCommand("aPdaProtPaladinRighteousStrike", "/pdaprotpaladinrighteousstrike", function()
    local o = build:_perStrategyRighteousnessStrike()
    if o and o.spellTimeToCooldown == 0 then
        cast(o.spell, o.spellTargetUnit)
    end
end)
