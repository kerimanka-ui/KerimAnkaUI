-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local choices={}
local function Refresh()
 C_Timer.After(0,function() if K.window and K.window:IsShown() then K.Render() end end)
end
local function Report(ok,err,id)
 if not ok then print("|cffb6ce96KerimAnka UI:|r "..K.L("dtFailed").." #"..tostring(id).." · "..tostring(err)) end
end
function K.DrawDetailsPage(page)
 local api=ForeverDetailsHunterAPI
 if not api or api.version<1 then return false end
 local db=api.GetSettings()
 local w=K.UnitWidgets
 w.Text(page,K.L("dtNote"),8,0,690,13,{.65,.70,.62})
 local y=-74
 for i,f in ipairs({{"showTrim","dtTrim"},{"keepFonts","dtFonts"},{"trimAlpha","dtAlpha",.1,1,.05},{"edgeTop","dmEdgeTop",-24,48,1},{"edgeBottom","dmEdgeBottom",-24,48,1},{"edgeLeft","dmEdgeLeft",-24,48,1},{"edgeRight","dmEdgeRight",-24,48,1}}) do
  local key,label,low,high,step=unpack(f)
  local c=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
  w.Text(c,K.L(label),14,-12,278,13)
  local help=w.Button(c,"?",311,-10,22,22,function() end); w.Tip(help,label,key:match("^edge") and "dmEdgeHelp" or "dtHelp")
  if low then
   local value=w.Text(c,string.format(step==1 and "%.0f" or "%.2f",db[key]),14,-54,150,15)
   local function change(delta)
    if K.InCombat() then return end
    local requested=math.max(low,math.min(high,math.floor((db[key]+delta*step)/step+.5)*step))
    if api.Set(key,requested) then value:SetText(string.format(step==1 and "%.0f" or "%.2f",db[key])) end
   end
   w.Button(c,"−",251,-47,36,32,function() change(-1) end)
   w.Button(c,"+",297,-47,36,32,function() change(1) end)
  else w.Switch(c,db[key],255,-48,function(value) if not K.InCombat() then api.Set(key,value) end end,true) end
 end
 y=y-404
 local windows=api.GetWindows()
 local all=w.Button(page,K.L("dtAll"),0,y,714,36,function()
  if K.InCombat() then return end
  local targets=api.GetWindows()
  if #targets==0 then K.Message("dtEmpty"); Refresh(); return end
  local failed=false
  for _,window in ipairs(targets) do
   local ok,err=api.Apply(window.id,api.skinName); Report(ok,err,window.id)
   if not ok then failed=true end
  end
  if not failed then K.Message("dtDone") end
  Refresh()
 end)
 w.Tip(all,"dtAll","dtAllHelp")
 if not api.IsReady() or #windows==0 then all:Disable() end
 y=y-58
 if not api.IsReady() then w.Text(page,K.L("dtWaiting"),8,y,690,14); y=y-48 end
 w.Text(page,K.L("dtWindows"),8,y,690,18,{.73,.62,.41}); y=y-36
 w.Text(page,K.L("dtSelection"),8,y,690,12,{.65,.70,.62}); y=y-48
 if #windows==0 then w.Text(page,K.L("dtEmpty"),8,y,690,14); y=y-64 end
 local skins=api.GetSkins()
 for _,window in ipairs(windows) do
  local id=window.id
  local c=w.Box(page,0,y,714,130)
  w.Text(c,K.L("dtWindow").." "..id,16,-14,680,17)
  w.Text(c,K.L("dtCurrent")..window.skin,16,-43,680,12,{.65,.70,.62})
  local selected=choices[id] or api.skinName
  local function valid(name) for _,skin in ipairs(skins) do if skin==name then return true end end end
  if not valid(selected) then selected=skins[1] or "" end
  choices[id]=selected
  local name=w.Text(c,selected,16,-81,344,14)
  local function cycle(delta)
   if #skins==0 then return end
   local index=1; for i,skin in ipairs(skins) do if skin==choices[id] then index=i; break end end
   choices[id]=skins[(index-1+delta)%#skins+1]; name:SetText(choices[id])
  end
  local prev=w.Button(c,"−",376,-72,32,32,function() cycle(-1) end)
  local nextButton=w.Button(c,"+",414,-72,32,32,function() cycle(1) end)
  local apply=w.Button(c,K.L("dtApply"),466,-72,230,32,function()
   if K.InCombat() then return end
   local ok,err=api.Apply(id,choices[id]); Report(ok,err,id)
   if ok then K.Message("dtDone") end
   Refresh()
  end)
  if #skins==0 or not api.IsReady() then prev:Disable(); nextButton:Disable(); apply:Disable() end
  w.Tip(apply,"dtApply","dtHelp")
  y=y-146
 end
 w.Button(page,K.L("dtRefresh"),365,y,349,36,Refresh)
 page:SetHeight(-y+56)
 return true
end

-- Appearance only: no combat-session reads, native data changes or ticker.
local M={};K.NativeMeter=M
local defaults={enabled=false,trim=true,trimAlpha=1,backgroundAlpha=.85,padding=14,edgeTop=0,edgeBottom=0,edgeLeft=0,edgeRight=0}
local shells=setmetatable({},{__mode="k"})
local owner,ownerHooked,queued,pending
local media="Interface\\AddOns\\KerimAnkaUI\\Media\\DamageMeter"
local warrior=select(2,UnitClass("player"))=="WARRIOR"
local function WarriorVariant() return KerimAnkaUITextAPI.WarriorSkin()==2 and "Horde" or "Alliance" end
local paladin=select(2,UnitClass("player"))=="PALADIN"
local paladinUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local function PaladinVariant()
 return KerimAnkaUITextAPI.PaladinSkin()==2 and "Horde" or "Alliance"
end
local rogue=select(2,UnitClass("player"))=="ROGUE"
local rogueUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local warlock=select(2,UnitClass("player"))=="WARLOCK"
local shaman=select(2,UnitClass("player"))=="SHAMAN"
local druid=select(2,UnitClass("player"))=="DRUID"
local druidUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local priest=select(2,UnitClass("player"))=="PRIEST"
local priestUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local mage=select(2,UnitClass("player"))=="MAGE"
local mageUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local shamanUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local warlockUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.5712890625,0.8125},Bottom={0.5712890625,0.8125},Left={0.8125,0.5625},Right={0.8125,0.5625}}
if warlock then media="Interface\\AddOns\\KerimAnkaUI\\Media\\WarlockMeter\\" end
if shaman then media="Interface\\AddOns\\KerimAnkaUI\\Media\\ShamanMeter\\" end
if druid then media="Interface\\AddOns\\KerimAnkaUI\\Media\\DruidMeter\\" end
if priest then media="Interface\\AddOns\\KerimAnkaUI\\Media\\PriestMeter\\" end
if mage then media="Interface\\AddOns\\KerimAnkaUI\\Media\\MageMeter\\" end
if rogue then media="Interface\\AddOns\\KerimAnkaUI\\Media\\RogueMeter\\" end
function M.Get(key)
 local db=K.db and K.db.nativeMeter
 if db and db[key]~=nil then return db[key] end
 return defaults[key]
end
local function Restricted(frame)
 return frame.IsForbidden and frame:IsForbidden() or frame.IsProtected and frame:IsProtected()
