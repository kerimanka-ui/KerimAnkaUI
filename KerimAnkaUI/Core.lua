local addonName, K = ...
K.ForeverInventoryRuntime=true
K.name, K.version = addonName, "0.40.1"
-- Final panel placement captured from Kerimankahan-Hantirt. These are panel
-- preferences, not the game's UI scale or any gameplay frame coordinates.
K.panelDefaults={scale=0.8721474221494858,height=819.36083984375,position={x=36.77588658330683,y=209.4805938205954}}
-- Sound shortcut position captured from Nosce-Temet near the minimap.
K.soundShortcutDefaults={enabled=true,locked=true,size=36,x=0.9051041920979818,y=0.9162963772578913}
K.modules = {
    {key="chat",addon="KerimAnkaUI_Chat",icon="Interface\\Icons\\INV_Misc_GroupLooking"},
    {key="backdrop", addon="KerimAnkaUI_BarBackdrop", icon="Interface\\Icons\\INV_Misc_Gear_01"},
    {key="art", addon="KerimAnkaUI_ClassArt", slash="FOREVERHUNTERART", icon="Interface\\Icons\\Ability_Hunter_BeastCall"},
    {key="units", addon="KerimAnkaUI_UnitFrames", slash="FOREVERLEATHERUNITS", icon="Interface\\Icons\\INV_Misc_GroupLooking"},
    {key="quests", addon="KerimAnkaUI_QuestJournal", slash="FOREVERQUESTJOURNAL", icon="Interface\\Icons\\INV_Misc_Book_09"},
    {key="details", addon="KerimAnkaUI_DetailsSkin", slash="DETAILS", args="options", icon="Interface\\Icons\\INV_Sword_04"},
    {key="range", addon="KerimAnkaUI_HunterRange", slash="FOREVERHUNTERRANGE", icon="Interface\\Icons\\Ability_Marksmanship", class="HUNTER"},
    {key="threat", addon="KerimAnkaUI_Threat", slash="FOREVERTHREAT", icon="Interface\\Icons\\Ability_Rogue_Feint"},
    {key="aspect", addon="KerimAnkaUI_AspectAlert", slash="HUNTERASPECTALERT", icon="Interface\\Icons\\Spell_Nature_RavenForm", class="HUNTER"},
}
K.soundOptions = {
    {key="soundMaster", cvar="Sound_EnableAllSound"},
    {key="speech", cvar="Sound_EnableErrorSpeech"},
    {key="music", cvar="Sound_EnableMusic"},
    {key="ambience", cvar="Sound_EnableAmbience"},
    {key="dialog", cvar="Sound_EnableDialog"},
    {key="effects", cvar="Sound_EnableSFX"},
    {key="pets", cvar="Sound_EnablePetSounds"},
    {key="background", cvar="Sound_EnableSoundWhenGameIsInBG"},
}
-- Every character owns a complete set, including enabled channels. No logout
-- writes are needed: the next character applies its own set at login.
local audioNames={}
for _,option in ipairs(K.soundOptions) do audioNames[option.cvar:lower()]=option.cvar end
local function AudioValue(value)
 if tostring(value)=='0' then return '0' elseif tostring(value)=='1' then return '1' end
end
local function AudioDefault(name)
 local getter=C_CVar and C_CVar.GetCVarDefault or GetCVarDefault
 if getter then local ok,value=pcall(getter,name);if ok and AudioValue(value) then return AudioValue(value) end end
 return name=='Sound_EnableSoundWhenGameIsInBG' and '0' or '1'
end
function K.ApplyCharacterAudio()
 if not K.db then return end
 K.db.cvars=K.db.cvars or {};K.db.originalCVars=K.db.originalCVars or {}
 K.audioReady=false
 local setter=C_CVar and C_CVar.SetCVar or SetCVar
 for _,name in pairs(audioNames) do
  local current=K.GetCVar(name)
  if current~=nil then
   local value=AudioValue(K.db.cvars[name]) or AudioValue(current) or AudioDefault(name)
   K.db.cvars[name]=value
   if K.db.originalCVars[name]==nil then K.db.originalCVars[name]=current end
   if setter and current~=value then pcall(setter,name,value) end
  end
 end
 if K.db.muteClicks==nil then K.db.muteClicks=false end
 K.audioReady=true
 if K.QueueSoundRefresh then K.QueueSoundRefresh()end
 if K.SoundShortcut then K.SoundShortcut.Refresh() end
end
function K.TrackCharacterAudio(name)
 if not K.audioReady or not K.db or type(name)~='string' then return end
 local canonical=audioNames[name:lower()];if not canonical then return end
 local value=AudioValue(K.GetCVar(canonical))
 if value then K.db.cvars[canonical]=value end
 if K.SoundShortcut then K.SoundShortcut.Refresh() end
end

K.errorSounds = {569772, 569773, 569774, 569775, 569776, 567407}
local muted, originalErrorEvent = {}, nil
local pendingModules = {}
function K.Message(key)
    print("|cffb6ce96KerimAnka UI:|r " .. K.L(key))
end
function K.InCombat()
    if InCombatLockdown() then K.Message("combatLock"); return true end
    return false
end
function K.GetCVar(name)
    local getter = C_CVar and C_CVar.GetCVar or GetCVar
    if not getter then return nil end
    local ok, value = pcall(getter, name)
    if ok and value ~= nil and value ~= "" then return value end
end
function K.SetCVar(name, value)
    -- Only these three ordinary sound switches are usable from the shortcut
    -- in combat. Layout and all other CVar changes retain their existing gate.
    if name~='Sound_EnableMusic' and name~='Sound_EnableAmbience' and name~='Sound_EnableAllSound' and K.InCombat() then return false end
    local previous = K.GetCVar(name)
    local setter = C_CVar and C_CVar.SetCVar or SetCVar
    if previous == nil or not setter then K.Message("unavailable"); return false end
    local ok = pcall(setter, name, tostring(value))
    local accepted = K.GetCVar(name)
    if not ok or accepted == nil or (tostring(value) ~= accepted and tonumber(value) ~= tonumber(accepted)) then
        K.Message("failed"); return false
    end
    if K.db.originalCVars[name] == nil then K.db.originalCVars[name] = previous end
    -- Keep the client's accepted value, rather than an unclamped requested value.
    K.db.cvars[name] = accepted
    return true
end
local errorGroups={
 cooldown={"ERR_ABILITY_COOLDOWN","ERR_SPELL_COOLDOWN","ERR_ITEM_COOLDOWN","SPELL_FAILED_NOT_READY","ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS","SPELL_FAILED_ANOTHER_IN_PROGRESS","SPELL_FAILED_SPELL_IN_PROGRESS"},
 range={"ERR_OUT_OF_RANGE","ERR_SPELL_OUT_OF_RANGE","SPELL_FAILED_OUT_OF_RANGE"},
 target={"ERR_NO_ATTACK_TARGET","ERR_INVALID_ATTACK_TARGET","ERR_GENERIC_NO_VALID_TARGETS","SPELL_FAILED_BAD_TARGETS","SPELL_FAILED_BAD_IMPLICIT_TARGETS","SPELL_FAILED_TARGETS_DEAD"},
 movement={"SPELL_FAILED_MOVING"},
 direction={"ERR_BADATTACKFACING","ERR_BADATTACKPOS","SPELL_FAILED_UNIT_NOT_INFRONT","SPELL_FAILED_LINE_OF_SIGHT"},
 resources={"ERR_OUT_OF_MANA","ERR_OUT_OF_FOCUS","ERR_OUT_OF_ENERGY","ERR_OUT_OF_RAGE","ERR_OUT_OF_COMBO_POINTS","SPELL_FAILED_NO_POWER"},
 important={"ERR_INV_FULL","ERR_BANK_FULL","ERR_BAG_FULL","ERR_QUEST_FAILED_BAG_FULL_S","ERR_QUEST_LOG_FULL","ERR_QUEST_PUSH_LOG_FULL_S","ERR_NOT_ENOUGH_MONEY","ERR_BANKSLOT_INSUFFICIENT_FUNDS","ERR_BANKSLOT_FAILED_TOO_MANY","ERR_BANKSLOT_NOTBANKER","ERR_QUEST_FAILED_NOT_ENOUGH_MONEY","ERR_ITEM_MAX_COUNT","ERR_ITEM_MAX_COUNT_EQUIPPED","ERR_ITEM_MAX_COUNT_SOCKETED","ERR_QUEST_FAILED_MAX_COUNT_S","ERR_NOT_IN_COMBAT","ERR_AFFECTING_COMBAT","SPELL_FAILED_AFFECTING_COMBAT","SPELL_FAILED_TARGET_AFFECTING_COMBAT","SPELL_FAILED_TARGET_IN_COMBAT","ERR_EQUIPMENT_MANAGER_COMBAT_SWAP_S"},
}
local ids,texts,errorNames={},{},{};local errorRelay
local function BuildErrorFilter()
 ids={};texts={};errorNames={}
 for group,names in pairs(errorGroups) do
  for _,name in ipairs(names) do
   errorNames[name]=group
   local id=_G["LE_GAME_"..name];if type(id)=="number" then ids[id]=group end
   local value=_G[name]
   if type(value)=="string" and value~="" and not value:find("%%") then texts[value]=group end
  end
 end
end
function K.ErrorMode()
 if not K.db or not K.db.hideErrors then return 1 end
 return K.db.errorMode==3 and 3 or 2
end
function K.ErrorShouldShow(id,message)
 local mode=K.ErrorMode();if mode==1 then return true end
 if issecretvalue and (issecretvalue(id) or issecretvalue(message)) then return mode==3 end
 local group=(type(id)=="number" and ids[id]) or (type(message)=="string" and texts[message])
 if not group and type(id)=="number" and GetGameMessageInfo then
  local name=GetGameMessageInfo(id);group=name and errorNames[name]
  if group then ids[id]=group end
 end
 if mode==2 then return group=="important" and K.db.keepImportantErrors~=false end
 if not group or group=="important" then return true end
 return K.db.errorFilters and K.db.errorFilters[group]==false or false
end
local function OnFilteredError(_,event,id,message,...)
 if not K.db or not K.db.hideErrors or not UIErrorsFrame or UIErrorsFrame:IsEventRegistered(event) then return end
 if not K.ErrorShouldShow(id,message) then return end
 local handler=UIErrorsFrame:GetScript("OnEvent");if handler then handler(UIErrorsFrame,event,id,message,...) end
end
function K.SetErrors(hidden)
 if K.InCombat() then return false end
 if not UIErrorsFrame then K.Message("unavailable");return false end
 if originalErrorEvent==nil then originalErrorEvent=UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE") end
 K.db.hideErrors=hidden==true;BuildErrorFilter()
 if not errorRelay then errorRelay=CreateFrame("Frame");errorRelay:SetScript("OnEvent",OnFilteredError) end
 if hidden then
  UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");errorRelay:RegisterEvent("UI_ERROR_MESSAGE")
 else
  errorRelay:UnregisterEvent("UI_ERROR_MESSAGE")
  UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
 end
 return true
