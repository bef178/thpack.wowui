local A = A;

local pda = A.SlotMan:new();
pda.slot_style = "sharp_square";
pda.slot_size = 31;
pda.slot_margin = 4;
pda.max_x_slots = 4;
pda.builds = {};
pda.anchor:ClearAllPoints();
pda.anchor:SetPoint("TOPLEFT", UIParent, "CENTER", 390, 120);

function pda:newBuild()
    return {
        name = "noname",
        description = "",
        createSlotModels = function() end,
        updateSlotModels = function() end,
    };
end

function pda:register(build)
    if (build) then
        Array.add(self.builds, build);
    end
end

function pda:start()
    local f = self.anchor;
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("SPELLS_CHANGED");
    f:SetScript("OnEvent", function(...)
        local activeBuild = self.builds[1];     -- TODO switch among builds
        if (activeBuild) then
            pda:render(activeBuild:createSlotModels());
        end
    end);
    f:SetScript("OnUpdate", (function()
        local acc = 0;
        return function(...)
            local elapsed = arg1;
            acc = acc + elapsed;
            if (acc > 0.07) then
                local activeBuild = self.builds[1];
                if (activeBuild) then
                    activeBuild:updateSlotModels();
                    pda:render();
                end
                acc = 0;
            end
        end;
    end)());
end

pda:start();

_G.pda = pda;
