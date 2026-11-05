-- Bounded, pooled settings surface. Only the selected Classic category is built.
local _,K=...;local M=K.UnitSettingsModel;local V={active=false};K.UnitSettingsView=V
local root,clip,pane,layer,slider,tabs;local tab,unit='general','player';local generation=0
local offset,maximum=0,0;local syncing=false;local offsets={};local open={module=true,scale=true,['buff:player']=true,['debuff:player']=true,['layout:player']=true,['position:player']=true}
local labels,buttons,boxes={},{},{};local nl,nb,nf=0,0,0;local cards,values={},{}
local gold={.79,.72,.51};local ink={.90,.92,.86};local muted={.63,.69,.61}
local tabLabels={general='usGeneral',auras='usAuras',indicators='usIndicators',position='usPosition',class='usClass'}
local unitLabels={player='upPlayer',target='upTarget',pet='upPet',targettarget='usToT'}
local Sync
local function L(k)return K.L(k)end
local function Rounded(f,selected)
 K.UnitWidgets.Rounded(f,selected and .20 or .15,selected and .25 or .165,selected and .17 or .15,selected and{.62,.68,.43,1}or nil,5,f.unitSettingsCard==true)
end
local function Text(text,x,y,width,size,color)
 nl=nl+1;local f=labels[nl]
 if not f then f=layer:CreateFontString(nil,'OVERLAY','GameFontNormal');labels[nl]=f;f:SetJustifyH('LEFT');f:SetJustifyV('TOP')end
 f:SetJustifyH('LEFT');f:SetJustifyV('TOP');f:SetWordWrap(true)
 f:ClearAllPoints();f:SetPoint('TOPLEFT',x,y);f:SetWidth(width);f:SetHeight(32)
 K.ApplyTextFont(f,size,false,'');f:SetTextColor(unpack(color or ink));f:SetText(text);f:Show();return f
end
local function Button(text,x,y,width,height,click,selected)
 nb=nb+1;local f=buttons[nb]
 if not f then f=CreateFrame('Button',nil,pane,'BackdropTemplate');buttons[nb]=f;f.label=f:CreateFontString(nil,'OVERLAY','GameFontNormal');f.label:SetPoint('CENTER');f.label:SetJustifyH('CENTER')end
 if f.switchThumb then f.switchThumb:Hide()end
 f:ClearAllPoints();f:SetPoint('TOPLEFT',x,y);f:SetSize(width,height);f:SetFrameLevel(pane:GetFrameLevel()+4)
 f:SetScript('OnEnter',nil);f:SetScript('OnLeave',nil);f:SetScript('OnClick',click);f.unitSettingKey=nil;f.unitSettingDelta=nil;f:SetAlpha(1);f:Enable();Rounded(f,selected)
 f.label:ClearAllPoints();f.label:SetPoint('CENTER');f.label:SetJustifyH('CENTER')
 K.ApplyTextFont(f.label,12,false,'');f.label:SetWidth(width-8);f.label:SetHeight(height-4);f.label:SetText(text);f.label:SetTextColor(unpack(selected and gold or ink));f:Show();return f
end
local function Switch(x,y,value,click,title)
 local f=Button('',x,y,70,24,click,value)
 K.UnitWidgets.Rounded(f,value and .30 or .25,value and .49 or .28,value and .27 or .24,nil,12,false)
 if not f.switchThumb then f.switchThumb=CreateFrame('Frame',nil,f,'BackdropTemplate');f.switchThumb:EnableMouse(false)end
 local thumb=f.switchThumb;thumb:SetFrameLevel(f:GetFrameLevel()+1);thumb:ClearAllPoints();thumb:SetPoint('TOPLEFT',value and 49 or 3,-3);thumb:SetSize(18,18)
 K.UnitWidgets.Rounded(thumb,.86,.90,.83,{.79,.84,.75,1},9,false);thumb:Show()
 f.label:ClearAllPoints();f.label:SetPoint(value and 'LEFT'or'RIGHT',value and 6 or -6,0);f.label:SetWidth(42);K.ApplyTextFont(f.label,9,true,'');f.label:SetText(L(value and'on'or'off'));local textWidth=f.label:GetStringWidth();if textWidth>42 then K.ApplyTextFont(f.label,9*42/textWidth,true,'')end
 -- State is already written on the switch; detailed help stays on the question mark.
 f:SetScript('OnEnter',nil);f:SetScript('OnLeave',K.HideTooltip)
 return f