end
function K.SetErrorMode(mode)
 if K.InCombat() or not K.db or (mode~=1 and mode~=2 and mode~=3) then return false end
 K.db.errorMode=mode;return K.SetErrors(mode~=1)
end
function K.SetErrorGroup(key,hide)
 if K.InCombat() or not K.db or not errorGroups[key] or key=="important" then return false end
 K.db.errorFilters=K.db.errorFilters or {};K.db.errorFilters[key]=hide==true
 return K.SetErrors(K.db.hideErrors)
end
function K.SetImportantErrors(value)
 if K.InCombat() or not K.db then return false end
 K.db.keepImportantErrors=value==true;return K.SetErrors(K.db.hideErrors)
end

local function DesiredSounds()
    local desired = {}
    if K.db.muteClicks then for _, id in ipairs(K.errorSounds) do desired[id] = true end end
    for id, enabled in pairs(K.db.sounds) do
        if enabled and type(id) == "number" and id > 0 and id == math.floor(id) then desired[id] = true end
    end
    return desired
end
function K.ApplySounds()
    if not MuteSoundFile or not UnmuteSoundFile then return false end
    local desired = DesiredSounds()
    -- Reconcile overlapping presets/custom entries before unmuting anything.
    local applied=true
    for id in pairs(muted) do
        if not desired[id] then
            local ok,result=pcall(UnmuteSoundFile,id)
            if ok and result~=false then muted[id]=nil else applied=false end
        end
    end
    for id in pairs(desired) do
        local ok,result=pcall(MuteSoundFile,id)
        muted[id]=(ok and result~=false) or nil
        if not muted[id] then applied=false end
    end
    return applied
end
-- File mute requests can be lost when the client reinitializes audio.
-- Coalesce explicit audio changes; no ticker and no CVar writes here.
local soundRefreshQueued=false
function K.QueueSoundRefresh()
 if soundRefreshQueued or not K.audioReady or not K.db then return end
 if not C_Timer or not C_Timer.After then return end
 soundRefreshQueued=true
 C_Timer.After(0,function()
  soundRefreshQueued=false
  if K.audioReady and K.db then K.ApplySounds()end
 end)
end
function K.CustomSoundState(id)
    if not MuteSoundFile or not UnmuteSoundFile then return "soundMuteUnavailable" end
    -- This reports our setting/API request, not proof that every related sound is silent.
    return muted[id] and "soundMuteActive" or "soundMuteFailed"
end
function K.SetClicks(enabled)
    if not MuteSoundFile or not UnmuteSoundFile then K.Message("unavailable"); return false end
    K.db.muteClicks = enabled
    return K.ApplySounds()
end
function K.AddSounds(text)
    if not MuteSoundFile or not UnmuteSoundFile then K.Message("unavailable"); return false end
    if text:match("[^%d%s,]") then K.Message("invalidIds"); return false end
    local additions, count, any = {}, 0, false
    for id in pairs(K.db.sounds) do additions[id] = true; count = count + 1 end
    for token in text:gmatch("%d+") do
        local id = tonumber(token)
        if not id or id < 1 or id > 2147483647 or id ~= math.floor(id) then K.Message("invalidIds"); return false end
        if not additions[id] then additions[id] = true; count = count + 1 end
        any = true
    end
    if not any or count > 30 then K.Message("invalidIds"); return false end
    K.db.sounds = additions
    K.ApplySounds()
    return true
end
function K.RemoveSound(id)
    K.db.sounds[id] = nil
    K.ApplySounds()
end
function K.StopPreview()
    if K.previewHandle and StopSound then pcall(StopSound, K.previewHandle) end
    K.previewHandle = nil
end
function K.PreviewSound(id)
    if not PlaySoundFile or not MuteSoundFile or not UnmuteSoundFile then K.Message("unavailable"); return false end
    K.StopPreview()
    -- Listen must also work for catalog files outside our custom mute list.
    -- A file may already be muted by an earlier request or another sound addon.
    local unmuted,result=pcall(UnmuteSoundFile,id)
    if not unmuted or result==false then K.Message("previewFail"); return false end
    local ok,played,handle=pcall(PlaySoundFile,id,"Master")
    -- Always restore the requested mute, including when playback throws or is declined.
    local restored=K.ApplySounds()
    if ok and played then K.previewHandle=handle else K.Message("previewFail"); return false end
    if not restored then K.Message("soundMuteFailed") end
    return restored
end
function K.TestSoundMute(id)
    K.StopPreview()
    if not PlaySoundFile then return "soundMuteUnavailable" end
    -- Unlike Listen, this must not unmute or reapply first: test the existing state.
    local ok,played,handle=pcall(PlaySoundFile,id,"Master")
    if not ok then return "previewFail" end
    if played then K.previewHandle=handle;return "soundTestPlayed" end
    -- Silence alone cannot distinguish a mute from a disabled channel/missing file.
    return "soundTestSilent"
end

function K.Restore()
    if K.InCombat() then return end
    local setter = C_CVar and C_CVar.SetCVar or SetCVar
    for name, value in pairs(K.db.originalCVars) do
        if setter and pcall(setter, name, value) and K.GetCVar(name) == tostring(value) then
            K.db.cvars[name], K.db.originalCVars[name] = nil, nil
        end
    end
    K.SetErrors(false)
    K.db.muteClicks, K.db.sounds = false, {}
    K.ApplySounds()
    K.StopPreview()
    if K.Render then K.Render() end
end
local function AddonAPI(name)
    return C_AddOns and C_AddOns[name] or _G[name]
end
-- Always pass a scalar identity. Never omit it: omission affects all characters.
local function CharacterIdentity(modern)
    local identity
    if modern and UnitGUID then identity=UnitGUID("player") end
    if type(identity)~="string" or identity=="" then
        local getName=UnitNameUnmodified or UnitName
        if getName then identity=getName("player") end
    end
    if type(identity)=="string" and identity~="" then return identity end
end
local function ReadModuleEnabled(name)
    local modern=C_AddOns and C_AddOns.GetAddOnEnableState
    local getter=modern or GetAddOnEnableState
    local character=CharacterIdentity(modern~=nil)
    if not getter or not character then return nil,"enable-state API or character identity unavailable" end
    local ok,value
    if modern then ok,value=pcall(getter,name,character)
    else ok,value=pcall(getter,character,name) end
    if not ok then return nil,tostring(value) end
    if type(value)~="number" then return nil,"unexpected enable state: "..tostring(value) end
    return value>0,"state="..tostring(value)
end
function K.ModuleState(module)
    local info=AddonAPI("GetAddOnInfo")
    local exists=false
    if info then
        local ok,name=pcall(info,module.addon)
        exists=ok and type(name)=="string" and name~=""
    end
    if not exists then return false,false,false end
    local enabled,detail=ReadModuleEnabled(module.addon)
    local loaded=false
    local isLoaded=AddonAPI("IsAddOnLoaded")
    if isLoaded then local ok,value=pcall(isLoaded,module.addon); loaded=ok and (value==true or value==1) end
    return true,enabled,loaded,detail
end
function K.ModuleApplicable(module)
    return not module.class or select(2,UnitClass("player"))==module.class
