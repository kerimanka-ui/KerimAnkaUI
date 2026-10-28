-- Classic-only inventory presentation helpers; no item operations.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={};K.ClassicInventoryStyle=M
local translated={
 ["tr"]={["Search"]="Ara",["Backpack"]="Sırt çantası",["Keyring"]="Anahtarlık",["Sort"]="Sırala",["Stop"]="Durdur",["Recorded items"]="Eşya kayıtları",["Recorded inventory and bank"]="Kayıtlı çanta ve banka",["Read-only snapshots for characters you have visited. Bank records require a bank visit."]="Giriş yaptığın karakterlerin salt okunur kayıtlarıdır. Banka kaydı için bankayı ziyaret etmelisin.",["Sort bags"]="Çantaları sırala",["Combine stacks, group item types, put grey items and empty slots last."]="Yığınları birleştirir, eşya türlerini gruplar; gri eşyaları ve boş yuvaları sona alır.",["All equipped bags. Outside combat only. Click again to stop."]="Takılı tüm çantalar içindir. Yalnızca savaş dışında çalışır. Durdurmak için tekrar tıkla.",[" slots | Click: filter / show all"]=" yuva | Tıkla: filtrele / tümünü göster",["Drag: move bag | Drop a bag here: equip / swap"]="Sürükle: çantayı taşı | Buraya çanta bırak: tak / değiştir",["Drop an item here: put in backpack"]="Buraya eşya bırak: sırt çantasına koy",["%d / %d slots free%s"]="%d / %d boş yuva%s",["%d / %d slots free"]="%d / %d boş yuva",[" | bag "]=" | çanta ",["Total: "]="Toplam: ",["No recorded characters"]="Kayıtlı karakter yok",["No recorded characters."]="Kayıtlı karakter yok.",["Character money"]="Karakter parası",["Total recorded"]="Kayıtlı toplam",["Click: full list | Mouse wheel: scroll after opening"]="Tıkla: tüm liste | Açıldıktan sonra fare tekerleğiyle kaydır",["Character money - last recorded"]="Karakter parası - son kayıt",["Recorded character money"]="Kayıtlı karakter paraları",["Last recorded, all realms. X removes only this money record. Logging into that character again records it anew."]="Tüm sunuculardaki son kayıtlardır. X yalnızca para kaydını kaldırır. Karaktere yeniden girildiğinde tekrar kaydedilir.",["Empty recorded slot"]="Kayıtlı boş yuva",["Saved view only - items cannot be moved or used."]="Yalnızca kayıtlı görünümdür; eşyalar taşınamaz veya kullanılamaz.",["Bag %d / slot %d"]="Çanta %d / yuva %d",["Remove favorite"]="Favorilerden çıkar",["Add favorite"]="Favorilere ekle",["%d-%d / %d  |  Mouse wheel"]="%d-%d / %d  |  Fare tekerleği",["Inventory: "]="Çanta: ",["saved"]="kayıtlı",["not recorded"]="kayıt yok",[" | Bank: "]=" | Banka: ",["KerimAnka UI - Recorded items"]="KerimAnka UI - Eşya kayıtları",["Select character"]="Karakter seç",["Inventory"]="Çanta",["Bank"]="Banka",["Read-only"]="Salt okunur",["Last recorded: "]="Son kayıt: ",["%d / %d slots occupied | Rows %d-%d / %d"]="%d / %d dolu yuva | Satır %d-%d / %d",["Bank not recorded. Visit the bank on this character."]="Banka kaydı yok. Bu karakterle bankayı ziyaret et.",["Inventory not recorded yet. Log in on this character."]="Çanta henüz kaydedilmedi. Bu karaktere giriş yap.",["No snapshot - this does not mean the container is empty."]="Kayıt yok; bu, çantanın veya bankanın boş olduğu anlamına gelmez.",["Read-only snapshots. Inventory updates on login and bag changes; bank updates only while the bank is open."]="Salt okunur kayıtlardır. Çanta girişte ve eşya değişiminde, banka ise yalnızca açıkken güncellenir.",["Open recorded items"]="Eşya kayıtlarını aç",["KerimAnka UI - Bank"]="KerimAnka UI - Banka",["Sort bank"]="Bankayı sırala",["Combine stacks and sort the bank and its bags. Outside combat only. Click again to stop."]="Yığınları birleştirir, bankayı ve banka çantalarını sıralar. Savaş dışında çalışır. Durdurmak için tekrar tıkla.",["All bank bag slots purchased"]="Tüm banka çantası yuvaları satın alındı",["Next bag slot: "]="Sonraki çanta yuvası: ",["Item information is loading. Press Sort again shortly."]="Eşya bilgileri yükleniyor. Biraz sonra Sırala düğmesine tekrar bas.",["Sorting stopped: place the item on your cursor into a free slot."]="Sıralama durdu: imlecindeki eşyayı boş bir yuvaya bırak.",["Finish moving the item on your cursor first."]="Önce imlecindeki eşyayı yerleştir.",["Items are still locked. Try again shortly."]="Eşyalar hâlâ kilitli. Biraz sonra tekrar dene.",["Sorting paused. Press Sort again to continue."]="Sıralama duraklatıldı. Devam etmek için Sırala düğmesine bas.",["An item could not be moved. Check bag space or item restrictions and try again."]="Bir eşya taşınamadı. Boş yuvaları ve eşya kısıtlamalarını kontrol edip tekrar dene.",["Sort outside combat."]="Savaş dışında sırala.",["Native item sorting APIs are unavailable."]="Oyunun eşya sıralama işlevleri kullanılamıyor.",["Native Classic bag-button APIs are unavailable. Original bags remain available."]="Classic çanta işlevleri kullanılamıyor. Oyunun çantaları kullanılabilir.",["Another bag addon is active: "]="Başka bir çanta eklentisi açık: ",["Enable combined bags in the inventory settings first."]="Önce Çanta ve Menü ayarlarından birleşik çantayı aç.",["Combined bags off. Native bags restored."]="Birleşik çanta kapatıldı. Oyunun çantaları geri açıldı.",["Change bag mode outside combat."]="Çanta modunu savaş dışında değiştir."},
 ["de"]={["Search"]="Suchen",["Sort"]="Sortieren",["Stop"]="Stopp",["Recorded items"]="Gegenstandsaufzeichnungen",["Inventory"]="Inventar",["Bank"]="Bank",["Read-only"]="Nur lesen",["%d / %d slots free%s"]="%d / %d freie Plätze%s",["%d / %d slots free"]="%d / %d freie Plätze"},
 ["frFR"]={["Search"]="Rechercher",["Sort"]="Trier",["Stop"]="Arrêter",["Recorded items"]="Objets enregistrés",["Inventory"]="Inventaire",["Bank"]="Banque",["Read-only"]="Lecture seule",["%d / %d slots free%s"]="%d / %d emplacements libres%s",["%d / %d slots free"]="%d / %d emplacements libres"},
 ["itIT"]={["Search"]="Cerca",["Sort"]="Ordina",["Stop"]="Ferma",["Recorded items"]="Oggetti registrati",["Inventory"]="Inventario",["Bank"]="Banca",["Read-only"]="Sola lettura",["%d / %d slots free%s"]="%d / %d spazi liberi%s",["%d / %d slots free"]="%d / %d spazi liberi"},
 ["esES"]={["Search"]="Buscar",["Sort"]="Ordenar",["Stop"]="Detener",["Recorded items"]="Objetos guardados",["Inventory"]="Inventario",["Bank"]="Banco",["Read-only"]="Solo lectura",["%d / %d slots free%s"]="%d / %d espacios libres%s",["%d / %d slots free"]="%d / %d espacios libres"},
 ["ptBR"]={["Search"]="Buscar",["Sort"]="Organizar",["Stop"]="Parar",["Recorded items"]="Itens registrados",["Inventory"]="Inventário",["Bank"]="Banco",["Read-only"]="Somente leitura",["%d / %d slots free%s"]="%d / %d espaços livres%s",["%d / %d slots free"]="%d / %d espaços livres"},
 ["ruRU"]={["Search"]="Поиск",["Sort"]="Сортировать",["Stop"]="Стоп",["Recorded items"]="Записанные предметы",["Inventory"]="Сумки",["Bank"]="Банк",["Read-only"]="Только чтение",["%d / %d slots free%s"]="%d / %d свободных ячеек%s",["%d / %d slots free"]="%d / %d свободных ячеек"},
 ["zhCN"]={["Search"]="搜索",["Sort"]="整理",["Stop"]="停止",["Recorded items"]="物品记录",["Inventory"]="背包",["Bank"]="银行",["Read-only"]="只读",["%d / %d slots free%s"]="%d / %d 空格%s",["%d / %d slots free"]="%d / %d 空格"},
}
K.locales.en["imQuestItems"]="Highlight quest items"
K.locales.en["imQuestItemsHelp"]="Marks quest items with a yellow border; other quality colors are kept."
K.locales.tr["imQuestItems"]="Görev eşyalarını vurgula"
K.locales.tr["imQuestItemsHelp"]="Görev eşyalarını sarı çerçeveyle belirtir; diğer eşyaların kalite renkleri korunur."
K.locales.de["imQuestItems"]="Questgegenstände hervorheben"
K.locales.de["imQuestItemsHelp"]="Markiert Questgegenstände gelb; andere Qualitätsfarben bleiben erhalten."
K.locales.frFR["imQuestItems"]="Souligner les objets de quête"
K.locales.frFR["imQuestItemsHelp"]="Bordure jaune pour les objets de quête ; autres couleurs de qualité conservées."
K.locales.itIT["imQuestItems"]="Evidenzia oggetti missione"
K.locales.itIT["imQuestItemsHelp"]="Bordo giallo per gli oggetti missione; altri colori di qualità conservati."
K.locales.esES["imQuestItems"]="Resaltar objetos de misión"
K.locales.esES["imQuestItemsHelp"]="Borde amarillo para objetos de misión; otros colores de calidad conservados."
K.locales.ptBR["imQuestItems"]="Destacar itens de missão"
K.locales.ptBR["imQuestItemsHelp"]="Borda amarela nos itens de missão; outras cores de qualidade preservadas."
K.locales.ruRU["imQuestItems"]="Выделять предметы заданий"
K.locales.ruRU["imQuestItemsHelp"]="Жёлтая рамка для предметов заданий; остальные сохраняют цвет качества."
K.locales.zhCN["imQuestItems"]="突出显示任务物品"
K.locales.zhCN["imQuestItemsHelp"]="任务物品使用黄色边框，其他物品保留品质颜色。"
function K.InventoryText(source)
 local lang=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or 'en'
 return translated[lang]and translated[lang][source]or source
