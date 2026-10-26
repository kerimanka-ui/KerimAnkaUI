-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={};K.Keyring=M

-- Initialize only this character's native visibility preference. No button
-- Show/parent/layout calls: Blizzard handles its normal CVar update path.
-- The marker stays outside portable profiles, so ready layouts cannot reset it.
function M.ApplyDefault()
 if not K.db or K.db.keyringDefaultInitialized then return end
 if InCombatLockdown and InCombatLockdown() then return end
 if not (C_ActionBar and C_ActionBar.ShouldShowKeyring and C_ActionBar.ShouldShowKeyring()) then return end
 if not GetKeyRingSize or GetKeyRingSize()<=0 then return end
 local get=C_CVar and C_CVar.GetCVar or GetCVar
 local set=C_CVar and C_CVar.SetCVar or SetCVar
 if not get or not set then return end
 local ok,value=pcall(get,'showKeyring')
 if not ok or (value~='0' and value~='1') then return end
 if value=='0' then
  ok=pcall(set,'showKeyring','1');if not ok then return end
 end
 ok,value=pcall(get,'showKeyring')
 if ok and value=='1' then K.db.keyringDefaultInitialized=true end
end

local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_ENTERING_WORLD','SETTINGS_LOADED','PLAYER_REGEN_ENABLED','PLAYER_LEVEL_UP'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(self)
 M.ApplyDefault()
 if K.db and K.db.keyringDefaultInitialized then self:UnregisterAllEvents() end
end)
