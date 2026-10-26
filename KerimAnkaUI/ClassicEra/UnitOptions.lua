-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local fields={
 {[1]="section",[2]="ufGeneral"},
 {[1]="enabled",[2]="",[3]="",[4]=""},
 {[1]="hideNative",[2]="",[3]="",[4]=""},
 {[1]="locked",[2]="",[3]="",[4]=""},
 {[1]="scale",[2]="",[3]="",[4]="",[5]=0.45,[6]=1.6,[7]=0.05},
 {[1]="textScale",[2]="",[3]="",[4]="",[5]=0.75,[6]=1.5,[7]=0.05},
 {[1]="nameOffsetY",[5]=-8,[6]=8,[7]=1,[8]="warlock"},
 {[1]="petTextScale",[5]=.7,[6]=1.3,[7]=.05,[8]="warlock"},
 {[1]="healthTextScale",[2]="",[3]="",[4]="",[5]=0.75,[6]=2,[7]=0.05},
 {[1]="powerTextScale",[2]="",[3]="",[4]="",[5]=0.75,[6]=2,[7]=0.05},
 {[1]="levelTextScale",[2]="",[3]="",[4]="",[5]=0.6,[6]=1.5,[7]=0.05},
 {[1]="levelOffsetY",[2]="",[3]="",[4]="",[5]=-10,[6]=12,[7]=1,[8]="notWarlock"},
 {[1]="classificationTextScale",[2]="",[3]="",[4]="",[5]=0.8,[6]=2,[7]=0.05},
 {[1]="section",[2]="ufPortraitCombat"},
 {[1]="portraitCombatPlayer",[2]="",[3]="",[4]=""},
 {[1]="portraitCombatPet",[2]="",[3]="",[4]="",[8]="pet"},
 {[1]="portraitCombatSize",[2]="",[3]="",[4]="",[5]=12,[6]=40,[7]=1},
 {[1]="section",[2]="ufQuestie"},
 {[1]="questieTargetIcon",[2]="",[3]="",[4]=""},
 {[1]="questieIconSize",[2]="",[3]="",[4]="",[5]=12,[6]=48,[7]=1},
 {[1]="questieIconX",[2]="",[3]="",[4]="",[5]=-80,[6]=80,[7]=1},
 {[1]="questieIconY",[2]="",[3]="",[4]="",[5]=-80,[6]=80,[7]=1},
 {[1]="section",[2]="ufHunterSummons"},
 {[1]="hunterSummons",[2]="",[3]="",[4]="",[8]="summons"},
 {[1]="hunterSummonSize",[2]="",[3]="",[4]="",[5]=16,[6]=48,[7]=1,[8]="summons"},
 {[1]="hunterSummonGap",[2]="",[3]="",[4]="",[5]=0,[6]=20,[7]=1,[8]="summons"},
 {[1]="hunterSummonX",[2]="",[3]="",[4]="",[5]=-300,[6]=500,[7]=1,[8]="summons"},
 {[1]="hunterSummonY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=1,[8]="summons"},
 {[1]="section",[2]="ufPositions"},
 {[1]="player.x",[2]="",[3]="",[4]="",[5]=-2000,[6]=2000,[7]=5},
 {[1]="player.y",[2]="",[3]="",[4]="",[5]=0,[6]=1800,[7]=5},
 {[1]="target.x",[2]="",[3]="",[4]="",[5]=-2000,[6]=2000,[7]=5},
 {[1]="target.y",[2]="",[3]="",[4]="",[5]=0,[6]=1800,[7]=5},
 {[1]="showToT",[2]="",[3]="",[4]=""},
 {[1]="totScale",[2]="",[3]="",[4]="",[5]=0.65,[6]=1.4,[7]=0.05},
 {[1]="totNameScale",[5]=.3,[6]=4,[7]=.05},
 {[1]="targettarget.x",[2]="",[3]="",[4]="",[5]=-2000,[6]=2000,[7]=5},
 {[1]="targettarget.y",[2]="",[3]="",[4]="",[5]=0,[6]=1800,[7]=5},
 {[1]="showCombo",[2]="",[3]="",[4]="",[8]="rogue"},
 {[1]="showPet",[2]="",[3]="",[4]="",[8]="pet"},
 {[1]="petScale",[2]="",[3]="",[4]="",[5]=0.45,[6]=1.1,[7]=0.05,[8]="pet"},
 {[1]="pet.x",[2]="",[3]="",[4]="",[5]=-2000,[6]=2000,[7]=5,[8]="pet"},
 {[1]="pet.y",[2]="",[3]="",[4]="",[5]=0,[6]=1800,[7]=5,[8]="pet"},
 {[1]="section",[2]="ufIndicators"},
 {[1]="pvpSize",[2]="",[3]="",[4]="",[5]=14,[6]=48,[7]=1},
 {[1]="pvpOffsetX",[2]="",[3]="",[4]="",[5]=-30,[6]=45,[7]=1},
 {[1]="pvpOffsetY",[2]="",[3]="",[4]="",[5]=-45,[6]=45,[7]=1},
 {[1]="leaderSize",[2]="",[3]="",[4]="",[5]=10,[6]=40,[7]=1},
 {[1]="restIconSize",[2]="",[3]="",[4]="",[5]=10,[6]=44,[7]=1},
 {[1]="combatIconSize",[2]="",[3]="",[4]="",[5]=10,[6]=44,[7]=1},
 {[1]="raidMarkerSize",[2]="",[3]="",[4]="",[5]=16,[6]=48,[7]=1},
 {[1]="raidMarkerOffsetX",[2]="",[3]="",[4]="",[5]=-100,[6]=100,[7]=1},
 {[1]="raidMarkerOffsetY",[2]="",[3]="",[4]="",[5]=0,[6]=50,[7]=1},
 {[1]="showPetHappiness",[2]="",[3]="",[4]="",[8]="hunter"},
 {[1]="happinessSize",[2]="",[3]="",[4]="",[5]=16,[6]=48,[7]=1,[8]="hunter"},
 {[1]="happinessOffsetX",[2]="",[3]="",[4]="",[5]=-100,[6]=100,[7]=1,[8]="hunter"},
 {[1]="happinessOffsetY",[2]="",[3]="",[4]="",[5]=-60,[6]=60,[7]=1,[8]="hunter"},
 {[1]="section",[2]="ufAuras"},
 {[1]="auraCooldown",[2]="",[3]="",[4]=""},
 {[1]="auraStacks",[2]="",[3]="",[4]=""},
 {[1]="playerBuffs",[2]="",[3]="",[4]=""},
 {[1]="playerDebuffs",[2]="",[3]="",[4]=""},
 {[1]="playerAuraBelow",[2]="",[3]="",[4]=""},
 {[1]="playerAuraSingleRow",[2]="",[3]="",[4]=""},
 {[1]="playerAuraSize",[2]="",[3]="",[4]="",[5]=12,[6]=48,[7]=1},
 {[1]="playerAuraGap",[2]="",[3]="",[4]="",[5]=0,[6]=16,[7]=1},
 {[1]="playerAuraColumns",[2]="",[3]="",[4]="",[5]=2,[6]=16,[7]=1},
 {[1]="playerAuraMax",[2]="",[3]="",[4]="",[5]=1,[6]=32,[7]=1},
 {[1]="playerBuffX",[2]="",[3]="",[4]="",[5]=-300,[6]=300,[7]=2},
 {[1]="playerBuffY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=2},
 {[1]="playerDebuffX",[2]="",[3]="",[4]="",[5]=-300,[6]=300,[7]=2},
 {[1]="playerDebuffY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=2},
 {[1]="targetBuffs",[2]="",[3]="",[4]=""},
 {[1]="targetDebuffs",[2]="",[3]="",[4]=""},
 {[1]="targetAuraBelow",[2]="",[3]="",[4]=""},
 {[1]="targetAuraSingleRow",[2]="",[3]="",[4]=""},
 {[1]="targetAuraSize",[2]="",[3]="",[4]="",[5]=12,[6]=48,[7]=1},
 {[1]="targetAuraGap",[2]="",[3]="",[4]="",[5]=0,[6]=16,[7]=1},
 {[1]="targetAuraColumns",[2]="",[3]="",[4]="",[5]=2,[6]=16,[7]=1},
 {[1]="targetAuraMax",[2]="",[3]="",[4]="",[5]=1,[6]=32,[7]=1},
 {[1]="targetBuffX",[2]="",[3]="",[4]="",[5]=-300,[6]=300,[7]=2},
 {[1]="targetBuffY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=2},
 {[1]="targetDebuffX",[2]="",[3]="",[4]="",[5]=-300,[6]=300,[7]=2},
 {[1]="targetDebuffY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=2},
 {[1]="petBuffs",[2]="",[3]="",[4]="",[8]="pet"},
 {[1]="petDebuffs",[2]="",[3]="",[4]="",[8]="pet"},
 {[1]="petAuraBelow",[2]="",[3]="",[4]="",[8]="pet"},
 {[1]="petAuraSingleRow",[2]="",[3]="",[4]="",[8]="pet"},
 {[1]="petAuraSize",[2]="",[3]="",[4]="",[5]=12,[6]=48,[7]=1,[8]="pet"},
 {[1]="petAuraGap",[2]="",[3]="",[4]="",[5]=0,[6]=16,[7]=1,[8]="pet"},
 {[1]="petAuraColumns",[2]="",[3]="",[4]="",[5]=2,[6]=16,[7]=1,[8]="pet"},
 {[1]="petAuraMax",[2]="",[3]="",[4]="",[5]=1,[6]=32,[7]=1,[8]="pet"},
 {[1]="petBuffX",[2]="",[3]="",[4]="",[5]=-300,[6]=300,[7]=2,[8]="pet"},
 {[1]="petBuffY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=2,[8]="pet"},
 {[1]="petDebuffX",[2]="",[3]="",[4]="",[5]=-300,[6]=300,[7]=2,[8]="pet"},
 {[1]="petDebuffY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=2,[8]="pet"},
 {[1]="section",[2]="ufCast"},
 {[1]="targetCastEnabled",[2]="",[3]="",[4]=""},
 {[1]="castIcon",[2]="",[3]="",[4]=""},
 {[1]="castWidth",[2]="",[3]="",[4]="",[5]=120,[6]=420,[7]=5},
 {[1]="castHeight",[2]="",[3]="",[4]="",[5]=12,[6]=40,[7]=1},
 {[1]="castFontSize",[2]="",[3]="",[4]="",[5]=8,[6]=20,[7]=1},
 {[1]="castX",[2]="",[3]="",[4]="",[5]=-400,[6]=400,[7]=2},
 {[1]="castY",[2]="",[3]="",[4]="",[5]=-250,[6]=250,[7]=2},
}
K.UnitProfileFields=fields
function K.UnitOptionApplies(unit,key)
 if unit=='targettarget'then return key=='totScale'or key=='totNameScale'or key=='healthTextScale'or key=='showToT'end
 local visible=key~='enabled'and key~='hideNative'and key~='totScale'and key~='totNameScale'and key~='showToT'and not key:match('^cast')and key~='targetCastEnabled'and not key:match('Aura')and not key:match('Buff')and not key:match('Debuff')and key~='auraCooldown'and key~='auraStacks'
 if key=='classificationTextScale'then visible=unit=='target'end
 if key:match('^questie')then visible=unit=='target'and Questie~=nil end
 if key:match('^pet')or key:match('^happiness')or key=='showPet'or key=='showPetHappiness'then visible=unit=='pet'end
 if key=='levelTextScale'or key=='levelOffsetY'then visible=unit~='pet'end
 if key=='restIconSize'or key:match('^hunterSummon')or key=='showCombo'or key=='classicEnergyTickMode'or key=='classicManaTickMode'then visible=unit=='player'end
 if key=='portraitCombatPlayer'then visible=unit=='player'elseif key=='portraitCombatPet'then visible=unit=='pet'elseif key=='portraitCombatSize'then visible=unit=='player'or unit=='pet'end
 if key:match('^happiness')or key=='showPetHappiness'then visible=unit=='pet'and ForeverLeatherUnitsAPI.IsHunter()end
 if unit=='pet'and(key:match('^pvp')or key=='leaderSize'or key=='combatIconSize')then visible=false end
 return visible and true or false
end

function K.SetUnitOption(key,value)
  if K.InCombat() then return false end
  local api=ForeverLeatherUnitsAPI;local db=api and api.GetSettings()
  if not db then return false end
  local spec
  for _,f in ipairs(fields)do if f[1]==key then spec=f;break end end
  if not spec or key=='section'then return false end
  if spec[5]then
   if type(value)~='number'or value~=value or math.abs(value)==math.huge then return false end
   value=math.max(spec[5],math.min(spec[6],value))
  elseif type(value)~='boolean'then return false end
  local unit,axis=key:match("^(%w+)%.([xy])$")
  if unit then
   db[unit]=db[unit] or {}; db[unit][axis]=value
   if unit=="pet" or unit=="targettarget" then db[unit].detached=true end
  else
   if key=='textScale'and db.totNameScale==nil then db.totNameScale=db.textScale or 1 end
   db[key]=value
   local auraUnit=key:match("^(%w+)AuraBelow$")
   if auraUnit then
    local rows=math.ceil(db[auraUnit.."AuraMax"]/db[auraUnit.."AuraColumns"])
    if db[auraUnit.."AuraSingleRow"] then rows=1 end
    db[auraUnit.."BuffY"]=value and -8 or 10
    db[auraUnit.."DebuffY"]=db[auraUnit.."BuffY"]+(value and -1 or 1)*rows*(db[auraUnit.."AuraSize"]+db[auraUnit.."AuraGap"])
   end
   local changedUnit=key:match("^(%w+)Buffs$") or key:match("^(%w+)Debuffs$")
   if changedUnit and db[changedUnit.."Buffs"] and db[changedUnit.."Debuffs"]
       and db[changedUnit.."BuffX"]==db[changedUnit.."DebuffX"] and db[changedUnit.."BuffY"]==db[changedUnit.."DebuffY"] then
    local rows=db[changedUnit.."AuraSingleRow"] and 1 or math.ceil(db[changedUnit.."AuraMax"]/db[changedUnit.."AuraColumns"])
    db[changedUnit.."DebuffY"]=db[changedUnit.."BuffY"]+(db[changedUnit.."AuraBelow"] and -1 or 1)*rows*(db[changedUnit.."AuraSize"]+db[changedUnit.."AuraGap"])
   end
  end
  api.Apply()
  if K.UpdateUnitPreview then K.UpdateUnitPreview(key) end
  return true
end

local unitBuildSerial=0
local pendingUnitJump
function K.CancelUnitPageBuild()
 unitBuildSerial=unitBuildSerial+1
 K.unitPageBuilding=false;pendingUnitJump=nil
end
local function ScrollToUnitOption(key)
 local offset=K.UnitOptionPositions and K.UnitOptionPositions[key]
 if offset and K.window and K.window:IsShown() then
  K.scroll:UpdateScrollChildRect()
  K.scroll:SetVerticalScroll(math.min(math.max(0,offset-8),K.scroll:GetVerticalScrollRange()))
 end
end
local function DrawUnitsPage(page)
 local api=ForeverLeatherUnitsAPI
 local db=api.GetSettings()
 local w=K.UnitWidgets
 local y=0
 local combo=KerimAnkaUIClassicCombo
 if combo and select(2,UnitClass('player'))=='ROGUE' then
  w.Text(page,'Classic: round combo points are independent of the unit frame. Enable the combo option below, then unlock and drag the points.',8,y,690,14,{.87,.73,.40});y=y-90
  local c=combo.Settings()
  w.Button(page,c and c.locked and 'Unlock combo points' or 'Lock combo points',0,y,220,32,function() if c then combo.Set('locked',not c.locked);K.Render() end end)
  w.Button(page,'Smaller',232,y,140,32,function() if c then combo.Set('size',c.size-2) end end)
  w.Button(page,'Larger',384,y,140,32,function() if c then combo.Set('size',c.size+2) end end)
  w.Button(page,'Reset position',536,y,178,32,function() combo.Reset();K.Render() end)
  y=y-60
 end
 w.Text(page,K.L("ufMoveHelp"),8,y,690,14,{.87,.73,.40}); y=y-72
 w.Text(page,K.L("ufNote"),8,y,690,12,{.65,.70,.62}); y=y-68
 K.UnitOptionPositions={}
 local warlock=(api.IsWarrior and api.IsWarrior() or false) or (api.IsWarlock and api.IsWarlock() or false) or (api.IsShaman and api.IsShaman() or false) or (api.IsMage and api.IsMage() or false) or (api.IsDruid and api.IsDruid() or false) or (api.IsPriest and api.IsPriest() or false)
 local shaman=api.IsShaman and api.IsShaman() or false
 local hunter=api.IsHunter(); local petSupported=api.SupportsPet and api.SupportsPet() or hunter
 local function read(key)
  local unit,axis=key:match("^(%w+)%.([xy])$")
  if unit then return db[unit] and db[unit][axis] or 0 end
  if key=='totNameScale'then return db.totNameScale or db.textScale or 1 end
  return db[key]
 end
 local write=K.SetUnitOption
 local column=0
 for _,f in ipairs(fields) do
  -- One settings card per timer callback, rather than the whole long page in
  -- one Lua execution budget. The page is built only while it is open.
  coroutine.yield()
  if f[1]=="section" and f[2]=="ufHunterSummons" and not (hunter or shaman) then
   -- Only classes with the supported native summon row expose these controls.
  elseif f[1]=="section" then
   if column==1 then y=y-96; column=0 end
   K.UnitOptionPositions[f[2]]=-y
   w.Text(page,K.L(shaman and f[2]=="ufHunterSummons" and "ufShamanTotems" or f[2]),8,y,690,19,{.73,.62,.41}); y=y-42
  elseif (f[8]~="summons" or hunter or shaman) and (f[8]~="notWarlock" or not warlock) and (f[8]~="warlock" or warlock) and (f[8]~="hunter" or hunter) and (f[8]~="pet" or petSupported) and (f[8]~="rogue" or not petSupported) then
   local key=f[1]
   local card=w.Box(page,column*365,y,349,86)
   K.UnitOptionPositions[key]=-y
   if key==K.highlightUnitOption then w.Rounded(card,.17,.21,.15,{.48,.65,.36,1},8,true) end
   local labelKey=shaman and key:find("^hunterSummon") and ("uf_"..key:gsub("^hunterSummon","shamanTotem")) or "uf_"..key
   w.Text(card,key=='showCombo' and 'Movable round combo points' or K.L(labelKey),14,-12,278,13)
   local help=w.Button(card,"?",311,-10,22,22,function() end)
   w.Tip(help,labelKey,key=="locked" and "ufMoveHelp" or key:find("^portraitCombat") and "ufPortraitCombatHelp" or key:find("^questie") and "ufQuestieHelp" or key:find("^hunterSummon") and (shaman and "ufShamanTotemsHelp" or "ufHunterSummonsHelp") or "ufHelp")
   if f[5] then
    local value=tonumber(read(key)) or f[5]
    local text=w.Text(card,string.format(f[7]<1 and "%.2f" or "%.0f",value),14,-54,150,15)
    local function change(delta)
     local current=tonumber(read(key)) or value
     write(key,math.max(f[5],math.min(f[6],math.floor((current+delta*f[7])/f[7]+.5)*f[7])))
     text:SetText(string.format(f[7]<1 and "%.2f" or "%.0f",tonumber(read(key)) or current))
    end
    w.Button(card,"−",251,-47,36,32,function() change(-1) end)
    w.Button(card,"+",297,-47,36,32,function() change(1) end)
   else w.Switch(card,read(key)==true,255,-48,function(v) write(key,v) end,true) end
   column=1-column
   if column==0 then y=y-96 end
  end
 end
 if column==1 then y=y-96 end
 local ticker=KerimAnkaUIClassicEnergyTick
 if ticker and select(2,UnitClass('player'))=='ROGUE' then
  K.UnitOptionPositions.classicEnergyTickMode=-y
  w.Text(page,K.L('etTitle'),8,y,698,18,{.73,.62,.41});y=y-34
  w.Text(page,K.L('etHelp'),8,y,698,13,{.65,.70,.62});y=y-78
  for i,mode in ipairs({'always','combat','off'})do
   local choice=mode;local label=mode=='always'and'etAlways'or mode=='combat'and'etCombat'or'etOff'
   local b=w.Button(page,K.L(label),(i-1)*243,y,228,34,function()if ticker.SetMode(choice)then K.Render()end end)
   w.Selected(b,ticker.GetMode()==mode)
  end
  y=y-56
 end
 local manaTick=KerimAnkaUIClassicManaTick
 if manaTick then
  K.UnitOptionPositions.classicManaTickMode=-y
  w.Text(page,K.L('mtTitle'),8,y,698,18,{.73,.62,.41});y=y-34
  w.Text(page,K.L('mtHelp'),8,y,698,13,{.65,.70,.62});y=y-112
  for i,mode in ipairs({'always','combat','off'})do
   local choice=mode;local label=mode=='always'and'etAlways'or mode=='combat'and'etCombat'or'etOff'
   local button=w.Button(page,K.L(label),(i-1)*243,y,228,34,function()if manaTick.SetMode(choice)then K.Render()end end)
   w.Selected(button,manaTick.GetMode()==mode)
  end
  y=y-56
 end
 w.Button(page,K.L("reload"),0,y,714,36,K.Reload)
 page:SetHeight(-y+64)
end
function K.DrawUnitsPage(page,complete)
 K.CancelUnitPageBuild()
 local serial=unitBuildSerial
 K.unitPageBuilding=true
 local worker=coroutine.create(function() DrawUnitsPage(page) end)
 local function Step()
  if serial~=unitBuildSerial then return end
  if not K.window or not K.window:IsShown() then K.CancelUnitPageBuild();return end
  local ok,err=coroutine.resume(worker)
  if not ok then K.CancelUnitPageBuild();error(err);return end
  if coroutine.status(worker)=='dead' then
   K.unitPageBuilding=false
   if complete then complete() end
   local key=pendingUnitJump;pendingUnitJump=nil
   if key then ScrollToUnitOption(key) end
  else C_Timer.After(0,Step) end
 end
 -- Yield before even the first card: opening-window work has its own budget.
 C_Timer.After(0,Step)
end
function K.JumpToUnitOption(key)
 K.HideTooltip();K.highlightUnitOption=key
 if K.unitPageBuilding then pendingUnitJump=key;return end
 K.Render()
 if K.unitPageBuilding then pendingUnitJump=key else ScrollToUnitOption(key) end
end

local energyTickLocales={en={etTitle="Energy tick",etHelp="A spark moves across your energy bar toward the next regeneration tick. Natural energy gains resynchronize it. At full energy it follows the last known rhythm until the next gain.",etAlways="Always visible",etCombat="Only in combat",etOff="Off"},tr={etTitle="Enerji tick göstergesi",etHelp="Enerji barındaki ışık, bir sonraki dolum anına doğru ilerler. Doğal enerji artışı zamanlamayı eşler. Enerji tam doluyken bir sonraki artışa kadar son bilinen ritimle devam eder.",etAlways="Her zaman görünür",etCombat="Yalnızca savaşta",etOff="Kapalı"},de={etTitle="Energietick",etHelp="Ein Licht bewegt sich auf dem Energiebalken zum nächsten Regenerationstick. Natürliche Energiezuwächse synchronisieren es. Bei voller Energie folgt es bis zum nächsten Zuwachs dem letzten Rhythmus.",etAlways="Immer sichtbar",etCombat="Nur im Kampf",etOff="Aus"},zhCN={etTitle="能量回复节拍",etHelp="能量条上的光标向下一次回复时刻移动，并在自然回复时重新同步。能量满时沿用上次节奏，直到下一次回复。",etAlways="始终显示",etCombat="仅战斗中",etOff="关闭"},frFR={etTitle="Cycle d’énergie",etHelp="Une lueur parcourt la barre vers la prochaine régénération. Les gains naturels la resynchronisent. À énergie maximale, elle suit le dernier rythme connu jusqu’au prochain gain.",etAlways="Toujours visible",etCombat="En combat uniquement",etOff="Désactivé"},itIT={etTitle="Impulso di energia",etHelp="Una luce attraversa la barra verso la prossima rigenerazione. I guadagni naturali la risincronizzano. A energia piena segue l’ultimo ritmo noto fino al prossimo guadagno.",etAlways="Sempre visibile",etCombat="Solo in combattimento",etOff="Disattivato"},esES={etTitle="Pulso de energía",etHelp="Una luz recorre la barra hacia la próxima regeneración. Las ganancias naturales la resincronizan. Con energía máxima sigue el último ritmo conocido hasta la próxima ganancia.",etAlways="Siempre visible",etCombat="Solo en combate",etOff="Desactivado"},ptBR={etTitle="Pulso de energia",etHelp="Uma luz percorre a barra até a próxima regeneração. Ganhos naturais a sincronizam. Com energia cheia, ela segue o último ritmo conhecido até o próximo ganho.",etAlways="Sempre visível",etCombat="Somente em combate",etOff="Desativado"},ruRU={etTitle="Такт энергии",etHelp="Огонёк движется по полосе к следующему восстановлению энергии. Естественный прирост уточняет ритм. При полной энергии он следует последнему известному ритму до следующего прироста.",etAlways="Всегда показывать",etCombat="Только в бою",etOff="Выключено"}}
for lang,entries in pairs(energyTickLocales)do for key,value in pairs(entries)do K.locales[lang][key]=value end end

K.locales.en["mtTitle"]="Mana tick / five-second rule"

K.locales.en["mtHelp"]="The left number shows the five-second spirit-regeneration wait after spending mana, then the next estimated tick. Amber: wait; blue: tick. MP5 and talents can still restore mana during the wait. The rhythm follows observed gains; — means it is not synchronized yet."

K.locales.tr["mtTitle"]="Mana tick / beş saniye kuralı"

K.locales.tr["mtHelp"]="Soldaki süre, mana harcamasından sonraki beş saniyelik ruh yenilenmesi beklemesini, ardından tahmini tick zamanını gösterir. Turuncu: bekleme; mavi: tick. MP5 ve yeteneklerle beklerken de mana gelebilir. Ritim gözlenen artışlara uyar; — henüz eşlenmedi demektir."

K.locales.de["mtTitle"]="Manatick / Fünfsekundenregel"

K.locales.de["mtHelp"]="Links steht nach Manaverbrauch die fünfsekündige Wartezeit der Willenskraft-Regeneration, danach der geschätzte nächste Tick. Orange: Warten; blau: Tick. MP5 und Talente können weiter Mana geben. Der Rhythmus folgt beobachteten Zuwächsen; — bedeutet noch nicht synchronisiert."

K.locales.zhCN["mtTitle"]="法力回复 / 五秒规则"

K.locales.zhCN["mtHelp"]="左侧先显示消耗法力后的五秒精神回复等待时间，再显示预计下次回复时间。橙色为等待，蓝色为回复。每五秒回蓝和天赋仍可能在等待期间恢复法力。节奏根据实际增长校准；— 表示尚未同步。"

K.locales.frFR["mtTitle"]="Cycle de mana / règle des cinq secondes"

K.locales.frFR["mtHelp"]="À gauche : attente de cinq secondes de régénération liée à l’esprit après une dépense, puis prochain cycle estimé. Orange : attente ; bleu : cycle. Le MP5 et les talents peuvent encore rendre du mana. Le rythme suit les gains observés ; — indique l’absence de synchronisation."

K.locales.itIT["mtTitle"]="Impulso di mana / regola dei cinque secondi"

K.locales.itIT["mtHelp"]="A sinistra: attesa di cinque secondi della rigenerazione da spirito dopo una spesa, poi il prossimo impulso stimato. Arancione: attesa; blu: impulso. MP5 e talenti possono comunque restituire mana. Il ritmo segue i guadagni osservati; — indica che non è ancora sincronizzato."

K.locales.esES["mtTitle"]="Pulso de maná / regla de cinco segundos"

K.locales.esES["mtHelp"]="A la izquierda: espera de cinco segundos de regeneración por espíritu tras gastar maná y luego el próximo pulso estimado. Naranja: espera; azul: pulso. El MP5 y los talentos pueden seguir dando maná. El ritmo sigue las ganancias observadas; — indica que aún no está sincronizado."

K.locales.ptBR["mtTitle"]="Pulso de mana / regra dos cinco segundos"

K.locales.ptBR["mtHelp"]="À esquerda: espera de cinco segundos da regeneração por espírito após gastar mana, depois o próximo pulso estimado. Laranja: espera; azul: pulso. MP5 e talentos ainda podem restaurar mana. O ritmo segue ganhos observados; — indica que ainda não está sincronizado."

K.locales.ruRU["mtTitle"]="Такт маны / правило пяти секунд"

K.locales.ruRU["mtHelp"]="Слева: пять секунд ожидания восстановления от духа после расхода маны, затем ожидаемый следующий такт. Оранжевый: ожидание; синий: такт. MP5 и таланты могут восстанавливать ману и во время ожидания. Ритм уточняется по приростам; — означает отсутствие синхронизации."

K.locales.en["uf_totNameScale"]="Target of target: name scale"

K.locales.tr["uf_totNameScale"]="Hedefin hedefi: isim ölçeği"

K.locales.de["uf_totNameScale"]="Ziel des Ziels: Namensgröße"

K.locales.zhCN["uf_totNameScale"]="目标的目标：姓名缩放"

K.locales.frFR["uf_totNameScale"]="Cible de la cible : taille du nom"

K.locales.itIT["uf_totNameScale"]="Bersaglio del bersaglio: scala nome"

K.locales.esES["uf_totNameScale"]="Objetivo del objetivo: escala del nombre"

K.locales.ptBR["uf_totNameScale"]="Alvo do alvo: escala do nome"

K.locales.ruRU["uf_totNameScale"]="Цель цели: масштаб имени"
