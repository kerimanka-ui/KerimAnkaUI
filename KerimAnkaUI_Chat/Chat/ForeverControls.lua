if select(2,...).blocked then return end
local _,N=...;local C=N.host.Chat
local owned=setmetatable({},{__mode='k'})
local maskHooks=setmetatable({},{__mode='k'})
local alphaHooks=setmetatable({},{__mode='k'})

local function KeepControlAlpha(frame)
 local r=C.Remember(frame);r.foreverControlAlpha=true
 if not alphaHooks[frame]then
  alphaHooks[frame]=true
  hooksecurefunc(frame,'SetAlpha',function(self,value)
   local saved=C.records[self]
   if not C.Enabled()or not(saved and saved.foreverControlAlpha)then return end
   local visibility=C.visibilityState and C.visibilityState[self]
   local wanted=visibility and visibility.wanted or 1
   if value~=wanted then self:SetAlpha(wanted)end
  end)
 end
 local visibility=C.visibilityState and C.visibilityState[frame]
 frame:SetAlpha(visibility and visibility.wanted or 1)
end

function C.IsFriendControl(button)
 return button and(button==QuickJoinToastButton or button:GetName()=='FriendsMicroButton')
end

local function Mask(frame)
 if not frame then return end
 local r=C.Remember(frame)
 if not r.foreverMask then
  r.foreverMask=true
  if frame.IsMouseEnabled then r.nativeMouse=frame:IsMouseEnabled();r.nativeShown=frame:IsShown()end
 end
 if not maskHooks[frame]then
  maskHooks[frame]=true
  hooksecurefunc(frame,'SetAlpha',function(self,value)
   local saved=C.records[self]
   if value~=0 and C.Enabled()and saved and saved.foreverMask then self:SetAlpha(0)end
  end)
 end
 frame:SetAlpha(0)
 if frame.EnableMouse then frame:EnableMouse(false)end
 for _,child in ipairs({frame:GetChildren()})do Mask(child)end
end

local function ScrollButton(frame,key,method,label)
 local buttons=owned[frame];if not buttons then buttons={};owned[frame]=buttons end
 local button=buttons[key]
 if not button then
  button=CreateFrame('Button',frame:GetName()..'KA'..key..'Button',frame.buttonFrame)
  button:SetSize(24,24)
  -- Scrolling is a native message-frame action, not a replacement chat handler.
  button:SetScript('OnClick',function()if frame[method]then frame[method](frame)end end)
  button:SetScript('OnEnter',function(self)if C.ButtonTooltip then C.ButtonTooltip(self,label,'')end end)
  button:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
  buttons[key]=button
 end
 button:Show();return button
end

function C.NativeControls(frame)
 -- Era uses layoutIndex children; Forever has a MinimalScrollBar instead.
 if not frame or not frame.ScrollBar or not frame.buttonFrame then return end
 KeepControlAlpha(frame.buttonFrame)
 local out={}
 local primary=GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.primary or ChatFrame1
 local function Add(button)
  if button then
   C.HookScript(button,'OnShow',C.Queue);C.HookScript(button,'OnHide',C.Queue)
   if button:IsShown()then KeepControlAlpha(button);out[#out+1]=button end
  end
 end
 if frame==primary then
  Add(QuickJoinToastButton)
  Add(ChatFrameChannelButton)
  Add(ChatFrameMenuButton)
 end
 Add(ScrollButton(frame,'Up','ScrollUp',SCROLL_UP or 'Scroll up'))
 Add(ScrollButton(frame,'Down','ScrollDown',SCROLL_DOWN or 'Scroll down'))
 Add(ScrollButton(frame,'Bottom','ScrollToBottom',CHAT_BOTTOM or 'Scroll to bottom'))
 Mask(frame.ScrollBar);Mask(frame.ScrollToBottomButton)
 return out
end

local Restore=C.Restore
function C.Restore()
 for frame,r in pairs(C.records)do
  if r.foreverMask or r.foreverControlAlpha then
   r.foreverMask=nil;r.foreverControlAlpha=nil;frame:SetAlpha(r.alpha)
  end
 end
 Restore()
 for _,buttons in pairs(owned)do for _,button in pairs(buttons)do button:Hide()end end
end