end
local function Part(shell,name)
 local t=shell:CreateTexture(nil,"OVERLAY")
 t:SetTexture((warrior and "Interface\\AddOns\\KerimAnkaUI\\Media\\WarriorMeter"..WarriorVariant().."\\" or paladin and "Interface\\AddOns\\KerimAnkaUI\\Media\\PaladinMeter"..PaladinVariant().."\\" or media)..name..".tga","CLAMP","CLAMP","TRILINEAR")
 if warrior or paladin or rogue or warlock or shaman or mage or priest or druid then local uv=((warrior or paladin) and paladinUV or rogue and rogueUV or druid and druidUV or priest and priestUV or mage and mageUV or shaman and shamanUV or warlockUV)[name];t:SetTexCoord(0,uv[1],0,uv[2]) end
 return t
end
local function NewShell(window)
 if Restricted(window) then return end
 local shell=CreateFrame("Frame",nil,window)
 shell:EnableMouse(false)
 -- The class-specific rails extend inside the native background rectangle. Their
 -- transparent overlay must render above that background, without taking input.
 -- Hunter's existing exterior trim retains its original ordering.
 shell:SetFrameLevel(math.max(0,window:GetFrameLevel()+((warrior or paladin or rogue or warlock or shaman or mage or priest or druid) and 1 or -1)))
 local state={shell=shell,window=window,pieces={}}
 for _,corner in ipairs({"TL","TR","BL","BR"}) do
  local points={TL="TOPLEFT",TR="TOPRIGHT",BL="BOTTOMLEFT",BR="BOTTOMRIGHT"}
  local t=Part(shell,corner);t:SetSize(32,32);t:SetPoint(points[corner],shell,points[corner]);state.pieces[corner]=t
 end
 for _,name in ipairs({"Top","Bottom","Left","Right"}) do state.pieces[name]=Part(shell,name) end
 local p=state.pieces
 p.Top:SetHeight(32);p.Top:SetPoint("TOPLEFT",32,0);p.Top:SetPoint("TOPRIGHT",-32,0)
 p.Bottom:SetHeight(32);p.Bottom:SetPoint("BOTTOMLEFT",32,0);p.Bottom:SetPoint("BOTTOMRIGHT",-32,0)
 p.Left:SetWidth(32);p.Left:SetPoint("TOPLEFT",0,-32);p.Left:SetPoint("BOTTOMLEFT",0,32)
 p.Right:SetWidth(32);p.Right:SetPoint("TOPRIGHT",0,-32);p.Right:SetPoint("BOTTOMRIGHT",0,32)
 shells[window]=state
 return state
end
local function CaptureBackground(state)
 local window=state.window
 local bg=window.MinimizeContainer and window.MinimizeContainer.Background
 if not bg or Restricted(bg) then return end
 if state.bg==bg then return bg end
 -- Only known native background textures are touched; rows and headers stay native.
 state.bg=bg
 state.original={atlas=bg.GetAtlas and bg:GetAtlas(),texture=bg:GetTexture(),uv={bg:GetTexCoord()},color={bg:GetVertexColor()},alpha=bg:GetAlpha()}
 return bg
end
local function Restore(state)
 state.shell:Hide()
 if not state.changed or not state.bg then return end
 local bg,original=state.bg,state.original
 if Restricted(bg) then return end
 if original.atlas then bg:SetAtlas(original.atlas)
 else bg:SetTexture(original.texture);bg:SetTexCoord(unpack(original.uv)) end
 bg:SetVertexColor(unpack(original.color))
 local alpha=original.alpha
 if state.window.GetBackgroundAlpha then alpha=state.window:GetBackgroundAlpha() end
 bg:SetAlpha(alpha)
 state.changed=false
end
local function Apply(window)
 if Restricted(window) then return end
 local state=shells[window]
 if not M.Get("enabled") then if state then Restore(state) end;return end
 state=state or NewShell(window);if not state then return end
 if paladin then
  local variant=PaladinVariant()
  if state.variant~=variant then
   for name,t in pairs(state.pieces) do t:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\PaladinMeter"..variant.."\\"..name..".tga","CLAMP","CLAMP","TRILINEAR") end
   state.variant=variant
  end
 end
 if warrior then
  local variant=WarriorVariant()
  if state.variant~=variant then
   for name,t in pairs(state.pieces) do t:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\WarriorMeter"..variant.."\\"..name..".tga","CLAMP","CLAMP","TRILINEAR") end
   state.variant=variant
  end
 end
 local bg=CaptureBackground(state)
 if warrior or paladin or rogue or warlock or shaman or mage or priest or druid then
  local parent=bg and bg.GetParent and bg:GetParent()
  local level=window:GetFrameLevel()
  if parent and parent.GetFrameLevel then level=math.max(level,parent:GetFrameLevel()) end
  state.shell:SetFrameLevel(level+1)
 end
 if bg then
  bg:SetTexture("Interface\\Buttons\\WHITE8X8")
  bg:SetTexCoord(0,1,0,1);bg:SetVertexColor(.055,.065,.05,1)
  bg:SetAlpha(M.Get("backgroundAlpha"));state.changed=true
 end
 local minimized=window.IsMinimized and window:IsMinimized()
 local inset=M.Get("padding")
 state.shell:ClearAllPoints()
 state.shell:SetPoint("TOPLEFT",window,"TOPLEFT",-math.max(0,inset+M.Get("edgeLeft")),math.max(0,inset+M.Get("edgeTop")))
 state.shell:SetPoint("BOTTOMRIGHT",window,"BOTTOMRIGHT",math.max(0,inset+M.Get("edgeRight")),-math.max(0,inset+M.Get("edgeBottom")))
 state.shell:SetAlpha(M.Get("trimAlpha"))
 state.shell:SetShown(M.Get("trim") and not minimized)
 if not state.hooked then
  state.hooked=true
  if window.UpdateBackground then hooksecurefunc(window,"UpdateBackground",function() M.Queue() end) end
  if window.SetMinimized then hooksecurefunc(window,"SetMinimized",function() M.Queue() end) end
  window:HookScript("OnShow",function() M.Queue() end)
 end
end
function M.Refresh()
 if InCombatLockdown() then pending=true;return end
 owner=_G.DamageMeter
 if not owner or Restricted(owner) or type(owner.GetSessionWindow)~="function" then return end
 if ownerHooked~=owner then
  ownerHooked=owner
  if owner.SetupSessionWindow then hooksecurefunc(owner,"SetupSessionWindow",function() M.Queue() end) end
  owner:HookScript("OnShow",function() M.Queue() end)
 end
 for i=1,3 do local window=owner:GetSessionWindow(i);if window then Apply(window) end end
 pending=false
end
function M.Queue()
 if queued then return end
 queued=true
 C_Timer.After(0,function() queued=false;M.Refresh() end)
end
-- Called only after an explicit, out-of-combat Paladin appearance change.
KerimAnkaUIAPI.RefreshMeterAppearance=function()
 if InCombatLockdown() then return end
 M.Queue()
 if ForeverDetailsHunterAPI and ForeverDetailsHunterAPI.RefreshAppearance then ForeverDetailsHunterAPI.RefreshAppearance() end
end
function M.Set(key,value)
 if InCombatLockdown() then return false end
 if type(defaults[key])=="boolean" then if type(value)~="boolean" then return false end
 elseif type(value)~="number" or value~=value then return false
 else local edge=key:match("^edge");value=math.max(edge and -24 or 0,math.min(edge and 48 or key=="padding" and 24 or 1,value)) end
 if defaults[key]==nil then return false end
 K.db.nativeMeter=K.db.nativeMeter or {};K.db.nativeMeter[key]=value
 M.Refresh();return true
end
function M.Status()
 if not _G.DamageMeter or type(_G.DamageMeter.GetSessionWindow)~="function" then return "dmUnavailable" end
 if GetCVar and GetCVar("damageMeterEnabled")=="0" then return "dmHidden" end
 return "dmReady"
