-- KerimAnka Bags: host boundary. No suite settings or feature engines are loaded.
local addonName,K=...
K.name=addonName;K.version='0.1.0-test5';K.blocked=true
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local function State(name)
 local api=C_AddOns;local info=api and api.GetAddOnInfo or GetAddOnInfo
 if info then local ok,v=pcall(info,name);if ok and not v then return false end end
 local get=api and api.GetAddOnEnableState or GetAddOnEnableState
 if not get then return nil end
 local who=UnitGUID and UnitGUID('player')or UnitName and UnitName('player')
 if type(who)~='string'or who==''then return nil end
 local ok,value
 if api and api.GetAddOnEnableState then ok,value=pcall(get,name,who)else ok,value=pcall(get,UnitName and UnitName('player'),name)end
 if ok and type(value)=='number'then return value>0 end
end
local reason
local suite=State('KerimAnkaUI')
if suite==true then reason='KerimAnka Bags is managed by the active KerimAnka UI suite. Use the suite Bags page, or disable the suite to use this independent edition.'
elseif suite==nil then reason='KerimAnka Bags could not determine the suite enable state. No bag hooks have been started.' end
if not reason and C_AddOns and C_AddOns.GetNumAddOns and C_AddOns.GetAddOnMetadata then
 for i=1,C_AddOns.GetNumAddOns()do
  local name=C_AddOns.GetAddOnInfo(i)
  if type(name)=='string'and name~=addonName and C_AddOns.GetAddOnMetadata(name,'X-KerimAnka-Independent')=='1'and State(name)==true then
   reason='Only one independent KerimAnka edition can run at a time Use the suite for multiple features.';break
  end
 end
end
if reason then
 K.blockReason=reason
 local f=CreateFrame('Frame');f:RegisterEvent('PLAYER_LOGIN')
 f:SetScript('OnEvent',function()
  if StaticPopupDialogs and StaticPopup_Show then
   StaticPopupDialogs.KERIMANKABAGS_HOST={text=reason,button1=OKAY or 'OK',timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
   StaticPopup_Show('KERIMANKABAGS_HOST')
  else print('|cffffcc66KerimAnka Bags:|r '..reason)end
 end)
 return
end
K.blocked=false
K.account=nil;K.db=nil;K.ready=false
function K.InCombat()return InCombatLockdown and InCombatLockdown()or false end
function K.Message(value)print('|cffffcc66KerimAnka Bags:|r '..(K.L and K.L(value)or tostring(value)))end
local init=CreateFrame('Frame');init:RegisterEvent('ADDON_LOADED')
init:SetScript('OnEvent',function(self,_,name)
 if name~=addonName then return end
 self:UnregisterEvent('ADDON_LOADED')
 KAClassic_KerimAnkaBagsDB=type(KAClassic_KerimAnkaBagsDB)=='table'and KAClassic_KerimAnkaBagsDB or{}
 KAClassic_KerimAnkaBagsCharacterDB=type(KAClassic_KerimAnkaBagsCharacterDB)=='table'and KAClassic_KerimAnkaBagsCharacterDB or{}
 K.account=KAClassic_KerimAnkaBagsDB;K.db=KAClassic_KerimAnkaBagsCharacterDB
 if not K.locales[K.account.language]then K.account.language='en'end
 -- Preserve the test2 panel placement while moving to the shared shell schema.
 if K.db.position==nil and type(K.account.panelPosition)=='table'then
  local p=K.account.panelPosition
  if type(p.x)=='number'and type(p.y)=='number'then K.db.position={x=p.x,y=p.y}end
 end
 K.db.bagTheme=nil;K.ready=true
 if K.Keyring then K.Keyring.ApplyDefault()end
end)
