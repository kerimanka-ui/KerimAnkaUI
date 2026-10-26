-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Shaman artwork adapter. Original buttons and their handlers are untouched.
function ForeverCreateShamanArt(art)
 local M={}
 local root="Interface\\AddOns\\KerimAnkaUI_ClassArt\\"
 local skins={
  {file="ShamanAncestralStraight.tga",railFile="ShamanAncestral.tga",left=280,right=1494,top=350,bodyTop=260,seam=650,bottom=850,railTop=40,railBottom=220,railCenter=110},
  {file="ShamanElements.tga",left=330,right=1444,top=340,bodyTop=250,seam=620,bottom=800,railTop=60,railBottom=180,railCenter=115},
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
  if d.shamanSkin~=2 then d.shamanSkin=1 end
  if d.shamanBackingEnabled==nil then d.shamanBackingEnabled=true end
  if d.shamanRailEnabled==nil then d.shamanRailEnabled=true end
  for key,value in pairs({shamanBackingAlpha=.9,shamanRailX=0,shamanRailY=0,shamanRailWidth=100,shamanRailHeight=100,shamanLeftSpread=0,shamanRightSpread=0}) do
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
  local s=skins[d.shamanSkin]
  if active~=d.shamanSkin then
   for _,t in ipairs(parts) do t:SetTexture(root..s.file,"CLAMP","CLAMP","TRILINEAR") end
   top:SetTexture(root..(s.railFile or s.file),"CLAMP","CLAMP","TRILINEAR")
   parts[1]:SetTexCoord(0,s.left/2048,s.bodyTop/1024,s.seam/1024)
   parts[2]:SetTexCoord(s.right/2048,1774/2048,s.bodyTop/1024,s.seam/1024)
   -- Fixed corner blocks and central emblem, with only the two connecting spans elastic.
   local cuts={0,430,680,1094,1344,1774}
   for i=1,5 do parts[i+2]:SetTexCoord(cuts[i]/2048,cuts[i+1]/2048,s.seam/1024,s.bottom/1024) end
   top:SetTexCoord(80/2048,1694/2048,s.railTop/1024,s.railBottom/1024)
   active=d.shamanSkin
  end
  -- Same reference opening as Hunter/Warlock, including imported locked layouts.
  local left,right=x+w*.135,x+w*.865
  local bottom,upper=y+h*.32,y+h*.82
  local sx=(right-left)/(s.right-s.left)
  local sy=math.max(1,upper-bottom)/(s.seam-s.top)
  local fullLeft=left-s.left*sx
  local bridgeWidth=250*sx
  -- Limit inward travel before a connecting span collapses; never flip UVs.
  local inward=math.max(0,bridgeWidth-8)
  local leftSpread=math.max(-inward,math.min(160,d.shamanLeftSpread))
  local rightSpread=math.max(-inward,math.min(160,d.shamanRightSpread))
  Rect(parts[1],fullLeft-leftSpread,bottom,s.left*sx,(s.seam-s.bodyTop)*sy)
  Rect(parts[2],right+rightSpread,bottom,(1774-s.right)*sx,(s.seam-s.bodyTop)*sy)
  local baseY=bottom-(s.bottom-s.seam)*sx
  local baseHeight=(s.bottom-s.seam)*sx
  Rect(parts[3],fullLeft-leftSpread,baseY,430*sx,baseHeight)
  Rect(parts[4],fullLeft+430*sx-leftSpread,baseY,bridgeWidth+leftSpread,baseHeight)
  Rect(parts[5],fullLeft+680*sx,baseY,414*sx,baseHeight)
  Rect(parts[6],fullLeft+1094*sx,baseY,bridgeWidth+rightSpread,baseHeight)
  Rect(parts[7],fullLeft+1344*sx+rightSpread,baseY,430*sx,baseHeight)
  for _,t in ipairs(parts) do t:Show() end
  local railWidth=((right-left)+240*sx+leftSpread+rightSpread)*math.max(50,math.min(150,d.shamanRailWidth))/100
  local railHeight=railWidth*(s.railBottom-s.railTop)/1614*math.max(50,math.min(150,d.shamanRailHeight))/100
  local railLeft=(left+right-leftSpread+rightSpread-railWidth)/2+math.max(-150,math.min(150,d.shamanRailX))
  -- Place the thick beam near the tops of the uprights; feather tips remain intact.
  local railCenter=upper+20+math.max(-100,math.min(100,d.shamanRailY))
  Rect(rail,railLeft,railCenter-(s.railBottom-s.railCenter)/(s.railBottom-s.railTop)*railHeight,railWidth,railHeight)
  rail:SetShown(d.shamanRailEnabled)
  -- Backing follows actual selected bars, independently of ornament offsets.
  local l,r,t,b=KerimAnkaUIBarsAPI.Bounds(d.bars)
  if not l then fill:Hide();return end
  l=l-4;r=r+4;t=t+4;b=b-4
  if d.shamanRailEnabled then l=math.min(l,railLeft+4);r=math.max(r,railLeft+railWidth-4);t=math.max(t,railCenter) end
  l,r,t,b=ForeverBackingColor.Expand(d,l,r,t,b,left-leftSpread,right+rightSpread,upper,bottom)
  Rect(fill,l,b,r-l,t-b)
  fill:SetAlpha(math.max(0,math.min(1,d.shamanBackingAlpha))*(d.alpha or 1));fill:SetShown(d.shamanBackingEnabled)
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
  return {type="group",name="Shaman",disabled=function() return InCombatLockdown() end,args={
   shamanLeftSpread=Range("shamanLeftSpread",.1,-80,160,1),shamanRightSpread=Range("shamanRightSpread",.2,-80,160,1),
   shamanBackingEnabled=Toggle("shamanBackingEnabled",1),shamanBackingAlpha=Range("shamanBackingAlpha",2,0,1,.05),
   shamanRailEnabled=Toggle("shamanRailEnabled",3),shamanRailX=Range("shamanRailX",4,-150,150,1),shamanRailY=Range("shamanRailY",5,-100,100,1),
   shamanRailWidth=Range("shamanRailWidth",6,50,150,1),shamanRailHeight=Range("shamanRailHeight",7,50,150,1),
  }}
 end
 return M
end
