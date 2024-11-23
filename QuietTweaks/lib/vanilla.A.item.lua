local A = A;

A.getBagItem = function(name)
    for bagIndex = 0, NUM_BAG_FRAMES do
        for slotIndex = 1, GetContainerNumSlots(bagIndex) do
            local itemLink = GetContainerItemLink(bagIndex, slotIndex);
            local itemName = itemLink and String.match(itemLink, '%[([^%]]+)%]') or nil;
            if (itemName and string.lower(itemName) == string.lower(name)) then
                local texture = GetContainerItemInfo(bagIndex, slotIndex);
                return {
                    type = "item",
                    itemTexture = texture,
                    bagIndex = bagIndex,
                    slotIndex = slotIndex,
                };
            end
        end
    end
end;
