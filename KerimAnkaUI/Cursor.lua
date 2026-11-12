local _,K=...
local M={};K.Cursor=M
-- Account-wide cosmetic preference, independent of character layout profiles.
local defaults={enabled=false,shape=1,size=40,alpha=.8,visibility=1,keepCamera=true,red=1,green=.82,blue=.15,gcd=false,cast=false,thickness=4,dot=false,hideDotCamera=true,countdown=false,trail=false,gcdGap=2,castGap=2,trailStyle=1,nativeScale=.35,nativeAlpha=.65,nativeOffsetX=0,nativeOffsetY=0,nativeShowCamera=false,nativeFadeIdle=false}
local bounds={shape={1,5},thickness={1,8},size={16,128},alpha={.1,1},visibility={1,3},red={0,1},green={0,1},blue={0,1},gcdGap={0,24},castGap={0,24},trailStyle={1,6},nativeScale={.35,1},nativeAlpha={.1,1},nativeOffsetX={-80,80},nativeOffsetY={-80,80}}
local driver,art,parts
local elapsed,lastX,lastY,scale=0,nil,nil,1
local events,RefreshRings,StopRings,UpdateRingColors,RefreshTrail,ClearTrail,UpdateTrail
local RefreshNative,ClearNative,UpdateNative,nativeMode,nativeFailedStyle
local gcdRing,castRing,castDuration,castStart,castLength,centerDot
local cameraLooking=false
local function Number(v)return type(v)=='number'and not(issecretvalue and issecretvalue(v))and v==v and math.abs(v)<math.huge end
function M.Get(key)
 local d=KerimAnkaUIDB and KerimAnkaUIDB.cursor
 local v=type(d)=='table'and d[key]
 if type(v)~=type(defaults[key])then return defaults[key]end
 if type(v)=='number'then
  local b=bounds[key];if not Number(v)or v<b[1]or v>b[2]then return defaults[key]end
  if(key=='shape'or key=='visibility'or key=='thickness'or key=='gcdGap'or key=='castGap'or key=='trailStyle')and v~=math.floor(v)then return defaults[key]end
 end
 return v
end
local function Position()
 -- Do not use hidden-cursor coordinates: camera mode can warp them to center.
 local looking=IsMouselooking and IsMouselooking()
 cameraLooking=not not looking
 art:SetShown(not looking or M.Get('keepCamera'))
 if centerDot then
  local timer=M.Get('countdown')and(castDuration~=nil or castStart~=nil)
  centerDot:SetShown(M.Get('dot')and not timer and(not looking or not M.Get('hideDotCamera')))
 end
 if looking and lastX then return end
 local x,y=GetCursorPosition()
 if not Number(x)or not Number(y)then return end
 if x==lastX and y==lastY then return end
 lastX,lastY=x,y
 art:ClearAllPoints();art:SetPoint('CENTER',UIParent,'BOTTOMLEFT',x/scale,y/scale)
end
local function Tick(_,delta)
 elapsed=elapsed+delta
 if elapsed<1/60 then return end
 -- No catch-up bursts after a slow frame; no tables/strings/frames per tick.
 local step=elapsed;elapsed=0;Position()
 if UpdateRingColors then UpdateRingColors(step)end
 if UpdateTrail then UpdateTrail(step)end
 if UpdateNative then UpdateNative(step)end
end
local function Ensure()
 if driver then return end
 driver=CreateFrame('Frame',nil,UIParent);driver:EnableMouse(false);driver:Hide()
 art=CreateFrame('Frame','KerimAnkaUICursor',driver);art:EnableMouse(false)
 art:SetFrameStrata('TOOLTIP');art:SetFrameLevel(100)
 parts={}
 for i=1,4 do parts[i]=art:CreateTexture(nil,'OVERLAY')end
