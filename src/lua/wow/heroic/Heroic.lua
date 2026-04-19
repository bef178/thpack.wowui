local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local GetTime = GetTime
local hookScript = Util.hookScript
local getResource = Util.getResource
local getClassColor = Util.getClassColor

-- war3 hero layout
Heroic = (function()
    local Heroic = {}

    function Heroic.createUnitFrame(unit, width, height)
        unit = string.lower(unit)

        -- transparent
        local uf = CreateFrame("Button", nil, UIParent, nil)
        uf.unit = unit
        uf:SetWidth(width)
        uf:SetHeight(height)

        local barHeight = 4
        local margin = 2

        Heroic._enablePortrait(uf, margin)
        Heroic._enableHealthBar(uf, barHeight, margin)
        Heroic._enableManaBar(uf, barHeight, margin)
        Heroic._enableCastBar(uf, barHeight, margin)
        Heroic._enableRaidMark(uf, 12, 12)
        Heroic._enablePressedEffect(uf, 3)
        Heroic._enableDeadGlowEffect(uf)
        Heroic._enableUnderAttackEffect(uf)
        Heroic._enableFreeTalentPointGlowEffect(uf)

        uf:SetScript("OnEnter", function()
            local self = uf
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
        end)
        uf:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        uf:SetScript("OnClick", function()
            local button = arg1
            if button == "LeftButton" then
                TargetUnit(unit)
            end
        end)

        -- RegisterUnitWatch(uf)

        return uf
    end

    function Heroic._enablePortrait(uf, margin)
        local portraitFrame = CreateFrame("Frame", nil, uf, nil)
        portraitFrame:SetBackdrop({
            bgFile = getResource("tile32"),
            insets = {
                left = -margin,
                right = -margin,
                top = -margin,
                bottom = -margin
            }
        })
        portraitFrame:SetBackdropColor(0, 0, 0, 0.85)
        portraitFrame:SetAllPoints()

        local portraitTexture = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 1)
        portraitTexture:SetPoint("TOPLEFT", margin, -margin)
        portraitTexture:SetPoint("BOTTOMRIGHT", -margin, margin)
        portraitFrame.portraitTexture = portraitTexture

        portraitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        portraitFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
        portraitFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        -- portraitFrame:RegisterEvent("UNIT_MODEL_CHANGED")
        portraitFrame:SetScript("OnEvent", function()
            local event = event
            if event == "PLAYER_ENTERING_WORLD" then
                Heroic._invalidatePortraitTexture(portraitTexture, uf.unit)
                local _, classType = UnitClass(unit)
                local colorString = getClassColor(classType) or "#FFFFFF"
                portraitFrame:SetBackdropBorderColor(Color.toVertex(colorString))
            elseif event == "UNIT_PORTRAIT_UPDATE" or event == "PARTY_MEMBER_ENABLE" then
                local unit = arg1
                if unit == nil or unit ~= uf.unit then
                    return
                end
                Heroic._invalidatePortraitTexture(portraitTexture, unit)
            elseif event == "UNIT_MODEL_CHANGED" then
                local unit = arg1
                if unit == nil or unit ~= uf.unit then
                    return
                end
                Heroic._invalidatePortraitModel(portrait3d, unit)
            end
        end)

        uf.portraitFrame = portraitFrame

        -- TODO update hostile
        -- TODO [[Interface\WorldStateFrame\Icons-Classes]] and texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classType]));
    end

    function Heroic._invalidatePortraitTexture(portraitTexture, unit)
        if UnitIsConnected(unit) then
            -- TODO square portrait
            portraitTexture:SetTexCoord(5 / 64, 59 / 64, 5 / 64, 59 / 64)
            SetPortraitTexture(portraitTexture, unit)
        else
            portraitTexture:SetTexCoord(5 / 64, 59 / 64, 5 / 64, 59 / 64)
            portraitTexture:SetTexture([[interface\icons\inv_misc_questionmark]])
        end
    end

    function Heroic._invalidatePortraitModel(portrait3d, unit)
        portrait3d:ClearModel()
        if UnitIsVisible(unit) then
            portrait3d:SetUnit(unit)
            if portrait3d:GetModel() == [[Character\Worgen\Male\WorgenMale.m2]] then
                portrait3d:SetCamera(1)
            else
                portrait3d:SetCamera(0)
            end
        else
            portrait3d:SetModel([[Interface\Buttons\TalkToMeQuestionMark.mdx]])
            portrait3d:SetModelScale(2.5)
            portrait3d:SetPosition(0, 0, -0.25)
        end
    end

    function Heroic._createStatusBar(uf, height, margin)
        local bar = CreateFrame("StatusBar", nil, uf, nil)
        bar:SetHeight(height)
        bar:SetStatusBarTexture(getResource("healthbar32"))
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(0.7749)
        bar:SetBackdrop({
            bgFile = getResource("tile32"),
            insets = {
                left = -margin,
                right = -margin,
                top = -margin,
                bottom = -margin
            }
        })
        bar:SetBackdropColor(0, 0, 0, 0.85)
        return bar
    end

    function Heroic._enableHealthBar(uf, height, margin)
        local healthBar = Heroic._createStatusBar(uf, height, margin)
        -- healthBar:SetPoint("BOTTOMLEFT", uf.portraitFrame, "BOTTOMLEFT", margin, margin)
        -- healthBar:SetPoint("BOTTOMRIGHT", uf.portraitFrame, "BOTTOMRIGHT", -margin, margin)
        healthBar:SetPoint("TOPLEFT", uf.portraitFrame, "BOTTOMLEFT", 0, 0)
        healthBar:SetPoint("TOPRIGHT", uf.portraitFrame, "BOTTOMRIGHT", 0, 0)

        healthBar:RegisterEvent("PLAYER_ENTERING_WORLD")
        healthBar:RegisterEvent("UNIT_HEALTH")
        healthBar:RegisterEvent("UNIT_MAXHEALTH")
        healthBar:SetScript("OnEvent", function()
            local event = event
            if event == "PLAYER_ENTERING_WORLD" then
                Heroic._invalidateHealthBar(healthBar, uf.unit)
            else
                local unit = arg1
                if unit == nil or unit ~= uf.unit then
                    return
                end
                Heroic._invalidateHealthBar(healthBar, unit)
            end
        end)

        uf.healthBar = healthBar
    end

    function Heroic._invalidateHealthBar(healthBar, unit)
        if healthBar == nil or unit == nil then
            return
        end

        local value = UnitHealth(unit)
        local maxValue = UnitHealthMax(unit)
        local fraction = value / maxValue
        if fraction < 0.001 then
            fraction = 0
        elseif fraction > 0.999 then
            fraction = 1
        end
        healthBar:SetValue(fraction)

        local dangerousLine = 0.2 -- 斩杀线
        local safeLine = 0.7
        if fraction <= dangerousLine then
            healthBar:SetStatusBarColor(1, 0, 0)
        elseif fraction >= safeLine then
            healthBar:SetStatusBarColor(0, 1, 0)
        else
            local p = (fraction - dangerousLine) / (safeLine - dangerousLine)
            if p > 0.5 then
                healthBar:SetStatusBarColor((1 - p) * 2, 1, 0)
            else
                -- go down red
                healthBar:SetStatusBarColor(1, p * 2, 0)
            end
        end

        if healthBar.valueTextRegion then
            healthBar.valueTextRegion:SetText(value)
        end
    end

    function Heroic._enableManaBar(uf, height, margin)
        if uf.healthBar == nil then
            return
        end

        -- uf.healthBar:ClearAllPoints()
        -- uf.healthBar:SetPoint("BOTTOMLEFT", uf.portraitFrame, "BOTTOMLEFT", 0, margin + height)
        -- uf.healthBar:SetPoint("BOTTOMRIGHT", uf.portraitFrame, "BOTTOMRIGHT", 0, margin + height)

        local manaBar = Heroic._createStatusBar(uf, height, margin)
        manaBar:SetPoint("TOPLEFT", uf.healthBar, "BOTTOMLEFT", 0, -margin)
        manaBar:SetPoint("TOPRIGHT", uf.healthBar, "BOTTOMRIGHT", 0, -margin)

        manaBar:RegisterEvent("PLAYER_ENTERING_WORLD")
        manaBar:RegisterEvent("UNIT_MANA")
        manaBar:RegisterEvent("UNIT_RAGE")
        manaBar:RegisterEvent("UNIT_FOCUS")
        manaBar:RegisterEvent("UNIT_ENERGY")
        manaBar:RegisterEvent("UNIT_HAPPINESS")
        manaBar:RegisterEvent("UNIT_MAXMANA")
        manaBar:RegisterEvent("UNIT_MAXRAGE")
        manaBar:RegisterEvent("UNIT_MAXFOCUS")
        manaBar:RegisterEvent("UNIT_MAXENERGY")
        manaBar:RegisterEvent("UNIT_MAXHAPPINESS")
        manaBar:RegisterEvent("UNIT_DISPLAYPOWER")
        manaBar:SetScript("OnEvent", function()
            local event = event
            if event == "PLAYER_ENTERING_WORLD" then
                Heroic._invalidateManaBar(manaBar, uf.unit)
            else
                local unit = arg1
                if unit == nil or unit ~= uf.unit then
                    return
                end
                Heroic._invalidateManaBar(manaBar, unit)
            end
        end)

        uf.manaBar = manaBar
    end

    function Heroic._invalidateManaBar(manaBar, unit)
        if manaBar == nil or unit == nil then
            return
        end

        local value = UnitMana(unit)
        local maxValue = UnitManaMax(unit)
        local fraction = value / maxValue
        if fraction < 0.001 then
            fraction = 0
        elseif fraction > 0.999 then
            fraction = 1
        end
        manaBar:SetValue(fraction)

        local colorObject = ManaBarColor[UnitPowerType(unit)] or ManaBarColor[0]
        if colorObject then
            manaBar:SetStatusBarColor(colorObject.r, colorObject.g, colorObject.b)
        else
            manaBar:SetStatusBarColor(0, 0, 0)
        end

        if manaBar.valueTextRegion then
            manaBar.valueTextRegion:SetText(value)
        end
    end

    function Heroic._enableCastBar(uf, height, margin)
        local castBar = Heroic._createStatusBar(uf, height, margin)
        castBar:SetFrameLevel(uf.manaBar:GetFrameLevel() + 1)
        castBar:SetAllPoints(uf.manaBar)
        castBar:Hide()

        -- 1.12: SPELLCAST events only fire for player
        if uf.unit == "player" then
            local function onCastEnd()
                castBar.castSpellName = nil
                castBar.castSpellType = nil
                castBar:SetScript("OnUpdate", nil)
                castBar:Hide()
            end

            local function onCastUpdate()
                local now = GetTime()
                if castBar.castSpellType == "CASTING" then
                    local effectiveElapsedSeconds = now - castBar.castStartTime - castBar.castDelayedSeconds
                    if effectiveElapsedSeconds < 0 then
                        effectiveElapsedSeconds = 0
                    end
                    local fraction = effectiveElapsedSeconds / castBar.castTotalSeconds
                    castBar:SetValue(fraction)
                    if castBar.valueTextRegion then
                        castBar.valueTextRegion:SetFormattedText("%.1f", castBar.castTotalSeconds - effectiveElapsedSeconds)
                    end
                elseif castBar.castSpellType == "CHANNELING" then
                    local effectiveElapsedSeconds = now - castBar.castStartTime + castBar.castDelayedSeconds
                    if effectiveElapsedSeconds > castBar.castTotalSeconds then
                        effectiveElapsedSeconds = castBar.castTotalSeconds
                    end
                    local fraction = 1 - effectiveElapsedSeconds / castBar.castTotalSeconds
                    castBar:SetValue(fraction)
                    if castBar.valueTextRegion then
                        castBar.valueTextRegion:SetFormattedText("%.1f", castBar.castTotalSeconds - effectiveElapsedSeconds)
                    end
                else
                    onCastEnd()
                end
            end

            local events = {
                ["SPELLCAST_START"] = function()
                    castBar.castSpellName = arg1
                    castBar.castSpellType = "CASTING"
                    castBar.castStartTime = GetTime()
                    castBar.castTotalSeconds = arg2 / 1000
                    castBar.castDelayedSeconds = 0
                    castBar:SetStatusBarColor(Color.toVertex(Color.pick("Gold")))
                    castBar:SetScript("OnUpdate", onCastUpdate)
                    castBar:Show()
                end,
                ["SPELLCAST_STOP"] = onCastEnd,
                ["SPELLCAST_FAILED"] = onCastEnd,
                ["SPELLCAST_INTERRUPTED"] = onCastEnd,
                ["SPELLCAST_DELAYED"] = function()
                    if castBar.castSpellType == "CASTING" then
                        castBar.castDelayedSeconds = castBar.castDelayedSeconds + arg1 / 1000
                    end
                end,
                ["SPELLCAST_CHANNEL_START"] = function()
                    castBar.castSpellName = arg2
                    castBar.castSpellType = "CHANNELING"
                    castBar.castStartTime = GetTime()
                    castBar.castTotalSeconds = arg1 / 1000
                    castBar.castDelayedSeconds = 0
                    castBar:SetStatusBarColor(Color.toVertex(Color.pick("Green")))
                    castBar:SetScript("OnUpdate", onCastUpdate)
                    castBar:Show()
                end,
                ["SPELLCAST_CHANNEL_STOP"] = onCastEnd,
                ["SPELLCAST_CHANNEL_UPDATE"] = function()
                    if castBar.castSpellType == "CHANNELING" then
                        castBar.castDelayedSeconds = castBar.castDelayedSeconds + arg1 / 1000
                    end
                end
            }
            for event, _ in pairs(events) do
                castBar:RegisterEvent(event)
            end
            castBar:SetScript("OnEvent", function()
                local event = event
                if events[event] then
                    events[event]()
                end
            end)
        end

        uf.castBar = castBar
    end

    function Heroic._enableRaidMark(uf, width, height)
        local raidMarkFrame = CreateFrame("Frame", nil, uf, nil)
        raidMarkFrame:SetWidth(width)
        raidMarkFrame:SetHeight(height)
        raidMarkFrame:SetPoint("CENTER", uf, "TOP", 0, 0)

        local raidMarkTexture = raidMarkFrame:CreateTexture(nil, "ARTWORK", nil, 4)
        raidMarkTexture:SetTexture("interface\\targetingframe\\ui-raidtargetingicons")
        raidMarkTexture:SetAllPoints()
        raidMarkTexture:Hide()

        raidMarkFrame:RegisterEvent("RAID_TARGET_UPDATE")
        raidMarkFrame:SetScript("OnEvent", function()
            local self = raidMarkFrame
            local event = event
            if event == "RAID_TARGET_UPDATE" then
                local unit = uf.unit
                local index = GetRaidTargetIndex(unit)
                if index then
                    index = index - 1
                    local x = math.mod(index, 4)
                    local y = math.floor(index / 4)
                    raidMarkTexture:SetTexCoord(x / 4, (x + 1) / 4, y / 4, (y + 1) / 4)
                    raidMarkTexture:Show()
                else
                    raidMarkTexture:Hide()
                end
            end
        end)

        uf.raidMarkFrame = raidMarkFrame
    end

    function Heroic._enablePressedEffect(uf, inset)
        if uf.portraitFrame == nil then
            return
        end

        uf.portraitFrame:ClearAllPoints()
        uf.portraitFrame:SetPoint("CENTER", 0, 0)

        local function setPressed(uf, isPressed)
            local w = isPressed and (uf:GetWidth() - inset) or uf:GetWidth()
            local h = isPressed and (uf:GetHeight() - inset) or uf:GetHeight()
            uf.portraitFrame:SetWidth(w)
            uf.portraitFrame:SetHeight(h)
        end

        -- keep frame size sync
        uf:SetScript("OnSizeChanged", function()
            uf.portraitFrame:SetWidth(uf:GetWidth())
            uf.portraitFrame:SetHeight(uf:GetHeight())
        end)

        uf:SetScript("OnMouseDown", function()
            local button = arg1
            if button == "LeftButton" then
                setPressed(uf, true)
            end
        end)
        uf:SetScript("OnMouseUp", function()
            setPressed(uf, false)
        end)
        hookScript(uf, "OnLeave", "post_hook", function()
            setPressed(uf, false)
        end)
    end

    function Heroic._enableDeadGlowEffect(uf)
        if not uf.portraitFrame then
            return
        end

        local deadGlowFrame = CreateFrame("Frame", nil, uf.portraitFrame, nil)
        deadGlowFrame:SetBackdrop({
            edgeFile = getResource("glow"),
            edgeSize = 5
        })
        deadGlowFrame:SetBackdropBorderColor(1, 1, 1, 0)
        deadGlowFrame:SetPoint("TOPLEFT", -5, 5)
        deadGlowFrame:SetPoint("BOTTOMRIGHT", 5, -5)

        deadGlowFrame:RegisterEvent("UNIT_HEALTH") -- TODO by dead/alive events
        deadGlowFrame:RegisterEvent("UNIT_MAXHEALTH")
        deadGlowFrame:SetScript("OnEvent", function()
            local event = event
            if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
                local unit = arg1
                if unit == nil or unit ~= uf.unit then
                    return
                end

                local portraitTexture = uf.portraitFrame.portraitTexture
                local freeTalentPointGlowFrame = uf.portraitFrame.freeTalentPointGlowFrame
                local healthBar = uf.healthBar
                local manaBar = uf.manaBar

                if UnitIsDeadOrGhost(unit) then
                    if portraitTexture then
                        portraitTexture:SetDesaturated(true)
                    end
                    if freeTalentPointGlowFrame then
                        freeTalentPointGlowFrame:Hide()
                    end
                    deadGlowFrame:SetBackdropBorderColor(1, 1, 1, 0.15)
                    if healthBar then
                        healthBar:Hide()
                    end
                    if manaBar then
                        manaBar:Hide()
                    end
                else
                    if portraitTexture then
                        portraitTexture:SetDesaturated(false)
                    end
                    if freeTalentPointGlowFrame then
                        freeTalentPointGlowFrame:Show()
                    end
                    deadGlowFrame:SetBackdropBorderColor(1, 1, 1, 0)
                    if healthBar then
                        healthBar:Show()
                    end
                    if manaBar then
                        manaBar:Show()
                    end
                end
            end
        end)

        uf.portraitFrame.deadGlowFrame = deadGlowFrame
    end

    function Heroic._enableUnderAttackEffect(uf)
        if not uf.portraitFrame or not uf.portraitFrame.portraitTexture then
            return
        end

        local function setRedout(portraitTexture, enabled)
            if portraitTexture == nil then
                return
            end
            if enabled == "FLIP" then
                enabled = not portraitTexture.isRedout
            end
            portraitTexture.isRedout = enabled
            local colorString = Color.pick(enabled and "Red" or "White")
            portraitTexture:SetVertexColor(Color.toVertex(colorString))
        end

        local portraitTexture = uf.portraitFrame.portraitTexture
        local flashTotalSeconds = 4
        local flashIntervalSeconds = 0.5
        local flashRemainingSeconds = 0
        local totalElapsedSeconds = 0
        local lastHealth = 0
        local lastMaxHealth = 0

        local f = CreateFrame("Frame", nil, uf, nil)
        f:RegisterEvent("UNIT_HEALTH")
        f:RegisterEvent("UNIT_MAXHEALTH")
        f:SetScript("OnEvent", function()
            local unit = arg1
            if not unit or unit ~= uf.unit then
                return
            end

            local health = UnitHealth(unit)
            local maxHealth = UnitHealthMax(unit)

            if maxHealth ~= lastMaxHealth then
                lastMaxHealth = maxHealth
            elseif health / maxHealth < 0.2 then
                flashRemainingSeconds = 0
                f:SetScript("OnUpdate", nil)
                setRedout(portraitTexture, true)
            elseif health < lastHealth then
                -- under attack
                flashRemainingSeconds = flashTotalSeconds
                if not f:GetScript("OnUpdate") then
                    -- state change
                    totalElapsedSeconds = 0
                    setRedout(portraitTexture, true)
                    f:SetScript("OnUpdate", function()
                        local elapsed = arg1
                        totalElapsedSeconds = totalElapsedSeconds + elapsed
                        if totalElapsedSeconds < flashIntervalSeconds then
                            return
                        end
                        totalElapsedSeconds = totalElapsedSeconds - flashIntervalSeconds
                        flashRemainingSeconds = flashRemainingSeconds - flashIntervalSeconds
                        if flashRemainingSeconds > 0 then
                            setRedout(portraitTexture, "FLIP")
                        else
                            f:SetScript("OnUpdate", nil)
                            setRedout(portraitTexture, false)
                        end
                    end)
                end
            end
            lastHealth = health
        end)
    end

    function Heroic._enableFreeTalentPointGlowEffect(uf)
        if not uf.portraitFrame then
            return
        end

        local freeTalentPointGlowFrame = CreateFrame("Frame", nil, uf.portraitFrame, nil)
        freeTalentPointGlowFrame:SetBackdrop({
            edgeFile = getResource("glow"),
            edgeSize = 5
        })
        freeTalentPointGlowFrame:SetPoint("TOPLEFT", -5, 5)
        freeTalentPointGlowFrame:SetPoint("BOTTOMRIGHT", 5, -5)
        freeTalentPointGlowFrame:SetBackdropBorderColor(1, 1, 1, 0)

        if uf.unit == "player" then
            freeTalentPointGlowFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            freeTalentPointGlowFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
            freeTalentPointGlowFrame:SetScript("OnEvent", function()
                local freePoints = UnitCharacterPoints("player")
                if freePoints > 0 then
                    freeTalentPointGlowFrame:SetBackdropBorderColor(1, 1, 1, 0.15)
                else
                    freeTalentPointGlowFrame:SetBackdropBorderColor(1, 1, 1, 0)
                end
            end)
        end

        uf.portraitFrame.freeTalentPointGlowFrame = freeTalentPointGlowFrame
    end

    return Heroic
end)()

myHero = Heroic.createUnitFrame("player", 60, 60)
myHero:SetPoint("TOPLEFT", 8, -8)
myHero:Show()
