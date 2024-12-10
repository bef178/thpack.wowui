local A = A;

local pda = A.SlotMan:new();
pda.slot_style = "sharp_square";
pda.slot_size = 31;
pda.slot_margin = 4;
pda.max_x_slots = 4;
pda.anchor:ClearAllPoints();
pda.anchor:SetPoint("TOPLEFT", UIParent, "CENTER", 390, 120);

pda.adviceBuilds = {};

function pda:register(build)
    if (build) then
        Array.add(self.adviceBuilds, build);
    end
end

function pda:start()
    local f = self.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(...)
        if (event == "PLAYER_ENTERING_WORLD") then
            pda:clearAllSlotModels();
            local activeBuild = self.adviceBuilds[1]; -- TODO switch among builds
            if (activeBuild) then
                local slotModels = activeBuild.prepareSlotModels(function()
                    return pda:newSlotModel();
                end);
                for _, slotModel in ipairs(slotModels) do
                    pda:addSlotModelAndDock(slotModel);
                end
                pda:renderAllSlotModels();
            end
        end
    end);
    f:SetScript("OnUpdate", (function()
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (acc < 0.07) then
                return;
            end

            local activeBuild = self.adviceBuilds[1];
            if (activeBuild) then
                activeBuild.onElapsed(acc);
                pda:renderAllSlotModels();
            end

            acc = 0;
        end;
    end)());
end

pda:start();

_G.pda = pda;
