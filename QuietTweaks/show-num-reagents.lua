local hookGlobalFunction = A.hookGlobalFunction;

(function()
    local getReagentNameByActionSlotId = (function()
        local reagentRegex = GetText("SPELL_REAGENTS") .. "(.+)";
        local tooltip = CreateFrame("GameTooltip", "aReagentTooltip", nil, "GameTooltipTemplate");
        return function(actionSlotId)
            tooltip:ClearLines();
            tooltip:SetOwner(UIParent, "ANCHOR_NONE");
            tooltip:SetAction(actionSlotId);
            for _, region in pairs({ tooltip:GetRegions() }) do
                if (region and region:GetObjectType() == "FontString") then
                    local line = region:GetText();
                    local s = String.match(line or "", reagentRegex);
                    if (s) then
                        return s;
                    end
                end
            end
        end;
    end)();

    local getReagentCountByActionSlotId = function(actionSlotId)
        local reagentName = getReagentNameByActionSlotId(actionSlotId);
        if (not reagentName) then
            return;
        end
        local n = 0;
        for bagId = 0, NUM_BAG_FRAMES do
            for slotId = 1, GetContainerNumSlots(bagId) do
                local itemLink = GetContainerItemLink(bagId, slotId);
                local itemName = itemLink and String.match(itemLink, '%[([^%]]+)%]') or nil;
                if (itemName and itemName == reagentName) then
                    local itemTexture, itemCount = GetContainerItemInfo(bagId, slotId);
                    n = n + itemCount;
                end
            end
        end
        return n;
    end;

    hookGlobalFunction("ActionButton_UpdateCount", "post_hook", function(...)
        local actionSlotId = ActionButton_GetPagedID(this);
        local reagentCount = getReagentCountByActionSlotId(actionSlotId);
        local reagentCountText;
        if (reagentCount) then
            if (reagentCount > 99) then
                reagentCountText = "*";
            else
                reagentCountText = tostring(reagentCount);
            end
        else
            reagentCountText = nil;
        end
        local textView = _G[this:GetName() .. "Count"];
        textView:SetText(reagentCountText);
    end);
end)();
