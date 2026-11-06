-- On-demand plain-text snapshots. Never hooks AddMessage or changes native chat state.
if select(2,...).blocked then return end
local _,N=...;local K=N.host;local C=K.Chat
local T={}
C.TextTools=T
local words={
 ["en"]={settings="Chat settings",copy="Copy this tab",search="Search this tab",title="Chat text",snapshot="Snapshot of this tab when opened. New messages are not added.",select="Select all",hint="Select text with the mouse, then press Ctrl+C.",empty="No readable messages in this tab.",limited="Only the latest retained messages are shown.",skipped="Unreadable or restricted lines skipped: %d",matches="%d / %d",close="Close",chat="Chat",searchHint="Search this snapshot…",menuHint="Settings, copy or search the selected tab."},
 ["tr"]={settings="Sohbet ayarları",copy="Bu sekmeyi kopyala",search="Bu sekmede ara",title="Sohbet metni",snapshot="Açılış anındaki sekme metni. Yeni mesajlar eklenmez.",select="Tümünü seç",hint="Metni fareyle seç, ardından Ctrl+C tuşlarına bas.",empty="Bu sekmede okunabilir mesaj yok.",limited="Yalnız saklanan son mesajlar gösteriliyor.",skipped="Okunamayan veya kısıtlı satır: %d",matches="%d / %d",close="Kapat",chat="Sohbet",searchHint="Bu metinde ara…",menuHint="Seçili sekmenin ayarları, kopyalama ve arama."},
 ["de"]={settings="Chat-Einstellungen",copy="Diesen Tab kopieren",search="Diesen Tab durchsuchen",title="Chat-Text",snapshot="Momentaufnahme dieses Tabs. Neue Nachrichten werden nicht ergänzt.",select="Alles auswählen",hint="Text mit der Maus auswählen und Strg+C drücken.",empty="Keine lesbaren Nachrichten in diesem Tab.",limited="Nur die letzten gespeicherten Nachrichten werden angezeigt.",skipped="Unlesbare oder eingeschränkte Zeilen übersprungen: %d",matches="%d / %d",close="Schließen",chat="Chat",searchHint="Diese Momentaufnahme durchsuchen…",menuHint="Einstellungen, Kopieren und Suche für den gewählten Tab."},
 ["zhCN"]={settings="聊天设置",copy="复制此标签",search="搜索此标签",title="聊天文本",snapshot="打开时的标签快照，不会添加新消息。",select="全选",hint="用鼠标选择文本，然后按 Ctrl+C。",empty="此标签中没有可读取的消息。",limited="仅显示最近保留的消息。",skipped="已跳过无法读取或受限的行：%d",matches="%d / %d",close="关闭",chat="聊天",searchHint="搜索此快照…",menuHint="所选标签的设置、复制和搜索。"},
 ["frFR"]={settings="Réglages du chat",copy="Copier cet onglet",search="Rechercher dans cet onglet",title="Texte du chat",snapshot="Instantané à l’ouverture. Les nouveaux messages ne sont pas ajoutés.",select="Tout sélectionner",hint="Sélectionnez le texte à la souris, puis appuyez sur Ctrl+C.",empty="Aucun message lisible dans cet onglet.",limited="Seuls les derniers messages conservés sont affichés.",skipped="Lignes illisibles ou restreintes ignorées : %d",matches="%d / %d",close="Fermer",chat="Chat",searchHint="Rechercher dans cet instantané…",menuHint="Réglages, copie et recherche de l’onglet sélectionné."},
 ["itIT"]={settings="Impostazioni chat",copy="Copia questa scheda",search="Cerca in questa scheda",title="Testo della chat",snapshot="Istantanea all’apertura. I nuovi messaggi non vengono aggiunti.",select="Seleziona tutto",hint="Seleziona il testo con il mouse, poi premi Ctrl+C.",empty="Nessun messaggio leggibile in questa scheda.",limited="Sono mostrati solo gli ultimi messaggi conservati.",skipped="Righe illeggibili o limitate saltate: %d",matches="%d / %d",close="Chiudi",chat="Chat",searchHint="Cerca in questa istantanea…",menuHint="Impostazioni, copia e ricerca della scheda selezionata."},
 ["esES"]={settings="Ajustes del chat",copy="Copiar esta pestaña",search="Buscar en esta pestaña",title="Texto del chat",snapshot="Instantánea al abrir. No se añaden mensajes nuevos.",select="Seleccionar todo",hint="Selecciona el texto con el ratón y pulsa Ctrl+C.",empty="No hay mensajes legibles en esta pestaña.",limited="Solo se muestran los últimos mensajes conservados.",skipped="Líneas ilegibles o restringidas omitidas: %d",matches="%d / %d",close="Cerrar",chat="Chat",searchHint="Buscar en esta instantánea…",menuHint="Ajustes, copia y búsqueda de la pestaña seleccionada."},
 ["ptBR"]={settings="Configurações do chat",copy="Copiar esta aba",search="Pesquisar nesta aba",title="Texto do chat",snapshot="Cópia no momento da abertura. Novas mensagens não são adicionadas.",select="Selecionar tudo",hint="Selecione o texto com o mouse e pressione Ctrl+C.",empty="Nenhuma mensagem legível nesta aba.",limited="Somente as últimas mensagens mantidas são exibidas.",skipped="Linhas ilegíveis ou restritas ignoradas: %d",matches="%d / %d",close="Fechar",chat="Bate-papo",searchHint="Pesquisar nesta cópia…",menuHint="Configurações, cópia e pesquisa da aba selecionada."},
 ["ruRU"]={settings="Настройки чата",copy="Копировать вкладку",search="Поиск во вкладке",title="Текст чата",snapshot="Снимок при открытии. Новые сообщения не добавляются.",select="Выделить всё",hint="Выделите текст мышью и нажмите Ctrl+C.",empty="В этой вкладке нет читаемых сообщений.",limited="Показаны только последние сохранённые сообщения.",skipped="Пропущено нечитаемых или ограниченных строк: %d",matches="%d / %d",close="Закрыть",chat="Чат",searchHint="Поиск в этом снимке…",menuHint="Настройки, копирование и поиск выбранной вкладки."},
}
local navigationWords={
 ["en"]={previous="Previous match",next="Next match",searchHelp="Arrows move between search matches.",matchLabel="Matches: "},
 ["tr"]={previous="Önceki eşleşme",next="Sonraki eşleşme",searchHelp="Oklar, arama eşleşmeleri arasında ilerler.",matchLabel="Eşleşme: "},
 ["de"]={previous="Vorheriger Treffer",next="Nächster Treffer",searchHelp="Die Pfeile wechseln zwischen Suchtreffern.",matchLabel="Treffer: "},
 ["zhCN"]={previous="上一个匹配项",next="下一个匹配项",searchHelp="箭头用于切换搜索匹配项。",matchLabel="匹配项："},
 ["frFR"]={previous="Résultat précédent",next="Résultat suivant",searchHelp="Les flèches parcourent les résultats de recherche.",matchLabel="Résultats : "},
 ["itIT"]={previous="Risultato precedente",next="Risultato successivo",searchHelp="Le frecce scorrono i risultati della ricerca.",matchLabel="Risultati: "},
 ["esES"]={previous="Coincidencia anterior",next="Coincidencia siguiente",searchHelp="Las flechas recorren las coincidencias de búsqueda.",matchLabel="Coincidencias: "},
 ["ptBR"]={previous="Resultado anterior",next="Próximo resultado",searchHelp="As setas percorrem os resultados da pesquisa.",matchLabel="Resultados: "},
 ["ruRU"]={previous="Предыдущее совпадение",next="Следующее совпадение",searchHelp="Стрелки переходят между результатами поиска.",matchLabel="Совпадения: "},
}
for lang,values in pairs(navigationWords)do for key,value in pairs(values)do words[lang][key]=value end end
local nameWords={
 ["en"]={nameUnavailable="Name unavailable",namesUnreadable="Unreadable names: %d"},
 ["tr"]={nameUnavailable="İsim okunamıyor",namesUnreadable="Okunamayan isim: %d"},
 ["de"]={nameUnavailable="Name nicht lesbar",namesUnreadable="Nicht lesbare Namen: %d"},
 ["zhCN"]={nameUnavailable="姓名不可读取",namesUnreadable="无法读取的姓名：%d"},
 ["frFR"]={nameUnavailable="Nom illisible",namesUnreadable="Noms illisibles : %d"},
 ["itIT"]={nameUnavailable="Nome non leggibile",namesUnreadable="Nomi non leggibili: %d"},
 ["esES"]={nameUnavailable="Nombre no legible",namesUnreadable="Nombres no legibles: %d"},
 ["ptBR"]={nameUnavailable="Nome não legível",namesUnreadable="Nomes não legíveis: %d"},
 ["ruRU"]={nameUnavailable="Имя недоступно",namesUnreadable="Недоступных имён: %d"},
}
for lang,values in pairs(nameWords)do for key,value in pairs(values)do words[lang][key]=value end end
local function L(key)
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or K.account and K.account.language or 'en'
 return (words[lang]or words.en)[key]or words.en[key]
