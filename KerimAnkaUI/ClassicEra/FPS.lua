-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={};K.FPS=M
-- Captured MoveAny DEFAULT / MAFPSFrame, relative to UIParent.
K.fpsDefaults={enabled=true,showMS=false,locked=true,x=-10,y=-260}
local defaults=K.fpsDefaults
local frame,dragging,elapsed
local networkElapsed,networkText=5,"—"
function M.Get(key)
 local data=K.db and K.db.fps
 if data and type(data[key])==type(defaults[key]) then return data[key] end
 return defaults[key]
end
local function Position()
 frame:ClearAllPoints();frame:SetPoint('RIGHT',UIParent,'RIGHT',M.Get('x'),M.Get('y'))
end
local function Update()
 local value=GetFramerate and GetFramerate()
 local text=type(value)=='number' and value==value and value>=0 and value<100000 and tostring(math.floor(value)) or '—'
 local output='|cff3fc7ebFPS:|r |cffffd100'..text..'|r'
 if M.Get('showMS')then
  -- Read Blizzard's cached World latency, never send a network probe.
  -- Reuse the FPS update script, with at most one network-stat read per 5s.
  if networkElapsed>=5 then
   networkElapsed=0;networkText='—'
   if type(GetNetStats)=='function'then
    local ok,inbound,outbound,home,world=pcall(GetNetStats)
    if ok and not(issecretvalue and issecretvalue(world))and type(world)=='number'and world==world and world>=0 and world<1000000000 then networkText=tostring(math.floor(world+.5))end
   end
  end
  output=output..'   |cff3fc7ebMS:|r |cffffd100'..networkText..'|r'
 end
 frame.text:SetText(output)
 local width=100
 if M.Get('showMS')then
  local measured=frame.text.GetUnboundedStringWidth and frame.text:GetUnboundedStringWidth()or frame.text.GetStringWidth and frame.text:GetStringWidth()
  width=math.max(190,math.ceil(type(measured)=='number'and measured or 180)+10)
 end
 if frame:GetWidth()~=width then frame:SetWidth(width)end
 frame.text:SetWidth(width)
end
local function Tick(_,delta)
 elapsed=(elapsed or 0)+delta
 if M.Get('showMS')then networkElapsed=networkElapsed+delta end
 if elapsed>=.5 then elapsed=0;Update() end
end
local function Stop(save)
 if not dragging then return end
 frame:StopMovingOrSizing();dragging=false
 if save and not K.InCombat() then
  local x,y=frame:GetCenter();local scale=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
  if x and y then
   K.db.fps=K.db.fps or {}
   K.db.fps.x=math.max(-10000,math.min(10000,(x+frame:GetWidth()/2)*scale-UIParent:GetWidth()))
   K.db.fps.y=math.max(-10000,math.min(10000,y*scale-UIParent:GetHeight()/2))
  end
 end
 Position()
end
local function Ensure()
 if frame then return end
 frame=CreateFrame('Frame','KerimAnkaUIFPS',UIParent)
 frame:SetSize(100,20);frame:SetFrameStrata('MEDIUM');frame:SetClampedToScreen(true);frame:SetMovable(true)
 frame:RegisterForDrag('LeftButton')
 frame.text=frame:CreateFontString(nil,'OVERLAY');frame.text:SetPoint('CENTER');frame.text:SetWidth(100);frame.text:SetWordWrap(false)
 frame.background=frame:CreateTexture(nil,'BACKGROUND');frame.background:SetAllPoints();frame.background:SetColorTexture(.07,.09,.07,.75)
 frame:SetScript('OnDragStart',function(self)
  if M.Get('locked') or K.InCombat() then return end
  dragging=true;self:StartMoving()
 end)
 frame:SetScript('OnDragStop',function() Stop(true) end)
 frame:SetScript('OnHide',function() Stop(false) end)
