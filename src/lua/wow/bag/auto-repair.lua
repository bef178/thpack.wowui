local logi = Util.logi
local buildCoinString = Util.buildCoinString

local repairBagItem = (function()
    local tooltip = CreateFrame("GameTooltip")
    return function(bagId, slotId)
        local _, repairCost = tooltip:SetBagItem(bagId, slotId)
        if repairCost and repairCost > 0 then
            PickupContainerItem(bagId, slotId)
        end
        return repairCost
    end
end)()

local function repairAllEquippedItemsAndBagItems()
    local allRepairCost, canRepair = GetRepairAllCost()
    if canRepair then
        RepairAllItems() -- for all equipped items
        ShowRepairCursor()
        for bagId = 0, NUM_BAG_FRAMES, 1 do
            for slotId = 1, GetContainerNumSlots(bagId), 1 do
                local repairCost = repairBagItem(bagId, slotId)
                if repairCost and repairCost > 0 then
                    allRepairCost = allRepairCost + repairCost
                end
            end
        end
        HideRepairCursor()
    end
    return allRepairCost
end

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", function()
    if CanMerchantRepair() then
        local cost = repairAllEquippedItemsAndBagItems()
        if cost and cost > 0 then
            logi("Auto repair costs " .. buildCoinString(cost))
        end
    end
end)
