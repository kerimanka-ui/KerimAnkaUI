-- Forever adaptation; internal component names preserve existing settings keys.
local _,K=...
local T=K.InventoryText
local M={};K.ClassicBank=M
local panel,holder,footer,cost,search,sortButton,moneyText
local sortContext
local active,closing,queued=false,false,false
local states={};local masks=setmetatable({},{__mode='k'});local hooked=setmetatable({},{__mode='k'})
local bagHolders,items={},{}
local offset=0
local QueueRefresh
local management=false
local modernControls={}
local nativeVisuals={}
local opening=false
local headings={}
local openRequested=false
local function Config()
 if not K.db then return end
 K.db.classicBank=K.db.classicBank or {};return K.db.classicBank
end
local function Columns()
 local c=Config();return math.max(6,math.min(14,math.floor(tonumber(c and c.columns) or 10)))
end
local function Cell()return 34+K.ClassicInventoryStyle.ItemGap()end
local function Width() return math.max(280,Columns()*Cell()+28) end
local function Enabled() return K.ClassicBags and K.ClassicBags.Enabled() end
local function MaxBags() return math.max(0,math.min(7,tonumber(NUM_BANKBAGSLOTS) or 6)) end
local function BankBag(id) if type(id)~='number'then return false end;for _,bag in ipairs(K.ForeverInventoryAdapter.BankIDs())do if bag==id then return true end end;return false end
local function Save(f)
 if not f or states[f] then return end
 local s={parent=f:GetParent(),points={},scale=f:GetScale(),strata=f:GetFrameStrata(),level=f:GetFrameLevel(),width=f:GetWidth(),height=f:GetHeight(),shown=f:IsShown()}
 for i=1,f:GetNumPoints() do s.points[i]={f:GetPoint(i)} end;states[f]=s
end
local function Move(f,parent)
 Save(f);f:SetParent(parent);f:SetScale(1);f:SetFrameStrata('DIALOG');f:SetFrameLevel(panel:GetFrameLevel()+5)
end
local function RestoreMasks()
 for f,alpha in pairs(masks) do f:SetAlpha(alpha);masks[f]=nil end
end
function M.ReleaseNativeFrame(f)
 if masks[f]~=nil then local alpha=masks[f];masks[f]=nil;f:SetAlpha(alpha) end
end
local function Mask(f)
 if (active or (BankFrame and BankFrame:IsShown() and BankSlotsFrame)) and Enabled() and f and f.GetID and BankBag(f:GetID()) then
  if masks[f]==nil then masks[f]=f:GetAlpha() end;f:SetAlpha(0)
 end
end
local evidence={}
local setterHooked=false
local function Secure(object,key)
 if not object or not issecurevariable then return '?'end
 local clean,source=issecurevariable(object,key);return tostring(clean)..(source and('/'..source)or'')
