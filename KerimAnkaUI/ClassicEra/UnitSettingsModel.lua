-- Classic settings presentation only. Existing keys and setters own all saved data.
if WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...;local M={};K.UnitSettingsModel=M
M.tabs={'general','auras','indicators','position','class'}
M.fields={};for _,f in ipairs(K.UnitProfileFields)do if f[1]~='section'then M.fields[f[1]]=f end end
local function Has(api,name)return api[name]and api[name]()or false end
local factsClass,factsCache
function M.Facts()
 local class=select(2,UnitClass('player'));if factsClass==class then return factsCache end
 local a=ForeverLeatherUnitsAPI;factsClass=class;factsCache={hunter=a.IsHunter(),shaman=Has(a,'IsShaman'),pet=Has(a,'SupportsPet')or a.IsHunter()or Has(a,'IsWarlock'),rogue=class=='ROGUE',combo=class=='ROGUE'or class=='DRUID',styled=Has(a,'IsWarrior')or Has(a,'IsWarlock')or Has(a,'IsShaman')or Has(a,'IsMage')or Has(a,'IsDruid')or Has(a,'IsPriest')}
 return factsCache
end
function M.Available(key,unit)
 local f=M.fields[key];if not f then return false end
 local c=M.Facts();local gate=f[8]
 if gate=='summons'and not(c.hunter or c.shaman)then return false end
 if gate=='notWarlock'and c.styled or gate=='warlock'and not c.styled then return false end
 if gate=='hunter'and not c.hunter or gate=='pet'and not c.pet or gate=='rogue'and not c.combo then return false end
 return true
end
local function C(id,tab,title,keys,enable,full,shared)
 return{id=id,tab=tab,title=title,keys=keys,enable=enable,full=full,shared=shared}
end
function M.Cards(unit)
 local u=unit;return{
 C('module','general','usModule',{'enabled','hideNative','locked'},'enabled',true,true),
 C('scale','general','uf_scale',{'scale'},nil,true,true),
 C('auraCommon','auras','usAuraCommon',{'auraCooldown','auraStacks'},nil,true,true),
 C('buff:'..u,'auras','upBuffs',{u..'Buffs',u..'BuffX',u..'BuffY'},u..'Buffs'),
 C('debuff:'..u,'auras','upDebuffs',{u..'Debuffs',u..'DebuffX',u..'DebuffY'},u..'Debuffs'),
 C('layout:'..u,'auras','usAuraLayout',{u..'AuraBelow',u..'AuraSingleRow',u..'AuraSize',u..'AuraGap',u..'AuraColumns',u..'AuraMax'},nil,true),
 C('combat','indicators','ufPortraitCombat',{u=='pet'and'portraitCombatPet'or'portraitCombatPlayer','portraitCombatSize'},u=='pet'and'portraitCombatPet'or'portraitCombatPlayer',true,true),
 C('quest','indicators','ufQuestie',{'questieTargetIcon','questieIconSize','questieIconX','questieIconY'},'questieTargetIcon',true),
 C('cast','indicators','ufCast',{'targetCastEnabled','castIcon','castWidth','castHeight','castFontSize','castX','castY'},'targetCastEnabled',true),
 C('status','indicators','ufIndicators',{'pvpSize','pvpOffsetX','pvpOffsetY','leaderSize','restIconSize','combatIconSize','raidMarkerSize','raidMarkerOffsetX','raidMarkerOffsetY'},nil,true,true),
 C('happiness','indicators','uf_showPetHappiness',{'showPetHappiness','happinessSize','happinessOffsetX','happinessOffsetY'},'showPetHappiness',true),
 C('position:'..u,'position','usFramePosition',{u..'.x',u..'.y',u=='pet'and'showPet'or nil,u=='pet'and'petScale'or nil},u=='pet'and'showPet'or nil,true),
 C('tot','position','usToT',{'showToT','totScale','totNameScale','targettarget.x','targettarget.y'},'showToT',true),
 C('text','position','usText',{'textScale','nameOffsetY','petTextScale','healthTextScale','powerTextScale','levelTextScale','levelOffsetY','classificationTextScale'},nil,true,true),
 C('summons','class',M.Facts().shaman and'ufShamanTotems'or'ufHunterSummons',{'hunterSummons','hunterSummonSize','hunterSummonGap','hunterSummonX','hunterSummonY'},'hunterSummons',true),
 C('combo','class','usCombo',{'showCombo'},'showCombo',true),
 }
end
function M.CardVisible(c,unit)
 if unit=='targettarget'then return c.id=='tot'or c.id=='text'or c.id=='module'or c.id=='scale'end
 if c.id=='combat'and unit=='target'then return false end
 if(c.id=='quest'or c.id=='cast')and unit~='target'then return false end
 if c.id=='happiness'and(unit~='pet'or not M.Facts().hunter)then return false end
 if c.id=='summons'and not(M.Facts().hunter or M.Facts().shaman)then return false end
 if c.id=='combo'and not M.Facts().combo then return false end
 return true
end
function M.Keys(c,unit)
 local out={};for _,key in ipairs(c.keys)do
  if M.Available(key,unit)then
   local specific=c.id=='status'or c.id=='text'
   if not specific or K.UnitOptionApplies(unit,key)then out[#out+1]=key end
  end
 end;return out
end
function M.Read(key)
 local d=ForeverLeatherUnitsAPI.GetSettings();local u,axis=key:match('^(%w+)%.([xy])$')
 if u then return d[u]and d[u][axis]or 0 end
 if key=='totNameScale'then return d[key]or d.textScale or 1 end
 return d[key]
end
function M.Route(key,unit)
 local u=key:match('^(player)')or key:match('^(pet)')or key:match('^(target)')or unit
 if key:match('^targettarget')or key:match('^tot')or key=='showToT'then return'position','tot','targettarget'end
 if key:find('Debuff',1,true)then return'auras','debuff:'..u,u end
 if key:find('Buff',1,true)then return'auras','buff:'..u,u end
 if key:find('Aura',1,true)then return'auras','layout:'..u,u end
 if key=='auraCooldown'or key=='auraStacks'then return'auras','auraCommon',unit end
 if key:match('^cast')or key=='targetCastEnabled'then return'indicators','cast','target'end
 if key:match('^questie')then return'indicators','quest','target'end
 if key:match('^portraitCombat')then return'indicators','combat',key=='portraitCombatPet'and'pet'or(unit=='pet'and'pet'or'player')end
 if key:match('^happiness')or key=='showPetHappiness'then return'indicators','happiness','pet'end
 if key:match('^hunterSummon')then return'class','summons','player'end
 if key=='showCombo'then return'class','combo','player'end
 if key=='classicEnergyTickMode'then return'class','energy','player'end
 if key=='classicManaTickMode'then return'class','mana','player'end
 if key=='showPet'or key=='petScale'then return'position','position:pet','pet'end
 if key:find('.',1,true)then return'position','position:'..u,u end
 if key=='scale'then return'general','scale',unit end
 if key=='enabled'or key=='hideNative'or key=='locked'then return'general','module',unit end
 if key=='pvpSize'or key:match('^pvpOffset')or key=='leaderSize'or key=='restIconSize'or key=='combatIconSize'or key:match('^raidMarker')then
  if key=='restIconSize'or(unit=='pet'and not key:match('^raidMarker'))then u='player'end
  return'indicators','status',u
 end
 if key=='classificationTextScale'then u='target'elseif key=='petTextScale'then u='pet'elseif unit=='pet'and(key=='levelTextScale'or key=='levelOffsetY')then u='player'end
 return'position','text',u
end
