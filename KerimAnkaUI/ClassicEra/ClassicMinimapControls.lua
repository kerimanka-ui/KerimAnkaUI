-- Classic-only minimap controls. Native clock/day-night scripts remain untouched.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={};K.ClassicMinimapControls=M
local defaults={sunSize=100,sunCustom=false,sunX=0,sunY=0,clockLocked=true,clockCustom=false,clockX=0,clockY=-18}
local sun,baseScale,sunPoints,clock,clockPoints,mover,applying,queued,dragging
local function DB()
 if not K.db then return end
 local d=type(K.db.minimapControls)=='table' and K.db.minimapControls or {};K.db.minimapControls=d
 for k,v in pairs(defaults)do if type(d[k])~=type(v)then d[k]=v end end
 return d
end
local function Sun()
 local c=MinimapCluster and MinimapCluster.MinimapContainer
 return _G.DielFrame or (c and c.DielFrame) or (MinimapCluster and MinimapCluster.DielFrame) or _G.GameTimeFrame
end
local function Clock()
 local c=MinimapCluster and MinimapCluster.MinimapContainer
 return _G.TimeManagerClockButton or (c and c.Clock)
end
local function Queue()
 if applying or queued then return end;queued=true
 C_Timer.After(0,function()queued=false;M.Refresh()end)
end
local function StopDrag()
 dragging=nil;if mover then mover:SetScript('OnUpdate',nil)end
end
local function PositionSun(d)
 if not sun or not Minimap or not d.sunCustom then return end
 local x,y=Minimap:GetCenter();if not x or not y then return end
 local ui=UIParent:GetEffectiveScale();local ms=Minimap:GetEffectiveScale()/ui;local ss=sun:GetEffectiveScale()/ui
 sun:ClearAllPoints();sun:SetPoint('CENTER',UIParent,'BOTTOMLEFT',(x+d.sunX)*ms/ss,(y+d.sunY)*ms/ss)
end
local function CaptureSunOffset(d)
 if d.sunCustom or not sun or not Minimap then return end
 local x,y=sun:GetCenter();local mx,my=Minimap:GetCenter()
 if x and y and mx and my then
  local ratio=sun:GetEffectiveScale()/Minimap:GetEffectiveScale()
  d.sunX=math.max(-300,math.min(300,x*ratio-mx));d.sunY=math.max(-300,math.min(300,y*ratio-my))
 end
end
local function PositionClock(d)
 if not clock or not Minimap or not d.clockCustom then return end
 local x=Minimap:GetCenter();local y=Minimap:GetBottom();if not x or not y then return end
 -- Use an absolute UIParent anchor to avoid dependency cycles with minimap layout.
 local ui=UIParent:GetEffectiveScale();local ms=Minimap:GetEffectiveScale()/ui;local cs=clock:GetEffectiveScale()/ui
 clock:ClearAllPoints();clock:SetPoint('CENTER',UIParent,'BOTTOMLEFT',(x+d.clockX)*ms/cs,(y+d.clockY)*ms/cs)
end
local function CaptureOffset(d)
 if d.clockCustom or not clock or not Minimap then return end
 local x,y=clock:GetCenter();local mx=Minimap:GetCenter();local my=Minimap:GetBottom()
 if x and y and mx and my then
  local ratio=clock:GetEffectiveScale()/Minimap:GetEffectiveScale()
  d.clockX=math.max(-300,math.min(300,x*ratio-mx));d.clockY=math.max(-300,math.min(300,y*ratio-my))
 end
