if select(2,...).blocked then return end
if WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,N=...;local K=N.host;local C=K.Chat
local previousStyle,appliedStyle,appliedMode
local hooked=setmetatable({},{__mode='k'})
local sent=setmetatable({},{__mode='k'})
function C.EnterMode()
 local d=C.GetSettings();return d and d.enterMode==true
end
function C.ApplyInputMode()
 local mode=C.EnterMode()and 'classic' or 'im'
 if appliedMode==mode then return end
 if not previousStyle then previousStyle=GetCVar('chatStyle')end
 appliedMode,appliedStyle=mode,mode
 if GetCVar('chatStyle')~=mode then SetCVar('chatStyle',mode)end
end
function C.RestoreInputMode()
 if previousStyle and GetCVar('chatStyle')==appliedStyle then SetCVar('chatStyle',previousStyle)end
 previousStyle,appliedStyle,appliedMode=nil,nil,nil
 if ChatFrameUtil and ChatFrameUtil.GetLastActiveWindow and ChatFrameUtil.DeactivateChat then
  local edit=ChatFrameUtil.GetLastActiveWindow()
  if edit then ChatFrameUtil.DeactivateChat(edit)end
 end
 wipe(sent)
end
function C.SetInputMode(enter)
 if InCombatLockdown()then print('KerimAnka Chat: change this setting out of combat.');return end
 local d=C.GetSettings();if not d then return end
 d.enterMode=enter==true
 if C.Enabled()then
  C.ApplyInputMode()
  -- Refresh the native visible/inactive box after a style change without taking focus.
  if ChatFrameUtil and ChatFrameUtil.GetLastActiveWindow and ChatFrameUtil.DeactivateChat then
   local edit=ChatFrameUtil.GetLastActiveWindow()
   if edit then ChatFrameUtil.DeactivateChat(edit)end
  end
  C.Queue()
 end
 print('KerimAnka Chat: '..(enter and 'Enter-to-chat' or 'Persistent input'))
end
function C.PrepareInput(frame)
 local edit=frame.editBox
 if not edit or not ChatFrameUtil or edit.disableActivate then return end
 if not hooked[edit]then
  hooked[edit]=true
  -- Native SendText parses slash commands first. Record only actual nonempty chat
  -- remaining after that step, never treat /reload or another command as a message.
  hooksecurefunc(edit,'SendText',function(self)
   local text=self:GetText()or ''
   sent[self]=C.Enabled()and not C.EnterMode()and self:HasFocus()
    and text:find('%S')and not text:match('^%s*/')and true or false
  end)
  C.HookScript(edit,'OnEnterPressed',function(self)
   local keep=sent[self];sent[self]=nil
   if keep and C.Enabled()and not C.EnterMode()and self.chatFrame
    and self.chatFrame:IsShown()and not self.disableActivate then
    -- Native handler has already sent, updated sticky channel and cleared text.
    -- Reuse native focus activation; no custom keyboard/message handler.
    ChatFrameUtil.ActivateChat(self)
   end
  end)
  C.HookScript(edit,'OnEscapePressed',function(self)sent[self]=nil end)
  C.HookScript(edit,'OnEditFocusGained',C.Queue)
  C.HookScript(edit,'OnEditFocusLost',C.Queue)
 end
 if C.EnterMode()then return end
 if ACTIVE_CHAT_EDIT_BOX and ACTIVE_CHAT_EDIT_BOX:HasFocus()then return end
 -- Layout is not an input-selection action. Detached windows must never take
 -- turns calling SetLastActiveWindow: native IM hides the previous box.
 local last=ChatFrameUtil.GetLastActiveWindow()
 if last==edit and not edit:IsShown()then edit:Show();edit:Deactivate()end
end
local function Available(edit)
 local f=edit and edit.chatFrame
 return f and f:IsShown()and not edit.disableActivate and (not f.isTemporary or f.inUse)
end
function C.ResolveInputOwner(list,preferred)
 if C.EnterMode()or not ChatFrameUtil then return end
 local active=ACTIVE_CHAT_EDIT_BOX
 if Available(active)and active:HasFocus()then return end
 local last=ChatFrameUtil.GetLastActiveWindow()
 if Available(last)then return end
 -- Only a closed/hidden/unused owner needs a fallback, once for the entire pass.
 local fallback=preferred and preferred.editBox
 if not Available(fallback)then
  fallback=nil
  for _,frame in ipairs(list)do if Available(frame.editBox)then fallback=frame.editBox;break end end
 end
 if fallback then
  if active and not Available(active)then ChatFrameUtil.DeactivateChat(active)end
  ChatFrameUtil.SetLastActiveWindow(fallback)
 end
end
function C.ActivateInput(edit)
 if not C.Enabled()or not Available(edit)or not ChatFrameUtil then return end
 -- Called only by an explicit click, never by painting or refresh.
 ChatFrameUtil.ActivateChat(edit);C.Queue()
end
function C.BindInputTarget(shell,edit)
 shell.inputTarget=edit
 if not shell.inputClick then
  local button=CreateFrame('Button',nil,shell.input)
  button:SetAllPoints(shell.input);button:SetFrameStrata('LOW');button:SetFrameLevel(8)
  button:EnableMouse(true)
  button:SetScript('OnClick',function()C.ActivateInput(shell.inputTarget)end)
  shell.inputClick=button
 end
 -- IM intentionally keeps only the last native box visible. Other independent
 -- wells remain clickable without creating extra editboxes or stealing focus.
 shell.inputClick:SetShown(edit and not edit.disableActivate and not edit:IsShown())
end

function C.ClearDraft(shell)
 local edit=shell.inputTarget
 if not C.Enabled()or not Available(edit)then return end
 -- Clear only the draft, never scrolling message history or sticky channel.
 C.ActivateInput(edit);edit:SetText('');edit:SetFocus()
end
local BindInputTarget=C.BindInputTarget
function C.BindInputTarget(shell,edit)
 BindInputTarget(shell,edit)
 if not shell.clearDraft then
  local b=CreateFrame('Button',nil,shell.input)
  b:SetSize(24,24);b:SetPoint('RIGHT',shell.input,'RIGHT',-4,0)
  b:SetFrameStrata('DIALOG');b:SetFrameLevel(20)
  local label=b:CreateFontString(nil,'OVERLAY','GameFontNormal');label:SetAllPoints();label:SetText('×');label:SetTextColor(.66,.71,.65,1)
  b:SetScript('OnClick',function()C.ClearDraft(shell)end)
  b:SetScript('OnEnter',function()label:SetTextColor(1,.88,.64,1)end)
  b:SetScript('OnLeave',function()label:SetTextColor(.66,.71,.65,1)end)
  shell.clearDraft=b
 end
 shell.clearDraft:SetShown(edit and not edit.disableActivate)
end
