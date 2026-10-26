-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Atlas cells: 1 unhappy/red, 2 content/amber, 3 happy/green, 4 transparent.
-- Restricted happiness values are forwarded only to the native texture sink.
ForeverUnitsPetHappiness = {}
function ForeverUnitsPetHappiness.Read()
    local getter = C_PetInfo and C_PetInfo.GetPetHappiness or GetPetHappiness
    if not getter then return false end
    return pcall(getter)
end
function ForeverUnitsPetHappiness.APIName()
    if C_PetInfo and C_PetInfo.GetPetHappiness then return "C_PetInfo.GetPetHappiness" end
    if GetPetHappiness then return "GetPetHappiness" end
    return "unavailable"
end
function ForeverUnitsPetHappiness.Update(texture, enabled)
    texture:Hide()
    if not enabled then return "disabled" end
    local ok, happiness = ForeverUnitsPetHappiness.Read()
    if not ok then return "api-unavailable" end
    local restricted = issecretvalue and issecretvalue(happiness)
    if not restricted then
        if type(happiness) ~= "number" or happiness < 1 or happiness > 3
            or happiness ~= math.floor(happiness) then return "no-happiness" end
    end
    if texture.SetSpriteSheetCell then
        local drawn = pcall(texture.SetSpriteSheetCell, texture, happiness, 1, 4)
        if drawn then texture:Show(); return "native-display" end
        if restricted then return "native-display-refused" end
    elseif restricted then
        return "native-display-unavailable"
    end
    -- Legacy fallback is permitted only for an ordinary, readable 1/2/3 value.
    local left = (happiness - 1) / 4
    texture:SetTexCoord(left, left + .25, 0, 1)
    texture:Show()
    return "public-atlas"
end

function ForeverUnitsPetHappiness.Tooltip(owner)
    local ok, happiness, damage, loyalty = ForeverUnitsPetHappiness.Read()
    if not ok then return end
    local function restricted(value) return issecretvalue and issecretvalue(value) end
    if not restricted(happiness) and happiness == nil then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    local title = "Begleiter-Zufriedenheit"
    if not restricted(happiness) and type(happiness) == "number"
        and happiness >= 1 and happiness <= 3 then
        title = _G["PET_HAPPINESS" .. happiness] or title
    end
    GameTooltip:SetText(title)
    if not restricted(damage) and type(damage) == "number" then
        local template = PET_DAMAGE_PERCENTAGE or "Verursacht %d%% des normalen Schadens."
        local formatted, line = pcall(string.format, template, damage)
        if formatted then GameTooltip:AddLine(line, 1, .82, 0, true) end
    end
    if not restricted(loyalty) and type(loyalty) == "number" then
        if loyalty > 0 then GameTooltip:AddLine(GAINING_LOYALTY or "Gewinnt Treue", 1, .82, 0)
        elseif loyalty < 0 then GameTooltip:AddLine(LOSING_LOYALTY or "Verliert Treue", 1, .4, .3) end
    end
    local foodGetter = C_PetInfo and C_PetInfo.GetPetFoodTypes or GetPetFoodTypes
    if foodGetter then
        local values = {pcall(foodGetter)}
        if values[1] then
            table.remove(values, 1)
            if not restricted(values[1]) and type(values[1]) == "table" then values = values[1] end
            local foods = {}
            for _, value in ipairs(values) do
                if not restricted(value) and type(value) == "string" then foods[#foods + 1] = value end
            end
            if #foods > 0 then
                GameTooltip:AddLine((FOOD or "Nahrung") .. ": " .. table.concat(foods, ", "), 1, .82, 0, true)
            end
        end
    end
    GameTooltip:Show()
end
