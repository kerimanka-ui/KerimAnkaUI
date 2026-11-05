-- Economy settings view. Widgets are pooled; no OnUpdate or work while hidden.
local _,K=...;local E=K.ClassicEconomy;if not E then return end
local V={draws=0};K.ClassicEconomyView=V
local pane,viewport,clip,scrollbar,textLayer;local scrollOffset=0;local scrollMaximum=0;local syncingScroll=false
local SyncViewport
local labels,buttons,bars={},{},{};local usedL,usedB=0,0
local period,character,filters,mode=30,nil,{},'overview'
local sortKey,ascending='time',false
local pageIndex=1;local chartIn,chartOut=true,true;local range;local queued=false;local generation=0
local gold={.88,.78,.49};local muted={.63,.69,.63};local green={.51,.80,.61};local red={.90,.56,.48}
local showHelp=false;local reflowQueued=false
local function ViewError(err)
 V.error=tostring(err)
 if V.lastError~=V.error then print('KA Economy UI: '..V.error);V.lastError=V.error end
end
local function Money(value)
 local prefix=value<0 and '-'or'';value=math.floor(math.abs(value))
 return prefix..math.floor(value/10000)..'g '..math.floor(value%10000/100)..'s '..(value%100)..'c'
end
local function Label(value,x,y,width,size,color)
 usedL=usedL+1;local t=labels[usedL]
 if not t then t=textLayer:CreateFontString(nil,'OVERLAY','GameFontNormal');labels[usedL]=t;t:SetJustifyH('LEFT');t:SetJustifyV('TOP')end
 t:SetJustifyH('LEFT');t:ClearAllPoints();t:SetPoint('TOPLEFT',x,y);t:SetWidth(width);t:SetHeight(size<=12 and 38 or 28)
 K.ApplyTextFont(t,size,false,'');t:SetTextColor(unpack(color or muted));t:SetText(value);t:Show();return t
end
-- Match Classic PixelUtil's 768-height UI coordinate convention.
local function PixelUnit(frame,pixels)
 local scale=frame.GetEffectiveScale and frame:GetEffectiveScale()or 1
 scale=type(scale)=='number'and scale>0 and scale or 1
 local factor
 if PixelUtil and PixelUtil.GetPixelToUIUnitFactor then factor=PixelUtil.GetPixelToUIUnitFactor()
 elseif GetPhysicalScreenSize then local _,height=GetPhysicalScreenSize();if height and height>0 then factor=768/height end end
 factor=type(factor)=='number'and factor>0 and factor or 1
 return pixels*factor/scale
end
local function Nearest(frame,value,minimum)
 local pixel=PixelUnit(frame,1)
 local count=math.floor(value/pixel+.5)
 return math.max(minimum or 0,count)*pixel
end
local function Smooth(texture)
 if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0)end
 if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(false)end
end
-- Two full rectangles avoid fragile, independently snapped one-pixel edges.
local surfaces=setmetatable({},{__mode='k'})
local function FitSurface(frame)
 local parts=frame.kaEconomySurface
 if not parts then return end
 local inset=PixelUnit(frame,2)
 parts[1]:ClearAllPoints();parts[1]:SetAllPoints(frame)
 parts[2]:ClearAllPoints();parts[2]:SetPoint('TOPLEFT',frame,'TOPLEFT',inset,-inset)
 parts[2]:SetPoint('BOTTOMRIGHT',frame,'BOTTOMRIGHT',-inset,inset)
end
local function Surface(frame,r,g,b,edge)
 local parts=frame.kaEconomySurface
 if not parts then
  parts={frame:CreateTexture(nil,'BACKGROUND',nil,0),frame:CreateTexture(nil,'BACKGROUND',nil,1)}
  frame.kaEconomySurface=parts;surfaces[frame]=true
  for _,texture in ipairs(parts)do Smooth(texture)end
 end
 frame:SetBackdrop(nil)
 if frame.roundedLayers then for _,layer in pairs(frame.roundedLayers)do for _,t in ipairs(layer)do t:Hide()end end end
 local border=edge or{.29,.34,.29,1}
 parts[1]:SetColorTexture(border[1],border[2],border[3],border[4]or 1)
 parts[2]:SetColorTexture(r,g,b,1)
 for _,texture in ipairs(parts)do texture:Show()end
 FitSurface(frame)
end
local function Paint(b,selected)
 Surface(b,selected and .19 or .10,selected and .22 or .13,selected and .15 or .11,selected and gold or{.29,.34,.29},4,false)
end
local function Button(value,x,y,width,height,click,selected)
 usedB=usedB+1;local b=buttons[usedB]
 if not b then
  b=CreateFrame('Button',nil,pane,'BackdropTemplate');b:SetFrameLevel(pane:GetFrameLevel()+3);buttons[usedB]=b
  b.label=b:CreateFontString(nil,'OVERLAY','GameFontNormal');b.label:SetPoint('CENTER');b.label:SetJustifyH('CENTER')
 end
 b:SetFrameLevel(pane:GetFrameLevel()+3);b:SetAlpha(1);b.label:SetJustifyH('CENTER');b:SetScript('OnEnter',nil);b:SetScript('OnLeave',nil);b:ClearAllPoints();b:SetPoint('TOPLEFT',x,y);b:SetSize(width,height);Paint(b,selected)
 K.ApplyTextFont(b.label,12,false,'');b.label:SetWidth(width-10);b.label:SetTextColor(unpack(selected and gold or muted));b.label:SetWordWrap(false);b.label:SetText(value)
 b:SetScript('OnClick',function()local ok,err=pcall(click);if not ok then ViewError(err)end end);b:Show();return b
