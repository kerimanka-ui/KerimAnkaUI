-- Only paints the existing backing texture. No button, layer or anchor changes.
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
