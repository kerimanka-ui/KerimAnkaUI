if select(2,...).blocked then return end
if WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,N=...;local K=N.host;local C=K.Chat
C.records={};C.scripts={};C.hooks={}
local function SnapPoints(f)
 local points={};for i=1,f:GetNumPoints()do points[i]={f:GetPoint(i)}end;return points
end
function C.Remember(f)
 if not f then return end
 local r=C.records[f];if r then return r end
 r={frame=f,points=SnapPoints(f),w=f:GetWidth(),h=f:GetHeight(),alpha=f:GetAlpha(),textures={},children={}}
 C.records[f]=r;return r
end
function C.Blank(t)
 if not t or not t.GetTexture then return end
 local r=C.Remember(t)
 if not r.blanked then r.texture=t:GetTexture();r.blanked=true end
 t:SetTexture('')
end
function C.Restore()
 if C.RestoreVisibility then C.RestoreVisibility()end
 if C.controlGeometries then wipe(C.controlGeometries)end
 for f,r in pairs(C.records)do
  if r.microArt then r.microArt=nil;f:SetAlpha(r.alpha)end
  if r.headerParentSaved then f:SetParent(r.headerParent)end
  if r.nativeClamped~=nil then f:SetClampedToScreen(r.nativeClamped)end
  if r.lockSaved then f.isLocked=r.nativeLocked end
  if r.nativeMouse~=nil then f:EnableMouse(r.nativeMouse);f:SetShown(r.nativeShown)end
  if r.blanked then
   if r.texture then f:SetTexture(r.texture)else f:SetTexture('')end
  end
  if r.placed then
   f:ClearAllPoints();for _,p in ipairs(r.points)do f:SetPoint(unpack(p))end
   f:SetSize(r.w,r.h)
  end
  if r.limitSize then f:SetSize(r.limitSize[1],r.limitSize[2])end
  if r.clearancePoints then
   f:ClearAllPoints();for _,p in ipairs(r.clearancePoints)do f:SetPoint(unpack(p))end
  end
  if r.fixedWidth then f.fixedWidth=r.fixedWidth;if f.MarkDirty then f:MarkDirty()end end
  if r.overflowWidth~=nil then f.width=r.overflowWidth end
  if r.inputInsets then f:SetTextInsets(unpack(r.inputInsets))end
  if r.toolFill then r.toolFill:Hide()end
  if r.toolUV then f:SetTexCoord(unpack(r.toolUV))end
  if r.chrome then r.chrome:Hide()end
  if r.tabChrome then r.tabChrome:Hide()end
  if r.textPoints then
   f:ClearAllPoints();for _,p in ipairs(r.textPoints)do f:SetPoint(unpack(p))end
  end
  if r.tabState then
   f.mouseOverAlpha=r.tabState.mouseOverAlpha;f.noMouseAlpha=r.tabState.noMouseAlpha
   f:SetAlpha(r.alpha)
   f:SetFrameLevel(r.tabState.level)
  end
  if r.textColor then f:SetTextColor(unpack(r.textColor))end
  if r.nativeLabel then f:SetAlpha(r.alpha)end
 end
 wipe(C.records)
 for _,f in pairs(C.shells or {})do if f.resize then f.resize:SetScript('OnUpdate',nil);f.resize.drag=nil end;f:Hide()end
 C.dragTop=nil
 if C.tabClip then C.tabClip:Hide()end
 C.microDock=nil;C.microSignature=nil
end
function C.EnsureBottomClearance(frame,minimum,minLeft)
 local scale=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
 local x,y=frame:GetLeft(),frame:GetBottom();if not x or not y then return end
 minLeft=minLeft or 0
 local maxX=math.max(minLeft,UIParent:GetWidth()-frame:GetWidth()*scale-12)
 local maxY=math.max(minimum,UIParent:GetHeight()-frame:GetHeight()*scale-36)
 local nx=math.min(maxX,math.max(x*scale,minLeft))/scale
 local ny=math.min(maxY,math.max(y*scale,minimum))/scale
 if math.abs(x-nx)<.1 and math.abs(y-ny)<.1 then return end
 local r=C.Remember(frame);if not r.clearancePoints then r.clearancePoints=SnapPoints(frame)end
 frame:ClearAllPoints();frame:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',nx,ny)
