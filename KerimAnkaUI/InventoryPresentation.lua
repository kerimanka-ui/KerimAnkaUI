-- Presentation-only preferences. Never register native item counts/cooldowns.
local _,K=...
local P={};K.InventoryPresentation=P
local fonts=setmetatable({},{__mode='k'})
local nativeFont=K.InventoryFont
local function Config(scope,create)
 if not K.db then return end
 local key=scope=='bank'and'classicBank'or'classicBags'
 if create then K.db[key]=K.db[key]or{}end
 return K.db[key]
end
local function Clamp(v,lo,hi,default)
 v=tonumber(v);if not v or v~=v then return default end
 return math.max(lo,math.min(hi,v))
end
function P.Level(scope)local d=Config(scope);return math.floor(Clamp(d and d.fontLevel,0,3,0))end
local function Scope(region)
 if region.kaInventoryFixedFont then return end
 local current=region
 for _=1,18 do
  if current.kaInventoryTextScope then return current.kaInventoryTextScope end
  current=current.GetParent and current:GetParent();if not current then return end
 end
end
function K.InventoryFont(region,size)
 if not region then return end
 local scope=Scope(region);if not scope then return nativeFont(region,size)end
 local spec=fonts[region]
 local text=region.GetFontString and region:GetFontString()or region
 local base=size or spec and spec.base or(text.GetFont and select(2,text:GetFont()))or 12
 if not spec then fonts[region]={base=base,scope=scope}else spec.base=base;spec.scope=scope end
 return nativeFont(region,base+P.Level(scope))
end
function P.ScopeWindow(frame,scope)
 if frame.kaInventoryTextScope==scope then return end
 frame.kaInventoryTextScope=scope
 for region,spec in pairs(fonts)do
  local owner=region
  for _=1,18 do
   if owner==frame then K.InventoryFont(region,spec.base);break end
   owner=owner.GetParent and owner:GetParent();if not owner then break end
  end
 end
end
function P.ChangeText(scope,delta)
 if InCombatLockdown()or not K.db or(delta~=-1 and delta~=1)then return false end
 local current=P.Level(scope);local nextLevel=math.max(0,math.min(3,current+delta))
 if nextLevel==current then return true end
 Config(scope,true).fontLevel=nextLevel
 for region,spec in pairs(fonts)do if spec.scope==scope then K.InventoryFont(region,spec.base)end end
 if scope=='bank'then if K.ClassicBank then K.ClassicBank.Refresh()end
 elseif K.ClassicBags then K.ClassicBags.Refresh()end
 if K.ClassicItemRecords then K.ClassicItemRecords.Refresh()end
 return true
end
local words={
 en={'Smaller interface text','Larger interface text','Drag to resize the window proportionally. Right-click: original size.'},
 tr={'Arayüz yazısını küçült','Arayüz yazısını büyüt','Sürükle: pencereyi orantılı boyutlandır. Sağ tık: ilk boyut.'},
 de={'Kleinere Oberflächenschrift','Größere Oberflächenschrift','Ziehen: Fenster proportional skalieren. Rechtsklick: Originalgröße.'},
 frFR={'Réduire le texte de l’interface','Agrandir le texte de l’interface','Glisser : redimensionner proportionnellement. Clic droit : taille initiale.'},
 itIT={'Riduci il testo dell’interfaccia','Ingrandisci il testo dell’interfaccia','Trascina: ridimensiona in proporzione. Clic destro: dimensione originale.'},
 esES={'Reducir texto de la interfaz','Ampliar texto de la interfaz','Arrastra para cambiar el tamaño proporcionalmente. Clic derecho: tamaño original.'},
 ptBR={'Diminuir texto da interface','Aumentar texto da interface','Arraste para redimensionar proporcionalmente. Clique direito: tamanho original.'},
 ruRU={'Уменьшить текст интерфейса','Увеличить текст интерфейса','Перетащите для пропорционального изменения размера. Правая кнопка: исходный размер.'},
 zhCN={'缩小界面文字','放大界面文字','拖动以按比例缩放窗口。右键恢复原始大小。'},
}
function P.Tip(index)local lang=KerimAnkaUIDB and KerimAnkaUIDB.language or'en';return(words[lang]or words.en)[index]end
function P.TextButton(button,scope,delta)
 if button.SetEnabled then button:SetEnabled(not InCombatLockdown()and(delta<0 and P.Level(scope)>0 or delta>0 and P.Level(scope)<3))end
 button:SetScript('OnEnter',function(self)GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText(P.Tip(delta<0 and 1 or 2));K.InventoryTooltip(GameTooltip);GameTooltip:Show()end)
 button:SetScript('OnLeave',function()GameTooltip:Hide()end)
