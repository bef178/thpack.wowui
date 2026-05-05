local getColoredString = Util.buildColoredString
local getClassColor = Util.getClassColor
local getUnitNameColor = UnitUtil.getUnitNameColor

local addonName, addon = ...

local function getMasterUnitByUnit(unit)
    if unit == "pet" or unit == "vehicle" then
        return "player";
    end

    local partypetn = unit:match("^partypet(%d+)$");
    if partypetn then
        return "party" .. partypetn;
    end

    local raidpetn = unit:match("^raidpet(%d+)$");
    if raidpetn then
        return "raid" .. raidpetn;
    end
end

local function getUnitClassColor(unit)
    local _, unitClassType = UnitClass(unit)
    return getClassColor(unitClassType)
end

local function addBuffSource(tooltip, unit, index, filter)
    if not UnitAura then
        return
    end
    local srcUnit = select(7, UnitAura(unit, index, filter))
    if srcUnit then
        local srcMasterUnit = getMasterUnitByUnit(srcUnit)
        local tipFormat = srcMasterUnit and "by %s(%s)%s" or "by %s%s%s"
        srcUnit = srcMasterUnit or srcUnit

        local nameColor = getUnitNameColor(srcUnit)
        local classColor = getUnitClassColor(srcUnit)
        local tip = string.format(tipFormat, getColoredString(nameColor, "["),
            getColoredString(classColor, GetUnitName(srcUnit, true)), getColoredString(nameColor, "]"))

        tooltip:AddLine("")
        tooltip:AddLine(tip)
        tooltip:Show()
    end
end

if hooksecurefunc then
    hooksecurefunc(GameTooltip, "SetUnitAura", addBuffSource)
    hooksecurefunc(GameTooltip, "SetUnitBuff", addBuffSource)
end