end
function M.Trace(stage,stack)
 if #evidence>=12 then return end
 local f=BankFrame;local bp=f and f.BankPanel
 evidence[#evidence+1]={summary=stage..' bankType='..Secure(bp,'bankType')..' map1='..Secure(f and f.TabIDToBankType,1)..' bagOwner='..Secure(_G,'FRAME_THAT_OPENED_BAGS'),stack=stack}
end
function M.ObserveSetter()
 local bp=BankFrame and BankFrame.BankPanel
 if setterHooked or not bp or not bp.SetBankType then return end
 setterHooked=true;M.Trace('native-load')
 hooksecurefunc(bp,'SetBankType',function()M.Trace('native-SetBankType',debugstack and debugstack(2,9,0)or nil)end)
end
function M.Hooks()
 M.ObserveSetter()
 -- Native ShowUIPanel may reposition the bank AFTER its OnShow script. Handoff
 -- after that complete call, before the next rendered frame, not on a timer.
 if type(ShowUIPanel)=='function'and not hooked.panelShow then
  hooksecurefunc('ShowUIPanel',function(f)if f==BankFrame then M.Open()end end);hooked.panelShow=true
 end
 if BankFrame and not hooked.bankShow then
  BankFrame:HookScript('OnShow',function() management=false;QueueRefresh(true) end);hooked.bankShow=true
 end
 for i=1,(NUM_CONTAINER_FRAMES or 13) do
  local f=_G['ContainerFrame'..i]
  if f and not hooked[f] then hooked[f]=true;f:HookScript('OnShow',Mask) end
 end
 if type(ContainerFrame_GenerateFrame)=='function' and hooked.generate~=ContainerFrame_GenerateFrame then
  hooksecurefunc('ContainerFrame_GenerateFrame',function(f) M.Hooks();Mask(f) end);hooked.generate=ContainerFrame_GenerateFrame
 end
end
local native
local function Restore()
 for f,v in pairs(nativeVisuals)do f:SetAlpha(v.alpha);if v.mouse~=nil then f:EnableMouse(v.mouse)end;nativeVisuals[f]=nil end
 for f,v in pairs(modernControls)do
  f:ClearAllPoints();for _,point in ipairs(v.points)do f:SetPoint(unpack(point))end
  f:SetScale(v.scale);f:SetSize(v.width,v.height);f:SetFrameStrata(v.strata);f:SetFrameLevel(v.level)
  modernControls[f]=nil
 end
 for f,s in pairs(states) do
  f:SetParent(s.parent);f:SetScale(s.scale);f:SetFrameStrata(s.strata);f:SetFrameLevel(s.level);f:SetSize(s.width,s.height);f:SetShown(s.shown)
  f:ClearAllPoints();for _,p in ipairs(s.points) do f:SetPoint(unpack(p)) end
 end
 states={};RestoreMasks()
 if native then BankFrame:SetAlpha(native.alpha);BankFrame:EnableMouse(native.mouse);native=nil end
end
function M.Close(closeService)
 if closing then return end
 if sortContext and K.ClassicBags.IsSorting(sortContext) then K.ClassicBags.StopSort() end
 active=false;closing=true
 if panel then panel:Hide() end
 if StackSplitFrame and StackSplitFrame.owner and StackSplitFrame.owner.kaClassicBankItem then StackSplitFrame:Hide() end
 Restore();closing=false
 if closeService then
  local close=C_Bank and C_Bank.CloseBankFrame or CloseBankFrame
  if close then close()end
 end
end
local function NativeReady()
 return BankFrame and K.ForeverInventoryAdapter.ContainerButtonReady()and K.ClassicBags and K.ClassicBags.PaintInventoryButton
end
local function Ensure()
 if panel then return true end
 if not NativeReady() then return false end
 panel=CreateFrame('Frame','KerimAnkaUIClassicLiveBank',UIParent,'BackdropTemplate');panel:Hide();panel.kaClassicInventory=true;panel.kaInventoryTextScope='bank'
 panel:SetSize(Width(),460);panel:SetFrameStrata('DIALOG');panel:SetMovable(true);panel:SetClampedToScreen(true);panel:EnableMouse(true);panel:EnableMouseWheel(true);panel:RegisterForDrag('LeftButton')
 panel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=2});panel:SetBackdropColor(.045,.05,.04,.97);panel:SetBackdropBorderColor(.63,.49,.25,1)
 panel:SetScript('OnDragStart',function(self) if not InCombatLockdown() then self:StartMoving() end end)
 panel:SetScript('OnDragStop',function(self) self:StopMovingOrSizing() end)
 panel:SetScript('OnHide',function() if not closing then M.Close(true) end end)
 panel:SetScript('OnMouseWheel',function(_,delta) offset=offset-delta;M.Refresh() end)
 local title=panel:CreateFontString(nil,'OVERLAY','GameFontNormal');K.InventoryFont(title);title:SetPoint('TOPLEFT',14,-13);K.InventoryLabel(title,'KerimAnka UI - Bank');title:SetWidth(Width()-110)
 panel.kaTitle=title
 for _,delta in ipairs({-1,1}) do
  local change=delta
  local b=K.ClassicBagDesigns.NewButton(change<0 and 'KerimAnkaUIClassicBankSmaller' or 'KerimAnkaUIClassicBankLarger',panel,change<0 and'minus'or'plus')
  b:SetSize(24,22);b:SetPoint('TOPRIGHT',change<0 and -88 or -61,-8);b:SetText(change<0 and '-' or '+')
  b:SetScript('OnClick',function()
   if InCombatLockdown() or not Config() then return end
   K.InventoryPresentation.ChangeText('bank',change)
  end)
  b.kaTextDelta=change;panel.kaFontButtons=panel.kaFontButtons or{};table.insert(panel.kaFontButtons,b)
  K.InventoryPresentation.TextButton(b,'bank',change)
 end
 local close=K.ClassicBagDesigns.NewButton(nil,panel,'close');panel.kaClose=close;close:SetText('X');close:SetSize(24,22);close:SetPoint('TOPRIGHT',1,1);close:SetScript('OnClick',function() M.Close(true) end)
 holder=CreateFrame('Frame',nil,panel);holder:SetID(-1);holder:SetAllPoints(panel)
 footer=panel:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');K.InventoryFont(footer);footer:SetPoint('BOTTOMLEFT',14,12)
 cost=panel:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');K.InventoryFont(cost);cost:SetPoint('BOTTOMLEFT',14,43)
 search=CreateFrame('EditBox','KerimAnkaUIClassicBankSearch',panel,'InputBoxTemplate');search:SetPoint('TOPLEFT',20,-83);search:SetSize(272,22);search:SetAutoFocus(false);K.InventoryFont(search)
 search:SetScript('OnTextChanged',function() offset=0;M.Refresh() end);search:SetScript('OnEscapePressed',function(self) self:SetText('');self:ClearFocus() end);search:SetScript('OnEnterPressed',function(self) self:ClearFocus() end)
 local clear=K.ClassicBagDesigns.NewButton('KerimAnkaUIClassicBankSearchClear',panel,'clear');panel.kaClear=clear;clear:SetSize(22,22);clear:SetPoint('TOPRIGHT',-14,-83);clear:SetText('X')
 clear:SetScript('OnClick',function() search:SetText('');search:ClearFocus() end)
 sortButton=K.ClassicBagDesigns.NewButton('KerimAnkaUIClassicBankSort',panel,'sort');sortButton:SetSize(68,22);sortButton:SetPoint('TOPRIGHT',-42,-83);K.InventoryLabel(sortButton,'Sort');K.InventoryFont(sortButton)
 sortContext={ids=K.ForeverInventoryAdapter.BankIDs(),Valid=function() return active and panel:IsShown() and BankFrame and BankFrame:IsShown() and Enabled() end,
  Refresh=function() M.Refresh() end,Label=function(running) sortButton:SetText(running and T('Stop') or T('Sort')) end}

 sortButton:SetScript('OnClick',function() K.ClassicBags.Sort(sortContext) end)
 sortButton:SetScript('OnEnter',function(self) GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText(T('Sort bank'));GameTooltip:AddLine(T('Combine stacks and sort the bank and its bags. Outside combat only. Click again to stop.'),.9,.9,.86,true);K.InventoryTooltip(GameTooltip);GameTooltip:Show() end)
 sortButton:SetScript('OnLeave',function() GameTooltip:Hide() end)
 moneyText=panel:CreateFontString('KerimAnkaUIClassicBankMoney','OVERLAY','GameFontHighlightSmall');K.InventoryFont(moneyText);moneyText:SetPoint('BOTTOMRIGHT',-25,12)
 UISpecialFrames=UISpecialFrames or {};table.insert(UISpecialFrames,'KerimAnkaUIClassicLiveBank')
 return true
