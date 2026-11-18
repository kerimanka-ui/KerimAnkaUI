local _,K=...
-- Forever Action Tracker 1.0.0-test3. Own frames/events only; no meter hooks.
local M={version='1.0.0-test3'};K.ActionTracker=M
local D={enabled=false,melee=false,ranged=false,gcd=true,locked=true,count=5,direction=1,size=36,gap=4,alpha=1,x=0,y=-180}
local bounds={count={1,10},direction={1,4},size={20,72},gap={0,16},alpha={.2,1},x={-4000,4000},y={-2500,2500}}
local history,slots={},{}
local sample={136048,132222,135846,136197,132089}
local host,preview,layoutPreview,candidate,gcdReference,queued,channel
local events=CreateFrame('Frame')
local function Secret(v)return issecretvalue and issecretvalue(v)end
local function Number(v)return not Secret(v)and type(v)=='number'and v==v and math.abs(v)<math.huge end
local function Combat()return InCombatLockdown()end
function M.Get(key)
 local db=KerimAnkaUIDB and KerimAnkaUIDB.actionTracker
 local v=type(db)=='table'and db[key]
 if Secret(v)or type(v)~=type(D[key])then return D[key]end
 if type(v)=='number'then
  local b=bounds[key]
  if not Number(v)or v<b[1]or v>b[2]then return D[key]end
  if key~='alpha'and v~=math.floor(v)then return D[key]end
 end
 return v
end
local function Store(key,v)
 KerimAnkaUIDB=KerimAnkaUIDB or {}
 if type(KerimAnkaUIDB.actionTracker)~='table'then KerimAnkaUIDB.actionTracker={}end
 KerimAnkaUIDB.actionTracker[key]=v
end
function M.Settings(create)
 if create then
  KerimAnkaUIDB=KerimAnkaUIDB or {}
  if type(KerimAnkaUIDB.actionTracker)~='table'then KerimAnkaUIDB.actionTracker={}end
 end
 return KerimAnkaUIDB and KerimAnkaUIDB.actionTracker
end
local function ClearCooldown(slot)
 slot.entry=nil;slot.cd:Clear();slot.cd:Hide()
end
local function Ensure()
 if not host then
 host=CreateFrame('Frame','KerimAnkaUIActionTracker',UIParent)
 M.hud=host
 host:SetFrameStrata('MEDIUM');host:SetClampedToScreen(true);host:SetMovable(true)
 host:RegisterForDrag('LeftButton')
 host:SetScript('OnDragStart',function(self)if not M.Get('locked')and not Combat()then self:StartMoving()end end)
 host:SetScript('OnDragStop',function(self)
  self:StopMovingOrSizing()
  if Combat()then M.Refresh();return end
  local x,y=self:GetCenter();local px,py=UIParent:GetCenter()
  if Number(x)and Number(y)and Number(px)and Number(py)then
   Store('x',math.max(-4000,math.min(4000,math.floor(x-px+.5))))
   Store('y',math.max(-2500,math.min(2500,math.floor(y-py+.5))))
  end
  M.Refresh()
 end)
 end
 -- Allocate extra slots only when requested; reuse them after a later shrink.
 for i=#slots+1,M.Get('count')do
  local f=CreateFrame('Frame',nil,host);f:EnableMouse(false)
  local bg=f:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.06,.06,.06,.9)
  local tex=f:CreateTexture(nil,'ARTWORK');tex:SetPoint('TOPLEFT',1,-1);tex:SetPoint('BOTTOMRIGHT',-1,1);tex:SetTexCoord(.07,.93,.07,.93)
  local cd=CreateFrame('Cooldown',nil,f,'CooldownFrameTemplate');cd:SetAllPoints();cd:EnableMouse(false)
  cd:SetDrawSwipe(true);cd:SetDrawEdge(false);cd:SetDrawBling(false);cd:SetSwipeColor(0,0,0,.65);cd:SetHideCountdownNumbers(true)
  local badge=f:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');badge:SetPoint('BOTTOMRIGHT',-2,2)
  local slot={frame=f,tex=tex,cd=cd,badge=badge};slots[i]=slot
  cd:SetScript('OnCooldownDone',function()
   if slot.entry then slot.entry.duration=nil;slot.entry.finished=true end
   slot.entry=nil;cd:Hide()
  end)
 end
