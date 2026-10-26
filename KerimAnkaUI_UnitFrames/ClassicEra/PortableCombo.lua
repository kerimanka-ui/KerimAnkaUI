-- Classic Era / Hardcore only. Original Blizzard Forever red combo artwork; local Classic renderer.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local M={};KerimAnkaUIClassicCombo=M
local frame,pips,label
local nativeState
local function DB() return type(KAClassic_ForeverLeatherUnitsDB)=='table' and KAClassic_ForeverLeatherUnitsDB end
local function Rogue() return select(2,UnitClass('player'))=='ROGUE' end
local function Config()
 local d=DB();if not d then return end
 if type(d.comboDetached)~='table' then d.comboDetached={} end
 local c=d.comboDetached
 if type(c.locked)~='boolean' then c.locked=true end
 c.size=math.max(12,math.min(40,tonumber(c.size) or 22))
 c.gap=math.max(0,math.min(16,tonumber(c.gap) or 5))
 c.x=tonumber(c.x) or 0;c.y=tonumber(c.y) or -170
 return c
end
function M.Wanted() local d=DB();return Rogue() and d and d.showCombo==true or false end
local function SuppressNative()
 local f=_G.ComboFrame;if not f or not f.GetAlpha then return end
 if not nativeState or nativeState.frame~=f then
  local s={frame=f,alpha=f:GetAlpha()};nativeState=s
  hooksecurefunc(f,'SetAlpha',function(_,alpha)
   if s.changing then return end
   s.alpha=alpha
   if s.suppressed then s.changing=true;f:SetAlpha(0);s.changing=false end
  end)
 end
 local d=DB();local hide=M.Wanted() or d and d.enabled and d.hideNative or false
 local s=nativeState
 if hide then
  s.suppressed=true;s.changing=true;f:SetAlpha(0);s.changing=false
 elseif s.suppressed then
  s.suppressed=false;s.changing=true;f:SetAlpha(s.alpha);s.changing=false
 end
end
local function Maximum()
 local getter=UnitPowerMax
 local ok,v=pcall(function() return getter and getter('player',(Enum and Enum.PowerType and Enum.PowerType.ComboPoints) or 4) end)
 return ok and type(v)=='number' and v>0 and math.max(1,math.min(10,math.floor(v))) or 5
end
function M.Points()
 local points
 if GetComboPoints then local ok,v=pcall(GetComboPoints,'player','target');if ok then points=v end end
 if type(points)~='number' and UnitPower then points=UnitPower('player',(Enum and Enum.PowerType and Enum.PowerType.ComboPoints) or 4) end
 return type(points)=='number' and math.max(0,math.min(Maximum(),math.floor(points))) or 0
end
-- Original high-resolution Forever atlas (FileDataID 8474117, build 1.60.1.70532).
-- Coordinates match UiTextureAtlasMember's c60-2x entries; no Classic atlas registration required.
local ART='Interface\\AddOns\\KerimAnkaUI_UnitFrames\\ClassicEra\\Media\\BlizzardRogueCombo.blp'
local parts={
 BGShadow={1,51,335,385,25,-4},BGActive={1,45,387,431,22,0},
 BGInactive={1,45,433,477,22,0},BGGlow={1,45,387,431,22,0},
 Icon={31,59,479,507,14,0},FX={1,29,479,507,14,0},
 FrameGlow={75,119,261,305,22,0},Slash={1,517,1,259,43,0},
}
local function Alpha(t,a) t:SetAlpha(math.max(0,math.min(1,a))) end
local function Ramp(t,delay,duration) return math.max(0,math.min(1,(t-delay)/duration)) end
local function SlashFrame(p,index)
 local col=index%6;local row=math.floor(index/6)
 p.Slash:SetTexCoord((1+col*86)/1024,(1+(col+1)*86)/1024,(1+row*86)/512,(1+(row+1)*86)/512)
end
local function Finish(p,active)
 p:SetScript('OnUpdate',nil);p.animating=false
 Alpha(p.BGInactive,active and 0 or 1);Alpha(p.BGActive,active and 1 or 0)
 Alpha(p.Icon,active and 1 or 0)
 for _,key in ipairs({'BGGlow','FX','FrameGlow','Slash'}) do Alpha(p[key],0) end
end
local function Paint(p,active,instant)
 if p.active==active then return end
 local hadState=p.active~=nil;p.active=active
 if instant or not hadState then Finish(p,active);return end
 p.elapsed=0;p.animating=true
 p:SetScript('OnUpdate',function(self,elapsed)
  self.elapsed=self.elapsed+elapsed;local t=self.elapsed
  if active then
   Alpha(self.Icon,.5*Ramp(t,0,.1)+.5*Ramp(t,.27,.27))
   Alpha(self.BGActive,Ramp(t,.2,.17));Alpha(self.BGInactive,1-Ramp(t,.37,.1))
   Alpha(self.BGGlow,t<.17 and Ramp(t,0,.17) or 1-Ramp(t,.17,.4))
   Alpha(self.FrameGlow,0);Alpha(self.FX,0)
   Alpha(self.Slash,t<.57 and 1 or 0);SlashFrame(self,math.min(16,math.floor(t/.57*17)))
  else
   Alpha(self.Icon,1-Ramp(t,0,.17));Alpha(self.FX,1-Ramp(t,0,.4))
   Alpha(self.FrameGlow,1-Ramp(t,0,.5));Alpha(self.BGGlow,0);Alpha(self.Slash,0)
   Alpha(self.BGActive,1-Ramp(t,.2,.17));Alpha(self.BGInactive,Ramp(t,.37,.1))
  end
  if t>=.57 then Finish(self,active) end
 end)
 -- Initialize this transition immediately; no stale effect on its first rendered frame.
 p:GetScript('OnUpdate')(p,0)
