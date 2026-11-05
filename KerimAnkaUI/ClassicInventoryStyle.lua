-- Forever adaptation; internal component names preserve existing settings keys.
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
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or 'en'
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
 local key=design..':'..state.edge..':'..tostring(background)..':'..tostring(border)..':'..M.BackgroundStyle()
 -- A material refresh must not repaint retired native chrome over the optional view.
 if panel==_G.KerimAnkaUIClassicBagFrame and K.ClassicBagsOrganized and K.ClassicBagsOrganized.Active()then state.key=nil;return end
 if state.key==key then return end;state.key=key
 panel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=edge or 1})
 if design==2 then panel:SetBackdropColor(.025,.03,.035,background and .98 or 0);panel:SetBackdropBorderColor(.3,.33,.36,border and 1 or 0)
 elseif design==3 then panel:SetBackdropColor(.05,.035,.025,background and .98 or 0);panel:SetBackdropBorderColor(.4,.28,.13,border and 1 or 0)
 else panel:SetBackdropColor(.035,.035,.03,background and .98 or 0);panel:SetBackdropBorderColor(.58,.43,.2,border and 1 or 0)end
 if K.ClassicBagDesigns then K.ClassicBagDesigns.PaintFrame(panel,design,background,border)end
 if panel.kaClassicInventory then M.PaintBackgroundPanel(panel,background)end
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

-- The optional black icon overlay was retired; old profile keys have no effect.
do
 local help={
  en='The bag background and decorative frame can be hidden independently. Quest and item-quality highlights are controlled separately.',
  tr='Çanta arka planı ve dekoratif çerçeve ayrı ayrı kapatılabilir. Görev ve eşya kalitesi vurguları ayrı ayarlanır.',
  de='Taschenhintergrund und dekorativer Rahmen können unabhängig ausgeblendet werden. Quest- und Qualitätsmarkierungen werden separat eingestellt.',
  frFR='Le fond et le cadre décoratif des sacs peuvent être masqués séparément. Les indications de quête et de qualité se règlent séparément.',
  itIT='Sfondo e cornice decorativa delle borse possono essere nascosti separatamente. Gli indicatori di missione e qualità hanno impostazioni separate.',
  esES='El fondo y el marco decorativo de las bolsas se pueden ocultar por separado. Los indicadores de misión y calidad se ajustan aparte.',
  ptBR='O fundo e a moldura decorativa das bolsas podem ser ocultados separadamente. Os destaques de missão e qualidade têm ajustes próprios.',
  ruRU='Фон сумки и декоративную рамку можно скрыть отдельно. Подсветка заданий и качества предметов настраивается отдельно.',
  zhCN='背包背景和装饰边框可分别隐藏。任务和物品品质高亮可单独设置。',
 }
 for language,text in pairs(help)do if K.locales[language]then K.locales[language].imBagAppearanceHelp=text end end
end

-- Optional inventory body material. Mode 1 delegates completely to the existing skin.
local BACKGROUND_ROCK='Interface\\FrameGeneral\\UI-Background-Rock'
function M.BackgroundStyle()
 local d=K.db and K.db.classicBags
 local value=d and tonumber(d.backgroundStyle)
 if value==nil then return 3 end
 if value~=2 and value~=3 then return 1 end
 return value
end
function M.PaintBackgroundTexture(texture,width,height,shown)
 local mode=M.BackgroundStyle();if mode==1 then return false end
 if mode==2 then texture:SetVertexColor(1,1,1,1);texture:SetColorTexture(.16,.17,.16,.98)
 else
  texture:SetTexture(BACKGROUND_ROCK,'REPEAT','REPEAT')
  texture:SetTexCoord(0,math.max(.1,width/256),0,math.max(.1,height/256));texture:SetVertexColor(1,1,1,1)
 end
 texture:SetShown(shown);return true
