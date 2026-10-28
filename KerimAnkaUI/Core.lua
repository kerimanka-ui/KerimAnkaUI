local addonName, K = ...
K.name, K.version = addonName, "0.35.1"
-- Final panel placement captured from Kerimankahan-Hantirt. These are panel
-- preferences, not the game's UI scale or any gameplay frame coordinates.
K.panelDefaults={scale=0.8721474221494858,height=819.36083984375,position={x=36.77588658330683,y=209.4805938205954}}
-- Sound shortcut position captured from Nosce-Temet near the minimap.
K.soundShortcutDefaults={enabled=true,locked=true,size=36,x=0.9051041920979818,y=0.9162963772578913}
K.modules = {
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
   local value=AudioValue(K.db.cvars[name]) or AudioDefault(name)
   K.db.cvars[name]=value
   if K.db.originalCVars[name]==nil then K.db.originalCVars[name]=current end
   if setter and current~=value then pcall(setter,name,value) end
  end
 end
 if K.db.muteClicks==nil then K.db.muteClicks=false end
 K.audioReady=true
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
    if K.InCombat() then return false end
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
 important={"ERR_INV_FULL","ERR_BANK_FULL","ERR_BAG_FULL","ERR_QUEST_FAILED_BAG_FULL_S","ERR_QUEST_LOG_FULL","ERR_QUEST_PUSH_LOG_FULL_S","ERR_NOT_ENOUGH_MONEY","ERR_QUEST_FAILED_NOT_ENOUGH_MONEY","ERR_ITEM_MAX_COUNT","ERR_ITEM_MAX_COUNT_EQUIPPED","ERR_ITEM_MAX_COUNT_SOCKETED","ERR_QUEST_FAILED_MAX_COUNT_S"},
}
local ids,texts={},{};local errorRelay
local function BuildErrorFilter()
 ids={};texts={}
 for group,names in pairs(errorGroups) do
  for _,name in ipairs(names) do
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
events:RegisterEvent("CVAR_UPDATE")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, event, name)
    if event=="CVAR_UPDATE" then K.TrackCharacterAudio(name) end
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
KerimAnkaUIAPI={version=1,OpenPage=function(key) if K.ShowPage then K.ShowPage(key) end end}

