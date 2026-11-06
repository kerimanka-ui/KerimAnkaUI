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
   local wanted=saved.railInactive and 0 or(visibility and visibility.wanted or 1)
   if value~=wanted then self:SetAlpha(wanted)end
  end)
 end
 local visibility=C.visibilityState and C.visibilityState[frame]
 frame:SetAlpha(r.railInactive and 0 or(visibility and visibility.wanted or 1))
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
 if frame.EnableMouse and not(InCombatLockdown()and frame.IsProtected and frame:IsProtected())then frame:EnableMouse(false)end
 -- Some native art ignores its parent's alpha. Mask its own regions too.
 if frame.GetRegions then for _,region in ipairs({frame:GetRegions()})do Mask(region)end end
 if frame.GetChildren then for _,child in ipairs({frame:GetChildren()})do Mask(child)end end
end

local function Unmask(frame)
 if not frame then return end
 local r=C.records[frame]
 if r and r.foreverMask then
  r.foreverMask=nil;frame:SetAlpha(r.alpha)
  if r.nativeMouse~=nil and not(InCombatLockdown()and frame.IsProtected and frame:IsProtected())then frame:EnableMouse(r.nativeMouse)end
 end
 if frame.GetRegions then for _,region in ipairs({frame:GetRegions()})do Unmask(region)end end
 if frame.GetChildren then for _,child in ipairs({frame:GetChildren()})do Unmask(child)end end
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
 C.HideMicroArt(frame.buttonFrame)
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
 -- This native button occupies the same top-left rail as our scrolling buttons.
 -- Docked tabs cannot be minimized here; keep detached-window minimize intact.
 local minimize=frame.buttonFrame.minimizeButton
 if frame==primary or frame.isDocked then Mask(minimize)
 elseif minimize then Unmask(minimize)end
 return out
end

-- The main shell/micro menu may be a dependency of protected buttons. Never
-- relayout it in combat. Newly selected native whisper frames are separate
-- message viewports: fit only unprotected viewports to the cached envelope.
local function Movable(frame)
 return frame and not(frame.IsProtected and frame:IsProtected())
end
local function RailPart(part,active)
 if not part then return end
 local r=C.Remember(part);r.railInactive=not active
 if not r.railMouseSaved and part.IsMouseEnabled then
  r.railMouseSaved=true;r.railMouse=part:IsMouseEnabled()
 end
 KeepControlAlpha(part)
 if r.railMouseSaved and Movable(part)then part:EnableMouse(active and r.railMouse or false)end
end
function C.SyncControlRails(list)
 local dock=GENERAL_CHAT_DOCK;local primary=dock and dock.primary or ChatFrame1
 local selected=dock and FCFDock_GetSelectedWindow(dock)or primary
 for _,frame in ipairs(list or C.List())do
  local tab=_G[frame:GetName()..'Tab']
  local active=frame:IsShown()and(not frame.isTemporary or frame.inUse)
  if tab and not tab:IsShown()then active=false end
  if frame==primary or frame.isDocked then active=active and frame==(selected or primary)end
  -- A native Close can undock and hide the tab, yet leave its message frame
  -- shown after HideUIPanel is blocked. Never use IsShown alone as rail ownership.
  if frame.buttonFrame and C.records[frame.buttonFrame]then RailPart(frame.buttonFrame,active)end
  for _,button in pairs(owned[frame]or{})do
   RailPart(button,active)
   if active then button:Show()else button:Hide()end
  end
  if frame==primary then
   for _,button in pairs({QuickJoinToastButton,ChatFrameChannelButton,ChatFrameMenuButton})do
    if C.records[button]then RailPart(button,active)end
   end
  end
 end
end
function C.RefreshCombat()
 local dock=GENERAL_CHAT_DOCK
 local primary=dock and dock.primary or ChatFrame1
 local g=C.mainGeometry
 if not primary or not g then return end
 local selected=dock and FCFDock_GetSelectedWindow(dock)or primary
 local shell=C.shells[primary]
 for _,frame in ipairs(C.List())do
  local docked=frame==primary or frame.isDocked
  if docked then
   -- Native OnHide may not hide sibling chrome, which is parented to the dock.
   local tab=_G[frame:GetName()..'Tab'];local record=tab and C.records[tab]
   if record and record.tabChrome and not tab:IsShown()then record.tabChrome:Hide()end
   if frame==selected and frame:IsShown()and(not frame.isTemporary or frame.inUse)then
    -- Temporary whispers can be created for the first time during combat.
    -- Paint their tab now; normal Refresh is intentionally deferred.
    if tab and Movable(tab)then C.StyleTab(frame)end
    if frame~=primary and Movable(frame)then
     local r=C.Remember(frame);r.placed=true
     frame:ClearAllPoints();frame:SetPoint('TOPLEFT',primary,'TOPLEFT',0,0)
     frame:SetPoint('BOTTOMRIGHT',primary,'BOTTOMRIGHT',0,0)
     local quick=frame.CombatLogQuickButtonFrame
     if quick and quick:IsShown()then frame:SetPoint('TOPLEFT',primary,'TOPLEFT',0,-quick:GetHeight()-2)end
    end
    -- Discover and mask each temporary frame's native scrollbar as well.
    if Movable(frame.buttonFrame)then
     local controls=C.NativeControls(frame)
     for _,button in ipairs(controls or{})do
      if Movable(button)then C.StyleToolButton(button)end
     end
     local cg={};for key,value in pairs(g)do cg[key]=value end
     cg.controlsLeft=frame~=primary
     if frame~=primary then cg.horizontal=false end
     C.PlaceControls(frame,cg)
    end
    if shell then
     shell.visibilityFrame=frame;shell.inputTarget=frame.editBox
     if shell.inputHint then shell.inputHint:SetShown(C.EnterMode()and not(frame.editBox and frame.editBox:IsShown()))end
    end
    if Movable(frame.editBox)then C.PlaceInput(frame,g,true)end
   end
  end
 end
 C.SyncControlRails()
end

local Restore=C.Restore
function C.Restore()
 for frame,r in pairs(C.records)do
  r.railInactive=nil
  if r.railMouseSaved and frame.EnableMouse then frame:EnableMouse(r.railMouse);r.railMouseSaved=nil end
  if r.foreverMask or r.foreverControlAlpha then
   r.foreverMask=nil;r.foreverControlAlpha=nil;frame:SetAlpha(r.alpha)
  end
 end
 Restore()
 for _,buttons in pairs(owned)do for _,button in pairs(buttons)do button:Hide()end end
end