end
function M.Refresh()
 local saved=KerimAnkaUIDB and KerimAnkaUIDB.cursor
 if type(saved)=='table'and saved.nativePoseVersion~=3 then
  -- The first native game test failed. Start this calibration revision in2D;
  -- only the failed native trial's size/alignment is reset, once, in memory.
  saved.nativePoseVersion=3;saved.nativeScale=.35;saved.nativeOffsetX=0;saved.nativeOffsetY=0
  if Number(saved.trailStyle)and saved.trailStyle>=4 then saved.trailStyle=1 end
 end
 local combat=InCombatLockdown()
 local mode=M.Get('visibility')
 local active=M.Get('enabled')and M.Get('alpha')>0 and(mode==1 or mode==2 and combat or mode==3 and not combat)
 if not active then
  if StopRings then StopRings()end
  if ClearTrail then ClearTrail()end
  if driver then driver:SetScript('OnUpdate',nil);driver:Hide();art:Hide()end
  lastX,lastY=nil,nil;return
 end
 Ensure();scale=UIParent:GetEffectiveScale()
 if not Number(scale)or scale<=0 then scale=1 end
 local size=M.Get('size');local shape=M.Get('shape');local weight=M.Get('thickness');local thickness=math.max(1,weight*size/64)
 art:SetSize(size,size);art:SetAlpha(M.Get('alpha'))
 for _,t in ipairs(parts)do t:Hide();t:ClearAllPoints();t:SetBlendMode('BLEND');t:SetVertexColor(M.Get('red'),M.Get('green'),M.Get('blue'))end
 if shape==1 then
  local t=parts[1];t:SetTexture('Interface\\AddOns\\KerimAnkaUI\\Media\\CursorWeights.tga','CLAMP','CLAMP','LINEAR')
  local tile=weight-1;local column=tile%4;local row=math.floor(tile/4)
  t:SetTexCoord(column/4,(column+1)/4,row/2,(row+1)/2);t:SetAllPoints(art);t:Show()
 elseif shape==5 then
  local glow,core=parts[1],parts[2]
  glow:SetTexture('Interface\\AddOns\\KerimAnkaUI\\Media\\CursorLight.tga','CLAMP','CLAMP','LINEAR');glow:SetTexCoord(0,1,0,1);glow:SetAllPoints(art);glow:SetBlendMode('ADD');glow:Show()
  core:SetTexture('Interface\\AddOns\\KerimAnkaUI\\Media\\Circle.tga','CLAMP','CLAMP','LINEAR');core:SetTexCoord(0,1,0,1)
  core:SetSize(math.max(2,thickness*1.5),math.max(2,thickness*1.5));core:SetPoint('CENTER',art,'CENTER');core:SetVertexColor(1,1,1);core:Show()
 else
  for i=1,(shape==3 and 2 or 4)do
   local t=parts[i];t:SetTexCoord(0,1,0,1);t:SetVertexColor(1,1,1);t:SetColorTexture(M.Get('red'),M.Get('green'),M.Get('blue'),1);t:Show()
   if shape==2 then
    if i<=2 then t:SetSize(size,thickness);t:SetPoint(i==1 and'TOP'or'BOTTOM',art, i==1 and'TOP'or'BOTTOM')
    else t:SetSize(thickness,size-2*thickness);t:SetPoint(i==3 and'LEFT'or'RIGHT',art,i==3 and'LEFT'or'RIGHT')end
   elseif shape==3 then t:SetSize(i==1 and size or thickness,i==1 and thickness or size);t:SetPoint('CENTER',art,'CENTER')
   else
    local length=size*.30;local offset=size*.35
    t:SetSize(i<=2 and length or thickness,i<=2 and thickness or length)
    t:SetPoint('CENTER',art,'CENTER',i==1 and-offset or i==2 and offset or 0,i==3 and-offset or i==4 and offset or 0)
   end
  end
 end
 if M.Get('dot')and not centerDot then centerDot=art:CreateTexture(nil,'OVERLAY',nil,3)end
 if centerDot then
  centerDot:SetTexture('Interface\\AddOns\\KerimAnkaUI\\Media\\Circle.tga','CLAMP','CLAMP','LINEAR')
  centerDot:SetSize(math.max(2,size*.10),math.max(2,size*.10));centerDot:ClearAllPoints();centerDot:SetPoint('CENTER',art,'CENTER')
  centerDot:SetVertexColor(M.Get('red'),M.Get('green'),M.Get('blue'));centerDot:SetShown(M.Get('dot'))
 end
 elapsed=0
 if lastX then art:ClearAllPoints();art:SetPoint('CENTER',UIParent,'BOTTOMLEFT',lastX/scale,lastY/scale)end
 driver:Show();Position();driver:SetScript('OnUpdate',Tick)
 if RefreshRings then RefreshRings(size)end
 if RefreshTrail then RefreshTrail(size)end
end
function M.Set(key,value)
 if not KerimAnkaUIDB or defaults[key]==nil or type(value)~=type(defaults[key])then return false end
 if type(value)=='number'then
  if not Number(value)then return false end
  local b=bounds[key];value=math.max(b[1],math.min(b[2],value))
  if key=='shape'or key=='visibility'or key=='thickness'or key=='gcdGap'or key=='castGap'or key=='trailStyle'then value=math.floor(value)end
 end
 if type(KerimAnkaUIDB.cursor)~='table'then KerimAnkaUIDB.cursor={}end
 -- Selecting a preset is an explicit retry, including the current preset.
 if key=='trailStyle'then nativeFailedStyle=nil;if ClearTrail then ClearTrail()end end
 KerimAnkaUIDB.cursor[key]=value;M.Refresh();return true
end
function M.SetColor(r,g,b)
 if not KerimAnkaUIDB or not Number(r)or not Number(g)or not Number(b)then return false end
 if type(KerimAnkaUIDB.cursor)~='table'then KerimAnkaUIDB.cursor={}end
 local d=KerimAnkaUIDB.cursor;d.red=math.max(0,math.min(1,r));d.green=math.max(0,math.min(1,g));d.blue=math.max(0,math.min(1,b))
 M.Refresh();return true
end
-- The game animates two native radial swipes. No custom per-segment animation,
-- spellbook scan, combat-log parsing, or cooldown queries in the cursor tick.
local colorElapsed,colorCurve=0,nil
local gcdReference
local castEvents={'UNIT_SPELLCAST_START','UNIT_SPELLCAST_STOP','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_INTERRUPTED','UNIT_SPELLCAST_DELAYED','UNIT_SPELLCAST_CHANNEL_START','UNIT_SPELLCAST_CHANNEL_UPDATE','UNIT_SPELLCAST_CHANNEL_STOP','UNIT_SPELLCAST_EMPOWER_START','UNIT_SPELLCAST_EMPOWER_UPDATE','UNIT_SPELLCAST_EMPOWER_STOP'}
local function Secret(v)return issecretvalue and issecretvalue(v)end
local function ClearCastColor()castDuration,castStart,castLength=nil,nil,nil;colorElapsed=0 end
local function ClearRing(cd)
 if cd then cd:Hide();if cd.Clear then cd:Clear()end end
end
local function NewRing(kind)
 local cd=CreateFrame('Cooldown',nil,art)
 cd:EnableMouse(false);cd:SetPoint('CENTER',art,'CENTER');cd:SetFrameLevel(101)
 cd:SetDrawSwipe(true);cd:SetDrawEdge(false);cd:SetDrawBling(false)
 cd:SetHideCountdownNumbers(true);cd:SetReverse(true)
 if cd.SetMinimumCountdownDuration then cd:SetMinimumCountdownDuration(0)end
 if cd.SetCountdownMillisecondsThreshold then cd:SetCountdownMillisecondsThreshold(0)end
 cd:SetSwipeTexture('Interface\\AddOns\\KerimAnkaUI\\Media\\CursorRing.tga',1,1,1,1)
 if cd.SetUseCircularEdge then cd:SetUseCircularEdge(true)end
 cd:SetScript('OnCooldownDone',function(self)
  self:Hide();if kind=='cast'then ClearCastColor()end
 end)
 cd:Hide();return cd
