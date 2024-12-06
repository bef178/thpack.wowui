local A = A;

-- item slot border quality color
(function()
    local getQualityVertexColor = (function()
        local itemQualityColors = {
            [0] = "#9D9D9D", -- poor
            [1] = "#FFFFFF", -- common
            [2] = "#1EFF00", -- uncommon
            [3] = "#0070DD", -- rare
            [4] = "#A335EE", -- epic
            [5] = "#FF8000", -- legnedary
            [6] = "#E6CC80", -- artifact
            [7] = "#00CCFF", -- heirloom
        };
        return function(quality)
            local hex = itemQualityColors[quality];
            if (hex == nil) then
                return 0, 0, 0, 0;
            end
            return Color.toVertex(hex);
        end;
    end)();

    local renderQuality = function(slot, quality)
        if (not slot) then
            return;
        end
        if (not slot.borderFrame) then
            local f = CreateFrame("Frame", nil, slot, nil);
            f:SetAllPoints(slot);
            f:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
            });
            slot.borderFrame = f;
            f:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.2);
        end
        slot.borderFrame:SetBackdropBorderColor(getQualityVertexColor(quality));
    end;

    -- player paperdoll and inspect paperdoll
    do
        local invSlotNames = {
            [0] = "AmmoSlot",
            "HeadSlot",
            "NeckSlot",
            "ShoulderSlot",
            "ShirtSlot",
            "ChestSlot",
            "WaistSlot",
            "LegsSlot",
            "FeetSlot",
            "WristSlot",
            "HandsSlot",
            "Finger0Slot",
            "Finger1Slot",
            "Trinket0Slot",
            "Trinket1Slot",
            "BackSlot",
            "MainHandSlot",
            "SecondaryHandSlot",
            "RangedSlot",
            "TabardSlot",
        };

        local updatePlayerInventorySlots = function()
            for i, name in pairs(invSlotNames) do
                local slot = _G["Character" .. name];
                if (slot) then
                    local quality = GetInventoryItemQuality("player", i);
                    renderQuality(slot, quality);
                end
            end
        end;

        local f = CreateFrame("Frame", nil, CharacterFrame, nil);
        f:RegisterEvent("UNIT_INVENTORY_CHANGED");
        f:SetScript("OnEvent", updatePlayerInventorySlots);
        f:SetScript("OnShow", updatePlayerInventorySlots);

        local updateInspectUnitInventorySlots = function()
            for i, name in pairs(invSlotNames) do
                local slot = _G["Inspect" .. name];
                if (slot) then
                    local quality = GetInventoryItemQuality("target", i);
                    renderQuality(slot, quality);
                    -- local itemLink = GetInventoryItemLink("target", i);
                end
            end
        end;

        local f1 = CreateFrame("Frame", nil, InspectPaperDollFrame, nil);
        f1:RegisterEvent("UNIT_INVENTORY_CHANGED");
        f1:SetScript("OnEvent", updateInspectUnitInventorySlots);
        f1:SetScript("OnShow", updateInspectUnitInventorySlots);
    end

    -- carry-on bags and bank bags
    do
        local updateItemSlots = function()
            -- carry-on bag slots
            -- TODO
            for i = 1+111, NUM_BAG_FRAMES do
                local slot = _G["CharacterBag" .. (i - 1) .. "Slot"]; -- e.g. CharacterBag0Slot
                local quality = GetInventoryItemQuality("player", ContainerIDToInventoryID(slot:GetID()));
                renderQuality(slot, quality);
            end

            -- bag item slots
            for i = 1, NUM_CONTAINER_FRAMES do
                local bag = _G["ContainerFrame" .. i];
                if (bag and bag:IsShown()) then
                    local bagId = bag:GetID();
                    for j = 1, MAX_CONTAINER_ITEMS do
                        local slot = _G["ContainerFrame" .. i .. "Item" .. j];
                        if (slot) then
                            local itemLink = GetContainerItemLink(bagId, slot:GetID());
                            local itemId = A.parseItemLink(itemLink);
                            local item = itemId and A.getItem(itemId);
                            local quality = item and item.itemQuality or nil;
                            renderQuality(slot, quality);
                        end
                    end
                end
            end

            -- bank item slots
            if (BankFrame and BankFrame:IsShown()) then
                for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
                    local slot = _G["BankFrameItem" .. i];
                    if (slot) then
                        local itemLink = GetContainerItemLink(-1, i);
                        local itemId = A.parseItemLink(itemLink);
                        local item = itemId and A.getItem(itemId);
                        local quality = item and item.itemQuality or nil;
                        renderQuality(slot, quality);
                    end
                end
            end

            -- bank bag slots
            if (BankFrame and BankFrame:IsShown()) then
                -- TODO
                for i = 1+111, NUM_BANKBAGSLOTS, 1 do
                    local slot = _G["BankFrameBag" .. i];
                    if (slot) then
                        local quality = GetInventoryItemQuality("player", ContainerIDToInventoryID(slot:GetID()));
                        renderQuality(slot, quality);
                    end
                end
            end
        end;

        A.hookGlobalFunction("ContainerFrame_OnShow", "post_hook", updateItemSlots);

        local f = CreateFrame("Frame");
        f:RegisterEvent("BAG_OPEN");
        f:RegisterEvent("BAG_UPDATE");
        f:RegisterEvent("BANKFRAME_OPENED");
        f:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
        f:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
        f:SetScript("OnEvent", updateItemSlots);
    end
end)();
