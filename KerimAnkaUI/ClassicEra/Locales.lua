-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
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
 local code=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or "en"
 local entries=K.locales[code] or K.locales.en
 return entries[key] or K.locales.en[key] or key
end
function K.LanguageName()
 local code=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or "en"
 for _,language in ipairs(K.languages) do if language.code==code then return language.name end end
 return "English"
end
local fonts=setmetatable({},{__mode="k"})
local path="Interface\\AddOns\\KerimAnkaUI\\Fonts\\"
local fontSerial=0
local sharedFonts={}
local function Apply(region,spec)
 -- An explicit false pins a language name to the bundled Latin/Cyrillic font.
 local native=spec.native==true or (spec.native==nil and KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language=="zhCN")
 if native then
  -- Never set a raw file or text height on the FontString. Local font
  -- overrides can replace the inherited font's multilingual glyph support.
  local object=spec.size>=20 and (GameFontNormalHuge or GameFontNormalLarge)
   or spec.size>=15 and GameFontNormalLarge
   or spec.size<=11 and GameFontNormalSmall or GameFontNormal
  region:SetFontObject(object or GameFontNormal)
 else
  -- Panel regions share immutable font styles instead of creating a Font per label.
  local key=(spec.bold and 'b' or 'r')..':'..tostring(spec.size)..':'..spec.flags
  local object=sharedFonts[key]
  if not object then
   fontSerial=fontSerial+1;object=CreateFont("KerimAnkaUIPanelFont"..fontSerial)
   object:SetFont(path..(spec.bold and "Ubuntu-B.ttf" or "Ubuntu-R.ttf"),spec.size,spec.flags)
   sharedFonts[key]=object
  end
  if not region.GetFontObject or region:GetFontObject()~=object then region:SetFontObject(object)end
 end
end
function K.ApplyTextFont(region,size,bold,flags,native)
 local spec=fonts[region] or {}
 spec.size=size or 13;spec.bold=bold;spec.flags=flags or "";spec.native=native
 fonts[region]=spec;Apply(region,spec)
end
function K.RefreshPanelFonts()
 if K.SoundShortcut then K.SoundShortcut.Refresh() end
 if K.FPS then K.FPS.Refresh() end
 for region,spec in pairs(fonts) do Apply(region,spec) end
end
function K.SetLanguage(code)
 if not K.locales[code] then return false end
 KAClassic_KerimAnkaUIDB.language=code
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
 local d=KAClassic_ForeverHunterArtCharacterDB
 if d and (d.paladinSkin==1 or d.paladinSkin==2) then return d.paladinSkin end
 return UnitFactionGroup and UnitFactionGroup('player')=='Horde' and 2 or 1
end

-- Shared faction palette; action-only alternatives never overwrite this choice.
function KerimAnkaUITextAPI.WarriorSkin()
 local d=KAClassic_ForeverHunterArtCharacterDB
 if d and (d.warriorSkin==1 or d.warriorSkin==2) then return d.warriorSkin end
 return UnitFactionGroup and UnitFactionGroup('player')=='Horde' and 2 or 1
end