end
local function Bind(slot,entry)
 if not M.Get('gcd')or entry.finished or not entry.duration or not slot.cd.SetCooldownFromDurationObject then return end
 slot.entry=entry;slot.cd:Show()
 if not pcall(slot.cd.SetCooldownFromDurationObject,slot.cd,entry.duration,true)then ClearCooldown(slot)end
end
local function Layout()
 if not host then return end
 local n,size,gap,dir=M.Get('count'),M.Get('size'),M.Get('gap'),M.Get('direction')
 local span=n*size+(n-1)*gap
 host:SetSize(dir<3 and span or size,dir<3 and size or span)
 host:ClearAllPoints();host:SetPoint('CENTER',UIParent,'CENTER',M.Get('x'),M.Get('y'))
 host:SetAlpha(M.Get('alpha'));host:EnableMouse(not M.Get('locked')and not layoutPreview);host:SetShown(M.Get('enabled')or preview or layoutPreview)
 for i,slot in ipairs(slots)do
  slot.frame:ClearAllPoints();slot.frame:SetSize(size,size)
  local offset=(i-1)*(size+gap)
  if dir==1 then slot.frame:SetPoint('LEFT',host,'LEFT',offset,0)
  elseif dir==2 then slot.frame:SetPoint('RIGHT',host,'RIGHT',-offset,0)
  elseif dir==3 then slot.frame:SetPoint('TOP',host,'TOP',0,-offset)
  else slot.frame:SetPoint('BOTTOM',host,'BOTTOM',0,offset)end
 end
