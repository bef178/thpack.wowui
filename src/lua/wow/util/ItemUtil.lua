ItemUtil = (function()
    local A = {}

    function A.findBagItemByName(name)
        for bagId = 0, NUM_BAG_FRAMES do
            for slotId = 1, GetContainerNumSlots(bagId) do
                local itemLink = GetContainerItemLink(bagId, slotId)
                local itemId = A.parseItemLink(itemLink)
                local itemName = GetItemInfo(itemId)
                if itemName and itemName == name then
                    return bagId, slotId
                end
            end
        end
    end

    -- (0, 1) => the topleft item in backpack
    function A.getBagItemId(bagId, slotId)
        local link = GetContainerItemLink(bagId, slotId)
        return A.parseItemLink(link)
    end

    function A.getBagItemLink(bagId, slotId)
        return GetContainerItemLink(bagId, slotId)
    end

    function A.getItem(id)
        if not id then
            return
        end
        -- GetItemInfo(16724): "Lightforge Gauntlets", "item:16724:0:0:0", 3, 54, Armor, Plate, 1, "INVTYPE_HAND", "Interface\\Icons\\INV_Gauntlets_19", 9091
        -- GetItemInfo(14023): "Barov Peasant Caller", "item:14023:0:0:0", 3, 0, "Armor", "Miscellaneous", 1, "INVTYPE_TRINKET", "Interface\\Icons\\INV_Misc_Bell_01", 8991
        -- GetItemInfo(4306): "Silk Cloth", "item:4306:0:0:0", 1, 0, "Trade Goods", "Trade Goods", 20, "", "Interface\\Icons\\INV_Fabric_Silk_01", 150
        local itemName, itemString, itemRarity, itemReqLevel, itemType, itemSubType, itemMaxStacks, itemEquipSlot,
            itemFileId, itemRecyclePrice = GetItemInfo(id)
        if itemName then
            return {
                type = "item",
                itemId = id,
                itemName = itemName,
                itemLink = nil,
                itemRarity = itemRarity, -- int value in [0,7]
                itemReqLevel = itemReqLevel,
                itemType = itemType, -- e.g. "Armor", "Weapon", "Quest", etc.
                itemSubType = itemSubType, -- e.g. "Shields"
                itemMaxStacks = itemMaxStacks,
                itemEquipSlot = itemEquipSlot, -- e.g. "INVTYPE_SHIELD"
                itemFileId = itemFileId,
                itemRecyclePrice = itemRecyclePrice,
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
        local itemColorString, itemString, itemNameString = String.match(itemLink,
            "^\124cff(%x*)\124H(item:[%-?%d:]+)\124h%[(.+)%]\124h\124r$")
        if not itemColorString then
            return
        end
        return A.parseItemString(itemString)
    end

    function A.parseItemString(itemString)
        local itemId, enchantId, suffixId, providerSpecId = String.match(itemString, "^item:(%d+):?(%d*):?(%d*):?(%d*)")
        if not itemId then
            return
        end
        return itemId, enchantId, suffixId, providerSpecId
    end

    return A
end)()
