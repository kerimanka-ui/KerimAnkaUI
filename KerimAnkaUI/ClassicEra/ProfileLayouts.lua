-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local L={};K.ProfileLayouts=L
local LIMIT=131072
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function Copy(value,depth,budget,seen)
 depth=depth or 0;budget=budget or {n=0,bytes=0};seen=seen or {}
 if issecretvalue and issecretvalue(value) then error('secret') end
 local kind=type(value);budget.n=budget.n+1
 if depth>24 or budget.n>16000 then error('limit') end
 if kind=='string' then budget.bytes=budget.bytes+#value;if budget.bytes>LIMIT then error('limit') end;return value end
 if kind=='number' then if value~=value or math.abs(value)>1e12 then error('number') end;return value end
 if kind=='boolean' or kind=='nil' then return value end
 if kind~='table' or seen[value] then error('data') end
 seen[value]=true;local result={}
 for key,item in pairs(value) do
  if type(key)~='string' and type(key)~='number' then error('key') end
  key=Copy(key,depth+1,budget,seen);result[key]=Copy(item,depth+1,budget,seen)
 end
 seen[value]=nil;return result
end
local function Safe(value) local ok,result=pcall(Copy,value);if ok then return result end end
local function Serializer() return K.Profiles and K.Profiles.LayoutSerializer end
local function Num(v,low,high) return type(v)=='number' and v==v and v>=low and v<=high end
local function SetupValid(s)
 if s==nil then return true end
 if type(s)~='table' then return false end
 for key in pairs(s) do if key~='bars' and key~='damage' and key~='personalResourceEnabled' and key~='preview' and key~='personalResourcePreview' and key~='nativeMeter' then return false end end
 if s.bars then
  if type(s.bars)~='table' or not Num(s.bars.n,0,8) or s.bars.n%1~=0 then return false end
  for i=1,s.bars.n do if type(s.bars[i])~='boolean' then return false end end
 end
 for _,key in ipairs({'damage','personalResourceEnabled'}) do if s[key]~=nil and s[key]~='0' and s[key]~='1' then return false end end
 for _,key in ipairs({'preview','personalResourcePreview'}) do
  local v=s[key]
  if v then
   local ids=Enum and Enum.EditModeAccountSetting
   local expected=ids and (key=='preview' and ids.ShowDamageMeter or ids.ShowPersonalResourceDisplay)
   if type(v)~='table' or not expected or v.setting~=expected or not Num(v.value,0,1) then return false end
  end
 end
 if s.nativeMeter then
  if type(s.nativeMeter)~='table' or type(s.nativeMeter.windows)~='table' then return false end
  for i,v in pairs(s.nativeMeter.windows) do
   if not Num(i,1,3) or i%1~=0 or type(v)~='table' or not Num(v.damageMeterType,0,100) or not Num(v.sessionType or 0,0,10) then return false end
   for _,key in ipairs({'shown','minimized','locked','nonInteractive'}) do if v[key]~=nil and type(v[key])~='boolean' then return false end end
   local g=v.geometry
   if g and (type(g)~='table' or (g.point~='BOTTOMLEFT' and g.point~='BOTTOMRIGHT') or not Num(g.x,-100000,100000) or not Num(g.y,-100000,100000) or not Num(g.width,1,10000) or not Num(g.height,1,10000)) then return false end
  end
 end
 return true
