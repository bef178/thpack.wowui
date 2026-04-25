ItemUtil = (function()
    local A = {}

    function A.findBagItem(name)
        for bagIndex = 0, NUM_BAG_FRAMES do
            for slotIndex = 1, GetContainerNumSlots(bagIndex) do
                local itemLink = GetContainerItemLink(bagIndex, slotIndex)
                local itemId = A.parseItemLink(itemLink)
                local item = A.getItem(itemId)
                if item and item.itemName and string.lower(item.itemName) == string.lower(name) then
                    item.bagIndex = bagIndex
                    item.slotIndex = slotIndex
                    return item
                end
            end
        end
    end

    function A.getItem(id)
        if not id then
            return
        end
        local name, str, quality, level, type, subType, maxStacks, equipLocation, texture = GetItemInfo(id)
        if name then
            return {
                type = "item",
                itemId = id,
                itemName = name,
                itemLink = nil,
                itemQuality = quality, -- int value in [0,7]
                itemLevel = level,
                itemType = type, -- e.g. "Armor", "Weapon", "Quest", etc.
                itemSubType = subType, -- e.g. "Shields"
                itemMaxStacks = maxStacks,
                itemEquipSlot = equipLocation, -- e.g. "INVTYPE_SHIELD"
                itemTexture = texture,
                itemRecyclePrice = nil,
                itemEnchantId = nil
            }
        end
    end

    function A.getEquippedItem(unit, slotId)
        local link = GetInventoryItemLink(unit, slotId)
        if link then
            local id = A.parseItemLink(link)
            if id then
                return A.getItem(id)
            end
        end
    end

    -- e.g. "|cffffffff|Hitem:4306::::::::60:258:::::::|h[Silk Cloth]|h|r"
    --   60: linkProviderLevel, this link is provided by a lv60 player
    --  258: linkProviderSpecializationId, this link is provided by a shadow priest
    function A.parseItemLink(itemLink)
        if not itemLink then
            return
        end
        local itemColorString, itemString, itemNameString = String.match(itemLink, "^\124cff(%x*)\124H(item:[%-?%d:]+)\124h%[(.+)%]\124h\124r$")
        if not itemColorString then
            return
        end
        return A._parseItemString(itemString)
    end

    function A._parseItemString(itemString)
        local itemId, enchantId, suffixId, linkProviderSpecializationId = String.match(itemString, "^item:(%d+):?(%d*):?(%d*):?(%d*)")
        if not itemId then
            return
        end
        return itemId, enchantId
    end

    return A
end)()
