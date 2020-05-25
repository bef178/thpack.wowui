local data = {};

data.spells = {
    -- mutual
    "攻击", "射击",
    2764, -- throw [8,30]
    -- mage
    "火球术", "寒冰箭", "冰枪术", "奥术冲击", "变形术",
    -- monk
    "碎玉闪电", "嚎镇八方", "分筋错骨", "怒雷破",
    -- paladin
    853, -- 制裁之锤 [0,10]
    879, -- 驱邪术 [0,30]
    20271, -- 审判 [0,10]
    635, -- 圣光术 [0,40]
    1152, -- 纯净术 [0,30]
    -- priest
    "惩击", "暗言术：痛",
    -- rogue
    "飞镖投掷", "暗影步", "致盲", "闷棍", "背刺",
    -- shaman
    "闪电箭", "大地震击", "治疗波", "治疗之涌", "先祖之魂", "风剪",
    -- warlock
    686, -- 暗影箭 [0-30]
    5782, -- 恐惧术 [0-20]
    5697, -- 魔息术 [0-30]
    -- warrior
    100, -- charge [8,25]
    772, -- rend [melee]
    5246, -- intimidating-shout [0,10]
    "英勇投掷",
};

data.spellRanges = {};

local function filterCandidate(spells, spellRanges)
    table.clear(spellRanges);
    for _, v in pairs(spells) do
        local spellName = SpellBook.getSpellName(v);
        if (spellName) then
            local minRange, maxRange = SpellBook.getSpellRange(spellName);
            if (maxRange) then
                if (maxRange == 0) then
                    -- melee
                    maxRange = 5;
                end
                spellRanges[spellName] = { minRange, maxRange };
            end
        end
    end
end

local function getUnitRange(unit, spellRanges)
    if (not UnitExists(unit)) then
        return "";
    end

    if (UnitIsUnit(unit, "player")) then
        return "."; -- in case of in combat
    end

    local MAX_RANGE = 99;
    local resultRange = { 0, MAX_RANGE };
    for spellName, range in pairs(spellRanges) do
        local inRange = IsSpellInRange(spellName, unit);
        if (inRange == 1) then
            resultRange = Seg.op(resultRange, range[1], range[2], Seg.getIntersection);
        elseif (inRange == 0) then
            resultRange = Seg.op(resultRange, range[1], range[2], Seg.getSubstraction);
        end
    end

    if (resultRange[2] == MAX_RANGE) then
        return ".";
    end

    if (#resultRange == 2) then
        if (resultRange[1] == 0 or resultRange[1] >= 10) then
            return resultRange[2];
        end
    end

    local s = "";
    for i = 1, #resultRange, 2 do
        s = s .. resultRange[i] .. "-" .. resultRange[i + 1];
        if (i + 1 < #resultRange) then
            s = s .. ","
        end
    end
    return s;
end

--------

local f = CreateFrame("Frame", nil, UIParent, nil);
f:SetSize(1, 1);
f:SetPoint("TOPLEFT");

local textView = f:CreateFontString();
textView:SetFont(DAMAGE_TEXT_FONT, 24, "OUTLINE");
textView:SetTextColor(0, 1, 0);
textView:SetJustifyH("RIGHT");
textView:SetPoint("CENTER", UIParent, "CENTER", 0, -40);
f.textView = textView;

if (select(4, GetBuildInfo()) >= 20000) then
    f:RegisterEvent("PLAYER_TALENT_UPDATE");
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
end
f:RegisterEvent("LEARNED_SPELL_IN_TAB");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("PLAYER_REGEN_ENABLED");
f:RegisterEvent("PLAYER_REGEN_DISABLED");
f:RegisterEvent("PLAYER_TARGET_CHANGED");

f:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD"
            or event == "PLAYER_TALENT_UPDATE"
            or event == "ACTIVE_TALENT_GROUP_CHANGED"
            or event == "LEARNED_SPELL_IN_TAB") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        filterCandidate(data.spells, data.spellRanges);
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self.textView:SetTextColor(0, 1, 0);
    elseif (event == "PLAYER_REGEN_DISABLED") then
        self.textView:SetTextColor(1, 0, 0);
    elseif (event == "PLAYER_TARGET_CHANGED") then
        -- update immediately
        self:GetScript("OnUpdate")(self, 99);
    end
end);

f:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed;
    if (self.elapsed > 0.1) then
        self.elapsed = 0;
        self.textView:SetText(getUnitRange("target", data.spellRanges));
    end
end);