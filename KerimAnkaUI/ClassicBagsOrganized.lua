-- Optional Classic Era presentation. Native bag/slot buttons and Fast3 own item operations.
local _,K=...
local O={};K.ClassicBagsOrganized=O
local categories={'quest','consumable','food','ammo','soul','gear','trade','misc','junk'}
local strings={
 en={'Organized','Quick Access','All','Pinned','Quest','Potions / Supplies','Food / Drink','Equipment','Crafting','Other','Junk','My bags','Pin items','Done','free','Empty slots','No matching items','Show all','Recorded items','Click items to pin / unpin. Finish to use items normally.','Keyring','Resize','Bag settings'},
 tr={'Düzenli','Hızlı Erişim','Tümü','Sabitler','Görev','İksir / Tüketim','Yiyecek / İçecek','Ekipman','Meslek','Diğer','Gri Eşyalar','Çantalarım','Sabitle','Bitir','boş','Boş yuvalar','Eşleşen eşya yok','Tümünü göster','Eşya kayıtları','Sabitlemek / kaldırmak için eşyaya tıkla. Normal kullanıma dönmek için Bitir.','Anahtarlık','Boyutlandır','Çanta ayarları'},
 de={'Geordnet','Schnellzugriff','Alle','Angeheftet','Quest','Tränke / Verbrauch','Essen / Trinken','Ausrüstung','Handwerk','Sonstiges','Plunder','Meine Taschen','Anheften','Fertig','frei','Leere Plätze','Keine passenden Gegenstände','Alle anzeigen','Gespeicherte Gegenstände','Zum Anheften / Lösen auf Gegenstände klicken. Fertig stellt die normale Nutzung wieder her.','Schlüsselbund','Größe ändern','Tascheneinstellungen'},
 frFR={'Organisé','Accès rapide','Tout','Épinglés','Quête','Potions / Consommables','Nourriture / Boisson','Équipement','Artisanat','Autres','Camelote','Mes sacs','Épingler','Terminé','libres','Emplacements vides','Aucun objet correspondant','Tout afficher','Objets enregistrés','Cliquez sur les objets pour épingler / retirer. Terminé rétablit leur utilisation normale.','Trousseau','Redimensionner','Options des sacs'},
 itIT={'Organizzato','Accesso rapido','Tutto','Fissati','Missione','Pozioni / Consumabili','Cibo / Bevande','Equipaggiamento','Professioni','Altro','Cianfrusaglie','Le mie borse','Fissa','Fine','liberi','Spazi vuoti','Nessun oggetto corrispondente','Mostra tutto','Oggetti salvati','Clicca sugli oggetti per fissarli / rimuoverli. Fine ripristina il normale utilizzo.','Portachiavi','Ridimensiona','Impostazioni borse'},
 esES={'Organizado','Acceso rápido','Todo','Fijados','Misión','Pociones / Consumibles','Comida / Bebida','Equipo','Profesiones','Otros','Chatarra','Mis bolsas','Fijar','Listo','libres','Espacios vacíos','No hay objetos coincidentes','Mostrar todo','Objetos guardados','Haz clic en objetos para fijar / quitar. Listo restaura el uso normal.','Llavero','Cambiar tamaño','Ajustes de bolsas'},
 ptBR={'Organizado','Acesso rápido','Todos','Fixados','Missão','Poções / Consumíveis','Comida / Bebida','Equipamento','Profissões','Outros','Sucata','Minhas bolsas','Fixar','Concluir','livres','Espaços vazios','Nenhum item correspondente','Mostrar todos','Itens registrados','Clique nos itens para fixar / remover. Concluir restaura o uso normal.','Chaveiro','Redimensionar','Configurações de bolsas'},
 ruRU={'По категориям','Быстрый доступ','Все','Закреплённые','Задания','Зелья / Расходники','Еда / Напитки','Экипировка','Ремёсла','Прочее','Хлам','Мои сумки','Закрепить','Готово','свободно','Пустые ячейки','Нет подходящих предметов','Показать всё','Записанные предметы','Нажимайте на предметы для закрепления / отмены. Готово возвращает обычное использование.','Связка ключей','Размер','Настройки сумок'},
 zhCN={'分类','快速访问','全部','已固定','任务','药水 / 消耗品','食物 / 饮料','装备','专业','其他','杂物','我的背包','固定物品','完成','空闲','空格','没有匹配物品','显示全部','已记录物品','点击物品以固定或取消固定。点击完成恢复正常使用。','钥匙链','调整大小','背包设置'},
}
-- Text for the in-bag workflow; no dependency on the suite options window.
local workflow={
 en={'Recent additions','Organize categories','Drag a heading onto another heading. Done saves the order.','Clear recent list','Recent limit','Also shown in their categories. Each icon acts on one real stack.','Bag tools'},
 tr={'Son Eklenenler','Kategorileri düzenle','Başlığı başka bir başlığa sürükle. Bitir ile düzenlemeyi kapat.','Son eklenenleri temizle','Son eklenen sınırı','Kendi kategorilerinde de görünür. Her ikon gerçek bir yığın üzerinde işlem yapar.','Çanta araçları'},
 de={'Zuletzt hinzugefügt','Kategorien anordnen','Eine Überschrift auf eine andere ziehen. Fertig beendet die Anordnung.','Liste leeren','Anzahl letzter Gegenstände','Auch in ihren Kategorien sichtbar. Jedes Symbol verwendet einen echten Stapel.','Taschenwerkzeuge'},
 frFR={'Ajouts récents','Organiser les catégories','Glissez un titre sur un autre. Terminé quitte ce mode.','Vider la liste récente','Limite des ajouts','Aussi affichés dans leur catégorie. Chaque icône utilise une pile réelle.','Outils des sacs'},
 itIT={'Aggiunti di recente','Ordina categorie','Trascina un titolo su un altro. Fine termina la modifica.','Svuota elenco recente','Limite recenti','Visibili anche nelle categorie. Ogni icona usa una pila reale.','Strumenti borse'},
 esES={'Añadidos recientemente','Ordenar categorías','Arrastra un título sobre otro. Listo termina la edición.','Vaciar lista reciente','Límite de recientes','También aparecen en sus categorías. Cada icono usa una pila real.','Herramientas de bolsas'},
 ptBR={'Adicionados recentemente','Organizar categorias','Arraste um título sobre outro. Concluir encerra a edição.','Limpar lista recente','Limite de recentes','Também aparecem em suas categorias. Cada ícone usa uma pilha real.','Ferramentas das bolsas'},
 ruRU={'Недавно полученные','Порядок категорий','Перетащите заголовок на другой. Готово завершает настройку.','Очистить список','Лимит недавних','Также видны в своих категориях. Значок использует реальную стопку.','Инструменты сумки'},
 zhCN={'最近获得','排列分类','将标题拖到另一个标题上。完成后退出排列。','清空最近列表','最近物品上限','也显示在原分类中。每个图标操作一个实际堆叠。','背包工具'},
}
local function W(i)local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en';return(workflow[lang]or workflow.en)[i]end
local capacityText={
 en={'General','Special','Full','Special slots only accept matching item types.','No suitable\nfree slot','Bag type pending','No space in\nselected bag'},
 tr={'Genel','Özel','Dolu','Özel yuvalar yalnız uygun eşya türlerini kabul eder.','Uygun boş\nyuva yok','Çanta türü bekleniyor','Seçili çantada\nyer yok'},
 de={'Allgemein','Spezial','Voll','Spezialplätze nehmen nur passende Gegenstände auf.','Kein passender\nfreier Platz','Taschentyp wird geladen','Kein Platz in\nausgewählter Tasche'},
 frFR={'Général','Spécial','Plein','Les emplacements spéciaux acceptent uniquement les objets adaptés.','Aucun emplacement\nlibre adapté','Type de sac en attente','Pas de place dans\nle sac sélectionné'},
 itIT={'Normali','Speciali','Pieno','Gli spazi speciali accettano solo oggetti adatti.','Nessuno spazio\nlibero adatto','Tipo borsa in attesa','Nessuno spazio nella\nborsa selezionata'},
 esES={'General','Especial','Lleno','Los espacios especiales solo aceptan objetos compatibles.','No hay espacio\nlibre compatible','Tipo de bolsa pendiente','Sin espacio en la\nbolsa seleccionada'},
 ptBR={'Geral','Especial','Cheia','Espaços especiais só aceitam tipos de itens compatíveis.','Sem espaço\nlivre compatível','Tipo de bolsa pendente','Sem espaço na\nbolsa selecionada'},
 ruRU={'Обычные','Особые','Полны','Особые ячейки принимают только подходящие предметы.','Нет подходящей\nсвободной ячейки','Тип сумки загружается','Нет места в\nвыбранной сумке'},
 zhCN={'普通','专用','已满','专用格只接受对应类型的物品。','没有合适的\n空格','等待背包类型','所选背包\n没有空间'},
}
local function Cap(i)local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en';return(capacityText[lang]or capacityText.en)[i]end
local Text
-- Presentation only: the dedicated reagent slot can report bag family zero,
-- but its empty slots are not general-purpose inventory space.
function O.SpaceFamily(bag)
 if bag==0 then return 0 end
 local get=C_Container and C_Container.GetContainerNumFreeSlots
 local family=get and select(2,get(bag))
 if type(family)~='number'or(issecretvalue and issecretvalue(family))then return end
 local reagent=Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag or 5
 if bag==reagent and family==0 then return 'reagent' end
 return family
