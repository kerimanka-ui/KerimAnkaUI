-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local function Refresh()
 C_Timer.After(0,function() if K.window and K.window:IsShown() then K.Render() end end)
end
local function BackingColors(page,w,y)
 local api=ForeverBackingColor
 local layout=ForeverClassArtLayoutAPI
 local d=layout and layout.GetSettings()
 if not api or not d then return y end
 local card=w.Box(page,0,y,714,202)
 w.Text(card,K.L('backingColorTitle'),16,-12,680,16)
 w.Text(card,K.L('backingColorHelp'),16,-38,680,13,{.65,.70,.62})
 local enabled=d.backingColorEnabled==true
 local c=api.Valid(d.backingColor) and d.backingColor or {.65,.59,.46}
 local original=w.Button(card,K.L('backingOriginal'),16,-83,220,32,function()
  if api.Set(false) then Refresh() end
 end)
 w.Selected(original,not enabled)
 local custom=w.Button(card,K.L('backingCustom'),246,-83,220,32,function()
  if api.Set(true,c) then Refresh() end
 end)
 w.Selected(custom,enabled)
 local color
 color=w.Button(card,K.L('backingPickColor'),476,-83,222,32,function()
  if K.InCombat() then return end
  local picker=ColorPickerFrame
  if not picker or not picker.SetupColorPickerAndShow then return end
  local before=d.backingColor and {unpack(d.backingColor)}
  local beforeEnabled=d.backingColorEnabled==true
  picker:SetupColorPickerAndShow({r=c[1],g=c[2],b=c[3],hasOpacity=false,
   swatchFunc=function()
    local r,g,b=picker:GetColorRGB()
    if api.Set(true,{r,g,b}) then c={r,g,b};color.backingSwatch:SetColorTexture(r,g,b,1);w.Selected(original,false);w.Selected(custom,true) end
   end,
   cancelFunc=function()
    -- Restoring saved cosmetic settings is safe; the artwork update itself
    -- already defers protected positioning during combat.
    d.backingColorEnabled=beforeEnabled;d.backingColor=before
    layout.Refresh();Refresh()
   end})
  if picker.Raise then picker:Raise() end
 end)
 if not color.backingSwatch then color.backingSwatch=color:CreateTexture(nil,'ARTWORK') end
 color.backingSwatch:ClearAllPoints();color.backingSwatch:SetPoint('RIGHT',-8,0)
 color.backingSwatch:SetSize(16,16);color.backingSwatch:SetColorTexture(c[1],c[2],c[3],1)
 local presets={{'backingCream',{.65,.59,.46}},{'backingBrown',{.20,.115,.065}},{'backingGrey',{.12,.13,.14}},{'backingBlack',{0,0,0}}}
 for i,p in ipairs(presets) do
  local rgb=p[2]
  local b=w.Button(card,K.L(p[1]),16+(i-1)*173,-130,163,30,function() if api.Set(true,rgb) then Refresh() end end)
  if K.InCombat() then b:Disable() end
 end
 w.Text(card,K.L('backingOpacityHelp'),16,-174,680,12,{.65,.70,.62})
 if K.InCombat() then original:Disable();custom:Disable();color:Disable() end
 return y-220
end

local function SkinChooser(page,w,y)
 local api=ForeverClassArtSkins
 if not api or not api.Available() then return y end
 local warlock=select(2,UnitClass("player"))=="WARLOCK"
 local shaman=select(2,UnitClass("player"))=="SHAMAN"
 local mage=select(2,UnitClass("player"))=="MAGE"
 local priest=select(2,UnitClass("player"))=="PRIEST"
 local druid=select(2,UnitClass("player"))=="DRUID"
 local count=api.Count and api.Count() or 2
 local paladin=select(2,UnitClass("player"))=="PALADIN"
 local tall=shaman or mage or priest or druid or paladin
 w.Text(page,K.L("artSkins"),8,y,690,18,{.73,.62,.41});y=y-34
 for id=1,count do
  local skin=id
  local card=w.Box(page,(id-1)%2*365,y-math.floor((id-1)/2)*(tall and 266 or warlock and 233 or 208),349,tall and 248 or warlock and 215 or 190)
  w.Text(card,K.L(api.Name and api.Name(id) or (id==1 and "artSkinHunter" or "artSkinMetal")),14,-12,300,14)
  if not card.skinPreview then card.skinPreview=card:CreateTexture(nil,"ARTWORK") end
  local preview=card.skinPreview
  preview:ClearAllPoints();preview:SetPoint("TOPLEFT",card,"TOPLEFT",14,-36);preview:SetSize(321,tall and 160.5 or warlock and 128.37 or 107)
  preview:SetTexture(api.Path(id),"CLAMP","CLAMP","TRILINEAR");if api.PreviewTexCoord then preview:SetTexCoord(api.PreviewTexCoord(id)) else preview:SetTexCoord(0,1,0,1) end;preview:Show()
  local selected=api.Get()==id
  local button=w.Button(card,K.L(selected and "artSkinSelected" or "artSkinUse"),14,tall and -205 or warlock and -173 or -148,321,30,function()
   if not K.InCombat() and api.Set(skin) then Refresh() end
  end)
  w.Selected(button,selected)
  if selected or K.InCombat() then button:Disable() end
  w.Tip(button,"artSkins",select(2,UnitClass("player"))=="WARRIOR" and "artSkinWarriorHelp" or "artSkinHelp")
 end
 return y-math.ceil(count/2)*(tall and 266 or warlock and 233 or 208)