end
local function Duration(getter,...)
 if not getter then return end
 local ok,d=pcall(getter,...)
 -- Never branch on or index an opaque secret return. Player duration objects
 -- with protected contents go straight to the native cooldown API below.
 if ok and not Secret(d)and d then return d end
end
local function BindDuration(cd,d)
 if not d or not cd.SetCooldownFromDurationObject then return false end
 if d.IsZero then
  local ok,zero=pcall(d.IsZero,d)
  if ok and not Secret(zero)and zero then return false end
 end
 cd:Show()
 if pcall(cd.SetCooldownFromDurationObject,cd,d,true)then return true end
 cd:Hide();return false
end
local function BindGCD(spellID)
 local d=Duration(C_Spell and C_Spell.GetSpellCooldownDuration,spellID)
 if BindDuration(gcdRing,d)then return true end
 -- Older client fallback uses only readable timestamps. GCD is never inferred
 -- from arbitrary spell cooldowns or estimated from a fixed 1.5 second timer.
 local info
 if C_Spell and C_Spell.GetSpellCooldown then
  local ok,value=pcall(C_Spell.GetSpellCooldown,spellID)
  if ok and not Secret(value)and type(value)=='table'then info=value end
 end
 if info and Number(info.startTime)and Number(info.duration)and info.duration>0 then
  local rate=Number(info.modRate)and info.modRate>0 and info.modRate or 1
  if info.startTime+info.duration/rate>GetTime()then
   gcdRing:Show();gcdRing:SetCooldown(info.startTime,info.duration,rate);return true
  end
 end
 return false
end
local function UpdateGCD()
 if not gcdRing or not M.Get('gcd')then return end
 if BindGCD(61304)then return end
 if gcdReference and BindGCD(gcdReference)then return end
 ClearRing(gcdRing)
end
local function ObserveGCDSpell(spellID)
 if gcdReference or not M.Get('gcd')or not Number(spellID)or not GetSpellBaseCooldown then return end
 -- Client-specific fallback: accept only an actually used player spell whose
 -- public static metadata proves zero own cooldown and a real global recovery.
 -- No "short cooldown must be GCD" guess, fixed timers, or spellbook scanning.
 local ok,ownMS,globalMS=pcall(GetSpellBaseCooldown,spellID)
 if ok and Number(ownMS)and Number(globalMS)and ownMS==0 and globalMS>0 then
  gcdReference=spellID;UpdateGCD()
 end
end
local function ReadCast(getter)
 if not getter then return end
 local ok,name,_,_,startMS,endMS=pcall(getter,'player')
 if not ok or Secret(name)or name==nil then return end
 if Number(startMS)and Number(endMS)and endMS>startMS then return startMS/1000,(endMS-startMS)/1000 end
end
local function UpdateCast()
 if not castRing or not M.Get('cast')then return end
 ClearCastColor();castRing:SetSwipeColor(1,1,1,1)
 local d=Duration(UnitCastingDuration,'player')or Duration(UnitChannelDuration,'player')
 if BindDuration(castRing,d)then
  castDuration=d
  -- Both normal casts and channels use elapsed progress: white -> red.
  return
 end
 local start,length=ReadCast(UnitCastingInfo)
 if not start then start,length=ReadCast(UnitChannelInfo)end
 if start and start+length>GetTime()then
  castStart,castLength=start,length
  castRing:Show();castRing:SetCooldown(start,length);return
 end
 ClearRing(castRing)
end
StopRings=function()
 events:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
 events:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED');events:UnregisterEvent('SPELLS_CHANGED')
 for _,e in ipairs(castEvents)do events:UnregisterEvent(e)end
 ClearCastColor();ClearRing(gcdRing);ClearRing(castRing)
end
RefreshRings=function(size)
 -- Annulus asset radii are51/128 and59/128 of its frame diameter.
 -- Use actual visible boundaries, with independent radial gaps in UI pixels.
 local shape=M.Get('shape')
 local radius=shape==2 and size/math.sqrt(2)or shape==1 and size*59/128 or size*.5
 local gcdDiameter=(radius+M.Get('gcdGap'))*128/51
 local castRadius=M.Get('gcd')and gcdDiameter*59/128 or radius
 local castDiameter=(castRadius+M.Get('castGap'))*128/51
 if M.Get('gcd')then
  gcdRing=gcdRing or NewRing('gcd');gcdRing:SetSize(gcdDiameter,gcdDiameter)
  gcdRing:SetSwipeColor(.25,.85,1,1)
  events:RegisterEvent('SPELL_UPDATE_COOLDOWN');UpdateGCD()
 else events:UnregisterEvent('SPELL_UPDATE_COOLDOWN');ClearRing(gcdRing)end
 if M.Get('cast')then
  castRing=castRing or NewRing('cast');castRing:SetSize(castDiameter,castDiameter)
  castRing:SetHideCountdownNumbers(not M.Get('countdown'))
  if M.Get('countdown')and castRing.GetCountdownFontString and K.ApplyTextFont then
   local text=castRing:GetCountdownFontString()
   K.ApplyTextFont(text,math.max(12,math.min(24,size*.35)),true,'OUTLINE')
   text:ClearAllPoints();text:SetPoint('CENTER',art,'CENTER')
  end
  if not colorCurve and C_CurveUtil and C_CurveUtil.CreateCurve then
   colorCurve=C_CurveUtil.CreateCurve()
   colorCurve:AddPoint(0,1);colorCurve:AddPoint(.50,1);colorCurve:AddPoint(1,.08)
  end
  for _,e in ipairs(castEvents)do events:RegisterUnitEvent(e,'player')end
  UpdateCast()
 else
  for _,e in ipairs(castEvents)do events:UnregisterEvent(e)end
  ClearCastColor();ClearRing(castRing)
 end
 if M.Get('gcd')then
  events:RegisterUnitEvent('UNIT_SPELLCAST_START','player');events:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED','player');events:RegisterEvent('SPELLS_CHANGED')
 else events:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED');events:UnregisterEvent('SPELLS_CHANGED')end
