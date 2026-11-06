if select(2,...).blocked then return end
local _,N=...;local K=N.host;local C=K.Chat
local previousStyle,appliedStyle,appliedMode
local hooked=setmetatable({},{__mode='k'})
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

end
function C.SetInputMode(enter)
 if InCombatLockdown()then print('KerimAnka Chat: change this setting out of combat.');return end
 local d=C.GetSettings();if not d then return end
 d.enterMode=enter==true
 if C.Enabled()then
  C.ApplyInputMode()
  C.Queue()
 end
 print('KerimAnka Chat: '..(enter and 'Enter-to-chat' or 'Persistent input'))
end
-- Native input/focus events alone select the active chat box. Calling
-- ActivateChat/SetLastActiveWindow here taints the global owner later read by
-- native whisper menus and combat closing. Layout must never select an owner.
function C.PrepareInput(frame)
 local edit=frame.editBox
 if not edit or hooked[edit]then return end
 hooked[edit]=true
 C.HookScript(edit,'OnEditFocusGained',C.Queue)
 C.HookScript(edit,'OnEditFocusLost',C.Queue)
end
local function Available(edit)
 local f=edit and edit.chatFrame
 return f and f:IsShown()and not edit.disableActivate and (not f.isTemporary or f.inUse)
end
function C.ResolveInputOwner()end -- Native tab selection/close owns fallback.
function C.BindInputTarget(shell,edit)
 shell.inputTarget=edit
 -- The real native edit box receives mouse and keyboard input. No custom
 -- activation surface or focus reacquisition after SendText.
end

function C.ClearDraft(shell)
 local edit=shell.inputTarget
 if not C.Enabled()or not Available(edit)then return end
 -- Clear only the draft, never scrolling message history or sticky channel.
 edit:SetText('')
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
