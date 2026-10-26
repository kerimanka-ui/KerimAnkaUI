-- Classic-only live bank presentation using Blizzard's native bank controls.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={};K.ClassicBank=M
local panel,holder,footer,cost,search,sortButton,moneyText
local sortContext
local active,closing,queued=false,false,false
local states={};local masks=setmetatable({},{__mode='k'});local hooked=setmetatable({},{__mode='k'})
local bagHolders,items={},{}
local offset=0
local function Config()
 if not K.db then return end
 K.db.classicBank=K.db.classicBank or {};return K.db.classicBank
end
local function Columns()
 local c=Config();return math.max(6,math.min(14,math.floor(tonumber(c and c.columns) or 10)))
end
local function Width() return math.max(280,Columns()*38+28) end
local function Enabled() return K.ClassicBags and K.ClassicBags.Enabled() end
local function MaxBags() return math.max(0,math.min(7,tonumber(NUM_BANKBAGSLOTS) or 6)) end
local function BankBag(id) return type(id)=='number' and id>=5 and id<=4+MaxBags() end
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
function M.Hooks()
 if BankFrame and not hooked.bankShow then
  BankFrame:HookScript('OnShow',function() M.Open() end);hooked.bankShow=true
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
 for f,s in pairs(states) do
  f:SetParent(s.parent);f:SetScale(s.scale);f:SetFrameStrata(s.strata);f:SetFrameLevel(s.level);f:SetSize(s.width,s.height);f:SetShown(s.shown)
  f:ClearAllPoints();for _,p in ipairs(s.points) do f:SetPoint(unpack(p)) end
 end
 states={};RestoreMasks()
 if native then BankFrame:SetAlpha(native.alpha);BankFrame:EnableMouse(native.mouse);native=nil end
end
function M.Close(closeService)
 if sortContext and K.ClassicBags.IsSorting(sortContext) then K.ClassicBags.StopSort() end
 active=false;closing=true
 if panel then panel:Hide() end
 if StackSplitFrame and StackSplitFrame.owner and StackSplitFrame.owner.kaClassicBankItem then StackSplitFrame:Hide() end
 Restore();closing=false
 if closeService and CloseBankFrame then CloseBankFrame() end
end
local function NativeReady()
 return BankFrame and BankSlotsFrame and BankSlotsFrame.Item1 and C_Container and K.ClassicBags and K.ClassicBags.PaintInventoryButton