end
local featureDB={backdrop="ForeverBarBackdropCharacterDB",art="ForeverHunterArtCharacterDB",units="ForeverLeatherUnitsDB",quests="ForeverQuestJournalDB",range="ForeverHunterRangeDB",threat="ForeverThreatDB",aspect="HunterAspectAlertCharacterDB"}
function K.VisibleModules()
    local visible={}
    for _,module in ipairs(K.modules) do if K.ModuleApplicable(module) then visible[#visible+1]=module end end
    return visible
end
function K.ModuleStatus(module)
    local exists,enabled,loaded=K.ModuleState(module)
    if not exists then return "missing" end
    if not K.ModuleApplicable(module) then return "hunterOnly" end
    if enabled==nil then return "addonStateUnknown" end
    local pending=pendingModules[module.addon]
    if pending~=nil and pending==enabled and enabled~=loaded then return enabled and "pendingOn" or "pendingOff" end
    if not enabled then return "disabled" end
    if not loaded then return "notLoaded" end
    local settings=_G[featureDB[module.key] or ""]
    if module.key=="quests" and type(settings)=="table" then return settings.scrollEnabled==false and "featureOff" or "loaded" end
    if type(settings)=="table" and settings.enabled==false then return "featureOff" end
    return "loaded"
end
function K.HasPendingModuleChanges(forProfile)
    for _,module in ipairs(K.modules) do
        local desired=pendingModules[module.addon]
        -- Disabling a module for another class is completed by the profile's
        -- own reload. It cannot affect this character's profile initialization.
        -- All enables and all applicable module changes still require settling.
        if desired~=nil and (not forProfile or desired or K.ModuleApplicable(module)) then
            local exists,enabled,loaded=K.ModuleState(module)
            if exists and enabled==desired and enabled~=loaded then return true end
        end
    end
    return false
end
function K.PendingModuleNames()
    local names={}
    for _,module in ipairs(K.modules) do
        local desired=pendingModules[module.addon]
        if desired~=nil then
            local exists,enabled,loaded=K.ModuleState(module)
            if exists and enabled==desired and enabled~=loaded then names[#names+1]=K.L(module.key) end
        end
    end
    return table.concat(names,", ")
end
local moduleChanging={}
local function ModuleFailure(module,step,detail)
    local message=module.addon.." · "..step..": "..tostring(detail)
    K.lastAddonError=message
    print("|cffb6ce96KerimAnka UI:|r "..K.L("addonChangeFailed").." "..message)
    if K.window and K.window:IsShown() then K.Render() end
end
function K.ToggleModule(module, enabled, quiet)
    if K.InCombat() then return end
    if enabled and not K.ModuleApplicable(module) then K.Message("hunterOnlyHelp"); return end
    if moduleChanging[module.addon] then if not quiet then K.Message("addonChanging") end; return end
    local action=enabled and "EnableAddOn" or "DisableAddOn"
    local modern=C_AddOns and C_AddOns[action]
    local setter=modern or _G[action]
    local character=CharacterIdentity(modern~=nil)
    if not setter or not character then ModuleFailure(module,action,"API or character identity unavailable"); return end
    local exists=K.ModuleState(module)
    if not exists then K.Message("missing"); return end
    moduleChanging[module.addon]=true
    local ok,err=pcall(setter,module.addon,character)
    if not ok then moduleChanging[module.addon]=nil; ModuleFailure(module,action,err); return end
    local save=AddonAPI("SaveAddOns")
    if save then
        local saved,saveError=pcall(save)
        if not saved then moduleChanging[module.addon]=nil; ModuleFailure(module,"SaveAddOns",saveError); return end
    end
    local function Verify(retry)
        local accepted,detail=ReadModuleEnabled(module.addon)
        if accepted~=enabled and retry then C_Timer.After(.1,function() Verify(false) end); return end
        moduleChanging[module.addon]=nil
        if accepted~=enabled then
            ModuleFailure(module,"verify",(enabled and "requested=on; " or "requested=off; ")..tostring(detail))
            if K.window and K.window:IsShown() then K.Render() end
            return
        end
        pendingModules[module.addon]=enabled
        K.lastAddonError=nil
        if quiet and K.HasPendingModuleChanges() and not K.classReloadNotice then
            K.classReloadNotice=true; K.Message("classChanged")
        end
        if not quiet then K.Message(enabled and "pendingOn" or "pendingOff") end
        if K.window and K.window:IsShown() then K.Render() end
        if not quiet and K.HasPendingModuleChanges() and K.ShowReloadPrompt then K.ShowReloadPrompt() end
    end
    -- Save first, then verify after the client has processed the loading preference.
    C_Timer.After(0,function() Verify(true) end)
end
function K.OpenModule(module)
    if module.key~="details" then K.ShowPage(module.key); return end
    if K.InCombat() then return end
    local _, _, loaded = K.ModuleState(module)
    if not K.ModuleApplicable(module) then K.Message("hunterOnlyHelp"); return end
    local command = module.slash and SlashCmdList[module.slash]
    if not loaded or not command then K.Message("moduleError"); return end
    K.window:Hide()
    local ok = pcall(command, module.args or "")
    if not ok then K.window:Show(); K.Message("moduleError") end
end
function K.Reload()
    if K.InCombat() then K.Message("combatLock");return false end
    -- Explicit user click only. Profile preparation never calls this function.
    local reload=C_UI and C_UI.Reload or ReloadUI
    if type(reload)~="function" then K.Message("pfManualReload");return false end
    if K.ClassPresets and K.ClassPresets.PrepareReload then
        local prepared,err=K.ClassPresets.PrepareReload()
        if not prepared then K.Message(err or "readyMeterPrepareFailed");return false end
    end
    local ok=pcall(reload)
    if not ok then
        if K.ClassPresets and K.ClassPresets.CancelPreparedReload then K.ClassPresets.CancelPreparedReload() end
        K.Message("pfManualReload")
    end
    -- Keep any queued transaction and undo backup intact if reload is denied.
    return ok
end
local function Initialize()
    KerimAnkaUIDB = type(KerimAnkaUIDB) == "table" and KerimAnkaUIDB or {}
    if not K.locales[KerimAnkaUIDB.language] then KerimAnkaUIDB.language = "en" end
    KerimAnkaUICharacterDB = type(KerimAnkaUICharacterDB) == "table" and KerimAnkaUICharacterDB or {}
    K.db = KerimAnkaUICharacterDB
    K.db.readyMeterPlacement=nil -- old post-login native geometry request is retired
    K.db.cvars = K.db.cvars or {}
    K.db.originalCVars = K.db.originalCVars or {}
    if K.Keyring then K.Keyring.ApplyDefault() end
    K.db.sounds = K.db.sounds or {}
    KerimAnkaUIDB.minimap = KerimAnkaUIDB.minimap or {minimapPos=220}
    local setter = C_CVar and C_CVar.SetCVar or SetCVar
    if setter then for name, value in pairs(K.db.cvars) do if not audioNames[name:lower()] and K.GetCVar(name) then pcall(setter, name, value) end end end
    K.ApplyCharacterAudio()
    if K.db.hideErrors then K.SetErrors(true) end
    K.ApplySounds()
    for _,module in ipairs(K.modules) do
        if not K.ModuleApplicable(module) then
            local exists,enabled=K.ModuleState(module)
            if exists and enabled then
                K.ToggleModule(module,false,true)
            end
        end
    end
    K.BuildWindow()
    K.CreateLauncher()
    if K.SoundShortcut then K.SoundShortcut.Refresh() end
    if K.FPS then K.FPS.Refresh() end
end
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("CVAR_UPDATE")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, event, name)
    if event=="CVAR_UPDATE" then
        K.TrackCharacterAudio(name)
        if type(name)=='string'and audioNames[name:lower()]then K.QueueSoundRefresh()end
    elseif event=="PLAYER_ENTERING_WORLD"then K.QueueSoundRefresh()end
    if event == "PLAYER_LOGIN" then Initialize()
    elseif K.window and K.window:IsShown() then
        if not K.refreshPending then
            K.refreshPending = true
            C_Timer.After(0, function()
                K.refreshPending = false
                if K.window:IsShown() then K.Render() end
            end)
        end
    end
end)
SLASH_KERIMANKAUI1, SLASH_KERIMANKAUI2 = "/kaui", "/kerimanka"
SlashCmdList.KERIMANKAUI = function(input)
    if not K.window then return end
    if input:lower():match("^%s*profiletest%s*$") then
        local ok=pcall(K.Profiles.SelfTest)
        K.Message(ok and "pfTestOK" or "pfFailed")
        return
    end
    if input:lower():match("^%s*center%s*$") then K.CenterWindow(); K.window:Show()
    else K.window:SetShown(not K.window:IsShown()) end
end

-- Published before children initialize; legacy entry points route into this hub.
KerimAnkaUIAPI={GetChatHost=function()return K end,version=1,OpenPage=function(key) if K.ShowPage then K.ShowPage(key) end end}

-- Stage2 separate profile engine.
K.InstallProfileEngine()

-- Blizzard action bar statue visibility.
-- Core feature: independent of Class Art, Bartender and any action-button layout.
do
local regions={}
local writing=false
local poll
local function Track(region)
    if not region or regions[region] or type(region.SetAlpha)~="function" or type(region.GetAlpha)~="function" then return end
    local state={alpha=region:GetAlpha(),hidden=false}
    regions[region]=state
    hooksecurefunc(region,"SetAlpha",function(self,alpha)
        if writing then return end
        state.alpha=alpha
        if state.hidden and not InCombatLockdown() then
            writing=true;self:SetAlpha(0);writing=false
        end
    end)
end
local function Discover()
    -- Original Classic end caps and Bartender's optional replicas.
    for _,name in ipairs({"MainMenuBarLeftEndCap","MainMenuBarRightEndCap","BlizzardArtLeftCap","BlizzardArtRightCap"}) do Track(_G[name]) end
    -- Modern Blizzard layouts (also used by newer Classic clients).
    for _,name in ipairs({"MainActionBar","MainMenuBar","MainMenuBarArtFrame"}) do
        local bar=_G[name]
        if bar then
            Track(bar.LeftEndCap);Track(bar.RightEndCap)
            if bar.EndCaps then Track(bar.EndCaps.LeftEndCap);Track(bar.EndCaps.RightEndCap) end
            if bar.ArtFrame then Track(bar.ArtFrame.LeftEndCap);Track(bar.ArtFrame.RightEndCap) end
        end
    end
end
function K.ApplyActionBarStatues()
    if not K.db then return end
    if InCombatLockdown() then
        if poll then poll:Cancel();poll=nil end
        return
    end
    local hide=K.db.hideActionBarStatues==true
    -- No work or hooks until this character actually uses the feature.
    if hide then Discover() end
    for region,state in pairs(regions) do
        state.hidden=hide
        local alpha=hide and 0 or state.alpha
        if region:GetAlpha()~=alpha then
            writing=true;region:SetAlpha(alpha);writing=false
        end
    end
    -- Bounded lookup only while enabled, to catch artwork created later by Edit
    -- Mode or an optional addon. No action-button iteration or per-frame work.
    if hide and not poll then poll=C_Timer.NewTicker(1,K.ApplyActionBarStatues)
    elseif not hide and poll then poll:Cancel();poll=nil end
end
function K.SetActionBarStatues(hide)
    if not K.db or InCombatLockdown() or type(hide)~="boolean" then return false end
    K.db.hideActionBarStatues=hide
    K.ApplyActionBarStatues()
    return true
end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED","ADDON_LOADED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",function() K.ApplyActionBarStatues() end)
end

-- Action bar source discovery (shared with optional artwork modules).
-- Native/Bartender discovery and decorative layout views. Does not own action slots,
-- bindings, secure button attributes, page drivers or Edit Mode layout data.
do
local A={}
KerimAnkaUIBarsAPI=A
local native={
 {prefix="ActionButton",frame="MainActionBar"},
 {prefix="MultiBarBottomLeftButton",frame="MultiBarBottomLeft"},
 {prefix="MultiBarBottomRightButton",frame="MultiBarBottomRight"},
 {prefix="MultiBarRightButton",frame="MultiBarRight"},
 {prefix="MultiBarLeftButton",frame="MultiBarLeft"},
 {prefix="MultiBar5Button",frame="MultiBar5"},
 {prefix="MultiBar6Button",frame="MultiBar6"},
 {prefix="MultiBar7Button",frame="MultiBar7"},
}
local cache=setmetatable({},{__mode="k"})
local geometry={bars=true,locked=true,width=true,height=true,x=true,y=true,gap=true}
local defaults={width=100,height=100,x=0,y=0,gap=4}
local function Root() return K.db or KerimAnkaUICharacterDB or {} end
function A.BartenderActive()
 local bt=_G.Bartender4
 if bt then
  if bt.IsEnabled then local ok,on=pcall(bt.IsEnabled,bt);if ok and not on then return false end end
  -- Bartender can leave Blizzard bars detached even if a bar module is disabled.
  if bt.UIHider then return true end
  if bt.GetModule then
   local ok,mod=pcall(bt.GetModule,bt,"ActionBars",true)
   if ok and mod and mod.IsEnabled then local yes,on=pcall(mod.IsEnabled,mod);if yes then return on==true end end
  end
 end
 local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 return loaded and loaded("Bartender4") and _G.BT4Button1~=nil or false
end
function A.Preference()
 local v=Root().barSource
 return (v==1 or v==2) and v or 0
end
function A.Resolve()
 local preference=A.Preference();local bt=A.BartenderActive()
 local source=preference==1 and "blizzard" or preference==2 and "bartender" or bt and "bartender" or "blizzard"
 local blocked=source=="blizzard" and bt or source=="bartender" and not bt
 return source,blocked
end
function A.Count() return A.Resolve()=="blizzard" and 8 or 10 end
function A.Button(bar,index)
 local source,blocked=A.Resolve();if blocked then return end
 if source=="bartender" then return _G["BT4Button"..((bar-1)*12+index)] end
 local entry=native[bar];return entry and _G[entry.prefix..index]
end
function A.ForEach(bars,callback)
 local source,blocked=A.Resolve();if blocked then return end
 for _,bar in ipairs(bars or {}) do
  local entry=native[bar]
  for i=1,12 do
   local button
   if source=="bartender" then button=_G["BT4Button"..((bar-1)*12+i)]
   elseif entry then button=_G[entry.prefix..i] end
   if button then callback(button,bar,i) end
  end
 end
end
function A.Bounds(bars)
 local left,right,top,bottom
 local rootScale=UIParent:GetEffectiveScale()
 A.ForEach(bars,function(button)
  if button:IsVisible() and button:GetEffectiveAlpha()>0 then
   local l,b,w,h=button:GetRect()
   local restricted=issecretvalue and (issecretvalue(l) or issecretvalue(b) or issecretvalue(w) or issecretvalue(h))
   if not restricted and l and b and w and h and w>0 and h>0 then
    local scale=button:GetEffectiveScale()/rootScale
    local r,t=(l+w)*scale,(b+h)*scale;l,b=l*scale,b*scale
    left=left and math.min(left,l) or l;right=right and math.max(right,r) or r
    top=top and math.max(top,t) or t;bottom=bottom and math.min(bottom,b) or b
   end
  end
 end)
 return left,right,top,bottom
