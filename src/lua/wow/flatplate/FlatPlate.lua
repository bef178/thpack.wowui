local UnitExists = UnitExists
local UnitName = UnitName
local UnitAffectingCombat = UnitAffectingCombat

local Color = Color
local hookScript = Util.hookScript
local FlatUnitFrame = FlatUnitFrame

local FlatPlate = (function()
    local FlatPlate = {
        _numInitialized = 0,
        _registry = {}
    }

    -- 1.12 nameplate: a Button child of WorldFrame
    -- first region is Texture with "Interface\Tooltips\Nameplate-Border"
    -- regions order: border, glow, name, level, levelicon, raidicon
    -- children order: healthbar, castbar
    local function isNamePlate(frame)
        if frame:GetObjectType() ~= "Button" then
            return
        end
        local region = frame:GetRegions()
        if not region or region:GetObjectType() ~= "Texture" then
            return
        end
        return region:GetTexture() == [[Interface\Tooltips\Nameplate-Border]]
    end

    local function disableObject(object)
        if not object or not object.GetObjectType then
            return
        end
        local objType = object:GetObjectType()
        if objType == "Texture" then
            object:SetTexture("")
            object:SetTexCoord(0, 0, 0, 0)
        elseif objType == "FontString" then
            object:SetWidth(0.001)
        elseif objType == "StatusBar" then
            object:SetStatusBarTexture("")
        end
    end

    local function hookNamePlate(namePlate)
        local healthbar = namePlate:GetChildren()
        namePlate._original = {
            healthbar = healthbar
        }

        local regions = {namePlate:GetRegions()}
        local order = {"border", "glow", "name", "level", "levelicon", "raidicon"}
        for i, object in ipairs(regions) do
            if order[i] then
                namePlate._original[order[i]] = object
            end
        end

        -- disable all blizzard visuals
        if healthbar then
            disableObject(healthbar)
        end
        for _, object in ipairs(regions) do
            disableObject(object)
        end

        -- create flatUnitFrame
        local uf = FlatUnitFrame.createUnitFrame(namePlate)
        uf:SetPoint("TOP", namePlate, "TOP", 0, 0)
        FlatUnitFrame.stop(uf)
        namePlate._flatUnitFrame = uf

        -- disable event-driven refresh on nameplate unit frames
        -- nameplates are updated by FlatNamePlate via data-driven invalidate
        if uf.nameFrame then
            uf.nameFrame:UnregisterAllEvents()
        end
        if uf.healthBar then
            uf.healthBar:UnregisterAllEvents()
        end
        if uf.selectionFrame then
            uf.selectionFrame:UnregisterAllEvents()
        end
        if uf.raidFrame then
            uf.raidFrame:UnregisterAllEvents()
        end

        if healthbar then
            hookScript(healthbar, "OnValueChanged", "post_hook", function()
                namePlate._dirty = true
            end)
        end

        hookScript(namePlate, "OnShow", "post_hook", function()
            namePlate._dirty = true
        end)
        hookScript(namePlate, "OnHide", "post_hook", function()
            namePlate._dirty = true
        end)

        namePlate._dirty = true
    end

    local function readNamePlate(namePlate)
        local original = namePlate._original
        local healthbar = original.healthbar

        -- read name from blizzard nameplate
        local name
        if original.name and original.name:GetObjectType() == "FontString" then
            name = original.name:GetText()
        end

        local nameColor = "#ffffff"
        if original.name and original.name:GetObjectType() == "FontString" then
            nameColor = Color.fromVertex(original.name:GetTextColor())
        end

        -- read level from blizzard nameplate
        local level
        if original.level and original.level:IsShown() and original.level:GetObjectType() == "FontString" then
            level = original.level:GetText()
        end

        local levelColor
        if original.level and original.level:GetObjectType() == "FontString" then
            levelColor = Color.fromVertex(original.level:GetTextColor())
        end

        -- read health fraction from blizzard healthbar
        local fraction
        if healthbar then
            local value = healthbar:GetValue()
            local _, max = healthbar:GetMinMaxValues()
            if max > 0 then
                fraction = value / max
            end
        end

        local barColor
        if healthbar then
            barColor = Color.fromVertex(healthbar:GetStatusBarColor())
        end

        -- detect target: blizzard sets alpha=1 on the target nameplate
        local isTarget = UnitExists("target") and namePlate:GetAlpha() == 1 and name and UnitName("target") == name

        return {
            name = name,
            nameColor = nameColor,
            level = level,
            levelColor = levelColor,
            fraction = fraction,
            barColor = barColor,
            isTarget = isTarget,
            inCombat = UnitAffectingCombat("player")
        }
    end

    local function updateNamePlate(namePlate)
        if not namePlate:IsVisible() then
            local uf = namePlate._flatUnitFrame
            if uf then
                FlatUnitFrame.stop(uf)
            end
            return
        end

        local uf = namePlate._flatUnitFrame
        if not uf then
            return
        end

        local data = readNamePlate(namePlate)
        if not data.name then
            FlatUnitFrame.stop(uf)
            return
        end

        uf:Show()
        FlatUnitFrame.refresh(uf, data)
    end

    function FlatPlate.scanNamePlates()
        local n = WorldFrame:GetNumChildren()
        if n <= FlatPlate._numInitialized then
            return
        end
        local children = {WorldFrame:GetChildren()}
        for i = FlatPlate._numInitialized + 1, n do
            local child = children[i]
            if child and isNamePlate(child) and not FlatPlate._registry[child] then
                hookNamePlate(child)
                FlatPlate._registry[child] = true
            end
        end
        FlatPlate._numInitialized = n
    end

    function FlatPlate.start()
        local f = CreateFrame("Frame", nil, UIParent, nil)
        f:RegisterEvent("PLAYER_REGEN_ENABLED")
        f:RegisterEvent("PLAYER_REGEN_DISABLED")
        f:RegisterEvent("PLAYER_TARGET_CHANGED")
        f:SetScript("OnEvent", function()
            for namePlate in pairs(FlatPlate._registry) do
                namePlate._dirty = true
            end
        end)
        f:SetScript("OnUpdate", function()
            FlatPlate.scanNamePlates()
            for namePlate in pairs(FlatPlate._registry) do
                if namePlate._dirty then
                    namePlate._dirty = nil
                    updateNamePlate(namePlate)
                end
            end
        end)
    end

    return FlatPlate
end)()

FlatPlate.start()