end
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN");events:RegisterEvent("ADDON_LOADED");events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent",function(_,event,name)
 if event=="PLAYER_LOGIN" or event=="ADDON_LOADED" and (name=="Blizzard_DamageMeter" or name==K.name) or event=="PLAYER_REGEN_ENABLED" and pending then M.Queue() end
end)

local meterPage="blizzard"
local meterContent
function K.DrawDamageMetersPage(page)
 local w=K.UnitWidgets
 for i,item in ipairs({{"blizzard","dmBlizzard"},{"details","dmDetails"}}) do
  local code=item[1]
  local b=w.Button(page,K.L(item[2]),(i-1)*365,0,349,34,function() meterPage=code;Refresh() end)
  w.Selected(b,meterPage==code)
 end
 if not meterContent then meterContent=CreateFrame("Frame",nil,page);meterContent:SetSize(734,400) end
 meterContent:ClearAllPoints();meterContent:SetPoint("TOPLEFT",page,"TOPLEFT",0,-58)
 meterContent:Show()
 if meterPage=="details" then
  if not K.DrawDetailsPage(meterContent) then
   w.Text(meterContent,K.L("dmDetailsMissing"),8,0,690,14);meterContent:SetHeight(80)
  end
  page:SetHeight(meterContent:GetHeight()+58)
  return true -- The optional Details addon loading control stays on this page.
 end
 local M=K.NativeMeter
 w.Text(meterContent,K.L("dmNote"),8,0,690,13,{.65,.70,.62})
 w.Text(meterContent,K.L(M.Status()),8,-76,690,13,{.73,.62,.41})
 local y=-126
 for i,f in ipairs({{"enabled","dmEnabled"},{"trim","dmTrim"},{"trimAlpha","dmTrimAlpha",1,.05},{"backgroundAlpha","dmBackground",1,.05},{"padding","dmPadding",24,1},{"edgeTop","dmEdgeTop",48,1,-24},{"edgeBottom","dmEdgeBottom",48,1,-24},{"edgeLeft","dmEdgeLeft",48,1,-24},{"edgeRight","dmEdgeRight",48,1,-24}}) do
  local key,label,high,step,low=unpack(f);low=low or 0
  local card=w.Box(meterContent,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
  w.Text(card,K.L(label),14,-12,278,13)
  local help=w.Button(card,"?",311,-10,22,22,function() end);w.Tip(help,label,key:match("^edge") and "dmEdgeHelp" or "dmHelp")
  if high then
   local value=w.Text(card,string.format(step<1 and "%.2f" or "%.0f",M.Get(key)),14,-54,150,15)
   local function change(delta)
    if K.InCombat() then return end
    if M.Set(key,math.max(low,math.min(high,math.floor((M.Get(key)+delta*step)/step+.5)*step))) then value:SetText(string.format(step<1 and "%.2f" or "%.0f",M.Get(key))) end
   end
   w.Button(card,"−",251,-47,36,32,function() change(-1) end)
   w.Button(card,"+",297,-47,36,32,function() change(1) end)
  else w.Switch(card,M.Get(key),255,-48,function(v) if not K.InCombat() then M.Set(key,v) end end,true) end
 end
 meterContent:SetHeight(636);page:SetHeight(694)
 return false
end

-- KerimAnka UI experience widget. Independent implementation using game data.
;(function(K)
local X={selected="xp"};K.Experience=X
local D={frameSize=16,verticalSpace=0,backgroundAlpha=.92,showBackground=true,enabled=false,locked=true,layout=1,width=500,barHeight=14,subHeight=10,showRep=true,showPet=true,showTime=true,showRate=true,showQuest=true,showRested=true,trim=true,hideNative=false,classColor=true,texturedBars=false,red=.55,green=.7,blue=.28}
local ids={"total","levelTime","xp","remaining","rate","reputation","pet"}
X.ids=ids
local state={revision=0,questXP=0,questDirty=true,gained=0}
local hud,preview,previewStage,previewPanel,previewToggle,ticker,nativeState
local eventFrame=CreateFrame("Frame")
local media="Interface\\AddOns\\KerimAnkaUI\\Media\\DamageMeter"
local plainCorners=select(2,UnitClass("player"))~="HUNTER"
local function TrimTexture(name)
 if plainCorners and (name=="TL" or name=="TR" or name=="BL" or name=="BR") then
  return "Interface\\AddOns\\KerimAnkaUI\\Media\\ExperiencePlain"..name..".tga"
 end
 return media..name..".tga"
end
local function Safe(v) return not (issecretvalue and issecretvalue(v)) end
local function Number(v,default) return Safe(v) and type(v)=="number" and v==v and v or default or 0 end
local function Text(v) return Safe(v) and type(v)=="string" and v or "" end
function X.Get(key)
 local db=K.db and K.db.experience
 if db and db[key]~=nil then return db[key] end
 return D[key]
end
local function DB() K.db.experience=K.db.experience or {};return K.db.experience end
local function LabelDB(id) local d=K.db and K.db.experience;return d and d.labels and d.labels[id] or {} end
X.LabelSettings=LabelDB
function X.LabelValue(id,key)
 local value=LabelDB(id)[key];if value~=nil then return value end
 if key=="size" then return id=="xp" and (X.Get("layout")==2 and 12 or 13) or (id=="pet" or id=="reputation") and 10 or 11 end
 if key=="align" then return (id=="xp" or id=="pet" or id=="reputation") and 1 or (id=="rate" or id=="levelTime" and X.Get("layout")==1 or id=="remaining" and X.Get("layout")==2) and 2 or 0 end
 if key=="visible" then return true end
 return 0
end
local function OtherExperienceLoaded() return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("ExperienceForever") or IsAddOnLoaded and IsAddOnLoaded("ExperienceForever") end
local function Clock(seconds)
 if not seconds then return "—" end
 local m=math.floor(math.max(0,seconds)/60)
 if m>=1440 then return math.floor(m/1440)..K.L("xpDayShort").." "..(math.floor(m/60)%24)..K.L("xpHourShort") end
 return math.floor(m/60)..K.L("xpHourShort").." "..(m%60)..K.L("xpMinuteShort")
end
local function Num(v) return tostring(math.floor(Number(v))) end
local function TimeContext(data)
 local now=GetTime()
 data.rate=state.start and state.gained*3600/math.max(1,now-state.start) or 0
 data.remaining=data.rate>0 and data.max>data.xp and (data.max-data.xp)*3600/data.rate or nil
 data.total=state.playedTotal and state.playedTotal+(now-state.playedAt) or nil
 data.levelTime=state.playedLevel and state.playedLevel+(now-state.playedAt) or nil
end
local function QuestXP()
 if not state.questDirty then return state.questXP end
 state.questDirty=false;state.questXP=0
 local q=C_QuestLog
 local count=q and q.GetNumQuestLogEntries and q.GetNumQuestLogEntries() or GetNumQuestLogEntries and GetNumQuestLogEntries() or 0
 for i=1,Number(count) do
  local id=q and q.GetQuestIDForLogIndex and q.GetQuestIDForLogIndex(i)
  if not id and GetQuestLogTitle then id=select(8,GetQuestLogTitle(i)) end
  if Number(id)>0 then
   local done=q and q.IsComplete and q.IsComplete(id) or IsQuestComplete and IsQuestComplete(id)
   if Safe(done) and (done==true or done==1) and GetQuestLogRewardXP then state.questXP=state.questXP+math.max(0,Number(GetQuestLogRewardXP(id))) end
  end
 end
 return state.questXP
end
local function Reputation()
 local name,low,high,value
 if C_Reputation and C_Reputation.GetWatchedFactionData then
  local d=C_Reputation.GetWatchedFactionData()
  if d then name=d.name;low=d.currentReactionThreshold;high=d.nextReactionThreshold;value=d.currentStanding end
 elseif GetWatchedFactionInfo then local reaction;name,reaction,low,high,value=GetWatchedFactionInfo() end
 if Text(name)=="" or Number(high)<=Number(low) then return end
 return {name=Text(name),value=math.max(0,Number(value)-Number(low)),max=Number(high)-Number(low)}
end
function X.LiveData()
 local level=Number(UnitLevel("player"));local xp=Number(UnitXP("player"));local maximum=Number(UnitXPMax("player"))
 local cap=GetMaxPlayerLevel and Number(GetMaxPlayerLevel()) or 0
 local data={level=level,xp=xp,max=maximum,main=maximum>0 and (cap==0 or level<cap),quest=QuestXP(),rested=GetXPExhaustion and Number(GetXPExhaustion()) or 0}
 if X.Get("showRep") then data.rep=Reputation() end
 local _,class=UnitClass("player")
 if X.Get("showPet") and class=="HUNTER" and UnitExists("pet") and GetPetExperience then
  local value,maxXP=GetPetExperience()
  if Number(maxXP)>0 then data.pet={name=Text(UnitName("pet")),level=Number(UnitLevel("pet")),value=Number(value),max=Number(maxXP)} end
 end
 if not state.start then state.start=GetTime();state.last={level=level,xp=xp,max=maximum} end
 local last=state.last
 if level>last.level then
  state.gained=state.gained+math.max(0,last.max-last.xp)+xp
  if state.playedTotal then state.playedTotal=state.playedTotal+GetTime()-state.playedAt;state.playedLevel=0;state.playedAt=GetTime() end
  state.last={level=level,xp=xp,max=maximum}
 elseif level==last.level and xp>=last.xp then
  state.gained=state.gained+xp-last.xp;state.last={level=level,xp=xp,max=maximum}
 elseif level<last.level then state.last={level=level,xp=xp,max=maximum} end
 TimeContext(data);return data
end
function X.Sample()
 return {main=true,level=28,xp=6109,max=41400,quest=4200,rested=10000,rate=3737,remaining=4320,total=104400,levelTime=9360,
  rep=X.Get("showRep") and {name=K.L("xpSampleFaction"),value=4755,max=6000} or nil,
  pet=X.Get("showPet") and select(2,UnitClass("player"))=="HUNTER" and {name=K.L("xpSamplePet"),level=27,value=2235,max=9725} or nil}
end
local colorDefaults={quest={.85,.55,.13},rested={.2,.45,.75},rep={.43,.61,.28},label={.94,.93,.85}}
local function ValidLabel(id) for _,value in ipairs(ids) do if value==id then return true end end end
local function RGB(value)
 if type(value)~="table" then return end
 for i=1,3 do if type(value[i])~="number" or not Safe(value[i]) or value[i]~=value[i] or value[i]<0 or value[i]>1 then return end end
 return {value[1],value[2],value[3]}
end
function X.RawColor(key,id)
 if key=="label" then return RGB(LabelDB(id).color) end
 local db=K.db and K.db.experience
 return db and db.colors and RGB(db.colors[key]) or nil
end
function X.GetColor(key,id)
 if key=="main" and X.Get("classColor") then
  local _,class=UnitClass("player");local c=RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
  if c then return c.r,c.g,c.b end
 end
 local custom=X.RawColor(key,id);if custom then return unpack(custom) end
 if key=="main" then return X.Get("red"),X.Get("green"),X.Get("blue") end
 if key=="pet" then return X.GetColor("main") end
 return unpack(colorDefaults[key] or colorDefaults.label)
end
function X.SetColor(key,value,id,rollback)
 if (InCombatLockdown() or (key=="main" and X.Get("classColor"))) and not rollback then return false end
 if key=="label" then if not ValidLabel(id) then return false end
 elseif key~="main" and key~="pet" and not colorDefaults[key] then return false end
 local color=value and RGB(value)
 if value~=nil and not color then return false end
 local db=DB()
 if key=="label" then
  db.labels=db.labels or {};db.labels[id]=db.labels[id] or {};db.labels[id].color=color
 else
  db.colors=db.colors or {};db.colors[key]=color
 end
 state.revision=state.revision+1;X.Refresh();return true
end
function X.ResetColor(key,id)
 if InCombatLockdown() or (key=="main" and X.Get("classColor")) then return false end
 if key=="main" then local db=DB();db.red=D.red;db.green=D.green;db.blue=D.blue end
 return X.SetColor(key,nil,id)
end
function X.HexColor(key,id)
 local r,g,b=X.GetColor(key,id)
 return string.format("#%02X%02X%02X",math.floor(r*255+.5),math.floor(g*255+.5),math.floor(b*255+.5))
end
function X.ApplyHex(key,text,id)
 if type(text)~="string" then return false end
 local hex=text:match("^%s*#?(%x%x%x%x%x%x)%s*$")
 if not hex then return false end
 return X.SetColor(key,{tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255},id)
end
function X.OpenColorPicker(key,id,onChange)
 if key=="main" and X.Get("classColor") then return false end
 if K.InCombat() then return false end
 local picker=ColorPickerFrame
 if not picker or not picker.SetupColorPickerAndShow then K.Message("xpPickerUnavailable");return false end
 local before=X.RawColor(key,id)
 local r,g,b=X.GetColor(key,id)
 local function changed()
  if InCombatLockdown() then return end
  local r,g,b=picker:GetColorRGB()
  if X.SetColor(key,{r,g,b},id) and onChange then onChange() end
 end
 picker:SetupColorPickerAndShow({r=r,g=g,b=b,hasOpacity=false,swatchFunc=changed,
  cancelFunc=function() X.SetColor(key,before,id,true);if onChange then onChange() end end})
 if picker.Raise then picker:Raise() end
 return true
end
local function ClearLabelLayout()
 local keep={}
 for _,id in ipairs(ids) do local color=X.RawColor("label",id);if color then keep[id]={color=color} end end
 DB().labels=next(keep) and keep or nil
end
function X.JumpToText(id)
 if not ValidLabel(id) then return end
 X.selected=id
 if K.Render then K.Render() end
 C_Timer.After(0,function()
  if not K.window or not K.window:IsShown() or not K.experiencePageAvailable then return end
  if X.textSettingsOffset then
   K.scroll:UpdateScrollChildRect()
   K.scroll:SetVerticalScroll(math.min(math.max(0,X.textSettingsOffset-8),K.scroll:GetVerticalScrollRange()))
  end
 end)
end

-- The native glossy asset darkens its tint. A white flat asset does not.
-- Match its approximate average brightness without recreating the bright band.
-- This affects rendering only: selected/class RGB and saved colors stay intact.
local function FillColor(key)
 local r,g,b=X.GetColor(key)
 local light=X.Get("texturedBars") and 1 or .5
 return r*light,g*light,b*light
end
local function Bar(parent)
 local f=CreateFrame("Frame",nil,parent,"BackdropTemplate")
 f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
 f:SetBackdropColor(.025,.03,.025,1);f:SetBackdropBorderColor(.3,.28,.17,1)
 f.layers={}
 for i=1,3 do local b=CreateFrame("StatusBar",nil,f);b:SetPoint("TOPLEFT",1,-1);b:SetPoint("BOTTOMRIGHT",-1,1);b:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8");b:SetMinMaxValues(0,1);b:SetFrameLevel(f:GetFrameLevel()+i);f.layers[i]=b end
 return f
end
local function CreateWidget(parent,isPreview)
 local f=CreateFrame("Frame",nil,parent,"BackdropTemplate")
 f.background=f:CreateTexture(nil,"BACKGROUND")
 f.main=Bar(f);f.rep=Bar(f);f.pet=Bar(f)
 f.textLayer=CreateFrame("Frame",nil,f);f.textLayer:SetAllPoints();f.textLayer:SetFrameLevel(f:GetFrameLevel()+10)
 f.labels={}
 for _,id in ipairs(ids) do
  local label=f.textLayer:CreateFontString(nil,"OVERLAY");label:SetWordWrap(false);label:SetTextColor(.94,.93,.85,1)
  label:SetShadowColor(0,0,0,1);label:SetShadowOffset(1,-1);f.labels[id]=label
  if isPreview then
   local hit=CreateFrame("Button",nil,f.textLayer,"BackdropTemplate");hit:SetAllPoints(label);hit:RegisterForDrag("LeftButton");hit:EnableMouseWheel(true)
   hit:SetScript("OnClick",function(self) if self.previewDragged then return end;X.JumpToText(id) end)
   hit:SetScript("OnDragStart",function(self)
    if InCombatLockdown() then return end
    X.selected=id;self.previewDragged=true
    local x,y=GetCursorPosition();local cfg=LabelDB(id);self.drag={x=x,y=y,dx=cfg.x or 0,dy=cfg.y or 0,scale=f:GetEffectiveScale()}
    self:SetScript("OnUpdate",function()
     if InCombatLockdown() then return end
     local cx,cy=GetCursorPosition();local d=self.drag
     X.SetLabel(id,"x",d.dx+(cx-d.x)/d.scale,true);X.SetLabel(id,"y",d.dy+(cy-d.y)/d.scale,true);X.PaintPreview()
    end)
   end)
   local function stop(self) self:SetScript("OnUpdate",nil);self.drag=nil;X.Refresh();if K.Render then K.Render() end;C_Timer.After(0,function() self.previewDragged=nil end) end
   hit:SetScript("OnDragStop",stop)
   hit:SetScript("OnHide",function(self) self:SetScript("OnUpdate",nil);self.drag=nil end)
   hit:SetScript("OnMouseWheel",function(_,delta) if not InCombatLockdown() then X.selected=id;X.SetLabel(id,"size",X.LabelValue(id,"size")+delta);if K.Render then K.Render() end end end)
   label.hit=hit
  end
 end
 f.trim=CreateFrame("Frame",nil,f);f.trim:EnableMouse(false);f.trim:SetAllPoints();f.trim:SetFrameLevel(f:GetFrameLevel()+7);f.parts={}
 if plainCorners then
  -- A single native rectangle avoids seams/doubled edges between decorative
  -- rails and the separately generated plain corner artwork.
  f.plainTrim=CreateFrame("Frame",nil,f.trim,"BackdropTemplate")
  f.plainTrim:EnableMouse(false)
  f.plainTrim:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
  f.plainTrim:SetBackdropBorderColor(.42,.32,.18,1)
 else
 for _,name in ipairs({"TL","TR","BL","BR","Top","Bottom","Left","Right"}) do local t=f.trim:CreateTexture(nil,"OVERLAY");t:SetTexture(TrimTexture(name),"CLAMP","CLAMP","TRILINEAR");f.parts[name]=t end
 end
 return f
end
local function Layout(f,data)
 local w=X.Get("width");local horizontal=X.Get("layout")==2
 local bh,sh=X.Get("barHeight"),X.Get("subHeight")
 -- Change fill assets only when layout/settings change, never on each XP tick.
 local texture=X.Get("texturedBars") and "Interface\\TargetingFrame\\UI-StatusBar" or "Interface\\Buttons\\WHITE8X8"
 for _,bar in ipairs({f.main,f.rep,f.pet}) do
  for _,layer in ipairs(bar.layers) do layer:SetStatusBarTexture(texture) end
 end
 local c=X.Get("frameSize");local pad=c+4
 local extra=data.rep or data.pet
 local vertical=X.Get("verticalSpace")
 local headerY=c+4+vertical/2
 local barY=headerY+10
 local statsY=barY+bh+10
 local extraY=data.main and (horizontal and barY+bh+8 or statsY+10) or c+3+vertical/2
 local bottom=math.ceil(c*.85)+3
 local h=(extra and extraY+sh or data.main and (horizontal and barY+bh or statsY+6) or c+3+vertical/2)+bottom+vertical/2
 f:SetSize(w,h)
 -- The artwork has transparent margins. The fill must start inside its
 -- visible outer edge instead of occupying the full rectangular hit frame.
 local inset=math.ceil(c*.27)
 f.background:ClearAllPoints();f.background:SetPoint("TOPLEFT",inset,-inset);f.background:SetPoint("BOTTOMRIGHT",-inset,inset)
 f.background:SetColorTexture(.045,.055,.045,X.Get("backgroundAlpha"))
 f.background:SetShown(X.Get("showBackground"))
 f.main:ClearAllPoints();f.main:SetPoint("TOPLEFT",pad,-barY);f.main:SetSize(w-pad*2,bh);f.main:SetShown(data.main)
 local subW=(data.rep and data.pet) and (w-pad*2-12)/2 or w-pad*2
 for _,id in ipairs({"rep","pet"}) do
  local bar=f[id];bar:ClearAllPoints();bar:SetSize(subW,sh)
  bar:SetPoint("TOPLEFT",pad+(id=="pet" and data.rep and subW+12 or 0),-extraY);bar:SetShown(data[id]~=nil)
 end
 local placements={
  total={pad,-headerY,"LEFT",w*.43,11},levelTime={w-pad,-headerY,"RIGHT",w*.43,11},
  xp={w/2,-barY-bh/2,"CENTER",w-pad*2-4,13},
  remaining={pad,-statsY,"LEFT",w*.46,11},rate={w-pad,-statsY,"RIGHT",w*.46,11},
  reputation={pad+subW/2,-extraY-sh/2,"CENTER",subW-4,10},
  pet={pad+(data.rep and subW+12 or 0)+subW/2,-extraY-sh/2,"CENTER",subW-4,10}}
 if horizontal then
  placements.total={pad,-headerY,"LEFT",w*.17,11};placements.levelTime={w*.22,-headerY,"LEFT",w*.17,11}
  placements.xp={w*.5,-headerY,"CENTER",w*.23,12};placements.remaining={w*.78,-headerY,"RIGHT",w*.16,11};placements.rate={w-pad,-headerY,"RIGHT",w*.17,11}
 end
 for id,p in pairs(placements) do
  local label=f.labels[id];local cfg=LabelDB(id)
  local align=cfg.align~=nil and ({[0]="LEFT",[1]="CENTER",[2]="RIGHT"})[cfg.align] or p[3]
  -- Explicit alignment uses the panel interior; untouched labels retain preset slots.
  local left,right=pad,w-pad
  if id=="reputation" or id=="pet" then
   left=pad+(id=="pet" and data.rep and subW+12 or 0)+2;right=left+subW-4
  end
  local anchorX=p[1]
  if cfg.align~=nil then anchorX=align=="LEFT" and left or align=="RIGHT" and right or (left+right)/2 end
  label:ClearAllPoints();label:SetPoint(align,f,"TOPLEFT",anchorX+(cfg.x or 0),p[2]+(cfg.y or 0));label:SetWidth(p[4]);label:SetJustifyH(align)
  K.ApplyTextFont(label,cfg.size or p[5],cfg.font==1,"",cfg.font==2 or nil)
  label:SetTextColor(X.GetColor("label",id))
  local shown=id=="reputation" and data.rep~=nil or id=="pet" and data.pet~=nil or data.main and id~="pet" and id~="reputation"
  if (id=="total" or id=="levelTime") and not X.Get("showTime") then shown=false end
  if (id=="remaining" or id=="rate") and not X.Get("showRate") then shown=false end
  if cfg.visible==false then shown=false end
  label:SetShown(shown);if label.hit then label.hit:SetShown(shown) end
 end
 if f.plainTrim then
  -- Match the visible background on all four sides. No extra outer rail.
  f.plainTrim:ClearAllPoints()
  f.plainTrim:SetPoint("TOPLEFT",f,"TOPLEFT",inset,-inset)
  f.plainTrim:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-inset,inset)
 else
 local p=f.parts
 for name,point in pairs({TL="TOPLEFT",TR="TOPRIGHT",BL="BOTTOMLEFT",BR="BOTTOMRIGHT"}) do p[name]:SetSize(c,c);p[name]:ClearAllPoints();p[name]:SetPoint(point) end
 p.Top:ClearAllPoints();p.Top:SetHeight(c);p.Top:SetPoint("TOPLEFT",c,0);p.Top:SetPoint("TOPRIGHT",-c,0)
 p.Bottom:ClearAllPoints();p.Bottom:SetHeight(c);p.Bottom:SetPoint("BOTTOMLEFT",c,0);p.Bottom:SetPoint("BOTTOMRIGHT",-c,0)
 p.Left:ClearAllPoints();p.Left:SetWidth(c);p.Left:SetPoint("TOPLEFT",0,-c);p.Left:SetPoint("BOTTOMLEFT",0,c)
 p.Right:ClearAllPoints();p.Right:SetWidth(c);p.Right:SetPoint("TOPRIGHT",0,-c);p.Right:SetPoint("BOTTOMRIGHT",0,c)
 end
 f.trim:SetShown(X.Get("trim"));f.height=h
end

local function Paint(f,data)
 local signature=tostring(data.main)..tostring(data.rep~=nil)..tostring(data.pet~=nil)
 if f.rev~=state.revision or f.signature~=signature then Layout(f,data);f.rev=state.revision;f.signature=signature end
 local max=math.max(1,data.max);local r,g,b=FillColor("main")
 local rr,rg,rb=FillColor("rested");local qr,qg,qb=FillColor("quest")
 f.main.layers[1]:SetStatusBarColor(rr,rg,rb,.45);f.main.layers[2]:SetStatusBarColor(qr,qg,qb,.9);f.main.layers[3]:SetStatusBarColor(r,g,b,1)
 f.main.layers[1]:SetValue(math.min(1,(data.xp+(X.Get("showQuest") and data.quest or 0)+(X.Get("showRested") and data.rested or 0))/max))
 f.main.layers[2]:SetValue(math.min(1,(data.xp+(X.Get("showQuest") and data.quest or 0))/max));f.main.layers[3]:SetValue(math.min(1,data.xp/max))
 local t=f.labels
 t.total:SetText(K.L("xpTotal")..": "..Clock(data.total));t.levelTime:SetText(K.L("xpLevelTime")..": "..Clock(data.levelTime))
 t.xp:SetText(K.L("xpLevel").." "..data.level.."  |  "..Num(data.xp).." / "..Num(data.max))
 t.remaining:SetText(K.L("xpRemaining")..": "..Clock(data.remaining));t.rate:SetText(K.L("xpRate")..": "..Num(data.rate))
 for _,id in ipairs({"rep","pet"}) do
  local info=data[id];local bar=f[id]
  if info then
   bar.layers[1]:SetValue(0);bar.layers[2]:SetValue(0);bar.layers[3]:SetStatusBarColor(FillColor(id));bar.layers[3]:SetValue(math.min(1,info.value/math.max(1,info.max)))
   t[id=="rep" and "reputation" or "pet"]:SetText(info.name..(id=="pet" and " · "..K.L("xpLevel").." "..info.level or "").."  "..Num(info.value).." / "..Num(info.max))
  end
 end
end
local function NativeBar(hide)
 local manager=_G.StatusTrackingBarManager or _G.MainMenuExpBar
 if not manager then return end
 if InCombatLockdown() then state.nativePending=true;return end
 if hide then
  if not nativeState then nativeState={frame=manager,shown=manager:IsShown()} end
  manager:Hide()
  if not manager.kerimAnkaXPHook then
   manager.kerimAnkaXPHook=true;manager:HookScript("OnShow",function() if state.hideNative then NativeBar(true) end end)
  end
 elseif nativeState then
  local old=nativeState;nativeState=nil;state.hideNative=false
  if old.shown and not OtherExperienceLoaded() then old.frame:Show();if old.frame.UpdateBarsShown then old.frame:UpdateBarsShown() end end
 end
 state.nativePending=false
end
local function StopTicker() if ticker then ticker:Cancel();ticker=nil end end
local dataEvents={"PLAYER_XP_UPDATE","PLAYER_LEVEL_UP","QUEST_LOG_UPDATE","TIME_PLAYED_MSG","UPDATE_EXHAUSTION","UPDATE_FACTION","UNIT_PET","UNIT_PET_EXPERIENCE","PET_UI_UPDATE","PLAYER_ENTERING_WORLD"}
local function Listen(active) for _,event in ipairs(dataEvents) do if active then eventFrame:RegisterEvent(event) else eventFrame:UnregisterEvent(event) end end end
function X.Update()
 local active=X.Get("enabled")
 if active then
  if not hud then
   hud=CreateWidget(UIParent,false);X.hud=hud;hud:SetClampedToScreen(true);hud:SetMovable(true);hud:RegisterForDrag("LeftButton");hud:EnableMouse(true)
   hud:SetScript("OnDragStart",function(self) if not X.Get("locked") and not InCombatLockdown() then self:StartMoving() end end)
   hud:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing();local x,y=self:GetCenter();local px,py=UIParent:GetCenter();local db=DB();db.x=x-px;db.y=y-py;X.Refresh()
   end)
  end
  local data=X.LiveData();Paint(hud,data)
  local shown=data.main or data.rep~=nil or data.pet~=nil
  hud:SetShown(shown)
  state.hideNative=shown and X.Get("hideNative");NativeBar(state.hideNative)
  if shown and not ticker then ticker=C_Timer.NewTicker(1,function() X.Update() end) elseif not shown then StopTicker() end
 else if hud then hud:Hide() end;StopTicker();state.hideNative=false;NativeBar(false) end
