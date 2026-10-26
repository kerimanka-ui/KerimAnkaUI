-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
K.classicEraAlpha=true
local state={loaded={},build='alpha1'};KerimAnkaUIClassicDiagnostics=state
local frame=CreateFrame('Frame');frame:RegisterEvent('ADDON_LOADED');frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent',function(_,event,name)
 if event=='ADDON_LOADED' and type(name)=='string' and name:match('^KerimAnkaUI') then state.loaded[name]=true end
 if event=='PLAYER_LOGIN' then print('|cffffcc66KerimAnka UI Classic Era alpha1|r: /kaui settings; /kauiclassic diagnostics. Ready layouts and custom quest tracker are not enabled in this test.') end
end)
SLASH_KERIMANKAUICLASSIC1='/kauiclassic'
SlashCmdList.KERIMANKAUICLASSIC=function()
 local version,build,_,interface=GetBuildInfo();local count=0;for _ in pairs(state.loaded) do count=count+1 end
 print('KerimAnka UI Classic Era alpha1 | client='..tostring(version)..' build='..tostring(build)..' interface='..tostring(interface)..' | modules='..count)
 print('Classic-only loader. Original Forever Lua files excluded. Ready layouts and custom quest tracker: pending adaptation.')
end
