-- Druid artwork adapter. Original buttons and their handlers are untouched.
function ForeverCreateDruidArt(art)
 local M={}
 local root="Interface\\AddOns\\KerimAnkaUI_ClassArt\\"
 local skins={
  {file="DruidGrove.tga",left=260,right=1514,top=310,bodyTop=310,seam=620,openBottom=620,interiorBottom=680,bottom=887,railTop=0,railBottom=310,railCenter=270},
  {file="DruidMoon.tga",left=220,right=1554,top=285,bodyTop=285,seam=630,openBottom=630,interiorBottom=680,bottom=887,railTop=0,railBottom=285,railCenter=245},
  {file="DruidWild.tga",left=250,right=1524,top=220,bodyTop=220,seam=580,openBottom=580,interiorBottom=650,bottom=887,railTop=0,railBottom=220,railCenter=180},
  {file="DruidSeasons.tga",left=240,right=1534,top=275,bodyTop=275,seam=570,openBottom=570,interiorBottom=615,bottom=887,railTop=0,railBottom=275,railCenter=235},
 }
 local fill=CreateFrame("Frame",nil,UIParent)
 fill:SetFrameStrata("BACKGROUND");fill:SetFrameLevel(0);fill:EnableMouse(false);fill:Hide()
 local background=fill:CreateTexture(nil,"BACKGROUND");background:SetAllPoints();background:SetColorTexture(.025,.025,.022,1)
 local parts={}
 for i=1,7 do parts[i]=art:CreateTexture(nil,"ARTWORK") end
 local rail=CreateFrame("Frame",nil,art);rail:EnableMouse(false);rail:Hide()
 local top=rail:CreateTexture(nil,"ARTWORK");top:SetAllPoints()
 local active
 local function Defaults(d)
  if not d.druidWildInitialized then d.druidSkin=3;d.druidWildInitialized=true end
  if d.druidSkin~=1 and d.druidSkin~=2 and d.druidSkin~=3 and d.druidSkin~=4 then d.druidSkin=3 end
  if d.druidBackingEnabled==nil then d.druidBackingEnabled=true end
  if d.druidRailEnabled==nil then d.druidRailEnabled=true end
  for key,value in pairs({druidBackingAlpha=.9,druidRailX=0,druidRailY=0,druidRailWidth=100,druidRailHeight=100,druidLeftSpread=0,druidRightSpread=0}) do
   if type(d[key])~="number" then d[key]=value end
  end
 end
 local function Rect(region,x,y,w,h)
  region:ClearAllPoints();region:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",x,y);region:SetSize(math.max(1,w),math.max(1,h))
 end
 function M.Hide()
  fill:Hide();rail:Hide();for _,t in ipairs(parts) do t:Hide() end
 end
 function M.Update(d)
  if not InCombatLockdown() then ForeverBackingColor.Paint(background,d,nil,{.025,.025,.022,1}) end
  Defaults(d)
  if not d.enabled or not art:IsShown() then M.Hide();return end
  if InCombatLockdown() then return end
  local x,y,w,h=art:GetRect()
  if not x or not y or not w or not h or w<=0 or h<=0 then M.Hide();return end
  local s=skins[d.druidSkin]
  if active~=d.druidSkin then
   for _,t in ipairs(parts) do t:SetTexture(root..s.file,"CLAMP","CLAMP","TRILINEAR") end
   top:SetTexture(root..(s.railFile or s.file),"CLAMP","CLAMP","TRILINEAR")
   parts[1]:SetTexCoord(0,s.left/2048,s.bodyTop/1024,s.seam/1024)
   parts[2]:SetTexCoord(s.right/2048,1774/2048,s.bodyTop/1024,s.seam/1024)
   -- Fixed corner blocks and central emblem, with only the two connecting spans elastic.
   local cuts={0,430,680,1094,1344,1774}
   for i=1,5 do parts[i+2]:SetTexCoord(cuts[i]/2048,cuts[i+1]/2048,s.seam/1024,s.bottom/1024) end
   top:SetTexCoord(0,1774/2048,s.railTop/1024,s.railBottom/1024)
   active=d.druidSkin
  end
  -- Same reference opening as Hunter/Warlock, including imported locked layouts.
  local left,right=x+w*.135,x+w*.865
  local bottom,upper=y+h*.32,y+h*.82
  local sx=(right-left)/(s.right-s.left)
  local seamY=bottom+(s.openBottom-s.seam)*sx
  local sy=math.max(1,upper-seamY)/(s.seam-s.top)
  local fullLeft=left-s.left*sx
  local bridgeWidth=250*sx
  -- Limit inward travel before a connecting span collapses; never flip UVs.
  local inward=math.max(0,bridgeWidth-8)
  local leftSpread=math.max(-inward,math.min(160,d.druidLeftSpread))
  local rightSpread=math.max(-inward,math.min(160,d.druidRightSpread))
  Rect(parts[1],fullLeft-leftSpread,seamY,s.left*sx,(s.seam-s.bodyTop)*sy)
  Rect(parts[2],right+rightSpread,seamY,(1774-s.right)*sx,(s.seam-s.bodyTop)*sy)
  local baseY=bottom-(s.bottom-s.openBottom)*sx
  local baseHeight=(s.bottom-s.seam)*sx
  Rect(parts[3],fullLeft-leftSpread,baseY,430*sx,baseHeight)
  Rect(parts[4],fullLeft+430*sx-leftSpread,baseY,bridgeWidth+leftSpread,baseHeight)
  Rect(parts[5],fullLeft+680*sx,baseY,414*sx,baseHeight)
  Rect(parts[6],fullLeft+1094*sx,baseY,bridgeWidth+rightSpread,baseHeight)
  Rect(parts[7],fullLeft+1344*sx+rightSpread,baseY,430*sx,baseHeight)
  for _,t in ipairs(parts) do t:Show() end
  local railWidth=(1774*sx+leftSpread+rightSpread)*math.max(50,math.min(150,d.druidRailWidth))/100
  local railHeight=railWidth*(s.railBottom-s.railTop)/1774*math.max(50,math.min(150,d.druidRailHeight))/100
  local railLeft=(left+right-leftSpread+rightSpread-railWidth)/2+math.max(-150,math.min(150,d.druidRailX))
  -- The cap and columns meet at the same source cut. Keep the cap independent.
  local railCenter=upper+(s.railBottom-s.railCenter)*sx+math.max(-100,math.min(100,d.druidRailY))
  Rect(rail,railLeft,railCenter-(s.railBottom-s.railCenter)/(s.railBottom-s.railTop)*railHeight,railWidth,railHeight)
  rail:SetShown(d.druidRailEnabled)
  -- Backing follows actual selected bars, independently of ornament offsets.
  local l,r,t,b=KerimAnkaUIBarsAPI.Bounds(d.bars)
  if not l then fill:Hide();return end
  l=l-4;r=r+4;t=t+4;b=math.min(b-4,bottom-(s.interiorBottom-s.openBottom)*sx-4)
  if d.druidRailEnabled then t=math.max(t,railCenter) end
  Rect(fill,l,b,r-l,t-b)
  fill:SetAlpha(math.max(0,math.min(1,d.druidBackingAlpha))*(d.alpha or 1));fill:SetShown(d.druidBackingEnabled)
 end
 function M.Options(getDB)
  local function DB() local d=getDB();Defaults(d);return d end
  local function Set(key,value) if InCombatLockdown() then return end;DB()[key]=value;M.Update(DB()) end
  local function Toggle(key,order)
   return {type="toggle",order=order,get=function() return DB()[key] end,set=function(_,value) Set(key,value) end}
  end
  local function Range(key,order,low,high,step)
   return {type="range",order=order,min=low,max=high,step=step,get=function() return DB()[key] end,set=function(_,value) Set(key,value) end}
  end
  return {type="group",name="Druid",disabled=function() return InCombatLockdown() end,args={
   druidLeftSpread=Range("druidLeftSpread",.1,-80,160,1),druidRightSpread=Range("druidRightSpread",.2,-80,160,1),
   druidBackingEnabled=Toggle("druidBackingEnabled",1),druidBackingAlpha=Range("druidBackingAlpha",2,0,1,.05),
   druidRailEnabled=Toggle("druidRailEnabled",3),druidRailX=Range("druidRailX",4,-150,150,1),druidRailY=Range("druidRailY",5,-100,100,1),
   druidRailWidth=Range("druidRailWidth",6,50,150,1),druidRailHeight=Range("druidRailHeight",7,50,150,1),
  }}
 end
 return M
end