end
T.L=L
local function Secret(v)return issecretvalue and issecretvalue(v)end
local function Plain(s)
 if Secret(s)or type(s)~='string'then return nil end
 -- Preserve literal pipes and opaque native name tokens. The client renders
 -- |K...|k names; stripping those tokens erases participants and tab titles.
 s=s:gsub('||','\001'):gsub('|H.-|h(.-)|h','%1')
 s=s:gsub('|T.-|t',''):gsub('|A.-|a',''):gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r',''):gsub('|n','\n')
 return s:gsub('\001','|')
end
T.Plain=Plain
local displayProbe
local function DisplayText(text)
 if not text:find('|K',1,true)then return text end
 -- A private, unfocused EditBox can supply display text only when the API
 -- permits reading it. Secret returns are never parsed, compared or stored.
 if not displayProbe then
  displayProbe=CreateFrame('EditBox',nil,UIParent)
  displayProbe:SetAutoFocus(false);displayProbe:SetMultiLine(true);displayProbe:SetFontObject(GameFontNormal);displayProbe:Hide()
 end
 if not displayProbe.GetDisplayText then return text end
 displayProbe:SetText(text)
 local ok,value=pcall(displayProbe.GetDisplayText,displayProbe)
 displayProbe:SetText('')
 if ok and not Secret(value)and type(value)=='string'and value~=''and #value<=131072 and not value:find('|K',1,true)then return Plain(value)end
 return text -- Keep native rendering; never guess identity from link/account IDs.