end
local function Valid(data)
 if type(data)~='table' or data.version~=1 then return false end
 local e,b=data.editMode,data.bartender
 if e and (type(e)~='table' or type(e.code)~='string' or #e.code<1 or #e.code>65536 or type(e.name)~='string' or #e.name>128 or type(e.kind)~='number') then return false end
 if b and (type(b)~='table' or type(b.profile)~='table' or type(b.namespaces)~='table' or type(b.name)~='string' or #b.name>128 or (b.configVersion~=nil and type(b.configVersion)~='number') or (b.project~=nil and type(b.project)~='number')) then return false end
 return SetupValid(data.setup)
end
function L.Encode(data)
 local value=Safe(data);if not value or not Valid(value) then return end
 local ser=Serializer();if not ser then return end
 local ok,code=pcall(ser.Serialize,ser,value)
 if ok and type(code)=='string' and #code<=LIMIT then return code end
end
function L.Decode(code)
 if type(code)~='string' or #code>LIMIT then return end
 local ser=Serializer();if not ser then return end
 local ok,success,data=pcall(ser.Deserialize,ser,code)
 if not ok or not success then return end
 data=Safe(data);if data and Valid(data) then return data end
end
local function BT()
 local bt=Bartender4
 if bt and bt.db and bt.db.GetCurrentProfile and bt.db.GetProfiles and bt.db.SetProfile and type(bt.db.profile)=='table' and type(Bartender4DB)=='table' then return bt end
end
local function CaptureBT()
 local bt=BT();if not bt then return end
 local data={name=bt.db:GetCurrentProfile(),profile=bt.db.profile,namespaces={},configVersion=bt.CONFIG_VERSION,project=WOW_PROJECT_ID}
 for name,child in pairs(bt.db.children or {}) do if type(child.profile)=='table' then data.namespaces[name]=child.profile end end
 return Safe(data)
end
function L.Capture(previous,runtime,phase)
 if Combat() or K.db.profileTransaction then return previous end
 local data=L.Decode(previous) or {version=1}
 local ready=K.FullLayout and K.FullLayout.SnapshotReady
 if phase~="login" and phase~="logout" and ready and ready() then
  local ok,value=pcall(K.FullLayout.Capture)
  if ok and value then data.editMode=Safe(value);data.captureVersion=2 end
  if K.ClassPresets and K.ClassPresets.CaptureProfileSetup then
   local good,setup=pcall(K.ClassPresets.CaptureProfileSetup)
   if good and setup then local clean=Safe(setup);if SetupValid(clean) then data.setup=clean end end
  end
 end
 local ok,bt=pcall(CaptureBT);if ok and bt then data.bartender=bt end
 if runtime then
  data.runtime=Safe({readyBartender=K.db.readyBartender,readyPresetLast=K.db.readyPresetLast,savedProfileBartender=K.db.savedProfileBartender})
 else data.runtime=nil end
 return L.Encode(data) or previous
end
local function Compatible(data)
 local bt=BT();if not bt then return true end
 if (data.project and WOW_PROJECT_ID and data.project~=WOW_PROJECT_ID) or (data.configVersion and bt.CONFIG_VERSION and data.configVersion>bt.CONFIG_VERSION) then return false end
 for name in pairs(data.namespaces) do if not (bt.db.children and bt.db.children[name]) then return false end end
 return true
end
local function Import(data,label)
 local bt=BT();if not bt then return false end
 if not Compatible(data) then error('incompatible Bartender profile') end
 local previous=bt.db:GetCurrentProfile();local base='KerimAnka Saved '..(label or 'Profile'):gsub('[%c|]',''):sub(1,36)
 local names={};local list={};bt.db:GetProfiles(list)
 for _,name in pairs(list) do names[name]=true end
 for name in pairs(Bartender4DB.profiles or {}) do names[name]=true end
 for _,ns in pairs(Bartender4DB.namespaces or {}) do for name in pairs(ns.profiles or {}) do names[name]=true end end
 local name=base;local suffix=2;while names[name] do name=base..' '..suffix;suffix=suffix+1 end
 local ok,err=pcall(function()
  Bartender4DB.profiles=Bartender4DB.profiles or {};Bartender4DB.profiles[name]=Copy(data.profile)
  Bartender4DB.namespaces=Bartender4DB.namespaces or {}
  for key,profile in pairs(data.namespaces) do
   local ns=Bartender4DB.namespaces[key] or {};Bartender4DB.namespaces[key]=ns
   ns.profiles=ns.profiles or {};ns.profiles[name]=Copy(profile)
  end
  bt.db:SetProfile(name)
  if bt.db:GetCurrentProfile()~=name then error('profile activation failed') end
  -- Position locking is separate from profile.buttonlock (spell dragging).
  if bt.Lock then bt:Lock()end
 end)
 if not ok then
  pcall(bt.db.SetProfile,bt.db,previous)
  if bt.db:GetCurrentProfile()~=name then
   Bartender4DB.profiles[name]=nil
   for _,ns in pairs(Bartender4DB.namespaces) do if ns.profiles then ns.profiles[name]=nil end end
  end
  error(err)
 end
 return name,previous
end
function L.Queue(record,label)
 if type(record)~='table' then return false,'pfInvalid' end
 local target=record.layouts and L.Decode(record.layouts)
 if record.layouts and not target then return false,'plInvalid' end
 if target and target.bartender and not Compatible(target.bartender) then return false,'plBTIncompatible' end
 local before=L.Capture(nil,true)
 if target then
  local backup=L.Decode(before)
  if not backup or (target.bartender and BT() and not backup.bartender) then return false,'pfFailed' end
 end
 local action=target and target.editMode and {mode=target.runtime and 'restore' or 'snapshot',target=target.editMode,setupRestore=target.setup} or nil
 local ok,err=K.Profiles.Apply(record.code,label or record.name,action)
 if not ok then return false,err end
 if target then
  local native=K.db.profileTransaction.fullLayout
  if native and native.before and native.before.restoreSlot then
   local backup=L.Decode(before)
   if not backup or not backup.editMode then K.Profiles.CancelPending();return false,'pfFailed' end
   backup.editMode.restoreSlot=Copy(native.before.restoreSlot)
   before=L.Encode(backup)
   if not before then K.Profiles.CancelPending();return false,'pfFailed' end
  end
  K.db.profileTransaction.savedLayouts={target=target,before=before,label=label or record.name}
 end
 return true,err
end
function L.Commit(transaction)
 local request=transaction.savedLayouts;if not request then return true end
 if Combat() then return false end
 local data=request.target
 if data.bartender then
  if BT() then
   local ok,name=pcall(Import,data.bartender,request.label)
   if not ok then
    local setup=transaction.fullLayout and transaction.fullLayout.setupBefore
    if setup and K.ClassPresets and K.ClassPresets.Restore then pcall(K.ClassPresets.Restore,setup)end
    return false
   end
   K.db.savedProfileBartender={status='applied',profile=name}
  else K.db.savedProfileBartender={status='pending',data=Copy(data.bartender),label=request.label} end
  -- A custom snapshot takes precedence over a previously queued ready preset.
  K.db.readyBartender=nil;K.db.readyPresetLast=nil
 end
 if data.runtime then
  K.db.readyBartender=Copy(data.runtime.readyBartender)
  K.db.readyPresetLast=Copy(data.runtime.readyPresetLast)
  K.db.savedProfileBartender=Copy(data.runtime.savedProfileBartender)
 end
 if K.db.profileBackup then K.db.profileBackup.layouts=request.before end
 return true
end
function L.TryDeferred()
 if Combat() or not K.db or K.db.profileTransaction then return end
 local state=K.db.savedProfileBartender
 if not state or state.status~='pending' or not BT() then return end
 local ok,name=pcall(Import,state.data,state.label)
 if ok then K.db.savedProfileBartender={status='applied',profile=name}
 else state.status='failed';if K.Message then K.Message('plBTFailed') end end
end
function L.Description(record)
 local data=record and L.Decode(record.layouts)
 if not data then return K.L('plLegacy') end
 local result=K.L(data.editMode and (data.bartender and 'plBoth' or 'plEdit') or data.bartender and 'plBT' or 'plLegacy')
 if data.editMode then result=result..'\n'..string.format(K.L('plNativeName'),data.editMode.name:gsub('|','||')) end
 return result
end
-- One deferred capture per native event, outside loading and logout teardown.
-- No ticker, frame polling, or protected Edit Mode manager mutation.
function L.ScheduleStable()
 local p=K.Profiles
 if p and p.ScheduleCheckpoint then p.ScheduleCheckpoint("stable") end
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','EDIT_MODE_LAYOUTS_UPDATED','ADDON_LOADED','PLAYER_REGEN_ENABLED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(_,event,addon)
 if event=='ADDON_LOADED' and addon~='Bartender4' then return end
 if C_Timer and C_Timer.After then C_Timer.After(0,L.TryDeferred) else L.TryDeferred() end
 if event~='ADDON_LOADED' then L.ScheduleStable() end
end)
if EventRegistry and EventRegistry.RegisterCallback then
 EventRegistry:RegisterCallback('EditMode.Exit',L.ScheduleStable,L)
end
