Util = (function()
    local A = {
        addonName = "r2d2"
    }

    function A.getLoggerChatFrame()
        local name = A.addonName .. "Logger"
        local log = _G[name] or DEFAULT_CHAT_FRAME or ChatFrame1
        if not log then
            -- TODO build dedicated chat frame
        end
        return log
    end

    function A.logi(...)
        local a = arg
        local prefix = "[" .. A.addonName .. "] "
        local log = A.getLoggerChatFrame()
        if not log then
            error(prefix .. "Failed to get logger chat frame")
        end
        for i, v in ipairs(a) do
            log:AddMessage(prefix .. v)
        end
    end

    function A.logd(...)
        local a = arg
        if Array.size(a) == 0 then
            A.logi("-- 1 - nil: nil")
            return
        end
        for i, v in ipairs(a) do
            local vType = type(v)
            if vType == "string" or vType == "number" then
                A.logi(string.format("-- %s - %s: %s", i, vType, tostring(v)))
            else
                A.logi(string.format("-- %s - %s", i, (tostring(v) or "N/A")))
            end
        end
    end

    ------------------------------------------------------------

    function A.getResource(resName)
        return "interface\\addons\\" .. A.addonName .. "\\src\\resource\\" .. resName
    end

    ------------------------------------------------------------

    function A.hookGlobalFunction(funcName, behaviorType, callbackFunc)
        return A.hookMemberFunction(_G, funcName, behaviorType, callbackFunc)
    end

    function A.hookMemberFunction(funcContainer, funcName, hookType, callbackFunc)
        local func = funcContainer[funcName]
        if not func then
            return
        end

        local funcKey = tostring(func) .. funcName
        funcContainer[funcKey] = func
        if hookType == "pre_hook" then
            funcContainer[funcName] = function(...)
                callbackFunc(unpack(arg))
                funcContainer[funcKey](unpack(arg))
            end
        elseif hookType == "post_hook" then
            funcContainer[funcName] = function(...)
                funcContainer[funcKey](unpack(arg))
                callbackFunc(unpack(arg))
            end
        elseif hookType == "replace_hook" then
            funcContainer[funcName] = function(...)
                callbackFunc(unpack(arg))
            end
        elseif hookType == "hook" then
            funcContainer[funcName] = function(...)
                callbackFunc(func, unpack(arg))
            end
        else
            error("UnknownHookTypeException: " .. (hookType or "(nil)"))
        end
        return 1
    end

    function A.hookScript(f, scriptName, hookType, callbackFunc)
        local old = f:GetScript(scriptName)
        if hookType == "pre_hook" then
            f:SetScript(scriptName, function()
                callbackFunc()
                if old then
                    old()
                end
            end)
        elseif hookType == "post_hook" then
            f:SetScript(scriptName, function()
                if old then
                    old()
                end
                callbackFunc()
            end)
        elseif hookType == "replace_hook" then
            f:SetScript(scriptName, callbackFunc)
        elseif hookType == "hook" then
            f:SetScript(scriptName, function()
                callbackFunc(old)
            end)
        end
    end

    ------------------------------------------------------------

    function A.addSlashCommand(key, slashCommand, fn)
        _G["SLASH_" .. key .. "1"] = slashCommand
        SlashCmdList[key] = fn
    end

    A.addSlashCommand("aReload", "/reload", function()
        ReloadUI()
    end)

    A.addSlashCommand("aDebug", "/debug", function(x)
        -- if no log, probably `slashCommand` already exists
        A.logi("-------- printing: ")
        A.logd(loadstring("return " .. x)())
    end)

    A.addSlashCommand("aExp", "/exp", function()
        local exp = UnitXP("player")
        local maxExp = UnitXPMax("player")
        local bonusExp = GetXPExhaustion()
        if bonusExp then
            A.logi(string.format("exp: %d(%d) / %d", exp, exp + bonusExp, maxExp))
        else
            A.logi(string.format("exp: %d / %d", exp, maxExp))
        end
    end)

    ------------------------------------------------------------

    function A.buildClassTextureString240(className)
        local coords = CLASS_ICON_TCOORDS[className]
        if coords then
            return A.buildTextureString240([[Interface\WorldStateFrame\Icons-Classes]], coords[1], coords[2], coords[3], coords[4])
        end
    end

    local function breakDownCoppers(totalCoppers)
        local golds = math.floor(totalCoppers / 10000)
        totalCoppers = totalCoppers - golds * 10000
        local silvers = math.floor(totalCoppers / 100)
        local coppers = totalCoppers - silvers * 100
        return golds, silvers, coppers
    end

    function A.buildCoinString(totalCoppers)
        local golds, silvers, coppers = breakDownCoppers(totalCoppers)
        if golds > 0 then
            return string.format("%s Gold %s Silver %s Copper", golds, silvers, coppers)
        elseif silvers > 0 then
            return string.format("%s Silver %s Copper", silvers, coppers)
        elseif coppers > 0 then
            return string.format("%s Copper", coppers)
        end
    end

    function A.buildCoinString240(totalCoppers)
        if GetCoinTextureString then
            -- likely since 3.0.2
            return GetCoinTextureString(totalCoppers)
        end

        local fileId = [[Interface\MoneyFrame\UI-MoneyIcons]]
        local goldIcon = A.buildTextureString240(fileId, 0, 0.25, 0, 1)
        local silverIcon = A.buildTextureString240(fileId, 0.25, 0.5, 0, 1)
        local copperIcon = A.buildTextureString240(fileId, 0.5, 0.75, 0, 1)
        -- size 19x19 or 13x13
        local golds, silvers, coppers = breakDownCoppers(totalCoppers)
        if golds > 0 then
            return string.format("%s%s%s%s%s%s", golds, goldIcon, silvers, silverIcon, coppers, copperIcon)
        elseif silvers > 0 then
            return string.format("%s%s%s%s", silvers, silverIcon, coppers, copperIcon)
        elseif coppers > 0 then
            return string.format("%s%s", coppers, copperIcon)
        end
    end

    -- `|T` likely since 2.4.0
    function A.buildTextureString240(fileId, left, right, top, bottom)
        left = left or 0
        right = right or 1
        top = top or 0
        bottom = bottom or 1
        -- |T<fileId>:<height>:<width>:<offsetX>:<offsetY>:<textureWidth>:<textureHeight>:<left>:<right>:<top>:<bottom>:<r>:<g>:<b>|t
        return string.format("|T%s:0:0:0:0:100:100:%s:%s:%s:%s|t", fileId, left * 100, right * 100, top * 100, bottom * 100)
    end

    function A.buildSkullTextureString240()
        return A.buildTextureString240([[Interface\TargetingFrame\UI-TargetingFrame-Skull]])
    end

    local function breakDownSeconds(totalSeconds)
        if ChatFrame_TimeBreakDown then
            return ChatFrame_TimeBreakDown(totalSeconds)
        end
        local days = math.floor(totalSeconds / (24 * 60 * 60))
        totalSeconds = totalSeconds - days * (24 * 60 * 60)
        local hours = math.floor(totalSeconds / (60 * 60))
        totalSeconds = totalSeconds - hours * (60 * 60)
        local minutes = math.floor(totalSeconds / 60)
        local seconds = totalSeconds - minutes * 60
        return days, hours, minutes, seconds
    end

    function A.buildTimeString(totalSeconds)
        if type(totalSeconds) ~= "number" or totalSeconds <= 0 then
            return
        end

        local days, hours, minutes, seconds = breakDownSeconds(totalSeconds)
        if days > 0 then
            return string.format("%dd", days)
        elseif hours > 0 then
            if hours > 2 then
                return string.format("%dh", hours)
            else
                return string.format("%d\'", hours * 60 + minutes)
            end
        elseif minutes > 9 then
            return string.format("%d\'", minutes)
        else
            return string.format("%d\'%02d", minutes, seconds)
        end
    end

    function A.buildColoredString(colorString, s)
        return string.format("|cff%06x%s|r", Color.toInt24(colorString), s)
    end

    function A.getClassColor(className)
        if not className then
            return
        end
        if RAID_CLASS_COLORS then
            local v = RAID_CLASS_COLORS[String.toUpper(className)]
            if v then
                if v.colorStr then
                    return "#" .. String.substring(v.colorStr, 3, 8)
                else
                    return Color.fromVertex(v.r, v.g, v.b)
                end
            end
        end
    end

    function A.toPrintableLink(link)
        local s, _ = string.gsub(link, "\124", "\124\124")
        return s
    end

    return A
end)()
