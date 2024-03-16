A = {};

A.logi = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
    local f = DEFAULT_CHAT_FRAME or ChatFrame1;
    local a = {a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16};
    for i, v in pairs(a) do
        f:AddMessage(v);
    end
end;

A.logd = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
    local a = {a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16};
    if (getn(a) == 0) then
        A.logi("-- 1 - nil: nil");
        return;
    end
    for i, v in pairs(a) do
        local vType = type(v);
        if (vType == "string" or vType == "number") then
            A.logi(string.format("-- %s - %s: %s", i, vType, tostring(v)));
        else
            A.logi(string.format("-- %s - %s", i, (tostring(v) or "N/A")));
        end
    end
end;

A.addSlashCommand = A.addSlashCommand or function(key, slashCommand, fn)
    setglobal("SLASH_" .. key .. "1", slashCommand);
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

----------------------------------------

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
            return string.format("%s gold %s silver %s copper", goldAmount, silverAmount, copperAmount);
        elseif (silverAmount > 0) then
            return string.format("%s silver %s copper", silverAmount, copperAmount);
        elseif (copperAmount > 0) then
            return string.format("%s copper", copperAmount);
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
