-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Paint existing backings; custom colors also cover the decorative interior.
local M={};ForeverBackingColor=M
local painted=setmetatable({},{__mode='k'})
function M.Valid(c)
 if type(c)~='table' or #c~=3 then return false end
 for i=1,3 do local v=c[i];if type(v)~='number' or v~=v or v<0 or v>1 then return false end end
 return true
end
function M.Paint(t,d,path,color,horizontalWrap,verticalWrap)
 local custom=d.backingColorEnabled and M.Valid(d.backingColor) or false
 local c=custom and d.backingColor or color or {1,1,1,1}
 local old=painted[t]
 if old and old.custom==custom and old.path==path and old.horizontalWrap==horizontalWrap and old.verticalWrap==verticalWrap and old[1]==c[1] and old[2]==c[2] and old[3]==c[3] then return end
 painted[t]={custom=custom,path=path,horizontalWrap=horizontalWrap,verticalWrap=verticalWrap,c[1],c[2],c[3]}
 if custom then
  t:SetColorTexture(d.backingColor[1],d.backingColor[2],d.backingColor[3],1)
  t:SetVertexColor(1,1,1,1)
 elseif path then
  t:SetTexture(path,horizontalWrap,verticalWrap);t:SetVertexColor(unpack(color or {1,1,1,1}))
 else
  t:SetColorTexture(unpack(color));t:SetVertexColor(1,1,1,1)
 end
end
local function Coordinate(v)
 return not (issecretvalue and issecretvalue(v)) and type(v)=='number'and v==v and math.abs(v)<math.huge
end
-- Union the existing bar backing with the actual inner opening. Textured
-- defaults retain their old geometry; no saved position/dimension is changed.
function M.Expand(d,l,r,t,b,innerLeft,innerRight,innerTop,innerBottom)
 if not d.backingColorEnabled or not M.Valid(d.backingColor)then return l,r,t,b end
 if not(Coordinate(innerLeft)and Coordinate(innerRight)and Coordinate(innerTop)and Coordinate(innerBottom))or innerRight<=innerLeft or innerTop<=innerBottom then return l,r,t,b end
 return math.min(l,innerLeft-4),math.max(r,innerRight+4),math.max(t,innerTop+4),math.min(b,innerBottom-4)
end
-- Hunter/Warrior keep their existing bar panel and rail anchors. Expand only
-- the mouse-transparent fill texture so resizing cannot reposition the rail.
function M.FollowArt(texture,d,l,r,t,b)
 if not d.backingColorEnabled or not M.Valid(d.backingColor)then return end
 local art=_G.ForeverHunterArtFrame
 if not art or not art:IsShown()then return end
 local x,y,w,h=art:GetRect()
 if not(Coordinate(x)and Coordinate(y)and Coordinate(w)and Coordinate(h))or w<=0 or h<=0 then return end
 local ratio=art:GetEffectiveScale()/UIParent:GetEffectiveScale()
 if not Coordinate(ratio)or ratio<=0 then return end
 local _,class=UnitClass('player')
 local left,right,top,bottom=.135,.865,.82,.32
 if class=='WARRIOR'then left,right,top,bottom=.145,.855,.74,.225 end
 l,r,t,b=M.Expand(d,l,r,t,b,(x+w*left)*ratio,(x+w*right)*ratio,(y+h*top)*ratio,(y+h*bottom)*ratio)
 texture:ClearAllPoints();texture:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',l,b)
 texture:SetPoint('TOPRIGHT',UIParent,'BOTTOMLEFT',r,t)
end
function M.Set(enabled,color)
 if InCombatLockdown() or type(enabled)~='boolean' or (color~=nil and not M.Valid(color)) then return false end
 local api=ForeverClassArtLayoutAPI;local d=api and api.GetSettings()
 if not d then return false end
 d.backingColorEnabled=enabled
 if color then d.backingColor={unpack(color)} end
 api.Refresh();return true
end
-- Paladin's original artwork has a transparent interior and no separate fill.
-- Add a mouse-transparent backing only when a custom color is requested.
function M.CreatePaladin()
 local panel=CreateFrame('Frame',nil,UIParent)
 panel:SetFrameStrata('BACKGROUND');panel:SetFrameLevel(0);panel:EnableMouse(false);panel:Hide()
 local t=panel:CreateTexture(nil,'BACKGROUND');t:SetAllPoints()
 return {Hide=function() panel:Hide() end,Options=function(getDB)
  return {args={opacity={type='range',order=1,min=0,max=1,step=.05,
   get=function() return getDB().backingAlpha or 1 end,
   set=function(_,v) if not InCombatLockdown() then getDB().backingAlpha=v;ForeverClassArtLayoutAPI.Refresh() end end}}}
 end,
  Update=function(d)
   if InCombatLockdown() then return end
   if not d.enabled or not d.backingColorEnabled or not M.Valid(d.backingColor) then panel:Hide();return end
   local l,r,top,bottom=KerimAnkaUIBarsAPI.Bounds(d.bars)
   if not l then panel:Hide();return end
   panel:ClearAllPoints();panel:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',l-3,bottom-3)
   panel:SetSize(r-l+6,top-bottom+6);M.Paint(t,d)
   panel:SetAlpha((d.alpha or 1)*(d.backingAlpha or 1));panel:Show()
  end}
end
