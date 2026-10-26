-- Classic-only unified position editor for explicitly registered KerimAnka features.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={active=false};K.LayoutEditor=M
local root,bar,grid,shade,info,chosen;local movers={};local entries,byID,initial={},{},{}
local checkpointQueued=false
local examplesText
local selected,drag,closing;local localized={};local titleText,hintText;local showGrid,showShade=true,true
local function Combat()return InCombatLockdown()end
local function Message(key)if K.Message then K.Message(key)end end
local function Journal()return K.db and K.db.layoutEditRecovery end
local function Center(f)return K.LayoutAdapters.Center(f)end
local function QueueCheckpoint()
 if checkpointQueued then return end;checkpointQueued=true
 C_Timer.After(0,function()
  checkpointQueued=false
  if not M.active and not Journal()and K.Profiles then K.Profiles.Checkpoint()end
 end)
end
local function Font(parent,size,text)
 local t=parent:CreateFontString(nil,'OVERLAY');K.ApplyTextFont(t,size,false,'OUTLINE');t:SetText(text or'');t:SetTextColor(1,1,1);return t
end
local function Backdrop(f,alpha)
 f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
 f:SetBackdropColor(.055,.065,.06,alpha);f:SetBackdropBorderColor(.72,.57,.29,.9)
end
local function Button(parent,text,x,y,width,callback)
 local b=CreateFrame('Button',nil,parent,'BackdropTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(width,27);Backdrop(b,.96)
 b.label=Font(b,11,K.L(text));b.localeKey=text;localized[#localized+1]=b;b.label:SetPoint('CENTER');b.label:SetWidth(width-8);b:SetScript('OnClick',callback);return b
end
local function Lookup()
 entries=K.LayoutAdapters.Build();byID={};for _,a in ipairs(entries)do byID[a.id]=a end
end
function M.Recover()
 local recovery=Journal();if not recovery then return true end
 if Combat()then return false end
 if type(recovery)~='table'or recovery.version~=1 or type(recovery.items)~='table'then Message('leRecovery');return false end
 Lookup()
  if recovery.quick then
  for name,values in pairs(recovery.quick)do local ok,result=pcall(K.LayoutQuickOptions.Restore,name,values);if ok and result then recovery.quick[name]=nil end end
 end
 Lookup()
 for id,values in pairs(recovery.items)do
  local a=byID[id]
  if a then local ok,result=pcall(a.Restore,values);if ok and result then recovery.items[id]=nil end
  else local ok,result=pcall(K.LayoutAdapters.RestoreRecord,id,values);if ok and result then recovery.items[id]=nil end end
 end
 if not next(recovery.items)and(not recovery.quick or not next(recovery.quick))then K.db.layoutEditRecovery=nil;return true end
 Message('leRecovery');return false
end
local function Mark(a)
 if not Journal()then K.db.layoutEditRecovery={version=1,items={}}end
 if not Journal().items[a.id]then Journal().items[a.id]=K.LayoutAdapters.Copy(initial[a.id])end
end
function M.MarkQuick(name)
 if not M.active or Combat()then return false end
 local snapshot=K.LayoutQuickOptions.Capture(name);if not snapshot then return false end
 if not Journal()then K.db.layoutEditRecovery={version=1,items={}}end
 local recovery=Journal();recovery.quick=recovery.quick or{}
 if not recovery.quick[name]then recovery.quick[name]=snapshot end
 return true
end
function M.OpenQuickSettings(id)
 if not M.active or Combat()then return false end
 id=id or selected;local a=byID[id];if not a then return false end
 if GameTooltip then GameTooltip:Hide()end
 selected=id;M.Refresh();return K.LayoutQuickOptions.Show(id,K.L(a.label))
end
function M.Nudge(dx,dy)
 if not M.active or Combat()or not selected then return false end
 M.EndDrag();local a=byID[selected];if not a or a.disabled then return false end
 local amount=IsShiftKeyDown and IsShiftKeyDown()and 10 or 1
 Mark(a);a.Move(dx*amount,dy*amount,a.Base());M.Refresh();return true
end
function M.Select(id)
 if not M.active or not byID[id]then return end
 selected=id;M.Refresh()
end
local function StopDrag()
 if drag and drag.mover then drag.mover:SetScript('OnUpdate',nil)end;drag=nil
end
function M.Rebuild(preferred)
 if not M.active or Combat()then return false end
 StopDrag();Lookup()
 for _,a in ipairs(entries)do if initial[a.id]==nil then initial[a.id]=a.Capture()end end
 if preferred and byID[preferred]then selected=preferred elseif not selected or not byID[selected]then selected=entries[1]and entries[1].id end
 if K.LayoutPreviews then K.LayoutPreviews.Rebuild()end
 if not selected then K.LayoutQuickOptions.Hide()end
 M.Refresh();K.LayoutQuickOptions.Redraw();if K.LayoutElements then K.LayoutElements.Refresh()end;return true
end
function M.ApplyDrag()
 if not drag or Combat()then return end
 local x,y=GetCursorPosition();if not x or not y then return end
 local scale=UIParent:GetEffectiveScale();local dx,dy=(x-drag.x)/scale,(y-drag.y)/scale
 if drag.cx then
  local w,h=UIParent:GetWidth(),UIParent:GetHeight();local hw=math.min(drag.width/2,w/2);local hh=math.min(drag.height/2,h/2)
  dx=math.max(hw,math.min(w-hw,drag.cx+dx))-drag.cx;dy=math.max(hh,math.min(h-hh,drag.cy+dy))-drag.cy
 end
 if math.abs(dx-(drag.dx or 0))<.05 and math.abs(dy-(drag.dy or 0))<.05 then return end
 Mark(drag.a)
 local ok=pcall(drag.a.Move,dx,dy,drag.base)
 if not ok then StopDrag();Message('leMoveError');return end
 drag.dx,drag.dy=dx,dy;M.Refresh()
end
function M.BeginDrag(id,mover)
 if not M.active or Combat()or not byID[id]then return false end
 if byID[id].disabled then M.OpenQuickSettings(id);return false end
 if drag and drag.mover==mover then return true end
 StopDrag();local a=byID[id];local x,y=GetCursorPosition();if not x or not y then return false end
 Mark(a);local ok,base=pcall(a.Base);if not ok or type(base)~='table'then Message('leMoveError');return false end
 local cx,cy=Center(a.frame);local r=a.frame and a.frame:GetEffectiveScale()/UIParent:GetEffectiveScale()or 1
 selected=id;drag={a=a,mover=mover,x=x,y=y,base=base,cx=cx,cy=cy,width=a.frame and a.frame:GetWidth()*r or 0,height=a.frame and a.frame:GetHeight()*r or 0}
 local elapsed=0;mover:SetScript('OnUpdate',function(_,dt)
  if Combat()then M.Finish(true,true);return end
  if IsMouseButtonDown and not IsMouseButtonDown('LeftButton')then M.EndDrag();return end
  elapsed=elapsed+dt;if elapsed>=.03 then elapsed=0;M.ApplyDrag()end
 end);M.Refresh();return true
end
function M.EndDrag()if not Combat()then M.ApplyDrag()end;StopDrag();M.Refresh()end
function M.RestoreSelected()
 if not M.active or Combat()or not selected then return false end
 M.EndDrag();local a=byID[selected];local recovery=Journal()
 if not a or not recovery then return true end
 -- Shared appearance controls may touch aura defaults. Keep the user's other
 -- explicitly moved elements in place while undoing this preference group.
 local keep={}
 for id in pairs(recovery.items)do if id~=selected and byID[id]then keep[id]=byID[id].Capture()end end
 if recovery.quick then
  for _,name in ipairs(K.LayoutQuickOptions.Groups(selected))do
   if recovery.quick[name]then
    local ok,result=pcall(K.LayoutQuickOptions.Restore,name,recovery.quick[name]);if not ok or not result then Message('leMoveError');return false end
    recovery.quick[name]=nil
   end
  end
 end
 for id,values in pairs(keep)do byID[id].Restore(values)end
 if recovery.items[selected]then
  local ok,result=pcall(a.Restore,initial[selected]);if not ok or not result then Message('leMoveError');return false end
  recovery.items[selected]=nil
 end
 if not next(recovery.items)and(not recovery.quick or not next(recovery.quick))then K.db.layoutEditRecovery=nil end
 if K.LayoutPreviews then K.LayoutPreviews.Invalidate()end
 M.Rebuild(selected);return true
end
function M.Finish(save,inCombat)
 if not M.active or closing then return end
 closing=true
 if not inCombat then M.ApplyDrag()end;StopDrag()
 local recovery=Journal()
 if not save and recovery then
  if recovery.quick then
   for name,values in pairs(recovery.quick)do local ok,result=pcall(K.LayoutQuickOptions.Restore,name,values);if ok and result then recovery.quick[name]=nil end end
  end
  Lookup()
  for id,values in pairs(recovery.items)do local a=byID[id];if a then local ok,result=pcall(a.Restore,values);if ok and result then recovery.items[id]=nil end else local ok,result=pcall(K.LayoutAdapters.RestoreRecord,id,values);if ok and result then recovery.items[id]=nil end end end
 end
 if save or recovery and not next(recovery.items)and(not recovery.quick or not next(recovery.quick))then K.db.layoutEditRecovery=nil end
 if K.LayoutPreviews then K.LayoutPreviews.Stop()end
 K.LayoutQuickOptions.Hide()
 if K.LayoutElements then K.LayoutElements.Hide()end
 M.active=false;root:SetScript('OnUpdate',nil);root:Hide();entries={};byID={};initial={};selected=nil;closing=false
 if not Journal()then QueueCheckpoint()end
 if inCombat then Message('leCombatClosed')elseif Journal()then Message('leRecovery')end
end
function M.OpenSettings(id)
 local a=byID[id or selected];if not a then return end
 local page,section,option=a.page,a.section,a.option
 M.Finish(true)
 -- Finish click/drag dispatch and checkpoint before rebuilding the large settings page.
 C_Timer.After(0,function()
  if M.active then return end
  if Combat()then Message('combatLock');return end
  K.ShowPage(page,section)
  if option and K.JumpToUnitOption then K.JumpToUnitOption(option)end
 end)
end
function M.Refresh()
 if not M.active then return end
 if K.LayoutPreviews then K.LayoutPreviews.Update(entries,root)end
 local visible={}
 for i,a in ipairs(entries)do
  local f=a.frame;local x,y=Center(f);local ratio=f and f:GetEffectiveScale()/UIParent:GetEffectiveScale()or 1
  if x and y then
   visible[a.id]=true
   local mover=movers[a.id]
   if not mover then
    mover=CreateFrame('Button',nil,root,'BackdropTemplate');movers[a.id]=mover;mover:RegisterForDrag('LeftButton');mover:RegisterForClicks('LeftButtonUp','RightButtonUp');mover:EnableMouse(true);mover:SetMovable(true);Backdrop(mover,.22)
    mover.label=Font(mover,11);mover.label:SetPoint('CENTER',0,0);mover.label:SetWordWrap(false)
    mover:SetScript('OnClick',function(_,button)if button=='RightButton'then M.OpenQuickSettings(a.id)else M.Select(a.id)end end)
    mover:SetScript('OnDragStart',function(self)M.BeginDrag(a.id,self)end);mover:SetScript('OnDragStop',M.EndDrag)
    mover:SetScript('OnMouseDown',function(self,button)if button=='LeftButton'then M.BeginDrag(a.id,self)end end)
    mover:SetScript('OnMouseUp',function(self,button)if button=='LeftButton'and drag and drag.mover==self then M.EndDrag()end end)
    -- Keep the edited icons unobstructed; interaction help lives in the toolbar.
    mover:SetScript('OnEnter',function()if GameTooltip then GameTooltip:Hide()end end)
   end
   local width,height=math.max(90,f:GetWidth()*ratio),math.max(26,f:GetHeight()*ratio)
   mover:ClearAllPoints();mover:SetPoint('CENTER',UIParent,'BOTTOMLEFT',x,y);mover:SetSize(width,height);mover.label:SetWidth(math.max(40,width-16))
   mover.label:SetTextColor(a.disabled and .65 or 1,a.disabled and .65 or 1,a.disabled and .65 or 1)
   mover.label:SetText(K.L(a.label)..(a.disabled and(' ['..K.L('off')..']')or''));mover:SetFrameLevel(selected==a.id and 60 or 20+i)
   mover:SetBackdropBorderColor(selected==a.id and 1 or .72,selected==a.id and .82 or .57,selected==a.id and .35 or .29,1)
   mover:SetBackdropColor(.035,.045,.04,a.disabled and .12 or selected==a.id and .52 or .28);mover:Show()
   if selected==a.id then chosen:SetText(K.L(a.label));info:SetText(string.format(K.L('lePosition'),math.floor(x-UIParent:GetWidth()/2+.5),math.floor(y-UIParent:GetHeight()/2+.5)))end
  end
 end
 for id,mover in pairs(movers)do if not visible[id]and mover:IsShown()then mover:Hide()end end
 if not selected then chosen:SetText(K.L('leItems'));info:SetText('')end
 grid:SetShown(showGrid);shade:SetShown(showShade)
 if selected and byID[selected]then K.LayoutQuickOptions.Sync(selected,K.L(byID[selected].label))end
end
local function Ensure()
 if root then return end
 root=CreateFrame('Frame','KAClassicLayoutEditor',UIParent);M.root=root;root:SetAllPoints();root:SetFrameStrata('DIALOG');root:EnableMouse(false)
 shade=root:CreateTexture(nil,'BACKGROUND');shade:SetAllPoints();shade:SetColorTexture(0,0,0,.32)
 grid=CreateFrame('Frame',nil,root);grid:SetAllPoints();grid:EnableMouse(false)
 local width,height=UIParent:GetWidth(),UIParent:GetHeight();local step=32
 for x=0,width,step do local t=grid:CreateTexture(nil,'BACKGROUND');t:SetColorTexture(.76,.65,.40,.14);t:SetPoint('TOPLEFT',UIParent,'TOPLEFT',x,0);t:SetSize(1,height)end
 for y=0,height,step do local t=grid:CreateTexture(nil,'BACKGROUND');t:SetColorTexture(.76,.65,.40,.14);t:SetPoint('TOPLEFT',UIParent,'TOPLEFT',0,-y);t:SetSize(width,1)end
 bar=CreateFrame('Frame',nil,root,'BackdropTemplate');M.bar=bar;bar:SetFrameStrata('FULLSCREEN_DIALOG');bar:SetFrameLevel(120);bar:SetSize(1080,115);bar:SetScale(math.min(1,(UIParent:GetWidth()-24)/1080));bar:SetPoint('TOP',UIParent,'TOP',0,-10);bar:EnableMouse(true);Backdrop(bar,.97)
 local title=Font(bar,14,'KerimAnka UI — '..K.L('leTitle'));title:SetPoint('TOPLEFT',12,-9);titleText=title
 chosen=Font(bar,12);chosen:SetPoint('TOPLEFT',12,-37);chosen:SetWidth(200);chosen:SetJustifyH('LEFT')
 info=Font(bar,11);info:SetPoint('TOPLEFT',12,-59)
 Button(bar,'leSave',860,-9,206,function()M.Finish(true)end)
 Button(bar,'leCancel',860,-44,206,function()M.Finish(false)end)
 Button(bar,'leReset',410,-9,220,M.RestoreSelected)
 Button(bar,'qeTitle',410,-44,220,function()M.OpenQuickSettings()end)
 Button(bar,'leGrid',646,-9,196,function()showGrid=not showGrid;M.Refresh()end)
 Button(bar,'leShade',646,-44,196,function()showShade=not showShade;M.Refresh()end)
 Button(bar,'leItems',860,-82,206,function()if K.LayoutElements then K.LayoutElements.Toggle()end end)
 Button(bar,'leExamples',12,-82,200,function()if K.LayoutPreviews then K.LayoutPreviews.Toggle()end;M.Refresh()end)
 local examples=Font(bar,10,K.L('leExamplesHelp'));examplesText=examples;examples:SetPoint('TOPLEFT',234,-89);examples:SetWidth(570)

 local function Cycle(delta)
  if not selected then return end
  for i,a in ipairs(entries)do if a.id==selected then M.Select(entries[(i-1+delta)%#entries+1].id);return end end
 end
 Button(bar,'<',234,-9,70,function()Cycle(-1)end);Button(bar,'>',318,-9,70,function()Cycle(1)end)
 local hint=Font(bar,10,K.L('leHint'));hint:SetPoint('TOPLEFT',234,-46);hint:SetWidth(155);hint:SetWordWrap(true);hintText=hint
 root:SetScript('OnHide',function()if M.active and not closing then M.Finish(false)end end)
 if K.window then K.window:HookScript('OnShow',function()if M.active then M.Finish(true)end end)end
 UISpecialFrames[#UISpecialFrames+1]='KAClassicLayoutEditor';root:Hide()
end
function M.Start()
 if M.active then return end
 if Combat()then Message('combatLock');return false end
 if not K.db or K.db.profileTransaction then Message('pfPendingProfile');return false end
 if EditModeManagerFrame and EditModeManagerFrame.IsEditModeActive and EditModeManagerFrame:IsEditModeActive()then Message('leCloseNative');return false end
 if not M.Recover()then return false end
 if K.window then K.window:Hide()end
 Lookup()
 Ensure();for _,b in ipairs(localized)do K.ApplyTextFont(b.label,11,false,'OUTLINE');b.label:SetText(K.L(b.localeKey))end;titleText:SetText('KerimAnka UI — '..K.L('leTitle'));hintText:SetText(K.L('leHint'));if examplesText then examplesText:SetText(K.L('leExamplesHelp'))end;initial={};for _,a in ipairs(entries)do initial[a.id]=a.Capture()end
 M.session=(M.session or 0)+1;M.active=true;selected=entries[1]and entries[1].id;root:Show();if K.LayoutPreviews then K.LayoutPreviews.Start()end;M.Refresh()
 local elapsed=0;root:SetScript('OnUpdate',function(_,dt)elapsed=elapsed+dt;if elapsed>=.15 then elapsed=0;M.Refresh()end end)
 return true
end
function M.Toggle()if M.active then M.Finish(true)else return M.Start()end end
function M.IsActive()return M.active end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','ADDON_LOADED'})do events:RegisterEvent(event)end
events:SetScript('OnEvent',function(_,event)
 if event=='PLAYER_REGEN_DISABLED'and M.active then M.Finish(true,true)
 elseif (event=='PLAYER_LOGIN'or event=='PLAYER_REGEN_ENABLED'or event=='ADDON_LOADED')and Journal()and not M.active then C_Timer.After(0,function()if M.Recover()and K.Profiles then K.Profiles.Checkpoint()end end)end
end)