end
-- Never modify or hook the shared purchase popup: its OnAccept must remain native.
local function PlaceControl(f,x,y,size)
 if not f then return end
 local masked=nativeVisuals[f];if masked then f:SetAlpha(masked.alpha);if masked.mouse~=nil then f:EnableMouse(masked.mouse)end;nativeVisuals[f]=nil end
 if not modernControls[f]then
  local v={points={},scale=f:GetScale(),width=f:GetWidth(),height=f:GetHeight(),strata=f:GetFrameStrata(),level=f:GetFrameLevel()}
  for i=1,f:GetNumPoints()do v.points[i]={f:GetPoint(i)}end;modernControls[f]=v
 end
 f:SetScale(1);f:SetFrameStrata('DIALOG');f:SetFrameLevel(panel:GetFrameLevel()+6)
 f:ClearAllPoints();f:SetPoint('TOPLEFT',panel,'TOPLEFT',x,y);if size then f:SetSize(size,size)end
end
local function MaskVisual(object,mouse)
 if not nativeVisuals[object]then local v={alpha=object:GetAlpha()};if mouse then v.mouse=object:IsMouseEnabled()end;nativeVisuals[object]=v end
 object:SetAlpha(0);if mouse then object:EnableMouse(false)end
end
-- Keep the bank root/BankPanel at their original alpha. Hiding that ancestor
-- also hides native purchase and bag-slot descendants on the real client.
local function MaskNativeTree(root,keep,ancestors)
 if keep[root]then return end
 if not ancestors[root]then MaskVisual(root,true)end
 if root.GetRegions then for _,region in ipairs({root:GetRegions()})do MaskVisual(region)end end
 if root.GetChildren then for _,child in ipairs({root:GetChildren()})do MaskNativeTree(child,keep,ancestors)end end
