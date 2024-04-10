local hookGlobalFunction = A.hookGlobalFunction;

(function()
    hookGlobalFunction("BuffFrame_Enchant_OnUpdate", "post_hook", function(...)
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId,
                hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo();
        if (hasOffHandEnchant) then
            local textView = TempEnchant1Count;
            textView:SetText(offHandCharges > 0 and offHandCharges or nil);
        end
        if (hasMainHandEnchant) then
            local textView = hasOffHandEnchant and TempEnchant2Count or TempEnchant1Count;
            textView:SetText(mainHandCharges > 0 and mainHandCharges or nil);
        end
    end);
end)();
