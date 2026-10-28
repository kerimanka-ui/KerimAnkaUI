-- Classic-only inventory presentation. Never runs in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local T=K.InventoryText
local M={};K.ClassicBags=M
local frame,body,footer,moneyText,search,searchHint,keyButton,searchClear,shelfToggle,sortButton
local holders,buttons,bagButtons={},{},{}
local queued,busy,pendingToggle,pendingOpen,pendingRefresh=false,false,false,false,false
local filterBag,redrawQueued,hoverBag,dockQueued
local CloseNative,QueueNativeHandoff
local moneyReady=false
local startupGeneration=0
local diagnostic={hooks=0,calls=0,requests=0,handled=0,last="none"}
local moneyTooltipRows,moneyListRows=7,10
local moneyHit,moneyPanel,moneyRows,moneyOffset
local keyState
local function Combat() return InCombatLockdown and InCombatLockdown() end
local headerText={
 ["en"]={"%s's bags","Show bag icons","Hide bag icons","Bag settings"},
 ["tr"]={"%s - Çantası","Çanta ikonlarını göster","Çanta ikonlarını gizle","Çanta ayarları"},
 ["de"]={"Taschen von %s","Taschensymbole anzeigen","Taschensymbole ausblenden","Tascheneinstellungen"},
 ["frFR"]={"Sacs de %s","Afficher les icônes des sacs","Masquer les icônes des sacs","Options des sacs"},
 ["itIT"]={"Borse di %s","Mostra le icone delle borse","Nascondi le icone delle borse","Impostazioni borse"},
 ["esES"]={"Bolsas de %s","Mostrar iconos de bolsas","Ocultar iconos de bolsas","Ajustes de bolsas"},
 ["ptBR"]={"Bolsas de %s","Mostrar ícones das bolsas","Ocultar ícones das bolsas","Configurações das bolsas"},
 ["ruRU"]={"Сумки: %s","Показать значки сумок","Скрыть значки сумок","Настройки сумок"},
 ["zhCN"]={"%s的背包","显示背包图标","隐藏背包图标","背包设置"},
}
local headerTooltip
local function HeaderText(index)
 local lang=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or 'en'
 return (headerText[lang]or headerText.en)[index]
end
local function HeaderTip(owner,text)
 if not headerTooltip then headerTooltip=CreateFrame('GameTooltip','KAClassicBagHeaderTooltip',UIParent,'GameTooltipTemplate')end
 headerTooltip:SetOwner(owner,'ANCHOR_LEFT');headerTooltip:SetText(text)
 K.InventoryTooltip(headerTooltip);headerTooltip:Show()
end
local function HideHeaderTip()if headerTooltip then headerTooltip:Hide()end end
local function HeaderIcon(button,texture)
 button:SetText('')
 local icon=button:CreateTexture(nil,'ARTWORK');icon:SetPoint('TOPLEFT',3,-3);icon:SetPoint('BOTTOMRIGHT',-3,3);icon:SetTexture(texture)
 button.icon=icon
end

