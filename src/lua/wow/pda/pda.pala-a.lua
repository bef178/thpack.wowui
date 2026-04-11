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

local _, class = UnitClass("player")
if class ~= "PALADIN" then
    return
end

local function palRecommendAura(favAura)
    local protAura = getPlayerSpell("Devotion Aura")
    local retAura = getPlayerSpell("Retribution Aura")

    if not protAura and not retAura then
        return
    end

    local stance = getPlayerActiveStance()
    if not stance then
        if favAura == "retribution" or favAura == "ret" or favAura == "r" then
            favAura = retAura
        elseif (type(favAura) == "string") then
            favAura = getPlayerSpell(favAura)
        end
        local auraSpell = favAura or protAura
        if auraSpell then
            return {
                spell = auraSpell,
                spellTimeToCooldown = getPlayerSpellCooldownTime(auraSpell)
            }
        end
    end
end

-- XXX how to get buff source
local function palRecommendBless(favBless)
    local migBless = getPlayerSpell("Blessing of Might")
    local wisBless = getPlayerSpell("Blessing of Wisdom")
    local ligBless = getPlayerSpell("Blessing of Light")
    local salBless = getPlayerSpell("Blessing of Salvation")
    local sanBless = getPlayerSpell("Blessing of Sanctuary")
    local kinBless = getPlayerSpell("Blessing of Kings")

    local playerInCombat = inCombat()
    local targetAttackable = canAttack("target")

    if not UnitExists("target") or UnitIsUnit("target", "player") or targetAttackable then
        -- targets myself

        if favBless == "sanctuary" or favBless == "san" or favBless == "s" then
            favBless = sanBless
        elseif (type(favBless) == "string") then
            favBless = getPlayerSpell(favBless)
        end
        local blessSpell = favBless or migBless

        local buff = buffed(blessSpell)

        if playerInCombat then
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
    elseif (canAssist("target") and not UnitIsUnit("player", "target")) then
        -- targets other friendly
        local blessSpell = nil
        do
            local a
            if UnitIsPlayer("target") then
                local _, c = UnitClass("target")
                if c == "WARRIOR" or c == "ROGUE" then
                    a = {
                        kinBless,
                        migBless,
                        sanBless
                    }
                elseif (c == "MAGE" or c == "PRIEST" or c == "WARLOCK") then
                    a = {
                        kinBless,
                        wisBless,
                        sanBless
                    }
                else
                    a = {
                        kinBless,
                        wisBless,
                        migBless,
                        sanBless
                    }
                end
            elseif (UnitPlayerControlled("target")) then
                local t = UnitCreatureType("target")
                if t == "Beast" then
                    a = {
                        kinBless,
                        migBless,
                        sanBless
                    }
                end
            else
                local targetPowerType = UnitPowerType("target")
                if targetPowerType and targetPowerType == 0 then
                    a = {
                        kinBless,
                        wisBless,
                        sanBless
                    }
                else
                    a = {
                        kinBless,
                        migBless,
                        sanBless
                    }
                end
            end
            if a then
                for _, v in pairs(a) do
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

-- TODO check equipped shield
local function palRecommendHolyShield()
    local spell = getPlayerSpell("Holy Shield")

    if not spell then
        return
    end

    local _, _, proportion = getUnitHp("player")
    if proportion < 0.85 then
        if inCombat() or canAttack("target") then
            -- should check both buff time and cooldown time
            -- due to buff time is always less than or equal to cooldown time
            -- so, it is OK to ignore buff time
            if spell then
                return {
                    spell = spell,
                    spellTimeToCooldown = getPlayerSpellCooldownTime(spell)
                }
            end
        end
    end
end

local function palRecommendRigSeal()
    local rigSeal = getPlayerSpell("Seal of Righteousness")
    local cruSeal = getPlayerSpell("Seal of Crusader")
    local wisSeal = getPlayerSpell("Seal of Wisdom")
    local ligSeal = getPlayerSpell("Seal of Light")
    local jusSeal = getPlayerSpell("Seal of Justice")
    local comSeal = getPlayerSpell("Seal of Command")
    local jud = getPlayerSpell("Judgement")
    local holyStrike = getPlayerSpell("Holy Strike")

    if not rigSeal then
        return
    end

    local which = nil
    do
        for i, v in ipairs({
            rigSeal,
            cruSeal,
            wisSeal,
            ligSeal,
            jusSeal,
            comSeal
        }) do
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
    elseif (which == 1) then
        -- in close combat [Holy Strike] is piror to [Judgement]
        if holyStrike then
            return {
                spell = holyStrike,
                spellTargetUnit = "target",
                spellTimeToCooldown = getPlayerSpellCooldownTime(holyStrike)
            }
        end
        -- if [Seal of Righteousness] is not ready, don't recommend [Judgement] or may miss the incidental holy damage
        if jud then
            return {
                spell = jud,
                spellTargetUnit = "target",
                spellTimeToCooldown = Math.max(getPlayerSpellCooldownTime(jud), getPlayerSpellCooldownTime(rigSeal))
            }
        end
    end
