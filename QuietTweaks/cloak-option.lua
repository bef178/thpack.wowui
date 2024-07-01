-- checkbox to control hat/cloak visible/invisible

local function createCheckboxWithLabel(parentFrame)
    local f = CreateFrame("CheckButton", nil, parentFrame, "OptionsCheckButtonTemplate");
    f:SetWidth(20);
    f:SetHeight(20);
    f:SetHitRectInsets(1, 1, 1, 1);
    f:SetToplevel(true);

    local t = f:CreateFontString(nil, "OVERLAY", "NumberFontNormal");
    t:SetTextColor(1, 1, 1);
    t:SetWidth(20);
    t:SetPoint("BOTTOMLEFT", f, "BOTTOMRIGHT", 5, 0);
    f.labelFontString = t;

    return f;
end

local function createShowHatOption(parentFrame)
    local f = createCheckboxWithLabel(parentFrame);
    -- f:SetPoint("TOPRIGHT", CharacterHeadSlot, "TOPRIGHT", 3, 3);
    f:SetScript("OnEnter", function()
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:SetText("Check to show hat");
    end);
    f:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);
    f:SetScript("OnClick", function()
        ShowHelm(not ShowingHelm());
    end);
    f:RegisterEvent("UNIT_MODEL_CHANGED");
    f:SetScript("OnEvent", function()
        f:SetChecked(ShowingHelm());
    end);
    f:SetChecked(ShowingHelm());
    f.labelFontString:SetText("Showing hat");
    return f;
end

local function createShowCloakOption(parentFrame)
    local f = createCheckboxWithLabel(parentFrame);
    -- f:SetPoint("TOPRIGHT", CharacterBackSlot, "TOPRIGHT", 3, 3);
    f:SetScript("OnEnter", function()
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
        GameTooltip:SetText("Check to show cloak");
    end);
    f:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);
    f:SetScript("OnClick", function()
        ShowCloak(not ShowingCloak());
    end);
    f:RegisterEvent("UNIT_MODEL_CHANGED");
    f:SetScript("OnEvent", function()
        f:SetChecked(ShowingCloak());
    end);
    f:SetChecked(ShowingCloak());
    f.labelFontString:SetText("Showing cloak");
    return f;
end

local function createOptions(modelFrame)
    local f = createShowHatOption(modelFrame);
    f:SetPoint("TOPLEFT", modelFrame, "TOPLEFT", 5, -5);

    local f1 = createShowCloakOption(modelFrame);
    f1:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -3);
end

(function()
    createOptions(CharacterModelFrame);
end)();
