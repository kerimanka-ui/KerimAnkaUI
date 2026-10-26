-- Classic Era/Hardcore only; native Forever artwork, independent Classic engine.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local addonName,K=...
local E=K.ClassicSwingEngine
local events=CreateFrame('Frame')
local db,frames,ready,cast,channel,shooting=nil,{},false,nil,nil,false
local hands={'mainhand','offhand','ranged'}
local layoutPreview=false
local titles={mainhand='Main Hand',offhand='Off Hand',ranged='Ranged'}
local media='Interface\\AddOns\\'..addonName..'\\ClassicEra\\SwingMedia\\SwingTimer.tga'
local art={background={1,423,33,59},frame={1,427,1,31},mainhand={1,419,61,83},offhand={1,419,85,107},ranged={1,419,109,131},pip={1,11,156,210},shadow={1,172,133,154}}
local function Texture(t,key)local r=art[key];t:SetTexture(media);t:SetTexCoord(r[1]/512,r[2]/512,r[3]/256,r[4]/256)end
local function Speed(h)local m,o=UnitAttackSpeed('player');local r=UnitRangedDamage('player');return (h=='mainhand' and m or h=='offhand' and o or h=='ranged' and r) or 0 end
local function Start(h,now)E:Start(h,now,Speed(h))end
local function ResetMelee(now)Start('mainhand',now);Start('offhand',now)end
local function Spell(id)if not id then return end;if GetSpellInfo then return GetSpellInfo(id)end;local s=C_Spell and C_Spell.GetSpellInfo(id);return s and s.name end
local function Same(id,base)return id==base or (Spell(id) and Spell(id)==Spell(base))end
local function CastTime(id)if GetSpellInfo then return select(4,GetSpellInfo(id))or 0 end;local s=C_Spell and C_Spell.GetSpellInfo(id);return s and s.castTime or 0 end
local function Shot(id)return id==75 or id==5019 or id==2764 or id==3018 or id==2480 or id==7918 end
local function Position(f,h)
 local p=db.positions[h];f:ClearAllPoints()
 if type(p)=='table' and type(p.x)=='number' and type(p.y)=='number' then f:SetPoint(p.point or 'CENTER',UIParent,p.relativePoint or 'BOTTOMLEFT',p.x,p.y)
 else f:SetPoint('CENTER',UIParent,'CENTER',0,-100-(h=='offhand' and 30 or h=='ranged' and 60 or 0))end
end
local function Update()
 if not ready then return end
 for _,h in ipairs(hands)do
  local f=frames[h];local progress,left,active=E:Progress(h,GetTime());local preview=layoutPreview or not db.locked
  local show=db.enabled and db.hands[h] and (preview or (Speed(h)>0 and (db.visibility=='always' or (db.visibility=='combat' and UnitAffectingCombat('player')))))
  f:SetShown(show);f:EnableMouse(not db.locked)
  local language=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or 'en'
  local color=db.textColor
  local style=language..':'..db.textFont..':'..db.textSize..':'..table.concat(color,':')
  if f.swingTextStyle~=style then
   f.swingTextStyle=style
   -- Keep multilingual game-font fallback. Scale a text-only carrier instead
   -- of changing the native FontString's font path or the bar dimensions.
   -- The Latin game font can lack Turkish dotted/dotless letters.
   -- Use the bundled regular face for Turkish without changing saved choices.
   if (db.textFont=='game' and language~='tr') or language=='zhCN' then
    f.title:SetFontObject(GameFontHighlightSmall);f.time:SetFontObject(GameFontHighlightSmall)
   else
    if not f.swingFont then f.swingFont=CreateFont('KAClassicSwingFont_'..h)end
    f.swingFont:SetFont('Interface\\AddOns\\'..addonName..'\\Fonts\\'..(db.textFont=='bold' and 'Ubuntu-B.ttf' or 'Ubuntu-R.ttf'),11,'')
    f.title:SetFontObject(f.swingFont);f.time:SetFontObject(f.swingFont)
   end
   f.textFrame:SetScale(db.textSize/11)
   f.title:SetTextColor(color[1],color[2],color[3],1);f.time:SetTextColor(color[1],color[2],color[3],1)
  end
  if layoutPreview then local phase=GetTime()%2.4;progress,left,active=phase/2.4,2.4-phase,true end
  if show then f.title:SetText(K.L(h=='mainhand' and 'swMain' or h=='offhand' and 'swOff' or 'swRanged'));f.title:SetShown(db.labels);f.time:SetShown(db.time);f.bar:SetValue(progress);f.time:SetText(string.format('%.1f',left));f.pip:SetShown(active)end
 end