end
local function AnchorTooltip(button)
 if not C.Enabled()or not GameTooltip or not GameTooltip:IsShown()then return end
 local owner=GameTooltip.GetOwner and GameTooltip:GetOwner()
 if owner~=button then return end
 GameTooltip:ClearAllPoints();GameTooltip:SetPoint('BOTTOMLEFT',button,'TOPRIGHT',6,3)
end
function C.NearTooltip(button)
 C.tooltipButtons=C.tooltipButtons or setmetatable({},{__mode='k'})
 if C.tooltipButtons[button]then return end;C.tooltipButtons[button]=true
 -- Native OnEnter populates the tooltip first. Reanchor in the SAME dispatch,
 -- before a rendered frame; a zero-delay timer previously caused the corner flash.
 button:HookScript('OnEnter',AnchorTooltip)
end
function C.HideNativeLabel(text)
 local r=C.Remember(text);r.nativeLabel=true
 C.labelHooks=C.labelHooks or setmetatable({},{__mode='k'})
 if not C.labelHooks[text]then
  C.labelHooks[text]=true
  hooksecurefunc(text,'SetAlpha',function(self,a)
   if a~=0 and C.Enabled()and C.records[self]and C.records[self].nativeLabel then self:SetAlpha(0)end
  end)
 end
 text:SetAlpha(0)
end

function C.KeepTabVisible(frame)
 if not C.Enabled()or not frame then return end
 local tab=_G[frame:GetName()..'Tab'];if not tab or not C.records[tab]then return end
 if UIFrameFadeRemoveFrame then UIFrameFadeRemoveFrame(tab)end
 tab.mouseOverAlpha=1;tab.noMouseAlpha=1;tab:SetAlpha(1)
end
function C.UpdateTab(tab,selected)
 if not C.Enabled()then return end
 local r=C.records[tab];if not r or not r.tabChrome then return end
 C.PlaceTabPlate(tab,r.tabChrome)
 r.tabChrome.accent=C.TabAccent(r.chatFrame)
 C.SelectBronzeTab(r.tabChrome,selected)
 -- Raise the selected tab as a whole (including its native text), not an opaque
 -- overlay above the label. Passive shoulders can tuck behind it.
 local base,count,index=r.rowBase or 64,r.rowCount or 1,r.rowIndex or 1
 local level=base+(selected and (count+2)*2 or (count-index)*2)
 if tab:GetFrameLevel()~=level then tab:SetFrameLevel(level)end
 r.tabChrome:SetFrameLevel(tab:GetFrameLevel()-1)
 local text=tab.GetFontString and tab:GetFontString()
 if text and not tab.selectedColorTable then
  if selected then text:SetTextColor(1,.85,.43,1)
  elseif r.tabChrome.hover then text:SetTextColor(.91,.83,.64,1)
  else text:SetTextColor(.65,.63,.56,1)end
 end
 if text then C.HideNativeLabel(text)end
 if text then
  local plate=r.tabChrome
  if not plate.label then plate.label=plate:CreateFontString(nil,'OVERLAY')end
  local label=plate.label
  if text.GetFont then
   local path,size,flags=text:GetFont()
   if path then label:SetFont(path,size,flags)end
  end
  label:SetText(text:GetText())
  if selected then label:SetTextColor(.95,.88,.65,1)elseif plate.hover then label:SetTextColor(.85,.86,.79,1)else label:SetTextColor(.64,.68,.62,1)end
  if plate.accent then local a=plate.accent;local gain=selected and 1 or plate.hover and .95 or .78;label:SetTextColor(a[1]*gain,a[2]*gain,a[3]*gain,1)end
  label:ClearAllPoints();label:SetPoint('CENTER',plate,'CENTER',0,0)
  label:SetWidth(math.max(1,tab:GetWidth()-8))
  if label.SetWordWrap then label:SetWordWrap(false)end
  if label.SetShadowColor then label:SetShadowColor(0,0,0,.8);label:SetShadowOffset(1,-1)end
 end

