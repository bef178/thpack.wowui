local getResource = Util.getResource
local hookScript = Util.hookScript
local SpellUtil = SpellUtil
local CastUtil = CastUtil

local function playerCastOnNameBar()
    local castBar = CreateFrame("StatusBar", nil, PlayerFrame)
    castBar:SetWidth(119)
    castBar:SetHeight(19)
    castBar:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 106, -22)
    castBar:SetBackdrop({
        bgFile = getResource("tile32")
    })
    castBar:SetBackdropColor(0, 0, 0, 0.85)
    castBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-TargetingFrame-LevelBackground]])
    castBar:SetMinMaxValues(0, 1)
    castBar:Hide()

    local sparkTextureRegion = castBar:CreateTexture(nil, "OVERLAY")
    sparkTextureRegion:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
    sparkTextureRegion:SetTexCoord(0, 1, 0, 58 / 64)
    sparkTextureRegion:SetBlendMode("ADD")
    sparkTextureRegion:SetWidth(32) -- SetSize(6, 18)
    sparkTextureRegion:SetHeight(19 * 2 * 58 / 64)
    castBar.sparkTextureRegion = sparkTextureRegion

    local iconTextureRegion = castBar:CreateTexture(nil, "ARTWORK")
    iconTextureRegion:SetAllPoints(PlayerPortrait)
    castBar.iconTextureRegion = iconTextureRegion

    castBar.nameTextRegion = PlayerName

    castBar.remainingTimeTextRegion = PlayerLevelText
    local remainingTimeTextRegion = castBar:CreateFontString(nil, "ARTWORK")
    remainingTimeTextRegion:SetFontObject(NumberFontNormalYellow)
    remainingTimeTextRegion:SetTextHeight(9)
    remainingTimeTextRegion:SetPoint("RIGHT", -1, 0)
    castBar.remainingTimeTextRegion = remainingTimeTextRegion

    CastUtil.enableCastBar(castBar, "player")

    hookScript(castBar, "OnShow", "post_hook", function()
        local spellName = castBar.nameTextRegion:GetText()
        local spellId = SpellUtil.getSpellId(spellName)
        if spellId then
            SetPortraitToTexture(iconTextureRegion, SpellUtil.getSpellTexture(spellId))
        end
        PlayerAttackIcon:SetAlpha(0.2)
        PlayerRestIcon:SetAlpha(0.2)
    end)

    hookScript(castBar, "OnHide", "post_hook", function()
        PlayerName:SetText(UnitName("player"))
        PlayerLevelText:SetText(UnitLevel("player"))
        PlayerAttackIcon:SetAlpha(1)
        PlayerRestIcon:SetAlpha(1)
    end)
end

playerCastOnNameBar()
CastingBarFrame:UnregisterAllEvents()
CastingBarFrame:SetScript("OnEvent", nil)
CastingBarFrame.Show = function()
    -- dummy
end
CastingBarFrame:Hide()
