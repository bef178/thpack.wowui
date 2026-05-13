local getPlayerSpell = UnitUtil.getPlayerSpell
local getPlayerSpellCooldownTime = UnitUtil.getPlayerSpellCooldownTime
local buffed = UnitUtil.buffed
local inCombat = UnitUtil.inCombat
local canAttack = UnitUtil.canAttack
local getUnitHp = UnitUtil.getUnitHp
local getPlayerActiveStance = UnitUtil.getPlayerActiveStance
local cast = UnitUtil.cast

local pda = pda

local _, classType = UnitClass("player")
if classType ~= "WARRIOR" then
    return
end

local function getStanceCooldownEndTime(stanceIndex)
    local startTime, duration, _ = GetShapeshiftFormCooldown(stanceIndex)
    if duration and duration > 0 then
        return startTime + duration
    end
    return 0
end

local function getStanceCooldownRemainingSeconds(stanceIndex)
    local seconds = getStanceCooldownEndTime(stanceIndex) - GetTime()
    if seconds < 0 then
        return 0
    else
        return seconds
    end
end

local function getMainHandWeaponDph()
    local base, posBuff, negBuff = UnitAttackPower("player")
    local ap = base + posBuff + negBuff
    local mainHandSpeed = UnitAttackSpeed("player") or 2.0
    local minDph, maxDph = UnitDamage("player")
    local apDph = ap / 14 * mainHandSpeed
    return minDph - apDph, maxDph - apDph
end

local function getFlurryTalentRankAndTexture()
    local tabIndex = 2
    for i = 1, GetNumTalents(tabIndex) do
        local name, texture, _, _, rank = GetTalentInfo(tabIndex, i)
        if name == "Flurry" then
            return rank, texture
        end
    end
    return 0
end

-- fury warrior dungeon/raid rotation
local build = pda:newBuild()
build.name = "fury-warrior"
build.description = "fury warrior dungeon/raid rotation"
build.spells = {}
build.slotModels = {}

build._flurryTalentRank = 0
build._flurryTalentTexture = nil

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHARACTER_POINTS_CHANGED")
f:SetScript("OnEvent", function()
    build._flurryTalentRank, build._flurryTalentTexture = getFlurryTalentRankAndTexture()
end)

build._overpowerBuffs = {}
build._revengeBuffs = {}

CastUtil.register(function(event)
    if not event then
        return
    end
    if event.source == "You" and event.isDodged then
        local now = GetTime()
        Array.add(build._overpowerBuffs, {
            startTime = now,
            endTime = now + 5
        })
    end
    if event.target == "You" and (event.isDodged or event.isParried or event.blocked) then
        local now = GetTime()
        Array.add(build._revengeBuffs, {
            startTime = now,
            endTime = now + 5
        })
    end
    if event.source == "You" and event.spellName == "Overpower" and event.spellStage == "TICK" then
        Array.remove(build._overpowerBuffs, 1)
    end
    if event.source == "You" and event.spellName == "Revenge" and event.spellStage == "TICK" then
        Array.remove(build._revengeBuffs, 1)
    end
end)

function build:createSlotModels()
    self:_updateSpells()

    Array.clear(build.slotModels)

    for i = 1, 4 do
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

function build:_updateSpells()
    self.spells.overpower = getPlayerSpell("Overpower")
    self.spells.revenge = getPlayerSpell("Revenge")
    self.spells.bloodthirst = getPlayerSpell("Bloodthirst")
    self.spells.whirlwind = getPlayerSpell("Whirlwind")
    self.spells.hamstring = getPlayerSpell("Hamstring")
    self.spells.execute = getPlayerSpell("Execute")
    self.spells.battleshout = getPlayerSpell("Battle Shout")
end

function build:updateSlotModels()
    self:_updateSlotModel(self.slotModels[1], self:_perStrategyFury())
    self:_updateSlotModel(self.slotModels[2], self:_recommendOverpower())
    self:_updateSlotModel(self.slotModels[3], self:_recommendRevenge())
    self:_updateSlotModel(self.slotModels[4], self:_recommendExecute())
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
    model.spellStacks = recommended.spellStacks
    model.dim = recommended.dim or recommended.spellTimeToCooldown > 0
    model.glowing = recommended.glowing
end

function build:_recommendOverpower()
    local spell = self.spells.overpower
    if not spell then
        return
    end

    if not canAttack("target") then
        return
    end

    local now = GetTime()
    local cooldownEndTime = now + getPlayerSpellCooldownTime(spell)
    while Array.size(self._overpowerBuffs) > 0 do
        local buff = self._overpowerBuffs[1]
        if buff.endTime < now or buff.endTime < cooldownEndTime then
            -- retire expired
            Array.remove(self._overpowerBuffs, 1)
        else
            break
        end
    end

    local stacks = Array.size(self._overpowerBuffs)
    if stacks == 0 then
        return
    end

    local stance = getPlayerActiveStance()
    local inBattleStance = stance and stance.stanceIndex == 1

    if not inBattleStance and getStanceCooldownRemainingSeconds(1) > 0.1 then
        return
    end

    local lastBuff = self._overpowerBuffs[stacks]
    local ttl = lastBuff and (lastBuff.endTime - now) or 0

    local rage = UnitMana("player")

    return {
        spell = spell,
        spellTargetUnit = "target",
        spellTimeToLive = ttl,
        spellTimeToCooldown = getPlayerSpellCooldownTime(spell),
        spellStacks = stacks,
        glowing = inBattleStance or rage < 23
    }
