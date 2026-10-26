-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local modes={"ranged","dead","melee","far","close","unknown"}
local edits={}
function K.HideRangeInputs() for _,edit in pairs(edits) do edit:ClearFocus();edit:Hide() end end
local function Input(parent,mode,api)
 local edit=edits[mode]
 if not edit then
  edit=CreateFrame("EditBox",nil,K.window,"BackdropTemplate");edits[mode]=edit
  K.ApplyTextFont(edit,14,false,"");edit:SetTextColor(.9,.92,.88,1)
  edit:SetAutoFocus(false);edit:SetMaxLetters(100);edit:SetTextInsets(12,12,0,0)
  edit:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
  edit:SetScript("OnEnterPressed",function(self) self:ClearFocus() end)
  edit:SetScript("OnEditFocusGained",function(self) if K.InCombat() then self:ClearFocus() end end)
  edit:SetScript("OnTextChanged",function(self,user)
   if not user then return end
   if not api.SetText(mode,self:GetText()) then self:SetText(api.GetText(mode));self:ClearFocus() end
  end)
 end
 edit:SetParent(parent);edit:SetFrameLevel(parent:GetFrameLevel()+2);edit:ClearAllPoints()
 edit:SetPoint("TOPLEFT",14,-40);edit:SetSize(321,32)
 K.UnitWidgets.Rounded(edit,.10,.12,.10,{.30,.36,.28,1},5,false)
 edit:SetText(api.GetText(mode));edit:Show()
end
local fields={
 {[1]="enabled",[2]="",[3]="",[4]=""},
 {[1]="locked",[2]="",[3]="",[4]=""},
 {[1]="coloredText",[2]="",[3]="",[4]=""},
 {[1]="outline",[2]="",[3]="",[4]=""},
 {[1]="shadow",[2]="",[3]="",[4]=""},
 {[1]="width",[2]="",[3]="",[4]="",[5]=150,[6]=420,[7]=10},
 {[1]="height",[2]="",[3]="",[4]="",[5]=28,[6]=60,[7]=2},
 {[1]="fontSize",[2]="",[3]="",[4]="",[5]=10,[6]=24,[7]=1},
 {[1]="x",[2]="",[3]="",[4]="",[5]=-2000,[6]=2000,[7]=5},
 {[1]="y",[2]="",[3]="",[4]="",[5]=-1200,[6]=1200,[7]=5},
}
function K.EndRangePreview()
 if ForeverHunterRangeAPI then ForeverHunterRangeAPI.EndPreview() end
end
function K.DrawRangePage(page)
 local api=ForeverHunterRangeAPI
 if not api or api.version<1 then return false end
 local db=api.GetSettings()
 if not db then return false end
 local w=K.UnitWidgets
 w.Text(page,K.L("hrNote"),8,0,690,13,{.65,.70,.62})
 local y=-74
 w.Text(page,K.L("hrPreview"),8,y,640,18,{.73,.62,.41})
 local help=w.Button(page,"?",676,y,22,22,function() end); w.Tip(help,"hrPreview","hrPreviewHelp")
 y=y-36
 for i,mode in ipairs({"ranged","dead","melee","far","close","unknown"}) do
  local b=w.Button(page,K.L("hunterRange_"..mode),(i-1)%3*240,y-math.floor((i-1)/3)*42,234,32,function()
   if K.InCombat() then return end
   api.SetPreview(mode); K.Render()
  end)
  w.Selected(b,api.GetPreview()==mode)
  if not db.enabled then b:Disable() end
  w.Tip(b,"hrPreview","hrPreviewHelp")
 end
 y=y-90
 local live=w.Button(page,K.L("hrLive"),0,y,349,34,function() if not K.InCombat() then api.SetPreview(nil); K.Render() end end)
 w.Selected(live,api.GetPreview()==nil)
 local sample=api.GetPreview()
 w.Text(page,K.L("hrMode")..(sample and K.L("hrSample")..(api.GetText and api.GetText(sample) or K.L("hunterRange_"..sample)) or K.L("hrLiveMode")),365,y-8,349,12,{.65,.70,.62})
 y=y-58
 for i,f in ipairs(fields) do
  local key=f[1]; local low,high,step=f[5],f[6],f[7]
  local c=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
  w.Text(c,K.L("hr_"..key),14,-12,278,13)
  local tip=w.Button(c,"?",311,-10,22,22,function() end); w.Tip(tip,"hr_"..key,"hrHelp")
  if low then
   local value=w.Text(c,string.format("%.0f",db[key]),14,-54,150,15)
   local function change(delta)
    if K.InCombat() then return end
    local requested=math.max(low,math.min(high,db[key]+delta*step))
    if api.Set(key,requested) then value:SetText(string.format("%.0f",db[key])) end
   end
   w.Button(c,"−",251,-47,36,32,function() change(-1) end)
   w.Button(c,"+",297,-47,36,32,function() change(1) end)
  else w.Switch(c,db[key],255,-48,function(value) if not K.InCombat() then api.Set(key,value) end end,true) end
 end
 y=y-math.ceil(#fields/2)*96
 if api.SetText and api.GetText then
  w.Text(page,K.L("hunterTextTitle"),8,y,690,18,{.73,.62,.41});y=y-34
  w.Text(page,K.L("hunterTextHelp"),8,y,690,13,{.65,.70,.62});y=y-90
  for i,mode in ipairs(modes) do
   local c=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*136,349,124)
   w.Text(c,K.L("hunterRange_"..mode),14,-12,321,13)
   Input(c,mode,api)
   w.Button(c,K.L("hunterTextReset"),14,-82,321,28,function()
    if not K.InCombat() and api.SetText(mode,"") then K.Render() end
   end)
  end
  y=y-408
 end
 w.Button(page,K.L("hrRefresh"),365,y,349,36,function() K.Render() end)
 page:SetHeight(-y+56)
 return true
end
