-- Transient, unprotected examples for KerimAnka edit mode. Never saved as data.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local P={};K.LayoutPreviews=P
local running,enabled=false,true
local generation,revision=0,0
local ghosts,masked,natives,modes={},{},{},{}
local pending,queue,pumping={},{},false
local focus,focusID
local function DB()return ForeverLeatherUnitsAPI and ForeverLeatherUnitsAPI.GetSettings()end
local function Font(parent,size)
 local f=parent:CreateFontString(nil,'OVERLAY');f:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',size,'OUTLINE');return f
end
local function Mask(f)
 if f and f.SetAlpha and masked[f]==nil then masked[f]=f:GetAlpha();f:SetAlpha(0)end
end
local function Native(api)
 if api and api.SetLayoutPreview and not natives[api]then natives[api]=true;api.SetLayoutPreview(true)end
end
local function Mode(api,value)
 if api and api.SetPreview and not modes[api]then modes[api]={value=api.GetPreview and api.GetPreview()};api.SetPreview(value)end
end
local function Clear()
 generation=generation+1;pending={};queue={};pumping=false
 for f,alpha in pairs(masked)do f:SetAlpha(alpha)end;masked={}
 for _,g in pairs(ghosts)do g:Hide()end
 for api in pairs(natives)do api.SetLayoutPreview(false)end;natives={}
 for api,old in pairs(modes)do api.SetPreview(old.value)end;modes={}
end
function P.Start()Clear();running=true;enabled=true;revision=revision+1;focus=nil end
function P.Stop()running=false;Clear();focus=nil end
function P.Toggle()enabled=not enabled;Clear();revision=revision+1 end
function P.Rebuild()Clear();revision=revision+1 end
function P.Invalidate()revision=revision+1 end
function P.Focus(id,key)if focusID==id and focus==key then return end;focusID=id;focus=key;P.Invalidate()end
function P.Enabled()return running and enabled end
local function Follow(g,a)
 local x,y=K.LayoutAdapters.Center(a.frame);if not x or not y then g:Hide();return end
 local ratio=a.frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
 g:SetScale(ratio);g:ClearAllPoints();g:SetPoint('CENTER',UIParent,'BOTTOMLEFT',x/ratio,y/ratio)
 g:SetSize(a.frame:GetWidth(),a.frame:GetHeight());g:Show()
end
local function Compact(parent)
 local f=CreateFrame('Frame',nil,parent,'BackdropTemplate')
 f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});f:SetBackdropColor(.075,.055,.035,.97);f:SetBackdropBorderColor(.48,.34,.19,1)
 f.health=CreateFrame('StatusBar',nil,f);f.health:SetPoint('BOTTOMLEFT',7,6);f.health:SetPoint('BOTTOMRIGHT',-7,6);f.health:SetHeight(12);f.health:SetStatusBarTexture('Interface\\AddOns\\KerimAnkaUI_UnitFrames\\BarFill.tga');f.health:SetMinMaxValues(0,1);f.health:SetValue(.72);f.health:SetStatusBarColor(.1,.85,.05)
 f.name=Font(f,13);f.name:SetPoint('TOP',2,-4);f.name:SetTextColor(1,.89,.58)
 f.hp=Font(f.health,10);f.hp:SetPoint('CENTER');return f
end
local function Cast(parent)
 local f=CreateFrame('StatusBar',nil,parent,'BackdropTemplate');f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});f:SetBackdropColor(.025,.025,.02,1);f:SetBackdropBorderColor(.55,.47,.3,1)
 f:SetStatusBarTexture('Interface\\AddOns\\KerimAnkaUI_UnitFrames\\BarFill.tga');f:SetStatusBarColor(.65,.48,.2);f:SetMinMaxValues(0,1);f:SetValue(.57)
 f.text=Font(f,12);f.text:SetPoint('LEFT',5,0)
 f.icon=f:CreateTexture(nil,'ARTWORK');f.icon:SetTexture('Interface\\Icons\\Spell_Holy_FlashHeal');f.icon:SetPoint('RIGHT',f,'LEFT',-3,0);return f
