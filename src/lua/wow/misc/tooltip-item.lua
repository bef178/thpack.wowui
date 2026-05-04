local hookMemberFunction = Util.hookMemberFunction
local ItemUtil = ItemUtil

-- GameTooltip有淡出动画，动画完成时才会重置边框颜色(OnHide)。
-- 当鼠标快速移动时其实显示的是最后一次设置的颜色。
-- BlizUI在任何情况下都不改变边框颜色，本来没有问题。
-- 但一旦设定可变的边框颜色(如物品品质)，则将看到五颜六色的商店招牌。
local function tooltipResetBorderColor(tooltip)
    tooltip:SetBackdropBorderColor(1, 1, 1)
end

local function tooltipAddItemIdAndPrice(tooltip, itemId)
    if not itemId then
        return
    end
    local item = ItemUtil.getItem(itemId)
    tooltip:AddLine(" ")
    tooltip:AddLine("itemId: " .. itemId, 0, 1, 1)
    if item and item.itemRecyclePrice and item.itemRecyclePrice > 0 and not MerchantFrame:IsShown() then
        SetTooltipMoney(tooltip, item.itemRecyclePrice)
    end
    tooltip:Show()
end

for _, tooltip in ipairs({GameTooltip, ItemRefTooltip}) do
    hookMemberFunction(tooltip, "SetBagItem", "post_hook", function(tooltip, bagId, slotId)
        local itemLink = ItemUtil.getBagItemLink(bagId, slotId)
        tooltipAddItemIdAndPrice(tooltip, ItemUtil.parseItemLink(itemLink))
    end)

    -- TODO figure out why cannot hook SetInventoryItem on TurtleWoW
    -- hookMemberFunction(tooltip, "SetInventoryItem", "post_hook", function(tooltip, unit, slotId)
    --     local itemLink = GetInventoryItemLink(unit, slotId)
    --     tooltipAddItemIdAndPrice(tooltip, ItemUtil.parseItemLink(itemLink))
    -- end)

    hookMemberFunction(tooltip, "SetHyperlink", "post_hook", function(tooltip, itemString)
        tooltipAddItemIdAndPrice(tooltip, ItemUtil.parseItemString(itemString))
    end)
end