end

function build:_recommendRevenge()
    local spell = self.spells.revenge
    if not spell then
        return
    end

    if not canAttack("target") then
        return
    end

    local now = GetTime()
    local cooldownEndTime = now + getPlayerSpellCooldownTime(spell)
    while Array.size(self._revengeBuffs) > 0 do
        local buff = self._revengeBuffs[1]
        if buff.endTime < now or buff.endTime < cooldownEndTime then
            Array.remove(self._revengeBuffs, 1)
        else
            break
        end
    end

    local stacks = Array.size(self._revengeBuffs)
    if stacks == 0 then
        return
    end

    local stance = getPlayerActiveStance()
    local inDefensiveStance = stance and stance.stanceIndex == 2

    if not inDefensiveStance and getStanceCooldownRemainingSeconds(2) > 0.1 then
        return
    end

    local lastBuff = self._revengeBuffs[stacks]
    local ttl = lastBuff and (lastBuff.endTime - now) or 0

    return {
        spell = spell,
        spellTargetUnit = "target",
        spellTimeToLive = ttl,
        spellTimeToCooldown = getPlayerSpellCooldownTime(spell),
        spellStacks = stacks,
        glowing = inDefensiveStance
    }
end

function build:_recommendBloodthirst()
    local spell = self.spells.bloodthirst
    if not spell then
        return
    end

    if not inCombat() or not canAttack("target") then
        return
    end

    local cooldown = getPlayerSpellCooldownTime(spell)
    if cooldown > 1 then
        return
    end

    return {
        spell = spell,
        spellTargetUnit = "target",
        spellTimeToCooldown = cooldown,
        glowing = true
    }
end

function build:_recommendWhirlwind()
    local spell = self.spells.whirlwind
    if not spell then
        return
    end

    if not inCombat() or not canAttack("target") then
        return
    end

    local cooldown = getPlayerSpellCooldownTime(spell)
    if cooldown > 1 then
        return
    end

    local bloodthirst = self.spells.bloodthirst
    local btCooldown = bloodthirst and getPlayerSpellCooldownTime(bloodthirst) or 999
    if btCooldown < 1.5 then
        return
    end

    local _, weaponMaxDph = getMainHandWeaponDph()
    local rage = UnitMana("player")
    if weaponMaxDph > 150 then
        if rage < 60 then
            return
        end
    else
        if rage < 85 then
            return
        end
    end

    return {
        spell = spell,
        spellTargetUnit = "target",
        spellTimeToCooldown = cooldown,
        glowing = true
    }
end

-- 毛乱舞
function build:_recommendHamstring()
    local spell = self.spells.hamstring
    if not spell then
        return
    end

    if not inCombat() or not canAttack("target") then
        return
    end

    local rage = UnitMana("player")
    if rage < 70 then
        return
    end

    if self._flurryTalentRank == 0 then
        return
    end

    if buffed({spellTexture = self._flurryTalentTexture}) then
        return
    end

    local bloodthirst = self.spells.bloodthirst
    local whirlwind = self.spells.whirlwind
    local btCooldown = bloodthirst and getPlayerSpellCooldownTime(bloodthirst) or 999
    local wwCooldown = whirlwind and getPlayerSpellCooldownTime(whirlwind) or 999
    if btCooldown < 1.5 or wwCooldown < 1.5 then
        return
    end

    return {
        spell = spell,
        spellTargetUnit = "target",
        spellTimeToCooldown = getPlayerSpellCooldownTime(spell)
    }
end

function build:_recommendExecute()
    local spell = self.spells.execute
    if not spell then
        return
    end

    if not canAttack("target") then
        return
    end

    local _, _, proportion = getUnitHp("target")
    if proportion >= 0.215 then
        return
    end

    local cooldown = getPlayerSpellCooldownTime(spell)
    local dim = proportion > 0.2

    return {
        spell = spell,
        spellTargetUnit = "target",
        spellTimeToCooldown = cooldown,
        dim = dim,
        glowing = not dim and cooldown == 0
    }
end

function build:_recommendBattleShout()
    local spell = self.spells.battleshout
    if not spell then
        return
    end

    local buff = buffed(spell)
    local buffTtl = buff and buff.buffTimeToLive or 0

    local rage = UnitMana("player")
    if rage < 10 then
        return
    end

    if inCombat() then
        if buffTtl < 2 then
            return {
                spell = spell,
                spellTimeToCooldown = getPlayerSpellCooldownTime(spell)
            }
        end
    else
        if buffTtl < 10 then
            return {
                spell = spell,
                spellTimeToCooldown = getPlayerSpellCooldownTime(spell)
            }
        end
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
                    if best.spellTimeToCooldown < 0.01 then
                        break
                    end
                end
            end
        end
    end
    return best
end

function build:_perStrategyFury()
    return self:_oneBest({
        self:_recommendBloodthirst() or false,
        self:_recommendWhirlwind() or false,
        self:_recommendBattleShout() or false,
        self:_recommendHamstring() or false
    })
end

pda:register(build)

Util.addSlashCommand("aPdaFuryWarrior", "/pdafurywarrior", function()
    local o = build:_oneBest({
        build:_recommendOverpower() or false,
        build:_perStrategyFury() or false
    })
    if o and o.spellTimeToCooldown == 0 then
        cast(o.spell, o.spellTargetUnit)
    end
end)
