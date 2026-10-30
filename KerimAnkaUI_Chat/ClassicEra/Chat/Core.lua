if select(2,...).blocked then return end
if WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,N=...;local K=N.host;local C=K.Chat
C.shells={};C.stats={refreshes=0,layouts=0};C.testVersion='Classic Chat test37'
local queued,busy,waitingCombat=false,false,false
local function Settings()
 if not K.db then return end
 if type(K.db.chat)~='table'then K.db.chat=C.DefaultSettings()end
 return K.db.chat
end
C.GetSettings=Settings
-- One fixed bottom toolbar for this prototype; legacy drawer preferences are left intact.
function C.ToggleMicro()end
function C.Enabled()local d=Settings();return not C.shuttingDown and d and d.enabled~=false end
local function Editing()return false end -- Main chat geometry belongs only to KerimAnka while enabled.
function C.GetMicroDock()
 if not C.Enabled()or Editing()then return end
 return C.microDock
end
function C.NativeInteraction()
 if MOVING_CHATFRAME then return true end
 for _,name in ipairs(CHAT_FRAMES or {})do
  local f=_G[name];local b=f and f.ResizeButton
  if b and b.GetButtonState and b:GetButtonState()=='PUSHED'then return true end
 end
 return false
end
function C.Queue()
 if busy or queued or not C.Enabled()or C.NativeInteraction()then return end
 queued=true
 C_Timer.After(0,function()queued=false;C.Refresh()end)
end
local function Visible(f)
 return f and f:IsShown()and(not f.isTemporary or f.inUse)
end
local function Bounds(f)
 local scale=f:GetEffectiveScale()/UIParent:GetEffectiveScale()
 local x,y=f:GetLeft(),f:GetBottom();if not x or not y then return end
 return x*scale,y*scale,f:GetWidth()*scale,f:GetHeight()*scale
end
local function Signature(g)
 return string.format('%.2f/%.2f/%.2f/%.2f/%.2f/%.2f',g.x,g.y,g.width,g.height,g.footer,g.railX)
end
function C.Refresh()
 if busy or not C.Enabled()or C.NativeInteraction()then return end
 if InCombatLockdown()then waitingCombat=true;return end
 C.tabKinds={}
 busy=true;C.stats.refreshes=C.stats.refreshes+1
 C.ApplyInputMode()
 local usedShells={}
 C.microDock=nil
 local list=C.List();local primary=GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.primary or ChatFrame1
 local menus=K.InventoryMenus;local d=Settings()
 local sideMicro=false
 local attach=not Editing()and d.microDock~=false and menus and menus.Get('microEnabled')
  and not menus.BartenderOwns('MicroMenu')and MicroMenu and MicroMenuContainer
  and MicroMenu:GetParent()==MicroMenuContainer
 for _,f in ipairs(list)do C.TrackNativePosition(f);C.StyleFrame(f)end
 C.ResolveInputOwner(list,GENERAL_CHAT_DOCK and FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK)or primary)
 C.StyleMicro(attach)
 for _,f in ipairs(list)do
  local docked=f.isDocked or f==primary
  local selected=docked and GENERAL_CHAT_DOCK and FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK)or nil
  local owner=docked and primary or f
  if Visible(f) and(not docked or selected==f or not selected and f==primary)and Bounds(owner)then
   C.PrepareInput(f)
   if not Editing()and not docked then C.EnsurePanelBounds(owner,f,38)end
   local _,_,nativeWidth=Bounds(owner)
   local toolbarHeight=docked and attach and C.MicroHeight(nativeWidth-8)or nil
   if not Editing()and not docked then C.EnsureBottomClearance(owner,31+(toolbarHeight and toolbarHeight+6 or 0),40)end
   local x,y,w,h=Bounds(owner)
   local quick=f.CombatLogQuickButtonFrame
   -- Docked combat-log header is already inside the primary frame's envelope.
   local qh=not docked and quick and quick:IsShown()and quick:GetHeight()*f:GetEffectiveScale()/UIParent:GetEffectiveScale()or 0
   local typing=f.editBox and f.editBox:IsShown()or false
   if docked then for _,other in ipairs(list)do
    if (other.isDocked or other==primary)and other.editBox and other.editBox:IsShown()then typing=true end
   end end
   local g=C.Geometry(x,y,w,h,UIParent:GetWidth(),toolbarHeight,qh,f.buttonSide or owner.buttonSide,typing)
   if docked and not Editing()then g=C.ApplyManaged(owner,f,attach);C.mainGeometry=g end
   if g then
    g.anchor=owner
    local shell=C.shells[owner]
    if not shell then shell=C.NewShell();C.shells[owner]=shell end
    local sig=Signature(g)
    if shell.signature~=sig then C.PlaceShell(shell,g);shell.signature=sig;C.stats.layouts=C.stats.layouts+1 end
    C.PaintBackground(shell)
    if docked then C.SettingsButton(shell,g);C.ResizeHandle(shell,g)end
    if not Editing()then C.PlaceControls(f,g)end
    shell.visibilityGeometry=g;shell.visibilityFrame=f
    usedShells[shell]=true;shell:Show()
    if docked and not Editing()then C.PlaceDock(g)end
    if quick then C.PlaceCombatHeader(f,owner,quick,docked)end
    if not docked then C.PlaceMinimize(f,shell)end
    if shell.microToggle then shell.microToggle:Hide()end
    C.JoinBronzeFrame(shell,g,_G[f:GetName()..'Tab'])
    -- Docked frames share one input well, but their native input objects stay separate.
    if docked then
     for _,other in ipairs(list)do if other.isDocked or other==primary then C.PlaceInput(other,g)end end
    else C.PlaceInput(f,g)end
    shell.input:Show()
    C.BindInputTarget(shell,f.editBox)
    shell.inputHint:SetShown(C.EnterMode()and not typing)
    if docked and attach then C.microDock={x=g.microX,y=g.microY,width=math.max(1,g.microWidth-(d.unlocked and 58 or 36)),height=g.microHeight,anchor=shell,vertical=false,hidden=false,buttonSize=d.microSize or 32,gap=d.microGap or 4,offsetX=10,offsetY=3}end
   end
  end
 end
 for _,shell in pairs(C.shells)do if not usedShells[shell]then shell:Hide()end end
 local md=C.microDock
 local sig=md and string.format('%.2f/%.2f/%.2f/%.2f/%s/%s',md.x,md.y,md.width,md.height or 0,tostring(md.vertical),tostring(md.hidden))..'/'..tostring(md.gap)..'/'..tostring(md.buttonSize)or 'none'
 if sig~=C.microSignature then
  C.microSignature=sig
  if menus then menus.Refresh()end
 end
 C.SyncTabLayers(GENERAL_CHAT_DOCK,true)
 busy=false
 C.UpdateVisibilityDriver()