end
local function AnchoredScale(frame,scale)
 if frame:GetScale()==scale then return end
 local effective=frame:GetEffectiveScale();local left=frame.GetLeft and frame:GetLeft();local top=frame.GetTop and frame:GetTop()
 frame:SetScale(scale)
 local after=frame:GetEffectiveScale()
 if left and top and after and after>0 then
  frame:ClearAllPoints();frame:SetPoint('TOPLEFT',UIParent,'BOTTOMLEFT',left*effective/after,top*effective/after)
 end
end
function P.SavePosition(frame)
 if not K.db or not frame.GetCenter then return end
 local x,y=frame:GetCenter();local px,py=UIParent:GetCenter();local scale=frame:GetEffectiveScale();local parent=UIParent:GetEffectiveScale()
 if x and y and px and py and scale>0 then local d=Config('bag',true);d.x=x-px*parent/scale;d.y=y-py*parent/scale end
end
function P.Stop(frame,scope)
 local grip=frame.kaPresentationGrip;if not grip or not grip.drag then return end
 grip.drag=nil;grip:SetScript('OnUpdate',nil)
 if K.db then Config(scope,true).windowScale=frame:GetScale();if scope=='bag'then P.SavePosition(frame)end end
end
function P.AttachGrip(frame,scope)
 if frame.kaPresentationGrip then return frame.kaPresentationGrip end
 local grip=CreateFrame('Button',nil,frame,'BackdropTemplate');frame.kaPresentationGrip=grip
 grip:SetSize(18,18);grip:SetPoint('BOTTOMRIGHT',-3,3);grip:SetFrameLevel(frame:GetFrameLevel()+12);grip:RegisterForClicks('LeftButtonUp','RightButtonUp')
 for i=1,3 do
  local t=grip:CreateTexture(nil,'OVERLAY');t:SetColorTexture(.78,.76,.66,1);t:SetSize(3+i*3,1);t:SetPoint('BOTTOMRIGHT',-2-i*2,2+i*2)
  if t.SetRotation then t:SetRotation(math.pi/4)end
 end
 grip:SetScript('OnEnter',function(self)GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText(P.Tip(3));K.InventoryTooltip(GameTooltip);GameTooltip:Show()end)
 grip:SetScript('OnLeave',function()GameTooltip:Hide()end)
 grip:SetScript('OnMouseDown',function(_,button)
  if button~='LeftButton'or grip.drag or InCombatLockdown()or GetCursorInfo and GetCursorInfo()or not GetCursorPosition then return end
  local x,y=GetCursorPosition();local e=frame:GetEffectiveScale()
  if not x or not y or not e or e<=0 then return end
  frame:StopMovingOrSizing()
  grip.drag={x=x,y=y,scale=frame:GetScale(),w=frame:GetWidth()*e,h=frame:GetHeight()*e}
  grip:SetScript('OnUpdate',function()
   if InCombatLockdown()or not IsMouseButtonDown('LeftButton')then P.Stop(frame,scope);return end
   local dx,dy=GetCursorPosition();local d=grip.drag;if not dx or not dy then P.Stop(frame,scope);return end
   dx,dy=dx-d.x,d.y-dy
   if math.abs(dx)<3 and math.abs(dy)<3 then return end
   local scale=math.floor(Clamp(d.scale*(1+(dx*d.w+dy*d.h)/(d.w*d.w+d.h*d.h)),.7,1.5,1)*100+.5)/100
   AnchoredScale(frame,scale)
  end)
 end)
 grip:SetScript('OnMouseUp',function()P.Stop(frame,scope)end)
 grip:SetScript('OnClick',function(_,button)
  if button=='RightButton'and not InCombatLockdown()and K.db then P.Stop(frame,scope);Config(scope,true).windowScale=1;AnchoredScale(frame,1);if scope=='bag'then P.SavePosition(frame)end end
 end)
 frame:HookScript('OnHide',function()P.Stop(frame,scope)end)
 return grip
end
function P.Window(frame,scope,organized)
 local grip=frame.kaPresentationGrip or(not organized and P.AttachGrip(frame,scope))
 if organized then P.Stop(frame,scope);if grip then grip:Hide()end;AnchoredScale(frame,1);return end
 local d=Config(scope);if not grip.drag then AnchoredScale(frame,Clamp(d and d.windowScale,.7,1.5,1))end
 grip:Show()
end