end
local labels=setmetatable({},{__mode='k'})
local panels=setmetatable({},{__mode='k'})
local Get
-- Button templates switch font objects on hover/disable. Give all states
-- multilingual fonts, retaining each state's original color and alpha.
local buttonFonts=setmetatable({},{__mode='k'})
local stateFonts={};local stateSerial=0
local fontSizes=setmetatable({},{__mode='k'})
local function TextSize(text,size)
 return size or(text.GetFont and select(2,text:GetFont()))or 12
end
local function Font(region,size)
 if not region then return end
 local text=region.GetFontString and region:GetFontString()or region
 if not text or not text.SetFontObject or not K.ApplyTextFont then return end
 size=size or fontSizes[region]or TextSize(text);fontSizes[region]=size
 if region.GetNormalFontObject and region.SetNormalFontObject then
  local states=buttonFonts[region]
  if not states then
   states={};buttonFonts[region]=states
   for _,name in ipairs({'Normal','Highlight','Disabled'})do
    local get=region['Get'..name..'FontObject'];local original=get and get(region)
    local r,g,b,a=1,1,1,1
    if original and original.GetTextColor then r,g,b,a=original:GetTextColor()end
    states[name]=name=='Disabled'and {r or .5,g or .5,b or .5,a or 1}or {1,1,1,1}
   end
  end
  for name,color in pairs(states)do
   local key=size..':'..table.concat(color,':')
   local object=stateFonts[key]
   if not object then
    stateSerial=stateSerial+1;object=CreateFont('KAClassicInventoryStateFont'..stateSerial)
    K.ApplyTextFont(object,size,false,'');object:SetTextColor(unpack(color));stateFonts[key]=object
   end
   region['Set'..name..'FontObject'](region,object)
  end
  -- Use the button's current state rather than pinning its FontString to normal.
 else
  -- Changing a font object also changes inherited color. Keep each label's color.
  local r,g,b,a=text:GetTextColor()
  K.ApplyTextFont(text,size,false,'');text:SetTextColor(r,g,b,a)
 end
