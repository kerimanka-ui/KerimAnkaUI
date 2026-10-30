if select(2,...).blocked then return end
if WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,N=...;local K=N.host;local C=K.Chat
local FRAME='Interface\\AddOns\\KerimAnkaUI_Chat\\ClassicEra\\Chat\\Media\\ControlAtlas.tga'
-- Steel band with a narrow bronze bevel; crop one material patch for the edges.
-- Never squeeze the full 1000px strip into a tiny button (mipmap band bleed).
local u0,u1,v0,v1=.009019166,.990417136,.277339346,.492671928
local cu,cv=(v1-v0)*.08,(v1-v0)*.16
local mid,half=(u0+u1)/2,(v1-v0)*.125
local slices={{'TOPLEFT',u0,u0+cu,v0,v0+cv},{'TOPRIGHT',u1-cu,u1,v0,v0+cv},
 {'BOTTOMLEFT',u0,u0+cu,v1-cv,v1},{'BOTTOMRIGHT',u1-cu,u1,v1-cv,v1},
 {'TOP',mid-half,mid+half,v0,v0+cv},{'BOTTOM',mid-half,mid+half,v1-cv,v1},
 {'LEFT',u0,u0+cu,v0+cv,v1-cv},{'RIGHT',u1-cu,u1,v0+cv,v1-cv}}
local function Texture(parent,layer)
 local t=parent:CreateTexture(nil,layer or 'BACKGROUND')
 if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false);t:SetTexelSnappingBias(0)end
 return t
end
function C.Border(parent,edge)
 for _,point in ipairs({'TOP','BOTTOM','LEFT','RIGHT'})do
  local t=Texture(parent,'BORDER');t:SetColorTexture(.24,.28,.25,1)
  if point=='TOP'or point=='BOTTOM'then t:SetPoint(point..'LEFT');t:SetPoint(point..'RIGHT');t:SetHeight(1)
  else t:SetPoint('TOP'..point);t:SetPoint('BOTTOM'..point);t:SetWidth(1)end
 end
end
local function Fill(parent,r,g,b,a)
 local t=Texture(parent);t:SetAllPoints();t:SetColorTexture(r,g,b,a);return t
end
function C.NewShell()
 local f=CreateFrame('Frame',nil,UIParent);f:SetFrameStrata('BACKGROUND');f:SetFrameLevel(1);f:EnableMouse(false)
 f.tabBand=Texture(f,'BACKGROUND');f.tabBand:SetColorTexture(.045,.06,.055,.96)
 f.material=Fill(f,.045,.060,.055,.94)
 local grain=Texture(f);grain:SetAllPoints();grain:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Background')
 grain:Hide()
 f.bronze=C.BronzeFrame(f)
 f.rail=Texture(f,'BORDER');f.rail:SetWidth(1);f.rail:SetColorTexture(.24,.28,.25,1)
 f.divider=Texture(f,'BORDER');f.divider:SetHeight(1);f.divider:SetColorTexture(.24,.28,.25,1)
 f.footer=Texture(f);f.footer:SetColorTexture(.075,.10,.085,1)
 f.footerGrain=Texture(f);f.footerGrain:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Background');f.footerGrain:SetVertexColor(0,0,0,0)
 f.input=CreateFrame('Frame',nil,f);f.input:EnableMouse(false);Fill(f.input,.012,.012,.009,.88);local rule=Texture(f.input,'BORDER');rule:SetColorTexture(.24,.28,.25,1);rule:SetPoint('TOPLEFT');rule:SetPoint('TOPRIGHT');rule:SetHeight(1)
 f.inputHint=f.input:CreateFontString(nil,'OVERLAY','ChatFontNormal')
 f.inputHint:SetPoint('LEFT',12,0);f.inputHint:SetTextColor(.46,.43,.36,1)
 f.inputHint:SetText(ENTER_MESSAGE or 'Press Enter to chat')
 return f
