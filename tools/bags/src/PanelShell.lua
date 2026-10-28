-- Bags-only capability adapter for the suite's original panel shell.
function K.Reload()if not K.InCombat()and ReloadUI then ReloadUI()end end
function K.Render()
 if not K.ready or not K.window or not K.window:IsShown()then return end
 K.HideTooltip();K.CloseCommunity()
 for _,f in pairs(pool)do f:Hide()end
 for _,text in ipairs(labels)do text:Hide()end
 used=0;labelUsed=0
 if languageMenu then languageMenu:Hide();languageDismiss:Hide()end
 UpdateLanguageLabel()
 heading:SetText(K.L('inventory'));subtitle:SetText(K.L('kbIndependentHelp'))
 footer:SetText('')
 K.window.edition:SetText('KerimAnka Bags — '..K.L('kbIndependent')..' | '..K.version)
 K.window.reload.label:SetText(K.L('reload'))
 for _,b in ipairs(nav)do
  b.label:SetText(K.L(b.key));b.label:SetTextColor(unpack(b.available and white or {.42,.46,.42}))
  Rounded(b,b.available and .20 or .095,b.available and .245 or .105,b.available and .17 or .10,
   b.available and {.43,.53,.34,1}or {.095,.105,.10,1},6,false)
  b.accent:SetShown(b.available)
 end
 K.DrawInventoryPage(page)
end
function K.ShowPage(key)
 if not K.ready or(key~='inventory'and key~='bags')then return false end
 K.BuildWindow();K.openingPage=true;K.window:Show();K.openingPage=nil;K.Render();return true
end
function K.ToggleSettings()
 if not K.ready then return end
 K.BuildWindow();if K.window:IsShown()then K.window:Hide()else K.ShowPage('inventory')end
end
SLASH_KERIMANKABAGSSETTINGS1='/kabags'
SlashCmdList.KERIMANKABAGSSETTINGS=function()K.ToggleSettings()end
KerimAnkaBagsAPI={version=1,OpenSettings=function()return K.ShowPage('inventory')end,IsReady=function()return K.ready==true end}
-- Register a small entry with Blizzard's installed-add-on settings list.
local register=CreateFrame('Frame');register:RegisterEvent('PLAYER_LOGIN')
register:SetScript('OnEvent',function(self)
 self:UnregisterEvent('PLAYER_LOGIN')
 if not K.ready then return end
 local entry=CreateFrame('Frame');entry.name='KerimAnka Bags'
 local title=entry:CreateFontString(nil,'OVERLAY','GameFontNormalLarge');title:SetPoint('TOPLEFT',16,-16);title:SetText('KerimAnka Bags')
 local button=CreateFrame('Button',nil,entry,'UIPanelButtonTemplate');button:SetPoint('TOPLEFT',16,-52);button:SetSize(260,32);button:SetText(K.L('bagSettingsTab'));K.InventoryFont(button,13)
 button:SetScript('OnClick',function()K.ShowPage('inventory')end)
 if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
  K.settingsCategory=Settings.RegisterCanvasLayoutCategory(entry,entry.name);Settings.RegisterAddOnCategory(K.settingsCategory)
 elseif InterfaceOptions_AddCategory then InterfaceOptions_AddCategory(entry)end
end)