end

local function SourceChooser(page,w,y)
 local api=KerimAnkaUIBarsAPI
 if not api then return y end
 local card=w.Box(page,0,y,714,194)
 w.Text(card,K.L("barsSource"),16,-14,620,16)
 local help=w.Button(card,"?",676,-12,22,22,function() end);w.Tip(help,"barsSource","barsSourceHelp")
 for i,key in ipairs({"barsAuto","barsNative","barsBT"}) do
  local value=i-1
  local button=w.Button(card,K.L(key),(i-1)*230+16,-46,222,34,function()
   if api.SetPreference(value) then Refresh() end
  end)
  w.Selected(button,api.Preference()==value)
  if api.Preference()==value or InCombatLockdown() then button:Disable() end
 end
 w.Text(card,K.L(api.Status()),16,-94,680,13,{.73,.62,.41})
 local source,blocked=api.Resolve()
 local editor=w.Button(card,K.L("barsEditor"),16,-150,682,30,function() api.OpenNativeLayout() end)
 if source~="blizzard" or blocked or InCombatLockdown() then editor:Disable() end
 return y-212
end

-- Reuse the artwork modules' validated getters/setters inside the hub.
-- These controls used to be available only in the separate AceConfig window.
function K.DrawArtExtras(page,w,y,onlyPet,onlyMinimap)
 if not onlyPet and not onlyMinimap then y=BackingColors(page,w,y) end
 local groups={}
 if onlyMinimap and ForeverClassArtMinimap then groups[#groups+1]={key="minimap",options=ForeverClassArtMinimap.Options()} end
 if not onlyMinimap and ForeverClassArtBarPanel then groups[#groups+1]={key="backing",options=ForeverClassArtBarPanel.Options(function() return ForeverClassArtLayoutAPI and ForeverClassArtLayoutAPI.GetSettings() or KAClassic_ForeverHunterArtCharacterDB end)} end
 if onlyPet then groups={} end
 if not onlyMinimap and ForeverPetBarPanel then groups[#groups+1]={key="petBar",options=ForeverPetBarPanel.Options()} end
 local function eval(value) if type(value)=="function" then return value({}) end; return value end
 for _,group in ipairs(groups) do
  local options=group.options
  if not eval(options.hidden) then
   local shaman=group.key=="backing" and select(2,UnitClass("player"))=="SHAMAN"
   local paladin=group.key=="backing" and select(2,UnitClass("player"))=="PALADIN"
   local druid=group.key=="backing" and select(2,UnitClass("player"))=="DRUID"
   local priest=group.key=="backing" and select(2,UnitClass("player"))=="PRIEST"
   local mage=group.key=="backing" and select(2,UnitClass("player"))=="MAGE"
   local ritual=group.key=="backing" and select(2,UnitClass("player"))=="WARLOCK"
   w.Text(page,K.L(paladin and "paladinArtTitle" or druid and "druidArtTitle" or priest and "priestArtTitle" or mage and "mageArtTitle" or shaman and "shamanArtTitle" or ritual and "warlockArtTitle" or (select(2,UnitClass("player"))=="PALADIN" and group.key=="backing") and "backingColorTitle" or "art_"..group.key),8,y,690,18,{.73,.62,.41}); y=y-38
   if group.key=="petBar" and KerimAnkaUIBarsAPI.PetSource()=="unavailable" then
    w.Text(page,K.L("petBarBTDisabled"),8,y,690,13,{.87,.73,.40});y=y-84
   end
   if paladin then w.Text(page,K.L("paladinArtHelp"),8,y,690,13,{.65,.70,.62});y=y-98 end
   if druid then w.Text(page,K.L("druidArtHelp"),8,y,690,13,{.65,.70,.62});y=y-98 end
   if priest then w.Text(page,K.L("priestArtHelp"),8,y,690,13,{.65,.70,.62});y=y-98 end
   if mage then w.Text(page,K.L("mageArtHelp"),8,y,690,13,{.65,.70,.62});y=y-98 end
   if shaman then w.Text(page,K.L("shamanArtHelp"),8,y,690,13,{.65,.70,.62});y=y-98 end
   if ritual then w.Text(page,K.L("warlockRitualHelp"),8,y,690,13,{.65,.70,.62});y=y-98 end
   local entries={}
   for key,option in pairs(options.args) do
    if option.type~="description" and not eval(option.hidden) then entries[#entries+1]={key=key,option=option} end
   end
   table.sort(entries,function(a,b) return (a.option.order or 0)<(b.option.order or 0) end)
   for i,entry in ipairs(entries) do
    local option,key=entry.option,entry.key
    local disabled=InCombatLockdown() or eval(options.disabled) or eval(option.disabled)
    local card=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
    local label="art_"..key
    w.Text(card,K.L(label),14,-12,278,13)
    w.Tip(card,label,key=="hideBorder" and "art_hideBorderHelp" or "art_artExtraHelp")
    if option.type=="toggle" then
     w.Switch(card,option.get({})==true,255,-48,function(v)
      if not K.InCombat() and not eval(options.disabled) and not eval(option.disabled) then option.set({},v) end
     end,not disabled)
    elseif option.type=="range" then
     local step=option.step or 1
     local function format(v) return string.format(step<1 and "%.2f" or "%.0f",v) end
     local value=w.Text(card,format(option.get({})),14,-54,150,15)
     local function change(delta)
      if K.InCombat() or eval(options.disabled) or eval(option.disabled) then return end
      local requested=math.max(option.min,math.min(option.max,option.get({})+delta*step))
      option.set({},requested); value:SetText(format(option.get({})))
     end
     local minus=w.Button(card,"−",251,-47,36,32,function() change(-1) end)
     local plus=w.Button(card,"+",297,-47,36,32,function() change(1) end)
     if disabled then minus:Disable(); plus:Disable() end
    elseif option.type=="execute" then
     local button=w.Button(card,K.L(label),14,-44,319,32,function()
      if not K.InCombat() and not eval(options.disabled) and not eval(option.disabled) then option.func({}); Refresh() end
     end)
     if disabled then button:Disable() end
    end
   end
   y=y-math.ceil(#entries/2)*96-12
  end
 end
 return y
end
local function BarList(page,w,y,db,set,helpKey,available)
 w.Text(page,K.L(KerimAnkaUIBarsAPI and KerimAnkaUIBarsAPI.Resolve()=="blizzard" and "barsNativeList" or "abBars"),8,y,690,18,{.73,.62,.41}); y=y-36
 if not available then w.Text(page,K.L("barsLocked"),8,y,690,13,{.73,.62,.41}); y=y-48 end
 local barCount=KerimAnkaUIBarsAPI and KerimAnkaUIBarsAPI.Count() or 10
 for bar=1,barCount do
  local n=bar
  local col=(bar-1)%2; local row=math.floor((bar-1)/2)
  local chosen=false; for _,id in ipairs(db.bars) do if id==n then chosen=true end end
  local card=w.Box(page,col*365,y-row*62,349,52)
  w.Text(card,K.L("abBar").." "..n,14,-16,180,14)
  w.Switch(card,chosen,255,-11,function(enabled)
   if K.InCombat() then return end
   local bars={}; for id=1,barCount do
    local keep=false; for _,old in ipairs(db.bars) do if old==id then keep=true end end
    if id==n then keep=enabled end
    if keep then bars[#bars+1]=id end
   end
   if #bars==0 then K.Message("abMin"); return end
   set(bars)
  end,available)
  w.Tip(card,"abBars",helpKey)
 end
 return y-math.ceil(barCount/2)*62
end
function K.DrawActionBarPage(page,kind)
 local w=K.UnitWidgets
 local backdrop=kind=="backdrop"
 local api=ForeverBarBackdropAPI
 local db=backdrop and api and api.GetSettings() or (not backdrop and ForeverClassArtLayoutAPI and ForeverClassArtLayoutAPI.GetSettings()) or (not backdrop and KAClassic_ForeverHunterArtCharacterDB)
 if type(db)~="table" then return false end
 local _,class=UnitClass("player")
 -- Registered class skins automatically enable the shared settings page.
 -- Keep the original classes whose single-theme artwork has no skin selector.
 local skins=ForeverClassArtSkins
 local supported=backdrop or (skins and skins.Available and skins.Available())
  or class=="HUNTER" or class=="ROGUE" or class=="WARRIOR" or class=="PALADIN" or class=="WARLOCK"
 local helpKey=backdrop and "abHelp" or "abArtHelp"
 local function set(key,value)
  if K.InCombat() or not supported then return false end
  if backdrop then return api.Set(key,value) end
  local command=key=="enabled" and (value and "show" or "hide") or key.." "..tostring(value)
  if SlashCmdList.FOREVERHUNTERART then SlashCmdList.FOREVERHUNTERART(command,true); return true end
  return false
 end
 w.Text(page,K.L("abIntro"),8,0,690,13,{.65,.70,.62})
 local y=SourceChooser(page,w,-58)
 if KerimAnkaUIBarsAPI.Resolve()=="blizzard" then
  for _,key in ipairs({"hideNativeHotkeys","hideNativeMacroNames"}) do
   local labelKey=key
   local box=w.Box(page,0,y,714,62)
   w.Text(box,K.L(labelKey),16,-20,550,14)
   local help=w.Button(box,"?",584,-20,22,22,function() end)
   w.Tip(help,labelKey,labelKey.."Help")
   w.Switch(box,K.db[labelKey]==true,620,-16,function(value) K.SetActionBarLabel(labelKey,value) end,not InCombatLockdown())
   y=y-80
  end
 end
 if backdrop and K.DrawActionRange then y=K.DrawActionRange(page,w,y) end
 if not supported then w.Text(page,K.L("abUnsupported"),8,y,690,15); if not backdrop then y=K.DrawArtExtras(page,w,y-40,true) end;page:SetHeight(-y+80);return true end
 local card=w.Box(page,0,y,714,62)
 w.Text(card,K.L(backdrop and "abShow" or "abArt"),16,-20,490,15)
 local help=w.Button(card,"?",584,-20,22,22,function() end); w.Tip(help,backdrop and "abShow" or "abArt",helpKey)
 w.Switch(card,db.enabled==true,620,-16,function(value) set("enabled",value) end,true)
 y=y-80
 if not backdrop then
  local statues=w.Box(page,0,y,714,62)
  w.Text(statues,K.L("hideActionBarStatues"),16,-20,550,14)
  local help=w.Button(statues,"?",584,-20,22,22,function() end)
  w.Tip(help,"hideActionBarStatues","hideActionBarStatuesHelp")
  w.Switch(statues,K.db.hideActionBarStatues==true,620,-16,function(value)
   K.SetActionBarStatues(value)
  end,not K.InCombat())
  y=y-80
  y=SkinChooser(page,w,y)
  w.Text(page,K.L("abMode")..K.L(db.locked and "abFixed" or "abAuto"),8,y,690,14); y=y-35
  local fixed=w.Button(page,K.L("abLock"),0,y,349,36,function() if set("lock","") then Refresh() end end)
  if db.locked or not db.enabled or select(2,KerimAnkaUIBarsAPI.Resolve()) then fixed:Disable() end
  w.Tip(fixed,"abLock",helpKey)
  local follow=w.Button(page,K.L("abFollow"),365,y,349,36,function() if set("auto","") then Refresh() end end)
  w.Tip(follow,"abFollow",helpKey)
  y=y-56
 end
 local fields=backdrop and {{"shade","abShade",0,1,.05},{"border","abBorder",0,6,1},{"slotAlpha","abSlot",0,1,.05}}
  or {{"width","abWidth",20,300,1},{"height","abHeight",20,300,1},{"x","abX",-500,500,1},{"y","abY",-500,500,1},{"alpha","abAlpha",0,1,.05},{"gap","abGap",0,50,1}}
 local col=0
 for _,field in ipairs(fields) do
  local key,label,low,high,step=unpack(field)
  local c=w.Box(page,col*365,y,349,86)
  w.Text(c,K.L(label),14,-12,278,13)
  local tip=w.Button(c,"?",311,-10,22,22,function() end); w.Tip(tip,label,helpKey)
  local function format(value) return string.format(step<1 and "%.2f" or "%.0f",value) end
  local value=w.Text(c,format(db[key]),14,-54,150,15)
  local function change(delta)
   local requested=math.max(low,math.min(high,math.floor((db[key]+delta*step)/step+.5)*step))
   if set(key,requested) then value:SetText(format(db[key])) end
  end
  local minus=w.Button(c,"−",251,-47,36,32,function() change(-1) end)
  local plus=w.Button(c,"+",297,-47,36,32,function() change(1) end)
  if key=="gap" and db.locked then minus:Disable(); plus:Disable() end
  col=1-col; if col==0 then y=y-96 end
 end
 if col==1 then y=y-96 end
 if backdrop then y=BackingColors(page,w,y) end
 y=BarList(page,w,y,db,function(bars)
  if backdrop then api.Set("bars",bars)
  else local ids={}; for _,id in ipairs(bars) do ids[#ids+1]=tostring(id) end; set("bars",table.concat(ids," ")) end
 end,helpKey,backdrop or not db.locked)
 if not backdrop then
  local confirmed=false
  w.Button(page,K.L("art_artReset"),0,y,714,36,function(self)
   if K.InCombat() then return end
   if not confirmed then confirmed=true; self.label:SetText(K.L("art_artConfirm")); return end
   if set("reset","") then Refresh() end
  end)
  y=K.DrawArtExtras(page,w,y-56)
 end
 page:SetHeight(-y+20)
 return true
end




function K.DrawInventoryPage(page)
 local M=K.InventoryMenus;local w=K.UnitWidgets;local y=0
 w.Text(page,K.L(M.Status()),8,y,690,13,{.65,.70,.62});y=y-78
 local function Toggle(key,label,help)
  local box=w.Box(page,0,y,714,62)
  w.Text(box,K.L(label),16,-20,550,14)
  local tip=w.Button(box,"?",584,-20,22,22,function() end);w.Tip(tip,label,help)
  w.Switch(box,M.Get(key)==true,620,-16,function(value) M.Set(key,value);K.Render() end,not InCombatLockdown())
  y=y-78
 end
 local function Numbers(fields)
  for i,field in ipairs(fields) do
   local key,label,low,high=unpack(field)
   local box=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
   w.Text(box,K.L(label),14,-12,310,13)
   local value=w.Text(box,tostring(M.Get(key)),14,-54,150,15)
   for j,delta in ipairs({-1,1}) do
    local button=w.Button(box,delta==-1 and "−" or "+",j==1 and 251 or 297,-47,36,32,function()
     if M.Set(key,math.max(low,math.min(high,M.Get(key)+delta))) then value:SetText(tostring(M.Get(key))) end
    end)
    if InCombatLockdown() then button:Disable() end
   end
  end
  y=y-math.ceil(#fields/2)*96
 end
 if K.BagShortcut then y=K.BagShortcut.Draw(page,w,y) end
 w.Text(page,K.L("imBags"),8,y,690,18,{.73,.62,.41});y=y-34
 Toggle("bagCombined","imCombinedBags","imCombinedBagsHelp")
 Toggle("bagDock","imDock","imBagHelp")
 Toggle("bagExpanded","imExpanded","imBagHelp")
 Toggle("bagBackground","imBagBackground","imBagAppearanceHelp")
 Toggle("bagFrame","imBagFrame","imBagAppearanceHelp")
 Toggle("bagIconBorder","imBagIconBorder","imBagAppearanceHelp")
 Toggle("hideNativeBagBar","imHideNativeBar","imHideNativeBarHelp")
 Toggle("bagJunk","imJunk","imItemLooksHelp")
 Toggle("bagQuality","imQuality","imItemLooksHelp")
 Numbers({{"bagSize","imBagSize",18,48},{"bagGap","imGap",0,16}})
 if K.ClassicMerchant and K.ClassicMerchant.DrawSettings then y=K.ClassicMerchant.DrawSettings(page,w,y) end
 if K.ClassicBags and K.ClassicBags.DrawMoneyRecords then y=K.ClassicBags.DrawMoneyRecords(page,w,y) end
 if K.ClassicItemRecords and K.ClassicItemRecords.DrawSettings then y=K.ClassicItemRecords.DrawSettings(page,w,y) end
 w.Text(page,K.L("imMicro"),8,y-8,690,18,{.73,.62,.41});y=y-44
 Toggle("microEnabled","imManage","imMicroHelp")
 Toggle("microLocked","imLocked","imMoveHelp")
 Numbers({{"microSize","imIconSize",18,48},{"microGap","imGap",0,16}})
 local align=w.Button(page,K.L("imAlign"),0,y,349,36,function() M.AlignChat();K.Render() end)
 local reset=w.Button(page,K.L("imReset"),365,y,349,36,function()
  if InCombatLockdown() then return end
  for _,key in ipairs({"microSize","microGap","microX","microY","microLocked"}) do K.db[key]=nil end
  M.Refresh();K.Render()
 end)
 if InCombatLockdown() then align:Disable();reset:Disable() end
 w.Text(page,K.L("imMoveHelp"),8,y-58,690,13,{.65,.70,.62})
 page:SetHeight(-y+130)
end

function K.DrawErrorOptions(page)
 local w=K.UnitWidgets;local mode=K.ErrorMode()
 for i,key in ipairs({"errorShowAll","errorImportantOnly","errorCustom"}) do
  local button=w.Button(page,K.L(key),(i-1)*240,0,230,38,function() K.SetErrorMode(i);K.Render() end)
  w.Selected(button,i==mode)
  if i==mode or InCombatLockdown() then button:Disable() end
 end
 w.Text(page,K.L(mode==1 and "errorShowHelp" or mode==2 and "errorImportantHelp" or "errorCustomHelp"),8,-58,690,14,{.65,.70,.62})
 local y=-152
 if mode==2 then
  local box=w.Box(page,0,y,714,62)
  w.Text(box,K.L("keepImportantErrors"),16,-20,550,14)
  local help=w.Button(box,"?",584,-20,22,22,function() end);w.Tip(help,"keepImportantErrors","keepImportantErrorsHelp")
  w.Switch(box,K.db.keepImportantErrors~=false,620,-16,function(v) K.SetImportantErrors(v) end,not InCombatLockdown())
  y=y-90
 elseif mode==3 then
  for i,key in ipairs({"target","movement","range","direction","cooldown","resources"}) do
   local group=key;local box=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*78,349,64)
   w.Text(box,K.L("error_"..group),14,-14,230,14)
   w.Switch(box,not K.db.errorFilters or K.db.errorFilters[group]~=false,245,-29,function(v) K.SetErrorGroup(group,v) end,not InCombatLockdown())
  end
  y=y-254
 end
 return y
end

-- Classic uses its own C_Map-backed coordinate frame; native frames remain supported.
;(function(K)
local M={};K.MinimapCoordinates=M
local defaults={enabled=true,x=0,y=-40,size=12,font=0,outline=true}
local bounds={x={-300,300},y={-300,300},size={8,32},font={0,2}}
local original,frame,mover,editing,fontObject,fontKey,windowHooked
local classicCoords
local function CoordinateText()
 if not classicCoords then return end
 local text='—, —'
 local id=C_Map.GetBestMapForUnit('player')
 local position=id and C_Map.GetPlayerMapPosition(id,'player')
 if position then
  local x,y=position:GetXY()
  if type(x)=='number' and type(y)=='number' and x==x and y==y and x>=0 and x<=1 and y>=0 and y<=1 then text=string.format('%.1f, %.1f',x*100,y*100)end
 end
 classicCoords.CoordText:SetText(text)
end
local function Native()
 local container=MinimapCluster and MinimapCluster.MinimapContainer
 local f=container and container.PlayerCoords
 if f and f.CoordText and Minimap then return f end
 if not Minimap or not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetPlayerMapPosition then return end
 if not classicCoords then
  classicCoords=CreateFrame('Frame','KAClassicMinimapCoordinates',Minimap)
  classicCoords:SetSize(96,20);classicCoords:SetPoint('CENTER',Minimap,'BOTTOM',0,-40);classicCoords:EnableMouse(false)
  classicCoords.CoordText=classicCoords:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');classicCoords.CoordText:SetPoint('CENTER')
  local elapsed=0;classicCoords:SetScript('OnUpdate',function(_,dt)elapsed=elapsed+dt;if elapsed>=.2 then elapsed=0;CoordinateText()end end)
  classicCoords:Hide();M.frame=classicCoords
 end
 return classicCoords
end
function M.Available() return Native()~=nil end
function M.Get(key)
 local db=K.db and K.db.minimapCoords
 if db and type(db[key])==type(defaults[key]) then return db[key] end
 return defaults[key]
end
local function DB()
 K.db.minimapCoords=K.db.minimapCoords or {};return K.db.minimapCoords
end
local function StopDrag()
 if mover then mover:SetScript("OnUpdate",nil);mover.drag=nil end
end
function M.SetEditing(value)
 StopDrag();editing=value==true and M.Get("enabled") and not InCombatLockdown()
 M.Refresh()
end
local function Capture(f)
 local s={points={},width=f:GetWidth(),height=f:GetHeight(),level=f:GetFrameLevel(),fontObject=f.CoordText:GetFontObject()}
 s.file,s.size,s.flags=f.CoordText:GetFont()
 for i=1,f:GetNumPoints() do s.points[i]={f:GetPoint(i)} end
 return s
end
local function Restore()
 if not original or not frame then return end
 frame:ClearAllPoints();for _,point in ipairs(original.points) do frame:SetPoint(unpack(point)) end
 frame:SetSize(original.width,original.height);frame:SetFrameLevel(original.level)
 if original.fontObject then frame.CoordText:SetFontObject(original.fontObject)
 elseif original.file then frame.CoordText:SetFont(original.file,original.size,original.flags) end
 original=nil;fontKey=nil
end
function M.Refresh()
 if InCombatLockdown() then if mover then StopDrag();mover:Hide() end;return end
 local f=Native()
 if f~=frame then Restore();frame=f end
 if not frame or not K.db then return end
 if not M.Get("enabled") then
  editing=false;StopDrag();if mover then mover:Hide() end;Restore();if classicCoords then classicCoords:Hide()end;return
 end
 original=original or Capture(frame)
 if classicCoords then if frame==classicCoords then CoordinateText();classicCoords:Show()else classicCoords:Hide()end end
 local size=M.Get("size");local font=M.Get("font")
 local key=font..":"..size..":"..tostring(M.Get("outline"))
 if key~=fontKey then
  local file=font==1 and "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-R.ttf"
   or font==2 and "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-B.ttf" or original.file
  if file then
   fontObject=fontObject or CreateFont("KerimAnkaUIMinimapCoordinateFont")
   fontObject:SetFont(file,size,M.Get("outline") and "OUTLINE" or "")
   frame.CoordText:SetFontObject(fontObject);frame.CoordText:SetTextColor(1,1,1,1)
  end
  fontKey=key
 end
 frame:ClearAllPoints();frame:SetPoint("CENTER",Minimap,"BOTTOM",M.Get("x"),M.Get("y"))
 frame:SetSize(math.max(90,size*8),size+8)
 frame:SetFrameLevel(math.max(original.level,Minimap:GetFrameLevel()+10))
 if not mover then
  mover=CreateFrame("Button",nil,frame:GetParent(),"BackdropTemplate");M.mover=mover
  mover:RegisterForDrag("LeftButton");mover:EnableMouse(true)
  mover:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
  mover:SetBackdropColor(.22,.3,.18,.3);mover:SetBackdropBorderColor(.85,.72,.4,1)
  mover:SetScript("OnDragStart",function(self)
   if not editing or InCombatLockdown() then return end
   local x,y=GetCursorPosition();self.drag={x,y,M.Get("x"),M.Get("y"),frame:GetEffectiveScale()}
   self:SetScript("OnUpdate",function(self)
    if InCombatLockdown() then M.SetEditing(false);return end
    local x,y=GetCursorPosition();local d=self.drag
    local db=DB();db.x=math.max(-300,math.min(300,math.floor(d[3]+(x-d[1])/d[5]+.5)))
    db.y=math.max(-300,math.min(300,math.floor(d[4]+(y-d[2])/d[5]+.5)))
    M.Refresh()
   end)
  end)
  mover:SetScript("OnDragStop",function() StopDrag();if K.Render then K.Render() end end)
 end
 if K.window and not windowHooked then
  windowHooked=true;K.window:HookScript("OnHide",function() M.SetEditing(false) end)
 end
 mover:ClearAllPoints();mover:SetPoint("CENTER",frame,"CENTER");mover:SetSize(frame:GetWidth(),frame:GetHeight())
 mover:SetFrameLevel(frame:GetFrameLevel()+1);mover:SetShown(editing==true)
end
function M.Set(key,value)
 if K.InCombat() or not M.Available() then return false end
 if type(defaults[key])=="boolean" then if type(value)~="boolean" then return false end
 elseif bounds[key] and type(value)=="number" and value==value then
  value=math.max(bounds[key][1],math.min(bounds[key][2],math.floor(value+.5)))
 else return false end
 DB()[key]=value;M.Refresh();return true
end
function M.Reset()
 if K.InCombat() then return end
 K.db.minimapCoords=nil;M.SetEditing(false);M.Refresh()
end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED","ADDON_LOADED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",function(_,event,addon)
 if event=="ADDON_LOADED" and addon~="Blizzard_Minimap" then return end
 if event=="PLAYER_REGEN_DISABLED" then editing=false;StopDrag();if mover then mover:Hide() end;return end
 M.Refresh()
end)
function K.DrawMinimapCoordinates(page,w,y)
 M.Refresh()
 w.Text(page,K.L("mcTitle"),8,y,690,18,{.73,.62,.41});y=y-34
 w.Text(page,K.L(M.Available() and "mcHelp" or "mcUnavailable"),8,y,690,13,{.65,.70,.62});y=y-60
 local available=M.Available() and not InCombatLockdown()
 local card=w.Box(page,0,y,714,62)
 w.Text(card,K.L("mcEnabled"),16,-20,570,14)
 w.Switch(card,M.Get("enabled"),620,-16,function(value) if M.Set("enabled",value) then Refresh() end end,available)
 y=y-78
 local active=available and M.Get("enabled")
 for i,entry in ipairs({{"x","mcX"},{"y","mcY"},{"size","mcSize"}}) do
  local key,label=entry[1],entry[2]
  local box=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
  w.Text(box,K.L(label),14,-12,290,13)
  local text=w.Text(box,tostring(M.Get(key)),14,-54,150,15)
  for j,delta in ipairs({-1,1}) do
   local b=w.Button(box,delta<0 and "−" or "+",251+(j-1)*46,-47,36,32,function()
    if M.Set(key,M.Get(key)+delta) then text:SetText(tostring(M.Get(key))) end
   end)
   if not active then b:Disable() end
  end
 end
 local box=w.Box(page,365,y-96,349,86);w.Text(box,K.L("mcOutline"),14,-12,290,13)
 w.Switch(box,M.Get("outline"),255,-48,function(value) M.Set("outline",value) end,active)
 y=y-204
 for i,label in ipairs({"xpFontGame","xpFontRegular","xpFontBold"}) do
  local font=i-1
  local b=w.Button(page,K.L(label),(i-1)*243,y,235,32,function() if M.Set("font",font) then Refresh() end end)
  w.Selected(b,M.Get("font")==font);if not active then b:Disable() end
 end
 y=y-46
 local drag=w.Button(page,K.L(editing and "mcLock" or "mcDrag"),0,y,349,34,function() M.SetEditing(not editing);Refresh() end)
 if not active then drag:Disable() end
 local reset=w.Button(page,K.L("mcReset"),365,y,349,34,function() M.Reset();Refresh() end)
 if not available then reset:Disable() end
 return y-52
end
end)(K)

-- One dedicated minimap page; its saved settings and artwork APIs stay intact.
function K.DrawMinimapPage(page)
 local w=K.UnitWidgets
 local y=0
 if K.MinimapButtons and K.MinimapButtons.IsBlocked() then
  local notice=w.Box(page,0,y,714,128)
  w.Text(notice,K.L("mbBlockedTitle"),14,-12,686,16,{1,.72,.30})
  w.Text(notice,K.L("mbBlockedHelp"),14,-42,686,13,{.85,.85,.78})
  y=y-144
 end
 y=K.DrawArtExtras(page,w,y,false,true)
 if not ForeverClassArtMinimap then w.Text(page,K.L("mmArtUnavailable"),8,y,690,13);y=y-72 end
 if K.DrawClassicMinimapControls then y=K.DrawClassicMinimapControls(page,w,y) end
 if K.DrawMinimapCoordinates then y=K.DrawMinimapCoordinates(page,w,y) end
 if K.DrawMinimapButtons then y=K.DrawMinimapButtons(page,w,y) end
 page:SetHeight(-y+20)
end