end
function C.SyncTabLayers(dock,force)
 if not C.Enabled()or C.tabLayerBusy then return end
 dock=dock or GENERAL_CHAT_DOCK;if not dock then return end
 local frames=FCFDock_GetChatFrames(dock);local selected=FCFDock_GetSelectedWindow(dock)
 if not force and C.layerDock==dock and C.layerCount==#frames and C.layerSelected==selected then return end
 C.tabLayerBusy=true;C.layerDock,C.layerCount,C.layerSelected=dock,#frames,selected
 -- All tabs in a dock share one scale, even when Blizzard puts the extra ones
 -- in a higher scrollChild. Rank left-to-right, selected always above the row.
 local base=64
 for _,frame in ipairs(frames)do
  local tab=_G[frame:GetName()..'Tab'];local p=tab and tab:GetParent()
  if p then base=math.max(base,p:GetFrameLevel()+2)end
 end
 for i,frame in ipairs(frames)do
  local tab=_G[frame:GetName()..'Tab'];local r=tab and C.records[tab]
  if r and r.tabChrome then
   r.rowBase,r.rowCount,r.rowIndex=base,#frames,i
   C.UpdateTab(tab,frame==selected)
  end
 end
 C.tabLayerBusy=false
end
function C.HoverTab(tab,hover)
 if not C.Enabled()then return end
 local r=C.records[tab];if not r or not r.tabChrome then return end
 r.tabChrome.hover=hover;C.UpdateTab(tab,r.tabChrome.selected)
end
function C.StyleTab(frame)
 local tab=_G[frame:GetName()..'Tab'];if not tab then return end
 local r=C.Remember(tab);r.chatFrame=frame
 if not r.tabState then
  r.tabState={mouseOverAlpha=tab.mouseOverAlpha,noMouseAlpha=tab.noMouseAlpha,level=tab:GetFrameLevel()}
  for _,key in ipairs({'leftTexture','middleTexture','rightTexture','leftSelectedTexture','middleSelectedTexture','rightSelectedTexture','leftHighlightTexture','middleHighlightTexture','rightHighlightTexture'})do C.Blank(tab[key])end
  r.tabChrome=C.NewTabChrome(tab)
  C.HookScript(tab,'OnHide',function(self)local r=C.records[self];if r and r.tabChrome then r.tabChrome:Hide()end end)
  C.HookScript(tab,'OnShow',C.Queue)
  r.tabChrome.hover=tab.IsMouseOver and tab:IsMouseOver()or false
  r.tabChrome.paintKey=nil
  C.HookScript(tab,'OnSizeChanged',C.Queue)
  C.HookScript(tab,'OnEnter',function(self)C.HoverTab(self,true)end)
  C.HookScript(tab,'OnLeave',function(self)C.HoverTab(self,false)end)
  if not C.hooks[tab]then C.hooks[tab]=true;hooksecurefunc(tab,'SetPoint',C.Queue)end
  C.tabParentHooks=C.tabParentHooks or setmetatable({},{__mode='k'})
  if not C.tabParentHooks[tab]then C.tabParentHooks[tab]=true;hooksecurefunc(tab,'SetParent',function()
   -- SetParent can reset frame levels AFTER native UpdateColors ran.
   -- Apply row ordering after the parent operation, without moving the tab.
   C.SyncTabLayers(GENERAL_CHAT_DOCK,true)
  end)end
 end
 local text=tab.GetFontString and tab:GetFontString()
 if text then
  local tr=C.Remember(text);if not tr.textPoints then tr.textPoints=SnapPoints(text)end
  if not tr.textColor and text.GetTextColor then tr.textColor={text:GetTextColor()}end
 end
 r.tabChrome:Show()
 C.SizeBronzeTab(r.tabChrome,tab:GetWidth())
 local docked=frame.isDocked or frame==GENERAL_CHAT_DOCK.primary
 local selected=not docked or frame==FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK)
 C.UpdateTab(tab,selected);C.KeepTabVisible(frame)
end
function C.StyleMicro(visible)
 if not MicroMenu then return end
 for _,button in ipairs({MicroMenu:GetChildren()})do
  if button.layoutIndex and button:IsObjectType('Button')then
   local r=C.records[button]
   if visible then
    r=C.Remember(button);C.NearTooltip(button);C.HideMicroArt(button)
    C.HookScript(button,'OnShow',C.Queue);C.HookScript(button,'OnHide',C.Queue)
    if not r.chrome then
     r.chrome=C.NewButtonChrome(button,true);r.chrome:ClearAllPoints()
     r.chrome:SetPoint('TOPLEFT',-.5,.5);r.chrome:SetPoint('BOTTOMRIGHT',.5,-.5)
    end
   end
   if r and r.chrome then r.chrome:SetShown(visible)end
  end
 end
