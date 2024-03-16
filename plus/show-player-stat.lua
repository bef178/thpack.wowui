-- stick on your own path

-- statistics on player's current status
-- what really matters:
--  tank e.g. warrior
--      defense rank, armor, block, block amount, dodge, parry
--  healer e.g. priest
--      sp, heal power, spell crit
--  caster e.g. mage
--      spell power, spell crit, spell hit
--  melee dps e.g. rogue
--      ap, dps, dph, crit, hit
--  ranged dps e.g. hunter
--      ranged ap, ranged dps, ranged dph, ranged crit, hit

local StatBook = {};

-- return dps, dph
StatBook.getUnitDamageWithWeapon = function(unit)
    local mainhandCooldown, offhandCooldown = UnitAttackSpeed(unit);
    local mainhandMinDamage, mainhandMaxDamage, offhandMinDamage, offhandMaxDamage, posBuff, negBuff, multiple = UnitDamage(unit);
    -- fist cooldown = 2.0
    local mainhandDph = ((mainhandMinDamage + mainhandMaxDamage) / 2 + posBuff + negBuff) * multiple;
    local mainhandDps = mainhandDph / mainhandCooldown;
    if (not offhandCooldown) then
        return mainhandDps, mainhandDph;
    end

    local offhandDph = ((offhandMinDamage + offhandMaxDamage) / 2 + posBuff + negBuff) * multiple;
    local offhandDps = offhandDph / offhandCooldown;
    local offhandMultiplier = 0.5; -- TODO some talents will change this
    return mainhandDps + offhandDps * offhandMultiplier, mainhandDph;
end;

StatBook.getUnitAttackPower = function(unit)
    local base, posBuff, negBuff = UnitAttackPower(unit);
    return (base + posBuff + negBuff) or 0;
end;

-- including wand
StatBook.getUnitRangedDamageWithWeapon = function(unit)
    local cooldown, minDamage, maxDamage, posBuff, negBuff, multiple = UnitRangedDamage(unit);
    if (weaponCooldown and weaponCooldown > 0) then
        local dph = ((minDamage + maxDamage) / 2 + posBuff + negBuff) * multiple;
        local dps = dph / cooldown;
        return dps, dph;
    end
end;

StatBook.getUnitRangedAttackPower = function(unit)
    local base, posBuff, negBuff = UnitRangedAttackPower(unit);
    return (base + posBuff + negBuff) or 0;
end;

StatBook.getDefenseRank = function()
    local rank = 0;
    for i = 1, GetNumSkillLines(), 1 do
        local skillName, _, _, base, _, bonus = GetSkillLineInfo(i);
        if (skillName == DEFENSE) then
            rank = base + bonus;
            break;
        end
    end
    if (rank == 0) then
        local baseRank, bonusRank = UnitDefense("player");
        rank = baseRank + bonusRank;
    end
    return rank;
end;

StatBook.getUnitArmor = function(unit)
    unit = unit or "player";
    local _, effectiveArmor, _, _, _ = UnitArmor(unit);
    return effectiveArmor or 0;
end;