end
function M.PaintBackgroundPanel(panel,shown)
 local mode=M.BackgroundStyle();if mode==1 then return false end
 local bg=panel.GetBackdrop and panel:GetBackdrop()or{}
 bg.bgFile=mode==3 and BACKGROUND_ROCK or'Interface\\Buttons\\WHITE8X8';bg.tile=mode==3;bg.tileSize=256
 panel:SetBackdrop(bg)
 if mode==3 then panel:SetBackdropColor(1,1,1,shown and .98 or 0)
 else panel:SetBackdropColor(.16,.17,.16,shown and .98 or 0)end
 return true
end
function M.SetBackgroundStyle(value)
 if not K.db or InCombatLockdown()or type(value)~='number'or value%1~=0 or value<1 or value>3 then return false end
 K.db.classicBags=K.db.classicBags or{};K.db.classicBags.backgroundStyle=value
 M.Refresh();return true
end
local backgroundLabels={
 en={'Bag background','Current','Plain grey','Blizzard stone','Changes the inventory surface only. Enable the bag background to see it; frames and item highlights keep their settings.'},
 tr={'Çanta zemini','Mevcut','Düz gri','Blizzard taş dokusu','Yalnızca envanter zeminini değiştirir. Görmek için çanta arka planı açık olmalı; çerçeve ve eşya vurguları kendi ayarlarında kalır.'},
 de={'Taschenhintergrund','Bisherig','Einfarbig grau','Blizzard-Stein','Ändert nur den Inventarhintergrund. Hintergrund muss aktiviert sein; Rahmen und Gegenstandsmarkierungen bleiben separat.'},
 frFR={'Fond des sacs','Actuel','Gris uni','Pierre Blizzard','Modifie seulement le fond de l’inventaire. Activez le fond pour le voir ; cadres et indications des objets restent séparés.'},
 itIT={'Sfondo delle borse','Attuale','Grigio uniforme','Pietra Blizzard','Modifica solo lo sfondo dell’inventario. Attiva lo sfondo per vederlo; cornici e indicatori restano separati.'},
 esES={'Fondo de las bolsas','Actual','Gris liso','Piedra Blizzard','Solo cambia el fondo del inventario. Activa el fondo para verlo; marcos e indicadores mantienen sus ajustes.'},
 ptBR={'Fundo das bolsas','Atual','Cinza liso','Pedra Blizzard','Muda apenas o fundo do inventário. Ative o fundo para vê-lo; molduras e destaques mantêm seus ajustes.'},
 ruRU={'Фон сумки','Текущий','Серый','Камень Blizzard','Меняет только фон инвентаря. Фон должен быть включён; рамки и подсветка предметов настраиваются отдельно.'},
 zhCN={'背包背景','当前','纯灰色','暴雪石纹','仅更改背包背景。需启用背景才能显示；边框和物品高亮保持原有设置。'},
}
function M.DrawBackgroundSettings(page,w,y)
 local language=KerimAnkaUIDB and KerimAnkaUIDB.language or'en'
 local text=backgroundLabels[language]or backgroundLabels.en
 w.Text(page,text[1],8,y,690,14,{.73,.62,.41})
 for value=1,3 do
  local mode=value
  local b=w.Button(page,text[value+1],(value-1)*240,y-27,234,32,function()if M.SetBackgroundStyle(mode)then K.Render()end end)
  w.Selected(b,M.BackgroundStyle()==value);if InCombatLockdown()then b:Disable()end
 end
 w.Text(page,text[5],8,y-73,690,11,{.65,.70,.62})
 return y-121
end

