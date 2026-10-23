local _,K=...
local M={};K.ClassPresets=M
local function Copy(v)
 if type(v)~='table' then return v end
 local result={};for k,x in pairs(v) do result[k]=Copy(x) end;return result
end
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function CurrentClass() return select(2,UnitClass('player')) end
function M.Get(class) return K.ReadyPresetData and K.ReadyPresetData[class or CurrentClass()] end
function M.Source() return KerimAnkaUIBarsAPI and KerimAnkaUIBarsAPI.BartenderActive() and 'bartender' or 'blizzard' end
local function GetVar() return C_CVar and C_CVar.GetCVar or GetCVar end
local function SetVar() return C_CVar and C_CVar.SetCVar or SetCVar end
local function Pack(...) return {n=select('#',...),...} end
local barRefresh
local function TryBarRefresh()
 local request=barRefresh;if not request or Combat() then return end
 if M.Source()=='bartender' then barRefresh=nil;return end
 local ready=Settings and Settings.GetSetting and Settings.NotifyUpdate
 if ready then
  ready=Settings.GetSetting('PROXY_SHOW_ACTIONBAR_2') and Settings.GetSetting('PROXY_SHOW_ACTIONBAR_3')
 end
 local current=Pack(GetActionBarToggles())
 for i=1,request.expected.n do
  if current[i]~=request.expected[i] then ready=false;break end
 end
 if ready then
  barRefresh=nil
  -- NotifyUpdate is Blizzard's path for changes made outside a setting object.
  -- It runs the normal visibility/tick/layout callbacks, even for an already
  -- checked setting. Do not Show protected frames or rewrite Edit Mode state.
  local ok,err=pcall(function()
   Settings.NotifyUpdate('PROXY_SHOW_ACTIONBAR_2')
   Settings.NotifyUpdate('PROXY_SHOW_ACTIONBAR_3')
  end)
  M.barRefreshError=not ok and tostring(err) or nil
  return
 end
 request.attempts=request.attempts+1
 if request.attempts>=20 then barRefresh=nil;return end
 if C_Timer and C_Timer.After then
  C_Timer.After(.25,function() if barRefresh==request then TryBarRefresh() end end)
 else barRefresh=nil end
end
function M.RefreshNativeBars(expected)
 barRefresh={expected=Copy(expected or Pack(GetActionBarToggles())),attempts=0}
 TryBarRefresh()
end
-- Native meter configuration belongs to the ready-layout transaction, not to
-- combat data. Only window choices and secondary-window geometry are copied.
local function NativeMeter()
 if not DamageMeter and C_AddOns and C_AddOns.LoadAddOn then pcall(C_AddOns.LoadAddOn,'Blizzard_DamageMeter') end
 local meter=DamageMeter
 if not meter then return end
 for _,method in ipairs({'GetSessionWindow','GetWindowDataList','CreateWindowData','SetupSessionWindow','HideSessionWindow','SetSessionWindowDamageMeterType','SetSessionWindowSessionID','SetSessionWindowMinimized'}) do
  if type(meter[method])~='function' then return end
 end
 return meter
end
local function Number(v) return type(v)=='number' and v==v and math.abs(v)<100000 end
local function Geometry(frame)
 if not frame then return end
 local x,y=frame:GetLeft(),frame:GetBottom()
 local scale=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
 local w,h=frame:GetWidth(),frame:GetHeight()
 if not (Number(x) and Number(y) and Number(w) and Number(h) and Number(scale) and scale>0) then return end
 return {point='BOTTOMLEFT',x=x*scale,y=y*scale,width=w*scale,height=h*scale}
end
local function CaptureMeter()
 local meter=NativeMeter();if not meter then return end
 local snapshot={windows={}}
 local saved=DamageMeterPerCharacterSettings and DamageMeterPerCharacterSettings.windowDataList or {}
 local live=meter:GetWindowDataList()
 for i=1,3 do
  local data=live[i] or saved[i]
  if data then
   local frame=meter:GetSessionWindow(i)
   local minimized=data.minimized
   if minimized==nil and saved[i] then minimized=saved[i].minimized end
   snapshot.windows[i]={damageMeterType=data.damageMeterType,sessionType=data.sessionType or 0,
    shown=frame and frame:IsShown() or false,minimized=minimized or false,
    locked=data.locked,nonInteractive=data.nonInteractive,
    geometry=i>1 and Geometry(frame) or nil}
  end
 end
 return snapshot