end
function X.Refresh()
 Listen(X.Get("enabled"))
 X.Update()
 if hud then hud:ClearAllPoints();hud:SetPoint("CENTER",UIParent,"CENTER",X.Get("x") or 0,X.Get("y") or UIParent:GetHeight()/2-90) end
 if X.Get("enabled") and not state.playedRequested and RequestTimePlayed then state.playedRequested=true;RequestTimePlayed() end
 X.PaintPreview()
end
function X.Set(key,value,quiet)
 if InCombatLockdown() then return false end
 local bounds={frameSize={10,24},verticalSpace={0,120},backgroundAlpha={0,1},width={280,1400},barHeight={8,28},subHeight={8,20},layout={1,2},red={0,1},green={0,1},blue={0,1},x={-10000,10000},y={-10000,10000}}
 if type(D[key])=="boolean" then if type(value)~="boolean" then return false end
 elseif bounds[key] and type(value)=="number" and value==value then value=math.max(bounds[key][1],math.min(bounds[key][2],value))
 else return false end
 DB()[key]=value;state.revision=state.revision+1;if not quiet then X.Refresh() end;return true
end
function X.SetLabel(id,key,value,quiet)
 if InCombatLockdown() then return false end
 local valid=false;for _,v in ipairs(ids) do if v==id then valid=true end end;if not valid then return false end
 local bounds={x={-1400,1400},y={-400,400},size={8,28},font={0,2},align={0,2}}
 if key=="visible" then if type(value)~="boolean" then return false end
 elseif bounds[key] and type(value)=="number" and value==value then value=math.max(bounds[key][1],math.min(bounds[key][2],math.floor(value+.5))) else return false end
 local db=DB();db.labels=db.labels or {};db.labels[id]=db.labels[id] or {};db.labels[id][key]=value
 state.revision=state.revision+1;if not quiet then X.Refresh() end;return true
