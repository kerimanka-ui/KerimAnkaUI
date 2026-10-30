if select(2,...).blocked then return end
if WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,N=...;local K=N.host;local C=K.Chat
local MEDIA='Interface\\AddOns\\KerimAnkaUI_Chat\\ClassicEra\\Chat\\Media\\'
-- Coordinates refer to the original generated assets; export resizing preserves UVs.
local l,r,t,b=32/1254,1224/1254,32/1254,1224/1254
local corner,rail=128/1254,64/1254
local frameUV={
 {l,l+corner,t,t+corner},{r-corner,r,t,t+corner},
 {l,l+corner,b-corner,b},{r-corner,r,b-corner,b},
 {.375,.625,t,t+rail},{.375,.625,b-rail,b},
 {l,l+rail,.375,.625},{r-rail,r,.375,.625}}
local function Tex(parent,path,uv)
 local texture=parent:CreateTexture(nil,'BORDER')
 texture:SetTexture(MEDIA..path,'CLAMP','CLAMP','TRILINEAR')
 texture:SetTexCoord(unpack(uv))
 if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(false);texture:SetTexelSnappingBias(0)end
 return texture
end
function C.BronzeMetrics(width,height)
 local c=math.min(12,width/4,height/4)
 return c,c/2,math.max(0,width-2*c),math.max(0,height-2*c)
end
function C.BronzeGap(width,left,right)
 local c=C.BronzeMetrics(width,100)
 left=math.max(c,math.min(width-c,left));right=math.max(left,math.min(width-c,right))
 return left,right,math.max(0,left-c),math.max(0,width-c-right)
end
function C.BronzeFrame(parent)
 local f={parent=parent,parts={}}
 for i,uv in ipairs(frameUV)do f.parts[i]=Tex(parent,'ClassicBronzeFrame.tga',uv)end
 f.before=Tex(parent,'ClassicBronzeFrame.tga',frameUV[5]);f.after=Tex(parent,'ClassicBronzeFrame.tga',frameUV[5])
 return f
end
function C.PlaceBronzeFrame(f,width,height)
 local c,e,w,h=C.BronzeMetrics(width,height);local p=f.parts;local parent=f.parent
 for i,point in ipairs({'TOPLEFT','TOPRIGHT','BOTTOMLEFT','BOTTOMRIGHT'})do
  p[i]:ClearAllPoints();p[i]:SetPoint(point,parent,point,0,0);p[i]:SetSize(c,c)
 end
 for i,point in ipairs({'TOP','BOTTOM'})do
  local tex=p[i+4];tex:ClearAllPoints();tex:SetPoint(point..'LEFT',parent,point..'LEFT',c,0);tex:SetSize(w,e)
 end
 for i,point in ipairs({'LEFT','RIGHT'})do
  local tex=p[i+6];tex:ClearAllPoints();tex:SetPoint('TOP'..point,parent,'TOP'..point,0,-c);tex:SetSize(e,h)
 end
 f.width,f.corner,f.edge=width,c,e;f.joinKey=nil
end
function C.JoinBronzeFrame(shell,g,tab)
 local f=shell.bronze;if not f then return end
 local scale=tab and tab:GetEffectiveScale()/UIParent:GetEffectiveScale()
 local x=tab and tab:GetLeft()
 if not x then f.parts[5]:Show();f.before:Hide();f.after:Hide();return end
 local left=x*scale-g.x-7*scale
 local right=left+(tab:GetWidth()+14)*scale
 local a,z,before,after=C.BronzeGap(g.width,left,right)
 f.parts[5]:Hide()
 for _,piece in ipairs({{f.before,f.corner,before},{f.after,z,after}})do
  local tex,offset,width=unpack(piece);tex:ClearAllPoints();tex:SetPoint('TOPLEFT',shell,'TOPLEFT',offset,0)
  tex:SetColorTexture(171/255,145/255,95/255,1)
  tex:SetSize(math.max(.01,width),1.35);tex:SetShown(width>.01)
 end

end
function C.BronzeTabSpec(width,selected,hover)return {height=27,base=3,u0=0,u1=1,v1=1,cap=1,color=selected and {1,1,1}or{.7,.7,.7}}end
local function Solid(parent,layer,r,g,b,a)
 local t=parent:CreateTexture(nil,layer);t:SetColorTexture(r,g,b,a or 1);return t