-- Bundled profile engine. LibSerialize retains its original MIT notice.
do
local ProfileSerializer=(function()
--[[
Copyright (c) 2020 Ross Nichols

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Credits:
The following projects served as inspiration for aspects of this project:

1. LibDeflate, by Haoqian He. https://github.com/SafeteeWoW/LibDeflate
    For the CreateReader/CreateWriter functions.
2. lua-MessagePack, by François Perrad. https://framagit.org/fperrad/lua-MessagePack
    For the mechanism for packing/unpacking floats and ints.
3. LibQuestieSerializer, by aero. https://github.com/AeroScripts/LibQuestieSerializer
    For the basis of the implementation, and initial inspiration.
]]


-- Latest version can be found at https://github.com/rossnichols/LibSerialize.

--[[
# LibSerialize

LibSerialize is a Lua library for efficiently serializing/deserializing arbitrary values.
It supports serializing nils, numbers, booleans, strings, and tables containing these types.

It is best paired with [LibDeflate](https://github.com/safeteeWow/LibDeflate), to compress
the serialized output and optionally encode it for World of Warcraft addon or chat channels.
IMPORTANT: if you decide not to compress the output and plan on transmitting over an addon
channel, it still needs to be encoded, but encoding via `LibDeflate:EncodeForWoWAddonChannel()`
or `LibCompress:GetAddonEncodeTable()` will likely inflate the size of the serialization
by a considerable amount. See the usage below for an alternative.

Note that serialization and compression are sensitive to the specifics of your data set.
You should experiment with the available libraries (LibSerialize, AceSerializer, LibDeflate,
LibCompress, etc.) to determine which combination works best for you.


## Usage:

```lua
-- Dependencies: AceAddon-3.0, AceComm-3.0, LibSerialize, LibDeflate
MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceComm-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

function MyAddon:OnEnable()
    self:RegisterComm("MyPrefix")
end

-- With compression (recommended):
function MyAddon:Transmit(data)
    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    self:SendCommMessage("MyPrefix", encoded, "WHISPER", UnitName("player"))
end

function MyAddon:OnCommReceived(prefix, payload, distribution, sender)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
    if not decoded then return end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return end
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then return end

    -- Handle `data`
end

-- Without compression (custom codec):
MyAddon._codec = LibDeflate:CreateCodec("\000", "\255", "")
function MyAddon:Transmit(data)
    local serialized = LibSerialize:Serialize(data)
    local encoded = self._codec:Encode(serialized)
    self:SendCommMessage("MyPrefix", encoded, "WHISPER", UnitName("player"))
end
function MyAddon:OnCommReceived(prefix, payload, distribution, sender)
    local decoded = self._codec:Decode(payload)
    if not decoded then return end
    local success, data = LibSerialize:Deserialize(decoded)
    if not success then return end

    -- Handle `data`
end
```


## API:
* **`LibSerialize:SerializeEx(opts, ...)`**

    Arguments:
    * `opts`: options (see below)
    * `...`: a variable number of serializable values

    Returns:
    * result: `...` serialized as a string

* **`LibSerialize:Serialize(...)`**

    Arguments:
    * `...`: a variable number of serializable values

    Returns:
    * `result`: `...` serialized as a string

    Calls `SerializeEx(opts, ...)` with the default options (see below)

* **`LibSerialize:Deserialize(input)`**

    Arguments:
    * `input`: a string previously returned from `LibSerialize:Serialize()`

    Returns:
    * `success`: a boolean indicating if deserialization was successful
    * `...`: the deserialized value(s), or a string containing the encountered Lua error

* **`LibSerialize:DeserializeValue(input)`**

    Arguments:
    * `input`: a string previously returned from `LibSerialize:Serialize()`

    Returns:
    * `...`: the deserialized value(s)

* **`LibSerialize:IsSerializableType(...)`**

    Arguments:
    * `...`: a variable number of values

    Returns:
    * `result`: true if all of the values' types are serializable.

    Note that if you pass a table, it will be considered serializable
    even if it contains unserializable keys or values. Only the types
    of the arguments are checked.

`Serialize()` will raise a Lua error if the input cannot be serialized.
This will occur if any of the following exceed 16777215: any string length,
any table key count, number of unique strings, number of unique tables.
It will also occur by default if any unserializable types are encountered,
though that behavior may be disabled (see options).

`Deserialize()` and `DeserializeValue()` are equivalent, except the latter
returns the deserialization result directly and will not catch any Lua
errors that may occur when deserializing invalid input.

Note that none of the serialization/deseriazation methods support reentrancy,
and modifying tables during the serialization process is unspecified and
should be avoided. Table serialization is multi-phased and assumes a consistent
state for the key/value pairs across the phases.


## Options:
The following serialization options are supported:
* `errorOnUnserializableType`: `boolean` (default true)
  * `true`: unserializable types will raise a Lua error
  * `false`: unserializable types will be ignored. If it's a table key or value,
     the key/value pair will be skipped. If it's one of the arguments to the
     call to SerializeEx(), it will be replaced with `nil`.
* `stable`: `boolean` (default false)
  * `true`: the resulting string will be stable, even if the input includes
     maps. This option comes with an extra memory usage and CPU time cost.
  * `false`: the resulting string will be unstable and will potentially differ
     between invocations if the input includes maps
* `filter`: `function(t, k, v) => boolean` (default nil)
  * If specified, the function will be called on every key/value pair in every
    table encountered during serialization. The function must return true for
    the pair to be serialized. It may be called multiple times on a table for
    the same key/value pair. See notes on reeentrancy and table modification.

If an option is unspecified in the table, then its default will be used.
This means that if an option `foo` defaults to true, then:
* `myOpts.foo = false`: option `foo` is false
* `myOpts.foo = nil`: option `foo` is true


## Customizing table serialization:
For any serialized table, LibSerialize will check for the presence of a
metatable key `__LibSerialize`. It will be interpreted as a table with
the following possible keys:
* `filter`: `function(t, k, v) => boolean`
  * If specified, the function will be called on every key/value pair in that
    table. The function must return true for the pair to be serialized. It may
    be called multiple times on a table for the same key/value pair. See notes
    on reeentrancy and table modification. If combined with the `filter` option,
    both functions must return true.


## Examples:
1. `LibSerialize:Serialize()` supports variadic arguments and arbitrary key types,
   maintaining a consistent internal table identity.
    ```lua
    local t = { "test", [false] = {} }
    t[ t[false] ] = "hello"
    local serialized = LibSerialize:Serialize(t, "extra")
    local success, tab, str = LibSerialize:Deserialize(serialized)
    assert(success)
    assert(tab[1] == "test")
    assert(tab[ tab[false] ] == "hello")
    assert(str == "extra")
    ```

2. Normally, unserializable types raise an error when encountered during serialization,
   but that behavior can be disabled in order to silently ignore them instead.
    ```lua
    local serialized = LibSerialize:SerializeEx(
        { errorOnUnserializableType = false },
        print, { a = 1, b = print })
    local success, fn, tab = LibSerialize:Deserialize(serialized)
    assert(success)
    assert(fn == nil)
    assert(tab.a == 1)
    assert(tab.b == nil)
    ```

3. Tables may reference themselves recursively and will still be serialized properly.
    ```lua
    local t = { a = 1 }
    t.t = t
    t[t] = "test"
    local serialized = LibSerialize:Serialize(t)
    local success, tab = LibSerialize:Deserialize(serialized)
    assert(success)
    assert(tab.t.t.t.t.t.t.a == 1)
    assert(tab[tab.t] == "test")
    ```

4. You may specify a global filter that applies to all tables encountered during
   serialization, and to individual tables via their metatable.
    ```lua
    local t = { a = 1, b = print, c = 3 }
    local nested = { a = 1, b = print, c = 3 }
    t.nested = nested
    setmetatable(nested, { __LibSerialize = {
        filter = function(t, k, v) return k ~= "c" end
    }})
    local opts = {
        filter = function(t, k, v) return LibSerialize:IsSerializableType(k, v) end
    }
    local serialized = LibSerialize:SerializeEx(opts, t)
    local success, tab = LibSerialize:Deserialize(serialized)
    assert(success)
    assert(tab.a == 1)
    assert(tab.b == nil)
    assert(tab.c == 3)
    assert(tab.nested.a == 1)
    assert(tab.nested.b == nil)
    assert(tab.nested.c == nil)
    ```


## Encoding format:
Every object is encoded as a type byte followed by type-dependent payload.

For numbers, the payload is the number itself, using a number of bytes
appropriate for the number. Small numbers can be embedded directly into
the type byte, optionally with an additional byte following for more
possible values. Negative numbers are encoded as their absolute value,
with the type byte indicating that it is negative. Floats are decomposed
into their eight bytes, unless serializing as a string is shorter.

For strings and tables, the length/count is also encoded so that the
payload doesn't need a special terminator. Small counts can be embedded
directly into the type byte, whereas larger counts are encoded directly
following the type byte, before the payload.

Strings are stored directly, with no transformations. Tables are stored
in one of three ways, depending on their layout:
* Array-like: all keys are numbers starting from 1 and increasing by 1.
    Only the table's values are encoded.
* Map-like: the table has no array-like keys.
    The table is encoded as key-value pairs.
* Mixed: the table has both map-like and array-like keys.
    The table is encoded first with the values of the array-like keys,
    followed by key-value pairs for the map-like keys. For this version,
    two counts are encoded, one each for the two different portions.

Strings and tables are also tracked as they are encountered, to detect reuse.
If a string or table is reused, it is encoded instead as an index into the
tracking table for that type. Strings must be >2 bytes in length to be tracked.
Tables may reference themselves recursively.


#### Type byte:
The type byte uses the following formats to implement the above:

* `NNNN NNN1`: a 7 bit non-negative int
* `CCCC TT10`: a 2 bit type index and 4 bit count (strlen, #tab, etc.)
    * Followed by the type-dependent payload
* `NNNN S100`: the lower four bits of a 12 bit int and 1 bit for its sign
    * Followed by a byte for the upper bits
* `TTTT T000`: a 5 bit type index
    * Followed by the type-dependent payload, including count(s) if needed
--]]

local MAJOR, MINOR = "LibSerialize", 4
local LibSerialize
if LibStub then
    LibSerialize = LibStub:NewLibrary(MAJOR, MINOR)
    if not LibSerialize then return end -- This version is already loaded.
else
    LibSerialize = {}
end

-- Rev the serialization version when making a breaking change.
-- Make sure to handle older versions properly within LibSerialize:DeserializeValue.
-- NOTE: these normally can be idential, but due to a bug when revving MINOR to 2,
-- we need to support both 1 and 2 as v1 serialization versions.
local SERIALIZATION_VERSION = 1
local DESERIALIZATION_VERSION = 2

local assert = assert
local error = error
local pcall = pcall
local print = print
local getmetatable = getmetatable
local pairs = pairs
local ipairs = ipairs
local select = select
local unpack = unpack
local type = type
local tostring = tostring
local tonumber = tonumber
local max = math.max
local frexp = math.frexp
local ldexp = math.ldexp
local floor = math.floor
local math_modf = math.modf
local math_huge = math.huge
local string_byte = string.byte
local string_char = string.char
local string_sub = string.sub
local table_concat = table.concat
local table_insert = table.insert
local table_sort = table.sort

local defaultOptions = {
    errorOnUnserializableType = true,
    stable = false,
    filter = nil,
}

local canSerializeFnOptions = {
    errorOnUnserializableType = false
}


--[[---------------------------------------------------------------------------
    Helper functions.
--]]---------------------------------------------------------------------------

-- Returns the number of bytes required to store the value,
-- up to a maximum of three. Errors if three bytes is insufficient.
local function GetRequiredBytes(value)
    if value < 256 then return 1 end
    if value < 65536 then return 2 end
    if value < 16777216 then return 3 end
    error("Object limit exceeded")
end

-- Returns the number of bytes required to store the value,
-- though always returning seven if four bytes is insufficient.
-- Doubles have room for 53bit numbers, so seven bits max.
local function GetRequiredBytesNumber(value)
    if value < 256 then return 1 end
    if value < 65536 then return 2 end
    if value < 16777216 then return 3 end
    if value < 4294967296 then return 4 end
    return 7
end

-- Returns whether the value (a number) is NaN.
local function IsNaN(value)
    -- With floating point optimizations enabled all comparisons involving
    -- NaNs will return true. Without them, these will both return false.
    return (value < 0) == (value >= 0)
end

-- Returns whether the value (a number) is finite, as opposed to being a
-- NaN or infinity.
local function IsFinite(value)
    return value > -math_huge and value < math_huge and not IsNaN(value)
end

-- Returns whether the value (a number) is fractional,
-- as opposed to a whole number.
local function IsFractional(value)
    local _, fract = math_modf(value)
    return fract ~= 0
end

-- Returns whether the value (a number) needs to be represented as a floating
-- point number due to either being fractional or non-finite.
local function IsFloatingPoint(value)
    return IsFractional(value) or not IsFinite(value)
end

-- Returns true if the given table key is an integer that can reside in the
-- array section of a table (keys 1 through arrayCount).
local function IsArrayKey(k, arrayCount)
    return type(k) == "number" and k >= 1 and k <= arrayCount and not IsFloatingPoint(k)
end

-- Sort compare function which is used to sort table keys to ensure that the
-- serialization of maps is stable. We arbitrarily put strings first, then
-- numbers, and finally booleans.
local function StableKeySort(a, b)
    local aType = type(a)
    local bType = type(b)
    -- Put strings first
    if aType == "string" and bType == "string" then
        return a < b
    elseif aType == "string" then
        return true
    elseif bType == "string" then
        return false
    end
    -- Put numbers next
    if aType == "number" and bType == "number" then
        return a < b
    elseif aType == "number" then
        return true
    elseif bType == "number" then
        return false
    end
    -- Put booleans last
    if aType == "boolean" and bType == "boolean" then
        return (a and 1 or 0) < (b and 1 or 0)
    else
        error(("Unhandled sort type(s): %s, %s"):format(aType, bType))
    end
end

-- Prints args to the chat window. To enable debug statements,
-- do a find/replace in this file with "-- DebugPrint(" for "DebugPrint(",
-- or the reverse to disable them again.
local DebugPrint = function(...)
    print(...)
end


--[[---------------------------------------------------------------------------
    Helpers for reading/writing streams of bytes from/to a string
--]]---------------------------------------------------------------------------

-- Creates a writer to lazily construct a string over multiple writes.
-- Return values:
-- 1. WriteString(str)
-- 2. Flush()
local function CreateWriter()
    local bufferSize = 0
    local buffer = {}

    -- Write the entire string into the writer.
    local function WriteString(str)
        -- DebugPrint("Writing string:", str, #str)
        bufferSize = bufferSize + 1
        buffer[bufferSize] = str
    end

    -- Return a string built from the previous calls to WriteString.
    local function FlushWriter()
        local flushed = table_concat(buffer, "", 1, bufferSize)
        bufferSize = 0
        return flushed
    end

    return WriteString, FlushWriter
end

-- Creates a reader to sequentially read bytes from the input string.
-- Return values:
-- 1. ReadBytes(bytelen)
-- 2. ReaderBytesLeft()
local function CreateReader(input)
    local inputLen = #input
    local nextPos = 1

    -- Read some bytes from the reader.
    -- @param bytelen The number of bytes to be read.
    -- @return the bytes as a string
    local function ReadBytes(bytelen)
        local result = string_sub(input, nextPos, nextPos + bytelen - 1)
        nextPos = nextPos + bytelen
        return result
    end

    local function ReaderBytesLeft()
        return inputLen - nextPos + 1
    end

    return ReadBytes, ReaderBytesLeft
end


--[[---------------------------------------------------------------------------
    Helpers for serializing/deserializing numbers (ints and floats)
--]]---------------------------------------------------------------------------

local function FloatToString(n)
    if IsNaN(n) then -- nan
        return string_char(0xFF, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
    end

    local sign = 0
    if n < 0.0 then
        sign = 0x80
        n = -n
    end
    local mant, expo = frexp(n)

    -- If n is infinity, mant will be infinity inside WoW, but NaN elsewhere.
    if (mant == math_huge or IsNaN(mant)) or expo > 0x400 then
        if sign == 0 then -- inf
            return string_char(0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
        else -- -inf
            return string_char(0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
        end
    elseif (mant == 0.0 and expo == 0) or expo < -0x3FE then -- zero
        return string_char(sign, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
    else
        expo = expo + 0x3FE
        mant = floor((mant * 2.0 - 1.0) * ldexp(0.5, 53))
        return string_char(sign + floor(expo / 0x10),
                           (expo % 0x10) * 0x10 + floor(mant / 281474976710656),
                           floor(mant / 1099511627776) % 256,
                           floor(mant / 4294967296) % 256,
                           floor(mant / 16777216) % 256,
                           floor(mant / 65536) % 256,
                           floor(mant / 256) % 256,
                           mant % 256)
    end
end

local function StringToFloat(str)
    local b1, b2, b3, b4, b5, b6, b7, b8 = string_byte(str, 1, 8)
    local sign = b1 > 0x7F
    local expo = (b1 % 0x80) * 0x10 + floor(b2 / 0x10)
    local mant = ((((((b2 % 0x10) * 256 + b3) * 256 + b4) * 256 + b5) * 256 + b6) * 256 + b7) * 256 + b8
    if sign then
        sign = -1
    else
        sign = 1
    end
    local n
    if mant == 0 and expo == 0 then
        n = sign * 0.0
    elseif expo == 0x7FF then
        if mant == 0 then
            n = sign * math_huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * ldexp(1.0 + mant / 4503599627370496.0, expo - 0x3FF)
    end
    return n
end

local function IntToString(n, required)
    if required == 1 then
        return string_char(n)
    elseif required == 2 then
        return string_char(floor(n / 256),
                           n % 256)
    elseif required == 3 then
        return string_char(floor(n / 65536),
                           floor(n / 256) % 256,
                           n % 256)
    elseif required == 4 then
        return string_char(floor(n / 16777216),
                           floor(n / 65536) % 256,
                           floor(n / 256) % 256,
                           n % 256)
    elseif required == 7 then
        return string_char(floor(n / 281474976710656) % 256,
                           floor(n / 1099511627776) % 256,
                           floor(n / 4294967296) % 256,
                           floor(n / 16777216) % 256,
                           floor(n / 65536) % 256,
                           floor(n / 256) % 256,
                           n % 256)
    end

    error("Invalid required bytes: " .. required)
end

local function StringToInt(str, required)
    if required == 1 then
        return string_byte(str)
    elseif required == 2 then
        local b1, b2 = string_byte(str, 1, 2)
        return b1 * 256 + b2
    elseif required == 3 then
        local b1, b2, b3 = string_byte(str, 1, 3)
        return (b1 * 256 + b2) * 256 + b3
    elseif required == 4 then
        local b1, b2, b3, b4 = string_byte(str, 1, 4)
        return ((b1 * 256 + b2) * 256 + b3) * 256 + b4
    elseif required == 7 then
        local b1, b2, b3, b4, b5, b6, b7, b8 = 0, string_byte(str, 1, 7)
        return ((((((b1 * 256 + b2) * 256 + b3) * 256 + b4) * 256 + b5) * 256 + b6) * 256 + b7) * 256 + b8
    end

    error("Invalid required bytes: " .. required)
end


--[[---------------------------------------------------------------------------
    Internal functionality:
    The `LibSerializeInt` table contains internal, immutable state (functions, tables)
    that is copied to a new table each time serialization/deserialization is
    invoked, so that each invocation has its own state encapsulated. Copying the
    state is preferred to a metatable, since we don't want to pay the cost of the
    indirection overhead every time we access one of the copied keys.
--]]---------------------------------------------------------------------------

local LibSerializeInt = {}

local function CreateSerializer(opts)
    local state = {}

    -- Copy the state from LibSerializeInt.
    for k, v in pairs(LibSerializeInt) do
        state[k] = v
    end

    -- Initialize string/table reference storage.
    state._stringRefs = {}
    state._tableRefs = {}

    -- Create the writer functions.
    state._writeString, state._flushWriter = CreateWriter()

    -- Create a combined options table, starting with the defaults
    -- and then overwriting any user-supplied keys.
    state._opts = {}
    for k, v in pairs(defaultOptions) do
        state._opts[k] = v
    end
    for k, v in pairs(opts) do
        state._opts[k] = v
    end

    return state
end

local function CreateDeserializer(input)
    local state = {}

    -- Copy the state from LibSerializeInt.
    for k, v in pairs(LibSerializeInt) do
        state[k] = v
    end

    -- Initialize string/table reference storage.
    state._stringRefs = {}
    state._tableRefs = {}

    -- Create the reader functions.
    state._readBytes, state._readerBytesLeft = CreateReader(input)

    return state
end


--[[---------------------------------------------------------------------------
    Object reuse:
    As strings/tables are serialized or deserialized, they are stored in a lookup
    table in case they're encountered again, at which point they can be referenced
    by their index into their table rather than repeating the string contents.
--]]---------------------------------------------------------------------------

function LibSerializeInt:_AddReference(refs, value)
    local ref = #refs + 1
    refs[ref] = value
    refs[value] = ref
end


--[[---------------------------------------------------------------------------
    Read (deserialization) support.
--]]---------------------------------------------------------------------------

function LibSerializeInt:_ReadObject()
    local value = self:_ReadByte()

    if value % 2 == 1 then
        -- Number embedded in the top 7 bits.
        local num = (value - 1) / 2
        -- DebugPrint("Found embedded number (1byte):", value, num)
        return num
    end

    if value % 4 == 2 then
        -- Type with embedded count. Extract both.
        -- The type is in bits 3-4, count in 5-8.
        local typ = (value - 2) / 4
        local count = (typ - typ % 4) / 4
        typ = typ % 4
        -- DebugPrint("Found type with embedded count:", value, typ, count)
        return self._EmbeddedReaderTable[typ](self, count)
    end

    if value % 8 == 4 then
        -- Number embedded in the top 4 bits, plus an additional byte's worth (so 12 bits).
        -- If bit 4 is set, the number is negative.
        local packed = self:_ReadByte() * 256 + value
        local num
        if value % 16 == 12 then
            num = -(packed - 12) / 16
        else
            num = (packed - 4) / 16
        end
        -- DebugPrint("Found embedded number (2bytes):", value, packed, num)
        return num
    end

    -- Otherwise, the type index is embedded in the upper 5 bits.
    local typ = value / 8
    -- DebugPrint("Found type:", value, typ)
    return self._ReaderTable[typ](self)
end

function LibSerializeInt:_ReadTable(entryCount, value)
    -- DebugPrint("Extracting keys/values for table:", entryCount)

    if value == nil then
        value = {}
        self:_AddReference(self._tableRefs, value)
    end

    for _ = 1, entryCount do
        local k, v = self:_ReadPair(self._ReadObject)
        value[k] = v
    end

    return value
end

function LibSerializeInt:_ReadArray(entryCount, value)
    -- DebugPrint("Extracting values for array:", entryCount)

    if value == nil then
        value = {}
        self:_AddReference(self._tableRefs, value)
    end

    for i = 1, entryCount do
        value[i] = self:_ReadObject()
    end

    return value
end

function LibSerializeInt:_ReadMixed(arrayCount, mapCount)
    -- DebugPrint("Extracting values for mixed table:", arrayCount, mapCount)

    local value = {}
    self:_AddReference(self._tableRefs, value)

    self:_ReadArray(arrayCount, value)
    self:_ReadTable(mapCount, value)

    return value
end

function LibSerializeInt:_ReadString(len)
    -- DebugPrint("Reading string,", len)

    local value = self._readBytes(len)
    if len > 2 then
        self:_AddReference(self._stringRefs, value)
    end
    return value
end

function LibSerializeInt:_ReadByte()
    -- DebugPrint("Reading byte")

    return self:_ReadInt(1)
end

function LibSerializeInt:_ReadInt(required)
    -- DebugPrint("Reading int", required)

    return StringToInt(self._readBytes(required), required)
end

function LibSerializeInt:_ReadPair(fn, ...)
    local first = fn(self, ...)
    local second = fn(self, ...)
    return first, second
end

local embeddedIndexShift = 4
local embeddedCountShift = 16
LibSerializeInt._EmbeddedIndex = {
    STRING = 0,
    TABLE = 1,
    ARRAY = 2,
    MIXED = 3,
}
LibSerializeInt._EmbeddedReaderTable = {
    [LibSerializeInt._EmbeddedIndex.STRING] = function(self, c) return self:_ReadString(c) end,
    [LibSerializeInt._EmbeddedIndex.TABLE] =  function(self, c) return self:_ReadTable(c) end,
    [LibSerializeInt._EmbeddedIndex.ARRAY] =  function(self, c) return self:_ReadArray(c) end,
    -- For MIXED, the 4-bit count contains two 2-bit counts that are one less than the true count.
    [LibSerializeInt._EmbeddedIndex.MIXED] =  function(self, c) return self:_ReadMixed((c % 4) + 1, floor(c / 4) + 1) end,
}

local readerIndexShift = 8
LibSerializeInt._ReaderIndex = {
    NIL = 0,

    NUM_16_POS = 1,
    NUM_16_NEG = 2,
    NUM_24_POS = 3,
    NUM_24_NEG = 4,
    NUM_32_POS = 5,
    NUM_32_NEG = 6,
    NUM_64_POS = 7,
    NUM_64_NEG = 8,
    NUM_FLOAT = 9,
    NUM_FLOATSTR_POS = 10,
    NUM_FLOATSTR_NEG = 11,

    BOOL_T = 12,
    BOOL_F = 13,

    STR_8 = 14,
    STR_16 = 15,
    STR_24 = 16,

    TABLE_8 = 17,
    TABLE_16 = 18,
    TABLE_24 = 19,

    ARRAY_8 = 20,
    ARRAY_16 = 21,
    ARRAY_24 = 22,

    MIXED_8 = 23,
    MIXED_16 = 24,
    MIXED_24 = 25,

    STRINGREF_8 = 26,
    STRINGREF_16 = 27,
    STRINGREF_24 = 28,

    TABLEREF_8 = 29,
    TABLEREF_16 = 30,
    TABLEREF_24 = 31,
}
LibSerializeInt._ReaderTable = {
    -- Nil
    [LibSerializeInt._ReaderIndex.NIL]  = function(self) return nil end,

    -- Numbers (ones requiring <=12 bits are handled separately)
    [LibSerializeInt._ReaderIndex.NUM_16_POS] = function(self) return self:_ReadInt(2) end,
    [LibSerializeInt._ReaderIndex.NUM_16_NEG] = function(self) return -self:_ReadInt(2) end,
    [LibSerializeInt._ReaderIndex.NUM_24_POS] = function(self) return self:_ReadInt(3) end,
    [LibSerializeInt._ReaderIndex.NUM_24_NEG] = function(self) return -self:_ReadInt(3) end,
    [LibSerializeInt._ReaderIndex.NUM_32_POS] = function(self) return self:_ReadInt(4) end,
    [LibSerializeInt._ReaderIndex.NUM_32_NEG] = function(self) return -self:_ReadInt(4) end,
    [LibSerializeInt._ReaderIndex.NUM_64_POS] = function(self) return self:_ReadInt(7) end,
    [LibSerializeInt._ReaderIndex.NUM_64_NEG] = function(self) return -self:_ReadInt(7) end,
    [LibSerializeInt._ReaderIndex.NUM_FLOAT]  = function(self) return StringToFloat(self._readBytes(8)) end,
    [LibSerializeInt._ReaderIndex.NUM_FLOATSTR_POS]  = function(self) return tonumber(self._readBytes(self:_ReadByte())) end,
    [LibSerializeInt._ReaderIndex.NUM_FLOATSTR_NEG]  = function(self) return -tonumber(self._readBytes(self:_ReadByte())) end,

    -- Booleans
    [LibSerializeInt._ReaderIndex.BOOL_T] = function(self) return true end,
    [LibSerializeInt._ReaderIndex.BOOL_F] = function(self) return false end,

    -- Strings (encoded as size + buffer)
    [LibSerializeInt._ReaderIndex.STR_8]  = function(self) return self:_ReadString(self:_ReadByte()) end,
    [LibSerializeInt._ReaderIndex.STR_16] = function(self) return self:_ReadString(self:_ReadInt(2)) end,
    [LibSerializeInt._ReaderIndex.STR_24] = function(self) return self:_ReadString(self:_ReadInt(3)) end,

    -- Tables (encoded as count + key/value pairs)
    [LibSerializeInt._ReaderIndex.TABLE_8]  = function(self) return self:_ReadTable(self:_ReadByte()) end,
    [LibSerializeInt._ReaderIndex.TABLE_16] = function(self) return self:_ReadTable(self:_ReadInt(2)) end,
    [LibSerializeInt._ReaderIndex.TABLE_24] = function(self) return self:_ReadTable(self:_ReadInt(3)) end,

    -- Arrays (encoded as count + values)
    [LibSerializeInt._ReaderIndex.ARRAY_8]  = function(self) return self:_ReadArray(self:_ReadByte()) end,
    [LibSerializeInt._ReaderIndex.ARRAY_16] = function(self) return self:_ReadArray(self:_ReadInt(2)) end,
    [LibSerializeInt._ReaderIndex.ARRAY_24] = function(self) return self:_ReadArray(self:_ReadInt(3)) end,

    -- Mixed arrays/maps (encoded as arrayCount + mapCount + arrayValues + key/value pairs)
    [LibSerializeInt._ReaderIndex.MIXED_8]  = function(self) return self:_ReadMixed(self:_ReadPair(self._ReadByte)) end,
    [LibSerializeInt._ReaderIndex.MIXED_16] = function(self) return self:_ReadMixed(self:_ReadPair(self._ReadInt, 2)) end,
    [LibSerializeInt._ReaderIndex.MIXED_24] = function(self) return self:_ReadMixed(self:_ReadPair(self._ReadInt, 3)) end,

    -- Previously referenced strings
    [LibSerializeInt._ReaderIndex.STRINGREF_8]  = function(self) return self._stringRefs[self:_ReadByte()] end,
    [LibSerializeInt._ReaderIndex.STRINGREF_16] = function(self) return self._stringRefs[self:_ReadInt(2)] end,
    [LibSerializeInt._ReaderIndex.STRINGREF_24] = function(self) return self._stringRefs[self:_ReadInt(3)] end,

    -- Previously referenced tables
    [LibSerializeInt._ReaderIndex.TABLEREF_8]  = function(self) return self._tableRefs[self:_ReadByte()] end,
    [LibSerializeInt._ReaderIndex.TABLEREF_16] = function(self) return self._tableRefs[self:_ReadInt(2)] end,
    [LibSerializeInt._ReaderIndex.TABLEREF_24] = function(self) return self._tableRefs[self:_ReadInt(3)] end,
}


--[[---------------------------------------------------------------------------
    Write (serialization) support.
--]]---------------------------------------------------------------------------

-- Returns the appropriate function from the writer table for the object's type.
-- If the object's type isn't supported and opts.errorOnUnserializableType is true,
-- then an error will be raised.
function LibSerializeInt:_GetWriteFn(obj)
    local typ = type(obj)
    local writeFn = self._WriterTable[typ]
    if not writeFn and self._opts.errorOnUnserializableType then
        error(("Unhandled type: %s"):format(typ))
    end

    return writeFn
end

-- Returns true if all of the variadic arguments are serializable.
-- Note that _GetWriteFn will raise a Lua error if it finds an
-- unserializable type, unless this behavior is suppressed via options.
function LibSerializeInt:_CanSerialize(...)
    for i = 1, select("#", ...) do
        local obj = select(i, ...)
        local writeFn = self:_GetWriteFn(obj)
        if not writeFn then
            return false
        end
    end

    return true
end

-- Returns true if the table's key/value pair should be serialized.
-- Both filter functions (if present) must return true, and the
-- key/value types must be serializable. Note that _CanSerialize
-- will raise a Lua error if it finds an unserializable type, unless
-- this behavior is suppressed via options.
function LibSerializeInt:_ShouldSerialize(t, k, v, filterFn)
    return (not self._opts.filter or self._opts.filter(t, k, v)) and
           (not filterFn or filterFn(t, k, v)) and
           self:_CanSerialize(k, v)
end

-- Note that _GetWriteFn will raise a Lua error if it finds an
-- unserializable type, unless this behavior is suppressed via options.
function LibSerializeInt:_WriteObject(obj)
    local writeFn = self:_GetWriteFn(obj)
    if not writeFn then
        return false
    end

    writeFn(self, obj)
    return true
end

function LibSerializeInt:_WriteByte(value)
    self:_WriteInt(value, 1)
end

function LibSerializeInt:_WriteInt(n, threshold)
    self._writeString(IntToString(n, threshold))
end

-- Lookup tables to map the number of required bytes to the
-- appropriate reader table index.
local numberIndices = {
    [2] = LibSerializeInt._ReaderIndex.NUM_16_POS,
    [3] = LibSerializeInt._ReaderIndex.NUM_24_POS,
    [4] = LibSerializeInt._ReaderIndex.NUM_32_POS,
    [7] = LibSerializeInt._ReaderIndex.NUM_64_POS,
}
local stringIndices = {
    [1] = LibSerializeInt._ReaderIndex.STR_8,
    [2] = LibSerializeInt._ReaderIndex.STR_16,
    [3] = LibSerializeInt._ReaderIndex.STR_24,
}
local tableIndices = {
    [1] = LibSerializeInt._ReaderIndex.TABLE_8,
    [2] = LibSerializeInt._ReaderIndex.TABLE_16,
    [3] = LibSerializeInt._ReaderIndex.TABLE_24,
}
local arrayIndices = {
    [1] = LibSerializeInt._ReaderIndex.ARRAY_8,
    [2] = LibSerializeInt._ReaderIndex.ARRAY_16,
    [3] = LibSerializeInt._ReaderIndex.ARRAY_24,
}
local mixedIndices = {
    [1] = LibSerializeInt._ReaderIndex.MIXED_8,
    [2] = LibSerializeInt._ReaderIndex.MIXED_16,
    [3] = LibSerializeInt._ReaderIndex.MIXED_24,
}
local stringRefIndices = {
    [1] = LibSerializeInt._ReaderIndex.STRINGREF_8,
    [2] = LibSerializeInt._ReaderIndex.STRINGREF_16,
    [3] = LibSerializeInt._ReaderIndex.STRINGREF_24,
}
local tableRefIndices = {
    [1] = LibSerializeInt._ReaderIndex.TABLEREF_8,
    [2] = LibSerializeInt._ReaderIndex.TABLEREF_16,
    [3] = LibSerializeInt._ReaderIndex.TABLEREF_24,
}

LibSerializeInt._WriterTable = {
    ["nil"] = function(self)
        -- DebugPrint("Serializing nil")
        self:_WriteByte(readerIndexShift * self._ReaderIndex.NIL)
    end,
    ["number"] = function(self, num)
        if IsFloatingPoint(num) then
            -- DebugPrint("Serializing float:", num)
            -- Normally a float takes 8 bytes. See if it's cheaper to encode as a string.
            -- If we encode as a string, though, we'll need a byte for its length.
            --
            -- Note that we only string encode finite values due to potential differences
            -- in encode/decode behaviour with such representations in some
            -- environments.
            local sign = 0
            local numAbs = num
            if num < 0 then
                sign = readerIndexShift
                numAbs = -num
            end
            local asString = tostring(numAbs)
            if #asString < 7 and tonumber(asString) == numAbs and IsFinite(numAbs) then
                self:_WriteByte(sign + readerIndexShift * self._ReaderIndex.NUM_FLOATSTR_POS)
                self:_WriteByte(#asString, 1)
                self._writeString(asString)
            else
                self:_WriteByte(readerIndexShift * self._ReaderIndex.NUM_FLOAT)
                self._writeString(FloatToString(num))
            end
        elseif num > -4096 and num < 4096 then
            -- The type byte supports two modes by which a number can be embedded:
            -- A 1-byte mode for 7-bit numbers, and a 2-byte mode for 12-bit numbers.
            if num >= 0 and num < 128 then
                -- DebugPrint("Serializing embedded number (1byte):", num)
                self:_WriteByte(num * 2 + 1)
            else
                -- DebugPrint("Serializing embedded number (2bytes):", num)
                local sign = 0
                if num < 0 then
                    sign = 8
                    num = -num
                end
                num = num * 16 + sign + 4
                local upper, lower = floor(num / 256), num % 256
                self:_WriteByte(lower)
                self:_WriteByte(upper)
            end
        else
            -- DebugPrint("Serializing number:", num)
            local sign = 0
            if num < 0 then
                num = -num
                sign = readerIndexShift
            end
            local required = GetRequiredBytesNumber(num)
            self:_WriteByte(sign + readerIndexShift * numberIndices[required])
            self:_WriteInt(num, required)
        end
    end,
    ["boolean"] = function(self, bool)
        -- DebugPrint("Serializing bool:", bool)
        self:_WriteByte(readerIndexShift * (bool and self._ReaderIndex.BOOL_T or self._ReaderIndex.BOOL_F))
    end,
    ["string"] = function(self, str)
        local ref = self._stringRefs[str]
        if ref then
            -- DebugPrint("Serializing string ref:", str)
            local required = GetRequiredBytes(ref)
            self:_WriteByte(readerIndexShift * stringRefIndices[required])
            self:_WriteInt(self._stringRefs[str], required)
        else
            local len = #str
            if len < 16 then
                -- Short lengths can be embedded directly into the type byte.
                -- DebugPrint("Serializing string, embedded count:", str, len)
                self:_WriteByte(embeddedCountShift * len + embeddedIndexShift * self._EmbeddedIndex.STRING + 2)
            else
                -- DebugPrint("Serializing string:", str, len)
                local required = GetRequiredBytes(len)
                self:_WriteByte(readerIndexShift * stringIndices[required])
                self:_WriteInt(len, required)
            end

            self._writeString(str)
            if len > 2 then
                self:_AddReference(self._stringRefs, str)
            end
        end
    end,
    ["table"] = function(self, tab)
        local ref = self._tableRefs[tab]
        if ref then
            -- DebugPrint("Serializing table ref:", tab)
            local required = GetRequiredBytes(ref)
            self:_WriteByte(readerIndexShift * tableRefIndices[required])
            self:_WriteInt(self._tableRefs[tab], required)
        else
            -- Add a reference before trying to serialize the table's contents,
            -- so that if the table recursively references itself, we can still
            -- properly serialize it.
            self:_AddReference(self._tableRefs, tab)

            local filter
            local mt = getmetatable(tab)
            if mt and type(mt) == "table" and mt.__LibSerialize then
                filter = mt.__LibSerialize.filter
            end

            -- First determine the "proper" length of the array portion of the table,
            -- which terminates at its first nil value. Note that some values in this
            -- range may not be serializable, which is fine - we'll handle them later.
            -- It's better to maximize the number of values that can be serialized
            -- without needing to also serialize their keys.
            local arrayCount, serializableArrayCount = 0, 0
            local entireArraySerializable = true
            local totalArraySerializable = 0
            for i, v in ipairs(tab) do
                arrayCount = i
                if self:_ShouldSerialize(tab, i, v, filter) then
                    totalArraySerializable = totalArraySerializable + 1
                    if entireArraySerializable then
                        serializableArrayCount = i
                    end
                else
                    entireArraySerializable = false
                end
            end

            -- Consider the array portion as a series of zero or more serializable
            -- entries followed by zero or more entries that may or may not be
            -- serializable. For the latter portion, we can either write them in
            -- the array portion, padding the unserializable entries with nils,
            -- or just write them as key/value pairs in the map portion. We'll choose
            -- the former if there are more serializable entries in this portion than
            -- unserializable, or the latter if more are unserializable.
            if arrayCount - totalArraySerializable > totalArraySerializable - serializableArrayCount then
                arrayCount = serializableArrayCount
                entireArraySerializable = true
            end

            -- Next determine the count of all entries in the table whose keys are not
            -- included in the array portion, only counting keys that are serializable.
            local mapCount = 0
            local entireMapSerializable = true
            for k, v in pairs(tab) do
                if not IsArrayKey(k, arrayCount) then
                    if self:_ShouldSerialize(tab, k, v, filter) then
                        mapCount = mapCount + 1
                    else
                        entireMapSerializable = false
                    end
                end
            end

            if mapCount == 0 then
                -- The table is an array. We can avoid writing the keys.
                if arrayCount < 16 then
                    -- Short counts can be embedded directly into the type byte.
                    -- DebugPrint("Serializing array, embedded count:", arrayCount)
                    self:_WriteByte(embeddedCountShift * arrayCount + embeddedIndexShift * self._EmbeddedIndex.ARRAY + 2)
                else
                    -- DebugPrint("Serializing array:", arrayCount)
                    local required = GetRequiredBytes(arrayCount)
                    self:_WriteByte(readerIndexShift * arrayIndices[required])
                    self:_WriteInt(arrayCount, required)
                end

                for i = 1, arrayCount do
                    local v = tab[i]
                    if entireArraySerializable or self:_ShouldSerialize(tab, i, v, filter) then
                        self:_WriteObject(v)
                    else
                        -- Since the keys are being omitted, write a `nil` entry
                        -- for any values that shouldn't be serialized.
                        self:_WriteObject(nil)
                    end
                end
            elseif arrayCount ~= 0 then
                -- The table has both array and dictionary keys. We can still save space
                -- by writing the array values first without keys.

                if mapCount < 5 and arrayCount < 5 then
                    -- Short counts can be embedded directly into the type byte.
                    -- They have to be really short though, since we have two counts.
                    -- Since neither can be zero (this is a mixed table),
                    -- we can get away with not being able to represent 0.
                    -- DebugPrint("Serializing mixed array-table, embedded counts:", arrayCount, mapCount)
                    local combined = (mapCount - 1) * 4 + arrayCount - 1
                    self:_WriteByte(embeddedCountShift * combined + embeddedIndexShift * self._EmbeddedIndex.MIXED + 2)
                else
                    -- Use the max required bytes for the two counts.
                    -- DebugPrint("Serializing mixed array-table:", arrayCount, mapCount)
                    local required = max(GetRequiredBytes(mapCount), GetRequiredBytes(arrayCount))
                    self:_WriteByte(readerIndexShift * mixedIndices[required])
                    self:_WriteInt(arrayCount, required)
                    self:_WriteInt(mapCount, required)
                end

                for i = 1, arrayCount do
                    local v = tab[i]
                    if entireArraySerializable or self:_ShouldSerialize(tab, i, v, filter) then
                        self:_WriteObject(v)
                    else
                        -- Since the keys are being omitted, write a `nil` entry
                        -- for any values that shouldn't be serialized.
                        self:_WriteObject(nil)
                    end
                end

                local mapCountWritten = 0
                if self._opts.stable then
                    -- In order to ensure that the output is stable, we sort the map keys and write
                    -- them in the sorted order.
                    local mapKeys = {}
                    for k, v in pairs(tab) do
                        -- Exclude keys that have already been written via the previous loop.
                        if not IsArrayKey(k, arrayCount) and (entireMapSerializable or self:_ShouldSerialize(tab, k, v, filter)) then
                            table_insert(mapKeys, k)
                        end
                    end
                    table_sort(mapKeys, StableKeySort)
                    for _, k in ipairs(mapKeys) do
                        self:_WriteObject(k)
                        self:_WriteObject(tab[k])
                        mapCountWritten = mapCountWritten + 1
                    end
                else
                    for k, v in pairs(tab) do
                        -- Exclude keys that have already been written via the previous loop.
                        if not IsArrayKey(k, arrayCount) and (entireMapSerializable or self:_ShouldSerialize(tab, k, v, filter)) then
                            self:_WriteObject(k)
                            self:_WriteObject(v)
                            mapCountWritten = mapCountWritten + 1
                        end
                    end
                end
                assert(mapCount == mapCountWritten)
            else
                -- The table has only dictionary keys, so we'll write them all.
                if mapCount < 16 then
                    -- Short counts can be embedded directly into the type byte.
                    -- DebugPrint("Serializing table, embedded count:", mapCount)
                    self:_WriteByte(embeddedCountShift * mapCount + embeddedIndexShift * self._EmbeddedIndex.TABLE + 2)
                else
                    -- DebugPrint("Serializing table:", mapCount)
                    local required = GetRequiredBytes(mapCount)
                    self:_WriteByte(readerIndexShift * tableIndices[required])
                    self:_WriteInt(mapCount, required)
                end

                if self._opts.stable then
                    -- In order to ensure that the output is stable, we sort the map keys and write
                    -- them in the sorted order.
                    local mapKeys = {}
                    for k, v in pairs(tab) do
                        if entireMapSerializable or self:_ShouldSerialize(tab, k, v, filter) then
                            table_insert(mapKeys, k)
                        end
                    end
                    table_sort(mapKeys, StableKeySort)
                    for _, k in ipairs(mapKeys) do
                        self:_WriteObject(k)
                        self:_WriteObject(tab[k])
                    end
                else
                    for k, v in pairs(tab) do
                        if entireMapSerializable or self:_ShouldSerialize(tab, k, v, filter) then
                            self:_WriteObject(k)
                            self:_WriteObject(v)
                        end
                    end
                end
            end
        end
    end,
}


--[[---------------------------------------------------------------------------
    API support.
--]]---------------------------------------------------------------------------

local serializeTester = CreateSerializer(canSerializeFnOptions)

function LibSerialize:IsSerializableType(...)
    return serializeTester:_CanSerialize(canSerializeFnOptions, ...)
end

function LibSerialize:SerializeEx(opts, ...)
    local ser = CreateSerializer(opts)

    ser:_WriteByte(SERIALIZATION_VERSION)

    for i = 1, select("#", ...) do
        local input = select(i, ...)
        if not ser:_WriteObject(input) then
            -- An unserializable object was passed as an argument.
            -- Write nil into its slot so that we deserialize a
            -- consistent number of objects from the resulting string.
            ser:_WriteObject(nil)
        end
    end

    return ser._flushWriter()
end

function LibSerialize:Serialize(...)
    return self:SerializeEx(defaultOptions, ...)
end

function LibSerialize:DeserializeValue(input)
    local deser = CreateDeserializer(input)

    -- Since there's only one compression version currently,
    -- no extra work needs to be done to decode the data.
    local version = deser:_ReadByte()
    assert(version <= DESERIALIZATION_VERSION, "Unknown serialization version!")

    -- Since the objects we read may be nil, we need to explicitly
    -- track the number of results and assign by index so that we
    -- can call unpack() successfully at the end.
    local output = {}
    local outputSize = 0

    while deser._readerBytesLeft() > 0 do
        outputSize = outputSize + 1
        output[outputSize] = deser:_ReadObject()
    end

    if deser._readerBytesLeft() < 0 then
        error("Reader went past end of input")
    end

    return unpack(output, 1, outputSize)
end

function LibSerialize:Deserialize(input)
    return pcall(self.DeserializeValue, self, input)
end

return LibSerialize
end)() or (LibStub and LibStub("LibSerialize",true))
-- Profile storage is deliberately bounded. Runtime caches never enter snapshots.
local P={MAX_CODE=65536,MAX_TOTAL=2097152,MAX_NAMED=32,MAX_CHARACTERS=64}
K.Profiles=P
local serializer=ProfileSerializer
P.LayoutSerializer=serializer
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local alphabetIndex={}; for i=1,64 do alphabetIndex[alphabet:sub(i,i)]=i-1 end
local function Encode64(input)
 local result={}
 for i=1,#input,3 do
  local a,b,c=input:byte(i,i+2); b=b or 0; c=c or 0
  local n=a*65536+b*256+c
  result[#result+1]=alphabet:sub(math.floor(n/262144)%64+1,math.floor(n/262144)%64+1)
  result[#result+1]=alphabet:sub(math.floor(n/4096)%64+1,math.floor(n/4096)%64+1)
  result[#result+1]=i+1<=#input and alphabet:sub(math.floor(n/64)%64+1,math.floor(n/64)%64+1) or "="
  result[#result+1]=i+2<=#input and alphabet:sub(n%64+1,n%64+1) or "="
 end
 return table.concat(result)
end
local function Decode64(input)
 if #input%4~=0 or input:find("[^A-Za-z0-9+/=]") then return end
 local result={}
 for i=1,#input,4 do
  local a,b,c,d=input:sub(i,i),input:sub(i+1,i+1),input:sub(i+2,i+2),input:sub(i+3,i+3)
  if not alphabetIndex[a] or not alphabetIndex[b] or (c=="=" and d~="=") then return end
  if (c=="=" or d=="=") and i+3~=#input then return end
  if c~="=" and not alphabetIndex[c] or d~="=" and not alphabetIndex[d] then return end
  local n=alphabetIndex[a]*262144+alphabetIndex[b]*4096+(alphabetIndex[c] or 0)*64+(alphabetIndex[d] or 0)
  result[#result+1]=string.char(math.floor(n/65536)%256)
  if c~="=" then result[#result+1]=string.char(math.floor(n/256)%256) end
  if d~="=" then result[#result+1]=string.char(n%256) end
 end
 local decoded=table.concat(result)
 if Encode64(decoded)~=input then return end -- reject noncanonical padding
 return decoded
end
local function Checksum(input)
 local a,b=1,0
 for i=1,#input do a=(a+input:byte(i))%65521; b=(b+a)%65521 end
 return string.format("%08x",b*65536+a)
end
local function Copy(t)
 if type(t)~="table" then return t end
 local out={}; for k,v in pairs(t) do out[k]=Copy(v) end; return out
end
local function N(low,high) return {kind="number",low=low,high=high} end
local B={kind="boolean"}
local function S(limit) return {kind="string",limit=limit or 160} end
local function Shape(fields) return {kind="table",fields=fields} end
local function Fields(booleans,numbers)
 local fields={}
 for key in booleans:gmatch("%S+") do fields[key]=B end
 for key,bounds in pairs(numbers or {}) do fields[key]=N(bounds[1],bounds[2]) end
 return fields
end
local position=Shape({x=N(-10000,10000),y=N(-10000,10000),detached=B});position.required={"x","y"}
local minimap=Shape({hide=B,minimapPos=N(-10000,10000)})
local bars={kind="bars"}
local schema={}
schema.root=Shape({fps=Shape(Fields("enabled locked",{x={-10000,10000},y={-10000,10000}})),soundShortcut=Shape(Fields("enabled locked",{size={24,64},x={0,1},y={0,1}})),bagShortcut=Shape(Fields("enabled locked",{size={24,80},x={0,1},y={0,1}})),actionRange=Shape({enabled=B,color={kind="rgb"}}),minimapButtons=Shape(Fields("enabled locked showTooltip",{buttonStyle={1,2},buttonSize={20,64},columns={1,12},iconSize={24,40},angle={-360,360},radius={0,80}})),minimapCoords=Shape(Fields("enabled outline",{x={-300,300},y={-300,300},size={8,32},font={0,2}})),experience=Shape(Fields("enabled locked showRep showPet showTime showRate showQuest showRested trim hideNative classColor",{frameSize={10,24},verticalSpace={0,120},backgroundAlpha={0,1},width={280,1400},barHeight={8,28},subHeight={8,20},layout={1,2},red={0,1},green={0,1},blue={0,1},x={-10000,10000},y={-10000,10000}})),nativeMeter=Shape(Fields("enabled trim",{trimAlpha={0,1},backgroundAlpha={0,1},padding={0,24},edgeTop={-24,48},edgeBottom={-24,48},edgeLeft={-24,48},edgeRight={-24,48}})),barSource=N(0,2),bagCombined=B,bagDock=B,hideNativeBagBar=B,bagJunk=B,bagQuality=B,bagExpanded=B,bagBackground=B,bagFrame=B,bagIconBorder=B,bagSize=N(18,48),bagGap=N(0,16),microEnabled=B,microLocked=B,microSize=N(18,48),microGap=N(0,16),microX=N(0,10000),microY=N(0,10000),hideNativeHotkeys=B,hideNativeMacroNames=B,hideActionBarStatues=B,hideErrors=B,keepImportantErrors=B,errorMode=N(1,3),errorFilters=Shape({target=B,movement=B,range=B,direction=B,cooldown=B,resources=B}),muteClicks=B,cvars={kind="cvars"},sounds={kind="sounds"},position=position,panelHeight=N(640,1100)})

schema.root.fields.minimapButtons.fields.excluded={kind="iconExclusions"}
schema.root.fields.experience.fields.labels=Shape({total=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),levelTime=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),xp=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),remaining=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),rate=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),reputation=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),pet=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)})})
schema.root.fields.experience.fields.colors=Shape({main={kind="rgb"},quest={kind="rgb"},rested={kind="rgb"},rep={kind="rgb"},pet={kind="rgb"}})
schema.appearance=Shape({scale=N(.3,2),cardGlow=B,glowStrength=N(0,1),glowRadius=N(4,20),glowColor={kind="rgb"},cardTone=N(.6,1.8),minimap=minimap})
local back=Fields("enabled",{shade={0,1},border={0,6},slotAlpha={0,1}});back.bars=bars;back.nativeLayout=Shape({bars=bars})
schema.ForeverBarBackdropCharacterDB=Shape(back)
local art=Fields("enabled backingEnabled hunterPetEnabled rogueBackingEnabled rogueDockBottom warlockBackingEnabled warlockDockBottom warlockRailEnabled",{warlockRailX={-150,150},warlockRailWidth={50,150},warlockBackingAlpha={0,1},warlockBottomInset={0,200},warlockRailY={-100,100},warlockRailHeight={8,48},gap={0,50},x={-10000,10000},y={-10000,10000},alpha={0,1},width={20,300},height={20,300},backingAlpha={0,1},backingPadding={0,20},backingRailHeight={1,50},backingRailY={-100,100},backingRailStyle={1,3},hunterPetPadding={0,30},rogueBackingAlpha={0,1},rogueBottomInset={-100,100}})
art.warriorSkin=N(1,2);art.warriorAction=N(1,4);art.backingRailEnabled=B;art.artSkin=N(1,2);art.warlockSkin=N(1,2);art.shamanSkin=N(1,2);art.paladinConnectedInitialized=B;art.paladinSkin=N(1,2);art.druidSkin=N(1,4);art.druidWildInitialized=B;art.priestSkin=N(1,2);art.mageSkin=N(1,4);art.mageAcademyInitialized=B
art.shamanLeftSpread=N(-80,160);art.shamanRightSpread=N(-80,160)
art.backingColorEnabled=B;art.backingColor={kind="rgb"}
art.shamanBackingEnabled=B;art.shamanRailEnabled=B;art.shamanBackingAlpha=N(0,1)
art.shamanRailX=N(-150,150);art.shamanRailY=N(-100,100);art.shamanRailWidth=N(50,150);art.shamanRailHeight=N(50,150)
art.mageLeftSpread=N(-80,160);art.mageRightSpread=N(-80,160)
art.mageBackingEnabled=B;art.mageRailEnabled=B;art.mageBackingAlpha=N(0,1)
art.mageRailX=N(-150,150);art.mageRailY=N(-100,100);art.mageRailWidth=N(50,150);art.mageRailHeight=N(50,150)
art.priestLeftSpread=N(-80,160);art.priestRightSpread=N(-80,160)
art.priestBackingEnabled=B;art.priestRailEnabled=B;art.priestBackingAlpha=N(0,1)
art.priestRailX=N(-150,150);art.priestRailY=N(-100,100);art.priestRailWidth=N(50,150);art.priestRailHeight=N(50,150)
art.druidLeftSpread=N(-80,160);art.druidRightSpread=N(-80,160)
art.druidBackingEnabled=B;art.druidRailEnabled=B;art.druidBackingAlpha=N(0,1)
art.druidRailX=N(-150,150);art.druidRailY=N(-100,100);art.druidRailWidth=N(50,150);art.druidRailHeight=N(50,150)
art.paladinLeftSpread=N(-80,160);art.paladinRightSpread=N(-80,160)
art.paladinBackingEnabled=B;art.paladinRailEnabled=B;art.paladinBackingAlpha=N(0,1)
art.paladinBottomHeight=N(30,100);art.paladinRailX=N(-150,150);art.paladinRailY=N(-100,100);art.paladinRailWidth=N(50,150);art.paladinRailHeight=N(50,150)
art.bars=bars;art.locked=Shape({left=N(-10000,10000),bottom=N(-10000,10000),width=N(1,10000),height=N(1,10000)})
art.locked.required={"left","bottom","width","height"}
art.nativeLayout=Shape({bars=bars,locked=art.locked,width=N(20,300),height=N(20,300),x=N(-10000,10000),y=N(-10000,10000),gap=N(0,50)})
schema.ForeverHunterArtCharacterDB=Shape(art)
schema.ForeverMinimapArtDB=Shape(Fields("enabled hideBorder hunterMatte warlockObsidianInitialized shamanElementInitialized mageAstralInitialized priestHaloInitialized druidWildInitialized",{size={80,130},x={-40,40},y={-40,40}}))
-- Keep legacy profile fields readable; petPanel* still stores the shared pet backing.
schema.ForeverHunterHUDDB=Shape(Fields("enabled units center hideResource petPanelEnabled",{petPanelPadding={0,12},petPanelAlpha={0,1},edge={8,20},padding={0,6},centerPadding={2,12},alpha={.2,1}}))
schema.ForeverQuestJournalDB=Shape(Fields("enabled showQuill scrollEnabled groupByZone",{opacity={.3,1},borderSize={4,12},scrollStep={12,120}}))
schema.ForeverQuestJournalDB.fields.collapsedZones={kind="iconExclusions"}
schema.ForeverDetailsHunterDB=Shape(Fields("showTrim keepFonts",{trimAlpha={.1,1},edgeTop={-24,48},edgeBottom={-24,48},edgeLeft={-24,48},edgeRight={-24,48}}))
schema.ForeverHunterRangeDB=Shape(Fields("enabled locked coloredText outline shadow",{width={150,420},height={28,60},fontSize={10,24},x={-2000,2000},y={-1200,1200}}))
for _,mode in ipairs({"ranged","dead","melee","far","close","unknown"}) do schema.ForeverHunterRangeDB.fields[mode.."Text"]=S(400) end
local threat=Fields("enabled locked autoColor raw showPercent bold outline shadow",{size={12,96},alpha={.2,1},x={-2000,2000},y={-1200,1200},r={0,1},g={0,1},b={0,1}});threat.font=S(160)
schema.ForeverThreatDB=Shape(threat)
schema.HunterAspectAlertCharacterDB=Shape({enabled=B,showText=B,cheetahGlow=B,locked=B,cheetahText=S(400),missingText=S(400),cheetahTextCustom=B,missingTextCustom=B,position={kind="anchor"}})
local moduleFor={ForeverBarBackdropCharacterDB="KerimAnkaUI_BarBackdrop",ForeverHunterArtCharacterDB="KerimAnkaUI_ClassArt",ForeverMinimapArtDB="KerimAnkaUI_ClassArt",ForeverHunterHUDDB="KerimAnkaUI_ClassArt",ForeverLeatherUnitsDB="KerimAnkaUI_UnitFrames",ForeverQuestJournalDB="KerimAnkaUI_QuestJournal",ForeverDetailsHunterDB="KerimAnkaUI_DetailsSkin",ForeverHunterRangeDB="KerimAnkaUI_HunterRange",ForeverThreatDB="KerimAnkaUI_Threat",HunterAspectAlertCharacterDB="KerimAnkaUI_AspectAlert"}
local cvars={cameraDistanceMaxZoomFactor={1,2.6},SpellQueueWindow={0,1000},ffxDeath={0,1}}
for _,option in ipairs(K.soundOptions) do cvars[option.cvar]={0,1} end
local anchors={TOP=true,TOPLEFT=true,TOPRIGHT=true,CENTER=true,LEFT=true,RIGHT=true,BOTTOM=true,BOTTOMLEFT=true,BOTTOMRIGHT=true}
local function Validate(value,spec,depth,budget)
 depth=depth or 0;budget=budget or {n=0}
 budget.n=budget.n+1; if depth>8 or budget.n>4000 then error("structure") end
 local kind=spec.kind
 if kind=="number" then
  if type(value)~="number" or value~=value or value<spec.low or value>spec.high then error("number") end
 elseif kind=="boolean" then if type(value)~="boolean" then error("boolean") end
 elseif kind=="string" then if type(value)~="string" or #value>spec.limit or value:find("%z") then error("string") end
 else
  if type(value)~="table" or getmetatable(value)~=nil then error("table") end
  if spec.required then for _,key in ipairs(spec.required) do if value[key]==nil then error("required field") end end end
  local count=0
  for key,child in pairs(value) do
   count=count+1; if count>4000 then error("entries") end
   if kind=="table" then
    local field=spec.fields[key]; if not field then error("field") end
    Validate(child,field,depth+1,budget)
   elseif kind=="cvars" then
    local bounds=cvars[key];local n=tonumber(child)
    if not bounds or (type(child)~="string" and type(child)~="number") or (type(child)=="string" and #child>32) or not n or n~=n or n<bounds[1] or n>bounds[2] then error("cvar") end
    if key~="cameraDistanceMaxZoomFactor" and key~="SpellQueueWindow" and n~=0 and n~=1 then error("boolean cvar") end
   elseif kind=="iconExclusions" then
    if type(key)~="string" or #key<1 or #key>160 or child~=true or count>128 then error("icon exclusions") end
   elseif kind=="sounds" then
    if type(key)~="number" or key%1~=0 or key<1 or key>2147483647 or child~=true or count>30 then error("sound") end
   elseif kind=="bars" then
    if type(key)~="number" or key%1~=0 or key<1 or key>10 or type(child)~="number" or child%1~=0 or child<1 or child>10 then error("bars") end
   elseif kind=="rgb" then
    if type(key)~="number" or key%1~=0 or key<1 or key>3 then error("rgb") end
    Validate(child,N(0,1),depth+1,budget)
   elseif kind=="anchor" then
    if key==1 or key==2 then if not anchors[child] then error("anchor") end
    elseif key==3 or key==4 then Validate(child,N(-10000,10000),depth+1,budget)
    else error("anchor") end
   else error("schema") end
  end
  if kind=="rgb" and count~=3 or kind=="anchor" and count~=4 then error("length") end
  if kind=="bars" and (count==0 or #value~=count) then error("bars") end
 end
 return value
end
function P.BuildSchema()
 local fields={warriorThemeInitialized=B,paladinThemeInitialized=B,compactMigration=B,hunterThemeInitialized=B,warlockThemeInitialized=B,shamanThemeInitialized=B,mageThemeInitialized=B,druidThemeInitialized=B,priestThemeInitialized=B,player=position,target=position,targettarget=position,pet=position}
 for _,f in ipairs(K.UnitProfileFields) do
  if f[1]~="section" and not f[1]:find("%.") then fields[f[1]]=f[5] and N(f[5],f[6]) or B end
 end
 -- Existing installations may predate panel limits; accept safe legacy values.
 fields.totScale=N(.3,3);fields.petScale=N(.3,2);fields.scale=N(.3,3)
 for _,key in ipairs({"textScale","healthTextScale","powerTextScale","levelTextScale","classificationTextScale"}) do fields[key]=N(.3,4) end
 fields.minimap=minimap
 schema.ForeverLeatherUnitsDB=Shape(fields)
end
local function Clean(value,spec)
 if spec.kind~="table" then return Copy(value) end
 local result={}
 for key,field in pairs(spec.fields) do
  if value[key]~=nil then result[key]=Clean(value[key],field) end
 end
 return result
end
function P.Validate(payload)
 if type(payload)~="table" or payload.app~="KerimAnkaUI" or payload.version~=1 or type(payload.class)~="string" or #payload.class>20 or type(payload.settings)~="table" then return false end
 local classes={HUNTER=true,ROGUE=true,MAGE=true,PRIEST=true,PALADIN=true,WARRIOR=true,WARLOCK=true,DRUID=true,SHAMAN=true,MONK=true,DEMONHUNTER=true,DEATHKNIGHT=true,EVOKER=true}
 if not classes[payload.class] then return false end
 for key in pairs(payload) do if key~="app" and key~="version" and key~="class" and key~="settings" then return false end end
 local ok=pcall(function()
  local budget={n=0}
  for key,value in pairs(payload.settings) do
   if not schema[key] then error("unknown module") end
   Validate(value,schema[key],0,budget)
  end
  if not payload.settings.root or not payload.settings.appearance then error("root") end
 end)
 return ok
end
function P.Encode(payload)
 if not P.Validate(payload) then return nil,"pfInvalid" end
 local ok,raw=pcall(serializer.Serialize,serializer,payload)
 if not ok or #raw>48000 then return nil,"pfTooLarge" end
 local code="KAUI1:"..Checksum(raw)..":"..Encode64(raw)
 if #code>P.MAX_CODE then return nil,"pfTooLarge" end
 return code
end
function P.Decode(code)
 if type(code)~="string" or #code>P.MAX_CODE+4096 then return nil,"pfTooLarge" end
 code=code:gsub("%s","")
 if #code>P.MAX_CODE then return nil,"pfTooLarge" end
 local sum,body=code:match("^KAUI1:([0-9a-f]+):([A-Za-z0-9+/=]+)$")
 if not sum or #sum~=8 then return nil,"pfInvalid" end
 local raw=Decode64(body)
 if not raw or #raw>48000 or Checksum(raw)~=sum then return nil,"pfInvalid" end
 local ok,value=serializer:Deserialize(raw)
 if not ok or not P.Validate(value) then return nil,"pfInvalid" end
 return value
end
local function Loaded(name)
 local fn=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 return fn and fn(name)
end
local function CharacterKey()
 local name,realm=UnitFullName("player")
 return (name or UnitName("player") or "?").." - "..(realm or GetRealmName() or "?")
end
local function Store()
 if type(KerimAnkaUIDB.profileStore)~="table" then KerimAnkaUIDB.profileStore={} end
 if type(KerimAnkaUIDB.profileStore.named)~="table" then KerimAnkaUIDB.profileStore.named={} end
 if type(KerimAnkaUIDB.profileStore.characters)~="table" then KerimAnkaUIDB.profileStore.characters={} end
 return KerimAnkaUIDB.profileStore
end
function P.Capture()
 local settings={root=Clean(K.db,schema.root),appearance=Clean(KerimAnkaUIDB,schema.appearance)}
 local prior=Store().characters[CharacterKey()]
 local previous=prior and P.Decode(prior.code)
 for name,addon in pairs(moduleFor) do
  if Loaded(addon) and type(_G[name])=="table" then settings[name]=Clean(_G[name],schema[name])
  elseif K.db.profileDeferred and K.db.profileDeferred[name] then settings[name]=Copy(K.db.profileDeferred[name])
  elseif previous then settings[name]=Copy(previous.settings[name]) end
 end
 return {app="KerimAnkaUI",version=1,class=select(2,UnitClass("player")),settings=settings}
end
local function Record(code,name)
 return {code=code,name=name,stamp=time(),class=select(2,UnitClass("player"))}
end
local function Count(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
function P.StorageBytes()
 local total=0
 for _,group in pairs({Store().named,Store().characters}) do for _,record in pairs(group) do total=total+#record.code+(type(record.layouts)=="string" and #record.layouts or 0) end end
 return total
end
local function OldestCharacter(except)
 local key,stamp
 for name,record in pairs(Store().characters) do
  if name~=except and (not stamp or record.stamp<stamp) then key,stamp=name,record.stamp end
 end
 return key
end
function P.Checkpoint(phase)
 if not K.db or not schema.ForeverLeatherUnitsDB or K.db.profileTransaction or P.failedApply then return end
 local code=P.Encode(P.Capture());if not code then return end
 local key=CharacterKey();local entries=Store().characters
 local prior=entries[key]
 entries[key]=Record(code,key)
 if K.ProfileLayouts then entries[key].layouts=K.ProfileLayouts.Capture(prior and prior.layouts,false,phase) end
 while Count(entries)>P.MAX_CHARACTERS or P.StorageBytes()>P.MAX_TOTAL do
  local old=OldestCharacter(key)
  if not old then entries[key]=nil;return end
  entries[old]=nil
 end
end
function P.Save(name)
 if K.db.profileTransaction then return false,"pfPendingProfile" end
 name=(name or ""):match("^%s*(.-)%s*$")
 if #name<1 or #name>48 or name:find("[%c|]") then return false,"pfBadName" end
 local entries=Store().named
 if entries[name] then return false,"pfExists" end
 if Count(entries)>=P.MAX_NAMED then return false,"pfFull" end
 local code,err=P.Encode(P.Capture());if not code then return false,err end
 local layouts=K.ProfileLayouts and K.ProfileLayouts.Capture()
 if P.StorageBytes()+#code+(layouts and #layouts or 0)>P.MAX_TOTAL then return false,"pfFull" end
 entries[name]=Record(code,name);entries[name].layouts=layouts;P.Checkpoint();return true
end
function P.Delete(group,key)
 local entries=Store()[group];if not entries or not entries[key] then return false end
 entries[key]=nil;return true
end
function P.Entries()
 P.Checkpoint()
 local result={}
 for _,group in ipairs({"named","characters"}) do
  local entries={};for key,record in pairs(Store()[group]) do entries[#entries+1]={group=group,key=key,record=record} end
  table.sort(entries,function(a,b) return a.key<b.key end)
  for _,entry in ipairs(entries) do result[#result+1]=entry end
 end
 return result
end
local function ReplaceTable(target,data)
 for key in pairs(target) do target[key]=nil end
 for key,value in pairs(data) do target[key]=Copy(value) end
end
local function ApplySettings(payload)
 local data=payload.settings
 -- Restore CVars previously controlled here but absent from the incoming profile.
 local setter=C_CVar and C_CVar.SetCVar or SetCVar
 K.db.originalCVars=K.db.originalCVars or {}
 for key in pairs(data.root.cvars or {}) do
  if K.db.originalCVars[key]==nil and K.GetCVar then K.db.originalCVars[key]=K.GetCVar(key) end
 end
 for key in pairs(K.db.cvars or {}) do
  if not (data.root.cvars or {})[key] and setter and K.db.originalCVars[key] then pcall(setter,key,K.db.originalCVars[key]) end
 end
 for key in pairs(schema.root.fields) do K.db[key]=nil end
 for key,value in pairs(data.root) do K.db[key]=Copy(value) end
 K.db.cvars=K.db.cvars or {};K.db.sounds=K.db.sounds or {}
 if K.ApplyCharacterAudio then K.ApplyCharacterAudio() end
 if K.BagMode then K.BagMode.ApplySaved() end
 if K.FPS then K.FPS.Refresh() end
 -- Core initializes sound state after the queued profile has been applied.
 for key in pairs(schema.appearance.fields) do KerimAnkaUIDB[key]=nil end
 for key,value in pairs(data.appearance) do KerimAnkaUIDB[key]=Copy(value) end
 K.db.profileDeferred={}
 for name,addon in pairs(moduleFor) do
  local value=data[name]
  if value then
   if Loaded(addon) then
    if type(_G[name])~="table" then _G[name]={} end
    ReplaceTable(_G[name],value)
   else K.db.profileDeferred[name]=Copy(value) end
  end
 end
end
local function Normalize(payload)
 local units=payload.settings.ForeverLeatherUnitsDB
 if units then
  -- Protocol v1 stores modern layouts. Never rerun one-time theme migrations.
  units.compactMigration=true
  if select(2,UnitClass("player"))=="HUNTER" then units.hunterThemeInitialized=true end
 end
 return payload
end
function P.Apply(code,label,layoutAction)
 if K.InCombat() then return false,"combatLock" end
 if K.HasPendingModuleChanges(true) then return false,"pfPending" end
 if K.db.profileTransaction then return false,"pfPendingProfile" end
 local payload,err=P.Decode(code);if not payload then return false,err end
 payload=Normalize(payload)
 local after,afterError=P.Encode(payload);if not after then return false,afterError end
 local before,beforeError=P.Encode(P.Capture());if not before then return false,beforeError end
 local fullLayout
 if layoutAction then
  local ok,value,layoutError=pcall(K.FullLayout.Prepare,layoutAction)
  if not ok then return false,"flFailed" end
  if not value then return false,layoutError end
  fullLayout=value
 end
 -- Stage only. No live DB mutation and no protected reload API call.
 K.db.profileTransaction={version=1,before=before,after=after,label=label or K.L("pfBeforeApply"),stamp=time()}
 K.db.profileTransaction.fullLayout=fullLayout
 if K.Message then K.Message("pfQueued") end
 return true,"pfQueued"
end
function P.RestoreBackup()
 if not K.db.profileBackup then return false,"pfNoBackup" end
 if K.db.profileBackup.layouts and K.ProfileLayouts then return K.ProfileLayouts.Queue(K.db.profileBackup,K.L("pfBeforeRestore")) end
 return P.Apply(K.db.profileBackup.code,K.L("pfBeforeRestore"),K.db.profileBackup.fullLayout and {mode="restore",target=K.db.profileBackup.fullLayout,setupRestore=K.db.profileBackup.classSetup})
end
function P.CancelPending()
 if P.active then return false end
 if K.ClassPresets and K.ClassPresets.CancelPreparedReload and not K.ClassPresets.CancelPreparedReload() then return false end
 K.db.profileTransaction=nil;return true
end
local function Match(expected,actual)
 if type(expected)~="table" then return expected==actual end
 if type(actual)~="table" then return false end
 for key,value in pairs(expected) do if not Match(value,actual[key]) then return false end end
 return true
end
function P.BeginTransaction()
 local transaction=K.db.profileTransaction
 if not transaction then return end
 if type(transaction)~="table" or transaction.version~=1 then K.db.profileTransaction=nil;P.failedApply=true;return end
 local before=P.Decode(transaction.before);local after=P.Decode(transaction.after)
 if not before or not after then K.db.profileTransaction=nil;P.failedApply=true;return end
 P.active=transaction;P.activeBefore=before;P.activeAfter=Normalize(after)
 ApplySettings(P.activeAfter)
end
-- Called after a child's SavedVariables load, before its PLAYER_LOGIN initializer.
function P.OnAddonLoaded(addon)
 if not K.db or not K.db.profileDeferred then return end
 for name,owner in pairs(moduleFor) do
  local value=K.db.profileDeferred[name]
  if owner==addon and value then
   local backup=P.activeBefore or (K.db.profileBackup and P.Decode(K.db.profileBackup.code))
   if backup and not backup.settings[name] then
    backup.settings[name]=Clean(type(_G[name])=="table" and _G[name] or {},schema[name])
    local code=P.Encode(backup)
    if not code then P.deferredError=true;return end
    if P.active then P.active.before=code else K.db.profileBackup.code=code end
   end
   if name=="ForeverLeatherUnitsDB" then
    value.compactMigration=true
    if select(2,UnitClass("player"))=="HUNTER" then value.hunterThemeInitialized=true end
   end
   if type(_G[name])~="table" then _G[name]={} end
   ReplaceTable(_G[name],value);K.db.profileDeferred[name]=nil
  end
 end
end
function P.CommitTransaction()
 if not P.active then return end
 local transaction=P.active
 if (transaction.fullLayout or transaction.savedLayouts) and InCombatLockdown() then P.layoutWaiting=true;return end
 local valid=true
 for name,owner in pairs(moduleFor) do
  local expected=P.activeAfter.settings[name]
  if expected and Loaded(owner) and not Match(expected,_G[name]) then valid=false end
 end
 -- The pre-application snapshot is authoritative even if a native initializer fails.
 K.db.profileBackup=Record(transaction.before,transaction.label)
 if transaction.fullLayout then K.db.profileBackup.fullLayout=Copy(transaction.fullLayout.before);K.db.profileBackup.classSetup=Copy(transaction.fullLayout.setupBefore) end
 K.db.profileTransaction=nil;P.active=nil;P.activeBefore=nil;P.activeAfter=nil
 if not valid then P.failedApply=true;return end
 if transaction.fullLayout and not K.FullLayout.Commit(transaction) then P.failedApply=true;return end
 if transaction.savedLayouts and K.ProfileLayouts and not K.ProfileLayouts.Commit(transaction) then
  if transaction.fullLayout then pcall(K.FullLayout.Apply,{mode="restore",target=transaction.fullLayout.before,setupRestore=transaction.fullLayout.setupBefore}) end
  P.failedApply=true;return
 end
 P.applied=true
end
function P.Initialize()
 P.BuildSchema();Store()
 local test=pcall(P.SelfTest)
 if not test then P.failed=true;P.ready=true;return end
 P.ready=true
 for _,group in ipairs({"named","characters"}) do
  for key,record in pairs(Store()[group]) do
   if type(key)~="string" or type(record)~="table" or type(record.code)~="string" or #record.code>P.MAX_CODE or type(record.stamp)~="number" then Store()[group][key]=nil end
  end
 end
 P.CommitTransaction()
 P.Checkpoint("login")
end
function P.SelfTest()
 for length=0,260 do
  local bytes={};for i=1,length do bytes[i]=string.char((i*71+length)%256) end
  local raw=table.concat(bytes);assert(Decode64(Encode64(raw))==raw,"base64 roundtrip")
 end
 assert(not Decode64("A==="));assert(not Decode64("AA=A"));assert(not Decode64("AB=="))
 local sample={app="KerimAnkaUI",version=1,class="HUNTER",settings={root={hideErrors=false,cvars={SpellQueueWindow="120"},sounds={[567407]=true}},appearance={glowColor={0,.5,1}},ForeverBarBackdropCharacterDB={enabled=true,bars={1,3,4},shade=.25}}}
 local code=assert(P.Encode(sample));local value=assert(P.Decode(code))
 assert(value.settings.root.hideErrors==false and value.settings.ForeverBarBackdropCharacterDB.bars[2]==3)
 assert(not P.Decode(code:sub(1,-2)),"truncated profile")
 assert(not P.Decode("KAUI2:"..code:sub(7)),"unknown version")
 assert(not P.Decode(code:sub(1,-3).."**"),"invalid alphabet")
 sample.settings.root.cvars.badCVar="1";assert(not P.Encode(sample),"cvar allowlist");sample.settings.root.cvars.badCVar=nil
 sample.settings.ForeverBarBackdropCharacterDB.shade="1";assert(not P.Encode(sample),"type validation")
 sample.settings.ForeverBarBackdropCharacterDB.shade=2;assert(not P.Encode(sample),"range validation")
 sample.settings.ForeverBarBackdropCharacterDB.shade=.2;sample.settings.root.fn=function() end;assert(not P.Encode(sample),"executable data rejected")
 return true
end
local profileEvents=CreateFrame("Frame")
profileEvents:RegisterEvent("PLAYER_LOGIN");profileEvents:RegisterEvent("PLAYER_LOGOUT");profileEvents:RegisterEvent("ADDON_LOADED")
profileEvents:SetScript("OnEvent",function(_,event,addon)
 if event=="PLAYER_LOGIN" then C_Timer.After(0,function() P.Initialize() end)
 elseif event=="PLAYER_LOGOUT" then P.Checkpoint("logout")
 elseif event=="ADDON_LOADED" then
  -- Parent SavedVariables have loaded; seed the deferred queue before children load.
  if addon==K.name and type(KerimAnkaUICharacterDB)=="table" then
   K.db=KerimAnkaUICharacterDB;P.BuildSchema()
   local ok=pcall(P.BeginTransaction);if not ok then P.failedApply=true end
  end
  if schema.ForeverLeatherUnitsDB then P.OnAddonLoaded(addon) end
 end
end)

end

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

-- Native inventory shelf and micro-menu layout. No action-button attributes or slots.
do
local M={};K.InventoryMenus=M
local bagState,microState,bagRow,bagToggle,microArt,mover,hiddenNativeBar
local busy=false;local pending=false;local queued=false;local hooked={}
local defaults={bagCombined=true,bagDock=true,bagExpanded=true,bagBackground=true,bagFrame=true,bagIconBorder=false,bagSize=30,bagGap=3,hideNativeBagBar=true,bagJunk=true,bagQuality=true,microEnabled=true,microSize=28,microGap=1,microLocked=true}
local excludedBags={};local hiddenItems={}
local iconBorders=setmetatable({},{__mode="k"})
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
local function Combined()
 local manager=ContainerFrameSettingsManager
 if manager and manager.IsUsingCombinedBags then return manager:IsUsingCombinedBags() end
 return false
end
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
local function Tip(button,key)
 button:SetScript("OnEnter",function(self)
  GameTooltip:SetOwner(self,"ANCHOR_TOP");GameTooltip:SetText(K.L(key),1,.83,.45);GameTooltip:Show()
 end)
 button:SetScript("OnLeave",function() GameTooltip:Hide() end)
end
local function Queue()
 if busy then return end
 if Combat() then pending=true;if M.RestoreBagPlacement then M.RestoreBagPlacement() end;return end
 if queued then return end
 queued=true
 C_Timer.After(0,function() queued=false;M.Refresh() end)
end
local function BagChanged()
 if busy then return end
 -- Cursor updates are synchronous. Repair before control returns to the UI,
 -- rather than allowing native anchors/bar visibility to render for one frame.
 if M.RestoreBagPlacement and M.RestoreBagPlacement() then return end
 if M.ApplyNativeBagHide and M.ApplyNativeBagHide() then return end
 Queue()
end
local function Hook(frame,method,callback)
 if frame and type(frame[method])=="function" then
  local methods=hooked[frame];if not methods then methods={};hooked[frame]=methods end
  if not methods[method] then methods[method]=true;hooksecurefunc(frame,method,callback or Queue) end
 end
end
local function BagButtons()
 local list={}
 for _,name in ipairs({"MainMenuBarBackpackButton","CharacterBag0Slot","CharacterBag1Slot","CharacterBag2Slot","CharacterBag3Slot","CharacterReagentBag0Slot","KeyRingButton"}) do
  local frame=_G[name]
  if frame then list[#list+1]=frame end
 end
 return list
end
local function ApplyBagFilter(clear)
 local container=ContainerFrameCombinedBags
 local active={}
 for _,item in ipairs(container and container.Items or {}) do
  active[item]=true
  local id=item.GetBagID and item:GetBagID()
  if not clear and id~=nil and excludedBags[id] and not Protected(item) then
   if item:IsShown() then hiddenItems[item]=true;item:Hide() end
  elseif hiddenItems[item] and not Protected(item) then item:Show();hiddenItems[item]=nil end
 end
 -- Pooled buttons no longer belonging to the window must never be resurrected.
 for item in pairs(hiddenItems) do if not active[item] then hiddenItems[item]=nil end end
end
local function BagID(button)
 if button==MainMenuBarBackpackButton then return 0 end
 if button.GetBagID then return button:GetBagID() end
 for i=0,3 do if button==_G["CharacterBag"..i.."Slot"] then return i+1 end end
 if button==CharacterReagentBag0Slot then return Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag or 5 end
 if button==KeyRingButton then return Enum and Enum.BagIndex and Enum.BagIndex.Keyring or KEYRING_CONTAINER end
end
local function InstallBagClick(state)
 local button=state.frame
 state.alpha=button:GetAlpha()
 state.checked=button.GetChecked and button:GetChecked()
 state.click=button:GetScript("OnClick")
 state.wrapper=function(self,mouse,down)
  local special=(CursorHasItem and CursorHasItem()) or (IsModifiedClick and IsModifiedClick())
  local id=BagID(self)
  if bagState and Combined() and id~=nil and not special and M.ToggleCompanion and M.ToggleCompanion(id) then return end
  -- Only bags actually included by Blizzard can be filtered here. Reagent
  -- and keyring buttons must retain their native separate-window click.
  local included=id~=nil and ContainerFrameSettingsManager and ContainerFrameSettingsManager:IsUsingCombinedBags(id)
  if bagState and Combined() and included and not special then
   if Combat() then
    for _,item in ipairs(ContainerFrameCombinedBags.Items or {}) do if Protected(item) then return end end
   end
   excludedBags[id]=not excludedBags[id] or nil
   ApplyBagFilter(false)
   M.Refresh()
   return
  end
  if state.click then return state.click(self,mouse,down) end
 end
 button:SetScript("OnClick",state.wrapper)
end
local function ReleaseBags()
 ApplyBagFilter(true);excludedBags={}
 if bagState then
  for _,state in ipairs(bagState.buttons) do
   if state.frame:GetScript("OnClick")==state.wrapper then state.frame:SetScript("OnClick",state.click) end
   if iconBorders[state.frame] then for _,edge in ipairs(iconBorders[state.frame]) do edge:Hide() end end
   state.frame:SetAlpha(state.alpha)
   if state.frame.SetChecked then state.frame:SetChecked(state.checked) end
   if state.frame:GetParent()==bagRow then Restore(state);state.frame:SetShown(state.shown) end
  end
  if not BT() then bagState.bar:SetShown(bagState.shown) end
  bagState=nil
  if not BT() and BagsBar.Layout then BagsBar:Layout() end
 end
 if bagRow then bagRow:Hide() end
 if bagToggle then bagToggle:Hide() end
end
local function CopyTexture(target,source)
 if not source then return false end
 local atlas=source.GetAtlas and source:GetAtlas()
 local file=source.GetTexture and source:GetTexture()
 if atlas and atlas~="" then target:SetAtlas(atlas)
 elseif file then target:SetTexture(file)
 else return false end
 if source.GetTexCoord then target:SetTexCoord(source:GetTexCoord()) end
 if source.GetVertexColor then target:SetVertexColor(source:GetVertexColor()) end
 target:SetAlpha(source.GetAlpha and source:GetAlpha() or 1)
 return true
end
local function MatchBagSurface(container)
 local bg=container.Bg or container.Background
 local source=bg and (bg.TopSection or bg)
 if not CopyTexture(bagRow.surface,source) then
  bagRow.surface:SetVertexColor(1,1,1,1);bagRow.surface:SetAlpha(1)
  bagRow.surface:SetColorTexture(.12,.12,.12,.82)
 elseif bg~=source and bg.GetAlpha then
  bagRow.surface:SetAlpha((source.GetAlpha and source:GetAlpha() or 1)*bg:GetAlpha())
 end
 local slice=container.NineSlice
 local borders=bagRow.nativeBorders
 for _,entry in ipairs({{"TopEdge","TopEdge"},{"LeftEdge","LeftEdge"},{"RightEdge","RightEdge"}}) do
  local texture=borders[entry[1]]
  local copied=CopyTexture(texture,slice and slice[entry[2]])
  texture:SetShown(copied)
 end
 for _,side in ipairs({"Left","Right"}) do
  local sourceCorner=slice and slice["Bottom"..side.."Corner"]
  local target=borders["Top"..side.."Corner"]
  local copied=CopyTexture(target,sourceCorner)
  if copied and sourceCorner.GetTexCoord then
   local uv={sourceCorner:GetTexCoord()}
   if #uv==8 then target:SetTexCoord(uv[3],uv[4],uv[1],uv[2],uv[7],uv[8],uv[5],uv[6])
   elseif #uv==4 then target:SetTexCoord(uv[1],uv[2],uv[4],uv[3]) end
  end
  target:SetShown(copied)
 end
 -- A complete backing rim stays visible even when one native edge is missing
 -- or mostly transparent. The original title border forms the lower seam.
 bagRow.surface:SetShown(M.Get("bagBackground")==true)
 if not M.Get("bagFrame") then for _,edge in pairs(borders) do edge:Hide() end end
 bagRow:SetBackdropBorderColor(.43,.32,.16,M.Get("bagFrame") and 1 or 0)
end
local function BagIconBorder(button)
 local edges=iconBorders[button]
 if not edges and M.Get("bagIconBorder") then
  edges={};iconBorders[button]=edges
  for i,side in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
   local edge=button:CreateTexture(nil,"OVERLAY",nil,7)
   edge:SetColorTexture(0,0,0,1)
   if side=="TOP" or side=="BOTTOM" then
    edge:SetPoint(side.."LEFT",button,side.."LEFT");edge:SetPoint(side.."RIGHT",button,side.."RIGHT")
   else
    edge:SetPoint("TOP"..side,button,"TOP"..side);edge:SetPoint("BOTTOM"..side,button,"BOTTOM"..side)
   end
   edges[i]=edge
  end
 end
 if edges then
  local width=2/button:GetScale()
  for i,edge in ipairs(edges) do
   if i<=2 then edge:SetHeight(width) else edge:SetWidth(width) end
   edge:SetShown(M.Get("bagIconBorder")==true)
  end
 end
end
local function MakeBagUI(container)
 if bagRow then return end
 bagRow=CreateFrame("Frame","KerimAnkaUIBagShelf",container,"BackdropTemplate")
 -- This extension follows the bag edges; it must not clamp away independently.
 bagRow:SetClampedToScreen(false);Skin(bagRow)
 bagRow:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=3})
 bagRow:SetBackdropColor(0,0,0,0)
 bagRow.surface=bagRow:CreateTexture(nil,"BACKGROUND")
 bagRow.surface:SetPoint("TOPLEFT",3,-3);bagRow.surface:SetPoint("BOTTOMRIGHT",-3,0)
 bagRow.nativeBorders={}
 local top=bagRow:CreateTexture(nil,"BORDER");top:SetHeight(8)
 top:SetPoint("TOPLEFT",12,0);top:SetPoint("TOPRIGHT",-12,0);bagRow.nativeBorders.TopEdge=top
 for _,key in ipairs({"LeftEdge","RightEdge"}) do
  local edge=bagRow:CreateTexture(nil,"BORDER");edge:SetWidth(8)
  edge:SetPoint(key=="LeftEdge" and "TOPLEFT" or "TOPRIGHT",0,-12)
  edge:SetPoint(key=="LeftEdge" and "BOTTOMLEFT" or "BOTTOMRIGHT",0,0)
  bagRow.nativeBorders[key]=edge
 end
 for _,side in ipairs({"Left","Right"}) do
  local corner=bagRow:CreateTexture(nil,"BORDER",nil,1);corner:SetSize(16,16)
  corner:SetPoint("TOP"..side)
  bagRow.nativeBorders["Top"..side.."Corner"]=corner
 end
 bagRow:SetPoint("BOTTOMLEFT",container,"TOPLEFT",0,-1)
 bagRow:SetPoint("BOTTOMRIGHT",container,"TOPRIGHT",0,-1)
 bagToggle=CreateFrame("Button","KerimAnkaUIBagShelfToggle",container,"BackdropTemplate")
 bagToggle:SetSize(24,22);Skin(bagToggle)
 bagToggle:EnableMouse(true)
 bagToggle:RegisterForClicks("LeftButtonUp")
 bagToggle:SetHitRectInsets(0,0,0,0)
 if bagToggle.SetPropagateMouseClicks then bagToggle:SetPropagateMouseClicks(false) end
 if bagToggle.SetPropagateMouseMotion then bagToggle:SetPropagateMouseMotion(false) end
 bagToggle:SetFrameLevel(container:GetFrameLevel()+20)
 local icon=bagToggle:CreateTexture(nil,"ARTWORK");icon:SetPoint("TOPLEFT",4,-3);icon:SetPoint("BOTTOMRIGHT",-4,3)
 icon:SetTexture("Interface\\Icons\\INV_Misc_Bag_08");bagToggle.icon=icon
 Tip(bagToggle,"imBagToggleHelp")
 bagToggle:SetScript("OnClick",function() M.Set("bagExpanded",not M.Get("bagExpanded")) end)
 container:HookScript("OnShow",Queue)
 container:HookScript("OnSizeChanged",Queue)
 Hook(container,"UpdateItemLayout");Hook(container,"UpdateItems")
 -- Parent visibility handles closing bags, including during combat, without polling.
end
local function ApplyBags()
 local container=ContainerFrameCombinedBags
 local enabled=M.Get("bagDock") and not BT() and not Editor() and NativeBags() and container and BagsBar and not Protected(BagsBar)
 if not enabled then ReleaseBags();return end
 local list=BagButtons()
 if #list==0 then ReleaseBags();return end
 for _,button in ipairs(list) do if Protected(button) then ReleaseBags();return end end
 MakeBagUI(container)
 MatchBagSurface(container)
 if not bagState then
  bagState={bar=BagsBar,shown=BagsBar:IsShown(),buttons={}}
  if hiddenNativeBar then bagState.shown=hiddenNativeBar.shown;hiddenNativeBar=nil end
  for _,button in ipairs(list) do
   local state=Snap(button);InstallBagClick(state);bagState.buttons[#bagState.buttons+1]=state
  end
 end
 Hook(BagsBar,"Layout",BagChanged);Hook(MainMenuBarBagManager,"OnExpandBarChanged",BagChanged)
 if not hooked.bagShow then BagsBar:HookScript("OnShow",BagChanged);hooked.bagShow=true end
 BagsBar:Hide()
 local expanded=Combined() and M.Get("bagExpanded")
 local size=M.Get("bagSize");local gap=M.Get("bagGap");local x=8;local count=0;local row=0
 local width=math.max(50,container:GetWidth())
 for _,state in ipairs(bagState.buttons) do
  local button=state.frame
  -- Never create a keyring on clients where Blizzard keeps it unavailable.
  local include=button~=KeyRingButton or state.shown
  if include then
   button:SetParent(bagRow)
   local height=button:GetHeight();local scale=height>0 and size/height or 1
   local buttonWidth=button:GetWidth()*scale
   if x>8 and x+buttonWidth>width-8 then x=8;row=row+1 end
   button:SetScale(scale);button:ClearAllPoints();button:SetPoint("TOPLEFT",bagRow,"TOPLEFT",x/scale,-(5+row*(size+gap))/scale)
   state.placement={scale=scale,point={"TOPLEFT",bagRow,"TOPLEFT",x/scale,-(5+row*(size+gap))/scale}}
   BagIconBorder(button)
   button:Show();x=x+buttonWidth+gap;count=count+1
   local id=BagID(button)
   local excluded=id~=nil and (excludedBags[id] or M.IsCompanionHidden and M.IsCompanionHidden(id))
   button:SetAlpha(excluded and .35 or 1)
   if button.SetChecked then button:SetChecked(not excluded) end
  end
 end
 bagRow:SetSize(width,(row+1)*size+row*gap+10)
 bagRow:SetShown(expanded==true)
 bagToggle:ClearAllPoints()
 local close=container.CloseButton or _G[container:GetName().."CloseButton"]
 -- Blizzard routes clicks across the title bar to its portrait dropdown. Keep
 -- only this small button above that router, without modifying the native menu.
 local level=container:GetFrameLevel()+2
 for _,child in ipairs({container:GetChildren()}) do
  if child~=bagToggle and child~=bagRow then level=math.max(level,child:GetFrameLevel()+2) end
 end
 bagToggle:SetFrameLevel(level)
 if container.GetFrameStrata then bagToggle:SetFrameStrata(container:GetFrameStrata()) end
 if close then bagToggle:SetPoint("RIGHT",close,"LEFT",-4,0)
 else bagToggle:SetPoint("TOPRIGHT",container,"TOPRIGHT",-30,0) end
 bagToggle:SetShown(Combined()==true)
 bagToggle.icon:SetAlpha(M.Get("bagExpanded") and 1 or .45)
 ApplyBagFilter(not Combined())
end
function M.RestoreBagPlacement()
 -- Cursor item changes make Blizzard lay out its bag bar even during combat.
 -- Reapply only existing, unprotected bag cosmetics; never touch the micro menu,
 -- handlers, protected buttons or initialize a layout while combat is active.
 if busy or not bagState or not bagRow or not M.Get("bagDock") or BT() or Editor() or not NativeBags() then return false end
 if Protected(bagRow) or Protected(bagToggle) or Protected(bagState.bar) then return false end
 for _,state in ipairs(bagState.buttons) do if state.placement and Protected(state.frame) then return false end end
 busy=true
 for _,state in ipairs(bagState.buttons) do
  local p=state.placement;local button=state.frame
  if p then
   if button:GetParent()~=bagRow then button:SetParent(bagRow) end
   if button:GetScale()~=p.scale then button:SetScale(p.scale) end
   local point={button:GetPoint(1)};local same=button:GetNumPoints()==1
   for i=1,5 do if point[i]~=p.point[i] then same=false;break end end
   if not same then button:ClearAllPoints();button:SetPoint(unpack(p.point)) end
   if not button:IsShown() then button:Show() end
  end
 end
 if bagState.bar:IsShown() then bagState.bar:Hide() end
 bagRow:SetShown(Combined() and M.Get("bagExpanded"))
 bagToggle:SetShown(Combined()==true)
 bagToggle.icon:SetAlpha(M.Get("bagExpanded") and 1 or .45)
 ApplyBagFilter(not Combined())
 busy=false;return true
end
function M.ApplyNativeBagHide()
 local bar=BagsBar
 if not bar or Protected(bar) then return false end
 if M.Get("hideNativeBagBar") and not BT() and not Editor() then
  if not bagState then
   if not hiddenNativeBar then hiddenNativeBar={frame=bar,shown=bar:IsShown()} end
   Hook(bar,"Layout",BagChanged)
   if not hooked.bagShow then bar:HookScript("OnShow",BagChanged);hooked.bagShow=true end
   local previousBusy=busy;busy=true
   if bar:IsShown() then bar:Hide() end
   busy=previousBusy
  end
  return true
 end
 if hiddenNativeBar then
  local old=hiddenNativeBar;hiddenNativeBar=nil
  if not bagState and not BT() then
   local previousBusy=busy;busy=true;old.frame:SetShown(old.shown);busy=previousBusy
  end
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
 MicroMenu.oldGridSettings=nil
 if MicroMenu.MarkDirty then MicroMenu:MarkDirty() end
 MicroMenu:Layout()
 -- Never show UIHider itself: it also contains Blizzard's action bars.
 if MicroMenuContainer.ShowBase then MicroMenuContainer:ShowBase() else MicroMenuContainer:Show() end
 if MicroMenu.ShowBase then MicroMenu:ShowBase() else MicroMenu:Show() end
 return true
end

local function ApplyMicro()
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
 local height=buttons[1]:GetHeight();local scale=M.Get("microSize")/math.max(1,height)
 MicroMenuContainer:SetScale(1)
 MicroMenu.childXPadding=M.Get("microGap")/scale;MicroMenu.childYPadding=0
 MicroMenu.isHorizontal=true;MicroMenu.isStacked=false;MicroMenu.layoutFramesGoingRight=true;MicroMenu.layoutFramesGoingUp=false;MicroMenu.stride=#buttons
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
 x=math.max(4,math.min(x,math.max(4,UIParent:GetWidth()-width-4)))
 y=math.max(4,math.min(y,math.max(4,UIParent:GetHeight()-h-4)))
 MicroMenuContainer:ClearAllPoints();MicroMenuContainer:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",x,y)
 MicroMenuContainer:SetSize(width,h)
 MicroMenu:ClearAllPoints();MicroMenu:SetPoint("BOTTOMLEFT",MicroMenuContainer,"BOTTOMLEFT",0,0)
 microArt:Show()
 mover:SetSize(math.max(150,width),18);mover:ClearAllPoints();mover:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",x,y+h+2)
 mover.menuHeight=h
 mover.label:SetText(K.L("imMove"));mover:SetShown(not M.Get("microLocked"))
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
 if Combat() then pending=true;if mover then mover:Hide() end;M.RestoreBagPlacement();M.ApplyNativeBagHide();return end
 busy=true;pending=false
 WatchBartender();WatchMicro()
 ApplyBags();M.ApplyNativeBagHide();ApplyMicro()
 busy=false
end
local ranges={bagSize={18,48},bagGap={0,16},microSize={18,48},microGap={0,16},microX={0,10000},microY={0,10000}}
function M.Set(key,value)
 if not K.db then return false end
 if Combat() then
  if key~="bagExpanded" or not bagState or Protected(bagRow) or Protected(bagToggle) then return false end
  K.db.bagExpanded=value==true;return M.RestoreBagPlacement()
 end
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
  choice.button:SetEnabled(value~=nil and not InCombatLockdown())
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
local started,applying,queued,pending=false,false,false,false
local attempts=0;local settingHooks={};local cvarHooked=false
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function Bool(v)
 if v==true or v==1 or v=='1' then return true end
 if v==false or v==0 or v=='0' then return false end
end
local function Replacement()
 local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 return loaded and (loaded('Bagnon') or loaded('AdiBags') or loaded('BetterBags'))
end
function M.Get()
 if K.db and type(K.db.bagCombined)=='boolean' then return K.db.bagCombined end
 return true
end
local function Actual()
 local getter=C_CVar and C_CVar.GetCVar or GetCVar
 if getter then local ok,value=pcall(getter,'combinedBags');if ok then return Bool(value) end end
end
local function Runtime()
 local manager=ContainerFrameSettingsManager
 if manager and manager.IsUsingCombinedBags then return Bool(manager:IsUsingCombinedBags()) end
end
local Queue
local function Remember(value)
 value=Bool(value)
 if value==nil or not started or applying or not K.db or Replacement() then return end
 K.db.bagCombined=value;attempts=0;pending=true;Queue()
end
local function Hooks()
 if type(hooksecurefunc)~='function' then return end
 -- Record explicit native UI intent, rather than adopting every CVar reset.
 -- The bag portrait menu calls SetCVar; the Settings checkbox calls SetValue.
 if not cvarHooked and type(SetCVar)=='function' then
  cvarHooked=true
  hooksecurefunc('SetCVar',function(name,value)
   if type(name)=='string' and name:lower()=='combinedbags' then Remember(value) end
  end)
 end
 local setting=Settings and Settings.GetSetting and Settings.GetSetting('combinedBags')
 if setting and type(setting.SetValue)=='function' and not settingHooks[setting] then
  settingHooks[setting]=true
  hooksecurefunc(setting,'SetValue',function(_,value) Remember(value) end)
 end
end
local function Apply()
 if not started or not K.db or not pending or Combat() or Replacement() then return end
 Hooks()
 local desired=M.Get();local manager=ContainerFrameSettingsManager
 local setter=C_CVar and C_CVar.SetCVar or SetCVar
 if setter and Actual()~=nil and manager and type(manager.OnCombinedBagSettingChanged)=='function' then
  applying=true
  local ok,err=pcall(function()
   if Actual()~=desired then setter('combinedBags',desired and '1' or '0') end
   if Actual()==desired and Runtime()~=desired then
    -- Native path closes/reopens existing bags and invalidates its enumerator.
    -- Merely setting the checkbox/CVar leaves a stale runtime mode on some builds.
    manager:OnCombinedBagSettingChanged(desired)
   end
  end)
  applying=false
  M.lastError=not ok and tostring(err) or nil
  if ok and Actual()==desired and Runtime()==desired then
   pending=false;attempts=0
   if K.InventoryMenus then K.InventoryMenus.Refresh() end
   if K.RefreshBagCompanions then K.RefreshBagCompanions() end
   return
  end
 end
 attempts=attempts+1
 if attempts<20 then Queue(.25) end
end
Queue=function(delay)
 if queued or Combat() or Replacement() or not started then return end
 queued=true
 C_Timer.After(delay or 0,function() queued=false;Apply() end)
end
function M.ApplySaved()
 if not K.db then return end
 if type(K.db.bagCombined)~='boolean' then K.db.bagCombined=true end
 started=true;attempts=0;pending=true;Hooks();Queue()
end
function M.Set(value)
 if not K.db or Combat() or type(value)~='boolean' then return false end
 K.db.bagCombined=value;M.ApplySaved();return true
end
local previous=K.InventoryMenus.Set
function K.InventoryMenus.Set(key,value)
 if key=='bagCombined' then return M.Set(value) end
 return previous(key,value)
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_REGEN_ENABLED','ADDON_LOADED','SETTINGS_LOADED','CVAR_UPDATE','USE_COMBINED_BAGS_CHANGED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(_,event,name)
 if event=='PLAYER_LOGIN' then M.ApplySaved();return end
 if not started then return end
 Hooks()
 if event=='CVAR_UPDATE' then
  if applying or type(name)~='string' or name:lower()~='combinedbags' then return end
 elseif event=='USE_COMBINED_BAGS_CHANGED' and applying then return end
 if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_REGEN_ENABLED' or event=='ADDON_LOADED' or event=='SETTINGS_LOADED'
  or Actual()~=M.Get() or Runtime()~=M.Get() then
  pending=true;attempts=0;Queue()
 end
end)
end