end
local function Box(id,x,y,width,height)
 nf=nf+1;local f=boxes[nf]
 if not f then f=CreateFrame('Frame',nil,pane,'BackdropTemplate');boxes[nf]=f;f:EnableMouse(false)end
 f:ClearAllPoints();f:SetPoint('TOPLEFT',x,y);f:SetSize(width,height);f:SetFrameLevel(pane:GetFrameLevel()+1);f.unitSettingsCard=id~='context';Rounded(f,false);f:Show();cards[id]={frame=f,y=-y};return f
end
local function Offset(n)
 offset=math.max(0,math.min(maximum,n or 0));pane:ClearAllPoints();pane:SetPoint('TOPLEFT',clip,'TOPLEFT',0,offset)
 if not syncing then syncing=true;slider:SetValue(offset);syncing=false end
 offsets[tab..':'..unit]=offset
end
Sync=function()
 if not pane then return end
 maximum=math.max(0,pane:GetHeight()-math.max(1,clip:GetHeight()))
 syncing=true;slider:SetMinMaxValues(0,maximum);slider:SetValue(math.min(maximum,offset));syncing=false
 slider:SetShown(maximum>0);Offset(offset)
 if K.scroll and K.scroll.ScrollBar then K.scroll.ScrollBar:Hide()end
end
local function Save()offsets[tab..':'..unit]=offset end
local function Changed()Save();V.Render(true)end
local function Preview(key)
 if K.FocusUnitPreview then K.FocusUnitPreview(key)end
end
local function HelpKey(key)
 if key:find('Aura',1,true)then return'usAuraFlowHelp'end
 if key=='locked'then return'ufMoveHelp'end
 if key:match('^portraitCombat')then return'ufPortraitCombatHelp'end
 if key:match('^questie')then return'ufQuestieHelp'end
 if key:match('^hunterSummon')then return M.Facts().shaman and'ufShamanTotemsHelp'or'ufHunterSummonsHelp'end
 return'ufHelp'
end
local function Hit(key,x,y,width)
 local f=Button('',x,y,width,34,function()Preview(key)end);f:SetAlpha(.01)
 f:SetScript('OnEnter',function()if K.ShowTooltip then K.ShowTooltip(f,L('uf_'..key),L(HelpKey(key)))end end);f:SetScript('OnLeave',K.HideTooltip)
end
local function Numeric(key,x,y,width)
 local f=M.fields[key];local label='uf_'..key;local value=tonumber(M.Read(key))or f[5]
 Text(L(label),x,y+4,width-112,13);Hit(key,x,y,width-114)
 local format=f[7]<1 and'%.2f'or'%.0f'
 local text=Text(format:format(value),x+width-78,y+4,48,14);text:SetHeight(27);text:SetJustifyH('CENTER');text:SetJustifyV('MIDDLE')
 values[key]=function()text:SetText(format:format(tonumber(M.Read(key))or value))end
 for i,delta in ipairs({-1,1})do
  local b=Button(delta<0 and'−'or'+',x+width-110+(i-1)*82,y+4,28,27,function()
   local current=tonumber(M.Read(key))or value
   if K.SetUnitOption(key,math.max(f[5],math.min(f[6],math.floor((current+delta*f[7])/f[7]+.5)*f[7])))then
    if values[key]then values[key]()end;Preview(key)
   end
  end)
  b.unitSettingKey=key;b.unitSettingDelta=delta
  if key:match('AuraColumns$')and M.Read(unit..'AuraSingleRow')then b:Disable()end
 end