end
function X.Preset(layout)
 if InCombatLockdown() then return end
 local db=DB();db.layout=layout;db.width=layout==2 and 960 or 500;ClearLabelLayout();state.revision=state.revision+1;X.Refresh()
end
function X.Place(where)
 if InCombatLockdown() then return end
 local db=DB()
 if where=="top" then db.x=0;db.y=UIParent:GetHeight()/2-(hud and hud.height or 74)/2-24
 else
  local meter=_G.DamageMeter;local first=meter and meter.GetSessionWindow and meter:GetSessionWindow(1)
  if not first or not first:IsShown() then K.Message("xpNoMeter");return end
  local left,right,top=first:GetLeft(),first:GetRight(),first:GetTop()
  for i=2,3 do local f=meter:GetSessionWindow(i);if f and f:IsShown() then left=math.min(left,f:GetLeft());right=math.max(right,f:GetRight());top=math.max(top,f:GetTop()) end end
  local scale=first:GetEffectiveScale()/UIParent:GetEffectiveScale();left=left*scale;right=right*scale;top=top*scale
  db.width=math.max(280,math.min(1400,right-left));db.x=(left+right)/2-UIParent:GetWidth()/2;db.y=top+12+(hud and hud.height or 74)/2-UIParent:GetHeight()/2
 end
 state.revision=state.revision+1;X.Refresh()
