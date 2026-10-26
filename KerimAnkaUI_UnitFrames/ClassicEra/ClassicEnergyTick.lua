-- Classic Era Rogue energy regeneration phase. Own implementation; no external addon dependency.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
if select(2,UnitClass('player'))~='ROGUE' then return end
local M={};KerimAnkaUIClassicEnergyTick=M
local state={anchor=GetTime(),previous=nil,synced=false,ignoreUntil=0}
local overlay,spark,glow,bar,countdown,textStyle,lastText
local function Settings()
 local api=ForeverLeatherUnitsAPI;return api and api.GetSettings and api.GetSettings()
end
function M.GetMode()
 local d=Settings();local mode=d and d.classicEnergyTickMode
 return (mode=='off'or mode=='combat')and mode or 'always'
end
function M.SetMode(mode)
 if mode~='always'and mode~='combat'and mode~='off'then return false end
 local d=Settings();if not d then return false end;d.classicEnergyTickMode=mode;M.Refresh();return true
end
function M.Reset(now,energy)
 state.anchor=now;state.previous=energy;state.synced=false;state.ignoreUntil=0;state.candidate=nil
end
function M.ExcludeGain(now)
 state.ignoreUntil=now+.2
 -- Power events and combat-log delivery may arrive in either order.
 local c=state.candidate
 if c and now-c.time<=.2 and c.value==UnitPower('player',3) then state.anchor=c.anchor;state.synced=c.synced;state.candidate=nil end
end
function M.Observe(now,energy,maximum)
 if type(energy)~='number'or type(maximum)~='number'then return end
 local previous=state.previous;state.previous=energy
 if not previous or energy<=previous or now<state.ignoreUntil then return end
 local gain=energy-previous
 -- Natural energy normally arrives in 20-point pulses (40 during Adrenaline Rush).
 -- A last partial pulse can hit the cap. Explicit energize spells are excluded separately.
 local natural=math.abs(gain-20)<=1 or math.abs(gain-40)<=1 or (energy==maximum and gain>0 and gain<40)
 if natural then
  state.candidate={time=now,value=energy,anchor=state.anchor,synced=state.synced}
  state.anchor=now;state.synced=true
 end
end
function M.Progress(now)return math.max(0,(now-state.anchor)%2)/2 end
function M.State()return state end
local function Ensure()
 local api=ForeverLeatherUnitsAPI;local player=api and api.GetPlayerFrame and api.GetPlayerFrame()
 local power=player and player.power
 if not power then return end
 if overlay and bar==power then return end
 bar=power;overlay=CreateFrame('Frame','KAClassicEnergyTickOverlay',bar);M.overlay=overlay
 overlay:SetAllPoints(bar);overlay:EnableMouse(false);overlay:SetFrameLevel(bar:GetFrameLevel()+1)
 glow=overlay:CreateTexture(nil,'OVERLAY',nil,0);glow:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark');glow:SetBlendMode('ADD');glow:SetAlpha(.7)
 spark=overlay:CreateTexture(nil,'OVERLAY',nil,1);spark:SetColorTexture(1,1,.8,.95)
 countdown=overlay:CreateFontString(nil,'OVERLAY');M.countdown=countdown
 countdown:SetPoint('LEFT',bar,'LEFT',4,0);countdown:SetJustifyH('LEFT');countdown:SetWordWrap(false)
 countdown:SetTextColor(1,1,1);countdown:SetShadowOffset(1,-1)
 textStyle=nil;lastText=nil
 overlay:Hide()
end
function M.Refresh()
 local d=Settings();if not d then return end
 Ensure();if not overlay then return end
 local powerID,token=UnitPowerType('player');local energy=token=='ENERGY'or powerID==3
 local mode=M.GetMode();local dead=UnitIsDeadOrGhost and UnitIsDeadOrGhost('player')
 local visible=d.enabled and mode~='off'and energy and not dead and bar:IsVisible()and(mode~='combat'or UnitAffectingCombat('player'))
 overlay:SetShown(visible and true or false)
 if not visible then return end
 local width,height=bar:GetWidth(),bar:GetHeight();local progress=M.Progress(GetTime())
 local size=11*(tonumber(d.powerTextScale)or 1)
 if textStyle~=size then countdown:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',size,'OUTLINE');textStyle=size end
 countdown:SetWidth(width*.4)
 local label=string.format('%.1fs',2*(1-progress))
 if label~=lastText then countdown:SetText(label);lastText=label end
 local inset=math.min(5,width/2);local x=inset+progress*math.max(0,width-2*inset)
 spark:ClearAllPoints();spark:SetPoint('CENTER',bar,'LEFT',x,0);spark:SetSize(2,height)
 glow:ClearAllPoints();glow:SetPoint('CENTER',spark,'CENTER');glow:SetSize(10,height)
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_DEAD','PLAYER_ALIVE','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','UNIT_POWER_UPDATE','UNIT_POWER_FREQUENT','UNIT_MAXPOWER','UNIT_DISPLAYPOWER','COMBAT_LOG_EVENT_UNFILTERED'})do events:RegisterEvent(event)end
local function ReadEnergy()
 M.Observe(GetTime(),UnitPower('player',3),UnitPowerMax('player',3))
end
events:SetScript('OnEvent',function(_,event,unit,token)
 if event=='PLAYER_LOGIN'or event=='PLAYER_ENTERING_WORLD'or event=='PLAYER_DEAD'then
  M.Reset(GetTime(),UnitPower('player',3))
 elseif event=='COMBAT_LOG_EVENT_UNFILTERED'then
  local _,sub,_,_,_,_,_,dest=CombatLogGetCurrentEventInfo()
  if (sub=='SPELL_ENERGIZE'or sub=='SPELL_PERIODIC_ENERGIZE')and dest==UnitGUID('player')then M.ExcludeGain(GetTime())end
 elseif unit=='player'and(token==nil or token=='ENERGY')then ReadEnergy()end
 M.Refresh()
end)
local elapsed=0;events:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<.03 then return end;elapsed=0
 ReadEnergy();M.Refresh()
end)