end
local function Layout()
 for _,h in ipairs(hands)do local f=frames[h];f:SetSize(db.bars[h].width,db.bars[h].height);f:SetScale(db.scale);f:SetAlpha(db.alpha);Position(f,h)end
 Update()
end
local function MakeFrame(h)
 local f=CreateFrame('Frame','KAClassicSwing_'..h,UIParent);f:SetFrameStrata('MEDIUM');f:SetClampedToScreen(true);f:SetMovable(true);f:RegisterForDrag('LeftButton')
 local bg=f:CreateTexture(nil,'BACKGROUND');Texture(bg,'background');bg:SetAllPoints()
 local edge=f:CreateTexture(nil,'BORDER');Texture(edge,'frame');edge:SetAllPoints()
 local bar=CreateFrame('StatusBar',nil,f);f.bar=bar;bar:SetPoint('TOPLEFT',5,-4);bar:SetPoint('BOTTOMRIGHT',-5,4);bar:SetMinMaxValues(0,1);bar:SetStatusBarTexture('Interface\\AddOns\\'..addonName..'\\ClassicEra\\SwingMedia\\Fill-'..h..'.tga')
 local shadow=bar:CreateTexture(nil,'OVERLAY');Texture(shadow,'shadow');shadow:SetPoint('TOPLEFT');shadow:SetPoint('BOTTOMLEFT');shadow:SetWidth(171)
 local textFrame=CreateFrame('Frame',nil,bar);f.textFrame=textFrame;textFrame:SetAllPoints(bar);textFrame:EnableMouse(false)
 local title=textFrame:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');f.title=title;title:SetPoint('LEFT',10,0);title:SetText(titles[h])
 f.time=textFrame:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');f.time:SetPoint('RIGHT',-10,0)
 f.pip=bar:CreateTexture(nil,'OVERLAY');Texture(f.pip,'pip');f.pip:SetSize(5,27);f.pip:SetPoint('CENTER',bar:GetStatusBarTexture(),'RIGHT',0,0)
 f:SetScript('OnDragStart',function(self)if not db.locked then self:StartMoving()end end)
 f:SetScript('OnDragStop',function(self)
  self:StopMovingOrSizing();local point,_,relativePoint,x,y=self:GetPoint(1)
  db.positions[h]={point=point,relativePoint=relativePoint,x=x,y=y};Position(self,h)
 end)
 f:Hide();return f