end
local function Rerender()pageIndex=1;range=nil;scrollOffset=0;V.Render()end
local function Date(stamp)return stamp<0 and E.L('old')or date('!%d.%m.%Y',stamp)end
local infoTip
local function HideTip()
 if infoTip then infoTip:Hide()end;GameTooltip:Hide()
end
local function Tip(owner,title,body)
 if not infoTip then
  infoTip=CreateFrame('Frame',nil,UIParent,'BackdropTemplate');infoTip:SetFrameStrata('TOOLTIP');infoTip:SetClampedToScreen(true)
  infoTip.title=infoTip:CreateFontString(nil,'OVERLAY','GameFontNormal')
  infoTip.body=infoTip:CreateFontString(nil,'OVERLAY','GameFontNormal')
  for _,t in ipairs({infoTip.title,infoTip.body})do t:SetJustifyH('LEFT');t:SetJustifyV('TOP')end
 end
 GameTooltip:Hide();infoTip:ClearAllPoints();infoTip:SetPoint('BOTTOMLEFT',owner,'TOPLEFT',0,6)
 infoTip:SetSize(340,body and 110 or 50);Surface(infoTip,.08,.10,.09,{.40,.44,.38},4,false)
 K.ApplyTextFont(infoTip.title,13,false,'');infoTip.title:SetPoint('TOPLEFT',10,-10);infoTip.title:SetWidth(320);infoTip.title:SetHeight(32);infoTip.title:SetTextColor(unpack(gold));infoTip.title:SetText(title)
 K.ApplyTextFont(infoTip.body,12,false,'');infoTip.body:SetPoint('TOPLEFT',10,-42);infoTip.body:SetWidth(320);infoTip.body:SetHeight(60);infoTip.body:SetTextColor(unpack(muted));infoTip.body:SetText(body or'')
 infoTip:Show()
end
local chooser,chooserDismiss
local plot
local function FitPlot()
 if not plot then return end
 local levels={0,47,94}
 for i,texture in ipairs(plot.grid)do
  texture:ClearAllPoints();texture:SetPoint('BOTTOMLEFT',plot,'BOTTOMLEFT',0,Nearest(plot,levels[i]))
  texture:SetSize(690,PixelUnit(plot,i==1 and 2 or 1))
 end
end
local function FitChart(bar)
 local values=bar.kaChartValues
 if not values then return end
 for n,texture in ipairs({bar.a,bar.b})do
  local amount=values[n]
  Smooth(texture)
  texture:SetSize(Nearest(bar,bar.kaChartWidth,2),Nearest(bar,amount/bar.kaChartMaximum*94,2))
  texture:SetShown(amount>0 and(n==1 and chartIn or n==2 and chartOut))
 end
