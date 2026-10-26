-- Classic Era mana five-second rule and natural regeneration phase.
-- Independent observer: no spell casts, protected changes or external dependency.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local classes={HUNTER=true,PALADIN=true,PRIEST=true,MAGE=true,WARLOCK=true,SHAMAN=true,DRUID=true}
if not classes[select(2,UnitClass('player'))] then return end
local M={};KerimAnkaUIClassicManaTick=M
local S={};local WINDOW=.3
local function Valid(n)return type(n)=='number'and n==n and not(issecretvalue and issecretvalue(n))end
function M.Reset(now,mana)
 S.previous=mana;S.waitUntil=0;S.anchor=nil;S.castAt=nil;S.loss=nil;S.spend=nil;S.gain=nil;S.ignoreGain=0;S.ignoreLoss=0
end
local function Spend(now,loss)
 S.spend={time=now,before=S.waitUntil,value=loss.value,amount=loss.amount}
 S.waitUntil=now+5
end
function M.Rebase(mana)S.previous=mana;S.gain=nil;S.loss=nil end
function M.Cast(now)
 S.castAt=now
 local loss=S.loss
 if loss and now-loss.time<=WINDOW and loss.time>=S.ignoreLoss then
  Spend(loss.time,loss);S.loss=nil
 end
end
function M.ExcludeGain(now)
 S.ignoreGain=now+WINDOW
 if S.gain and now-S.gain.time<=WINDOW then S.gain=nil end
end
function M.ExcludeLoss(now,amount)
 S.ignoreLoss=now+WINDOW;S.loss=nil
 if S.spend and now-S.spend.time<=WINDOW and S.previous==S.spend.value and (not Valid(amount)or S.spend.amount==amount)then S.waitUntil=S.spend.before;S.spend=nil end
end
function M.Step(now)
 if S.gain and now-S.gain.time>=WINDOW then S.anchor=S.gain.time;S.gain=nil end
end
function M.Observe(now,mana,maximum)
 if not Valid(mana)or not Valid(maximum)then return end
 M.Step(now)
 local before=S.previous;S.previous=mana
 if not before or mana==before then return end
 if mana<before then
  if now<S.ignoreLoss then return end
  local loss={time=now,value=mana,amount=before-mana};S.loss=loss
  if S.castAt and now-S.castAt<=WINDOW then Spend(now,loss);S.loss=nil end
 elseif now>=S.ignoreGain then
  -- Keep the observed timestamp; commit after the combat log can exclude potions.
  S.gain={time=now,value=mana}
 end
end
function M.Readout(now)
 M.Step(now)
 if now<S.waitUntil then return 'wait',S.waitUntil-now,math.max(0,1-(S.waitUntil-now)/5)end
 if not S.anchor then return 'unknown',nil,nil end
 local progress=((now-S.anchor)%2)/2
 return 'tick',2*(1-progress),progress
end
function M.State()return S end
M.Reset(GetTime(),UnitPower('player',0))