end
function O.CapacityTooltip(owner,spaces)
 local generalFree,generalSlots,specialFree,specialSlots=0,0,0,0
 for _,e in ipairs(spaces or{})do
  if e.family==0 then generalFree=generalFree+e.free;generalSlots=generalSlots+e.slots
  elseif type(e.family)=='number'or e.family=='reagent'then specialFree=specialFree+e.free;specialSlots=specialSlots+e.slots end
 end
 GameTooltip:SetOwner(owner,'ANCHOR_RIGHT');GameTooltip:SetText(Text(16))
 GameTooltip:AddDoubleLine(Cap(1),generalFree..' / '..generalSlots,.8,.8,.75,1,1,1)
 if specialSlots>0 then GameTooltip:AddDoubleLine(Cap(2),specialFree..' / '..specialSlots,.8,.8,.75,1,1,1)end
 for _,e in ipairs(spaces or{})do if e.slots>0 then
  local name=C_Container.GetBagName and C_Container.GetBagName(e.bag)or(K.InventoryText('Backpack')..' '..e.bag)
  local kind=e.family==0 and Cap(1)or(type(e.family)=='number'or e.family=='reagent')and Cap(2)or Cap(6)
  GameTooltip:AddDoubleLine(name..' ('..kind..')',e.free..' / '..e.slots,.8,.8,.75,1,1,1)
 end end
 if specialSlots>0 then GameTooltip:AddLine(Cap(4),.95,.75,.45,true)end
 K.InventoryTooltip(GameTooltip);GameTooltip:Show()
end
local specialLabels={en={'Ammunition','Soul Shards'},tr={'Mühimmat','Ruh Parçaları'},
 de={'Munition','Seelensplitter'},frFR={'Munitions',"Fragments d’âme"},itIT={'Munizioni','Frammenti d’anima'},
 esES={'Munición','Fragmentos de alma'},ptBR={'Munição','Fragmentos de alma'},
 ruRU={'Боеприпасы','Осколки душ'},zhCN={'弹药','灵魂碎片'}}
for lang,labels in pairs(specialLabels)do strings[lang][25]=labels[1];strings[lang][26]=labels[2]end
local labelIndex={quest=5,consumable=6,food=7,gear=8,trade=9,misc=10,junk=11,pins=4,all=3,ammo=25,soul=26}
Text=function(i)
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en'
 return (strings[lang]or strings.en)[i]or strings.en[i]
end
function O.CategoryLabel(id)return Text(id=='empty'and 16 or labelIndex[id]or 10)end
local function Config()
 if not K.db then return end
 K.db.classicBags=K.db.classicBags or{}
 local d=K.db.classicBags
 if type(d.organized)~='table'then d.organized={}end
 local c=d.organized
 if type(c.pins)~='table'then c.pins={}end
 if type(c.collapsed)~='table'then c.collapsed={}end
 if type(c.recent)~='table'then c.recent={}end
 c.recentLimit=({[6]=true,[12]=true,[24]=true})[c.recentLimit]and c.recentLimit or 12
 return c