local metadata={}
-- Classic consumable subclasses are not a reliable food classifier by themselves.
-- Compare API-returned use effects to canonical localized Food / Drink effects;
-- never compare item names or scan tooltip prose.
local foodNames,foodSubclass
local function FoodReferences()
 if foodNames then return foodNames end
 local names={};local ready=0
 for _,id in ipairs({433,430})do
  local name
  if C_Spell and C_Spell.GetSpellName then name=C_Spell.GetSpellName(id)
  elseif GetSpellInfo then name=GetSpellInfo(id)end
  if type(name)=='string'and name~=''then names[name]=true;ready=ready+1 end
 end
 local use=C_Item and C_Item.GetItemSpell or GetItemSpell
 if use then for _,id in ipairs({117,159})do local name=use(id);if type(name)=='string'and name~=''then names[name]=true end end end
 local get=C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
 if get then
  local _,_,_,_,_,fc,fs=get(117)
  local _,_,_,_,_,wc,ws=get(159)
  local _,_,_,_,_,pc,ps=get(118)
  if fc==0 and wc==0 and pc==0 and type(fs)=='number'and fs==ws and fs~=ps then foodSubclass=fs end
 end
 if ready==2 then foodNames=names end
 return names
end
local function IsFood(info,m)
 if m.food~=nil then return m.food end
 local names=FoodReferences()
 local use=C_Item and C_Item.GetItemSpell or GetItemSpell
 local name,spell
 if use then name,spell=use(info.itemID)end
 if spell==433 or spell==430 or name and names[name]then m.food=true;return true end
 if foodSubclass~=nil and m.sub==foodSubclass then m.food=true;return true end
 -- Missing use data is not a permanent negative cache entry.
 if name and foodNames then m.food=false end
 return false
end
local infoEvents=CreateFrame('Frame')
infoEvents:RegisterEvent('GET_ITEM_INFO_RECEIVED')
infoEvents:SetScript('OnEvent',function(_,_,id,success)
 if success~=false then if type(id)=='number'then metadata[id]=nil end;foodNames=nil;foodSubclass=nil end
end)
function M.ItemCategory(bag,slot,info)
 if not info then return 'empty' end
 if K.ClassicInventoryStyle.IsQuestItem(bag,slot,info)then return 'quest'end
 if info.quality==0 then return 'junk'end
 local id=info.itemID;local m=id and metadata[id]
 if not m then
  local get=C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
  if get and id then
   local _,_,_,equip,_,class,sub=get(id)
   if type(class)=='number'then m={class=class,sub=sub,equip=equip};metadata[id]=m end
  end
 end
 if not m then return 'misc'end
 if m.class==12 then return 'quest'end
 if m.class==0 then return IsFood(info,m)and'food'or'consumable'end
 if m.class==2 or m.class==4 then return 'gear'end
 if m.class==7 or m.class==9 or m.class==5 or m.class==3 then return 'trade'end
 return 'misc'
end

