-- Classic player cast bar: Blizzard's Classic cast controller, modern local artwork.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local addon,K=...
local M={};K.ClassicCastBar=M
local holder,cast,preview,ready
local restoring=false;local nativeStates={}
local media='Interface\\AddOns\\'..addon..'\\ClassicEra\\CastMedia\\'
local defaults={enabled=true,locked=true,icon=true,time=true,width=240,height=14,scale=1,fontSize=12,x=0,y=-210}
local bounds={width={140,600},height={10,40},scale={.5,2},fontSize={8,24},x={-10000,10000},y={-10000,10000}}
local art={background={1,423,188,214},border={422,848,1,31},textbox={1,420,1,58},spark={78,88,408,468},flash={1,427,124,154}}
local function DB()
 if not K.db then return end
 local d=type(K.db.classicCast)=='table'and K.db.classicCast or {};K.db.classicCast=d
 for key,v in pairs(defaults)do if type(d[key])~=type(v)then d[key]=v end end
 for key,b in pairs(bounds)do local n=d[key];if n~=n or math.abs(n)==math.huge then n=defaults[key]end;d[key]=math.max(b[1],math.min(b[2],n))end
 return d
end
local function Texture(t,key)
 local r=art[key];t:SetTexture(media..'PlayerCast.blp');t:SetTexCoord(r[1]/1024,r[2]/1024,r[3]/512,r[4]/512)
end
local function Rect(t,parent,left,top,right,bottom)
 t:ClearAllPoints();t:SetPoint('TOPLEFT',parent,'TOPLEFT',left,top);t:SetPoint('BOTTOMRIGHT',parent,'BOTTOMRIGHT',right,bottom)
end
local function Fill(f,full)
 local types=CastingBarType or {};local kind=f.barType
 local key=(kind==types.Channel and 'Channel' or kind==types.Interrupted and 'Interrupted' or kind==types.Uninterruptable and 'Shield' or 'Standard')
 if full and (key=='Channel'or key=='Standard')then key='Full'..key end
 f:SetStatusBarTexture(media..key..'.tga');f:SetStatusBarColor(1,1,1)
end
local function Skin(f)
 local d=DB();if not d then return end
 f:ClearAllPoints();f:SetPoint('TOP',holder,'TOP',0,0);f:SetSize(d.width,d.height)
 f.Background=f.Background or f:CreateTexture(nil,'BACKGROUND');Texture(f.Background,'background');Rect(f.Background,f,-1,1,1,-1)
 Texture(f.Border,'border');Rect(f.Border,f,-2,2,2,-2)
 Texture(f.TextBorder,'textbox');f.TextBorder:ClearAllPoints();f.TextBorder:SetPoint('TOP',f,'BOTTOM',0,1);f.TextBorder:SetSize(d.width,d.fontSize+8)
 f.Text:ClearAllPoints();f.Text:SetPoint('TOP',f,'BOTTOM',0,-2);f.Text:SetWidth(d.width);f.Text:SetHeight(d.fontSize+5);f.Text:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',d.fontSize,'OUTLINE');f.Text:SetTextColor(1,1,1)
 f.CastTimeText:ClearAllPoints();f.CastTimeText:SetPoint('LEFT',f,'RIGHT',8,0);f.CastTimeText:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',d.fontSize,'OUTLINE');f.CastTimeText:SetTextColor(1,1,1)
 f.showCastTimeSetting=d.time;f.CastTimeText:SetShown(d.time)
 f.Icon:ClearAllPoints();f.Icon:SetPoint('RIGHT',f,'LEFT',-6,0);f.Icon:SetSize(d.height+6,d.height+6);f.Icon:SetShown(d.icon)
 Texture(f.Spark,'spark');f.Spark:SetSize(5,d.height+8);f.Spark.offsetY=0
 Texture(f.Flash,'flash');Rect(f.Flash,f,-2,2,2,-2);f.Flash:SetVertexColor(1,1,1)
 if f.BorderShield then f.BorderShield:Hide()end
end
local function Preview()
 if not ready then return end
 local d=DB();preview:SetShown(d.enabled and (M.layoutPreview or not d.locked) and not cast:IsShown())
