local presetKeyBindings = {
    ["ESCAPE"] = "TOGGLEGAMEMENU",
    ["TAB"] = "TARGETNEARESTENEMY",
    ["SHIFT-TAB"] = "TARGETPREVIOUSENEMY",
    ["SPACE"] = "JUMP",

    ["BUTTON3"] = "macro m3",
    ["BUTTON4"] = "macro m4",
    ["BUTTON5"] = "TOGGLEAUTORUN",
    ["MOUSEWHEELUP"] = "macro m3f",
    ["MOUSEWHEELDOWN"] = "macro m3b",
    ["CTRL-MOUSEWHEELUP"] = "CAMERAZOOMIN",
    ["CTRL-MOUSEWHEELDOWN"] = "CAMERAZOOMOUT",

    ["F1"] = "TOGGLECHARACTER0",
    ["F2"] = "TOGGLEWORLDMAP",
    ["F3"] = "OPENALLBAGS",
    ["F8"] = "INTERACTTARGET",
    ["F9"] = "ALLNAMEPLATES",
    ["F10"] = "TOGGLEGAMEMENU",
    ["F11"] = "TOGGLECHARACTER4",
    ["F12"] = "TOGGLE_MACRO_FRAME",
    ["SHIFT-F11"] = "TOGGLELFGPARENT",

    ["W"] = "MOVEFORWARD",
    ["S"] = "MOVEBACKWARD",
    ["A"] = "STRAFELEFT",
    ["D"] = "STRAFERIGHT",

    ["ALT-W"] = "TOGGLEAUTORUN",
    ["ALT-S"] = "macro alt-s",
    ["ALT-A"] = "PETATTACK",
    ["ALT-D"] = "macro alt-d",

    [";"] = "REPLY",
    ["SHIFT-;"] = "REPLY2",
    ["'"] = "OPENALLBAGS",
    ["/"] = "OPENCHATSLASH",
    ["L"] = "TOGGLEQUESTLOG",
    ["O"] = "TOGGLESOCIAL",
    ["P"] = "TOGGLESPELLBOOK",
    ["M"] = "TOGGLEWORLDMAP",
    ["ALT-Z"] = "TOGGLEUI",
    ["PRINTSCREEN"] = "SCREENSHOT",

    ["1"] = "ACTIONBUTTON1",
    ["2"] = "ACTIONBUTTON2",
    ["3"] = "ACTIONBUTTON3",
    ["4"] = "ACTIONBUTTON4",
    ["5"] = "ACTIONBUTTON5",

    ["Z"] = "MULTIACTIONBAR1BUTTON1",
    ["X"] = "MULTIACTIONBAR1BUTTON2",
    ["C"] = "MULTIACTIONBAR1BUTTON3",
    ["V"] = "MULTIACTIONBAR1BUTTON4",
    ["B"] = "MULTIACTIONBAR1BUTTON5",
    ["F"] = "MULTIACTIONBAR1BUTTON6",
    ["G"] = "MULTIACTIONBAR1BUTTON7",
    ["Q"] = "MULTIACTIONBAR1BUTTON8",
    ["E"] = "MULTIACTIONBAR1BUTTON9",
    ["R"] = "MULTIACTIONBAR1BUTTON10",
    ["T"] = "MULTIACTIONBAR1BUTTON11",
    ["SHIFT-S"] = "MULTIACTIONBAR1BUTTON12",
};

local function fillPresetKeyBindings(bindings)
    local modifierKeys = [[:ctrl-:alt-:shift-:ctrl-shift-]];
    local keys = {
        [[button3:button4:button5:mousewheelup:mousewheeldown]],
        [[escape:f1:f2:f3:f4:f5:f6:f7:f8:f9:f10:f11:f12]],
        [[0:1:2:3:4:5:6:7:8:9]],
        [[a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z]],
        [[tab:space:`:-:=:[:]:\:;:':,:.:/]],
        [[insert:delete:home:end:pageup:pagedown]],
        [[up:down:left:right]],
        [[numlock:numpadplus:numpadminus:numpadmultiply:numpaddivide:numpaddecimal]],
        [[numpad0:numpad1:numpad2:numpad3:numpad4:numpad5:numpad6:numpad7:numpad8:numpad9]]
    };

    for _, s in ipairs(keys) do
        for _, k in ipairs(String.split(s, ":")) do
            for _, m in ipairs(String.split(modifierKeys, ":")) do
                local key = string.upper(m .. k);
                if (not bindings[key]) then
                    bindings[key] = "unbind";
                end
            end
        end
    end
    return bindings;
end

local function loadPresetKeyBindings()
    for key, v in pairs(presetKeyBindings or {}) do
        if (v == "unbind") then
            SetBinding(key, nil);
        else
            SetBinding(key, v);
        end
    end
end

local function savePresetKeyBindings()
    local i = GetCurrentBindingSet();
    if i and (i == 1 or i == 2) then
        SaveBindings(i);
    end
end

(function()
    fillPresetKeyBindings(presetKeyBindings);

    A.addSlashCommand("aLoadPresetKeyBindings", "/loadpresetkeybindings", function()
        loadPresetKeyBindings();
        A.logi("Preset key bindings loaded.");
        savePresetKeyBindings();
    end);

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function()
        f:UnregisterAllEvents();
        f:Hide();
        A.logi("To load preset key bindings, type \"/loadpresetkeybindings\".");
    end);
end)();
