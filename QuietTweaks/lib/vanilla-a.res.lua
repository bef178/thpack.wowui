A.getResource = (function()
    local addonName = "QuietTweaks";
    return function(resourceName)
        return "interface\\addons\\" .. addonName .. "\\resource\\" .. resourceName;
    end;
end)();