end
function C.HookScript(f,event,callback)
 if not f then return end
 local found=C.scripts[f];if not found then found={};C.scripts[f]=found end
 if not found[event]then f:HookScript(event,callback);found[event]=true end
end
function C.Hook(name,callback)
 if type(_G[name])=='function' and not C.hooks[name]then
  hooksecurefunc(name,callback);C.hooks[name]=true
 end
end
function C.StyleFrame(f)
 if not f then return end
 local name=f:GetName();local record=C.Remember(f)
 C.StyleTab(f)
 if not record.styled then
  record.styled=true
  for _,suffix in ipairs(CHAT_FRAME_TEXTURES or {})do C.Blank(_G[name..suffix])end
  C.HookScript(f,'OnSizeChanged',C.Queue)
  C.HookScript(f,'OnShow',C.Queue);C.HookScript(f,'OnHide',C.Queue)
  C.HookScript(f,'OnDragStop',C.Queue)
  -- Reapply shell geometry after native edit-mode moves; no native message hook.
  if not C.hooks[f]then
   C.hooks[f]=true;hooksecurefunc(f,'SetPoint',C.Queue)
  end
 end
 local bar=f.buttonFrame
 if bar then
  local barRecord=C.Remember(bar)
  if not barRecord.fixedWidth then barRecord.fixedWidth=bar.fixedWidth;bar.fixedWidth=26;bar:SetWidth(26);barRecord.placed=true end
  -- Reanchor the native group, never its children: scroll handlers need parent.parent.
  bar:ClearAllPoints()
  if f.buttonSide=='right'then bar:SetPoint('TOPLEFT',f,'TOPRIGHT',8,0)
  else bar:SetPoint('TOPRIGHT',f,'TOPLEFT',-8,0)end
  for _,b in ipairs({bar:GetChildren()})do
   if b:IsObjectType('Button') and b.layoutIndex then
    local br=C.Remember(b);C.NearTooltip(b);C.StyleToolButton(b)
    if not br.chrome then br.chrome=C.NewButtonChrome(b)end
    if not br.placed then b:SetSize(24,b:GetName()=='FriendsMicroButton'and 34 or 24);br.placed=true;if bar.MarkDirty then bar:MarkDirty()end end
    br.chrome:Show()
   end
  end
 end
 local edit=f.editBox
 if edit then
  C.Remember(edit)
  for _,suffix in ipairs({'Left','Mid','Right'})do C.Blank(_G[edit:GetName()..suffix])end
  C.HookScript(edit,'OnShow',C.Queue);C.HookScript(edit,'OnHide',C.Queue)
 end
end
function C.PlaceInput(f,g)
 local edit=f.editBox;if not edit then return end
 local r=C.Remember(edit);r.placed=true
 -- Preserve the native parent and event scripts, including IME and autocomplete.
 local scale=edit:GetEffectiveScale()/UIParent:GetEffectiveScale()
 edit:ClearAllPoints();edit:SetPoint('BOTTOMLEFT',g.anchor or UIParent,'BOTTOMLEFT',
  (g.inputX-(g.anchor and g.anchorX or 0))/scale,(g.inputY-(g.anchor and g.anchorY or 0))/scale)
 edit:SetSize(g.inputWidth/scale,g.inputHeight/scale)
 C.AlignInputHeader(edit)