end
T.DisplayText=DisplayText
-- A Battle.net link carries its account ID independently of the opaque
-- rendered label. Resolve that one explicit account via the public API before
-- stripping hyperlinks; never infer identity from |K token contents.
local function PublicName(value)
 if Secret(value)or type(value)~='string'or #value>256 or not value:find('%S')then return nil end
 if value:find('|',1,true)or value:find('[%z\1-\31\127]')then return nil end
 return value
end
local function BattleNetName(id,cache)
 if cache[id]~=nil then return cache[id]or nil end
 cache[id]=false
 if not C_BattleNet or not C_BattleNet.GetAccountInfoByID then return nil end
 local ok,info=pcall(C_BattleNet.GetAccountInfoByID,id)
 if not ok or Secret(info)or type(info)~='table'then return nil end
 local returnedID=info.bnetAccountID
 if Secret(returnedID)or type(returnedID)~='number'or returnedID~=id then return nil end
 local name=PublicName(info.accountName)
 if not name then
  local tag=PublicName(info.battleTag)
  if tag then name=tag:gsub('#%d+$','');if name==''then name=nil end end
 end
 if name then cache[id]=name end
 return name
end
function T.BattleNetLinks(text,cache)
 cache=cache or {}
 -- Quoted pipes are literal text, not clickable player links.
 text=text:gsub('||','\001')
 text=text:gsub('|H(.-)|h(.-)|h',function(data,label)
  local original='|H'..data..'|h'..label..'|h'
  if not label:find('|K',1,true)then return original end
  -- Blizzard GetBNPlayerLink: BNplayer:name:accountID:lineID:chatType:target.
  local account=data:match('^BNplayer:[^:]*:(%d+):')
  local id=account and tonumber(account)
  if not id or id<=0 or id>=9007199254740992 or id~=math.floor(id)then return original end
  local name=BattleNetName(id,cache)
  if not name then return original end
  -- Replace only the label of this link, never any other person's token.
  label=label:gsub('|K.-|k',function()return name end,1)
  return '|H'..data..'|h'..label..'|h'
 end)
 return text:gsub('\001','||')
end
function T.CopyText(text)
 local cache,unreadable={},0
 local copy=Plain(T.BattleNetLinks(text)):gsub('|K.-|k',function(token)
  local name=cache[token]
  if name==nil then
   local ok,value=pcall(DisplayText,token)
   if ok and not Secret(value)and type(value)=='string'and value~=''and value~=token and #value<=256 and not value:find('[\r\n]')and not value:find('|K',1,true)then
    name=value
   else name=false end
   cache[token]=name
  end
  if name then return name end
  unreadable=unreadable+1;return L('nameUnavailable')
 end)
 local clipped=false
 if #copy>131072 then
  local first=#copy-131072+1
  while first<=#copy and copy:byte(first)>=128 and copy:byte(first)<192 do first=first+1 end
  copy=copy:sub(first);clipped=true
 end
 return copy,unreadable,clipped