end

local function palRecommendWisSeal()
    local rigSeal = getPlayerSpell("Seal of Righteousness")
    local cruSeal = getPlayerSpell("Seal of Crusader")
    local wisSeal = getPlayerSpell("Seal of Wisdom")
    local ligSeal = getPlayerSpell("Seal of Light")
    local jusSeal = getPlayerSpell("Seal of Justice")
    local comSeal = getPlayerSpell("Seal of Command")
    local jud = getPlayerSpell("Judgement")

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
        for i, v in ipairs({
            rigSeal,
            cruSeal,
            jusSeal,
            comSeal
        }) do
            if buffed(v) then
                otherSealBuff = i
                break
            end
        end
    end

    if otherSealBuff or ligTargetDebuff and wisTargetDebuff then
        return palRecommendRigSeal()
    elseif (ligTargetDebuff) then
        if ligBuff then
            if ligBuff.buffTimeToLive < 2 then
                -- TODO check health proportion and mana proportion then make recommendation
                if wisSeal then
                    return {
                        spell = wisSeal,
                        spellTimeToCooldown = getPlayerSpellCooldownTime(wisSeal)
                    }
                end
            else
            end
        elseif (wisBuff) then
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
    elseif (wisTargetDebuff) then
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
        elseif (wisBuff) then
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

local function palRecommendStrike(favStrike)
    local holyStrike = getPlayerSpell("Holy Strike")

    if favStrike == "holy" or favStrike == "h" then
        favStrike = holyStrike
    elseif (type(favStrike) == "string") then
        favStrike = getPlayerSpell(favStrike)
    end
    local strike = favStrike or holyStrike

    if strike then
        if inCombat() or canAttack("target") then
            return {
                spell = strike,
                spellTargetUnit = "target",
                spellTimeToCooldown = getPlayerSpellCooldownTime(strike)
            }
        end
    end
end

local function palRecommendConsecration()
    local spell = getPlayerSpell("Consecration")

    if not spell then
        return
    end

    if inCombat() then
        if spell then
            return {
                spell = spell,
                spellTimeToCooldown = getPlayerSpellCooldownTime(spell)
            }
        end
    end
end

local function palRecommend(strategy)
    local config
    if strategy == "righteoushammer" then
        config = {
            {
                palRecommendAura,
                "retribution"
            },
            {
                palRecommendBless
            },
            {
                palRecommendRigSeal
            }
        }
    elseif (strategy == "counterattack") then
        config = {
            {
                palRecommendAura,
                "retribution"
            },
            {
                palRecommendBless,
                "sanctuary"
            },
            {
                palRecommendWisSeal
            },
            {
                palRecommendHolyShield
            },
            {
                palRecommendStrike
            }
        }
    end
    if config then
        local best
        for _, v in ipairs(config) do
            local recommended = v[1](v[2])
            if recommended then
                if not best then
                    best = recommended
                    if best.spellTimeToCooldown == 0 then
                        break
                    end
                else
                    if best.spellTimeToCooldown > recommended.spellTimeToCooldown then
                        best = recommended
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
end

paladinCombo = function(strategy)
    if strategy ~= "counterattack" then
        strategy = "righteoushammer"
    end
    local a = palRecommend(strategy)
    if a and a.spellTimeToCooldown == 0 then
        cast(a.spell, a.spellTargetUnit)
    end
end

-- prot pal aoe
-- 输出有二。其一为「一键」，其二为奉献
-- 「一键」只讲光明圣印、智慧圣印、审判及神圣打击；飞锤、驱邪等需随机应变
-- 空，表示无须关注。如长CD，无施法材料(含buff、连击点)，或机制不满足(如压制、斩杀)
-- 暗，表示施放条件不具备，但可能即将具备
-- 亮，表示可以施放
-- 高亮，表示应立即施放

local build = pda:newBuild()
build.name = "pal-a"
build.description = "prot pal solo aoe, for turtle wow"
build.slotModels = {}

function build:createSlotModels()
    Array.clear(build.slotModels)

    for i = 1, 2 do
        local model = pda:newSlotModel()
        model.onClick = function(f, button)
            if model.spellTimeToCooldown == 0 then
                cast(model.spell, model.spellTargetUnit)
            end
        end
        Array.add(build.slotModels, model)
    end

    self:updateSlotModels()

    return build.slotModels
end

function build:updateSlotModels()
    if self.slotModels[1] then
        self:_updateSlotModel(self.slotModels[1], palRecommend("counterattack"))
    end
    if self.slotModels[2] then
        self:_updateSlotModel(self.slotModels[2], palRecommendConsecration())
    end
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
    model.spellReadyToCast = recommended.spellTimeToCooldown == 0
    model.glowing = recommended.spellTimeToCooldown < 0.1
end

pda:register(build)
