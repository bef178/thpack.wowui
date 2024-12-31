local A = A;

(function()
    local function getTooltipUnit()
        local title = GameTooltipTextLeft1:GetText();
        if (not title) then
            return;
        end
        if (UnitExists("mouseover")) then
            return "mouseover";
        end
        for _, u in ipairs({ "player", "pet", "target" }) do
            if (UnitExists(u) and (UnitName(u) == title or UnitPVPName(u) == title)) then
                return u;
            end
        end
        if (GetNumPartyMembers() > 0) then
            for _, u in ipairs({ "party", "partypet" }) do
                for i = 1, 4, 1 do
                    local unit = u .. i;
                    if (UnitExists(unit) and (UnitName(unit) == title or UnitPVPName(unit) == title)) then
                        return unit;
                    end
                end
            end
        end
        if (GetNumRaidMembers() > 0) then
            for _, u in ipairs({ "raid", "raidpet" }) do
                for i = 1, 40, 1 do
                    local unit = u .. i;
                    if UnitExists(unit) and (UnitName(unit) == title or UnitPVPName(unit) == title) then
                        return unit;
                    end
                end
            end
        end
    end

    local f = CreateFrame("Frame", nil, GameTooltip, nil);
    f:SetScript("OnShow", function()
        local unit = getTooltipUnit();
        if (not unit) then
            return;
        end

        -- add class texture to title line
        if (UnitIsPlayer(unit)) then
            local name = UnitName(unit);
            local _, c = UnitClass(unit);
            local replaced, n = string.gsub(
                GameTooltipTextLeft1:GetText(),
                name,
                A.buildColoredString(A.getClassColor(c), name));
            if (n > 0) then
                GameTooltipTextLeft1:SetText(replaced);
            end
        end

        -- add unit's target
        local u = unit .. "target";
        if (UnitExists(u)) then
            local prefix = "=> ";
            if (UnitIsUnit(u, "player")) then
                GameTooltip:AddLine(prefix .. A.buildColoredString(Color.pick("red"), "!!!"), 1, 1, 1);
            else
                local _, c = UnitClass(u);
                GameTooltip:AddLine(
                    string.format("%s%s",
                        prefix,
                        A.buildColoredString(A.getUnitNameColor(u), UnitName(u))),
                    1, 1, 1);
            end
        end

        GameTooltip:Show();
    end);
end)();