-- Classic inventory priorities: shared by the sorter and optional category view.
local priorityGroups={'quest','consumable','food','gear','trade','misc'}
local priorityKeys={'first','second','third','fourth','fifth','sixth'}
local priorityLabels={
 en={'Sorting order','Daily use','Previous order','Custom','Hearthstone first','Quest items','Potions / Bandages','Food / Drink','Equipment','Crafting','Other','Earlier','Later','Junk and empty slots stay last. Special bags keep their item restrictions.','Character Inventory','Saved bags and bank · Read-only','ON','OFF'},
 tr={'Sıralama düzeni','Günlük kullanım','Önceki sıra','Özel','Ev taşını en öne al','Görev eşyaları','İksir / Bandaj','Yiyecek / İçecek','Ekipman','Meslek','Diğer','Öne','Arkaya','Gri eşyalar ve boş yuvalar sonda kalır. Özel çantaların eşya kısıtlamaları korunur.','Karakter Envanteri','Kayıtlı çanta ve banka · Salt okunur','AÇIK','KAPALI'},
 de={'Sortierreihenfolge','Alltag','Bisherige Reihenfolge','Eigene','Ruhestein zuerst','Questgegenstände','Tränke / Verbände','Essen / Trinken','Ausrüstung','Handwerk','Sonstiges','Früher','Später','Plunder und leere Plätze bleiben zuletzt. Spezialtaschen behalten ihre Einschränkungen.','Charakterinventar','Gespeicherte Taschen und Bank · Nur lesen','AN','AUS'},
 frFR={'Ordre de tri','Usage quotidien','Ordre précédent','Personnalisé','Pierre de foyer en premier','Objets de quête','Potions / Bandages','Nourriture / Boisson','Équipement','Artisanat','Autres','Avant','Après','Camelote et emplacements vides en dernier. Les sacs spéciaux gardent leurs restrictions.','Inventaire des personnages','Sacs et banque enregistrés · Lecture seule','ACTIVÉ','DÉSACTIVÉ'},
 itIT={'Ordine di riordino','Uso quotidiano','Ordine precedente','Personalizzato','Pietra del ritorno prima','Oggetti missione','Pozioni / Bende','Cibo / Bevande','Equipaggiamento','Professioni','Altro','Prima','Dopo','Cianfrusaglie e spazi vuoti in fondo. Restano i limiti delle borse speciali.','Inventario personaggi','Borse e banca salvate · Sola lettura','SÌ','NO'},
 esES={'Orden de clasificación','Uso diario','Orden anterior','Personalizado','Piedra de hogar primero','Objetos de misión','Pociones / Vendas','Comida / Bebida','Equipo','Profesiones','Otros','Antes','Después','Chatarra y huecos vacíos al final. Las bolsas especiales mantienen sus restricciones.','Inventario de personajes','Bolsas y banco guardados · Solo lectura','SÍ','NO'},
 ptBR={'Ordem de organização','Uso diário','Ordem anterior','Personalizada','Pedra de Regresso primeiro','Itens de missão','Poções / Bandagens','Comida / Bebida','Equipamento','Profissões','Outros','Antes','Depois','Sucata e espaços vazios no fim. Bolsas especiais mantêm suas restrições.','Inventário dos personagens','Bolsas e banco salvos · Somente leitura','SIM','NÃO'},
 ruRU={'Порядок сортировки','Повседневный','Прежний порядок','Свой','Камень возвращения первым','Предметы заданий','Зелья / Бинты','Еда / Напитки','Экипировка','Ремёсла','Прочее','Раньше','Позже','Хлам и пустые ячейки в конце. Ограничения специальных сумок сохраняются.','Инвентарь персонажей','Записанные сумки и банк · Только чтение','ВКЛ','ВЫКЛ'},
 zhCN={'排序方式','日常使用','原有顺序','自定义','炉石优先','任务物品','药水 / 绷带','食物 / 饮料','装备','专业','其他','提前','延后','杂物和空格放在最后。专用背包仍遵守物品限制。','角色物品栏','已记录的背包和银行 · 只读','开启','关闭'},
}
function M.PriorityText(index)
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en'
 return(priorityLabels[lang]or priorityLabels.en)[index]
end
local function PriorityConfig()
 return K.db and K.db.classicBags or{}
end
function M.SortMode()
 local mode=PriorityConfig().sortMode
 return(mode=='legacy'or mode=='custom')and mode or'daily'
