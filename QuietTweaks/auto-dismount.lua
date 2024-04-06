-- auto dismount
(function()
    local dismountIfMounted = (function()
        if (IsMounted and Dismount) then
            return function()
                if (IsMounted()) then
                    Dismount();
                end
            end;
        end

        local MOUNTED_BUFF_TEXTURE_KEYWORD = {
            "_mount_",
            "_qirajicrystal_",
            "ability_bullrush",
            "ability_racial_bearform",
            "ability_druid_catform",
            "ability_druid_travelform",
            "ability_druid_aquaticform",
            "ability_hunter_pet_turtle",
            "inv_misc_head_dragon_black",
            "inv_pet_speedy",
            "spell_nature_forceofnature",
            "spell_nature_spiritwolf",
            "spell_nature_swiftness",
        };
        return function()
            for i = 0, 15, 1 do
                local texture = GetPlayerBuffTexture(i);
                if (texture) then
                    texture = string.lower(texture);
                    for _, keyword in ipairs(MOUNTED_BUFF_TEXTURE_KEYWORD) do
                        if (string.find(texture, keyword)) then
                            CancelPlayerBuff(i);
                        end
                    end
                end
            end
        end;
    end)();

    local NOT_WITH_MOUNTED_MESSAGES = {
        ERR_ATTACK_MOUNTED,
        ERR_CANT_INTERACT_SHAPESHIFTED,
        ERR_MOUNT_ALREADYMOUNTED,
        ERR_MOUNT_SHAPESHIFTED,
        ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
        ERR_NOT_WHILE_MOUNTED or "",
        ERR_NOT_WHILE_SHAPESHIFTED,
        ERR_TAXIPLAYERALREADYMOUNTED,
        ERR_TAXIPLAYERSHAPESHIFTED,
        PLAYER_LOGOUT_FAILED_ERROR,
        SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED,
        SPELL_FAILED_NOT_MOUNTED,
        SPELL_FAILED_NOT_SHAPESHIFT,
        SPELL_NOT_SHAPESHIFTED,
        SPELL_NOT_SHAPESHIFTED_NOSPACE,
    };

    local f = CreateFrame("Frame");
    f:RegisterEvent("UI_ERROR_MESSAGE");
    f:SetScript("OnEvent", function()
        local errorMessage = arg1;
        if (errorMessage and Array.contains(NOT_WITH_MOUNTED_MESSAGES, errorMessage)) then
            dismountIfMounted();
        end
    end);
end)();

-- auto stand up
(function()
    local NOT_STANDING_MESSAGES = {
        SPELL_FAILED_NOT_STANDING,
        ERR_CANTATTACK_NOTSTANDING,
        ERR_LOOT_NOTSTANDING,
        ERR_TEXTNOTSTANDING,
    };

    local f = CreateFrame("Frame");
    f:RegisterEvent("UI_ERROR_MESSAGE");
    f:SetScript("OnEvent", function()
        local errorMessage = arg1;
        if (errorMessage and Array.contains(NOT_STANDING_MESSAGES, errorMessage)) then
            DoEmote("STAND");
        end
    end);
end)();
