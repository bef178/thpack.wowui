-- team fortress styled scoreboard for wow battleground
-- alliance color: 0.62, 0.8, 0.98
-- horde color: 1, 0.25, 0.2
-- banner: 368 * 30
-- vertical rule: 2 * 370
-- board: 348 * 400
-- horizontal: 20 + 348 + 9 + 2 + 9 + 348 + 20
local MAX_ROWS = 15

local Scoreboard = {}

function Scoreboard.createWideBoardFrame()
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetFrameStrata("DIALOG")
    f:SetPoint("CENTER", 0, 0)
    f:SetWidth(756)
    f:SetHeight(400)

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(0, 0, 0, 0.4)
    bg:SetAllPoints()

    local allianceBanner = Scoreboard.createBannerFrame(f, "alliance")
    allianceBanner:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 8)
    f.allianceBanner = allianceBanner

    local hordeBanner = Scoreboard.createBannerFrame(f, "horde")
    hordeBanner:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, 8)
    f.hordeBanner = hordeBanner

    local separatorLine = f:CreateTexture(nil, "BACKGROUND")
    separatorLine:SetTexture(0, 0, 0, 1)
    separatorLine:SetPoint("TOP", 0, -12)
    separatorLine:SetPoint("BOTTOM", 0, 18)
    separatorLine:SetWidth(2)

    local allianceBoard = Scoreboard.createBoardFrame(f, "alliance")
    allianceBoard:SetPoint("TOPLEFT", 20, 0)
    f.allianceBoard = allianceBoard

    local hordeBoard = Scoreboard.createBoardFrame(f, "horde")
    hordeBoard:SetPoint("TOPRIGHT", -20, 0)
    f.hordeBoard = hordeBoard

    local playerIndicator = f:CreateTexture(nil, "BACKGROUND")
    playerIndicator:SetTexture(1, 1, 1, 0.4)
    playerIndicator:SetWidth(348)
    playerIndicator:SetHeight(22)
    playerIndicator:Hide()
    f.playerIndicator = playerIndicator

    return f
end

function Scoreboard.createBannerFrame(parent, faction)
    local f = CreateFrame("Frame", nil, parent, nil)
    f:SetWidth(368)
    f:SetHeight(30)

    local bgTextureRegion = f:CreateTexture(nil, "BACKGROUND")
    bgTextureRegion:SetAllPoints()

    local titleTextRegion = f:CreateFontString(nil, "ARTWORK")
    titleTextRegion:SetFont(STANDARD_TEXT_FONT, 50)
    titleTextRegion:SetVertexColor(0.93, 0.89, 0.78)

    local playersTextRegion = f:CreateFontString(nil, "ARTWORK")
    playersTextRegion:SetFont(STANDARD_TEXT_FONT, 16)
    playersTextRegion:SetJustifyH("LEFT")
    playersTextRegion:SetPoint("TOPLEFT", titleTextRegion, "BOTTOMLEFT", 0, 3)
    f.playersTextRegion = playersTextRegion

    local killsTextRegion = f:CreateFontString(nil, "ARTWORK")
    killsTextRegion:SetFont(DAMAGE_TEXT_FONT, 24)
    f.killsTextRegion = killsTextRegion

    local scoreTextRegion = f:CreateFontString(nil, "ARTWORK")
    scoreTextRegion:SetFont(STANDARD_TEXT_FONT, 40)
    scoreTextRegion:SetVertexColor(0.93, 0.89, 0.78)
    f.scoreTextRegion = scoreTextRegion

    if faction == "alliance" then
        bgTextureRegion:SetTexture(0.62, 0.8, 0.98, 0.4)
        titleTextRegion:SetJustifyH("LEFT")
        titleTextRegion:SetText("Alliance")
        titleTextRegion:SetPoint("BOTTOMLEFT", 20, 12)
        killsTextRegion:SetJustifyH("RIGHT")
        killsTextRegion:SetPoint("BOTTOMRIGHT", -4, 3)
        scoreTextRegion:SetPoint("BOTTOMRIGHT", -50, 14)
    elseif faction == "horde" then
        bgTextureRegion:SetTexture(1, 0.25, 0.2, 0.4)
        titleTextRegion:SetJustifyH("RIGHT")
        titleTextRegion:SetText("Horde")
        titleTextRegion:SetPoint("BOTTOMRIGHT", -20, 12)
        killsTextRegion:SetJustifyH("LEFT")
        killsTextRegion:SetPoint("BOTTOMLEFT", 4, 3)
        scoreTextRegion:SetPoint("BOTTOMLEFT", 50, 14)
    end

    return f
end

