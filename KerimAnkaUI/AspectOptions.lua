local _,K=...
local edits={}
function K.HideAspectInputs()
 for _,edit in pairs(edits) do edit:ClearFocus(); edit:Hide() end
end
function K.EndAspectPreview()
 if HunterAspectAlertAPI then HunterAspectAlertAPI.EndPreview() end
end
local function Refresh()
 C_Timer.After(0,function() if K.window and K.window:IsShown() then K.Render() end end)
end
local function Input(parent,key,api)
 local edit=edits[key]
 if not edit then
  edit=CreateFrame("EditBox",nil,K.window,"BackdropTemplate"); edits[key]=edit
  K.ApplyTextFont(edit,14,false,"")
  edit:SetTextColor(.9,.92,.88,1); edit:SetAutoFocus(false); edit:SetMaxLetters(100); edit:SetTextInsets(12,12,0,0)
  edit:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
  edit:SetScript("OnEnterPressed",function(self) self:ClearFocus() end)
  edit:SetScript("OnEditFocusGained",function(self) if K.InCombat() then self:ClearFocus() end end)
  edit:SetScript("OnTextChanged",function(self,userInput)
   if not userInput then return end
   local settings=api.GetSettings()
   if InCombatLockdown() then self:SetText((api.GetText and api.GetText(key) or settings[key])); self:ClearFocus(); K.Message("combatLock"); return end
   if not api.Set(key,self:GetText()) then self:SetText((api.GetText and api.GetText(key) or settings[key])) end
  end)
 end
 edit:SetParent(parent); edit:SetFrameLevel(parent:GetFrameLevel()+2); edit:ClearAllPoints(); edit:SetPoint("TOPLEFT",20,-49); edit:SetSize(674,34)
 K.UnitWidgets.Rounded(edit,.10,.12,.10,{.30,.36,.28,1},5,false)
 edit:SetText(api.GetText and api.GetText(key) or api.GetSettings()[key]); edit:Show()
end
function K.DrawAspectPage(page)
 local api=HunterAspectAlertAPI
 local db=api and api.GetSettings()
 if not db then return false end
 local w=K.UnitWidgets
 w.Text(page,K.L("aaNote"),8,0,690,13,{.65,.70,.62})
 local notice=w.Box(page,0,-64,714,148)
 w.Text(notice,K.L("aaCombatNoticeTitle"),14,-12,686,14,{.85,.69,.37})
 w.Text(notice,K.L("aaCombatNotice"),14,-38,686,13,{.78,.80,.73})
 local y=-230
 for i,item in ipairs({{"cheetah","aaPreview"},{"missing","aaPreviewMissing"},{false,"aaLive"}}) do
  local mode=item[1] or nil
  local b=w.Button(page,K.L(item[2]),(i-1)*240,y,234,34,function()
   if not K.InCombat() then api.SetPreview(mode); Refresh() end
  end)
  w.Selected(b,api.GetPreview()==mode)
  if item[1] and not db.enabled then b:Disable() end
  w.Tip(b,item[2],"aaPreviewHelp")
 end
 y=y-56
 for i,field in ipairs({{"enabled","aaEnabled"},{"locked","aaLock"},{"showText","aaText"},{"cheetahGlow","aaGlow"}}) do
  local key=field[1]
  local c=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
  w.Text(c,K.L(field[2]),14,-12,278,13)
  local help=w.Button(c,"?",311,-10,22,22,function() end); w.Tip(help,field[2],"aaHelp")
  local value=db[key]; if key=="locked" then value=api.IsLocked() end
  w.Switch(c,value,255,-48,function(enabled)
   if K.InCombat() then return end
   if key=="locked" then api.SetLocked(enabled) else api.Set(key,enabled) end
  end,true)
 end
 y=y-212
 for _,field in ipairs({{"cheetahText","aaCheetah"},{"missingText","aaMissing"}}) do
  local c=w.Box(page,0,y,714,102)
  w.Text(c,K.L(field[2]),16,-16,620,15)
  local help=w.Button(c,"?",676,-13,22,22,function() end); w.Tip(help,field[2],"hunterTextHelp")
  Input(c,field[1],api); y=y-120
 end
 w.Button(page,K.L("aaResetPosition"),0,y,349,36,function() if not K.InCombat() and api.ResetPosition() then Refresh() end end)
 w.Button(page,K.L("aaResetTexts"),365,y,349,36,function() if not K.InCombat() and api.ResetTexts() then Refresh() end end)
 y=y-50
 w.Button(page,K.L("aaRefresh"),365,y,349,36,Refresh)
 page:SetHeight(-y+56)
 return true
end