end
local function PlaceMeter(config)
 local meter=NativeMeter();if not meter then return false end
 for i=2,3 do
  local data=config.windows[i];local g=data and data.geometry
  if data and g then
   local frame=meter:GetSessionWindow(i);if not frame and data.shown then return false end
   if frame then
   local scale=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
   if not Number(scale) or scale<=0 then return false end
   frame:ClearAllPoints()
   frame:SetPoint(g.point,UIParent,g.point,g.x/scale,g.y/scale)
   frame:SetSize(g.width/scale,g.height/scale)
   frame:SetUserPlaced(true)
   end
  end
 end
 return true
end
local nativeWritePhase=false
local function ApplyMeter(config)
 if not nativeWritePhase then error('native meter setup is only allowed immediately before explicit reload') end
 local meter=NativeMeter();if not meter then error('native meter unavailable') end
 local live=meter:GetWindowDataList()
 for i=1,3 do
  local data=config.windows[i];local frame=meter:GetSessionWindow(i)
  if data and (data.shown or i==1) then
   if not frame then
    if live[i] then meter:SetupSessionWindow(i,live[i]) else meter:CreateWindowData(i) end
    frame=meter:GetSessionWindow(i)
   end
   if not frame then error('native meter window missing') end
   if not frame:IsShown() then frame:Show() end
   local current=live[i]
   if current.damageMeterType~=data.damageMeterType then meter:SetSessionWindowDamageMeterType(frame,data.damageMeterType) end
   if current.sessionType~=(data.sessionType or 0) or current.sessionID~=nil then meter:SetSessionWindowSessionID(frame,data.sessionType or 0,nil) end
   if meter.SetSessionWindowLocked and (current.locked==true)~=(data.locked==true) then meter:SetSessionWindowLocked(frame,data.locked==true) end
   if meter.SetSessionWindowNonInteractive and (current.nonInteractive==true)~=(data.nonInteractive==true) then meter:SetSessionWindowNonInteractive(frame,data.nonInteractive==true) end
   if (current.minimized==true)~=(data.minimized==true) then meter:SetSessionWindowMinimized(frame,data.minimized==true) end
  elseif i>1 and frame then meter:HideSessionWindow(frame) end
 end
 -- Persist only data. Never store frame objects, session IDs, or combat totals.
 local saved={}
 for i,data in pairs(config.windows) do
  saved[i]={damageMeterType=data.damageMeterType,sessionType=data.sessionType or 0,shown=data.shown,
   minimized=data.minimized,locked=data.locked,nonInteractive=data.nonInteractive}
 end
 DamageMeterPerCharacterSettings={windowDataList=saved}
 if not PlaceMeter(config) then error('native meter geometry unavailable') end
 -- Frame cache and window settings are saved by the reload which follows.
 -- Never queue a post-login native geometry/configuration pass.
end

function M.Capture()
 if Combat() then return nil,'combatLock' end
 local get=GetVar()
 if not get or not SetVar() or not GetActionBarToggles or not SetActionBarToggles then return nil,'readyUnavailable' end
 local result={source=M.Source(),bars=Pack(GetActionBarToggles()),damage=get('damageMeterEnabled')}
 result.savedProfileBartender=Copy(K.db.savedProfileBartender)
 result.readyBartenderCaptured=true
 result.readyBartender=Copy(K.db.readyBartender)
 result.readyPresetLast=Copy(K.db.readyPresetLast)
 result.nativeMeter=CaptureMeter()
 if M.Get() and M.Get().nativeMeter and not result.nativeMeter then return nil,'readyUnavailable' end
 if result.bars.n<2 or result.damage==nil then return nil,'readyUnavailable' end
 local id=Enum and Enum.EditModeAccountSetting and Enum.EditModeAccountSetting.ShowDamageMeter
 if id and C_EditMode and C_EditMode.GetAccountSettings then
  for _,v in ipairs(C_EditMode.GetAccountSettings() or {}) do if v.setting==id then result.preview={setting=id,value=v.value};break end end
 end
 -- Only presets which request this setting take ownership of its undo state.
 local preset=M.Get()
 if preset and preset.personalResourceDisplay then result.personalResourceEnabled=get('nameplateShowSelf') end
 local resourceID=preset and preset.personalResourceDisplay and Enum and Enum.EditModeAccountSetting and Enum.EditModeAccountSetting.ShowPersonalResourceDisplay
 if resourceID and C_EditMode and C_EditMode.GetAccountSettings then
  for _,v in ipairs(C_EditMode.GetAccountSettings() or {}) do
   if v.setting==resourceID then result.personalResourcePreview={setting=resourceID,value=v.value};break end
  end
 end
 local bt=_G.Bartender4
 if bt and bt.db and bt.db.GetCurrentProfile then result.btProfile=bt.db:GetCurrentProfile() end
 return result
