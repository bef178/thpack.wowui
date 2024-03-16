local logi = A.logi;
local buildCoinString = A.buildCoinString;

(function()
    local getBagItemRepairCost = (function()
        local tooltip = CreateFrame("GameTooltip");
        return function(bagId, slotId)
            local _, repairCost = tooltip:SetBagItem(bagId, slotId);
            return repairCost;
        end;
    end)();

    local repairAllEquipments = function()
        local amount, canRepair = GetRepairAllCost();
        if (canRepair) then
            RepairAllItems();
            ShowRepairCursor();
            for bagId = 0, NUM_BAG_FRAMES, 1 do
                for slotId = 1, GetContainerNumSlots(bagId), 1 do
                    local repairCost = getBagItemRepairCost(bagId, slotId);
                    if (repairCost and repairCost > 0) then
                        amount = amount + repairCost;
                        PickupContainerItem(bagId, slotId);
                    end
                end
            end
            HideRepairCursor();
        end
        return amount;
    end;

    local f = CreateFrame("Frame");
    f:RegisterEvent("MERCHANT_SHOW");
    f:SetScript("OnEvent", function()
        if (CanMerchantRepair()) then
            local amount = repairAllEquipments();
            if (amount and amount > 0) then
                logi("Auto repair for " .. buildCoinString(amount));
            end
        end
    end);
end)();