end
local function Handle(_,name,...)
 local now=GetTime()
 if name=='PLAYER_LOGIN' then
  if type(K.db)~='table' then return end
  K.db.classicSwing=type(K.db.classicSwing)=='table' and K.db.classicSwing or {};db=K.db.classicSwing
  local defaults={enabled=true,locked=true,labels=true,time=true,width=213,height=15,scale=1,alpha=1,textSize=11,textFont='game'}
  for k,v in pairs(defaults)do if type(db[k])~=type(v)then db[k]=v end end
  db.width=math.max(140,math.min(852,db.width));db.height=math.max(15,math.min(60,db.height));db.scale=math.max(.5,math.min(2,db.scale));db.alpha=math.max(.2,math.min(1,db.alpha))
  if db.visibility~='always' and db.visibility~='combat' then db.visibility='always' end
  db.textSize=math.max(8,math.min(24,db.textSize))
  if db.textFont~='game' and db.textFont~='ui' and db.textFont~='bold' then db.textFont='game' end
  local c=db.textColor
  if type(c)~='table' or type(c[1])~='number' or type(c[2])~='number' or type(c[3])~='number' or c[1]~=c[1] or c[2]~=c[2] or c[3]~=c[3] then c={1,1,1} end
  db.textColor={math.max(0,math.min(1,c[1])),math.max(0,math.min(1,c[2])),math.max(0,math.min(1,c[3]))}
  db.positions=type(db.positions)=='table' and db.positions or {};db.hands=type(db.hands)=='table' and db.hands or {}
  -- Migrate the old shared size without losing any saved placement or hand toggle.
  db.bars=type(db.bars)=='table' and db.bars or {}
  for _,h in ipairs(hands)do
   local b=type(db.bars[h])=='table' and db.bars[h] or {};db.bars[h]=b
   local width=type(b.width)=='number' and b.width==b.width and b.width or db.width
   local height=type(b.height)=='number' and b.height==b.height and b.height or db.height
   b.width=math.max(140,math.min(852,width));b.height=math.max(15,math.min(60,height))
  end
  for _,h in ipairs(hands)do if type(db.hands[h])~='boolean'then db.hands[h]=true end;frames[h]=MakeFrame(h)end
  ready=true;Layout()
  for _,e in ipairs({'COMBAT_LOG_EVENT_UNFILTERED','UNIT_ATTACK_SPEED','UNIT_RANGEDDAMAGE','UNIT_SPELLCAST_START','UNIT_SPELLCAST_SUCCEEDED','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_FAILED_QUIET','UNIT_SPELLCAST_INTERRUPTED','UNIT_SPELLCAST_CHANNEL_START','UNIT_SPELLCAST_CHANNEL_STOP','PLAYER_EQUIPMENT_CHANGED','PLAYER_ENTERING_WORLD','PLAYER_DEAD','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','START_AUTOREPEAT_SPELL','STOP_AUTOREPEAT_SPELL'})do events:RegisterEvent(e)end
  local elapsed=0;events:SetScript('OnUpdate',function(_,dt)elapsed=elapsed+dt;if elapsed>=.03 then elapsed=0;Update()end end);return
 end
 if not ready then return end
 if name=='PLAYER_ENTERING_WORLD' or name=='PLAYER_DEAD' then E:Clear();cast=nil;channel=nil;shooting=false
 elseif name=='START_AUTOREPEAT_SPELL' then shooting=true
 elseif name=='STOP_AUTOREPEAT_SPELL' then shooting=false;E:Clear('ranged')
 elseif not db.enabled then return
 elseif name=='COMBAT_LOG_EVENT_UNFILTERED' then
  local a={CombatLogGetCurrentEventInfo()};local sub,source,dest=a[2],a[4],a[8];local player=UnitGUID('player')
  if sub=='SWING_MISSED' and dest==player and a[12]=='PARRY' then E:Parry(now)end
  if source==player then
   if sub=='SWING_DAMAGE' or sub=='SWING_MISSED' then
    local off;if sub=='SWING_DAMAGE'then off=a[21]else off=a[13]end;Start(off and 'offhand' or 'mainhand',now)
   elseif sub=='SPELL_DAMAGE' or sub=='SPELL_MISSED' then
    if Same(a[12],78) or Same(a[12],845) or Same(a[12],6807)then Start('mainhand',now)end
   end
  end
 elseif name=='UNIT_ATTACK_SPEED' or name=='UNIT_RANGEDDAMAGE' then
  if (...)=='player'then for _,h in ipairs(hands)do E:Speed(h,now,Speed(h))end end
 elseif name=='PLAYER_EQUIPMENT_CHANGED' then
  local slot=...;if slot==16 or slot==17 or slot==18 then E:Clear();cast=nil;channel=nil end
 elseif name=='UNIT_SPELLCAST_START' then
  local unit,_,id=...;if unit=='player'then cast=id;if Same(id,19434)then E:Pause(now)end end
 elseif name=='UNIT_SPELLCAST_CHANNEL_START' then
  local unit,_,id=...;if unit=='player'then channel=id end
 elseif name=='UNIT_SPELLCAST_SUCCEEDED' then
  local unit,_,id=...;if unit=='player'then
   if Shot(id)then Start('ranged',now)
   elseif Same(id,19434)then E:Resume(now);Start('ranged',now)
   elseif CastTime(id)>0 and not channel then ResetMelee(now)end
   cast=nil
  end
 elseif name=='UNIT_SPELLCAST_FAILED_QUIET' then
  local unit,_,id=...;if unit=='player' and shooting and Shot(id)then
   local s=E.hands.ranged;local speed=Speed('ranged')
   -- Retry delay plus approximate Auto Shot wind-up; validate movement on Hunter.
   if speed>0 then s.speed=speed;s.expires=now+1.02 end
  end
 elseif name=='UNIT_SPELLCAST_FAILED' or name=='UNIT_SPELLCAST_INTERRUPTED' then
  local unit=...;if unit=='player'then E:Resume(now);cast=nil end
 elseif name=='UNIT_SPELLCAST_CHANNEL_STOP' then
  local unit,_,id=...;if unit=='player'then if not Shot(id or channel)then ResetMelee(now)end;channel=nil end
 end
 Update()