end
K.InventoryFont=Font
-- These tooltip regions are shared with Blizzard/other addons. Restore and
-- unregister our temporary font overrides when the tooltip closes or is reused.
local tooltips=setmetatable({},{__mode='k'})
local function RestoreTooltip(tip)
 local state=tooltips[tip];if not state then return end
 for line,object in pairs(state.lines)do
  if K.ReleaseTextFont then K.ReleaseTextFont(line)end
  line:SetFontObject(object)
 end
 state.lines={}
end
function K.InventoryTooltip(tip)
 if not tip or not tip.GetName or not tip.NumLines then return end
 local state=tooltips[tip]
 if not state then state={lines={}};tooltips[tip]=state;tip:HookScript('OnHide',RestoreTooltip)end
 RestoreTooltip(tip)
 local prefix=tip:GetName();if not prefix then return end
 for i=1,tip:NumLines()do for _,side in ipairs({'Left','Right'})do
  local line=_G[prefix..'Text'..side..i]
  if line and line.GetFontObject then
   local object=line:GetFontObject();local text=line:GetText()or''
   if object and text~=''then
    state.lines[line]=object
    local r,g,b,a=line:GetTextColor();local size=TextSize(line)
    -- Preserve the client's font fallback for CJK/other three-byte scripts,
    -- even when they appear in a character or item name under another UI language.
    local native=text:find('[\224-\244]')and true or nil
    K.ApplyTextFont(line,size,false,'',native);line:SetTextColor(r,g,b,a)
   end
  end
 end end
