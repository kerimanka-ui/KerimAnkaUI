-- Compatibility guard: mute only a confirmed closed, orphaned viewport.
-- This does not repair native HideUIPanel/SmartNavigation blocked actions.
if select(2,...).blocked then return end
local _,N=...;local C=N.host.Chat
local trial={enabled=true,masked=0,restored=0};C.ClosedViewTrial=trial
local muted={};local hooked=setmetatable({},{__mode='k'})
function trial.IsMuted(frame)local r=muted[frame];return r and r.active==true or false end
local function Secret(v)return issecretvalue and issecretvalue(v)end
local function Movable(f)return f and not(f.IsProtected and f:IsProtected())end
local repaintQueued=false
local function RepaintAfterRefresh()
 if repaintQueued then return end
 repaintQueued=true
 C_Timer.After(0,function()
  repaintQueued=false
  if C.Enabled()then C.Queue()end
 end)
end
local function Reused(frame)
 local value=frame.inUse
 return not Secret(value)and value==true
end
local function Release(frame,record,reuse,requestedAlpha)
 record.active=false
 if Movable(frame)then
  local alpha=record.alpha
  if reuse then
   -- A closed/faded snapshot is not a new conversation's visibility request.
   if not Secret(requestedAlpha)and type(requestedAlpha)=='number'and requestedAlpha>0 then alpha=requestedAlpha
   elseif alpha<=0 then alpha=1 end
  end
  frame:SetAlpha(alpha)
  if record.mouse~=nil then frame:EnableMouse(record.mouse)end
 end
 muted[frame]=nil;trial.restored=trial.restored+1
 -- A reused native frame may have been styled before this release. Repaint
 -- once with its new valid lifecycle; no forced native docking/selection.
 RepaintAfterRefresh()
end
function trial.PrepareForReuse()
 if not trial.enabled then return end
 local ready={}
 for frame in pairs(muted)do if Reused(frame)then ready[#ready+1]=frame end end
 for _,frame in ipairs(ready)do Release(frame,muted[frame],true)end
end
function trial.SetEnabled(value)
 trial.enabled=value==true
 if not trial.enabled then
  local frames={};for f in pairs(muted)do frames[#frames+1]=f end
  for _,f in ipairs(frames)do Release(f,muted[f])end
 end
end
function trial.Sync(list)
 local dock=GENERAL_CHAT_DOCK;local selected=dock and FCFDock_GetSelectedWindow(dock)
 for _,frame in ipairs(list or C.List())do
  local closed=trial.enabled and frame~=selected and frame~=ChatFrame1 and frame:IsShown()and frame.isTemporary==true and frame.inUse==false and not frame.isDocked
  local record=muted[frame]
  if closed and Movable(frame)then
   if not record then
    local alpha=frame:GetAlpha()
    if not Secret(alpha)and type(alpha)=='number'then
     record={alpha=alpha,mouse=frame.IsMouseEnabled and frame:IsMouseEnabled(),active=true};muted[frame]=record
     trial.masked=trial.masked+1
    end
   end
   if record then
    if not hooked[frame]then
     hooked[frame]=true
     hooksecurefunc(frame,'SetAlpha',function(self,value)
      local saved=muted[self]
      if trial.enabled and C.Enabled()and saved and saved.active and not Secret(value)and value~=0 then
       if Reused(self)then Release(self,saved,true,value)
       else self:SetAlpha(0)end
      end
     end)
    end
    frame:SetAlpha(0);if frame.EnableMouse then frame:EnableMouse(false)end
    local tab=_G[frame:GetName()..'Tab'];local tr=tab and C.records[tab]
    if tr and tr.tabChrome then tr.tabChrome:Hide()end
   end
  elseif record then Release(frame,record,Reused(frame))end
 end
end
local sync=C.SyncControlRails
function C.SyncControlRails(list)sync(list);if trial.enabled then trial.Sync(list)end end
local restore=C.Restore
function C.Restore(...)trial.SetEnabled(false);return restore(...)end
SLASH_KACLOSEDVIEW1='/kachatclosedview'
SlashCmdList.KACLOSEDVIEW=function(input)
 input=(input or ''):lower():match('^%s*(.-)%s*$')
 if input=='on'then trial.SetEnabled(true);C.Queue()
 elseif input=='off'then trial.SetEnabled(false);C.Queue()end
 -- No startup/status messages: do not add another addon-written chat line.
end