end
function C.List()
 local list={}
 for _,name in ipairs(CHAT_FRAMES or {})do local f=_G[name];if f then list[#list+1]=f end end
 return list
end

function C.PlaceDock(g)
 local dock=GENERAL_CHAT_DOCK
 if not dock or not dock.SetPoint then return end
 local r=C.Remember(dock);r.placed=true
 local scale=dock:GetEffectiveScale()/UIParent:GetEffectiveScale()
 local key=string.format('%.3f/%.3f/%.3f/%.3f',g.x,g.width,scale,g.dockOffset or 6)
 if r.dockKey~=key then
  r.dockKey=key
  dock:ClearAllPoints()
  dock:SetPoint('BOTTOMLEFT',g.anchor,'TOPLEFT',(g.x+1-g.anchorX)/scale,(g.dockOffset or 6)/scale)
  dock:SetPoint('BOTTOMRIGHT',g.anchor,'TOPRIGHT',(g.x+g.width-1-g.anchorX-g.anchor:GetWidth()*g.anchor:GetEffectiveScale()/UIParent:GetEffectiveScale())/scale,(g.dockOffset or 6)/scale)
  -- Recalculate after the engine resolves new anchor bounds, once per layout change.
  if not C.dockSettlePending then
   C.dockSettlePending=true
   C_Timer.After(0,function()
    C.dockSettlePending=false
    if not C.Enabled()or InCombatLockdown()then return end
    if FCFDock_UpdateTabs then FCFDock_UpdateTabs(dock,true)end
    C.SyncTabLayers(dock,true);C.Queue()
   end)
  end
 end
 local button=dock.overflowButton
 if button then
  local br=C.Remember(button)
  if br.overflowWidth==nil then br.overflowWidth=button.width or button:GetWidth()end
  br.placed=true;button.width=24;button:SetSize(24,27)
  button:ClearAllPoints();button:SetPoint('BOTTOMRIGHT',dock,'BOTTOMRIGHT',-1,0)
  if not br.chrome then br.chrome=C.overflowChrome end
  if not br.chrome then
   br.chrome=CreateFrame('Frame',nil,button);br.chrome:SetAllPoints();br.chrome:SetFrameLevel(button:GetFrameLevel()+2);br.chrome:EnableMouse(false)
   local bg=br.chrome:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.13,.18,.15,1);C.Border(br.chrome,1)
   local label=br.chrome:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');label:SetAllPoints();label:SetText('v');label:SetTextColor(.78,.81,.73,1)
   C.overflowChrome=br.chrome
  end
  br.chrome:Show();C.NearTooltip(button)
  local viewport=dock.scrollFrame
  if viewport and button:IsShown()then
   local vr=C.Remember(viewport);vr.placed=true
   viewport:SetPoint('BOTTOMRIGHT',button,'BOTTOMLEFT',0,-5)
  end
 end
end

function C.AlignInputHeader(edit)
 if not edit.GetTextInsets or not edit.SetTextInsets then return end
 local r=C.Remember(edit)
 if not r.inputInsets then r.inputInsets={edit:GetTextInsets()}end
 C.inputHeaderHooks=C.inputHeaderHooks or setmetatable({},{__mode='k'})
 if not C.inputHeaderHooks[edit]then
  C.inputHeaderHooks[edit]=true
  hooksecurefunc(edit,'SetTextInsets',function(self,l,right,top,bottom)
   if not C.Enabled()or C.alignInsetBusy then return end
   C.alignInsetBusy=true;self:SetTextInsets(math.max(2,l-13),right,top,bottom);C.alignInsetBusy=false
  end)
 end
 local header=edit.header or _G[edit:GetName()..'Header']
 if header then
  local hr=C.Remember(header);hr.placed=true
  header:ClearAllPoints();header:SetPoint('LEFT',edit,'LEFT',2,0)
 end
 if edit.UpdateHeader then edit:UpdateHeader()end
end

-- Derive limits from visible native controls, not a guessed fixed height.
function C.ControlHeight(frame)
 local bar=frame and frame.buttonFrame;if not bar then return 0 end
 local total=0
 for _,b in ipairs({bar:GetChildren()})do
  if b.layoutIndex and b:IsObjectType('Button')and b:IsShown()then
   total=total+b:GetHeight()+math.max(0,b.bottomPadding or 0)+math.max(0,b.topPadding or 0)+2
  end
 end
 return total
end
function C.EnsurePanelBounds(owner,active,footer)
 local scale=owner:GetEffectiveScale()/UIParent:GetEffectiveScale()
 local minH=math.max(120,C.ControlHeight(owner)+12,C.ControlHeight(active)+12)
 local maxH=math.max(minH,(UIParent:GetHeight()-footer-70)/scale)
 local maxW=math.max(300,(UIParent:GetWidth()-52)/scale)
 local w=math.max(300,math.min(maxW,owner:GetWidth()))
 local h=math.max(minH,math.min(maxH,owner:GetHeight()))
 if math.abs(w-owner:GetWidth())>.1 or math.abs(h-owner:GetHeight())>.1 then
  local r=C.Remember(owner);if not r.limitSize then r.limitSize={owner:GetWidth(),owner:GetHeight()}end
  owner:SetSize(w,h)
 end
end
