-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local fields={
 {[1]="enabled",[2]="",[3]="",[4]=""},
 {[1]="locked",[2]="",[3]="",[4]=""},
 {[1]="autoColor",[2]="",[3]="",[4]=""},
 {[1]="raw",[2]="",[3]="",[4]=""},
 {[1]="showPercent",[2]="",[3]="",[4]=""},
 {[1]="bold",[2]="",[3]="",[4]=""},
 {[1]="outline",[2]="",[3]="",[4]=""},
 {[1]="shadow",[2]="",[3]="",[4]=""},
 {[1]="size",[2]="",[3]="",[4]="",[5]=12,[6]=96,[7]=2},
 {[1]="alpha",[2]="",[3]="",[4]="",[5]=0.2,[6]=1,[7]=0.05,[8]=100},
 {[1]="x",[2]="",[3]="",[4]="",[5]=-2000,[6]=2000,[7]=5},
 {[1]="y",[2]="",[3]="",[4]="",[5]=-1200,[6]=1200,[7]=5},
}
local menu
local font="Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-R.ttf"
local function FontName(name) return name=="Varsayılan" and K.L("ftDefault") or name end
function K.HideThreatFontMenu() if menu then menu:Hide() end end
local function Refresh()
 C_Timer.After(0,function() if K.window and K.window:IsShown() then K.Render() end end)
