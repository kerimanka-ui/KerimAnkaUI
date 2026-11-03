-- Classic Era profile workflows. Data validation/application lives in Profiles/ProfileTransfer.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local Q={};K.ProfilePage=Q
local tab='saved'
local inputs={}
local selectedIndex=1
local shareSource='current'
local states={saved={partial=false,selection={}},import={partial=false,selection={}},share={partial=false,selection={}}}
local incoming={text=''}
local output
local showLocalSave=false
local pulseTarget
local revealOffset
local pulses={}
local selectionVersion=0
local status
local armed
local deleteArmed
local restoreArmed=false
local forgetArmed=false
local context

local function Copy(value)
 if type(value)~='table' then return value end
 local result={}
 for key,item in pairs(value)do result[key]=Copy(item)end
 return result
end
local function L(key)return K.L(key)end
local function Scope(state)return state.partial and state.selection or nil end
local function Pending()return K.db.profileTransaction~=nil end
local function InCombat()return K.InCombat()end
local function Refresh(targetOffset)
 local offset=targetOffset or K.scroll:GetVerticalScroll()
 C_Timer.After(0,function()
  if not K.window:IsShown()then return end
  K.Render()
  K.scroll:UpdateScrollChildRect()
  K.scroll:SetVerticalScroll(math.max(0,math.min(revealOffset or offset,K.scroll:GetVerticalScrollRange())))
  revealOffset=nil
 end)