end
function C.BronzeTab(tab)
 C.tabChrome=C.tabChrome or setmetatable({},{__mode='k'})
 if C.tabChrome[tab]then return C.tabChrome[tab]end
 local f=CreateFrame('Frame',nil,tab);f:EnableMouse(false);f.nativeTab=tab;f.width=tab:GetWidth()
 f.fill=Solid(f,'BACKGROUND',.10,.13,.12,.98);f.fill:SetAllPoints()
 f.edges={};for _,point in ipairs({'TOP','LEFT','RIGHT'})do
  local t=Solid(f,'BORDER',.25,.29,.26,1);f.edges[#f.edges+1]=t
  if point=='TOP'then t:SetPoint('TOPLEFT');t:SetPoint('TOPRIGHT');t:SetHeight(1)
  else t:SetPoint('TOP'..point);t:SetPoint('BOTTOM'..point);t:SetWidth(1)end
 end
 f.baseline=Solid(f,'OVERLAY',.68,.64,.46,1);f.baseline:SetPoint('BOTTOMLEFT',7,0);f.baseline:SetPoint('BOTTOMRIGHT',-7,0);f.baseline:SetHeight(2)
 C.tabChrome[tab]=f;return f
end
function C.PaintBronzeTab(f)
 f:ClearAllPoints();f:SetPoint('BOTTOMLEFT',f.nativeTab,'BOTTOMLEFT',1,3);f:SetPoint('BOTTOMRIGHT',f.nativeTab,'BOTTOMRIGHT',-1,3);f:SetHeight(27)
 local v=f.selected and .17 or f.hover and .14 or .09
 f.fill:SetColorTexture(v,v+.02,v+.01,.98)
 for _,t in ipairs(f.edges)do t:SetColorTexture(f.selected and .39 or .22,f.selected and .42 or .26,f.selected and .36 or .23,1)end
 if f.accent then f.baseline:SetColorTexture(f.accent[1],f.accent[2],f.accent[3],1)else f.baseline:SetColorTexture(.68,.64,.46,1)end
 f.baseline:SetShown(f.selected)
end
function C.SelectBronzeTab(f,selected)f.selected=selected;C.PaintBronzeTab(f)end
function C.SizeBronzeTab(f,width)f.width=width;C.PaintBronzeTab(f)end

function C.PlaceTabPlate(tab,plate)
 local dock=GENERAL_CHAT_DOCK
 local primary=dock and dock.primary
 local first=primary and _G[primary:GetName()..'Tab']
 local parent=first and first:GetParent()or tab
 local viewport=dock and dock.scrollFrame
 if viewport and tab:GetParent()==viewport:GetScrollChild()then
  if not C.tabClip then C.tabClip=CreateFrame('Frame',nil,parent);C.tabClip:EnableMouse(false);C.tabClip:SetClipsChildren(true)end
  C.tabClip:ClearAllPoints();C.tabClip:SetPoint('TOPLEFT',viewport,'TOPLEFT',0,10);C.tabClip:SetPoint('BOTTOMRIGHT',viewport,'BOTTOMRIGHT',0,0);C.tabClip:Show()
  parent=C.tabClip
 end
 if plate:GetParent()~=parent then plate:SetParent(parent)end
 plate:SetScale(tab:GetEffectiveScale()/parent:GetEffectiveScale())
 local visible=tab:IsShown()and(not tab.IsVisible or tab:IsVisible())
 local viewport=dock and dock.scrollFrame
 if visible and viewport and tab:GetParent()==viewport:GetScrollChild()then
  local s=tab:GetEffectiveScale();local v=viewport:GetEffectiveScale()
  local l,r=tab:GetLeft(),tab:GetRight();local a,b=viewport:GetLeft(),viewport:GetRight()
  if l and r and a and b then visible=r*s>a*v and l*s<b*v end
 end
 plate:SetShown(visible)
end

function C.BronzeFrame(parent)
 local f={parent=parent,parts={}}
 for i=1,8 do f.parts[i]=Solid(parent,'BORDER',.24,.28,.25,1)end
 f.before=Solid(parent,'BORDER',.24,.28,.25,1);f.after=Solid(parent,'BORDER',.24,.28,.25,1);return f
end
function C.PlaceBronzeFrame(f,w,h)
 local specs={{'TOPLEFT','TOPRIGHT',w,1},{'BOTTOMLEFT','BOTTOMRIGHT',w,1},{'TOPLEFT','BOTTOMLEFT',1,h},{'TOPRIGHT','BOTTOMRIGHT',1,h}}
 for i=1,8 do local t=f.parts[i];t:Hide();if specs[i]then local a,b,tw,th=unpack(specs[i]);t:ClearAllPoints();t:SetPoint(a,f.parent,a);t:SetSize(tw,th);t:Show()end end
 f.before:Hide();f.after:Hide()
end
function C.JoinBronzeFrame()end
