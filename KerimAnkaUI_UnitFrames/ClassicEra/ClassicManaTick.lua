-- Display the Classic mana observer on the existing player mana bar.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local M=KerimAnkaUIClassicManaTick;if not M then return end
local overlay,bar,player,spark,glow,countdown,percent,percentAlpha
local hooked=false
local function Settings()local a=ForeverLeatherUnitsAPI;return a and a.GetSettings and a.GetSettings()end
function M.GetMode()
 local d=Settings();local mode=d and d.classicManaTickMode
 return(mode=='off'or mode=='combat')and mode or'always'
end
local function RestorePercent()
 if percent and percentAlpha~=nil then percent:SetAlpha(percentAlpha);percentAlpha=nil end
end
local function Ensure()
 local api=ForeverLeatherUnitsAPI;local f=api and api.GetPlayerFrame and api.GetPlayerFrame()
 if not f or not f.power then return end
 if bar==f.power and overlay then return end
 RestorePercent();if overlay then overlay:Hide()end
 player=f;bar=f.power;percent=f.powerPercent
 overlay=CreateFrame('Frame',nil,bar);M.overlay=overlay
 overlay:EnableMouse(false);overlay:SetAllPoints();overlay:SetFrameLevel(bar:GetFrameLevel()+4)
 spark=overlay:CreateTexture(nil,'OVERLAY',nil,0);spark:SetColorTexture(.65,.9,1,.95)
 glow=overlay:CreateTexture(nil,'OVERLAY',nil,0);glow:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark');glow:SetBlendMode('ADD');glow:SetAlpha(.55)
 countdown=overlay:CreateFontString(nil,'OVERLAY');M.countdown=countdown
 countdown:SetPoint('LEFT',bar,'LEFT',4,0);countdown:SetJustifyH('LEFT');countdown:SetWordWrap(false);countdown:SetShadowOffset(1,-1)
 overlay:SetScript('OnHide',RestorePercent)
 local elapsed=0
 overlay:SetScript('OnUpdate',function(_,dt)
  elapsed=elapsed+dt;if elapsed<.05 then return end;elapsed=0
  M.Step(GetTime());M.Refresh()
 end)
 if bar.HookScript then bar:HookScript('OnShow',function()M.Refresh()end)end
 overlay:Hide()
end
function M.Refresh()
 local d=Settings();if not d then RestorePercent();return end
 Ensure();if not overlay then return end
 local id,token=UnitPowerType('player');local mana=id==0 or token=='MANA'
 local mode=M.GetMode();local visible=d.enabled and mana and mode~='off'and bar:IsVisible()and not UnitIsDeadOrGhost('player')and(mode~='combat'or UnitAffectingCombat('player'))
 if not visible then RestorePercent();overlay:Hide();return end
 if percent then
  if percentAlpha==nil then percentAlpha=percent:GetAlpha()end
  percent:SetAlpha(0)
 end
 overlay:Show()
 local kind,left,progress=M.Readout(GetTime())
 local font,size,flags
 if percent and percent.GetFont then font,size,flags=percent:GetFont()end
 font=type(font)=='string'and font or(STANDARD_TEXT_FONT or'Fonts\\FRIZQT__.TTF')
 size=type(size)=='number'and size or 11*(tonumber(d.powerTextScale)or 1)
 local style=font..':'..size..':'..(flags or'OUTLINE')
 if overlay.textStyle~=style then countdown:SetFont(font,size,flags or'OUTLINE');overlay.textStyle=style end
 countdown:SetWidth(bar:GetWidth()*.4)
 local label=left and string.format('%.1fs',left)or'—'
 if overlay.lastText~=label then countdown:SetText(label);overlay.lastText=label end
 local r,g,b=kind=='wait'and 1 or .65,kind=='wait'and .72 or .9,kind=='wait'and .25 or 1
 countdown:SetTextColor(r,g,b);spark:SetColorTexture(r,g,b,.95)
 spark:SetShown(progress~=nil);glow:SetShown(progress~=nil)
 if progress then
  local w,h=bar:GetWidth(),bar:GetHeight();local inset=math.min(5,w/2)
  spark:ClearAllPoints();spark:SetPoint('CENTER',bar,'LEFT',inset+progress*math.max(0,w-2*inset),0);spark:SetSize(2,h)
  glow:ClearAllPoints();glow:SetPoint('CENTER',spark,'CENTER');glow:SetSize(10,h)
 end
end
function M.SetMode(mode)
 if mode~='always'and mode~='combat'and mode~='off'then return false end
 local d=Settings();if not d then return false end
 d.classicManaTickMode=mode;M.Refresh();return true
end
local function Read(now)M.Observe(now,UnitPower('player',0),UnitPowerMax('player',0))end
local nextSwing={[2973]=true,[14260]=true,[14261]=true,[14262]=true,[14263]=true,[14264]=true,[14265]=true,[14266]=true}
local events=CreateFrame('Frame')
for _,e in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_DEAD','PLAYER_ALIVE','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','UNIT_POWER_UPDATE','UNIT_POWER_FREQUENT','UNIT_MAXPOWER','UNIT_DISPLAYPOWER','UNIT_SPELLCAST_SUCCEEDED','UNIT_SPELLCAST_CHANNEL_START','COMBAT_LOG_EVENT_UNFILTERED'})do events:RegisterEvent(e)end
events:SetScript('OnEvent',function(_,event,unit,token)
 local now=GetTime()
 if event=='PLAYER_LOGIN'or event=='PLAYER_DEAD'then
  M.Reset(now,UnitPower('player',0))
 elseif event=='PLAYER_ENTERING_WORLD'or(event=='UNIT_MAXPOWER'and unit=='player')then
  M.Rebase(UnitPower('player',0))
 elseif event=='COMBAT_LOG_EVENT_UNFILTERED'then
  local _,sub,_,source,_,_,_,dest,_,_,_,spell,_,_,amount=CombatLogGetCurrentEventInfo()
  local guid=UnitGUID('player')
  local leech=sub=='SPELL_LEECH'or sub=='SPELL_PERIODIC_LEECH'
  if dest==guid and sub=='SPELL_RESURRECT'then M.Rebase(UnitPower('player',0))
  elseif dest==guid and(sub=='SPELL_ENERGIZE'or sub=='SPELL_PERIODIC_ENERGIZE')then M.ExcludeGain(now)
  elseif dest==guid and(sub=='SPELL_DRAIN'or sub=='SPELL_PERIODIC_DRAIN'or leech)then M.ExcludeLoss(now,amount)
  elseif source==guid and leech then M.ExcludeGain(now)
  elseif source==guid and(sub=='SPELL_CAST_SUCCESS'or nextSwing[spell]and(sub=='SPELL_DAMAGE'or sub=='SPELL_MISSED'))then Read(now);M.Cast(now)
  else return end
 elseif unit=='player'and(event=='UNIT_SPELLCAST_SUCCEEDED'or event=='UNIT_SPELLCAST_CHANNEL_START')then
  Read(now);M.Cast(now)
 elseif unit=='player'and(token==nil or token=='MANA')then Read(now)
 elseif event:sub(1,5)=='UNIT_'then return end
 if not hooked and ForeverLeatherUnitsAPI and type(ForeverLeatherUnitsAPI.Apply)=='function'and hooksecurefunc then
  hooked=true;hooksecurefunc(ForeverLeatherUnitsAPI,'Apply',function()M.Refresh()end)
 end
 M.Refresh()
end)
