local _,K=...
local PATH="Interface\\AddOns\\KerimAnkaUI_UnitFrames\\"
local font="Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-R.ttf"
local unitFont=STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local state={unit="player",kind="Buffs",examples=true,icons={}}
local panel,stage,model,drag
local unitLabels={player="upPlayer",target="upTarget",pet="upPet"}
local function Settings() return ForeverLeatherUnitsAPI and ForeverLeatherUnitsAPI.GetSettings() end
local function FinishDrag()
 if not drag then return end
 local button=drag.button
 button:SetScript("OnUpdate",nil); drag=nil
 C_Timer.After(0,function() button.previewDragged=nil end)
 local api=ForeverLeatherUnitsAPI
 if api then api.Apply() end
 C_Timer.After(0,function() if K.window:IsShown() and panel:IsShown() then K.Render() end end)
end
local function Editable(button,xKey,yKey,sizeKey,low,high,invertX,coordinateFactor,step)
 button:EnableMouse(true); button:RegisterForDrag("LeftButton"); button:EnableMouseWheel(true)
 button.xKey,button.yKey,button.sizeKey=xKey,yKey,sizeKey
 button.low,button.high,button.invertX=low,high,invertX
 button.coordinateFactor=coordinateFactor or 1
 button.optionKey=xKey or sizeKey
 button:SetScript("OnClick",function(self)
  if not self.previewDragged and K.JumpToUnitOption then K.JumpToUnitOption(self.optionKey) end
 end)
 button:SetScript("OnEnter",function(self) K.ShowTooltip(self,K.L("upControl"),K.L("upControlHelp")) end)
 button:SetScript("OnLeave",K.HideTooltip)
 button:SetScript("OnDragStart",function(self)
  if K.InCombat() then return end
  local db=Settings(); if not db or not self.xKey then return end
  local x,y=GetCursorPosition()
  self.previewDragged=true
  drag={button=self,x=x,y=y,baseX=db[self.xKey],baseY=db[self.yKey],scale=model:GetEffectiveScale()*self.coordinateFactor,modelScale=model:GetScale()}
  K.HideTooltip()
  self:SetScript("OnUpdate",function()
   if not IsMouseButtonDown("LeftButton") or InCombatLockdown() then FinishDrag(); return end
   local cx,cy=GetCursorPosition()
   local bounds=self.sizeKey=="raidMarkerSize" and {-100,100,0,50} or self.sizeKey=="pvpSize" and {-30,45,-45,45}
       or self.sizeKey=="questieIconSize" and {-80,80,-80,80} or self.sizeKey=="hunterSummonSize" and {-300,500,-250,250}
       or self.sizeKey=="happinessSize" and {-100,100,-60,60} or self.sizeKey=="castHeight" and {-400,400,-250,250} or {-300,300,-250,250}
   db[self.xKey]=math.max(bounds[1],math.min(bounds[2],math.floor(drag.baseX+(cx-drag.x)/drag.scale*(self.invertX and -1 or 1)+.5)))
   db[self.yKey]=math.max(bounds[3],math.min(bounds[4],math.floor(drag.baseY+(cy-drag.y)/drag.scale+.5)))
   K.UpdateUnitPreview()
  end)
 end)
 button:SetScript("OnDragStop",FinishDrag)
 button:SetScript("OnMouseWheel",function(self,delta)
  if K.InCombat() then return end
  local db=Settings(); if not db or not self.sizeKey then return end
  db[self.sizeKey]=math.max(self.low,math.min(self.high,math.floor(((tonumber(db[self.sizeKey]) or self.low)+delta*(step or 1))*100+.5)/100))
  ForeverLeatherUnitsAPI.Apply(); K.Render()
 end)
 button:SetScript("OnHide",function(self) if drag and drag.button==self then FinishDrag() end end)
end
local function Label(parent,size,unitName)
 local t=parent:CreateFontString(nil,"OVERLAY")
 if unitName then K.ApplyUnitNameFont(t,size,false,"Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-R.ttf") else K.ApplyTextFont(t,size,false,"OUTLINE") end
 t:SetWordWrap(false)
 return t