end
function M.ItemGap()
 local v=tonumber(Get('bagItemGap',4))or 4
 if v~=v then return 4 end
 return math.max(0,math.min(16,math.floor(v)))
end
function M.EmptySlot(button,hasItem)
 local texture=button.kaEmptySlot
 local show=not hasItem and Get('bagEmptySlots',false)==true
 if show and not texture then
  texture=button:CreateTexture(nil,'BACKGROUND',nil,1);button.kaEmptySlot=texture
  texture:SetPoint('TOPLEFT',2,-2);texture:SetPoint('BOTTOMRIGHT',-2,2)
  texture:SetTexture('Interface\\PaperDoll\\UI-Backpack-EmptySlot')
 end
 if texture then texture:SetShown(show)end
end

function K.InventoryLabel(region,source)
 labels[region]=source;region:SetText(K.InventoryText(source));Font(region)
end
Get=function(key,default)
 local value=K.InventoryMenus and K.InventoryMenus.Get(key)
 if value==nil then return default end;return value
end
function M.Apply(panel,edge)
 if not panel then return end;local state=panels[panel]or{};panels[panel]=state;state.edge=edge or 1
 local design=K.ClassicBagDesigns and K.ClassicBagDesigns.ID()or 1;local background=Get('bagBackground',true);local border=Get('bagFrame',true)
 local key=design..':'..state.edge..':'..tostring(background)..':'..tostring(border)
 if state.key==key then return end;state.key=key
 panel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=edge or 1})
 if design==2 then panel:SetBackdropColor(.025,.03,.035,background and .98 or 0);panel:SetBackdropBorderColor(.3,.33,.36,border and 1 or 0)
 elseif design==3 then panel:SetBackdropColor(.05,.035,.025,background and .98 or 0);panel:SetBackdropBorderColor(.4,.28,.13,border and 1 or 0)
 else panel:SetBackdropColor(.035,.035,.03,background and .98 or 0);panel:SetBackdropBorderColor(.58,.43,.2,border and 1 or 0)end
 if K.ClassicBagDesigns then K.ClassicBagDesigns.PaintFrame(panel,design,background,border)end
