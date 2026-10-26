-- Discoverable on/off state for enabled and disabled KerimAnka editor elements.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local L={};K.LayoutElements=L
local function Units()return ForeverLeatherUnitsAPI and ForeverLeatherUnitsAPI.GetSettings()end
function L.Entries()
 local list={}
 local function Add(id,label,group,get,set,available,reason,focus)
  local e={id=id,label=label,group=group,get=get,set=set,available=available and true or false,reason=reason,focus=focus or id}
  list[#list+1]=e;return e
 end
 local function API(id,label,group,api,key)
  local available=api and api.Set and (api.Get or api.GetSettings and api.GetSettings())
  local e=Add(id,label,group,function()if not available then return false end;if api.Get then return api.Get(key)==true end;return api.GetSettings()[key]==true end,function(v)return api.Set(key,v)end,available);e.control=key
 end
 local u=Units();local units=ForeverLeatherUnitsAPI
 Add('unit.module','units','units',function()return Units()and Units().enabled==true end,function(v)return K.SetUnitOption('enabled',v)end,u~=nil,nil,'unit.player')
 for _,item in ipairs({{'player','upPlayer'},{'target','upTarget'}})do
  local unit,label=item[1],item[2]
  Add('unit.'..unit,label,nil,function()return Units()and Units().enabled==true end,nil,u~=nil,'leItemsLinked')
 end
 local function UnitFeature(id,label,key,pet,applicable)
  local available=u~=nil and applicable~=false
  local function Active()
   local d=Units();return d and d.enabled and d[key]==true and(not pet or d.showPet==true)or false
  end
  local function Set(value)
   if value then
    if not K.SetUnitOption('enabled',true)then return false end
    if pet and not K.SetUnitOption('showPet',true)then return false end
   end
   local ok=K.SetUnitOption(key,value)
   if key=='showCombo'and KerimAnkaUIClassicCombo then KerimAnkaUIClassicCombo.Refresh()end
   return ok
  end
  local e=Add(id,label,'units',Active,Set,available,applicable==false and'leItemsClass'or nil)
  e.control=key
  if available and not u.enabled then e.reason='leItemsParent'end
 end
 local pet=units and units.SupportsPet and units.SupportsPet()or false
 UnitFeature('unit.targettarget','leToT','showToT')
 UnitFeature('unit.pet','upPet','showPet',false,pet)
 for _,owner in ipairs({'player','target','pet'})do
  for _,kind in ipairs({'Buff','Debuff'})do
   local id=owner..kind
   UnitFeature('aura.'..id,'le'..owner:sub(1,1):upper()..owner:sub(2)..kind..'s',id..'s',owner=='pet',owner~='pet'or pet)
  end
 end
 UnitFeature('targetCast','uf_targetCastEnabled','targetCastEnabled')
 local rogue=UnitClass and select(2,UnitClass('player'))=='ROGUE'
 UnitFeature('combo','uf_showCombo','showCombo',false,rogue and KerimAnkaUIClassicCombo~=nil)
 local swing=K.ClassicSwingTimer
 for _,hand in ipairs({'mainhand','offhand','ranged'})do
  local h=hand;local d=swing and swing.GetSettings()
  Add('swing.'..h,h=='mainhand'and'swMain'or h=='offhand'and'swOff'or'swRanged','swing',function()local s=swing and swing.GetSettings();return s and s.enabled and s.hands[h]==true or false end,function(v)if v and not swing.Set('enabled',true)then return false end;return swing.Set(h,v)end,d~=nil)
 end
 API('cast','pcTitle','cast',K.ClassicCastBar,'enabled')
 API('fps','leFPS','fps',K.FPS,'enabled')
 API('experience','experience','experience',K.Experience,'enabled')
 API('sound','soundShortcutTitle','sound',K.SoundShortcut,'enabled')
 API('bagShortcut','bsTitle','bagShortcut',K.BagShortcut,'enabled')
 local coords=K.MinimapCoordinates
 local e
 API('coordinates','leCoordinates','coordinates',coords,'enabled')
 e=list[#list];if coords and coords.Available and not coords.Available()then e.available=false;e.reason='leItemsUnavailable'end
 API('drawer','mbTitle','drawer',K.MinimapButtons,'enabled')
 e=list[#list];if K.MinimapButtons and K.MinimapButtons.IsBlocked()then e.available=false;e.reason='mbConflict'end
 API('micro','imMicro','micro',K.InventoryMenus,'microEnabled')
 API('range','range','range',ForeverHunterRangeAPI,'enabled')
 API('threat','threat','threat',ForeverThreatAPI,'enabled')
 API('aspect','aspect','aspect',HunterAspectAlertAPI,'enabled')
 for _,v in ipairs({{'minimap.clock','leClock',_G.TimeManagerClockButton},{'minimap.sun','leSun',_G.DielFrame or _G.GameTimeFrame}})do
  local id,label,frame=v[1],v[2],v[3]
  Add(id,label,nil,function()return frame~=nil end,nil,frame~=nil,'leItemsFixed')
 end
 return list
end
local function Entry(id)for _,e in ipairs(L.Entries())do if e.id==id then return e end end end
function L.State(id)
 local e=Entry(id);if not e then return end
 return e.available,e.available and e.get()and true or false,e.reason
end
function L.Set(id,value)
 local E=K.LayoutEditor
 if not E or not E.IsActive()or InCombatLockdown()or type(value)~='boolean'then return false end
 local e=Entry(id)
 if not e or not e.available or not e.set or not E.MarkQuick(e.group)then return false end
 if e.set(value)==false then return false end
 L.Refresh()
 local session=E.session
 C_Timer.After(0,function()
  if not E.IsActive()or E.session~=session or InCombatLockdown()then return end
  E.Rebuild(value and e.focus or nil);L.Refresh()
 end)
 return true
end
function L.Select(id)
 local e=Entry(id);local E=K.LayoutEditor
 if not e or not e.available or not E.IsActive()or InCombatLockdown()then return false end
 if not e.get()then if e.set then return L.Set(id,true)end;return false end
 E.Select(e.focus);return E.OpenQuickSettings(e.focus)
end
local panel,rows,title,help,pager;local page=1;local count=8
local function Font(parent,size)
 local t=parent:CreateFontString(nil,'OVERLAY');K.ApplyTextFont(t,size,false,'OUTLINE');t:SetTextColor(.94,.94,.89);return t
end
local function Skin(f)
 f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});f:SetBackdropColor(.055,.065,.06,.98);f:SetBackdropBorderColor(.72,.57,.29,1)
end
local function Button(parent,text,x,y,w,fn)
 local b=CreateFrame('Button',nil,parent,'BackdropTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(w,28);Skin(b);b.label=Font(b,11);b.label:SetPoint('CENTER');b.label:SetWidth(w-10);b.label:SetText(text);b:SetScript('OnClick',fn);return b
end
local function Tip(owner,e)
 if not e then return end
 local active=e.available and e.get()
 local state=K.L(not e.available and'leItemsUnavailable'or active and'on'or'off')
 local reason=K.L(e.reason or(not e.available and'leItemsUnavailableHelp'or e.set and(active and'leItemsDisable'or'leItemsEnable')or'leItemsLinked'))
 GameTooltip:SetOwner(owner,'ANCHOR_RIGHT');GameTooltip:SetText(K.L(e.label)..'\n'..state..'\n'..reason);GameTooltip:Show()
end
local Draw
local function Ensure()
 if panel then return end
 panel=CreateFrame('Frame',nil,UIParent,'BackdropTemplate');L.panel=panel;panel:SetSize(410,492);panel:SetPoint('TOPLEFT',UIParent,'TOPLEFT',20,-138);panel:SetFrameStrata('FULLSCREEN_DIALOG');panel:SetFrameLevel(170);panel:SetClampedToScreen(true);panel:EnableMouse(true);Skin(panel)
 title=Font(panel,15);title:SetPoint('TOPLEFT',12,-12)
 help=Font(panel,11);help:SetPoint('TOPLEFT',12,-39);help:SetWidth(382);help:SetWordWrap(true)
 Button(panel,'X',373,-7,25,function()L.Hide()end)
 rows={}
 for i=1,count do
  local row={}
  row.label=Button(panel,'',12,-100-(i-1)*42,280,function()if row.entry then L.Select(row.entry.id)end end)
  row.state=Button(panel,'',300,-100-(i-1)*42,98,function()local e=row.entry;if e and e.available and e.set then L.Set(e.id,not e.get())end end)
  for _,b in ipairs({row.label,row.state})do b:SetScript('OnEnter',function(self)Tip(self,row.entry)end);b:SetScript('OnLeave',function()GameTooltip:Hide()end)end
  rows[i]=row
 end
 panel:Hide()
 Button(panel,'<',12,-453,48,function()page=math.max(1,page-1);Draw()end)
 Button(panel,'>',350,-453,48,function()page=math.min(math.ceil(#L.Entries()/count),page+1);Draw()end)
 pager=Font(panel,12);pager:SetPoint('BOTTOM',panel,'BOTTOM',0,18)
end
Draw=function()
 if not panel then return end
 local entries=L.Entries();local pages=math.max(1,math.ceil(#entries/count));page=math.max(1,math.min(page,pages))
 title:SetText(K.L('leItems'));help:SetText(K.L('leItemsHelp'))
 for i,row in ipairs(rows)do
  local e=entries[(page-1)*count+i];row.entry=e;row.label:SetShown(e~=nil);row.state:SetShown(e~=nil)
  if e then
   local active=e.available and e.get()
   row.label.label:SetText(K.L(e.label));row.state.label:SetText(K.L(not e.available and'leItemsUnavailable'or active and'on'or'off'))
   row.state.label:SetTextColor(e.available and(active and .35 or .75)or 1,e.available and(active and 1 or .75)or .7,e.available and .75 or .25)
  end
 end
 pager:SetText(string.format('%d / %d',page,pages))
end
function L.Refresh()if panel and panel:IsShown()then Draw()end end
function L.Toggle()
 if not K.LayoutEditor.IsActive()or InCombatLockdown()then return end
 Ensure();if panel:IsShown()then L.Hide()else page=1;panel:SetScale(math.min(1,(UIParent:GetHeight()-145)/492));Draw();panel:Show()end
end
function L.Hide()if panel then panel:Hide()end;if GameTooltip then GameTooltip:Hide()end end
-- Disabled simple elements remain discoverable on the edit canvas. Unit-frame
-- aura rows stay in the catalog until explicitly enabled.
local placeholders={}
function L.VisibilityField(id)
 local e=Entry(id)
 if not e or not e.available or not e.set then return end
 return {key='elementEnabled',label='qeVisible',group=e.group,control=e.control,get=function()return e.get()and true or false end,set=function(v)return L.Set(id,v)end}
end
local function PositionScope(e,create)
 local d
 if e.id=='unit.targettarget'then return Units().targettarget,{'x','y','detached'}
 elseif e.id=='targetCast'then return Units(),{'castX','castY'}
 elseif e.id:match('^swing%.')then
  local s=K.ClassicSwingTimer.GetSettings();local h=e.id:sub(7);s.positions=s.positions or{}
  if create and not s.positions[h]then s.positions[h]={}end
  return s.positions[h]or{}, {'point','relativePoint','x','y'}
 end
 local g=K.LayoutQuickOptions.Group(e.group);d=g and g.scope()
 if e.id=='drawer'then return d,{'angle'}elseif e.id=='micro'then return d,{'microX','microY'}elseif e.id=='aspect'then return d,{'position'}end
 return d,{'x','y'}
end
local function Actor(e)
 local id=e.id
 local native={fps=_G.KerimAnkaUIFPS,sound=_G.KerimAnkaUISoundShortcut,bagShortcut=_G.KerimAnkaUIBagShortcut,coordinates=K.MinimapCoordinates and K.MinimapCoordinates.frame,drawer=_G.KerimAnkaUIIconDrawer,micro=_G.MicroMenuContainer,range=_G.ForeverHunterRangeBar,threat=_G.ForeverThreatDisplay,aspect=_G.HunterAspectAlertPanel,['unit.targettarget']=_G.ForeverLeatherUnit_targettarget,combo=_G.KerimAnkaUIClassicComboFrame}
 local f=native[id]
 if id=='cast'then f=K.ClassicCastBar.holder elseif id=='experience'then f=K.Experience.hud
 elseif id:match('^swing%.')then f=K.ClassicSwingTimer.Frames[id:sub(7)]
 elseif id=='targetCast'and ForeverUnitsCombatWidgets and ForeverUnitsCombatWidgets.GetLayoutElements then local _,cast=ForeverUnitsCombatWidgets.GetLayoutElements();f=cast end
 if f then return f end
 f=placeholders[id]
 if not f then f=CreateFrame('Frame',nil,UIParent);f:EnableMouse(false);f:Hide();placeholders[id]=f end
 local g=K.LayoutQuickOptions.Group(e.group);local d=g and g.scope()or{}
 f:ClearAllPoints();f:SetScale(1);f:SetSize(d.width or 140,d.height or 30)
 if id=='coordinates'then f:SetPoint('CENTER',Minimap,'BOTTOM',d.x or 0,d.y or -40)
 elseif id=='drawer'then f:SetPoint('CENTER',Minimap,'CENTER',-80,-60);f:SetSize(36,36)
 elseif id=='fps'then f:SetPoint('RIGHT',UIParent,'RIGHT',K.FPS.Get('x'),K.FPS.Get('y'));f:SetSize(100,20)
 elseif id=='sound'or id=='bagShortcut'then local api=id=='sound'and K.SoundShortcut or K.BagShortcut;f:SetPoint('CENTER',UIParent,'BOTTOMLEFT',(api.Get('x')or .7)*UIParent:GetWidth(),(api.Get('y')or .8)*UIParent:GetHeight());f:SetSize(api.Get('size')or 36,api.Get('size')or 36)
 else f:SetPoint('CENTER',UIParent,'CENTER',d.x or 0,d.y or 250)end
 return f
end
function L.AddDisabled(list)
 local found={};for _,a in ipairs(list)do found[a.id]=true end
 for _,e in ipairs(L.Entries())do
  local simple=not e.id:match('^unit%.')and not e.id:match('^aura%.')or e.id=='unit.targettarget'
  if simple and not found[e.id]and e.available and e.set and not e.get()then
   local item=e;local a={id=e.id,label=e.label,frame=Actor(e),disabled=true,disabledReason=e.reason,page=e.group=='units'and'units'or e.id=='fps'and'home'or e.id=='sound'and'home'or e.id=='experience'and'experience'or e.id=='coordinates'and'minimap'or e.id=='drawer'and'minimap'or e.id=='micro'and'inventory'or e.id=='bagShortcut'and'inventory'or e.id=='range'and'range'or e.id=='threat'and'threat'or e.id=='aspect'and'aspect'or'home',section=e.id=='sound'and'sounds'or e.id=='fps'and'overview'or'combat'}
   function a.Capture()local d,keys=PositionScope(item,false);local values={};for _,key in ipairs(keys)do values[key]=K.LayoutAdapters.Copy(d and d[key])end;return values end
   function a.Restore(values,quiet)local d,keys=PositionScope(item,true);if not d then return false end;for _,key in ipairs(keys)do d[key]=K.LayoutAdapters.Copy(values[key])end;if not quiet then if item.id=='aspect'and _G.HunterAspectAlertPanel then local f=HunterAspectAlertPanel;f:ClearAllPoints();local p=d.position;if p then f:SetPoint(p[1],UIParent,p[2],p[3],p[4])else f:SetPoint('CENTER',UIParent,'CENTER',0,100)end end;local g=K.LayoutQuickOptions.Group(item.group);if g and g.refresh then g.refresh()end end;return true end
   a.Base=function()return{x=0,y=0}end;a.Move=function()end
   list[#list+1]=a
  end
 end
end
