-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Pass secret threat values directly to supported display sinks.
-- Never concatenate, compare, perform arithmetic on, or log a secret value.
local frame=CreateFrame("Frame","ForeverThreatDisplay",UIParent)
frame:SetFrameStrata("HIGH"); frame:SetSize(170,62); frame:SetPoint("CENTER")
frame:SetMovable(true); frame:SetClampedToScreen(true); frame:RegisterForDrag("LeftButton")
local bg=frame:CreateTexture(nil,"BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(.025,.045,.035,.85)
local boldNumber=frame:CreateFontString(nil,"OVERLAY")
local number=frame:CreateFontString(nil,"OVERLAY"); number:SetPoint("CENTER")
boldNumber:SetPoint("CENTER",number,"CENTER",.8,0)
local texts={number,boldNumber}
local hint=frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
hint:SetPoint("TOP",frame,"BOTTOM",0,-2)
-- The placement hint follows the hub language and uses its Turkish/CJK font
-- support independently of the user's selected threat-number font.
if KerimAnkaUITextAPI and KerimAnkaUITextAPI.Font then KerimAnkaUITextAPI.Font(hint,11,false,"OUTLINE") end
hint:SetWordWrap(false)
local function Hint(key,fallback)
    local api=KerimAnkaUITextAPI
    return api and api.Hint and api.Hint(key) or fallback
end

local db,panel,SyncPanel
local Update,ApplyStyle,OpenPanel
local lastError
local function Secret(v) return issecretvalue and issecretvalue(v) end
local function Defaults()
    if type(KAClassic_ForeverThreatDB)~="table" then KAClassic_ForeverThreatDB={} end
    db=KAClassic_ForeverThreatDB
    for k,v in pairs({enabled=false,locked=true,size=30,alpha=1,x=0,y=40,r=1,g=.82,b=.2,autoColor=false,raw=false,
        font="Varsayılan",bold=false,outline=true,shadow=true,showPercent=false}) do
        if db[k]==nil or type(db[k])~=type(v) then db[k]=v end
    end
    db.size=math.max(12,math.min(96,db.size)); db.alpha=math.max(.2,math.min(1,db.alpha))
    for _,k in ipairs({"r","g","b"}) do db[k]=math.max(0,math.min(1,db[k])) end
end
local function SetText(text)
    for _,label in ipairs(texts) do label:SetText(text) end
end
local function FixedColor()
    for _,label in ipairs(texts) do label:SetTextColor(db.r,db.g,db.b,1) end
end
local function FontChoices()
    local default=STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    local choices={
        {name="Varsayılan",path=default},
        {name="Friz Quadrata",path="Fonts\\FRIZQT__.TTF"},
        {name="Arial Narrow",path="Fonts\\ARIALN.TTF"},
        {name="Morpheus",path="Fonts\\MORPHEUS.TTF"},
        {name="Skurri",path="Fonts\\SKURRI.TTF"},
    }
    local seen={}
    for _,entry in ipairs(choices) do seen[entry.name]=true end
    local media=LibStub and LibStub("LibSharedMedia-3.0",true)
    if media then
        for _,name in ipairs(media:List("font")) do
            if not seen[name] then
                choices[#choices+1]={name=name,path=media:Fetch("font",name)}
                seen[name]=true
            end
        end
    end
    return choices
end
local function FontPath()
    for _,entry in ipairs(FontChoices()) do
        if entry.name==db.font then return entry.path end
    end
    return STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
end
local function NoData(reason)
    lastError=reason
    SetText("") -- Clear the last target's value before hiding.
    if db.locked then frame:Hide()
    else
        SetText(db.showPercent and "75%" or "75")
        FixedColor(); hint:SetText(Hint("ftPreviewHint","PREVIEW - Drag / right-click: settings"))
        frame:Show()
    end
end
local layoutPreview=false
local function Render()
    if not db or not db.enabled then frame:Hide(); return end
    FixedColor()
    if layoutPreview then
        SetText(db.showPercent and "75%" or "75")
        if db.autoColor then
            local r,g,b=1,.6,0
            if GetThreatStatusColor then r,g,b=GetThreatStatusColor(2)end
            for _,label in ipairs(texts)do label:SetTextColor(r,g,b,1)end
        end
        frame:Show();return
    end
    local exists=UnitExists("target")
    if not Secret(exists) and not exists then NoData(nil); return end
    if not UnitDetailedThreatSituation then NoData("Tehdit API'si bulunamadı."); return end
    local ok,tanking,status,scaled,raw=pcall(UnitDetailedThreatSituation,"player","target")
    if not ok then NoData("Tehdit API'si bu durumda veri vermedi."); return end
    local value=scaled
    if db.raw then value=raw end
    if not Secret(value) then
        if value==nil then NoData(nil); return end
        if type(value)~="number" then NoData("Geçerli tehdit sayısı alınamadı."); return end
    end
    -- SetFormattedText is the engine's secret-aware text sink. Do not use string.format.
    local format=db.showPercent and "%.0f%%" or "%.0f"
    local formatted=pcall(function()
        for _,label in ipairs(texts) do label:SetFormattedText(format,value) end
    end)
    if not formatted then NoData("İstemci korumalı yüzdeyi yazdırmayı kabul etmedi."); return end
    if db.autoColor and GetThreatStatusColor then
        -- The native color function consumes status; the returned RGB goes directly to the font.
        if Secret(status) or status~=nil then
            pcall(function()
                local r,g,b=GetThreatStatusColor(status)
                for _,label in ipairs(texts) do label:SetTextColor(r,g,b,1) end
            end)
        end
    end
    lastError=nil
    hint:SetText(db.locked and "" or Hint("ftDragHint","Drag / right-click: settings"))
    frame:Show()
end
Update=function()
    local ok=pcall(Render)
    if not ok and db then NoData("İstemci bu durumda gösterimi kısıtladı.") end
end
ApplyStyle=function()
    local path=FontPath()
    for _,label in ipairs(texts) do
        local ok,result=pcall(label.SetFont,label,path,db.size,db.outline and "OUTLINE" or "")
        if not ok or result==false then
            label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",db.size,db.outline and "OUTLINE" or "")
        end
        label:SetShadowColor(0,0,0,db.shadow and 1 or 0)
        label:SetShadowOffset(db.shadow and 1 or 0,db.shadow and -1 or 0)
    end
    -- WoW has no BOLD font flag. A second text layer thickens any selected font
    -- while receiving protected values directly, without reading the rendered text.
    boldNumber:SetShown(db.bold)
    frame:SetSize(math.max(150,db.size*5),db.size+20)
    frame:SetAlpha(db.alpha); frame:EnableMouse(not db.locked)
    bg:SetShown(not db.locked); hint:SetShown(not db.locked)
    frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",db.x,db.y)
    Update()
end
frame:SetScript("OnDragStart",function(self)
    if db and not db.locked and not InCombatLockdown() then self:StartMoving() end
end)
frame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    local x,y=self:GetCenter(); local cx,cy=UIParent:GetCenter()
    if x and y then db.x=x-cx; db.y=y-cy end
    ApplyStyle()
end)
frame:SetScript("OnMouseUp",function(_,button) if button=="RightButton" then OpenPanel() end end)
frame:Hide()
local function BuildPanel()
    if panel then return end
    panel=CreateFrame("Frame","ForeverThreatOptions",UIParent)
    panel:SetSize(440,630); panel:SetPoint("CENTER"); panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true); panel:SetMovable(true); panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart",function(self) self:StartMoving() end)
    panel:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
    local backdrop=panel:CreateTexture(nil,"BACKGROUND"); backdrop:SetAllPoints(); backdrop:SetColorTexture(.025,.035,.045,.98)
    local title=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    title:SetPoint("TOPLEFT",18,-18); title:SetText("Forever Threat — Bedrohung")
    local close=CreateFrame("Button",nil,panel,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT")
    close:SetScript("OnClick",function() panel:Hide() end)
    local checks,labels={},{}
    local function Check(key,text,y)
        local b=CreateFrame("CheckButton",nil,panel,"UICheckButtonTemplate"); b:SetPoint("TOPLEFT",16,y)
        local t=panel:CreateFontString(nil,"OVERLAY","GameFontHighlight"); t:SetPoint("LEFT",b,"RIGHT",3,0); t:SetText(text)
        b:SetScript("OnClick",function(self) db[key]=self:GetChecked() and true or false; ApplyStyle(); SyncPanel() end)
        checks[key]=b
    end
    Check("enabled","Göstergeyi etkinleştir",-48)
    Check("locked","Konumu kilitle (tıklamalar alttaki hedefe geçer)",-82)
    Check("autoColor","Oyunun tehdit durumuna göre renk kullan",-116)
    Check("raw","Ham tehdit % (varsayılan: aggro eşiğine göre %)",-150)
    Check("showPercent","Sayı yanında % işaretini göster",-184)
    Check("bold","Kalın yazı",-218)
    Check("outline","Yazı kenarlığı (outline)",-252)
    Check("shadow","Yazı gölgesi",-286)
    local fontLabel=panel:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    fontLabel:SetPoint("TOPLEFT",22,-334); fontLabel:SetText("Yazı tipi")
    local fontButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    fontButton:SetSize(280,26); fontButton:SetPoint("TOPLEFT",138,-328)
    local fontMenu=CreateFrame("Frame",nil,panel,"BackdropTemplate")
    fontMenu:SetSize(300,190); fontMenu:SetPoint("TOPRIGHT",fontButton,"BOTTOMRIGHT",0,-2)
    fontMenu:SetFrameLevel(panel:GetFrameLevel()+20); fontMenu:EnableMouse(true)
    fontMenu:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    fontMenu:SetBackdropColor(.025,.035,.045,1); fontMenu:SetBackdropBorderColor(.45,.4,.25,1)
    local scroll=CreateFrame("ScrollFrame",nil,fontMenu,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",6,-6); scroll:SetPoint("BOTTOMRIGHT",-28,6)
    local child=CreateFrame("Frame",nil,scroll); child:SetWidth(260); scroll:SetScrollChild(child)
    local fontRows={}
    fontMenu:Hide()
    fontButton:SetScript("OnClick",function()
        if fontMenu:IsShown() then fontMenu:Hide(); return end
        local choices=FontChoices()
        for _,row in ipairs(fontRows) do row:Hide() end
        for i,entry in ipairs(choices) do
            local row=fontRows[i]
            if not row then
                row=CreateFrame("Button",nil,child,"UIPanelButtonTemplate")
                row:SetSize(258,24); row:SetPoint("TOPLEFT",0,-(i-1)*26)
                fontRows[i]=row
            end
            local name=entry.name
            row:SetText(name)
            row:SetScript("OnClick",function()
                db.font=name; fontMenu:Hide(); ApplyStyle(); SyncPanel()
            end)
            row:Show()
        end
        child:SetHeight(math.max(1,#choices*26)); scroll:SetVerticalScroll(0); fontMenu:Show()
    end)
    panel:SetScript("OnHide",function() fontMenu:Hide() end)
    local function Stepper(key,text,y,step,min,max,factor)
        local t=panel:CreateFontString(nil,"OVERLAY","GameFontHighlight"); t:SetPoint("TOPLEFT",22,y-6)
        labels[key]={text=t,label=text,factor=factor}
        for i,sign in ipairs({-1,1}) do
            local b=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate"); b:SetSize(34,24)
            b:SetPoint("TOPLEFT",panel,"TOPLEFT",338+(i-1)*40,y); b:SetText(sign<0 and "-" or "+")
            b:SetScript("OnClick",function() db[key]=math.max(min,math.min(max,db[key]+sign*step)); ApplyStyle(); SyncPanel() end)
        end
    end
    Stepper("size","Yazı boyutu",-380,2,12,96,1)
    Stepper("alpha","Görünürlük (%)",-416,.05,.2,1,100)
    local colors={{"Altın",1,.82,.2},{"Beyaz",1,1,1},{"Yeşil",.3,1,.3},{"Kırmızı",1,.25,.2},{"Mavi",.35,.7,1}}
    for i,c in ipairs(colors) do
        local b=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate"); b:SetSize(74,24)
        b:SetPoint("TOPLEFT",18+(i-1)*81,-462); b:SetText(c[1])
        b:SetScript("OnClick",function() db.r,db.g,db.b=c[2],c[3],c[4]; db.autoColor=false; ApplyStyle(); SyncPanel() end)
    end
    local reset=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate"); reset:SetSize(190,25)
    reset:SetPoint("TOPLEFT",18,-500); reset:SetText("Konumu merkeze getir")
    reset:SetScript("OnClick",function() db.x=0; db.y=40; db.locked=false; ApplyStyle(); SyncPanel() end)
    local note=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    note:SetPoint("TOPLEFT",18,-537); note:SetWidth(402); note:SetJustifyH("LEFT")
    note:SetText("Kilidi aç, sayıyı sürükle, sonra kilitle.\nÖNİZLEME yazan 75 yalnızca yerleştirme örneğidir.\nSayı hâlâ tehdit yüzdesidir; % işareti isteğe bağlıdır.\nVeri yoksa kilitli gösterge gizlenir.")
    local status=panel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    status:SetPoint("BOTTOMLEFT",18,10)
    SyncPanel=function()
        for key,b in pairs(checks) do b:SetChecked(db[key]) end
        fontButton:SetText(db.font.."  ▾")
        for key,v in pairs(labels) do v.text:SetText(v.label..": "..math.floor(db[key]*v.factor+.5)) end
        status:SetText(lastError or "Ayarlar bu karaktere kaydedilir. /fth")
    end
    panel:SetScript("OnShow",SyncPanel)
    table.insert(UISpecialFrames,"ForeverThreatOptions"); panel:Hide()
    if not KerimAnkaUIAPI and Settings and Settings.RegisterCanvasLayoutCategory then
        local page=CreateFrame("Frame"); page.name="Forever Threat"
        local t=page:CreateFontString(nil,"OVERLAY","GameFontNormalLarge"); t:SetPoint("TOPLEFT",20,-20); t:SetText("Forever Threat")
        local b=CreateFrame("Button",nil,page,"UIPanelButtonTemplate"); b:SetPoint("TOPLEFT",20,-60); b:SetSize(190,28); b:SetText("Tehdit göstergesi ayarları")
        b:SetScript("OnClick",function() OpenPanel() end)
        Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(page,page.name))
    end
end
OpenPanel=function()
    if KerimAnkaUIAPI then KerimAnkaUIAPI.OpenPage("threat"); return end
    if not db then return end; BuildPanel(); panel:Show()
end
SLASH_FOREVERTHREAT1="/fth"
SlashCmdList.FOREVERTHREAT=function(msg)
    if not db then return end
    if msg=="lock" then db.locked=true; ApplyStyle()
    elseif msg=="unlock" then db.locked=false; ApplyStyle()
    elseif msg=="off" then db.enabled=false; ApplyStyle()
    elseif msg=="on" then db.enabled=true; ApplyStyle()
    elseif msg=="status" then print("Forever Threat: "..(lastError or "Hazır; gösterge player → target verisini kullanıyor."))
    else OpenPanel() end
    if SyncPanel then SyncPanel() end
end
local events=CreateFrame("Frame")
for _,e in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","PLAYER_TARGET_CHANGED","UNIT_THREAT_LIST_UPDATE",
    "UNIT_THREAT_SITUATION_UPDATE","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED"}) do events:RegisterEvent(e) end
local pending=false
local function Queue()
    if pending then return end
    pending=true; C_Timer.After(0,function() pending=false; Update() end)
end
events:SetScript("OnEvent",function(_,event)
    if event=="PLAYER_LOGIN" then
        Defaults(); ApplyStyle(); BuildPanel()
        C_Timer.NewTicker(.25,function() if db.enabled then Update() end end)
    elseif event=="PLAYER_TARGET_CHANGED" then
        SetText(""); frame:Hide(); Queue()
    else Queue() end
end)

ForeverThreatAPI={version=1}
function ForeverThreatAPI.SetLayoutPreview(value)layoutPreview=value==true;Update()end
function ForeverThreatAPI.GetSettings() return db end
function ForeverThreatAPI.RefreshText() Update() end
function ForeverThreatAPI.GetFonts() return FontChoices() end
local boolKeys={enabled=true,locked=true,autoColor=true,raw=true,showPercent=true,bold=true,outline=true,shadow=true}
local bounds={size={12,96},alpha={.2,1},x={-2000,2000},y={-1200,1200}}
local function RefreshSettings()
    ApplyStyle()
    if SyncPanel then SyncPanel() end
end
function ForeverThreatAPI.Set(key,value)
    if not db or InCombatLockdown() then return false end
    if boolKeys[key] and type(value)=="boolean" then db[key]=value
    elseif bounds[key] and type(value)=="number" and value==value and math.abs(value)<math.huge then
        db[key]=math.max(bounds[key][1],math.min(bounds[key][2],value))
    elseif key=="font" and type(value)=="string" then
        local found=false
        for _,entry in ipairs(FontChoices()) do if entry.name==value then found=true; break end end
        if not found then return false end
        db.font=value
    else return false end
    RefreshSettings()
    return true
end
function ForeverThreatAPI.SetColor(r,g,b)
    if not db or InCombatLockdown() then return false end
    for _,value in ipairs({r,g,b}) do
        if type(value)~="number" or value~=value or math.abs(value)==math.huge then return false end
    end
    if r==nil or g==nil or b==nil then return false end
    db.r=math.max(0,math.min(1,r)); db.g=math.max(0,math.min(1,g)); db.b=math.max(0,math.min(1,b))
    db.autoColor=false
    RefreshSettings()
    return true
end
function ForeverThreatAPI.Center()
    if not db or InCombatLockdown() then return false end
    db.x=0; db.y=40; db.locked=false
    RefreshSettings()
    return true
end