end
UpdateRingColors=function(delta)
 if not castDuration and not castStart then return end
 colorElapsed=colorElapsed+delta
 if colorElapsed<1/30 then return end
 colorElapsed=0
 if castDuration then
  if colorCurve and castDuration.EvaluateElapsedPercent then
   local ok,fade=pcall(castDuration.EvaluateElapsedPercent,castDuration,colorCurve)
   -- Curve outputs may be secret. Only forward to the native color setter;
   -- no comparison, arithmetic, persistence, logs or conversion of that value.
   if ok then castRing:SetSwipeColor(1,fade,fade,1)end
  elseif castDuration.GetElapsedPercent then
   local ok,value=pcall(castDuration.GetElapsedPercent,castDuration)
   if ok and Number(value)then
    local fade=1-.92*math.max(0,math.min(1,(value-.5)*2))
    castRing:SetSwipeColor(1,fade,fade,1)
   end
  end
 else
  local progress=(GetTime()-castStart)/castLength
  if progress>=1 then ClearCastColor();ClearRing(castRing);return end
  local fade=1-.92*math.max(0,math.min(1,(progress-.5)*2))
  castRing:SetSwipeColor(1,fade,fade,1)
 end
end
-- Optional light ribbon: 24 reusable line pairs, at most 60 samples/sec.
-- Core and soft halo share endpoints. No independent timer or new runtime objects.
local TRAIL_COUNT,TRAIL_LIFE=24,.40
local trailFrame,trailPool,trailHead,trailActive,trailElapsed,trailX,trailY=nil,nil,0,0,0,nil,nil
local sparkPool,sparkHead,sparkActive,sparkElapsed,sparkOffset=nil,0,0,0,1
local sparkX,sparkY
local ribbonEnabled,sparkEnabled=true,false
local SPARK_COUNT,SPARK_LIFE=16,.45
ClearTrail=function()
 if ClearNative then ClearNative()end
 nativeMode=nil
 if trailFrame then trailFrame:Hide()end
 if trailPool then for i=1,TRAIL_COUNT do local p=trailPool[i];p.life=0;p.core:Hide();p.glow:Hide()end end
 if sparkPool then for i=1,SPARK_COUNT do local p=sparkPool[i];p.life=0;p.texture:Hide()end end
 sparkActive,sparkElapsed,sparkX,sparkY=0,0,nil,nil
 trailActive,trailElapsed,trailX,trailY=0,0,nil,nil
end
RefreshTrail=function(size)
 local style=M.Get('trailStyle')
 if M.Get('trail')and style>=4 and nativeMode==style and nativeFailedStyle~=style then
  -- Combat/world/settings refresh must not restart an already valid model.
  RefreshNative(style,true);return
 end
 ClearTrail()
 if not M.Get('trail')then return end
 nativeMode=style>=4 and nativeFailedStyle~=style and style or nil
 ribbonEnabled=style==1 or style==3 or nativeFailedStyle==style
 sparkEnabled=style==2 or style==3
 if nativeMode then RefreshNative(style);return end
 if not trailFrame then
  trailFrame=CreateFrame('Frame',nil,driver);trailFrame:EnableMouse(false);trailFrame:SetFrameStrata('TOOLTIP');trailFrame:SetFrameLevel(99)
  -- Texture anchors alone do not define the owning layer's viewport.
  trailFrame:SetAllPoints(UIParent)
 end
 if ribbonEnabled and not trailPool then
  trailPool={}
  for i=1,TRAIL_COUNT do
   local glow=trailFrame:CreateLine(nil,'ARTWORK',nil,0);glow:SetBlendMode('ADD')
   local core=trailFrame:CreateLine(nil,'ARTWORK',nil,1);core:SetBlendMode('ADD')
   trailPool[i]={core=core,glow=glow,life=0}
  end
 end
 if sparkEnabled and not sparkPool then
  sparkPool={}
  for i=1,SPARK_COUNT do
   local t=trailFrame:CreateTexture(nil,'OVERLAY');t:SetTexture('Interface\\AddOns\\KerimAnkaUI\\Media\\CursorLight.tga','CLAMP','CLAMP','LINEAR');t:SetBlendMode('ADD')
   sparkPool[i]={texture=t,life=0}
  end
 end
 trailFrame:SetAlpha(M.Get('alpha'));trailFrame:Show()
 local r,g,b=M.Get('red'),M.Get('green'),M.Get('blue')
 if ribbonEnabled then for i=1,TRAIL_COUNT do
  local p=trailPool[i];local width=math.max(1,size*.025)
  p.core:SetThickness(width);p.glow:SetThickness(width*4)
  p.core:SetColorTexture(.70+.30*r,.70+.30*g,.70+.30*b,1);p.glow:SetColorTexture(r,g,b,1)
  p.core:Hide();p.glow:Hide()
 end end
 if sparkEnabled then
  sparkOffset=math.max(1,size*.06)
  for i=1,SPARK_COUNT do
   local t=sparkPool[i].texture;t:SetSize(math.max(5,size*.30),math.max(5,size*.30));t:SetVertexColor(.65+.35*r,.65+.35*g,.65+.35*b);t:Hide()
  end
 end
 trailX,trailY=lastX,lastY
 sparkX,sparkY=lastX,lastY
