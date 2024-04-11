-- vanilla allows shift-click to pick action, which is not good
-- shift-drag to pick action, ignoring LOCK_ACTIONBAR option
(function()
    local abOnClick = function()
        if (MacroFrame_SaveMacro) then
            MacroFrame_SaveMacro();
        end
        UseAction(ActionButton_GetPagedID(this), 1);
        ActionButton_UpdateState();
    end;

    local abOnDragStart = function()
        if (IsShiftKeyDown()) then
            PickupAction(ActionButton_GetPagedID(this));
            ActionButton_UpdateHotkeys(this.buttonType);
            ActionButton_UpdateState();
            ActionButton_UpdateFlash();
        end
    end;

    local abOnReceiveDrag = function()
        if (IsShiftKeyDown()) then
            PlaceAction(ActionButton_GetPagedID(this));
            ActionButton_UpdateHotkeys(this.buttonType);
            ActionButton_UpdateState();
            ActionButton_UpdateFlash();
        end
    end;

    for i = 1, 12, 1 do
        for _, prefix in ipairs({
            "ActionButton",
            "BonusActionButton",
            "MultiBarBottomLeftButton",
            "MultiBarBottomRightButton",
            "MultiBarRightButton",
            "MultiBarLeftButton"
        }) do
            local ab = _G[prefix .. i];
            ab:SetScript("OnClick", abOnClick);
            ab:SetScript("OnDragStart", abOnDragStart);
            ab:SetScript("OnReceiveDrag", abOnReceiveDrag);
        end
    end
end)();