end
local function NativeChanged()C.Queue()end
function C.DiscoverHooks()
 C.InstallBackgroundMenu()
 C.Hook('FCF_UpdateButtonSide',function(f)if C.Enabled()then C.SampleNativePosition(f)end end)
 C.Hook('FCF_DockFrame',function(f)if C.Enabled()then
  if C.controlGeometries then C.controlGeometries[f]=nil end
  if MOVING_CHATFRAME==f then C.ResolveNativePosition(f)end;C.Queue()
 end end)
 C.Hook('FCF_UnDockFrame',function(f)if C.controlGeometries then C.controlGeometries[f]=nil end;C.Queue()end)
 C.Hook('FCF_ToggleLock',C.Queue)
 C.Hook('FCFTab_UpdateAlpha',C.KeepTabVisible)
 C.Hook('FCF_FadeInChatFrame',C.KeepTabVisible)
 C.Hook('FCF_FadeOutChatFrame',C.KeepTabVisible)
 C.Hook('FCFTab_UpdateColors',C.UpdateTab)
 local dock=GENERAL_CHAT_DOCK
 if dock and dock.HookScript then C.HookScript(dock,'OnSizeChanged',function(self)
  local r=C.records[self];if r then r.dockKey=nil end;C.Queue()
 end)end
 C.Hook('FCFDock_SetPrimary',function(dock)local r=C.records[dock];if r then r.dockKey=nil end;C.Queue()end)
 local viewport=GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.scrollFrame
 if viewport then C.HookScript(viewport,'OnHorizontalScroll',C.Queue)end
 for _,name in ipairs({'FCF_OpenNewWindow','FCF_OpenTemporaryWindow','FCF_Close',
 'ChatFrame_AddMessageGroup','ChatFrame_RemoveMessageGroup','ChatFrame_AddChannel','ChatFrame_RemoveChannel',
 'FCF_DockFrame','FCF_UnDockFrame','FCFDock_SelectWindow','FCF_SetWindowName',
 'FCF_RestorePositionAndDimensions','FCF_StopDragging','FCF_SavePositionAndDimensions','FCF_SetButtonSide','FCF_MinimizeFrame','FCF_MaximizeFrame',
 'Blizzard_CombatLog_Update_QuickButtons'})do C.Hook(name,NativeChanged)end
 -- Native dock update runs frequently; Queue coalesces it. Skip unchanged dock state.
 C.Hook('FCFDock_UpdateTabs',function(dock)
  C.SyncTabLayers(dock)
  local selected=FCFDock_GetSelectedWindow(dock)
  local count=#FCFDock_GetChatFrames(dock)
  if C.selected~=selected or C.count~=count then C.selected=selected;C.count=count;C.Queue()end
 end)
 if K.InventoryMenus and not C.menuHook then C.menuHook=true;hooksecurefunc(K.InventoryMenus,'Refresh',C.Queue)end
 if EditModeManagerFrame then
  C.HookScript(EditModeManagerFrame,'OnShow',C.Queue);C.HookScript(EditModeManagerFrame,'OnHide',C.Queue)
 end
