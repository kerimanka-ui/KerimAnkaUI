-- Original KerimAnka UI implementation: read-only Classic item snapshots.
-- No Bagnon code, dependencies, data imports, or native item-action templates.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
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
 local root=KAClassic_KerimAnkaUIDB;if type(root)~='table' then return end
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
 local wealth=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.bagWealth
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
 local wealth=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.bagWealth
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
local function CopyItem(info)
 if not info then return end
 local link=type(info.hyperlink)=='string' and info.hyperlink or nil
 local name=link and link:match('%[(.-)%]')
 return {itemID=tonumber(info.itemID),link=link,icon=info.iconFileID,count=tonumber(info.stackCount) or 1,
  quality=tonumber(info.quality) or 1,name=name}
end
function M.Capture(kind)
 if kind~='bags' and kind~='bank' then return false end
 if kind=='bank' and not bankOpen then return false end
 local C=C_Container;if not C or not C.GetContainerNumSlots or not C.GetContainerItemInfo then return false end
 local key,name,realm=Identity();if not key then return false end
 local db=Store(true);if not db or db.removed[key] then return false end
 local base=kind=='bank' and -1 or 0
 local baseSlots=C.GetContainerNumSlots(base)
 -- Do not replace a valid snapshot with unavailable world/bank data.
 if type(baseSlots)~='number' or baseSlots<=0 then return false end
 local ids={0,1,2,3,4}
 if kind=='bank' then
  ids={-1};local count=math.max(0,math.min(7,tonumber(NUM_BANKBAGSLOTS) or 6))
  for i=1,count do ids[#ids+1]=4+i end
 end
 local snapshot={updated=Timestamp(),containers={},slots=0,occupied=0}
 for _,bag in ipairs(ids) do
  local count=C.GetContainerNumSlots(bag) or 0
  if type(count)~='number' or count<0 or count>160 then return false end
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
 record.lastSeen=Timestamp();record[kind]=snapshot
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
 db.characters[key]=nil;db.removed[key]=true;db.favorites[key]=nil
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
local function Text(parent,size)
 return parent:CreateFontString(nil,'OVERLAY',size or 'GameFontHighlightSmall')
end
local function Button(parent,name,text,x,y,width,fn)
 local b=CreateFrame('Button',name,parent,'UIPanelButtonTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(width,24);b:SetText(text);b:SetScript('OnClick',fn);return b
end
local function ItemTooltip(self)
 local entry=self.entry;if not entry then return end
 GameTooltip:SetOwner(self,'ANCHOR_RIGHT')
 local item=entry.item
 if item and item.link and GameTooltip.SetHyperlink then
  local ok=pcall(GameTooltip.SetHyperlink,GameTooltip,item.link)
  if not ok then GameTooltip:SetText(item.name or ('Item '..tostring(item.itemID or '?'))) end
 elseif item then GameTooltip:SetText(item.name or ('Item '..tostring(item.itemID or '?')))
 else GameTooltip:SetText('Empty recorded slot') end
 GameTooltip:AddLine(' ');GameTooltip:AddLine('Saved view only - items cannot be moved or used.',1,.82,0,true)
 GameTooltip:AddLine(string.format('Bag %d / slot %d',entry.bag,entry.slot),.65,.7,.62)
 GameTooltip:Show()
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
 b:SetScript('OnEnter',function(self) GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(M.IsFavorite(parent.recordKey) and 'Remove favorite' or 'Add favorite');GameTooltip:Show() end)
 b:SetScript('OnLeave',function() GameTooltip:Hide() end)
 return b
end
local function RefreshMenu()
 if not menu or not menu:IsShown() then return end
 local list=M.Characters();menuOffset=math.max(0,math.min(menuOffset or 0,math.max(0,#list-characterRows)))
 for i,b in ipairs(menu.buttons) do
  local entry=list[menuOffset+i];b:SetShown(entry~=nil);b.recordKey=entry and entry.key;b.record=entry and entry.record
  if entry then
   b.label:SetText(CharacterLabel(entry.record));PaintStar(b.star,M.IsFavorite(entry.key))
   b:SetBackdropColor(selected==entry.key and .20 or .04,selected==entry.key and .17 or .045,.035,.9)
  end
 end
 local count=math.max(1,math.min(characterRows,#list))
 menu.range:SetText(#list==0 and 'No recorded characters' or string.format('%d-%d / %d  |  Mouse wheel',menuOffset+1,math.min(#list,menuOffset+characterRows),#list))
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
    GameTooltip:AddLine('Inventory: '..(r.bags and 'saved' or 'not recorded')..' | Bank: '..(r.bank and 'saved' or 'not recorded'),1,.82,0,true);GameTooltip:Show()
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
local function Ensure()
 if panel then return end
 panel=CreateFrame('Frame','KerimAnkaUIClassicItemRecords',UIParent,'BackdropTemplate');panel:Hide();panel:SetSize(430,410)
 panel:SetFrameStrata('DIALOG');panel:SetClampedToScreen(true);panel:EnableMouse(true);panel:EnableMouseWheel(true);panel:SetMovable(true);panel:RegisterForDrag('LeftButton');Backdrop(panel)
 panel:SetScript('OnDragStart',function(self) self:StartMoving() end);panel:SetScript('OnDragStop',function(self) self:StopMovingOrSizing() end)
 panel:SetScript('OnHide',function() if menu then menu:Hide() end;GameTooltip:Hide() end)
 local heading=Text(panel,'GameFontNormal');heading:SetPoint('TOPLEFT',12,-13);heading:SetText('KerimAnka UI - Recorded items')
 local close=CreateFrame('Button',nil,panel,'UIPanelCloseButton');close:SetPoint('TOPRIGHT',1,1);close:SetScript('OnClick',function() panel:Hide() end)
 selector=Button(panel,'KerimAnkaUIClassicRecordCharacter','Select character',12,-38,300,ToggleMenu)
 inventoryTab=Button(panel,'KerimAnkaUIClassicRecordInventory','Inventory',12,-70,110,function() mode='bags';offset=0;M.Refresh() end)
 bankTab=Button(panel,'KerimAnkaUIClassicRecordBank','Bank',128,-70,110,function() mode='bank';offset=0;M.Refresh() end)
 local readOnly=Text(panel);readOnly:SetPoint('TOPRIGHT',-12,-77);readOnly:SetText('Read-only')
 status=Text(panel);status:SetPoint('TOPLEFT',12,-103);status:SetWidth(406);status:SetJustifyH('LEFT')
 rows={}
 for i=1,columns*visibleRows do
  -- Display-only buttons intentionally do NOT inherit any inventory template.
  local b=CreateFrame('Button',nil,panel,'BackdropTemplate');b:SetSize(34,34)
  b:SetPoint('TOPLEFT',12+((i-1)%columns)*cell,-132-math.floor((i-1)/columns)*cell)
  b:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});b:SetBackdropColor(.06,.065,.055,.8)
  b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetPoint('TOPLEFT',2,-2);b.icon:SetPoint('BOTTOMRIGHT',-2,2)
  b.count=Text(b,'NumberFontNormalSmall');b.count:SetPoint('BOTTOMRIGHT',-1,1)
  b:SetScript('OnEnter',ItemTooltip);b:SetScript('OnLeave',function() GameTooltip:Hide() end)
  rows[i]=b
 end
 summary=Text(panel);summary:SetPoint('BOTTOMLEFT',12,12);summary:SetWidth(406);summary:SetJustifyH('LEFT')
 panel:SetScript('OnMouseWheel',function(_,delta) offset=offset-delta;M.Refresh() end)
 UISpecialFrames=UISpecialFrames or {};table.insert(UISpecialFrames,'KerimAnkaUIClassicItemRecords')
end
function M.Refresh()
 if not panel or not panel:IsShown() then return end
 local list=M.Characters()
 if not selected or not Record(selected) then
  local key=Identity();selected=Record(key) and key or list[1] and list[1].key;offset=0
 end
 local record=selected and Record(selected)
 local snapshot=record and record[mode]
 selector:SetText(record and (CharacterLabel(record)..'  v') or 'No recorded characters')
 inventoryTab:SetAlpha(mode=='bags' and 1 or .55);bankTab:SetAlpha(mode=='bank' and 1 or .55)
 local slots=Flat(snapshot);local rowCount=math.max(1,math.ceil(#slots/columns))
 offset=math.max(0,math.min(offset,math.max(0,rowCount-visibleRows)))
 for i,b in ipairs(rows) do
  local entry=slots[offset*columns+i];b.entry=entry;b:SetShown(entry~=nil)
  if entry then
   local item=entry.item;b.icon:SetTexture(item and item.icon or nil);b.icon:SetShown(item~=nil)
   b.count:SetText(item and item.count>1 and tostring(item.count) or '')
   local c=ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[item and item.quality or 1] or {r=.4,g=.4,b=.4}
   local coloured=item and type(item.quality)=='number' and item.quality>=2
   b:SetBackdropBorderColor(coloured and c.r or .25,coloured and c.g or .25,coloured and c.b or .25,1)
  end
 end
 if snapshot then
  status:SetText('Last recorded: '..Stamp(snapshot.updated))
  summary:SetText(string.format('%d / %d slots occupied | Rows %d-%d / %d',snapshot.occupied,snapshot.slots,offset+1,math.min(rowCount,offset+visibleRows),rowCount))
 else
  status:SetText(mode=='bank' and 'Bank not recorded. Visit the bank on this character.' or 'Inventory not recorded yet. Log in on this character.')
  summary:SetText('No snapshot - this does not mean the container is empty.')
 end
 panel:SetHeight(174+cell*math.min(visibleRows,rowCount));RefreshMenu()
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
 w.Text(page,'Recorded inventory and bank',8,y,690,18,{.73,.62,.41});y=y-34
 w.Text(page,'Read-only snapshots. Inventory updates on login and bag changes; bank updates only while the bank is open.',8,y,690,13,{.65,.70,.62});y=y-55
 w.Button(page,'Open recorded items',0,y,240,32,function() M.Open() end);y=y-48
 local list=M.Characters()
 for _,entry in ipairs(list) do
  local key=entry.key;local r=entry.record;local box=w.Box(page,0,y,714,46)
  w.Text(box,ColourName(r),12,-14,400,13)
  w.Text(box,'Inventory: '..(r.bags and 'saved' or '-')..' | Bank: '..(r.bank and 'saved' or '-'),418,-14,230,12)
  w.Button(box,'X',662,-10,30,26,function() M.Remove(key);if K.Render then K.Render() end end);y=y-54
 end
 return y-20
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_ENTERING_WORLD','BAG_UPDATE_DELAYED','PLAYERBANKSLOTS_CHANGED','PLAYERBANKBAGSLOTS_CHANGED','BANKFRAME_OPENED','BANKFRAME_CLOSED','PLAYER_LOGOUT'}) do events:RegisterEvent(event) end
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