end
local function Toggle(key,x,y,width,title,cardId)
 Text(title or L('uf_'..key),x,y+4,width-90,13);Hit(key,x,y,width-92)
 Switch(x+width-70,y+3,M.Read(key)==true,function()
  local value=not M.Read(key)
  if K.SetUnitOption(key,value)then if cardId then open[cardId]=value end;Changed()end
 end,title or L('uf_'..key))
end
local function DrawCard(c,keys,x,y,width)
 local expanded=open[c.id]==true;local n=0;for _,key in ipairs(keys)do if key~=c.enable then n=n+1 end end
 local columns=c.full and n>1 and 2 or 1
 local auraNote=c.id:match('^layout:')or c.id=='cast'
 local extra=c.id=='module'and 108 or c.id:match('^layout:')and 92 or auraNote and 64 or 0
 local combo=c.id=='combo'and KerimAnkaUIClassicCombo
 if combo then extra=44 end
 local height=60+(expanded and(math.ceil(n/columns)*52+12+extra)or(c.enable and not M.Read(c.enable)and 28 or 0))
 Box(c.id,x,y,width,height)
 Text(L(c.title),x+13,y-11,width-(c.enable and 180 or 90),14,gold)
 Text(c.id=='tot'and L('usToT')or c.shared and L('usShared')or L(unitLabels[unit]),x+13,y-34,width-40,11,muted)
 local focusKey=c.enable or keys[1]
 local head=Button('',x+11,y-7,width-(c.enable and 180 or 90),27,function()Preview(focusKey)end);head:SetAlpha(.01)
 if c.enable then Switch(x+width-118,y-13,M.Read(c.enable)==true,function()
  local v=not M.Read(c.enable);if K.SetUnitOption(c.enable,v)then open[c.id]=v;Changed()end
 end,L(c.title))end
 local help=Button('?',x+width-(c.enable and 150 or 70),y-12,24,27,function()if K.ShowTooltip then K.ShowTooltip(root,L(c.title),L(HelpKey(focusKey)))end end)
 help:SetScript('OnEnter',function()if K.ShowTooltip then K.ShowTooltip(help,L(c.title),L(HelpKey(focusKey)))end end);help:SetScript('OnLeave',K.HideTooltip)
 Button(expanded and'−'or'+',x+width-38,y-12,26,27,function()open[c.id]=not expanded;Changed();Preview(focusKey)end)
 if not expanded then
  if c.enable and not M.Read(c.enable)then Text(L('usClosed'),x+13,y-59,width-26,10,muted)end
  return height
 end
 local index=0;local cell=(width-40)/columns
 for _,key in ipairs(keys)do if key~=c.enable then
  local xx=x+13+(index%columns)*(cell+14);local yy=y-64-math.floor(index/columns)*52
  K.UnitOptionPositions[key]=-yy
  if M.fields[key][5]then Numeric(key,xx,yy,cell)else Toggle(key,xx,yy,cell)end
  index=index+1
 end end
 if c.enable then K.UnitOptionPositions[c.enable]=-y end
 local bottom=y-64-math.ceil(n/columns)*52
 if c.id=='module'then
  Button(L('usMove'),x+13,bottom,width-26,28,function()if K.OpenLayoutEditor then K.OpenLayoutEditor()elseif K.layoutEditButton and K.layoutEditButton.Click then K.layoutEditButton:Click()end end)
  Text(L('ufMoveHelp'),x+13,bottom-40,width-26,11,muted):SetHeight(54)
 elseif combo then
  local settings=combo.Settings();local actions={{settings and settings.locked and'usUnlock'or'usLock',function()if not K.InCombat()then combo.Set('locked',not settings.locked);Changed()end end},{'usSmaller',function()if not K.InCombat()then combo.Set('size',settings.size-2)end end},{'usLarger',function()if not K.InCombat()then combo.Set('size',settings.size+2)end end},{'usResetPosition',function()if not K.InCombat()then combo.Reset();Changed()end end}}
  for i,a in ipairs(actions)do Button(L(a[1]),x+13+(i-1)*(width-26)/4,bottom,(width-34)/4,30,a[2])end
 end
 if auraNote then Text(L(c.id:match('^layout:')and'usAuraFlowHelp'or'ufNote'),x+13,bottom,width-26,11,muted):SetHeight(c.id:match('^layout:')and 84 or 54)end
 return height