end
function M.Get(key)local d=DB();if d then if key=='clockX'or key=='clockY'then CaptureOffset(d)elseif key=='sunX'or key=='sunY'then CaptureSunOffset(d)end;return d[key]end;return defaults[key]end
function M.ClockAvailable()return Clock()~=nil end
function M.SunAvailable()return Sun()~=nil end
function M.Refresh()
 local d=DB();if not d or InCombatLockdown()then if mover then StopDrag();mover:Hide()end;return end
 applying=true
 local nextSun=Sun()
 if nextSun and nextSun~=sun then
  sun=nextSun;baseScale=sun:GetScale();sunPoints={};for i=1,sun:GetNumPoints()do sunPoints[i]={sun:GetPoint(i)}end
  hooksecurefunc(sun,'SetPoint',function()if DB() and DB().sunCustom then Queue()end end)
  hooksecurefunc(sun,'SetScale',function(_,value)if not applying then baseScale=value;Queue()end end)
 end
 if sun then local scale=baseScale*d.sunSize/100;if math.abs(sun:GetScale()-scale)>.0001 then sun:SetScale(scale)end;PositionSun(d)end
 local nextClock=Clock()
 if nextClock and nextClock~=clock then
  clock=nextClock;clockPoints={};for i=1,clock:GetNumPoints()do clockPoints[i]={clock:GetPoint(i)}end
  hooksecurefunc(clock,'SetPoint',function()if DB() and DB().clockCustom then Queue()end end)
 end
 if clock then
  PositionClock(d)
  if not mover then
   mover=CreateFrame('Button','KAClassicMinimapClockMover',UIParent,'BackdropTemplate');M.mover=mover;mover:RegisterForDrag('LeftButton');mover:EnableMouse(true)
   mover:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});mover:SetBackdropColor(.2,.3,.16,.3);mover:SetBackdropBorderColor(.85,.72,.4,1)
   mover:SetScript('OnDragStart',function(self)
    if InCombatLockdown() or DB().clockLocked then return end
    local d=DB();CaptureOffset(d);d.clockCustom=true
    local x,y=GetCursorPosition();dragging={x,y,d.clockX,d.clockY,Minimap:GetEffectiveScale()}
    self:SetScript('OnUpdate',function()
     if InCombatLockdown()then StopDrag();return end
     local x,y=GetCursorPosition();local a=dragging;if not a then return end
     local d=DB();d.clockX=math.max(-300,math.min(300,a[3]+(x-a[1])/a[5]));d.clockY=math.max(-300,math.min(300,a[4]+(y-a[2])/a[5]));M.Refresh()
    end)
   end)
   mover:SetScript('OnDragStop',function()StopDrag();if K.Render then K.Render()end end)
  end
  mover:ClearAllPoints();mover:SetAllPoints(clock);mover:SetFrameStrata(clock:GetFrameStrata());mover:SetFrameLevel(clock:GetFrameLevel()+3)
  mover:SetShown(not d.clockLocked and clock:IsVisible())
 end
 applying=false
end
function M.Set(key,value)
 local d=DB();if not d or InCombatLockdown()then return false end
 if key=='clockLocked'and type(value)=='boolean'then d[key]=value;if value then StopDrag()end
 elseif (key=='sunSize' or key=='sunX' or key=='sunY' or key=='clockX' or key=='clockY')and type(value)=='number'and value==value and math.abs(value)<math.huge then
  if key=='sunSize'then d[key]=math.max(50,math.min(150,value))
  elseif key=='sunX'or key=='sunY'then CaptureSunOffset(d);d.sunCustom=true;d[key]=math.max(-300,math.min(300,value))
  else CaptureOffset(d);d.clockCustom=true;d[key]=math.max(-300,math.min(300,value))end
 else return false end
 M.Refresh();return true
end
function M.ResetSunPosition()
 local d=DB();if not d or InCombatLockdown()then return false end
 d.sunCustom=false;d.sunX=0;d.sunY=0
 if sun and sunPoints then applying=true;sun:ClearAllPoints();for _,p in ipairs(sunPoints)do sun:SetPoint(unpack(p))end;applying=false end
 M.Refresh();return true
