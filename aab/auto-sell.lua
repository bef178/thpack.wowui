local logi = A.logi;
local buildCoinString = A.buildCoinString;

(function()
    local getBagItemSellPrice = (function()
        local sellPrice = 0;
        local tooltip = CreateFrame("GameTooltip");
        tooltip:SetScript("OnTooltipAddMoney", function()
            sellPrice = arg1 or 0;
        end);
        return function(bagId, slotId)
            tooltip:SetBagItem(bagId, slotId);
            return sellPrice;
        end
    end)();

    local function sellAllGrayItems()
        local amount = 0;
        for bagId = 0, NUM_BAG_FRAMES, 1 do
            for slotId = 1, GetContainerNumSlots(bagId), 1 do
                local link = GetContainerItemLink(bagId, slotId);
                if (link and string.find(link, ITEM_QUALITY_COLORS[0].hex)) then
                    amount = amount + getBagItemSellPrice(bagId, slotId);
                    UseContainerItem(bagId, slotId);
                end
            end
        end
        return amount;
    end;

    local f = CreateFrame("Frame");
    f:RegisterEvent("MERCHANT_SHOW");
    f:SetScript("OnEvent", function()
        local amount = sellAllGrayItems();
        if (amount > 0) then
            logi("Auto sell for " .. buildCoinString(amount));
        end
    end);
end)();
