-- Classic Era only. Bounded cash ledger; no inventory actions or per-frame work.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local E={VERSION=2,MAX_ROWS=5000,MAX_DAYS=366,KEEP_DAYS=366,MAX_CHARACTERS=1,MAX_PRODUCTS=2000,MAX_PRODUCT_ENTRIES=12000};K.ClassicEconomy=E
E.sources={'loot','quest','vendor','repair','travel','auction','mail','trade','other'}
E.index={};for i,key in ipairs(E.sources)do E.index[key]=i end
local identityInfo;local checkedRef;local revision=0;local identity;local storeRef;local baseline;local ready=false;local notified=false
local function Now()return GetServerTime and GetServerTime()or time()end
E.Now=Now
local function Integer(n)return type(n)=='number'and n==n and n>=0 and n<1000000000000000 end
local function Clean(s,n)return type(s)=='string'and s:sub(1,n or 96)or nil end
local function Identity()
 if identityInfo then return identityInfo[1],identityInfo[2],identityInfo[3]end
 local name,realm=UnitFullName('player');name=name or UnitName('player');realm=realm or GetRealmName()
 local key=UnitGUID('player');if not name or not realm or not key then return end
 identityInfo={key,name,realm};return key,name,realm
end
local function Copy(value)
 if type(value)~='table'then return value end
 local t={};for k,v in pairs(value)do t[k]=Copy(v)end;return t
end
local function ProfileClock()return debugprofilestop and debugprofilestop()or 0 end
local metrics={validations=0,validationMs=0,migrations=0,migrationMs=0,reports=0,reportMs=0,reportPeak=0,cacheHits=0,cacheMisses=0,rollovers=0,mergedJunk=0,records=0,recordMs=0,recordPeak=0,pruneMs=0}
local reportCache={};local cacheOrder={}
local function ClearCache()reportCache={};cacheOrder={}end
local function ProductKey(row)return row.source..':'..(row.itemLink or(row.itemID and tostring(row.itemID))or row.item or'?')end
local function ProductAdd(map,key,row)
 local p=map[key]
 if not p then p={name=row.item,itemID=row.itemID,itemLink=row.itemLink,source=row.source,income=0,expense=0,inQty=0,outQty=0};map[key]=p end
 if row.amount>0 then p.income=p.income+row.amount;p.inQty=p.inQty+(row.quantity or 1)
 else p.expense=p.expense-row.amount;p.outQty=p.outQty+(row.quantity or 1)end
end
local function AddProduct(d,row)
 if not row.item or(row.kind~='sale'and row.kind~='purchase')then return end
 local day=math.floor(row.time/86400);local key=ProductKey(row)
 if not(d.productDays[day]and d.productDays[day][key])and d.productCount>=E.MAX_PRODUCT_ENTRIES then
  local oldest;for candidate in pairs(d.productDays)do if candidate<day and(not oldest or candidate<oldest)then oldest=candidate end end
  if oldest then for _ in pairs(d.productDays[oldest])do d.productCount=d.productCount-1 end;d.productDays[oldest]=nil;d.productPartial=true end
 end
 local daily=d.productDays[day];if not daily then daily={};d.productDays[day]=daily end
 if daily[key]or d.productCount<E.MAX_PRODUCT_ENTRIES then
  if not daily[key]then d.productCount=d.productCount+1 end;ProductAdd(daily,key,row)
 else d.productPartial=true end
 if d.productAll[key]or d.productAllCount<E.MAX_PRODUCTS then
  if not d.productAll[key]then d.productAllCount=d.productAllCount+1 end;ProductAdd(d.productAll,key,row)
 else d.productPartial=true end
end
local function PruneProducts(d)
 local cutoff=math.floor(Now()/86400)-E.KEEP_DAYS+1
 for day,values in pairs(d.productDays)do if day<cutoff then
  for _ in pairs(values)do d.productCount=d.productCount-1 end;d.productDays[day]=nil
 end end
