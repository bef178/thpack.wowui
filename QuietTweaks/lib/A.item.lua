local A = A;

A.findBagItem = function(name)
    for bagIndex = 0, NUM_BAG_FRAMES do
        for slotIndex = 1, GetContainerNumSlots(bagIndex) do
            local itemLink = GetContainerItemLink(bagIndex, slotIndex);
            local itemId = A.parseItemLink(itemLink);
            local item = A.getItem(itemId);
            if (item and item.itemName and string.lower(item.itemName) == string.lower(name)) then
                item.bagIndex = bagIndex;
                item.slotIndex = slotIndex;
                return item;
            end
        end
    end
end;

A.getItem = function(id)
    if (not id) then
        return;
    end
    local name, str, quality, level, type, subType, maxStacks, equipLocation, texture = GetItemInfo(id);
    if (name) then
        return {
            type = "item",
            itemId = id,
            itemName = name,
            itemLink = nil,
            itemQuality = quality, -- int value in [0,7]
            itemLevel = level,
            itemType = type, -- e.g. "Armor", "Weapon", "Quest", etc.
            itemMaxStacks = maxStacks,
            itemTexture = texture,
            itemRecyclePrice = nil,
            itemEnchantId = nil,
        };
    end
end;

-- e.g. "|cffffffff|Hitem:4306::::::::60:258:::::::|h[Silk Cloth]|h|r"
--   60: linkProviderLevel, this link is provided by a lv60 player
--  258: linkProviderSpecializationId, this link is provided by a shadow priest
A.parseItemLink = function(itemLink)
    if (not itemLink) then
        return;
    end
    local itemColorString, itemString, itemNameString = string.match(itemLink, "^|cff(%x*)|H(item:[%-?%d:]+)|h%[(.+)%]|h|r$");
    if (not itemColorString) then
        return;
    end
    return A.parseItemString(itemString);
end;

A.parseItemString = function(itemString)
    local itemId, enchantId, suffixId, linkProviderSpecializationId = string.match(itemString, "^item:(%d+):?(%d*):?(%d*):?(%d*)");
    if (not itemId) then
        return;
    end
    return itemId, enchantId;
end;

A.toPrintableItemLink = function(itemLink)
    local s, _ = string.gsub(itemLink, "\124", "\124\124");
    return s;
end;