end
function T.Source(shell)
 if shell and shell.visibilityFrame and not shell.visibilityFrame.isDocked and shell.visibilityFrame~=ChatFrame1 then
  return shell.visibilityFrame
 end
 if GENERAL_CHAT_DOCK and FCFDock_GetSelectedWindow then
  local ok,f=pcall(FCFDock_GetSelectedWindow,GENERAL_CHAT_DOCK)
  if ok and f then return f end
 end
 return ChatFrame1
end
local function Name(f)
 local value=f and f.name
 if not Secret(value)and value==nil and f and f.GetID and GetChatWindowInfo then
  local ok,id=pcall(f.GetID,f)
  if ok and not Secret(id)and type(id)=='number'then
   local good,name=pcall(GetChatWindowInfo,id);if good then value=name end
  end
 end
 local clean=Plain(value)
 if clean then clean=DisplayText(clean)end
 if clean and clean~=''then return clean end
 return L('chat')
end
function T.Snapshot(f)
 local lines,bytes,skipped,accounts={},0,0,{}
 if not f or not f.GetNumMessages or not f.GetMessageInfo then return '',0,false end
 local ok,n=pcall(f.GetNumMessages,f)
 if not ok or Secret(n)or type(n)~='number'or n~=n or n==math.huge then return '',1,false end
 n=math.max(0,math.floor(n));local first=math.max(1,n-999);local limited=first>1
 -- Walk backwards to retain the newest lines under a strict 128 KiB bound.
 for i=n,first,-1 do
  local good,s=pcall(f.GetMessageInfo,f,i)
  if not good or Secret(s)or type(s)~='string'then skipped=skipped+1
  elseif #s>32768 then skipped=skipped+1;limited=true
  else
   s=Plain(T.BattleNetLinks(s,accounts))
   if bytes+#s+1>131072 then limited=true;break end
   bytes=bytes+#s+1;lines[#lines+1]=s
  end
 end
 local ordered={};for i=#lines,1,-1 do ordered[#ordered+1]=lines[i]end
 return table.concat(ordered,'\n'),skipped,limited