end
local function Graph(report,y)
 Label(E.L('chart'),8,y,690,16,gold);y=y-24
 local input=report.timeline;local groups={};local first=period>0 and math.floor(E.Now()/86400)-period+1 or nil
 if first then
  local lookup={};for _,r in ipairs(input)do lookup[math.floor(r.time/86400)]=r end
  local size=math.max(1,math.ceil(period/30))
  for start=first,first+period-1,size do
   local g={first=start*86400,last=math.min(first+period,start+size)*86400-1,income=0,expense=0}
   for day=start,math.min(first+period-1,start+size-1)do local r=lookup[day];if r then g.income=g.income+r.income;g.expense=g.expense+r.expense end end;groups[#groups+1]=g
  end
 else
  local size=math.max(1,math.ceil(#input/30))
  for i=1,#input,size do local g={first=input[i].time,last=input[math.min(#input,i+size-1)].time+86399,income=0,expense=0}
   for j=i,math.min(#input,i+size-1)do g.income=g.income+input[j].income;g.expense=g.expense+input[j].expense end;groups[#groups+1]=g
  end
 end
 local maximum=1;for _,g in ipairs(groups)do maximum=math.max(maximum,chartIn and g.income or 0,chartOut and g.expense or 0)end
 if not plot then
  plot=CreateFrame('Frame',nil,pane);plot:SetFrameLevel(pane:GetFrameLevel());plot:EnableMouse(false);plot.grid={}
  for i=1,3 do
   local texture=plot:CreateTexture(nil,'BACKGROUND');Smooth(texture)
   texture:SetColorTexture(.30,.34,.30,i==1 and .9 or .35);plot.grid[i]=texture
  end
 end
 plot:ClearAllPoints();plot:SetPoint('TOPLEFT',8,y);plot:SetSize(690,100);FitPlot();plot:Show()
 local width=690/math.max(1,#groups)
 for i,g in ipairs(groups)do
  local b=bars[i];if not b then
   b=CreateFrame('Button',nil,pane);bars[i]=b;b.a=b:CreateTexture(nil,'ARTWORK');b.b=b:CreateTexture(nil,'ARTWORK')
   b.a:SetColorTexture(unpack(green));b.b:SetColorTexture(unpack(red));b:SetScript('OnLeave',HideTip)
  end
  b:ClearAllPoints();b:SetPoint('TOPLEFT',8+(i-1)*width,y);b:SetSize(width,100)
  local w=math.max(2,(width-6)/2)
  b.kaChartValues={g.income,g.expense};b.kaChartMaximum=maximum;b.kaChartWidth=w
  for n,t in ipairs({b.a,b.b})do
   t:ClearAllPoints();t:SetPoint('BOTTOMLEFT',(n-1)*(w+1),0)
   Smooth(t)
  end
  FitChart(b)
  b:SetScript('OnEnter',function()Tip(b,Date(g.first)..' - '..Date(g.last),E.L('income')..': '..Money(g.income)..'\n'..E.L('expense')..': '..Money(g.expense))end)
  b:SetScript('OnClick',function()range={first=g.first,last=g.last};mode='recent';sortKey='time';ascending=false;pageIndex=1;V.Render()end);b:Show()
 end
 Label(#groups>0 and(Date(groups[1].first)..'  —  '..Date(groups[#groups].last))or E.L('empty'),8,y-106,690,12)
 return y-132
end
local fills={};local usedF=0
local function FitSource(pair)
 pair[1]:SetSize(690,Nearest(pane,6,3))
 pair[2]:SetSize(Nearest(pane,pair.amountWidth,2),Nearest(pane,6,3))
end
local function SourceBar(x,y,width,color)
 usedF=usedF+1;local pair=fills[usedF]
 if not pair then
  pair={pane:CreateTexture(nil,'BACKGROUND'),pane:CreateTexture(nil,'ARTWORK')};fills[usedF]=pair
  for _,t in ipairs(pair)do Smooth(t) end
 end
 pair.amountWidth=width
 for _,t in ipairs(pair)do t:ClearAllPoints();t:SetPoint('TOPLEFT',x,y);t:Show()end
 FitSource(pair)
 pair[1]:SetColorTexture(.17,.21,.18,1);pair[2]:SetColorTexture(color[1],color[2],color[3],1)
end
-- Small pooled monochrome strokes; no font glyph, atlas or animation.
local symbols={
 income={{2,14,7,9},{7,9,10,11},{10,11,16,4},{11,4,16,4},{16,4,16,9}},
 expense={{2,4,7,9},{7,9,10,7},{10,7,16,14},{11,14,16,14},{16,14,16,9}},
 net={{2,5,16,5},{12,2,16,5},{12,8,16,5},{16,13,2,13},{6,10,2,13},{6,16,2,13}},
 balance={{5,2,11,2},{11,2,15,6},{15,6,15,12},{15,12,11,16},{11,16,5,16},{5,16,1,12},{1,12,1,6},{1,6,5,2},{8,5,8,13}}
}
local function Symbol(owner,kind,x,y,color)
 owner.symbolParts=owner.symbolParts or{}
 local shape=symbols[kind]
 for i,line in ipairs(shape)do
  local t=owner.symbolParts[i]
  if not t then t=owner:CreateTexture(nil,'OVERLAY');owner.symbolParts[i]=t
   Smooth(t)
  end
  local dx,dy=line[3]-line[1],line[4]-line[2]
  t:ClearAllPoints();t:SetPoint('CENTER',owner,'TOPLEFT',x+(line[1]+line[3])/2,-y-(line[2]+line[4])/2)
  t:SetSize(math.sqrt(dx*dx+dy*dy),1.4);t:SetRotation(math.atan2(-dy,dx));t:SetColorTexture(color[1],color[2],color[3],1);t:Show()
 end
 for i=#shape+1,#owner.symbolParts do owner.symbolParts[i]:Hide()end
end
local panels={};local usedP=0
local function Panel(x,y,width,height,color)
 usedP=usedP+1;local f=panels[usedP]
 if not f then f=CreateFrame('Frame',nil,pane,'BackdropTemplate');panels[usedP]=f;f:EnableMouse(false)end
 f:ClearAllPoints();f:SetPoint('TOPLEFT',x,y);f:SetSize(width,height)
 Surface(f,.10,.125,.11,color or{.24,.28,.25},4,false);f:Show()
 if f.symbolParts then for _,t in ipairs(f.symbolParts)do t:Hide()end end
 -- Decorative frames stay below both the pane's labels and its buttons.
 f:SetFrameLevel(pane:GetFrameLevel()+1);return f
end
local grouping='sources'
local searchBox;local searchQuery='';local searchTicket=0;local searchSync=false
local sortedCache
local function AscendingTime(rows)
 local result={};local last=#rows
 while last>0 do local first=last
  while first>1 and rows[first-1].time==rows[last].time do first=first-1 end
  for i=first,last do result[#result+1]=rows[i]end;last=first-1
 end
 return result
end
local function SortedItems(report,isRecent,flow)
 if not sortedCache or sortedCache.report~=report then sortedCache={report=report,entries={},order={},search={}}end
 local key=mode..':'..grouping..':'..sortKey..':'..tostring(ascending)..':'..(range and(range.first..':'..range.last)or'all')
 local cached=sortedCache.entries[key]
 if cached then V.listCacheHits=(V.listCacheHits or 0)+1;return cached end
 local started=debugprofilestop and debugprofilestop()or 0;local items={}
 if isRecent then
  if sortKey=='time'and not range then
   if not ascending then items=report.rows else items=AscendingTime(report.rows)end
  else
   for _,row in ipairs(report.rows)do if not range or(row.time>=range.first and row.time<=range.last)then items[#items+1]=row end end
   if sortKey~='time'then E.SortRows(items,sortKey,ascending,false)
   elseif ascending then items=AscendingTime(items)end
  end
 else items=E.SortRows(E.Ranking(report,flow,grouping),sortKey,ascending,true)end
 local elapsed=(debugprofilestop and debugprofilestop()or started)-started
 V.listBuilds=(V.listBuilds or 0)+1;V.listMs=(V.listMs or 0)+elapsed;V.listPeak=math.max(V.listPeak or 0,elapsed)
 sortedCache.entries[key]=items;sortedCache.order[#sortedCache.order+1]=key
 if #sortedCache.order>4 then sortedCache.entries[table.remove(sortedCache.order,1)]=nil end
 return items
end


local function SearchItems(items)
 if searchQuery==''then return items end
 local key=tostring(items)..':'..searchQuery
 if sortedCache.filteredKey==key then return sortedCache.filtered end
 local result={};local started=debugprofilestop and debugprofilestop()or 0
 for _,row in ipairs(items)do
  local text=sortedCache.search[row]
  if not text then text=E.SearchText((row.item or row.name or '')..' '..(row.peer or '')..' '..E.L(row.source or ''));sortedCache.search[row]=text end
  if text:find(searchQuery,1,true)then result[#result+1]=row end
 end
 sortedCache.filteredKey=key;sortedCache.filtered=result
 local cost=(debugprofilestop and debugprofilestop()or started)-started
 V.searchBuilds=(V.searchBuilds or 0)+1;V.searchMs=(V.searchMs or 0)+cost;V.searchPeak=math.max(V.searchPeak or 0,cost)
 return result
end
local function SearchControl(y)
 if not searchBox then
  searchBox=CreateFrame('EditBox',nil,pane,'BackdropTemplate');searchBox:SetAutoFocus(false);searchBox:SetMaxLetters(80)
  searchBox:SetTextInsets(8,8,0,0);searchBox:SetFrameLevel(pane:GetFrameLevel()+3)
  searchBox.hint=searchBox:CreateFontString(nil,'OVERLAY','GameFontNormal');searchBox.hint:SetPoint('LEFT',8,0);searchBox.hint:SetJustifyH('LEFT')
  searchBox:SetScript('OnEscapePressed',function(self)self:ClearFocus()end)
  local function ApplySearch()
   local query=E.SearchText((searchBox:GetText()or''):match('^%s*(.-)%s*$'))
   if query~=searchQuery then searchQuery=query;pageIndex=1;HideTip();V.Render()end
  end
  searchBox:SetScript('OnEnterPressed',function(self)searchTicket=searchTicket+1;ApplySearch();self:ClearFocus()end)
  searchBox:SetScript('OnTextChanged',function()
   searchBox.hint:SetShown((searchBox:GetText()or'')=='')
   if searchSync then return end
   searchTicket=searchTicket+1;local ticket,token=searchTicket,generation
   C_Timer.After(.25,function()
    if ticket~=searchTicket or token~=generation or not V.active or not pane:IsVisible()then return end
    ApplySearch()
   end)
  end)
 end
 searchBox:ClearAllPoints();searchBox:SetPoint('TOPLEFT',8,y);searchBox:SetSize(532,28)
 Surface(searchBox,.07,.09,.08,{.29,.34,.29},4,false);K.ApplyTextFont(searchBox,12,false,'');searchBox:SetTextColor(unpack(gold));searchBox:Show()
 K.ApplyTextFont(searchBox.hint,12,false,'');searchBox.hint:SetText(E.L('searchPlaceholder'));searchBox.hint:SetTextColor(unpack(muted));searchBox.hint:SetShown((searchBox:GetText()or'')=='')
 Button(E.L('clearSearch'),550,y,148,28,function()
  searchTicket=searchTicket+1;searchQuery='';searchSync=true;searchBox:SetText('');searchSync=false;pageIndex=1;V.Render()
 end)
 Label(E.L('searchHelp'),8,y-34,690,11)
 return y-64
end

local function Sort(key)
 if sortKey==key then ascending=not ascending else sortKey=key;ascending=false end
 pageIndex=1;V.Render()
end
local function Header(key,title,x,y,width)
 return Button(title..(sortKey==key and(ascending and' +'or' -')or''),x,y,width,26,function()Sort(key)end,sortKey==key)
end
local function ModifiedItemLink(row)
 if not(IsModifiedClick and IsModifiedClick())and not(IsShiftKeyDown and IsShiftKeyDown())then return false end
 local raw=row.itemLink or(row.itemID and('item:'..row.itemID));if not raw then return false end
 local name,link
 local get=C_Item and C_Item.GetItemInfo or GetItemInfo
 if get then local ok,a,b=pcall(get,raw);if ok then name,link=a,b end end
 name=name or row.item or row.name or('Item '..tostring(row.itemID or''))
 link=link or('|H'..raw..'|h['..name:gsub('|','||')..']|h')
 if HandleModifiedItemClick then local ok,handled=pcall(HandleModifiedItemClick,link);if ok and handled then return true end end
 if IsShiftKeyDown and IsShiftKeyDown()then
  local edit=ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow()
  if edit and ChatEdit_InsertLink then local ok,handled=pcall(ChatEdit_InsertLink,link);if ok and handled then return true end end
  -- Filling the visible Classic AH search field never starts a query or a purchase.
  if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible()and BrowseName and BrowseName.SetText then BrowseName:SetText(name);return true end
 end
 return false
end
local function ItemPreview(owner,row)
 if ModifiedItemLink(row)then return end
 local link=row.itemLink or(row.itemID and('item:'..row.itemID))
 if not link then Tip(owner,E.L('previewUnavailable'),E.L('previewHelp'));return end
 GameTooltip:SetOwner(owner,'ANCHOR_RIGHT')
 local ok=pcall(GameTooltip.SetHyperlink,GameTooltip,link)
 if ok then GameTooltip:Show()else GameTooltip:Hide();Tip(owner,E.L('previewUnavailable'))end
end
local function Detail(row,d)
 local c=d and d.characters[row.character]
 local kind=({transfer='transferKind',junk='junk',deposit='deposit',postage='postage',refund='refund',flight='flight',training='training'})[row.kind]
 local title=(c and c.name or'?')..' / '..E.L(kind or row.source)
 if row.item then title=title..' / '..row.item end
 if row.peer then title=title..' > '..row.peer end
 if row.evidence~='matched'then title=title..' *'end
 return title
end
function V.Render(keepPosition)
 if not pane or not pane:IsShown()then return end
 HideTip()
 if searchBox and mode=='overview'then searchTicket=searchTicket+1;searchBox:Hide();searchBox:ClearFocus()end
 if not character then local _,_,key=E.Current();character=key or'all'end
 local started=debugprofilestop and debugprofilestop()or 0
 for _,t in ipairs(labels)do t:Hide()end;for _,f in ipairs(buttons)do f:Hide()end;for _,f in ipairs(bars)do f:Hide()end;for _,f in ipairs(panels)do f:Hide()end
 for _,pair in ipairs(fills)do for _,t in ipairs(pair)do t:Hide()end end
 if plot then plot:Hide()end
 usedL,usedB,usedP,usedF=0,0,0,0;V.draws=V.draws+1;V.error=nil
 local report=E.Report(period,character,filters);local d=E.Store();local active=E.Active()
 local name=E.L('all');if character~='all'and d and d.characters[character]then local c=d.characters[character];name=c.name..' - '..c.realm end
 Panel(8,0,448,30,{.29,.34,.29});Label(name,20,-8,420,13,gold)
 local record=Button(E.L(active and'pauseAction'or'resumeAction'),466,0,232,30,function()E.SetEnabled(not E.Active());V.Render()end)
 record:SetScript('OnEnter',function()Tip(record,E.L(active and'on'or'paused'),E.L('recordHelp'))end);record:SetScript('OnLeave',HideTip)
 for i,days in ipairs({1,7,30,90,180,270,365,0})do Button(E.L('day'..days),8+(i-1)*86.5,-40,82.5,27,function()period=days;Rerender()end,period==days)end
 Symbol(pane,'balance',8,79,gold)
 Label(E.L('balance')..': '..Money(report.balance),32,-80,666,17,gold)
 for i,entry in ipairs({{'income',report.income,green},{'expense',report.expense,red},{'net',report.net,gold}})do
  local x=8+(i-1)*234;local card=Panel(x,-110,222,70,entry[3])
  Symbol(card,entry[1],8,9,entry[3])
  local title=Label(E.L(entry[1]),x+32,-120,180,11,entry[3]);title:SetHeight(25);title:SetWordWrap(true)
  Label(Money(entry[2]),x+12,-148,198,18,entry[3])
 end
 Label(E.L('cashChange')..': '..Money(report.cashChange),8,-192,690,13,gold)
 Label(E.L('transfer')..': '..Money(report.transfer),8,-214,690,11)
 Label(E.L('transferIn')..': '..Money(report.transferIn)..'   |   '..E.L('transferOut')..': '..Money(report.transferOut),8,-233,690,11)
 Label(E.L(report.productPartial and'productPartial'or'detailLimit'),8,-252,690,11,report.productPartial and gold or muted)
 Label(E.L('localTimeHelp'),8,-270,690,10)
 local sourceKeys={'reset'};for _,source in ipairs(E.sources)do sourceKeys[#sourceKeys+1]=source end
 local all=true;for _,source in ipairs(E.sources)do if filters[source]==false then all=false end end
 for i,source in ipairs(sourceKeys)do
  local chosen=source=='reset'and all or source~='reset'and not all and filters[source]~=false
  Button(E.L(source),8+((i-1)%5)*140,-288-math.floor((i-1)/5)*29,134,25,function()
   if source=='reset'then filters={}
   elseif IsShiftKeyDown and IsShiftKeyDown()then filters[source]=filters[source]==false
   else local solo=true;for _,key in ipairs(E.sources)do if(key==source and filters[key]==false)or(key~=source and filters[key]~=false)then solo=false end end
    if solo then filters={}else for _,key in ipairs(E.sources)do filters[key]=key==source end end
   end;Rerender()
  end,chosen)
 end
 Label(E.L('filterHelp'),8,-349,690,11)
 local y=-380
 for i,key in ipairs({'overview','recent','sales','purchases'})do Button(E.L(key),8+(i-1)*175,y,168,29,function()mode=key;pageIndex=1;sortKey=key=='recent'and'time'or'amount';ascending=false;V.Render(true)end,mode==key)end
 y=y-43
 if mode=='overview'then
  y=Graph(report,y)
  Button(E.L('graphIn'),8,y,340,26,function()chartIn=not chartIn;V.Render()end,chartIn)
  Button(E.L('graphOut'),358,y,340,26,function()chartOut=not chartOut;V.Render()end,chartOut);y=y-40
  local biggestIn,biggestOut=report.bigIn or 0,report.bigOut or 0

  local elapsed=math.max(1,math.floor(E.Now()/86400)-math.floor((report.started or E.Now())/86400)+1)
  local divisor=period>0 and math.min(period,elapsed)or elapsed
  for i,stat in ipairs({{'bigIn',biggestIn},{'bigOut',biggestOut},{'average',report.net/divisor}})do
   local x=8+(i-1)*234;Label(E.L(stat[1]),x,y,222,12);Label(Money(stat[2]),x,y-20,222,15,gold)
  end;y=y-45;Label(E.L('rankLimit'),8,y,690,11);y=y-40
  -- Full retained/lifetime source aggregates, unlike item rankings, survive row eviction.
  for _,flow in ipairs({'income','expense'})do
   Label(E.L(flow)..' / '..E.L('sourceDistribution'),8,y,690,15,flow=='income'and green or red);y=y-28
   local ranking=E.SortRows(E.Ranking(report,flow,'sources'),'amount',false,true)
   local total=flow=='income'and report.income or report.expense
   for _,r in ipairs(ranking)do
    Label(E.L(r.source),8,y,270,12);Label(Money(r.amount)..'  ('..math.floor(r.amount/math.max(1,total)*100+.5)..'%)',390,y,308,12):SetJustifyH('RIGHT')
    SourceBar(8,y-19,690*r.amount/math.max(1,total),flow=='income'and green or red);y=y-35
   end
   if #ranking==0 then Label(E.L('empty'),8,y,690,12);y=y-30 end
  end
 else
  local isRecent=mode=='recent';local flow=mode=='sales'and'income'or'expense'
  if not isRecent then
   for i,key in ipairs({'sources','products','transactions'})do Button(E.L(key),8+(i-1)*234,y,222,27,function()grouping=key;sortKey='amount';ascending=false;pageIndex=1;V.Render(true)end,grouping==key)end
   y=y-38
  end
  y=SearchControl(y)
  local items=SearchItems(SortedItems(report,isRecent,flow))
  if range and isRecent then Button(Date(range.first)..' - '..Date(range.last)..'   X',8,y,690,28,function()range=nil;pageIndex=1;V.Render()end,true);y=y-37 end
  local product=not isRecent and grouping=='products'
  local source=not isRecent and grouping=='sources'
  local firstKey=product and'quantity'or'time'
  if source then Label('#',16,y-5,100,12)else Header(firstKey,E.L(product and'quantity'or'date'),8,y,126)end
  Label(E.L(source and'sourceDistribution'or'detail'),145,y-5,340,12)
  if product then Header('unit',E.L('unit'),402,y,128)end
  Header('amount',E.L('amount'),550,y,148);y=y-32
  local size=math.max(5,math.min(12,math.floor(((clip and clip:GetHeight()or 415)-140)/34)))
  local pages=math.max(1,math.ceil(#items/size));pageIndex=math.min(pageIndex,pages)
  if #items==0 then Label(E.L(searchQuery~=''and'searchEmpty'or'empty'),8,y,690,13);y=y-34 end
  for i=(pageIndex-1)*size+1,math.min(#items,pageIndex*size)do
   local row=items[i];local title,stamp
   if source then title=E.L(row.source);stamp=tostring(i)
   elseif product then title=row.name;stamp=tostring(row.quantity or 0)..' x'
   else title=Detail(row,d);stamp=date('%d.%m %H:%M',row.time)end
   Panel(8,y,690,33,i%2==0 and{.20,.24,.21}or{.14,.18,.15})
   Label(stamp,16,y-7,120,12)
   local label=Label(title,145,y-7,product and 245 or 385,12);label:SetHeight(24)
   if row.itemLink or row.itemID then
    label:SetTextColor(unpack(gold))
    local hit;hit=Button('',140,y,product and 250 or 395,33,function()HideTip();ItemPreview(hit,row)end)
    -- No eager item lookups; only the click opens Blizzard's item tooltip.
    Surface(hit,.10,.125,.11,{.23,.28,.24},3,false)
    hit:SetAlpha(.01)
    hit:SetScript('OnEnter',function()Tip(hit,E.L('previewTitle'),E.L('previewHelp'))end);hit:SetScript('OnLeave',HideTip)
   end
   local amount
   -- Preserve signed values in recent transactions; expense ranks show negative cash.
   amount=row.amount;if not isRecent then amount=flow=='expense'and-math.abs(row.amount)or math.abs(row.amount)end
   Label(Money(amount),550,y-7,140,12,amount>=0 and green or red):SetJustifyH('RIGHT')
   if product then Label(Money(row.amount/math.max(1,row.quantity or 1)),402,y-7,128,12):SetJustifyH('RIGHT')end
   y=y-34
  end
  Button(E.L('previous'),8,y-5,150,29,function()pageIndex=math.max(1,pageIndex-1);V.Render()end)
  Label(pageIndex..' / '..pages,185,y-11,180,13)
  Button(E.L('next'),548,y-5,150,29,function()pageIndex=math.min(pages,pageIndex+1);V.Render()end);y=y-49
  Label(E.L(source and'sourceHelp'or grouping=='products'and'productHelp'or'detailLimit'),8,y,690,11);y=y-37
 end
 Button(E.L('helpToggle'),8,y,690,28,function()showHelp=not showHelp;V.Render()end,showHelp);y=y-40
 if showHelp then
  for _,key in ipairs({'cashHelp','retention','startHelp','evidenceHelp','transferHelp','localTimeHelp'})do Label(E.L(key),8,y,690,12);y=y-52 end
 end
 if not active then Label(E.L('recordHelp'),8,y,690,11,gold);y=y-40 end
 if report.condensed then Label(E.L('condensed'),8,y,690,12,gold);y=y-50 end
 if E.fault then Label(E.L('fault')..E.fault,8,y,690,12,red);y=y-50 end
 -- Preserve the clicked navigation row even when the new list is shorter.
 -- Only navigation reserves the visible tail; normal rendering retains clamping.
 local height=-y+20
 if keepPosition and clip then height=math.max(height,scrollOffset+math.max(1,clip:GetHeight()))end
 pane:SetHeight(height);if SyncViewport then SyncViewport()end
 local elapsed=(debugprofilestop and debugprofilestop()or started)-started;V.drawTotal=(V.drawTotal or 0)+elapsed;V.peakDraw=math.max(V.peakDraw or 0,elapsed)
 local diag=_G.KerimAnkaDiagnostics;if diag and diag.captureScopes then diag.RecordScope('Economy.UI',elapsed)end
end

function V.Suspend()
 HideTip()
 -- Parent visibility already hides children. Do not leave the pane explicitly hidden.
 generation=generation+1;searchTicket=searchTicket+1;queued=false;reflowQueued=false
 if searchBox then searchBox:ClearFocus()end
 local owner=GameTooltip.GetOwner and GameTooltip:GetOwner()
 if owner and owner.GetParent and owner:GetParent()==pane then GameTooltip:Hide()end
 if chooser then chooser:Hide();chooserDismiss:Hide()end
end
function V.Hide()
 V.active=false;V.Suspend();if viewport then viewport:Hide()end;if pane then pane:Hide()end
 if K.scroll and K.scroll.ScrollBar then K.scroll.ScrollBar:SetShown(K.scroll:GetVerticalScrollRange()>0)end
end
function V.Visibility()
 return pane and pane:IsShown()or false,pane and pane:IsVisible()or false
end
-- This view deliberately does not live in the shared ScrollFrame's scroll child.
-- Move a pooled content frame inside an ordinary clipped viewport instead. The
-- native panel scale can then change without recycling a ScrollFrame render target.
local function SetOffset(value,userScroll)
 local nextOffset=math.max(0,math.min(scrollMaximum,tonumber(value)or 0))
 if userScroll or nextOffset~=scrollOffset then
  HideTip();if chooser then chooser:Hide();chooserDismiss:Hide()end
 end
 scrollOffset=nextOffset
 pane:ClearAllPoints();pane:SetPoint('TOPLEFT',clip,'TOPLEFT',0,Nearest(pane,scrollOffset))
 if scrollbar and not syncingScroll then
  syncingScroll=true;scrollbar:SetValue(scrollOffset);syncingScroll=false
 end
end
SyncViewport=function()
 if not viewport or not pane then return end
 if K.scroll and K.scroll.ScrollBar then K.scroll.ScrollBar:Hide()end
 scrollMaximum=math.max(0,pane:GetHeight()-math.max(1,clip:GetHeight()))
 syncingScroll=true;scrollbar:SetMinMaxValues(0,scrollMaximum);scrollbar:SetValue(math.min(scrollOffset,scrollMaximum));syncingScroll=false
 scrollbar:SetShown(scrollMaximum>0);SetOffset(scrollOffset)
end
local function BuildViewport()
 viewport=CreateFrame('Frame',nil,K.window)
 viewport:SetPoint('TOPLEFT',K.scroll,'TOPLEFT',10,-6)
 viewport:SetPoint('BOTTOMRIGHT',K.scroll,'BOTTOMRIGHT',0,0)
 viewport:SetFrameLevel(K.scroll:GetFrameLevel()+5)
 clip=CreateFrame('Frame',nil,viewport);clip:SetPoint('TOPLEFT');clip:SetPoint('BOTTOMRIGHT',-20,0)
 clip:SetClipsChildren(true)
 scrollbar=CreateFrame('Slider',nil,viewport)
 scrollbar:SetPoint('TOPRIGHT',-1,-2);scrollbar:SetPoint('BOTTOMRIGHT',-1,2);scrollbar:SetWidth(12)
 scrollbar:SetOrientation('VERTICAL');scrollbar:SetValueStep(1);scrollbar:SetMinMaxValues(0,0)
 local rail=scrollbar:CreateTexture(nil,'BACKGROUND');rail:SetAllPoints();rail:SetColorTexture(.16,.18,.16,1)
 local thumb=scrollbar:CreateTexture(nil,'ARTWORK');thumb:SetSize(10,36);thumb:SetColorTexture(.52,.57,.48,1)
 scrollbar:SetThumbTexture(thumb)
 scrollbar:SetScript('OnValueChanged',function(_,value)if not syncingScroll then SetOffset(value,true)end end)
 viewport:EnableMouseWheel(true)
 viewport:SetScript('OnMouseWheel',function(_,delta)SetOffset(scrollOffset-delta*38,true)end)
 viewport:SetScript('OnSizeChanged',function()if V.active then V.Reflow()end end)
 pane=CreateFrame('Frame',nil,clip);pane:SetWidth(714)
 textLayer=CreateFrame('Frame',nil,pane);textLayer:SetAllPoints(pane);textLayer:SetFrameLevel(pane:GetFrameLevel()+2)
 if K.window then K.window:HookScript('OnHide',V.Suspend)end
end
function V.Reflow()
 if reflowQueued or not V.active or not pane then return end
 reflowQueued=true;local token=generation
 C_Timer.After(0,function()
  if token~=generation then return end;reflowQueued=false
  if not V.active or not K.window or not K.window:IsShown()then return end
  local ok,err=pcall(function()
   for surface in pairs(surfaces)do if surface:IsVisible()then FitSurface(surface)end end
   for _,bar in ipairs(bars)do if bar:IsVisible()then FitChart(bar)end end
   for _,pair in ipairs(fills)do if pair[1]:IsVisible()then FitSource(pair)end end
   if plot and plot:IsVisible()then FitPlot()end
   SyncViewport()
  end);if not ok then ViewError(err)end
 end)
end
function V.Invalidate()
 sortedCache=nil
 if queued or not pane or not pane:IsVisible()then return end
 queued=true;local token=generation
 C_Timer.After(.5,function()
  if token~=generation then return end;queued=false
  if pane and pane:IsVisible()then local ok,err=pcall(V.Render);if not ok then ViewError(err)end end
 end)
end
function V.Draw(page,w,y)
 V.active=true
 if not pane then BuildViewport()end
 viewport:Show();pane:Show()
 -- The economy viewport has its own clipping; the shared page stays idle.
 if K.scroll then
  K.scroll:SetVerticalScroll(0)
  local child=K.scroll:GetScrollChild()
  if child then child:SetHeight(math.max(80,K.scroll:GetHeight()))end
 end
 local ok,err=pcall(V.Render)
 if not ok then ViewError(err);viewport:Hide();w.Text(page,E.L('viewFault')..tostring(err),8,y,690,13,red);return y-100 end
 V.Reflow();return y-20
end
SLASH_KACLASSICECONOMY1='/kaeco'
SlashCmdList.KACLASSICECONOMY=function(message)
 if message=='status'then
  local s=E.SummaryStats();if not s then print('KA Economy: not initialized.');return end
  print(('KA Economy: rows=%d/5000 days=%d/366 characters=%d/1 events=%d ready=%s fault=%s UI draws=%d peak=%.2fms'):format(s.rows,s.days,s.characters,s.totalRows,tostring(s.ready),tostring(s.fault),V.draws,V.peakDraw or 0));if V.error then print('KA Economy UI: '..V.error)end
  local own,visible=V.Visibility();local scroll=K.scroll;print(('KA Economy view: shown=%s visible=%s height=%.1f scroll=%.1f range=%.1f'):format(tostring(own),tostring(visible),pane and pane:GetHeight()or 0,scrollOffset,scrollMaximum))
 elseif message=='render'then
  local count=0
  for frame in pairs(surfaces)do if frame:IsVisible()then count=count+1 end end
  local points=0;for _,bar in ipairs(bars)do if bar:IsVisible()then for _,amount in ipairs(bar.kaChartValues or{})do if amount>0 then points=points+1 end end end end
  print(('KA Economy render: surfaces=%d nonzero-bars=%d ui-pixel=%.4f scroll=%.2f'):format(count,points,pane and PixelUnit(pane,1)or 0,scrollOffset))
 elseif message=='selection'then
  print('KA Economy selection: '..tostring(character)..' menu='..tostring(chooser and chooser:IsShown()or false))
 elseif message=='parents'then
  print(('KA Economy viewport: offset=%.1f max=%.1f height=%.1f'):format(scrollOffset,scrollMaximum,clip and clip:GetHeight()or 0))
  local f=pane
  for i=1,8 do if not f then break end
   print(('KA Economy parent %d: %s shown=%s visible=%s alpha=%s'):format(i,f.GetName and f:GetName()or'unnamed',tostring(f:IsShown()),tostring(f:IsVisible()),tostring(f.GetAlpha and f:GetAlpha()or'?')))
   f=f.GetParent and f:GetParent()or nil
  end
 elseif message=='trace'and E.GetTrace then for _,line in ipairs(E.GetTrace())do print('KA Economy: '..line)end
 elseif K.OpenEconomySettings then K.OpenEconomySettings()end
end