function Scoreboard.createBoardFrame(parent, faction)
    local f = CreateFrame("Frame", nil, parent, nil)
    f:SetWidth(348)
    f:SetHeight(400)

    local separatorLine = f:CreateTexture(nil, "BACKGROUND")
    separatorLine:SetTexture(1, 1, 1, 0.4)
    separatorLine:SetPoint("TOP", 0, -27)
    separatorLine:SetWidth(348)
    separatorLine:SetHeight(1)

    local header = Scoreboard.createRowFrame(f, faction)
    header:SetPoint("BOTTOMLEFT", separatorLine, "BOTTOMLEFT", 0, 2)
    header.seqRankTextRegion:SetFont(STANDARD_TEXT_FONT, 12)
    header.seqRankTextRegion:SetText("#")
    header.classTextureRegion:SetTexture()
    header.nameTextRegion:SetFont(STANDARD_TEXT_FONT, 12)
    header.nameTextRegion:SetText("Name")
    header.killsTextRegion:SetFont(STANDARD_TEXT_FONT, 12)
    header.killsTextRegion:SetText("K")
    header.deathsTextRegion:SetFont(STANDARD_TEXT_FONT, 12)
    header.deathsTextRegion:SetText("D")
    header.pvpRankTextRegion:SetFont(STANDARD_TEXT_FONT, 12)
    header.pvpRankTextRegion:SetText("R")

    f.faction = faction
    f.dy = -25
    f._rowFrames = {}

    return f
end

function Scoreboard.createRowFrame(parent, faction)
    local r, g, b
    if faction == "alliance" then
        r, g, b = 0.62, 0.8, 0.98
    elseif faction == "horde" then
        r, g, b = 1, 0.25, 0.2
    else
        r, g, b = 0.93, 0.89, 0.78
    end
    local f = CreateFrame("Frame", nil, parent, nil)
    f:SetWidth(348)
    f:SetHeight(22)

    local seqRankTextRegion = f:CreateFontString(nil, "ARTWORK")
    seqRankTextRegion:SetFont(DAMAGE_TEXT_FONT, 12)
    seqRankTextRegion:SetJustifyH("RIGHT")
    seqRankTextRegion:SetVertexColor(r, g, b)
    seqRankTextRegion:SetPoint("BOTTOMLEFT", 2, 0)
    seqRankTextRegion:SetWidth(20)
    f.seqRankTextRegion = seqRankTextRegion

    local classTextureRegion = f:CreateTexture(nil, "ARTWORK")
    classTextureRegion:SetPoint("BOTTOMLEFT", 32, -1)
    classTextureRegion:SetWidth(16)
    classTextureRegion:SetHeight(16)
    f.classTextureRegion = classTextureRegion

    local nameTextRegion = f:CreateFontString(nil, "ARTWORK")
    nameTextRegion:SetFont(STANDARD_TEXT_FONT, 16)
    nameTextRegion:SetJustifyH("LEFT")
    nameTextRegion:SetVertexColor(r, g, b)
    nameTextRegion:SetPoint("BOTTOMLEFT", 48, 0)
    f.nameTextRegion = nameTextRegion

    -- TODO move to right-most
    local pvpRankTextRegion = f:CreateFontString(nil, "ARTWORK")
    pvpRankTextRegion:SetFont(DAMAGE_TEXT_FONT, 14)
    pvpRankTextRegion:SetJustifyH("LEFT")
    pvpRankTextRegion:SetVertexColor(r, g, b)
    pvpRankTextRegion:SetPoint("BOTTOMRIGHT", -88, 0)
    pvpRankTextRegion:SetWidth(28)
    f.pvpRankTextRegion = pvpRankTextRegion

    local killsTextRegion = f:CreateFontString(nil, "ARTWORK")
    killsTextRegion:SetFont(DAMAGE_TEXT_FONT, 16)
    killsTextRegion:SetJustifyH("RIGHT")
    killsTextRegion:SetVertexColor(r, g, b)
    killsTextRegion:SetPoint("BOTTOMRIGHT", -66, 0)
    killsTextRegion:SetWidth(24)
    f.killsTextRegion = killsTextRegion

    local deathsTextRegion = f:CreateFontString(nil, "ARTWORK")
    deathsTextRegion:SetFont(DAMAGE_TEXT_FONT, 16)
    deathsTextRegion:SetJustifyH("RIGHT")
    deathsTextRegion:SetVertexColor(r, g, b)
    deathsTextRegion:SetPoint("BOTTOMRIGHT", -38, 0)
    deathsTextRegion:SetWidth(24)
    f.deathsTextRegion = deathsTextRegion

    -- local honorableKillsTextRegion = f:CreateFontString(nil, "ARTWORK")
    -- honorableKillsTextRegion:SetFont(DAMAGE_TEXT_FONT, 16)
    -- honorableKillsTextRegion:SetJustifyH("RIGHT")
    -- honorableKillsTextRegion:SetVertexColor(r, g, b)
    -- honorableKillsTextRegion:SetPoint("BOTTOMRIGHT", -4, 0)
    -- honorableKillsTextRegion:SetWidth(24)
    -- f.honorableKillsTextRegion = honorableKillsTextRegion

    return f
end

