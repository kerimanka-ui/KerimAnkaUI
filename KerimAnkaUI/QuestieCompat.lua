local _,K=...
local M={};K.QuestieCompat=M

local function Profile()
 local q=_G.Questie
 return type(q)=='table' and q.db and type(q.db.profile)=='table' and q.db.profile or nil
end
function M.Allowed()
 local db=K.db or KerimAnkaUICharacterDB
 return type(db)=='table' and db.questieTrackerAllowed==true or false
end
-- This compatibility preference stays outside portable layout snapshots.
-- Only a saved option is changed: never call Questie's Disable (ReloadUI),
-- tracker Update, WatchFrame hooks, or any Blizzard tracker/layout methods.
function M.ApplyStartup()
 if IsLoggedIn and IsLoggedIn() or InCombatLockdown and InCombatLockdown() then return false end
 local profile=Profile();if not profile then return false end
 profile.trackerEnabled=M.Allowed()
 return true
end
function M.SetAllowed(value)
 if type(value)~='boolean' or not K.db or InCombatLockdown and InCombatLockdown() then return false end
 K.db.questieTrackerAllowed=value
 local profile=Profile()
 if profile then profile.trackerEnabled=value end
 -- Existing hooks must be discarded by the user's normal reload button.
 M.pendingReload=true
 if K.Message then K.Message('qjQuestieReload') end
 return true
end

-- Questie is an OptionalDep, so its AceDB profile normally exists here,
-- before its PLAYER_LOGIN/OnEnable tracker initialization. The event handles
-- an unavailable database at initial evaluation, without timers or polling.
M.ApplyStartup()
local events=CreateFrame('Frame')
events:RegisterEvent('ADDON_LOADED');events:RegisterEvent('PLAYER_LOGIN')
events:SetScript('OnEvent',function(self,event,name)
 if event=='PLAYER_LOGIN' then self:UnregisterAllEvents();return end
 if name=='Questie' then M.ApplyStartup() end
end)
