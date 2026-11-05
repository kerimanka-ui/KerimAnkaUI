-- Classic Era only. Forever uses its existing files.
local _,K=...
-- Called at the original Core initialization point; load order is intentional.
function K.InstallProfileEngine()
local ProfileSerializer=K.CreateProfileSerializer()
-- Profile storage is deliberately bounded. Runtime caches never enter snapshots.
local P={MAX_CODE=65536,MAX_TOTAL=2097152,MAX_NAMED=32,MAX_CHARACTERS=64}
K.Profiles=P
local serializer=ProfileSerializer
P.LayoutSerializer=serializer
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local alphabetIndex={}; for i=1,64 do alphabetIndex[alphabet:sub(i,i)]=i-1 end
local function Encode64(input)
 local result={}
 for i=1,#input,3 do
  local a,b,c=input:byte(i,i+2); b=b or 0; c=c or 0
  local n=a*65536+b*256+c
  result[#result+1]=alphabet:sub(math.floor(n/262144)%64+1,math.floor(n/262144)%64+1)
  result[#result+1]=alphabet:sub(math.floor(n/4096)%64+1,math.floor(n/4096)%64+1)
  result[#result+1]=i+1<=#input and alphabet:sub(math.floor(n/64)%64+1,math.floor(n/64)%64+1) or "="
  result[#result+1]=i+2<=#input and alphabet:sub(n%64+1,n%64+1) or "="
 end
 return table.concat(result)
end
local function Decode64(input)
 if #input%4~=0 or input:find("[^A-Za-z0-9+/=]") then return end
 local result={}
 for i=1,#input,4 do
  local a,b,c,d=input:sub(i,i),input:sub(i+1,i+1),input:sub(i+2,i+2),input:sub(i+3,i+3)
  if not alphabetIndex[a] or not alphabetIndex[b] or (c=="=" and d~="=") then return end
  if (c=="=" or d=="=") and i+3~=#input then return end
  if c~="=" and not alphabetIndex[c] or d~="=" and not alphabetIndex[d] then return end
  local n=alphabetIndex[a]*262144+alphabetIndex[b]*4096+(alphabetIndex[c] or 0)*64+(alphabetIndex[d] or 0)
  result[#result+1]=string.char(math.floor(n/65536)%256)
  if c~="=" then result[#result+1]=string.char(math.floor(n/256)%256) end
  if d~="=" then result[#result+1]=string.char(n%256) end
 end
 local decoded=table.concat(result)
 if Encode64(decoded)~=input then return end -- reject noncanonical padding
 return decoded
end
local function Checksum(input)
 local a,b=1,0
 for i=1,#input do a=(a+input:byte(i))%65521; b=(b+a)%65521 end
 return string.format("%08x",b*65536+a)
end
local function Copy(t)
 if type(t)~="table" then return t end
 local out={}; for k,v in pairs(t) do out[k]=Copy(v) end; return out
end
local function N(low,high) return {kind="number",low=low,high=high} end
local B={kind="boolean"}
local function S(limit) return {kind="string",limit=limit or 160} end
local function Shape(fields) return {kind="table",fields=fields} end
local function Fields(booleans,numbers)
 local fields={}
 for key in booleans:gmatch("%S+") do fields[key]=B end
 for key,bounds in pairs(numbers or {}) do fields[key]=N(bounds[1],bounds[2]) end
 return fields
end
-- Strict choices for Classic-only profile controls; old profiles remain readable.
local function Choice(values)
 local choices={};for value in values:gmatch("%S+") do choices[value]=true end
 return {kind="string",limit=32,choices=choices}
end
local position=Shape({x=N(-10000,10000),y=N(-10000,10000),detached=B});position.required={"x","y"}
local minimap=Shape({hide=B,minimapPos=N(-10000,10000)})
local bars={kind="bars"}
local schema={}
-- bagTheme below is validation-only for legacy portable profiles.
schema.root=Shape({chat=Shape(Fields("enabled microDock enterMode microHidden")),fps=Shape(Fields("enabled locked showMS",{x={-10000,10000},y={-10000,10000}})),soundShortcut=Shape(Fields("enabled locked",{size={24,64},x={0,1},y={0,1}})),bagShortcut=Shape(Fields("enabled locked",{size={24,80},x={0,1},y={0,1}})),actionRange=Shape({enabled=B,color={kind="rgb"}}),minimapButtons=Shape(Fields("enabled locked showTooltip",{buttonStyle={1,2},buttonSize={20,64},columns={1,12},iconSize={24,40},angle={-360,360},radius={0,80}})),minimapCoords=Shape(Fields("enabled outline",{x={-300,300},y={-300,300},size={8,32},font={0,2}})),experience=Shape(Fields("enabled locked showRep showPet showTime showRate showQuest showRested trim hideNative classColor",{frameSize={10,24},verticalSpace={0,120},backgroundAlpha={0,1},width={280,1400},barHeight={8,28},subHeight={8,20},layout={1,2},red={0,1},green={0,1},blue={0,1},x={-10000,10000},y={-10000,10000}})),nativeMeter=Shape(Fields("enabled trim",{trimAlpha={0,1},backgroundAlpha={0,1},padding={0,24},edgeTop={-24,48},edgeBottom={-24,48},edgeLeft={-24,48},edgeRight={-24,48}})),barSource=N(0,2),bagCombined=B,bagDock=B,hideNativeBagBar=B,bagJunk=B,bagQuality=B,bagQuest=B,bagEmptySlots=B,bagItemGap=N(0,16),bagTheme=N(1,3),bagDesign=N(1,3),bagExpanded=B,bagBackground=B,bagFrame=B,bagIconBorder=B,bagSize=N(18,48),bagGap=N(0,16),microEnabled=B,microLocked=B,microSize=N(18,48),microGap=N(0,16),microX=N(0,10000),microY=N(0,10000),hideNativeHotkeys=B,hideNativeMacroNames=B,hideActionBarStatues=B,hideErrors=B,keepImportantErrors=B,errorMode=N(1,3),errorFilters=Shape({target=B,movement=B,range=B,direction=B,cooldown=B,resources=B}),muteClicks=B,cvars={kind="cvars"},sounds={kind="sounds"},position=position,panelHeight=N(640,1100)})

schema.root.fields.minimapButtons.fields.excluded={kind="iconExclusions"}
-- Character UI preferences only. Inventory, money and timer runtime state are excluded.

schema.root.fields.classicBags=Shape(Fields("shelfHidden autoSellJunk autoReplaceJunk",{backgroundStyle={1,3},columns={6,14},fontLevel={0,3},windowScale={.7,1.5},x={-10000,10000},y={-10000,10000}}))
schema.root.fields.classicBags.fields.sortMode=Choice("daily legacy custom")
schema.root.fields.classicBags.fields.sortHearthFirst=B
local bagPriorityFields={}
for _,key in ipairs({"first","second","third","fourth","fifth","sixth"})do bagPriorityFields[key]=Choice("quest consumable food gear trade misc")end
schema.root.fields.classicBags.fields.sortOrder=Shape(bagPriorityFields)
schema.root.fields.classicBags.fields.recordColumns=N(8,14)
schema.root.fields.classicBags.fields.recordRows=N(3,10)
schema.root.fields.classicBank=Shape({columns=N(6,14),fontLevel=N(0,3),windowScale=N(.7,1.5)})
-- Shared chat appearance, validated for profile import/export.
schema.root.fields.chat.fields.theme=N(1,3)
for key,range in pairs({x={0,10000},y={0,10000},width={300,3000},height={100,2000},controlMode={1,3},microGap={0,12},microSize={20,40}})do schema.root.fields.chat.fields[key]=N(range[1],range[2])end
schema.root.fields.chat.fields.unlocked=B
schema.root.fields.chat.fields.channelColors=B
schema.root.fields.chat.fields.visibilityMode=N(1,3)
schema.root.fields.chat.fields.backgroundColor={kind="rgb"}
schema.root.fields.chat.fields.backgroundAlpha=N(0,1)
schema.root.fields.experience.fields.labels=Shape({total=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),levelTime=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),xp=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),remaining=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),rate=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),reputation=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)}),pet=Shape({color={kind="rgb"},visible=B,x=N(-1400,1400),y=N(-400,400),size=N(8,28),font=N(0,2),align=N(0,2)})})
schema.root.fields.experience.fields.colors=Shape({main={kind="rgb"},quest={kind="rgb"},rested={kind="rgb"},rep={kind="rgb"},pet={kind="rgb"}})
schema.appearance=Shape({scale=N(.3,2),cardGlow=B,glowStrength=N(0,1),glowRadius=N(4,20),glowColor={kind="rgb"},cardTone=N(.6,1.8),minimap=minimap})
local back=Fields("enabled",{shade={0,1},border={0,6},slotAlpha={0,1}});back.classicBartenderInitialized=B;back.bars=bars;back.nativeLayout=Shape({bars=bars})
schema.ForeverBarBackdropCharacterDB=Shape(back)
local art=Fields("enabled backingEnabled hunterPetEnabled rogueBackingEnabled rogueDockBottom warlockBackingEnabled warlockDockBottom warlockRailEnabled",{warlockRailX={-150,150},warlockRailWidth={50,150},warlockBackingAlpha={0,1},warlockBottomInset={0,200},warlockRailY={-100,100},warlockRailHeight={8,48},gap={0,50},x={-10000,10000},y={-10000,10000},alpha={0,1},width={20,300},height={20,300},backingAlpha={0,1},backingPadding={0,20},backingRailHeight={1,50},backingRailY={-100,100},backingRailStyle={1,3},hunterPetPadding={0,30},rogueBackingAlpha={0,1},rogueBottomInset={-100,100}})
art.warriorSkin=N(1,2);art.warriorAction=N(1,4);art.backingRailEnabled=B;art.artSkin=N(1,2);art.warlockSkin=N(1,2);art.shamanSkin=N(1,2);art.paladinConnectedInitialized=B;art.paladinSkin=N(1,2);art.druidSkin=N(1,4);art.druidWildInitialized=B;art.priestSkin=N(1,2);art.mageSkin=N(1,4);art.mageAcademyInitialized=B
art.shamanLeftSpread=N(-80,160);art.shamanRightSpread=N(-80,160)
art.backingColorEnabled=B;art.backingColor={kind="rgb"}
art.shamanBackingEnabled=B;art.shamanRailEnabled=B;art.shamanBackingAlpha=N(0,1)
art.shamanRailX=N(-150,150);art.shamanRailY=N(-100,100);art.shamanRailWidth=N(50,150);art.shamanRailHeight=N(50,150)
art.mageLeftSpread=N(-80,160);art.mageRightSpread=N(-80,160)
art.mageBackingEnabled=B;art.mageRailEnabled=B;art.mageBackingAlpha=N(0,1)
art.mageRailX=N(-150,150);art.mageRailY=N(-100,100);art.mageRailWidth=N(50,150);art.mageRailHeight=N(50,150)
art.priestLeftSpread=N(-80,160);art.priestRightSpread=N(-80,160)
art.priestBackingEnabled=B;art.priestRailEnabled=B;art.priestBackingAlpha=N(0,1)
art.priestRailX=N(-150,150);art.priestRailY=N(-100,100);art.priestRailWidth=N(50,150);art.priestRailHeight=N(50,150)
art.druidLeftSpread=N(-80,160);art.druidRightSpread=N(-80,160)
art.druidBackingEnabled=B;art.druidRailEnabled=B;art.druidBackingAlpha=N(0,1)
art.druidRailX=N(-150,150);art.druidRailY=N(-100,100);art.druidRailWidth=N(50,150);art.druidRailHeight=N(50,150)
art.paladinLeftSpread=N(-80,160);art.paladinRightSpread=N(-80,160)
art.paladinBackingEnabled=B;art.paladinRailEnabled=B;art.paladinBackingAlpha=N(0,1)
art.paladinBottomHeight=N(30,100);art.paladinRailX=N(-150,150);art.paladinRailY=N(-100,100);art.paladinRailWidth=N(50,150);art.paladinRailHeight=N(50,150)
art.classicBartenderInitialized=B;art.bars=bars;art.locked=Shape({left=N(-10000,10000),bottom=N(-10000,10000),width=N(1,10000),height=N(1,10000)})
art.locked.required={"left","bottom","width","height"}
art.nativeLayout=Shape({bars=bars,locked=art.locked,width=N(20,300),height=N(20,300),x=N(-10000,10000),y=N(-10000,10000),gap=N(0,50)})
schema.ForeverHunterArtCharacterDB=Shape(art)
schema.ForeverMinimapArtDB=Shape(Fields("enabled hideBorder hunterMatte warlockObsidianInitialized shamanElementInitialized mageAstralInitialized priestHaloInitialized druidWildInitialized",{size={80,130},x={-40,40},y={-40,40}}))
-- Keep legacy profile fields readable; petPanel* still stores the shared pet backing.
schema.ForeverHunterHUDDB=Shape(Fields("enabled units center hideResource petPanelEnabled",{petPanelPadding={0,12},petPanelAlpha={0,1},edge={8,20},padding={0,6},centerPadding={2,12},alpha={.2,1}}))
schema.ForeverQuestJournalDB=Shape(Fields("enabled showQuill scrollEnabled groupByZone",{opacity={.3,1},borderSize={4,12},scrollStep={12,120}}))
schema.ForeverQuestJournalDB.fields.collapsedZones={kind="iconExclusions"}
schema.ForeverDetailsHunterDB=Shape(Fields("showTrim keepFonts",{trimAlpha={.1,1},edgeTop={-24,48},edgeBottom={-24,48},edgeLeft={-24,48},edgeRight={-24,48}}))
schema.ForeverHunterRangeDB=Shape(Fields("enabled locked coloredText outline shadow",{width={150,420},height={28,60},fontSize={10,24},x={-2000,2000},y={-1200,1200}}))
for _,mode in ipairs({"ranged","dead","melee","far","close","unknown"}) do schema.ForeverHunterRangeDB.fields[mode.."Text"]=S(400) end
local threat=Fields("enabled locked autoColor raw showPercent bold outline shadow",{size={12,96},alpha={.2,1},x={-2000,2000},y={-1200,1200},r={0,1},g={0,1},b={0,1}});threat.font=S(160)
schema.ForeverThreatDB=Shape(threat)
schema.HunterAspectAlertCharacterDB=Shape({enabled=B,showText=B,cheetahGlow=B,locked=B,cheetahText=S(400),missingText=S(400),cheetahTextCustom=B,missingTextCustom=B,position={kind="anchor"}})
local moduleFor={ForeverBarBackdropCharacterDB="KerimAnkaUI_BarBackdrop",ForeverHunterArtCharacterDB="KerimAnkaUI_ClassArt",ForeverMinimapArtDB="KerimAnkaUI_ClassArt",ForeverHunterHUDDB="KerimAnkaUI_ClassArt",ForeverLeatherUnitsDB="KerimAnkaUI_UnitFrames",ForeverQuestJournalDB="KerimAnkaUI_QuestJournal",ForeverDetailsHunterDB="KerimAnkaUI_DetailsSkin",ForeverHunterRangeDB="KerimAnkaUI_HunterRange",ForeverThreatDB="KerimAnkaUI_Threat",HunterAspectAlertCharacterDB="KerimAnkaUI_AspectAlert"}
local cvars={cameraDistanceMaxZoomFactor={1,2.6},SpellQueueWindow={0,1000},ffxDeath={0,1}}
for _,option in ipairs(K.soundOptions) do cvars[option.cvar]={0,1} end
local anchors={TOP=true,TOPLEFT=true,TOPRIGHT=true,CENTER=true,LEFT=true,RIGHT=true,BOTTOM=true,BOTTOMLEFT=true,BOTTOMRIGHT=true}
local function Validate(value,spec,depth,budget)
 depth=depth or 0;budget=budget or {n=0}
 budget.n=budget.n+1; if depth>8 or budget.n>4000 then error("structure") end
 local kind=spec.kind
 if kind=="number" then
  if type(value)~="number" or value~=value or value<spec.low or value>spec.high then error("number") end
 elseif kind=="boolean" then if type(value)~="boolean" then error("boolean") end
 elseif kind=="string" then if type(value)~="string" or #value>spec.limit or value:find("%z") then error("string") end;if spec.choices and not spec.choices[value] then error("choice") end
 else
  if type(value)~="table" or getmetatable(value)~=nil then error("table") end
  if spec.required then for _,key in ipairs(spec.required) do if value[key]==nil then error("required field") end end end
  local count=0
  for key,child in pairs(value) do
   count=count+1; if count>4000 then error("entries") end
   if kind=="table" then
    local field=spec.fields[key]; if not field then error("field") end
    Validate(child,field,depth+1,budget)
   elseif kind=="cvars" then
    local bounds=cvars[key];local n=tonumber(child)
    if not bounds or (type(child)~="string" and type(child)~="number") or (type(child)=="string" and #child>32) or not n or n~=n or n<bounds[1] or n>bounds[2] then error("cvar") end
    if key~="cameraDistanceMaxZoomFactor" and key~="SpellQueueWindow" and n~=0 and n~=1 then error("boolean cvar") end
   elseif kind=="iconExclusions" then
    if type(key)~="string" or #key<1 or #key>160 or child~=true or count>128 then error("icon exclusions") end
   elseif kind=="sounds" then
    if type(key)~="number" or key%1~=0 or key<1 or key>2147483647 or child~=true or count>30 then error("sound") end
   elseif kind=="bars" then
    if type(key)~="number" or key%1~=0 or key<1 or key>10 or type(child)~="number" or child%1~=0 or child<1 or child>10 then error("bars") end
   elseif kind=="rgb" then
    if type(key)~="number" or key%1~=0 or key<1 or key>3 then error("rgb") end
    Validate(child,N(0,1),depth+1,budget)
   elseif kind=="anchor" then
    if key==1 or key==2 then if not anchors[child] then error("anchor") end
    elseif key==3 or key==4 then Validate(child,N(-10000,10000),depth+1,budget)
    else error("anchor") end
   else error("schema") end
  end
  if kind=="rgb" and count~=3 or kind=="anchor" and count~=4 then error("length") end
  if kind=="bars" and (count==0 or #value~=count) then error("bars") end
 end
 return value
end
function P.BuildSchema()
 local fields={warriorThemeInitialized=B,paladinThemeInitialized=B,compactMigration=B,hunterThemeInitialized=B,warlockThemeInitialized=B,shamanThemeInitialized=B,mageThemeInitialized=B,druidThemeInitialized=B,priestThemeInitialized=B,player=position,target=position,targettarget=position,pet=position}
 for _,f in ipairs(K.UnitProfileFields) do
  if f[1]~="section" and not f[1]:find("%.") then fields[f[1]]=f[5] and N(f[5],f[6]) or B end
 end
 -- Existing installations may predate panel limits; accept safe legacy values.
 fields.totScale=N(.3,3);fields.petScale=N(.3,2);fields.scale=N(.3,3)
 for _,key in ipairs({"textScale","healthTextScale","powerTextScale","levelTextScale","classificationTextScale"}) do fields[key]=N(.3,4) end
 fields.minimap=minimap
 fields.comboDetached=Shape(Fields("locked",{size={12,40},gap={0,16},x={-10000,10000},y={-10000,10000}}))
 fields.classicEnergyTickMode=Choice("always combat off")
 fields.classicManaTickMode=Choice("always combat off")
 schema.ForeverLeatherUnitsDB=Shape(fields)
end
-- Validate old portable codes, but never capture/apply the retired shelf keys.
local function RetiredRootKey(key)return key=="bagDock"or key=="bagExpanded"end
local function Clean(value,spec)
 if spec.kind~="table" then return Copy(value) end
 local result={}
 for key,field in pairs(spec.fields) do
  if value[key]~=nil and not(spec==schema.root and RetiredRootKey(key))then result[key]=Clean(value[key],field)end
 end
 return result
end
function P.Validate(payload)
 if type(payload)~="table" or payload.app~="KerimAnkaUI" or payload.version~=1 or type(payload.class)~="string" or #payload.class>20 or type(payload.settings)~="table" then return false end
 local classes={HUNTER=true,ROGUE=true,MAGE=true,PRIEST=true,PALADIN=true,WARRIOR=true,WARLOCK=true,DRUID=true,SHAMAN=true,MONK=true,DEMONHUNTER=true,DEATHKNIGHT=true,EVOKER=true}
 if not classes[payload.class] then return false end
 for key in pairs(payload) do if key~="app" and key~="version" and key~="class" and key~="settings" then return false end end
 local ok=pcall(function()
  local budget={n=0}
  for key,value in pairs(payload.settings) do
   if not schema[key] then error("unknown module") end
   Validate(value,schema[key],0,budget)
  end
  if not payload.settings.root or not payload.settings.appearance then error("root") end
 end)
 return ok
end
function P.Encode(payload)
 if not P.Validate(payload) then return nil,"pfInvalid" end
 local ok,raw=pcall(serializer.Serialize,serializer,payload)
 if not ok or #raw>48000 then return nil,"pfTooLarge" end
 local code="KAUI1:"..Checksum(raw)..":"..Encode64(raw)
 if #code>P.MAX_CODE then return nil,"pfTooLarge" end
 return code
end
function P.Decode(code)
 if type(code)~="string" or #code>P.MAX_CODE+4096 then return nil,"pfTooLarge" end
 code=code:gsub("%s","")
 if #code>P.MAX_CODE then return nil,"pfTooLarge" end
 local sum,body=code:match("^KAUI1:([0-9a-f]+):([A-Za-z0-9+/=]+)$")
 if not sum or #sum~=8 then return nil,"pfInvalid" end
 local raw=Decode64(body)
 if not raw or #raw>48000 or Checksum(raw)~=sum then return nil,"pfInvalid" end
 local ok,value=serializer:Deserialize(raw)
 if not ok or not P.Validate(value) then return nil,"pfInvalid" end
 return value
end
local function Loaded(name)
 local fn=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
 return fn and fn(name)
end
local function CharacterKey()
 local name,realm=UnitFullName("player")
 return (name or UnitName("player") or "?").." - "..(realm or GetRealmName() or "?")
end
local function Store()
 if type(KerimAnkaUIDB.profileStore)~="table" then KerimAnkaUIDB.profileStore={} end
 if type(KerimAnkaUIDB.profileStore.named)~="table" then KerimAnkaUIDB.profileStore.named={} end
 if type(KerimAnkaUIDB.profileStore.characters)~="table" then KerimAnkaUIDB.profileStore.characters={} end
 return KerimAnkaUIDB.profileStore
end
function P.TransferFields(name)
 local fields={}
 for key in pairs(schema[name] and schema[name].fields or {}) do fields[#fields+1]=key end
 table.sort(fields);return fields
end
function P.Capture()
 local settings={root=Clean(K.db,schema.root),appearance=Clean(KerimAnkaUIDB,schema.appearance)}
 settings.root.bagTheme=nil -- legacy inputs are readable, never exported
 local prior=Store().characters[CharacterKey()]
 local previous,previousLoaded
 for name,addon in pairs(moduleFor) do
  if Loaded(addon) and type(_G[name])=="table" then settings[name]=Clean(_G[name],schema[name])
  elseif K.db.profileDeferred and K.db.profileDeferred[name] then settings[name]=Copy(K.db.profileDeferred[name])
  else
   -- Decode the previous portable profile only when an unloaded module needs it.
   if not previousLoaded then previous=prior and P.Decode(prior.code);previousLoaded=true end
   if previous then settings[name]=Copy(previous.settings[name]) end
  end
 end
 return {app="KerimAnkaUI",version=1,class=select(2,UnitClass("player")),settings=settings}
end
local function Record(code,name)
 return {code=code,name=name,stamp=time(),class=select(2,UnitClass("player"))}
end
local function Count(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
function P.StorageBytes()
 local total=0
 for _,group in pairs({Store().named,Store().characters}) do for _,record in pairs(group) do total=total+#record.code+(type(record.layouts)=="string" and #record.layouts or 0) end end
 return total
end
local function OldestCharacter(except)
 local key,stamp
 for name,record in pairs(Store().characters) do
  if name~=except and (not stamp or record.stamp<stamp) then key,stamp=name,record.stamp end
 end
 return key
end
-- Automatic saves run in their own timer callback, never on the transaction
-- commit stack. Coalesce simultaneous login/native-layout/module events.
local checkpointPending,checkpointPhase
function P.ScheduleCheckpoint(phase)
 if checkpointPending then
  if phase=="stable" then checkpointPhase=phase end
  return
 end
 if not C_Timer or not C_Timer.After then return end
 checkpointPending=true;checkpointPhase=phase
 C_Timer.After(.25,function()
  local requested=checkpointPhase
  checkpointPending=nil;checkpointPhase=nil
  if not P.ready or P.failed or K.InCombat() then return end
  P.Checkpoint(requested)
 end)
end
function P.Checkpoint(phase)
 if K.db and K.db.layoutEditRecovery or K.LayoutEditor and K.LayoutEditor.IsActive() then return end
 if not K.db or not schema.ForeverLeatherUnitsDB or K.db.profileTransaction or P.failedApply then return end
 local code=P.Encode(P.Capture());if not code then return end
 local key=CharacterKey();local entries=Store().characters
 local prior=entries[key]
 local record=Record(code,key)
 if K.ProfileLayouts then record.layouts=K.ProfileLayouts.Capture(prior and prior.layouts,false,phase) end
 entries[key]=record
 while Count(entries)>P.MAX_CHARACTERS or P.StorageBytes()>P.MAX_TOTAL do
  local old=OldestCharacter(key)
  if not old then entries[key]=nil;return end
  entries[old]=nil
 end
end
function P.Save(name)
 if K.db.profileTransaction then return false,"pfPendingProfile" end
 name=(name or ""):match("^%s*(.-)%s*$")
 if #name<1 or #name>48 or name:find("[%c|]") then return false,"pfBadName" end
 local entries=Store().named
 if entries[name] then return false,"pfExists" end
 if Count(entries)>=P.MAX_NAMED then return false,"pfFull" end
 local code,err=P.Encode(P.Capture());if not code then return false,err end
 local layouts=K.ProfileLayouts and K.ProfileLayouts.Capture()
 if P.StorageBytes()+#code+(layouts and #layouts or 0)>P.MAX_TOTAL then return false,"pfFull" end
 entries[name]=Record(code,name);entries[name].layouts=layouts;P.Checkpoint();return true
end
function P.Delete(group,key)
 local entries=Store()[group];if not entries or not entries[key] then return false end
 entries[key]=nil;return true
end
function P.Entries()
 P.Checkpoint()
 local result={}
 for _,group in ipairs({"named","characters"}) do
  local entries={};for key,record in pairs(Store()[group]) do entries[#entries+1]={group=group,key=key,record=record} end
  table.sort(entries,function(a,b) return a.key<b.key end)
  for _,entry in ipairs(entries) do result[#result+1]=entry end
 end
 return result
end
local function ReplaceTable(target,data)
 for key in pairs(target) do target[key]=nil end
 for key,value in pairs(data) do target[key]=Copy(value) end
end
local function ApplySettings(payload,selection)
 if selection then return K.ProfileTransfer.ApplySettings(payload,selection) end
 local data=payload.settings
 -- Restore CVars previously controlled here but absent from the incoming profile.
 local setter=C_CVar and C_CVar.SetCVar or SetCVar
 K.db.originalCVars=K.db.originalCVars or {}
 for key in pairs(data.root.cvars or {}) do
  if K.db.originalCVars[key]==nil and K.GetCVar then K.db.originalCVars[key]=K.GetCVar(key) end
 end
 for key in pairs(K.db.cvars or {}) do
  if not (data.root.cvars or {})[key] and setter and K.db.originalCVars[key] then pcall(setter,key,K.db.originalCVars[key]) end
 end
 for key in pairs(schema.root.fields) do K.db[key]=nil end
 for key,value in pairs(data.root)do if not RetiredRootKey(key)then K.db[key]=Copy(value)end end
 K.db.cvars=K.db.cvars or {};K.db.sounds=K.db.sounds or {}
 if K.ApplyCharacterAudio then K.ApplyCharacterAudio() end
 if K.BagMode then K.BagMode.ApplySaved() end
 if K.FPS then K.FPS.Refresh() end
 -- Core initializes sound state after the queued profile has been applied.
 for key in pairs(schema.appearance.fields) do KerimAnkaUIDB[key]=nil end
 for key,value in pairs(data.appearance) do KerimAnkaUIDB[key]=Copy(value) end
 K.db.profileDeferred={}
 for name,addon in pairs(moduleFor) do
  local value=data[name]
  if value then
   if Loaded(addon) then
    if type(_G[name])~="table" then _G[name]={} end
    ReplaceTable(_G[name],value)
   else K.db.profileDeferred[name]=Copy(value) end
  end
 end
end
local function Normalize(payload)
 local units=payload.settings.ForeverLeatherUnitsDB
 if units then
  -- Protocol v1 stores modern layouts. Never rerun one-time theme migrations.
  units.compactMigration=true
  if select(2,UnitClass("player"))=="HUNTER" then units.hunterThemeInitialized=true end
 end
 return payload
end
function P.Apply(code,label,layoutAction,selection)
 if selection and (not K.ProfileTransfer or not K.ProfileTransfer.ValidSelection(selection) or layoutAction) then return false,'pfInvalid' end
 if K.db and K.db.layoutEditRecovery or K.LayoutEditor and K.LayoutEditor.IsActive() then return false,"pfPendingProfile" end
 if K.InCombat() then return false,"combatLock" end
 if K.HasPendingModuleChanges(true) then return false,"pfPending" end
 if K.db.profileTransaction then return false,"pfPendingProfile" end
 local payload,err=P.Decode(code);if not payload then return false,err end
 payload=Normalize(payload)
 local after,afterError=P.Encode(payload);if not after then return false,afterError end
 local before,beforeError=P.Encode(P.Capture());if not before then return false,beforeError end
 local fullLayout
 if layoutAction then
  local ok,value,layoutError=pcall(K.FullLayout.Prepare,layoutAction)
  if not ok then return false,"flFailed" end
  if not value then return false,layoutError end
  fullLayout=value
 end
 -- Stage only. No live DB mutation and no protected reload API call.
 K.db.profileTransaction={version=1,before=before,after=after,label=label or K.L("pfBeforeApply"),stamp=time()}
 K.db.profileTransaction.fullLayout=fullLayout
 K.db.profileTransaction.selection=selection and Copy(selection) or nil
 if K.Message then K.Message("pfQueued") end
 return true,"pfQueued"
end
function P.RestoreBackup()
 if not K.db.profileBackup then return false,"pfNoBackup" end
 if K.db.profileBackup.layouts and K.ProfileLayouts then return K.ProfileLayouts.Queue(K.db.profileBackup,K.L("pfBeforeRestore")) end
 return P.Apply(K.db.profileBackup.code,K.L("pfBeforeRestore"),K.db.profileBackup.fullLayout and {mode="restore",target=K.db.profileBackup.fullLayout,setupRestore=K.db.profileBackup.classSetup})
end
function P.CancelPending()
 if P.active then return false end
 if K.ClassPresets and K.ClassPresets.CancelPreparedReload and not K.ClassPresets.CancelPreparedReload() then return false end
 K.db.profileTransaction=nil;return true
end
local function Match(expected,actual,path)
 if type(expected)~="table" then return expected==actual,path end
 if type(actual)~="table" then return false,path end
 for key,value in pairs(expected) do
  local ok,field=Match(value,actual[key],(path or "").."."..tostring(key))
  if not ok then return false,field end
 end
 return true
end
function P.BeginTransaction()
 local transaction=K.db.profileTransaction
 if not transaction then return end
 if type(transaction)~="table" or transaction.version~=1 then K.db.profileTransaction=nil;P.failedApply=true;return end
 local before=P.Decode(transaction.before);local after=P.Decode(transaction.after)
 if not before or not after then K.db.profileTransaction=nil;P.failedApply=true;return end
 P.active=transaction;P.activeBefore=before;P.activeAfter=Normalize(after)
 if transaction.selection and (not K.ProfileTransfer or not K.ProfileTransfer.ValidSelection(transaction.selection)) then P.active=nil;P.activeBefore=nil;P.activeAfter=nil;K.db.profileTransaction=nil;P.failedApply=true;return end
 ApplySettings(P.activeAfter,transaction.selection)
end
-- Called after a child's SavedVariables load, before its PLAYER_LOGIN initializer.
function P.OnAddonLoaded(addon)
 if not K.db or not K.db.profileDeferred then return end
 for name,owner in pairs(moduleFor) do
  local value=K.db.profileDeferred[name]
  if owner==addon and value then
   local backup=P.activeBefore or (K.db.profileBackup and P.Decode(K.db.profileBackup.code))
   if backup and not backup.settings[name] then
    backup.settings[name]=Clean(type(_G[name])=="table" and _G[name] or {},schema[name])
    local code=P.Encode(backup)
    if not code then P.deferredError=true;return end
    if P.active then P.active.before=code else K.db.profileBackup.code=code end
   end
   if name=="ForeverLeatherUnitsDB" then
    if value.totNameScale==nil then value.totNameScale=value.textScale or 1 end
    value.compactMigration=true
    if select(2,UnitClass("player"))=="HUNTER" then value.hunterThemeInitialized=true end
   end
   if type(_G[name])~="table" then _G[name]={} end
   ReplaceTable(_G[name],value);K.db.profileDeferred[name]=nil
  end
 end
end
function P.CommitTransaction()
 if not P.active then return end
 local transaction=P.active
 if (transaction.fullLayout or transaction.savedLayouts) and InCombatLockdown() then P.layoutWaiting=true;return end
 local report=K.FullLayout and K.FullLayout.BeginReport and K.FullLayout.BeginReport(transaction)
 local valid=true
 for name,owner in pairs(moduleFor) do
  local expected=P.activeAfter.settings[name]
  if expected and Loaded(owner) and (not transaction.selection or K.ProfileTransfer.ModuleSelected(transaction.selection,name)) then
   local matches,field=Match(expected,_G[name],name)
   if not matches then
    valid=false
    if report then
     report.mismatchCount=(report.mismatchCount or 0)+1
     report["mismatch"..report.mismatchCount]=field
    end
   end
  end
 end
 -- The pre-application snapshot is authoritative even if a native initializer fails.
 K.db.profileBackup=Record(transaction.before,transaction.label)
 if transaction.fullLayout then K.db.profileBackup.fullLayout=Copy(transaction.fullLayout.before);K.db.profileBackup.classSetup=Copy(transaction.fullLayout.setupBefore) end
 K.db.profileTransaction=nil;P.active=nil;P.activeBefore=nil;P.activeAfter=nil
 if not valid then if report then report.result="settings-failed" end;P.failedApply=true;return end
 if transaction.fullLayout and not K.FullLayout.Commit(transaction) then if report then report.result=K.FullLayout.status or "native-failed" end;P.failedApply=true;return end
 if transaction.savedLayouts and K.ProfileLayouts and not K.ProfileLayouts.Commit(transaction) then
  if transaction.fullLayout then pcall(K.FullLayout.Apply,{mode="restore",target=transaction.fullLayout.before,setupRestore=transaction.fullLayout.setupBefore}) end
  if report then report.result="bartender-failed" end
  P.failedApply=true;return
 end
 if report then report.result="applied" end
 P.applied=true
end
function P.Initialize()
 P.BuildSchema();Store()
 local test=pcall(P.SelfTest)
 if not test then P.failed=true;P.ready=true;return end
 P.ready=true
 for _,group in ipairs({"named","characters"}) do
  for key,record in pairs(Store()[group]) do
   if type(key)~="string" or type(record)~="table" or type(record.code)~="string" or #record.code>P.MAX_CODE or type(record.stamp)~="number" then Store()[group][key]=nil end
  end
 end
 P.CommitTransaction()
 P.ScheduleCheckpoint("login")
end
function P.SelfTest()
 for length=0,260 do
  local bytes={};for i=1,length do bytes[i]=string.char((i*71+length)%256) end
  local raw=table.concat(bytes);assert(Decode64(Encode64(raw))==raw,"base64 roundtrip")
 end
 assert(not Decode64("A==="));assert(not Decode64("AA=A"));assert(not Decode64("AB=="))
 local sample={app="KerimAnkaUI",version=1,class="HUNTER",settings={root={hideErrors=false,cvars={SpellQueueWindow="120"},sounds={[567407]=true}},appearance={glowColor={0,.5,1}},ForeverBarBackdropCharacterDB={enabled=true,bars={1,3,4},shade=.25}}}
 local code=assert(P.Encode(sample));local value=assert(P.Decode(code))
 assert(value.settings.root.hideErrors==false and value.settings.ForeverBarBackdropCharacterDB.bars[2]==3)
 assert(not P.Decode(code:sub(1,-2)),"truncated profile")
 assert(not P.Decode("KAUI2:"..code:sub(7)),"unknown version")
 assert(not P.Decode(code:sub(1,-3).."**"),"invalid alphabet")
 sample.settings.root.cvars.badCVar="1";assert(not P.Encode(sample),"cvar allowlist");sample.settings.root.cvars.badCVar=nil
 sample.settings.ForeverBarBackdropCharacterDB.shade="1";assert(not P.Encode(sample),"type validation")
 sample.settings.ForeverBarBackdropCharacterDB.shade=2;assert(not P.Encode(sample),"range validation")
 sample.settings.ForeverBarBackdropCharacterDB.shade=.2;sample.settings.root.fn=function() end;assert(not P.Encode(sample),"executable data rejected")
 return true
end
local profileEvents=CreateFrame("Frame")
profileEvents:RegisterEvent("PLAYER_LOGIN");profileEvents:RegisterEvent("PLAYER_LOGOUT");profileEvents:RegisterEvent("ADDON_LOADED")
profileEvents:SetScript("OnEvent",function(_,event,addon)
 if event=="PLAYER_LOGIN" then C_Timer.After(0,function() P.Initialize() end)
 elseif event=="PLAYER_LOGOUT" then P.Checkpoint("logout")
 elseif event=="ADDON_LOADED" then
  -- Parent SavedVariables have loaded; seed the deferred queue before children load.
  if addon==K.name and type(KerimAnkaUICharacterDB)=="table" then
   K.db=KerimAnkaUICharacterDB;P.BuildSchema()
   local ok=pcall(P.BeginTransaction);if not ok then P.failedApply=true end
  end
  if schema.ForeverLeatherUnitsDB then P.OnAddonLoaded(addon) end
 end
end)

end