end
local function Ensure()
 if panel then return true end
 if not NativeReady() then return false end
 panel=CreateFrame('Frame','KerimAnkaUIClassicLiveBank',UIParent,'BackdropTemplate');panel:Hide();panel.kaClassicInventory=true
 panel:SetSize(Width(),460);panel:SetFrameStrata('DIALOG');panel:SetMovable(true);panel:SetClampedToScreen(true);panel:EnableMouse(true);panel:EnableMouseWheel(true);panel:RegisterForDrag('LeftButton')
 panel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=2});panel:SetBackdropColor(.045,.05,.04,.97);panel:SetBackdropBorderColor(.63,.49,.25,1)
 panel:SetScript('OnDragStart',function(self) if not InCombatLockdown() then self:StartMoving() end end)
 panel:SetScript('OnDragStop',function(self) self:StopMovingOrSizing() end)
 panel:SetScript('OnHide',function() if not closing then M.Close(true) end end)
 panel:SetScript('OnMouseWheel',function(_,delta) offset=offset-delta;M.Refresh() end)
 local title=panel:CreateFontString(nil,'OVERLAY','GameFontNormal');title:SetPoint('TOPLEFT',14,-13);title:SetText('KerimAnka UI - Bank');title:SetWidth(Width()-110)
 panel.kaTitle=title
 for _,delta in ipairs({-1,1}) do
  local change=delta
  local b=CreateFrame('Button',change<0 and 'KerimAnkaUIClassicBankSmaller' or 'KerimAnkaUIClassicBankLarger',panel,'UIPanelButtonTemplate')
  b:SetSize(24,22);b:SetPoint('TOPRIGHT',change<0 and -88 or -61,-8);b:SetText(change<0 and '-' or '+')
  b:SetScript('OnClick',function()
   if InCombatLockdown() or not Config() then return end
   Config().columns=math.max(6,math.min(14,Columns()+change));offset=0;M.Refresh()
  end)
 end
 local close=CreateFrame('Button',nil,panel,'UIPanelCloseButton');close:SetPoint('TOPRIGHT',1,1);close:SetScript('OnClick',function() M.Close(true) end)
 holder=CreateFrame('Frame',nil,panel);holder:SetID(-1);holder:SetAllPoints(panel)
 footer=panel:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');footer:SetPoint('BOTTOMLEFT',14,12)
 cost=panel:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');cost:SetPoint('BOTTOMLEFT',14,43)
 search=CreateFrame('EditBox','KerimAnkaUIClassicBankSearch',panel,'InputBoxTemplate');search:SetPoint('TOPLEFT',20,-83);search:SetSize(272,22);search:SetAutoFocus(false)
 search:SetScript('OnTextChanged',function() offset=0;M.Refresh() end);search:SetScript('OnEscapePressed',function(self) self:SetText('');self:ClearFocus() end);search:SetScript('OnEnterPressed',function(self) self:ClearFocus() end)
 local clear=CreateFrame('Button','KerimAnkaUIClassicBankSearchClear',panel,'UIPanelButtonTemplate');clear:SetSize(22,22);clear:SetPoint('TOPRIGHT',-14,-83);clear:SetText('X')
 clear:SetScript('OnClick',function() search:SetText('');search:ClearFocus() end)
 sortButton=CreateFrame('Button','KerimAnkaUIClassicBankSort',panel,'UIPanelButtonTemplate');sortButton:SetSize(68,22);sortButton:SetPoint('TOPRIGHT',-42,-83);sortButton:SetText('Sort')
 sortContext={ids={-1},Valid=function() return active and panel:IsShown() and BankFrame and BankFrame:IsShown() and Enabled() end,
  Refresh=function() M.Refresh() end,Label=function(running) sortButton:SetText(running and 'Stop' or 'Sort') end}
 for i=1,MaxBags() do sortContext.ids[#sortContext.ids+1]=4+i end
 sortButton:SetScript('OnClick',function() K.ClassicBags.Sort(sortContext) end)
 sortButton:SetScript('OnEnter',function(self) GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText('Sort bank');GameTooltip:AddLine('Combine stacks and sort the bank and its bags. Outside combat only. Click again to stop.',1,.82,0,true);GameTooltip:Show() end)
 sortButton:SetScript('OnLeave',function() GameTooltip:Hide() end)
 moneyText=panel:CreateFontString('KerimAnkaUIClassicBankMoney','OVERLAY','GameFontHighlightSmall');moneyText:SetPoint('BOTTOMRIGHT',-14,12)
 UISpecialFrames=UISpecialFrames or {};table.insert(UISpecialFrames,'KerimAnkaUIClassicLiveBank')
 return true
end
local function PurchaseDialog()
 for i=1,4 do local popup=_G['StaticPopup'..i]
  if popup and popup:IsShown() and popup.which=='CONFIRM_BUY_BANK_SLOT' then K.ClassicBags.PromoteInventoryDialog(popup,panel) end
 end
end
local function TakeControls()
 if not native then native={alpha=BankFrame:GetAlpha(),mouse=BankFrame:IsMouseEnabled()} end
 BankFrame:SetAlpha(0);BankFrame:EnableMouse(false)
 for i=1,MaxBags() do
  local b=BankSlotsFrame['Bag'..i]
  if b then Move(b,panel);b:ClearAllPoints();b:SetPoint('TOPLEFT',14+(i-1)*(math.min(36,(Width()-28)/MaxBags()-4)+4),-40);local size=math.min(36,(Width()-28)/MaxBags()-4);b:SetSize(size,size);b:Show() end
 end
 local buy=BankFramePurchaseButton
 if buy then
  Move(buy,panel);buy:ClearAllPoints();buy:SetPoint('BOTTOMRIGHT',-14,34);buy:SetSize(140,24)
  if not hooked.purchase then buy:HookScript('OnClick',function() if active then PurchaseDialog() end end);hooked.purchase=true end
 end
end
function M.Refresh()
 if not active or not panel or not panel:IsShown() then return end
 if not Enabled() then M.Close(false);return end
 TakeControls()
 local columns=Columns();local width=Width();local extra=width<360 and 29 or 0
 panel:SetWidth(width);panel.kaTitle:SetWidth(width-110);search:SetWidth(width-146)
 cost:ClearAllPoints();cost:SetPoint('BOTTOMLEFT',14,43+extra);cost:SetWidth(width-(extra>0 and 28 or 180))
 local list={};local total,free=0,0
 local query=(search:GetText() or ''):lower():match('^%s*(.-)%s*$')
 local ids={-1};for i=1,MaxBags() do ids[#ids+1]=4+i end
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
    if bag==-1 then b=BankSlotsFrame['Item'..slot];if b then Move(b,parent) end
    else b=CreateFrame('Button','KAClassicBank'..bag..'Item'..slot,parent,'ContainerFrameItemButtonTemplate');b:SetID(slot) end
    if b then items[bag][slot]=b;b.kaClassicBankItem=true end
   end
   if b then
    if bag==-1 then Move(b,parent) end
    b.kaBankVisible=false;total=total+1
    local info=C_Container.GetContainerItemInfo(bag,slot);if not info then free=free+1 end
    local name=info and (info.hyperlink and info.hyperlink:match('%[(.-)%]') or '') or ''
    if query=='' or info and name:lower():find(query,1,true) then list[#list+1]={button=b,bag=bag,slot=slot} end
   end
  end
  for slot=count+1,#items[bag] do items[bag][slot]:Hide() end
 end
 local rowCount=math.max(1,math.ceil(#list/columns));offset=math.max(0,math.min(offset,math.max(0,rowCount-8)))
 local shownRows=math.min(8,rowCount)
 panel:SetHeight(190+extra+shownRows*38)
 for i=offset*columns+1,math.min(#list,(offset+8)*columns) do
  local e=list[i];local b=e.button;local n=i-offset*columns-1;b.kaBankVisible=true
  b:SetSize(37,37);b:SetScale(34/37);b:ClearAllPoints();b:SetPoint('TOPLEFT',panel,'TOPLEFT',(14+(n%columns)*38)/(34/37),(-119-math.floor(n/columns)*38)/(34/37))
  K.ClassicBags.PaintInventoryButton(b,e.bag,e.slot);b:Show()
 end
 for _,group in pairs(items) do for _,b in pairs(group) do if not b.kaBankVisible then b:Hide() end end end
 footer:SetText(string.format('%d / %d slots free',free,total))
 local money=GetMoney and GetMoney() or 0
 moneyText:SetText(GetCoinTextureString and GetCoinTextureString(money) or string.format('%dg %ds %dc',math.floor(money/10000),math.floor(money/100)%100,money%100))
 local moneyWidth=math.min(width-120,math.max(70,(moneyText.GetStringWidth and moneyText:GetStringWidth() or 80)+12))
 moneyText:SetWidth(moneyWidth);footer:SetWidth(math.max(70,width-moneyWidth-38))
 sortButton:SetAlpha(InCombatLockdown() and .45 or 1)
 local purchased,full=GetNumBankSlots();local nextCost=not full and GetBankSlotCost(purchased) or 0
 cost:SetText(full and 'All bank bag slots purchased' or ('Next bag slot: '..(GetCoinTextureString and GetCoinTextureString(nextCost) or tostring(nextCost))))
 if BankFramePurchaseButton then BankFramePurchaseButton:SetShown(not full) end
end
function M.Open()
 if not Enabled() or not Ensure() then return false end
 -- OnShow and BANKFRAME_OPENED describe the same visit. Only the first one
 -- opens/positions the panel; a late event must not undo a drag or jump it.
 if active then M.Refresh();return true end
 if not K.ClassicBags.OpenForBank() then return false end
 active=true;offset=0;M.Hooks();TakeControls()
 panel:SetWidth(Width());panel:ClearAllPoints();local bags=_G.KerimAnkaUIClassicBagFrame
 if bags and bags:IsShown() and bags.GetLeft and bags:GetLeft()*bags:GetEffectiveScale()>panel:GetWidth()+10 then panel:SetPoint('TOPRIGHT',bags,'TOPLEFT',-8,0)
 else panel:SetPoint('TOPLEFT',UIParent,'TOPLEFT',25,-100) end
 panel:Show();M.Refresh();return true
end
local function QueueRefresh(open)
 if queued then return end;queued=true
 C_Timer.After(0,function() queued=false;if open then
  if BankFrame and BankFrame:IsShown() then M.Open() end
 elseif active then M.Refresh() end end)
end
local events=CreateFrame('Frame')
for _,e in ipairs({'BANKFRAME_OPENED','BANKFRAME_CLOSED','BAG_UPDATE_DELAYED','PLAYERBANKSLOTS_CHANGED','PLAYERBANKBAGSLOTS_CHANGED','PLAYER_MONEY','ITEM_LOCK_CHANGED','BAG_UPDATE_COOLDOWN','ADDON_LOADED'}) do events:RegisterEvent(e) end
events:SetScript('OnEvent',function(_,event)
 if event=='BANKFRAME_OPENED' then QueueRefresh(true)
 elseif event=='BANKFRAME_CLOSED' then M.Close(false)
 elseif event=='ADDON_LOADED' then M.Hooks()
 elseif active then QueueRefresh(false) end
end)
M.Hooks()