end
function M.Refresh()
 if not K.db or not K.ApplyTextFont then return end
 Ensure();if dragging then return end
 K.ApplyTextFont(frame.text,14,false,'OUTLINE');Position()
 frame:EnableMouse(not M.Get('locked') and not K.InCombat())
 frame.background:SetShown(not M.Get('locked'))
 local enabled=M.Get('enabled') and type(GetFramerate)=='function'
 frame:SetScript('OnUpdate',enabled and Tick or nil)
 frame:SetShown(enabled)
 elapsed=0;networkElapsed=5;if enabled then Update() end
end
function M.Set(key,value)
 if not K.db or K.InCombat() or defaults[key]==nil or type(value)~=type(defaults[key]) then return false end
 if type(value)=='number' then
  if value~=value or math.abs(value)==math.huge then return false end
  value=math.max(-10000,math.min(10000,value))
 end
 Stop(false);K.db.fps=K.db.fps or {};K.db.fps[key]=value;M.Refresh();return true
end
function M.ResetPosition()
 if not K.db or K.InCombat() then return false end
 Stop(false);K.db.fps=K.db.fps or {};K.db.fps.x=defaults.x;K.db.fps.y=defaults.y;M.Refresh();return true
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','DISPLAY_SIZE_CHANGED','UI_SCALE_CHANGED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function() Stop(false);M.Refresh() end)

K.locales.en["fpsShowMS"]="Show latency (MS) next to FPS"

K.locales.en["fpsShowMSHelp"]="Shows World-server latency beside FPS when the display is enabled. Uses the latest value provided by the game; no additional network probes."

K.locales.tr["fpsShowMS"]="FPS yanında gecikmeyi (MS) göster"

K.locales.tr["fpsShowMSHelp"]="FPS göstergesi açıkken yanında dünya sunucusu gecikmesini gösterir. Oyunun sunduğu son değer kullanılır; ek ağ sorgusu gönderilmez."

K.locales.de["fpsShowMS"]="Latenz (MS) neben FPS anzeigen"

K.locales.de["fpsShowMSHelp"]="Zeigt bei aktivierter FPS-Anzeige die Weltserver-Latenz. Verwendet den letzten Spielwert ohne zusätzliche Netzwerkanfragen."

K.locales.zhCN["fpsShowMS"]="在帧率旁显示延迟（MS）"

K.locales.zhCN["fpsShowMSHelp"]="启用帧率显示时，同时显示世界服务器延迟。使用游戏提供的最新数据，不发送额外网络探测。"

K.locales.frFR["fpsShowMS"]="Afficher la latence (MS) à côté des FPS"

K.locales.frFR["fpsShowMSHelp"]="Affiche la latence du serveur de monde lorsque les FPS sont visibles. Utilise la dernière valeur du jeu sans sonde réseau supplémentaire."

K.locales.itIT["fpsShowMS"]="Mostra latenza (MS) accanto agli FPS"

K.locales.itIT["fpsShowMSHelp"]="Mostra la latenza del server di gioco insieme agli FPS. Usa l’ultimo valore fornito dal gioco senza ulteriori sonde di rete."

K.locales.esES["fpsShowMS"]="Mostrar latencia (MS) junto a FPS"

K.locales.esES["fpsShowMSHelp"]="Muestra la latencia del servidor del mundo junto a los FPS. Usa el último valor del juego sin sondeos de red adicionales."

K.locales.ptBR["fpsShowMS"]="Mostrar latência (MS) ao lado do FPS"

K.locales.ptBR["fpsShowMSHelp"]="Mostra a latência do servidor de mundo junto ao FPS. Usa o último valor do jogo sem sondagens de rede adicionais."

K.locales.ruRU["fpsShowMS"]="Показывать задержку (MS) рядом с FPS"

K.locales.ruRU["fpsShowMSHelp"]="Показывает задержку игрового мира рядом с FPS. Использует последнее значение игры без дополнительных сетевых запросов."