StatBook.getRowItems = (function()
    local executors = {
        ["melee"] = function()
            -- 132223:ability_meleedamage
            -- 132333:ability_warrior_battleshout
            -- 132090:ability_backstab
            -- 132222:ability_marksmanship
            -- 132329:ability_trueshot
            -- 132169:ability_hunter_criticalshot
            local unit = "player";
            local dps, dph = StatBook.getUnitDamageWithWeapon(unit);
            local ap = StatBook.getUnitAttackPower(unit);
            local critChance = GetCritChance() or 0;
            local hitChance = GetHitModifier() or 0;
            local weaponTexture = GetInventoryItemTexture(unit, INVSLOT_MAINHAND) or 132223;
            return {
                { "meleeDps", weaponTexture, string.format("%.01f", dps) },
                { "meleeAp", 135906, string.format("%d", ap) },
                { "meleeCritChance", 132090, string.format("%.02f%%", critChance), },
                { "hitChance", 132222, string.format("+%.01f%%", hitChance) },
            };
        end,
        ["ranged"] = function()
            local unit = "player";
            local rangedDps, rangedDph = StatBook.getUnitRangedDamageWithWeapon(unit);
            local rangedAp = StatBook.getUnitRangedAttackPower(unit);
            local rangedCritChance = GetRangedCritChance() or 0;
            local hitChance = GetHitModifier() or 0;
            local rangedWeaponTexture = GetInventoryItemTexture(unit, INVSLOT_RANGED);
            return {
                { "rangedDps", rangedWeaponTexture, string.format("%.01f", rangedDps) },
                { "rangedAp", 132329, string.format("%d", rangedAp) },
                { "rangedCritChance", 132169, string.format("%.02f%%", rangedCritChance) },
                { "hitChance", 132222, string.format("+%.01f%%", hitChance) },
            };
        end,
        ["spell"] = function()
            -- 136096:spell_nature_starfall
            local spellBonusDamageHoly = GetSpellBonusDamage(2);
            local spellBonusDamageFire = GetSpellBonusDamage(3);
            local spellBonusDamageNature = GetSpellBonusDamage(4);
            local spellBonusDamageFrost = GetSpellBonusDamage(5);
            local spellBonusDamageShadow = GetSpellBonusDamage(6);
            local spellBonusDamageArcane = GetSpellBonusDamage(7);
            local spellBonusHealing = GetSpellBonusHealing();
            local spellCritChance = GetSpellCritChance() or 0;
            local spellHitChance = GetSpellHitModifier() or 0;
            local spellBonusDamage = math.min(
                spellBonusDamageHoly,
                spellBonusDamageFire,
                spellBonusDamageNature,
                spellBonusDamageFrost,
                spellBonusDamageShadow,
                spellBonusDamageArcane);
            return {
                { "spellBonus", 136096, string.format("%d/%d", spellBonusDamage, spellBonusHealing) },
                { "spellCritChance", 132090, string.format("%.02f%%", spellCritChance) },
                { "spellHitChance", 132222, string.format("+%.01f%%", spellHitChance) },
            };
        end,
        ["defense"] = function()
            -- 132341:ability_warrior_defensivestance
            -- 135893:spell_holy_devotionaura
            -- 136047:spell_nature_invisibilty
            -- 132269:ability_parry
            -- 132110:ability_defend
            local defenseRank = StatBook.getDefenseRank();
            local armor = StatBook.getUnitArmor();
            local blockChance = GetBlockChance() or 0;
            local blockAmount = GetShieldBlock() or 0;
            local dodgeChance = GetDodgeChance() or 0;
            local parryChance = GetParryChance() or 0;
            return {
                { "defenseRank", 132341, string.format("%d/%d", defenseRank, armor) },
                { "dodgeChance", 136047, string.format("%.1f%%", dodgeChance) },
                { "parryChance", 132269, string.format("%.1f%%", parryChance) },
                { "block", 132110, string.format("%.1f%%/%d", blockChance, blockAmount) },
            };
        end,
    };

    return function(key)
        local exec = executors[key];
        if (not exec) then
            return;
        end
        return exec();
    end;
end)();

--------

local Layout = {};

-- a board consists of multiple rows
Layout.createBoardView = function(parentView, dx, dy)
    local f = CreateFrame("Frame", nil, parentView);
    f:SetWidth(1);
    f:SetHeight(1);
    f:SetPoint("TOPLEFT", dx, dy);

    f.rowViews = {};

    return f;
end;

-- a row consists of a Texture and a FontString
Layout.createRowView = function(boardView)
    local ICON_HEIGHT = 20;
    local LINE_WIDTH = 60;
    local LINE_HEIGHT = 14;
    local FONT_SIZE = 12;

    local rowIndex = array.size(boardView.rowViews);

    local icon = boardView:CreateTexture(nil, "OVERLAY");
    icon:SetPoint("TOPLEFT", 0, -(ICON_HEIGHT + 2) * rowIndex);
    icon:SetSize(ICON_HEIGHT, ICON_HEIGHT);

    local text = boardView:CreateFontString(nil, "OVERLAY", nil);
    text:SetFont(STANDARD_TEXT_FONT, FONT_SIZE, "OUTLINE");
    text:SetJustifyH("LEFT");
    text:SetPoint("LEFT", icon, "RIGHT", 4, 0);
    text:SetSize(LINE_WIDTH, LINE_HEIGHT);

    return {
        icon = icon,
        text = text,
    };
