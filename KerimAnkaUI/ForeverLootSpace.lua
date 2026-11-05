-- Forever bag convenience: opt-in grey-stack replacement during real input.
local _,K=...
local P={open=false,attempts=0,deleted=0,received=0};K.LootSpace=P
local function T(key)return K.L('ls'..key)end
local function F(key,...)return string.format(T(key),...)end
local function Config(create)
 if not K.db then return end
 if create then K.db.classicBags=K.db.classicBags or {}end
 return K.db.classicBags
end
function P.Enabled()local cfg=Config(false);return cfg and cfg.autoReplaceJunk==true or false end
P.reason=T('Idle')
local C=C_Container
local pending,transaction,lastAttempt,fullAt,busy
local inputFrame
local function ClearPending()
 pending=nil
 if inputFrame then inputFrame:Hide()end
end
local function Say(s) print('|cffffd36aKerimAnka Bags:|r '..s)end
local function Plain(v)return not(issecretvalue and issecretvalue(v))end
local function Number(v)return Plain(v)and type(v)=='number'and v==v and v>=0 and v<1000000000000 end
local function ID(link)return type(link)=='string'and Plain(link)and tonumber(link:match('item:(%d+)'))end
local function Metadata(link)
 if not ID(link)or not C_Item or not C_Item.GetItemInfo then return end
 local name,_,quality,_,_,_,_,maxStack,_,_,price=C_Item.GetItemInfo(link)
 if not Plain(name)or type(name)~='string'or not Number(quality)or not Number(price)or not Number(maxStack)or maxStack<1 then return end
 return {quality=quality,price=price,maxStack=maxStack}
end
local function LastBag()return math.max(4,math.min(5,tonumber(NUM_TOTAL_BAG_FRAMES)or tonumber(NUM_BAG_SLOTS)or 4))end
local function Source(slot)
 if not GetLootSourceInfo then return end
 local values={GetLootSourceInfo(slot)};if #values==0 then return end
 for _,v in ipairs(values)do if not Plain(v)or type(v)~='string'and type(v)~='number'then return end end
 return table.concat(values,':')
end
local function Loot(slot)
 if not Number(slot)or slot<1 or not P.open then return end
 local link=GetLootSlotLink(slot);local id=ID(link);if not id then return end
 local _,_,quantity,_,_,locked=GetLootSlotInfo(slot)
 if not Number(quantity)or quantity<1 or not Plain(locked)or locked~=false then return end
 local source=Source(slot);local meta=Metadata(link)
 if not source or not meta or meta.price<=0 then return end
 return {slot=slot,link=link,id=id,quantity=quantity,source=source,value=quantity*meta.price,maxStack=meta.maxStack}
end
local function SameLoot(a,b)return a and b and a.id==b.id and a.link==b.link and a.quantity==b.quantity and a.source==b.source end
local function Available()
 return P.Enabled() and not transaction and not busy and not InCombatLockdown()and not GetCursorInfo()
  and not(UnitIsDeadOrGhost and UnitIsDeadOrGhost('player'))
  and not(MerchantFrame and MerchantFrame:IsShown())and not(BankFrame and BankFrame:IsShown())
  and not(TradeFrame and TradeFrame:IsShown())and not(MailFrame and MailFrame:IsShown())
  and not(K and K.ClassicBags and K.ClassicBags.IsSorting and K.ClassicBags.IsSorting())