end
function M.SortOrder()
 local saved=PriorityConfig().sortOrder;local order,seen={},{}
 local allowed={};for _,id in ipairs(priorityGroups)do allowed[id]=true end
 for _,key in ipairs(priorityKeys)do
  local id=type(saved)=='table'and saved[key]
  if allowed[id]and not seen[id]then order[#order+1]=id;seen[id]=true end
 end
 for _,id in ipairs(priorityGroups)do if not seen[id]then order[#order+1]=id end end
 return order
end
function M.SortPriorities()
 local mode=M.SortMode();local ranks={}
 if mode~='legacy'then
  for i,id in ipairs(mode=='custom'and M.SortOrder()or priorityGroups)do ranks[id]=i end
  ranks.junk=99
 end
 return ranks,mode~='legacy'and PriorityConfig().sortHearthFirst~=false
end
local function CanChangePriorities()
 return K.db and not(InCombatLockdown and InCombatLockdown())and not(K.ClassicBags and K.ClassicBags.IsSorting())
end
function M.SetSortMode(mode)
 if not CanChangePriorities()or(mode~='daily'and mode~='legacy'and mode~='custom')then return false end
 K.db.classicBags=K.db.classicBags or{};K.db.classicBags.sortMode=mode;return true
end
function M.SetHearthFirst(value)
 if not CanChangePriorities()or type(value)~='boolean'then return false end
 K.db.classicBags=K.db.classicBags or{};K.db.classicBags.sortHearthFirst=value;return true
end
function M.MoveSortGroup(index,delta)
 if not CanChangePriorities()or M.SortMode()~='custom'or type(index)~='number'or index%1~=0 or(delta~=-1 and delta~=1)then return false end
 local other=index+delta;if index<1 or index>6 or other<1 or other>6 then return false end
 local order=M.SortOrder();order[index],order[other]=order[other],order[index]
 local saved={};for i,key in ipairs(priorityKeys)do saved[key]=order[i]end
 K.db.classicBags.sortOrder=saved;return true
end
function M.DrawSortSettings(page,w,y)
 local text=M.PriorityText;local mode=M.SortMode();local enabled=CanChangePriorities()
 w.Text(page,text(1),8,y,690,14,{.73,.62,.41});y=y-27
 for i,id in ipairs({'daily','legacy','custom'})do
  local value=id;local b=w.Button(page,text(i+1),(i-1)*240,y,234,32,function()if M.SetSortMode(value)then K.Render()end end)
  w.Selected(b,id==mode);if not enabled then b:Disable()end
 end
 y=y-43
 local first=mode~='legacy'and PriorityConfig().sortHearthFirst~=false
 local b=w.Button(page,text(5)..': '..text(first and 17 or 18),0,y,714,30,function()if M.SetHearthFirst(not first)then K.Render()end end)
 w.Selected(b,first and mode~='legacy');if not enabled or mode=='legacy'then b:Disable()end;y=y-40
 local order=mode=='custom'and M.SortOrder()or priorityGroups
 for i,id in ipairs(mode~='legacy'and order or{})do
  local number=i;local label=6;for j,group in ipairs(priorityGroups)do if id==group then label=j+5;break end end
  w.Text(page,i..'. '..text(label),16,y-7,400,12,{.86,.87,.82})
  if mode=='custom'then
   for j,delta in ipairs({-1,1})do
    local direction=delta;local button=w.Button(page,text(j+11),418+(j-1)*148,y,140,27,function()if M.MoveSortGroup(number,direction)then K.Render()end end)
    if not enabled or i+delta<1 or i+delta>6 then button:Disable()end
   end
  end
  y=y-32
 end
 w.Text(page,text(14),8,y-3,690,12,{.65,.70,.62});return y-62
end

function M.PaintItemBorder(button,quality,hasItem,quest)
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
 local questBorder=quest and Get('bagQuest',true)
 local qualityBorder=type(quality)=='number'and quality>=2 and Get('bagQuality',true)
 local color=questBorder and {r=1,g=.82,b=0}or qualityBorder and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
 color=color or{r=1,g=1,b=1}
 -- Draw an extra outline only for enabled quest / quality highlights.
 -- Thickness is in physical pixels, independent of inventory/item scale.
 local scale=button.GetEffectiveScale and button:GetEffectiveScale()or button:GetScale()
 scale=type(scale)=='number'and scale>0 and scale or 1
 local width=(questBorder or qualityBorder)and 2/scale or 1/scale
 for i,t in ipairs(button.kaEdges)do
  if i<=2 then t:SetHeight(width)else t:SetWidth(width)end
  if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(true)end
  t:SetVertexColor(color.r,color.g,color.b);t:SetShown(hasItem and(questBorder or qualityBorder))
 end
end
