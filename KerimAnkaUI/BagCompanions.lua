-- Native companion windows. Reagent visibility follows its shelf icon;
-- keyring stays manual. Inventory items and click attributes remain Blizzard's.
local _,K=...
local M=K.InventoryMenus
if not M then return end
local watched,owned={},{}
local busy,queued,session=false,false,false
local hidden=false
local reagentClosing,intentVersion=0,0
local attempts,epoch=0,0
local Queue
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function Forbidden(f) return f and f.IsForbidden and f:IsForbidden() end
local function KeyID() return Enum and Enum.BagIndex and Enum.BagIndex.Keyring or KEYRING_CONTAINER end
local function ReagentID() return Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag or 5 end
local function Frames()
 local result={}
 if ContainerFrameUtil_EnumerateContainerFrames then
  for _,f in ContainerFrameUtil_EnumerateContainerFrames() do result[#result+1]=f end
 else
  for i=1,(NUM_CONTAINER_FRAMES or 13) do local f=_G['ContainerFrame'..i];if f then result[#result+1]=f end end
 end
 return result
end
local function Find(id)
 for _,f in ipairs(Frames()) do
  if f~=ContainerFrameCombinedBags and not Forbidden(f) and f.GetID and f:GetID()==id and f:IsShown() then return f end
 end
end
local function Allowed()
 local c=ContainerFrameCombinedBags
 if not c or Forbidden(c) or not M.Get('bagDock') then return false end
 if M.BartenderOwns and M.BartenderOwns("BagBar") then return false end
 local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 if loaded then for _,name in ipairs({'Bagnon','AdiBags','BetterBags'}) do if loaded(name) then return false end end end
 if EditModeManagerFrame and EditModeManagerFrame.IsEditModeActive and EditModeManagerFrame:IsEditModeActive() then return false end
 return ContainerFrameSettingsManager and ContainerFrameSettingsManager:IsUsingCombinedBags() and c:IsShown()
end
local function Eligible(id)
 if id==nil or ContainerFrameSettingsManager:IsUsingCombinedBags(id) then return false end
 if id==KeyID() then
  local get=C_CVar and C_CVar.GetCVarBool or GetCVarBool
  return C_ActionBar and C_ActionBar.ShouldShowKeyring and C_ActionBar.ShouldShowKeyring()
   and get and get('showKeyring') and GetKeyRingSize and GetKeyRingSize()>0
 end
 return C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(id)>0
end
local function Snapshot(f,id,opened)
 return {frame=f,id=id,opened=opened,strata=f.GetFrameStrata and f:GetFrameStrata(),level=f:GetFrameLevel()}
end
local function Restore(s,closing)
 local f=s.frame
 if Forbidden(f) or f:GetID()~=s.id then return end
 -- Native bag anchors reference pooled peers. A saved peer may now depend
 -- on this frame, so replaying saved SetPoints can create an anchor cycle.
 f:ClearAllPoints()
 if s.strata then f:SetFrameStrata(s.strata) end
 f:SetFrameLevel(s.level)
 if (closing or s.opened) and f:IsShown() then f:Hide() end
end
local function Release(closing)
 local released=owned;owned={}
 -- Detach the entire chain before any Hide invokes Blizzard's own layout.
 for _,s in pairs(released) do
  if not Forbidden(s.frame) and s.frame:GetID()==s.id then s.frame:ClearAllPoints() end
 end
 for _,s in pairs(released) do Restore(s,closing) end
 if next(released) and type(UpdateContainerFrameAnchors)=='function' then UpdateContainerFrameAnchors() end
 attempts=0;epoch=epoch+1;session=false
end
local function NotifyShelf()
 -- The original refresh redraws both alpha and checked state using our getter.
 -- busy prevents this notification from scheduling another companion refresh.
 M.Refresh()
end
local function Place(frame,anchor,c)
 local ratio=anchor:GetEffectiveScale()/frame:GetEffectiveScale()
 frame:ClearAllPoints()
 if anchor==c then frame:SetPoint('TOPRIGHT',c,'TOPLEFT',-8*ratio,0)
 else frame:SetPoint('TOPRIGHT',anchor,'BOTTOMRIGHT',0,-8*ratio) end
end
local function RepairAnchors()
 -- Native show/hide reanchors all bags. Include newly opened companions in
 -- this pass so their first position is repaired before a frame is rendered.
 -- Opening, closing, hooks and shelf refresh stay on the deferred path.
 if busy or Combat() or not Allowed() then return end
 busy=true
 local c=ContainerFrameCombinedBags;local anchor=c
 for _,id in ipairs({ReagentID(),KeyID()}) do
  local frame=Eligible(id) and Find(id)
  if frame then
   if not owned[id] or owned[id].frame~=frame then owned[id]=Snapshot(frame,id,false) end
   if c.GetFrameStrata then frame:SetFrameStrata(c:GetFrameStrata()) end
   frame:SetFrameLevel(c:GetFrameLevel()+1)
   Place(frame,anchor,c);anchor=frame
  end
 end
 busy=false
end
local function Watch(f)
 if not f or watched[f] then return end
 watched[f]=true
 f:HookScript('OnShow',function() Queue() end)
 f:HookScript('OnSizeChanged',function() Queue() end)
 f:HookScript('OnHide',function()
  if f==ContainerFrameCombinedBags then intentVersion=intentVersion+1 end
  if busy then return end
  local reagent=f~=ContainerFrameCombinedBags and f.GetID and f:GetID()==ReagentID()
  local version=intentVersion
  if reagent then reagentClosing=reagentClosing+1 end
  -- Wait until native CloseAllBags has also hidden the combined frame.
  C_Timer.After(0,function()
   if reagent then reagentClosing=reagentClosing-1 end
   if Combat() then Queue();return end
   if version==intentVersion and Allowed() and reagent and f:GetID()==ReagentID() and not Find(ReagentID()) then
    hidden=true;busy=true;NotifyShelf();busy=false
   end
   Queue()
  end)
 end)
end
local function Refresh()
 if busy or Combat() or reagentClosing>0 then return end
 busy=true
 local c=ContainerFrameCombinedBags;Watch(c)
 if not Allowed() then Release(c and not c:IsShown());busy=false;return end
 if not session then session=true;attempts=0;epoch=epoch+1 end
 local id=ReagentID()
 local eligible=Eligible(id)
 local f=eligible and Find(id)
 if eligible and not hidden and not f and attempts<4 and OpenBag then
  attempts=attempts+1
  OpenBag(id)
  f=Find(id)
  if f then owned[id]=Snapshot(f,id,true) end
  -- An early opening can be refused while Blizzard is still setting up bags.
  -- Retry only within this opening, with a strict bound, and cancel on close.
  if not f and attempts<4 then
   local token=epoch
   C_Timer.After(({.05,.15,.35})[attempts],function() if token==epoch then Queue() end end)
  end
 end
 if eligible and hidden and f then f:Hide();f=nil end
 local anchor=c
 for _,bag in ipairs({id,KeyID()}) do
  local frame=Eligible(bag) and Find(bag)
  if frame then
   if not owned[bag] or owned[bag].frame~=frame then owned[bag]=Snapshot(frame,bag,false) end
   Watch(frame)
   -- Blizzard can assign an individual bag a lower layer than the combined
   -- bag. Match its layer before placing the companion beside it.
   if c.GetFrameStrata then frame:SetFrameStrata(c:GetFrameStrata()) end
   frame:SetFrameLevel(c:GetFrameLevel()+1)
   Place(frame,anchor,c)
   anchor=frame
  elseif not Eligible(bag) and owned[bag] then
   local state=owned[bag];owned[bag]=nil;Restore(state)
   if type(UpdateContainerFrameAnchors)=='function' then UpdateContainerFrameAnchors() end
  end
 end
 NotifyShelf()
 busy=false
 RepairAnchors()
end
Queue=function()
 if busy or queued or Combat() then return end
 queued=true;C_Timer.After(0,function() queued=false;Refresh() end)
end
function M.IsCompanionHidden(id)
 return id==ReagentID() and hidden
end
function M.ToggleCompanion(id)
 if id~=ReagentID() or not Allowed() or not Eligible(id) or Combat() then return false end
 intentVersion=intentVersion+1
 hidden=not hidden;attempts=0;epoch=epoch+1
 Refresh();return true
end
local previous=M.Refresh
function M.Refresh(...) previous(...);Queue() end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','ADDON_LOADED','BAG_UPDATE_DELAYED','CVAR_UPDATE','PLAYER_REGEN_ENABLED','EDIT_MODE_LAYOUTS_UPDATED','USE_COMBINED_BAGS_CHANGED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',Queue)
if type(UpdateContainerFrameAnchors)=='function' then
 hooksecurefunc('UpdateContainerFrameAnchors',function() RepairAnchors();Queue() end)
end
K.RefreshBagCompanions=Queue
Queue()
