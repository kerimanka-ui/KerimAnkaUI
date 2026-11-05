-- Forever guild-bank presentation. Native permissions, actions, logs and queries stay native.
local _,K=...
local M={};K.ForeverGuildBank=M
local nativeFrame,skin,preview
local optedIn=false -- Experimental native guild skin; session-only until live guild tests.
local masked={}
local hooked=setmetatable({},{__mode='k'})
local labels={
 en={'Guild bank','Guild bank preview','Example only - no guild items or transactions.','Items','Item log','Money log','Information'},
 tr={'Lonca bankası','Lonca bankası ön izlemesi','Yalnızca örnek - gerçek lonca eşyası veya işlem yok.','Eşyalar','Eşya günlüğü','Para günlüğü','Bilgi'},
 de={'Gildenbank','Gildenbank-Vorschau','Nur ein Beispiel - keine Gildengegenstände oder Transaktionen.','Gegenstände','Gegenstandslog','Geldlog','Informationen'},
 frFR={'Banque de guilde','Aperçu de la banque de guilde','Exemple uniquement - aucun objet ni transaction de guilde.','Objets','Journal des objets','Journal monétaire','Informations'},
 itIT={'Banca di gilda','Anteprima banca di gilda','Solo esempio - nessun oggetto o transazione di gilda.','Oggetti','Registro oggetti','Registro denaro','Informazioni'},
 esES={'Banco de hermandad','Vista previa del banco','Solo ejemplo: sin objetos ni transacciones de hermandad.','Objetos','Registro de objetos','Registro de dinero','Información'},
 ptBR={'Banco da guilda','Prévia do banco da guilda','Somente exemplo: sem itens ou transações da guilda.','Itens','Registro de itens','Registro de dinheiro','Informações'},
 ruRU={'Банк гильдии','Предпросмотр банка гильдии','Только пример: без предметов гильдии и операций.','Предметы','Журнал предметов','Журнал денег','Информация'},
 zhCN={'公会银行','公会银行预览','仅为示例，不含真实公会物品或交易。','物品','物品记录','资金记录','信息'},
}
local function Text(i)local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en';return(labels[lang]or labels.en)[i]end
local function Design()return K.ClassicBagsOrganized and K.ClassicBagsOrganized.Active()and 2 or K.ClassicBagDesigns.ID()end
local function Mask(region)
 if region and region.GetAlpha and region.SetAlpha then if masked[region]==nil then masked[region]=region:GetAlpha()end;region:SetAlpha(0)end
end
function M.Restore()
 for region,alpha in pairs(masked)do region:SetAlpha(alpha);masked[region]=nil end
 if skin then skin:Hide()end
end
local function Caption(parent,text,x,y,size)
 local t=parent:CreateFontString(nil,'OVERLAY','GameFontNormal');K.InventoryFont(t,size or 12);t:SetPoint('TOPLEFT',x,y);t:SetJustifyH('LEFT');t:SetText(text);return t
end
local function Paint(parent)
 local design=Design();K.ClassicBagDesigns.PaintFrame(parent,design,true,true)
 parent:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
 parent:SetBackdropColor(design==3 and .075 or .025,design==3 and .055 or .03,design==3 and .035 or .025,.98)
 parent:SetBackdropBorderColor(.4,.39,.34,1)
end
function M.Refresh()
 local f=nativeFrame
 if not f or not f:IsShown()then return end
 local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 if not optedIn or not K.ClassicBags.Enabled()or loaded and loaded('Bagnon_GuildBank')or InCombatLockdown()then M.Restore();return end
 if not skin then
  skin=CreateFrame('Frame',nil,f,'BackdropTemplate');skin.kaInventoryTextScope='bank';skin:SetAllPoints(f)
  skin:SetFrameLevel(math.max(0,f:GetFrameLevel()-1));skin:EnableMouse(false)
  skin.title=Caption(skin,'',54,-7,14);skin.title:SetWidth(math.max(100,f:GetWidth()-180))
 end
 -- Only frame decoration changes: no native mode, tab, permission or item fields.
 if f.GetRegions then for _,region in ipairs({f:GetRegions()})do if region.IsObjectType and region:IsObjectType('Texture')then Mask(region)end end end
 for _,name in ipairs({'NineSlice','Emblem','TitleText'})do Mask(f[name])end
 for _,column in ipairs(f.Columns or{})do Mask(column.Background)end
 local guild=GetGuildInfo and GetGuildInfo('player');if K.ForeverInventoryAdapter.IsSecret(guild)then guild=nil end
 skin.title:SetText(Text(1)..(guild and(' - '..guild)or''));Paint(skin);skin:Show()
end
function M.Hooks()
 local f=GuildBankFrame
 if not f or type(f.Columns)~='table'or hooked[f]then return end
 nativeFrame=f;hooked[f]=true
 f:HookScript('OnShow',M.Refresh);f:HookScript('OnHide',M.Restore)
 if type(f.Update)=='function'then hooksecurefunc(f,'Update',M.Refresh)end
 if f:IsShown()then M.Refresh()end