end
local function ValidProducts(d)
 if type(d.productDays)~='table'or type(d.productAll)~='table'or not Integer(d.productCount)or not Integer(d.productAllCount)then return false end
 local function Entry(key,p)
  if type(key)~='string'or #key>360 or type(p)~='table'or type(p.name)~='string'or #p.name>96 or not E.index[p.source]then return false end
  for _,k in ipairs({'income','expense','inQty','outQty'})do if not Integer(p[k])then return false end end
  if p.itemLink and(type(p.itemLink)~='string'or #p.itemLink>256 or not p.itemLink:match('^item:%d+'))then return false end
  if p.itemID and not Integer(p.itemID)then return false end
  return true
 end
 local count,days=0,0
 for day,values in pairs(d.productDays)do
  days=days+1;if days>E.KEEP_DAYS or not Integer(day)or type(values)~='table'then return false end
  for key,p in pairs(values)do count=count+1;if count>E.MAX_PRODUCT_ENTRIES or not Entry(key,p)then return false end end
 end
 if count~=d.productCount then return false end
 count=0;for key,p in pairs(d.productAll)do count=count+1;if count>E.MAX_PRODUCTS or not Entry(key,p)then return false end end
 return count==d.productAllCount
end
local function PrivateData(root,key,name,realm,legacy)
 local started=ProfileClock();local old=legacy and legacy.characters[key]
 local c=old and Copy(old)or{name=Clean(name),realm=Clean(realm),started=Now(),all={},days={},transfer=0,events=0}
 c.transferIn=0;c.transferOut=0;c.bigIn=0;c.bigOut=0;c.maxIn={};c.maxOut={}
 local d={version=2,owner=key,characters={[key]=c},rows={},nextRow=1,rowCount=0,dayCount=0,started=c.started,totalRows=c.events,enabled=not legacy or legacy.enabled~=false,productDays={},productAll={},productCount=0,productAllCount=0,productPartial=old~=nil,legacySummary=old~=nil}
 local rows={};if legacy then for _,row in pairs(legacy.rows)do if row.character==key then rows[#rows+1]=Copy(row)end end end
 table.sort(rows,function(a,b)return(a.id or 0)<(b.id or 0)end)
 for i,row in ipairs(rows)do
  row.id=i;d.rows[i]=row;d.rowCount=i;AddProduct(d,row)
  local day=math.floor(row.time/86400);local values=c.days[day]
  if row.kind=='transfer'then
   if row.amount>0 then c.transferIn=c.transferIn+row.amount;if values then values[20]=(values[20]or 0)+row.amount end
   else c.transferOut=c.transferOut-row.amount;if values then values[21]=(values[21]or 0)-row.amount end end
  else c.bigIn=math.max(c.bigIn,row.amount);c.bigOut=math.max(c.bigOut,-row.amount)
   c.maxIn[row.source]=math.max(c.maxIn[row.source]or 0,row.amount);c.maxOut[row.source]=math.max(c.maxOut[row.source]or 0,-row.amount)
   if values then local i=E.index[row.source];values[22+i*2]=math.max(values[22+i*2]or 0,row.amount);values[23+i*2]=math.max(values[23+i*2]or 0,-row.amount)end
   if values then values[22]=math.max(values[22]or 0,row.amount);values[23]=math.max(values[23]or 0,-row.amount)end
  end
 end
 d.nextRow=d.rowCount%E.MAX_ROWS+1;for _ in pairs(c.days)do d.dayCount=d.dayCount+1 end
 root.classicEconomyPrivate=d
 metrics.migrations=metrics.migrations+1;metrics.migrationMs=ProfileClock()-started
 return d
end
local function Remember(root,key,name,realm,legacy)
 local names=root.classicEconomyIdentities
 if type(names)~='table'then names={};root.classicEconomyIdentities=names end
 local count=0;for _ in pairs(names)do count=count+1 end
 local function Add(k,n,r)if names[k]or count<64 then if not names[k]then count=count+1 end;names[k]={name=Clean(n),realm=Clean(r)}end end
 if legacy then for k,c in pairs(legacy.characters)do Add(k,c.name,c.realm)end end
 Add(key,name,realm)
end

-- Validate once per loaded table. Unknown/corrupt data is never repaired by guessing.
local function Valid(d,legacy)
 local rowsLimit=legacy and 1000 or E.MAX_ROWS;local daysLimit=legacy and 2000 or E.MAX_DAYS;local charsLimit=legacy and 24 or 1
 if type(d)~='table'or d.version~=(legacy and 1 or 2) or type(d.characters)~='table'or type(d.rows)~='table'then return false end
 if not Integer(d.nextRow)or d.nextRow<1 or d.nextRow>rowsLimit or d.nextRow~=math.floor(d.nextRow)then return false end
 if not Integer(d.started)or not Integer(d.rowCount)or d.rowCount>rowsLimit or(d.totalRows~=nil and not Integer(d.totalRows))or(d.enabled~=nil and type(d.enabled)~='boolean')then return false end
 local count,days,rows=0,0,0
 for key,c in pairs(d.characters)do
  count=count+1;if count>charsLimit or type(key)~='string'or #key>96 or type(c)~='table'or type(c.name)~='string'or #c.name>96 or type(c.realm)~='string'or #c.realm>96 or type(c.all)~='table'or type(c.days)~='table'or not Integer(c.started)or not Integer(c.events)then return false end
  if not legacy then
   for _,field in ipairs({'maxIn','maxOut'})do if type(c[field])~='table'then return false end;local n=0;for source,value in pairs(c[field])do n=n+1;if n>9 or not E.index[source]or not Integer(value)then return false end end end
   for _,field in ipairs({'transferIn','transferOut','bigIn','bigOut'})do if not Integer(c[field])then return false end end
  end
  if c.balance~=nil and not Integer(c.balance)then return false end
  if c.transfer~=nil and not Integer(math.abs(type(c.transfer)=='number'and c.transfer or math.huge))then return false end
  for index,value in pairs(c.all)do if type(index)~='number'or index<1 or index>18 or index~=math.floor(index)or not Integer(value)then return false end end
  for day,values in pairs(c.days)do
   days=days+1;if days>daysLimit or not Integer(day)or day~=math.floor(day)or type(values)~='table'then return false end
   for index,value in pairs(values)do if type(index)~='number'or index<1 or index>(legacy and 19 or 41) or index~=math.floor(index)or type(value)~='number'or not Integer(index==19 and math.abs(value)or value)then return false end end
  end
 end
 for slot,row in pairs(d.rows)do
  rows=rows+1;if rows>rowsLimit or type(slot)~='number'or slot<1 or slot>rowsLimit or slot~=math.floor(slot)or type(row)~='table'or not Integer(row.time)or type(row.amount)~='number'or row.amount==0 or not Integer(math.abs(row.amount))or not d.characters[row.character]or not E.index[row.source]then return false end
  for _,field in ipairs({'kind','item','peer','evidence'})do if row[field]~=nil and(type(row[field])~='string'or #row[field]>96)then return false end end
  if row.quantity~=nil and not Integer(row.quantity)then return false end
  if row.itemID~=nil and(not Integer(row.itemID)or row.itemID~=math.floor(row.itemID))then return false end
  if row.itemLink~=nil and(type(row.itemLink)~='string'or #row.itemLink>256 or not row.itemLink:match('^item:%d+'))then return false end
 end
 if rows~=d.rowCount then return false end
 if not legacy and not ValidProducts(d)then return false end
 return true
end
function E.Store()
 local account=KAClassic_KerimAnkaUIDB;if type(account)~='table'then return end
 local key,name,realm=Identity();if not key then return end
 if type(KAClassic_KerimAnkaUICharacterDB)~='table'then KAClassic_KerimAnkaUICharacterDB={}end
 local root=KAClassic_KerimAnkaUICharacterDB;local d=root.classicEconomyPrivate
 if not d then
  local legacy=account.classicEconomy
  if legacy and not Valid(legacy,true)then E.fault='Legacy economy data invalid; original preserved.';return end
  Remember(account,key,name,realm,legacy);d=PrivateData(root,key,name,realm,legacy)
 end
 if checkedRef~=d then
  local t=ProfileClock()
  if d.owner~=key or not Valid(d,false)then E.fault='Unsupported or damaged private economy data; original preserved.';return end
  metrics.validations=metrics.validations+1;metrics.validationMs=ProfileClock()-t
  checkedRef=d;ClearCache();Remember(account,key,name,realm)
 end
 return d
end
local function Prune(d)
 local pruneStarted=ProfileClock()
 PruneProducts(d)
 local cutoff=math.floor(Now()/86400)-E.KEEP_DAYS+1;local list={}
 for key,c in pairs(d.characters)do for day in pairs(c.days)do
  if type(day)=='number'and day>=cutoff then list[#list+1]={key=key,day=day}
  else c.days[day]=nil;c.condensed=true end
 end end
 table.sort(list,function(a,b)return a.day<b.day end)
 for i=1,math.max(0,#list-E.MAX_DAYS)do local entry=list[i];local c=d.characters[entry.key];c.days[entry.day]=nil;c.condensed=true end
 d.dayCount=math.min(#list,E.MAX_DAYS);d.lastPruneDay=math.floor(Now()/86400);metrics.pruneMs=metrics.pruneMs+ProfileClock()-pruneStarted
end
function E.Current()
 local d=E.Store();if not d then return end
 local key,name,realm=Identity();if not key then return end
 local c=d.characters[key]
 if not c then
  local count=0;for _ in pairs(d.characters)do count=count+1 end
  if count>=E.MAX_CHARACTERS then E.fault='Economy character limit reached; existing history preserved.';return end
  c={name=Clean(name),realm=Clean(realm),started=Now(),all={},days={},transfer=0,events=0};d.characters[key]=c
 end
 identity=key;return c,d,key
end
function E.Active()local d=E.Store();return d and d.enabled~=false and not E.fault end
function E.Invalidate()
 revision=revision+1;ClearCache()
 if K.ClassicEconomyView and K.ClassicEconomyView.Invalidate then
  local ok,err=pcall(K.ClassicEconomyView.Invalidate);if not ok then K.ClassicEconomyView.error=tostring(err)end
 end
end
function E.Revision()return revision end
function E.Ready()return ready end
function E.Baseline()return baseline end
function E.Seed(value)
 if not Integer(value)then return false end
 local c,d,key=E.Current();if not c then return false end
 if storeRef~=d then storeRef=d;Prune(d)end
 baseline=math.floor(value);ready=true;c.balance=baseline;c.updated=Now();c.initial=c.initial or baseline
 E.Invalidate();return true
end
function E.Record(amount,source,meta)
 local recordStarted=ProfileClock()
 if type(amount)~='number'or amount==0 or amount~=math.floor(amount)or math.abs(amount)>1000000000000 then return false end
 local c,d,key=E.Current();if not c or not E.Active()then return false end
 meta=meta or{};source=E.index[source]and source or'other'
 local stamp=Now();local day=math.floor(stamp/86400);local transfer=meta.kind=='transfer'
 local index=(E.index[source]-1)*2+(amount>0 and 1 or 2)
 if d.lastPruneDay~=day then Prune(d)end
 if not c.days[day]then c.days[day]={};d.dayCount=(d.dayCount or 0)+1;if d.dayCount>E.MAX_DAYS then Prune(d)end end
 local bucket=c.days[day]
 if transfer then c.transfer=(c.transfer or 0)+amount;bucket[19]=(bucket[19]or 0)+amount
  if amount>0 then c.transferIn=(c.transferIn or 0)+amount;bucket[20]=(bucket[20]or 0)+amount else c.transferOut=(c.transferOut or 0)-amount;bucket[21]=(bucket[21]or 0)-amount end
 else c.all[index]=(c.all[index]or 0)+math.abs(amount);bucket[index]=(bucket[index]or 0)+math.abs(amount)end
 if not transfer then c.bigIn=math.max(c.bigIn or 0,amount);c.bigOut=math.max(c.bigOut or 0,-amount);bucket[22]=math.max(bucket[22]or 0,amount);bucket[23]=math.max(bucket[23]or 0,-amount)end
 if not transfer then c.maxIn=c.maxIn or{};c.maxOut=c.maxOut or{};c.maxIn[source]=math.max(c.maxIn[source]or 0,amount);c.maxOut[source]=math.max(c.maxOut[source]or 0,-amount);local i=E.index[source];bucket[22+i*2]=math.max(bucket[22+i*2]or 0,amount);bucket[23+i*2]=math.max(bucket[23+i*2]or 0,-amount)end
 c.events=c.events+1;c.updated=stamp
 local row={id=(d.totalRows or 0)+1,time=stamp,character=key,amount=amount,source=source,kind=Clean(meta.kind,24),item=Clean(meta.item),quantity=meta.quantity and math.min(10000,math.max(1,math.floor(meta.quantity))),peer=Clean(meta.peer),evidence=Clean(meta.evidence or'context',24)}
 local link=type(meta.itemLink)=='string'and meta.itemLink:match('(item:[^|]+)')or nil
 if link and #link<=256 and link:match('^item:%d+')then row.itemLink=link;row.itemID=tonumber(link:match('^item:(%d+)'))
 elseif Integer(meta.itemID)and meta.itemID==math.floor(meta.itemID)then row.itemID=meta.itemID end
 AddProduct(d,row)
 local previous=d.rows[((d.nextRow or 1)-2)%E.MAX_ROWS+1]
 if meta.batch and row.kind=='junk'and row.source=='vendor'and amount>0 and previous and previous.kind=='junk'and previous.batch==meta.batch and math.floor(previous.time/86400)==day then
  previous.amount=previous.amount+amount;previous.quantity=(previous.quantity or 0)+(row.quantity or 1);previous.time=stamp;metrics.mergedJunk=metrics.mergedJunk+1;metrics.records=metrics.records+1;local cost=ProfileClock()-recordStarted;metrics.recordMs=metrics.recordMs+cost;metrics.recordPeak=math.max(metrics.recordPeak,cost);E.Invalidate();return true
 end
 row.batch=Clean(meta.batch)
 if d.rowCount>=E.MAX_ROWS then metrics.rollovers=metrics.rollovers+1 end
 local slot=d.nextRow or 1;d.rows[slot]=row;d.nextRow=slot%E.MAX_ROWS+1;d.rowCount=math.min(E.MAX_ROWS,(d.rowCount or 0)+1);d.totalRows=(d.totalRows or 0)+1
 metrics.records=metrics.records+1;local cost=ProfileClock()-recordStarted;metrics.recordMs=metrics.recordMs+cost;metrics.recordPeak=math.max(metrics.recordPeak,cost);E.Invalidate();return true
end
function E.Observe(value,parts)
 if not Integer(value)then return false end
 if not ready then return E.Seed(value)end
 local previous=baseline;baseline=math.floor(value)
 local c=E.Current();if c then c.balance=baseline;c.updated=Now()end
 if not E.Active()then E.Invalidate();return false end
 local delta=baseline-previous;if delta==0 then return false end
 local sum=0;if type(parts)=='table'then for _,p in ipairs(parts)do if type(p.amount)~='number'then parts=nil;break end;sum=sum+p.amount end end
 if not parts or sum~=delta then parts={{amount=delta,source='other',evidence='unresolved'}}end
 for _,p in ipairs(parts)do E.Record(p.amount,p.source,p)end
 return true
end
function E.SetEnabled(value)
 local d=E.Store();if not d then return end
 d.enabled=value==true;baseline=nil;ready=false;if E.ClearIntents then E.ClearIntents()end
 if value then E.Seed(GetMoney())end
 E.Invalidate()
end
function E.IsOwn(name)
 if type(name)~='string'then return false end
 local d=E.Store();local me=E.Current();if not d or not me then return false end
 local target=name:gsub('%s',''):lower()
 for key,c in pairs(KAClassic_KerimAnkaUIDB.classicEconomyIdentities or{})do
  if key~=identity and c.realm==me.realm then
   if target==c.name:lower()or target==(c.name..'-'..c.realm):gsub('%s',''):lower()then return true end
  end
 end
 local wealth=KAClassic_KerimAnkaUIDB.bagWealth
 for key,c in pairs(wealth and wealth.characters or{})do if c.name~=me.name and c.realm==me.realm and type(c.name)=='string'and(target==c.name:lower()or target==(c.name..'-'..c.realm):gsub('%s',''):lower())then return true end end
 return false
end
function E.Report(days,character,enabled)
 local t=ProfileClock();local store=E.Store();local _,_,owner=E.Current();character=owner
 local mask='';for _,source in ipairs(E.sources)do mask=mask..((enabled and enabled[source]==false)and'0'or'1')end
 local cacheKey=tostring(revision)..':'..math.floor(Now()/86400)..':'..tostring(days)..':'..mask
 if reportCache[cacheKey]then metrics.cacheHits=metrics.cacheHits+1;return reportCache[cacheKey]end
 metrics.cacheMisses=metrics.cacheMisses+1
 local d=E.Store();local result={income=0,expense=0,balance=0,transfer=0,transferIn=0,transferOut=0,sources={},timeline={},rows={},productsIn={},productsOut={},days=days,started=d and d.started,totalRows=d and d.totalRows or 0}
 if not d then return result end
 local today=math.floor(Now()/86400);local first=days>0 and today-days+1 or nil;local timeline={};local selected={}
 for key,c in pairs(d.characters)do if character=='all'or character==key then
  selected[key]=true;result.balance=result.balance+(c.balance or 0);result.started=math.min(result.started or c.started,c.started)
  if c.condensed then result.condensed=true end
  if not first and(not enabled or enabled.mail~=false)then result.transfer=result.transfer+(c.transfer or 0);result.transferIn=result.transferIn+(c.transferIn or 0);result.transferOut=result.transferOut+(c.transferOut or 0)end
  local retained={}
  for day,values in pairs(c.days)do
   for index,value in pairs(values)do retained[index]=(retained[index]or 0)+value end
   if not first or day>=first then
    if first and(not enabled or enabled.mail~=false)then result.transfer=result.transfer+(values[19]or 0);result.transferIn=result.transferIn+(values[20]or 0);result.transferOut=result.transferOut+(values[21]or 0)end
    local row=timeline[day]or{time=day*86400,income=0,expense=0};timeline[day]=row
    for i,source in ipairs(E.sources)do if not enabled or enabled[source]~=false then
     local inc,out=values[i*2-1]or 0,values[i*2]or 0
     row.income=row.income+inc;row.expense=row.expense+out
     local group=result.sources[source]or{income=0,expense=0};result.sources[source]=group;group.income=group.income+inc;group.expense=group.expense+out
    end end
   end
  end
  if not first then
   for i,source in ipairs(E.sources)do if not enabled or enabled[source]~=false then
    local inc,out=math.max(0,(c.all[i*2-1]or 0)-(retained[i*2-1]or 0)),math.max(0,(c.all[i*2]or 0)-(retained[i*2]or 0))
    if inc+out>0 then local row=timeline[-1]or{time=-1,income=0,expense=0};timeline[-1]=row;row.income=row.income+inc;row.expense=row.expense+out
     local group=result.sources[source]or{income=0,expense=0};result.sources[source]=group;group.income=group.income+inc;group.expense=group.expense+out
    end
   end end
  end
 end end
 for _,group in pairs(result.sources)do result.income=result.income+group.income;result.expense=result.expense+group.expense end
 for _,row in pairs(timeline)do result.timeline[#result.timeline+1]=row end;table.sort(result.timeline,function(a,b)return a.time<b.time end)
 for _,row in pairs(d.rows)do if selected[row.character]and(not first or row.time>=first*86400)and(not enabled or enabled[row.source]~=false)then
  result.rows[#result.rows+1]=row


 end end
 table.sort(result.rows,function(a,b)if a.time==b.time then return(a.id or 0)>(b.id or 0)end;return a.time>b.time end)
 local maps={};if first then for day,map in pairs(d.productDays)do if day>=first then maps[#maps+1]=map end end else maps[1]=d.productAll end
 for _,map in ipairs(maps)do for key,p in pairs(map)do if not enabled or enabled[p.source]~=false then
  for i,target in ipairs({result.productsIn,result.productsOut})do local amount=i==1 and p.income or p.expense
   if amount>0 then local resultKey=p.itemLink or(p.itemID and tostring(p.itemID))or p.name;local v=target[resultKey]or{name=p.name,itemID=p.itemID,itemLink=p.itemLink,amount=0,quantity=0};target[resultKey]=v;v.amount=v.amount+amount;v.quantity=v.quantity+(i==1 and p.inQty or p.outQty)end
  end
 end end end
 result.bigIn=0;result.bigOut=0
 local c=d.characters[owner]
 for i,source in ipairs(E.sources)do if not enabled or enabled[source]~=false then
  if not first then result.bigIn=math.max(result.bigIn,c.maxIn[source]or 0);result.bigOut=math.max(result.bigOut,c.maxOut[source]or 0)
  else for day,values in pairs(c.days)do if day>=first then result.bigIn=math.max(result.bigIn,values[22+i*2]or 0);result.bigOut=math.max(result.bigOut,values[23+i*2]or 0)end end end
 end end
 result.productPartial=d.productPartial;result.legacySummary=d.legacySummary;result.test=d.test==true
 result.net=result.income-result.expense;result.cashChange=result.net+result.transfer;result.version=revision
 metrics.reports=metrics.reports+1;local elapsed=ProfileClock()-t;metrics.reportMs=metrics.reportMs+elapsed;metrics.reportPeak=math.max(metrics.reportPeak,elapsed)
 reportCache[cacheKey]=result;cacheOrder[#cacheOrder+1]=cacheKey;if #cacheOrder>4 then reportCache[table.remove(cacheOrder,1)]=nil end
 return result
end
function E.SummaryStats()
 local d=E.Store();if not d then return end
 local count,days=0,0;for _,c in pairs(d.characters)do count=count+1;for _ in pairs(c.days)do days=days+1 end end
 return{characters=count,days=days,rows=d.rowCount or 0,totalRows=d.totalRows or 0,ready=ready,revision=revision,fault=E.fault}
end
function E.Fault(message)
 E.fault=Clean(tostring(message),180)
 if not notified then notified=true;print('KerimAnka Economy: '..E.fault)end
end

-- Derived only from bounded report data. Never writes history or loads item data.
function E.Ranking(report,flow,grouping)
 local items={}
 if grouping=='sources'then
  for key,v in pairs(report.sources)do local amount=flow=='income'and v.income or v.expense
   if amount>0 then items[#items+1]={name=key,source=key,amount=amount}end
  end
 elseif grouping=='products'then
  for _,v in pairs(flow=='income'and report.productsIn or report.productsOut)do items[#items+1]=v end
 else
  for _,row in ipairs(report.rows)do
   if row.kind~='transfer'and(flow=='income'and row.amount>0 or flow=='expense'and row.amount<0)then items[#items+1]=row end
  end
 end
 return items
end
function E.SortRows(items,key,ascending,magnitude)
 -- Choose the numeric comparator once, without per-comparison key dispatch.
 local comparator
 if key=='quantity' then
  comparator=function(a,b)
   local av,bv=a.quantity or 0,b.quantity or 0
   if av~=bv then if ascending then return av<bv else return av>bv end end
   if (a.id or 0)~=(b.id or 0)then return(a.id or 0)>(b.id or 0)end
   return(a.name or a.item or a.source or'')<(b.name or b.item or b.source or'')
  end
 elseif key=='unit' then
  comparator=function(a,b)
   local av,bv=math.abs(a.amount)/(a.quantity or 1),math.abs(b.amount)/(b.quantity or 1)
   if av~=bv then if ascending then return av<bv else return av>bv end end
   if (a.id or 0)~=(b.id or 0)then return(a.id or 0)>(b.id or 0)end
   return(a.name or a.item or a.source or'')<(b.name or b.item or b.source or'')
  end
 elseif key=='time' then
  comparator=function(a,b)
   local av,bv=a.time or 0,b.time or 0
   if av~=bv then if ascending then return av<bv else return av>bv end end
   if (a.id or 0)~=(b.id or 0)then return(a.id or 0)>(b.id or 0)end
   return(a.name or a.item or a.source or'')<(b.name or b.item or b.source or'')
  end
 elseif magnitude then
  comparator=function(a,b)
   local av,bv=math.abs(a.amount),math.abs(b.amount)
   if av~=bv then if ascending then return av<bv else return av>bv end end
   if (a.id or 0)~=(b.id or 0)then return(a.id or 0)>(b.id or 0)end
   return(a.name or a.item or a.source or'')<(b.name or b.item or b.source or'')
  end
 else
  comparator=function(a,b)
   local av,bv=a.amount,b.amount
   if av~=bv then if ascending then return av<bv else return av>bv end end
   if (a.id or 0)~=(b.id or 0)then return(a.id or 0)>(b.id or 0)end
   return(a.name or a.item or a.source or'')<(b.name or b.item or b.source or'')
  end
 end
 table.sort(items,comparator);return items
end

-- Search only stored names; no item API, inventory scan or history writes.
local searchCase={['İ']='i',['ı']='i',['Ğ']='ğ',['Ü']='ü',['Ş']='ş',['Ö']='ö',['Ç']='ç',['Ä']='ä',['É']='é',['ẞ']='ß'}
local function FoldSearchChar(ch)return searchCase[ch]or ch end
function E.SearchText(text)
 local normalized=tostring(text or ''):lower():gsub('[\194-\244][\128-\191]*',FoldSearchChar)
 return normalized
end
function E.Diagnostics()
 local d=E.Store();local result=Copy(metrics)
 local v=K.ClassicEconomyView or{};result.uiDraws=v.draws or 0;result.uiMs=v.drawTotal or 0;result.uiPeak=v.peakDraw or 0;result.listBuilds=v.listBuilds or 0;result.listMs=v.listMs or 0;result.listPeak=v.listPeak or 0;result.listCacheHits=v.listCacheHits or 0
 result.searchBuilds=v.searchBuilds or 0;result.searchMs=v.searchMs or 0;result.searchPeak=v.searchPeak or 0
 result.version=2;result.rows=d and d.rowCount or 0;result.rowLimit=E.MAX_ROWS;result.productEntries=d and d.productCount or 0;result.productLimit=E.MAX_PRODUCT_ENTRIES;result.test=d and d.test==true;result.owner=d and d.owner;result.ready=ready;result.fault=E.fault
 return result
end
_G.KerimAnkaEconomyDiagnostics=E.Diagnostics
