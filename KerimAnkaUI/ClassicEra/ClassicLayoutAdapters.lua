-- Explicit KerimAnka position adapters. No Blizzard frame discovery or third-party movers.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local A={};K.LayoutAdapters=A
local function Copy(v)if type(v)~='table'then return v end;local o={};for k,x in pairs(v)do o[k]=Copy(x)end;return o end
A.Copy=Copy
local function Root(key,create)if not K.db then return end;if create and type(K.db[key])~='table'then K.db[key]={}end;return K.db[key]end
local function Ratio(f)return f and f:GetEffectiveScale()/UIParent:GetEffectiveScale()or 1 end
local factors={CENTER={0,0},LEFT={-.5,0},RIGHT={.5,0},TOP={0,.5},BOTTOM={0,-.5},TOPLEFT={-.5,.5},TOPRIGHT={.5,.5},BOTTOMLEFT={-.5,-.5},BOTTOMRIGHT={.5,-.5}}
local function Center(f,seen)
 if not f then return end
 if f==UIParent then return UIParent:GetWidth()/2,UIParent:GetHeight()/2 end
 local x,y=f:GetCenter();local r=Ratio(f)
 if x and y then return x*r,y*r end
 -- Hidden target/pet/cast widgets may not have resolved screen coordinates yet.
 if not f.GetPoint then return end;seen=seen or{};if seen[f]then return end;seen[f]=true
 local point,relative,relativePoint,dx,dy=f:GetPoint(1)
 if type(relative)=='string'then relative=_G[relative]end
 if not point or not relative then return end
 local cx,cy=Center(relative,seen);local p=factors[point];local q=factors[relativePoint or point]
 if cx and cy and p and q then local rr=Ratio(relative);return cx+relative:GetWidth()*rr*q[1]+(dx or 0)*r-f:GetWidth()*r*p[1],cy+relative:GetHeight()*rr*q[2]+(dy or 0)*r-f:GetHeight()*r*p[2]end
end
A.Center=Center
local function UnitValue(key,value)
 for _,field in ipairs(K.UnitProfileFields or{})do if field[1]==key and field[5]and field[6]then return math.max(field[5],math.min(field[6],value))end end
 return value