end
function C.SetEnabled(enabled)
 if InCombatLockdown()then print('KerimAnka Chat: change this setting out of combat.');return end
 local d=Settings();if not d then return end
 if enabled then d.enabled=true;C.DiscoverHooks();C.Queue()
 else d.enabled=false;busy=true;C.RestoreInputMode();C.Restore();if K.InventoryMenus then K.InventoryMenus.Refresh()end;busy=false end
end


C.themes={
 {name='Klasik koyu',en='Classic dark',body={.045,.060,.055,.94},bar={.075,.10,.085,1}},
 {name='Antrasit',en='Anthracite',body={.065,.075,.09,.96},bar={.10,.115,.135,1}},
 {name='Sıcak koyu',en='Warm dark',body={.085,.065,.045,.96},bar={.125,.10,.075,1}},
}
function C.Text(tr,en)return K.ChatText and K.ChatText(en)or (K.account and K.account.language=='tr'and tr or en)end
function C.ThemeID()local id=Settings().theme;return C.themes[id]and id or 1 end
function C.Background()return unpack(C.themes[C.ThemeID()].body)end
function C.PaintBackground(shell)
 local t=C.themes[C.ThemeID()];shell.material:SetColorTexture(unpack(t.body))
 shell.footer:SetColorTexture(unpack(t.bar));shell.tabBand:SetColorTexture(unpack(t.bar))
end
function C.SetTheme(id)
 if not C.themes[id]then return end
 local d=Settings();d.theme=id
 -- Ignore earlier experimental free colors; presets are the sole appearance source.
 d.backgroundColor=nil;d.backgroundAlpha=nil
 for _,shell in pairs(C.shells)do C.PaintBackground(shell)end
end
function C.OpenSettings()
 if not K.window and K.BuildWindow then K.BuildWindow()end
 if K.ShowPage then K.ShowPage('chat')end
end
-- Old slash entry redirects to the real suite page, never the game color picker.
C.OpenBackgroundPicker=C.OpenSettings
function C.InstallBackgroundMenu()
 if C.backgroundMenuInstalled or not Menu or not Menu.ModifyMenu or not MenuUtil or not MenuUtil.GetElementText then return end
 C.backgroundMenuInstalled=true
 Menu.ModifyMenu('MENU_FCF_TAB',function(owner,root)
  if not C.Enabled()then return end
  for _,entry in root:EnumerateElementDescriptions()do
   if HUD_EDIT_MODE_MENU and MenuUtil.GetElementText(entry)==HUD_EDIT_MODE_MENU then
    entry:SetResponder(function()C.OpenEditor();return MenuResponse and MenuResponse.CloseAll end)
   end
   local data=entry.GetData and entry:GetData()
   local isBackground=type(data)=='table' and FCF_SetChatWindowBackGroundColor and data.swatchFunc==FCF_SetChatWindowBackGroundColor
   if (isBackground or MenuUtil.GetElementText(entry)==BACKGROUND) and entry.SetResponder then
    if MenuUtil.SetElementText then MenuUtil.SetElementText(entry,'KerimAnka · '..C.Text('Chat görünümü','Chat appearance'))end
    entry:SetResponder(function()C.OpenSettings();return MenuResponse and MenuResponse.CloseAll end)
    -- Color swatches may install their own OnClick rather than use the responder.
    if entry.AddInitializer then entry:AddInitializer(function(button)
     if button.fontString then button.fontString:SetText('KerimAnka · '..C.Text('Chat görünümü','Chat appearance'))end
     if button.colorSwatch then button.colorSwatch:Hide()end
     button:SetScript('OnClick',function()
      local manager=Menu and Menu.GetManager and Menu.GetManager()
      if manager and manager.CloseMenus then manager:CloseMenus()end
      C.OpenSettings()
     end)
    end)end
   end
  end
 end)
