ForeverHunterUnitsGeometry = {
    aspect = 0.305647841,
    layout = {
        Portrait = { 0.106312292, 0.181677019, 0.135738016, 0.572981366 },
        Health = { 0.293308021, 0.419254658, 0.634551495, 0.159937888 },
        Power = { 0.293308021, 0.631987578, 0.634076887, 0.128881988 },
    },
    level = { 0.100379687, 0.781055901 },
    levelSize = { 0.064072140, 0.211180124 },
    name = { .61, .29 },
}

-- Match the approved native brown/gold level ring without sampling live frames.
function ForeverHunterUnitsGeometry.ApplyCircle(texture)
    local atlas="UI-HUD-UnitFrame-SmallCircle"
    if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
        texture:SetAtlas(atlas);return
    end
    texture:SetTexture("Interface\\AddOns\\KerimAnkaUI_UnitFrames\\LevelCircle.tga","CLAMP","CLAMP","TRILINEAR")
    texture:SetTexCoord(0,1,0,1)
end
