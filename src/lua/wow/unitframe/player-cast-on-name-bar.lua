local hookScript = Util.hookScript

local function playerCastOnNameBar()
    local castBar = CastingBarFrame
    castBar:ClearAllPoints()
    castBar:SetWidth(119)
    castBar:SetHeight(19)
    castBar:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 106, -22)

    local castTexture = castBar:CreateTexture(nil, "ARTWORK")
    castTexture:SetTexCoord(5 / 64, 1 - 5 / 64, 5 / 64, 1 - 5 / 64)
    castTexture:SetAllPoints(PlayerPortrait)

    local borderTexture = CastingBarBorder
    borderTexture:SetTexture([[Interface\CastingBar\UI-CastingBar-Border-Small]])
    borderTexture:Hide()

    local sparkTexture = CastingBarSpark

    local flashTexture = CastingBarFlash
    flashTexture:SetTexture([[Interface\CastingBar\UI-CastingBar-Flash-Small]])
    flashTexture:ClearAllPoints()
    flashTexture:SetAllPoints(borderTexture)

    local castNameText = CastingBarText
    castNameText.SetFontObject(GameFontNormalSmall)
    castNameText:ClearAllPoints()
    castNameText:SetAllPoints(PlayerName)

    -- local castRemainingTimeText = castBar:CreateFontString(nil, "OVERLAY")
    -- castRemainingTimeText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    -- castRemainingTimeText:SetPoint("RIGHT", -4, 0)

    hookScript(castBar, "OnUpdate", "post_hook", function()
        local self = castBar
        local elapsed = arg1

        local eta = 0
        if castBar.casting then
            eta = castBar.maxValue - castBar.value
        elseif castBar.channeling then
            eta = castBar.value
        end
        if eta < 0 then
            eta = 0
        end

        local spellName = castNameText:GetText()
        local _, _, textureName = GetSpellInfo(spellName)
        SetPortraitToTexture(castTexture, textureName)

        PlayerName:Hide()
        PlayerStatusTexture:Hide()
        PlayerFrameBackground:Hide()
        PlayerAttackIcon:SetAlpha(0.2)
        PlayerRestIcon:SetAlpha(0.2)
        PlayerPortrait:Hide()
        PlayerLevelText:SetFormattedText("%.1f", eta)
    end)

    hookScript(castBar, "OnHide", "post_hook", function()
        PlayerName:Show()
        PlayerStatusTexture:Show()
        PlayerFrameBackground:Show()
        PlayerAttackIcon:SetAlpha(1)
        PlayerRestIcon:SetAlpha(1)
        PlayerPortrait:Show()
        PlayerLevelText:SetText(UnitLevel("player"))
    end)
end

playerCastOnNameBar()

--[=[

-- relayout the UI

-- move unit frame to center below in the screen
-- move buff frame below unit frame

-- move casting bar to unit frame's name region
T.ask("PLAYER_LOGIN").answer("relayoutCastingBar", function()

    local function relayoutUnitFrame(unitFrame)
        local castingBar = unitFrame.castingBar
        castingBar:ClearAllPoints()
        castingBar:SetAllPoints(unitFrame.hpBar)

        castingBar.Text:SetFontObject(GameFontNormalSmall)

        castingBar.Border:SetTexture([[Interface\CastingBar\UI-CastingBar-Border-Small]])
        castingBar.Border:Hide()

        castingBar.Flash:SetTexture([[Interface\CastingBar\UI-CastingBar-Flash-Small]])
        castingBar.Flash:ClearAllPoints()
        castingBar.Flash:SetAllPoints(castingBar.Border)

        castingBar.Icon:ClearAllPoints()
        castingBar.Icon:SetAllPoints(unitFrame.portrait)
        castingBar.Icon:SetTexCoord(5 / 64, 1 - 5 / 64, 5 / 64, 1 - 5 / 64)
        castingBar.Icon:Show()
    end

    PlayerFrame.portrait = PlayerPortrait
    PlayerFrame.hpBar = PlayerFrameHealthBar
    PlayerFrame.castingBar = CastingBarFrame
    PlayerFrame.castingBar.text2 = PlayerLevelText
    -- what's the diff between CastingBarFrame and PlayerFrame's casting bar?

    relayoutUnitFrame(PlayerFrame)

    PlayerFrame.castingBar:HookScript("OnUpdate", function(self, elapsed)
        local etc = 0
        if self.casting then
            etc = self.maxValue - self.value
        elseif self.channeling then
            etc = self.value
        end
        if etc < 0 then
            etc = 0
        end

        self.text2:SetFormattedText("%.1f", etc)

        if etc > 0 then
            PlayerName:Hide()
            PlayerStatusTexture:Hide()
            PlayerFrameBackground:Hide()
            PlayerAttackIcon:SetAlpha(0.2)
            PlayerRestIcon:SetAlpha(0.2)
            PlayerFrame.portrait:Hide()
            SetPortraitToTexture(self.Icon, self.Icon:GetTexture())
        end
    end)

    PlayerFrame.castingBar:HookScript("OnHide", function(self, event, ...)
        PlayerName:Show()
        PlayerStatusTexture:Show()
        PlayerFrameBackground:Show()
        PlayerPortrait:Show()
        PlayerLevelText:SetText(UnitLevel("player"))
        PlayerAttackIcon:SetAlpha(1)
        PlayerRestIcon:SetAlpha(1)
    end)

    TargetFrame.portrait = TargetFramePortrait
    TargetFrame.hpBar = TargetFrameHealthBar
    TargetFrame.castingBar = TargetFrameSpellBar
    TargetFrame.castingBar.text2 = TargetFrameTextureFrameLevelText

    relayoutUnitFrame(TargetFrame)
    TargetFrame.castingBar.Icon:SetMask([[Interface\CharacterFrame\TempPortraitAlphaMask]])

    TargetFrame.castingBar:HookScript("OnUpdate", function(self, elapsed)
        local etc = 0
        if self.casting then
            etc = self.maxValue - self.value
        elseif self.channeling then
            etc = self.value
        end
        if etc < 0 then
            etc = 0
        end

        self.text2:SetFormattedText("%.1f", etc)

        if etc > 0 then
            TargetFrameTextureFrameName:Hide()
            TargetFrameNameBackground:Hide()
            TargetFrame.portrait:Hide()
            local notInterruptible = select(9, UnitCastingInfo("target"))
            if notInterruptible then
                TargetFrameTextureFrameQuestIcon:Show()
                TargetFrameTextureFrameQuestIcon:SetVertexColor(1, 0, 0, 1)
            else
                TargetFrameTextureFrameQuestIcon:SetVertexColor(1, 1, 1, 1)
            end
        end
    end)

    TargetFrame.castingBar:HookScript("OnHide", function(self, event, ...)
        TargetFrameTextureFrameName:Show()
        TargetFrameNameBackground:Show()
        TargetFrame.portrait:Show()
        TargetFrameTextureFrameQuestIcon:Hide()
        TargetFrameTextureFrameLevelText:SetText(UnitLevel("target"))
        TargetFrameTextureFrameQuestIcon:SetVertexColor(1, 1, 1, 1)
    end)
end)

T.ask("PLAYER_LOGIN").answer("relayoutUnitFrames", function()
    if InCombatLockdown() then
        return
    end
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("center", -265, -150)
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("center", 265, -150)
    FocusFrame:ClearAllPoints()
    FocusFrame:SetPoint("left", 260, -215)
    PartyMemberFrame1:ClearAllPoints()
    PartyMemberFrame1:SetPoint("left", 175, 125)
end)

]=]
