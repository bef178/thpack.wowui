local function updateWeaponEnchantCharges()
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
    local mainHandTextRegion, offHandTextRegion
    if hasOffHandEnchant then
        offHandTextRegion = TempEnchant1Count
        if hasMainHandEnchant then
            mainHandTextRegion = TempEnchant2Count
        end
    elseif hasMainHandEnchant then
        mainHandTextRegion = TempEnchant2Count
    end
    if mainHandTextRegion then
        mainHandTextRegion:SetText(mainHandCharges > 0 and mainHandCharges or nil)
    end
    if offHandTextRegion then
        offHandTextRegion:SetText(offHandCharges > 0 and offHandCharges or nil)
    end
end

Util.hookGlobalFunction("BuffFrame_Enchant_OnUpdate", "post_hook", updateWeaponEnchantCharges)
