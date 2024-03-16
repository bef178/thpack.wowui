A = A or {};

A.logi = function(...)
    local f = DEFAULT_CHAT_FRAME or ChatFrame1;
    local a = arg;
    for i, v in ipairs(a) do
        f:AddMessage(v);
    end
end;

A.logd = function(...)
    local a = arg;
    if (Map.size(a) == 0) then
        A.logi("-- 1 - nil: nil");
        return;
    end
    for i, v in ipairs(a) do
        local vType = type(v);
        if (vType == "string" or vType == "number") then
            A.logi(string.format("-- %s - %s: %s", i, vType, tostring(v)));
        else
            A.logi(string.format("-- %s - %s", i, (tostring(v) or "N/A")));
        end
    end
end;

A.addSlashCommand = A.addSlashCommand or function(key, slashCommand, fn)
    _G["SLASH_" .. key .. "1"] = slashCommand;
    SlashCmdList[key] = fn;
end;

----------------------------------------

A.addSlashCommand("aReload", "/reload", ReloadUI);

A.addSlashCommand("aPrint", "/debug", function(x)
    -- if no log, probably `slashCommand` already exists
    A.logi("-------- printing: ");
    A.logd(loadstring("return " .. x)());
end);

A.addSlashCommand("aExp", "/exp", function()
    local exp = UnitXP("player");
    local maxExp = UnitXPMax("player");
    local bonusExp = GetXPExhaustion();
    if (bonusExp) then
        A.logi(string.format("exp: %d(%d) / %d", exp, exp + bonusExp, maxExp));
    else
        A.logi(string.format("exp: %d / %d", exp, maxExp));
    end
end);

------------------------------------------------------------

A.getFunctionId = function(func)
    if (type(func) ~= "function") then
        error("InvalidArgumentException");
    end
    return String.substring(String.match(tostring(func), ": .+$"), 3);
end;

A.hookGlobalFunction = function(funcName, behaviorType, callbackFunc)
    return A.hookMemberFunction(_G, funcName, behaviorType, callbackFunc);
end;

A.hookMemberFunction = function(funcContainer, funcName, hookType, callbackFunc)
    local func = funcContainer[funcName];
    if (not func) then
        return;
    end

    local funcKey = A.getFunctionId(func) .. funcName;
    funcContainer[funcKey] = func;
    if (hookType == "pre_hook") then
        funcContainer[funcName] = function(...)
            callbackFunc(unpack(arg))
            funcContainer[funcKey](unpack(arg))
        end;
    elseif (hookType == "post_hook") then
        funcContainer[funcName] = function(...)
            funcContainer[funcKey](unpack(arg))
            callbackFunc(unpack(arg))
        end;
    elseif (hookType == "replace_hook") then
        funcContainer[funcName] = function(...)
            callbackFunc(unpack(arg))
        end;
    elseif (hookType == "hook") then
        funcContainer[funcName] = function(...)
            callbackFunc(func, unpack(arg))
        end;
    else
        error("UnknownHookTypeException: " .. (hookType or "(nil)"));
    end
    return 1;
end;

A.buildCoinString = function(amount)
    if (GetCoinTextureString) then
        return GetCoinTextureString(amount);
    end

    local buildCoinTextureString = function(goldAmount, silverAmount, copperAmount)
        local texture = "Interface\\MoneyFrame\\UI-MoneyIcons";
        local goldIcon = string.format("|T%s:0:0:0:0:100:100:%s:%s:%s:%s|t", texture, 0, 25, 0, 100);
        local silverIcon = string.format("|T%s:0:0:0:0:100:100:%s:%s:%s:%s|t", texture, 25, 50, 0, 100);
        local copperIcon = string.format("|T%s:0:0:0:0:64:16:%s:%s:%s:%s|t", texture, 32, 48, 0, 16);
        if (goldAmount > 0) then
            return string.format("%s%s%s%s%s%s", goldAmount, goldIcon, silverAmount, silverIcon, copperAmount, copperIcon);
        elseif (silverAmount > 0) then
            return string.format("%s%s%s%s", silverAmount, silverIcon, copperAmount, copperIcon);
        elseif (copperAmount > 0) then
            return string.format("%s%s", copperAmount, copperIcon);
        end
    end

    local buildCoinTextString = function(goldAmount, silverAmount, copperAmount)
        if (goldAmount > 0) then
            return string.format("%s Gold %s Silver %s Copper", goldAmount, silverAmount, copperAmount);
        elseif (silverAmount > 0) then
            return string.format("%s Silver %s Copper", silverAmount, copperAmount);
        elseif (copperAmount > 0) then
            return string.format("%s Copper", copperAmount);
        end
    end

    local goldAmount = math.floor(amount / 10000);
    amount = amount - goldAmount * 10000;
    local silverAmount = math.floor(amount / 100);
    amount = amount - silverAmount * 100;
    local copperAmount = amount;

    -- likely vanilla not support texture string
    return buildCoinTextString(goldAmount, silverAmount, copperAmount);
end;

A.getBagItemByName = function(name)
    for bagId = 0, NUM_BAG_FRAMES do
        for slotId = 1, GetContainerNumSlots(bagId) do
            local itemLink = GetContainerItemLink(bagId, slotId);
            local itemName = itemLink and String.match(itemLink, '%[([^%]]+)%]') or nil;
            if (itemName and string.lower(itemName) == string.lower(name)) then
                local texture = GetContainerItemInfo(bagId, slotId);
                return bagId, slotId, texture;
            end
        end
    end
end;