end
function M.ResetClock()
 local d=DB();if not d or InCombatLockdown()then return false end
 StopDrag();d.clockCustom=false;d.clockLocked=true;d.clockX=0;d.clockY=-18
 if clock and clockPoints then applying=true;clock:ClearAllPoints();for _,p in ipairs(clockPoints)do clock:SetPoint(unpack(p))end;applying=false end
 M.Refresh();return true
end
local events=CreateFrame('Frame')
for _,e in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','ADDON_LOADED','PLAYER_REGEN_ENABLED','PLAYER_REGEN_DISABLED','DISPLAY_SIZE_CHANGED','UI_SCALE_CHANGED'})do events:RegisterEvent(e)end
events:SetScript('OnEvent',function(_,event)
 if event=='PLAYER_REGEN_DISABLED'then StopDrag();if mover then mover:Hide()end;return end
 M.Refresh()
end)
-- Follow native minimap movement/resizing while the clock has a custom offset.
local elapsed=0;events:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<.2 then return end;elapsed=0
 local d=DB();if d and not InCombatLockdown()then applying=true;if clock and d.clockCustom then PositionClock(d)end;if sun and d.sunCustom then PositionSun(d)end;applying=false end
end)
function K.DrawClassicMinimapControls(page,w,y)
 local function Refresh()if K.Render then K.Render()end end
 M.Refresh();w.Text(page,K.L('mmControlsTitle'),8,y,698,18,{.73,.62,.41});y=y-36
 local function Number(label,get,set,x,at,step,available)
  local b=w.Box(page,x,at,349,86);w.Text(b,K.L(label),14,-12,310,13);local value=w.Text(b,string.format('%.0f',get()),14,-49,190,15)
  for i,delta in ipairs({-step,step})do local change=delta;local button=w.Button(b,delta<0 and '−'or '+',251+(i-1)*46,-47,36,32,function()if set(get()+change)then value:SetText(string.format('%.0f',get()))end end);if not available or InCombatLockdown()then button:Disable()end end
 end
 Number('mmSunSize',function()return M.Get('sunSize')end,function(v)return M.Set('sunSize',v)end,0,y,5,M.SunAvailable())
 Number('mmSunX',function()return M.Get('sunX')end,function(v)return M.Set('sunX',v)end,365,y,1,M.SunAvailable());y=y-100
 Number('mmSunY',function()return M.Get('sunY')end,function(v)return M.Set('sunY',v)end,0,y,1,M.SunAvailable())
 local sunReset=w.Button(page,K.L('mmSunReset'),365,y-25,349,34,function()M.ResetSunPosition();Refresh()end);if not M.SunAvailable()or InCombatLockdown()then sunReset:Disable()end;y=y-110
 w.Text(page,K.L('mmClockTitle'),8,y,698,16,{.73,.62,.41});y=y-32
 w.Text(page,K.L('mmClockHelp'),8,y,698,13,{.65,.70,.62});y=y-56
 local b=w.Box(page,0,y,714,62);w.Text(b,K.L('mmClockLock'),14,-18,580,14);w.Switch(b,M.Get('clockLocked'),620,-16,function(v)M.Set('clockLocked',v)end,M.ClockAvailable()and not InCombatLockdown());y=y-78
 Number('mcX',function()return M.Get('clockX')end,function(v)return M.Set('clockX',v)end,0,y,1,M.ClockAvailable())
 Number('mcY',function()return M.Get('clockY')end,function(v)return M.Set('clockY',v)end,365,y,1,M.ClockAvailable());y=y-100
 local reset=w.Button(page,K.L('mmClockReset'),0,y,714,32,function()M.ResetClock();Refresh()end);if not M.ClockAvailable()or InCombatLockdown()then reset:Disable()end
 return y-56
end

