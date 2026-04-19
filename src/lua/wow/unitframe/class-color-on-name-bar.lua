-- unitframe name background colored according to class
local Color = Color
local hookGlobalFunction = Util.hookGlobalFunction
local getClassColor = Util.getClassColor

local function enablePlayerClassColorTexture()
    local _, className = UnitClass("player")
    local texture = PlayerFrame:CreateTexture(nil, "BORDER")
    texture:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-LevelBackground]])
    texture:SetWidth(119)
    texture:SetHeight(19)
    texture:SetPoint("TOPLEFT", 106, -22)
    texture:SetVertexColor(Color.toVertex(getClassColor(className)))
end

local function enableTargetClassColorTexture()
    local texture = TargetFrameNameBackground
    texture:SetDrawLayer("BORDER")
    hookGlobalFunction("TargetFrame_CheckFaction", "post_hook", function(...)
        if (UnitIsPlayer("target")) then
            local _, className = UnitClass("target")
            local classColor = getClassColor(className) or "#808080"
            texture:SetVertexColor(Color.toVertex(classColor))
            texture:Show()
            return
        end
    end)
end

enablePlayerClassColorTexture()
enableTargetClassColorTexture()