end
local function KeepAncestors(frame,ancestors)
 for i=1,12 do
  if not frame or frame==UIParent then break end
  ancestors[frame]=true;frame=frame:GetParent()
 end
end
local function Money(value)
 if GetCoinTextureString then return GetCoinTextureString(value)end
 value=tonumber(value)or 0
 return string.format('%dg %ds %dc',math.floor(value/10000),math.floor(value/100)%100,value%100)
end
local function TakeControls()
 if not native then native={alpha=BankFrame:GetAlpha(),mouse=BankFrame:IsMouseEnabled()} end
 BankFrame:EnableMouse(false)
 local modern=BankFrame.BankPanel and C_Bank and C_Bank.FetchNextPurchasableBankTabData
 if modern then
  local keep={};local ancestors={[BankFrame]=true,[BankFrame.BankPanel]=true}
  -- The native control tree may clip to its original bank bounds. Keep parents
  -- intact, but align both native containers with our visible bank rectangle.
  PlaceControl(BankFrame,0,0);BankFrame:SetSize(panel:GetWidth(),panel:GetHeight());BankFrame:SetScale(panel:GetScale())
  PlaceControl(BankFrame.BankPanel,0,0);BankFrame.BankPanel:SetSize(panel:GetWidth(),panel:GetHeight())
  local pool=BankFrame.itemButtonBagPool
  if pool and pool.EnumerateActive then
   local buttons={};for button in pool:EnumerateActive()do buttons[#buttons+1]=button end
   table.sort(buttons,function(a,b)return(a.bagSlotID or 0)<(b.bagSlotID or 0)end)
   local size=math.min(30,(Width()-28)/math.max(1,#buttons)-4)
   for i,button in ipairs(buttons)do keep[button]=true;KeepAncestors(button,ancestors);PlaceControl(button,14+(i-1)*(size+4),-40,size)end
  end
  local buy=BankFrame.BankPanel.PurchaseButton
  if buy then
   keep[buy]=true;KeepAncestors(buy,ancestors);PlaceControl(buy,Width()-154,-panel:GetHeight()+58)
  end
  MaskNativeTree(BankFrame,keep,ancestors)
  -- Explicit pools also cover item frames that ignore parent alpha or were
  -- acquired after an earlier tree walk. Keep true bag/slot identity untouched.
  local pool=BankFrame.BankPanel.itemButtonPool
  if pool and pool.EnumerateActive then for item in pool:EnumerateActive()do MaskNativeTree(item,keep,ancestors)end end
 else
  BankFrame:SetAlpha(0)
  for i=1,MaxBags()do
   local b=BankSlotsFrame and BankSlotsFrame['Bag'..i]
   if b then Move(b,panel);b:ClearAllPoints();b:SetPoint('TOPLEFT',14+(i-1)*40,-40);b:SetSize(36,36);b:Show()end
  end
  local buy=BankFramePurchaseButton
  if buy then
   Move(buy,panel);buy:ClearAllPoints();buy:SetPoint('BOTTOMRIGHT',-14,34);buy:SetSize(140,24)

  end
 end
end
function M.Refresh()
 if panel then
  K.ClassicInventoryStyle.Apply(panel,2)
  if K.ClassicBagsOrganized and K.ClassicBagsOrganized.Active()then
   K.ClassicBagDesigns.PaintFrame(panel,2,false,false)
   panel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
   panel:SetBackdropColor(.025,.03,.025,.98);panel:SetBackdropBorderColor(.4,.39,.34,1)
  end
 end
 if not active or not panel or not panel:IsShown() then return end
 if not Enabled() then M.Close(false);return end
 K.InventoryPresentation.Window(panel,'bank',false)
 for _,b in ipairs(panel.kaFontButtons or{})do K.InventoryPresentation.TextButton(b,'bank',b.kaTextDelta)end
 local columns=Columns();local width=Width();local extra=width<360 and 29 or 0
 panel:SetWidth(width);panel.kaTitle:SetWidth(width-110);search:SetWidth(width-146)
 cost:ClearAllPoints();cost:SetPoint('BOTTOMLEFT',14,43+extra);cost:SetWidth(width-(extra>0 and 28 or 180))
 local list={};local total,free=0,0
 local organized=K.ClassicBagsOrganized and K.ClassicBagsOrganized.Active()
 local groups={};local empty={}
 local query=(search:GetText() or ''):lower():match('^%s*(.-)%s*$')
 local ids=K.ForeverInventoryAdapter.BankIDs();sortContext.ids=ids
 for _,bag in ipairs(ids) do
  local count=C_Container.GetContainerNumSlots(bag) or 0
  local parent=holder
  if bag~=-1 then
   parent=bagHolders[bag]
   if not parent then parent=CreateFrame('Frame',nil,panel);parent:SetID(bag);parent:SetAllPoints(panel);bagHolders[bag]=parent end
  end
  items[bag]=items[bag] or {}
  for slot=1,count do
   local b=items[bag][slot]
   if not b then
    if bag==-1 and BankSlotsFrame then b=BankSlotsFrame['Item'..slot];if b then Move(b,parent)end end
    if not b then b=CreateFrame('ItemButton','KAForeverBank'..bag..'Item'..slot,parent,'ContainerFrameItemButtonTemplate');b:SetID(slot)end
    if b then items[bag][slot]=b;b.kaClassicBankItem=true end
   end
   if b then
    if bag==-1 then Move(b,parent) end
    b.kaBankVisible=false;total=total+1
    local info=C_Container.GetContainerItemInfo(bag,slot);if not info then free=free+1 end
    local name=info and (info.hyperlink and info.hyperlink:match('%[(.-)%]') or '') or ''
    if query=='' or info and name:lower():find(query,1,true) then local e={button=b,bag=bag,slot=slot};list[#list+1]=e;if organized then local category=info and K.ClassicBagsOrganized.Category(bag,slot,info)or'empty';groups[category]=groups[category]or{};table.insert(groups[category],e)end end
   end
  end
  for slot=count+1,#items[bag] do items[bag][slot]:Hide() end
 end
 for _,heading in ipairs(headings)do heading:Hide()end
 if organized then
  local grouped={};local headingIndex=0
  local order=K.ClassicBagsOrganized.Order();order[#order+1]='empty'
  for _,id in ipairs(order)do local group=groups[id]
   if group and #group>0 then
    headingIndex=headingIndex+1
    local label=headings[headingIndex]
    if not label then label=panel:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');K.InventoryFont(label);headings[headingIndex]=label end
    grouped[#grouped+1]={heading=label,label=K.ClassicBagsOrganized.CategoryLabel(id)}
    for i=2,columns do grouped[#grouped+1]={spacer=true}end
    for _,entry in ipairs(group)do grouped[#grouped+1]=entry end
    while #grouped%columns~=0 do grouped[#grouped+1]={spacer=true}end
   end
  end
  list=grouped
 end
 local rowCount=math.max(1,math.ceil(#list/columns));offset=math.max(0,math.min(offset,math.max(0,rowCount-8)))
 local shownRows=math.min(8,rowCount)
 panel:SetHeight(210+extra+shownRows*Cell())
 for i=offset*columns+1,math.min(#list,(offset+8)*columns) do
  local e=list[i];local b=e.button;local n=i-offset*columns-1
  if e.heading then
   e.heading:ClearAllPoints();e.heading:SetPoint('TOPLEFT',panel,'TOPLEFT',14,-119-math.floor(n/columns)*Cell());e.heading:SetWidth(width-28);e.heading:SetJustifyH('LEFT');e.heading:SetText(e.label);e.heading:Show()
  elseif b then
  b.kaBankVisible=true
  b:SetSize(37,37);b:SetScale(34/37);b:ClearAllPoints();b:SetPoint('TOPLEFT',panel,'TOPLEFT',(14+(n%columns)*Cell())/(34/37),(-119-math.floor(n/columns)*Cell())/(34/37))
  K.ClassicBags.PaintInventoryButton(b,e.bag,e.slot);b:Show()
  end
 end
 for _,group in pairs(items) do for _,b in pairs(group) do if not b.kaBankVisible then b:Hide() end end end
 footer:SetText(string.format(T('%d / %d slots free'),free,total))
 local money=GetMoney and GetMoney() or 0
 moneyText:SetText(GetCoinTextureString and GetCoinTextureString(money) or string.format('%dg %ds %dc',math.floor(money/10000),math.floor(money/100)%100,money%100))
 local moneyWidth=math.min(width-120,math.max(70,(moneyText.GetStringWidth and moneyText:GetStringWidth() or 80)+12))
 moneyText:SetWidth(moneyWidth);footer:SetWidth(math.max(70,width-moneyWidth-38))
 sortButton:SetAlpha(InCombatLockdown() and .45 or 1)
 local purchased,full=0,true;local nextCost=0
 if GetNumBankSlots and GetBankSlotCost then purchased,full=GetNumBankSlots();nextCost=not full and GetBankSlotCost(purchased)or 0 end
 cost:SetText((not GetNumBankSlots)and ''or full and T('All bank bag slots purchased') or (T('Next bag slot: ')..(GetCoinTextureString and GetCoinTextureString(nextCost) or tostring(nextCost))))
 if C_Bank and C_Bank.FetchNextPurchasableBankTabData and Enum and Enum.BankType then
  local data=C_Bank.FetchNextPurchasableBankTabData(Enum.BankType.Character)
  cost:SetText(data and(T('Next bag slot: ')..Money(data.tabCost))or T('All bank bag slots purchased'))
 elseif BankFramePurchaseButton then BankFramePurchaseButton:SetShown(not full)end
 TakeControls()
 local design=organized and 2 or K.ClassicBagDesigns.ID()
 for _,b in ipairs(panel.kaFontButtons or{})do K.ClassicBagDesigns.PaintButton(b,design)end
 for _,b in ipairs({panel.kaClose,panel.kaClear,sortButton})do K.ClassicBagDesigns.PaintButton(b,design)end
end
function M.Open()
 if management or InCombatLockdown()or not BankFrame or not BankFrame:IsShown()then return false end
 if C_Bank and C_Bank.FetchPurchasedBankTabIDs then
  local ids=K.ForeverInventoryAdapter.BankIDs()
  -- Before the first free tab finishes initializing, leave native ownership intact.
  local slots=0;for _,id in ipairs(ids)do slots=slots+(C_Container.GetContainerNumSlots(id)or 0)end
  if #ids==0 or slots==0 then if active then M.Close(false)end;return false end
 end
 -- Personal-bank presentation only. Account/guild bank pages remain native.
 if BankFrame and BankFrame.GetActiveBankType and Enum and Enum.BankType then
  local kind=BankFrame:GetActiveBankType()
  if kind~=nil and kind~=Enum.BankType.Character then M.Close(false);return false end
 end
 if not Enabled() or not Ensure() then return false end
 -- OnShow and BANKFRAME_OPENED describe the same visit. Only the first one
 -- opens/positions the panel; a late event must not undo a drag or jump it.
 if active then M.Refresh();return true end
 M.Trace('before-bags')
 opening=true
 if not K.ClassicBags.OpenForBank() then opening=false;return false end
 M.Trace('after-bags')
 active=true;offset=0;opening=true;M.Hooks()
 panel:SetWidth(Width());panel:ClearAllPoints();local bags=_G.KerimAnkaUIClassicBagFrame
 if bags and bags:IsShown() and bags.GetLeft and bags:GetLeft()*bags:GetEffectiveScale()>panel:GetWidth()+10 then panel:SetPoint('TOPRIGHT',bags,'TOPLEFT',-8,0)
 else panel:SetPoint('TOPLEFT',UIParent,'TOPLEFT',25,-100) end
 panel:Show();M.Refresh();M.Trace('after-bank-render');opening=false;return true
end
QueueRefresh=function(open)
 openRequested=openRequested or open
 if queued then return end;queued=true
 C_Timer.After(0,function() queued=false;local shouldOpen=openRequested;openRequested=false;if shouldOpen then
  if BankFrame and BankFrame:IsShown() then M.Open() end
 elseif active then M.Refresh() end end)
end
local events=CreateFrame('Frame')
for _,e in ipairs({'QUEST_LOG_UPDATE','BANKFRAME_OPENED','BANKFRAME_CLOSED','BAG_UPDATE_DELAYED','PLAYERBANKSLOTS_CHANGED','PLAYERBANKBAGSLOTS_CHANGED','BANK_TABS_CHANGED','BAG_CONTAINER_UPDATE','PLAYER_MONEY','ITEM_LOCK_CHANGED','BAG_UPDATE_COOLDOWN','ADDON_LOADED'}) do K.ForeverInventoryAdapter.RegisterEvent(events,e) end
events:SetScript('OnEvent',function(_,event)
 if event=='BANKFRAME_OPENED' then QueueRefresh(true)
 elseif event=='BANKFRAME_CLOSED' then management=false;M.Close(false)
 elseif event=='BANK_TABS_CHANGED'or event=='BAG_CONTAINER_UPDATE'or event=='BAG_UPDATE_DELAYED'then
  if BankFrame and BankFrame:IsShown()then QueueRefresh(true)end
 elseif event=='ADDON_LOADED' then M.Hooks()
 elseif active then QueueRefresh(false) end
end)
M.Hooks()


SLASH_KERIMANKABANKDEBUG1='/kabankdebug'
SlashCmdList.KERIMANKABANKDEBUG=function()
 M.Trace('status')
 print('KA Bank test3: active='..tostring(active)..' records='..#evidence..' bankType='..Secure(BankFrame and BankFrame.BankPanel,'bankType')..' bagOwner='..Secure(_G,'FRAME_THAT_OPENED_BAGS'))
 for i,entry in ipairs(evidence)do print('KA Bank '..i..': '..entry.summary);if entry.stack then print(entry.stack)end end
end