end
local function TickCard(id,title,help,api,y)
 Box(id,0,y,714,164);Text(L(title),13,y-12,680,14,gold);Text(L(help),13,y-42,680,11,muted)
 for i,mode in ipairs({'always','combat','off'})do local selected=mode
  Button(L(mode=='always'and'etAlways'or mode=='combat'and'etCombat'or'etOff'),13+(i-1)*230,y-108,222,31,function()if api.SetMode(selected)then Changed()end end,api.GetMode()==mode)
 end
 return y-176
end
function V.Render(keep)
 if not V.active or not pane then return end
 generation=generation+1;K.HideTooltip()
 for _,f in ipairs(labels)do f:Hide()end;for _,f in ipairs(buttons)do f:Hide()end;for _,f in ipairs(boxes)do f:Hide()end
 nl,nb,nf=0,0,0;cards={};values={};K.UnitOptionPositions={};K.unitPageBuilding=false
 for _,b in ipairs(tabs)do Rounded(b,b.key==tab);b.label:SetText(L(tabLabels[b.key]));b.label:SetTextColor(unpack(b.key==tab and gold or ink))end
 Text(L(tabLabels[tab]),0,0,500,18,gold)
 Box('context',540,2,174,30)
 local badge=Text(tab=='general'and L('usShared')or L(unitLabels[unit]),546,-5,162,13,gold);badge:SetJustifyH('CENTER')
 Text(L(({general='usGeneralHelp',auras='usAurasHelp',indicators='usIndicatorsHelp',position='usPositionHelp',class='usClassHelp'})[tab]),0,-38,700,12,muted)
 local y=-96;local column=0;local rowHeight=0;local count=0
 for _,c in ipairs(M.Cards(unit))do
  local keys=M.Keys(c,unit)
  if c.tab==tab and M.CardVisible(c,unit)and #keys>0 then
   count=count+1
   if c.full and column==1 then y=y-rowHeight-12;column=0;rowHeight=0 end
   local diag=_G.KerimAnkaDiagnostics;local began=diag and diag.captureScopes and debugprofilestop and debugprofilestop()
   local h=DrawCard(c,keys,c.full and 0 or column*365,y,c.full and 714 or 349)
   if began then diag.RecordScope('UnitOptions.BuildStep',debugprofilestop()-began)end
   if c.full then y=y-h-12 else rowHeight=math.max(rowHeight,h);column=1-column;if column==0 then y=y-rowHeight-12;rowHeight=0 end end
  end
 end
 if column==1 then y=y-rowHeight-12 end
 if tab=='class'then
  local facts=M.Facts()
  if facts.combo and KerimAnkaUIClassicEnergyTick then count=count+1;y=TickCard('energy','etTitle','etHelp',KerimAnkaUIClassicEnergyTick,y)end
  local class=select(2,UnitClass('player'))
  if class~='ROGUE'and class~='WARRIOR'and KerimAnkaUIClassicManaTick then count=count+1;y=TickCard('mana','mtTitle','mtHelp',KerimAnkaUIClassicManaTick,y)end
 end
 if count==0 then Text(L('usEmpty'),10,y,690,13,muted);y=y-50 end
 pane:SetHeight(math.max(100,-y+16,offset>0 and offset+clip:GetHeight()or 0));Sync()
