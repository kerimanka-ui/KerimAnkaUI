-- Own presentation only. Never replace native module methods, edit its module
-- list, or call native Update/MarkDirty/Edit Mode layout functions from Lua.
local API={version=4};ForeverQuestJournalAPI=API
local db,view,scroll,content,nativeContent,originalAlpha
local active,editing,queued=false,false,false
local rows,headers={},{}
local stats={layouts=0,repairs=0,scans=0}
local watched=setmetatable({},{__mode='k'})
local Queue
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function Safe(f) return f and not (f.IsForbidden and f:IsForbidden()) end
local function DB()
 if type(ForeverQuestJournalDB)~='table' then ForeverQuestJournalDB={} end
 local d=ForeverQuestJournalDB
 if type(d.scrollEnabled)~='boolean' then d.scrollEnabled=false end
 if type(d.groupByZone)~='boolean' then d.groupByZone=true end
 if type(d.scrollStep)~='number' or d.scrollStep~=d.scrollStep then d.scrollStep=48 end
 d.scrollStep=math.max(12,math.min(120,d.scrollStep))
 if type(d.collapsedZones)~='table' then d.collapsedZones={} end
 db=d;return d
end
local function OtherTracker() return Questie and Questie.db and Questie.db.profile and Questie.db.profile.trackerEnabled==true end
function API.GetSettings() return DB() end
function API.IsAttached() return active end
function API.IsSuspended() return false end
function API.GetDiagnostics() return {layouts=stats.layouts,repairs=0,scans=stats.scans} end
function API.Status()
 if OtherTracker() then return 'qjOtherTracker' end
 return active and 'qjActive' or 'qjNativeWaiting'
end
local function Offset(value)
 local maximum=math.max(0,content:GetHeight()-scroll:GetHeight())
 scroll:SetVerticalScroll(math.max(0,math.min(maximum,value)))
end
local function Wheel(_,delta)
 if active and not Combat() then Offset(scroll:GetVerticalScroll()-delta*db.scrollStep) end
end
local function Release()
 if Combat() then return end
 if nativeContent and Safe(nativeContent) then nativeContent:SetAlpha(originalAlpha or 1) end
 nativeContent,originalAlpha=nil,nil;active=false
 if view then view:Hide() end
end
local function Label(parent)
 local f=parent:CreateFontString(nil,'OVERLAY')
 f:SetFontObject(ObjectiveTrackerLineFont or GameFontNormal)
 f:SetJustifyH('LEFT');return f
end
local function MakeView(q)
 if view then return end
 view=CreateFrame('Button','KerimAnkaUIQuestViewport',q)
 view:EnableMouse(true);view:EnableMouseWheel(true);view:SetScript('OnMouseWheel',Wheel)
 scroll=CreateFrame('ScrollFrame',nil,view);scroll:SetAllPoints(view)
 scroll:EnableMouseWheel(true);scroll:SetScript('OnMouseWheel',Wheel)
 content=CreateFrame('Frame',nil,scroll);scroll:SetScrollChild(content)
 view:Hide()
end
local function Category(id)
 local api=C_QuestLog
 local index=api.GetHeaderIndexForQuest and api.GetHeaderIndexForQuest(id)
 local info=index and api.GetInfo(index)
 if info and info.isHeader and type(info.title)=='string' and info.title~='' then
  local key='header:'..tostring(info.headerSortKey or info.title)
  if #key<=160 then return key,info.title,index end
 end
 return 'other',OTHER or MISCELLANEOUS or 'Other',math.huge