end
-- Unicode folding with original UTF-8 byte offsets for EditBox:HighlightText.
local lower={
 ["À"]="à",
 ["Á"]="á",
 ["Â"]="â",
 ["Ã"]="ã",
 ["Ä"]="ä",
 ["Å"]="å",
 ["Æ"]="æ",
 ["Ç"]="ç",
 ["È"]="è",
 ["É"]="é",
 ["Ê"]="ê",
 ["Ë"]="ë",
 ["Ì"]="ì",
 ["Í"]="í",
 ["Î"]="î",
 ["Ï"]="ï",
 ["Ð"]="ð",
 ["Ñ"]="ñ",
 ["Ò"]="ò",
 ["Ó"]="ó",
 ["Ô"]="ô",
 ["Õ"]="õ",
 ["Ö"]="ö",
 ["Ø"]="ø",
 ["Ù"]="ù",
 ["Ú"]="ú",
 ["Û"]="û",
 ["Ü"]="ü",
 ["Ý"]="ý",
 ["Þ"]="þ",
 ["Ā"]="ā",
 ["Ă"]="ă",
 ["Ą"]="ą",
 ["Ć"]="ć",
 ["Ĉ"]="ĉ",
 ["Ċ"]="ċ",
 ["Č"]="č",
 ["Ď"]="ď",
 ["Đ"]="đ",
 ["Ē"]="ē",
 ["Ĕ"]="ĕ",
 ["Ė"]="ė",
 ["Ę"]="ę",
 ["Ě"]="ě",
 ["Ĝ"]="ĝ",
 ["Ğ"]="ğ",
 ["Ġ"]="ġ",
 ["Ģ"]="ģ",
 ["Ĥ"]="ĥ",
 ["Ħ"]="ħ",
 ["Ĩ"]="ĩ",
 ["Ī"]="ī",
 ["Ĭ"]="ĭ",
 ["Į"]="į",
 ["İ"]="i",
 ["Ĳ"]="ĳ",
 ["Ĵ"]="ĵ",
 ["Ķ"]="ķ",
 ["Ĺ"]="ĺ",
 ["Ļ"]="ļ",
 ["Ľ"]="ľ",
 ["Ŀ"]="ŀ",
 ["Ł"]="ł",
 ["Ń"]="ń",
 ["Ņ"]="ņ",
 ["Ň"]="ň",
 ["Ŋ"]="ŋ",
 ["Ō"]="ō",
 ["Ŏ"]="ŏ",
 ["Ő"]="ő",
 ["Œ"]="œ",
 ["Ŕ"]="ŕ",
 ["Ŗ"]="ŗ",
 ["Ř"]="ř",
 ["Ś"]="ś",
 ["Ŝ"]="ŝ",
 ["Ş"]="ş",
 ["Š"]="š",
 ["Ţ"]="ţ",
 ["Ť"]="ť",
 ["Ŧ"]="ŧ",
 ["Ũ"]="ũ",
 ["Ū"]="ū",
 ["Ŭ"]="ŭ",
 ["Ů"]="ů",
 ["Ű"]="ű",
 ["Ų"]="ų",
 ["Ŵ"]="ŵ",
 ["Ŷ"]="ŷ",
 ["Ÿ"]="ÿ",
 ["Ź"]="ź",
 ["Ż"]="ż",
 ["Ž"]="ž",
 ["Ѐ"]="ѐ",
 ["Ё"]="ё",
 ["Ђ"]="ђ",
 ["Ѓ"]="ѓ",
 ["Є"]="є",
 ["Ѕ"]="ѕ",
 ["І"]="і",
 ["Ї"]="ї",
 ["Ј"]="ј",
 ["Љ"]="љ",
 ["Њ"]="њ",
 ["Ћ"]="ћ",
 ["Ќ"]="ќ",
 ["Ѝ"]="ѝ",
 ["Ў"]="ў",
 ["Џ"]="џ",
 ["А"]="а",
 ["Б"]="б",
 ["В"]="в",
 ["Г"]="г",
 ["Д"]="д",
 ["Е"]="е",
 ["Ж"]="ж",
 ["З"]="з",
 ["И"]="и",
 ["Й"]="й",
 ["К"]="к",
 ["Л"]="л",
 ["М"]="м",
 ["Н"]="н",
 ["О"]="о",
 ["П"]="п",
 ["Р"]="р",
 ["С"]="с",
 ["Т"]="т",
 ["У"]="у",
 ["Ф"]="ф",
 ["Х"]="х",
 ["Ц"]="ц",
 ["Ч"]="ч",
 ["Ш"]="ш",
 ["Щ"]="щ",
 ["Ъ"]="ъ",
 ["Ы"]="ы",
 ["Ь"]="ь",
 ["Э"]="э",
 ["Ю"]="ю",
 ["Я"]="я",
}
local function Fold(s,offsets)
 local parts,starts,ends={}, {}, {};local pos=1;local out=0
 for char in s:gmatch('[%z\1-\127\194-\244][\128-\191]*')do
  local v=lower[char]or char:lower();parts[#parts+1]=v
  if offsets then for j=1,#v do starts[out+j]=pos;ends[out+j]=pos+#char-1 end end
  out=out+#v;pos=pos+#char
 end
 return table.concat(parts),starts,ends
end
function T.Find(text,query)
 if query==''then return {}end
 local source,starts,ends=Fold(text,true);local needle=Fold(query);local found={};local pos=1
 if needle==''then return found end
 while #found<1000 do
  local a,b=source:find(needle,pos,true);if not a then break end
  found[#found+1]={starts[a]-1,ends[b]};pos=b+1
 end
 return found
end
local paletteFrames,fonts={},{}
local function ApplyToolFont(region,size,bold)
 local apply=KerimAnkaUITextAPI and KerimAnkaUITextAPI.Font or K.ApplyTextFont
 if apply then apply(region,size,bold,'');return end
 local lang=KerimAnkaUIDB and KerimAnkaUIDB.language
 if lang=='zhCN'then region:SetFontObject(GameFontNormal)
 else region:SetFont('Interface\\AddOns\\KerimAnkaUI\\Fonts\\'..(bold and 'Ubuntu-B.ttf'or 'Ubuntu-R.ttf'),size,'')end
end
local function Font(r,size,bold)
 fonts[#fonts+1]={r,size,bold}
 ApplyToolFont(r,size,bold)
 r:SetTextColor(.91,.92,.88,1)
end
local function Label(parent,size,bold)
 local r=parent:CreateFontString(nil,'OVERLAY');Font(r,size,bold);r:SetJustifyH('LEFT');return r
end
local function Surface(frame,well)
 frame.fill=frame:CreateTexture(nil,'BACKGROUND');frame.fill:SetAllPoints()
 -- All four edges remain visible at fractional UI scales.
 local function Edge(a,b,vertical)
  local edge=frame:CreateTexture(nil,'BORDER');edge:SetColorTexture(.43,.47,.41,1)
  edge:SetPoint(a);edge:SetPoint(b)
  if vertical then edge:SetWidth(1)else edge:SetHeight(1)end
 end
 Edge('TOPLEFT','TOPRIGHT');Edge('BOTTOMLEFT','BOTTOMRIGHT')
 Edge('TOPLEFT','BOTTOMLEFT',true);Edge('TOPRIGHT','BOTTOMRIGHT',true)
 frame.toolWell=well;paletteFrames[#paletteFrames+1]=frame
end
function C.PaintTextTools()
 for _,v in ipairs(fonts)do ApplyToolFont(v[1],v[2],v[3])end
 local t=C.themes[C.ThemeID()];local c=t.body
 for _,f in ipairs(paletteFrames)do
  local add=f.toolWell and -.012 or f.toolButton and .075 or .035
  f.fill:SetColorTexture(math.max(0,c[1]+add),math.max(0,c[2]+add),math.max(0,c[3]+add),1)
 end
end
local function Button(parent,text,width,click)
 local b=CreateFrame('Button',nil,parent);b:SetSize(width,28);b.toolButton=true;Surface(b)
 local padding=width<=32 and 2 or 8
 b.label=Label(b,13,true);b.label:SetPoint('LEFT',padding,0);b.label:SetPoint('RIGHT',-padding,0);b.label:SetJustifyH('CENTER');b.label:SetText(text)
 local h=b:CreateTexture(nil,'HIGHLIGHT');h:SetAllPoints();h:SetColorTexture(.7,.75,.65,.10)
 b:SetScript('OnClick',click);return b
end
local menu,reader
local function PointerOver(frame)
 if not frame then return false end
 if type(frame.IsMouseOver)=='function'then return frame:IsMouseOver()end
 if type(MouseIsOver)=='function'then return MouseIsOver(frame)end
 return false
end
local function CloseMenu()if menu then menu:Hide();menu.source=nil;menu.anchor=nil end end
local function CloseReader()
 if T.HideTip then T.HideTip()end
 if reader then
  reader.body:ClearFocus();reader.search:ClearFocus();reader:Hide()
  reader.text='';reader.matches={};reader.query=nil;reader.body:SetText('');reader.measure:SetText('')
 end
end
local function Count(r,current,total)
 r.count:SetText(L('matchLabel')..string.format(L('matches'),current,total)..(total==1000 and '+'or ''))
 r.prev:SetAlpha(total>0 and 1 or .45);r.next:SetAlpha(total>0 and 1 or .45)
end
local toolTip
function T.HideTip()if toolTip then toolTip:Hide()end end
local function Tip(button,key)
 button:SetScript('OnEnter',function(self)
  if not toolTip then
   toolTip=CreateFrame('Frame',nil,UIParent);toolTip:SetFrameStrata('TOOLTIP');toolTip:SetSize(220,40);toolTip:SetClampedToScreen(true);toolTip:EnableMouse(false);Surface(toolTip)
   toolTip.label=Label(toolTip,13);toolTip.label:SetPoint('TOPLEFT',10,-8);toolTip.label:SetPoint('RIGHT',-10,0);toolTip.label:SetWordWrap(true)
  end
  toolTip:ClearAllPoints();toolTip:SetPoint('BOTTOM',self,'TOP',0,6);toolTip.label:SetText(L(key));C.PaintTextTools()
  toolTip:SetHeight(math.max(32,toolTip.label:GetStringHeight()+16));toolTip:Show()
 end)
 button:SetScript('OnLeave',T.HideTip)
end
local function Search(step)
 local r=reader;if not r then return end
 if r.query~=r.search:GetText()then
  r.query=r.search:GetText();r.matches=T.Find(r.text,r.query);r.index=0
 end
 local n=#r.matches
 if n>0 then
  if r.index==0 and step==-1 then r.index=1 end
  r.index=((r.index-1+(step or 1))%n)+1
  local hit=r.matches[r.index];r.body:SetFocus();r.body:SetCursorPosition(hit[1]);r.body:HighlightText(hit[1],hit[2])
 else r.index=0;r.body:HighlightText(0,0)end
 Count(r,r.index,n)
end
local function MakeReader()
 local r=CreateFrame('Frame',nil,UIParent);reader=r;r:SetFrameStrata('DIALOG');r:SetFrameLevel(40)
 r:SetSize(470,440);r:SetPoint('CENTER');r:SetClampedToScreen(true);r:EnableMouse(true);Surface(r)
 r:SetMovable(true);r:RegisterForDrag('LeftButton');r:SetScript('OnDragStart',r.StartMoving);r:SetScript('OnDragStop',r.StopMovingOrSizing)
 r.title=Label(r,17,true);r.title:SetPoint('TOPLEFT',16,-16);r.title:SetPoint('RIGHT',-50,0)
 r.close=Button(r,'X',28,CloseReader);r.close:SetPoint('TOPRIGHT',-10,-10);Tip(r.close,'close')
 r.source=Label(r,13,true);r.source:SetPoint('TOPLEFT',16,-43);r.source:SetPoint('RIGHT',-16,0)
 r.note=Label(r,11);r.note:SetPoint('TOPLEFT',16,-63);r.note:SetPoint('RIGHT',-16,0);r.note:SetHeight(30);r.note:SetWordWrap(true)
 local box=CreateFrame('Frame',nil,r);box:SetPoint('TOPLEFT',16,-101);box:SetPoint('RIGHT',-128,0);box:SetHeight(28);Surface(box,true)
 r.search=CreateFrame('EditBox',nil,box);r.search:SetPoint('TOPLEFT',8,-3);r.search:SetPoint('BOTTOMRIGHT',-8,3);r.search:SetAutoFocus(false);r.search:SetMaxLetters(120);Font(r.search,13)
 r.prev=Button(r,'<',28,function()Search(-1)end);r.prev:SetPoint('TOPRIGHT',-94,-101)
 r.next=Button(r,'>',28,function()Search(1)end);r.next:SetPoint('LEFT',r.prev,'RIGHT',4,0);Tip(r.prev,'previous');Tip(r.next,'next')
 r.count=Label(r,11);r.count:SetPoint('TOPRIGHT',-16,-135)
 r.searchHint=Label(r,11);r.searchHint:SetPoint('TOPLEFT',16,-135);r.searchHint:SetPoint('RIGHT',-175,0);r.searchHint:SetWordWrap(true);r.searchHint:SetHeight(26)
 r.well=CreateFrame('Frame',nil,r);r.well:SetPoint('TOPLEFT',16,-167);r.well:SetPoint('BOTTOMRIGHT',-16,85);Surface(r.well,true)
 r.scroll=CreateFrame('ScrollFrame',nil,r.well,'UIPanelScrollFrameTemplate');r.scroll:SetPoint('TOPLEFT',8,-8);r.scroll:SetPoint('BOTTOMRIGHT',-28,8)
 r.body=CreateFrame('EditBox',nil,r.scroll);r.body:SetMultiLine(true);r.body:SetAutoFocus(false);r.body:SetMaxLetters(0);Font(r.body,13)
 r.body:SetWidth(400);r.body:SetHeight(180);r.scroll:SetScrollChild(r.body)
 r.measure=Label(r,13);r.measure:SetWidth(400);r.measure:SetWordWrap(true);r.measure:Hide()
 r.body:SetScript('OnTextChanged',function(self)
  if r.setting then return end
  local ok,value=pcall(self.GetText,self)
  if not ok or Secret(value)or value~=r.text then
   r.setting=true;self:SetText(r.text or '');r.setting=false
  end
 end)
 r.body:SetScript('OnCursorChanged',function(_,_,cy,_,ch)
  if Secret(cy)or Secret(ch)or type(cy)~='number'or type(ch)~='number'then return end
  local y=-cy;local offset=r.scroll:GetVerticalScroll()
  if Secret(offset)or type(offset)~='number'then return end
  if y<offset then r.scroll:SetVerticalScroll(math.max(0,y))
  elseif y+ch>offset+r.scroll:GetHeight()then r.scroll:SetVerticalScroll(y+ch-r.scroll:GetHeight())end
 end)
 r.select=Button(r,'',150,function()r.body:SetFocus();r.body:HighlightText()end);r.select:SetPoint('BOTTOMLEFT',16,45)
 r.status=Label(r,11);r.status:SetPoint('BOTTOMLEFT',180,45);r.status:SetPoint('RIGHT',-16,0);r.status:SetHeight(28);r.status:SetWordWrap(true)
 r.hint=Label(r,11);r.hint:SetPoint('BOTTOMLEFT',16,13);r.hint:SetPoint('RIGHT',-16,0);r.hint:SetHeight(27);r.hint:SetWordWrap(true)
 for _,edit in ipairs({r.body,r.search})do edit:SetScript('OnEscapePressed',CloseReader)end
 r.search:SetScript('OnEnterPressed',function()Search(1)end)
 -- Debounce only our snapshot search. No per-frame native message reads.
 r.search:SetScript('OnTextChanged',function(_,user)if user then r.pending=.15 end end)
 r:SetScript('OnUpdate',function(_,dt)
  if r.pending then r.pending=r.pending-dt;if r.pending<=0 then
   r.pending=nil;r.query=nil;r.matches=T.Find(r.text,r.search:GetText());r.query=r.search:GetText();r.index=0
   Count(r,0,#r.matches)
  end end
 end)
 r:SetScript('OnHide',function()r.pending=nil;r.body:ClearFocus();r.search:ClearFocus()end)
 r:Hide();return r
end
function C.OpenTextTools(source,mode)
 source=source or T.Source();local name=Name(source)
 local raw,skipped,limited=T.Snapshot(source)
 local text,unreadableNames,clipped=T.CopyText(raw);limited=limited or clipped;CloseMenu()
 local r=reader or MakeReader();r.text=text;r.query=nil;r.matches={};r.index=0;r.pending=nil
 r.title:SetText(L('title'));r.source:SetText(name);r.note:SetText(L('snapshot'));r.select.label:SetText(L('select'));r.hint:SetText(L('hint'));r.searchHint:SetText(L('searchHelp'))
 local status={};if text==''then status[#status+1]=L('empty')end
 if skipped>0 then status[#status+1]=string.format(L('skipped'),skipped)end
 if limited then status[#status+1]=L('limited')end
 if unreadableNames>0 then status[#status+1]=string.format(L('namesUnreadable'),unreadableNames)end
 r.status:SetText(table.concat(status,' '));Count(r,0,0);r.search:SetText('')
 r.setting=true;r.body:SetText(text);r.setting=false
 r.body:Show()
 local scale=math.min(1,(UIParent:GetWidth()-24)/470,(UIParent:GetHeight()-24)/440);r:SetScale(math.max(.3,scale))
 C.PaintTextTools();r.measure:SetText(text)
 local measured,height=pcall(r.measure.GetStringHeight,r.measure)
 if measured and not Secret(height)and type(height)=='number'then r.body:SetHeight(math.max(180,height+26))end
 r:Show();r.scroll:SetVerticalScroll(0)
 if mode=='search'then r.body:ClearFocus();r.search:SetFocus()else r.search:ClearFocus();r.body:SetFocus();r.body:HighlightText(0,0);r.body:SetCursorPosition(0)end
end
function C.ToggleToolsMenu(anchor,shell)
 if menu and menu:IsShown()then CloseMenu();return end
 if GameTooltip then GameTooltip:Hide()end
 if not menu then
  menu=CreateFrame('Frame',nil,UIParent);menu:SetFrameStrata('DIALOG');menu:SetFrameLevel(30);menu:SetSize(270,146);menu:SetClampedToScreen(true);menu:EnableMouse(true);Surface(menu)
  menu.title=Label(menu,13,true);menu.title:SetPoint('TOPLEFT',12,-10);menu.title:SetPoint('RIGHT',-12,0)
  menu.items={}
  for i,key in ipairs({'settings','copy','search'})do
   local action=key
   local btn=Button(menu,'',246,function()
    local source=menu.source
    if action=='settings'then CloseMenu();C.OpenSettings()else C.OpenTextTools(source,action)end
   end)
   btn:SetScript('OnMouseDown',function(_,button)if button=='RightButton'then CloseMenu()end end)
   btn.label:SetJustifyH('LEFT');btn:SetPoint('TOPLEFT',12,-32-(i-1)*34);menu.items[i]=btn
  end
  menu:SetScript('OnKeyDown',function(self,key)self:SetPropagateKeyboardInput(key~='ESCAPE');if key=='ESCAPE'then CloseMenu()end end)
  menu:EnableKeyboard(true)
  -- Observe outside presses without an input-catching fullscreen overlay.
  -- The original mouse event reaches the world/UI, including right-drag camera.
  menu:SetScript('OnUpdate',function(self)
   if IsMouseButtonDown('LeftButton')or IsMouseButtonDown('RightButton')or IsMouseButtonDown('MiddleButton')then
    if not PointerOver(self)and not PointerOver(self.anchor)then CloseMenu()end
   end
  end)
  menu:SetScript('OnMouseDown',function(_,button)if button=='RightButton'then CloseMenu()end end)
 end
 menu.anchor=anchor;menu.source=T.Source();menu.title:SetText(Name(menu.source))
 for i,key in ipairs({'settings','copy','search'})do menu.items[i].label:SetText(L(key))end
 menu:ClearAllPoints();menu:SetPoint('BOTTOMRIGHT',anchor,'TOPRIGHT',0,6);C.PaintTextTools();menu:Show()
end
local restore=C.Restore
function C.Restore(...)T.HideTip();CloseMenu();CloseReader();return restore(...)end