end
local function OpenFonts(owner,api)
 if menu and menu:IsShown() then menu:Hide(); return end
 K.HideTooltip()
 if not menu then
  menu=CreateFrame("Frame","KerimAnkaUIThreatFontMenu",K.window,"BackdropTemplate")
  menu:SetSize(349,236); menu:SetFrameLevel(K.window:GetFrameLevel()+40); menu:EnableMouse(true)
  K.UnitWidgets.Rounded(menu,.13,.15,.13,{.45,.50,.38,1},8,false)
  menu.scroll=CreateFrame("ScrollFrame",nil,menu,"UIPanelScrollFrameTemplate")
  menu.scroll:SetPoint("TOPLEFT",8,-8); menu.scroll:SetPoint("BOTTOMRIGHT",-30,8)
  menu.child=CreateFrame("Frame",nil,menu.scroll); menu.child:SetWidth(307); menu.scroll:SetScrollChild(menu.child)
  menu.rows={}
  K.scroll:HookScript("OnVerticalScroll",K.HideThreatFontMenu)
  UISpecialFrames[#UISpecialFrames+1]="KerimAnkaUIThreatFontMenu"
 end
 menu:ClearAllPoints(); menu:SetPoint("TOPLEFT",owner,"BOTTOMLEFT",0,-4)
 for _,row in ipairs(menu.rows) do row:Hide() end
 local entries=api.GetFonts()
 for i,entry in ipairs(entries) do
  local name=entry.name
  local row=menu.rows[i]
  if not row then
   row=CreateFrame("Button",nil,menu.child,"BackdropTemplate"); row:SetSize(303,28); row:SetPoint("TOPLEFT",0,-(i-1)*30)
   row.label=row:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(row.label,13,false,""); row.label:SetPoint("LEFT",10,0); row.label:SetWidth(283); row.label:SetJustifyH("LEFT"); row.label:SetWordWrap(false)
   menu.rows[i]=row
  end
  local selected=name==api.GetSettings().font
  K.UnitWidgets.Rounded(row,selected and .22 or .13,selected and .29 or .15,selected and .18 or .13,nil,4,false)
  row.label:SetText(FontName(name)); row.label:SetTextColor(.9,.92,.88,1)
  row:SetScript("OnClick",function()
   if K.InCombat() then return end
   if api.Set("font",name) then menu:Hide(); Refresh() end
  end)
  row:Show()
 end
 menu.child:SetHeight(math.max(1,#entries*30)); menu.scroll:SetVerticalScroll(0); menu:Show()
end
-- Only presentation state; folding groups never writes character settings.
local groups={general=true,appearance=true,position=false}
local function Repaint()
 local offset=K.scroll:GetVerticalScroll();K.HideThreatFontMenu();K.HideTooltip();K.Render()
 K.scroll:SetVerticalScroll(math.min(offset,K.scroll:GetVerticalScrollRange()))
end
function K.DrawThreatPage(page)
 local api=ForeverThreatAPI;local db=api and api.GetSettings()
 if not db then return false end
 local w=K.CompactSettingsWidgets and K.CompactSettingsWidgets()or K.UnitWidgets
 local y=0
 local function Disabled(button)if K.InCombat()then button:Disable()end;return button end
 local function Toggles(keys)
  for i,key in ipairs(keys)do
   local card=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*74,349,64)
   local title=w.Text(card,K.L('ft_'..key),13,-11,207,14);title:SetHeight(44)
   local help=w.Button(card,'?',225,-20,22,22,function()end);w.Tip(help,'ft_'..key,'ftHelp')
   w.Switch(card,db[key],259,-19,function(value)if not K.InCombat()then api.Set(key,value)end end,not K.InCombat())
  end
  y=y-math.ceil(#keys/2)*74
 end
 local function Numbers(keys)
  for i,key in ipairs(keys)do
   local field;for _,f in ipairs(fields)do if f[1]==key then field=f;break end end
   local low,high,step,factor=field[5],field[6],field[7],field[8]or 1
   local card=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
   w.Text(card,K.L('ft_'..key),14,-12,278,14)
   local help=w.Button(card,'?',311,-10,22,22,function()end);w.Tip(help,'ft_'..key,'ftHelp')
   local function Number()return string.format('%.0f',db[key]*factor)end
   local value=w.Text(card,Number(),14,-54,150,15)
   for n,direction in ipairs({-1,1})do
    local delta=direction
    Disabled(w.Button(card,delta<0 and'−'or'+',251+(n-1)*46,-47,36,32,function()
     if K.InCombat()then return end
     local requested=math.max(low,math.min(high,db[key]+delta*step))
     if api.Set(key,requested)then value:SetText(Number())end
    end))
   end
  end
  y=y-math.ceil(#keys/2)*96
 end
 local function Fold(id,label,draw)
  local header=w.Button(page,'',0,y,714,42,function()groups[id]=not groups[id];Repaint()end)
  w.Text(header,K.L(label),14,-12,650,15,{.73,.62,.41});w.Text(header,groups[id]and'−'or'+',677,-10,24,18)
  y=y-54;if groups[id]then draw()end;y=y-12
 end
 w.Text(page,K.L('ftNote'),8,y,690,13,{.65,.70,.62}):SetHeight(58);y=y-74
 Fold('general','ftGroupGeneral',function()Toggles({'enabled','locked','raw','showPercent'})end)
 Fold('appearance','ftGroupAppearance',function()
  local card=w.Box(page,0,y,714,94)
  w.Text(card,K.L('ftFont'),16,-16,620,15)
  local help=w.Button(card,'?',676,-13,22,22,function()end);w.Tip(help,'ftFont','ftFontHelp')
  local choose=Disabled(w.Button(card,FontName(db.font)..'  ▾',16,-48,682,32,function(self)if not K.InCombat()then OpenFonts(self,api)end end))
  w.Tip(choose,'ftFont','ftFontHelp');y=y-106
  Toggles({'autoColor','bold','outline','shadow'});Numbers({'size','alpha'})
  w.Text(page,K.L('ftColors'),8,y,690,16,{.73,.62,.41});y=y-30
  for i,color in ipairs({{'ftGold',1,.82,.2},{'ftWhite',1,1,1},{'ftGreen',.3,1,.3},{'ftRed',1,.25,.2},{'ftBlue',.35,.7,1}})do
   local button=Disabled(w.Button(page,K.L(color[1]),(i-1)*144,y,138,34,function()
    if not K.InCombat()and api.SetColor(color[2],color[3],color[4])then Refresh()end
   end))
   button.label:SetTextColor(color[2],color[3],color[4],1);w.Tip(button,'ftColors','ftColorHelp')
  end
  y=y-46
 end)
 Fold('position','ftGroupPosition',function()
  Numbers({'x','y'})
  Disabled(w.Button(page,K.L('ftCenter'),0,y,714,36,function()if not K.InCombat()and api.Center()then Refresh()end end));y=y-48
 end)
 w.Button(page,K.L('ftRefresh'),365,y,349,36,Refresh);y=y-48
 page:SetHeight(-y+12);return true
end
