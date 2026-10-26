-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Hunter-only theme adapter. Warrior module and saved layout are unchanged.
local _,hunterClass=UnitClass("player")
if hunterClass~="HUNTER" then return end
local M={}
ForeverClassArtBarPanel=M
local _,class=UnitClass("player")
local panel=CreateFrame("Frame",nil,UIParent)
panel:SetFrameStrata("BACKGROUND")
panel:SetFrameLevel(0)
panel:EnableMouse(false)
panel:Hide()
local fill=panel:CreateTexture(nil,"BACKGROUND",nil,-8)
-- Fill extends under the raised rail; its transparent lower margin cannot expose the world.
fill:SetTexture("Interface\\AddOns\\KerimAnkaUI_ClassArt\\HunterBacking.tga")
fill:SetHorizTile(true); fill:SetVertTile(true)
fill:SetVertexColor(.8,.8,.8,1)
-- Fixed-size end/center ornaments; only the plain metal spans stretch.
local rail=CreateFrame("Frame",nil,panel)
rail:EnableMouse(false)
local railParts={}
local railUV={{0,.12},{.12,.44},{.44,.56},{.56,.88},{.88,1}}
for i,uv in ipairs(railUV) do
    local t=rail:CreateTexture(nil,"BORDER",nil,0)
    t:SetTexture("Interface\\AddOns\\KerimAnkaUI_ClassArt\\HunterTopRail.tga")
    t:SetTexCoord(uv[1],uv[2],0.30386740,0.65331492)
    railParts[i]=t
end
local panelSkin
local function LayoutRail(height,width)
    local cap=math.min(height*1.03019763,width/4)
    local t=railParts
    for _,part in ipairs(t) do part:ClearAllPoints() end
    for _,i in ipairs({1,3,5}) do t[i]:SetSize(cap,height) end
    t[1]:SetPoint("TOPLEFT",rail,"TOPLEFT")
    t[3]:SetPoint("CENTER",rail,"CENTER")
    t[5]:SetPoint("TOPRIGHT",rail,"TOPRIGHT")
    t[2]:SetPoint("TOPLEFT",t[1],"TOPRIGHT")
    t[2]:SetPoint("BOTTOMRIGHT",t[3],"BOTTOMLEFT")
    t[4]:SetPoint("TOPLEFT",t[3],"TOPRIGHT")
    t[4]:SetPoint("BOTTOMRIGHT",t[5],"BOTTOMLEFT")
end
local function Defaults(d)
    if d.backingEnabled==nil then d.backingEnabled=true end
    if type(d.backingAlpha)~="number" then d.backingAlpha=1 end
    if type(d.backingPadding)~="number" then d.backingPadding=3 end
    if type(d.backingRailHeight)~="number" then d.backingRailHeight=18 end
    if type(d.backingRailY)~="number" then d.backingRailY=0 end
    if d.backingRailStyle~=2 then
        d.backingRailHeight=math.max(18,math.min(24,d.backingRailHeight))
        d.backingRailStyle=2
    end
end
function M.Hide() panel:Hide() end
function M.Update(d)
    if class~="HUNTER" or not d then M.Hide(); return end
    Defaults(d)
    local skin=d.artSkin==2 and 2 or 1
    if panelSkin~=skin then
        fill:SetTexture("Interface\\AddOns\\KerimAnkaUI_ClassArt\\"..(skin==2 and "ForgedIron.tga" or "HunterBacking.tga"))
        panelSkin=skin
    end
    if not d.enabled or not d.backingEnabled then M.Hide(); return end
    if InCombatLockdown() then return end
    ForeverBackingColor.Paint(fill,d,"Interface\\AddOns\\KerimAnkaUI_ClassArt\\"..(d.artSkin==2 and "ForgedIron.tga" or "HunterBacking.tga"),{.8,.8,.8,1})
    local left,right,top,bottom=KerimAnkaUIBarsAPI.Bounds(d.bars)
    if not left then M.Hide(); return end
    local pad=math.max(0,math.min(12,d.backingPadding))
    local width,height=right-left+pad*2,top-bottom+pad*2
    panel:ClearAllPoints()
    panel:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",left-pad,bottom-pad)
    panel:SetSize(width,height)
    local railHeight=math.max(8,math.min(24,d.backingRailHeight))
    local railY=math.max(-24,math.min(24,d.backingRailY))
    -- The diamond tips define the asset bounds; the straight rail ends higher.
    -- Overlap by a quarter of its height and back it with metal up to its center.
    local railBottom=railY-railHeight*.25
    local extension=skin==2 and 0 or math.max(0,railBottom+railHeight*.5)
    fill:ClearAllPoints()
    fill:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT")
    fill:SetPoint("TOPRIGHT",panel,"TOPRIGHT",0,extension)
    fill:SetTexCoord(0,width/256,0,(height+extension)/256)
    ForeverBackingColor.FollowArt(fill,d,left-pad,right+pad,top+pad+extension,bottom-pad)
    rail:ClearAllPoints()
    rail:SetPoint("BOTTOMLEFT",panel,"TOPLEFT",0,railBottom)
    rail:SetPoint("BOTTOMRIGHT",panel,"TOPRIGHT",0,railBottom)
    rail:SetHeight(railHeight)
    LayoutRail(railHeight,width)
    rail:SetShown(skin~=2)
    panel:SetAlpha(math.max(0,math.min(1,d.backingAlpha))*(d.alpha or 1))
    panel:Show()
end
function M.Options(getDB)
    local function d() local value=getDB(); Defaults(value); return value end
    local function Set(key,value) d()[key]=value; M.Update(d()) end
    return {type="group",name="Hunter — Arka panel ve üst şerit",order=45,inline=true,
        hidden=function() return class~="HUNTER" end,
        disabled=function() return InCombatLockdown() end,
        args={
            info={type="description",order=1,name="Butonların arkasında koyu yeşil deri panel ve yalnızca üstte bitiş şeridi. Satır aralarında metal çizgi yok. Panel, süsleme sabit olsa da seçilen barları takip eder."},
            enabled={type="toggle",name="Hunter arka panelini göster",order=2,width="full",
                get=function() return d().backingEnabled end,set=function(_,v) Set("backingEnabled",v) end},
            opacity={type="range",name="Panel görünürlüğü",order=3,min=0,max=1,step=.05,width="full",
                get=function() return d().backingAlpha end,set=function(_,v) Set("backingAlpha",v) end},
            padding={type="range",name="Panelin kenar payı",order=4,min=0,max=12,step=1,width="full",
                get=function() return d().backingPadding end,set=function(_,v) Set("backingPadding",v) end},
            railY={disabled=function() return d().artSkin==2 end,type="range",name="Üst şerit yukarı / aşağı",desc="Negatif değer şeridi aşağı indirir. Süslemenin genel konumundan bağımsızdır.",order=6,min=-24,max=24,step=1,width="full",
                get=function() return d().backingRailY end,set=function(_,v) Set("backingRailY",v) end},
            rail={disabled=function() return d().artSkin==2 end,type="range",name="Üst ahşap şerit kalınlığı",order=5,min=8,max=24,step=1,width="full",
                get=function() return d().backingRailHeight end,set=function(_,v) Set("backingRailHeight",v) end},
        }}
end