end
local function SuppressNative(enabled)
 for _,name in ipairs({'PlayerCastingBarFrame','CastingBarFrame'})do
  local f=_G[name]
  if f and f~=cast and f.GetAlpha then
   local state=nativeStates[f]
   if not state then
    state={alpha=f:GetAlpha()};nativeStates[f]=state
    -- Alpha animation tracks can bypass SetAlpha. Keep the stock frame hidden too.
    f:HookScript('OnShow',function()
     if state.suppressed and not restoring then restoring=true;f:Hide();restoring=false end
    end)
    hooksecurefunc(f,'SetAlpha',function(_,value)
     if restoring then return end;state.alpha=value
     if state.suppressed then restoring=true;f:SetAlpha(0);restoring=false end
    end)
   end
   if enabled then state.suppressed=true;restoring=true;f:SetAlpha(0);f:Hide();restoring=false
   elseif state.suppressed then
    state.suppressed=false;restoring=true;f:SetAlpha(state.alpha);restoring=false
    -- Re-evaluate the native controller's current cast and its own visibility option.
    if f.UpdateIsShown then f:UpdateIsShown()end
   end
  end
 end
end
function M.Refresh()
 local d=DB();if not ready or not d then return end
 holder:ClearAllPoints();holder:SetPoint('CENTER',UIParent,'CENTER',d.x,d.y);holder:SetSize(d.width,d.height+d.fontSize+9);holder:SetScale(d.scale);holder:EnableMouse(d.enabled and not d.locked and not K.InCombat())
 Skin(cast);Skin(preview);preview:SetMinMaxValues(0,1);preview:SetValue(.65);Fill(preview);preview.Spark:Hide();preview.Flash:Hide();preview.Text:SetText(K.L('pcPreview'));preview.CastTimeText:SetText('1.5s')
 if d.enabled then
  cast:SetUnit('player',true,false);cast.showCastbar=true;cast.showIcon=d.icon
  -- Native ShouldShowCastBar remains independent from Edit Mode's player-bar checkbox.
 else cast:SetUnit(nil);cast:Hide()end
 SuppressNative(d.enabled);Preview()
end
function M.Set(key,value)
 local d=DB();if not d or K.InCombat()or defaults[key]==nil or type(value)~=type(defaults[key])then return false end
 if type(value)=='number'then if value~=value or math.abs(value)==math.huge then return false end;local b=bounds[key];value=math.max(b[1],math.min(b[2],value))end
 d[key]=value;M.Refresh();return true