local entries={en={mmControlsTitle="Minimap icons",mmSoundSize="Sound icon size",mmSunSize="Day/night icon size (%)",mmClockTitle="Clock position",mmClockLock="Lock clock position",mmClockHelp="Unlock to drag the clock, or adjust its horizontal and vertical offsets below. The game clock keeps its normal click actions.",mmClockReset="Reset clock position",mcHelp="Shows your current map coordinates below the minimap. Adjust position and font here. Some instances do not provide coordinates."},tr={mmControlsTitle="Minimap ikonları",mmSoundSize="Ses ikonu boyutu",mmSunSize="Gün/gece ikonu boyutu (%)",mmClockTitle="Saat konumu",mmClockLock="Saat konumunu kilitle",mmClockHelp="Saati sürüklemek için kilidi kaldır veya aşağıdan yatay ve dikey konumunu ayarla. Saatin normal tıklama işlevleri korunur.",mmClockReset="Saat konumunu sıfırla",mcHelp="Güncel harita koordinatlarını minimap altında gösterir. Konum ve yazı tipini buradan ayarlayabilirsin. Bazı zindanlarda koordinat bilgisi bulunmaz."},de={mmControlsTitle="Minikarten-Symbole",mmSoundSize="Größe des Soundsymbols",mmSunSize="Größe des Tag-/Nachtsymbols (%)",mmClockTitle="Uhrposition",mmClockLock="Uhrposition sperren",mmClockHelp="Zum Verschieben die Uhr entsperren oder die Position unten einstellen. Die normalen Klickfunktionen der Uhr bleiben erhalten.",mmClockReset="Uhrposition zurücksetzen",mcHelp="Zeigt die aktuellen Kartenkoordinaten unter der Minikarte. Position und Schrift sind einstellbar. Manche Instanzen liefern keine Koordinaten."},zhCN={mmControlsTitle="小地图图标",mmSoundSize="声音图标大小",mmSunSize="昼夜图标大小（%）",mmClockTitle="时钟位置",mmClockLock="锁定时钟位置",mmClockHelp="解锁后可拖动时钟，也可在下方调整水平和垂直偏移。时钟原有的点击功能保持不变。",mmClockReset="重置时钟位置",mcHelp="在小地图下方显示当前地图坐标，可调整位置和字体。部分副本不提供坐标信息。"},frFR={mmControlsTitle="Icônes de la minicarte",mmSoundSize="Taille de l’icône du son",mmSunSize="Taille de l’icône jour/nuit (%)",mmClockTitle="Position de l’horloge",mmClockLock="Verrouiller l’horloge",mmClockHelp="Déverrouillez l’horloge pour la déplacer ou réglez les décalages ci-dessous. Ses fonctions de clic restent inchangées.",mmClockReset="Réinitialiser l’horloge",mcHelp="Affiche les coordonnées sous la minicarte. Réglez ici leur position et leur police. Certaines instances ne fournissent pas de coordonnées."},itIT={mmControlsTitle="Icone della minimappa",mmSoundSize="Dimensione dell’icona audio",mmSunSize="Dimensione icona giorno/notte (%)",mmClockTitle="Posizione dell’orologio",mmClockLock="Blocca l’orologio",mmClockHelp="Sblocca l’orologio per trascinarlo oppure regola gli spostamenti qui sotto. Le normali funzioni dei clic restano invariate.",mmClockReset="Reimposta l’orologio",mcHelp="Mostra le coordinate sotto la minimappa. Qui puoi regolare posizione e carattere. Alcune istanze non forniscono coordinate."},esES={mmControlsTitle="Iconos del minimapa",mmSoundSize="Tamaño del icono de sonido",mmSunSize="Tamaño del icono día/noche (%)",mmClockTitle="Posición del reloj",mmClockLock="Bloquear el reloj",mmClockHelp="Desbloquea el reloj para arrastrarlo o ajusta su posición abajo. Se conservan sus funciones normales al hacer clic.",mmClockReset="Restablecer el reloj",mcHelp="Muestra las coordenadas bajo el minimapa. Ajusta aquí su posición y fuente. Algunas estancias no proporcionan coordenadas."},ptBR={mmControlsTitle="Ícones do minimapa",mmSoundSize="Tamanho do ícone de som",mmSunSize="Tamanho do ícone dia/noite (%)",mmClockTitle="Posição do relógio",mmClockLock="Travar o relógio",mmClockHelp="Destrave o relógio para arrastá-lo ou ajuste a posição abaixo. As funções normais de clique são mantidas.",mmClockReset="Redefinir o relógio",mcHelp="Mostra as coordenadas abaixo do minimapa. Ajuste aqui a posição e a fonte. Algumas instâncias não fornecem coordenadas."},ruRU={mmControlsTitle="Значки мини-карты",mmSoundSize="Размер значка звука",mmSunSize="Размер значка дня и ночи (%)",mmClockTitle="Положение часов",mmClockLock="Закрепить часы",mmClockHelp="Разблокируйте часы для перетаскивания или настройте смещение ниже. Обычные действия по щелчку сохраняются.",mmClockReset="Сбросить положение часов",mcHelp="Показывает координаты под мини-картой. Здесь можно настроить положение и шрифт. В некоторых подземельях координаты недоступны."}}
for lang,values in pairs(entries)do K.locales[lang]=K.locales[lang]or {};for key,value in pairs(values)do K.locales[lang][key]=value end end