end
local function Render()
 if not host then return end
 local n=M.Get('count')
 for i,slot in ipairs(slots)do
  ClearCooldown(slot)
  local e=history[i]
  slot.frame:SetShown(i<=n and(preview or layoutPreview or e~=nil))
  slot.badge:SetText('')
  if i<=n then
   if preview or layoutPreview then slot.tex:SetTexture(sample[(i-1)%#sample+1])
   elseif e then slot.tex:SetTexture(e.icon);slot.badge:SetText(e.hand and K.L('atHand'..e.hand)or'');Bind(slot,e)end
  end
 end
end
local function TrimHistory()
 while #history>M.Get('count')do local removed=table.remove(history);if candidate==removed then candidate=nil end end
end
local function Push(entry)
 table.insert(history,1,entry)
 -- Only the selected number of recent icons is kept. No growing spell cache.
 TrimHistory()
 if not preview and not layoutPreview then Render()end
end
function M.Clear()
 history={};candidate=nil;channel=nil
 if host then for _,s in ipairs(slots)do ClearCooldown(s)end end
 Render()
end
local function GCDReference(spellID)
 if not GetSpellBaseCooldown then return end
 local ok,own,global=pcall(GetSpellBaseCooldown,spellID)
 if ok and Number(own)and Number(global)then
  if own==0 and global>0 and not Secret(spellID)then gcdReference=spellID end
  return global>0
 end
end
local function Duration(id)
 if not C_Spell or not C_Spell.GetSpellCooldownDuration then return end
 local ok,d=pcall(C_Spell.GetSpellCooldownDuration,id)
 if not ok or Secret(d)or d==nil then return end
 if d.IsZero then
  local success,zero=pcall(d.IsZero,d)
  if success and not Secret(zero)and zero then return end
 end
 return d
end
local function UpdateGCD(fromCooldownEvent)
 local e=candidate
 -- A later unrelated cooldown cannot restart an old history icon.
 if not e or not M.Get('enabled')or not M.Get('gcd')or GetTime()-e.time>.35 then return end
 local eligible=e.gcdEligible
 if fromCooldownEvent and C_Spell and C_Spell.GetSpellCooldown then
  local ok,info=pcall(C_Spell.GetSpellCooldown,e.spellID)
  if ok and not Secret(info)and type(info)=='table'then
   local flag=info.isOnGCD
   if not Secret(flag)and type(flag)=='boolean'then eligible=flag end
  end
 end
 if eligible~=true then return end
 -- Only the dedicated GCD spell or a proven zero-own-CD reference is used.
 local d=Duration(61304)
 if not d and gcdReference then d=Duration(gcdReference)end
 if not d then return end
 e.duration=d;e.finished=nil
 if not preview and not layoutPreview then Render()end
end
local function PublicGUID(v)return not Secret(v)and type(v)=='string'and v~=''and v or nil end
local function ChannelStart(castGUID,spellID)
 channel=nil
 if not Number(spellID)then return end
 local guid=PublicGUID(castGUID)
 local last=history[1]
 channel={id=spellID,recorded=guid~=nil and last~=nil and last.guid==guid}
end
local function Spell(spellID,castGUID)
 if not C_Spell or not C_Spell.GetSpellTexture then return end
 -- Known autos have one authority: PLAYER_SWING, even when their option is off.
 if not Secret(spellID)and(spellID==6603 or spellID==75 or spellID==5019)then return end
 local sameChannel=channel and not Secret(spellID)and spellID==channel.id
 if sameChannel and channel.recorded then return end
 local ok,icon=pcall(C_Spell.GetSpellTexture,spellID)
 if not ok then return end
 if not Secret(icon)and icon==nil then return end
 local eligible
 if M.Get('gcd')then eligible=GCDReference(spellID)end
 local e={icon=icon,time=GetTime(),spellID=spellID,guid=PublicGUID(castGUID),gcdEligible=eligible}
 Push(e)
 if sameChannel then channel.recorded=true end
 if not M.Get('gcd')then return end
 if e.gcdEligible~=false then candidate=e end
 if e.gcdEligible==true then UpdateGCD(false)end
 if not queued then
  queued=true
  C_Timer.After(0,function()queued=false;UpdateGCD(false)end)
 end
end
local function Swing(_,swingType)
 -- Duration is intentionally never read: an event is not a predicted swing.
 if Secret(swingType)or not Number(swingType)then return end
 local types=Enum and Enum.PlayerSwingType
 if not types then return end
 local hand
 if swingType==types.MainHand then hand='Main'
 elseif swingType==types.OffHand then hand='Off'
 elseif swingType==types.Ranged then hand='Ranged'
 else return end
 if hand=='Ranged'and not M.Get('ranged')or hand~='Ranged'and not M.Get('melee')then return end
 -- Static icons avoid querying equipped weapons/auras every swing.
 Push({icon=hand=='Ranged'and 132222 or 132269,hand=hand,time=GetTime()})
end
function M.Refresh()
 events:UnregisterAllEvents()
 TrimHistory()
 if M.Get('enabled')then
  Ensure()
  events:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED','player')
  events:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START','player')
  events:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP','player')
  events:RegisterEvent('PLAYER_LEAVING_WORLD');events:RegisterEvent('SPELLS_CHANGED')
  if M.Get('melee')or M.Get('ranged')then events:RegisterEvent('PLAYER_SWING')end
  if M.Get('gcd')then events:RegisterEvent('SPELL_UPDATE_COOLDOWN')end
 else layoutPreview=false;M.Clear()end
 if preview or layoutPreview then Ensure();events:RegisterEvent('PLAYER_REGEN_DISABLED')end
 if host then Layout();Render()end
end
function M.Set(key,value)
 if Combat()or D[key]==nil or Secret(value)or type(value)~=type(D[key])then return false end
 if type(value)=='number'then
  local b=bounds[key];if not Number(value)or value<b[1]or value>b[2]or key~='alpha'and value~=math.floor(value)then return false end
 end
 Store(key,value)
 if key=='enabled'or key=='melee'or key=='ranged'then M.Clear()end
 if key=='gcd'and not value then candidate=nil;for _,e in ipairs(history)do e.duration=nil end end
 M.Refresh();return true
end
function M.Preview()
 if Combat()then return false end
 preview=not preview;Ensure();M.Refresh();return true
end
function M.IsPreview()return not not preview end
function M.SetLayoutPreview(value)
 if value and Combat()then return false end
 layoutPreview=value and M.Get('enabled')or false
 M.Refresh();return true
end
function M.SetPosition(x,y)
 if Combat()or not Number(x)or not Number(y)then return false end
 Store('x',math.max(-4000,math.min(4000,math.floor(x+.5))))
 Store('y',math.max(-2500,math.min(2500,math.floor(y+.5))))
 M.Refresh();return true
end
function M.ResetPosition()
 if Combat()then return false end
 Store('x',D.x);Store('y',D.y);M.Refresh();return true
end
events:RegisterEvent('PLAYER_LOGIN')
events:SetScript('OnEvent',function(_,event,unit,castGUID,spellID)
 if event=='PLAYER_LOGIN'then M.Refresh()
 elseif event=='PLAYER_REGEN_DISABLED'then preview=false;layoutPreview=false;M.Refresh()
 elseif event=='PLAYER_LEAVING_WORLD'then preview=false;layoutPreview=false;M.Clear()
 elseif event=='SPELLS_CHANGED'then gcdReference=nil;candidate=nil;channel=nil
 elseif event=='UNIT_SPELLCAST_CHANNEL_START'then ChannelStart(castGUID,spellID)
 elseif event=='UNIT_SPELLCAST_CHANNEL_STOP'then channel=nil
 elseif event=='UNIT_SPELLCAST_SUCCEEDED'then Spell(spellID,castGUID)
 elseif event=='PLAYER_SWING'then Swing(unit,castGUID)
 elseif event=='SPELL_UPDATE_COOLDOWN'then UpdateGCD(true)end
end)
function K.DrawActionTrackerPage(page)
 local w=K.CompactSettingsWidgets and K.CompactSettingsWidgets()or K.UnitWidgets
 local function Refresh()if K.window and K.window:IsShown()then K.Render()end end
 local available=not Combat()
 w.Text(page,K.L('atIntro'),8,0,698,13,{.65,.70,.62}):SetHeight(72)
 local function Toggle(key,label,y)
  local c=w.Box(page,0,y,714,62);w.Text(c,K.L(label),14,-12,565,14):SetHeight(38)
  w.Switch(c,M.Get(key),620,-17,function(v)M.Set(key,v)end,available)
 end
 Toggle('enabled','atEnable',-84)
 Toggle('gcd','atGCD',-158)
 Toggle('melee','atMelee',-232)
 Toggle('ranged','atRanged',-306)
 w.Text(page,K.L('atDirection'),8,-386,698,14)
 for i,key in ipairs({'atRight','atLeft','atDown','atUp'})do
  local dir=i
  local b=w.Button(page,K.L(key),(i-1)*182,-414,168,34,function()M.Set('direction',dir);Refresh()end)
  w.Selected(b,M.Get('direction')==i);if not available then b:Disable()end
 end
 local function NumberControl(key,label,x,y,step,percent)
  local c=w.Box(page,x,y,349,84);w.Text(c,K.L(label),14,-10,318,14)
  local value=M.Get(key);w.Text(c,string.format('%.0f%s',percent and value*100 or value,percent and' %'or''),14,-46,210,17)
  for i,delta in ipairs({-1,1})do
   local d=delta
   local b=w.Button(c,d<0 and'−'or'+',251+(i-1)*44,-42,36,30,function()M.Set(key,value+d*step);Refresh()end)
   if not available then b:Disable()end
  end
 end
 NumberControl('count','atCount',0,-466,1);NumberControl('size','atSize',365,-466,2)
 NumberControl('gap','atGap',0,-564,1);NumberControl('alpha','atAlpha',365,-564,.1,true)
 Toggle('locked','atLock',-662)
 local p=w.Button(page,K.L(M.IsPreview()and'atPreviewOff'or'atPreview'),0,-740,349,36,function()M.Preview();Refresh()end)
 local r=w.Button(page,K.L('atReset'),365,-740,349,36,function()M.ResetPosition()end)
 if not available then p:Disable();r:Disable()end
 local clear=w.Button(page,K.L('atClear'),0,-790,714,34,function()M.Clear()end)
 if not available then clear:Disable()end
 w.Text(page,K.L('atHelp'),8,-844,698,13,{.65,.70,.62}):SetHeight(110)
 w.Text(page,'Action Tracker '..M.version,8,-972,698,12,{.65,.70,.62})
 page:SetHeight(1010)
end