end
-- Read only settings, never sessions/totals; never load the meter just to save a profile.
function M.CaptureProfileSetup()
 if Combat() then return end
 local get=GetVar();if not get or not GetActionBarToggles then return end
 local result={bars=Pack(GetActionBarToggles()),damage=get('damageMeterEnabled'),personalResourceEnabled=get('nameplateShowSelf')}
 if DamageMeter then result.nativeMeter=CaptureMeter() end
 local ids=Enum and Enum.EditModeAccountSetting
 if ids and C_EditMode and C_EditMode.GetAccountSettings then
  for _,value in ipairs(C_EditMode.GetAccountSettings() or {}) do
   if value.setting==ids.ShowDamageMeter then result.preview={setting=value.setting,value=value.value}
   elseif value.setting==ids.ShowPersonalResourceDisplay then result.personalResourcePreview={setting=value.setting,value=value.value} end
  end
 end
 return result
end
function M.Prepare(class)
 local data=M.Get(class)
 if class~=CurrentClass() or not data then return nil,'readyMissing' end
 local snapshot,err=M.Capture();if not snapshot then return nil,err end
 if snapshot.source=='bartender' then
  local bt=_G.Bartender4
  if not bt or not bt.db or not bt.db.SetProfile or not bt.db.children or not bt.db.children.ActionBars or type(Bartender4DB)~='table'
   or (bt.CONFIG_VERSION and data.bartender.configVersion>bt.CONFIG_VERSION)
   or (WOW_PROJECT_ID and data.bartender.project~=WOW_PROJECT_ID) then return nil,'readyBTUnavailable' end
 end
 return snapshot
end
local function Preview(value)
 if not value then return end
 -- A C API updates the native preference without calling manager layout Lua.
 if C_EditMode and C_EditMode.SetAccountSetting then C_EditMode.SetAccountSetting(value.setting,value.value) end
end
function M.Restore(snapshot)
 if Combat() or type(snapshot)~='table' then return false end
 local profile=snapshot.btProfile
 local deferred=K.db.readyBartender
 if not profile and snapshot.readyBartenderCaptured and deferred and deferred.status=='applied'
  and (not snapshot.readyBartender or snapshot.readyBartender.profile~=deferred.profile) then profile=deferred.previousProfile end
 if profile then
  local bt=_G.Bartender4
  if not bt or not bt.db or not bt.db.SetProfile then return false end
  local ok=pcall(bt.db.SetProfile,bt.db,profile);if not ok then return false end
 end
 if snapshot.bars and GetActionBarToggles and SetActionBarToggles then
  SetActionBarToggles(unpack(snapshot.bars,1,snapshot.bars.n))
  M.RefreshNativeBars(snapshot.bars)
 end
 local set=SetVar();if snapshot.damage~=nil and set then set('damageMeterEnabled',snapshot.damage) end
 if snapshot.personalResourceEnabled~=nil and set then set('nameplateShowSelf',snapshot.personalResourceEnabled) end
 Preview(snapshot.preview)
 Preview(snapshot.personalResourcePreview)
 if snapshot.readyBartenderCaptured then
  K.db.savedProfileBartender=Copy(snapshot.savedProfileBartender)
  K.db.readyBartender=Copy(snapshot.readyBartender)
  K.db.readyPresetLast=Copy(snapshot.readyPresetLast)
 end
 return true
