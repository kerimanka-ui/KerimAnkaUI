-- Original KerimAnka UI implementation: read-only Classic item snapshots.
-- No Bagnon code, dependencies, data imports, or native item-action templates.
local _,K=...
local T=K.InventoryText
local M={};K.ClassicItemRecords=M
local bankOpen=false
local bankGeneration=0
local pending={}
local panel,selector,menu,status,summary,rows,inventoryTab,bankTab
local selected,mode,offset,menuOffset=nil,'bags',0,0
local visibleRows=6
local characterRows=10
local columns,cell=10,38
local function Store(create)
 local root=KerimAnkaUIDB;if type(root)~='table' then return end
 if create and type(root.itemRecords)~='table' then root.itemRecords={version=1,characters={},removed={}} end
 local db=root.itemRecords
 if type(db)=='table' then
  db.characters=type(db.characters)=='table' and db.characters or {}
  db.removed=type(db.removed)=='table' and db.removed or {}
  db.favorites=type(db.favorites)=='table' and db.favorites or {};return db
 end
end
local function Identity()
 if not UnitName then return end
 local name,realm;if UnitFullName then name,realm=UnitFullName('player') end
 name=name or UnitName('player');realm=realm or (GetRealmName and GetRealmName()) or '?'
 if not name or name=='' then return end
 return (UnitGUID and UnitGUID('player')) or (name..'-'..realm),name,realm
end
local function Timestamp() return time and time() or 0 end
local function Stamp(value)
 return date and date('%d.%m.%Y %H:%M',value or 0) or tostring(value or 0)
end
local function ColourName(record)
 local c=RAID_CLASS_COLORS and RAID_CLASS_COLORS[record.class] or {r=1,g=1,b=1}
 return string.format('|cff%02x%02x%02x%s|r',math.floor(c.r*255+.5),math.floor(c.g*255+.5),math.floor(c.b*255+.5),record.name)..' - '..record.realm
end
local function Record(key)
 local db=Store(false)
 if db and db.removed[key] then return end
 local record=db and db.characters[key]
 if record then return record end
 -- Older logins may have a money snapshot but no item snapshot. Include their
 -- identity without inventing inventory/bank contents or copying money data.
 local wealth=KerimAnkaUIDB and KerimAnkaUIDB.bagWealth
 if wealth and type(wealth.characters)=='table' and not (wealth.removed and wealth.removed[key]) then return wealth.characters[key] end
end
function M.IsFavorite(key)
 local db=Store(false);return db and db.favorites[key]==true or false
end
function M.SetFavorite(key,value)
 if type(value)~='boolean' or not Record(key) then return false end
 local db=Store(true);if not db then return false end
 db.favorites[key]=value and true or nil;menuOffset=0
 if panel and panel:IsShown() then M.Refresh() end
 return true