end
function M.IsQuestItem(bag,slot,info)
 if not info then return false end
 local api=C_Container and C_Container.GetContainerItemQuestInfo or GetContainerItemQuestInfo
 if type(api)=='function'then
  local ok,quest,id=pcall(api,bag,slot)
  if ok and type(quest)=='table'then return quest.isQuestItem==true or (type(quest.questID)=='number'and quest.questID>0)or(type(quest.questId)=='number'and quest.questId>0) end
  if ok and (quest~=nil or id~=nil)then return quest==true or(type(id)=='number'and id>0)end
 end
 local getter=C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
 if getter and info.itemID then local ok,_,_,_,_,_,classID=pcall(getter,info.itemID);if ok then return classID==12 end end
 return false
end
function M.Refresh()
 for region,source in pairs(labels)do region:SetText(K.InventoryText(source));Font(region)end
 for panel,state in pairs(panels)do M.Apply(panel,state.edge)end
 if K.ClassicBags then K.ClassicBags.Refresh();K.ClassicBags.RefreshMoneyList()end
 if K.ClassicBank then K.ClassicBank.Refresh()end
 if K.ClassicItemRecords then K.ClassicItemRecords.Refresh()end
end
local setLanguage=K.SetLanguage
function K.SetLanguage(code)
 local ok=setLanguage(code);if ok~=false then M.Refresh()end;return ok
end
local set=K.InventoryMenus.Set
function K.InventoryMenus.Set(key,value)
 if key=='bagDesign'and(type(value)~='number'or value~=value or value<1 or value>3 or value%1~=0)then return false end
 local ok=set(key,value);if ok and(type(key)=='string'and key:find('^bag')or key=='hideNativeBagBar')then M.Refresh()end;return ok
end

K.locales.en["imEmptySlots"]="Blizzard-style empty slots"
K.locales.en["imEmptySlotsHelp"]="Show a Blizzard background texture in empty item slots."
K.locales.en["imItemGap"]="Item spacing"
K.locales.en["imBagShortcutGap"]="Bag shortcut spacing"
K.locales.tr["imEmptySlots"]="Boş yuvalarda Blizzard görünümü"
K.locales.tr["imEmptySlotsHelp"]="Boş eşya yuvalarında Blizzard arka plan dokusunu gösterir."
K.locales.tr["imItemGap"]="Eşyalar arası boşluk"
K.locales.tr["imBagShortcutGap"]="Çanta kısayolları arası boşluk"
K.locales.de["imEmptySlots"]="Leere Plätze im Blizzard-Stil"
K.locales.de["imEmptySlotsHelp"]="Blizzard-Hintergrund in leeren Gegenstandsplätzen anzeigen."
K.locales.de["imItemGap"]="Gegenstandsabstand"
K.locales.de["imBagShortcutGap"]="Abstand der Taschensymbole"
K.locales.frFR["imEmptySlots"]="Emplacements vides style Blizzard"
K.locales.frFR["imEmptySlotsHelp"]="Afficher un fond Blizzard dans les emplacements vides."
K.locales.frFR["imItemGap"]="Espacement des objets"
K.locales.frFR["imBagShortcutGap"]="Espacement des raccourcis de sacs"
K.locales.itIT["imEmptySlots"]="Spazi vuoti stile Blizzard"
K.locales.itIT["imEmptySlotsHelp"]="Mostra lo sfondo Blizzard negli spazi oggetto vuoti."
K.locales.itIT["imItemGap"]="Spaziatura oggetti"
K.locales.itIT["imBagShortcutGap"]="Spaziatura icone borse"
K.locales.esES["imEmptySlots"]="Casillas vacías estilo Blizzard"
K.locales.esES["imEmptySlotsHelp"]="Mostrar un fondo Blizzard en las casillas vacías."
K.locales.esES["imItemGap"]="Separación de objetos"
K.locales.esES["imBagShortcutGap"]="Separación de iconos de bolsas"
K.locales.ptBR["imEmptySlots"]="Espaços vazios estilo Blizzard"
K.locales.ptBR["imEmptySlotsHelp"]="Mostrar um fundo Blizzard nos espaços vazios."
K.locales.ptBR["imItemGap"]="Espaçamento dos itens"
K.locales.ptBR["imBagShortcutGap"]="Espaçamento dos atalhos de bolsas"
K.locales.ruRU["imEmptySlots"]="Пустые ячейки в стиле Blizzard"
K.locales.ruRU["imEmptySlotsHelp"]="Показывать фон Blizzard в пустых ячейках предметов."
K.locales.ruRU["imItemGap"]="Интервал между предметами"
K.locales.ruRU["imBagShortcutGap"]="Интервал значков сумок"
K.locales.zhCN["imEmptySlots"]="暴雪风格空格"
K.locales.zhCN["imEmptySlotsHelp"]="在空物品格中显示暴雪背景纹理。"
K.locales.zhCN["imItemGap"]="物品间距"
K.locales.zhCN["imBagShortcutGap"]="背包快捷图标间距"