end
UpdateTrail=function(delta)
 if nativeMode then return end
 if not trailFrame or not M.Get('trail')then return end
 if cameraLooking then if trailActive>0 or sparkActive>0 or trailX~=nil or sparkX~=nil then ClearTrail()end;return end
 if not trailFrame:IsShown()then trailFrame:Show()end
 if trailActive>0 then
  for i=1,TRAIL_COUNT do
   local p=trailPool[i]
   if p.life>0 then
    p.life=p.life-delta
    if p.life<=0 then p.life=0;p.core:Hide();p.glow:Hide();trailActive=trailActive-1
    else local fade=p.life/TRAIL_LIFE;p.core:SetAlpha(.95*fade);p.glow:SetAlpha(.25*fade*fade)end
   end
  end
 end
 if sparkActive>0 then
  for i=1,SPARK_COUNT do
   local p=sparkPool[i]
   if p.life>0 then
    p.life=p.life-delta
    if p.life<=0 then p.life=0;p.texture:Hide();sparkActive=sparkActive-1
    else
     local fade=p.life/SPARK_LIFE;local twinkle=1-math.abs((p.life*10)%2-1)
     p.texture:SetAlpha(fade*fade*(.25+.75*twinkle))
    end
   end
  end
 end
 sparkElapsed=sparkElapsed+delta
 -- Keep a separate spark sample so a brief movement between30Hz samples
 -- still emits once instead of being consumed by the60Hz ribbon sampler.
 if sparkEnabled and lastX then
  if not sparkX then sparkX,sparkY=lastX,lastY
  elseif sparkElapsed>=1/30 and(lastX~=sparkX or lastY~=sparkY)then
   sparkElapsed=0;sparkHead=sparkHead%SPARK_COUNT+1;local p=sparkPool[sparkHead]
   if p.life<=0 then sparkActive=sparkActive+1 end
   p.life=SPARK_LIFE;local t=p.texture;t:ClearAllPoints()
   t:SetPoint('CENTER',UIParent,'BOTTOMLEFT',sparkX/scale+(sparkHead%3-1)*sparkOffset,sparkY/scale+(sparkHead%2==0 and sparkOffset or-sparkOffset))
   sparkX,sparkY=lastX,lastY
   t:SetRotation(sparkHead*.85);t:SetAlpha(1);t:Show()
  end
 end
 trailElapsed=trailElapsed+delta
 if trailElapsed<1/60 or not lastX or(lastX==trailX and lastY==trailY)then return end
 local previousX,previousY=trailX,trailY
 trailElapsed=0;trailX,trailY=lastX,lastY
 if not previousX then return end
 local x1,y1,x2,y2=previousX/scale,previousY/scale,lastX/scale,lastY/scale
 if ribbonEnabled then
 trailHead=trailHead%TRAIL_COUNT+1;local p=trailPool[trailHead]
 if p.life<=0 then trailActive=trailActive+1 end
 p.life=TRAIL_LIFE
 p.core:SetStartPoint('BOTTOMLEFT',x1,y1);p.core:SetEndPoint('BOTTOMLEFT',x2,y2)
 p.glow:SetStartPoint('BOTTOMLEFT',x1,y1);p.glow:SetEndPoint('BOTTOMLEFT',x2,y2)
 p.core:SetAlpha(.95);p.glow:SetAlpha(.25);p.core:Show();p.glow:Show()
 end
end

-- Optional native game assets. These are game file IDs, not bundled models.
-- One model viewport is reused; all lifecycle/projection/settings code is ours.
-- Numeric projection anchors were checked against the supplied model reference;
-- final alignment remains an explicit game-test requirement.
local nativeModels={
 [4]={id=166498,customCamera=true,history=.6,baseScale=.07,projectionX=.0472,projectionY=.0472,anchorX=.075,anchorY=.2},
 [5]={id=166492,customCamera=false,history=.2,baseScale=.10,projectionX=.3430,projectionY=.3155,anchorX=0,anchorY=.005,slanted=true},
 [6]={id=166491,customCamera=false,history=.2,baseScale=.11,projectionX=.3430,projectionY=.3155,anchorX=0,anchorY=.01,slanted=true},
}
local nativeFrame,nativeLoaded,nativeX,nativeY,nativeIdle,nativeFade=nil,false,nil,nil,0,0
local nativeWidth,nativeHeight,nativeDiagonal,nativeDrawScale=1,1,1,1
local nativeOpacity,nativeShiftX,nativeShiftY=0,0,0
local nativeLastAlpha
local nativeReady,nativeSleeping,nativeHiding,nativeWaiting=false,false,false,0
local nativePaused,nativeWarm,nativePoll=false,0,0
local nativeApplying=false
local nativeVerify,nativeRepairs=0,0
local nativeWorldBlocked=false
local ApplyNativePose
local function NativePoseMatches()
 if nativeModels[nativeMode].customCamera and nativeFrame.HasCustomCamera then
  local ok,active=pcall(nativeFrame.HasCustomCamera,nativeFrame)
  if not ok or type(active)~='boolean'or(issecretvalue and issecretvalue(active))or not active then return false end
 end
 if nativeFrame.GetScale then
  local ok,value=pcall(nativeFrame.GetScale,nativeFrame)
  if not ok or not Number(value)or math.abs(value-nativeDrawScale)>.00001 then return false end
 end
 if nativeFrame.GetModelScale then
  local ok,value=pcall(nativeFrame.GetModelScale,nativeFrame)
  if not ok or not Number(value)or math.abs(value-1)>.00001 then return false end
 end
 return true
end

local nativeCameraConfigured,nativeCameraAttempts=false,0
local function NativeCameraReady()
 -- Camera selection initializes the built-in view even when the asset has
 -- no authored cameras. Only the authored-camera validation is optional.
 if nativeCameraConfigured then
  if not nativeModels[nativeMode].customCamera then return true end
  if not nativeFrame.HasCustomCamera then return true end
  local ok,active=pcall(nativeFrame.HasCustomCamera,nativeFrame)
  if ok and type(active)=='boolean'and not(issecretvalue and issecretvalue(active))and active then return true end
  nativeCameraConfigured=false
 end
 if not nativeFrame.SetCustomCamera or nativeCameraAttempts>=3 then return false end
 nativeCameraAttempts=nativeCameraAttempts+1
 local ok=pcall(nativeFrame.SetCustomCamera,nativeFrame,1)
 if not ok then return false end
 if nativeModels[nativeMode].customCamera and nativeFrame.HasCustomCamera then
  local success,active=pcall(nativeFrame.HasCustomCamera,nativeFrame)
  if not success or type(active)~='boolean'or(issecretvalue and issecretvalue(active))or not active then return false end
 end
 nativeCameraConfigured=true;return true
end

