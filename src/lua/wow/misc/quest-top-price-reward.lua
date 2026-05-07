-- 自动选择最贵的任务奖励
local f = CreateFrame("Frame")
f:RegisterEvent("QUEST_COMPLETE")
f:SetScript("OnEvent", function()
    local topPrice = 0
    local topPriceIndex = 0
    for i = 1, GetNumQuestChoices() do
        local itemLink = GetQuestItemLink("choice", i)
        if itemLink then
            local itemId = ItemUtil.parseItemLink(itemLink)
            if itemId then
                local price = ItemUtil.getItem(itemId).itemRecyclePrice
                if price and price > topPrice then
                    topPrice = price
                    topPriceIndex = i
                end
            end
        end
    end
    if topPriceIndex > 0 then
        _G["QuestRewardItem" .. topPriceIndex]:Click()
    end
end)