function M.BagShortcutGap()
 local v=tonumber(Get('bagGap',3))or 3
 if v~=v then return 3 end
 return math.max(0,math.min(16,v))
end
K.locales.en["imBagShortcutGapHelp"]="Spaces the bag icons at the top of our bag window. Use Blizzard Edit Mode for the standard bag bar."
K.locales.tr["imBagShortcutGapHelp"]="Çanta penceremizin üstündeki çanta ikonlarının arasını ayarlar. Standart çanta çubuğu için Blizzard edit modunu kullan."
K.locales.de["imBagShortcutGapHelp"]="Abstand der Taschensymbole oben in unserem Taschenfenster. Die Standardleiste wird im Blizzard-Bearbeitungsmodus eingestellt."
K.locales.frFR["imBagShortcutGapHelp"]="Espace les icônes en haut de notre fenêtre de sacs. Réglez la barre standard dans le mode Édition Blizzard."
K.locales.itIT["imBagShortcutGapHelp"]="Regola lo spazio tra le icone in alto nella nostra finestra borse. Per la barra standard usa la modalità modifica Blizzard."
K.locales.esES["imBagShortcutGapHelp"]="Ajusta las separaciones de los iconos superiores de nuestra ventana de bolsas. Usa el modo de edición Blizzard para la barra estándar."
K.locales.ptBR["imBagShortcutGapHelp"]="Ajusta o espaço entre os ícones no topo da nossa janela de bolsas. Use o modo de edição Blizzard para a barra padrão."
K.locales.ruRU["imBagShortcutGapHelp"]="Интервал между значками сверху нашего окна сумок. Стандартная панель настраивается в режиме редактирования Blizzard."
K.locales.zhCN["imBagShortcutGapHelp"]="调整本插件背包窗口顶部背包图标的间距。标准背包栏请使用暴雪编辑模式调整。"