end
function C.PlaceShell(f,g)
 f:ClearAllPoints();f:SetPoint('BOTTOMLEFT',g.anchor or UIParent,'BOTTOMLEFT',g.x-(g.anchor and g.anchorX or 0),g.y-(g.anchor and g.anchorY or 0));f:SetSize(g.width,g.height)
 C.PlaceBronzeFrame(f.bronze,g.width,g.height)
 f.tabBand:ClearAllPoints();f.tabBand:SetPoint('BOTTOMLEFT',f,'TOPLEFT',0,0);f.tabBand:SetSize(g.width,30)
 f.rail:SetShown(not g.horizontal);f.rail:ClearAllPoints();f.rail:SetPoint('TOPLEFT',g.railX,-6);f.rail:SetPoint('BOTTOMLEFT',g.railX,g.footer+29)
 f.divider:ClearAllPoints();f.divider:SetPoint('BOTTOMLEFT',4,g.footer);f.divider:SetPoint('BOTTOMRIGHT',-4,g.footer)
 f.divider:SetShown(g.footer>0)
 f.footer:ClearAllPoints();f.footer:SetPoint('BOTTOMLEFT',4,4);f.footer:SetPoint('BOTTOMRIGHT',-4,4);f.footer:SetHeight(math.max(1,g.footer-4));f.footer:SetShown(g.footer>0)
 f.footerGrain:SetAllPoints(f.footer);f.footerGrain:SetShown(g.footer>0)
 f.input:ClearAllPoints();f.input:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',1,g.inputY-g.y);f.input:SetSize(g.width-2,g.inputHeight)
 -- The permanent well is decorative; the real Blizzard input is shown only when typing.
 f:Show()
end
function C.NewTabChrome(tab)
 return C.BronzeTab(tab)
end
function C.NewButtonChrome(button,outlineOnly)
 C.buttonChrome=C.buttonChrome or setmetatable({},{__mode='k'})
 if C.buttonChrome[button]then return C.buttonChrome[button]end
 local f=CreateFrame('Frame',nil,button);f:SetFrameLevel(button:GetFrameLevel()+1);f:EnableMouse(false)
 -- Border only: keep the original glyph and its normal/pushed textures visible.
 f:SetAllPoints();C.Border(f,4);C.buttonChrome[button]=f;return f
end

-- Display-only surfaces over the real buttons; no replacement click handlers.
local simpleIcons={CharacterMicroButton='Character',SpellbookMicroButton='Book',TalentMicroButton='Talents',QuestLogMicroButton='Quest',SocialsMicroButton='Social',WorldMapMicroButton='Map',MainMenuMicroButton='Menu',HelpMicroButton='Help'}
local previousButtonChrome=C.NewButtonChrome
function C.NewButtonChrome(button,outlineOnly)
 local name=button:GetName();local key=name and simpleIcons[name]
 if not key then return previousButtonChrome(button,outlineOnly)end
 C.simpleButtons=C.simpleButtons or setmetatable({},{__mode='k'})
 C.HideMicroArt(button)
 if C.simpleButtons[button]then return C.simpleButtons[button]end
 local f=CreateFrame('Frame',nil,button);f:SetFrameLevel(button:GetFrameLevel()+2);f:EnableMouse(false);f:SetAllPoints()
 local fill=f:CreateTexture(nil,'BACKGROUND');fill:SetAllPoints();fill:SetColorTexture(.13,.18,.15,1);C.Border(f,1)
 local icon=f:CreateTexture(nil,'OVERLAY');icon:SetTexture('Interface\\AddOns\\KerimAnkaUI_Chat\\ClassicEra\\Chat\\Media\\Simple'..key..'.tga');icon:SetSize(20,20);icon:SetPoint('CENTER');icon:SetVertexColor(.78,.81,.73,1)
 C.HookScript(button,'OnEnter',function()fill:SetColorTexture(.22,.28,.22,1);icon:SetVertexColor(.91,.84,.66,1)end)
 C.HookScript(button,'OnLeave',function()fill:SetColorTexture(.13,.18,.15,1);icon:SetVertexColor(.78,.81,.73,1)end)
 C.simpleButtons[button]=f;return f
end