end
local function SampleIcon(parent,texture)
 local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
 b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
 b:SetBackdropColor(.025,.025,.02,1); b:SetBackdropBorderColor(.55,.47,.3,1)
 b.icon=b:CreateTexture(nil,"ARTWORK"); b.icon:SetPoint("TOPLEFT",1,-1); b.icon:SetPoint("BOTTOMRIGHT",-1,1)
 b.icon:SetTexture(texture); b.icon:SetTexCoord(.07,.93,.07,.93)
 b.count=Label(b,10); b.count:SetPoint("BOTTOMRIGHT",-1,1)
 return b
end
local function Build()
 panel=CreateFrame("Frame",nil,K.window,"BackdropTemplate"); K.previewPanel=panel
 panel:SetPoint("TOPLEFT",220,-201); panel:SetSize(734,202)
 panel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
 panel:SetBackdropColor(.09,.105,.095,1); panel:SetBackdropBorderColor(.30,.34,.28,1)
 panel.title=Label(panel,13); panel.title:SetPoint("TOPLEFT",10,-10)
 local visible=CreateFrame("CheckButton",nil,K.window,"UICheckButtonTemplate")
 visible:SetPoint("TOPLEFT",752,-126); K.ApplyTextFont(visible.text,11,false,""); K.previewToggle=visible
 visible:SetScript("OnClick",function(self)
  KerimAnkaUIDB.unitPreview=self:GetChecked() and true or false
  FinishDrag(); K.Render()
 end)
 panel.buttons={}
 for i,unit in ipairs({"player","target","pet"}) do
  local b=CreateFrame("Button",nil,panel,"BackdropTemplate"); b:SetPoint("TOPLEFT",124+(i-1)*92,-5); b:SetSize(86,26)
  b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
  b.label=Label(b,11); b.label:SetPoint("CENTER")
  b:SetScript("OnClick",function()
   FinishDrag(); state.unit=unit; state.kind=unit=="target" and "Debuffs" or "Buffs"; K.UpdateUnitPreview()
   if K.JumpToUnitOption then K.JumpToUnitOption(unit..state.kind) end
  end)
  b.unit=unit; panel.buttons[i]=b
 end
 panel.kinds={}
 for i,kind in ipairs({"Buffs","Debuffs"}) do
  local b=CreateFrame("Button",nil,panel,"BackdropTemplate"); b:SetPoint("TOPLEFT",406+(i-1)*85,-5); b:SetSize(81,26)
  b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
  b.label=Label(b,11); b.label:SetPoint("CENTER"); b.kind=kind
  b:SetScript("OnClick",function() state.kind=kind; K.UpdateUnitPreview(); if K.JumpToUnitOption then K.JumpToUnitOption(state.unit..kind) end end)
  panel.kinds[i]=b
 end
 local examples=CreateFrame("CheckButton",nil,panel,"UICheckButtonTemplate"); examples:SetPoint("TOPLEFT",577,-3)
 K.ApplyTextFont(examples.text,11,false,""); examples:SetScript("OnClick",function(self) state.examples=self:GetChecked() and true or false; K.UpdateUnitPreview() end)
 panel.examples=examples
 panel.note=Label(panel,10); panel.note:SetPoint("BOTTOMLEFT",9,5); panel.note:SetWidth(714); panel.note:SetJustifyH("LEFT")
 stage=CreateFrame("Frame",nil,panel); stage:SetPoint("TOPLEFT",8,-36); stage:SetSize(718,143); stage:SetClipsChildren(true)
 model=CreateFrame("Frame",nil,stage); model:SetSize(360,110)
 model.portrait=CreateFrame("Frame",nil,model)
 model.portrait.backing=model.portrait:CreateTexture(nil,"BACKGROUND")
 model.portrait.backing:SetPoint("TOPLEFT",model.portrait,"TOPLEFT",-2,2)
 model.portrait.backing:SetPoint("BOTTOMRIGHT",model.portrait,"BOTTOMRIGHT",2,-2)
 model.portrait.backing:SetColorTexture(.025,.025,.025,1)
 model.portrait.backingMask=model.portrait:CreateMaskTexture()
 model.portrait.backingMask:SetAllPoints(model.portrait.backing)
 model.portrait.backing:AddMaskTexture(model.portrait.backingMask)
 model.portrait.icon=model.portrait:CreateTexture(nil,"ARTWORK"); model.portrait.icon:SetAllPoints()
 model.portrait.mask=model.portrait:CreateMaskTexture(); model.portrait.mask:SetAllPoints(); model.portrait.icon:AddMaskTexture(model.portrait.mask)
 for _,name in ipairs({"health","power"}) do
  local bar=CreateFrame("StatusBar",nil,model); bar:SetStatusBarTexture(PATH.."BarFill.tga"); bar:SetMinMaxValues(0,1)
  local bg=bar:CreateTexture(nil,"BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(.025,.025,.02,1)
  bar:SetValue(name=="health" and .72 or .65); model[name]=bar
 end
 model.decoration=CreateFrame("Frame",nil,model); model.decoration:SetAllPoints(); model.decoration:SetFrameLevel(model:GetFrameLevel()+4)
 model.art=model.decoration:CreateTexture(nil,"ARTWORK"); model.art:SetAllPoints()
 model.name=Label(model.decoration,14,true); model.level=Label(model.decoration,14)
 model.hp=Label(model.decoration,12); model.energy=Label(model.decoration,11)
 model.hpPercent=Label(model.decoration,12); model.energyPercent=Label(model.decoration,11)
 model.rank=Label(model.decoration,12); model.rank:SetTextColor(1,.73,.25)
 for _,kind in ipairs({"raid","pvp","leader","happiness","rest"}) do
  local b=CreateFrame("Button",nil,model.decoration); b.icon=b:CreateTexture(nil,"ARTWORK"); b.icon:SetAllPoints(); model[kind]=b
 end
 model.raid.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons"); model.raid.icon:SetTexCoord(0,.25,0,.25)
 model.pvp.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance")
 model.leader.icon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
 model.rest.icon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon"); model.rest.icon:SetTexCoord(0,.5,0,.421875)
 model.happiness.icon:SetTexture(PATH.."PetHappiness.tga"); model.happiness.icon:SetTexCoord(.5,.75,0,1)
 model.auras={}
 model.auraLabel=Label(model.decoration,11)
 model.questie=CreateFrame("Button",nil,model.decoration);model.questie.icon=model.questie:CreateTexture(nil,"ARTWORK");model.questie.icon:SetAllPoints()
 model.summons={}
 for i=1,4 do
  local b=SampleIcon(model.decoration,132158)
  b.count:Hide();b.duration=Label(b,11);b.duration:SetPoint("TOP",b,"BOTTOM",0,-2);b.duration:SetText(i==1 and "7 s" or "13 s");model.summons[i]=b
 end
 local icons={"Spell_Nature_Rejuvenation","Spell_Holy_WordFortitude","Ability_Hunter_AspectOfTheHawk","Spell_Nature_Thorns","Spell_Shadow_ShadowWordPain","Ability_Rogue_DualWeild","Ability_Hunter_SniperShot","Spell_Fire_FlameBolt"}
 for i=1,4 do
  model.auras[i]=SampleIcon(model.decoration,"Interface\\Icons\\"..icons[(i-1)%#icons+1])
  local b=model.auras[i]
  b.cd=CreateFrame("Cooldown",nil,b,"CooldownFrameTemplate"); b.cd:SetAllPoints()
    b.cd:SetHideCountdownNumbers(true); b.cd.noCooldownCount=true
  local carrier=CreateFrame("Frame",nil,b); carrier:SetAllPoints(); carrier:SetFrameLevel(b.cd:GetFrameLevel()+1)
  b.count:SetParent(carrier)
 end
 model.cast=SampleIcon(model.decoration,"Interface\\Icons\\Spell_Fire_FlameBolt")
 model.cast.icon:Hide()
 model.cast.bar=CreateFrame("StatusBar",nil,model.cast); model.cast.bar:SetPoint("TOPLEFT",1,-1); model.cast.bar:SetPoint("BOTTOMRIGHT",-1,1)
 model.cast.bar:SetStatusBarTexture(PATH.."BarFill.tga"); model.cast.bar:SetStatusBarColor(.65,.48,.2,1)
 model.cast.bar:SetMinMaxValues(0,1); model.cast.bar:SetValue(.57)
 model.cast.text=Label(model.cast.bar,12); model.cast.text:SetPoint("LEFT",5,0); model.cast.text:SetWordWrap(false)
 model.cast.spell=model.cast:CreateTexture(nil,"ARTWORK"); model.cast.spell:SetTexture("Interface\\Icons\\Spell_Fire_FlameBolt"); model.cast.spell:SetPoint("RIGHT",model.cast,"LEFT",-3,0)
 model.rankHit=CreateFrame("Button",nil,model.decoration); model.rankHit:SetAllPoints(model.rank)
 model.nameHit=CreateFrame("Button",nil,model.decoration); model.nameHit:SetAllPoints(model.name)
 model.levelHit=CreateFrame("Button",nil,model.decoration); model.levelHit:SetAllPoints(model.level)
 -- Keep bar hit targets above the decorative artwork and numeric labels.
 model.healthHit=CreateFrame("Button",nil,model.decoration); model.healthHit:SetAllPoints(model.health)
 model.powerHit=CreateFrame("Button",nil,model.decoration); model.powerHit:SetAllPoints(model.power)
 panel:SetScript("OnHide",FinishDrag)
end
function K.ConfigureUnitPreview(available)
 K.unitPreviewPageAvailable=available and true or false
 if not panel and available then Build() end
 local shown=available and KerimAnkaUIDB.unitPreview~=false
 if K.previewToggle then
  K.previewToggle:SetShown(available and true or false); K.previewToggle:SetChecked(shown and true or false)
  K.previewToggle.text:SetText(K.L("upVisible"))
 end
 if panel then panel:SetShown(shown and true or false) end
 K.scroll:ClearAllPoints(); K.scroll:SetPoint("TOPLEFT",220,shown and -415 or -205)
 K.scroll:SetSize(734,math.max(140,K.window:GetHeight()-60-(shown and 415 or 205)))
 if shown then K.UpdateUnitPreview() end
end
function K.UpdateUnitPreview(changedKey)
 if not panel or not panel:IsShown() then return end
 local db=Settings(); if not db then return end
 local hunter=ForeverLeatherUnitsAPI.IsHunter()
 local warlock=ForeverLeatherUnitsAPI.IsWarlock and ForeverLeatherUnitsAPI.IsWarlock() or false
 local shaman=ForeverLeatherUnitsAPI.IsShaman and ForeverLeatherUnitsAPI.IsShaman() or false
 local mage=ForeverLeatherUnitsAPI.IsMage and ForeverLeatherUnitsAPI.IsMage() or false
 local priest=ForeverLeatherUnitsAPI.IsPriest and ForeverLeatherUnitsAPI.IsPriest() or false
 local druid=ForeverLeatherUnitsAPI.IsDruid and ForeverLeatherUnitsAPI.IsDruid() or false
 local warrior=ForeverLeatherUnitsAPI.IsWarrior and ForeverLeatherUnitsAPI.IsWarrior() or false
 local paladin=ForeverLeatherUnitsAPI.IsPaladin and ForeverLeatherUnitsAPI.IsPaladin() or false
 local styled=warlock or shaman or mage or druid or priest or paladin or warrior
 local prefix=warrior and "Warrior" or paladin and "Paladin" or druid and "Druid" or priest and "Priest" or mage and "Mage" or shaman and "Shaman" or warlock and "Warlock" or hunter and "Hunter" or ""
 local petSupported=ForeverLeatherUnitsAPI.SupportsPet and ForeverLeatherUnitsAPI.SupportsPet() or hunter or warlock
 if changedKey then
  if changedKey:match("^questie") then state.unit="target"
  elseif changedKey:match("^hunterSummon") then state.unit="player"
  elseif changedKey:match("^player") then state.unit="player"
  elseif (changedKey:match("^target") and not changedKey:match("^targettarget")) or changedKey:match("^cast") then state.unit="target"
  elseif changedKey:match("^pet") or changedKey:match("^happiness") or changedKey:match("^showPet") then state.unit="pet" end
  if changedKey:find("Debuff",1,true) then state.kind="Debuffs" elseif changedKey:find("Buff",1,true) then state.kind="Buffs" end
 end
 if state.unit=="pet" and not petSupported then state.unit="player" end
 local unit=state.unit; local mirrored=unit=="target"
 panel.title:SetText(K.L("upTitle")); panel.note:SetText(K.L("upNote")); panel.examples.text:SetText(K.L("upExamples")); panel.examples:SetChecked(state.examples)
 local function SelectStyle(b,selected)
  b:SetBackdropColor(selected and .22 or .10,selected and .29 or .12,selected and .18 or .10,1)
  b:SetBackdropBorderColor(selected and .60 or .3,selected and .73 or .34,selected and .45 or .28,1)
 end
 for i,b in ipairs(panel.buttons) do b.label:SetText(K.L(unitLabels[b.unit])); b:SetEnabled(b.unit~="pet" or petSupported); SelectStyle(b,b.unit==unit) end
 for _,b in ipairs(panel.kinds) do b.label:SetText(K.L(b.kind=="Buffs" and "upBuffs" or "upDebuffs")); SelectStyle(b,b.kind==state.kind) end
 local geometry=ForeverLeatherUnitsAPI.GetGeometry and ForeverLeatherUnitsAPI.GetGeometry() or (hunter and ForeverHunterUnitsGeometry)
 local layout=geometry and geometry.layout or {Portrait={.066914,.106414,.2579,.755102},Health={.350836,.457726,.597119,.148688},Power={.335502,.693878,.604554,.118076}}
 local petGeometry=unit=="pet" and ForeverLeatherUnitsAPI.GetPetGeometry and ForeverLeatherUnitsAPI.GetPetGeometry()
 if petGeometry then layout=petGeometry.layout end
 local W,H=360,360*(petGeometry and petGeometry.aspect or geometry and geometry.aspect or 686/2152)
 model:SetSize(W,H)
 local function Slot(widget,coords)
  local x,y,w,h=unpack(coords); if mirrored then x=1-x-w end
  widget:ClearAllPoints(); widget:SetPoint("TOPLEFT",model,"TOPLEFT",x*W,-y*H); widget:SetSize(w*W,h*H)
 end
 Slot(model.portrait,layout.Portrait); Slot(model.health,layout.Health); Slot(model.power,layout.Power)
 local portraitMaskFile=PATH..(unit=="pet" and petSupported and (prefix.."PetPortraitMask.tga") or (prefix..(mirrored and "PortraitMaskRight.tga" or "PortraitMask.tga")))
 model.portrait.mask:SetTexture(portraitMaskFile,"CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
 model.portrait.backingMask:SetTexture(portraitMaskFile,"CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
 model.portrait.icon:SetTexture("Interface\\Icons\\"..(unit=="pet" and (warlock and "Spell_Shadow_SummonImp" or "Ability_Hunter_Pet_Bear") or "Ability_Hunter_Pet_Wolf"))
 if unit=="player" then SetPortraitTexture(model.portrait.icon,"player") end
 local portraitW,portraitH=model.portrait:GetWidth(),model.portrait:GetHeight()
 if portraitW>=portraitH then
  local crop=(1-portraitH/portraitW)/2; model.portrait.icon:SetTexCoord(0,1,crop,1-crop)
 else local crop=(1-portraitW/portraitH)/2; model.portrait.icon:SetTexCoord(crop,1-crop,0,1) end
 model.art:SetTexture(PATH..((warrior or paladin) and geometry.File() or unit=="pet" and petSupported and (prefix.."PetFrame.tga") or (druid and "DruidFrame.tga" or priest and "PriestFrame.tga" or mage and "MageFrame.tga" or shaman and "ShamanFrame.tga" or warlock and "WarlockFrame.tga" or hunter and "HunterFrame.tga" or "LeatherFrame.tga")),"CLAMP","CLAMP","TRILINEAR")
 if styled then
  local uv=petGeometry and petGeometry.artUV or geometry.artUV
  model.art:SetTexCoord(mirrored and uv[2] or uv[1],mirrored and uv[1] or uv[2],uv[3],uv[4])
 else model.art:SetTexCoord(mirrored and 1 or 0,mirrored and 0 or 1,0,1) end; model.art:SetVertexColor(hunter and .82 or 1,hunter and .82 or 1,hunter and .78 or 1)
 model.health:SetStatusBarColor(.1,.85,.05,1); model.power:SetStatusBarColor(petSupported and .05 or .9,petSupported and .25 or .85,petSupported and .95 or .05,1)
 local petFactor=unit=="pet" and 1/db.petScale or 1
 local nx=geometry and geometry.name[1] or .64
 model.name:ClearAllPoints(); model.name:SetPoint("CENTER",model,"TOPLEFT",(mirrored and (geometry and 1-nx or .365) or nx)*W+2,-(geometry and geometry.name[2] or .27)*H)
 K.ApplyUnitNameFont(model.name,14*db.textScale*petFactor,false,"Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-R.ttf"); model.name:SetWidth(W*.54-4); model.name:SetText(K.L(unit=="player" and "upPlayerName" or unit=="target" and "upTargetName" or "upPetName"))
 local lx=geometry and geometry.level[1] or .108
 model.level:ClearAllPoints(); model.level:SetPoint("CENTER",model,"TOPLEFT",(mirrored and 1-lx or lx)*W,-(geometry and geometry.level[2] or .845)*H+db.levelOffsetY)
 model.level:SetJustifyH("CENTER");model.level:SetJustifyV("MIDDLE");model.level:SetFont(unitFont,14*db.levelTextScale*petFactor,"OUTLINE"); model.level:SetText(druid and "72" or priest and "72" or mage and "72" or shaman and "28" or warlock and "60" or "22")
 if styled and not model.levelBadge then
  model.levelBadge=model.decoration:CreateTexture(nil,"ARTWORK",nil,3)
  model.levelBadgeMask=model.decoration:CreateMaskTexture()
  model.levelBadgeMask:SetTexture(PATH..prefix.."LevelMask.tga","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
  model.levelBadge:AddMaskTexture(model.levelBadgeMask)
 end
 if model.levelBadge then
  model.levelBadge:SetShown(styled and unit~="pet")
  if styled then
   local size=geometry.LevelMetrics(db,unit,unitFont);local uv=geometry.levelBadgeUV
   model.level:SetWidth(size)
   model.levelBadge:ClearAllPoints();model.levelBadge:SetPoint("CENTER",model,"TOPLEFT",(mirrored and 1-lx or lx)*W,-geometry.level[2]*H)
   model.levelBadge:SetSize(size,size)
   geometry.ApplyCircle(model.levelBadge)
   model.levelBadgeMask:ClearAllPoints();model.levelBadgeMask:SetAllPoints(model.levelBadge)
  end
 end
 for _,p in ipairs({{model.hp,model.hpPercent,model.health,db.healthTextScale,12,"720","72%"},{model.energy,model.energyPercent,model.power,db.powerTextScale,11,"65","65%"}}) do
  p[1]:ClearAllPoints(); p[2]:ClearAllPoints()
  p[1]:SetFont(unitFont,p[5]*p[4]*petFactor,"OUTLINE"); p[2]:SetFont(unitFont,p[5]*p[4]*petFactor,"OUTLINE")
  p[1]:SetPoint(geometry and "RIGHT" or "CENTER",p[3],geometry and "RIGHT" or "CENTER",geometry and -4 or 0,0)
  p[2]:SetPoint("LEFT",p[3],"LEFT",4,0); p[2]:SetShown(geometry~=nil)
  p[1]:SetText(geometry and p[6] or p[6].." / 1000"); p[2]:SetText(p[7])
 end
 if styled then
  geometry.ApplyLabels({anchor=model,name=model.name,level=model.level,levelBadge=model.levelBadge,
   hpText=model.hp,powerText=model.energy,hpPercent=model.hpPercent,powerPercent=model.energyPercent},db,unit,W,H,unitFont,mirrored)
 end
 model.rank:ClearAllPoints(); model.rank:SetPoint("BOTTOM",model.portrait,"TOP",0,2); model.rank:SetFont(unitFont,12*db.classificationTextScale,"OUTLINE"); model.rank:SetText(K.L("upElite")); model.rank:SetShown(mirrored)
 model.rankHit:SetShown(mirrored); Editable(model.rankHit,nil,nil,"classificationTextScale",.8,2,false,1,.05)
 Editable(model.nameHit,nil,styled and "nameOffsetY" or nil,"textScale",.75,1.5,false,1,.05)
 model.level:SetShown(unit~="pet");model.levelHit:SetShown(unit~="pet")
 Editable(model.levelHit,nil,nil,"levelTextScale",.6,1.5,false,1,.05)
 Editable(model.healthHit,nil,nil,"healthTextScale",.75,2,false,1,.05)
 Editable(model.powerHit,nil,nil,"powerTextScale",.75,2,false,1,.05)
 local function PlaceIcon(b,size,point,relative,relPoint,x,y)
  b:SetSize(size,size); b:ClearAllPoints(); b:SetPoint(point,relative,relPoint,x,y)
 end
 PlaceIcon(model.raid,db.raidMarkerSize,"BOTTOM",model.name,"TOP",db.raidMarkerOffsetX,db.raidMarkerOffsetY)
 Editable(model.raid,"raidMarkerOffsetX","raidMarkerOffsetY","raidMarkerSize",16,48)
 PlaceIcon(model.pvp,db.pvpSize,"CENTER",model.portrait,mirrored and "TOPRIGHT" or "TOPLEFT",(mirrored and 1 or -1)*db.pvpOffsetX,db.pvpOffsetY)
 Editable(model.pvp,"pvpOffsetX","pvpOffsetY","pvpSize",14,48,not mirrored)
 PlaceIcon(model.leader,db.leaderSize,"CENTER",model.portrait,mirrored and "TOPRIGHT" or "TOPLEFT",mirrored and 1 or -1,-3)
 Editable(model.leader,nil,nil,"leaderSize",10,40)
 PlaceIcon(model.rest,db.restIconSize or 18,"CENTER",model.portrait,mirrored and "TOPLEFT" or "TOPRIGHT",0,-3)
 Editable(model.rest,nil,nil,"restIconSize",10,44)
 model.rest:SetShown(state.examples and unit=="player")
 model.raid:SetShown(state.examples); model.pvp:SetShown(state.examples); model.leader:SetShown(state.examples)
 PlaceIcon(model.happiness,db.happinessSize*petFactor,"LEFT",model,"RIGHT",db.happinessOffsetX*petFactor,db.happinessOffsetY*petFactor)
 Editable(model.happiness,"happinessOffsetX","happinessOffsetY","happinessSize",16,48,false,petFactor)
 model.happiness:SetShown(unit=="pet" and (state.examples or db.showPetHappiness))
 model.happiness:SetAlpha(db.showPetHappiness and 1 or .45)
 local minX,minY,maxX,maxY=-40,-H-20,W+50,60
 if unit=="pet" and (state.examples or db.showPetHappiness) then
  minX=math.min(minX,W+db.happinessOffsetX*petFactor)
  maxX=math.max(maxX,W+(db.happinessOffsetX+db.happinessSize)*petFactor)
  minY=math.min(minY,-H/2+(db.happinessOffsetY-db.happinessSize/2)*petFactor)
  maxY=math.max(maxY,-H/2+(db.happinessOffsetY+db.happinessSize/2)*petFactor)
 end
 local questieShown=unit=="target" and (state.examples or db.questieTargetIcon~=false)
 model.questie:SetShown(questieShown)
 if questieShown then
  local profile=Questie and Questie.db and Questie.db.profile
  local icon=profile and profile.ICON_SLAY or Questie and Questie.icons and Questie.icons.slay or "Interface\\Icons\\INV_Sword_04"
  model.questie.icon:SetTexture(icon)
  local size,x,y=db.questieIconSize or 26,db.questieIconX or -4,db.questieIconY or 0
  PlaceIcon(model.questie,size,"CENTER",model.portrait,"TOPRIGHT",x,y)
  model.questie:SetAlpha(db.questieTargetIcon~=false and 1 or .45)
  Editable(model.questie,"questieIconX","questieIconY","questieIconSize",12,48)
  local px=(1-layout.Portrait[1])*W+x;local py=-layout.Portrait[2]*H+y
  minX=math.min(minX,px-size/2);maxX=math.max(maxX,px+size/2);minY=math.min(minY,py-size/2);maxY=math.max(maxY,py+size/2)
 end
 local summonsShown=(hunter or shaman) and unit=="player" and (state.examples or db.hunterSummons~=false)
 for i,b in ipairs(model.summons) do
  local visible=summonsShown and (shaman or i<=2)
  b:SetShown(visible)
  if visible then
   local icons={"Spell_Nature_StrengthOfEarthTotem02","Spell_Fire_SearingTotem","Spell_Nature_HealingStreamTotem","Spell_Nature_Windfury"}
   b.icon:SetTexture(shaman and ("Interface\\Icons\\"..icons[i]) or 132158)
   b.duration:SetText(shaman and (i==1 and "45 s" or "2 m") or (i==1 and "7 s" or "13 s"))
   local size,gap=db.hunterSummonSize or 26,db.hunterSummonGap or 6
   local x,y=(db.hunterSummonX or 250)+(i-1)*(size+gap),db.hunterSummonY or -8
   b:SetSize(size,size);b:ClearAllPoints();b:SetPoint("TOPLEFT",model,"BOTTOMLEFT",x,y)
   b:SetAlpha(db.hunterSummons~=false and 1 or .45)
   K.ApplyTextFont(b.duration,math.max(10,math.floor(size*.4)),false,"OUTLINE")
   Editable(b,"hunterSummonX","hunterSummonY","hunterSummonSize",16,48)
   minX=math.min(minX,x);maxX=math.max(maxX,x+size);minY=math.min(minY,-H+y-size-18);maxY=math.max(maxY,-H+y)
  end
 end
 local size,gap=db[unit.."AuraSize"],db[unit.."AuraGap"]
 local count=math.min(4,db[unit.."AuraColumns"],db[unit.."AuraMax"])
 local kind=state.kind=="Buffs" and "Buff" or "Debuff"
 local shown=state.examples or db[unit..state.kind]
 local below=db[unit.."AuraBelow"]
 local xKey,yKey=unit..kind.."X",unit..kind.."Y"
 for i,b in ipairs(model.auras) do
  b:SetShown(shown and i<=count)
  if shown and i<=count then
   local x=(db[xKey] or db[unit.."AuraX"])+(i-1)*(size+gap)
   local y=db[yKey] or db[unit.."AuraY"]
   local samples=kind=="Buff" and {"Spell_Holy_WordFortitude","Spell_Nature_Rejuvenation","Ability_Hunter_AspectOfTheHawk","Spell_Nature_Thorns"}
       or {"Spell_Shadow_ShadowWordPain","Spell_Nature_CorrosiveBreath","Ability_Hunter_SniperShot","Spell_Fire_FlameBolt"}
   b.icon:SetTexture("Interface\\Icons\\"..samples[i])
   b:SetSize(size,size); b:ClearAllPoints()
   b:SetPoint(below and "TOPLEFT" or "BOTTOMLEFT",model,below and "BOTTOMLEFT" or "TOPLEFT",x,y)
   b:SetBackdropBorderColor(kind=="Buff" and .35 or .75,kind=="Buff" and .6 or .25,.2,1)
   b.count:SetText(db.auraStacks and i==3 and "3" or "")
   b.cd:SetShown(db.auraCooldown); if db.auraCooldown then b.cd:SetCooldown(GetTime()-4,12) end
   b:SetAlpha(db[unit..state.kind] and 1 or .45)
   Editable(b,xKey,yKey,unit.."AuraSize",12,48)
   local bottom=below and (-H+y-size) or y
   minX=math.min(minX,x); maxX=math.max(maxX,x+size)
   minY=math.min(minY,bottom-18); maxY=math.max(maxY,bottom+size+18)
  end
 end
 model.auraLabel:SetShown(shown)
 if shown then
  model.auraLabel:ClearAllPoints()
  model.auraLabel:SetPoint(below and "TOPLEFT" or "BOTTOMLEFT",model.auras[1],below and "BOTTOMLEFT" or "TOPLEFT",0,below and -3 or 3)
  model.auraLabel:SetText(K.L(state.kind=="Buffs" and "upBuffs" or "upDebuffs").." · 1")
 end
 local castShown=unit=="target" and (state.examples or db.targetCastEnabled)
 model.cast:SetShown(castShown)
 if castShown then
  model.cast:SetSize(db.castWidth,db.castHeight); model.cast:ClearAllPoints(); model.cast:SetPoint("TOP",model,"BOTTOM",db.castX,db.castY)
  K.ApplyTextFont(model.cast.text,db.castFontSize,false,"OUTLINE"); model.cast.text:SetText(K.L("upCast")); model.cast.text:SetWidth(db.castWidth-30)
  model.cast.spell:SetSize(db.castHeight,db.castHeight); model.cast.spell:SetShown(db.castIcon)
  model.cast:SetAlpha(db.targetCastEnabled and 1 or .45)
  Editable(model.cast,"castX","castY","castHeight",12,40)
  minX=math.min(minX,W/2+db.castX-db.castWidth/2-db.castHeight-3); maxX=math.max(maxX,W/2+db.castX+db.castWidth/2)
  minY=math.min(minY,-H+db.castY-db.castHeight)
 end
 local unitScale=db.scale*(unit=="pet" and db.petScale or 1)
 local fit=math.min(1,(stage:GetWidth()-20)/((maxX-minX)*unitScale),(stage:GetHeight()-10)/((maxY-minY)*unitScale))
 local scale=unitScale*fit; if drag then scale=drag.modelScale end
 model:SetScale(scale)
 if not drag then
  model:ClearAllPoints()
  model:SetPoint("TOPLEFT",stage,"CENTER",-(minX+maxX)/2,-(minY+maxY)/2)
 end
end