end
local function ImportBartender(data,preset)
 local bt=_G.Bartender4
 local name='KerimAnka UI '..preset.name..' 1080';local base=name;local suffix=2
 local used={};bt.db:GetProfiles(used)
 local names={};for _,v in ipairs(used) do names[v]=true end
 -- Namespace-only profiles must also be treated as existing user data.
 for _,ns in pairs(Bartender4DB.namespaces or {}) do for key in pairs(ns.profiles or {}) do names[key]=true end end
 for key in pairs(Bartender4DB.profiles or {}) do names[key]=true end
 while names[name] do name=base..' '..suffix;suffix=suffix+1 end
 local previous=bt.db:GetCurrentProfile()
 local ok,err=pcall(function()
 Bartender4DB.profiles=Bartender4DB.profiles or {}
 Bartender4DB.profiles[name]=Copy(data.profile)
 Bartender4DB.namespaces=Bartender4DB.namespaces or {}
 for key,profile in pairs(data.namespaces) do
  if bt.db.children[key] then
   local ns=Bartender4DB.namespaces[key] or {};Bartender4DB.namespaces[key]=ns
   ns.profiles=ns.profiles or {};ns.profiles[name]=Copy(profile)
  end
 end
 bt.db:SetProfile(name)
 if bt.db:GetCurrentProfile()~=name then error('Bartender profile activation failed') end
 end)
 if not ok then
  pcall(bt.db.SetProfile,bt.db,previous)
  if bt.db:GetCurrentProfile()~=name then
   if Bartender4DB.profiles then Bartender4DB.profiles[name]=nil end
   for _,ns in pairs(Bartender4DB.namespaces or {}) do if ns.profiles then ns.profiles[name]=nil end end
  end
  error(err)
 end
 return name
end
function M.Commit(action)
 if Combat() then return false,'combatLock' end
 if action.setupRestore then
  if action.setupRestore.nativeMeter and not action.nativeMeterPrepared then return false,'readyMeterStageRequired' end
  local ok,result=pcall(M.Restore,action.setupRestore)
  if not ok or not result then return false,'readyApplyFailed' end
  return true
 end
 local data=M.Get(action.class)
 if not data or action.class~=CurrentClass() then return false,'readyMissing' end
 if data.nativeMeter and not action.nativeMeterPrepared then return false,'readyMeterStageRequired' end
 local before=action.setupBefore
 if not before then return false,'readyApplyFailed' end
 local imported
 local ok=pcall(function()
  if before.source=='bartender' then imported=ImportBartender(data.bartender,data) end
  -- Prepare the native fallback even while Bartender owns/hides its frames.
  -- Its saved preferences must survive disabling Bartender on the next reload.
  local bars=Copy(before.bars);bars[1]=true;bars[2]=true
  -- One call preserves bars 4-8 and avoids stale server-mirrored toggle masks.
  SetActionBarToggles(unpack(bars,1,bars.n))
  M.RefreshNativeBars(bars)
  SetVar()('damageMeterEnabled','1')
  -- The edit-mode checkbox is disabled while the actual display CVar is off.
  -- Use the normal CVar event path; never force-enable native controls.
  if data.personalResourceDisplay and before.personalResourceEnabled~=nil then SetVar()('nameplateShowSelf','1') end
  if before.preview then Preview({setting=before.preview.setting,value=1}) end
  if data.personalResourceDisplay and before.personalResourcePreview then Preview({setting=before.personalResourcePreview.setting,value=1}) end
 end)
 if not ok then pcall(M.Restore,before);return false,'readyApplyFailed' end
 K.db.savedProfileBartender=nil
 K.db.readyPresetLast={class=action.class,revision=data.revision,source=before.source}
 K.db.readyBartender={class=action.class,revision=data.revision,status=imported and 'applied' or 'pending',
  profile=imported,previousProfile=before.btProfile}

 return true
end
-- Saved character state is intentionally outside portable UI settings. It is
-- consumed once and never reapplies the other modules, native layout or meters.
function M.TryDeferredBartender()
 if not K.db or K.db.profileTransaction or K.db.savedProfileBartender or Combat() then return end
 local state=K.db.readyBartender
 if not state then
  -- Upgrade characters which already applied a ready layout without Bartender.
  local last=K.db.readyPresetLast
  if last and last.class==CurrentClass() and last.source=='blizzard' and M.Get(last.class) then
   state={class=last.class,revision=last.revision,status='pending'};K.db.readyBartender=state
  end
 end
 if not state or state.class~=CurrentClass() or state.status~='pending' or M.Source()~='bartender' then return end
 local data=M.Get(state.class);local bt=_G.Bartender4
 if not data or not bt or not bt.db or not bt.db.GetCurrentProfile or not bt.db.GetProfiles or not bt.db.SetProfile
  or not bt.db.children or not bt.db.children.ActionBars or type(Bartender4DB)~='table' then return end
 if (bt.CONFIG_VERSION and data.bartender.configVersion>bt.CONFIG_VERSION)
  or (WOW_PROJECT_ID and data.bartender.project~=WOW_PROJECT_ID) then return end
 local previous=bt.db:GetCurrentProfile()
 local ok,name=pcall(ImportBartender,data.bartender,data)
 if not ok then
  state.status='failed';M.deferredBartenderError=tostring(name)
  if K.Message then K.Message('readyBTDeferredFailed') end
  return false
 end
 state.status='applied';state.profile=name;state.previousProfile=previous;state.revision=data.revision
 return true