end
K.ClassicSwingTimer={Handle=Handle,Frames=frames,Engine=E}
function K.ClassicSwingTimer.Set(key,value)
 if not ready then return false end
 if (key=='enabled' or key=='locked' or key=='labels' or key=='time') and type(value)=='boolean' then db[key]=value
 elseif db.hands[key]~=nil and type(value)=='boolean' then db.hands[key]=value
 elseif key=='visibility' and (value=='always' or value=='combat')then db.visibility=value
 elseif key=='textFont' and (value=='game' or value=='ui' or value=='bold')then db.textFont=value
 elseif type(value)=='number' and value==value and math.abs(value)<math.huge then
  local limits={width={140,852},height={15,60},scale={.5,2},alpha={.2,1},textSize={8,24}};local range=limits[key];if not range then return false end
  db[key]=math.max(range[1],math.min(range[2],value))
  if key=='width' or key=='height' then for _,h in ipairs(hands)do db.bars[h][key]=db[key]end end
 else return false end
 if not db.enabled then E:Clear()end
 Layout();return true
end
function K.ClassicSwingTimer.SetBar(hand,key,value)
 if not ready or not db.bars[hand] or (key~='width' and key~='height') then return false end
 if type(value)~='number' or value~=value or math.abs(value)==math.huge then return false end
 local lo,hi=key=='width' and 140 or 15,key=='width' and 852 or 60
 db.bars[hand][key]=math.max(lo,math.min(hi,value))
 -- Size changes never reset swing state, change another bar, or move it.
 local f=frames[hand];f:SetSize(db.bars[hand].width,db.bars[hand].height);Update();return true
end
function K.ClassicSwingTimer.SetTextColor(color)
 if not ready or type(color)~='table' then return false end
 for i=1,3 do local v=color[i];if type(v)~='number' or v~=v or math.abs(v)==math.huge then return false end end
 db.textColor={math.max(0,math.min(1,color[1])),math.max(0,math.min(1,color[2])),math.max(0,math.min(1,color[3]))};Update();return true
end
function K.ClassicSwingTimer.ResetText()
 if ready then db.textColor={1,1,1};db.textFont='game';db.textSize=11;Update()end
end
function K.ClassicSwingTimer.SetLayoutPreview(value)layoutPreview=value==true;Update()end
function K.ClassicSwingTimer.GetSettings()return db end
function K.ClassicSwingTimer.ResetPositions()if ready then db.positions={};Layout()end end
function K.ClassicSwingTimer.OriginalSize()if ready then db.width=213;db.height=15;db.scale=1;for _,h in ipairs(hands)do db.bars[h]={width=213,height=15}end;Layout()end end
events:RegisterEvent('PLAYER_LOGIN');events:SetScript('OnEvent',Handle)

