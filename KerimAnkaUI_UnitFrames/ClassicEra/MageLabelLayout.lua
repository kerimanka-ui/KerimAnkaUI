-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Only static samples are measured: unit names/levels may be secret in combat.
-- Live and preview share these exact placement and typography calculations.
local G=ForeverMageUnitsGeometry
if not G then return end
local measure
local function Fit(font,size,sample,width,height)
    if not measure then
        local holder=CreateFrame("Frame",nil,UIParent)
        holder:Hide()
        measure=holder:CreateFontString(nil,"OVERLAY")
        measure:SetWidth(1024);measure:SetWordWrap(false)
    end
    measure:SetFont(font,size,"OUTLINE");measure:SetText(sample)
    local ok,w,h=pcall(function() return measure:GetStringWidth(),measure:GetStringHeight() end)
    local factor=1
    if ok and not (issecretvalue and (issecretvalue(w) or issecretvalue(h)))
        and type(w)=="number" and type(h)=="number" and w>0 and h>0 then
        if type(w)=="number" and w>0 and width then factor=math.min(factor,width/w) end
        if type(h)=="number" and h>0 and height then factor=math.min(factor,height/h) end
    else
        -- Conservative fallback if a font has not finished loading.
        if width then factor=math.min(factor,width/(size*1.6)) end
        if height then factor=math.min(factor,height/(size*1.2)) end
    end
    return math.max(5,size*factor)
end
local function NativeParts()
    local target=TargetFrame and TargetFrame.TargetFrameContent and TargetFrame.TargetFrameContent.TargetFrameContentMain
    return target and target.LevelText or TargetFrameLevelText or PlayerLevelText or NumberFontNormal,
        target and target.LevelBackgroundCircle
end
function G.LevelFont(fallback)
    local text=NativeParts()
    if text and type(text.GetFont)=="function" then
        local ok,font=pcall(text.GetFont,text)
        if ok and not (issecretvalue and issecretvalue(font)) and type(font)=="string" and font~="" then return font end
    end
    return fallback
end
function G.ApplyCircle(texture)
    local _,circle=NativeParts()
    if circle and type(circle.GetAtlas)=="function" and texture.SetAtlas then
        local ok,atlas=pcall(circle.GetAtlas,circle)
        if ok and not (issecretvalue and issecretvalue(atlas)) and type(atlas)=="string" and atlas~="" then
            local set=pcall(texture.SetAtlas,texture,atlas)
            if set then return end
        end
    end
    texture:SetTexture("Interface\\AddOns\\KerimAnkaUI_UnitFrames\\LevelCircle.tga","CLAMP","CLAMP","TRILINEAR")
    texture:SetTexCoord(0,1,0,1)
end
function G.LevelMetrics(db,unit,font)
    local diameter=36 -- fixed: independent of glyph count, text and pet scales
    local size=Fit(G.LevelFont(font),16*(db.levelTextScale or 1),"88",diameter*.74-2,diameter*.72-2)
    return diameter,size
end
function G.ApplyLabels(f,db,unit,W,H,font,mirrored)
    local pet=unit=="pet" and (db.petTextScale or 1) or 1
    local geo=unit=="pet" and ForeverPetUnitsGeometry.MAGE or G
    local nameHeight=H*geo.nameHeight
    -- The selected concept uses a bold name. Keep the native font on CJK
    -- clients, where the bundled Latin font does not cover the character set.
    local locale=GetLocale and GetLocale() or "enUS"
    local nameFont=(locale=="zhCN" or locale=="zhTW" or locale=="koKR") and font
        or "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-B.ttf"
    -- Fit a fixed reference once, then honor the requested name scale.
    -- Refitting each requested size caused plateaus and pixel-rounding shrinkage.
    local nameSize=Fit(nameFont,14,"Ag",nil,nameHeight-2)*(db.textScale or 1)*pet
    f.name:ClearAllPoints()
    f.name:SetPoint("CENTER",f.anchor or f,"TOPLEFT",(mirrored and 1-geo.name[1] or geo.name[1])*W+2,-geo.name[2]*H+(db.nameOffsetY or 0))
    f.name:SetSize(W*geo.nameWidth-4,math.max(nameHeight,nameSize*1.4+2));f.name:SetJustifyV("MIDDLE");f.name:SetWordWrap(false)
    KerimAnkaUITextAPI.NameFont(f.name,nameSize,true)
    -- Pet bars keep proportional type, rather than cancelling the pet's scale.
    -- Bar typography follows the user's independent scale, like existing themes.
    -- Fitting it to the painted aperture cancelled increases on these thin bars.
    local hpSize=12*(db.healthTextScale or 1)*pet
    local powerSize=11*(db.powerTextScale or 1)*pet
    f.hpText:SetFont(font,hpSize,"OUTLINE")
    f.powerText:SetFont(font,powerSize,"OUTLINE")
    if f.hpPercent then f.hpPercent:SetFont(font,hpSize,"OUTLINE") end
    if f.powerPercent then f.powerPercent:SetFont(font,powerSize,"OUTLINE") end
    local diameter,size=G.LevelMetrics(db,unit,font)
    if f.levelBadge then f.levelBadge:SetSize(diameter,diameter) end
    f.level:SetSize(diameter,diameter)
    f.level:SetFont(G.LevelFont(font),size,"OUTLINE")
    f.level:SetJustifyH("CENTER");f.level:SetJustifyV("MIDDLE");f.level:SetShadowOffset(0,-1)
    f.level:ClearAllPoints()
    if f.levelBadge then f.level:SetPoint("CENTER",f.levelBadge,"CENTER",0,0)
    else f.level:SetPoint("CENTER",f.anchor or f,"TOPLEFT",(mirrored and 1-G.level[1] or G.level[1])*W,-G.level[2]*H) end
    if unit=="pet" then f.level:Hide();if f.levelBadge then f.levelBadge:Hide() end end
end