end
function X.PaintPreview()
 if not preview or not previewPanel:IsShown() then return end
 Paint(preview,X.Sample());preview:SetScale(math.min(1,690/(X.Get("width")+20),115/(preview.height+12)));preview:ClearAllPoints();preview:SetPoint("CENTER",previewStage,"CENTER")
 for id,label in pairs(preview.labels) do
  local hit=label.hit
  if id==X.selected then hit:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1});hit:SetBackdropBorderColor(.8,.68,.36,1)
  else hit:SetBackdrop(nil) end
 end
end
function K.ConfigureExperiencePreview(available)
 K.experiencePageAvailable=available and true or false
 if not previewPanel and available then
  previewPanel=CreateFrame("Frame",nil,K.window,"BackdropTemplate");previewPanel:SetPoint("TOPLEFT",220,-201);previewPanel:SetSize(734,146)
  previewPanel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1});previewPanel:SetBackdropColor(.09,.105,.095,1);previewPanel:SetBackdropBorderColor(.3,.34,.28,1)
  local note=previewPanel:CreateFontString(nil,"OVERLAY");note:SetPoint("BOTTOMLEFT",8,3);K.ApplyTextFont(note,10,false,"");previewPanel.note=note
  previewStage=CreateFrame("Frame",nil,previewPanel);previewStage:SetPoint("TOPLEFT",6,-4);previewStage:SetSize(722,126);previewStage:SetClipsChildren(true)
  preview=CreateWidget(previewStage,true)
  previewToggle=CreateFrame("CheckButton",nil,K.window,"UICheckButtonTemplate");previewToggle:SetPoint("TOPLEFT",752,-126);K.ApplyTextFont(previewToggle.text,11,false,"")
  previewToggle:SetScript("OnClick",function(self) KAClassic_KerimAnkaUIDB.experiencePreview=self:GetChecked() and true or false;K.Render() end)
 end
 local shown=available and KAClassic_KerimAnkaUIDB.experiencePreview~=false
 if previewToggle then previewToggle:SetShown(available);previewToggle:SetChecked(shown);previewToggle.text:SetText(K.L("upVisible")) end
 if previewPanel then previewPanel:SetShown(shown);previewPanel.note:SetText(K.L("xpPreviewNote")) end
 if available then K.scroll:ClearAllPoints();K.scroll:SetPoint("TOPLEFT",220,shown and -359 or -205);K.scroll:SetSize(734,math.max(140,K.window:GetHeight()-60-(shown and 359 or 205))) end
 X.PaintPreview()