end
local deferredScheduled=false
local function ScheduleDeferredBartender()
 if deferredScheduled then return end
 if C_Timer and C_Timer.After then
  deferredScheduled=true
  C_Timer.After(0,function() deferredScheduled=false;M.TryDeferredBartender() end)
 else M.TryDeferredBartender() end
end

-- A reload/provider change must refresh the currently saved preferences, not
-- force bars back on after the user has intentionally unchecked them.
local barEvents=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','SETTINGS_LOADED','PLAYER_REGEN_ENABLED','ADDON_LOADED'}) do barEvents:RegisterEvent(event) end
barEvents:SetScript('OnEvent',function(_,event,addon)
 if event=='ADDON_LOADED' and addon~='Bartender4' then return end
 ScheduleDeferredBartender()
 if event=='PLAYER_REGEN_ENABLED' or event=='SETTINGS_LOADED' then TryBarRefresh()
 elseif barRefresh then TryBarRefresh()
 elseif K.db and not K.db.profileTransaction and K.db.readyPresetLast and K.db.readyPresetLast.class==CurrentClass() then
  M.RefreshNativeBars()
 end
end)
function M.Queue()
 if Combat() then return false,'combatLock' end
 if K.db.profileTransaction then return false,'pfQueued' end
 local class=CurrentClass();local data=M.Get(class)
 if not data then return false,'readyMissing' end
 local payload,err=K.Profiles.Decode(data.ui);if not payload then return false,err end
 -- A ready layout installs visuals, not the creator's audio preferences.
 -- Retain managed audio CVars too, so profile replacement cannot restore old
 -- originals over the recipient's current sound choices.
 local root=payload.settings.root
 root.cvars=root.cvars or {}
 for key in pairs(root.cvars) do
  if key:match('^Sound_') then root.cvars[key]=nil end
 end
 for key,value in pairs(K.db.cvars or {}) do
  if key:match('^Sound_') then root.cvars[key]=value end
 end
 root.sounds=Copy(K.db.sounds or {})
 root.muteClicks=K.db.muteClicks
 root.fps=Copy(K.db.fps or K.fpsDefaults)
 local audio=K.soundShortcutDefaults
 root.soundShortcut=Copy(K.db.soundShortcut or audio)
 root.soundShortcut.x=audio.x;root.soundShortcut.y=audio.y;root.soundShortcut.locked=audio.locked
 -- Keep both geometries and follow the available renderer after addon changes.
 -- Explicit manual source preferences remain available outside this preset.
 payload.settings.root.barSource=0
 payload.settings.root.hideNativeBagBar=true
 payload.settings.root.bagCombined=K.db.bagCombined
 if payload.settings.root.bagCombined==nil then payload.settings.root.bagCombined=true end
 local panel=K.panelDefaults
 payload.settings.root.position=Copy(panel.position)
 payload.settings.root.panelHeight=panel.height
 payload.settings.appearance.scale=panel.scale
 -- Ready Paladins start in their own faction palette, not the author's.
 if class=='PALADIN' and payload.settings.ForeverHunterArtCharacterDB then
  payload.settings.ForeverHunterArtCharacterDB.paladinSkin=UnitFactionGroup and UnitFactionGroup('player')=='Horde' and 2 or 1
 end
 -- Warrior's ready artwork follows the recipient's faction as a linked set.
 if class=='WARRIOR' and payload.settings.ForeverHunterArtCharacterDB then
  local art=payload.settings.ForeverHunterArtCharacterDB
  art.warriorSkin=UnitFactionGroup and UnitFactionGroup('player')=='Horde' and 2 or 1
  art.warriorAction=1
 end
 -- Ready layouts are safe to use immediately; every draggable widget starts locked.
 root.microLocked=true
 for _,key in ipairs({'fps','soundShortcut','bagShortcut','minimapButtons','experience'}) do
  if type(root[key])=='table' then root[key].locked=true end
 end
 for _,key in ipairs({'ForeverLeatherUnitsDB','ForeverThreatDB','ForeverHunterRangeDB','HunterAspectAlertCharacterDB'}) do
  if type(payload.settings[key])=='table' then payload.settings[key].locked=true end
 end
 local code;code,err=K.Profiles.Encode(payload);if not code then return false,err end
 return K.Profiles.Apply(code,'KerimAnka UI '..data.name..' 1920x1080',{mode='classPreset',class=class})
