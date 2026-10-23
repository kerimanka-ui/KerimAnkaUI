-- Native display-only forwarding for restricted raid target indices.
-- SetSpriteSheetCell accepts secret cell values (Blizzard's own marker path).
ForeverUnitsRaidMarker = {}
function ForeverUnitsRaidMarker.Update(texture, unit)
    texture:Hide()
    local ok, marker = pcall(GetRaidTargetIndex, unit)
    if not ok then return "api-unavailable" end
    local restricted = issecretvalue and issecretvalue(marker)
    if not restricted then
        if type(marker) ~= "number" or marker < 1 or marker > 8
            or marker ~= math.floor(marker) then return "unmarked" end
    end
    -- Do not compare, calculate with, stringify, or cache a restricted marker.
    -- Pass it unchanged into the supported C rendering sink.
    if texture.SetSpriteSheetCell then
        local drawn = pcall(texture.SetSpriteSheetCell, texture, marker, 4, 4)
        if drawn then
            texture:Show()
            return "native-display"
        end
        if restricted then return "native-display-refused" end
    elseif restricted then
        return "native-display-unavailable"
    end
    -- Compatibility fallback is exclusively for ordinary public indices.
    local cell = marker - 1
    local left = (cell % 4) / 4
    local top = math.floor(cell / 4) / 4
    texture:SetTexCoord(left, left + .25, top, top + .25)
    texture:Show()
    return "public-atlas"
end