end
local function Preview()
 if not preview then
  preview=CreateFrame('Frame','KerimAnkaUIGuildBankPreview',UIParent,'BackdropTemplate');preview:Hide();preview.kaInventoryTextScope='bank'
  preview:SetSize(750,428);preview:SetPoint('CENTER');preview:SetFrameStrata('DIALOG');preview:SetMovable(true);preview:EnableMouse(true);preview:SetClampedToScreen(true);preview:RegisterForDrag('LeftButton')
  preview:SetScript('OnDragStart',function(self)self:StartMoving()end);preview:SetScript('OnDragStop',function(self)self:StopMovingOrSizing()end)
  preview.title=Caption(preview,'',18,-12,14);preview.note=Caption(preview,'',18,-38,11)
  local close=K.ClassicBagDesigns.NewButton(nil,preview,'close');close:SetSize(24,22);close:SetPoint('TOPRIGHT',-5,-5);close:SetText('X');close:SetScript('OnClick',function()preview:Hide()end);preview.close=close
  local examples={'Interface\\Icons\\INV_Potion_54','Interface\\Icons\\INV_Misc_Herb_02','Interface\\Icons\\INV_Misc_LeatherScrap_03','Interface\\Icons\\INV_Ingot_Iron','Interface\\Icons\\INV_Fabric_Silk_01'}
  for slot=1,98 do
   local n=slot-1;local group=math.floor(n/14);local index=n%14
   local cell=CreateFrame('Frame',nil,preview);cell:SetSize(36,36);cell:SetPoint('TOPLEFT',24+group*100+(index>=7 and 43 or 0),-65-(index%7)*43);cell:EnableMouse(false)
   local icon=cell:CreateTexture(nil,'ARTWORK');icon:SetAllPoints(cell);icon:SetTexture(examples[slot]or'Interface\\PaperDoll\\UI-Backpack-EmptySlot')
  end
  preview.tabs={}
  for i=1,4 do local label=Caption(preview,'',18+(i-1)*181,-389,12);label:SetWidth(174);preview.tabs[i]=label end
  UISpecialFrames=UISpecialFrames or{};table.insert(UISpecialFrames,'KerimAnkaUIGuildBankPreview')
 end
 if preview:IsShown()then preview:Hide();return end
 Paint(preview);preview.title:SetText(Text(2));preview.note:SetText(Text(3));K.ClassicBagDesigns.PaintButton(preview.close,Design())
 for i,label in ipairs(preview.tabs)do label:SetText(Text(i+3))end
 preview:Show()
end
local status={
 en={'Guild bank theme enabled for this session.','Guild bank theme disabled.'},
 tr={'Lonca bankası teması bu oturum için açıldı.','Lonca bankası teması kapatıldı.'},
 de={'Gildenbank-Design für diese Sitzung aktiviert.','Gildenbank-Design deaktiviert.'},
 frFR={'Thème de banque de guilde activé pour cette session.','Thème de banque de guilde désactivé.'},
 itIT={'Tema banca di gilda attivato per questa sessione.','Tema banca di gilda disattivato.'},
 esES={'Tema del banco activado para esta sesión.','Tema del banco desactivado.'},
 ptBR={'Tema do banco da guilda ativado nesta sessão.','Tema do banco da guilda desativado.'},
 ruRU={'Тема банка гильдии включена на этот сеанс.','Тема банка гильдии отключена.'},
 zhCN={'公会银行主题已在本次会话启用。','公会银行主题已禁用。'},
}
SLASH_KERIMANKAGUILDSKIN1='/kaguildskin'
SlashCmdList.KERIMANKAGUILDSKIN=function(message)
 local mode=(message or''):lower():match('^%s*(.-)%s*$')
 if mode=='on'then optedIn=true;M.Hooks();M.Refresh()
 elseif mode=='off'then optedIn=false;M.Restore()
 else print('/kaguildskin on | off');return end
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en';print((status[lang]or status.en)[optedIn and 1 or 2])
end
SLASH_KERIMANKAGUILDPREVIEW1='/kaguildpreview'
SlashCmdList.KERIMANKAGUILDPREVIEW=Preview
local events=CreateFrame('Frame')
for _,event in ipairs({'ADDON_LOADED','GUILDBANKFRAME_OPENED','GUILDBANKFRAME_CLOSED'})do K.ForeverInventoryAdapter.RegisterEvent(events,event)end
events:SetScript('OnEvent',function(_,event)
 M.Hooks()
 if event=='GUILDBANKFRAME_CLOSED'then M.Restore()elseif event=='GUILDBANKFRAME_OPENED'then M.Refresh()end
end)
if K.ClassicInventoryStyle and K.ClassicInventoryStyle.Refresh then hooksecurefunc(K.ClassicInventoryStyle,'Refresh',M.Refresh)end
M.Hooks()