end
-- Temporary guidance belongs to this render only; it never changes saved settings.
local function Pulse(frame,id,y)
 if pulseTarget~=id then return end
 pulseTarget=nil;revealOffset=math.max(0,-y-8)
 local border=frame.profileGuidanceBorder
 if not border then border=CreateFrame('Frame',nil,frame,'BackdropTemplate');frame.profileGuidanceBorder=border end
 border:SetPoint('TOPLEFT',-2,2);border:SetPoint('BOTTOMRIGHT',2,-2)
 border:SetFrameLevel(frame:GetFrameLevel()+10);border:EnableMouse(false)
 border:SetBackdrop({edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=2})
 border:SetBackdropBorderColor(1,.77,.25,1)
 border.guidanceVersion=(border.guidanceVersion or 0)+1
 local version=border.guidanceVersion
 border:Show()
 pulses[#pulses+1]=border
 C_Timer.After(3,function()if border.guidanceVersion==version then border:Hide()end end)
end
local function SelectCode(edit)
 selectionVersion=selectionVersion+1
 local version=selectionVersion
 -- Button mouse handling must finish before focus/selection is restored.
 C_Timer.After(0,function()
  if version~=selectionVersion or not edit:IsShown()or not K.window:IsShown()then return end
  edit:SetFocus();edit:HighlightText(0,-1)
 end)
end
local function Changed()
 armed=nil;status=nil;deleteArmed=nil;output=nil
 Refresh()
end
local function Report(key)
 status=key;Refresh(key=="pfQueued"and 0 or nil)
end
function K.HideProfileInputs()
 selectionVersion=selectionVersion+1
 for _,border in ipairs(pulses)do border:Hide()end
 pulses={}
 if K.Profiles and K.Profiles.profileMenu then K.Profiles.profileMenu:Hide()end
 for _,entry in pairs(inputs)do entry.edit:ClearFocus();entry.edit:HighlightText(0,0);entry:Hide()end
end
function K.EndProfileSession()
 armed=nil;status=nil;deleteArmed=nil;restoreArmed=false;forgetArmed=false
 incoming={text=''};output=nil;pulseTarget=nil;revealOffset=nil
 for _,entry in pairs(inputs)do entry.edit:ClearFocus()end
 if inputs.import then inputs.import.edit:SetText('')end
 if inputs.output then inputs.output.edit:SetText('')end
end
local function Input(kind,parent,x,y,width,height)
 local entry=inputs[kind]
 if not entry then
  local code=kind~='name'
  entry=CreateFrame(code and 'ScrollFrame'or'Frame',nil,parent,code and 'UIPanelScrollFrameTemplate'or nil)
  entry.edit=CreateFrame('EditBox',nil,entry,code and nil or 'InputBoxTemplate')
  entry.edit:SetAutoFocus(false)
  K.ApplyTextFont(entry.edit,13,false,'')
  entry.edit:SetTextColor(.94,.93,.87,1)
  entry.edit:SetScript('OnEditFocusLost',function(self)self:HighlightText(0,0)end)
  entry.edit:SetMaxLetters(code and K.Profiles.MAX_CODE+4096 or 48)
  entry.edit:SetMultiLine(code)
  entry.edit:SetScript('OnEscapePressed',function(self)self:ClearFocus()end)
  if code then
   entry:SetScrollChild(entry.edit)
   entry.edit:SetWidth(width-18);entry.edit:SetHeight(height)
   entry.edit:SetScript('OnCursorChanged',function(_,_,cy,_,ch)
    local offset=entry:GetVerticalScroll();local position=-cy
    if position<offset then entry:SetVerticalScroll(math.max(0,position))
    elseif position+ch>offset+entry:GetHeight()then entry:SetVerticalScroll(position+ch-entry:GetHeight())end
   end)
  else entry.edit:SetAllPoints()end
  if kind=='import'then
   entry.edit:SetScript('OnTextChanged',function(self,user)
    if not user then return end
    incoming={text=self:GetText()};armed=nil;status=nil
    if Q.importReview then Q.importReview:Hide()end
    if Q.importStatus then Q.importStatus:SetText(L('pfNeedsValidation'))end
    if Q.inspectButton then
     if not Pending()and incoming.text:find('%S')then Q.inspectButton:Enable()else Q.inspectButton:Disable()end
    end
   end)
  end
  inputs[kind]=entry
 end
 entry:SetParent(parent);entry:ClearAllPoints();entry:SetPoint('TOPLEFT',x,y)
 entry:SetSize(width,height);entry:Show()
 return entry.edit
end
local function Highlight(button,active)
 if not active then return end
 context.Rounded(button,.20,.25,.15,{.65,.72,.39,1},6,true)
 button.label:SetTextColor(1,.9,.55)
end
local function Selection(entries)
 local remembered=K.db.profileSelection
 if type(remembered)=='table'then
  for index,entry in ipairs(entries)do
   if entry.group==remembered.group and entry.key==remembered.key then selectedIndex=index;break end
  end
 end
 selectedIndex=math.max(1,math.min(#entries,selectedIndex))
 return entries[selectedIndex]
end
local function EntryLabel(entry)
 if not entry then return L('pfEmpty')end
 return L(entry.group=='named'and'pfNamed'or'pfCharacter')..': '..entry.key
end
local function Dropdown(owner,entries)
 local P=K.Profiles
 local menu=P.profileMenu
 if menu and menu:IsShown()then menu:Hide();return end
 if not menu then
  menu=CreateFrame('Frame',nil,K.window,'BackdropTemplate');P.profileMenu=menu
  context.Backdrop(menu,.10,.12,.10,{.43,.48,.38,1});menu:SetFrameStrata('DIALOG')
  menu.scroll=CreateFrame('ScrollFrame',nil,menu,'UIPanelScrollFrameTemplate')
  menu.scroll:SetPoint('TOPLEFT',8,-8);menu.scroll:SetPoint('BOTTOMRIGHT',-30,8)
  menu.content=CreateFrame('Frame',nil,menu.scroll);menu.content:SetWidth(636);menu.scroll:SetScrollChild(menu.content)
  menu.rows={}
 end
 menu:SetFrameLevel(K.window:GetFrameLevel()+80)
 menu:ClearAllPoints();menu:SetPoint('TOPLEFT',owner,'BOTTOMLEFT',0,-4)
 menu:SetSize(682,math.min(8,math.max(1,#entries))*34+16)
 menu.content:SetHeight(math.max(34,#entries*34))
 for _,row in ipairs(menu.rows)do row:Hide()end
 for index,entry in ipairs(entries)do
  local item=entry;local itemIndex=index
  local row=menu.rows[index]
  if not row then row=context.FixedButton(menu.content,'',0,-(index-1)*34,636,32,function()end);menu.rows[index]=row end
  row.label:SetText(EntryLabel(item)..' · '..(item.record.class or''))
  row:SetScript('OnClick',function()
   selectedIndex=itemIndex;K.db.profileSelection={group=item.group,key=item.key}
   menu:Hide();Changed()
  end)
  row:Show()
 end
 menu.scroll:SetVerticalScroll(0);menu:Show()
end
local function Picker(parent,y,entries,selected)
 local b=context.Button(parent,EntryLabel(selected)..'  ▾',16,y,682,32,function(self)Dropdown(self,entries)end)
 if not selected or Pending()then b:Disable()end
 if selected then
  context.Text(parent,date('%Y-%m-%d %H:%M',selected.record.stamp)..' · '..(selected.record.class or''),16,y-40,680,12,context.muted)
 end
end
local function DrawScope(parent,y,state,payload,manifest)
 local T=K.ProfileTransfer
 local function available(id)return payload and T.Available(payload,id)and(not manifest or manifest[id])end
 if state.partial then
  for id in pairs(state.selection)do if not available(id)then state.selection[id]=nil end end
 end
 context.Text(parent,L('psTitle'),16,y,680,13)
 local all=context.Button(parent,L(manifest and'pxIncluded'or'psAll'),16,y-26,334,30,function()
  state.partial=manifest~=nil;state.selection=Copy(manifest or{});Changed()
 end)
 local partial=context.Button(parent,L('psSelected'),362,y-26,336,30,function()
  if not state.partial then
   state.partial=true;state.selection={}
   for _,group in ipairs(T.groups)do if available(group.id)then state.selection[group.id]=true end end
  end
  Changed()
 end)
 Highlight(all,not state.partial);Highlight(partial,state.partial)
 if Pending()then all:Disable();partial:Disable()end
 if not state.partial then return y-70 end
 for index,group in ipairs(T.groups)do
  local id=group.id
  local b=context.Button(parent,L(group.label),16+(index-1)*230,y-66,222,30,function()
   state.selection[id]=not state.selection[id]or nil;Changed()
  end)
  Highlight(b,state.selection[id])
  if not available(id)or Pending()then b:Disable()end
 end
 return y-110
end
local function Summary(parent,y,payload,state,record)
 local scope=Scope(state)
 local text
 if scope then text=K.ProfileTransfer.ValidSelection(scope)and K.ProfileTransfer.Description(scope)or L('psChooseOne')
 elseif record and K.ProfileLayouts then text=K.ProfileLayouts.Description(record)..'\n'..L('pxBackupHint')
 else text=L('pxCodeOnly')..'\n'..L('pxBackupHint')end
 if payload then text=string.format(L('pxSourceClass'),payload.class or'?')..'\n'..text end
 if not scope then text=text..'\n'..L('pfSourceHint')end
 context.Text(parent,text,16,y,680,12,context.muted)
 return y-96
end
local function Feedback(parent,y)
 if not status then return end
 context.Text(parent,L(status),16,y,680,13,context.gold)
end
local function CanApply(payload,state)
 if not payload or Pending()or InCombat()then return false end
 if state.partial and not K.ProfileTransfer.ValidSelection(state.selection)then return false end
 return true
end
local function ApplyButton(parent,y,state,payload,action)
 local button=context.Button(parent,L(armed and'pfConfirmApply'or'pfUseSelected'),16,y,682,34,function()
  if not CanApply(payload,state)then return end
  if not armed then armed=true;Report('pxConfirmHint');return end
  armed=nil
  local ok,err=action();Report(err or(ok and'pfQueued'or'pfFailed'))
 end)
 Highlight(button,armed)
 if not CanApply(payload,state)then button:Disable()end
end
local function Saved(y,entries,selected)
 local ui=context;local P,T=K.Profiles,K.ProfileTransfer;local state=states.saved
 local box=ui.Box(ui.page,0,y,714,state.partial and 444 or 404)
 ui.Text(box,L('pxSavedHelp'),16,-14,680,13,ui.muted)
 Picker(box,-48,entries,selected)
 local payload=selected and P.Decode(selected.record.code)
 local bottom=DrawScope(box,-110,state,payload)
 bottom=Summary(box,bottom,payload,state,selected and selected.record)
 ApplyButton(box,bottom,state,payload,function()return T.ApplyRecord(selected.record,selected.key,Scope(state))end)
 bottom=bottom-48
 local share=ui.Button(box,L('pxShareSelected'),16,bottom,334,30,function()
  tab='share';shareSource='saved';states.share=Copy(state);Changed()
 end)
 local remove=ui.Button(box,L(deleteArmed and'pfConfirmDelete'or'pfDelete'),518,bottom,180,30,function()
  if not selected or Pending()or InCombat()then return end
  if not deleteArmed then deleteArmed=true;Report('pfConfirmDelete');return end
  deleteArmed=nil;local ok=P.Delete(selected.group,selected.key);Report(ok and'pfDeleted'or'pfFailed')
 end)
 if not selected or Pending()then share:Disable();remove:Disable()end
 Feedback(box,bottom-46)
 return y-(state.partial and 460 or 420)
end
local function Import(y)
 local ui=context;local state=states.import
 local box=ui.Box(ui.page,0,y,714,258)
 ui.Text(box,L('uxImportHelp'),16,-14,680,13,ui.muted)
 local edit=Input('import',box,20,-52,656,120)
 if edit:GetText()~=incoming.text then edit:SetText(incoming.text)end
 local inspect=ui.Button(box,L('pxInspect'),16,-192,334,32,function()
  if Pending()then return end
  incoming.text=edit:GetText();armed=nil
  if not incoming.text:find('%S')then Report('uxPasteFirst');return end
  local payload,err,manifest=K.ProfileTransfer.Decode(incoming.text)
  incoming.payload=payload;incoming.manifest=manifest
  incoming.validated=payload and incoming.text or nil
  state.partial=manifest~=nil;state.selection=Copy(manifest or{})
  if payload then pulseTarget='review'end
  Report(payload and'pxInspected'or err)
 end)
 Q.inspectButton=inspect
 if Pending()or not edit:GetText():find('%S')then inspect:Disable()end
 ui.Button(box,L('uxGetCode'),362,-192,336,32,function()tab='share';shareSource='current';pulseTarget='generator';Changed()end)
 Q.importStatus=ui.Text(box,status and L(status)or L('uxNoCode'),16,-232,680,12,incoming.payload and ui.gold or ui.muted)
 y=y-274
 if not incoming.payload or incoming.validated~=edit:GetText()then return y end
 local review=ui.Box(ui.page,0,y,714,state.partial and 304 or 264);Q.importReview=review
 Pulse(review,'review',y)
 local bottom=DrawScope(review,-16,state,incoming.payload,incoming.manifest)
 bottom=Summary(review,bottom,incoming.payload,state)
 ApplyButton(review,bottom,state,incoming.payload,function()
  return K.ProfileTransfer.Apply(incoming.validated,L('pfBeforeApply'),Scope(state))
 end)
 return y-(state.partial and 320 or 280)
end
local function LocalSave(y)
 local ui=context;local P=K.Profiles
 local save=ui.Box(ui.page,0,y,714,148)
 ui.Text(save,L('pxLocalSave'),16,-14,680,14)
 ui.Text(save,L('pxLocalSaveHelp'),16,-42,680,12,ui.muted)
 local name=Input('name',save,22,-80,468,30)
 local button=ui.Button(save,L('pfSave'),510,-78,188,32,function()
  if Pending()or InCombat()then return end
  local value=(name:GetText()or''):match('^%s*(.-)%s*$')
  local ok,err=P.Save(value)
  if ok then K.db.profileSelection={group='named',key=value};name:SetText('');name:ClearFocus()end
  Report(ok and'pfSaved'or err)
 end)
 if Pending()then button:Disable()end
 if status=='pfSaved'or status=='pfBadName'or status=='pfExists'or status=='pfFull'then Feedback(save,-122)end
 return y-164
end
local function Share(y,entries,selected)
 local ui=context;local P,T=K.Profiles,K.ProfileTransfer;local state=states.share
 local baseHeight=shareSource=='saved'and 364 or 284
 if state.partial then baseHeight=baseHeight+40 end
 local box=ui.Box(ui.page,0,y,714,baseHeight)
 Pulse(box,'generator',y)
 ui.Text(box,L('pxExportHelp'),16,-14,680,13,ui.muted)
 local current=ui.Button(box,L('pxCurrent'),16,-46,334,30,function()shareSource='current';Changed()end)
 local stored=ui.Button(box,L('pxStored'),362,-46,336,30,function()shareSource='saved';Changed()end)
 Highlight(current,shareSource=='current');Highlight(stored,shareSource=='saved')
 local payload;local bottom=-92
 if shareSource=='saved'then
  Picker(box,bottom,entries,selected);bottom=bottom-80
  payload=selected and P.Decode(selected.record.code)
 else payload=P.Capture()end
 bottom=DrawScope(box,bottom,state,payload)
 ui.Text(box,L('pxExportOnly'),16,bottom,680,12,ui.muted);bottom=bottom-44
 local generate=ui.Button(box,L('pxGenerate'),16,bottom,682,32,function()
  if not payload then return end
  local source=shareSource=='current'and P.Capture()or payload
  local code,err=T.Export(Scope(state),source)
  output=code;if code then pulseTarget='output'end;Report(code and'pxCopyCode'or err)
 end)
 if not payload or(state.partial and not T.ValidSelection(state.selection))then generate:Disable()end
 if status~='pfSaved'and status~='pfBadName'and status~='pfExists'and status~='pfFull'then Feedback(box,bottom-44)end
 y=y-baseHeight-16
 if output then
  local result=ui.Box(ui.page,0,y,714,260)
  Pulse(result,'output',y)
  ui.Text(result,L('pxCopyCode'),16,-14,680,13,ui.muted)
  local edit=Input('output',result,20,-48,656,128)
  if edit:GetText()~=output then edit:SetText(output)end
  ui.Button(result,L('pxSelectCode'),500,-14,198,26,function()SelectCode(edit)end)
  ui.Text(result,L('uxCodeNext'),16,-192,680,12,ui.muted)
  y=y-276
 end
 ui.Button(ui.page,L('uxLocalToggle'),0,y,714,32,function()showLocalSave=not showLocalSave;Refresh()end)
 y=y-48
 if showLocalSave then y=LocalSave(y)end
 return y
end
local function Recovery(y)
 local ui=context;local P=K.Profiles;local backup=K.db.profileBackup
 local box=ui.Box(ui.page,0,y,714,154)
 ui.Text(box,L('pxRecovery'),16,-12,680,14)
 ui.Text(box,backup and(date('%Y-%m-%d %H:%M',backup.stamp)..' · '..(backup.name or''))or L('pfNoBackup'),16,-40,680,12,ui.muted)
 local restore=ui.Button(box,L(restoreArmed and'pfConfirmRestore'or'pfRestore'),16,-72,334,30,function()
  if Pending()or InCombat()then return end
  if not restoreArmed then restoreArmed=true;Report('pfRestoreWarning');return end
  restoreArmed=false;local ok,err=P.RestoreBackup();Report(err or(ok and'pfQueued'or'pfFailed'))
 end)
 local forget=ui.Button(box,L(forgetArmed and'pfConfirmDelete'or'pfDeleteBackup'),518,-72,180,30,function()
  if Pending()or InCombat()then return end
  if not forgetArmed then forgetArmed=true;Refresh();return end
  forgetArmed=false;K.db.profileBackup=nil;Report('pfDeleted')
 end)
 if not backup or Pending()then restore:Disable();forget:Disable()end
 ui.Text(box,L(restoreArmed and'pfRestoreWarning'or'pxRecoveryHelp'),16,-116,680,12,ui.muted)
 return y-170
end
function Q.Draw(ui)
 context=ui;Q.importReview=nil;Q.importStatus=nil;Q.inspectButton=nil
 local P=K.Profiles
 if not P then return end
 if not P.ready then P.Initialize()end
 if P.failed then ui.Text(ui.page,L('pfFailed'),8,0,690,15,ui.gold);ui.page:SetHeight(130);return end
 local y=0
 if Pending()then
  local box=ui.Box(ui.page,0,0,714,248)
  ui.Rounded(box,.22,.19,.10,{.88,.68,.25,1},8,true)
  ui.Text(box,L('uxPendingTitle'),20,-20,674,19,ui.gold)
  ui.Text(box,L('uxPendingHelp'),20,-66,674,14,ui.gold)
  local label=K.db.profileTransaction.label or ''
  ui.Text(box,L('pxTitle')..': '..tostring(label):gsub('|','||'),20,-132,674,12,ui.muted)
  local finish=ui.Button(box,L('uxFinish'),20,-182,330,40,K.Reload)
  Highlight(finish,true)
  ui.Button(box,L('uxCancel'),362,-182,332,40,function()
   if P.CancelPending()then armed=nil;Report('pfCancelled')end
  end)
  ui.page:SetHeight(280)
  return
 end
 if K.ClassPresets and not Pending()then y=K.ClassPresets.Draw(ui.page,{Box=ui.Box,Text=ui.Text,Button=ui.Button},y)end
 y=y-24
 local heading=ui.Box(ui.page,0,y,714,106)
 ui.Text(heading,L('pxTitle'),16,-12,680,17,ui.gold)
 for index,item in ipairs({{'saved','pxSaved'},{'share','pxShare'},{'import','pxImport'}})do
  local id=item[1]
  local b=ui.Button(heading,L(item[2]),16+(index-1)*230,-54,222,34,function()
   tab=id;Changed();if K.Profiles.profileMenu then K.Profiles.profileMenu:Hide()end
  end)
  Highlight(b,tab==id)
 end
 y=y-122
 if P.deferredError or P.failedApply then ui.Text(ui.page,L('pfFailed'),16,y,680,13,ui.gold);y=y-48 end
 if K.FullLayout and K.FullLayout.status then ui.Text(ui.page,L(K.FullLayout.status),16,y,680,12,ui.muted);y=y-64 end
 local entries=P.Entries();local selected=Selection(entries)
 if tab=='saved'then y=Saved(y,entries,selected)
 elseif tab=='import'then y=Import(y)
 else y=Share(y,entries,selected)end
 y=Recovery(y)
 ui.Text(ui.page,string.format(L('pfStorage'),P.StorageBytes()/1024,P.MAX_TOTAL/1024,#entries),16,y,680,11,ui.muted)
 ui.page:SetHeight(-y+42)
end