end
function C.SettingsButton(shell,g)
 if not shell.settingsButton then
  local b=CreateFrame('Button',nil,shell);b:SetSize(28,28);b:SetFrameStrata('LOW');b:SetFrameLevel(15)
  local bg=b:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.13,.18,.15,1);C.Border(b,1)
  local icon=b:CreateTexture(nil,'ARTWORK');icon:SetSize(18,18);icon:SetPoint('CENTER')
  icon:SetTexture('Interface\\AddOns\\KerimAnkaUI_Chat\\ClassicEra\\Chat\\Media\\SimpleSettings.tga')
  b:SetScript('OnClick',C.OpenSettings)
  b:SetScript('OnEnter',function(self)C.ButtonTooltip(self,C.Text('Chat ayarları','Chat settings'),C.Text('Görünüm, yerleşim ve mikro menü ayarlarını aç.','Open appearance, layout and micro menu settings.'))end)
  b:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
  shell.settingsButton=b
 end
 local size=math.min(28,g.microHeight or 28);shell.settingsButton:SetSize(size,size)
 shell.settingsButton:ClearAllPoints();shell.settingsButton:SetPoint('BOTTOMRIGHT',shell,'BOTTOMRIGHT',Settings().unlocked and -29 or -7,3)
 shell.settingsButton:SetShown(g.footer>0)
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','UPDATE_CHAT_WINDOWS','UPDATE_FLOATING_CHAT_WINDOWS',
 'ADDON_LOADED','PLAYER_REGEN_ENABLED','UI_SCALE_CHANGED','DISPLAY_SIZE_CHANGED','PLAYER_LOGOUT'})do events:RegisterEvent(event)end
events:SetScript('OnEvent',function(_,event)
 if event=='PLAYER_LOGOUT'then C.shuttingDown=true;C.RestoreInputMode();return end
 if event=='ADDON_LOADED' or event=='PLAYER_LOGIN'then C.DiscoverHooks()end
 if event=='PLAYER_REGEN_ENABLED'then waitingCombat=false end
 C.Queue()
end)
SLASH_KERIMANKACHAT1='/kachat'
SlashCmdList.KERIMANKACHAT=function(input)
 input=(input or ''):lower():match('^%s*(.-)%s*$')
 if input=='off'then C.SetEnabled(false)
 elseif input=='on'then C.SetEnabled(true)
 elseif input=='micro left'then print('KerimAnka Chat: test26 uses one fixed bottom toolbar.')
 elseif input=='micro bottom'then print('KerimAnka Chat: test26 uses one fixed bottom toolbar.')
 elseif input=='micro hide'then print('KerimAnka Chat: test26 uses one fixed bottom toolbar.')
 elseif input=='micro show'then print('KerimAnka Chat: test26 uses one fixed bottom toolbar.')
 elseif input=='settings'then C.OpenSettings()
 elseif input=='background'then C.OpenBackgroundPicker()
 elseif input=='refresh'then C.Queue()
 elseif input=='input enter'then C.SetInputMode(true)
 elseif input=='input always'then C.SetInputMode(false)
 else print('KerimAnka Chat test37: '..(C.Enabled()and 'ON'or 'OFF')..' | /kachat input always | /kachat input enter | /kachat on/off')end