end
local function PetModule()
 local bt=_G.Bartender4
 if bt and bt.GetModule then local ok,module=pcall(bt.GetModule,bt,"PetBar",true);if ok then return module end end
end
function A.PetSource()
 if not A.BartenderActive() then return "blizzard" end
 local module=PetModule()
 local profile=module and module.db and module.db.profile
 if profile and profile.enabled==false then return "unavailable" end
 if module and not profile and module.IsEnabled and not module:IsEnabled() then return "unavailable" end
 return "bartender"
end
function A.PetParent()
 local source=A.PetSource()
 if source=="unavailable" then return end
 if source=="blizzard" then return PetActionBar or PetActionBarFrame end
 local module=PetModule()
 return module and module.bar or (_G.BT4PetButton1 and _G.BT4PetButton1:GetParent())
end
function A.PetButton(i)
 local source=A.PetSource()
 if source=="unavailable" then return end
 return _G[(source=="bartender" and "BT4PetButton" or "PetActionButton")..i]
end
function A.View(data,kind)
 if type(data)~="table" then return data end
 if A.Resolve()~="blizzard" then return data end
 if type(data.nativeLayout)~="table" then data.nativeLayout={} end
 local layout=data.nativeLayout
 if type(layout.bars)~="table" or #layout.bars==0 then layout.bars={1,2,3} end
 if kind=="art" then for key,value in pairs(defaults) do if type(layout[key])~="number" then layout[key]=value end end end
 local views=cache[data];if not views then views={};cache[data]=views end
 if not views[kind] then
  views[kind]=setmetatable({}, {
   __index=function(_,key)
    if key=="bars" or kind=="art" and geometry[key] then return data.nativeLayout[key] end
    return data[key]
   end,
   __newindex=function(_,key,value)
    if key=="bars" or kind=="art" and geometry[key] then data.nativeLayout[key]=value
    else data[key]=value end
   end,
  })
 end
 return views[kind]
end
function A.Status()
 local source,blocked=A.Resolve()
 if blocked then return source=="blizzard" and "barsConflict" or "barsMissingBT" end
 return source=="blizzard" and "barsNativeActive" or "barsBTActive"
end
function A.Refresh()
 if InCombatLockdown() then return end
 if A.RefreshPetBar then A.RefreshPetBar() end
 if ForeverClassArtLayoutAPI then ForeverClassArtLayoutAPI.Refresh() end
 if ForeverBarBackdropAPI and ForeverBarBackdropAPI.Refresh then ForeverBarBackdropAPI.Refresh() end
 if ForeverPetBarPanel then ForeverPetBarPanel.Apply() end
end
function A.SetPreference(value)
 if InCombatLockdown() or not K.db or (value~=0 and value~=1 and value~=2) then return false end
 K.db.barSource=value;A.Refresh();return true
end
function A.OpenNativeLayout()
 if InCombatLockdown() then return false end
 local manager=EditModeManagerFrame
 if not manager or not ShowUIPanel then K.Message("barsNoEditor");return false end
 if manager.CanEnterEditMode then
  local ok,can=pcall(manager.CanEnterEditMode,manager)
  if not ok or not can then K.Message("barsNoEditor");return false end
 end
 if K.window then K.window:Hide() end
 local ok=pcall(ShowUIPanel,manager)
 if not ok then if K.window then K.window:Show() end;K.Message("barsNoEditor") end
 return ok
end
end

-- Observe PetBar changes for cosmetic updates only. Never resurrect Blizzard
-- pet buttons detached by Bartender: calling their initializers/visibility
-- methods from addon code can taint subsequent protected pet commands.
do
local A=KerimAnkaUIBarsAPI
local queued,pending=false,false
local watched=setmetatable({},{__mode="k"})
local function Queue()
 if queued then return end;queued=true
 C_Timer.After(0,function()
  queued=false
  if InCombatLockdown() then pending=true;return end
  pending=false;A.Refresh()
  if K.window and K.window:IsShown() and K.Render then K.Render() end
 end)
end
local function Hook(object,key)
 if not object or type(object[key])~="function" then return end
 local methods=watched[object];if not methods then methods={};watched[object]=methods end
 if methods[key] then return end;methods[key]=true;hooksecurefunc(object,key,Queue)
end
function A.RefreshPetBar()
 if InCombatLockdown() then pending=true;return end
 local bt=_G.Bartender4
 if bt then
  local module=bt.GetModule and bt:GetModule("PetBar",true)
  for _,key in ipairs({"ToggleModule","OnEnable","OnDisable","ApplyConfig"}) do Hook(module,key) end
  Hook(bt,"HideBlizzard");Hook(bt,"UpdateModuleConfigs")
 end
end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","ADDON_LOADED","PLAYER_REGEN_ENABLED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",function(_,event)
 if event~="PLAYER_REGEN_ENABLED" or pending then Queue() end
end)
end

-- Cosmetic font visibility only. Never changes bindings, macro text or button attributes.
do
local tracked={}
local prefixes={"ActionButton","MultiBarBottomLeftButton","MultiBarBottomRightButton","MultiBarRightButton","MultiBarLeftButton","MultiBar5Button","MultiBar6Button","MultiBar7Button"}
local function Hidden(record)
 local source,blocked=KerimAnkaUIBarsAPI.Resolve()
 if not K.db or source~="blizzard" or blocked then return false end
 if record.key=="hideNativeHotkeys" and RANGE_INDICATOR and record.font:GetText()==RANGE_INDICATOR then return false end
 return K.db[record.key]==true
end
local function Apply(record)
 local alpha=Hidden(record) and 0 or record.alpha
 if record.font:GetAlpha()~=alpha then
  record.busy=true;record.font:SetAlpha(alpha);record.busy=false
 end
end
local function Track(font,key)
 if not font or not font.SetAlpha then return end
 local record=tracked[font]
 if not record then
  if not K.db or not K.db[key] then return end
  record={font=font,key=key,alpha=font:GetAlpha()};tracked[font]=record
  hooksecurefunc(font,"SetAlpha",function(_,alpha)
   if record.busy then return end
   record.alpha=alpha;Apply(record)
  end)
  if key=="hideNativeHotkeys" then hooksecurefunc(font,"SetText",function() Apply(record) end) end
 end
 Apply(record)
end
function K.ApplyActionBarLabels()
 if not K.db then return end
 for _,prefix in ipairs(prefixes) do
  for i=1,12 do
   local name=prefix..i;local button=_G[name]
   if button then
    Track(button.HotKey or _G[name.."HotKey"],"hideNativeHotkeys")
    Track(button.Name or _G[name.."Name"],"hideNativeMacroNames")
   end
  end
 end
 for _,record in pairs(tracked) do Apply(record) end
end
function K.SetActionBarLabel(key,hide)
 if InCombatLockdown() or not K.db or (key~="hideNativeHotkeys" and key~="hideNativeMacroNames") then return false end
 K.db[key]=hide==true;K.ApplyActionBarLabels();return true
end
local previous=KerimAnkaUIBarsAPI.Refresh
function KerimAnkaUIBarsAPI.Refresh(...)
 previous(...);K.ApplyActionBarLabels()
end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","ADDON_LOADED","UPDATE_BINDINGS"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",K.ApplyActionBarLabels)
end

-- Forever inventory preferences with new bag owner and Chat dock.
-- Classic inventory preferences, native bag-bar visibility and micro-menu layout.
do
local M={};K.InventoryMenus=M
local microState,microArt,mover,hiddenNativeBar
local busy=false;local pending=false;local queued=false;local hooked={}
local defaults={bagCombined=true,bagBackground=true,bagFrame=true,bagIconBorder=false,bagSize=30,bagGap=3,hideNativeBagBar=true,bagJunk=true,bagQuality=true,bagQuest=true,bagEmptySlots=false,bagItemGap=4,bagDesign=1,microEnabled=true,microSize=28,microGap=1,microLocked=true}
function M.Get(key)
 local value=K.db and K.db[key]
 if value==nil then return defaults[key] end
 return value
end
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function Editor() return EditModeManagerFrame and EditModeManagerFrame.IsEditModeActive and EditModeManagerFrame:IsEditModeActive() end
local function BTModule(name)
 local bt=_G.Bartender4
 if not bt or type(bt.GetModule)~="function" then return nil end
 local ok,module=pcall(bt.GetModule,bt,name,true)
 if ok then return module end
end
function M.BartenderOwns(name)
 local module=BTModule(name)
 if not module then return false end
 -- Hiding a module via its visibility rules does not release its buttons.
 local profile=module.db and module.db.profile
 if profile and type(profile.enabled)=="boolean" then return profile.enabled end
 return module.IsEnabled and module:IsEnabled()==true or false
end
local function BT() return M.BartenderOwns("BagBar") end
local function BTMicro() return M.BartenderOwns("MicroMenu") end
local function Loaded(name)
 local f=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 return f and f(name) or false
end
local function Protected(frame) return frame and frame.IsProtected and frame:IsProtected() end
local function NativeBags() return not Loaded("Bagnon") and not Loaded("AdiBags") and not Loaded("BetterBags") end
local function Snap(frame)
 local state={frame=frame,parent=frame:GetParent(),scale=frame:GetScale(),shown=frame:IsShown(),points={}}
 for i=1,frame:GetNumPoints() do state.points[i]={frame:GetPoint(i)} end
 return state
end
local function Restore(state)
 local frame=state.frame
 frame:SetParent(state.parent);frame:SetScale(state.scale);frame:ClearAllPoints()
 for _,point in ipairs(state.points) do frame:SetPoint(unpack(point)) end
end
local function Skin(frame)
 frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
 frame:SetBackdropColor(.055,.06,.055,.98);frame:SetBackdropBorderColor(.42,.35,.21,1)
end
local function Queue()
 if busy then return end
 if Combat() then pending=true;return end
 if queued then return end
 queued=true
 C_Timer.After(0,function() queued=false;M.Refresh() end)
end
local function BagChanged()
 if busy then return end
 -- Cursor updates are synchronous. Repair before control returns to the UI,
 -- rather than allowing native anchors/bar visibility to render for one frame.
 if M.ApplyNativeBagHide and M.ApplyNativeBagHide() then return end
 Queue()
end
local function Hook(frame,method,callback)
 if frame and type(frame[method])=="function" then
  local methods=hooked[frame];if not methods then methods={};hooked[frame]=methods end
  if not methods[method] then methods[method]=true;hooksecurefunc(frame,method,callback or Queue) end
 end