end
function X.Status() return OtherExperienceLoaded() and "xpConflict" or "xpIntro" end
function X.ResetLabels() if not InCombatLockdown() then ClearLabelLayout();state.revision=state.revision+1;X.Refresh() end end
function X.ResetSession() state.start=nil;state.gained=0;state.last=nil;X.LiveData();X.Refresh() end
local queued
local function Queue() if queued then return end;queued=true;C_Timer.After(0,function() queued=false;X.Update() end) end
eventFrame:RegisterEvent("PLAYER_LOGIN");eventFrame:RegisterEvent("ADDON_LOADED");eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent",function(_,event,...)
 if event=="PLAYER_LOGIN" then X.Refresh()
 elseif event=="ADDON_LOADED" then if (...)=="ExperienceForever" then X.Refresh() end
 elseif event=="PLAYER_REGEN_ENABLED" then if state.nativePending then NativeBar(state.hideNative) end
 elseif event=="TIME_PLAYED_MSG" then local total,level=...;state.playedTotal=Number(total);state.playedLevel=Number(level);state.playedAt=GetTime();Queue()
 else if event=="QUEST_LOG_UPDATE" or event=="PLAYER_LEVEL_UP" then state.questDirty=true end;Queue() end
end)
X.Paint=Paint;X.Layout=Layout -- shared rendering for tests and future previews
end)(K)