ClearNative=function()
 nativeCameraConfigured,nativeCameraAttempts=false,0
 local release=nativeLoaded
 nativeLoaded,nativeReady,nativeSleeping,nativeWaiting=false,false,false,0
 nativePaused,nativeWarm,nativePoll=false,0,0
 nativeVerify,nativeRepairs=0,0
 if nativeFrame then
  nativeHiding=true;nativeFrame:Hide();nativeHiding=false
  if release and nativeFrame.ClearModel then pcall(nativeFrame.ClearModel,nativeFrame)end
 end
 nativeLoaded,nativeX,nativeY,nativeIdle,nativeFade=false,nil,nil,0,0
 nativeLastAlpha=nil
end
local function NativeFallback()
 local failed=nativeMode
 if not failed then return end
 nativeFailedStyle=failed;ClearNative();nativeMode=nil
 RefreshTrail(M.Get('size'))
 if K.Message then K.Message('cursorNativeUnavailable')end
end
local function MarkNativeReady(repose)
 if not nativeLoaded or not nativeMode or nativeApplying then return false end
 -- Repeated engine notifications must not reset the warmup indefinitely.
 if nativeReady and not repose then
  if NativePoseMatches()then return true end
  -- A later genuine load can reset the pose after an early file-ID match.
  if nativeRepairs>=3 then NativeFallback();return false end
  nativeRepairs=nativeRepairs+1
 end
 nativeFrame:SetAlpha(0);nativeLastAlpha=0
 nativeApplying=true;local applied=ApplyNativePose();nativeApplying=false
 if not applied then NativeFallback();return false end
 nativeReady,nativeWaiting,nativeFade,nativeWarm=true,0,0,nativeModels[nativeMode].history+.1
 nativeVerify=2
 return true
end
RefreshNative=function(style,preserve)
 if not nativeFrame then
  local ok,frame=pcall(CreateFrame,'PlayerModel',nil,UIParent)
  if not ok or not frame then NativeFallback();return end
  nativeFrame=frame
  nativeFrame:EnableMouse(false);nativeFrame:SetAllPoints(UIParent)
  nativeFrame:SetFrameStrata('TOOLTIP');nativeFrame:SetFrameLevel(98)
  -- Stop native rendering as well as Lua work when the entire UI is hidden.
  nativeFrame:SetScript('OnHide',function(self)
   if not nativeHiding then ClearNative()end
  end)
  nativeFrame:SetScript('OnModelLoaded',function(self)
   if not nativeLoaded or not nativeMode then return end
   if self.GetModelFileID then
    local ok,id=pcall(self.GetModelFileID,self)
    if not ok or not Number(id)or id~=nativeModels[nativeMode].id then return end
   end
   MarkNativeReady()
  end)
  nativeFrame:Hide()
 end
 local oldWidth,oldHeight,oldScale,oldShiftX,oldShiftY=nativeWidth,nativeHeight,nativeDrawScale,nativeShiftX,nativeShiftY
 local width,height=UIParent:GetWidth(),UIParent:GetHeight()
 nativeWidth=Number(width)and width>0 and width*scale or 1920
 nativeHeight=Number(height)and height>0 and height*scale or 1080
 nativeDiagonal=math.sqrt(nativeWidth*nativeWidth+nativeHeight*nativeHeight)
 nativeDrawScale=nativeModels[style].baseScale*M.Get('nativeScale')
 nativeOpacity=M.Get('nativeAlpha')*M.Get('alpha')
 nativeShiftX,nativeShiftY=M.Get('nativeOffsetX')*scale,M.Get('nativeOffsetY')*scale
 if preserve then
  if nativeReady and(oldWidth~=nativeWidth or oldHeight~=nativeHeight or oldScale~=nativeDrawScale or oldShiftX~=nativeShiftX or oldShiftY~=nativeShiftY)then MarkNativeReady(true)end
  return
 end
 nativeFrame:SetAlpha(0)
 nativeLastAlpha=0
 nativeIdle,nativeFade,nativeX,nativeY=0,0,nil,nil
end
local function NativePosition(x,y)
 local data=nativeModels[nativeMode]
 local dx,dy=x+nativeShiftX-nativeWidth*.5,y+nativeShiftY-nativeHeight*.5
 -- A conservative linear perspective correction for hand-attached models;
 -- avoids copying the reference addon's piecewise edge-warp implementation.
 if data.slanted then dx=dx*(1.105-.12*y/nativeHeight);dy=dy*(dy<0 and 1.11 or .99)end
 local px=(dx/(nativeDiagonal*data.projectionX)+data.anchorX*nativeDiagonal*.0001)/nativeDrawScale
 local py=(dy/(nativeDiagonal*data.projectionY)+data.anchorY*nativeDiagonal*.0001)/nativeDrawScale
 local ok=pcall(nativeFrame.SetPosition,nativeFrame,0,px,py)
 return ok
end
local function ResetNativeModelSpace()
  if nativeFrame.ClearTransform then nativeFrame:ClearTransform()end
  nativeFrame:SetModelScale(1)
  nativeFrame:SetFacing(0);nativeFrame:SetPitch(0);nativeFrame:SetRoll(0)
end
ApplyNativePose=function()
 if not lastX then return false end
 local ok=pcall(function()
  ResetNativeModelSpace()
  -- Model camera1 is selected explicitly before changing viewport scale or
  -- cursor translation. Waiting on zero camera getters cannot create it.
  if not NativeCameraReady()then error('Native camera could not be configured')end
  nativeFrame:SetScale(nativeDrawScale)
  if nativeFrame.GetScale then
   local actual=nativeFrame:GetScale()
   if not Number(actual)or math.abs(actual-nativeDrawScale)>.00001 then error('Native scale did not apply')end
  end
  if not NativePosition(lastX,lastY)then error('Native pose did not apply')end
 end)
 return ok