end
function M.ApplyNativeBagHide()
 local bar=BagsBar
 if not bar or Protected(bar) then return false end
 if M.Get("hideNativeBagBar") and not BT() and not Editor() then
  if not hiddenNativeBar then hiddenNativeBar={frame=bar,shown=bar:IsShown()}end
  Hook(bar,"Layout",BagChanged)
  if not hooked.bagShow then bar:HookScript("OnShow",BagChanged);hooked.bagShow=true end
  local previousBusy=busy;busy=true
  if bar:IsShown()then bar:Hide()end
  busy=previousBusy;return true
 end
 if hiddenNativeBar then
  local old=hiddenNativeBar;hiddenNativeBar=nil
  if not BT()then local previousBusy=busy;busy=true;old.frame:SetShown(old.shown);busy=previousBusy end
 end
 return false
end
local microFields={"childXPadding","childYPadding","isHorizontal","isStacked","layoutFramesGoingRight","layoutFramesGoingUp","stride"}
local function ReleaseMicro()
 if microState then
  Restore(microState.container)
  if MicroMenu:GetParent()==microState.menu.parent then Restore(microState.menu)
  elseif MicroMenu:GetScale()==microState.appliedScale then MicroMenu:SetScale(microState.menu.scale) end
  for _,key in ipairs(microFields) do MicroMenu[key]=microState.fields[key] end
  for button,original in pairs(microState.buttonSizes or {})do button:SetSize(original[1],original[2])end
  microState=nil
  if MicroMenu.MarkDirty then MicroMenu:MarkDirty() end
  if MicroMenuContainer.Layout then MicroMenuContainer:Layout() end
 end
 if microArt then microArt:Hide() end
 if mover then mover:Hide() end