end
local function Build()
 root=CreateFrame('Frame',nil,K.window);root:SetFrameLevel(K.scroll:GetFrameLevel()+5);root:SetPoint('TOPLEFT',K.scroll,'TOPLEFT',0,0);root:SetPoint('BOTTOMRIGHT',K.scroll,'BOTTOMRIGHT')
 tabs={}
 for i,key in ipairs(M.tabs)do
  local b=CreateFrame('Button',nil,root,'BackdropTemplate');b.key=key;b:SetPoint('TOPLEFT',(i-1)*144,0);b:SetSize(138,33)
  b.label=b:CreateFontString(nil,'OVERLAY','GameFontNormal');b.label:SetPoint('CENTER');b.label:SetWidth(130);b.label:SetHeight(29);K.ApplyTextFont(b.label,11,false,'')
  b:SetScript('OnClick',function()Save();tab=key;if unit=='targettarget'and(tab=='auras'or tab=='indicators'or tab=='class')then unit='target';if K.SetUnitPreviewContext then K.SetUnitPreviewContext(unit)end end;offset=offsets[tab..':'..unit]or 0;V.Render()end);tabs[i]=b
 end
 clip=CreateFrame('Frame',nil,root);clip:SetPoint('TOPLEFT',0,-48);clip:SetPoint('BOTTOMRIGHT',-18,0);clip:SetClipsChildren(true)
 pane=CreateFrame('Frame',nil,clip);pane:SetWidth(714)
 layer=CreateFrame('Frame',nil,pane,'BackdropTemplate');layer:SetAllPoints();layer:SetFrameLevel(pane:GetFrameLevel()+3)
 slider=CreateFrame('Slider',nil,root);slider:SetPoint('TOPRIGHT',-1,-48);slider:SetPoint('BOTTOMRIGHT',-1,0);slider:SetWidth(10);slider:SetOrientation('VERTICAL');slider:SetValueStep(1)
 local rail=slider:CreateTexture(nil,'BACKGROUND');rail:SetAllPoints();rail:SetColorTexture(.13,.16,.12,1)
 local thumb=slider:CreateTexture(nil,'ARTWORK');thumb:SetSize(9,32);thumb:SetColorTexture(.5,.57,.43,1);slider:SetThumbTexture(thumb)
 slider:SetScript('OnValueChanged',function(_,n)if not syncing then Offset(n)end end)
 root:EnableMouseWheel(true);root:SetScript('OnMouseWheel',function(_,delta)Offset(offset-delta*40)end)
 root:SetScript('OnSizeChanged',function()if V.active then Sync()end end)
 K.window:HookScript('OnHide',function()V.active=false;generation=generation+1;Save()end)
end
function V.Hide()
 V.active=false;generation=generation+1;if root then Save();root:Hide()end
 if K.scroll and K.scroll.ScrollBar then K.scroll.ScrollBar:SetShown(K.scroll:GetVerticalScrollRange()>0)end
end
function V.Draw(page)
 if not root then Build()end
 V.active=true;root:Show();page:SetHeight(100);K.scroll:SetVerticalScroll(0)
 if unit=='pet'and not M.Facts().pet then unit='player'end
 offset=offsets[tab..':'..unit]or 0;V.Render()
end
function K.DrawUnitsPage(page,complete)V.Draw(page);if complete then complete()end end
function K.CancelUnitPageBuild()generation=generation+1;K.unitPageBuilding=false end
function K.RefreshUnitOptionValues(...)
 if not V.active then return end
 for i=1,select('#',...)do local f=values[select(i,...)];if f then f()end end
end
function K.SetUnitSettingsContext(selected)
 if selected=='pet'and not M.Facts().pet then return end
 Save();unit=selected;if selected=='targettarget'then tab='position';open.tot=true end;offset=offsets[tab..':'..unit]or 0;if V.active then V.Render()end
end
function K.JumpToUnitOption(key)
 local nextTab,id,nextUnit=M.Route(key,unit)
 if nextUnit=='pet'and not M.Facts().pet then return end
 Save();tab,unit=nextTab,nextUnit;open[id]=true;offset=offsets[tab..':'..unit]or 0
 if K.SetUnitPreviewContext then K.SetUnitPreviewContext(unit)end
 if not V.active then return end
 V.Render();local c=cards[id]
 if c then
  Offset(c.y-8);Rounded(c.frame,true);local token=generation
  C_Timer.After(2,function()if V.active and generation==token then Rounded(c.frame,false)end end)
 end
end