end
UpdateNative=function(delta)
 if nativeWorldBlocked or not nativeMode or not nativeFrame then return end
 -- Only the finite startup window needs polling. A late load notification
 -- also validates the pose, even after this window has finished.
 if nativeReady and nativeVerify>0 then
  nativeVerify=math.max(0,nativeVerify-delta)
  if not NativePoseMatches()then MarkNativeReady();if not nativeMode then return end end
 end
 if cameraLooking and not M.Get('nativeShowCamera')then
  if not nativePaused then
   -- Hide/Show can discard the engine's model even while GetModelFileID
   -- still reports the old ID. Brief pauses keep the viewport shown.
   nativePaused=true
   nativeFrame:SetAlpha(0);nativeLastAlpha=0
  end
  return
 end
 if not lastX then return end
 if nativePaused then
  nativePaused=false;nativeWarm=nativeModels[nativeMode].history+.1;nativeFade=0
  nativeFrame:SetAlpha(0);nativeLastAlpha=0
  if nativeLoaded then
   if nativeReady and not NativePosition(lastX,lastY)then NativeFallback();return end
   nativeFrame:Show()
  end
 end
 local moved=lastX~=nativeX or lastY~=nativeY
 if nativeSleeping and not moved and M.Get('nativeFadeIdle')then
  nativeIdle=nativeIdle+delta
  if nativeIdle>=2 and nativeLoaded then
   local x,y=nativeX,nativeY;ClearNative();nativeX,nativeY=x,y
  end
  return
 end
 if not nativeLoaded then
  if not moved then return end
  -- Initialize at a transparent pose and wait for the engine's load callback.
  nativeFrame:SetAlpha(0);nativeLastAlpha=0
  local initialized=pcall(function()
   nativeFrame:SetScale(1);ResetNativeModelSpace();nativeFrame:SetPosition(0,0,0)
  end)
  if not initialized then NativeFallback();return end
  nativeLoaded,nativeReady,nativeWaiting=true,false,0
  local ok=pcall(nativeFrame.SetModel,nativeFrame,nativeModels[nativeMode].id)
  if not ok then NativeFallback();return end
  if not nativeMode then return end
  nativeFrame:Show()
 end
 if not nativeReady then
  nativeWaiting=nativeWaiting+delta
  -- A cached model can be ready without producing a new load callback.
  -- Poll only while waiting, at20Hz; never turn a missed callback into a
  -- permanent disappearance if the public file ID already matches.
  nativePoll=nativePoll+delta
  if nativePoll>=.05 and nativeFrame.GetModelFileID then
   nativePoll=0;local ok,id=pcall(nativeFrame.GetModelFileID,nativeFrame)
   if ok and Number(id)and id==nativeModels[nativeMode].id then MarkNativeReady()end
  end
  if nativeReady then return end
  if nativeWaiting>2 then NativeFallback()end
  return
 end
 if nativeSleeping then
  nativeSleeping=false;nativeFrame:SetAlpha(0);nativeLastAlpha=0;nativeFade=0;nativeWarm=nativeModels[nativeMode].history+.1
  if not NativePosition(lastX,lastY)then NativeFallback();return end
  nativeFrame:Show()
 end
 if moved then
  nativeX,nativeY=lastX,lastY;nativeIdle=0
  if not NativePosition(lastX,lastY)then NativeFallback();return end
 end
 -- The verified game assets keep ribbons alive for up to0.6seconds. Keep
 -- the renderer transparent after a jump until its old-origin history ages out.
 if nativeWarm>0 then
  nativeWarm=math.max(0,nativeWarm-delta);nativeIdle=0
  if not NativePosition(lastX,lastY)then NativeFallback();return end
  nativeFrame:SetAlpha(0);nativeLastAlpha=0;return
 end
 if moved or not M.Get('nativeFadeIdle')or cameraLooking then
  nativeIdle=0;nativeFade=math.min(1,nativeFade+delta*8)
 else
  nativeIdle=nativeIdle+delta
  if nativeIdle>.08 then nativeFade=math.max(0,nativeFade-delta*3)end
 end
 local alpha=nativeOpacity*nativeFade
 if alpha~=nativeLastAlpha then nativeFrame:SetAlpha(alpha);nativeLastAlpha=alpha end
 if nativeIdle>.08 and nativeFade<=0 then
  -- Alpha is already zero. Keep the viewport shown during short idle:
  -- Hide/Show does not reliably retain a renderable native model.
  -- A longer idle releases it once; no reload until cursor movement.
  nativeSleeping=true
 end
end
events=CreateFrame('Frame')
for _,e in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_LEAVING_WORLD','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','UI_SCALE_CHANGED','DISPLAY_SIZE_CHANGED'})do events:RegisterEvent(e)end
events:SetScript('OnEvent',function(_,event,unit,castGUID,spellID)
 if event=='PLAYER_ENTERING_WORLD'then
  nativeWorldBlocked=false
  -- A model prepared at login must not survive the loading-screen boundary.
  if ClearNative then ClearNative()end;M.Refresh()
 elseif event=='PLAYER_LEAVING_WORLD'then
  nativeWorldBlocked=true
  if ClearNative then ClearNative()end
 elseif event=='SPELL_UPDATE_COOLDOWN'then UpdateGCD()
 elseif event=='SPELLS_CHANGED'then gcdReference=nil;UpdateGCD()
 elseif event:sub(1,15)=='UNIT_SPELLCAST_'then
  if event=='UNIT_SPELLCAST_START'or event=='UNIT_SPELLCAST_SUCCEEDED'then ObserveGCDSpell(spellID)end
  if M.Get('cast')then UpdateCast()end
 else M.Refresh()end
end)

