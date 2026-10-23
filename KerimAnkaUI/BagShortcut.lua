local _,K=...
local M={};K.BagShortcut=M
local defaults={enabled=true,locked=true,size=44,x=.71,y=.16}
local bounds={size={24,80},x={0,1},y={0,1}}
local button,dragging,skipClick,pending
local art='Interface\\AddOns\\KerimAnkaUI\\Media\\BagShortcut.tga'
local function Combat() return InCombatLockdown and InCombatLockdown() end
function M.Get(key)
 local db=K.db and K.db.bagShortcut
 if db and type(db[key])==type(defaults[key]) then return db[key] end
 return defaults[key]
end
local function KeyName(command)
 local first,second
 if GetBindingKey then first,second=GetBindingKey(command) end
 local keys={}
 for _,key in ipairs({first,second}) do
  keys[#keys+1]=GetBindingText and GetBindingText(key,'KEY_') or key
 end
 return #keys>0 and table.concat(keys,' / ') or K.L('bsUnbound')
end
function M.BindingInfo()
 return K.L('bsAllBags')..': '..KeyName('OPENALLBAGS')..'\n'..K.L('bsBackpack')..': '..KeyName('TOGGLEBACKPACK')
end
local function Position()
 if not button then return end
 button:ClearAllPoints()
 button:SetPoint('CENTER',UIParent,'BOTTOMLEFT',UIParent:GetWidth()*M.Get('x'),UIParent:GetHeight()*M.Get('y'))
end
local function StopDrag(save)
 if not button or not dragging then return end
 button:StopMovingOrSizing();dragging=false
 if save and not Combat() then
  local x,y=button:GetCenter()
  if x and y then
   local scale=button:GetEffectiveScale()/UIParent:GetEffectiveScale()
   K.db.bagShortcut=K.db.bagShortcut or {}
   K.db.bagShortcut.x=math.max(0,math.min(1,x*scale/UIParent:GetWidth()))
   K.db.bagShortcut.y=math.max(0,math.min(1,y*scale/UIParent:GetHeight()))
  end
 end
 Position()
end
local function Tooltip(self)
 GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT');GameTooltip:SetText(K.L('bsTitle'),1,.83,.45)
 GameTooltip:AddLine(M.BindingInfo(),1,1,1)
 if not M.Get('locked') then GameTooltip:AddLine(K.L('bsDrag'),.7,.8,.7) end
 GameTooltip:Show()
end
local function Ensure()
 if button then return end
 button=CreateFrame('Button','KerimAnkaUIBagShortcut',UIParent)
 button:SetFrameStrata('MEDIUM');button:SetMovable(true);button:SetClampedToScreen(true)
 button:EnableMouse(true);button:RegisterForClicks('LeftButtonUp');button:RegisterForDrag('LeftButton')
 local icon=button:CreateTexture(nil,'ARTWORK');icon:SetAllPoints();icon:SetTexture(art,'CLAMP','CLAMP','TRILINEAR')
 local glow=button:CreateTexture(nil,'HIGHLIGHT');glow:SetAllPoints();glow:SetTexture(art,'CLAMP','CLAMP','TRILINEAR');glow:SetBlendMode('ADD');glow:SetAlpha(.18)
 button:SetScript('OnClick',function()
  if dragging or skipClick then return end
  -- Native entry point also respects installed bag replacements. No bindings
  -- or item-button attributes are changed by this shortcut.
  if ToggleAllBags then ToggleAllBags() elseif ToggleBackpack then ToggleBackpack() end
 end)
 button:SetScript('OnEnter',Tooltip)
 button:SetScript('OnLeave',function() GameTooltip:Hide() end)
 button:SetScript('OnDragStart',function(self)
  if M.Get('locked') or Combat() then return end
  GameTooltip:Hide();dragging=true;self:StartMoving()
 end)
 button:SetScript('OnDragStop',function()
  if not dragging then return end
  skipClick=true;StopDrag(true)
  C_Timer.After(0,function() skipClick=false end)
 end)
end
function M.Refresh()
 if not K.db then return end
 if Combat() then pending=true;return end
 pending=false;Ensure()
 if dragging then return end
 button:SetSize(M.Get('size'),M.Get('size'));Position();button:SetShown(M.Get('enabled'))
end
function M.Set(key,value)
 if not K.db or Combat() or defaults[key]==nil then return false end
 if type(defaults[key])=='boolean' then
  if type(value)~='boolean' then return false end
 else
  if type(value)~='number' or value~=value or math.abs(value)==math.huge then return false end
  value=math.max(bounds[key][1],math.min(bounds[key][2],value))
 end
 StopDrag(false);K.db.bagShortcut=K.db.bagShortcut or {};K.db.bagShortcut[key]=value
 M.Refresh();return true
end
function M.ResetPosition()
 if not K.db or Combat() then return false end
 StopDrag(false);K.db.bagShortcut=K.db.bagShortcut or {}
 K.db.bagShortcut.x=nil;K.db.bagShortcut.y=nil;M.Refresh();return true
end
function M.Draw(page,w,y)
 w.Text(page,K.L('bsTitle'),8,y,690,18,{.73,.62,.41});y=y-36
 w.Text(page,K.L('bsHelp'),8,y,690,13,{.65,.70,.62});y=y-94
 w.Text(page,M.BindingInfo(),8,y,690,13,{.83,.78,.60});y=y-60
 for _,entry in ipairs({{'enabled','bsEnabled'},{'locked','bsLocked'}}) do
  local key,label=unpack(entry);local card=w.Box(page,0,y,714,62)
  w.Text(card,K.L(label),16,-20,550,14)
  w.Switch(card,M.Get(key),620,-16,function(value) M.Set(key,value);K.Render() end,not Combat())
  y=y-78
 end
 local card=w.Box(page,0,y,349,86)
 w.Text(card,K.L('bsSize'),14,-12,310,13)
 local value=w.Text(card,tostring(M.Get('size')),14,-54,150,15)
 for _,delta in ipairs({-1,1}) do
  local change=delta
  local b=w.Button(card,delta<0 and '−' or '+',delta<0 and 251 or 297,-47,36,32,function()
   if M.Set('size',M.Get('size')+change) then value:SetText(tostring(M.Get('size'))) end
  end)
  if Combat() then b:Disable() end
 end
 local reset=w.Button(page,K.L('bsReset'),365,y-22,349,38,function() if M.ResetPosition() then K.Render() end end)
 if Combat() then reset:Disable() end
 return y-110
end
local previous=K.InventoryMenus.Refresh
function K.InventoryMenus.Refresh(...) previous(...);M.Refresh() end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_REGEN_ENABLED','PLAYER_REGEN_DISABLED','DISPLAY_SIZE_CHANGED','UI_SCALE_CHANGED','UPDATE_BINDINGS'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(_,event)
 if event=='PLAYER_REGEN_DISABLED' then StopDrag(false);return end
 if event=='UPDATE_BINDINGS' then
  if button and GameTooltip.IsOwned and GameTooltip:IsOwned(button) then Tooltip(button) end
  return
 end
 M.Refresh()
end)