;(function(K)
local function Redraw() C_Timer.After(0,function() if K.window and K.window:IsShown() then K.Render() end end) end
local colorEdits={}
function K.HideExperienceInputs()
 for _,edit in pairs(colorEdits) do edit:ClearFocus();edit:Hide() end
end
local function ColorRow(page,w,y,key,label,id)
 local X=K.Experience;local tag=key..":"..(id or "")
 local locked=key=="main" and X.Get("classColor")
 local height=locked and 98 or 78;local controlY=locked and -55 or -35
 local card=w.Box(page,0,y,714,height);card.xpColorTag=tag
 if locked then w.Text(card,K.L("xpClassColorActive"),14,-31,680,11,{.64,.64,.59}) end
 w.Text(card,K.L(label),14,-10,620,13)
 if not card.xpColorChip then card.xpColorChip=card:CreateTexture(nil,"OVERLAY") end
 local chip=card.xpColorChip;chip:ClearAllPoints();chip:SetPoint("TOPRIGHT",-14,-10);chip:SetSize(38,16);chip:Show()
 local edit=colorEdits[key]
 if not edit then
  edit=CreateFrame("EditBox",nil,page,"InputBoxTemplate");edit:SetSize(150,28);edit:SetAutoFocus(false);edit:SetMaxLetters(7)
  edit:SetScript("OnEscapePressed",function(self) self:ClearFocus() end);colorEdits[key]=edit
 end
 edit:SetParent(card);edit:ClearAllPoints();edit:SetPoint("TOPLEFT",260,controlY-3);K.ApplyTextFont(edit,13,false,"");edit:Show()
 if locked then edit:Disable() else edit:Enable() end;edit:SetAlpha(locked and .45 or 1)
 local function Sync()
  if card.xpColorTag~=tag then return end
  local r,g,b=X.GetColor(key,id);chip:SetColorTexture(r,g,b,1)
  edit:SetText(X.HexColor(key,id))
 end
 local function Apply()
  edit:ClearFocus()
  if key=="main" and X.Get("classColor") then return end
  if K.InCombat() then return end
  if not X.ApplyHex(key,edit:GetText(),id) then K.Message("xpInvalidHex") end
  Sync()
 end
 edit:SetScript("OnEnterPressed",Apply)
 local choose=w.Button(card,K.L("xpChooseColor"),14,controlY,224,30,function() X.OpenColorPicker(key,id,Sync) end)
 local apply=w.Button(card,K.L("xpApplyColor"),430,controlY,116,30,Apply)
 local reset=w.Button(card,K.L("xpResetColor"),558,controlY,142,30,function() if not K.InCombat() then X.ResetColor(key,id);Sync() end end)
 for _,button in ipairs({choose,apply,reset}) do
  if locked then button:Disable() else button:Enable() end
  button.label:SetTextColor(locked and .48 or .94,locked and .48 or .93,locked and .45 or .85)
 end
 Sync()
 return y-height-10
end

function K.DrawExperiencePage(page)
 local X=K.Experience;local w=K.UnitWidgets;local y=0
 w.Text(page,K.L(X.Status()),8,y,690,13,{.65,.7,.62});y=y-82
 for i,item in ipairs({{"xpCompact",1},{"xpHorizontal",2}}) do
  local b=w.Button(page,K.L(item[1]),(i-1)*365,y,349,34,function() X.Preset(item[2]);Redraw() end);w.Selected(b,X.Get("layout")==item[2])
 end
 y=y-52
 local function Toggle(key,label,x,top,width,reader,writer)
  local card=w.Box(page,x,top,width,78);w.Text(card,K.L(label),14,-10,width-66,13)
  local help=w.Button(card,"?",width-38,-8,22,22,function() end);w.Tip(help,label,key=="texturedBars" and "xpTexturedBarsHelp" or key=="showBackground" and "xpShowBackgroundHelp" or "xpHelp")
  w.Switch(card,reader and reader() or X.Get(key),width-94,-41,function(v) if not K.InCombat() then if writer then writer(v) else X.Set(key,v) end;Redraw() end end,true)
 end
 local toggles={{"enabled","xpEnabled"},{"locked","xpLocked"},{"showRep","xpShowRep"},{"showPet","xpShowPet"},{"showTime","xpShowTime"},{"showRate","xpShowRate"},{"showQuest","xpShowQuest"},{"showRested","xpShowRested"},{"trim","xpTrim"},{"showBackground","xpShowBackground"},{"hideNative","xpHideNative"},{"classColor","xpClassColor"},{"texturedBars","xpTexturedBars"}}
 for i,f in ipairs(toggles) do Toggle(f[1],f[2],(i-1)%2*365,y-math.floor((i-1)/2)*88,349) end
 y=y-math.ceil(#toggles/2)*88-16
 local function Step(key,label,low,high,step,reader,writer)
  local card=w.Box(page,0,y,714,72);w.Text(card,K.L(label),14,-12,480,13)
  local function read() return reader and reader() or X.Get(key) end
  local val=w.Text(card,string.format(step<1 and "%.2f" or "%.0f",read()),14,-43,450,14)
  local function change(delta)
   if K.InCombat() then return end
   local v=math.max(low,math.min(high,math.floor((read()+delta*step)/step+.5)*step))
   if writer then writer(v) else X.Set(key,v) end;val:SetText(string.format(step<1 and "%.2f" or "%.0f",read()))
  end
  w.Button(card,"−",616,-30,36,32,function() change(-1) end);w.Button(card,"+",662,-30,36,32,function() change(1) end);y=y-82
 end
 for _,f in ipairs({{"width","xpWidth",280,1400,10},{"verticalSpace","xpPanelSpace",0,120,2},{"frameSize","xpFrameSize",10,24,1},{"backgroundAlpha","xpBackgroundAlpha",0,1,.05},{"barHeight","xpHeight",8,28,1},{"subHeight","xpSubHeight",8,20,1}}) do Step(unpack(f)) end
 w.Text(page,K.L("xpColors"),8,y,690,18,{.73,.62,.41});y=y-36
 y=ColorRow(page,w,y,"main","xpColorMain")
 for _,entry in ipairs({{"quest","xpColorQuest"},{"rested","xpColorRested"},{"rep","xpColorRep"},{"pet","xpColorPet"}}) do y=ColorRow(page,w,y,entry[1],entry[2]) end
 y=y-12
 w.Button(page,K.L("xpPlaceTop"),0,y,349,34,function() X.Place("top");Redraw() end)
 w.Button(page,K.L("xpPlaceMeter"),365,y,349,34,function() X.Place("meter");Redraw() end);y=y-54
 w.Text(page,K.L("xpTextSettings"),8,y,690,18,{.73,.62,.41});y=y-38
 X.selected=X.selected or "xp"
 for i,id in ipairs(X.ids) do
  local selected=id
  local b=w.Button(page,K.L("xpLabel_"..id),((i-1)%3)*243,y-math.floor((i-1)/3)*39,235,32,function() X.selected=selected;Redraw() end)
  w.Selected(b,X.selected==id)
 end
 y=y-3*39-12
 local id=X.selected
 X.textSettingsOffset=-y
 w.Text(page,K.L("xpLabel_"..id).." · "..K.L("xpTextSettings"),8,y,690,17,{.73,.62,.41});y=y-34
 y=ColorRow(page,w,y,"label","xpTextColor",id)
 local function Read(key,default) return function() return X.LabelValue(id,key) end end
 local function Write(key) return function(v) X.SetLabel(id,key,v) end end
 Toggle("","xpLabelVisible",0,y,714,Read("visible",true),Write("visible"));y=y-88
 for i,label in ipairs({"xpLeft","xpCenter","xpRight"}) do
  local value=i-1;local b=w.Button(page,K.L(label),(i-1)*243,y,235,32,function() X.SetLabel(id,"align",value);Redraw() end)
  w.Selected(b,X.LabelValue(id,"align")==value)
 end
 y=y-46
 for _,f in ipairs({{"x","xpTextX",-1400,1400,2,0},{"y","xpTextY",-400,400,2,0},{"size","xpTextSize",8,28,1,id=="xp" and 13 or 11}}) do Step(f[1],f[2],f[3],f[4],f[5],Read(f[1],f[6]),Write(f[1])) end
 for i,label in ipairs({"xpFontRegular","xpFontBold","xpFontGame"}) do
  local value=i-1;local b=w.Button(page,K.L(label),(i-1)*243,y,235,32,function() X.SetLabel(id,"font",value);Redraw() end);w.Selected(b,(X.LabelSettings(id).font or 0)==value)
 end
 y=y-48
 w.Button(page,K.L("xpResetText"),0,y,349,34,function() X.ResetLabels();Redraw() end)
 w.Button(page,K.L("xpResetSession"),365,y,349,34,function() if not K.InCombat() then X.ResetSession();Redraw() end end)
 page:SetHeight(-y+70)
end
end)(K)
