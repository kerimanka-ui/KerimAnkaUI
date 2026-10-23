local _,K=...
local families={}
local serial=0
local alphabets={"roman","korean","simplifiedchinese","traditionalchinese","russian"}
-- Explicit per-alphabet files: inheriting GameFontNormal inside each XML
-- member did not provide usable multilingual members on the Forever client.
local defaults={korean="Fonts\\2002.TTF",simplifiedchinese="Fonts\\ARKai_C.ttf",
 traditionalchinese="Fonts\\arheiuhk_bd.TTF",russian="Fonts\\FRIZQT___CYR.TTF"}
local function NativeFile(alphabet)
 local native=SystemFont_Outline or GameFontNormal
 if native and native.GetFontObjectForAlphabet then
  local ok,member=pcall(native.GetFontObjectForAlphabet,native,alphabet)
  if ok and member and member.GetFont then
   local good,file=pcall(member.GetFont,member)
   if good and not (issecretvalue and issecretvalue(file)) and type(file)=="string" and file~="" then return file end
  end
 end
 return defaults[alphabet]
end
function K.ApplyUnitNameFont(region,size,bold,roman)
 size=type(size)=="number" and size==size and size or 14
 size=math.max(5,math.min(128,size))
 roman=roman or (bold and "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-B.ttf"
  or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF")
 local key=roman..":"..string.format("%.6f",size)
 local family=families[key]
 if not family and type(CreateFontFamily)=="function" then
  local members={}
  for _,alphabet in ipairs(alphabets) do
   members[#members+1]={alphabet=alphabet,file=alphabet=="roman" and roman or NativeFile(alphabet),height=size,flags="OUTLINE"}
  end
  serial=serial+1
  local ok,result=pcall(CreateFontFamily,"KAUIUnitNamesV55_"..serial,members)
  if ok and result then family=result;families[key]=family end
 end
 if family then
  region:SetFontObject(family)
  K.nameFontStatus="family"
 else
  -- Keep size/style functional even if this client cannot create a family.
  region:SetFont(roman,size,"OUTLINE")
  K.nameFontStatus="single-font-fallback"
 end
end
KerimAnkaUITextAPI.NameFont=K.ApplyUnitNameFont
