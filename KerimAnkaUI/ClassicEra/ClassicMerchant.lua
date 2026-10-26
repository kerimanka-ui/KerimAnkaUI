-- Original Classic-only merchant convenience; no external addon implementation.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={};K.ClassicMerchant=M
local merchantOpen,running=false,false
local generation=0
local function Config(create)
 if not K.db then return end
 if create then K.db.classicBags=K.db.classicBags or {} end
 return K.db.classicBags
end
function M.Enabled() local c=Config(false);return c and c.autoSellJunk==true or false end
function M.Stop() running=false;generation=generation+1 end
function M.Set(value)
 if type(value)~='boolean' or not K.db or InCombatLockdown() then return false end
 Config(true).autoSellJunk=value
 if not value then M.Stop() elseif merchantOpen then M.Start() end
 return true
end
function M.IsRunning() return running end
local function Valid()
 return merchantOpen and M.Enabled() and MerchantFrame and MerchantFrame:IsShown()
  and (not MerchantFrame.selectedTab or MerchantFrame.selectedTab==1)
  and not InCombatLockdown() and not (UnitIsDead and UnitIsDead('player'))
  and not (CursorHasItem and CursorHasItem())
  and not (K.ClassicBags and K.ClassicBags.IsSorting and K.ClassicBags.IsSorting())
end
local function Sellable(C,bag,slot)
 local info=C.GetContainerItemInfo(bag,slot)
 if not info or info.quality~=0 or info.isLocked or info.hasNoValue then return false end
 local getter=C_Item and C_Item.GetItemInfo or GetItemInfo
 if not getter then return false end
 local _,_,quality,_,_,_,_,_,_,_,price=getter(info.hyperlink or info.itemID)
 -- Both current container quality and cached item metadata must identify junk.
 -- Unknown metadata or a zero vendor price is never treated as permission to sell.
 return quality==0 and type(price)=='number' and price>0
end
function M.Start()
 M.Stop()
 local C=C_Container
 -- MERCHANT_SHOW can precede the native window OnShow handler. Validate
 -- visible merchant state in the deferred step, after all event handlers run.
 if not merchantOpen or not M.Enabled() or not C or not C.GetContainerNumSlots or not C.GetContainerItemInfo or not C.UseContainerItem then return false end
 running=true;local token=generation;local bag,slot=0,0
 local function Step()
  if token~=generation or not running then return end
  if not Valid() then M.Stop();return end
  while bag<=4 do
   local count=math.min(160,math.max(0,tonumber(C.GetContainerNumSlots(bag)) or 0))
   slot=slot+1
   if slot>count then bag=bag+1;slot=0
   elseif Sellable(C,bag,slot) then
    -- Read and validate this live slot immediately before using the native
    -- merchant sale action. No cached sell queue, cursor clearing or deletion.
    local ok,err=pcall(C.UseContainerItem,bag,slot)
    if not ok then M.Stop();if geterrorhandler then geterrorhandler()(err) end;return end
    C_Timer.After(.2,Step);return
   end
  end
  M.Stop()
 end
 C_Timer.After(.2,Step);return true
end
local translations={
 en={merchantAutoJunk='Auto sell grey items',merchantAutoJunkHelp='When a vendor opens, sell only grey-quality items with a vendor value. Off by default. Also starts if enabled while the vendor is open.'},
 tr={merchantAutoJunk='Gri eşyaları otomatik sat',merchantAutoJunkHelp='Satıcı açıldığında yalnızca satış değeri olan gri eşyaları satar. Varsayılan olarak kapalıdır. Satıcı açıkken etkinleştirildiğinde de çalışır.'},
 de={merchantAutoJunk='Graue Gegenstände automatisch verkaufen',merchantAutoJunkHelp='Verkauft beim Händler nur graue Gegenstände mit Verkaufswert. Standardmäßig aus. Startet auch beim Einschalten am geöffneten Händler.'}
}
if K.locales then for locale,values in pairs(translations) do
 K.locales[locale]=K.locales[locale] or {};for key,value in pairs(values) do K.locales[locale][key]=value end
end end
function M.DrawSettings(page,w,y)
 local box=w.Box(page,0,y,714,94)
 w.Text(box,K.L('merchantAutoJunk'),16,-15,570,14)
 w.Text(box,K.L('merchantAutoJunkHelp'),16,-43,565,12,{.65,.70,.62})
 w.Switch(box,M.Enabled(),620,-15,function(value) if M.Set(value) and K.Render then K.Render() end end,not InCombatLockdown())
 return y-110
end
local events=CreateFrame('Frame')
for _,event in ipairs({'MERCHANT_SHOW','MERCHANT_CLOSED','PLAYER_REGEN_DISABLED','PLAYER_LEAVING_WORLD','PLAYER_LOGOUT'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(_,event)
 if event=='MERCHANT_SHOW' then merchantOpen=true;M.Start()
 elseif event=='MERCHANT_CLOSED' or event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_LOGOUT' then merchantOpen=false;M.Stop()
 else M.Stop() end
end)
