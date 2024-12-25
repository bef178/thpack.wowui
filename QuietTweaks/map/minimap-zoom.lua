(function()
    Minimap:EnableMouseWheel(true);
    Minimap:SetScript("OnMouseWheel", function()
        if (arg1 > 0) then
            Minimap_ZoomIn();
        else
            Minimap_ZoomOut();
        end
    end)
end)();
