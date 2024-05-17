-- vanilla allows shift-click to pick action, which is not good
-- shift-drag to pick action, ignoring LOCK_ACTIONBAR option
(function()
    local onClick = function()
        if (MacroFrame_SaveMacro) then
            MacroFrame_SaveMacro();
        end
        UseAction(ActionButton_GetPagedID(this), 1);
        ActionButton_UpdateState();
    end;

    local onDragStart = function()
        if (IsShiftKeyDown()) then
            PickupAction(ActionButton_GetPagedID(this));
            ActionButton_UpdateHotkeys(this.buttonType);
            ActionButton_UpdateState();
            ActionButton_UpdateFlash();
        end
    end;

    local onReceiveDrag = function()
        PlaceAction(ActionButton_GetPagedID(this));
        ActionButton_UpdateHotkeys(this.buttonType);
        ActionButton_UpdateState();
        ActionButton_UpdateFlash();
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
            ab:SetScript("OnClick", onClick);
            ab:SetScript("OnDragStart", onDragStart);
            ab:SetScript("OnReceiveDrag", onReceiveDrag);
        end
    end
end)();
