local hookGlobalFunction = Util.hookGlobalFunction

local getReagentNameByActionSlotId = (function()
    local reagentRegex = GetText("SPELL_REAGENTS") .. "(.+)"
    local tooltip = CreateFrame("GameTooltip", "aReagentTooltip", nil, "GameTooltipTemplate")
    return function(actionSlotId)
        tooltip:ClearLines()
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetAction(actionSlotId)
        for _, region in pairs({tooltip:GetRegions()}) do
            if region and region:GetObjectType() == "FontString" then
                local line = region:GetText()
                local s = String.match(line or "", reagentRegex)
                if s then
                    return s
                end
            end
        end
    end
end)()

local function getNumReagentsByActionSlotId(actionSlotId)
    local reagentName = getReagentNameByActionSlotId(actionSlotId)
    if not reagentName then
        return
    end
    local n = 0
    for bagId = 0, NUM_BAG_FRAMES do
        for slotId = 1, GetContainerNumSlots(bagId) do
            local itemLink = GetContainerItemLink(bagId, slotId)
            local itemName = itemLink and String.match(itemLink, "%[([^%]]+)%]") or nil
            if itemName and itemName == reagentName then
                local _, itemCount = GetContainerItemInfo(bagId, slotId)
                n = n + itemCount
            end
        end
    end
    return n
end

local function showNumReagents(actionButton)
    local actionSlotId = ActionButton_GetPagedID(actionButton)
    local n = getNumReagentsByActionSlotId(actionSlotId)
    if n then
        local textRegion = _G[actionButton:GetName() .. "Count"]
        if n > 99 then
            textRegion:SetText("*")
        else
            textRegion:SetText(n)
        end
    end
end

if hooksecurefunc then
    hooksecurefunc("ActionButton_UpdateCount", showNumReagents)
else
    hookGlobalFunction("ActionButton_UpdateCount", "post_hook", function()
        local actionButton = this
        showNumReagents(actionButton)
    end)
end