end
local function NewPip()
 local p=CreateFrame('Frame',nil,frame);p:EnableMouse(false)
 for _,key in ipairs({'BGShadow','BGActive','BGInactive','BGGlow','Icon','FX','FrameGlow','Slash'}) do
  local part=parts[key];local layer=(key=='Icon' or key=='FX') and 'ARTWORK' or (key=='FrameGlow' or key=='Slash') and 'OVERLAY' or 'BACKGROUND'
  local t=p:CreateTexture(nil,layer);p[key]=t
  t:SetTexture(ART,'CLAMP','CLAMP','LINEAR')
  t:SetTexCoord(part[1]/1024,part[2]/1024,part[3]/512,part[4]/512)
  if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
  if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
 end
 Alpha(p.BGShadow,1);return p
end
local function LayoutPip(p,size)
 p:SetSize(size,size)
 for key,part in pairs(parts) do
  local t=p[key];t:ClearAllPoints();t:SetPoint('CENTER',p,'CENTER',0,part[6]*size/22)
  t:SetSize(part[5]*size/22,part[5]*size/22)
 end
end
local function Ensure()
 if frame then return end
 frame=CreateFrame('Frame','KerimAnkaUIClassicComboFrame',UIParent);frame:SetFrameStrata('MEDIUM')
 frame:SetMovable(true);frame:SetClampedToScreen(true);frame:RegisterForDrag('LeftButton');pips={}
 label=frame:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');label:SetPoint('BOTTOM',frame,'TOP',0,5)
 label:SetText('Combo points - drag to move')
 frame:SetScript('OnDragStart',function(self)
  local c=Config();if c and not c.locked and not InCombatLockdown() then self:StartMoving() end
 end)
 frame:SetScript('OnDragStop',function(self)
  self:StopMovingOrSizing();local c=Config();local x,y=self:GetCenter();local px,py=UIParent:GetCenter()
  if c and x and y and px and py then c.x=x-px;c.y=y-py end
  M.Refresh()
 end)
end
function M.Refresh(suppressTransitions)
 SuppressNative()
 if not M.Wanted() then
  if frame then frame:Hide();for _,p in ipairs(pips) do Finish(p,false);p.active=nil end end
  return
 end
 local c=Config();if not c then return end
 local instant=suppressTransitions or not frame or not frame:IsShown()
 Ensure();local maximum=Maximum();local points=M.Points()
 frame:SetSize(maximum*c.size+(maximum-1)*c.gap,c.size)
 frame:ClearAllPoints();frame:SetPoint('CENTER',UIParent,'CENTER',c.x,c.y)
 frame:EnableMouse(not c.locked);label:SetShown(not c.locked)
 for i=1,maximum do
  local pip=pips[i]
  if not pip then pip=NewPip();pips[i]=pip end
  LayoutPip(pip,c.size);pip:ClearAllPoints()
  pip:SetPoint('TOPLEFT',frame,'TOPLEFT',(i-1)*(c.size+c.gap),0)
  if instant then Finish(pip,i<=points);pip.active=i<=points else Paint(pip,i<=points,false) end
  pip:Show()
 end
 for i=maximum+1,#pips do local p=pips[i];Finish(p,false);p.active=nil;p:Hide() end
 frame:Show()
end
function M.Settings() return Config() end
function M.Set(key,value)
 if InCombatLockdown() then return false end
 local c=Config();if not c then return false end
 if key=='locked' and type(value)=='boolean' then c.locked=value
 elseif key=='size' and type(value)=='number' then c.size=math.max(12,math.min(40,value))
 elseif key=='gap' and type(value)=='number' then c.gap=math.max(0,math.min(16,value))
 else return false end
 M.Refresh();return true
end
function M.Reset()
 if InCombatLockdown() or not DB() then return false end
 DB().comboDetached=nil;M.Refresh();return true
end
local e=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_TARGET_CHANGED','COMBO_TARGET_CHANGED','UNIT_POWER_FREQUENT','UNIT_MAXPOWER','PLAYER_REGEN_ENABLED','PLAYER_REGEN_DISABLED','ADDON_LOADED'}) do e:RegisterEvent(event) end
e:SetScript('OnEvent',function(_,event,unit)
 if (event=='UNIT_POWER_FREQUENT' or event=='UNIT_MAXPOWER') and unit~='player' then return end
 if event=='PLAYER_REGEN_DISABLED' and frame then frame:StopMovingOrSizing() end
 M.Refresh(event=='PLAYER_TARGET_CHANGED' or event=='PLAYER_LOGIN' or event=='PLAYER_ENTERING_WORLD')
end)
SLASH_KERIMANKAUICLASSICCOMBO1='/kauicombo'
SlashCmdList.KERIMANKAUICLASSICCOMBO=function(text)
 text=(text or ''):lower():match('^%s*(.-)%s*$')
 if text=='unlock' then M.Set('locked',false)
 elseif text=='lock' then M.Set('locked',true)
 elseif text=='reset' then M.Reset()
 else print('Classic combo: /kauicombo unlock | lock | reset. Enable round points in Unit Frames settings.') end
end