-- Main KerimAnka UI settings only; there is no separate Swing Timer window.
local swingLocales={
 en={swTitle='Swing Timer',swHelp='Track main-hand, off-hand and ranged attacks. Unlock the bars to show and move them; timers stay live.',swEnabled='Show Swing Timer',swLocked='Lock bar positions',swMain='Main hand',swOff='Off hand',swRanged='Ranged weapon',swAlways='Always visible',swCombat='Visible in combat',swWidth='Bar width',swHeight='Bar height',swScale='Scale',swAlpha='Opacity',swLabels='Show weapon labels',swTime='Show remaining time',swReset='Reset bar positions',swNative='Original proportions',swPreview='Unlocked bars show live attack times; idle bars show 0.0. Width and height are saved separately for each bar.'},
 tr={swTitle='Swing Timer',swHelp='Ana el, ikinci el ve menzilli saldırıları takip eder. Görünürlük ve taşıma için konum kilidini kaldır; sayaçlar çalışmaya devam eder.',swEnabled='Swing Timer göster',swLocked='Bar konumlarını kilitle',swMain='Ana el',swOff='İkinci el',swRanged='Menzilli silah',swAlways='Her zaman görünür',swCombat='Savaşta görünür',swWidth='Bar genişliği',swHeight='Bar yüksekliği',swScale='Ölçek',swAlpha='Saydamlık',swLabels='Silah etiketlerini göster',swTime='Kalan süreyi göster',swReset='Bar konumlarını sıfırla',swNative='Orijinal oranlar',swPreview='Kilit açıkken de gerçek saldırı süreleri gösterilir; boşta 0.0 yazar. Her barın genişliği ve yüksekliği ayrı kaydedilir.'},
 de={swTitle='Swing Timer',swHelp='Zeigt Angriffe mit Haupt-, Nebenhand und Fernkampfwaffe. Zum Verschieben die Positionssperre aufheben; die Timer laufen weiter.',swEnabled='Swing Timer anzeigen',swLocked='Positionen sperren',swMain='Haupthand',swOff='Nebenhand',swRanged='Fernkampfwaffe',swAlways='Immer sichtbar',swCombat='Im Kampf sichtbar',swWidth='Balkenbreite',swHeight='Balkenhöhe',swScale='Skalierung',swAlpha='Deckkraft',swLabels='Waffenbeschriftung anzeigen',swTime='Verbleibende Zeit anzeigen',swReset='Positionen zurücksetzen',swNative='Originalproportionen',swPreview='Auch entsperrt bleiben die Timer live; im Leerlauf steht 0.0. Breite und Höhe werden pro Balken gespeichert.'}}