-- Native buttons retain their actions, states and text. Crop only old ornamental margins.
function C.StyleToolButton(button)
 local r=C.Remember(button)
 if not r.toolFill then
  C.toolFills=C.toolFills or setmetatable({},{__mode='k'})
  r.toolFill=C.toolFills[button]
  if not r.toolFill then
   r.toolFill=button:CreateTexture(nil,'BACKGROUND');r.toolFill:SetAllPoints();r.toolFill:SetColorTexture(.13,.18,.15,1)
   C.toolFills[button]=r.toolFill
   local fill=r.toolFill
   button:HookScript('OnEnter',function()if C.Enabled()then fill:SetColorTexture(.22,.28,.22,1)end end)
   button:HookScript('OnLeave',function()fill:SetColorTexture(.13,.18,.15,1)end)
  end
  for _,method in ipairs({'GetNormalTexture','GetPushedTexture','GetDisabledTexture'})do
   local t=button[method]and button[method](button)
   if t then
    local tr=C.Remember(t);tr.toolUV=t.GetTexCoord and {t:GetTexCoord()};tr.placed=true
    t:ClearAllPoints();t:SetPoint('CENTER',button,'CENTER',0,0);t:SetSize(18,18)
    t:SetTexCoord(.18,.82,.18,.82)
   end
  end
 end
 r.toolFill:Show()
end

local OldToolStyle=C.StyleToolButton
function C.StyleToolButton(button)
 local name=button:GetName()or ''
 local key=name=='FriendsMicroButton'and 'Character'or name=='ChatFrameChannelButton'and 'Speaker'or name:find('MenuButton')and 'Social'
  or name:find('BottomButton')and 'Bottom'or name:find('DownButton')and 'Down'or name:find('UpButton')and 'Up'
 if not key then return OldToolStyle(button)end
 local r=C.Remember(button)
 C.toolSurfaces=C.toolSurfaces or setmetatable({},{__mode='k'})
 local f=C.toolSurfaces[button]
 if not f then
  f=CreateFrame('Frame',nil,button);f:SetAllPoints();f:EnableMouse(false);f:SetFrameLevel(button:GetFrameLevel()+2)
  local bg=f:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.13,.18,.15,1);C.Border(f,1)
  local icon=f:CreateTexture(nil,'ARTWORK');icon:SetPoint('CENTER');icon:SetSize(18,18)
  icon:SetTexture('Interface\\AddOns\\KerimAnkaUI_Chat\\ClassicEra\\Chat\\Media\\Simple'..key..'.tga');icon:SetVertexColor(.78,.81,.73,1)
  f.glyph=icon
  local count=_G[name..'Count']
  if count then
   icon:ClearAllPoints();icon:SetPoint('TOP',f,'TOP',0,-2);icon:SetSize(14,14)
   local label=f:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');label:SetPoint('BOTTOM',f,'BOTTOM',0,2)
   f.countLabel=label
   label:SetTextColor(.79,.83,.76,1)
   if label.SetShadowColor then label:SetShadowColor(0,0,0,.8);label:SetShadowOffset(1,-1)end
   local function UpdateCount()label:SetText(count:GetText())end
   hooksecurefunc(count,'SetText',UpdateCount)
   if count.SetFormattedText then hooksecurefunc(count,'SetFormattedText',UpdateCount)end
   UpdateCount()
  end
  button:HookScript('OnEnter',function()bg:SetColorTexture(.22,.28,.22,1)end)
  button:HookScript('OnLeave',function()bg:SetColorTexture(.13,.18,.15,1)end)
  C.toolSurfaces[button]=f
 end
 r.toolFill=f;f:Show()
end

function C.HideMicroArt(button)
 -- Native artwork can extend beyond the modern surface when the button shrinks.
 local textures={}
 if button.GetRegions then for _,region in ipairs({button:GetRegions()})do if region:IsObjectType('Texture')then textures[#textures+1]=region end end end
 for _,method in ipairs({'GetNormalTexture','GetPushedTexture','GetDisabledTexture','GetHighlightTexture'})do
  local texture=button[method]and button[method](button);if texture then textures[#textures+1]=texture end
 end
 for _,texture in pairs({button.Portrait,button.portrait,_G[(button:GetName()or '')..'Portrait']})do textures[#textures+1]=texture end
 for _,texture in ipairs(textures)do
  local r=C.Remember(texture);r.microArt=true
  C.microArtHooks=C.microArtHooks or setmetatable({},{__mode='k'})
  if not C.microArtHooks[texture]then C.microArtHooks[texture]=true;hooksecurefunc(texture,'SetAlpha',function(self,a)
   local record=C.records[self];if a~=0 and C.Enabled()and record and record.microArt then self:SetAlpha(0)end
  end)end
  texture:SetAlpha(0)
 end
end
