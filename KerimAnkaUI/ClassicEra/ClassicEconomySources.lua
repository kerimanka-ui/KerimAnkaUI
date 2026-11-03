-- Observe confirmed wallet changes. No protected actions, native overrides or retries.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...;local E=K.ClassicEconomy;if not E then return end
local trade;local trace={};local buybacks={};local tokens={};local context={};local mailbox={};local mailQueued=false;local outgoing=0;local outgoingCost;local vendorBatch;local vendorSerial=0;local initQueued=false;local sendPlan;local sendHooked=false
function E.ClearIntents()tokens={};outgoing=0;outgoingCost=nil;sendPlan=nil end
local function Clock()return GetTime()end
local function Trace(text)trace[#trace+1]=('%.2f '):format(Clock())..text;if #trace>24 then table.remove(trace,1)end end
function E.GetTrace()return trace end
local function Call(fn,...)if type(fn)~='function'then return end;local ok,a,b,c,d,e,f,g,h,i,j,k,l=pcall(fn,...);if ok then return a,b,c,d,e,f,g,h,i,j,k,l end end
local function Intent(source,sign,meta,amount)
 if not E.Active()then return end
 if source=='loot'or source=='quest'then for i=#tokens,1,-1 do if tokens[i].source==source then table.remove(tokens,i)end end end
 local t={source=source,sign=sign,meta=meta or{},amount=amount,expires=Clock()+4}
 tokens[#tokens+1]=t;while #tokens>24 do table.remove(tokens,1)end
end
local function Guard(fn)return function(...)
 if E.fault then return end
 local diag=_G.KerimAnkaDiagnostics;local began=diag and diag.captureScopes and debugprofilestop and debugprofilestop()
 local ok,err=pcall(fn,...)
 if began then diag.RecordScope('Economy.Collector',debugprofilestop()-began)end
 if not ok then E.Fault(err)end
end end
local function Context(key,active)if active then context[key]=true else context[key]=nil end end
local function TradeFallback(delta)
 if not trade or(trade.cancelled and not trade.completed)then return end
 if not context.trade and(not trade.closedAt or Clock()-trade.closedAt>3)then return end
 local plan=trade.lastAccepted;if not plan then return end
 local incoming=math.max(0,plan.received-(trade.recordedIn or 0))
 local outgoing=math.max(0,plan.sent-(trade.recordedOut or 0))
 local parts={}
 if incoming-outgoing==delta then
  if incoming>0 then parts[#parts+1]={amount=incoming,source='trade',kind='trade',peer=plan.peer,evidence='matched'}end
  if outgoing>0 then parts[#parts+1]={amount=-outgoing,source='trade',kind='trade',peer=plan.peer,evidence='matched'}end
  trade.recordedIn=plan.received;trade.recordedOut=plan.sent
 elseif incoming>0 and delta==incoming then
  parts[1]={amount=delta,source='trade',kind='trade',peer=plan.peer,evidence='matched'};trade.recordedIn=plan.received
 elseif outgoing>0 and delta==-outgoing then
  parts[1]={amount=delta,source='trade',kind='trade',peer=plan.peer,evidence='matched'};trade.recordedOut=plan.sent
 else return end
 trade.settling=true;Trace('matched accepted trade snapshot delta='..delta)
 return parts
end
local function Resolve(delta)
 local sign=delta>0 and 1 or -1
 -- Native auto-loot can combine several already-observed mail claims in one
 -- PLAYER_MONEY. Match only the exact sum of bounded, priced positive claims.
 if delta>0 then
  local total,count=0,0
  for _,t in ipairs(tokens)do if t.expires>=Clock()and t.sign==1 and(t.source=='mail'or t.source=='auction')and type(t.amount)=='number'and t.amount>0 then total=total+t.amount;count=count+1 end end
  if count>1 and total==delta then
   local parts={}
   for i=#tokens,1,-1 do local t=tokens[i]
    if t.expires>=Clock()and t.sign==1 and(t.source=='mail'or t.source=='auction')and type(t.amount)=='number'and t.amount>0 then
     local m=t.meta;local refund=type(m.refund)=='number'and math.max(0,math.min(t.amount,m.refund))or 0
     if t.amount-refund>0 then parts[#parts+1]={amount=t.amount-refund,source=t.source,kind=m.kind,peer=m.peer,item=m.item,itemID=m.itemID,itemLink=m.itemLink,batch=m.batch,quantity=m.quantity,evidence='matched'}end
     if refund>0 then parts[#parts+1]={amount=refund,source=t.source,kind='refund',evidence='matched'}end
     table.remove(tokens,i)
    end
   end
   Trace('matched combined mail claims count='..count..' delta='..delta);return parts
  end
 end
 for i=#tokens,1,-1 do local t=tokens[i]
  if t.expires<Clock()then table.remove(tokens,i)
  elseif t.sign==sign and(not t.amount or math.abs(delta)==t.amount or math.abs(delta)==t.meta.alternateTotal)and(not t.meta.principal or math.abs(delta)>=t.meta.principal)then
   table.remove(tokens,i);local m=t.meta;if m.sendPlan then m.sendPlan.recorded=true end
   if t.source=='trade'then
    if trade then
     trade.settling=true
     if m.tradeNet then trade.recordedIn=(trade.recordedIn or 0)+m.received;trade.recordedOut=(trade.recordedOut or 0)+m.sent
     elseif m.tradeSide=='in'then trade.recordedIn=(trade.recordedIn or 0)+delta
     elseif m.tradeSide=='out'then trade.recordedOut=(trade.recordedOut or 0)-delta end
    end
    for j=#tokens,1,-1 do local other=tokens[j]
     if other.source=='trade'and(m.tradeNet or other.meta.tradeNet or other.meta.tradeSide==m.tradeSide)then table.remove(tokens,j)end
    end
    if m.tradeNet then
     local parts={}
     if m.received>0 then parts[#parts+1]={amount=m.received,source='trade',kind='trade',peer=m.peer,evidence='matched'}end
     if m.sent>0 then parts[#parts+1]={amount=-m.sent,source='trade',kind='trade',peer=m.peer,evidence='matched'}end
     return parts
    end
   end
   if m.principal and m.principal>0 and math.abs(delta)>=m.principal then
    local principal=m.principal*sign;local result={{amount=principal,source=t.source,kind=m.kind,peer=m.peer,item=m.item,itemID=m.itemID,itemLink=m.itemLink,batch=m.batch,quantity=m.quantity,evidence='matched'}}
    if delta~=principal then result[#result+1]={amount=delta-principal,source='mail',kind='postage',evidence='matched'}end
    return result
   end
   if delta>0 and type(m.refund)=='number'and m.refund>0 and m.refund<delta then
    return{{amount=delta-m.refund,source=t.source,kind=m.kind,item=m.item,itemID=m.itemID,itemLink=m.itemLink,batch=m.batch,quantity=m.quantity,evidence='matched'},{amount=m.refund,source=t.source,kind='refund',evidence='matched'}}
   end
   return{{amount=delta,source=t.source,kind=m.kind,item=m.item,itemID=m.itemID,itemLink=m.itemLink,batch=m.batch,quantity=m.quantity,peer=m.peer,evidence=t.amount and'matched'or'action'}}
  end
 end
 local matched=TradeFallback(delta);if matched then return matched end
 local source
 if context.vendor then source='vendor'elseif context.auction then source='auction'elseif context.mail then source='mail'elseif context.trade then source='trade'elseif context.trainer then source='travel'end
 return{{amount=delta,source='other',evidence=source and('context-'..source)or'unresolved'}}
end
local function Hook(owner,name,fn)
 if type(owner)=='string'then if type(_G[owner])=='function'then hooksecurefunc(owner,Guard(name))end
 elseif owner and type(owner[name])=='function'then hooksecurefunc(owner,name,Guard(fn))end
end
local function Snapshot(index)
 local _,_,sender,_,money,cod=Call(GetInboxHeaderInfo,index)
 if not sender then return end
 local invoice,item,_,_,_,deposit,_,_,_,_,quantity=Call(GetInboxInvoiceInfo,index)
 return{sender=sender,money=money,cod=cod,invoice=invoice,item=item,quantity=quantity,deposit=deposit}
end
local function CacheMail()
 if mailQueued or not context.mail or not E.Active()then return end;mailQueued=true
 C_Timer.After(.15,Guard(function()
  mailQueued=false;if not context.mail then return end
  local fresh={};local count=math.min(100,Call(GetInboxNumItems)or 0)
  for i=1,count do fresh[i]=Snapshot(i)end;mailbox=fresh
 end))
end
local function Mail(index,attachment)
 local m=Snapshot(index);if not m or ((m.money or 0)==0 and (m.cod or 0)==0)then m=mailbox[index]end
 if not m then return end
 local sender,money,cod,invoice,item,quantity=m.sender,m.money,m.cod,m.invoice,m.item,m.quantity
 if attachment and type(cod)=='number'and cod>0 then
  local itemName,_,_,count=Call(GetInboxItem,index,attachment)
  Intent('mail',-1,{kind='purchase',item=itemName,itemLink=Call(GetInboxItemLink,index,attachment),quantity=count,peer=sender},cod);return
 end
 if type(money)~='number'or money<=0 then return end
 if invoice=='seller'then Intent('auction',1,{kind='sale',item=item,quantity=quantity,refund=m.deposit},money)
 elseif E.IsOwn(sender)then Intent('mail',1,{kind='transfer',peer=sender},money)
 else Intent('mail',1,{peer=sender,kind=invoice and'refund'or nil},money)end
end
local function CacheBuybacks()
 local fresh={};local count=math.min(12,Call(GetNumBuybackItems)or 0)
 for i=1,count do local name,_,price,quantity=Call(GetBuybackItemInfo,i);if name then fresh[i]={name=name,price=price,quantity=quantity,link=Call(GetBuybackItemLink,i)}end end
 buybacks=fresh
end
local function ArmSend(recipient,money,quote,origin)
 if not E.Active()or type(recipient)~='string'or recipient==''then return end
 money=type(money)=='number'and math.max(0,math.floor(money))or 0
 quote=type(quote)=='number'and quote>=0 and math.floor(quote)or nil
 for i=#tokens,1,-1 do if tokens[i].meta.sendPlan then table.remove(tokens,i)end end
 sendPlan={recipient=recipient,principal=money,quote=quote,expires=Clock()+4}
 local own=money>0 and E.IsOwn(recipient)
 local expected=quote and money+quote or nil
 -- Some client paths expose a total rather than a postage-only quote. Either
 -- candidate still has to equal the real wallet delta; never guess 30 copper.
 local alternate=quote and quote>=money and quote or nil
 Intent('mail',-1,{kind=own and'transfer'or money>0 and'sent'or'postage',principal=money,peer=recipient,sendPlan=sendPlan,alternateTotal=alternate},expected)
 Trace(('mail send %s principal=%d quote=%s own=%s'):format(origin,money,tostring(quote),tostring(own)))
end
local function InstallSendSnapshot()
 local button=SendMailMailButton
 if sendHooked or not button or not button.HookScript then return end
 sendHooked=true
 -- Read-only PreClick runs before the native protected send/reset action.
 -- No replacement of the button's action script or protected mail functions.
 button:HookScript('PreClick',Guard(function()
  local recipient=SendMailNameEditBox and Call(SendMailNameEditBox.GetText,SendMailNameEditBox)
  local attached=SendMailSendMoneyButton and Call(SendMailSendMoneyButton.GetChecked,SendMailSendMoneyButton)
  local money=attached and Call(MoneyInputFrame_GetCopper,SendMailMoney)or 0
  ArmSend(recipient,money,Call(GetSendMailPrice),'preclick')
 end))
end
local function Hooks()
 Hook('BuybackItem',function(index)
  local info=buybacks[index]
  Intent('vendor',-1,{kind='purchase',item=info and info.name,itemLink=info and info.link,quantity=info and info.quantity},info and info.price)
 end)
 Hook('BuyMerchantItem',function(index,quantity)local name=Call(GetMerchantItemInfo,index);Intent('vendor',-1,{kind='purchase',item=name,itemLink=Call(GetMerchantItemLink,index),quantity=quantity})end)
 Hook(C_Container,'UseContainerItem',function(bag,slot)
  if not context.vendor then return end
  if InRepairMode and InRepairMode()then Intent('repair',-1);return end
  local info=Call(C_Container.GetContainerItemInfo,bag,slot);if not info then return end
  local name=Call(C_Item and C_Item.GetItemInfo or GetItemInfo,info.hyperlink or info.itemID)
  Intent('vendor',1,{kind=info.quality==0 and'junk'or'sale',item=info.quality~=0 and name or nil,batch=info.quality==0 and vendorBatch or nil,itemID=info.itemID,itemLink=info.hyperlink,quantity=info.stackCount})
 end)
 Hook('RepairAllItems',function()Intent('repair',-1)end)
 Hook('TakeTaxiNode',function(index)local cost=Call(TaxiNodeCost,index);Intent('travel',-1,{kind='flight'},type(cost)=='number'and cost or nil)end)
 Hook('BuyTrainerService',function()Intent('travel',-1,{kind='training'})end)
 Hook('StartAuction',function()Intent('auction',-1,{kind='deposit'})end)
 -- Current Classic auction UI posts through PostAuction; retain legacy support.
 Hook('PostAuction',function()Intent('auction',-1,{kind='deposit'});Trace('auction post: awaiting confirmed deposit')end)
 Hook('PlaceAuctionBid',function(list,index,amount)
  local name,_,count,_,_,_,_,_,_,buyout=Call(GetAuctionItemInfo,list,index)
  Intent('auction',-1,{kind=type(buyout)=='number'and buyout>0 and amount==buyout and'purchase'or'bid',item=name,itemLink=Call(GetAuctionItemLink,list,index),quantity=count},amount)
 end)
 Hook('TakeInboxMoney',function(index)Mail(index)end)
 Hook('AutoLootMailItem',function(index)Mail(index)end)
 Hook('TakeInboxItem',function(index,attachment)Mail(index,attachment or 1)end)
 Hook('SetSendMailMoney',function(amount)if type(amount)=='number'and amount>=0 then outgoing=amount;outgoingCost=Call(GetSendMailPrice)end end)
 Hook('SendMail',function(recipient)
  if sendPlan and sendPlan.cancelled and sendPlan.recipient==recipient and sendPlan.expires>=Clock()then
   Trace('mail send post-hook ignored failed dispatch');outgoing=0;outgoingCost=nil;return
  end
  if sendPlan and not sendPlan.postSeen and sendPlan.recipient==recipient and sendPlan.expires>=Clock()then
   sendPlan.postSeen=true
   Trace('mail send post-hook keeps pre-click snapshot recorded='..tostring(sendPlan.recorded==true))
  else
   local money=Call(GetSendMailMoney)or outgoing;if money==0 and outgoing>0 then money=outgoing end
   ArmSend(recipient,money,outgoingCost or Call(GetSendMailPrice),'posthook');if sendPlan then sendPlan.postSeen=true end
  end
  outgoing=0;outgoingCost=nil
 end)
end
local function TradeSnapshot()
 if not trade or trade.closed or trade.settling then return end
 local sent,received=Call(GetPlayerTradeMoney),Call(GetTargetTradeMoney)
 if type(sent)=='number'and type(received)=='number'and sent==0 and received==0 and trade.accepted and ((trade.sent or 0)>0 or(trade.received or 0)>0)then
  Trace('trade offers reset by client; retaining accepted snapshot');return
 end
 if type(sent)=='number'and sent>=0 then trade.sent=sent end
 if type(received)=='number'and received>=0 then trade.received=received end
 trade.peer=Call(GetUnitName,'NPC',true)or trade.peer
 if (trade.sent or 0)+(trade.received or 0)>0 then trade.lastOffer={sent=trade.sent or 0,received=trade.received or 0,peer=trade.peer}end
 for i=#tokens,1,-1 do if tokens[i].source=='trade'then table.remove(tokens,i)end end
 local a,b=trade.sent or 0,trade.received or 0
 if b~=a then Intent('trade',b>a and 1 or -1,{tradeNet=true,sent=a,received=b,peer=trade.peer},math.abs(b-a))end
 if b>0 then Intent('trade',1,{kind='trade',tradeSide='in',peer=trade.peer},b)end
 if a>0 then Intent('trade',-1,{kind='trade',tradeSide='out',peer=trade.peer},a)end
 Trace(('trade offer out=%d in=%d'):format(a,b))
end
local function Changed()
 local value=GetMoney()
 if not E.Ready()then E.Seed(value);return end
 local previous=E.Baseline()
 if type(previous)~='number'then E.Seed(value);return end
 local delta=value-previous;Trace(('wallet=%d baseline=%d delta=%d active=%s'):format(value,previous,delta,tostring(E.Active())));if delta==0 then return end;local parts=Resolve(delta);E.Observe(value,parts)
end
local f=CreateFrame('Frame');E.sourceFrame=f
for _,event in ipairs({'PLAYER_ENTERING_WORLD','PLAYER_MONEY','MERCHANT_SHOW','MERCHANT_UPDATE','MERCHANT_CLOSED','AUCTION_HOUSE_SHOW','AUCTION_HOUSE_CLOSED','MAIL_SHOW','MAIL_CLOSED','TRADE_SHOW','TRADE_CLOSED','TRADE_ACCEPT_UPDATE','TRADE_MONEY_CHANGED','PLAYER_TRADE_MONEY','TRADE_REQUEST_CANCEL','UI_INFO_MESSAGE','UI_ERROR_MESSAGE','TRAINER_SHOW','TRAINER_CLOSED','LOOT_OPENED','LOOT_CLOSED','CHAT_MSG_MONEY','QUEST_TURNED_IN','MAIL_FAILED','QUEST_COMPLETE','MAIL_INBOX_UPDATE'})do f:RegisterEvent(event)end
f:SetScript('OnEvent',Guard(function(_,event,...)
 if event=='PLAYER_ENTERING_WORLD'then
  if not initQueued then initQueued=true;C_Timer.After(1,Guard(function()if not E.Ready()then E.Seed(GetMoney())end end))end
 elseif event=='PLAYER_MONEY'then Changed()
 elseif event=='MERCHANT_SHOW'then vendorSerial=vendorSerial+1;vendorBatch=tostring(E.Now())..':'..Clock()..':'..vendorSerial;Context('vendor',true);CacheBuybacks()
 elseif event=='MERCHANT_UPDATE'then if context.vendor and E.Active()then CacheBuybacks()end
 elseif event=='MERCHANT_CLOSED'then Context('vendor',false);buybacks={}
 elseif event=='AUCTION_HOUSE_SHOW'then Context('auction',true)
 elseif event=='AUCTION_HOUSE_CLOSED'then Context('auction',false)
 elseif event=='MAIL_SHOW'then Context('mail',true);InstallSendSnapshot();CacheMail()
 elseif event=='MAIL_INBOX_UPDATE'then CacheMail()
 elseif event=='MAIL_CLOSED'then Context('mail',false);mailbox={};outgoing=0;outgoingCost=nil
 elseif event=='TRADE_SHOW'then Context('trade',true);trade={sent=0,received=0};TradeSnapshot()
 elseif event=='TRADE_MONEY_CHANGED'or event=='PLAYER_TRADE_MONEY'then TradeSnapshot()
 elseif event=='TRADE_CLOSED'then
  Context('trade',false);Trace('trade closed')
  if trade and not trade.closed then
   trade.closed=true;trade.closedAt=Clock();local session=trade
   -- Bounded, event-triggered reconciliation; no polling loop. A late PLAYER_MONEY is deduplicated by baseline.
   for _,delay in ipairs({.05,.3})do C_Timer.After(delay,Guard(function()Trace('trade close reconciliation outcome='..tostring(session.completed)..' cancel='..tostring(session.cancelled));Changed() end))end
  end
 elseif event=='TRADE_REQUEST_CANCEL'then
  if trade then trade.cancelSignal=true end
  Trace('trade cancel signal (not proof of settlement)')
 elseif(event=='UI_INFO_MESSAGE'or event=='UI_ERROR_MESSAGE')and trade then
  local id,message=...;local key=Call(GetGameMessageInfo,id)
  if key=='ERR_TRADE_COMPLETE'or(ERR_TRADE_COMPLETE and message==ERR_TRADE_COMPLETE)then
   trade.completed=true;trade.cancelled=false;Trace('trade outcome COMPLETE')
   if not trade.completionChecked then trade.completionChecked=true;C_Timer.After(0,Guard(Changed))end
  elseif key=='ERR_TRADE_CANCELLED'or(ERR_TRADE_CANCELLED and message==ERR_TRADE_CANCELLED)then
   trade.cancelled=true;Trace('trade outcome CANCELLED')
  elseif context.trade or(trade.closedAt and Clock()-trade.closedAt<=3)then Trace('trade UI message '..tostring(key or id))end
 elseif event=='TRAINER_SHOW'then Context('trainer',true)
 elseif event=='TRAINER_CLOSED'then Context('trainer',false)
 elseif event=='LOOT_OPENED'or event=='CHAT_MSG_MONEY'then Intent('loot',1)
 elseif event=='QUEST_COMPLETE'then local money=Call(GetQuestMoneyToGet);if type(money)=='number'and money>0 then Intent('quest',1,{},money)end
 elseif event=='QUEST_TURNED_IN'then local _,_,money=...;if type(money)=='number'and money~=0 then Intent('quest',money>0 and 1 or -1,{},math.abs(money))end
 elseif event=='TRADE_ACCEPT_UPDATE'then local mine,theirs=...;Trace('trade accept '..tostring(mine)..'/'..tostring(theirs));TradeSnapshot();if trade then trade.accepted=mine==1 or theirs==1;if trade.accepted and trade.lastOffer then local p=trade.lastOffer;trade.lastAccepted={sent=p.sent,received=p.received,peer=p.peer};Trace('accepted snapshot saved')end end
 elseif event=='MAIL_FAILED'then tokens={};if sendPlan then sendPlan.cancelled=true end;Trace('mail failed: pending snapshot discarded')
 end
end))
Hooks();InstallSendSnapshot()