function Scoreboard.getOrCreateRowFrame(boardFrame, index)
    while Array.size(boardFrame._rowFrames) < index do
        local rowFrame = Scoreboard.createRowFrame(boardFrame, boardFrame.faction)
        rowFrame:SetPoint("TOPLEFT", boardFrame, "TOPLEFT", 0, boardFrame.dy - 22 * Array.size(boardFrame._rowFrames))
        Array.add(boardFrame._rowFrames, rowFrame)
    end
    return boardFrame._rowFrames[index]
end

--------

function Scoreboard.refreshWideBoard(scoreboard)
    Scoreboard.resetScoreboard(scoreboard)
    local numAlliances = 0
    local numHordes = 0
    local numAllianceKills = 0
    local numHordeKills = 0
    for i = 1, GetNumBattlefieldScores() do
        local name, kills, honorableKills, deaths, honorGained, faction, rank, race, class = GetBattlefieldScore(i)
        if faction then
            local isPlayer = name == UnitName("player")
            local _, pvpRank = GetPVPRankInfo(rank, faction)
            local classToken = class and strupper(class)
            if faction == 0 then
                -- horde
                numHordes = numHordes + 1
                numHordeKills = numHordeKills + kills
                local rowFrame
                if numHordes <= MAX_ROWS then
                    rowFrame = Scoreboard.getOrCreateRowFrame(scoreboard.hordeBoard, numHordes)
                elseif isPlayer then
                    rowFrame = Scoreboard.getOrCreateRowFrame(scoreboard.hordeBoard, MAX_ROWS)
                end
                if rowFrame then
                    Scoreboard.refreshRowFrame(rowFrame, numHordes, name, classToken, pvpRank, kills, deaths)
                    if isPlayer then
                        local indicator = scoreboard.playerIndicator
                        indicator:ClearAllPoints()
                        indicator:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", 0, -4)
                        indicator:Show()
                    end
                end
            elseif faction == 1 then
                -- alliance
                numAlliances = numAlliances + 1
                numAllianceKills = numAllianceKills + kills
                local rowFrame
                if numAlliances <= MAX_ROWS then
                    rowFrame = Scoreboard.getOrCreateRowFrame(scoreboard.allianceBoard, numAlliances)
                elseif isPlayer then
                    rowFrame = Scoreboard.getOrCreateRowFrame(scoreboard.allianceBoard, MAX_ROWS)
                end
                if rowFrame then
                    Scoreboard.refreshRowFrame(rowFrame, numAlliances, name, classToken, pvpRank, kills, deaths)
                    if isPlayer then
                        local indicator = scoreboard.playerIndicator
                        indicator:ClearAllPoints()
                        indicator:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", 0, -4)
                        indicator:Show()
                    end
                end
            end
        end
    end
    scoreboard.allianceBanner.playersTextRegion:SetText(numAlliances .. " player(s)")
    scoreboard.allianceBanner.killsTextRegion:SetText(numAllianceKills)
    scoreboard.hordeBanner.playersTextRegion:SetText(numHordes .. " player(s)")
    scoreboard.hordeBanner.killsTextRegion:SetText(numHordeKills)

    -- TODO update alliance vs horde scores
end

function Scoreboard.refreshRowFrame(rowFrame, seqRank, name, classToken, pvpRank, k, d)
    rowFrame.seqRankTextRegion:SetText(seqRank)
    if classToken then
        rowFrame.classTextureRegion:SetTexture("Interface/Glues/CharacterCreate/UI-CharacterCreate-Classes")
        rowFrame.classTextureRegion:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classToken]))
    else
        rowFrame.classTextureRegion:SetTexture(nil)
    end
    rowFrame.nameTextRegion:SetText(name)
    rowFrame.pvpRankTextRegion:SetText(pvpRank and ("R" .. pvpRank))
    rowFrame.killsTextRegion:SetText(k)
    rowFrame.deathsTextRegion:SetText(d)
end

function Scoreboard.resetScoreboard(scoreboard)
    Scoreboard.resetBoardFrame(scoreboard.allianceBoard)
    Scoreboard.resetBoardFrame(scoreboard.hordeBoard)
    scoreboard.playerIndicator:Hide()
end

function Scoreboard.resetBoardFrame(boardFrame)
    local n = Array.size(boardFrame._rowFrames)
    for i = 1, n do
        local rowFrame = Scoreboard.getOrCreateRowFrame(boardFrame, i)
        Scoreboard.refreshRowFrame(rowFrame)
    end
end

--------

local scoreboard = Scoreboard.createWideBoardFrame()
scoreboard:Hide()

scoreboard:RegisterEvent("PLAYER_ENTERING_WORLD")
scoreboard:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
scoreboard:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        if inInstance and instanceType == "pvp" then
            Scoreboard.resetScoreboard(scoreboard)
        end
    elseif event == "UPDATE_BATTLEFIELD_SCORE" then
        Scoreboard.refreshWideBoard(scoreboard)
    end
end)

function hideScoreboard()
    scoreboard:Hide()
end

function showScoreboard()
    scoreboard:Show()
    RequestBattlefieldScoreData()
end
