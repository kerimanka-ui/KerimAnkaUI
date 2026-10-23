local _,K=...
local M={};K.FPS=M
-- Captured MoveAny DEFAULT / MAFPSFrame, relative to UIParent.
K.fpsDefaults={enabled=true,locked=true,x=-10,y=-260}
local defaults=K.fpsDefaults
local frame,dragging,elapsed
function M.Get(key)
 local data=K.db and K.db.fps
 if data and type(data[key])==type(defaults[key]) then return data[key] end
 return defaults[key]
end
local function Position()
 frame:ClearAllPoints();frame:SetPoint('RIGHT',UIParent,'RIGHT',M.Get('x'),M.Get('y'))
end
local function Update()
 local value=GetFramerate and GetFramerate()
 local text=type(value)=='number' and value==value and value>=0 and value<100000 and tostring(math.floor(value)) or '—'
 frame.text:SetText('|cff3fc7ebFPS:|r |cffffd100'..text..'|r')
end
local function Tick(_,delta)
 elapsed=(elapsed or 0)+delta
 if elapsed>=.5 then elapsed=0;Update() end
end
local function Stop(save)
 if not dragging then return end
 frame:StopMovingOrSizing();dragging=false
 if save and not K.InCombat() then
  local x,y=frame:GetCenter();local scale=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
  if x and y then
   K.db.fps=K.db.fps or {}
   K.db.fps.x=math.max(-10000,math.min(10000,(x+frame:GetWidth()/2)*scale-UIParent:GetWidth()))
   K.db.fps.y=math.max(-10000,math.min(10000,y*scale-UIParent:GetHeight()/2))
  end
 end
 Position()
end
local function Ensure()
 if frame then return end
 frame=CreateFrame('Frame','KerimAnkaUIFPS',UIParent)
 frame:SetSize(100,20);frame:SetFrameStrata('MEDIUM');frame:SetClampedToScreen(true);frame:SetMovable(true)
 frame:RegisterForDrag('LeftButton')
 frame.text=frame:CreateFontString(nil,'OVERLAY');frame.text:SetPoint('CENTER');frame.text:SetWidth(100);frame.text:SetWordWrap(false)
 frame.background=frame:CreateTexture(nil,'BACKGROUND');frame.background:SetAllPoints();frame.background:SetColorTexture(.07,.09,.07,.75)
 frame:SetScript('OnDragStart',function(self)
  if M.Get('locked') or K.InCombat() then return end
  dragging=true;self:StartMoving()
 end)
 frame:SetScript('OnDragStop',function() Stop(true) end)
 frame:SetScript('OnHide',function() Stop(false) end)
end
function M.Refresh()
 if not K.db or not K.ApplyTextFont then return end
 Ensure();if dragging then return end
 K.ApplyTextFont(frame.text,14,false,'OUTLINE');Position()
 frame:EnableMouse(not M.Get('locked') and not K.InCombat())
 frame.background:SetShown(not M.Get('locked'))
 local enabled=M.Get('enabled') and type(GetFramerate)=='function'
 frame:SetScript('OnUpdate',enabled and Tick or nil)
 frame:SetShown(enabled)
 elapsed=0;if enabled then Update() end
end
function M.Set(key,value)
 if not K.db or K.InCombat() or defaults[key]==nil or type(value)~=type(defaults[key]) then return false end
 if type(value)=='number' then
  if value~=value or math.abs(value)==math.huge then return false end
  value=math.max(-10000,math.min(10000,value))
 end
 Stop(false);K.db.fps=K.db.fps or {};K.db.fps[key]=value;M.Refresh();return true
end
function M.ResetPosition()
 if not K.db or K.InCombat() then return false end
 Stop(false);K.db.fps=K.db.fps or {};K.db.fps.x=defaults.x;K.db.fps.y=defaults.y;M.Refresh();return true
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','DISPLAY_SIZE_CHANGED','UI_SCALE_CHANGED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function() Stop(false);M.Refresh() end)