end
local defaultOrder={'recent','pins','quest','consumable','food','ammo','soul','gear','trade','misc','junk'}
function O.Order()
 local d=Config();local result,seen={},{}
 if d and type(d.categoryOrder)=='table'then for i=1,#defaultOrder do local id=d.categoryOrder[i];for _,valid in ipairs(defaultOrder)do if id==valid and not seen[id]then result[#result+1]=id;seen[id]=true end end end end
 for _,id in ipairs(defaultOrder)do if not seen[id]then result[#result+1]=id end end
 return result
end
function O.MoveCategory(source,target)
 if InCombatLockdown and InCombatLockdown()then return false end
 local order=O.Order();local from,to
 for i,id in ipairs(order)do if id==source then from=i end;if id==target then to=i end end
 if not from or not to or from==to then return false end
 table.remove(order,from);table.insert(order,to,source);Config().categoryOrder=order;return true
end
-- Session baseline is never restored from a profile. Track quantities across ALL
-- carried bags, so sorting, swapping and splitting cannot create new entries.
local baseline,recentQueued
local function Totals()
 local result={};local locked=false
 for bag=0,K.ForeverInventoryAdapter.LastBag()do for slot=1,C_Container.GetContainerNumSlots(bag)do
  local info=C_Container.GetContainerItemInfo(bag,slot)
  if info and info.itemID then result[info.itemID]=(result[info.itemID]or 0)+(info.stackCount or 1);locked=locked or info.isLocked end
 end end
 return result,locked
end
function O.ObserveRecent()
 local d=Config();if not d then return end
 local totals,locked=Totals();local old=baseline
 local ids,seen={},{}
 -- Keep the last settled baseline while native moves, locks or a held stack
 -- temporarily remove items from slots. Splitting must not look like a gain.
 local held=(GetCursorInfo and GetCursorInfo())or(CursorHasItem and CursorHasItem())
 local sorting=K.ClassicBags and K.ClassicBags.IsSorting and K.ClassicBags.IsSorting()
 if held or sorting or locked then return end
 baseline=totals
 if old then
  local added={};for id,count in pairs(totals)do if count>(old[id]or 0)then added[#added+1]=id end end;table.sort(added)
  for _,id in ipairs(added)do ids[#ids+1]=id;seen[id]=true end
 end
 for i=1,24 do local id=d.recent[i];if type(id)=='number'and totals[id]and not seen[id]then ids[#ids+1]=id;seen[id]=true end end
 d.recent={};for i=1,math.min(#ids,d.recentLimit)do d.recent[i]=ids[i]end
end
local function Combat()return InCombatLockdown and InCombatLockdown()end
function O.Active()local c=Config();return c and c.enabled==true end
function O.Category(bag,slot,info)
 local base=K.ClassicInventoryStyle.ItemCategory(bag,slot,info)
 if base=='quest'then return base end
 return K.ForeverInventoryAdapter.SpecialCategory(info)or base
end
function O.ShelfLayout(width,lastBag,hasKey)
 local cells=lastBag+1+(hasKey and 1 or 0)
 local size=math.min(38,math.floor((width-40-7*(cells-1))/cells))
 return size,math.floor((width-size*cells-7*(cells-1))/2),lastBag+1
end
function O.PinKey(info)
 if not info or not info.itemID then return end
 -- Favourite a type, not a physical slot. Random suffixes must remain distinct.
 local raw=info.hyperlink and info.hyperlink:match('item:([^|]+)')
 local parts={};if raw then for p in (raw..':'):gmatch('(.-):')do parts[#parts+1]=p end end
 local suffix=tonumber(parts[7])or 0
 return tostring(info.itemID)..':'..tostring(suffix)
end
local function Clamp(v,lo,hi,default)
 v=tonumber(v);if not v or v~=v or v==math.huge or v==-math.huge then return default end
 return math.max(lo,math.min(hi,v))
end
local state
-- A merchant window can emit cursor changes without a held item. Ignore those.
local function CursorItem()
 local kind,id,link;if GetCursorInfo then kind,id,link=GetCursorInfo()end
 if kind=='merchant'then
  link=GetMerchantItemLink and id and GetMerchantItemLink(id)
  return true,link and tonumber(link:match('item:(%d+)')),'merchant:'..tostring(id)..':'..tostring(link)
 end
 if kind=='item'then return true,id,'item:'..tostring(id)..':'..tostring(link)end
 -- Some split/pickup paths expose the held item before cursor metadata settles.
 if CursorHasItem and CursorHasItem()then return true,nil,'held-item'end
 return false,nil,'none'
end
local dropHelp={
 en='Drop here. The item will appear in its own category. This is existing free bag space.',
 tr='Buraya bırak. Eşya kendi kategorisinde görünür. Bu, çantandaki mevcut boş bir yuvadır.',
 de='Hier ablegen. Der Gegenstand erscheint in seiner Kategorie. Dies ist ein vorhandener freier Taschenplatz.',
 frFR='Déposez ici. L’objet apparaîtra dans sa catégorie. Cet emplacement libre existe déjà dans vos sacs.',
 itIT='Rilascia qui. L’oggetto apparirà nella sua categoria. È uno spazio libero già presente nelle borse.',
 esES='Suelta aquí. El objeto aparecerá en su categoría. Es un hueco libre que ya existe en tus bolsas.',
 ptBR='Solte aqui. O item aparecerá em sua categoria. Este espaço livre já existe nas suas bolsas.',
 ruRU='Поместите сюда. Предмет появится в своей категории. Это свободная ячейка вашей сумки.',
 zhCN='放到这里。物品会显示在所属分类中。这是背包内已有的空格。',
}
local function DropHelp()
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en';return dropHelp[lang]or dropHelp.en
end
local function Refresh()if K.ClassicBags then K.ClassicBags.Refresh()end end
local function Label(parent,size)
 local f=parent:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');K.InventoryFont(f,size)
 f:SetWordWrap(false);return f
end
local function TabFont(label)K.InventoryFont(label,11)end
local function Backdrop(f,r,g,b,a)
 f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
 f:SetBackdropColor(r,g,b,a or 1);f:SetBackdropBorderColor(.28,.27,.24,1)
end
local function HideTip(owner)
 if not GameTooltip.GetOwner or GameTooltip:GetOwner()==owner then GameTooltip:Hide()end
end
local function Button(parent,text,fn)
 local b=CreateFrame('Button',nil,parent,'BackdropTemplate');Backdrop(b,.115,.115,.11)
 b.label=Label(b);b.label:SetPoint('LEFT',6,0);b.label:SetPoint('RIGHT',-6,0);b.label:SetJustifyH('CENTER');b.label:SetText(text);b.label:SetTextColor(.80,.79,.73,1)
 b:SetScript('OnEnter',function(self)self:SetBackdropColor(.19,.18,.16,1);self:SetBackdropBorderColor(.43,.39,.31,1);if self.label then self.label:SetTextColor(.91,.84,.66,1)end;if self.kaTip then GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(self.kaTip);K.InventoryTooltip(GameTooltip);GameTooltip:Show()end end)
 b:SetScript('OnLeave',function(self)self:SetBackdropColor(.115,.115,.11,1);self:SetBackdropBorderColor(.28,.27,.24,1);if self.label then self.label:SetTextColor(.78,.78,.73,1)end;HideTip(self)end)
 b:SetScript('OnHide',function(self)HideTip(self)end)
 b:SetScript('OnClick',function(self,...)HideTip(self);if not Combat()or self.kaCombatAllowed then fn(self,...)end end)
 return b
end
local MEDIA='Interface\\AddOns\\KerimAnkaUI\\BagMedia\\Organized'
local extraText={
 en={'Narrower bag window','Wider bag window','Previous bag view','Drag: resize. Right-click: compact size.','Close','Filter items'},
 tr={'Çanta penceresini daralt','Çanta penceresini genişlet','Önceki çanta görünümü','Sürükle: boyutlandır. Sağ tık: kompakt boyut.','Kapat','Eşyaları filtrele'},
 de={'Taschenfenster schmaler','Taschenfenster breiter','Vorherige Taschenansicht','Ziehen: Größe ändern. Rechtsklick: kompakte Größe.','Schließen','Gegenstände filtern'},
 frFR={'Réduire la largeur du sac','Augmenter la largeur du sac','Vue précédente','Glisser : redimensionner. Clic droit : taille compacte.','Fermer','Filtrer les objets'},
 itIT={'Restringi la finestra della borsa','Allarga la finestra della borsa','Vista precedente','Trascina: ridimensiona. Clic destro: dimensioni compatte.','Chiudi','Filtra oggetti'},
 esES={'Estrechar la ventana de bolsas','Ampliar la ventana de bolsas','Vista anterior','Arrastra: cambiar tamaño. Clic derecho: tamaño compacto.','Cerrar','Filtrar objetos'},
 ptBR={'Estreitar a janela de bolsas','Alargar a janela de bolsas','Visualização anterior','Arraste: redimensionar. Clique direito: tamanho compacto.','Fechar','Filtrar itens'},
 ruRU={'Сузить окно сумки','Расширить окно сумки','Предыдущий вид сумки','Перетащить: размер. Правая кнопка: компактный размер.','Закрыть','Фильтр предметов'},
 zhCN={'缩窄背包窗口','加宽背包窗口','上一个背包视图','拖动：调整大小。右键：紧凑尺寸。','关闭','筛选物品'},
}
local function TipText(i)
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en'
 return(extraText[lang]or extraText.en)[i]
end
local function Asset(owner,name,size,point,x,y,rotation)
 local t=owner.kaOrganizedGlyph
 if not t then t=owner:CreateTexture(nil,'OVERLAY');owner.kaOrganizedGlyph=t end
 t:SetTexture(MEDIA..name..'.tga');t:SetSize(size,size);t:ClearAllPoints();t:SetPoint(point or'CENTER',x or 0,y or 0)
 if t.SetRotation then t:SetRotation(rotation or 0)end
 t:SetVertexColor(.80,.79,.73,1);t:Show();return t
end
local function Segments(b,kind)
 if b.label then b.label:SetText('')else b:SetText('')end
 b.kaLines=b.kaLines or{}
 local shapes=kind=='close'and{{0,0,13,1.4,math.pi/4},{0,0,13,1.4,-math.pi/4}}
  or kind=='plus'and{{0,0,10,1.4,0},{0,0,1.4,10,0}}
  or kind=='minus'and{{0,0,10,1.4,0}}
  or{{0,0,17,1.4,math.pi/4},{4,-1,10,1.4,math.pi/4},{6,-4,4,1.4,math.pi/4}}
 for i,a in ipairs(shapes)do
  local t=b.kaLines[i];if not t then t=b:CreateTexture(nil,'OVERLAY');b.kaLines[i]=t end
  t:SetColorTexture(.80,.79,.73,1);t:ClearAllPoints();t:SetPoint('CENTER',a[1],a[2]);local factor=(b==state.close or b==state.smaller or b==state.larger)and .84 or 1;t:SetSize(a[3]*factor,a[4]);if t.SetRotation then t:SetRotation(a[5])end;t:Show()
 end
end

local function Place(b,parent,x,y,w,h)
 local key=tostring(parent)..':'..x..':'..y..':'..w..':'..h..':'..(state and state.activation or 0)
 if b.kaOrganizedPlace~=key then b:ClearAllPoints();b:SetPoint('TOPLEFT',parent,'TOPLEFT',x,-y);b:SetSize(w,h);b.kaOrganizedPlace=key end
 b:Show()
end
local function SkinPlain(b)
 if b.kaOrganizedSkinActivation==(state and state.activation)then return end
 b.kaOrganizedSkinActivation=state and state.activation
 if b.GetBackdrop then b.kaOrganizedOldBackdrop={layout=b:GetBackdrop(),color={b:GetBackdropColor()},border={b:GetBackdropBorderColor()}}end
 for _,r in ipairs({b:GetRegions()})do if r:GetObjectType()=='Texture'then r:Hide()end end
 for _,method in ipairs({'GetNormalTexture','GetPushedTexture','GetHighlightTexture','GetDisabledTexture'})do
  local t=b[method]and b[method](b);if t then t:Hide()end
 end
 Backdrop(b,.115,.115,.11)
end
local function Ensure(c)
 if state then return state end
 local f=c.frame
 local s={filter='all',editing=false,shelf=false,empty=false,filters={},headers={},hidden={},ctx=c}
 state=s
 s.surface=CreateFrame('Frame',nil,f,'BackdropTemplate');s.surface:SetAllPoints();Backdrop(s.surface,.055,.055,.05,.98)
 s.surface:SetFrameLevel(f:GetFrameLevel()+1);s.surface:EnableMouse(false)
 s.shade=s.surface:CreateTexture(nil,'BACKGROUND',nil,2);s.shade:SetAllPoints();s.shade:SetColorTexture(.025,.025,.025,.42)
 s.top=CreateFrame('Frame',nil,s.surface,'BackdropTemplate');Backdrop(s.top,.065,.065,.06);s.top:SetPoint('TOPLEFT',1,-1);s.top:SetPoint('TOPRIGHT',-1,-1);s.top:SetHeight(32)
 s.logo=s.top:CreateTexture(nil,'ARTWORK');K.ClassicBagDesigns.Glyph(s.logo,1);s.logo:SetSize(44,44);s.logo:SetPoint('TOPLEFT',-14,10)
 s.brand=Label(s.top,14);s.brand:SetPoint('TOPLEFT',44,-9);s.brand:SetTextColor(.83,.77,.58)
 s.sub=Label(s.top,10);s.sub:SetPoint('TOPLEFT',47,-29);s.sub:SetTextColor(.55,.60,.53);s.sub:SetJustifyH('LEFT')
 s.close=Button(s.top,'X',function()f:Hide()end);s.close.kaCombatAllowed=true
 
 s.smaller=Button(s.top,'-',function()K.InventoryPresentation.ChangeText('bag',-1)end)
 s.larger=Button(s.top,'+',function()K.InventoryPresentation.ChangeText('bag',1)end)
 s.edit=Button(s.surface,'',function()if s.reordering then s.reordering=false;s.drag=nil;Refresh();return end;s.editing=not s.editing;if s.editing then Config().collapsed.pins=nil end;Refresh()end)
 s.filterToggle=Button(s.surface,'',function()s.filterOpen=not s.filterOpen;Refresh()end);s.filterToggle.kaCombatAllowed=true
 s.filterPanel=CreateFrame('Frame',nil,s.surface,'BackdropTemplate');Backdrop(s.filterPanel,.065,.065,.06);s.filterPanel:SetFrameLevel(f:GetFrameLevel()+15)
 s.filterPanel:EnableMouse(true);s.filterPanel:SetClampedToScreen(true)
 s.filterPanel:SetScript('OnHide',function()s.filterOpen=false end)
 local ids={'all','pins','recent'};for _,id in ipairs(categories)do ids[#ids+1]=id end
 for _,id in ipairs(ids)do
  local key=id
  s.filters[id]=Button(s.surface,'',function()s.filter=key;if key=='all'then s.ctx.setFilter(nil)end;s.filterOpen=false;s.scroll:SetVerticalScroll(0);Refresh()end);s.filters[id].kaCombatAllowed=true
 end
 s.note=Label(s.surface,10);s.note:SetJustifyH('LEFT');s.note:SetTextColor(.64,.68,.62)
 s.scroll=CreateFrame('ScrollFrame',nil,s.surface);s.scroll:EnableMouseWheel(true)
 s.child=CreateFrame('Frame',nil,s.scroll);s.child:SetSize(1,1);s.scroll:SetScrollChild(s.child)
 s.scroll:SetScript('OnMouseWheel',function(self,delta)self:SetVerticalScroll(Clamp(self:GetVerticalScroll()-delta*42,0,s.maxScroll or 0,0))end)
 s.track=CreateFrame('Frame',nil,s.surface,'BackdropTemplate');Backdrop(s.track,.055,.055,.05)
 s.thumb=s.track:CreateTexture(nil,'ARTWORK');s.thumb:SetColorTexture(.31,.35,.29,1)
 s.scroll:SetScript('OnVerticalScroll',function(_,offset)
  local h=s.scroll:GetHeight();local max=s.maxScroll or 0;local thumb=math.max(18,h*h/math.max(h,s.child:GetHeight()))
  s.thumb:ClearAllPoints();s.thumb:SetPoint('TOPLEFT',0,-(max>0 and offset/max*(h-thumb)or 0));s.thumb:SetSize(3,thumb)
 end)
 s.tools=CreateFrame('Frame',nil,s.surface,'BackdropTemplate');Backdrop(s.tools,.065,.065,.06);s.tools:SetFrameLevel(f:GetFrameLevel()+30);s.tools:EnableMouse(true);s.tools:SetClampedToScreen(true);s.tools:Hide()
 s.toolButtons={}
 local function Tool(fn)local b=Button(s.tools,'',function()s.tools:Hide();fn()end);s.toolButtons[#s.toolButtons+1]=b;return b end
 s.originalSettingsClick=c.settings:GetScript('OnClick')
 Tool(function()if s.originalSettingsClick then s.originalSettingsClick(c.settings,'LeftButton')end end)
 Tool(function()s.reordering=not s.reordering;s.editing=false;s.filter='all';s.ctx.setFilter(nil);Refresh()end)
 Tool(function()Config().recent={};Refresh()end)
 for _,limit in ipairs({6,12,24})do local value=limit;Tool(function()Config().recentLimit=value;while #Config().recent>value do table.remove(Config().recent)end;Refresh()end)end
 s.shelfPanel=CreateFrame('Frame',nil,s.surface,'BackdropTemplate');Backdrop(s.shelfPanel,.065,.065,.06)
 s.shelfTitle=Label(s.shelfPanel,10);s.shelfTitle:SetPoint('TOPLEFT',8,-6)
 s.shelfButton=Button(s.surface,'',function()s.shelf=not s.shelf;Refresh()end);s.shelfButton.kaCombatAllowed=true
 s.capacity=Button(s.surface,'',function()s.empty=not s.empty;Refresh();if s.empty then s.scroll:SetVerticalScroll(s.maxScroll or 0)end end);s.capacity.kaCombatAllowed=true
 s.money=Label(s.surface);s.money:SetJustifyH('RIGHT')
 s.none=Label(s.child)
 s.grip=Button(s.surface,'',function(_,button)
  if button=='RightButton'then local d=Config();d.width=400;d.height=380;K.InventoryMenus.Set('bagSize',30);Refresh()end
 end);s.grip:RegisterForClicks('LeftButtonUp','RightButtonUp');s.grip:SetScript('OnMouseDown',function(_,button)
  if button=='LeftButton'then O.StartResize()end
 end)
 s.grip:SetScript('OnMouseUp',function()O.StopResize()end)
 f:HookScript('OnHide',function()O.StopResize();s.editing=false;s.reordering=false;s.drag=nil;s.tools:Hide();s.filterOpen=false;s.cursorItem=false;s.cursorSignature=nil;HideTip(s.filterToggle)end)
 s.cursorEvents=CreateFrame('Frame',nil,f);K.ForeverInventoryAdapter.RegisterEvent(s.cursorEvents,'CURSOR_CHANGED')
 s.cursorEvents:SetScript('OnEvent',function()
  if not s.active or not f:IsShown()or s.cursorQueued then return end
  s.cursorQueued=true;C_Timer.After(0,function()
   s.cursorQueued=false;if not s.active or not f:IsShown()then return end
   local held,_,signature=CursorItem()
   if signature==s.cursorSignature then return end
   s.cursorSignature=signature;s.cursorItem=held;Refresh()
   -- Keep the current viewport; never navigate on cursor/merchant events.
  end)
 end)
 s.activation=0
 return s
end
-- One origin and one cursor delta: never combine native StartSizing with relayout.
function O.StartResize()
 local s=state;if not s or not s.active or s.sizing or Combat()or not GetCursorPosition then return false end
 if GetCursorInfo and GetCursorInfo()then return false end
 local f=s.ctx.frame;local x,y=GetCursorPosition();local scale=f:GetEffectiveScale()
 if not x or not y or not scale or scale<=0 then return false end
 local cx,cy=f:GetCenter();local left=f.GetLeft and f:GetLeft()or(cx and cx-f:GetWidth()/2)
 local top=f.GetTop and f:GetTop()or(cy and cy+f:GetHeight()/2)
 if not left or not top then return false end
 local parentScale=UIParent:GetEffectiveScale();local ratio=parentScale/scale
 local screenWidth=UIParent:GetWidth()*ratio;local screenHeight=UIParent:GetHeight()*ratio
 local initial={x=x,y=y,scale=scale,w=f:GetWidth(),h=f:GetHeight(),left=left,top=top,
  maxW=math.max(400,math.min(1000,screenWidth-left)),maxH=math.max(380,math.min(800,top,screenHeight))}
 f:StopMovingOrSizing();f:ClearAllPoints();f:SetPoint('TOPLEFT',UIParent,'BOTTOMLEFT',left,top)
 s.sizing=initial
 s.grip:SetScript('OnUpdate',function()
  if Combat()or not IsMouseButtonDown('LeftButton')then O.StopResize();return end
  local px,py=GetCursorPosition();if not px or not py then O.StopResize();return end
  local dx,dy=(px-initial.x)/initial.scale,(initial.y-py)/initial.scale
  if math.abs(dx)<3 and math.abs(dy)<3 then return end
  local w=math.floor(Clamp(initial.w+dx,400,initial.maxW,initial.w)+.5)
  local h=math.floor(Clamp(initial.h+dy,380,initial.maxH,initial.h)+.5)
  local d=Config();if w~=f:GetWidth()or h~=f:GetHeight()then d.width=w;d.height=h;f:SetSize(w,h);Refresh()end
 end)
 return true
end
function O.StopResize()
 local s=state;if not s or not s.sizing then return end
 s.sizing=false;s.grip:SetScript('OnUpdate',nil)
 local f=s.ctx.frame;local d=Config();d.width=f:GetWidth();d.height=f:GetHeight()
 local x,y=f:GetCenter();local px,py=UIParent:GetCenter()
 if x and y and px and py then K.db.classicBags.x=x-px;K.db.classicBags.y=y-py end
end
local function EmptyFamily(entry)
 if entry.bag==0 then return 0 end
 if C_Container.GetContainerNumFreeSlots then return select(2,C_Container.GetContainerNumFreeSlots(entry.bag))end
end
local function FitsCursor(entry,itemID)
 local family=EmptyFamily(entry);if family==0 then return true end
 local get=C_Item and C_Item.GetItemFamily or GetItemFamily
 local itemFamily=get and itemID and get(itemID)
 return type(family)=='number'and type(itemFamily)=='number'and bit and bit.band and bit.band(family,itemFamily)~=0 or false
end
local function HideExisting(s)
 local c=s.ctx
 for _,r in ipairs({c.frame:GetRegions()})do
  if r:GetObjectType()=='Texture'then s.hidden[r]=r:IsShown();r:Hide()end
 end
 for _,b in ipairs(c.frame.kaDesignButtons or{})do b:Hide()end
 c.shelfToggle:Hide();c.keyButton:Hide();c.footer:Hide()
 for _,h in pairs(c.holders)do h:SetParent(s.child);h:SetFrameLevel(s.child:GetFrameLevel()+1);h:ClearAllPoints();h:SetAllPoints(s.child)end
 s.activation=s.activation+1
end
function O.Release()
 local s=state;if not s or not s.active then return end
 O.StopResize();s.active=false;s.reordering=false;s.drag=nil;s.itemOrigin=nil;s.layoutCursorSignature=nil;local c=s.ctx;s.surface:Hide();c.settings:SetScript('OnClick',s.originalSettingsClick)
 for _,pools in ipairs({s.recentButtons or{},s.footerButtons or{}})do for _,pool in pairs(pools)do for _,b in pairs(pool)do b:Hide();if b.kaOrganizedEmptyMark then b.kaOrganizedEmptyMark:Hide();for _,edge in ipairs(b.kaOrganizedEmptyEdges)do edge:Hide()end end end end end
 for r,shown in pairs(s.hidden)do r:SetShown(shown)end;s.hidden={}
 for _,h in pairs(c.holders)do h:SetParent(c.body);h:SetFrameLevel(c.body:GetFrameLevel()+1);h:ClearAllPoints();h:SetAllPoints(c.body)end
 for _,group in pairs(c.buttons)do for _,b in pairs(group)do
  b:SetFrameLevel(b:GetParent():GetFrameLevel()+1);b.kaX=nil;b.kaY=nil;b.kaOrganizedPoint=nil;if b.kaOrganizedOverlay then b.kaOrganizedOverlay:Hide()end
  if b.kaOrganizedStar then b.kaOrganizedStar:Hide()end
  if b.kaOrganizedEmptyMark then b.kaOrganizedEmptyMark:Hide();for _,edge in ipairs(b.kaOrganizedEmptyEdges)do edge:Hide()end end
  if not b.kaHasItem then local normal=b.GetNormalTexture and b:GetNormalTexture();if normal then normal:SetAlpha(b.kaOriginalItemNormalAlpha or 1)end end
 end end
 c.search:SetFrameLevel(c.searchLevel);c.sort:SetFrameLevel(c.sortLevel);c.records:SetFrameLevel(c.recordsLevel)
 if s.searchBG then s.searchBG:Hide()end
 c.search:SetTextInsets(27,27,0,0);c.searchHint:ClearAllPoints();c.searchHint:SetPoint('LEFT',27,0)
 c.settings.icon:Show();c.settings:SetText('');if c.settings.kaOrganizedGlyph then c.settings.kaOrganizedGlyph:Hide()end;if c.records.kaOrganizedGlyph then c.records.kaOrganizedGlyph:Hide()end;K.InventoryLabel(c.records,'Recorded items')
 c.moneyText:Show();c.moneyHit:SetFrameLevel(c.frame:GetFrameLevel()+1)
 c.records.kaOrganizedPlace=nil;c.sort.kaOrganizedPlace=nil;c.settings.kaOrganizedPlace=nil
 for _,line in ipairs(c.clear.kaLines or{})do line:Hide()end
 for _,b in ipairs({c.records,c.sort,c.settings,c.clear})do local old=b.kaOrganizedOldBackdrop
  if old then b:SetBackdrop(old.layout);if old.layout then b:SetBackdropColor(unpack(old.color));b:SetBackdropBorderColor(unpack(old.border))end;b.kaOrganizedOldBackdrop=nil end
 end
 for _,b in ipairs(c.frame.kaDesignButtons or{})do b:Show()end
 c.footer:Show();c.shelfToggle:Show();c.frame.kaGeometryKey=nil
end
local function ItemButton(s,entry,parent,x,y,size)
 local c=s.ctx;local bag,slot=entry.bag,entry.slot;local holder=c.holders[bag]
 local duplicate=entry.recent==true or entry.footer==true
 s.recentButtons=s.recentButtons or{};s.recentHolders=s.recentHolders or{}
 local pool=c.buttons[bag]
 if duplicate then
  local holders,pools,base,prefix=s.recentHolders,s.recentButtons,s.child,'KAOrganizedRecentBag'
  if entry.footer then s.footerHolders=s.footerHolders or{};s.footerButtons=s.footerButtons or{};holders,pools,base,prefix=s.footerHolders,s.footerButtons,s.surface,'KAOrganizedDropBag'end
  if not holders[bag]then local h=CreateFrame('Frame',prefix..bag,base);h:SetID(bag);h:SetAllPoints(base);h:SetFrameLevel(base:GetFrameLevel()+4);holders[bag]=h;pools[bag]={}end
  holder=holders[bag];holder.size=c.holders[bag].size;pool=pools[bag]
 end
 local b=pool[slot]
 if not b then b=CreateFrame('ItemButton',holder:GetName()..'Item'..slot,holder,'ContainerFrameItemButtonTemplate');b:SetID(slot);pool[slot]=b end
 local scale=size/37
 b:SetFrameLevel(holder:GetFrameLevel()+1)
 if b.kaScale~=scale then b:SetSize(37,37);b:SetScale(scale);b.kaScale=scale end
 local key=tostring(parent)..':'..x..':'..y..':'..size..':'..s.activation
 if b.kaOrganizedPoint~=key then b:ClearAllPoints();b:SetPoint('TOPLEFT',parent,'TOPLEFT',x/scale,-y/scale);b.kaOrganizedPoint=key;b.kaX=nil;b.kaY=nil end
 b.kaOrganizedGroup=entry.displayGroup
 if not b.kaOrganizedOriginHook then
  b.kaOrganizedOriginHook=true
  local function Origin(self)
   if not state or not state.active or not self.kaHasItem then return end
   state.itemOrigin={id=self.kaRecordedItemID,group=self.kaOrganizedGroup,time=GetTime()}
  end
  -- Observe the source without replacing the native use, split or drag scripts.
  b:HookScript('OnMouseDown',Origin);b:HookScript('OnDragStart',Origin)
 end
 c.paint(b,bag,slot,entry.info,true)
 if not b.kaOrganizedStar then b.kaOrganizedStar=Label(b,13);b.kaOrganizedStar:SetPoint('TOPLEFT',0,1);b.kaOrganizedStar:SetText('*');b.kaOrganizedStar:SetTextColor(.95,.81,.40)end
 b.kaOrganizedStar:SetShown(entry.pinned==true)
 if not b.kaOrganizedOverlay then
  local overlay=Button(b,'',function(self)
   local e=self.entry;if not e or not e.key then return end
   if GetCursorInfo and GetCursorInfo()then return end
   local d=Config();d.pins[e.key]=not d.pins[e.key]or nil;Refresh()
  end)
  overlay:SetAllPoints();overlay:SetFrameLevel(b:GetFrameLevel()+12);overlay:SetBackdropColor(.05,.07,.05,.65)
  overlay:SetScript('OnEnter',function()local fn=b:GetScript('OnEnter');if fn then fn(b)end end)
  overlay:SetScript('OnLeave',function()local fn=b:GetScript('OnLeave');if fn then fn(b)end end)
  b.kaOrganizedOverlay=overlay
 end
 if not b.kaOrganizedEmptyMark then
  b.kaOrganizedEmptyMark=Label(b,18);b.kaOrganizedEmptyMark:SetPoint('CENTER');b.kaOrganizedEmptyMark:SetText('+');b.kaOrganizedEmptyMark:SetTextColor(.58,.56,.49,1)
  b.kaOrganizedEmptyEdges={}
  for i=1,4 do local t=b:CreateTexture(nil,'BORDER');t:SetColorTexture(.36,.34,.28,.8)
   if i<3 then t:SetHeight(1);t:SetPoint(i==1 and'TOPLEFT'or'BOTTOMLEFT');t:SetPoint(i==1 and'TOPRIGHT'or'BOTTOMRIGHT')
   else t:SetWidth(1);t:SetPoint(i==3 and'TOPLEFT'or'TOPRIGHT');t:SetPoint(i==3 and'BOTTOMLEFT'or'BOTTOMRIGHT')end
   b.kaOrganizedEmptyEdges[i]=t
  end
 end
 local empty=entry.info==nil;b.kaOrganizedEmptyMark:SetShown(empty)
 for _,edge in ipairs(b.kaOrganizedEmptyEdges)do edge:SetShown(empty)end
 if empty then local normal=b.GetNormalTexture and b:GetNormalTexture();if normal then normal:SetAlpha(0)end end
 b.kaOrganizedDropTarget=empty
 if not b.kaOrganizedDropHook then
  b.kaOrganizedDropHook=true
  b:HookScript('OnEnter',function(self)
   if state and state.active and self.kaOrganizedDropTarget then
    GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(Text(16));GameTooltip:AddLine(DropHelp(),.86,.85,.79,true);K.InventoryTooltip(GameTooltip);GameTooltip:Show()
   end
  end)
  b:HookScript('OnLeave',function(self)if self.kaOrganizedDropTarget then HideTip(self)end end)
 end
 b.kaOrganizedOverlay.entry=entry;b.kaOrganizedOverlay.label:SetText(entry.pinned and'*'or'+');b.kaOrganizedOverlay:SetShown(s.editing and entry.info~=nil)
 b.kaRecentEntry=entry.recent and entry or nil
 if duplicate and not b.kaRecentTipHook then b.kaRecentTipHook=true;b:HookScript('OnEnter',function(self)
  local e=self.kaRecentEntry;if e and state.active and GameTooltip:GetOwner()==self then
   GameTooltip:AddLine(W(6),.8,.8,.75,true);GameTooltip:AddDoubleLine(TOTAL or'Total',tostring(e.total),.8,.8,.75,1,1,1);GameTooltip:Show()
  end
 end)end
 b.kaOrganizedVisible=true;if not b:IsShown()then b:Show()end;return b
end
local function Header(s,id,parent,x,y,w,label,count)
 local b=s.headers[id]
 if not b then
  b=Button(parent,'',function()if not s.reordering and not s.drag then local d=Config();d.collapsed[id]=not d.collapsed[id];Refresh()end end);s.headers[id]=b
  b:RegisterForDrag('LeftButton')
  b:SetScript('OnDragStart',function()if s.reordering and not Combat()then s.drag=id;s.dropTarget=nil end end)
  b:SetScript('OnDragStop',function()
   local target=s.dropTarget
   if MouseIsOver then for key,h in pairs(s.headers)do if h:IsShown()and MouseIsOver(h)then target=key;break end end end
   if s.drag and target then O.MoveCategory(s.drag,target)end;s.drag=nil;s.dropTarget=nil;Refresh()
  end)
 end
 b.kaContentY=y;b.kaCategory=id;b.kaCombatAllowed=true;b:SetParent(parent);Place(b,parent,x,y,w,20);b:SetBackdropColor(0,0,0,0);b:SetBackdropBorderColor(0,0,0,0)
 b.label:ClearAllPoints();b.label:SetPoint('LEFT',18,0);b.label:SetPoint('RIGHT',-40,0);b.label:SetJustifyH('LEFT');b.label:SetText((s.reordering and ':: 'or'')..label)
 b.label:SetTextColor(id=='pins'and .83 or .68,id=='pins'and .77 or .72,id=='pins'and .58 or .64,1)
 if not b.count then b.count=Label(b,10);b.count:SetPoint('RIGHT',-3,0);b.count:SetTextColor(.50,.55,.47,1)end;b.count:SetText(tostring(count))
 Asset(b,Config().collapsed[id]and'Up'or'Down',12,'LEFT',1,0,Config().collapsed[id]and -math.pi/2 or 0)
 b:SetScript('OnEnter',function(self)self.label:SetTextColor(.91,.84,.66,1);if s.drag then s.dropTarget=id;self:SetBackdropBorderColor(.83,.77,.58,1)elseif id=='recent'then GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(W(1));GameTooltip:AddLine(W(6),.8,.8,.75,true);GameTooltip:Show()end end)
 b:SetScript('OnLeave',function(self)HideTip(self);self:SetBackdropBorderColor(0,0,0,0);self.label:SetTextColor(id=='pins'and .83 or .68,id=='pins'and .77 or .72,id=='pins'and .58 or .64,1)end)
 if not b.line then b.line=b:CreateTexture(nil,'BACKGROUND');b.line:SetColorTexture(.26,.25,.22,1);b.line:SetPoint('BOTTOMLEFT',0,0);b.line:SetPoint('BOTTOMRIGHT',0,0);b.line:SetHeight(1)end
 return b
end
function O.Render(c)
 local d=Config();local s=Ensure(c);s.ctx=c
 if not s.active then HideExisting(s);s.active=true end
 if Combat()then O.StopResize();s.editing=false;s.reordering=false;s.drag=nil;s.tools:Hide()end
 local f=c.frame
 K.InventoryPresentation.Window(f,'bag',true)
 local fontLevel=K.InventoryPresentation.Level('bag')
 -- First-use defaults from Dikkatzühtü's approved 400x380 view.
 -- Existing explicit sizes are never overwritten, including older test versions.
 local width=Clamp(d.width,400,1000,400);local height=Clamp(d.height,380,800,380)
 if not s.sizing then f:SetSize(width,height)end
 local size=Clamp(c.option('bagSize',30),18,48,30);local cell=size+4
 s.surface:Show()
 local style=K.ClassicInventoryStyle.BackgroundStyle();local background=c.option('bagBackground',true)~=false
 local bgKey=style..':'..tostring(background)
 if s.backgroundKey~=bgKey then
  Backdrop(s.surface,.055,.055,.05,background and .98 or 0)
  K.ClassicInventoryStyle.PaintBackgroundPanel(s.surface,background);s.backgroundKey=bgKey
 end
 s.shade:SetShown(background)
 s.brand:SetText(K.ForeverInventoryAdapter.PlayerDisplayName());s.brand:SetWidth(math.max(80,width-166));s.brand:SetJustifyH('LEFT');s.sub:Hide()
 Segments(s.close,'close');Segments(s.smaller,'minus');Segments(s.larger,'plus');Segments(s.grip,'resize')
 s.close.kaTip=TipText(5);s.smaller.kaTip=K.InventoryPresentation.Tip(1);s.larger.kaTip=K.InventoryPresentation.Tip(2);s.grip.kaTip=TipText(4)
 s.filterToggle.kaTip=TipText(6);s.capacity.kaTip=Text(16)
 
 s.grip:SetBackdropColor(.115,.115,.11,1);s.grip:SetBackdropBorderColor(.43,.39,.31,1)
 
 Place(s.close,s.top,width-30,5,22,22)
 Place(s.smaller,s.top,width-111,5,22,22);Place(s.larger,s.top,width-84,5,22,22)
 if s.smaller.SetEnabled then s.smaller:SetEnabled(not Combat()and fontLevel>0);s.larger:SetEnabled(not Combat()and fontLevel<3)end
 Place(c.settings,s.top,width-57,5,22,22);SkinPlain(c.settings);c.settings.icon:Hide();c.settings:SetText('');Asset(c.settings,'Settings',15)
 c.settings:SetFrameLevel(s.top:GetFrameLevel()+2)
 c.settings:SetScript('OnClick',function()if not Combat()then s.tools:SetShown(not s.tools:IsShown())end end)
 local toolsShown=s.tools:IsShown();Place(s.tools,s.surface,math.max(0,width-248),34,242,6*27+12)
 local toolLabels={Text(23),s.reordering and Text(14)or W(2),W(4),W(5)..': 6',W(5)..': 12',W(5)..': 24'}
 for i,b in ipairs(s.toolButtons)do Place(b,s.tools,6,6+(i-1)*27,230,26);b:SetFrameLevel(s.tools:GetFrameLevel()+1);b.label:SetText(toolLabels[i])end
 s.tools:SetShown(toolsShown)
 for _,b in ipairs(c.frame.kaResizeButtons or{})do b:Hide()end
 c.search:SetFrameLevel(s.surface:GetFrameLevel()+3);c.sort:SetFrameLevel(s.surface:GetFrameLevel()+3);c.records:SetFrameLevel(s.surface:GetFrameLevel()+3)
 local editWidth=62+fontLevel*5;local filterWidth=124+fontLevel*7;local sortWidth=76+fontLevel*3
 if fontLevel>0 then editWidth=math.min(editWidth,math.floor(width*.18));filterWidth=math.min(filterWidth,math.floor(width*.28));sortWidth=math.min(sortWidth,math.floor(width*.20))end
 local toolsY=40
 c.search:ClearAllPoints();c.search:SetPoint('TOPLEFT',f,'TOPLEFT',14,-40);c.search:SetSize(width-28-editWidth-filterWidth-sortWidth-18,28)
 if not s.searchBG then s.searchBG=CreateFrame('Frame',nil,c.search,'BackdropTemplate');s.searchBG:SetAllPoints();s.searchBG:SetFrameLevel(c.search:GetFrameLevel()-1);Backdrop(s.searchBG,.012,.012,.009)end
 c.search:SetTextInsets(8,24,0,0);c.searchHint:ClearAllPoints();c.searchHint:SetPoint('LEFT',8,0)
 if c.search.kaSearchGlyph then c.search.kaSearchGlyph:Hide()end
 s.searchBG:Show();c.searchHint:SetWidth(math.max(1,c.search:GetWidth()-45))
 c.clear:ClearAllPoints();c.clear:SetPoint('RIGHT',c.search,'RIGHT',-2,0);c.clear:SetSize(20,20);SkinPlain(c.clear);c.clear:SetFrameLevel(c.search:GetFrameLevel()+2);Segments(c.clear,'close');c.clear:Show()
 Place(s.edit,s.surface,width-14-sortWidth-6-editWidth,toolsY,editWidth,28);s.edit.label:SetText(Text((s.editing or s.reordering)and 14 or 13))
 Place(c.sort,s.surface,width-14-sortWidth,toolsY,sortWidth,28);SkinPlain(c.sort)
 local total,free=0,0;local groups={pins={},empty={},recent={}};local counts={all=0,pins=0,recent=0};for _,id in ipairs(categories)do groups[id]={};counts[id]=0 end
 local filterBag=c.getFilter();local occupied=0;local representatives,totals={},{}
 local generalFree,generalSlots,specialFree,specialSlots,unknownFree=0,0,0,0,0;local bagSpaces={}
 for bag=0,K.ForeverInventoryAdapter.LastBag()do
  local n=c.slots(bag);c.holders[bag].size=n;total=total+n
  local freeBag=0
  for slot=1,n do
   local info=C_Container.GetContainerItemInfo(bag,slot)
   if not info then free=free+1;freeBag=freeBag+1 else occupied=occupied+1 end
   local category=O.Category(bag,slot,info);local key=O.PinKey(info);local pinned=key and d.pins[key]==true or false
   local e={bag=bag,slot=slot,info=info,key=key,pinned=pinned,category=category}
   if info then totals[info.itemID]=(totals[info.itemID]or 0)+(info.stackCount or 1);local previous=representatives[info.itemID];if not previous or previous.info.isLocked and not info.isLocked or not info.isLocked and(info.stackCount or 1)>(previous.info.stackCount or 1)then representatives[info.itemID]=e end;counts.all=counts.all+1;counts[category]=counts[category]+1;if pinned then counts.pins=counts.pins+1 end end
   if(filterBag==nil or filterBag==bag)and(not info or c.matches(info))then
    if not info then groups.empty[#groups.empty+1]=e
    elseif s.filter=='all'or s.filter==category or s.filter=='pins'and pinned then
     local list=pinned and groups.pins or groups[category];list[#list+1]=e
    end
   end
  end
  local family=O.SpaceFamily(bag)
  bagSpaces[#bagSpaces+1]={bag=bag,free=freeBag,slots=n,family=family}
  if family==0 then generalFree=generalFree+freeBag;generalSlots=generalSlots+n
  elseif type(family)=='number'or family=='reagent'then specialFree=specialFree+freeBag;specialSlots=specialSlots+n
  else unknownFree=unknownFree+freeBag end
  local b=c.bagButtons[bag];local inv=bag>0 and C_Container.ContainerIDToInventoryID(bag)
  b.icon:SetTexture(bag==0 and'Interface\\Buttons\\Button-Backpack-Up'or(inv and GetInventoryItemTexture('player',inv))or'Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag')
  b:SetBackdropBorderColor(.70,.65,.45,filterBag==bag and 1 or .3)
 end
 for _,id in ipairs(d.recent)do local e=representatives[id];if e then
  counts.recent=counts.recent+1
  if(s.filter=='all'or s.filter=='recent')and(filterBag==nil or filterBag==e.bag)and c.matches(e.info)then groups.recent[#groups.recent+1]={bag=e.bag,slot=e.slot,info=e.info,key=e.key,pinned=e.pinned,category=e.category,recent=true,total=totals[id]}end
 end end
 for _,pool in pairs(s.recentButtons or{})do for _,b in pairs(pool)do b.kaOrganizedVisible=false end end
 K.ClassicBags.ShortcutCounts(c.bagButtons,free)
 -- Preserve the visible heading when a cursor transition changes the flow.
 local held,cursorID,cursorSignature=CursorItem();s.cursorItem=held
 local oldOffset=s.scroll:GetVerticalScroll();local anchor,anchorY,distance
 if s.layoutCursorSignature~=cursorSignature then
  local origin=s.itemOrigin;local h=origin and s.headers[origin.group]
  if h and h:IsShown()and h.kaContentY and h.kaContentY+20>=oldOffset and h.kaContentY<oldOffset+s.scroll:GetHeight()and GetTime()-origin.time<120 then anchor,anchorY,distance=origin.group,h.kaContentY,-1 end
  for id,h in pairs(s.headers)do
   local hy=h.kaContentY
   if id~='empty'and h:IsShown()and hy then
    local delta=math.abs(hy-oldOffset)
    if not distance or delta<distance then anchor,anchorY,distance=id,hy,delta end
   end
  end
 end
 s.layoutCursorSignature=cursorSignature
 for _,pool in pairs(s.footerButtons or{})do for _,b in pairs(pool)do b.kaOrganizedVisible=false end end
 -- Keep existing visible native buttons alive; avoid OnHide/OnShow churn per refresh.
 for _,group in pairs(c.buttons)do for _,b in pairs(group)do b.kaOrganizedVisible=false end end
 for _,h in pairs(s.headers)do h:Hide()end
 local y=74
 local filterIds={'all','pins','recent'};for _,id in ipairs(categories)do
  if(id~='ammo'and id~='soul')or counts[id]>0 or s.filter==id then filterIds[#filterIds+1]=id else s.filters[id]:Hide()end
 end
 local filterX=width-14-sortWidth-6-editWidth-6-filterWidth
 Place(s.filterToggle,s.surface,filterX,toolsY,filterWidth,28)
 s.filterToggle.label:SetText((s.filter=='recent'and W(1)or Text(labelIndex[s.filter])));TabFont(s.filterToggle.label);Asset(s.filterToggle,'Down',12,'RIGHT',-6,0)
 s.filterToggle.label:ClearAllPoints();s.filterToggle.label:SetPoint('LEFT',6,0);s.filterToggle.label:SetPoint('RIGHT',-21,0)
 Place(s.filterPanel,s.surface,filterX,toolsY+32,228,#filterIds*25+12);s.filterPanel:SetShown(s.filterOpen)
 for i,id in ipairs(filterIds)do
  local b=s.filters[id];b:SetParent(s.filterPanel);b:SetFrameLevel(s.filterPanel:GetFrameLevel()+1)
  b.label:SetText((id=='recent'and W(1)or Text(labelIndex[id]))..' '..counts[id]);TabFont(b.label);b.label:SetJustifyH('LEFT')
  local chosen=s.filter==id
  b:SetBackdropColor(chosen and .20 or .085,chosen and .19 or .085,chosen and .16 or .08,1)
  b:SetBackdropBorderColor(0,0,0,0);b.label:SetTextColor(chosen and .95 or .72,chosen and .87 or .72,chosen and .63 or .67,1)
  Place(b,s.filterPanel,6,6+(i-1)*25,216,24);b:SetShown(s.filterOpen)
 end
 local threshold=math.max(4,math.ceil(generalSlots*.10))
 local lowSpace=unknownFree==0 and generalFree<=threshold
 s.spaceColour=unknownFree>0 and{.64,.68,.62,1}or generalFree==0 and{.95,.35,.30,1}or lowSpace and{.95,.65,.25,1}or{.64,.68,.62,1}
 s.capacityColour=s.spaceColour
 local matched=s.filter=='recent'and #groups.recent or #groups.pins;for _,id in ipairs(categories)do matched=matched+#groups[id]end
 Place(s.note,s.surface,14,y,width-28,16);s.note:SetText(s.reordering and W(3)or s.editing and Text(20)or((s.filter=='recent'and W(1)or Text(labelIndex[s.filter]))..'  |  '..matched..' / '..occupied..(filterBag~=nil and'  |  '..K.InventoryText('Backpack')..' '..filterBag or'')));y=y+19
 if not s.spaceStatus then s.spaceStatus=Label(s.surface,10);s.spaceStatus:SetJustifyH('RIGHT')end
 s.spaceStatus:Hide()
 if lowSpace then
  local message=Cap(1)..': '..(generalFree==0 and Cap(3)or generalFree..' '..Text(15))
  Place(s.spaceStatus,s.surface,width-160,y-19,146,16);s.spaceStatus:SetText(message);s.spaceStatus:SetTextColor(unpack(s.spaceColour));s.note:SetWidth(math.max(1,width-185))
 end
 local shelfH=s.shelf and 61 or 0;local footerHeight=fontLevel>0 and 71 or 47;local bottom=footerHeight+shelfH
 local columns=math.max(1,math.floor((width-40+4)/cell))
 -- Pinned groups share the clipped scroll surface; each native slot is drawn once.
 local listY=0;local childWidth=width-34
 s.scroll:ClearAllPoints();s.scroll:SetPoint('TOPLEFT',s.surface,'TOPLEFT',14,-y);s.scroll:SetSize(childWidth,math.max(50,height-y-bottom));s.child:SetWidth(childWidth)
 local assigned={}
 local function CategoryEmpty()
  for _,entry in ipairs(groups.empty)do
   local key=entry.bag..':'..entry.slot
   if not assigned[key]and FitsCursor(entry,cursorID)then assigned[key]=true;return entry end
  end
 end
 local preferred,preferredDrop
 if s.cursorItem and not s.editing then
  local origin=s.itemOrigin
  if origin and(origin.id==cursorID or cursorID==nil)and GetTime()-origin.time<120 and groups[origin.group]and #groups[origin.group]>0 and not d.collapsed[origin.group]then preferred=origin.group end
  if not preferred then
   -- No known source (vendor/mail/other window): favour a visible matching
   -- section; the fixed footer target remains available even without one.
   for _,id in ipairs(O.Order())do local h=s.headers[id]
    if h and h.kaContentY and h.kaContentY+20>=oldOffset and h.kaContentY<oldOffset+s.scroll:GetHeight()and not d.collapsed[id]then
     for _,e in ipairs(groups[id]or{})do if e.info.itemID==cursorID then preferred=id;break end end
    end
    if preferred then break end
   end
  end
  if preferred then preferredDrop=CategoryEmpty()end
 end
 local flowX,flowY,rowHeight=0,0,0
 local function DrawGroup(id,label,list)
  if #list==0 then return end
  local itemCount=#list;local extra
  if id~='empty'and s.cursorItem and not s.editing and not d.collapsed[id]then extra=id==preferred and preferredDrop or nil end
  local displayCount=itemCount+(extra and 1 or 0)
  local header=Header(s,id,s.child,0,0,childWidth-6,label,#list)
  local minimum=math.ceil((header.label:GetStringWidth()+48)/cell)
  local groupCols=math.min(columns,math.max(3,minimum,math.min(displayCount,columns)))
  local groupWidth=math.min(childWidth-6,groupCols*cell-4)
  if flowX>0 and flowX+groupWidth>childWidth-6 then flowX=0;flowY=flowY+rowHeight+8;rowHeight=0 end
  Header(s,id,s.child,flowX,flowY,groupWidth,label,#list)
  local groupHeight=20
  if not d.collapsed[id]or id=='empty'and s.cursorItem then
   for i,e in ipairs(list)do e.displayGroup=id;ItemButton(s,e,s.child,flowX+((i-1)%groupCols)*cell,flowY+24+math.floor((i-1)/groupCols)*cell,size)end
   if extra then extra.displayGroup=id;local i=itemCount;ItemButton(s,extra,s.child,flowX+(i%groupCols)*cell,flowY+24+math.floor(i/groupCols)*cell,size)end
   groupHeight=24+math.ceil(displayCount/groupCols)*cell
  end
  rowHeight=math.max(rowHeight,groupHeight);flowX=flowX+groupWidth+12;listY=flowY+rowHeight
 end
 for _,id in ipairs(O.Order())do
  if s.filter~='recent'or id=='recent'then DrawGroup(id,id=='recent'and W(1)or id=='pins'and Text(2)or Text(labelIndex[id]),groups[id])end
 end
 local remaining={}
 for _,entry in ipairs(groups.empty)do
  if not assigned[entry.bag..':'..entry.slot]and(not s.cursorItem or FitsCursor(entry,cursorID))then remaining[#remaining+1]=entry end
 end
 local showEmpty=s.empty or matched==0
 -- A fixed footer destination replaces automatic navigation to an empty grid.
 local showNone=matched==0 and not(showEmpty and #remaining>0)
 s.none:SetShown(showNone);if showNone then Place(s.none,s.child,0,8,childWidth-10,24);s.none:SetText(Text(17));listY=46;flowY=46;flowX=0;rowHeight=0 end
 if showEmpty then DrawGroup('empty',Text(16),remaining)end
 for _,group in pairs(c.buttons)do for _,b in pairs(group)do if not b.kaOrganizedVisible and b:IsShown()then b:Hide()end end end
 for _,pool in pairs(s.recentButtons or{})do for _,b in pairs(pool)do if not b.kaOrganizedVisible and b:IsShown()then b:Hide()end end end
 s.child:SetHeight(math.max(listY,s.scroll:GetHeight()));s.maxScroll=math.max(0,s.child:GetHeight()-s.scroll:GetHeight());local offset=oldOffset
 if anchor and s.headers[anchor]and s.headers[anchor]:IsShown()then offset=oldOffset+s.headers[anchor].kaContentY-anchorY end
 s.scroll:SetVerticalScroll(Clamp(offset,0,s.maxScroll,0))
 Place(s.track,s.surface,width-8,y,3,s.scroll:GetHeight());s.track:SetShown(s.maxScroll>0)
 local h=s.scroll:GetHeight();local thumb=math.max(18,h*h/math.max(h,s.child:GetHeight()));s.thumb:ClearAllPoints();s.thumb:SetPoint('TOPLEFT',0,-(s.maxScroll>0 and s.scroll:GetVerticalScroll()/s.maxScroll*(h-thumb)or 0));s.thumb:SetSize(3,thumb)
 if s.shelf then
  Place(s.shelfPanel,s.surface,1,height-footerHeight-shelfH,width-2,shelfH);s.shelfTitle:SetText(Text(12))
  local hasKey=KeyRingButton~=nil and(KEYRING_CONTAINER~=nil or Enum and Enum.BagIndex and Enum.BagIndex.Keyring~=nil)
  local last=K.ForeverInventoryAdapter.LastBag();local bw,start,keyIndex=O.ShelfLayout(width,last,hasKey)
  for bag=0,last do c.bagButtons[bag]:SetFrameLevel(s.shelfPanel:GetFrameLevel()+2);Place(c.bagButtons[bag],f,start+bag*(bw+7),height-47-shelfH+20,bw,bw)end
  if hasKey then c.keyButton:SetFrameLevel(s.shelfPanel:GetFrameLevel()+2);Place(c.keyButton,f,start+keyIndex*(bw+7),height-47-shelfH+20,bw,bw)else c.keyButton:Hide()end
 else s.shelfPanel:Hide();for _,b in pairs(c.bagButtons)do b:Hide()end;c.keyButton:Hide()end
 local footY=height-36
 Place(c.records,s.surface,10,footY,28,26);SkinPlain(c.records);c.records:SetText('');Asset(c.records,'Book',17);c.records:Show()
 Place(s.shelfButton,s.surface,44,footY,math.min(100+fontLevel*8,width*.33),26);s.shelfButton.label:SetText(Text(12));s.shelfButton.label:ClearAllPoints();s.shelfButton.label:SetPoint('LEFT',5,0);s.shelfButton.label:SetPoint('RIGHT',-19,0);Asset(s.shelfButton,s.shelf and'Up'or'Down',13,'RIGHT',-4,0)
 local moneyWidth=90+fontLevel*8
 Place(s.capacity,s.surface,fontLevel>0 and 14 or 155,fontLevel>0 and footY-28 or footY,fontLevel>0 and width-28 or width-155-moneyWidth-28,fontLevel>0 and 28 or 26);local capacity=Cap(1)..': '..(generalFree==0 and Cap(3)or generalFree..' '..Text(15))
 if specialSlots>0 then capacity=capacity..'\n'..Cap(2)..': '..specialFree..' '..Text(15)end
 if unknownFree>0 then capacity=free..' '..Text(15)..'\n'..Cap(6)end
 s.capacity.label:SetText(capacity);s.capacityWarning=generalFree==0 and unknownFree==0
 s.capacity.label:SetTextColor(unpack(s.spaceColour));s.capacity:SetBackdropColor(0,0,0,0);s.capacity:SetBackdropBorderColor(0,0,0,0);s.capacity:SetScript('OnEnter',function(self)self.label:SetTextColor(.91,.84,.66,1);O.CapacityTooltip(self,bagSpaces)
 end);s.capacity:SetScript('OnLeave',function(self)self.label:SetTextColor(unpack(s.capacityColour or s.spaceColour));GameTooltip:Hide()end)
 -- A separate native button for the SAME real free slot stays reachable in
 -- the footer. No synthetic inventory, API retries or custom item clicks.
 if not s.dropLabel then s.dropLabel=Label(s.surface,10);s.dropLabel:SetTextColor(.83,.77,.58)end
 s.dropLabel:Hide()
 if s.cursorItem and not s.editing then
  local destination
  for _,e in ipairs(groups.empty)do if FitsCursor(e,cursorID)then destination=e;break end end
  if destination then
   s.capacity:Hide()
   local e={bag=destination.bag,slot=destination.slot,footer=true}
   ItemButton(s,e,s.surface,155,footY+1,24)
   Place(s.dropLabel,s.surface,185,footY+4,math.max(1,width-185-moneyWidth-28),20);s.dropLabel:SetText(Text(16));s.dropLabel:SetJustifyH('LEFT')
  else
   s.capacity.label:SetText(Cap(filterBag~=nil and 7 or 5));s.capacityWarning=true;s.capacityColour={.95,.35,.30,1};s.capacity.label:SetTextColor(unpack(s.capacityColour))
  end
 end
 for _,pool in pairs(s.footerButtons or{})do for _,b in pairs(pool)do if not b.kaOrganizedVisible and b:IsShown()then b:Hide()end end end
 c.footer:Hide();c.moneyText:Hide();s.money:ClearAllPoints();s.money:SetPoint('BOTTOMRIGHT',s.surface,'BOTTOMRIGHT',-25,15);s.money:SetWidth(moneyWidth);s.money:SetText(c.money())
 c.moneyHit:SetFrameLevel(s.surface:GetFrameLevel()+3)
 c.moneyHit:ClearAllPoints();c.moneyHit:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-23,8);c.moneyHit:SetSize(moneyWidth,28)
 Place(s.grip,s.surface,width-22,height-24,18,18)
 c.searchHint:SetShown(c.search:GetText()=='');c.sortLabel();c.dockKeyring()
 return true
end
function O.MoneyChanged()
 if state and state.active then state.money:SetText(state.ctx.money())end
end

function O.ChangeWidth(direction)
 if Combat()or not state or not state.active or(direction~=-1 and direction~=1)then return false end
 O.StopResize();local d=Config();local size=Clamp(state.ctx.option('bagSize',30),18,48,30)
 d.width=Clamp(state.ctx.frame:GetWidth()+direction*(size+4),400,1000,400);Refresh();return true
end
function O.SetEnabled(value)
 if Combat()or type(value)~='boolean'or not K.db then return false end
 local d=Config();d.enabled=value
 if state then state.filter='all';state.ctx.setFilter(nil)end
 Refresh();return true
end
function O.DrawSettings(page,w,y)
 local b=w.Button(page,Text(1),0,y,714,32,function()if O.SetEnabled(not O.Active())and K.Render then K.Render()end end)
 w.Selected(b,O.Active());if Combat()then b:Disable()end
 return y-44
end

local recentEvents=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','BAG_UPDATE_DELAYED','PLAYER_LOGOUT','BAG_UPDATE_COOLDOWN'})do K.ForeverInventoryAdapter.RegisterEvent(recentEvents,event)end
recentEvents:SetScript('OnEvent',function(_,event)
 if event=='BAG_UPDATE_COOLDOWN'then
  if state and state.active then for bag,pool in pairs(state.recentButtons or{})do for slot,b in pairs(pool)do if b:IsShown()then state.ctx.paint(b,bag,slot,C_Container.GetContainerItemInfo(bag,slot),true)end end end end;return
 end
 if event=='PLAYER_LOGIN'then baseline=nil;O.ObserveRecent();return end
 if event=='PLAYER_LOGOUT'then O.ObserveRecent();return end
 if recentQueued then return end;recentQueued=true
 C_Timer.After(.35,function()recentQueued=false;O.ObserveRecent();Refresh()end)
end)
