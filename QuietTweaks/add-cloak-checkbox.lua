-- checkbox to control cloak visible/invisible
(function()
    local cloakCheck = CreateFrame("CheckButton", nil, PaperDollFrame, "OptionsCheckButtonTemplate");
    cloakCheck:SetWidth(20);
    cloakCheck:SetHeight(20);
    cloakCheck:SetHitRectInsets(1, 1, 1, 1);
    cloakCheck:SetToplevel(true);

    cloakCheck:SetPoint("TOPRIGHT", CharacterBackSlot, "TOPRIGHT", 3, 3);

    cloakCheck:SetScript("OnEnter", function()
        GameTooltip:SetOwner(cloakCheck, "ANCHOR_RIGHT")
        GameTooltip:SetText("Check to show cloak");
    end);
    cloakCheck:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    cloakCheck:SetScript("OnClick", function()
        ShowCloak(not ShowingCloak());
    end);

    cloakCheck:RegisterEvent("UNIT_MODEL_CHANGED");
    cloakCheck:SetScript("OnEvent", function()
        cloakCheck:SetChecked(ShowingCloak());
    end);

	cloakCheck:SetChecked(ShowingCloak());
end)();

-- same for hat
(function()
    local hatCheck = CreateFrame("CheckButton", nil, PaperDollFrame, "OptionsCheckButtonTemplate");
    hatCheck:SetWidth(20);
    hatCheck:SetHeight(20);
    hatCheck:SetHitRectInsets(1, 1, 1, 1);
    hatCheck:SetToplevel(true);

    hatCheck:SetPoint("TOPRIGHT", CharacterHeadSlot, "TOPRIGHT", 3, 3);

    hatCheck:SetScript("OnEnter", function()
        GameTooltip:SetOwner(hatCheck, "ANCHOR_RIGHT")
        GameTooltip:SetText("Check to show hat");
    end);
    hatCheck:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    hatCheck:SetScript("OnClick", function()
        ShowHelm(not ShowingHelm());
    end);

    hatCheck:RegisterEvent("UNIT_MODEL_CHANGED");
    hatCheck:SetScript("OnEvent", function()
        hatCheck:SetChecked(ShowingHelm());
    end);

	hatCheck:SetChecked(ShowingHelm());
end)();