end
local function Objectives(id,index)
 local api=C_QuestLog
 if api.GetQuestObjectives then return api.GetQuestObjectives(id) or {} end
 local result={}
 if GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
  for n=1,math.min(60,GetNumQuestLeaderBoards(index) or 0) do
   local text,kind,finished=GetQuestLogLeaderBoard(n,index)
   result[#result+1]={text=text,type=kind,finished=finished}
  end
 end
 return result
end
local function Entries()
 local api=C_QuestLog
 if not (api and api.GetNumQuestWatches and api.GetQuestIDForQuestWatchIndex and api.GetLogIndexForQuestID and api.GetInfo) then return end
 local groups,byKey={},{}
 for n=1,math.min(300,api.GetNumQuestWatches()) do
  local id=api.GetQuestIDForQuestWatchIndex(n)
  local index=id and api.GetLogIndexForQuestID(id)
  local info=index and api.GetInfo(index)
  if info and not info.isHeader and not info.isHidden and not info.isTask then
   local key,title,order=Category(id)
   if not db.groupByZone then key,title,order='all','',0 end
   local group=byKey[key]
   if not group then group={key=key,title=title,order=order,quests={}};byKey[key]=group;groups[#groups+1]=group end
   group.quests[#group.quests+1]={id=id,index=index,info=info,objectives=Objectives(id,index)}
  end
 end
 table.sort(groups,function(a,b) if a.order==b.order then return a.title<b.title end;return a.order<b.order end)
 stats.scans=stats.scans+1;return groups
end
local function Header(index,width,y,g)
 local h=headers[index]
 if not h then
  h=CreateFrame('Button',nil,content);headers[index]=h
  h:EnableMouseWheel(true);h:SetScript('OnMouseWheel',Wheel);h:RegisterForClicks('LeftButtonUp')
  h:SetScript('OnClick',function(self) API.ToggleZone(self.zoneKey) end)
  h.icon=h:CreateTexture(nil,'ARTWORK');h.icon:SetPoint('LEFT',0,0);h.icon:SetSize(14,14)
  h.label=Label(h);h.label:SetPoint('LEFT',18,0);h.label:SetWordWrap(false)
  h.count=Label(h);h.count:SetPoint('RIGHT',-3,0);h.count:SetTextColor(.68,.66,.60)
  h.label:SetPoint('RIGHT',h.count,'LEFT',-8,0)
  local glow=h:CreateTexture(nil,'HIGHLIGHT');glow:SetAllPoints();glow:SetColorTexture(1,1,1,.06)
 end
 h.zoneKey=g.key;h:SetSize(math.max(1,width-22),26);h:ClearAllPoints();h:SetPoint('TOPLEFT',content,'TOPLEFT',22,-y)
 h.label:SetFontObject(ObjectiveTrackerLineFont or GameFontNormal);h.count:SetFontObject(ObjectiveTrackerLineFont or GameFontNormal)
 h.label:SetTextColor(1,.82,0);h.label:SetText(g.title);h.count:SetText('('..#g.quests..')')
 h.icon:SetAtlas(db.collapsedZones[g.key] and 'ui-questtrackerbutton-secondary-expand' or 'ui-questtrackerbutton-secondary-collapse')
 h:Show();return y+28
end
local function Click(self,button)
 if Combat() or not self.questID then return end
 if button=='RightButton' then
  if MenuUtil and MenuUtil.CreateContextMenu then
   MenuUtil.CreateContextMenu(self,function(_,root)
    root:CreateTitle(self.titleText or '')
    root:CreateButton(OBJECTIVES_VIEW_IN_QUESTLOG or 'View quest',function() if QuestMapFrame_OpenToQuestDetails then QuestMapFrame_OpenToQuestDetails(self.questID) end end)
    root:CreateButton(OBJECTIVES_STOP_TRACKING or 'Stop tracking',function() if C_QuestLog.RemoveQuestWatch then C_QuestLog.RemoveQuestWatch(self.questID) end end)
   end)
  end
 elseif IsModifiedClick and IsModifiedClick('QUESTWATCHTOGGLE') then
  if C_QuestLog.RemoveQuestWatch then C_QuestLog.RemoveQuestWatch(self.questID) end
 else
  if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID then C_SuperTrack.SetSuperTrackedQuestID(self.questID) end
  if QuestMapFrame_OpenToQuestDetails then QuestMapFrame_OpenToQuestDetails(self.questID) end
 end
end
-- Read geometry only: the native module shrinks to its current rows, while
-- its owning container keeps the height selected in Edit Mode.
local function ViewportHeight(q,c)
 local owner=q.parentContainer or ObjectiveTrackerFrame
 if not Safe(owner) or not c.GetTop or not owner.GetBottom then return c:GetHeight() end
 local top,bottom=c:GetTop(),owner:GetBottom()
 if not top or not bottom then return c:GetHeight() end
 local scale=c:GetEffectiveScale();local ownerScale=owner:GetEffectiveScale()
 if not scale or scale<=0 or not ownerScale or ownerScale<=0 then return c:GetHeight() end
 top=top*scale;bottom=(bottom+(owner.bottomModulePadding or 10))*ownerScale
 if UIParent and UIParent.GetBottom then
  local screenBottom=UIParent:GetBottom()
  if screenBottom then bottom=math.max(bottom,(screenBottom+8)*UIParent:GetEffectiveScale()) end
 end
 -- Do not cover later native achievement/scenario/etc. modules. They keep
 -- their native positions; our own viewport ends above the first one below.
 for _,module in ipairs(owner.modules or {}) do
  if module~=q and Safe(module) and module:IsShown() and module.GetTop then
   local moduleTop=module:GetTop()
   if moduleTop then
    local edge=moduleTop*module:GetEffectiveScale()
    if edge<top and module:GetHeight()>0 then bottom=math.max(bottom,edge+(owner.moduleSpacing or 10)*ownerScale) end
   end
  end
 end
 return math.max(0,(top-bottom)/scale)
end
local function Atlas(region)
 return Safe(region) and region.GetAtlas and region:GetAtlas() or nil
end
local function QuestIcon(r,entry,complete)
 local selected=C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID()==entry.id
 local native=QuestObjectiveTracker
 local block=native and native.usedBlocks and native.usedBlocks[entry.id]
 local poi=block and block.id==entry.id and block.poiButton
 local base=Atlas(poi and poi.NormalTexture)
 local mark=Atlas(poi and poi.Display and poi.Display.Icon)
 r.icon:SetAtlas(base or (selected and 'UI-QuestPoi-QuestNumber-SuperTracked' or 'UI-QuestPoi-QuestNumber'))
 r.iconMark:SetAtlas(mark or (complete and 'UI-QuestIcon-TurnIn-Normal' or (selected and 'Quest-In-Progress-Icon-Brown' or 'Quest-In-Progress-Icon-yellow')))
 -- Texture copies on our own rows. Never initialize a native POI button or
 -- access/write the shared QuestCache/POI highlight manager from our code.
 r.icon:SetSize(32,32);r.iconMark:SetSize(32,32)
end
local function PublicCall(fn,...)
 if type(fn)~='function' then return end
 local ok,value=pcall(fn,...)
 if ok and not (issecretvalue and issecretvalue(value)) then return value end
end
local function TitleColor(entry)
 local difficulty=PublicCall(C_PlayerInfo and C_PlayerInfo.GetContentDifficultyQuestForPlayer,entry.id)
 local color=difficulty~=nil and PublicCall(GetDifficultyColor,difficulty)
 if type(color)~='table' and type(entry.info.level)=='number' then color=PublicCall(GetQuestDifficultyColor,entry.info.level) end
 if type(color)=='table' and type(color.r)=='number' and type(color.g)=='number' and type(color.b)=='number' then
  return color.r,color.g,color.b
 end
 return 1,.82,0
end
local function PinClick(self,button)
 if Combat() or button~='LeftButton' then return end
 local id=self:GetParent().questID
 if not id or not C_SuperTrack then return end
 local selected=C_SuperTrack.GetSuperTrackedQuestID and C_SuperTrack.GetSuperTrackedQuestID()==id
 if selected then
  if C_SuperTrack.ClearAllSuperTracked then C_SuperTrack.ClearAllSuperTracked()
  elseif C_SuperTrack.SetSuperTrackedQuestID then C_SuperTrack.SetSuperTrackedQuestID(0) end
 elseif (IsShiftKeyDown and IsShiftKeyDown()) or (IsModifiedClick and IsModifiedClick('QUESTWATCHTOGGLE')) then
  if C_QuestLog.RemoveQuestWatch then C_QuestLog.RemoveQuestWatch(id) end
 elseif C_SuperTrack.SetSuperTrackedQuestID then C_SuperTrack.SetSuperTrackedQuestID(id) end
 -- The pin only selects/clears the map objective. The quest title retains
 -- its separate map/details action. Never invoke a native POI callback here.
 Queue()
end
local function Row(index,width,y,entry)
 local r=rows[index]
 if not r then
  r=CreateFrame('Button',nil,content);rows[index]=r;r.lines={}
  r:RegisterForClicks('LeftButtonUp','RightButtonUp');r:SetScript('OnClick',Click)
  r:EnableMouseWheel(true);r:SetScript('OnMouseWheel',Wheel)
  r.icon=r:CreateTexture(nil,'ARTWORK',nil,0);r.icon:SetPoint('CENTER',r,'TOPLEFT',25,-7)
  r.iconMark=r:CreateTexture(nil,'ARTWORK',nil,1);r.iconMark:SetPoint('CENTER',r.icon,'CENTER',0,0)
  r.pin=CreateFrame('Button',nil,r);r.pin:SetSize(20,20);r.pin:SetPoint('CENTER',r.icon,'CENTER',0,0)
  r.pin:RegisterForClicks('LeftButtonUp');r.pin:SetScript('OnClick',PinClick)
  r.pin:EnableMouseWheel(true);r.pin:SetScript('OnMouseWheel',Wheel)
  r.title=Label(r);r.title:SetPoint('TOPLEFT',42,0);r.title:SetWordWrap(true)
 end
 r.questID=entry.id;r.titleText=entry.info.title or ''
 local complete=entry.info.isComplete==1 or entry.info.isComplete==true
 if C_QuestLog.IsComplete then complete=C_QuestLog.IsComplete(entry.id)==true end
 local link,icon
 if GetQuestLogSpecialItemInfo then link,icon=GetQuestLogSpecialItemInfo(entry.index) end
 local itemWidth=link and 32 or 0
 local textWidth=math.max(40,width-44-itemWidth)
 r:SetWidth(width);r:ClearAllPoints();r:SetPoint('TOPLEFT',content,'TOPLEFT',0,-y)
 r.title:SetFontObject(ObjectiveTrackerLineFont or GameFontNormal);r.title:SetWidth(textWidth)
 r.title:SetTextColor(TitleColor(entry))
 local level=entry.info.level
 r.title:SetHeight(0)
 r.title:SetText((level and level>0 and '['..level..'] ' or '')..r.titleText)
 QuestIcon(r,entry,complete)
 local height=math.max(1,r.title:GetStringHeight())
 local native=QuestObjectiveTracker
 local lineSpacing=native and native.lineSpacing or 4
 local rowSpacing=-(native and native.fromBlockOffsetY or -10)
 local lineIndex=0
 local function Line(text,finished)
  if type(text)~='string' or text=='' then return end
  lineIndex=lineIndex+1
  local f=r.lines[lineIndex]
  if not f then f=Label(r);r.lines[lineIndex]=f;f:SetWordWrap(true) end
  f:SetFontObject(ObjectiveTrackerLineFont or GameFontNormal);f:SetWidth(textWidth)
  height=height+lineSpacing
  f:ClearAllPoints();f:SetPoint('TOPLEFT',r,'TOPLEFT',42,-height)
  f:SetHeight(0)
  f:SetText((finished and '' or '- ')..text)
  if finished then f:SetTextColor(.65,.65,.60) else f:SetTextColor(.80,.80,.75) end
  f:Show();height=height+math.max(1,f:GetStringHeight())
 end
 if complete then
  -- Completed quests switch from objective counters to native turn-in text.
  -- Do not append our own font-dependent checkmark to either kind of line.
  local completion=GetQuestLogCompletionText and GetQuestLogCompletionText(entry.index)
  if type(completion)~='string' or completion=='' then completion=QUEST_WATCH_QUEST_READY or 'Ready for turn-in' end
  Line(completion,true)
 else
  for n,o in ipairs(entry.objectives) do if n>60 then break end;Line(o.text,o.finished) end
 end
 for n=lineIndex+1,#r.lines do r.lines[n]:Hide() end
 if link then
  if not r.item then
   r.item=CreateFrame('Button',nil,r,'SecureActionButtonTemplate')
   r.item:SetSize(28,28);r.item:SetPoint('TOPRIGHT',-1,-1);r.item:RegisterForClicks('AnyUp','AnyDown')
   r.item.icon=r.item:CreateTexture(nil,'ARTWORK');r.item.icon:SetAllPoints()
   r.item:SetAttribute('type','item')
   r.item:EnableMouseWheel(true);r.item:SetScript('OnMouseWheel',Wheel)
   r.item:SetScript('OnEnter',function(self) if GameTooltip then GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetHyperlink(self.link);GameTooltip:Show() end end)
   r.item:SetScript('OnLeave',function(self) if GameTooltip and GameTooltip:IsOwned(self) then GameTooltip:Hide() end end)
  end
  r.item.link=link;r.item:SetAttribute('item',link);r.item.icon:SetTexture(icon);r.item:Show();height=math.max(30,height)
 elseif r.item then r.item:SetAttribute('item',nil);r.item:Hide() end
 r:SetHeight(height+rowSpacing);r:Show();return y+height+rowSpacing
end
local function Refresh()
 if Combat() then return end
 DB()
 local q=QuestObjectiveTracker
 if not db.scrollEnabled or editing or OtherTracker() or not Safe(q) or not Safe(q.ContentsFrame) then Release();return end
 local c=q.ContentsFrame
 if not c:IsShown() or c:GetHeight()<8 or (q.IsCollapsed and q:IsCollapsed()) then Release();return end
 local groups=Entries();if not groups then Release();return end
 MakeView(q)
 if view:GetParent()~=q then view:SetParent(q) end
 local width=math.max(80,c:GetWidth());local height=ViewportHeight(q,c)
 if height<8 then Release();return end
 view:ClearAllPoints();view:SetPoint('TOPLEFT',c,'TOPLEFT',-22,0);view:SetSize(width+22,height)
 view:SetFrameLevel(c:GetFrameLevel()+50);scroll:SetSize(width+22,height);content:SetWidth(width+22)
 local y,rowIndex,headerIndex=-(q.fromHeaderOffsetY or -10),0,0
 for _,g in ipairs(groups) do
  if db.groupByZone then headerIndex=headerIndex+1;y=Header(headerIndex,width+22,y,g) end
  if not db.groupByZone or not db.collapsedZones[g.key] then
   for _,entry in ipairs(g.quests) do rowIndex=rowIndex+1;y=Row(rowIndex,width+22,y,entry) end
  end
 end
 for n=rowIndex+1,#rows do rows[n]:Hide() end
 for n=headerIndex+1,#headers do headers[n]:Hide() end
 if rowIndex==0 and headerIndex==0 then Release();return end
 content:SetHeight(math.max(1,y));Offset(scroll:GetVerticalScroll())
 if nativeContent~=c then Release();nativeContent=c;originalAlpha=c:GetAlpha() end
 -- Cosmetic C property only. Keep native Header, parents, methods, module
 -- membership, dirty flags, layout sizes and native quest rows untouched.
 c:SetAlpha(0);active=true;view:Show();stats.layouts=stats.layouts+1
end
Queue=function()
 if queued or Combat() then return end
 queued=true;C_Timer.After(.05,function() queued=false;Refresh() end)
end
local function Watch()
 local q=QuestObjectiveTracker
 if not Safe(q) then return end
 for _,f in ipairs({q,q.ContentsFrame,q.parentContainer or ObjectiveTrackerFrame}) do
  if Safe(f) and not watched[f] then
   watched[f]=true
   for _,script in ipairs({'OnSizeChanged','OnShow','OnHide'}) do f:HookScript(script,Queue) end
  end
 end
 -- Post-hooks only schedule own work; they never invoke native code or run
 -- our renderer inside the native/shared Edit Mode update call stack.
 if q.EndLayout and not watched['layout'] then watched['layout']=true;hooksecurefunc(q,'EndLayout',Queue) end
end
function API.Set(key,value)
 if Combat() then return false end
 DB()
 if (key=='scrollEnabled' or key=='groupByZone') and type(value)=='boolean' then db[key]=value
 elseif key=='scrollStep' and type(value)=='number' and value==value and math.abs(value)<math.huge then db[key]=math.max(12,math.min(120,math.floor(value+.5)))
 else return false end
 Queue();return true
end
function API.ToggleZone(key)
 if Combat() or not active or type(key)~='string' or #key>160 then return false end
 DB();local count=0;for _ in pairs(db.collapsedZones) do count=count+1 end
 if not db.collapsedZones[key] and count>=128 then return false end
 db.collapsedZones[key]=not db.collapsedZones[key] or nil;Queue();return true
end
local events=CreateFrame('Frame')
events:SetScript('OnEvent',function() DB();Watch();Queue() end)
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','ADDON_LOADED','QUEST_LOG_UPDATE','QUEST_WATCH_UPDATE','QUEST_WATCH_LIST_CHANGED','QUEST_TURNED_IN','SUPER_TRACKING_CHANGED','PLAYER_LEVEL_UP','PLAYER_REGEN_ENABLED','EDIT_MODE_LAYOUTS_UPDATED'}) do events:RegisterEvent(event) end
if EventRegistry then
 EventRegistry:RegisterCallback('EditMode.Enter',function() editing=true;Queue() end)
 EventRegistry:RegisterCallback('EditMode.Exit',function() editing=false;Queue() end)
end
SLASH_FOREVERQUESTJOURNAL1='/fqj'
SlashCmdList.FOREVERQUESTJOURNAL=function(message)
 local command=(message or ''):lower():match('^%s*(%S+)')
 if command=='stats' then print('KerimAnka Quest: layouts='..stats.layouts..' scans='..stats.scans)
 elseif command=='off' then API.Set('scrollEnabled',false)
 elseif command=='on' then API.Set('scrollEnabled',true)
 elseif KerimAnkaUIAPI then KerimAnkaUIAPI.OpenPage('quests') end
end