end
local function MicroButtons()
 local list={}
 for _,button in ipairs({MicroMenu:GetChildren()}) do
  if button.layoutIndex then list[#list+1]=button end
 end
 table.sort(list,function(a,b) return a.layoutIndex<b.layoutIndex end)
 return list
end
local function MakeMicroUI()
 if microArt then return end
 microArt=CreateFrame("Frame","KerimAnkaUIMicroBackdrop",MicroMenu,"BackdropTemplate")
 microArt:SetPoint("TOPLEFT",-4,4);microArt:SetPoint("BOTTOMRIGHT",4,-4)
 microArt:SetFrameLevel(math.max(0,MicroMenu:GetFrameLevel()-1));Skin(microArt)
 mover=CreateFrame("Frame","KerimAnkaUIMicroMover",UIParent,"BackdropTemplate")
 mover:SetFrameStrata("DIALOG");mover:SetMovable(true);mover:SetClampedToScreen(true);mover:EnableMouse(true)
 mover:RegisterForDrag("LeftButton");Skin(mover)
 local label=mover:CreateFontString(nil,"OVERLAY");K.ApplyTextFont(label,11,false,"")
 label:SetPoint("CENTER");mover.label=label
 mover:SetScript("OnDragStart",function(self) if not Combat() then self:StartMoving() end end)
 mover:SetScript("OnDragStop",function(self)
  self:StopMovingOrSizing()
  if Combat() then pending=true;return end
  local scale=self:GetEffectiveScale()/UIParent:GetEffectiveScale()
  K.db.microX=self:GetLeft()*scale;K.db.microY=math.max(4,self:GetBottom()*scale-(self.menuHeight or 28)-2)
  M.Refresh()
 end)
end
function M.AlignChat()
 if Combat() or not K.db then return false end
 local chat=ChatFrame1
 local scale=chat and chat:GetEffectiveScale()/UIParent:GetEffectiveScale() or 1
 local x=chat and chat:GetLeft() or 24;local bottom=chat and chat:GetBottom() or 65
 K.db.microX=math.max(4,(x or 24)*scale)
 K.db.microY=math.max(4,(bottom or 65)*scale-M.Get("microSize")-12)
 M.Refresh();return true
end
local function WatchMicro()
 -- Install observers before waiting for buttons or their normal parent.
 -- Initial native construction and cinematic return can happen after our first refresh.
 for _,frame in pairs({MicroMenu,MicroMenuContainer}) do
  local methods=hooked[frame]
  if not methods then methods={};hooked[frame]=methods end
  if not methods.microShow then frame:HookScript("OnShow",Queue);methods.microShow=true end
  Hook(frame,"Layout");Hook(frame,"SetParent");Hook(frame,"SetPoint");Hook(frame,"SetScale")
 end
 Hook(MicroMenu,"SetNormalScale")
end
-- Bartender disables its bar without returning the original micro buttons.
-- Recover only its disabled bar, never a cinematic/vehicle/other-addon parent.
local function ReturnMicroButtons()
 local module=BTModule("MicroMenu")
 local bar=module and module.bar
 if BTMicro() or not MicroMenu or not MicroMenuContainer then return end
 local parent=MicroMenu:GetParent()
 local bt=_G.Bartender4
 local hider=bt and bt.UIHider
 if parent~=MicroMenuContainer and parent~=UIParent and (not hider or parent~=hider) then return end
 local returning={}
 for _,button in ipairs(bar and bar.buttons or {}) do
  if button:GetParent()==bar then
   if Combat() and Protected(button) then pending=true;return false end
   returning[#returning+1]=button
  end
 end
 -- HideBlizzard runs even when the MicroMenu module was never enabled:
 -- both native frames are hidden and parented to UIHider, with no module.bar.
 local hiddenContainer=hider and MicroMenuContainer:GetParent()==hider
 local hiddenMenu=hider and parent==hider
 if #returning==0 and not hiddenContainer and not hiddenMenu then return end
 if hiddenContainer then MicroMenuContainer:SetParent(UIParent) end
 -- Set the menu parent first: any remaining BT post-hook may move buttons.
 if parent~=MicroMenuContainer then
  MicroMenu:SetParent(MicroMenuContainer)
  MicroMenu:ClearAllPoints();MicroMenu:SetPoint("BOTTOMLEFT",MicroMenuContainer,"BOTTOMLEFT",0,0)
 end
 for _,button in ipairs(returning) do
  button:SetParent(MicroMenu);button:ClearAllPoints()
 end
 -- Grid layout skips hidden children. Make the returned menu visible before
 -- rebuilding anchors, so GetEdgeButton can compare real button coordinates.
 -- Never show UIHider itself: it also contains Blizzard's action bars.
 if MicroMenuContainer.ShowBase then MicroMenuContainer:ShowBase() else MicroMenuContainer:Show() end
 if MicroMenu.ShowBase then MicroMenu:ShowBase() else MicroMenu:Show() end
 MicroMenu.oldGridSettings=nil
 if MicroMenu.MarkDirty then MicroMenu:MarkDirty() end
 MicroMenu:Layout()
 return true
end

local chatMenuHidden=false
local function ApplyMicro()
 if not(K.Chat and K.Chat.Enabled())then ReleaseMicro();return end
 local dockState=K.Chat and K.Chat.GetMicroDock and K.Chat.GetMicroDock()
 if chatMenuHidden and not(dockState and dockState.hidden)then MicroMenuContainer:Show();chatMenuHidden=false end
 if BTMicro() or Editor() or not MicroMenu or not MicroMenuContainer or Protected(MicroMenuContainer) or Protected(MicroMenu) then ReleaseMicro();return end
 if ReturnMicroButtons()==false then return end
 if not M.Get("microEnabled") then ReleaseMicro();return end
 -- Cinematics/possess screens may temporarily own the native menu.
 if MicroMenu:GetParent()~=MicroMenuContainer then ReleaseMicro();return end
 local buttons=MicroButtons();if #buttons==0 then ReleaseMicro();return end
 if not microState then
  microState={container=Snap(MicroMenuContainer),menu=Snap(MicroMenu),fields={}}
  for _,key in ipairs(microFields) do microState.fields[key]=MicroMenu[key] end
 end
 MakeMicroUI()
 Hook(MicroMenu,"Layout");Hook(MicroMenu,"SetNormalScale");Hook(MicroMenu,"SetParent");Hook(MicroMenuContainer,"SetPoint");Hook(MicroMenuContainer,"SetScale")
 local ownedDock=K.Chat and K.Chat.GetMicroDock and K.Chat.GetMicroDock()
 if ownedDock then
  microState.buttonSizes=microState.buttonSizes or {}
  for _,b in ipairs(buttons)do
   if not microState.buttonSizes[b]then microState.buttonSizes[b]={b:GetWidth(),b:GetHeight()}end
   b:SetSize(ownedDock.buttonSize or 32,ownedDock.buttonSize or 32)
  end
 end
 local height=buttons[1]:GetHeight();local scale=ownedDock and 1 or M.Get("microSize")/math.max(1,height)
 -- One placement owner: the chat supplies a temporary dock rectangle. Saved x/y stay intact.
 local chatDock=K.Chat and K.Chat.GetMicroDock and K.Chat.GetMicroDock()
 if chatDock and chatDock.hidden then MicroMenuContainer:Hide();chatMenuHidden=true;return end
 if chatDock and chatDock.vertical then
  local total,count=0,0;for _,b in ipairs(buttons)do if b:IsShown()then total=total+b:GetHeight();count=count+1 end end
  scale=math.min(scale,math.max(.1,(chatDock.height-math.max(0,count-1)*3)/math.max(1,total)))

 end
 MicroMenuContainer:SetScale(1)
 MicroMenu.childXPadding=(chatDock and chatDock.gap or M.Get("microGap"))/scale;MicroMenu.childYPadding=chatDock and (chatDock.gap or 4)or 0
 MicroMenu.isHorizontal=true;MicroMenu.isStacked=false;MicroMenu.layoutFramesGoingRight=true;MicroMenu.layoutFramesGoingUp=false;MicroMenu.stride=#buttons
 if chatDock and chatDock.vertical then
  MicroMenu.isHorizontal=false;MicroMenu.childXPadding=0;MicroMenu.childYPadding=3/scale
 end
 if chatDock and not chatDock.vertical then
  MicroMenu.stride=math.max(1,math.floor((chatDock.width+(chatDock.gap or 4))/((chatDock.buttonSize or 32)+(chatDock.gap or 4))))
 end
 MicroMenu:SetScale(scale)
 microState.appliedScale=scale
 MicroMenu:Layout()
 -- Keep the original container and button handlers. No replacement menu clicks.
 local x=M.Get("microX");local y=M.Get("microY")
 if x==nil or y==nil then
  local chat=ChatFrame1;local cs=chat and chat:GetEffectiveScale()/UIParent:GetEffectiveScale() or 1
  x=math.max(4,((chat and chat:GetLeft()) or 24)*cs)
  y=math.max(4,((chat and chat:GetBottom()) or 65)*cs-M.Get("microSize")-12)
 end
 local width=MicroMenu:GetWidth()*scale;local h=MicroMenu:GetHeight()*scale
 if chatDock then x=chatDock.x+(chatDock.width-width)/2;y=chatDock.y+(chatDock.height-h)/2 end
 x=math.max(4,math.min(x,math.max(4,UIParent:GetWidth()-width-4)))
 y=math.max(4,math.min(y,math.max(4,UIParent:GetHeight()-h-4)))
 MicroMenuContainer:ClearAllPoints()
 if chatDock and chatDock.anchor then
  -- Anchor to the shared shell so dragging the native chat moves the menu without polling.
  MicroMenuContainer:SetPoint("BOTTOMLEFT",chatDock.anchor,"BOTTOMLEFT",(chatDock.offsetX or 10)+(chatDock.width-width)/2,(chatDock.offsetY or 3)+(chatDock.height-h)/2)
 else MicroMenuContainer:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",x,y)end
 MicroMenuContainer:SetSize(width,h)
 MicroMenu:ClearAllPoints();MicroMenu:SetPoint("BOTTOMLEFT",MicroMenuContainer,"BOTTOMLEFT",0,0)
 microArt:SetShown(not chatDock)
 mover:SetSize(math.max(150,width),18);mover:ClearAllPoints();mover:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",x,y+h+2)
 mover.menuHeight=h
 mover.label:SetText(K.L("imMove"));mover:SetShown(not M.Get("microLocked") and not chatDock)
end
local function WatchBartender()
 for _,name in ipairs({"BagBar","MicroMenu"}) do
  local module=BTModule(name)
  if module then
   for _,method in ipairs({"ToggleModule","OnEnable","OnDisable","ApplyConfig","MicroMenuBarShow","RestoreMicroButtonParent","MicroMenuSetParent","UpdateMicroButtonsParent"}) do Hook(module,method) end
  end
 end
 local bt=_G.Bartender4
 if bt then Hook(bt,"UpdateModuleConfigs");Hook(bt,"HideBlizzard") end
end
function M.Refresh()
 if busy or not K.db then return end
 if Combat() then pending=true;if mover then mover:Hide() end;M.ApplyNativeBagHide();return end
 busy=true;pending=false
 WatchBartender();WatchMicro()
 M.ApplyNativeBagHide();ApplyMicro()
 busy=false
end
local ranges={bagDesign={1,3},bagItemGap={0,16},bagSize={18,48},bagGap={0,16},microSize={18,48},microGap={0,16},microX={0,10000},microY={0,10000}}
function M.Set(key,value)
 if not K.db then return false end
 if Combat()then return false end
 if ranges[key] then
  if type(value)~="number" then return false end
  value=math.max(ranges[key][1],math.min(ranges[key][2],value))
 elseif type(defaults[key])=="boolean" then value=value==true
 else return false end
 K.db[key]=value;M.Refresh();return true
end
function M.Status()
 if BT() and BTMicro() then return "imBTBoth" end
 if BT() then return "imBTBags" end
 if BTMicro() then return "imBTMicro" end
 if not NativeBags() then return "imOtherBags" end
 if not BagsBar or Protected(BagsBar) or not ContainerFrameCombinedBags or not ContainerFrameSettingsManager then return "imUnavailable" end
 return "imHelp"
end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","ADDON_LOADED","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED","CVAR_UPDATE","BAG_UPDATE_DELAYED","EDIT_MODE_LAYOUTS_UPDATED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",function(_,event)
 if event=="PLAYER_REGEN_DISABLED" then if mover then mover:Hide() end;return end
 Queue()
 if event=="PLAYER_LOGIN" or event=="PLAYER_ENTERING_WORLD" then
  C_Timer.After(1,Queue);C_Timer.After(3,Queue)
 end
end)
if EventRegistry and EventRegistry.RegisterCallback then
 EventRegistry:RegisterCallback("EditMode.Enter",Queue,M)
 EventRegistry:RegisterCallback("EditMode.Exit",Queue,M)
end
end

-- Additive item overlays; no item clicks, item movement or native icon tint is changed.
do
local looks={};local watched={};local queued=false
local colors={[2]={.12,1,.12},[3]={.15,.45,1},[4]={.67,.22,1},[5]={1,.5,0},[6]={.9,.8,.5},[7]={.3,.8,1},[8]={.3,.8,1}}
local function Native()
 local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 return not loaded or not (loaded("Bagnon") or loaded("AdiBags") or loaded("BetterBags"))
end
local function Hide(look)
 look.coin:Hide();look.gray:Hide();for _,edge in ipairs(look.edges) do edge:Hide() end
end
local function CreateLook(button)
 local look={edges={}}
 local coin=button:CreateTexture(nil,"OVERLAY",nil,6)
 coin:SetSize(12,12);coin:SetPoint("TOPLEFT",2,-2)
 coin:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon");look.coin=coin
 for _,point in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
  local edge=button:CreateTexture(nil,"OVERLAY",nil,3)
  if point=="TOP" or point=="BOTTOM" then
   edge:SetHeight(2);edge:SetPoint(point.."LEFT",1,point=="TOP" and -1 or 1);edge:SetPoint(point.."RIGHT",-1,point=="TOP" and -1 or 1)
  else
   edge:SetWidth(2);edge:SetPoint("TOP"..point,point=="LEFT" and 1 or -1,-1);edge:SetPoint("BOTTOM"..point,point=="LEFT" and 1 or -1,1)
  end
  look.edges[#look.edges+1]=edge
 end
 -- A separate desaturated copy keeps the native icon's lock/search styling
 -- and its state untouched. Coins, stack counts and cooldowns stay above it.
 look.gray=button:CreateTexture(nil,"ARTWORK",nil,7)
 look.gray:SetDesaturated(true);look.gray:Hide()
 looks[button]=look;return look
end
local function Refresh()
 if not K.db then return end
 local enabled=Native();local active={}
 local function Container(container)
  if not container or not container:IsShown() then return end
  for _,button in ipairs(container.Items or {}) do
   if button.GetBagID and button.GetID then
    active[button]=true
    local look=looks[button]
    if not look and enabled and (K.db.bagJunk~=false or K.db.bagQuality~=false) and not InCombatLockdown() then look=CreateLook(button) end
    if look then
     Hide(look)
     if enabled and C_Container and C_Container.GetContainerItemInfo then
      local bag,slot=button:GetBagID(),button:GetID()
      if not (issecretvalue and (issecretvalue(bag) or issecretvalue(slot))) and type(bag)=="number" and bag>=0 and bag<=5 and type(slot)=="number" then
       local info=C_Container.GetContainerItemInfo(bag,slot)
       if info and not (issecretvalue and (issecretvalue(info.quality) or issecretvalue(info.hasNoValue))) then
        local junk=K.db.bagJunk~=false and info.quality==0 and info.hasNoValue~=true
        look.coin:SetShown(junk)
        if junk then
         local icon=button.icon or button.Icon or button.iconTexture or button.IconTexture
         if type(icon)=="string" then icon=_G[icon] end
         if icon and icon.GetTexture and icon.GetTexCoord then
          look.gray:ClearAllPoints();look.gray:SetAllPoints(icon)
          look.gray:SetTexture(icon:GetTexture());look.gray:SetTexCoord(icon:GetTexCoord())
          look.gray:SetAlpha(icon:GetAlpha())
          look.gray:SetVertexColor(icon:GetVertexColor())
          look.gray:Show()
         end
        end
        local rgb=colors[info.quality]
        if K.db.bagQuality~=false and rgb then
         local native=ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[info.quality]
         for _,edge in ipairs(look.edges) do edge:SetColorTexture(native and native.r or rgb[1],native and native.g or rgb[2],native and native.b or rgb[3],.95);edge:Show() end
        end
       end
      end
     end
    end
   end
  end
 end
 Container(ContainerFrameCombinedBags)
 for i=1,13 do Container(_G["ContainerFrame"..i]) end
 for button,look in pairs(looks) do if not active[button] then Hide(look) end end
end
local function Queue()
 if queued then return end
 queued=true;C_Timer.After(0,function() queued=false;Refresh() end)
end
local function Discover()
 local function Watch(container)
  if not container or watched[container] then return end
  watched[container]=true
  container:HookScript("OnShow",Queue);container:HookScript("OnHide",Queue)
  if container.UpdateItems then hooksecurefunc(container,"UpdateItems",Queue) end
  if container.UpdateItemSlots then hooksecurefunc(container,"UpdateItemSlots",Queue) end
 end
 Watch(ContainerFrameCombinedBags);for i=1,13 do Watch(_G["ContainerFrame"..i]) end
 Queue()
end
K.RefreshBagItemLooks=Refresh
local previous=K.InventoryMenus.Refresh
function K.InventoryMenus.Refresh(...) previous(...);Discover() end
local frame=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","ADDON_LOADED","BAG_UPDATE_DELAYED","GET_ITEM_INFO_RECEIVED","PLAYER_REGEN_ENABLED"}) do frame:RegisterEvent(event) end
frame:SetScript("OnEvent",Discover)
end

-- Optional native Edit Mode companion to the existing queued profile transaction.
do
local F={};K.FullLayout=F
-- This block is separate from profile serialization. Keep its snapshot copier
-- local here; the profile engine's private Copy helper is not in this scope.
local function Copy(value)
 if type(value)~="table" then return value end
 local result={};for key,item in pairs(value) do result[key]=Copy(item) end;return result
end
local preset=[==[5 0 59 0 0 0 0 6 MultiBarBottomLeft 0.0 -4.0 -1 ##$$%/&('&)$+#,# 0 1 0 0 6 MultiBarBottomRight 0.0 -4.0 -1 ##$$%/&('&(#,$ 0 2 0 7 7 UIParent -20.5 128.5 -1 ##$$%/&('&(#,$ 0 3 0 4 4 UIParent 430.5 -0.0 -1 #$$$%/&('%(#,$ 0 4 1 5 5 UIParent -5.0 -77.0 -1 #$$$%/&('%(#,$ 0 5 1 1 4 UIParent 0.0 0.0 -1 ##$$%/&('%(#,$ 0 6 1 1 4 UIParent 0.0 -50.0 -1 ##$$%/&('%(#,$ 0 7 0 0 0 UIParent 2.0 -3.0 -1 ##$$%)&%'%(&,$ 0 10 0 7 7 UIParent 239.0 642.0 -1 ##$$&('% 0 11 0 7 7 UIParent 119.0 222.3 -1 ##$$&''%,# 0 12 0 1 4 UIParent 284.0 -2.0 -1 ##$$&('% 1 -1 0 4 4 UIParent -16.0 -194.0 -1 ##$#%# 2 -1 1 2 2 UIParent 0.0 0.0 -1 ##$#%&&, 3 0 0 6 6 UIParent 403.6 115.7 -1 $#3% 3 1 0 7 7 UIParent 370.0 193.4 -1 %#3# 3 2 1 6 7 UIParent 520.0 265.0 -1 %#&#3# 3 3 0 0 0 UIParent 490.0 -316.0 -1 '$(#)#-_.+/#1$3#5#6(7-7$8(9( 3 4 1 0 2 CompactRaidFrameManager 0.0 -5.0 -1 ,#-=.+/#0#1#2(3#5#6(7-7$8(9( 3 5 1 5 5 UIParent 0.0 0.0 -1 &#*$3# 3 6 1 5 5 UIParent 0.0 0.0 -1 -=.+/#4$5#6(7-7$8(9( 3 7 0 4 4 UIParent -379.0 -301.5 -1 3# 4 -1 0 4 4 UIParent -283.0 -172.0 -1 # 5 -1 0 3 3 UIParent 1062.0 218.0 -1 # 6 0 1 2 2 UIParent -255.0 -10.0 -1 ##$#%#&.(()( 6 1 1 2 2 UIParent -270.0 -155.0 -1 ##$#%#'+(()(-$ 6 2 1 1 1 UIParent 0.0 -25.0 -1 ##$#%$&.(()(+#,-,$ 7 -1 1 7 7 UIParent 0.0 -4.0 -1 # 8 -1 0 6 6 UIParent 32.0 78.0 -1 #%$w%$&t 9 -1 0 4 4 UIParent 361.0 -61.0 -1 # 10 -1 0 0 0 UIParent 630.0 -280.0 -1 # 11 -1 0 5 5 UIParent -2.0 -173.0 -1 # 12 -1 1 2 2 UIParent -110.0 -275.0 -1 #K$#%# 13 -1 0 5 5 UIParent -71.8 -8.0 -1 ##$#%1 14 -1 0 5 5 UIParent -143.0 48.9 -1 ##$#%& 15 0 0 1 1 UIParent -65.0 -31.5 -1 &- 15 1 0 1 1 UIParent -62.0 -11.5 -1 &- 16 -1 0 5 5 UIParent -282.0 246.5 -1 #, 17 -1 0 1 1 UIParent -5.0 -42.0 -1 #$ 18 -1 1 5 5 UIParent 0.0 0.0 -1 #- 19 -1 1 7 7 UIParent 0.0 0.0 -1 ## 20 0 0 4 4 UIParent -146.0 95.0 -1 ##$/%$&('%(-($)#+$,$-$ 20 1 0 1 1 UIParent 119.0 -234.0 -1 ##$*%$&('%(-($)#+$,$-$ 20 2 0 4 4 UIParent 61.0 53.0 -1 ##$$%$&('((-($)#+$,$-$ 20 3 0 4 4 UIParent 340.0 -103.5 -1 #$$$%#&('((U)#*#+#,$-#.-.$ 21 -1 0 4 4 UIParent 0.0 -170.1 -1 #$%$&#'(())#*-*$+%,'-#.$/-0$1# 22 0 1 8 7 UIParent -457.0 336.0 -1 #$$$%#&('((#)U*$+%,$-#.#/U0% 22 1 1 1 1 UIParent 0.0 -40.0 -1 &('()U*#+% 22 2 1 1 1 UIParent 0.0 -90.0 -1 &('()U*#+% 22 3 1 1 1 UIParent 0.0 -130.0 -1 &('()U*#+% 23 -1 0 8 8 UIParent -223.5 8.0 -1 ##$#%$&I'M(%)U+$,$-$.*/U 24 -1 1 1 1 UIParent 0.0 -182.0 -1 # 25 -1 1 5 7 UIParent -28.0 128.0 -1 # 26 0 1 5 3 MainActionBar 30.0 5.0 -1 ## 26 1 0 7 7 UIParent 331.0 23.0 -1 ## 27 -1 1 4 4 Minimap -68.0 -68.0 -1 #- 28 -1 1 4 4 UIParent 0.0 0.0 -1 #( 29 0 0 7 7 UIParent 122.9 194.6 -1 #($U%#&i'+($)$ 29 1 0 1 4 UIParent 0.0 -2.0 -1 #($U%%&D&%'2($)$ 29 2 0 7 7 UIParent -163.9 194.3 -1 #($U%#&i',($)$]==]
local function Available()
 return C_EditMode and C_EditMode.GetLayouts and C_EditMode.ConvertStringToLayoutInfo
  and C_EditMode.ConvertLayoutInfoToString and C_EditMode.SaveLayouts
  and C_EditMode.OnLayoutAdded and C_EditMode.SetActiveLayout
  and Enum and Enum.EditModeLayoutType and Constants and Constants.EditModeConsts
  and EditModePresetLayoutManager and EditModePresetLayoutManager.GetCopyOfPresetLayouts
end
local function Ready()
 if InCombatLockdown() then return false,"combatLock" end
 if not Available() then return false,"flUnavailable" end
 local m=EditModeManagerFrame
 -- HasActiveChanges can remain true while the editor is closed, including
 -- after a reload with addon-positioned frames. It is not an open edit session.
 -- Never reset that Blizzard flag or save/discard changes on the user's behalf.
 if m and ((m.IsEditModeActive and m:IsEditModeActive()) or (m.IsShown and m:IsShown())) then return false,"flCloseEdit" end
 return true
end
local function Parse(code)
 if type(code)~="string" or #code<1 or #code>65536 then return nil end
 local ok,layout=pcall(C_EditMode.ConvertStringToLayoutInfo,code)
 if ok and type(layout)=="table" and type(layout.systems)=="table" and #layout.systems>0 then return layout end
end
local function Export(layout)
 local ok,code=pcall(C_EditMode.ConvertLayoutInfoToString,layout)
 if ok and type(code)=="string" then return code end
end
local function Info()
 local raw=C_EditMode.GetLayouts()
 if not raw or type(raw.layouts)~="table" then return nil end
 -- Never append into a native/preset-manager table: some clients reuse it.
 local info=Copy(raw)
 for _,layout in ipairs(info.layouts) do
  if layout.layoutType==Enum.EditModeLayoutType.Preset then return info end
 end
 -- The active index includes presets. Their count is client-specific.
 -- The initialized manager is authoritative; fall back to the preset provider.
 local manager=EditModeManagerFrame
 local source=manager and manager.layoutInfo and manager.layoutInfo.layouts
 if type(source)~="table" then source=EditModePresetLayoutManager:GetCopyOfPresetLayouts() end
 local layouts,seen={},{}
 for _,layout in ipairs(source or {}) do
  if layout.layoutType==Enum.EditModeLayoutType.Preset then
   local key=layout.layoutName or layout.layoutIndex
   if key~=nil and not seen[key] then layouts[#layouts+1]=Copy(layout);seen[key]=true end
  end
 end
 for _,layout in ipairs(info.layouts) do layouts[#layouts+1]=layout end
 info.layouts=layouts
 return info
end
function F.Capture()
 local info=Info()
 local manager=EditModeManagerFrame
 local current=manager and manager.layoutInfo
 -- This is the same accessor used by Blizzard's own CopyActiveLayoutToClipboard.
 -- It can resolve a character-specific/override layout which a raw row lookup cannot.
 if info and manager and type(manager.GetActiveLayoutInfo)=="function"
  and (not current or current.activeLayout==info.activeLayout) then
  local ok,selected=pcall(manager.GetActiveLayoutInfo,manager)
  if ok and type(selected)=="table" and type(selected.systems)=="table" then
   local code=Export(selected)
   if code then return {code=code,name=selected.layoutName,kind=selected.layoutType} end
  end
 end
 local active=info and info.layouts and info.layouts[info.activeLayout]
 if info and current and current.activeLayout==info.activeLayout and type(current.layouts)=="table" then
  local selected=current.layouts[current.activeLayout]
  if selected and type(selected.systems)=="table" then active=selected end
 end
 local code=active and Export(active)
 if not code then return nil end
 return {code=code,name=active.layoutName,kind=active.layoutType}
end
local function Find(info,snapshot)
 for index,layout in ipairs(info.layouts) do
  if layout.layoutName==snapshot.name and layout.layoutType==snapshot.kind and Export(layout)==snapshot.code then return index end
 end
end
local function Room(info,kind)
 local count=0
 for _,layout in ipairs(info.layouts) do if layout.layoutType==kind then count=count+1 end end
 return count<Constants.EditModeConsts.EditModeMaxLayoutsPerType
end
local function PresetName()
 local classes={WARRIOR="Warrior",PALADIN="Paladin",HUNTER="Hunter",ROGUE="Rogue",PRIEST="Priest",SHAMAN="Shaman",MAGE="Mage",WARLOCK="Warlock",DRUID="Druid",MONK="Monk",DEATHKNIGHT="Death Knight",DEMONHUNTER="Demon Hunter",EVOKER="Evoker"}
 local class=select(2,UnitClass("player"))
 return "KerimAnka UI"..(classes[class] and (" "..classes[class]) or "")
end
function F.SnapshotReady() return Ready() end
local function Target(action)
 if action.mode=="classPreset" then
  local data=K.ClassPresets and K.ClassPresets.Get(action.class)
  if data and action.class==select(2,UnitClass("player")) then return Parse(data.layout),action.kind or Enum.EditModeLayoutType.Account,"KerimAnka UI "..data.name end
  return nil
 end
 if action.mode=="preset" then
  return Parse(preset),action.kind or Enum.EditModeLayoutType.Account,PresetName()
 end
 local target=action.target
 if (action.mode=="restore" or action.mode=="snapshot") and type(target)=="table" then
  local kind=action.kind or (target.kind==Enum.EditModeLayoutType.Character and target.kind or Enum.EditModeLayoutType.Account)
  return Parse(target.code),kind,action.mode=="snapshot" and ("KerimAnka UI Saved "..select(2,UnitClass("player"))) or "KerimAnka Restore"
 end
end
local function Existing(info,action,layout)
 if action.mode=="restore" then return Find(info,action.target) end
 if action.mode=="snapshot" then local index=Find(info,action.target);if index then return index end end
 -- Reuse only unchanged layouts previously created with our name.
 local code=Export(layout)
 for index,current in ipairs(info.layouts) do
  if (current.layoutType==Enum.EditModeLayoutType.Account or current.layoutType==Enum.EditModeLayoutType.Character)
   and (not action.kind or current.layoutType==action.kind) and type(current.layoutName)=="string"
   and current.layoutName:match("^KerimAnka UI") and Export(current)==code then return index end
 end
end
local function Resolve(info,action,layout,kind)
 local index=Existing(info,action,layout)
 if index then return info.layouts[index].layoutType,index end
 if (action.mode=="snapshot" or action.mode=="preset" or action.mode=="classPreset") and not action.kind and not Room(info,kind) then kind=Enum.EditModeLayoutType.Character end
 return kind
end
function F.Prepare(action)
 local ready,err=Ready();if not ready then return nil,err end
 if type(action)~="table" then return nil,"flInvalid" end
 local layout,kind=Target(action)
 if not layout then return nil,"flInvalid" end
 local info=Info()
 if not info or type(info.layouts)~="table" then return nil,"flUnavailable" end
 local index;kind,index=Resolve(info,action,layout,kind)
 if not index and not Room(info,kind) then return nil,"flFull" end
 local before=F.Capture();if not before then return nil,"flUnavailable" end
 local setupBefore
 if action.mode=="classPreset" then
  local value,setupError=K.ClassPresets.Prepare(action.class);if not value then return nil,setupError end
  setupBefore=value
 elseif action.setupRestore then
  local value,setupError=K.ClassPresets.Capture();if not value then return nil,setupError end
  setupBefore=value
 end
 return {mode=action.mode,class=action.class,target=action.target,before=before,kind=kind,setupBefore=setupBefore,setupRestore=Copy(action.setupRestore)}
end
function F.Plan()
 local ok,value,err=pcall(F.Prepare,{mode="preset"})
 if not ok then return nil,"flUnavailable" end
 if not value then return nil,err end
 return value,value.kind==Enum.EditModeLayoutType.Character and "flCharacterPlan" or "flAccountPlan"
end
function F.Apply(action)
 local ready,err=Ready();if not ready then return false,err end
 local layout,kind,name=Target(action)
 if not layout then return false,"flInvalid" end
 local info=Info()
 if not info or type(info.layouts)~="table" then return false,"flUnavailable" end
 local index;kind,index=Resolve(info,action,layout,kind)
 if not index then
  if not Room(info,kind) then return false,"flFull" end
  local names={};local highest
  for i,current in ipairs(info.layouts) do
   names[current.layoutName]=true
   if current.layoutType==kind then highest=i end
  end
  local base=name;local suffix=2
  while names[name] do name=base.." "..suffix;suffix=suffix+1 end
  if C_EditMode.IsValidLayoutName and not C_EditMode.IsValidLayoutName(name) then return false,"flInvalid" end
  -- Keep account layouts before character layouts, as Blizzard's importer does.
  if not highest then
   for i,current in ipairs(info.layouts) do
    if current.layoutType==Enum.EditModeLayoutType.Preset or (kind==Enum.EditModeLayoutType.Character and current.layoutType==Enum.EditModeLayoutType.Account) then highest=i end
   end
  end
  index=(highest or 0)+1
  layout.layoutType=kind;layout.layoutName=name
  -- GetLayouts returns a snapshot. No existing layout is replaced or deleted.
  table.insert(info.layouts,index,layout)
  C_EditMode.SaveLayouts(info)
  C_EditMode.OnLayoutAdded(index,true,true)
 end
 C_EditMode.SetActiveLayout(index)
 local after=Info()
 if not after or after.activeLayout~=index then return false,"flFailed" end
 return true,kind==Enum.EditModeLayoutType.Character and "flAppliedCharacter" or "flApplied"
end
function F.Commit(transaction)
 local action=transaction.fullLayout
 if not action then return true end
 local ok,result,err=pcall(F.Apply,action)
 if ok and result and (action.class or action.setupRestore) then
  local extraOK,extraResult,extraError=pcall(K.ClassPresets.Commit,action)
  if not extraOK or not extraResult then
   pcall(K.ClassPresets.Restore,action.setupBefore)
   result=false;err=extraOK and extraError or "readyApplyFailed"
  end
 end
 if not ok or not result then
  -- If native saving/activation fails partway through, return to the saved
  -- previous layout when it is still present. Never delete a user layout.
  if not InCombatLockdown() and Available() and action.before then
   pcall(function()
    local info=Info();local index=Find(info,action.before)
    if index then C_EditMode.SetActiveLayout(index) end
   end)
  end
  F.status=ok and err or "flFailed";return false
 end
 F.status=err;return true
end
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent",function()
 if K.Profiles and K.Profiles.layoutWaiting then
  K.Profiles.layoutWaiting=nil;K.Profiles.CommitTransaction();K.Profiles.Checkpoint()
 end
end)
end

do
local M={};K.SoundShortcut=M
local defaults=K.soundShortcutDefaults
local limits={size={24,64},x={0,1},y={0,1}}
local button,menu,dragging,skipClick
local choices={{key='music',cvar='Sound_EnableMusic'},{key='ambience',cvar='Sound_EnableAmbience'},{key='all',cvar='Sound_EnableAllSound'}}
local art='Interface\\AddOns\\KerimAnkaUI\\Media\\SoundShortcut.tga'
function M.Get(key)
 local data=K.db and K.db.soundShortcut
 if data and type(data[key])==type(defaults[key]) then return data[key] end
 return defaults[key]
end
local function Position()
 button:ClearAllPoints();button:SetPoint('CENTER',UIParent,'BOTTOMLEFT',UIParent:GetWidth()*M.Get('x'),UIParent:GetHeight()*M.Get('y'))
 menu:ClearAllPoints()
 local right=button:GetRight()
 if right and right+menu:GetWidth()+4>UIParent:GetWidth() then menu:SetPoint('RIGHT',button,'LEFT',-4,0)
 else menu:SetPoint('LEFT',button,'RIGHT',4,0) end
end
local function StopDrag(save)
 if not dragging then return end
 button:StopMovingOrSizing();dragging=false
 if save and not InCombatLockdown() then
  local x,y=button:GetCenter();local scale=button:GetEffectiveScale()/UIParent:GetEffectiveScale()
  if x and y then
   K.db.soundShortcut=K.db.soundShortcut or {}
   K.db.soundShortcut.x=math.max(0,math.min(1,x*scale/UIParent:GetWidth()))
   K.db.soundShortcut.y=math.max(0,math.min(1,y*scale/UIParent:GetHeight()))
  end
 end
 Position()
end
local function HideTip()
 if GameTooltip and GameTooltip:GetOwner()==button then GameTooltip:Hide() end
end
local function Leave()
 HideTip()
 C_Timer.After(.2,function()
  if menu and not menu:IsMouseOver() and not button:IsMouseOver() then menu:Hide() end
 end)
end
local function Tooltip(self)
 GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT');GameTooltip:SetText(K.L('soundShortcutTitle'),1,.83,.45)
 GameTooltip:AddLine(K.L(M.Get('locked') and 'soundShortcutTip' or 'soundShortcutDrag'),1,1,1,true);GameTooltip:Show()
end
local function Ensure()
 if button then return end
 button=CreateFrame('Button','KerimAnkaUISoundShortcut',UIParent)
 button:SetFrameStrata('MEDIUM');button:SetMovable(true);button:SetClampedToScreen(true)
 button:EnableMouse(true);button:RegisterForDrag('LeftButton');button:RegisterForClicks('LeftButtonUp')
 button.icon=button:CreateTexture(nil,'ARTWORK');button.icon:SetAllPoints();button.icon:SetTexture(art)
 button.glow=button:CreateTexture(nil,'HIGHLIGHT');button.glow:SetAllPoints();button.glow:SetTexture(art);button.glow:SetBlendMode('ADD');button.glow:SetAlpha(.2)
 menu=CreateFrame('Frame','KerimAnkaUISoundShortcutMenu',UIParent,'BackdropTemplate')
 menu:SetFrameStrata('DIALOG');menu:SetSize(410,56);menu:SetClampedToScreen(true);menu:EnableMouse(true)
 K.UnitWidgets.Rounded(menu,.055,.065,.06,{.58,.43,.21,1},24,false);menu:Hide()
 menu:SetScript('OnLeave',Leave)
 for i,choice in ipairs(choices) do
  local b=CreateFrame('Button',nil,menu,'BackdropTemplate');choice.button=b
  b:SetSize(128,38);b:SetPoint('LEFT',menu,'LEFT',9+(i-1)*132,0)
  K.UnitWidgets.Rounded(b,.10,.12,.10,{.28,.32,.25,1},16,false)
  -- Native CJK text must inherit its font from creation, independently of
  -- the Latin/Cyrillic region's font history. Reuse both across language switches.
  b.romanLabel=b:CreateFontString(nil,'OVERLAY')
  b.chineseLabel=b:CreateFontString(nil,'OVERLAY','GameFontNormal')
  for _,label in ipairs({b.romanLabel,b.chineseLabel}) do
   label:SetPoint('CENTER');label:SetWidth(118);label:SetWordWrap(false)
  end
  K.ApplyTextFont(b.romanLabel,12,true,'',false)
  K.ApplyTextFont(b.chineseLabel,12,true,'',true)
  b.label=b.romanLabel
  b:SetScript('OnClick',function()
   local value=K.GetCVar(choice.cvar)
   if value~=nil then K.SetCVar(choice.cvar,value=='0' and 1 or 0);M.Refresh() end
  end)
  b:SetScript('OnLeave',Leave)
 end
 button:SetScript('OnEnter',Tooltip);button:SetScript('OnLeave',Leave)
 button:SetScript('OnClick',function()
  if dragging or skipClick then return end
  HideTip();Position();menu:SetShown(not menu:IsShown())
 end)
 button:SetScript('OnDragStart',function(self)
  if M.Get('locked') or InCombatLockdown() then return end
  menu:Hide();HideTip();dragging=true;self:StartMoving()
 end)
 button:SetScript('OnDragStop',function()
  if not dragging then return end
  skipClick=true;StopDrag(true);C_Timer.After(0,function() skipClick=false end)
 end)
end
function M.Refresh()
 if not K.db or not K.UnitWidgets then return end
 Ensure()
 if dragging then return end
 button:SetSize(M.Get('size'),M.Get('size'));Position();button:SetShown(M.Get('enabled'))
 local enabled=K.GetCVar('Sound_EnableAllSound')~='0'
 button.icon:SetVertexColor(enabled and 1 or .5,enabled and 1 or .5,enabled and 1 or .5,1)
 if not M.Get('enabled') then menu:Hide() end
 for _,choice in ipairs(choices) do
  local value=K.GetCVar(choice.cvar);local on=value~='0'
  local b=choice.button
  b.romanLabel:Hide();b.chineseLabel:Hide()
  b.label=KerimAnkaUIDB.language=='zhCN' and b.chineseLabel or b.romanLabel
  b.label:Show()
  choice.button.label:SetText(K.L('soundShortcut_'..choice.key)..': '..K.L(on and 'soundShortcutOn' or 'soundShortcutOff'))
  choice.button.label:SetTextColor(on and .75 or .7,on and .9 or .7,on and .55 or .7,1)
  choice.button:SetEnabled(value~=nil)
 end
end
function M.Set(key,value)
 if not K.db or InCombatLockdown() or defaults[key]==nil then return false end
 if type(value)~=type(defaults[key]) then return false end
 if type(value)=='number' then
  if value~=value or math.abs(value)==math.huge then return false end
  value=math.max(limits[key][1],math.min(limits[key][2],value))
 end
 StopDrag(false);K.db.soundShortcut=K.db.soundShortcut or {};K.db.soundShortcut[key]=value;M.Refresh();return true
end
function M.ResetPosition()
 if not K.db or InCombatLockdown() then return false end
 StopDrag(false);K.db.soundShortcut=K.db.soundShortcut or {};K.db.soundShortcut.x=defaults.x;K.db.soundShortcut.y=defaults.y
 M.Refresh();return true
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','DISPLAY_SIZE_CHANGED','UI_SCALE_CHANGED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function()
 if dragging then StopDrag(false) end
 if menu then menu:Hide() end
 M.Refresh()
end)
end

do
local M={};K.BagMode=M
function M.Get()return not K.db or K.db.bagCombined~=false end
function M.ApplySaved()
 if not K.db then return end
 if K.db.bagCombined==nil then K.db.bagCombined=true end
 K.db.bagDock=nil;K.db.bagExpanded=nil
 if K.ClassicBags then K.ClassicBags.Refresh()end
 if K.InventoryMenus then K.InventoryMenus.Refresh()end
end
function M.Set(value)
 if not K.db or K.InCombat()or type(value)~='boolean'then return false end
 K.db.bagCombined=value;M.ApplySaved();return true
end
local previous=K.InventoryMenus.Set
function K.InventoryMenus.Set(key,value)
 if key=='bagCombined'then return M.Set(value)end
 return previous(key,value)
end
end
