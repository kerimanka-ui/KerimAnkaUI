-- Independent Classic Era timing model.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local E={hands={mainhand={},offhand={},ranged={}}};K.ClassicSwingEngine=E
function E:Clear(hand)
 if hand then self.hands[hand]={} else for h in pairs(self.hands)do self.hands[h]={}end end
end
function E:Start(hand,now,speed)
 if not speed or speed<=0 then self:Clear(hand);return end
 self.hands[hand]={speed=speed,expires=now+speed}
end
function E:Speed(hand,now,speed)
 local s=self.hands[hand]
 if not speed or speed<=0 then self:Clear(hand);return end
 if s.speed and s.paused then s.paused=s.paused*speed/s.speed;s.speed=speed
 elseif s.expires and s.expires>now and s.speed then s.expires=now+(s.expires-now)*speed/s.speed;s.speed=speed end
end
function E:Parry(now)
 local s=self.hands.mainhand
 if not s.expires or s.paused then return end
 local left=s.expires-now;local floor=s.speed*.2
 if left>floor then s.expires=now+math.max(floor,left-s.speed*.4)end
end
function E:Pause(now)
 for _,h in ipairs({'mainhand','offhand'})do local s=self.hands[h];if s.expires and s.expires>now and not s.paused then s.paused=s.expires-now end end
end
function E:Resume(now)
 for _,h in ipairs({'mainhand','offhand'})do local s=self.hands[h];if s.paused then s.expires=now+s.paused;s.paused=nil end end
end
function E:Progress(hand,now)
 local s=self.hands[hand];local left=s.paused or (s.expires and s.expires-now) or 0
 if left<=0 or not s.speed then return 0,0,false end
 return math.max(0,math.min(1,1-left/s.speed)),left,true
end