end
function M.SetLayoutPreview(value)M.layoutPreview=value==true;if preview then preview.Icon:SetTexture("Interface\\Icons\\Spell_Holy_FlashHeal")end;Preview()end
function M.GetSettings()return DB()end
function M.ResetPosition()local d=DB();if not d or K.InCombat()then return false end;d.x=0;d.y=-210;M.Refresh();return true end
function M.Initialize()
 if ready or not DB()or not CastingBarMixin or not PlayerCastingBarFrame then return end
 holder=CreateFrame('Frame','KAClassicPlayerCastHolder',UIParent);holder:SetFrameStrata('HIGH');holder:SetMovable(true);holder:SetClampedToScreen(true);holder:RegisterForDrag('LeftButton')
 local ok,f=pcall(CreateFrame,'StatusBar','KAClassicPlayerCastBar',holder,'CastingBarFrameTemplate')
 if not ok or not f or not f.SetUnit then holder:Hide();return end
 cast=f;cast:Hide();M.frame=cast;M.holder=holder
 cast.TextBorder=cast:CreateTexture(nil,'BACKGROUND',nil,1);cast.CastTimeText=cast:CreateFontString(nil,'OVERLAY')
 -- Classic has no CAST_BAR_CAST_TIME global. Format only our frame's timer locally.
 -- Keep Blizzard's shared mixin and globals unchanged for native/other addon bars.
 cast.UpdateCastTimeText=function(self)
  if not self.CastTimeText or not self.showCastTimeSetting then return end
  local seconds=0
  if self.casting or self.channeling then
   local minimum,maximum=self:GetMinMaxValues()
   seconds=math.max(minimum or 0,self.casting and (maximum-self:GetValue())or self:GetValue())
  end
  self.CastTimeText:SetText(string.format('%.1fs',seconds))
 end
 preview=CreateFrame('StatusBar',nil,holder);M.preview=preview
 for _,key in ipairs({'Border','TextBorder','Icon','Spark','Flash'})do preview[key]=preview:CreateTexture(nil,key=='Spark'and'OVERLAY'or'ARTWORK')end
 preview.Text=preview:CreateFontString(nil,'OVERLAY');preview.CastTimeText=preview:CreateFontString(nil,'OVERLAY')
 hooksecurefunc(cast,'UpdateBarFillTexture',function(self,full)Fill(self,full)end)
 cast:HookScript('OnShow',function()Skin(cast);Preview()end);cast:HookScript('OnHide',Preview)
 -- Keep Blizzard's spell events, channel timing, delay, interruption and completion animations.
 cast:HookScript('OnEvent',function()Skin(cast);cast.Icon:SetShown(DB().icon);Preview()end)
 holder:SetScript('OnDragStart',function(self)if not DB().locked and not K.InCombat()then self:StartMoving()end end)
 holder:SetScript('OnDragStop',function(self)
  self:StopMovingOrSizing();local x,y=self:GetCenter();local px,py=UIParent:GetCenter();local factor=self:GetEffectiveScale()/UIParent:GetEffectiveScale()
  if x and y and px and py then local d=DB();d.x=math.max(-10000,math.min(10000,x*factor-px));d.y=math.max(-10000,math.min(10000,y*factor-py))end;M.Refresh()
 end)
 ready=true;M.Refresh();Fill(cast)
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','ADDON_LOADED','PLAYER_ENTERING_WORLD','PLAYER_REGEN_ENABLED','PLAYER_REGEN_DISABLED'})do events:RegisterEvent(event)end
M.Handle=function(_,event)
 if event=='PLAYER_LOGIN'or event=='ADDON_LOADED'then M.Initialize()end
 if ready then M.Refresh()end
end
events:SetScript('OnEvent',M.Handle)
function K.DrawClassicCastOptions(page,w,y)
 if not ready then return y end
 w.Text(page,K.L('pcTitle'),8,y,698,19,{.73,.62,.41});y=y-34
 w.Text(page,K.L('pcHelp'),8,y,698,13,{.65,.70,.62});y=y-76
 local function Toggle(key,label,x,at)
  local card=w.Box(page,x,at,349,64);w.Text(card,K.L(label),14,-12,300,13)
  w.Switch(card,DB()[key],255,-28,function(v)M.Set(key,v)end,true)
 end
 Toggle('enabled','pcEnabled',0,y);Toggle('locked','swLocked',365,y);y=y-78
 Toggle('icon','pcIcon',0,y);Toggle('time','swTime',365,y);y=y-78
 local function Number(key,label,x,at,step,fmt)
  local card=w.Box(page,x,at,349,86);w.Text(card,K.L(label),14,-12,310,13);w.Text(card,string.format(fmt,DB()[key]),14,-49,190,15)
  for i,delta in ipairs({-step,step})do local change=delta;w.Button(card,delta<0 and '−'or'+',251+(i-1)*46,-47,36,32,function()if M.Set(key,DB()[key]+change)and K.Render then K.Render()end end)end
 end
 Number('width','swWidth',0,y,10,'%.0f');Number('height','swHeight',365,y,1,'%.0f');y=y-100
 Number('scale','swScale',0,y,.05,'%.2f');Number('fontSize','pcFont',365,y,1,'%.0f');y=y-100
 Number('x','pcX',0,y,5,'%.0f');Number('y','pcY',365,y,5,'%.0f');y=y-100
 w.Button(page,K.L('pcReset'),0,y,349,34,function()M.ResetPosition();if K.Render then K.Render()end end)
 return y-64
end


