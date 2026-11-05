local _,K=...
-- The TOC loads language dictionaries before Core.lua and the panel modules.
K.locales={en={}}
K.languages={
 {code="en",name="English"}, {code="de",name="Deutsch"},
 {code="tr",name="Türkçe"}, {code="zhCN",name="简体中文",native=true},
 {code="frFR",name="Français"}, {code="itIT",name="Italiano"},
 {code="esES",name="Español"}, {code="ptBR",name="Português (Brasil)"},
 {code="ruRU",name="Русский"},
}
function K.L(key)
 local code=KerimAnkaUIDB and KerimAnkaUIDB.language or "en"
 local entries=K.locales[code] or K.locales.en
 return entries[key] or K.locales.en[key] or key
end
function K.LanguageName()
 local code=KerimAnkaUIDB and KerimAnkaUIDB.language or "en"
 for _,language in ipairs(K.languages) do if language.code==code then return language.name end end
 return "English"
end
local fonts=setmetatable({},{__mode="k"})
local path="Interface\\AddOns\\KerimAnkaUI\\Fonts\\"
local fontSerial=0
local sharedFonts={}
local function PanelRegion(region)
 if not K.window or region.panelTextFixed then return false end
 local current=region
 for _=1,32 do
  if current.panelTextExclude then return false end
  if current==K.window then return true end
  current=current.GetParent and current:GetParent()
  if not current then return false end
 end
 return false
end
local factors={1,1.12,1.24}
function K.PanelTextSize()
 local value=KerimAnkaUIDB and KerimAnkaUIDB.panelTextSize
 return value==2 and 2 or value==3 and 3 or 1
end
local function Apply(region,spec,fitSize)
 local scalable=PanelRegion(region)
 local size=fitSize or(scalable and math.floor(spec.size*factors[K.PanelTextSize()]*2+.5)/2 or spec.size)
 -- An explicit false pins a language name to the bundled Latin/Cyrillic font.
 local native=spec.native==true or (spec.native==nil and KerimAnkaUIDB and KerimAnkaUIDB.language=="zhCN")
 if native then
  -- Never set a raw file or text height on the FontString. Local font
  -- overrides can replace the inherited font's multilingual glyph support.
  local object=size>=20 and (GameFontNormalHuge or GameFontNormalLarge)
   or size>=15 and GameFontNormalLarge
   or size<=11 and GameFontNormalSmall or GameFontNormal
  region:SetFontObject(object or GameFontNormal)
 else
  -- Panel regions share immutable font styles instead of creating a Font per label.
  local key=(spec.bold and 'b' or 'r')..':'..tostring(size)..':'..spec.flags
  local object=sharedFonts[key]
  if not object then
   fontSerial=fontSerial+1;object=CreateFont("KerimAnkaUIPanelFont"..fontSerial)
   object:SetFont(path..(spec.bold and "Ubuntu-B.ttf" or "Ubuntu-R.ttf"),size,spec.flags)
   sharedFonts[key]=object
  end
  if not region.GetFontObject or region:GetFontObject()~=object then region:SetFontObject(object)end
 end
 if not fitSize and scalable and size>spec.size and region.GetText and region:GetText()and region:GetText()~=''then
  local function Overflow()
   if region.IsTruncated and region:IsTruncated()then return true end
   local height=region.GetHeight and region:GetHeight()or 0
   if height>0 and region.GetStringHeight and region:GetStringHeight()>height+.5 then return true end
   if region.CanWordWrap and not region:CanWordWrap()then
    local width=region:GetWidth();return width>0 and region:GetStringWidth()>width+.5
   end
   return false
  end
  local candidate=size
  while candidate>spec.size and Overflow()do
   candidate=math.max(spec.size,candidate-.5);Apply(region,spec,candidate)
  end
 end
end
function K.ApplyTextFont(region,size,bold,flags,native)
 local spec=fonts[region] or {}
 spec.size=size or 13;spec.bold=bold;spec.flags=flags or "";spec.native=native
 fonts[region]=spec;Apply(region,spec)
 if K.QueuePanelTextFit and PanelRegion(region)then K.QueuePanelTextFit()end
end
function K.ReleaseTextFont(region)fonts[region]=nil end
function K.RefreshPanelFonts()
 if K.SoundShortcut then K.SoundShortcut.Refresh() end
 if K.FPS then K.FPS.Refresh() end
 for region,spec in pairs(fonts) do Apply(region,spec) end
end
-- Refresh only visible settings text after a render settles. No polling/OnUpdate.
local textFitQueued=false
local lastTextSize=1
function K.QueuePanelTextFit()
 if K.PanelTextSize()==1 and lastTextSize==1 then return end
 if textFitQueued or not K.window or not K.window:IsShown()then return end
 textFitQueued=true
 C_Timer.After(0,function()
  textFitQueued=false
  if not K.window or not K.window:IsShown()then return end
  lastTextSize=K.PanelTextSize()
  for region,spec in pairs(fonts)do
   if PanelRegion(region)and region:IsVisible()then Apply(region,spec)end
  end
 end)
end
function K.SetPanelTextSize(value)
 if value~=1 and value~=2 and value~=3 then return false end
 if not KerimAnkaUIDB then return false end
 if K.PanelTextSize()==value then return true end
 KerimAnkaUIDB.panelTextSize=value
 if K.HideTooltip then K.HideTooltip()end
 if K.Render then K.Render()end
 K.QueuePanelTextFit();return true
end
function K.SetLanguage(code)
 if not K.locales[code] then return false end
 KerimAnkaUIDB.language=code
 if K.HideTooltip then K.HideTooltip() end
 if K.HideThreatFontMenu then K.HideThreatFontMenu() end
 K.RefreshPanelFonts()
 if K.SoundShortcut then K.SoundShortcut.Refresh() end
 if ForeverHunterRangeAPI and ForeverHunterRangeAPI.RefreshText then ForeverHunterRangeAPI.RefreshText() end
 if HunterAspectAlertAPI and HunterAspectAlertAPI.RefreshText then HunterAspectAlertAPI.RefreshText() end
 if ForeverThreatAPI and ForeverThreatAPI.RefreshText then ForeverThreatAPI.RefreshText() end
 if K.Render then K.Render() end
 return true
end

-- Defaults follow the UI language; explicit custom text is never translated.
local legacyAspect={cheetahText="Geparden aktif: Aspekti değiştir!",missingText="Bir aspekt seç!"}
KerimAnkaUITextAPI={Font=K.ApplyTextFont}
function KerimAnkaUITextAPI.HunterText(kind,key,value,custom)
 if type(value)=="string" and value~="" and
  (kind~="aspect" or custom==true or (custom~=false and value~=legacyAspect[key])) then return value end
 return K.L(kind=="aspect" and "hunterAspect_"..key or "hunterRange_"..key)
end

KerimAnkaUITextAPI.Hint=K.L

function KerimAnkaUITextAPI.PaladinSkin()
 local d=ForeverHunterArtCharacterDB
 if d and (d.paladinSkin==1 or d.paladinSkin==2) then return d.paladinSkin end
 return UnitFactionGroup and UnitFactionGroup('player')=='Horde' and 2 or 1
end

-- Shared faction palette; action-only alternatives never overwrite this choice.
function KerimAnkaUITextAPI.WarriorSkin()
 local d=ForeverHunterArtCharacterDB
 if d and (d.warriorSkin==1 or d.warriorSkin==2) then return d.warriorSkin end
 return UnitFactionGroup and UnitFactionGroup('player')=='Horde' and 2 or 1
end
