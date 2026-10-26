-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Connected frame: all eight decorative cells stay outside the action opening.
function ForeverCreatePaladinArt(art)
 local M={}
 local root="Interface\\AddOns\\KerimAnkaUI_ClassArt\\"
 local source={left=250,right=1526,top=70,bottom=395,width=1774,height=466}
 local cells={};local active
 for row=1,3 do for col=1,3 do if row~=2 or col~=2 then
  cells[#cells+1]={row=row,col=col,texture=art:CreateTexture(nil,"ARTWORK")}
 end end end
 local fill=CreateFrame('Frame',nil,UIParent)
 fill:SetFrameStrata('BACKGROUND');fill:SetFrameLevel(0);fill:EnableMouse(false);fill:Hide()
 local background=fill:CreateTexture(nil,'BACKGROUND');background:SetAllPoints()
 local function Defaults(d)
  if d.paladinSkin~=1 and d.paladinSkin~=2 then d.paladinSkin=KerimAnkaUITextAPI.PaladinSkin() end
  if d.paladinBackingEnabled==nil then d.paladinBackingEnabled=true end
  if d.paladinRailEnabled==nil then d.paladinRailEnabled=true end
  for key,value in pairs({paladinBackingAlpha=.9,paladinRailHeight=100,paladinBottomHeight=55,paladinLeftSpread=0,paladinRightSpread=0}) do
   if type(d[key])~='number' then d[key]=value end
  end
 end
 local function Rect(t,x,y,w,h)
  t:ClearAllPoints();t:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',x,y);t:SetSize(math.max(.01,w),math.max(.01,h))
 end
 local function FitMigration()
  local raw=KAClassic_ForeverHunterArtCharacterDB
  if type(raw)~='table' or raw.paladinConnectedInitialized then return end
  -- Only obsolete decorative fitting offsets are reset, for both providers.
  for _,d in pairs({raw,raw.nativeLayout}) do
   d.width=100;d.height=100;d.x=0;d.y=0;d.locked=nil;d.gap=4
  end
  raw.paladinConnectedInitialized=true
 end
 function M.Hide()
  fill:Hide();for _,cell in ipairs(cells) do cell.texture:Hide() end
 end
 function M.Update(d)
  if InCombatLockdown() then return end
  Defaults(d);FitMigration()
  if not d.enabled or not art:IsShown() then M.Hide();return end
  local l,r,t,b=KerimAnkaUIBarsAPI.Bounds(d.bars)
  if not l or not r or not t or not b or r<=l or t<=b then M.Hide();return end
  -- Native and Bartender slot backdrops can inherit a raised button level.
  -- Lift only our mouse-transparent ornament; never modify their frames.
  local ornamentLevel=1
  if KerimAnkaUIBarsAPI.ForEach then KerimAnkaUIBarsAPI.ForEach(d.bars,function(button)
   local level=button.GetFrameLevel and button:GetFrameLevel()
   if not (issecretvalue and issecretvalue(level)) and type(level)=='number' then ornamentLevel=math.max(ornamentLevel,level+4) end
  end) end
  art:SetFrameLevel(ornamentLevel)
  local pad=math.max(2,math.min(40,d.gap or 4))
  local bw,bh=r-l,t-b
  local width=(bw+2*pad)*math.max(1,(d.width or 100)/100)
  local height=(bh+2*pad)*math.max(1,(d.height or 100)/100)
  local cx,cy=(l+r)/2+(d.x or 0),(b+t)/2+(d.y or 0)
  -- Changing dimensions/position cannot push decoration over selected buttons.
  local left=math.min(cx-width/2,l-pad)
  local right=math.max(cx+width/2,r+pad)
  local upper=math.max(cy+height/2,t+pad)
  local bottom=math.min(cy-height/2,b-pad)
  local scale=(right-left)/(source.right-source.left)
  local lw=math.max(24,source.left*scale+(d.paladinLeftSpread or 0))
  local rw=math.max(24,(source.width-source.right)*scale+(d.paladinRightSpread or 0))
  local topHeight=math.max(8,math.min(24,d.paladinRailHeight*.16))
  local bottomHeight=math.max(5.4,math.min(18,d.paladinBottomHeight*.18))
  -- No clipping-based automatic shrinking: thickness controls remain effective.
  -- The footer may meet the screen edge, but never moves into the button area.
  local xs={left-lw,left,right,right+rw}
  local ys={upper+topHeight,upper,bottom,bottom-bottomHeight}
  if active~=d.paladinSkin then
   local file=d.paladinSkin==2 and 'PaladinConnectedHorde.tga' or 'PaladinConnectedAlliance.tga'
   local sx={0,source.left,source.right,source.width}
   local sy={0,source.top,source.bottom,source.height}
   for _,cell in ipairs(cells) do
    cell.texture:SetTexture(root..file,'CLAMP','CLAMP','TRILINEAR')
    cell.texture:SetTexCoord(sx[cell.col]/2048,sx[cell.col+1]/2048,sy[cell.row]/512,sy[cell.row+1]/512)
   end
   active=d.paladinSkin
  end
  for _,cell in ipairs(cells) do
   local row,col=cell.row,cell.col
   Rect(cell.texture,xs[col],ys[row+1],xs[col+1]-xs[col],ys[row]-ys[row+1])
   cell.texture:SetShown(not (row==1 and col==2) or d.paladinRailEnabled)
  end
  ForeverBackingColor.Paint(background,d,nil,{.025,.025,.022,1})
  -- The source aperture's anti-aliased inner edge is partly transparent.
  -- Continue the backing under that edge instead of ending exactly beside it.
  local bleed=4
  Rect(fill,left-bleed,bottom-bleed,right-left+2*bleed,upper-bottom+2*bleed)
  fill:SetAlpha(math.max(0,math.min(1,d.paladinBackingAlpha))*(d.alpha or 1));fill:SetShown(d.paladinBackingEnabled)
 end
 function M.Options(getDB)
  local function DB() local d=getDB();Defaults(d);return d end
  local function Set(key,value) if InCombatLockdown() then return end;DB()[key]=value;M.Update(DB()) end
  local function Toggle(key,order) return {type='toggle',order=order,get=function() return DB()[key] end,set=function(_,v) Set(key,v) end} end
  local function Range(key,order,low,high,step) return {type='range',order=order,min=low,max=high,step=step,get=function() return DB()[key] end,set=function(_,v) Set(key,v) end} end
  return {type='group',name='Paladin',disabled=function() return InCombatLockdown() end,args={
   paladinLeftSpread=Range('paladinLeftSpread',.1,-80,160,5),paladinRightSpread=Range('paladinRightSpread',.2,-80,160,5),
   paladinBackingEnabled=Toggle('paladinBackingEnabled',1),paladinBackingAlpha=Range('paladinBackingAlpha',2,0,1,.05),
   paladinRailEnabled=Toggle('paladinRailEnabled',3),paladinRailHeight=Range('paladinRailHeight',4,50,150,5),
   paladinBottomHeight=Range('paladinBottomHeight',5,30,100,5),
  }}
 end
 return M
end