local castLocales={en={pcTitle="Player cast bar",pcHelp="Modern player spell casting bar. Unlock to preview and drag it. Turning it off restores Blizzard’s original bar.",pcEnabled="Use modern player cast bar",pcIcon="Show spell icon",pcPreview="Player spell cast",pcFont="Text size",pcX="Horizontal position",pcY="Vertical position",pcReset="Reset cast bar position"},tr={pcTitle="Oyuncu büyü barı",pcHelp="Modern oyuncu büyü barı. Önizlemek ve sürüklemek için kilidini aç. Kapatıldığında Blizzard’ın orijinal barı geri gelir.",pcEnabled="Modern oyuncu büyü barını kullan",pcIcon="Büyü simgesini göster",pcPreview="Oyuncu büyüsü",pcFont="Yazı boyutu",pcX="Yatay konum",pcY="Dikey konum",pcReset="Büyü barı konumunu sıfırla"},de={pcTitle="Zauberleiste des Spielers",pcHelp="Moderne Spieler-Zauberleiste. Zum Vorschauen und Verschieben entsperren. Ausschalten stellt Blizzards Originalleiste wieder her.",pcEnabled="Moderne Spieler-Zauberleiste verwenden",pcIcon="Zaubersymbol anzeigen",pcPreview="Zauber des Spielers",pcFont="Schriftgröße",pcX="Horizontale Position",pcY="Vertikale Position",pcReset="Position der Zauberleiste zurücksetzen"},zhCN={pcTitle="玩家施法条",pcHelp="现代风格的玩家施法条。解锁后可预览和拖动。关闭后恢复暴雪原版施法条。",pcEnabled="使用现代玩家施法条",pcIcon="显示法术图标",pcPreview="玩家施法",pcFont="文字大小",pcX="水平位置",pcY="垂直位置",pcReset="重置施法条位置"},frFR={pcTitle="Barre d’incantation du joueur",pcHelp="Barre moderne du joueur. Déverrouillez-la pour la prévisualiser et la déplacer. La désactivation restaure la barre de Blizzard.",pcEnabled="Utiliser la barre d’incantation moderne",pcIcon="Afficher l’icône du sort",pcPreview="Sort du joueur",pcFont="Taille du texte",pcX="Position horizontale",pcY="Position verticale",pcReset="Réinitialiser la position"},itIT={pcTitle="Barra di lancio del giocatore",pcHelp="Barra moderna del giocatore. Sblocca per visualizzarla e trascinarla. Disattivandola torna la barra originale Blizzard.",pcEnabled="Usa la barra di lancio moderna",pcIcon="Mostra icona della magia",pcPreview="Magia del giocatore",pcFont="Dimensione testo",pcX="Posizione orizzontale",pcY="Posizione verticale",pcReset="Ripristina posizione della barra"},esES={pcTitle="Barra de lanzamiento del jugador",pcHelp="Barra moderna del jugador. Desbloquéala para verla y moverla. Al desactivarla se restaura la barra de Blizzard.",pcEnabled="Usar barra de lanzamiento moderna",pcIcon="Mostrar icono del hechizo",pcPreview="Hechizo del jugador",pcFont="Tamaño del texto",pcX="Posición horizontal",pcY="Posición vertical",pcReset="Restablecer posición de la barra"},ptBR={pcTitle="Barra de lançamento do jogador",pcHelp="Barra moderna do jogador. Desbloqueie para visualizar e arrastar. Ao desativar, a barra original da Blizzard volta.",pcEnabled="Usar barra de lançamento moderna",pcIcon="Mostrar ícone da magia",pcPreview="Magia do jogador",pcFont="Tamanho do texto",pcX="Posição horizontal",pcY="Posição vertical",pcReset="Redefinir posição da barra"},ruRU={pcTitle="Полоса заклинаний игрока",pcHelp="Современная полоса игрока. Разблокируйте для просмотра и перемещения. Отключение возвращает исходную полосу Blizzard.",pcEnabled="Использовать современную полосу",pcIcon="Показывать значок заклинания",pcPreview="Заклинание игрока",pcFont="Размер текста",pcX="По горизонтали",pcY="По вертикали",pcReset="Сбросить положение полосы"}}
for lang,entries in pairs(castLocales)do K.locales[lang]=K.locales[lang]or{};for key,value in pairs(entries)do K.locales[lang][key]=value end end
