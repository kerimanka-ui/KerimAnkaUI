-- Classic-only small, paginated controls using the existing feature setters.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local Q={};K.LayoutQuickOptions=Q
local Copy=function(v)return K.LayoutAdapters.Copy(v)end
local function Root(key)if not K.db then return end;K.db[key]=K.db[key]or{};return K.db[key]end
local function Group(name,scope,refresh)
 local g={name=name,scope=scope,refresh=refresh,fields={},keys={}}
 function g.Add(key,label,lo,hi,step,get,set,choices)
  g.keys[key]=true
  local d={key=key,label=label,lo=lo,hi=hi,step=step or 1,get=get,set=set,choices=choices,group=name}
  g.fields[#g.fields+1]=d;return d
 end
 function g.API(api,key,label,lo,hi,step,choices)
  return g.Add(key,label,lo,hi,step,function()if api.Get then return api.Get(key)end;return api.GetSettings()[key]end,function(v)return api.Set(key,v)end,choices)
 end
 return g
end
local function Flag(g,api,key,label)g.API(api,key,label)end
local function Number(g,api,key,label,lo,hi,step)g.API(api,key,label,lo,hi,step)end
local function Color(g,key,label,get,set)
 g.keys[key]=true
 for i=1,3 do
  local index=i
  g.Add(key..'.'..i,label,0,1,.05,function()return (get()or{1,1,1})[index]end,function(v)local c=Copy(get()or{1,1,1});c[index]=v;return set(c)end).suffix=({'R','G','B'})[i]
  g.keys[key..'.'..i]=nil
 end
end
function Q.Group(name)
 local g,api
 if name=='units'then
  api=ForeverLeatherUnitsAPI;if not api or not api.GetSettings()or not K.SetUnitOption then return end
  g=Group(name,api.GetSettings,api.Apply)
  local special=false
  for _,class in ipairs({'Warrior','Warlock','Shaman','Mage','Druid','Priest'})do if api['Is'..class]and api['Is'..class]()then special=true end end
  local hunter=api.IsHunter and api.IsHunter();local shaman=api.IsShaman and api.IsShaman();local pet=api.SupportsPet and api.SupportsPet()
  for _,f in ipairs(K.UnitProfileFields or{})do
   local key=f[1]
   local tag=f[8];local available=(tag~='summons'or hunter or shaman)and(tag~='notWarlock'or not special)and(tag~='warlock'or special)and(tag~='hunter'or hunter)and(tag~='pet'or pet)and(tag~='rogue'or select(2,UnitClass('player'))=='ROGUE')
   if available then
   if key~='section'and not key:find('%.')and key~='locked'then
    g.Add(key,shaman and key:find('^hunterSummon')and('uf_'..key:gsub('^hunterSummon','shamanTotem'))or'uf_'..key,f[5],f[6],f[7],function()local d=api.GetSettings();if key=='totNameScale'then return d.totNameScale or d.textScale or 1 end;return d[key]end,function(v)return K.SetUnitOption(key,v)end)

   end
  end
  end
  for _,unit in ipairs({'player','target','pet'})do for _,kind in ipairs({'Buff','Debuff'})do g.keys[unit..kind..'X']=true;g.keys[unit..kind..'Y']=true end end
  local tick=KerimAnkaUIClassicEnergyTick
  if tick and select(2,UnitClass('player'))=='ROGUE'then
   g.Add('classicEnergyTickMode','etTitle',nil,nil,nil,tick.GetMode,tick.SetMode,{{'always','etAlways'},{'combat','etCombat'},{'off','etOff'}})
  end
  local mana=KerimAnkaUIClassicManaTick
  if mana then
   g.Add('classicManaTickMode','mtTitle',nil,nil,nil,mana.GetMode,mana.SetMode,{{'always','etAlways'},{'combat','etCombat'},{'off','etOff'}})
  end
 elseif name=='combo'then
  api=KerimAnkaUIClassicCombo;if not api or not api.Settings()then return end
  g=Group(name,api.Settings,api.Refresh)
  g.Add('size','qeSize',12,40,1,function()return api.Settings().size end,function(v)return api.Set('size',v)end)
  g.Add('gap','qeSpacing',0,16,1,function()return api.Settings().gap end,function(v)return api.Set('gap',v)end)
 elseif name=='swing'then
  api=K.ClassicSwingTimer;if not api or not api.GetSettings()then return end
  g=Group(name,api.GetSettings,function()api.Set('scale',api.GetSettings().scale)end)
  for _,h in ipairs({'mainhand','offhand','ranged'})do
   for _,key in ipairs({'width','height'})do
    local hand,k=h,key
    g.keys.bars=true
    g.Add(h..'.'..key,key=='width'and'swWidth'or'swHeight',key=='width'and 140 or 15,key=='width'and 852 or 60,key=='width'and 10 or 1,function()return api.GetSettings().bars[hand][k]end,function(v)return api.SetBar(hand,k,v)end).hand=hand
    g.keys[h..'.'..key]=nil
   end
  end
  Number(g,api,'scale','swScale',.5,2,.05);Number(g,api,'alpha','swAlpha',.2,1,.05)
  Number(g,api,'textSize','swTextSize',8,24,1)
  Flag(g,api,'labels','swLabels');Flag(g,api,'time','swTime')
  g.API(api,'visibility','qeVisibility',nil,nil,nil,{{'always','swAlways'},{'combat','swCombat'}})
  g.API(api,'textFont','swFont',nil,nil,nil,{{'game','swFontGame'},{'ui','swFontUI'},{'bold','swFontBold'}})
  Color(g,'textColor','swTextColor',function()return api.GetSettings().textColor end,api.SetTextColor)
 elseif name=='cast'then
  api=K.ClassicCastBar;if not api or not api.GetSettings()then return end
  g=Group(name,api.GetSettings,api.Refresh)
  Number(g,api,'width','swWidth',140,600,10);Number(g,api,'height','swHeight',10,40,1);Number(g,api,'scale','swScale',.5,2,.05);Number(g,api,'fontSize','pcFont',8,24,1)
  Flag(g,api,'icon','pcIcon');Flag(g,api,'time','swTime')
 elseif name=='sound'or name=='fps'or name=='bagShortcut'or name=='coordinates'or name=='drawer'then
  local defs={sound={K.SoundShortcut,'soundShortcut'},fps={K.FPS,'fps'},bagShortcut={K.BagShortcut,'bagShortcut'},coordinates={K.MinimapCoordinates,'minimapCoords'},drawer={K.MinimapButtons,'minimapButtons'}}
  api=defs[name][1];if not api then return end
  g=Group(name,function()return Root(defs[name][2])end,api.Refresh)
  if name=='sound'then Number(g,api,'size','mmSoundSize',24,64,1)
  elseif name=='fps'then Flag(g,api,'showMS','fpsShowMS')
  elseif name=='bagShortcut'then Number(g,api,'size','qeSize',24,80,1)
  elseif name=='coordinates'then
   Number(g,api,'size','swTextSize',8,32,1);Flag(g,api,'outline','mcOutline')
   g.API(api,'font','swFont',nil,nil,nil,{{0,'xpFontRegular'},{1,'xpFontBold'},{2,'xpFontGame'}})
  elseif name=='drawer'then
   Number(g,api,'buttonSize','mbButtonSize',20,64,1);Number(g,api,'iconSize','mbSize',24,40,1);Number(g,api,'columns','qeColumns',1,12,1);Number(g,api,'radius','qeRadius',0,80,1)
   g.API(api,'buttonStyle','qeStyle',nil,nil,nil,{{1,'mbRound'},{2,'mbSquare'}});Flag(g,api,'showTooltip','mbShowTooltip')
  end
  Flag(g,api,'enabled','qeVisible')
 elseif name=='minimap'then
  api=K.ClassicMinimapControls;if not api then return end
  g=Group(name,function()return Root('minimapControls')end,api.Refresh)
  Number(g,api,'sunSize','mmSunSize',50,150,5);Flag(g,api,'clockLocked','mmClockLock')
 elseif name=='experience'then
  api=K.Experience;if not api then return end
  g=Group(name,function()return Root('experience')end,function()api.Set('width',api.Get('width'))end)
  for _,f in ipairs({{'width','xpWidth',280,1400,10},{'barHeight','xpHeight',8,28,1},{'subHeight','xpSubHeight',8,20,1},{'frameSize','xpFrameSize',10,24,1},{'verticalSpace','xpPanelSpace',0,120,2},{'backgroundAlpha','xpBackgroundAlpha',0,1,.05}})do Number(g,api,unpack(f))end
  for _,e in ipairs({{'showRep','xpShowRep'},{'showPet','xpShowPet'},{'showTime','xpShowTime'},{'showRate','xpShowRate'},{'showQuest','xpShowQuest'},{'showRested','xpShowRested'},{'trim','xpTrim'},{'classColor','xpClassColor'}})do Flag(g,api,e[1],e[2])end
  g.keys.labels=true;g.keys.colors=true
  if api.GetColor and api.SetColor then
   for _,name in ipairs({'main','quest','rested','rep','pet'})do
    local colorKey=name
    Color(g,'colors','xpColor'..name:sub(1,1):upper()..name:sub(2),function()return{api.GetColor(colorKey)}end,function(c)return api.SetColor(colorKey,c)end)
   end
  end
  for _,id in ipairs(api.ids or{})do
   for _,f in ipairs({{'size','xpTextSize',8,28,1},{'x','xpTextX',-1400,1400,2},{'y','xpTextY',-400,400,2}})do
    local labelID,key=id,f[1]
    local d=g.Add(id..'.'..key,f[2],f[3],f[4],f[5],function()return api.LabelValue(labelID,key)end,function(v)return api.SetLabel(labelID,key,v)end);d.prefix='xpLabel_'..id;g.keys[id..'.'..key]=nil
   end
   local labelID=id
   g.Add(id..'.visible','xpLabelVisible',nil,nil,nil,function()return api.LabelValue(labelID,'visible')end,function(v)return api.SetLabel(labelID,'visible',v)end).prefix='xpLabel_'..id;g.keys[id..'.visible']=nil
   g.Add(id..'.font','swFont',nil,nil,nil,function()return api.LabelValue(labelID,'font')end,function(v)return api.SetLabel(labelID,'font',v)end,{{0,'xpFontRegular'},{1,'xpFontBold'},{2,'xpFontGame'}}).prefix='xpLabel_'..id;g.keys[id..'.font']=nil
   g.Add(id..'.align','qeAlignment',nil,nil,nil,function()return api.LabelValue(labelID,'align')end,function(v)return api.SetLabel(labelID,'align',v)end,{{0,'xpLeft'},{1,'xpCenter'},{2,'xpRight'}}).prefix='xpLabel_'..id;g.keys[id..'.align']=nil
  end
 elseif name=='micro'or name=='inventory'then
  api=K.InventoryMenus;if not api then return end
  g=Group(name,function()return K.db end,api.Refresh)
  if name=='micro'then Number(g,api,'microSize','imIconSize',18,48,1);Number(g,api,'microGap','imGap',0,16,1)
  else
   Number(g,api,'bagSize','imBagSize',18,48,1);Number(g,api,'bagGap','imGap',0,16,1)
   for _,e in ipairs({{'bagBackground','imBagBackground'},{'bagFrame','imBagFrame'},{'bagIconBorder','imBagIconBorder'},{'bagJunk','imJunk'},{'bagQuality','imQuality'}})do Flag(g,api,e[1],e[2])end
  end
 elseif name=='bags'then
  api=K.ClassicBags;if not api then return end
  g=Group(name,function()return Root('classicBags')end,api.Refresh)
  g.Add('columns','qeColumns',6,14,1,function()return Root('classicBags').columns or 10 end,function(v)Root('classicBags').columns=v;api.Refresh();return true end)
  g.Add('shelfHidden','qeHideBagIcons',nil,nil,nil,function()return Root('classicBags').shelfHidden==true end,api.SetShelfHidden)
 elseif name=='range'or name=='threat'then
  api=name=='range'and ForeverHunterRangeAPI or ForeverThreatAPI;if not api or not api.GetSettings()then return end
  g=Group(name,api.GetSettings,function()local d=api.GetSettings();api.Set(name=='range'and'width'or'size',name=='range'and d.width or d.size)end)
  if name=='range'then
   Number(g,api,'width','hr_width',150,420,10);Number(g,api,'height','hr_height',28,60,2);Number(g,api,'fontSize','hr_fontSize',10,24,1)
   for _,key in ipairs({'coloredText','outline','shadow'})do Flag(g,api,key,'hr_'..key)end
  else
   Number(g,api,'size','ft_size',12,96,2);Number(g,api,'alpha','ft_alpha',.2,1,.05)
   for _,key in ipairs({'autoColor','raw','showPercent','bold','outline','shadow'})do Flag(g,api,key,'ft_'..key)end
   local choices={};for _,f in ipairs(api.GetFonts())do choices[#choices+1]={f.name,f.name}end;g.API(api,'font','swFont',nil,nil,nil,choices)
   g.keys.r=true;g.keys.g=true;g.keys.b=true
   for i,key in ipairs({'r','g','b'})do
    local k,index=key,i
    g.Add(k,'swTextColor',0,1,.05,function()return api.GetSettings()[k]end,function(v)local d=api.GetSettings();local c={d.r,d.g,d.b};c[index]=v;return api.SetColor(unpack(c))end).suffix=({'R','G','B'})[i]
   end
  end
 elseif name=='aspect'then
  api=HunterAspectAlertAPI;if not api or not api.GetSettings()then return end
  g=Group(name,api.GetSettings,api.RefreshText)
  for _,e in ipairs({{'showText','aaText'},{'cheetahGlow','aaGlow'}})do Flag(g,api,e[1],e[2])end
  for _,e in ipairs({{'cheetahText','aaCheetah'},{'missingText','aaMissing'}})do
   local key=e[1];g.keys[key..'Custom']=true
   g.Add(key,e[2],nil,nil,nil,function()return api.GetText and api.GetText(key)or api.GetSettings()[key]end,function(v)return api.Set(key,v)end).text=true
  end
 end
 return g
end
function Q.Groups(id)
 if id:match('^unit%.')or id:match('^aura%.')or id=='targetCast'then return{'units'}end
 if id:match('^swing%.')then return{'swing'}end
 if id:match('^minimap%.')then return{'minimap'}end
 if id=='bags'then return{'bags','inventory'}end
 return{id}
end
function Q.Fields(id)
 local fields={}
 for _,name in ipairs(Q.Groups(id))do
  local g=Q.Group(name)
  if g then for _,f in ipairs(g.fields)do
   local visible=not f.hand or f.hand==id:match('^swing%.(.+)')
   if id=='minimap.clock'then visible=f.key=='clockLocked'elseif id=='minimap.sun'then visible=f.key=='sunSize'end
   local selectedUnit=id:match('^unit%.(.+)')
   if selectedUnit then visible=K.UnitOptionApplies(selectedUnit,f.key)end
   if id=='targetCast'then visible=f.key:match('^cast')or f.key=='targetCastEnabled'
   elseif id:match('^aura%.')then local unit=id:match('^aura%.(%a+)[BD]');visible=unit and f.key:match('^'..unit)or f.key=='auraCooldown'or f.key=='auraStacks'
   end
   if visible then fields[#fields+1]=f end
  end end
 end
 if id:match('^unit%.')then
  local priority={scale=1,textScale=2,totNameScale=2,healthTextScale=3,powerTextScale=4,levelTextScale=5,levelOffsetY=6,nameOffsetY=7,classificationTextScale=8}
  for i,f in ipairs(fields)do f.order=i end
  table.sort(fields,function(a,b)return(priority[a.key]or a.order+20)<(priority[b.key]or b.order+20)end)
 end
 if K.LayoutElements then
  local visibility=K.LayoutElements.VisibilityField(id)
  if visibility then
   for i=#fields,1,-1 do if fields[i].key==visibility.control or fields[i].key=='enabled'then table.remove(fields,i)end end
   table.insert(fields,1,visibility)
  end
 end
 return fields
end
function Q.Capture(name)
 local g=Q.Group(name);local d=g and g.scope();if not d then return end
 if name=='swing'then g.keys.enabled=true;g.keys.hands=true elseif name=='micro'then g.keys.microEnabled=true elseif name=='cast'or name=='experience'or name=='range'or name=='threat'or name=='aspect'then g.keys.enabled=true end
 local values={};for key in pairs(g.keys)do if d[key]~=nil then values[key]=Copy(d[key])end end
 return {values=values}
end
function Q.Restore(name,snapshot)
 local g=Q.Group(name);local d=g and g.scope()
 if not d or type(snapshot)~='table'or type(snapshot.values)~='table'then return false end
 if name=='swing'then g.keys.enabled=true;g.keys.hands=true elseif name=='micro'then g.keys.microEnabled=true elseif name=='cast'or name=='experience'or name=='range'or name=='threat'or name=='aspect'then g.keys.enabled=true end
 for key in pairs(g.keys)do d[key]=Copy(snapshot.values[key])end
 if g.refresh then g.refresh()end
 return true
end
function Q.Set(id,index,value)
 local E=K.LayoutEditor;if not E or not E.IsActive()or InCombatLockdown()then return false end
 local f=Q.Fields(id)[index];if not f then return false end
 if f.lo then
  if type(value)~='number'or value~=value or math.abs(value)==math.huge then return false end
  value=math.max(f.lo,math.min(f.hi,value))
 elseif f.choices then
  local valid=false;for _,c in ipairs(f.choices)do if value==c[1]then valid=true end end;if not valid then return false end
 elseif f.text then if type(value)~='string'or #value>400 then return false end
 elseif type(value)~='boolean'then return false end
 if not E.MarkQuick(f.group)then return false end
 local ok=f.set(value)
 if K.LayoutPreviews then K.LayoutPreviews.Focus(id,f.key);K.LayoutPreviews.Invalidate()end
 if ok==false then return false end
 E.Refresh();return true
end

local panel,rows,title,note,pager,full,close,prev,nextButton,moveText;local current,page,fields=nil,1,{}
local pageSize=6
local function Font(parent,size)
 local t=parent:CreateFontString(nil,'OVERLAY');K.ApplyTextFont(t,size,false,'OUTLINE');t:SetTextColor(.93,.93,.89);return t
end
local function Skin(f)
 f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});f:SetBackdropColor(.055,.065,.06,.98);f:SetBackdropBorderColor(.72,.57,.29,1)
end
local function Button(parent,label,x,y,w,fn)
 local b=CreateFrame('Button',nil,parent,'BackdropTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(w,25);Skin(b);b.label=Font(b,11);b.label:SetPoint('CENTER');b.label:SetWidth(w-6);b.label:SetText(label);b:SetScript('OnClick',fn);return b
end
local function Label(f)
 local s=K.L(f.label)
 if f.prefix then s=K.L(f.prefix)..': '..s end
 if f.suffix then s=s..' '..f.suffix end
 return s
end
local Draw
local function Ensure()
 if panel then return end
 panel=CreateFrame('Frame',nil,UIParent,'BackdropTemplate');Q.panel=panel;Skin(panel);panel:SetSize(370,492);panel:SetFrameStrata('FULLSCREEN_DIALOG');panel:SetFrameLevel(150);panel:SetClampedToScreen(true);panel:EnableMouse(true);panel:SetMovable(true);panel:RegisterForDrag('LeftButton');panel:SetScript('OnDragStart',function(self)self:StartMoving()end);panel:SetScript('OnDragStop',function(self)self:StopMovingOrSizing()end)
 panel:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',-20,-110)
 title=Font(panel,14);title:SetPoint('TOPLEFT',12,-12);title:SetWidth(306);title:SetJustifyH('LEFT')
 close=Button(panel,'X',335,-7,25,function()Q.Hide()end)
 note=Font(panel,10);note:SetPoint('TOPLEFT',12,-38);note:SetWidth(346);note:SetWordWrap(true)
 rows={}
 for i=1,pageSize do
  local row=CreateFrame('Frame',nil,panel);row:SetPoint('TOPLEFT',12,-76-(i-1)*51);row:SetSize(346,48)
  row.label=Font(row,11);row.label:SetPoint('TOPLEFT',0,0);row.label:SetWidth(344);row.label:SetJustifyH('LEFT');row.label:SetWordWrap(false)
  row.value=CreateFrame('EditBox',nil,row,'BackdropTemplate');Skin(row.value);K.ApplyTextFont(row.value,12,false,'');row.value:SetPoint('TOPLEFT',40,-18);row.value:SetSize(266,25);row.value:SetAutoFocus(false);row.value:SetMaxLetters(100);row.value:SetTextInsets(7,7,0,0)
  row.value:SetScript('OnEnterPressed',function(self)
   local f=fields[row.index];if not f then return end
   Q.Set(current,row.index,f.text and self:GetText()or tonumber(self:GetText()));self:ClearFocus();Draw()
  end)
  row.value:SetScript('OnEscapePressed',function(self)self:ClearFocus();Draw()end)
  local function Change(delta)
   local f=fields[row.index];if f then Q.Set(current,row.index,(tonumber(f.get())or f.lo)+delta*f.step);Draw()end
  end
  row.minus=Button(row,'-',0,-18,32,function()Change(-1)end);row.plus=Button(row,'+',314,-18,32,function()Change(1)end)
  row.choice=Button(row,'',0,-18,346,function()
   local f=fields[row.index];if not f then return end
   local v=f.get()
   if f.choices then
    local n=0;for index,c in ipairs(f.choices)do if c[1]==v then n=index;break end end
    local c=f.choices[n%#f.choices+1];if c then Q.Set(current,row.index,c[1])end
   else Q.Set(current,row.index,not v)end
   Draw()
  end)
  local function FocusField()
   local f=fields[row.index]
   if f and K.LayoutPreviews then K.LayoutPreviews.Focus(current,f.key);K.LayoutEditor.Refresh()end
  end
  for _,control in ipairs({row.minus,row.plus,row.value,row.choice})do control:SetScript('OnEnter',FocusField)end
  row.value:SetScript('OnEditFocusGained',FocusField)
  rows[i]=row
 end
 prev=Button(panel,'<',12,-389,42,function()page=math.max(1,page-1);Draw()end)
 nextButton=Button(panel,'>',316,-389,42,function()page=math.min(math.max(1,math.ceil(#fields/pageSize)),page+1);Draw()end)
 pager=Font(panel,11);pager:SetPoint('TOP',panel,'TOP',0,-396)
 for i,delta in ipairs({{-1,0},{1,0},{0,1},{0,-1}})do
  local dx,dy=delta[1],delta[2]
  Button(panel,({'<','>','^','v'})[i],12+(i-1)*44,-424,38,function()local E=K.LayoutEditor;if E then E.Nudge(dx,dy)end end)
 end
 moveText=Font(panel,10);moveText:SetPoint('TOPLEFT',192,-430);moveText:SetWidth(166)
 full=Button(panel,K.L('leSettings'),12,-460,346,function()K.LayoutEditor.OpenSettings(current)end)
 panel:Hide()
end
Draw=function()
 if not panel or not current or not K.LayoutEditor.IsActive()then return end
 fields=Q.Fields(current);page=math.max(1,math.min(page,math.max(1,math.ceil(#fields/pageSize))))
 title:SetText(Q.label or K.L('qeTitle'));note:SetText(K.L('qeHelp'));full.label:SetText(K.L('leSettings'));moveText:SetText(K.L('qeNudge'))
 for i,row in ipairs(rows)do
  row.value:ClearFocus();local index=(page-1)*pageSize+i;local f=fields[index];row.index=index;row:SetShown(f~=nil)
  if f then
   row.label:SetText(Label(f));local v=f.get()
   row.value:SetShown(f.lo~=nil or f.text==true);row.minus:SetShown(f.lo~=nil);row.plus:SetShown(f.lo~=nil);row.choice:SetShown(not f.lo and not f.text)
   if f.lo then row.value:SetText(string.format(f.step<1 and '%.2f'or'%.0f',tonumber(v)or f.lo))
   elseif f.text then row.value:SetText(v or'')
   else
    local text=K.L(v and'on'or'off')
    if f.choices then text=tostring(v or'');for _,c in ipairs(f.choices)do if c[1]==v then text=K.L(c[2]);break end end end
    row.choice.label:SetText(text)
   end
  end
 end
 pager:SetText(string.format('%d / %d',page,math.max(1,math.ceil(#fields/pageSize))))
end
function Q.Show(id,label)
 if not K.LayoutEditor.IsActive()or InCombatLockdown()then return false end
 Ensure();current=id;Q.label=label;page=1;panel:SetScale(math.min(1,(UIParent:GetHeight()-115)/492));Draw();panel:Show();return true
end
function Q.Sync(id,label)if panel and panel:IsShown()and id~=current then Q.Show(id,label)end end
function Q.Redraw()if panel and panel:IsShown()then Draw()end end
function Q.Hide()if panel then for _,row in ipairs(rows)do row.value:ClearFocus()end;panel:Hide()end;current=nil end