local function Message(text) print('|cffffcc66KerimAnka UI Classic bags:|r '..text) end
local refreshing=false
local paintEpoch=0
local waitingForItemInfo=false
local perf
local function Clock()return debugprofilestop and debugprofilestop()or(GetTime and GetTime()*1000 or 0)end
local function Count(key,amount)if perf then perf[key]=(perf[key]or 0)+(amount or 1)end end
function M.StartPerf()
 if perf then Message('Performance sample already running.');return end
 local sample={events={},refresh=0,layout=0,paint=0,cached=0,cooldown=0,ms=0};perf=sample
 Message('Sampling bags for 5 seconds; keep the bag open.')
 C_Timer.After(5,function()
  if perf~=sample then return end;perf=nil
  Message(string.format('5s: refresh=%d layout=%d paint=%d cached=%d cooldown=%d refreshLua=%.2fms',sample.refresh,sample.layout,sample.paint,sample.cached,sample.cooldown,sample.ms))
  local list={};for event,n in pairs(sample.events)do list[#list+1]={event,n}end;table.sort(list,function(a,b)return a[2]>b[2]end)
  local top={};for i=1,math.min(4,#list)do top[#top+1]=list[i][1]..'='..list[i][2]end
  Message('Events: '..table.concat(top,', '))
 end)
end

local function Replacement()
 local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 if loaded then
  for _,name in ipairs({'Bagnon','Baggins','AdiBags','BetterBags','ArkInventory','Inventorian','LiteBag','Sorted'}) do
   if loaded(name) then return name end
  end
 end
end
function M.Enabled() return K.db and K.db.bagCombined~=false and not Replacement() end
-- Native bag calls still run for their normal bookkeeping, but their frames
-- must be transparent before the deferred combined-window toggle can render.
local nativeMasked=setmetatable({},{__mode='k'})
local nativeHooked=setmetatable({},{__mode='k'})
local function RestoreNativeFrame(f)
 local alpha=nativeMasked[f]
 if alpha~=nil then nativeMasked[f]=nil;f:SetAlpha(alpha) end
end
function M.RestoreNativeBagAlpha()
 for f in pairs(nativeMasked) do RestoreNativeFrame(f) end
end
local function MaskNativeBag(f)
 if not f or not f.GetID then return end
 local id=f:GetID()
 if type(id)~='number' or id<0 or id>4 or not M.Enabled() then RestoreNativeFrame(f);return end
 if K.ClassicBank and K.ClassicBank.ReleaseNativeFrame then K.ClassicBank.ReleaseNativeFrame(f) end
 if nativeMasked[f]==nil then nativeMasked[f]=f:GetAlpha() end
 f:SetAlpha(0)
 if QueueNativeHandoff then QueueNativeHandoff() end
end
function M.InstallNativeBagHooks()
 for i=1,(NUM_CONTAINER_FRAMES or 13) do
  local f=_G['ContainerFrame'..i]
  if f and not nativeHooked[f] then
   nativeHooked[f]=true
   f:HookScript('OnShow',MaskNativeBag)
  end
 end
end
local function Slots(bag) return C_Container and C_Container.GetContainerNumSlots(bag) or 0 end
local function Config()
 if not K.db then return end
 K.db.classicBags=K.db.classicBags or {};return K.db.classicBags
end
local function Option(key,default)
 if K.InventoryMenus and K.InventoryMenus.Get then local v=K.InventoryMenus.Get(key);if v~=nil then return v end end
 return default
end
function M.MinimumColumns()
 return K.ClassicBagDesigns.MinimumColumns(K.ClassicBagDesigns.ID(),Option('bagSize',30),K.ClassicInventoryStyle.ItemGap())
end
local function Columns()
 local d=Config();return math.max(M.MinimumColumns(),math.min(14,math.floor(tonumber(d and d.columns)or 10)))
end
M.GetColumns=Columns
function M.SetColumns(value)
 if Combat()or type(value)~='number'or value~=value then return false end
 value=math.max(M.MinimumColumns(),math.min(14,math.floor(value)))
 if value~=Columns()then Config().columns=value;M.Refresh()end
 return true
end
local function Position()
 if not frame then return end
 local d=Config();frame:ClearAllPoints()
 if d and type(d.x)=='number' and type(d.y)=='number' then frame:SetPoint('CENTER',UIParent,'CENTER',d.x,d.y)
 else frame:SetPoint('BOTTOMRIGHT',UIParent,'BOTTOMRIGHT',-35,100) end
end
local function Border(button,quality,hasItem,quest)
 if not button.kaEdges then
  button.kaEdges={}
  for i=1,4 do
   local t=button:CreateTexture(nil,'OVERLAY');t:SetColorTexture(1,1,1,1)
   if i==1 then t:SetPoint('TOPLEFT');t:SetPoint('TOPRIGHT');t:SetHeight(2)
   elseif i==2 then t:SetPoint('BOTTOMLEFT');t:SetPoint('BOTTOMRIGHT');t:SetHeight(2)
   elseif i==3 then t:SetPoint('TOPLEFT');t:SetPoint('BOTTOMLEFT');t:SetWidth(2)
   else t:SetPoint('TOPRIGHT');t:SetPoint('BOTTOMRIGHT');t:SetWidth(2) end
   button.kaEdges[i]=t
  end
 end
 local questBorder=quest and Option('bagQuest',true)
 local color=questBorder and {r=1,g=.82,b=0}or ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality or 1]or {r=1,g=1,b=1}
 for _,t in ipairs(button.kaEdges) do t:SetVertexColor(color.r,color.g,color.b);t:SetShown(hasItem and (questBorder or type(quality)=='number'and quality>=2 and Option('bagQuality',true))) end
end
local function QuietTemplate(button)
 -- The standalone template's extended-slot overlays are blue by default.
 -- They describe native layouts, not these bags. Keep only our own borders.
 for _,name in ipairs({'flashAnim','newitemglowAnim'}) do
  local animation=button[name];if animation and animation.Stop then animation:Stop() end
 end
 for _,name in ipairs({'ExtendedSlot','ExtendedOverlay','ExtendedOverlay2','BagStaticBottom','BagStaticTop','NewItemTexture','BattlepayItemTexture','flash','IconBorder'}) do
  local region=button[name];if region then region:Hide() end
 end
end
local function ItemName(info)
 if not info then return '' end
 local key=info.hyperlink or info.itemID
 local getter=C_Item and C_Item.GetItemInfo or GetItemInfo
 local name=key and getter and getter(key)
 if not name and info.hyperlink then name=info.hyperlink:match('%[(.-)%]') end
 if type(name)~='string'then waitingForItemInfo=true;return ''end
 return name
end
function M.Matches(info,query)
 if query==nil then query=(search and search:GetText()or''):match('^%s*(.-)%s*$'):lower()end
 return query=='' or (info~=nil and ItemName(info):lower():find(query,1,true)~=nil)
end
function M.HoverBag(id)
 if hoverBag==id then return end;hoverBag=id
 -- Hover changes only the existing glow. Never reload items or move widgets.
 for bag,group in pairs(buttons)do for _,b in pairs(group)do
  if b.kaBagGlow then b.kaBagGlow:SetShown(id~=nil and bag==id)end
 end end
end
local function Money()
 local value=GetMoney and GetMoney() or 0
 if GetCoinTextureString then return GetCoinTextureString(value) end
 return string.format('%dg %ds %dc',math.floor(value/10000),math.floor(value/100)%100,value%100)
end
-- Account-wide Classic snapshots; deliberately outside character UI profiles.
local function WealthStore(create)
 local root=KAClassic_KerimAnkaUIDB;if type(root)~='table' then return end
 if type(root.bagWealth)~='table' and create then root.bagWealth={characters={},removed={}} end
 local db=root.bagWealth
 if type(db)=='table' then db.characters=type(db.characters)=='table' and db.characters or {};db.removed=type(db.removed)=='table' and db.removed or {};return db end
end
local function Identity()
 if not UnitName then return end
 local name,realm
 if UnitFullName then name,realm=UnitFullName('player') end
 name=name or UnitName('player');realm=realm or (GetRealmName and GetRealmName()) or '?'
 if not name or name=='' then return end
 return (UnitGUID and UnitGUID('player')) or (name..'-'..realm),name,realm
end
function M.RecordMoney(initialLogin,confirmed)
 local key,name,realm=Identity();if not key then return end
 local db=WealthStore(true);if not db then return end
 if initialLogin then db.removed[key]=nil end
 if db.removed[key] then return end
 local value=GetMoney and GetMoney()
 if type(value)~='number' or value<0 then return end
 -- Login can precede server money data. Never turn unavailable data into zero.
 if value==0 and not moneyReady and not confirmed then return end
 moneyReady=true
 local _,class=UnitClass('player');local race
 -- Store race metadata for a native portrait icon when its atlas is available.
 if UnitRace then _,race=UnitRace('player') end
 db.characters[key]={name=name,realm=realm,class=class,race=race,sex=UnitSex and UnitSex('player'),
  money=math.floor(value),updated=time and time() or 0}
end
function M.MoneyRecords()
 local db=WealthStore(false);local list,total={},0
 if db then for key,v in pairs(db.characters) do
  if type(v)=='table' and type(v.name)=='string' and type(v.money)=='number' and v.money>=0 then
   list[#list+1]={key=key,record=v};total=total+v.money
  end
 end end
 table.sort(list,function(a,b)
  if a.record.money~=b.record.money then return a.record.money>b.record.money end
  if a.record.name~=b.record.name then return a.record.name<b.record.name end
  return a.key<b.key
 end)
 return list,total
end
local function Coin(value)
 if GetCoinTextureString then return GetCoinTextureString(value) end
 return string.format('%dg %ds %dc',math.floor(value/10000),math.floor(value/100)%100,value%100)
end
local function CharacterLabel(v,realm)
 local c=RAID_CLASS_COLORS and RAID_CLASS_COLORS[v.class] or {r=1,g=1,b=1}
 local color=string.format('|cff%02x%02x%02x',math.floor(c.r*255+.5),math.floor(c.g*255+.5),math.floor(c.b*255+.5))
 local icon=''
 local atlas=v.race and ('raceicon128-'..v.race:lower()..(v.sex==3 and '-female' or '-male'))
 if atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then icon='|A:'..atlas..':16:16|a '
 else
  local uv=CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[v.class]
  if uv then icon=string.format('|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:16:16:0:0:256:256:%d:%d:%d:%d|t ',uv[1]*256,uv[2]*256,uv[3]*256,uv[4]*256) end
 end
 return icon..color..v.name..'|r'..(realm and (' |cff999999'..v.realm..'|r') or '')
end
function M.RefreshMoneyList()
 if not moneyPanel or not moneyPanel:IsShown() then return end
 local list,total=M.MoneyRecords();moneyOffset=math.max(0,math.min(moneyOffset or 0,math.max(0,#list-moneyListRows)))
 for i,row in ipairs(moneyRows) do
  local entry=list[moneyOffset+i];row:SetShown(entry~=nil)
  if entry then row.label:SetText(CharacterLabel(entry.record,true));row.value:SetText(Coin(entry.record.money)) end
 end
 moneyPanel.total:SetText(T('Total: ')..Coin(total))
 moneyPanel.range:SetText(#list==0 and T('No recorded characters') or string.format('%d-%d / %d',moneyOffset+1,math.min(#list,moneyOffset+moneyListRows),#list))
 moneyPanel:SetHeight(88+24*math.min(moneyListRows,math.max(1,#list)))
end
function M.RemoveMoneyRecord(key)
 local db=WealthStore(false);if not db or not db.characters[key] then return false end
 db.characters[key]=nil;db.removed[key]=true
 M.RefreshMoneyList();return true
end
local function MoneyTooltip(self)
 M.RecordMoney()
 local list,total=M.MoneyRecords();GameTooltip:SetOwner(self,'ANCHOR_TOPRIGHT');GameTooltip:SetText(T('Character money'))
 for i=1,math.min(moneyTooltipRows,#list) do local v=list[i].record;GameTooltip:AddDoubleLine(CharacterLabel(v,true),Coin(v.money),1,1,1,1,1,1) end
 if #list>moneyTooltipRows then
  local rest=0;for i=moneyTooltipRows+1,#list do rest=rest+list[i].record.money end
  GameTooltip:AddDoubleLine('Other characters ('..(#list-moneyTooltipRows)..')',Coin(rest),.6,.6,.6,1,1,1)
 end
 GameTooltip:AddLine(' ');GameTooltip:AddDoubleLine(T('Total recorded'),Coin(total),1,.82,0,1,.82,0)
 GameTooltip:AddLine(T('Click: full list | Mouse wheel: scroll after opening'),.65,.7,.62,true);K.InventoryTooltip(GameTooltip);GameTooltip:Show()
end
function M.ToggleMoneyList()
 M.RecordMoney()
 if moneyPanel and moneyPanel:IsShown() then moneyPanel:Hide();return end
 GameTooltip:Hide()
 if not moneyPanel then
  moneyPanel=CreateFrame('Frame','KerimAnkaUIClassicMoneyList',frame,'BackdropTemplate');moneyPanel:SetWidth(390)
  moneyPanel:SetFrameStrata('TOOLTIP');moneyPanel:SetClampedToScreen(true);moneyPanel:EnableMouse(true);moneyPanel:EnableMouseWheel(true)
  moneyPanel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
  K.ClassicInventoryStyle.Apply(moneyPanel,1)
  local heading=moneyPanel:CreateFontString(nil,'OVERLAY','GameFontNormal');K.InventoryFont(heading);heading:SetPoint('TOPLEFT',12,-12);K.InventoryLabel(heading,'Character money - last recorded')
  local close=CreateFrame('Button',nil,moneyPanel,'UIPanelCloseButton');close:SetPoint('TOPRIGHT',1,1);close:SetScript('OnClick',function() moneyPanel:Hide() end)
  moneyRows={}
  for i=1,moneyListRows do
   local row=CreateFrame('Frame',nil,moneyPanel);row:SetPoint('TOPLEFT',12,-35-(i-1)*24);row:SetSize(366,22)
   row.label=row:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');K.InventoryFont(row.label);row.label:SetPoint('LEFT');row.label:SetWidth(228);row.label:SetJustifyH('LEFT')
   row.value=row:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');K.InventoryFont(row.value);row.value:SetPoint('RIGHT');row.value:SetWidth(126);row.value:SetJustifyH('RIGHT')
   moneyRows[i]=row
  end
  moneyPanel.total=moneyPanel:CreateFontString(nil,'OVERLAY','GameFontNormal');K.InventoryFont(moneyPanel.total);moneyPanel.total:SetPoint('BOTTOMRIGHT',-12,12)
  moneyPanel.range=moneyPanel:CreateFontString(nil,'OVERLAY','GameFontDisableSmall');K.InventoryFont(moneyPanel.range);moneyPanel.range:SetPoint('BOTTOMLEFT',12,34)
  moneyPanel:SetScript('OnMouseWheel',function(_,delta) moneyOffset=(moneyOffset or 0)-delta;M.RefreshMoneyList() end)
  table.insert(UISpecialFrames,'KerimAnkaUIClassicMoneyList')
 end
 moneyOffset=0;moneyPanel:ClearAllPoints();moneyPanel:SetPoint('BOTTOMRIGHT',moneyHit,'TOPRIGHT',0,6);moneyPanel:Show();M.RefreshMoneyList()
end
function M.DrawMoneyRecords(page,w,y)
 local list,total=M.MoneyRecords()
 w.Text(page,T('Recorded character money'),8,y,690,18,{.73,.62,.41});y=y-34
 w.Text(page,T('Last recorded, all realms. X removes only this money record. Logging into that character again records it anew.'),8,y,690,13,{.65,.70,.62});y=y-56
 w.Text(page,T('Total: ')..Coin(total),8,y,690,14);y=y-34
 for _,entry in ipairs(list) do
  local key=entry.key;local box=w.Box(page,0,y,714,46)
  w.Text(box,CharacterLabel(entry.record,true),12,-15,410,13)
  w.Text(box,Coin(entry.record.money),428,-15,210,13)
  w.Button(box,'X',662,-10,30,26,function() M.RemoveMoneyRecord(key);if K.Render then K.Render() end end)
  y=y-54
 end
 if #list==0 then w.Text(page,T('No recorded characters.'),8,y,690,13);y=y-34 end
 return y-20
end
local function CooldownText(counter)
 local left=counter.expires and counter.expires-GetTime() or 0
 if left<=0 then counter.expires=nil;if counter.kaText~=''then counter.label:SetText('');counter.kaText=''end;counter:SetScript('OnUpdate',nil);counter:Hide();return end
 local text
 if left>=3600 then text=string.format(HOUR_ONELETTER_ABBR or '%dh',math.ceil(left/3600))
 elseif left>=60 then text=string.format(MINUTE_ONELETTER_ABBR or '%dm',math.ceil(left/60))
 else text=tostring(math.ceil(left))end
 if counter.kaText~=text then counter.label:SetText(text);counter.kaText=text end
end
local function CounterUpdate(self,dt)
 self.kaElapsed=(self.kaElapsed or 0)+dt;if self.kaElapsed>=.1 then self.kaElapsed=0;CooldownText(self)end
end
local function PaintCooldown(button,bag,slot,hasItem)
 local start,duration,enabled=0,0,0
 if hasItem and C_Container.GetContainerItemCooldown then start,duration,enabled=C_Container.GetContainerItemCooldown(bag,slot)end
 start,duration=start or 0,duration or 0
 local active=hasItem and enabled==1 and start>0 and duration>0 and start+duration>GetTime()
 -- Classic exposes $parentCooldown by global name, unlike modern .Cooldown.
 local name=button:GetName()
 local cooldown=button.Cooldown or button.cooldown or (name and _G[name..'Cooldown']) or button.kaCooldown
 if not cooldown and active then
  cooldown=CreateFrame('Cooldown',nil,button,'CooldownFrameTemplate');cooldown:SetAllPoints(button);button.kaCooldown=cooldown
 end
 if cooldown then
  -- One explicit counter, independent of the global cooldown-number CVar.
  -- Let native swipe timing/animation run; do not replace its scripts.
  if not cooldown.kaConfigured then
   cooldown.noCooldownCount=true
   if cooldown.SetHideCountdownNumbers then cooldown:SetHideCountdownNumbers(true)end
   if cooldown.SetDrawSwipe then cooldown:SetDrawSwipe(true)end
   cooldown.kaConfigured=true
  end
  if cooldown.kaStart~=start or cooldown.kaDuration~=duration or cooldown.kaEnabled~=(enabled or 0)or cooldown.kaActive~=not not active then
  cooldown.kaStart,cooldown.kaDuration,cooldown.kaEnabled,cooldown.kaActive=start,duration,enabled or 0,not not active
  if CooldownFrame_Set then CooldownFrame_Set(cooldown,start,duration,enabled or 0)
  elseif cooldown.SetCooldown then cooldown:SetCooldown(active and start or 0,active and duration or 0);cooldown:SetShown(active and true or false)end
  end
 end
 local counter=button.kaCooldownCounter
 if active and not counter then
  counter=CreateFrame('Frame',nil,button);button.kaCooldownCounter=counter;counter:SetAllPoints(button);counter:EnableMouse(false)
  counter:SetFrameLevel(math.max(button:GetFrameLevel()+5,cooldown and cooldown:GetFrameLevel()+1 or 0))
  counter.label=counter:CreateFontString(nil,'OVERLAY','NumberFontNormal');K.InventoryFont(counter.label);counter.label:SetPoint('CENTER');counter.label:SetTextColor(1,1,1,1)
  counter.kaElapsed=0
 end
 if counter then
  counter.expires=active and start+duration or nil
  if active then if counter:GetScript('OnUpdate')~=CounterUpdate then counter:SetScript('OnUpdate',CounterUpdate)end;counter:Show()end
  CooldownText(counter)
 end
end
local EMPTY_ITEM={}
local function Paint(button,bag,slot,info,provided)
 if not provided then info=C_Container.GetContainerItemInfo(bag,slot)end
 button.kaHasItem=info~=nil
 local v=info or EMPTY_ITEM
 local junkOption,qualityOption,questOption,emptyOption,design=Option('bagJunk',true),Option('bagQuality',true),Option('bagQuest',true),Option('bagEmptySlots',false),Option('bagDesign',1)
 local c=button.kaPaintSnapshot
 if c and c.epoch==paintEpoch and c.present==(info~=nil)and c.itemID==v.itemID and c.link==v.hyperlink and c.icon==v.iconFileID and c.count==v.stackCount and c.quality==v.quality and c.lock==v.isLocked and c.value==v.hasNoValue and c.junkOption==junkOption and c.qualityOption==qualityOption and c.questOption==questOption and c.emptyOption==emptyOption and c.design==design then
  Count('cached');if button.kaBagGlow then button.kaBagGlow:SetShown(hoverBag==bag)end;PaintCooldown(button,bag,slot,info~=nil);return
 end
 Count('paint');QuietTemplate(button)
 local icon=info and info.iconFileID
 local quality=info and info.quality
 SetItemButtonTexture(button,icon);K.ClassicInventoryStyle.EmptySlot(button,icon~=nil);K.ClassicBagDesigns.SkinItem(button,K.ClassicBagDesigns.ID(),icon~=nil);SetItemButtonCount(button,info and info.stackCount or 0)
 local quest=K.ClassicInventoryStyle.IsQuestItem(bag,slot,info)
 local junk=info and not quest and quality==0 and not info.hasNoValue and Option('bagJunk',true)
 if SetItemButtonDesaturated then SetItemButtonDesaturated(button,(info and info.isLocked) or junk or false) end
 local texture=button.icon or button.Icon or _G[button:GetName()..'IconTexture']
 if texture then texture:SetVertexColor(junk and .55 or 1,junk and .55 or 1,junk and .55 or 1) end
 if button.JunkIcon then button.JunkIcon:SetShown(junk and true or false) end
 if not button.kaJunk then
  button.kaJunk=button:CreateTexture(nil,'OVERLAY',nil,7)
  button.kaJunk:SetTexture('Interface\\MoneyFrame\\UI-GoldIcon');button.kaJunk:SetSize(13,13);button.kaJunk:SetPoint('TOPLEFT',1,-1)
 end
 button.kaJunk:SetShown(junk and true or false)
 Border(button,quality,icon~=nil,quest)
 if not button.kaBagGlow then
  button.kaBagGlow=button:CreateTexture(nil,'OVERLAY',nil,6)
  button.kaBagGlow:SetAllPoints();button.kaBagGlow:SetColorTexture(1,.78,.20,.22)
 end
 button.kaBagGlow:SetShown(hoverBag==bag)
 PaintCooldown(button,bag,slot,info~=nil)
 c=c or{};button.kaPaintSnapshot=c
 c.epoch,c.present,c.itemID,c.link,c.icon,c.count,c.quality,c.lock,c.value=paintEpoch,info~=nil,v.itemID,v.hyperlink,v.iconFileID,v.stackCount,v.quality,v.isLocked,v.hasNoValue
 c.junkOption,c.qualityOption,c.questOption,c.emptyOption,c.design=junkOption,qualityOption,questOption,emptyOption,design
end
-- Keep Blizzard split/purchase dialogs above our inventory windows, without
-- changing their owners, values, scripts or the actual item operation.
M.PaintInventoryButton=Paint
local dialogStates=setmetatable({},{__mode='k'})
local function RestoreDialog(dialog)
 local state=dialogStates[dialog]
 if state then dialog:SetFrameStrata(state.strata);dialog:SetFrameLevel(state.level);dialogStates[dialog]=nil end
end
function M.PromoteInventoryDialog(dialog,owner)
 if not dialog then return end
 local p=owner;local ours=false
 for i=1,12 do if not p then break end;if p.kaClassicInventory then ours=true;break end;p=p.GetParent and p:GetParent() end
 if not ours then RestoreDialog(dialog);return end
 if not dialogStates[dialog] then dialogStates[dialog]={strata=dialog:GetFrameStrata(),level=dialog:GetFrameLevel()} end
 if not dialog.kaClassicRestoreHook then dialog:HookScript('OnHide',RestoreDialog);dialog.kaClassicRestoreHook=true end
 dialog:SetFrameStrata('FULLSCREEN_DIALOG');dialog:SetFrameLevel(math.max(dialog:GetFrameLevel(),(owner.GetFrameLevel and owner:GetFrameLevel() or 1)+20))
end
local splitHook
function M.InstallSplitHook()
 if type(OpenStackSplitFrame)=='function' and splitHook~=OpenStackSplitFrame then
  hooksecurefunc('OpenStackSplitFrame',function() if StackSplitFrame then M.PromoteInventoryDialog(StackSplitFrame,StackSplitFrame.owner) end end)
  splitHook=OpenStackSplitFrame
 end
end
local function KeyID()
 return Enum and Enum.BagIndex and Enum.BagIndex.Keyring or KEYRING_CONTAINER
end
function M.ReleaseKeyring(close)
 local state=keyState;if not state or Combat() then return end
 keyState=nil
 local f=state.frame
 f:ClearAllPoints();for _,point in ipairs(state.points) do f:SetPoint(unpack(point)) end
 if state.strata then f:SetFrameStrata(state.strata) end
 if state.level then f:SetFrameLevel(state.level) end
 if close then f:Hide() end
end
function M.DockKeyring()
 if Combat() then return end
 if not frame or not frame:IsShown() or not M.Enabled() then M.ReleaseKeyring(true);return end
 local id=KeyID();if not id then return end
 local found
 for i=1,(NUM_CONTAINER_FRAMES or 13) do
  local f=_G['ContainerFrame'..i]
  if f and f.GetID and f:GetID()==id and f:IsShown() then found=f;break end
 end
 if not found then M.ReleaseKeyring(false);return end
 if keyState and keyState.frame~=found then M.ReleaseKeyring(false) end
 if not keyState then
  keyState={frame=found,points={}}
  for i=1,found:GetNumPoints() do keyState.points[i]={found:GetPoint(i)} end
  keyState.strata=found:GetFrameStrata();keyState.level=found:GetFrameLevel()
 end
 found:ClearAllPoints()
 -- Prefer below the bag; at the screen bottom dock beside it instead.
 local bottom=frame:GetBottom()
 local space=bottom and bottom*frame:GetEffectiveScale() or math.huge
 if space>found:GetHeight()*found:GetEffectiveScale()+8 then found:SetPoint('TOPRIGHT',frame,'BOTTOMRIGHT',0,-6)
 else found:SetPoint('TOPRIGHT',frame,'TOPLEFT',-6,0) end
 found:SetFrameStrata(frame:GetFrameStrata());found:SetFrameLevel(frame:GetFrameLevel()+1)
end
local function QueueDock()
 if busy or dockQueued or not frame or not frame:IsShown() or not M.Enabled() then return end
 dockQueued=true;C_Timer.After(0,function() dockQueued=false;M.DockKeyring() end)
end
function M.SetShelfHidden(value)
 if Combat() or type(value)~='boolean' or not Config() then return false end
 Config().shelfHidden=value;filterBag=nil;hoverBag=nil;M.Refresh();return true
end
-- Match native Classic bag-slot interactions (MainMenuBarBagButtons.lua):
-- PutItemInBag expects an EQUIPPED inventory slot; PickupBagFromSlot picks up
-- the bag itself. Item contents retain their separate container/slot identity.
local function InventoryID(bag)
 if bag<1 or bag>4 or not C_Container.ContainerIDToInventoryID then return end
 return C_Container.ContainerIDToInventoryID(bag)
end
local function CursorItem()
 if CursorHasItem then return CursorHasItem() end
 return GetCursorInfo and GetCursorInfo()=='item' or false
end
local function ReceiveBagItem(bag)
 if Combat() or not M.Enabled() or not CursorItem() then return false end
 if bag==0 then
  if PutItemInBackpack then PutItemInBackpack() end
 else
  local inventory=InventoryID(bag)
  if inventory and PutItemInBag then PutItemInBag(inventory) end
 end
 -- Never clear the cursor: native validation retains rejected items and swaps.
 M.Refresh();return true
end
local function ClickBag(bag)
 if Combat() or not M.Enabled() then return end
 if ReceiveBagItem(bag) then return end
 if filterBag==bag then filterBag=nil else filterBag=bag end
 M.Refresh()
end
local function PickupEquippedBag(bag)
 if Combat() or not M.Enabled() then return end
 local inventory=InventoryID(bag)
 if inventory and PickupBagFromSlot then PickupBagFromSlot(inventory);M.Refresh() end
end
-- Independent Classic sorter. All inventory moves use native container APIs;
-- Bag and live-bank scopes are separate; specialty bag families stay separate.
local sorting,sortGeneration=false,0
local sortContext
local sortMoves,sortWaits=0,0
local lastSortMove,sortStalls
local function SortLabel()
 if sortButton then sortButton:SetText(sorting and not sortContext and T('Stop') or T('Sort'));sortButton:SetAlpha(Combat() and .45 or 1) end
 if sortContext and sortContext.Label then sortContext.Label(sorting) end
end
function M.StopSort(reason)
 sorting=false;sortGeneration=sortGeneration+1;SortLabel();sortContext=nil
 if reason then Message(reason) end
end
local function ItemData(info)
 local getter=C_Item and C_Item.GetItemInfo or GetItemInfo
 local name,link,quality,level,_,_,_,maxStack,equip,_,_,class,subclass=getter(info.hyperlink or info.itemID)
 if not name or not maxStack or not class then return end
 return {key=info.hyperlink or link,name=name,quality=quality or info.quality or 1,level=level or 0,
  maxStack=maxStack,equip=equip or '',class=class,subclass=subclass or 0,
  itemID=info.itemID or 0,count=info.stackCount or 1}
end
local function ReadSortSlots()
 local groups,order={},{}
 local ids=sortContext and sortContext.ids or {0,1,2,3,4}
 for _,bag in ipairs(ids) do
  local count=Slots(bag)
  if count>0 then
   local family=0
   if bag~=0 and bag~=-1 then
    if not C_Container.GetContainerNumFreeSlots then return nil,'Bag-family information is unavailable.' end
    family=select(2,C_Container.GetContainerNumFreeSlots(bag))
    if type(family)~='number' then return nil,'Bag-family information is loading. Try again.' end
   end
   if not groups[family] then groups[family]={};order[#order+1]=family end
   for slot=1,count do
    local info=C_Container.GetContainerItemInfo(bag,slot)
    if info and info.isLocked then return nil,'locked' end
    local data=info and ItemData(info)
    if info and not data then
     if C_Item and C_Item.RequestLoadItemDataByID and info.itemID then C_Item.RequestLoadItemDataByID(info.itemID) end
     return nil,T('Item information is loading. Press Sort again shortly.')
    end
    local group=groups[family];group[#group+1]={bag=bag,slot=slot,item=data,index=#group+1}
   end
  end
 end
 return groups,order
end
local function Before(a,b)
 if not a then return false end;if not b then return true end
 local aj,bj=a.quality==0,b.quality==0
 if aj~=bj then return not aj end
 for _,key in ipairs({'class','subclass','equip'}) do if a[key]~=b[key] then return a[key]<b[key] end end
 if a.quality~=b.quality then return a.quality>b.quality end
 if a.level~=b.level then return a.level>b.level end
 if a.name~=b.name then return a.name<b.name end
 if a.itemID~=b.itemID then return a.itemID<b.itemID end
 if a.key~=b.key then return a.key<b.key end
 return a.count>b.count
end
local function MoveSlots(from,to)
 if CursorItem() then return false,T('Finish moving the item on your cursor first.') end
 C_Container.PickupContainerItem(from.bag,from.slot)
 if not CursorItem() then return false,'The item could not be picked up. Try again.' end
 C_Container.PickupContainerItem(to.bag,to.slot)
 -- A swap or partial stack leaves an item on the cursor. Put it in the
 -- vacated source slot immediately; never delete or blindly clear the cursor.
 if CursorItem() then C_Container.PickupContainerItem(from.bag,from.slot) end
 if CursorItem() then return false,T('Sorting stopped: place the item on your cursor into a free slot.') end
 return true
end
local function NextSortMove(groups,order)
 -- Merge only identical full hyperlinks, preserving random properties/enchantments.
 for _,family in ipairs(order) do
  local slots=groups[family]
  for i=1,#slots do
   local dest=slots[i];local item=dest.item
   if item and item.maxStack>1 and item.count<item.maxStack then
    for j=i+1,#slots do
     local from=slots[j];local other=from.item
     if other and other.key==item.key and other.count<other.maxStack then return from,dest end
    end
   end
  end
 end
 -- Selection by the desired tuple, with empty slots last. Each move is a swap
 -- within one compatible family; the next pass reads fresh native inventory data.
 for _,family in ipairs(order) do
  local slots=groups[family]
  for i=1,#slots do
   local best=i
   for j=i+1,#slots do if Before(slots[j].item,slots[best].item) then best=j end end
   if best~=i then return slots[best],slots[i] end
  end
 end
end
local function SortVisible()
 if sortContext then return sortContext.Valid() end
 return frame and frame:IsShown()
end
local function SortRefresh()
 if sortContext then sortContext.Refresh() else M.Refresh() end
end
local function SortTick(token)
 if not sorting or token~=sortGeneration then return end
 if Combat() or not M.Enabled() or not SortVisible() or (UnitIsDead and UnitIsDead('player')) then M.StopSort();return end
 if CursorItem() then M.StopSort(T('Finish moving the item on your cursor first.'));return end
 local groups,order=ReadSortSlots()
 if not groups then
  if order=='locked' and sortWaits<120 then sortWaits=sortWaits+1;C_Timer.After(.1,function() SortTick(token) end);return end
  M.StopSort(order=='locked' and T('Items are still locked. Try again shortly.') or order);return
 end
 sortWaits=0
 local from,to=NextSortMove(groups,order)
 if not from then SortRefresh();M.StopSort();return end
 if sortMoves>=1024 then M.StopSort(T('Sorting paused. Press Sort again to continue.'));return end
 local function Signature(slot)
  local item=slot.item;return slot.bag..':'..slot.slot..':'..(item and (item.key..':'..item.count) or 'empty')
 end
 local signature=Signature(from)..'>'..Signature(to)
 sortStalls=signature==lastSortMove and (sortStalls or 0)+1 or 0;lastSortMove=signature
 if sortStalls>=3 then M.StopSort(T('An item could not be moved. Check bag space or item restrictions and try again.'));return end
 local ok,reason=MoveSlots(from,to)
 if not ok then M.StopSort(reason);return end
 sortMoves=sortMoves+1;SortRefresh()
 C_Timer.After(.08,function() SortTick(token) end)
end
function M.Sort(context)
 if sorting then local same=sortContext==context;M.StopSort();if same then return false end end
 if Combat() then Message(T('Sort outside combat.'));return false end
 if not M.Enabled() then return false end
 if context then if not context.Valid() then return false end
 elseif not frame or not frame:IsShown() then return false end
 if CursorItem() then Message(T('Finish moving the item on your cursor first.'));return false end
 if not C_Container.PickupContainerItem or not (C_Item and C_Item.GetItemInfo or GetItemInfo) then Message(T('Native item sorting APIs are unavailable.'));return false end
 sortContext=context;sorting=true;sortGeneration=sortGeneration+1;sortMoves=0;sortWaits=0;lastSortMove=nil;sortStalls=0;SortLabel()
 SortTick(sortGeneration);return true
end
function M.IsSorting(context) return sorting and (context==nil or sortContext==context) end
local function Ensure()
 if frame then return true end
 if not (C_Container and ContainerFrameItemButton_OnLoad and SetItemButtonTexture and SetItemButtonCount) then
  Message(T('Native Classic bag-button APIs are unavailable. Original bags remain available.'));return false
 end
 frame=CreateFrame('Frame','KerimAnkaUIClassicBagFrame',UIParent,'BackdropTemplate')
 frame:Hide()
 frame.kaClassicInventory=true;frame.kaBagDesignWindow=true
 frame:SetFrameStrata('DIALOG');frame:SetMovable(true);frame:SetClampedToScreen(true);frame:EnableMouse(true);frame:RegisterForDrag('LeftButton')
 frame:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=2})
 frame:SetBackdropColor(.045,.05,.04,.97);frame:SetBackdropBorderColor(.63,.49,.25,1)
 frame:SetScript('OnDragStart',function(self) if not Combat() then self:StartMoving() end end)
 frame:SetScript('OnDragStop',function(self)
  self:StopMovingOrSizing();local x,y=self:GetCenter();local px,py=UIParent:GetCenter()
  local d=Config();if d and x and y and px and py then d.x=x-px;d.y=y-py end
  Position()
 end)
 local close=K.ClassicBagDesigns.NewButton('KerimAnkaUIClassicBagClose',frame,'close');close:SetSize(26,26);close:SetPoint('TOPRIGHT',-10,-10)
 close:SetScript('OnClick',function() frame:Hide() end)
 local settings=K.ClassicBagDesigns.NewButton('KerimAnkaUIClassicBagSettings',frame,'settings')
 frame.kaBagSettings=settings;settings:SetSize(22,22);settings:SetPoint('TOPRIGHT',-36,-8)
 HeaderIcon(settings,'Interface\\Icons\\INV_Misc_Gear_01')
 settings:SetScript('OnClick',function()
  HideHeaderTip()
  if K.ShowPage then frame:Hide();if K.OpenBagSettings then K.OpenBagSettings()else K.ShowPage('inventory')end end
 end)
 settings:SetScript('OnEnter',function(self)HeaderTip(self,HeaderText(4))end)
 settings:SetScript('OnLeave',HideHeaderTip)
 footer=frame:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');K.InventoryFont(footer);footer:SetPoint('BOTTOMLEFT',14,12)
 local records=K.ClassicBagDesigns.NewButton('KerimAnkaUIClassicBagRecords',frame,'records')
 frame.kaRecordsButton=records;records:SetSize(150,22);records:SetPoint('BOTTOMLEFT',14,33);K.InventoryLabel(records,'Recorded items')
 records:SetScript('OnClick',function() if K.ClassicItemRecords then K.ClassicItemRecords.Toggle() end end)
 records:SetScript('OnEnter',function(self)
  GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText(T('Recorded inventory and bank'))
  GameTooltip:AddLine(T('Read-only snapshots for characters you have visited. Bank records require a bank visit.'),.9,.9,.86,true);K.InventoryTooltip(GameTooltip);GameTooltip:Show()
 end)
 records:SetScript('OnLeave',function() GameTooltip:Hide() end)
 moneyText=frame:CreateFontString('KerimAnkaUIClassicBagMoney','OVERLAY','GameFontHighlightSmall');K.InventoryFont(moneyText);moneyText:SetPoint('BOTTOMRIGHT',-14,12)
 moneyHit=CreateFrame('Button','KerimAnkaUIClassicMoneyButton',frame);moneyHit:SetPoint('BOTTOMRIGHT',-10,5);moneyHit:SetSize(90,25)
 moneyHit:SetScript('OnEnter',MoneyTooltip);moneyHit:SetScript('OnLeave',function() GameTooltip:Hide() end)
 moneyHit:SetScript('OnClick',function() M.ToggleMoneyList() end)

 search=CreateFrame('EditBox','KerimAnkaUIClassicBagSearch',frame)
 search:EnableMouse(true);search:SetAutoFocus(false);search:SetSize(240,22);search:SetPoint('TOPLEFT',20,-79)
 search:SetMaxLetters(80);search:SetFontObject(GameFontHighlightSmall);K.InventoryFont(search)
 searchHint=search:CreateFontString(nil,'OVERLAY','GameFontDisableSmall');K.InventoryFont(searchHint);searchHint:SetPoint('LEFT',27,0);K.InventoryLabel(searchHint,'Search');searchHint:SetTextColor(.6,.61,.58,1);searchHint:SetWordWrap(false)
 search.kaLastQuery=search:GetText()or''
 search:SetScript('OnTextChanged',function(self)
  local query=self:GetText()or'';searchHint:SetShown(query=='')
  if self.kaLastQuery==query then return end;self.kaLastQuery=query;M.Refresh()
 end)
 search:SetScript('OnMouseDown',function(self)self:SetFocus()end)
 search:SetScript('OnEditFocusGained',function(self)searchHint:SetShown(self:GetText()=='');K.ClassicBagDesigns.SearchFocus(self,true)end)
 search:SetScript('OnEditFocusLost',function(self)searchHint:SetShown(self:GetText()=='');K.ClassicBagDesigns.SearchFocus(self,false)end)
 search:SetScript('OnEscapePressed',function(self) self:SetText('');self:ClearFocus() end)
 search:SetScript('OnEnterPressed',function(self) self:ClearFocus() end)
 local clear=K.ClassicBagDesigns.NewButton(nil,search,'clear');searchClear=clear;clear:SetSize(22,22);clear:SetPoint('TOPRIGHT',-14,-79);clear:SetText('x')
 clear:SetScript('OnClick',function() search:SetText('');search:ClearFocus() end)
 sortButton=K.ClassicBagDesigns.NewButton('KerimAnkaUIClassicBagSort',frame,'sort')
 sortButton:SetSize(68,22);sortButton:SetPoint('TOPRIGHT',-42,-79);K.InventoryLabel(sortButton,'Sort')
 sortButton:SetScript('OnClick',function() M.Sort() end)
 sortButton:SetScript('OnEnter',function(self)
  GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText(T('Sort bags'))
  GameTooltip:AddLine(T('Combine stacks, group item types, put grey items and empty slots last.'),.9,.9,.86,true)
  GameTooltip:AddLine(T('All equipped bags. Outside combat only. Click again to stop.'),.9,.9,.86,true);K.InventoryTooltip(GameTooltip);GameTooltip:Show()
 end)
 sortButton:SetScript('OnLeave',function() GameTooltip:Hide() end)

 frame:HookScript('OnHide',function()
  HideHeaderTip()
  if not sortContext then M.StopSort() end
  if moneyPanel then moneyPanel:Hide() end
  hoverBag=nil;if search then search:ClearFocus() end
  local wasBusy=busy;busy=true
  M.ReleaseKeyring(true);if CloseNative then CloseNative() end
  busy=wasBusy
 end)
 shelfToggle=K.ClassicBagDesigns.NewButton('KerimAnkaUIClassicBagShelfToggle',frame,'shelf')
 shelfToggle:SetSize(22,22);shelfToggle:SetPoint('TOPRIGHT',-58,-8)
 HeaderIcon(shelfToggle,'Interface\\Buttons\\Button-Backpack-Up')
 shelfToggle:SetScript('OnClick',function() M.SetShelfHidden(not Config().shelfHidden) end)
 shelfToggle:SetScript('OnEnter',function(self)HeaderTip(self,HeaderText(Config().shelfHidden and 2 or 3))end)
 shelfToggle:SetScript('OnLeave',HideHeaderTip)

 body=CreateFrame('Frame',nil,frame);body:SetAllPoints(frame)
 for bag=0,4 do
  local id=bag
  local b=CreateFrame('Button',nil,frame,'BackdropTemplate');bagButtons[bag]=b
  b:SetSize(30,30);b:SetPoint('TOPLEFT',14+bag*35,-39)
  b:SetBackdrop({edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
  b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetPoint('TOPLEFT',2,-2);b.icon:SetPoint('BOTTOMRIGHT',-2,2)
  b.free=b:CreateFontString(nil,'OVERLAY','NumberFontNormalSmall');K.InventoryFont(b.free);b.free:SetPoint('BOTTOMRIGHT',-1,1)
  b:RegisterForClicks('LeftButtonUp')
  b:SetScript('OnClick',function() ClickBag(id) end)
  b:SetScript('OnReceiveDrag',function() ReceiveBagItem(id) end)
  if id>0 then
   b:RegisterForDrag('LeftButton')
   b:SetScript('OnDragStart',function() PickupEquippedBag(id) end)
  end
  b:SetScript('OnEnter',function(self)
   M.HoverBag(id)
   GameTooltip:SetOwner(self,'ANCHOR_LEFT')
   if id>0 and C_Container.ContainerIDToInventoryID then GameTooltip:SetInventoryItem('player',C_Container.ContainerIDToInventoryID(id))
   else GameTooltip:SetText(BACKPACK_TOOLTIP or T('Backpack')) end
   GameTooltip:AddLine(tostring(Slots(id))..T(' slots | Click: filter / show all'),.9,.9,.86)
   if id>0 then GameTooltip:AddLine(T('Drag: move bag | Drop a bag here: equip / swap'),.9,.9,.86)
   else GameTooltip:AddLine(T('Drop an item here: put in backpack'),.9,.9,.86) end
   K.InventoryTooltip(GameTooltip);GameTooltip:Show()
  end)
  b:SetScript('OnLeave',function() M.HoverBag(nil);GameTooltip:Hide() end)
  local holder=CreateFrame('Frame','KAClassicBagHolder'..bag,body);holders[bag]=holder
  holder:SetID(bag);holder:SetAllPoints(body);buttons[bag]={}
 end
 keyButton=CreateFrame('Button',nil,frame,'BackdropTemplate');keyButton:SetSize(25,30);keyButton:SetPoint('TOPLEFT',190,-39)
 keyButton:SetBackdrop({edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});keyButton:SetBackdropBorderColor(0,0,0,0)
 keyButton.icon=keyButton:CreateTexture(nil,'ARTWORK');keyButton.icon:SetPoint('TOPLEFT',2,-2);keyButton.icon:SetPoint('BOTTOMRIGHT',-2,2);keyButton.icon:SetTexture('Interface\\Icons\\INV_Misc_Key_14')
 keyButton:SetScript('OnClick',function()
  local id=Enum and Enum.BagIndex and Enum.BagIndex.Keyring or KEYRING_CONTAINER
  if not Combat() and id and ToggleBag then ToggleBag(id);QueueDock() end
 end)
 keyButton:SetScript('OnEnter',function(self) GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText(KEYRING or T('Keyring'));K.InventoryTooltip(GameTooltip);GameTooltip:Show() end)
 keyButton:SetScript('OnLeave',function() GameTooltip:Hide() end)
 for _,delta in ipairs({-1,1}) do
  local change=delta
  local b=K.ClassicBagDesigns.NewButton(nil,frame,change<0 and'minus'or'plus');b:SetSize(24,22)
  frame.kaResizeButtons=frame.kaResizeButtons or {};table.insert(frame.kaResizeButtons,b);b.kaResizeDelta=change
  b:SetPoint('TOPRIGHT',change<0 and -112 or -85,-8);b:SetText(change<0 and '-' or '+')
  b:SetScript('OnClick',function()M.SetColumns(Columns()+change)end)
 end
 UISpecialFrames=UISpecialFrames or {};table.insert(UISpecialFrames,'KerimAnkaUIClassicBagFrame')
 frame.kaDesignButtons={close,settings,records,sortButton,searchClear,shelfToggle}
 for _,b in ipairs(frame.kaResizeButtons)do table.insert(frame.kaDesignButtons,b)end
 frame.kaBagBadge=frame:CreateTexture(nil,'ARTWORK');frame.kaBagBadge:SetPoint('TOPLEFT',14,-10);frame.kaBagBadge:SetSize(20,20);frame.kaBagBadge:SetTexture('Interface\\Buttons\\Button-Backpack-Up')
 Position();frame:Hide();return true
end
local function SetText(region,value)
 if region.kaTextValue~=value then region:SetText(value);region.kaTextValue=value end
end
local function CapacityText(free,total,l)
 local compact=string.format('%d / %d',free,total)
 if not l.wideFooter then return compact end
 local full=string.format(T('%d / %d slots free%s'),free,total,filterBag and(T(' | bag ')..filterBag)or'')
 local language=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or'en'
 K.ClassicBagDesigns.CapacityFont(footer)
 if footer.kaFullText~=full or footer.kaMeasureLanguage~=language then
  SetText(footer,full)
  footer.kaFullWidth=footer.GetUnboundedStringWidth and footer:GetUnboundedStringWidth()or footer:GetStringWidth()
  footer.kaFullText,footer.kaMeasureLanguage=full,language
 end
 return footer.kaFullWidth<=l.footerWidth and full or compact
end
function M.RefreshMoney()
 if not frame or not frame:IsShown()then return end
 SetText(moneyText,Money())
 local width=math.min(96,math.max(70,(moneyText.GetStringWidth and moneyText:GetStringWidth()or 80)+12))
 if moneyText.kaWidth~=width then moneyText:SetWidth(width);moneyHit:SetWidth(width+8);moneyText.kaWidth=width end
end
function M.RefreshCooldowns()
 if not frame or not frame:IsShown()then return end;Count('cooldown')
 for bag,group in pairs(buttons)do for slot,b in pairs(group)do if b:IsShown()then PaintCooldown(b,bag,slot,b.kaHasItem)end end end
end
local function RefreshVisible()
 if not frame or not K.db or not frame:IsShown() then return end
 K.ClassicInventoryStyle.Apply(frame,2)
 local size=math.max(18,math.min(48,tonumber(Option('bagSize',30)) or 30))
 local cell=size+K.ClassicInventoryStyle.ItemGap();local columns=Columns();local n,total,free=0,0,0
 waitingForItemInfo=false
 local query=(search:GetText()or''):match('^%s*(.-)%s*$'):lower()
 local shelfHidden=Config().shelfHidden==true
 local shortcutGap=K.ClassicInventoryStyle.BagShortcutGap()
 local hasKey=KeyRingButton~=nil and (KEYRING_CONTAINER~=nil or Enum and Enum.BagIndex and Enum.BagIndex.Keyring~=nil)
 local layout=K.ClassicBagDesigns.Layout(K.ClassicBagDesigns.ID(),size,columns,0,K.ClassicInventoryStyle.ItemGap(),shortcutGap,shelfHidden,hasKey)
 local gridLeft,itemTop=layout.itemX,layout.itemY
 for bag=0,4 do
  local count=Slots(bag);local holder=holders[bag];holder.size=count
  local row=bagButtons[bag]
  local inventory=bag>0 and C_Container.ContainerIDToInventoryID(bag)
  local icon=bag==0 and 'Interface\\Buttons\\Button-Backpack-Up'or(inventory and GetInventoryItemTexture('player',inventory))or'Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag'
  if row.kaIcon~=icon then row.icon:SetTexture(icon);row.kaIcon=icon end
  -- Position after the filtered item count determines the bottom tray.
  row:SetShown(not shelfHidden)
  row:SetAlpha(count>0 and 1 or .4);row:SetBackdropBorderColor(.65,.72,.78,filterBag==bag and 1 or 0)
  total=total+count
  for slot=1,count do
   local info=C_Container.GetContainerItemInfo(bag,slot);if not info then free=free+1 elseif not info.iconFileID then waitingForItemInfo=true end
   local button=buttons[bag][slot]
   if not button then
    button=CreateFrame('Button',holder:GetName()..'Item'..slot,holder,'ContainerFrameItemButtonTemplate')
    button:SetID(slot);buttons[bag][slot]=button
   end
   if (filterBag==nil or filterBag==bag) and M.Matches(info,query) then
    local scale=size/37;local x,y=(gridLeft+(n%columns)*cell)/scale,(-itemTop-math.floor(n/columns)*cell)/scale
    if button.kaScale~=scale then button:SetSize(37,37);button:SetScale(scale);button.kaScale=scale end
    if button.kaX~=x or button.kaY~=y then button:ClearAllPoints();button:SetPoint('TOPLEFT',frame,'TOPLEFT',x,y);button.kaX,button.kaY=x,y end
    Paint(button,bag,slot,info,true);if not button:IsShown()then button:Show()end;n=n+1
   else button:Hide() end
  end
  for slot=count+1,#buttons[bag] do buttons[bag][slot]:Hide() end
 end
 local l=K.ClassicBagDesigns.Layout(K.ClassicBagDesigns.ID(),size,columns,n,K.ClassicInventoryStyle.ItemGap(),shortcutGap,shelfHidden,hasKey)
 SetText(footer,CapacityText(free,total,l))
 SetText(bagButtons[0].free,tostring(free));for bag=1,4 do SetText(bagButtons[bag].free,'')end
 SetText(moneyText,Money())
 local moneyWidth=math.min(96,math.max(70,(moneyText.GetStringWidth and moneyText:GetStringWidth()or 80)+12))
 moneyText:SetWidth(moneyWidth);moneyHit:SetWidth(moneyWidth+8)
 local key=table.concat({l.id,size,columns,l.rows,tostring(shelfHidden),tostring(hasKey),K.ClassicInventoryStyle.ItemGap(),shortcutGap,tostring(Option('bagBackground',true)),tostring(Option('bagFrame',true)),KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or'en'},':')
 if frame.kaGeometryKey~=key then
  Count('layout')
 frame:SetSize(l.width,l.height);frame.kaBagLayout=l
 K.ClassicBagDesigns.PaintShelf(frame,l,Option('bagBackground',true))
 for bag=0,4 do
  local row=bagButtons[bag];row:SetSize(l.iconSize,l.iconSize);row:ClearAllPoints();row:SetPoint('TOPLEFT',l.icons[bag].x,-l.icons[bag].y);K.ClassicBagDesigns.SkinShortcut(row)
 end
 keyButton:SetSize(l.id==2 and 24 or 25,l.iconSize);keyButton:ClearAllPoints();keyButton:SetPoint('TOPLEFT',l.icons[5].x,-l.icons[5].y)
 keyButton:SetShown(not shelfHidden and hasKey);K.ClassicBagDesigns.SkinShortcut(keyButton)
 local moneyWidth=math.min(96,math.max(70,(moneyText.GetStringWidth and moneyText:GetStringWidth()or 80)+12))
 local record=frame.kaRecordsButton
 record:ClearAllPoints();footer:ClearAllPoints();moneyText:ClearAllPoints();moneyHit:ClearAllPoints()
 record:SetSize(l.recordWidth,28);record:SetPoint('BOTTOMLEFT',14,10)
 footer:SetPoint('BOTTOMLEFT',l.footerX,16);footer:SetWidth(l.footerWidth);footer:SetJustifyH('CENTER')
 moneyText:SetPoint('BOTTOMRIGHT',-14,16);moneyHit:SetPoint('BOTTOMRIGHT',-10,8)
 footer:SetWordWrap(false);if footer.SetMaxLines then footer:SetMaxLines(1)end
 shelfToggle:SetText('');shelfToggle.icon:SetAlpha(shelfHidden and .55 or 1)
 shelfToggle:ClearAllPoints();shelfToggle:SetSize(l.headerSize,l.headerSize);shelfToggle:SetPoint('TOPLEFT',l.controls.shelf.x,-l.controls.shelf.y)
 for _,b in ipairs(frame.kaResizeButtons or{})do
  local p=b.kaResizeDelta<0 and l.controls.minus or l.controls.plus
  b:SetSize(l.headerSize,l.headerSize);b:ClearAllPoints();b:SetPoint('TOPLEFT',p.x,-p.y)
  if b.SetEnabled then b:SetEnabled(b.kaResizeDelta<0 and columns>M.MinimumColumns()or b.kaResizeDelta>0 and columns<14)end
 end
 frame.kaBagSettings:ClearAllPoints();frame.kaBagSettings:SetSize(l.headerSize,l.headerSize);frame.kaBagSettings:SetPoint('TOPRIGHT',-40,-l.headerY)
 for _,b in ipairs(frame.kaDesignButtons)do if b.kaRole=='close'then b:SetSize(l.headerSize,l.headerSize);b:ClearAllPoints();b:SetPoint('TOPRIGHT',-10,-l.headerY)end end
 -- Main inventory deliberately has no character-name caption.
 K.ClassicBagDesigns.Interior(frame,l,Option('bagBackground',true))
 K.ClassicBagDesigns.CapacityFont(footer)
 search:ClearAllPoints();search:SetPoint('TOPLEFT',l.searchX,-l.searchY);search:SetSize(l.searchWidth,26);searchHint:SetWidth(math.max(1,l.searchWidth-54));K.ClassicBagDesigns.SkinSearch(search,l.id,l)
 searchClear:ClearAllPoints();searchClear:SetPoint('RIGHT',search,'RIGHT',-4,0);searchClear:SetSize(20,20);searchClear:SetFrameLevel(search:GetFrameLevel()+1);searchClear:Show()
 sortButton:ClearAllPoints();sortButton:SetSize(76,26);sortButton:SetPoint('TOPRIGHT',-14,-l.searchY);SortLabel()
 for _,b in ipairs(frame.kaDesignButtons)do K.ClassicBagDesigns.PaintButton(b,l.id)end

 M.DockKeyring()
 frame.kaGeometryKey=key
 end
 searchClear:Show();searchHint:SetShown(search:GetText()=='');SortLabel()
 pendingRefresh=false
end
function M.Refresh()
 if refreshing or not frame or not frame:IsShown()then return end
 refreshing=true;Count('refresh');local began=perf and Clock()
 local ok,err=pcall(RefreshVisible);refreshing=false
 if perf and began then perf.ms=perf.ms+math.max(0,Clock()-began)end
 if not ok then error(err,0)end
end
CloseNative=function()
 if CloseAllBags then CloseAllBags() end
 M.RestoreNativeBagAlpha()
end
local function Show()
 if not M.Enabled() or not Ensure() then M.RestoreNativeBagAlpha();return false end
 busy=true;CloseNative();if not frame:IsShown()then paintEpoch=paintEpoch+1;frame:Show();M.Refresh()end;busy=false;return true
end
-- A bank visit is an explicit open, even when native OpenAllBags calls
-- ToggleBag internally. Discard those pending toggles before the UI handoff.
function M.OpenForBank()
 pendingToggle,pendingOpen=false,false
 return Show()
end
function M.Toggle()
 if not M.Enabled() then
  local replacement=Replacement();Message(replacement and (T('Another bag addon is active: ')..replacement) or T('Enable combined bags in the inventory settings first.'));return false
 end
 if frame and frame:IsShown() then frame:Hide();return true end
 return Show()
end
local function Schedule(toggle)
 diagnostic.requests=diagnostic.requests+1
 if busy or not M.Enabled() then return end
 if toggle then pendingToggle=true else pendingOpen=true end
 if queued then return end;queued=true
 C_Timer.After(0,function()
  diagnostic.handled=diagnostic.handled+1
  queued=false;local wantToggle,wantOpen=pendingToggle,pendingOpen;pendingToggle,pendingOpen=false,false
  if not M.Enabled() then M.RestoreNativeBagAlpha();return end
  if wantToggle then M.Toggle() elseif wantOpen then Show() end
 end)
end
-- Post-hooks leave Blizzard functions and native item scripts intact. All native
-- bag calls in the same UI action are coalesced before closing their windows.
local callHooks={}
function M.InstallBagCallHooks()
 for _,name in ipairs({'ToggleAllBags','ToggleBackpack','ToggleBag','OpenAllBags','OpenBackpack'}) do
  local hookName=name;local current=_G[hookName]
  if type(current)=='function' and callHooks[hookName]~=current then
   diagnostic.hooks=diagnostic.hooks+1
   hooksecurefunc(hookName,function(id)
    diagnostic.calls=diagnostic.calls+1;diagnostic.last=hookName
    if hookName=='ToggleBag' and id==KeyID() then QueueDock()
    elseif hookName=='OpenAllBags' or hookName=='OpenBackpack' then Schedule(false)
    elseif hookName~='ToggleBag' or type(id)=='number' and id>=0 and id<=4 then Schedule(true) end
   end)
   callHooks[hookName]=_G[hookName]
  end
 end
 local current=_G.ContainerFrame_GenerateFrame
 if type(current)=='function' and callHooks.ContainerFrame_GenerateFrame~=current then
  hooksecurefunc('ContainerFrame_GenerateFrame',function(f)
   M.InstallNativeBagHooks();if f and f:IsShown() then MaskNativeBag(f) end
  end)
  callHooks.ContainerFrame_GenerateFrame=_G.ContainerFrame_GenerateFrame
 end
end
QueueNativeHandoff=function() Schedule(false) end
function M.PrepareBags()
 M.InstallSplitHook()
 M.InstallBagCallHooks();M.InstallNativeBagHooks()
 if M.Enabled() then Ensure() else M.RestoreNativeBagAlpha() end
end
local function Startup(initialLogin)
 startupGeneration=startupGeneration+1;local token=startupGeneration
 -- Capture account money even when Bagnon owns the inventory window.
 -- Zero is accepted only after the world has settled; later PLAYER_MONEY
 -- events still record genuine spending down to zero immediately.
 if initialLogin then local db=WealthStore(false);local key=Identity();if db and key then db.removed[key]=nil end end
 for _,delay in ipairs({0,.5,2,5}) do
  local settled=delay>=2
  C_Timer.After(delay,function()
   if token~=startupGeneration then return end
   M.PrepareBags();M.RecordMoney(false,settled);M.RefreshMoneyList()
  end)
 end
end
M.InstallBagCallHooks()
if type(UpdateContainerFrameAnchors)=='function' then hooksecurefunc('UpdateContainerFrameAnchors',QueueDock) end
local previousSet=K.InventoryMenus and K.InventoryMenus.Set
if previousSet then
 function K.InventoryMenus.Set(key,value)
  if key=='bagCombined' then
   if not K.db or Combat() or type(value)~='boolean' then return false end
   K.db.bagCombined=value;if value then M.PrepareBags() end;if not value then if frame then frame:Hide() end;M.RestoreNativeBagAlpha() end;return true
  end
  local ok=previousSet(key,value);if not K.ClassicInventoryStyle and frame and frame:IsShown()then M.Refresh()end;return ok
 end
end
K.BagMode={Get=function() return K.db and K.db.bagCombined~=false end,Set=function(value) return K.InventoryMenus.Set('bagCombined',value) end,ApplySaved=function() end}
function M.Status()
 local changed=0
 for name,fn in pairs(callHooks) do if _G[name]~=fn then changed=changed+1 end end
 Message(string.format('enabled=%s shown=%s busy=%s queued=%s changed=%d',tostring(not not M.Enabled()),tostring(frame and frame:IsShown() or false),tostring(busy),tostring(queued),changed))
 Message(string.format('hooks=%d calls=%d requests=%d handled=%d last=%s',diagnostic.hooks,diagnostic.calls,diagnostic.requests,diagnostic.handled,diagnostic.last))
end
local events=CreateFrame('Frame')
-- Native or third-party bag functions may be replaced after PLAYER_LOGIN and
-- the last startup timer, without another ADDON_LOADED notification. Check
-- references only, once per second; never open/toggle a bag from this watcher.
local hookElapsed=0
events:SetScript('OnUpdate',function(_,elapsed)
 hookElapsed=hookElapsed+elapsed;if hookElapsed<1 then return end;hookElapsed=0
 if M.Enabled() then M.InstallBagCallHooks();M.InstallNativeBagHooks() end
end)
for _,event in ipairs({'QUEST_LOG_UPDATE','BAG_UPDATE_DELAYED','PLAYER_EQUIPMENT_CHANGED','ITEM_LOCK_CHANGED','BAG_UPDATE_COOLDOWN','PLAYER_MONEY','GET_ITEM_INFO_RECEIVED','PLAYER_REGEN_ENABLED','PLAYER_REGEN_DISABLED','PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_LOGOUT','ADDON_LOADED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(_,event,initialLogin,isReloadingUi)
 if perf then perf.events[event]=(perf.events[event]or 0)+1 end
 if event=='BAG_UPDATE_COOLDOWN'then M.RefreshCooldowns();return end
 if event=='GET_ITEM_INFO_RECEIVED'and not waitingForItemInfo then return end
 if event=='QUEST_LOG_UPDATE'or event=='GET_ITEM_INFO_RECEIVED'then paintEpoch=paintEpoch+1 end
 if event=='PLAYER_ENTERING_WORLD' then
  moneyReady=false;Startup(initialLogin==true and isReloadingUi~=true)
 elseif event=='PLAYER_LOGIN' then
  -- Core settings and other addons may finish initializing later in this event.
  C_Timer.After(0,function() M.PrepareBags() end)
 elseif event=='PLAYER_MONEY'then M.RecordMoney();M.RefreshMoneyList();M.RefreshMoney();return
 elseif event=='PLAYER_LOGOUT' then
  -- Keep the latest valid snapshot; teardown APIs may already report zero.
  startupGeneration=startupGeneration+1
 end
 if event=='ADDON_LOADED' then C_Timer.After(0,function() M.PrepareBags() end) end
 if event=='PLAYER_REGEN_DISABLED' then M.StopSort();if frame then frame:StopMovingOrSizing() end end
 if event=='ADDON_LOADED' and not M.Enabled() then if frame then frame:Hide() end;M.RestoreNativeBagAlpha();return end
 if frame and frame:IsShown() then
  if redrawQueued then pendingRefresh=true;return end
  redrawQueued=true;C_Timer.After(.05,function()redrawQueued=false;M.Refresh()end)
 elseif event=='PLAYER_REGEN_ENABLED' then pendingRefresh=false end
end)
SLASH_KERIMANKAUICLASSICBAGS1='/kauibags'
SlashCmdList.KERIMANKAUICLASSICBAGS=function(input)
 input=(input or ''):lower():match('^%s*(.-)%s*$')
 if input=='perf'then M.StartPerf();return end
 if input=='status' then M.Status();return end
 if input=='repair' then M.PrepareBags();M.Status();return end
 if input=='off' then if K.InventoryMenus.Set('bagCombined',false) then Message(T('Combined bags off. Native bags restored.')) else Message(T('Change bag mode outside combat.')) end;return end
 if input=='on' then if K.InventoryMenus.Set('bagCombined',true) then Show() end;return end
 M.Toggle()
end



M.InstallNativeBagHooks()

M.InstallSplitHook()