-- The freely positioned sound shortcut belongs beside its visibility/lock controls.
function K.DrawSoundShortcutSize(page,w,y)
 local sound=K.SoundShortcut;if not sound then return y end
 local b=w.Box(page,0,y,714,86);w.Text(b,K.L('mmSoundSize'),14,-12,580,13)
 local value=w.Text(b,string.format('%.0f',sound.Get('size')),14,-49,570,15)
 for i,delta in ipairs({-2,2})do local change=delta
  local button=w.Button(b,delta<0 and '−'or '+',616+(i-1)*46,-47,36,32,function()
   if sound.Set('size',sound.Get('size')+change)then value:SetText(string.format('%.0f',sound.Get('size')))end
  end)
  if InCombatLockdown()then button:Disable()end
 end
 return y-100
end

local sunLabels={en={mmSunX="Day/night icon: horizontal position",mmSunY="Day/night icon: vertical position",mmSunReset="Reset day/night icon position"},tr={mmSunX="Gün/gece ikonu: yatay konum",mmSunY="Gün/gece ikonu: dikey konum",mmSunReset="Gün/gece ikonu konumunu sıfırla"},de={mmSunX="Tag-/Nachtsymbol: horizontale Position",mmSunY="Tag-/Nachtsymbol: vertikale Position",mmSunReset="Position des Tag-/Nachtsymbols zurücksetzen"},zhCN={mmSunX="昼夜图标：水平位置",mmSunY="昼夜图标：垂直位置",mmSunReset="重置昼夜图标位置"},frFR={mmSunX="Icône jour/nuit : position horizontale",mmSunY="Icône jour/nuit : position verticale",mmSunReset="Réinitialiser la position jour/nuit"},itIT={mmSunX="Icona giorno/notte: posizione orizzontale",mmSunY="Icona giorno/notte: posizione verticale",mmSunReset="Reimposta la posizione giorno/notte"},esES={mmSunX="Icono día/noche: posición horizontal",mmSunY="Icono día/noche: posición vertical",mmSunReset="Restablecer la posición día/noche"},ptBR={mmSunX="Ícone dia/noite: posição horizontal",mmSunY="Ícone dia/noite: posição vertical",mmSunReset="Redefinir a posição do ícone dia/noite"},ruRU={mmSunX="Значок дня и ночи: по горизонтали",mmSunY="Значок дня и ночи: по вертикали",mmSunReset="Сбросить положение значка дня и ночи"}}
for lang,values in pairs(sunLabels)do for key,value in pairs(values)do K.locales[lang][key]=value end end