end
local function Pinned(info)
 local cfg=K.db and K.db.classicBags
 cfg=cfg and cfg.organized
 if cfg and cfg.pins then
  if not Number(info.itemID)or not Plain(info.hyperlink)then return true end
  local raw=(info.hyperlink or''):match('item:([^|]+)');local parts={}
  if raw then for part in(raw..':'):gmatch('(.-):')do parts[#parts+1]=part end end
  return cfg.pins[tostring(info.itemID)..':'..tostring(tonumber(parts[7])or 0)]==true
 end
 return false
end
local function Grey(bag,slot,info)
 if not info or not Plain(info.quality)or info.quality~=0 or not Plain(info.isLocked)or info.isLocked
  or not Plain(info.isLootable)or info.isLootable or not Number(info.stackCount)or info.stackCount<1 or Pinned(info)then return end
 local link=info.hyperlink;local id=ID(link);if not id then return end
 local q=C.GetContainerItemQuestInfo and C.GetContainerItemQuestInfo(bag,slot)
 if not q or not Plain(q.isQuestItem)or not Plain(q.questID)or q.isQuestItem or q.questID then return end
 local meta=Metadata(link);if not meta or meta.quality~=0 then return end
 return {bag=bag,slot=slot,link=link,id=id,count=info.stackCount,value=info.stackCount*meta.price}
end
local function Fits(bag,itemFamily)
 if bag==0 then return true end
 local _,family=C.GetContainerNumFreeSlots(bag)
 if not Number(family)then return nil end
 return family==0 or bit and bit.band(family,itemFamily)~=0 or false
end
-- Bounded, on-demand inventory pass. Unknown capacity cancels the transaction.
function P.Choose(loot)
 if not loot or not C or not C.GetContainerNumFreeSlots or not C_Item.GetItemFamily or not bit then return end
 local family=C_Item.GetItemFamily(loot.link);if not Number(family)then return end
 local candidate,room,total=nil,0,0
 for bag=0,LastBag()do
  local slots=C.GetContainerNumSlots(bag);if not Number(slots)or slots>160 then return end
  local fits=false;if slots>0 then fits=Fits(bag,family)end;if fits==nil then return end
  for slot=1,slots do
   local info=C.GetContainerItemInfo(bag,slot)
   if fits then
    if not info then room=room+loot.maxStack
    elseif not Plain(info.itemID)or not Plain(info.isLocked)or not Number(info.stackCount)then return
    elseif info.itemID==loot.id then
     total=total+info.stackCount
     -- Variant/link ambiguity must never cause unnecessary destruction.
     if info.hyperlink~=loot.link then return end
     if not info.isLocked then room=room+math.max(0,loot.maxStack-info.stackCount)end
    end
    local grey=Grey(bag,slot,info)
    if grey and grey.id~=loot.id and grey.value<loot.value and(not candidate or grey.value<candidate.value)then candidate=grey end
   elseif info and Plain(info.itemID)and info.itemID==loot.id then
    if not Number(info.stackCount)then return end;total=total+info.stackCount
   end
  end
 end
 -- Only one whole grey stack may be removed. It must actually free enough space.
 if room>=loot.quantity or loot.quantity-room>loot.maxStack then return end
 return candidate,total
end
local function Count(id)
 local n=0
 for bag=0,LastBag()do
  local slots=C.GetContainerNumSlots(bag);if not Number(slots)or slots>160 then return end
  for slot=1,slots do
  local info=C.GetContainerItemInfo(bag,slot)
  if info and Plain(info.itemID)and info.itemID==id then if not Number(info.stackCount)then return end;n=n+info.stackCount end
 end end
 return n
end
local function Verify(final)
 local t=transaction;if not t or busy then return end
 local greyCount=Count(t.grey.id);local lootCount=Count(t.loot.id)
 if not t.deleted and t.deleteRequested and greyCount and greyCount<=t.greyBefore-t.grey.count then
  t.deleted=true;P.deleted=P.deleted+1
 end
 if not t.received and lootCount and lootCount>=t.before+t.loot.quantity then t.received=true end
 if t.deleted and t.received then
  transaction=nil;P.received=P.received+1;P.reason=T('Done');t.result=P.reason
  if t.notified then Say(F('Received',t.loot.link,t.loot.quantity))
  else Say(F('Together',t.grey.link,t.grey.count,t.loot.link,t.loot.quantity))end
 elseif t.deleted then
  if not t.notified then
   t.notified=true;Say(F('FreedMessage',t.grey.link,t.grey.count,t.loot.link))
  end
  P.reason=T('Freed');t.result=P.reason
  if final then
   transaction=nil;P.reason=T('Missing');t.result=P.reason
   Say(F('MissingMessage',t.loot.link))
  end
 elseif final then
  transaction=nil;local cfg=Config(false);if cfg then cfg.autoReplaceJunk=false end;ClearPending();P.reason=T('NoProof');t.result=P.reason
  Say(F('Unverified',t.grey.link,t.grey.count,t.loot.link))
 end
end
local function Fault(message)
 local cfg=Config(false);if cfg then cfg.autoReplaceJunk=false end;ClearPending();busy=false;P.reason=message;Say(F('Stopped',message))
end
-- Only called directly from a genuine mouse input/native loot call, never a timer.
function P.Input()
 if not pending or not Available()then return end
 if GetTime()>pending.expires then ClearPending();P.reason=T('Expired');return end
 local loot=Loot(pending.loot.slot)
 if not SameLoot(loot,pending.loot)then ClearPending();P.reason=T('Changed');return end
 local grey,before=P.Choose(loot);if not grey then ClearPending();P.reason=T('NoCandidate');return end
 local fresh=Grey(grey.bag,grey.slot,C.GetContainerItemInfo(grey.bag,grey.slot))
 if not fresh or fresh.id~=grey.id or fresh.link~=grey.link or fresh.count~=grey.count or fresh.value~=grey.value then ClearPending();return end
 local greyBefore=Count(grey.id);if not greyBefore then ClearPending();return end
 ClearPending();fullAt=nil;lastAttempt=nil;busy=true;P.attempts=P.attempts+1
 -- Save links/counts BEFORE either native action; container events may be delayed
 -- or synchronous. Never infer failure from one stale source-slot snapshot.
 local token={grey=grey,loot=loot,before=before,greyBefore=greyBefore,result=T('Waiting')}
 transaction=token;P.last=token
 local ok,err=pcall(function()
  C.PickupContainerItem(grey.bag,grey.slot)
  local kind,id,link=GetCursorInfo()
  if not Plain(kind)or not Plain(id)or not Plain(link)or kind~='item'or id~=grey.id or link~=grey.link then error(T('CursorError'))end
  token.deleteRequested=true;DeleteCursorItem()
 end)
 -- Never clear someone else's cursor. Restore our exact stack if deletion failed.
 local kind,id,link=GetCursorInfo()
 if kind then
  local current=C.GetContainerItemInfo(grey.bag,grey.slot)
  local originUnchanged=not current or Plain(current.itemID)and Plain(current.hyperlink)and Plain(current.stackCount)and current.itemID==grey.id and current.hyperlink==grey.link and current.stackCount==grey.count
  if Plain(kind)and Plain(id)and Plain(link)and kind=='item'and id==grey.id and link==grey.link and originUnchanged then
   pcall(C.PickupContainerItem,grey.bag,grey.slot)
  end
  token.error=not ok and tostring(err)or T('CursorRetained')
  Fault(F('Blocked',grey.link,grey.count,token.error))
 elseif not ok then
  token.error=tostring(err);Fault(F('ActionError',grey.link,token.error))
 end
 if ok and not kind then P.reason=T('Waiting')end
 -- Bound to the exact still-present loot/source; no retries or confirmation bypass.
 if ok and not kind and SameLoot(loot,Loot(loot.slot))then
  local worked=pcall(LootSlot,loot.slot)
  if not worked then P.reason=T('NativeFailed')end
 end
 busy=false
 Verify(false)
 -- Bounded observation only: timers never delete or re-loot.
 for _,delay in ipairs({.15,.6,1.5,4,6})do
  local final=delay==6
  C_Timer.After(delay,function()if transaction==token then Verify(final)end end)
 end
end
local movement={MOVEFORWARD=true,MOVEBACKWARD=true,STRAFELEFT=true,STRAFERIGHT=true,TURNLEFT=true,TURNRIGHT=true,JUMP=true,TOGGLEAUTORUN=true,MOVEANDSTEER=true,ASCEND=true,DESCEND=true}
local function MovementInput(_,key)
 if not pending or not Plain(key)or type(key)~='string'or not GetBindingAction then return end
 -- Do not react to typing in chat/search, or to unrelated shortcuts.
 if GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()then return end
 if ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow()then return end
 local prefix=(IsAltKeyDown and IsAltKeyDown()and'ALT-'or'')..(IsControlKeyDown and IsControlKeyDown()and'CTRL-'or'')..(IsShiftKeyDown and IsShiftKeyDown()and'SHIFT-'or'')
 local action=GetBindingAction(prefix..key)
 if Plain(action)and type(action)=='string'and movement[action]then P.Input()end
end
local function WatchMovement()
 if not inputFrame then
  -- Created outside combat, visible only during the short failed-loot request.
  -- Always propagate: never swallow movement keys or modify any key binding.
  inputFrame=CreateFrame('Frame',nil,UIParent)
  inputFrame:SetPropagateKeyboardInput(true);inputFrame:EnableKeyboard(true)
  inputFrame:SetScript('OnKeyDown',MovementInput);inputFrame:SetScript('OnKeyUp',MovementInput)
 end
 inputFrame:Show()
 local request=pending
 C_Timer.After(8,function()
  if pending==request then ClearPending();P.reason=T('Expired')end
 end)
end
local function Prepare()
 if not P.open or not Available()or not fullAt or GetTime()-fullAt>1 then return end
 local loot
 if lastAttempt and GetTime()-lastAttempt.at<1 then loot=Loot(lastAttempt.slot)end
 if not loot and P.autoLoot then
  local n=GetNumLootItems();if not Number(n)or n>100 then return end
  for i=1,n do local v=Loot(i);if v and(not loot or v.value>loot.value)then loot=v end end
 end
 if not loot then P.reason=T('NoLoot');return end
 local grey=P.Choose(loot)
 if grey then pending={loot=loot,expires=GetTime()+8};P.reason=T('Armed');WatchMovement()
 else P.reason=T('NoCandidate')end
end
local frame=CreateFrame('Frame')
for _,event in ipairs({'LOOT_READY','LOOT_OPENED','LOOT_CLOSED','UI_ERROR_MESSAGE','BAG_UPDATE_DELAYED','PLAYER_REGEN_DISABLED','PLAYER_LEAVING_WORLD'})do frame:RegisterEvent(event)end
frame:SetScript('OnEvent',function(_,event,...)
 if event=='PLAYER_LEAVING_WORLD'then
  ClearPending();P.open=false;fullAt=nil;lastAttempt=nil
  if transaction then transaction.result=T('WorldLeft');transaction=nil end
  return
 end
 if not P.Enabled() and not transaction then
  if pending then ClearPending()end;P.open=false;return
 end
 if event=='BAG_UPDATE_DELAYED'then Verify(false);return end
 if event=='LOOT_OPENED'or event=='LOOT_READY'then
  if not P.open then ClearPending();lastAttempt=nil;fullAt=nil end
  P.open=true;P.autoLoot=select(1,...)==true
 elseif event=='LOOT_CLOSED'then P.open=false;ClearPending();lastAttempt=nil;fullAt=nil
 elseif event=='UI_ERROR_MESSAGE'then
  local code,message=...
  if P.Enabled() and P.open and not transaction and(Plain(code)and Enum and Enum.GameError and code==Enum.GameError.InvFull or Plain(message)and type(message)=='string'and(message==ERR_INV_FULL or message==INVENTORY_FULL))then fullAt=GetTime();Prepare()end
 else ClearPending();lastAttempt=nil;fullAt=nil end
end)
if hooksecurefunc and LootSlot then hooksecurefunc('LootSlot',function(slot)
 if busy or transaction or not P.Enabled() or not P.open then return end
 lastAttempt={slot=slot,at=GetTime()};Prepare();P.Input()
end)end
-- No full-screen input overlay or permanent OnUpdate loop. Movement input is
-- observed only for an armed request and is always propagated unchanged.
if WorldFrame and WorldFrame.HookScript then
 WorldFrame:HookScript('OnMouseDown',function()P.Input()end)
 WorldFrame:HookScript('OnMouseUp',function()P.Input()end)
end
function P.Set(value)
 if type(value)~='boolean' or not K.db or InCombatLockdown()then return false end
 if value and not(C and C.PickupContainerItem and DeleteCursorItem and GetLootSourceInfo and C_Timer and C_Timer.After)then Say(T('Unavailable'));return false end
 Config(true).autoReplaceJunk=value;ClearPending();fullAt=nil;lastAttempt=nil
 P.reason=T(value and'Idle'or'Off')
 return true
end
function P.DrawSettings(page,w,y)
 local box=w.Box(page,0,y,714,172)
 w.Text(box,T('Title'),16,-15,566,14)
 local help=w.Text(box,T('Help'),16,-48,680,12,{.65,.70,.62})
 help:SetWordWrap(true);help:SetHeight(108)
 w.Switch(box,P.Enabled(),620,-15,function(value)if P.Set(value)and K.Render then K.Render()end end,not InCombatLockdown())
 return y-188
end
SLASH_KALOOTSPACE1='/kalootspace'
SlashCmdList.KALOOTSPACE=function(command)
 command=(command or''):lower():match('^%s*(.-)%s*$')
 if command=='on'or command=='off'then
  if InCombatLockdown()then Say(T('Combat'));return end
  local value=command=='on';if P.Set(value)then Say(T(value and'Enabled'or'Disabled'))end
 elseif command=='last'then
  local t=P.last
  if t then Say(F('Last',t.grey.link,t.grey.count,t.loot.link,t.loot.quantity,t.result))else Say(T('NoLast'))end
 else Say(F('Status',T(P.Enabled()and'On'or'Off'),P.attempts,P.deleted,P.received,T(transaction and'On'or'Off'),P.reason))end
end