end
local function Auras(parent)
 local f=CreateFrame('Frame',nil,parent);f.icons={}
 for i=1,4 do
  local icon=CreateFrame('Frame',nil,f,'BackdropTemplate');icon:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});icon:SetBackdropColor(.025,.025,.02,1)
  icon.texture=icon:CreateTexture(nil,'ARTWORK');icon.texture:SetPoint('TOPLEFT',1,-1);icon.texture:SetPoint('BOTTOMRIGHT',-1,1);icon.texture:SetTexCoord(.07,.93,.07,.93)
  icon.count=Font(icon,10);icon.count:SetPoint('BOTTOMRIGHT',-1,1);f.icons[i]=icon
 end
 return f
end
local function Paint(a,parent)
 if not running or not enabled then return end
 local d=DB();if not d then return end
 local id=a.id;local unit=id:match('^unit%.(.+)');local g=ghosts[id]
 if not g then
  if unit=='targettarget'then g=Compact(parent)
  elseif unit then
   if not K.UnitLayoutPreview then return end
   g=K.UnitLayoutPreview.Create(parent)
  elseif id=='targetCast'then g=Cast(parent)
  elseif id:match('^aura%.')then g=Auras(parent)
  else return end
  g:SetFrameLevel(2);g:EnableMouse(false);ghosts[id]=g
 end
 if unit=='targettarget'then
  if K.ApplyUnitNameFont then K.ApplyUnitNameFont(g.name,13*(d.totNameScale or d.textScale or 1),false)end
  g.name:SetText(K.L('leToT'));g.hp:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',10*d.healthTextScale,'OUTLINE');g.hp:SetText('720 / 1000')
 elseif unit then K.UnitLayoutPreview.Paint(g,unit,a.frame,focus)
 elseif id=='targetCast'then
  g.text:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',d.castFontSize,'OUTLINE');g.text:SetText(K.L('upCast')..'  1.5s');g.text:SetWidth(d.castWidth-30);g.icon:SetSize(d.castHeight,d.castHeight);g.icon:SetShown(d.castIcon)
 else
  local owner,kind=id:match('^aura%.(%a+)(Buff)$');if not owner then owner,kind=id:match('^aura%.(%a+)(Debuff)$')end
  if not owner then return end
  local size,gap=d[owner..'AuraSize'],d[owner..'AuraGap'];local count=math.min(4,d[owner..'AuraMax']);local columns=d[owner..'AuraColumns']
  local textures=kind=='Buff'and{'Spell_Holy_WordFortitude','Spell_Nature_Rejuvenation','Ability_Hunter_AspectOfTheHawk','Spell_Nature_Thorns'}or{'Spell_Shadow_ShadowWordPain','Spell_Nature_CorrosiveBreath','Ability_Hunter_SniperShot','Spell_Fire_FlameBolt'}
  for i,icon in ipairs(g.icons)do
   icon:SetShown(i<=count);icon:SetSize(size,size);icon:ClearAllPoints();icon:SetPoint('TOPLEFT',g,'TOPLEFT',((i-1)%columns)*(size+gap),-math.floor((i-1)/columns)*(size+gap));icon.texture:SetTexture('Interface\\Icons\\'..textures[i]);icon.count:SetText(d.auraStacks and i==3 and '3'or'');icon:SetBackdropBorderColor(kind=='Buff'and .35 or .75,kind=='Buff'and .6 or .25,.2,1)
  end
 end
 g.previewRevision=revision;Follow(g,a);Mask(a.frame)
end
local function Enqueue(a,parent)
 if pending[a.id]then return end
 pending[a.id]=true;queue[#queue+1]={a=a,parent=parent}
 if pumping then return end;pumping=true
 local token=generation
 local function Step()
  if token~=generation or not running or not enabled then return end
  if InCombatLockdown()then P.Stop();return end
  local task=table.remove(queue,1)
  if task then pending[task.a.id]=nil;Paint(task.a,task.parent)end
  if #queue>0 then C_Timer.After(0,Step)else pumping=false end
 end
 C_Timer.After(0,Step)
end
function P.Update(entries,parent)
 if not running or not enabled then return end
 Native(K.ClassicCastBar);Native(K.ClassicSwingTimer);Native(ForeverThreatAPI)
 Mode(ForeverHunterRangeAPI,'ranged');Mode(HunterAspectAlertAPI,'cheetah')
 for _,a in ipairs(entries)do
  if not a.disabled and(a.id:match('^unit%.')or a.id=='targetCast'or a.id:match('^aura%.'))then
   local g=ghosts[a.id]
   if not g or g.previewRevision~=revision then Enqueue(a,parent)else Follow(g,a)end
  end
 end
end