swingLocales.zhCN={swTitle="攻击计时条",swHelp="追踪主手、副手和远程攻击。解锁后可显示并移动计时条，计时仍会继续。",swEnabled="显示攻击计时条",swLocked="锁定计时条位置",swMain="主手",swOff="副手",swRanged="远程武器",swAlways="始终显示",swCombat="战斗中显示",swWidth="计时条宽度",swHeight="计时条高度",swScale="缩放",swAlpha="不透明度",swLabels="显示武器标签",swTime="显示剩余时间",swReset="重置计时条位置",swNative="原始比例",swPreview="解锁时仍显示实际攻击时间；空闲时显示 0.0。每条计时条的宽度和高度分别保存。"}
swingLocales.frFR={swTitle="Minuteur d’attaque",swHelp="Suit les attaques des deux mains et à distance. Déverrouillez les barres pour les afficher et les déplacer ; le décompte continue.",swEnabled="Afficher les minuteurs d’attaque",swLocked="Verrouiller les positions",swMain="Main droite",swOff="Main gauche",swRanged="Arme à distance",swAlways="Toujours visible",swCombat="Visible en combat",swWidth="Largeur de la barre",swHeight="Hauteur de la barre",swScale="Échelle",swAlpha="Opacité",swLabels="Afficher le nom des armes",swTime="Afficher le temps restant",swReset="Réinitialiser les positions",swNative="Proportions d’origine",swPreview="Les barres déverrouillées affichent le temps réel des attaques, ou 0.0 au repos. La largeur et la hauteur sont enregistrées séparément pour chaque barre."}
swingLocales.itIT={swTitle="Timer degli attacchi",swHelp="Tiene traccia degli attacchi delle due mani e a distanza. Sblocca le barre per mostrarle e spostarle; il timer continua a funzionare.",swEnabled="Mostra i timer degli attacchi",swLocked="Blocca le posizioni",swMain="Mano primaria",swOff="Mano secondaria",swRanged="Arma a distanza",swAlways="Sempre visibile",swCombat="Visibile in combattimento",swWidth="Larghezza della barra",swHeight="Altezza della barra",swScale="Scala",swAlpha="Opacità",swLabels="Mostra le etichette delle armi",swTime="Mostra il tempo rimanente",swReset="Reimposta le posizioni",swNative="Proporzioni originali",swPreview="Anche sbloccate, le barre mostrano i tempi reali degli attacchi; a riposo indicano 0.0. Larghezza e altezza vengono salvate separatamente per ogni barra."}
swingLocales.esES={swTitle="Temporizador de ataques",swHelp="Sigue los ataques de ambas manos y a distancia. Desbloquea las barras para mostrarlas y moverlas; el temporizador sigue funcionando.",swEnabled="Mostrar temporizadores de ataques",swLocked="Bloquear posiciones",swMain="Mano derecha",swOff="Mano izquierda",swRanged="Arma a distancia",swAlways="Siempre visible",swCombat="Visible en combate",swWidth="Anchura de la barra",swHeight="Altura de la barra",swScale="Escala",swAlpha="Opacidad",swLabels="Mostrar etiquetas de armas",swTime="Mostrar tiempo restante",swReset="Restablecer posiciones",swNative="Proporciones originales",swPreview="Las barras desbloqueadas muestran los tiempos reales de ataque; en reposo indican 0.0. La anchura y la altura se guardan por separado para cada barra."}
swingLocales.ptBR={swTitle="Temporizador de ataques",swHelp="Acompanha os ataques das duas mãos e à distância. Destrave as barras para exibi-las e movê-las; a contagem continua.",swEnabled="Mostrar temporizadores de ataques",swLocked="Travar posições",swMain="Mão principal",swOff="Mão secundária",swRanged="Arma de longo alcance",swAlways="Sempre visível",swCombat="Visível em combate",swWidth="Largura da barra",swHeight="Altura da barra",swScale="Escala",swAlpha="Opacidade",swLabels="Mostrar rótulos das armas",swTime="Mostrar tempo restante",swReset="Redefinir posições",swNative="Proporções originais",swPreview="As barras destravadas mostram os tempos reais dos ataques; em repouso, exibem 0.0. A largura e a altura são salvas separadamente para cada barra."}
swingLocales.ruRU={swTitle="Таймер атак",swHelp="Отслеживает атаки обеих рук и дальнего боя. Разблокируйте полосы, чтобы отобразить и переместить их; отсчёт продолжится.",swEnabled="Показывать таймеры атак",swLocked="Закрепить положение полос",swMain="Правая рука",swOff="Левая рука",swRanged="Оружие дальнего боя",swAlways="Всегда показывать",swCombat="Показывать в бою",swWidth="Ширина полосы",swHeight="Высота полосы",swScale="Масштаб",swAlpha="Непрозрачность",swLabels="Показывать названия оружия",swTime="Показывать оставшееся время",swReset="Сбросить положение полос",swNative="Исходные пропорции",swPreview="Разблокированные полосы показывают реальное время атак, а в покое — 0.0. Ширина и высота сохраняются отдельно для каждой полосы."}
local textLocales={en={swTextTitle="Text appearance",swFont="Font",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Bold",swTextSize="Text size",swTextColor="Choose text color",swTextReset="Default text"},tr={swTextTitle="Yazı görünümü",swFont="Yazı tipi",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Kalın",swTextSize="Yazı boyutu",swTextColor="Yazı rengi seç",swTextReset="Varsayılan yazı"},de={swTextTitle="Textdarstellung",swFont="Schriftart",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Fett",swTextSize="Schriftgröße",swTextColor="Textfarbe wählen",swTextReset="Standardtext"},zhCN={swTextTitle="文字外观",swFont="字体",swFontGame="暴雪默认",swFontUI="KerimAnka UI",swFontBold="粗体",swTextSize="文字大小",swTextColor="选择文字颜色",swTextReset="默认文字样式"},frFR={swTextTitle="Apparence du texte",swFont="Police",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Gras",swTextSize="Taille du texte",swTextColor="Choisir la couleur du texte",swTextReset="Texte par défaut"},itIT={swTextTitle="Aspetto del testo",swFont="Carattere",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Grassetto",swTextSize="Dimensione del testo",swTextColor="Scegli il colore del testo",swTextReset="Testo predefinito"},esES={swTextTitle="Apariencia del texto",swFont="Fuente",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Negrita",swTextSize="Tamaño del texto",swTextColor="Elegir color del texto",swTextReset="Texto predeterminado"},ptBR={swTextTitle="Aparência do texto",swFont="Fonte",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Negrito",swTextSize="Tamanho do texto",swTextColor="Escolher cor do texto",swTextReset="Texto padrão"},ruRU={swTextTitle="Оформление текста",swFont="Шрифт",swFontGame="Blizzard",swFontUI="KerimAnka UI",swFontBold="Жирный",swTextSize="Размер текста",swTextColor="Выбрать цвет текста",swTextReset="Текст по умолчанию"}}
for lang,entries in pairs(textLocales)do for key,value in pairs(entries)do swingLocales[lang][key]=value end end
for lang,entries in pairs(swingLocales)do
 K.locales[lang]=K.locales[lang] or {};for key,value in pairs(entries)do K.locales[lang][key]=value end
end
function K.DrawClassicSwingOptions(page,w,y)
 if not ready then return y end
 local api=K.ClassicSwingTimer
 local function Refresh()if K.Render then K.Render()end end
 w.Text(page,K.L('swTitle'),8,y,690,19,{.73,.62,.41});y=y-34
 w.Text(page,K.L('swHelp'),8,y,698,13,{.65,.70,.62});y=y-60
 local function Toggle(key,label,x,at)
  local card=w.Box(page,x,at,349,64);w.Text(card,K.L(label),14,-12,300,13)
  local value=db.hands[key];if value==nil then value=db[key]end
  w.Switch(card,value,255,-28,function(v)api.Set(key,v)end,true)
 end
 Toggle('enabled','swEnabled',0,y);Toggle('locked','swLocked',365,y);y=y-78
 Toggle('mainhand','swMain',0,y);Toggle('offhand','swOff',365,y);y=y-78
 Toggle('ranged','swRanged',0,y);Toggle('labels','swLabels',365,y);y=y-78
 Toggle('time','swTime',0,y)
 local visibility=w.Box(page,365,y,349,64)
 for i,mode in ipairs({'always','combat'})do
  local selected=mode;local b=w.Button(visibility,K.L(mode=='always' and 'swAlways' or 'swCombat'),10+(i-1)*168,-16,160,32,function()api.Set('visibility',selected);Refresh()end)
  w.Selected(b,db.visibility==mode)
 end
 y=y-90
 local function Number(key,label,x,at,step,format,hand)
  local card=w.Box(page,x,at,349,86);w.Text(card,K.L(label),14,-12,310,13)
  local value=hand and db.bars[hand][key] or db[key]
  w.Text(card,string.format(format,value),14,-49,190,15)
  for i,delta in ipairs({-step,step})do local change=delta;w.Button(card,delta<0 and '−' or '+',251+(i-1)*46,-47,36,32,function()if hand then api.SetBar(hand,key,db.bars[hand][key]+change)else api.Set(key,db[key]+change)end;Refresh()end)end
 end
 for _,h in ipairs(hands)do
  local title=h=='mainhand' and 'swMain' or h=='offhand' and 'swOff' or 'swRanged'
  w.Text(page,K.L(title),8,y,698,16,{.73,.62,.41});y=y-28
  Number('width','swWidth',0,y,10,'%.0f',h);Number('height','swHeight',365,y,1,'%.0f',h);y=y-108
 end
 Number('scale','swScale',0,y,.05,'%.2f');Number('alpha','swAlpha',365,y,.05,'%.2f');y=y-104
 w.Text(page,K.L('swTextTitle'),8,y,698,16,{.73,.62,.41});y=y-34
 for i,font in ipairs({'game','ui','bold'})do
  local choice=font;local key=font=='game' and 'swFontGame' or font=='ui' and 'swFontUI' or 'swFontBold'
  local b=w.Button(page,K.L(key),(i-1)*243,y,228,32,function()api.Set('textFont',choice);Refresh()end);w.Selected(b,db.textFont==font)
 end
 y=y-46
 Number('textSize','swTextSize',0,y,1,'%.0f')
 local colorCard=w.Box(page,365,y,349,86);w.Text(colorCard,K.L('swTextColor'),14,-12,310,13)
 local colorButton=w.Button(colorCard,K.L('swTextColor'),14,-47,321,32,function()
  local picker=ColorPickerFrame;if not picker or not picker.SetupColorPickerAndShow then return end
  local before={unpack(db.textColor)}
  picker:SetupColorPickerAndShow({r=before[1],g=before[2],b=before[3],hasOpacity=false,
   swatchFunc=function()local r,g,b=picker:GetColorRGB();api.SetTextColor({r,g,b})end,
   cancelFunc=function()api.SetTextColor(before)end})
  if picker.Raise then picker:Raise()end
 end)
 y=y-100
 w.Button(page,K.L('swTextReset'),0,y,714,32,function()api.ResetText();Refresh()end);y=y-50
 w.Button(page,K.L('swReset'),0,y,349,34,function()api.ResetPositions()end)
 w.Button(page,K.L('swNative'),365,y,349,34,function()api.OriginalSize();Refresh()end);y=y-52
 w.Text(page,K.L('swPreview'),8,y,698,13,{.65,.70,.62})
 return y-72
end
