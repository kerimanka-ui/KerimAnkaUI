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
function K.DrawUnitsPage(page)
 local api=ForeverLeatherUnitsAPI
 local db=api.GetSettings()
 local w=K.UnitWidgets
 local y=0
 w.Text(page,K.L("ufMoveHelp"),8,y,690,14,{.87,.73,.40}); y=y-72
 w.Text(page,K.L("ufNote"),8,y,690,12,{.65,.70,.62}); y=y-68
 K.UnitOptionPositions={}
 local warlock=(api.IsWarrior and api.IsWarrior() or false) or (api.IsWarlock and api.IsWarlock() or false) or (api.IsShaman and api.IsShaman() or false) or (api.IsMage and api.IsMage() or false) or (api.IsDruid and api.IsDruid() or false) or (api.IsPriest and api.IsPriest() or false)
 local shaman=api.IsShaman and api.IsShaman() or false
 local hunter=api.IsHunter(); local petSupported=api.SupportsPet and api.SupportsPet() or hunter
 local function read(key)
  local unit,axis=key:match("^(%w+)%.([xy])$")
  if unit then return db[unit] and db[unit][axis] or 0 end
  return db[key]
 end
 local function write(key,value)
  if K.InCombat() then return end
  local unit,axis=key:match("^(%w+)%.([xy])$")
  if unit then
   db[unit]=db[unit] or {}; db[unit][axis]=value
   if unit=="pet" or unit=="targettarget" then db[unit].detached=true end
  else
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
 end
 local column=0
 for _,f in ipairs(fields) do
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
   w.Text(card,K.L(labelKey),14,-12,278,13)
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
 w.Button(page,K.L("reload"),0,y,714,36,K.Reload)
 page:SetHeight(-y+64)
end
function K.JumpToUnitOption(key)
 K.HideTooltip()
 K.highlightUnitOption=key
 C_Timer.After(0,function()
  if not K.window:IsShown() or not K.UnitOptionPositions then return end
  K.Render()
  local offset=K.UnitOptionPositions and K.UnitOptionPositions[key]
  if offset then
   K.scroll:UpdateScrollChildRect()
   K.scroll:SetVerticalScroll(math.min(math.max(0,offset-8),K.scroll:GetVerticalScrollRange()))
  end
 end)
end