K.locales.en["imBagDesign"]="Bag design"
K.locales.en["imBagDesign1"]="Classic"
K.locales.en["imBagDesign2"]="Compact"
K.locales.en["imBagDesign3"]="Leather & Metal"
K.locales.en["imBagDesignHelp1"]="Bag icons at the top."
K.locales.en["imBagDesignHelp2"]="Bag icons on the left."
K.locales.en["imBagDesignHelp3"]="Bag icons at the bottom."
K.locales.en["imBagShortcutGapHelp"]="Spaces the bag icons in the selected design. Blizzard Edit Mode controls the standard bag bar."
K.locales.tr["imBagDesign"]="Çanta tasarımı"
K.locales.tr["imBagDesign1"]="Klasik"
K.locales.tr["imBagDesign2"]="Kompakt"
K.locales.tr["imBagDesign3"]="Deri ve Metal"
K.locales.tr["imBagDesignHelp1"]="Çanta ikonları üstte."
K.locales.tr["imBagDesignHelp2"]="Çanta ikonları solda."
K.locales.tr["imBagDesignHelp3"]="Çanta ikonları altta."
K.locales.tr["imBagShortcutGapHelp"]="Seçilen tasarımdaki çanta ikonlarının arasını ayarlar. Standart çanta çubuğunu Blizzard edit modu yönetir."
K.locales.de["imBagDesign"]="Taschendesign"
K.locales.de["imBagDesign1"]="Klassisch"
K.locales.de["imBagDesign2"]="Kompakt"
K.locales.de["imBagDesign3"]="Leder & Metall"
K.locales.de["imBagDesignHelp1"]="Taschensymbole oben."
K.locales.de["imBagDesignHelp2"]="Taschensymbole links."
K.locales.de["imBagDesignHelp3"]="Taschensymbole unten."
K.locales.de["imBagShortcutGapHelp"]="Abstand der Taschensymbole im gewählten Design. Die Standardleiste steuert der Blizzard-Bearbeitungsmodus."
K.locales.frFR["imBagDesign"]="Style des sacs"
K.locales.frFR["imBagDesign1"]="Classique"
K.locales.frFR["imBagDesign2"]="Compact"
K.locales.frFR["imBagDesign3"]="Cuir et métal"
K.locales.frFR["imBagDesignHelp1"]="Icônes des sacs en haut."
K.locales.frFR["imBagDesignHelp2"]="Icônes des sacs à gauche."
K.locales.frFR["imBagDesignHelp3"]="Icônes des sacs en bas."
K.locales.frFR["imBagShortcutGapHelp"]="Espace les icônes du style choisi. Le mode Édition Blizzard règle la barre standard."
K.locales.itIT["imBagDesign"]="Stile borse"
K.locales.itIT["imBagDesign1"]="Classico"
K.locales.itIT["imBagDesign2"]="Compatto"
K.locales.itIT["imBagDesign3"]="Pelle e metallo"
K.locales.itIT["imBagDesignHelp1"]="Icone borse in alto."
K.locales.itIT["imBagDesignHelp2"]="Icone borse a sinistra."
K.locales.itIT["imBagDesignHelp3"]="Icone borse in basso."
K.locales.itIT["imBagShortcutGapHelp"]="Regola lo spazio tra le icone dello stile scelto. La barra standard usa la modalità modifica Blizzard."
K.locales.esES["imBagDesign"]="Diseño de bolsas"
K.locales.esES["imBagDesign1"]="Clásico"
K.locales.esES["imBagDesign2"]="Compacto"
K.locales.esES["imBagDesign3"]="Cuero y metal"
K.locales.esES["imBagDesignHelp1"]="Iconos de bolsas arriba."
K.locales.esES["imBagDesignHelp2"]="Iconos de bolsas a la izquierda."
K.locales.esES["imBagDesignHelp3"]="Iconos de bolsas abajo."
K.locales.esES["imBagShortcutGapHelp"]="Ajusta los iconos del diseño elegido. El modo de edición Blizzard controla la barra estándar."
K.locales.ptBR["imBagDesign"]="Estilo das bolsas"
K.locales.ptBR["imBagDesign1"]="Clássico"
K.locales.ptBR["imBagDesign2"]="Compacto"
K.locales.ptBR["imBagDesign3"]="Couro e metal"
K.locales.ptBR["imBagDesignHelp1"]="Ícones das bolsas acima."
K.locales.ptBR["imBagDesignHelp2"]="Ícones das bolsas à esquerda."
K.locales.ptBR["imBagDesignHelp3"]="Ícones das bolsas abaixo."
K.locales.ptBR["imBagShortcutGapHelp"]="Ajusta os ícones do estilo selecionado. O modo de edição Blizzard controla a barra padrão."
K.locales.ruRU["imBagDesign"]="Дизайн сумок"
K.locales.ruRU["imBagDesign1"]="Классический"
K.locales.ruRU["imBagDesign2"]="Компактный"
K.locales.ruRU["imBagDesign3"]="Кожа и металл"
K.locales.ruRU["imBagDesignHelp1"]="Значки сумок сверху."
K.locales.ruRU["imBagDesignHelp2"]="Значки сумок слева."
K.locales.ruRU["imBagDesignHelp3"]="Значки сумок снизу."
K.locales.ruRU["imBagShortcutGapHelp"]="Интервал значков выбранного дизайна. Стандартной панелью управляет режим редактирования Blizzard."
K.locales.zhCN["imBagDesign"]="背包设计"
K.locales.zhCN["imBagDesign1"]="经典"
K.locales.zhCN["imBagDesign2"]="紧凑"
K.locales.zhCN["imBagDesign3"]="皮革与金属"
K.locales.zhCN["imBagDesignHelp1"]="背包图标在顶部。"
K.locales.zhCN["imBagDesignHelp2"]="背包图标在左侧。"
K.locales.zhCN["imBagDesignHelp3"]="背包图标在底部。"
K.locales.zhCN["imBagShortcutGapHelp"]="调整所选设计的背包图标间距。标准背包栏由暴雪编辑模式管理。"