end;

Layout.getOrCreateRowView = function(boardView, index)
    -- lua: array index starts from 1
    while (array.size(boardView.rowViews) < index) do
        local rowView = Layout.createRowView(boardView);
        array.insert(boardView.rowViews, rowView);
    end
    return boardView.rowViews[index];
end;

Layout.renderRowItems = function(boardView, rowItems)
    local startIndex = 1;
    while (startIndex <= array.size(rowItems)) do
        local rowItem = rowItems[startIndex];
        if (rowItem[3]) then
            local rowView = Layout.getOrCreateRowView(boardView, startIndex);
            rowView.icon:SetTexture(rowItem[2]);
            rowView.text:SetText(rowView[3]);
        end
        startIndex = startIndex + 1;
    end
    while (startIndex <= array.size(boardView.rowViews)) do
        local rowView = boardView.rowViews[startIndex];
        rowView.icon:SetTexture(nil);
        rowView.text:SetText(nil);
    end
end;

Layout.filterAndRenderKeys = function(boardView, keys)
    local rowItems = {};
    for _, v in pairs(boardView.keys) do
        if (array.contains(keys, v)) then
            array.merge(rowItems, StatBook.getRowItems(v));
        end
    end
    if (map.size(rowItems) > 0) then
        Layout.renderRowItems(boardView, rowItems);
    end
end;

--------

local allKeys = {
    ["MAGE"] = { "spell" },
    ["PRIEST"] = { "spell" },
    ["WARLOCK"] = { "spell" },
    ["ROGUE"] = { "melee" },
    ["DRUID"] = { "melee", "spell", "defense" },
    ["HUNTER"] = { "ranged", "spell" },
    ["SHAMAN"] = { "melee", "spell" },
    ["WARRIOR"] = { "melee", "defense" },
    ["PALADIN"] = { "melee", "spell", "defense" },
};
local _, className = UnitClass("player");
local classKeys = allKeys[className];

local mightBoard = Layout.createBoardView(CharacterModelFrame, 6, -36); -- 6, -212
mightBoard.keys = { "melee", "ranged", "defense" };

local magicBoard = Layout.createBoardView(CharacterModelFrame, 160, -146);
magicBoard.keys = { "spell" };

local delayRefresh = function()
    local self = mightBoard;
    -- immediate refresh leads to incorrect result; have to delay
    self.ttl = 0.5; -- long enough
    if (not self:GetScript("OnUpdate")) then
        self:SetScript("OnUpdate", function()
            self.ttl = self.ttl - arg1;
            if (self.ttl < 0) then
                self.ttl = nil;
                self:SetScript("OnUpdate", nil);
                Layout.filterAndRenderKeys(mightBoard, classKeys);
                Layout.filterAndRenderKeys(magicBoard, classKeys);
            end
        end);
    end
end;

mightBoard:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
mightBoard:RegisterEvent("SKILL_LINES_CHANGED");
mightBoard:RegisterEvent("UNIT_ATTACK", "player");
mightBoard:RegisterEvent("UNIT_ATTACK_POWER", "player");
mightBoard:RegisterEvent("UNIT_ATTACK_SPEED", "player");
mightBoard:RegisterEvent("UNIT_AURA", "player");
mightBoard:RegisterEvent("UNIT_RANGED_ATTACK_POWER", "player");
mightBoard:RegisterEvent("UNIT_RANGEDDAMAGE", "player");
mightBoard:RegisterEvent("UNIT_STATS", "player");
mightBoard:SetScript("OnEvent", delayRefresh);

CharacterModelFrame:SetScript("OnShow", delayRefresh);

--CharacterModelFrameRotateRightButton:Hide();
--CharacterModelFrameRotateLeftButton:Hide();

--CharacterResistanceFrame:Hide();
--CharacterAttributesFrame:Hide();
--CharacterModelFrame:SetHeight(302);