function K.DrawCursorPage(page,w,refresh)
 w.Text(page,K.L('cursorHelp'),0,0,714,13,{.65,.70,.62}):SetHeight(64)
 local box=w.Box(page,0,-76,714,64)
 w.Text(box,K.L('cursorEnabled'),13,-18,570,14)
 w.Switch(box,M.Get('enabled'),620,-19,function(v)M.Set('enabled',v)end,true)
 w.Text(page,K.L('cursorShape'),0,-156,714,15)
 for i,key in ipairs({'cursorRing','cursorSquare','cursorPlus','cursorReticle','cursorLight'})do
  local choice=i
  local b=w.Button(page,K.L(key),(i-1)*145,-184,134,34,function()M.Set('shape',choice);refresh()end)
  w.Selected(b,M.Get('shape')==i)
 end
 local function NumberControl(key,title,x,y,step,format)
  local c=w.Box(page,x,y,349,90);w.Text(c,K.L(title),13,-12,322,14)
  local value=M.Get(key);local percent=key=='alpha'or key=='nativeAlpha'or key=='nativeScale'
  w.Text(c,string.format(format,percent and value*100 or value),13,-48,225,20)
  for i,direction in ipairs({-1,1})do
   local delta=direction
   w.Button(c,delta<0 and'−'or'+',255+(i-1)*43,-45,35,30,function()M.Set(key,value+delta*step);refresh()end)
  end
 end
 NumberControl('size','cursorSize',0,-236,4,'%.0f')
 NumberControl('alpha','cursorAlpha',365,-236,.1,'%.0f %%')
 local color=w.Button(page,K.L('cursorColor'),0,-342,714,38,function()
  local picker=ColorPickerFrame;if not picker or not picker.SetupColorPickerAndShow then return end
  local r,g,b=M.Get('red'),M.Get('green'),M.Get('blue')
  picker:SetupColorPickerAndShow({r=r,g=g,b=b,hasOpacity=false,
   swatchFunc=function()M.SetColor(picker:GetColorRGB())end,
   cancelFunc=function()M.SetColor(r,g,b)end})
 end)
 if not color.cursorSwatch then color.cursorSwatch=color:CreateTexture(nil,'ARTWORK')end
 color.cursorSwatch:SetSize(20,20);color.cursorSwatch:ClearAllPoints();color.cursorSwatch:SetPoint('RIGHT',-12,0)
 color.cursorSwatch:SetColorTexture(M.Get('red'),M.Get('green'),M.Get('blue'),1);color.cursorSwatch:Show()
 w.Text(page,K.L('cursorVisibility'),0,-400,714,15)
 for i,key in ipairs({'cursorAlways','cursorCombat','cursorPeace'})do
  local choice=i
  local b=w.Button(page,K.L(key),(i-1)*242,-428,230,38,function()M.Set('visibility',choice);refresh()end)
  w.Selected(b,M.Get('visibility')==i)
 end
 local c=w.Box(page,0,-484,714,64)
 w.Text(c,K.L('cursorCamera'),13,-12,570,14):SetHeight(44)
 w.Switch(c,M.Get('keepCamera'),620,-19,function(v)M.Set('keepCamera',v)end,true)
 w.Text(page,K.L('cursorCameraHelp'),0,-564,714,13,{.65,.70,.62}):SetHeight(60)
 local timing=w.Box(page,0,-640,714,64)
 w.Text(timing,K.L('cursorGCD'),13,-12,570,14):SetHeight(44)
 w.Switch(timing,M.Get('gcd'),620,-19,function(v)M.Set('gcd',v)end,true)
 local casting=w.Box(page,0,-724,714,64)
 w.Text(casting,K.L('cursorCast'),13,-12,570,14):SetHeight(44)
 w.Switch(casting,M.Get('cast'),620,-19,function(v)M.Set('cast',v)end,true)
 w.Text(page,K.L('cursorTimingHelp'),0,-808,714,13,{.65,.70,.62}):SetHeight(90)
 NumberControl('gcdGap','cursorGCDGap',0,-920,1,'%.0f px')
 NumberControl('castGap','cursorCastGap',365,-920,1,'%.0f px')
 NumberControl('thickness','cursorThickness',0,-1030,1,'%.0f / 8')
 local function ExtraToggle(key,label,y)
  local box=w.Box(page,0,y,714,64)
  w.Text(box,K.L(label),13,-12,570,14):SetHeight(44)
  w.Switch(box,M.Get(key),620,-19,function(v)M.Set(key,v)end,true)
 end
 ExtraToggle('dot','cursorDot',-1140)
 ExtraToggle('hideDotCamera','cursorDotCamera',-1220)
 ExtraToggle('countdown','cursorCountdown',-1300)
 ExtraToggle('trail','cursorTrail',-1380)
 w.Text(page,K.L('cursorEffectStyle'),0,-1465,714,15)
 for i,key in ipairs({'cursorRibbon','cursorSparkles','cursorRibbonSparkles','cursorNativeBlueFlow','cursorNativeBlueArc','cursorNativeGreenArc'})do
  local style=i
  local b=w.Button(page,K.L(key),((i-1)%3)*242,-1494-math.floor((i-1)/3)*46,230,38,function()M.Set('trailStyle',style);refresh()end)
  w.Selected(b,M.Get('trailStyle')==i)
 end
 local effectHelp=nativeFailedStyle==M.Get('trailStyle')and'cursorNativeFallbackStatus'or'cursorEffectsHelp'
 w.Text(page,K.L(effectHelp),0,-1605,714,13,{.65,.70,.62}):SetHeight(110)
 w.Text(page,K.L('cursorNativeTitle'),0,-1735,714,16)
 NumberControl('nativeScale','cursorNativeScale',0,-1770,.1,'%.0f %%')
 NumberControl('nativeAlpha','cursorNativeAlpha',365,-1770,.1,'%.0f %%')
 NumberControl('nativeOffsetX','cursorNativeX',0,-1875,2,'%.0f px')
 NumberControl('nativeOffsetY','cursorNativeY',365,-1875,2,'%.0f px')
 w.Text(page,K.L('cursorNativeHelp'),0,-1985,714,13,{.65,.70,.62}):SetHeight(110)
 ExtraToggle('nativeShowCamera','cursorNativeCamera',-2110)
 ExtraToggle('nativeFadeIdle','cursorNativeFadeIdle',-2190)
 w.Text(page,K.L('cursorNativePolicyHelp'),0,-2270,714,13,{.65,.70,.62}):SetHeight(100)
 page:SetHeight(2390)
end