end
function M.Characters()
 local db=Store(false);local list,seen={},{}
 local function Add(key)
  if seen[key] then return end;seen[key]=true
  local record=Record(key)
  if type(record)=='table' and type(record.name)=='string' and type(record.realm)=='string' then list[#list+1]={key=key,record=record} end
 end
 if db then for key in pairs(db.characters) do Add(key) end end
 local wealth=KerimAnkaUIDB and KerimAnkaUIDB.bagWealth
 if wealth and type(wealth.characters)=='table' then for key in pairs(wealth.characters) do Add(key) end end
 table.sort(list,function(a,b)
  local af,bf=M.IsFavorite(a.key),M.IsFavorite(b.key)
  if af~=bf then return af end
  if a.record.realm~=b.record.realm then return a.record.realm<b.record.realm end
  if a.record.name~=b.record.name then return a.record.name<b.record.name end
  return a.key<b.key
 end)
 return list
end
local function CharacterLabel(record)
 local c=RAID_CLASS_COLORS and RAID_CLASS_COLORS[record.class] or {r=1,g=1,b=1}
 local icon=''
 local atlas=record.race and ('raceicon128-'..record.race:lower()..(record.sex==3 and '-female' or '-male'))
 if atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then icon='|A:'..atlas..':16:16|a '
 else
  local uv=CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[record.class]
  if uv then icon=string.format('|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:16:16:0:0:256:256:%d:%d:%d:%d|t ',uv[1]*256,uv[2]*256,uv[3]*256,uv[4]*256) end
 end
 return icon..string.format('|cff%02x%02x%02x%s|r |cff999999%s|r',math.floor(c.r*255+.5),math.floor(c.g*255+.5),math.floor(c.b*255+.5),record.name,record.realm)
end
-- Item identities, not inventory ownership: keep observed names usable after
-- an item is sold or another character's client cache does not know its name.
local catalogRef,catalogCount
local function Catalog(create)
 local db=Store(create);if not db then return end
 if type(db.knownItemIDs)~='table'and create then db.knownItemIDs={}end
 local ids=db.knownItemIDs;if type(ids)~='table'then return end
 if catalogRef~=ids then
  local count=0;for _ in pairs(ids)do count=count+1;if count>4096 then catalogRef,catalogCount=ids,count;return end end
  catalogRef,catalogCount=ids,count
 end
 if catalogCount<=4096 then return ids end
end
local function ItemIdentity(item)
 if type(item)~='table'or(issecretvalue and issecretvalue(item))then return end
 local link=item.link
 if type(link)~='string'or(issecretvalue and issecretvalue(link))or #link>512 then return end
 local id,name=link:match('|Hitem:(%d+)[^|]*|h%[(.-)%]|h');id=tonumber(id)
 if not id or id<=0 or id>4294967295 or not name or name==''or #name>200 then return end
 if issecretvalue and issecretvalue(item.itemID)then return end
 if item.itemID and item.itemID~=id then return end
 return name,id
end
local function RememberItem(item)
 local name,id=ItemIdentity(item);if not name then return end
 local ids=Catalog(true);if not ids then return end
 if ids[name]==nil then
  if catalogCount>=4096 then return end
  ids[name]=id;catalogCount=catalogCount+1
 elseif ids[name]~=id then ids[name]=false end -- ambiguous names stay unresolved
end
function M.FindItemID(name)
 if type(name)~='string'or(issecretvalue and issecretvalue(name))or name==''or #name>200 then return end
 local db=Store(false);if not db then return end
 local ids=Catalog(false);local found=ids and ids[name]
 if found==false then return nil,'ambiguous' end
 if type(found)~='number'or found<=0 or found>4294967295 or found~=math.floor(found)then found=nil end
 -- Also use snapshots created before this catalog existed. Exact displayed
 -- names and real links only; never persist a guessed or conflicting ID.
 local budget=8192
 for key,record in pairs(db.characters)do
  budget=budget-1;if budget<0 then return end
  if type(record)=='table'and not db.removed[key]then
   for _,kind in ipairs({'bags','bank'})do
    local snapshot=record[kind]
    if type(snapshot)=='table'and type(snapshot.containers)=='table'then
     for _,bag in pairs(snapshot.containers)do
      budget=budget-1;if budget<0 then return end
      if type(bag)=='table'and type(bag.items)=='table'then
       for _,item in pairs(bag.items)do
        budget=budget-1;if budget<0 then return end
        local itemName,id=ItemIdentity(item)
        if itemName==name then if found and found~=id then return nil,'ambiguous' end;found=id end
       end
      end
     end
    end
   end
  end
 end
 return found
end
local function CopyItem(info)
 if not info then return end
 local link=type(info.hyperlink)=='string' and info.hyperlink or nil
 local name=link and link:match('%[(.-)%]')
 local item={itemID=tonumber(info.itemID),link=link,icon=info.iconFileID,count=tonumber(info.stackCount) or 1,
  quality=tonumber(info.quality) or 1,name=name}
 RememberItem(item);return item
end
function M.Capture(kind)
 if kind~='bags' and kind~='bank' then return false end
 if kind=='bank' and not bankOpen then return false end
 local C=C_Container;if not C or not C.GetContainerNumSlots or not C.GetContainerItemInfo then return false end
 local key,name,realm=Identity();if not key then return false end
 local db=Store(true);if not db or db.removed[key] then return false end
 local ids=kind=='bank'and K.ForeverInventoryAdapter.BankIDs()or K.ForeverInventoryAdapter.BagIDs()
 local available=false;for _,id in ipairs(ids)do local count=C.GetContainerNumSlots(id);if type(count)=='number'and count>0 then available=true;break end end
 if not available then return false end
 local snapshot={updated=Timestamp(),containers={},slots=0,occupied=0}
 for _,bag in ipairs(ids) do
  local count=C.GetContainerNumSlots(bag) or 0
  if type(count)~='number' or count<0 or count>200 then return false end
  local container={id=bag,slots=math.floor(count),items={}}
  for slot=1,container.slots do
   local item=CopyItem(C.GetContainerItemInfo(bag,slot))
   if item then container.items[slot]=item;snapshot.occupied=snapshot.occupied+1 end
  end
  snapshot.slots=snapshot.slots+container.slots;snapshot.containers[#snapshot.containers+1]=container
 end
 local record=db.characters[key] or {};db.characters[key]=record
 record.name=name;record.realm=realm
 if UnitClass then local _,class=UnitClass('player');record.class=class end
 if UnitRace then local _,race=UnitRace('player');record.race=race end
 if UnitSex then record.sex=UnitSex('player') end
 record.lastSeen=Timestamp();record[kind]=snapshot;M.InvalidateItemCounts(key)
 if panel and panel:IsShown() then M.Refresh() end
 return true
end
local function Queue(kind)
 if pending[kind] then return end
 pending[kind]=true
 local token=bankGeneration
 C_Timer.After(0,function()
  pending[kind]=false
  if kind=='bank' and token~=bankGeneration then return end
  M.Capture(kind)
 end)
end
function M.Remove(key)
 if not Record(key) then return false end
 local db=Store(true);if not db then return false end
 db.characters[key]=nil;db.removed[key]=true;db.favorites[key]=nil;M.InvalidateItemCounts(key)
 if selected==key then selected=nil;offset=0 end
 if panel and panel:IsShown() then M.Refresh() end
 return true
end
function M.Select(key,kind)
 if not Record(key) then return false end
 selected=key;if kind=='bags' or kind=='bank' then mode=kind end;offset=0
 if menu then menu:Hide() end
 if panel and panel:IsShown() then M.Refresh() end
 return true
end
function M.CurrentView()
 local record=selected and Record(selected)
 return selected,mode,record and record[mode]
end
local function Flat(snapshot)
 local slots={}
 for _,bag in ipairs(snapshot and snapshot.containers or {}) do
  for slot=1,bag.slots do slots[#slots+1]={bag=bag.id,slot=slot,item=bag.items[slot]} end
 end
 return slots
end
local function Backdrop(f)
 f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
 f:SetBackdropColor(.035,.04,.03,.98);f:SetBackdropBorderColor(.63,.49,.25,1)
end
local function Text(parent,size,fixed)
 local label=parent:CreateFontString(nil,'OVERLAY',size or 'GameFontHighlightSmall')
 label.kaInventoryFixedFont=fixed or false;if not fixed then K.InventoryFont(label)end;return label
end
local function Button(parent,name,text,x,y,width,fn)
 local b=K.ClassicBagDesigns.NewButton(name,parent,'records');b:SetPoint('TOPLEFT',x,y);b:SetSize(width,24);K.InventoryLabel(b,text);b:SetScript('OnClick',fn);return b
end
local function ItemTooltip(self)
 local entry=self.entry;if not entry then return end
 GameTooltip:SetOwner(self,'ANCHOR_RIGHT')
 local item=entry.item
 if item and item.link and GameTooltip.SetHyperlink then
  local ok=pcall(GameTooltip.SetHyperlink,GameTooltip,item.link)
  if not ok then GameTooltip:SetText(item.name or ('Item '..tostring(item.itemID or '?'))) end
 elseif item then GameTooltip:SetText(item.name or ('Item '..tostring(item.itemID or '?')))
 else GameTooltip:SetText(T('Empty recorded slot')) end
 GameTooltip:AddLine(' ');GameTooltip:AddLine(T('Saved view only - items cannot be moved or used.'),.9,.9,.86,true)
 GameTooltip:AddLine(string.format(T('Bag %d / slot %d'),entry.bag,entry.slot),.65,.7,.62)
 if item then M.AppendItemCounts(GameTooltip,item.itemID)end
 K.InventoryTooltip(GameTooltip);GameTooltip:Show()
end
-- Draw the small star with native UI lines: no font glyph or client atlas dependency.
local function PaintStar(button,favorite)
 local r,g,b=favorite and 1 or .45,favorite and .79 or .47,favorite and .18 or .42
 if button.lines then for _,line in ipairs(button.lines) do line:SetColorTexture(r,g,b,1) end
 else button:SetText(favorite and '|cffffc92e*|r' or '|cff73786b*|r') end
end
local function Star(parent)
 local b=CreateFrame('Button',nil,parent);b:SetSize(24,24);b:SetPoint('RIGHT',-1,0)
 if b.CreateLine then
  b.lines={};local vertices={}
  for i=0,9 do local angle=math.pi/2+i*math.pi/5;local radius=i%2==0 and 8 or 3.5;vertices[i+1]={math.cos(angle)*radius,math.sin(angle)*radius} end
  for i=1,10 do
   local line=b:CreateLine(nil,'OVERLAY');line:SetThickness(1.5)
   local a,z=vertices[i],vertices[i%10+1];line:SetStartPoint('CENTER',a[1],a[2]);line:SetEndPoint('CENTER',z[1],z[2]);b.lines[i]=line
  end
 end
 b:SetScript('OnClick',function(self) if parent.recordKey then M.SetFavorite(parent.recordKey,not M.IsFavorite(parent.recordKey)) end end)
 b:SetScript('OnEnter',function(self) GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(M.IsFavorite(parent.recordKey) and T('Remove favorite') or T('Add favorite'));K.InventoryTooltip(GameTooltip);GameTooltip:Show() end)
 b:SetScript('OnLeave',function() GameTooltip:Hide() end)
 return b
end
local function RefreshMenu()
 if not menu or not menu:IsShown() then return end
 K.ClassicInventoryStyle.PaintBackgroundPanel(menu,true)
 local list=M.Characters();menuOffset=math.max(0,math.min(menuOffset or 0,math.max(0,#list-characterRows)))
 for i,b in ipairs(menu.buttons) do
  local entry=list[menuOffset+i];b:SetShown(entry~=nil);b.recordKey=entry and entry.key;b.record=entry and entry.record
  if entry then
   b.label:SetText(CharacterLabel(entry.record));PaintStar(b.star,M.IsFavorite(entry.key))
   b:SetBackdropColor(selected==entry.key and .20 or .04,selected==entry.key and .17 or .045,.035,.9)
  end
 end
 local count=math.max(1,math.min(characterRows,#list))
 menu.range:SetText(#list==0 and T('No recorded characters') or string.format(T('%d-%d / %d  |  Mouse wheel'),menuOffset+1,math.min(#list,menuOffset+characterRows),#list))
 menu:SetHeight(38+26*count)
end
local function ToggleMenu()
 if menu and menu:IsShown() then menu:Hide();return end
 if not menu then
  menu=CreateFrame('Frame','KerimAnkaUIClassicRecordMenu',panel,'BackdropTemplate');menu:SetWidth(360);menu:SetPoint('TOPLEFT',selector,'BOTTOMLEFT',0,-3)
  menu:SetFrameStrata('TOOLTIP');menu:SetClampedToScreen(true);menu:EnableMouse(true);menu:EnableMouseWheel(true);Backdrop(menu);menu.buttons={}
  for i=1,characterRows do
   local b=CreateFrame('Button',nil,menu,'BackdropTemplate');b:SetPoint('TOPLEFT',8,-7-(i-1)*26);b:SetSize(344,24)
   b:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'});b:SetBackdropColor(.04,.045,.035,.9)
   b.label=Text(b);b.label:SetPoint('LEFT',7,0);b.label:SetWidth(302);b.label:SetJustifyH('LEFT')
   b:SetScript('OnClick',function(self) if self.recordKey then M.Select(self.recordKey) end end)
   b:SetScript('OnEnter',function(self)
    local r=self.record;if not r then return end
    GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(ColourName(r))
    GameTooltip:AddLine(T('Inventory: ')..(r.bags and T('saved') or T('not recorded'))..T(' | Bank: ')..(r.bank and T('saved') or T('not recorded')),.9,.9,.86,true);K.InventoryTooltip(GameTooltip);GameTooltip:Show()
   end)
   b:SetScript('OnLeave',function() GameTooltip:Hide() end)
   b:EnableMouseWheel(true);b:SetScript('OnMouseWheel',function(_,delta) menuOffset=(menuOffset or 0)-delta;RefreshMenu() end)
   b.star=Star(b)
   menu.buttons[i]=b
  end
  menu.range=Text(menu);menu.range:SetPoint('BOTTOMLEFT',12,10);menu.range:SetTextColor(.65,.7,.62)
  menu:SetScript('OnMouseWheel',function(_,delta) menuOffset=(menuOffset or 0)-delta;RefreshMenu() end)
 end
 menuOffset=0
 -- Always start at the top so favorites are immediately visible.
 menu:Show();RefreshMenu()
end
local function RecordConfig()
 if not K.db then return {}end
 K.db.classicBags=K.db.classicBags or{};return K.db.classicBags
end
local function Bound(value,minimum,maximum,fallback)
 value=tonumber(value);if not value or value~=value or value==math.huge or value==-math.huge then return fallback end
 return math.max(minimum,math.min(maximum,math.floor(value+.5)))
end
function M.SetSize(newColumns,newRows)
 if not K.db or(InCombatLockdown and InCombatLockdown())then return false end
 local d=RecordConfig();d.recordColumns=Bound(newColumns,8,14,10);d.recordRows=Bound(newRows,3,10,6)
 offset=0;M.Refresh();return true
end
function M.StopResize()
 if panel and panel.kaGrip then panel.kaGrip:SetScript('OnUpdate',nil);panel.kaSizing=nil end
end
function M.StartResize()
 if not panel or not GetCursorPosition or(InCombatLockdown and InCombatLockdown())then return false end
 local x,y=GetCursorPosition();local scale=panel:GetEffectiveScale();if not x or not y or not scale or scale<=0 then return false end
 local originX,originY=x/scale,y/scale;local originW,originH=panel:GetWidth(),panel:GetHeight()
 panel.kaSizing=true
 panel.kaGrip:SetScript('OnUpdate',function()
  if(InCombatLockdown and InCombatLockdown())or(IsMouseButtonDown and not IsMouseButtonDown('LeftButton'))then M.StopResize();return end
  local px,py=GetCursorPosition();if not px or not py then M.StopResize();return end
  local cols=Bound((originW+px/scale-originX-24)/cell,8,14,10)
  local count=Bound((originH+originY-py/scale-192)/cell,3,10,6)
  local d=RecordConfig();if d.recordColumns~=cols or d.recordRows~=count then M.SetSize(cols,count)end
 end)
 return true
end
local function CreateRow(i)
 local b=CreateFrame('Button',nil,panel,'BackdropTemplate');b:SetSize(34,34);b.kaRecordSnapshotButton=true
 b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetAllPoints(b)
 b.count=Text(b,'NumberFontNormalSmall',true);b.count:SetPoint('BOTTOMRIGHT',-1,1)
 b:SetScript('OnEnter',ItemTooltip);b:SetScript('OnLeave',function()GameTooltip:Hide()end)
 rows[i]=b;return b
end
local function Ensure()
 if panel then return end
 panel=CreateFrame('Frame','KerimAnkaUIClassicItemRecords',UIParent,'BackdropTemplate');panel:Hide();panel:SetSize(430,430);panel.kaClassicInventory=true;panel.kaRecordWindow=true;panel.kaInventoryTextScope=mode=='bank'and'bank'or'bag'
 panel:SetFrameStrata('DIALOG');panel:SetClampedToScreen(true);panel:EnableMouse(true);panel:EnableMouseWheel(true);panel:SetMovable(true);panel:RegisterForDrag('LeftButton');Backdrop(panel)
 panel:SetScript('OnDragStart',function(self) self:StartMoving() end);panel:SetScript('OnDragStop',function(self) self:StopMovingOrSizing() end)
 panel:SetScript('OnHide',function()M.StopResize();if menu then menu:Hide()end;GameTooltip:Hide()end)
 local heading=Text(panel,'GameFontNormal');heading:SetPoint('TOPLEFT',12,-13);panel.kaHeading=heading
 local subtitle=Text(panel);subtitle:SetPoint('TOPLEFT',12,-35);panel.kaSubtitle=subtitle
 local close=K.ClassicBagDesigns.NewButton(nil,panel,'close');close:SetSize(22,22);close:SetPoint('TOPRIGHT',-6,-6);close:SetScript('OnClick',function() panel:Hide() end);panel.kaClose=close
 selector=Button(panel,'KerimAnkaUIClassicRecordCharacter','Select character',12,-54,300,ToggleMenu)
 local label=selector:GetFontString();label:ClearAllPoints();label:SetPoint('LEFT',8,0);label:SetWidth(266);label:SetJustifyH('LEFT')
 selector.kaArrow={}
 for i=1,2 do local line=selector:CreateTexture(nil,'OVERLAY');line:SetSize(7,1.5);line:SetPoint('RIGHT',i==1 and -13 or -8,0);line:SetColorTexture(.86,.82,.67,1);line:SetRotation(i==1 and -math.pi/4 or math.pi/4);selector.kaArrow[i]=line end
 inventoryTab=Button(panel,'KerimAnkaUIClassicRecordInventory','Inventory',12,-86,110,function() mode='bags';offset=0;M.Refresh() end)
 bankTab=Button(panel,'KerimAnkaUIClassicRecordBank','Bank',128,-86,110,function() mode='bank';offset=0;M.Refresh() end)
 local readOnly=Text(panel);readOnly:SetPoint('TOPRIGHT',-12,-93);K.InventoryLabel(readOnly,'Read-only')
 status=Text(panel);status:SetPoint('TOPLEFT',12,-119);status:SetWidth(406);status:SetJustifyH('LEFT')
 rows={}
 local smaller=K.ClassicBagDesigns.NewButton(nil,panel,'minus');smaller:SetSize(22,22);smaller:SetPoint('TOPRIGHT',-62,-6);panel.kaSmaller=smaller
 smaller:SetScript('OnClick',function()K.InventoryPresentation.ChangeText(mode=='bank'and'bank'or'bag',-1)end)
 local larger=K.ClassicBagDesigns.NewButton(nil,panel,'plus');larger:SetSize(22,22);larger:SetPoint('TOPRIGHT',-34,-6);panel.kaLarger=larger
 larger:SetScript('OnClick',function()K.InventoryPresentation.ChangeText(mode=='bank'and'bank'or'bag',1)end)
 local grip=CreateFrame('Button',nil,panel);grip:SetSize(18,18);grip:SetPoint('BOTTOMRIGHT',-5,5);grip:EnableMouse(true);panel.kaGrip=grip
 for i=1,3 do local line=grip:CreateTexture(nil,'OVERLAY');line:SetColorTexture(.73,.67,.48,1);line:SetSize(4+i*3,1.5);line:SetPoint('BOTTOMRIGHT',-i*3,i*3);line:SetRotation(math.pi/4)end
 grip:SetScript('OnMouseDown',function(_,button)if button=='LeftButton'then M.StartResize()end end)
 grip:SetScript('OnMouseUp',M.StopResize)
 summary=Text(panel);summary:SetPoint('BOTTOMLEFT',12,12);summary:SetWidth(406);summary:SetJustifyH('LEFT')
 panel:SetScript('OnMouseWheel',function(_,delta) offset=offset-delta;M.Refresh() end)
 UISpecialFrames=UISpecialFrames or {};table.insert(UISpecialFrames,'KerimAnkaUIClassicItemRecords')
end
function M.Refresh()
 if panel then K.ClassicInventoryStyle.Apply(panel,1)end
 if not panel or not panel:IsShown() then return end
 local scope=mode=='bank'and'bank'or'bag'
 K.InventoryPresentation.ScopeWindow(panel,scope)
 K.InventoryPresentation.TextButton(panel.kaSmaller,scope,-1);K.InventoryPresentation.TextButton(panel.kaLarger,scope,1)
 local list=M.Characters()
 if not selected or not Record(selected) then
  local key=Identity();selected=Record(key) and key or list[1] and list[1].key;offset=0
 end
 local record=selected and Record(selected)
 local snapshot=record and record[mode]
 selector:SetText(record and CharacterLabel(record)or T('No recorded characters'))
 panel.kaHeading:SetText(K.ClassicInventoryStyle.PriorityText(15));K.InventoryFont(panel.kaHeading,14);panel.kaHeading:SetTextColor(.95,.88,.65)
 panel.kaSubtitle:SetText(K.ClassicInventoryStyle.PriorityText(16));K.InventoryFont(panel.kaSubtitle,11);panel.kaSubtitle:SetTextColor(.65,.70,.62)
 local design=K.ClassicBagDesigns.ID()
 for _,button in ipairs({selector,inventoryTab,bankTab,panel.kaClose,panel.kaSmaller,panel.kaLarger})do K.ClassicBagDesigns.PaintButton(button,design)end
 inventoryTab:SetAlpha(mode=='bags' and 1 or .55);bankTab:SetAlpha(mode=='bank' and 1 or .55)
 local d=RecordConfig();columns=Bound(d.recordColumns,8,14,10);visibleRows=Bound(d.recordRows,3,10,6)
 cell=34+K.ClassicInventoryStyle.ItemGap();panel:SetWidth(math.max(360,columns*cell+24))
 panel.kaHeading:SetWidth(panel:GetWidth()-110)
 for i=#rows+1,columns*visibleRows do CreateRow(i)end
 status:SetWidth(panel:GetWidth()-24);summary:SetWidth(panel:GetWidth()-44)
 local slots=Flat(snapshot);local rowCount=math.max(1,math.ceil(#slots/columns))
 offset=math.max(0,math.min(offset,math.max(0,rowCount-visibleRows)))
 for i,b in ipairs(rows) do
  local entry=i<=columns*visibleRows and slots[offset*columns+i]or nil;b.entry=entry;b:SetShown(entry~=nil)
  b:ClearAllPoints();b:SetPoint('TOPLEFT',12+((i-1)%columns)*cell,-150-math.floor((i-1)/columns)*cell)
  if entry then
   local item=entry.item;K.ClassicInventoryStyle.EmptySlot(b,item~=nil);b.icon:SetTexture(item and item.icon or nil);b.icon:SetShown(item~=nil)
   b.count:SetText(item and item.count>1 and tostring(item.count) or '')
   K.ClassicInventoryStyle.PaintItemBorder(b,item and item.quality,item~=nil,false)
  end
 end
 if snapshot then
  status:SetText(T('Last recorded: ')..Stamp(snapshot.updated))
  summary:SetText(string.format(T('%d / %d slots occupied | Rows %d-%d / %d'),snapshot.occupied,snapshot.slots,offset+1,math.min(rowCount,offset+visibleRows),rowCount))
 else
  status:SetText(mode=='bank' and T('Bank not recorded. Visit the bank on this character.') or T('Inventory not recorded yet. Log in on this character.'))
  K.InventoryLabel(summary,'No snapshot - this does not mean the container is empty.')
 end
 panel:SetHeight(192+cell*math.min(visibleRows,rowCount));RefreshMenu()
end
function M.Open(kind)
 Ensure();if kind=='bags' or kind=='bank' then mode=kind end
 local owner=_G.KerimAnkaUIClassicBagFrame
 panel:ClearAllPoints()
 if owner and owner:IsShown() then
  local left=owner.GetLeft and owner:GetLeft();local scale=owner.GetEffectiveScale and owner:GetEffectiveScale() or 1
  if left and left*scale>440 then panel:SetPoint('TOPRIGHT',owner,'TOPLEFT',-8,0)
  else panel:SetPoint('TOPLEFT',owner,'TOPRIGHT',8,0) end
 else panel:SetPoint('CENTER',UIParent,'CENTER',0,0) end
 panel:Show();M.Refresh()
end
function M.Toggle()
 if panel and panel:IsShown() then panel:Hide() else M.Open() end
end
function M.DrawSettings(page,w,y)
 w.Text(page,T('Recorded inventory and bank'),8,y,690,18,{.73,.62,.41});y=y-34
 w.Text(page,T('Read-only snapshots. Inventory updates on login and bag changes; bank updates only while the bank is open.'),8,y,690,13,{.65,.70,.62});y=y-55
 w.Button(page,T('Open recorded items'),0,y,240,32,function() M.Open() end);y=y-48
 local list=M.Characters()
 for _,entry in ipairs(list) do
  local key=entry.key;local r=entry.record;local box=w.Box(page,0,y,714,46)
  w.Text(box,ColourName(r),12,-14,400,13)
  w.Text(box,T('Inventory: ')..(r.bags and T('saved') or '-')..T(' | Bank: ')..(r.bank and T('saved') or '-'),418,-14,230,12)
  w.Button(box,'X',662,-10,30,26,function() M.Remove(key);if K.Render then K.Render() end end);y=y-54
 end
 return y-20
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_ENTERING_WORLD','BAG_UPDATE_DELAYED','PLAYERBANKSLOTS_CHANGED','PLAYERBANKBAGSLOTS_CHANGED','BANKFRAME_OPENED','BANKFRAME_CLOSED','PLAYER_LOGOUT'}) do K.ForeverInventoryAdapter.RegisterEvent(events,event) end
events:SetScript('OnEvent',function(_,event,initialLogin,reloading)
 if event=='PLAYER_ENTERING_WORLD' then
  if initialLogin==true and reloading~=true then local db=Store(false);local key=Identity();if db and key then db.removed[key]=nil end end
  for _,delay in ipairs({0,.5,2}) do C_Timer.After(delay,function() M.Capture('bags') end) end
 elseif event=='BANKFRAME_OPENED' then
  bankOpen=true;bankGeneration=bankGeneration+1;local token=bankGeneration
  for _,delay in ipairs({0,.25,1}) do C_Timer.After(delay,function() if bankOpen and token==bankGeneration then M.Capture('bank') end end) end
 elseif event=='BANKFRAME_CLOSED' then bankOpen=false;bankGeneration=bankGeneration+1
 elseif event=='BAG_UPDATE_DELAYED' then Queue('bags');if bankOpen then Queue('bank') end
 elseif event=='PLAYERBANKSLOTS_CHANGED' or event=='PLAYERBANKBAGSLOTS_CHANGED' then if bankOpen then Queue('bank') end
 elseif event=='PLAYER_LOGOUT' then bankOpen=false;bankGeneration=bankGeneration+1 end
end)
SLASH_KERIMANKAUICLASSICRECORDS1='/kauirecords'
SlashCmdList.KERIMANKAUICLASSICRECORDS=function(text)
 text=(text or ''):lower():match('^%s*(.-)%s*$')
 if text=='bank' then M.Open('bank') elseif text=='bags' then M.Open('bags') else M.Toggle() end
end


-- Recorded inventories only. No live scans, item actions or foreign account access.
local ownerSummaries,ownerQueries,ownerStore={},{},nil
local ownerPlayer
function M.InvalidateItemCounts(key)
 if key then ownerSummaries[key]=nil else ownerSummaries={}end
 ownerQueries={}
end
local function Summary(snapshot)
 local result={}
 for _,container in ipairs(snapshot and snapshot.containers or{})do
  for _,item in pairs(container.items or{})do
   local id,count=tonumber(item.itemID)or(item.link and tonumber(item.link:match('item:(%d+)'))),tonumber(item.count)
   if id and id>0 and count and count>0 and count<1000000 then result[id]=(result[id]or 0)+math.floor(count)end
  end
 end
 return result
end
function M.ItemOwners(itemID)
 itemID=tonumber(itemID);if not itemID or itemID<=0 then return {},0 end
 local db=Store(false)
 if ownerStore~=db then ownerStore=db;M.InvalidateItemCounts()end
 local playerKey,playerName,playerRealm=Identity()
 local signature=tostring(playerKey)..':'..tostring(playerName)..':'..tostring(playerRealm)
 if ownerPlayer~=signature then ownerPlayer=signature;ownerQueries={}end
 if ownerQueries[itemID]then return ownerQueries[itemID].rows,ownerQueries[itemID].total end
 local rows,total={},0
 for _,entry in ipairs(M.Characters())do
  local record=entry.record;local cached=ownerSummaries[entry.key]
  if not cached or cached.bags~=record.bags or cached.bank~=record.bank then
   cached={bags=record.bags,bank=record.bank,bagCounts=Summary(record.bags),bankCounts=Summary(record.bank)};ownerSummaries[entry.key]=cached
  end
  local bags,bank=cached.bagCounts[itemID]or 0,cached.bankCounts[itemID]or 0
  local isPlayer=entry.key==playerKey or(playerName and record.name==playerName and record.realm==playerRealm)
  if not isPlayer and bags+bank>0 then
   total=total+bags+bank;rows[#rows+1]={key=entry.key,record=record,bags=bags,bank=bank,hasBags=record.bags~=nil,hasBank=record.bank~=nil}
  end
 end
 ownerQueries[itemID]={rows=rows,total=total};return rows,total
end
local ownerText={
 en={'Other characters','Total','Bags','Bank','Recorded snapshots. ? = not recorded.','Other characters'},
 tr={'Diğer karakterlerde','Toplam','Çanta','Banka','Son kayıtlara göre. ? = kayıt yok.','Diğer karakterler'},
 de={'Andere Charaktere','Gesamt','Taschen','Bank','Gespeicherte Daten. ? = nicht erfasst.','Weitere Charaktere'},
 frFR={'Autres personnages','Total','Sacs','Banque','Données enregistrées. ? = non enregistré.','Autres personnages'},
 itIT={'Altri personaggi','Totale','Borse','Banca','Dati salvati. ? = non registrato.','Altri personaggi'},
 esES={'Otros personajes','Total','Bolsas','Banco','Datos guardados. ? = sin registrar.','Otros personajes'},
 ptBR={'Outros personagens','Total','Bolsas','Banco','Dados salvos. ? = não registrado.','Outros personagens'},
 ruRU={'Другие персонажи','Всего','Сумки','Банк','Последние записи. ? = нет данных.','Другие персонажи'},
 zhCN={'其他角色','总计','背包','银行','根据最近记录。? = 尚未记录。','其他角色'},
}
local function OwnerText()
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en';return ownerText[lang]or ownerText.en
end
local function OwnerLabel(record)
 local label=CharacterLabel(record)
 if GetRealmName and record.realm==GetRealmName()then label=label:match('^(.-) |cff999999')or label end
 return label
end
function M.AppendItemCounts(tip,itemID)
 if K.ForeverInventoryAdapter.IsSecret(itemID)then return false end
 itemID=tonumber(itemID)
 if not tip or not itemID or tip.kaRecordedCountItem==itemID or not tip.AddDoubleLine then return false end
 local rows,total=M.ItemOwners(itemID);if #rows==0 then return false end
 tip.kaRecordedCountItem=itemID
 local text=OwnerText();tip:AddLine(' ')
 tip:AddDoubleLine(text[1],text[2]..': '..total,.83,.77,.58,.60,.76,.87)
 for i=1,math.min(6,#rows)do
  local row=rows[i]
  local right=text[3]..': '..(row.hasBags and tostring(row.bags)or'?')..'  '..text[4]..': '..(row.hasBank and tostring(row.bank)or'?')
  tip:AddDoubleLine(OwnerLabel(row.record),right,.87,.87,.82,.72,.79,.83)
 end
 if #rows>6 then
  local remaining=0;for i=7,#rows do remaining=remaining+rows[i].bags+rows[i].bank end
  tip:AddDoubleLine(text[6]..' ('..(#rows-6)..')',tostring(remaining),.60,.62,.59,.72,.79,.83)
 end
 tip:AddLine(text[5],.55,.59,.57,true);K.InventoryTooltip(tip);tip:Show();return true
end
function M.InstallItemTooltip()
 local tip=GameTooltip;if not tip or not tip.HookScript or tip.kaRecordedCountHook then return false end
 tip.kaRecordedCountHook=true
 if tip.HasScript and tip:HasScript('OnTooltipCleared')then
  tip:HookScript('OnTooltipCleared',function(self)self.kaRecordedCountItem=nil end)
 end
 tip:HookScript('OnHide',function(self)self.kaRecordedCountItem=nil end)
 local function Append(self,data)
  if self~=tip then return end
  local owner=self.GetOwner and self:GetOwner();if owner and owner.kaRecordSnapshotButton then return end
  local id=data and data.id
  if not id and self.GetItem then local _,link=self:GetItem();id=link and tonumber(link:match('item:(%d+)'))end
  M.AppendItemCounts(self,id)
 end
 if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,Append)
 elseif tip.HasScript and tip:HasScript('OnTooltipSetItem')then tip:HookScript('OnTooltipSetItem',Append)end
 return true
end
M.InstallItemTooltip()