end
function A.Build()
 local list={}
 local function Add(id,label,page,section,scope,fields,frame,refresh,base,move,enabled,option)
  if not enabled or not scope or not scope(false)and not base then return end
  local a={id=id,label=label,page=page,section=section,frame=frame,option=option}
  function a.Capture()local d=scope(false)or{};local out={};for _,key in ipairs(fields)do if d[key]~=nil then out[key]=Copy(d[key])end end;return out end
  function a.Restore(values,quiet)local d=scope(true);if not d then return false end;for _,key in ipairs(fields)do d[key]=Copy(values[key])end;if not quiet and refresh then refresh()end;return true end
  a.Base=base or function()local d=scope(false)or{};return{x=d.x or 0,y=d.y or 0}end
  function a.Move(dx,dy,start)if move then move(dx,dy,start)else local d=scope(true);d.x=start.x+dx;d.y=start.y+dy;if refresh then refresh()end end end
  a.Refresh=refresh;list[#list+1]=a
 end
 local function Basic(id,label,page,section,key,api,frame,normalize)
  if not api or not api.Get or api.Get('enabled')==false or not frame then return end
  local function scope(create)return Root(key,create)end
  Add(id,label,page,section,scope,{'x','y'},frame,api.Refresh,function()return{x=api.Get('x')or 0,y=api.Get('y')or 0}end,
   function(dx,dy,s)local d=scope(true);d.x=s.x+dx/(normalize and UIParent:GetWidth()or 1);d.y=s.y+dy/(normalize and UIParent:GetHeight()or 1);if normalize then d.x=math.max(0,math.min(1,d.x));d.y=math.max(0,math.min(1,d.y))end;api.Refresh()end,true)
 end
 Basic('sound','soundShortcutTitle','home','sounds','soundShortcut',K.SoundShortcut,_G.KerimAnkaUISoundShortcut,true)
 Basic('fps','leFPS','home','overview','fps',K.FPS,_G.KerimAnkaUIFPS)
 Basic('bagShortcut','bsTitle','inventory',nil,'bagShortcut',K.BagShortcut,_G.KerimAnkaUIBagShortcut,true)
 Basic('experience','experience','experience',nil,'experience',K.Experience,K.Experience and K.Experience.hud)
 local units=ForeverLeatherUnitsAPI;local u=units and units.GetSettings()
 if u then
  for _,unit in ipairs({'player','target','targettarget','pet'})do
   local key=unit;local f=_G['ForeverLeatherUnit_'..unit]
   local active=u.enabled and(unit~='targettarget'or u.showToT)and(unit~='pet'or u.showPet and units.SupportsPet())
   if type(u[key])=='table'and f then
    Add('unit.'..key,key=='player'and'upPlayer'or key=='target'and'upTarget'or key=='pet'and'upPet'or'leToT','units',nil,function()return u[key]end,{'x','y','detached'},f,units.Apply,
     function()local x,y=Center(f);return{x=x and x-UIParent:GetWidth()/2 or u[key].x,y=y or u[key].y}end,
     function(dx,dy,s)u[key].x=s.x+dx;u[key].y=s.y+dy;if key=='pet'or key=='targettarget'then u[key].detached=true end;units.Apply()end,active)
   end
  end
  local combo=KerimAnkaUIClassicCombo
  if combo and combo.Wanted()then
   Add('combo','uf_showCombo','units',nil,function(create)if create and not u.comboDetached then u.comboDetached={}end;return u.comboDetached end,{'x','y'},_G.KerimAnkaUIClassicComboFrame,combo.Refresh,
    function()local c=combo.Settings();return{x=c.x,y=c.y}end,function(dx,dy,s)local c=combo.Settings();c.x=s.x+dx;c.y=s.y+dy;combo.Refresh()end,true,'showCombo')
  end
 end
 local swing=K.ClassicSwingTimer;local s=swing and swing.GetSettings()
 if s and s.enabled then
  for _,hand in ipairs({'mainhand','offhand','ranged'})do
   local h=hand;local f=swing.Frames[h]
   if f and s.hands[h]then
    Add('swing.'..h,h=='mainhand'and'swMain'or h=='offhand'and'swOff'or'swRanged','home','combat',function(create)s.positions=s.positions or{};if create and not s.positions[h]then s.positions[h]={}end;return s.positions[h]end,{'point','relativePoint','x','y'},f,
     function()swing.SetBar(h,'width',s.bars[h].width);local p=s.positions[h];f:ClearAllPoints();if p and p.x then f:SetPoint(p.point or'CENTER',UIParent,p.relativePoint or'BOTTOMLEFT',p.x,p.y)else f:SetPoint('CENTER',UIParent,'CENTER',0,-100-(h=='offhand'and 30 or h=='ranged'and 60 or 0))end end,
     function()local x,y=Center(f);return{x=x,y=y,scale=Ratio(f)}end,
     function(dx,dy,b)s.positions[h]={point='CENTER',relativePoint='BOTTOMLEFT',x=(b.x+dx)/b.scale,y=(b.y+dy)/b.scale};f:ClearAllPoints();f:SetPoint('CENTER',UIParent,'BOTTOMLEFT',s.positions[h].x,s.positions[h].y)end,true)
   end
  end
 end
 local cast=K.ClassicCastBar;local c=cast and cast.GetSettings()
 if c and c.enabled and cast.holder then
  Add('cast','pcTitle','home','combat',function()return c end,{'x','y'},cast.holder,cast.Refresh,function()return{x=c.x,y=c.y,scale=Ratio(cast.holder)}end,
   function(dx,dy,b)c.x=b.x+dx/b.scale;c.y=b.y+dy/b.scale;cast.Refresh()end,true)
 end
 local coords=K.MinimapCoordinates
 if coords and coords.Get('enabled')and coords.Available()then
  Add('coordinates','leCoordinates','minimap',nil,function(create)return Root('minimapCoords',create)end,{'x','y'},coords.frame,coords.Refresh,
   function()return{x=coords.Get('x'),y=coords.Get('y'),scale=Ratio(Minimap)}end,
   function(dx,dy,b)coords.Set('x',b.x+dx/b.scale);coords.Set('y',b.y+dy/b.scale)end,true)
 end
 local map=K.ClassicMinimapControls
 if map then
  local container=MinimapCluster and MinimapCluster.MinimapContainer
  for _,entry in ipairs({{'clock','leClock','clockX','clockY','clockCustom',_G.TimeManagerClockButton or container and container.Clock},{'sun','leSun','sunX','sunY','sunCustom',_G.DielFrame or container and container.DielFrame or _G.GameTimeFrame}})do
   local e=entry
   if e[6]then
    Add('minimap.'..e[1],e[2],'minimap',nil,function(create)return Root('minimapControls',create)end,{e[3],e[4],e[5]},e[6],map.Refresh,
     function()return{x=map.Get(e[3]),y=map.Get(e[4]),scale=Ratio(Minimap)}end,
     function(dx,dy,b)map.Set(e[3],b.x+dx/b.scale);map.Set(e[4],b.y+dy/b.scale)end,true)
   end
  end
 end
 for _,entry in ipairs({{'range','range',ForeverHunterRangeAPI,_G.ForeverHunterRangeBar},{'threat','threat',ForeverThreatAPI,_G.ForeverThreatDisplay}})do
  local e=entry;local api=e[3];local d=api and api.GetSettings()
  if d and d.enabled then Add(e[1],e[2],e[1],nil,function()return d end,{'x','y'},e[4],function()api.Set('x',d.x)end,nil,function(dx,dy,b)api.Set('x',b.x+dx);api.Set('y',b.y+dy)end,true)end
 end
 -- Class decoration follows action-bar bounds. Offsetting its anchor can expand
 -- connected artwork (notably Paladin), so it is not a freely movable widget.
 local chat=K.Chat
 if chat and chat.Enabled()then
  local d=chat.ManagedBounds();local primary=GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.primary or ChatFrame1
  local frame=chat.shells[primary]
  if d and frame then Add('chat','Chat','chat',nil,chat.ManagedBounds,{'x','y','width','height','controlMode','microGap','microSize'},frame,chat.Refresh,
   function()return{x=d.x,y=d.y}end,function(dx,dy,b)d.x=b.x+dx;d.y=b.y+dy;chat.Refresh()end,true)end
 end
 local menus=K.InventoryMenus
 if menus and menus.Get('microEnabled')and _G.MicroMenuContainer and not(chat and chat.Enabled()and chat.GetMicroDock())then
  Add('micro','imMicro','home','imMicro',function()return K.db end,{'microX','microY'},MicroMenuContainer,menus.Refresh,
   function()local x=MicroMenuContainer:GetLeft();local y=MicroMenuContainer:GetBottom();return{x=(x or 0)*Ratio(MicroMenuContainer),y=(y or 0)*Ratio(MicroMenuContainer)}end,
   function(dx,dy,b)menus.Set('microX',b.x+dx);menus.Set('microY',b.y+dy)end,true)
 end
 -- Only the already open custom bag belongs here; bank/recorded windows remain transient windows.
 local bag=_G.KerimAnkaUIClassicBagFrame
 if bag and bag:IsShown()and K.ClassicBags and K.ClassicBags.Enabled()then
  Add('bags','leBags','inventory',nil,function(create)return Root('classicBags',create)end,{'x','y'},bag,K.ClassicBags.Refresh,
   function()local x,y=Center(bag);return{x=x-UIParent:GetWidth()/2,y=y-UIParent:GetHeight()/2}end,nil,true)
 end
 local widgets=ForeverUnitsCombatWidgets
 if u and u.enabled and widgets and widgets.GetLayoutElements then
  local holders,castFrame=widgets.GetLayoutElements()
  for _,unit in ipairs({'player','target','pet'})do
   for _,kind in ipairs({'Buff','Debuff'})do
    local id=unit..kind;local xKey=id..'X';local yKey=id..'Y';local f=holders[unit]and holders[unit][kind..'s']
    if u[id..'s']and f then
     Add('aura.'..id,unit=='player'and(kind=='Buff'and'lePlayerBuffs'or'lePlayerDebuffs')or unit=='target'and(kind=='Buff'and'leTargetBuffs'or'leTargetDebuffs')or(kind=='Buff'and'lePetBuffs'or'lePetDebuffs'),'units',nil,function()return u end,{xKey,yKey},f,units.Apply,
      function()return{x=u[xKey],y=u[yKey],scale=Ratio(f)}end,
      function(dx,dy,b)u[xKey]=UnitValue(xKey,b.x+dx/b.scale);u[yKey]=UnitValue(yKey,b.y+dy/b.scale);units.Apply()end,true,xKey)
    end
   end
  end
  if u.targetCastEnabled and castFrame then
   Add('targetCast','uf_targetCastEnabled','units',nil,function()return u end,{'castX','castY'},castFrame,units.Apply,
    function()return{x=u.castX,y=u.castY,scale=Ratio(castFrame)}end,
    function(dx,dy,b)u.castX=UnitValue("castX",b.x+dx/b.scale);u.castY=UnitValue("castY",b.y+dy/b.scale);units.Apply()end,true,'castX')
  end
 end
 local aspect=HunterAspectAlertAPI;local aspectDB=aspect and aspect.GetSettings();local aspectFrame=_G.HunterAspectAlertPanel
 if aspectDB and aspectDB.enabled and aspectFrame then
  local function ApplyAspect()
   aspectFrame:ClearAllPoints();local p=aspectDB.position
   if p then aspectFrame:SetPoint(p[1],UIParent,p[2],p[3],p[4])else aspectFrame:SetPoint('CENTER',UIParent,'CENTER',0,100)end
   aspect.RefreshText()
  end
  Add('aspect','aspect','aspect',nil,function()return aspectDB end,{'position'},aspectFrame,ApplyAspect,
   function()local x,y=Center(aspectFrame);return{x=x,y=y,scale=Ratio(aspectFrame)}end,
   function(dx,dy,b)aspectDB.position={'CENTER','BOTTOMLEFT',(b.x+dx)/b.scale,(b.y+dy)/b.scale};ApplyAspect()end,true)
 end
 local drawer=K.MinimapButtons;local drawerFrame=_G.KerimAnkaUIIconDrawer
 if drawer and drawer.Get('enabled')and not drawer.IsBlocked()and drawerFrame then
  Add('drawer','mbTitle','minimap',nil,function(create)return Root('minimapButtons',create)end,{'angle'},drawerFrame,drawer.Refresh,
   function()local x,y=Center(drawerFrame);local mx,my=Center(Minimap);return{x=x,y=y,mx=mx,my=my}end,
   function(dx,dy,b)drawer.Set('angle',math.deg(math.atan2(b.y+dy-b.my,b.x+dx-b.mx)))end,true)
 end
 if K.LayoutElements then K.LayoutElements.AddDisabled(list)end
 return list
end

-- Recover positions even when a conditional feature/window is not visible after reload.
function A.RestoreRecord(id,values)
 if type(values)~='table'then return false end
 local roots={sound='soundShortcut',fps='fps',bagShortcut='bagShortcut',experience='experience',coordinates='minimapCoords',cast='classicCast',bags='classicBags',drawer='minimapButtons',['minimap.clock']='minimapControls',['minimap.sun']='minimapControls'}
 local d,fields
 if roots[id]then
  d=Root(roots[id],true);fields=id=='drawer'and{'angle'}or id=='minimap.clock'and{'clockX','clockY','clockCustom'}or id=='minimap.sun'and{'sunX','sunY','sunCustom'}or{'x','y'}
 elseif id=='art'then
  -- Recover an unfinished session from older editor versions through the same
  -- provider-aware settings view used by the class-design page.
  local api=ForeverClassArtLayoutAPI
  d=api and api.GetSettings();fields={'x','y'}
 elseif id=='chat'then d=Root('chat',true);fields={'x','y','width','height','controlMode','microGap','microSize'}
 elseif id=='micro'then d=K.db;fields={'microX','microY'}
 elseif id:match('^unit%.')then
  local key=id:sub(6);if key~='player'and key~='target'and key~='targettarget'and key~='pet'then return false end
  local u=KAClassic_ForeverLeatherUnitsDB;if type(u)~='table'then return false end;u[key]=u[key]or{};d=u[key];fields={'x','y','detached'}
 elseif id=='combo'then
  local u=KAClassic_ForeverLeatherUnitsDB;if type(u)~='table'then return false end;u.comboDetached=u.comboDetached or{};d=u.comboDetached;fields={'x','y'}
 elseif id:match('^swing%.')then
  local key=id:sub(7);if key~='mainhand'and key~='offhand'and key~='ranged'then return false end
  local sw=Root('classicSwing',true);sw.positions=sw.positions or{};sw.positions[key]=sw.positions[key]or{};d=sw.positions[key];fields={'point','relativePoint','x','y'}
 elseif id:match('^aura%.')then
  local key=id:sub(6);local valid=false;for _,unit in ipairs({'player','target','pet'})do for _,kind in ipairs({'Buff','Debuff'})do if key==unit..kind then valid=true end end end
  if not valid or type(KAClassic_ForeverLeatherUnitsDB)~='table'then return false end;d=KAClassic_ForeverLeatherUnitsDB;fields={key..'X',key..'Y'}
 elseif id=='targetCast'then d=KAClassic_ForeverLeatherUnitsDB;fields={'castX','castY'}
 elseif id=='range'then d=KAClassic_ForeverHunterRangeDB;fields={'x','y'}
 elseif id=='threat'then d=KAClassic_ForeverThreatDB;fields={'x','y'}
 elseif id=='aspect'then d=KAClassic_HunterAspectAlertCharacterDB;fields={'position'}
 end
 if type(d)~='table'or not fields then return false end
 for _,key in ipairs(fields)do d[key]=Copy(values[key])end
 if id=='art'and ForeverClassArtLayoutAPI.Refresh then ForeverClassArtLayoutAPI.Refresh()end
 return true
end