end
function M.Draw(page,w,y)
 local data=M.Get();if not data then return y end
 local box=w.Box(page,0,y,714,208)
 M.readyCard=box
 w.Text(box,K.L('ready'..data.name..'Title'),16,-14,680,17,{.87,.73,.40})
 local help=w.Text(box,K.L('ready'..data.name..'Help'),16,-46,680,13,{.65,.70,.62})
 w.Text(box,K.L(M.Source()=='bartender' and 'readyUsesBT' or 'readyUsesNative'),16,-118,680,13,{.87,.73,.40})
 -- Confirmation belongs to this visible card only. First click is cosmetic:
 -- no transaction, backup replacement, native preparation or reload yet.
 local armed=false
 local cancel
 local button=w.Button(box,K.L('readyApply'..data.name),16,-160,682,34,function(self)
  if Combat() or K.db.profileTransaction then return end
  if not armed then
   armed=true
   help:SetText(K.L('readyConfirmWarning'));help:SetTextColor(.94,.79,.41)
   self.label:SetText(K.L('readyConfirmApply'));self:SetWidth(510)
   cancel:Show();return
  end
  local ok,err=M.Queue()
  -- Keep the clicked button visible through the protected reload call.
  if ok then K.Reload() else M.status=err;if K.Message then K.Message(err) end;if K.Render then K.Render() end end
 end)
 local function Reset()
  armed=false
  help:SetText(K.L('ready'..data.name..'Help'));help:SetTextColor(.65,.70,.62)
  button.label:SetText(K.L('readyApply'..data.name));button:SetWidth(682)
  cancel:Hide()
 end
 cancel=w.Button(box,K.L('readyConfirmCancel'),538,-160,160,34,Reset)
 cancel:Hide()
 -- Settings widgets are pooled: replace this handler, never accumulate hooks.
 button:SetScript('OnHide',function() if armed then Reset() end end)
 if Combat() or K.db.profileTransaction then button:Disable() end
 if M.status then w.Text(page,K.L(M.status),8,y-220,690,13,{.87,.73,.40});return y-280 end
 return y-230
end

-- Invoked by K.Reload from an explicit user click, before the old UI is torn
-- down. The reloaded UI consumes native saved settings and is never configured
-- by our meter setup Lua. M.Queue remains a data-only, cancellable operation.
function M.PrepareReload()
 local transaction=K.db and K.db.profileTransaction
 local action=transaction and transaction.fullLayout
 if not action or action.nativeMeterPrepared then return true end
 if Combat() then return false,'combatLock' end
 local data=action.class and M.Get(action.class)
 local target=action.setupRestore and action.setupRestore.nativeMeter or data and data.nativeMeter
 if not target then return true end
 nativeWritePhase=true
 local ok,err=pcall(ApplyMeter,target)
 nativeWritePhase=false
 if not ok then
  local before=action.setupBefore and action.setupBefore.nativeMeter
  if before then nativeWritePhase=true;pcall(ApplyMeter,before);nativeWritePhase=false end
  M.meterPreparationError=tostring(err);return false,'readyMeterPrepareFailed'
 end
 action.nativeMeterPrepared=true;return true
end
function M.CancelPreparedReload()
 local transaction=K.db and K.db.profileTransaction
 local action=transaction and transaction.fullLayout
 if not action or not action.nativeMeterPrepared then return true end
 if Combat() then return false end
 local before=action.setupBefore and action.setupBefore.nativeMeter
 if before then
  nativeWritePhase=true;local ok=pcall(ApplyMeter,before);nativeWritePhase=false
  if not ok then return false end
 end
 action.nativeMeterPrepared=nil;return true
end
