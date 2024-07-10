-- mouse drag to roll the model

local function onMouseButtonDown(f, button)
    if (button == "LeftButton") then
        local x, y = GetCursorPosition();
        f.mouseX = x;
        f.mouseY = y;
    end
end

local function onMouseButtonUp(f, button)
    if (button == "LeftButton") then
        f.mouseX = nil;
        f.mouseY = nil;
    end
end

local function onMouseMove(f)
    if (f.mouseX ~= nil) then
        local x, y = GetCursorPosition();
        f:SetFacing(f:GetFacing() + ((x - f.mouseX) / 50));
        f.mouseX = x;
        f.mouseY = y;
	end
end

local function onMouseScroll(f, a1)
	local z, x, y = f:GetPosition();
	f:SetPosition(z + ((a1 > 0 and 0.6) or -0.6), x, y);
end

local function attachMouseScripts(model)
    if (not model) then
        return;
    end
    model:EnableMouse(true);
	model:EnableMouseWheel(true);
	model:SetScript("OnMouseDown", function()
        onMouseButtonDown(model, arg1);
    end);
	model:SetScript("OnMouseUp", function()
        onMouseButtonUp(model, arg1);
    end);
	model:SetScript("OnMouseWheel", function()
        onMouseScroll(model, arg1);
    end);
	model:SetScript("OnUpdate", function()
        onMouseMove(model);
    end);
end

(function()
    local f = CreateFrame("Frame");
    f:RegisterEvent("ADDON_LOADED");
    f:SetScript("OnEvent", function(...)
        if (event == "ADDON_LOADED") then
            local addonName = arg3;
            if (addonName == "Blizzard_AuctionUI") then
                attachMouseScripts(AuctionDressUpModel);
            elseif (addonName == "Blizzard_InspectUI") then
                attachMouseScripts(InspectModelFrame);
            end
        end
    end);
    attachMouseScripts(AuctionDressUpModel);
    attachMouseScripts(InspectModelFrame);
    attachMouseScripts(DressUpModel);
    attachMouseScripts(CharacterModelFrame);
    attachMouseScripts(TabardModel);
    attachMouseScripts(PetModelFrame);
    attachMouseScripts(PetStableModel);
end)();