end
-- Main dock geometry has one owner. Detached windows retain native positioning.
function C.Controls(frame)
 local out={};local bar=frame and frame.buttonFrame
 if bar then for _,b in ipairs({bar:GetChildren()})do
  if b.layoutIndex and b:IsObjectType('Button')and b:IsShown()then out[#out+1]=b end
 end end
 table.sort(out,function(a,b)return a.layoutIndex<b.layoutIndex end);return out
end
function C.ManagedBounds()
 local d=Settings();local f=GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.primary or ChatFrame1
 if not d or not f then return end
 if not d.width then local defaults=C.DefaultSettings();for key,value in pairs(defaults)do if d[key]==nil then d[key]=value end end end
 return d
end
function C.SetLayout(key,value)
 if InCombatLockdown()then return false end
 local d=C.ManagedBounds();if not d then return false end
 local ranges={x={0,10000},y={0,10000},width={348,3000},height={160,2000},controlMode={1,3},microGap={0,12},microSize={20,40}}
 if key=='unlocked'then d[key]=value==true
 elseif ranges[key]and type(value)=='number'and value==value then d[key]=math.max(ranges[key][1],math.min(ranges[key][2],value))
 else return false end
 C.Queue();return true
end
function C.ApplyManaged(owner,active,attach)
 local d=C.ManagedBounds();if not d then return end
 -- Keep outer minimums and auto-mode hysteresis independent of the selected tab.
 local controls=C.Controls(owner);local vertical=0;local horizontal=0
 for _,b in ipairs(controls)do
  local friend=b:GetName()=='FriendsMicroButton'
  vertical=vertical+(friend and 34 or 24)+2;horizontal=horizontal+(friend and 46 or 24)+2
 end
 local gap=d.microGap or 4;local size=d.microSize or 32
 local count=0;if attach and MicroMenu then for _,b in ipairs({MicroMenu:GetChildren()})do if b.layoutIndex and b:IsObjectType('Button')and b:IsShown()then count=count+1 end end end
 local minW=math.max(348,horizontal+16,count*size+math.max(0,count-1)*gap+(d.unlocked and 78 or 56))
 d.width=math.min(UIParent:GetWidth(),math.max(minW,d.width))
 local footer=attach and size+6 or 0
 local threshold=vertical+12+29+footer+6
 local mode=d.controlMode or 1;local row=mode==3
 if mode==1 then row=C.horizontal and d.height<threshold+16 or not C.horizontal and d.height<threshold end
 C.horizontal=row
 local header=row and 32 or 0
 local minH=(row and 64+header or math.max(90,vertical+6))+29+footer+6
 d.height=math.min(UIParent:GetHeight()-30,math.max(minH,d.height))
 -- Only the primary tab owns the full toolbar. Other tabs use a compact left rail.
 if active~=owner then row=false;header=0 end
 if C.dragTop then d.y=C.dragTop-d.height end
 d.x=math.max(0,math.min(UIParent:GetWidth()-d.width,d.x or 0))
 d.y=math.max(0,math.min(UIParent:GetHeight()-d.height-30,d.y or 0))
 local inset=row and 10 or 38
 local x,y=d.x+inset,d.y+footer+29
 local w,h=d.width-inset-10,d.height-footer-29-header-6
 C.OwnNativeFrame(owner)
 local r=C.Remember(owner);r.placed=true
 local scale=owner:GetEffectiveScale()/UIParent:GetEffectiveScale()
 owner:ClearAllPoints();owner:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',x/scale,y/scale);owner:SetSize(w/scale,h/scale)
 return {x=d.x,y=d.y,width=d.width,height=d.height,anchorX=x,anchorY=y,anchor=owner,
 railX=inset-6,footer=footer,inputX=d.x+8,inputWidth=d.width-42,inputY=d.y+footer,inputHeight=26,
 microX=d.x+10,microY=d.y+3,microWidth=d.width-20,microHeight=attach and size or nil,
 horizontal=row,controlsLeft=active~=owner,header=header,dockOffset=header+6}
end
function C.PlaceControls(frame,g)
 local bar=frame.buttonFrame;if not bar then return end
 local scale=bar:GetEffectiveScale()/UIParent:GetEffectiveScale()
 C.Unclamp(bar)
 local r=C.Remember(bar);r.placed=true
 local railLeft=g.horizontal and g.x+7 or (not g.controlsLeft and frame.buttonSide=='right'and g.x+g.width-33 or g.x+7)
 local ax,ay=frame:GetLeft(),frame:GetBottom()
 if not ax or not ay then return end
 bar:ClearAllPoints();bar:SetPoint('TOPLEFT',frame,'BOTTOMLEFT',(railLeft-ax*scale)/scale,(g.y+g.height-6-ay*scale)/scale)
 bar:SetSize((g.horizontal and g.width-14 or 26)/scale,(g.horizontal and 26 or g.height-g.footer-35)/scale)
 local offset=0
 for _,b in ipairs(C.Controls(frame))do
  local br=C.Remember(b);br.placed=true
  local friend=b:GetName()=='FriendsMicroButton';local w=g.horizontal and friend and 46 or 24;local h=not g.horizontal and friend and 34 or 24
  b:ClearAllPoints();b:SetPoint('TOPLEFT',bar,'TOPLEFT',g.horizontal and offset/scale or 0,g.horizontal and 0 or -offset/scale);b:SetSize(w/scale,h/scale)
  local surface=C.toolSurfaces and C.toolSurfaces[b]
  if friend and surface and surface.countLabel then
   local icon,label=surface.glyph,surface.countLabel;icon:ClearAllPoints();label:ClearAllPoints()
   if g.horizontal then icon:SetPoint('LEFT',surface,'LEFT',3,0);label:SetPoint('RIGHT',surface,'RIGHT',-3,0)
   else icon:SetPoint('TOP',surface,'TOP',0,-2);label:SetPoint('BOTTOM',surface,'BOTTOM',0,2)end
  end
  offset=offset+(g.horizontal and w or h)+2
 end
 C.controlGeometries=C.controlGeometries or setmetatable({},{__mode='k'});C.controlGeometries[frame]=g
 C.controlLayoutHooks=C.controlLayoutHooks or setmetatable({},{__mode='k'})
 if bar.Layout and not C.controlLayoutHooks[bar]then
  C.controlLayoutHooks[bar]=true;hooksecurefunc(bar,'Layout',function()
   if C.Enabled()and not C.NativeInteraction()and not Editing()and not InCombatLockdown()and C.controlGeometries[frame]and frame:IsShown()and not C.placingControls then
    C.placingControls=true;C.PlaceControls(frame,C.controlGeometries[frame]);C.placingControls=false
   end
  end)
 end
end
function C.ResizeHandle(shell,g,inEditor)
 if not shell.resize then
  local b=CreateFrame('Button',nil,shell);shell.resize=b;b:SetSize(22,22);b:EnableMouse(true);b:SetFrameStrata('MEDIUM')
  local grip=b:CreateTexture(nil,'ARTWORK');grip:SetAllPoints();grip:SetTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up');grip:SetVertexColor(.8,.85,.78,1)
  b:SetScript('OnEnter',function(self)grip:SetVertexColor(1,.9,.6,1);C.ButtonTooltip(self,C.Text('Boyutlandır','Resize'),C.Text('Basılı tutup sürükle.','Hold and drag to resize.'))end)
  b:SetScript('OnLeave',function()grip:SetVertexColor(.8,.85,.78,1);if GameTooltip then GameTooltip:Hide()end end)
  b:RegisterForDrag('LeftButton')
  local function Stop(self)self:SetScript('OnUpdate',nil);self.drag=nil;C.dragTop=nil end
  b:SetScript('OnDragStop',Stop)
  b:SetScript('OnHide',Stop)
  b:SetScript('OnDragStart',function(self)
   if GameTooltip then GameTooltip:Hide()end
   if InCombatLockdown()then return end
   if inEditor and K.LayoutEditor then K.LayoutEditor.MarkChatResize()end
   local d=C.ManagedBounds();local x,y=GetCursorPosition();local scale=UIParent:GetEffectiveScale()
   C.dragTop=d.y+d.height
   self.drag={x=x/scale,y=y/scale,w=d.width,h=d.height,bottom=d.y,top=d.y+d.height}
   self:SetScript('OnUpdate',function(btn)
    if InCombatLockdown()or not C.Enabled()or not(inEditor and K.LayoutEditor and K.LayoutEditor.IsActive()or Settings().unlocked)then Stop(btn);return end
    local a=btn.drag;local cx,cy=GetCursorPosition();cx=cx/scale;cy=cy/scale
    local d=C.ManagedBounds();d.width=a.w+cx-a.x;d.height=a.h+a.y-cy;d.y=a.top-d.height;C.Refresh();if inEditor then K.LayoutEditor.Refresh()end
   end)
  end)
 end
 shell.resize:ClearAllPoints();shell.resize:SetPoint('BOTTOMRIGHT',shell,'BOTTOMRIGHT',-1,1)
 shell.resize:SetFrameStrata(inEditor and 'DIALOG'or'MEDIUM');shell.resize:SetFrameLevel(shell:GetFrameLevel()+5)
 shell.resize:SetShown((inEditor or Settings().unlocked==true)and not InCombatLockdown())
end

function C.Unclamp(frame)
 if not frame.SetClampedToScreen then return end
 local r=C.Remember(frame)
 if r.nativeClamped==nil then r.nativeClamped=frame:IsClampedToScreen()end
 frame:SetClampedToScreen(false)
end
function C.OpenEditor()
 if InCombatLockdown()then return end
 if K.window then K.window:Hide()end
 if EditModeManagerFrame and EditModeManagerFrame:IsShown()then
  if HideUIPanel then HideUIPanel(EditModeManagerFrame)else EditModeManagerFrame:Hide()end
 end
 if K.LayoutEditor then K.LayoutEditor.Start();K.LayoutEditor.Select('chat')end
end
function C.OwnNativeFrame(frame)
 C.Unclamp(frame)
 local r=C.Remember(frame)
 if not r.lockSaved then r.lockSaved=true;r.nativeLocked=frame.isLocked end
 frame.isLocked=true
 C.nativeEditHooks=C.nativeEditHooks or setmetatable({},{__mode='k'})
 for _,name in ipairs({'Selection','EditModeResizeButton','ResizeButton'})do
  local child=frame[name]
  if child then
   local cr=C.Remember(child)
   if cr.nativeMouse==nil and child.IsMouseEnabled then cr.nativeMouse=child:IsMouseEnabled();cr.nativeShown=child:IsShown()end
   child:EnableMouse(false);child:Hide()
   if not C.nativeEditHooks[child]then
    C.nativeEditHooks[child]=true
    child:HookScript('OnShow',function(self)if C.Enabled()and not InCombatLockdown()then self:EnableMouse(false);self:Hide()end end)
   end
  end
 end
 if not C.nativeEditHooks[frame]then
  C.nativeEditHooks[frame]=true
  for _,method in ipairs({'OnEditModeEnter','OnEditModeExit'})do
   if frame[method]then hooksecurefunc(frame,method,function()if C.Enabled()and not InCombatLockdown()then C.OwnNativeFrame(frame);C.Queue()end end)end
  end
 end
end

-- Capture resolved rectangles; never substitute guessed screen coordinates.
function C.SampleNativePosition(f)
 if not f then return end
 local x,y=f:GetLeft(),f:GetBottom()
 if x and y then
  C.nativePositions=C.nativePositions or setmetatable({},{__mode='k'})
  C.nativePositions[f]={x=x,y=y,w=f:GetWidth(),h=f:GetHeight()}
 end
end
function C.ResolveNativePosition(f)
 if not f or not C.Enabled()or InCombatLockdown()then return end
 if f:GetLeft()and f:GetBottom()then C.SampleNativePosition(f);return end
 local p=C.nativePositions and C.nativePositions[f];if not p then return end
 f:ClearAllPoints();f:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',p.x,p.y);f:SetSize(p.w,p.h)
end
function C.TrackNativePosition(f)
 C.SampleNativePosition(f)
 C.nativeStopHooks=C.nativeStopHooks or setmetatable({},{__mode='k'})
 if f.StopMovingOrSizing and not C.nativeStopHooks[f]then
  C.nativeStopHooks[f]=true
  hooksecurefunc(f,'StopMovingOrSizing',function()C.ResolveNativePosition(f)end)
 end
end

-- The native header belongs to the combat-log tab, but our tab visuals are clipped.
-- Parent the real, interactive header to its message frame and restore on disable.
function C.PlaceCombatHeader(frame,owner,quick,docked)
 local r=C.Remember(quick);r.placed=true
 if not r.headerParentSaved then r.headerParentSaved=true;r.headerParent=quick:GetParent()end
 quick:SetParent(frame)
 quick:ClearAllPoints()
 if docked and frame~=owner then
  quick:SetPoint('TOPLEFT',owner,'TOPLEFT',0,-1)
  quick:SetPoint('TOPRIGHT',owner,'TOPRIGHT',0,-1)
  local fr=C.Remember(frame);fr.placed=true
  frame:SetPoint('TOPLEFT',owner,'TOPLEFT',0,-quick:GetHeight()-2)
 else
  quick:SetPoint('BOTTOMLEFT',frame,'TOPLEFT',0,0)
  quick:SetPoint('BOTTOMRIGHT',frame,'TOPRIGHT',0,0)
 end
end
function C.PlaceMinimize(frame,shell)
 local button=frame.minimizeButton;if not button then return end
 local r=C.Remember(button);r.placed=true
 -- Independent of the message viewport and combat header height.
 button:ClearAllPoints();button:SetPoint('BOTTOMLEFT',shell,'TOPLEFT',5,2)
 button:SetSize(26,26)
end

C.tabPalette={guild={.42,.82,.49},party={.57,.69,.96},raid={.96,.65,.34},combat={.94,.53,.35}}
function C.TabAccent(frame)
 if not Settings().channelColors or not frame then return end
 C.tabKinds=C.tabKinds or{}
 local cached=C.tabKinds[frame];if cached~=nil then return C.tabPalette[cached]end
 local kind=false
 if frame==COMBATLOG or frame==ChatFrame2 then kind='combat'
 elseif frame.GetID and GetChatWindowMessages then
  local id=frame:GetID()
  local groups={GUILD='guild',OFFICER='guild',GUILD_ACHIEVEMENT='guild',PARTY='party',PARTY_LEADER='party',RAID='raid',RAID_LEADER='raid',RAID_WARNING='raid'}
  local mixed=false
  for _,message in ipairs({GetChatWindowMessages(id)})do
   local group=groups[message]
   if not group or kind and kind~=group then mixed=true;break end
   kind=group
  end
  if GetChatWindowChannels and select('#',GetChatWindowChannels(id))>0 then mixed=true end
  if mixed then kind=false end
 end
 C.tabKinds[frame]=kind;return C.tabPalette[kind]
end
function C.SetChannelColors(enabled)
 if InCombatLockdown()then return false end
 Settings().channelColors=enabled==true;C.tabKinds={};C.Queue();return true
end
function C.ResetChatSettings()
 if InCombatLockdown()or K.LayoutEditor and K.LayoutEditor.IsActive()then return false end
 local enabled=Settings().enabled
 K.db.chat=C.DefaultSettings();K.db.chat.enabled=enabled~=false
 C.horizontal=nil;C.tabKinds={};C.Queue();return true
end

function C.ButtonTooltip(button,title,description)
 if not GameTooltip then return end
 GameTooltip:SetOwner(button,'ANCHOR_NONE');GameTooltip:ClearLines()
 GameTooltip:AddLine(title,1,.85,.43)
 GameTooltip:AddLine(description,.9,.9,.9,true)
 GameTooltip:ClearAllPoints();GameTooltip:SetPoint('BOTTOMLEFT',button,'TOPRIGHT',6,3)
 GameTooltip:Show()
end

-- Opt-in visibility: only a cheap pointer/focus check at 10 Hz; no layout polling.
C.visibilityState=setmetatable({},{__mode='k'})
function C.VisibilityValue(object,alpha,mouse)
 if not object then return end
 local saved=C.visibilityState[object]
 if not saved then saved={alpha=object:GetAlpha()};C.visibilityState[object]=saved end
 saved.wanted=alpha
 C.visibilityAlphaHooks=C.visibilityAlphaHooks or setmetatable({},{__mode='k'})
 if not C.visibilityAlphaHooks[object]then
  C.visibilityAlphaHooks[object]=true;hooksecurefunc(object,'SetAlpha',function(self,value)
   local state=C.visibilityState[self]
   if state and state.wanted~=nil and value~=state.wanted and C.Enabled()then self:SetAlpha(state.wanted)end
  end)
 end
 if object:GetAlpha()~=alpha then object:SetAlpha(alpha)end
 if mouse~=nil and object.EnableMouse and object.IsMouseEnabled and not(object.IsProtected and object:IsProtected())then
  if saved.mouse==nil then saved.mouse=object:IsMouseEnabled()end
  local wanted=mouse and saved.mouse or false
  if object:IsMouseEnabled()~=wanted then object:EnableMouse(wanted)end
 end
end
function C.RestoreVisibility()
 if C.visibilityDriver then C.visibilityDriver:SetScript('OnUpdate',nil)end
 for object,saved in pairs(C.visibilityState)do
  saved.wanted=nil
  object:SetAlpha(saved.alpha)
  if saved.mouse~=nil then object:EnableMouse(saved.mouse)end
 end
 wipe(C.visibilityState);C.visibilityElapsed=0
end
function C.VisibilityTick()
 local mode=Settings().visibilityMode or 1
 if not C.Enabled()or mode==1 or InCombatLockdown()then C.RestoreVisibility();return end
 local force=K.window and K.window:IsShown()or K.LayoutEditor and K.LayoutEditor.IsActive()or MOVING_CHATFRAME or C.dragTop
 local cursorX,cursorY=GetCursorPosition();local scale=UIParent:GetEffectiveScale();cursorX=cursorX/scale;cursorY=cursorY/scale
 local dock=GENERAL_CHAT_DOCK;local primary=dock and dock.primary or ChatFrame1
 for owner,shell in pairs(C.shells)do
  if shell:IsShown()and shell.visibilityGeometry then
   local g=shell.visibilityGeometry;local active=shell.visibilityFrame
   local hover=cursorX>=g.x and cursorX<=g.x+g.width and cursorY>=g.y and cursorY<=g.y+g.height+30
   local focused=false
   for _,frame in ipairs(C.List())do
    if frame==active or owner==primary and(frame.isDocked or frame==primary)then
     if frame.editBox and frame.editBox:HasFocus()then focused=true end
    end
   end
   local visible=force or hover or focused
   local a=visible and 1 or 0
   C.VisibilityValue(shell,a)
   for _,button in pairs({shell.settingsButton,shell.resize,shell.inputClick,shell.clearDraft})do C.VisibilityValue(button,a,visible)end
   for _,frame in ipairs(C.List())do
    if frame==active or owner==primary and(frame.isDocked or frame==primary)then
     C.VisibilityValue(frame,(visible or mode==2)and 1 or 0,visible)
     C.VisibilityValue(frame.buttonFrame,a)
     for _,button in ipairs(C.Controls(frame))do C.VisibilityValue(button,a,visible)end
     C.VisibilityValue(frame.minimizeButton,a,visible)
     C.VisibilityValue(frame.CombatLogQuickButtonFrame,a)
     C.VisibilityValue(frame.editBox,a,visible)
     local tab=_G[frame:GetName()..'Tab'];C.VisibilityValue(tab,a,visible)
     local r=tab and C.records[tab];if r then C.VisibilityValue(r.tabChrome,a)end
    end
   end
   if owner==primary then
    if dock then C.VisibilityValue(dock.overflowButton,a,visible)end
    if C.microDock and MicroMenu then
     for _,button in ipairs({MicroMenu:GetChildren()})do
      if button.layoutIndex and button:IsObjectType('Button')then C.VisibilityValue(button,a,visible)end
     end
    end
   end
  end
 end
end
function C.UpdateVisibilityDriver()
 local mode=Settings().visibilityMode or 1
 if mode==1 or not C.Enabled()or InCombatLockdown()then C.RestoreVisibility();return end
 if not C.visibilityDriver then C.visibilityDriver=CreateFrame('Frame')end
 if not C.visibilityDriver:GetScript('OnUpdate')then
  C.visibilityElapsed=0
  C.visibilityDriver:SetScript('OnUpdate',function(_,elapsed)
   C.visibilityElapsed=C.visibilityElapsed+elapsed
   if C.visibilityElapsed>=.1 then C.visibilityElapsed=0;C.VisibilityTick()end
  end)
 end
 C.VisibilityTick()
end
function C.SetVisibilityMode(mode)
 if InCombatLockdown()or mode<1 or mode>3 then return false end
 C.RestoreVisibility();Settings().visibilityMode=mode;C.Queue();return true
end

function C.DefaultSettings()
 return {enabled=true,microDock=true,enterMode=false,theme=1,x=0,y=0,width=348,height=233,
 controlMode=2,microGap=12,microSize=20,unlocked=true,channelColors=true,visibilityMode=1}
end
