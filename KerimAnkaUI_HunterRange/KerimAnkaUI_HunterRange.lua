local ADDON, ns = ...
local MEDIA = "Interface\\AddOns\\" .. ADDON .. "\\Media\\"
local AUTO_SHOT = 75
local function Hint(key,fallback)
    local api=KerimAnkaUITextAPI
    return api and api.Hint and api.Hint(key) or fallback
end

local states = {
    ranged = {"RANGED", .42, 1, .30},
    dead = {"DEAD ZONE", 1, .30, .25},
    melee = {"MELEE", 1, .74, .25},
    far = {"TOO FAR", .70, .73, .75},
    close = {"TOO CLOSE", 1, .48, .28},
    unknown = {"RANGE ?", .70, .73, .75},
    preview = {"RANGED", .42, 1, .30},
}
local defaults = {enabled=false, locked=true, width=230, height=36, fontSize=14,
    x=0, y=-190, coloredText=true, outline=true, shadow=true}
local db, bar, label, dot, group, hint, panel, SyncPanel
local preview, currentState, dragging
local hubPreview=false
local lastSwing, swingLength = -100, 0
local function Secret(value) return issecretvalue and issecretvalue(value) end
local function Say(text) print("|cff9bd478Forever Hunter Range:|r " .. text) end

local function Ask(func, ...)
    if not func then return nil end
    local ok, result = pcall(func, ...)
    if not ok or Secret(result) then return nil end
    if result == true or result == 1 then return true end
    if result == false or result == 0 then return false end
    return nil
end

local function Observe()
    if Ask(UnitIsDeadOrGhost,"player") == true
        or Ask(UnitOnTaxi,"player") == true or Ask(IsFlying) == true then
        return nil
    end
    if Ask(UnitExists,"target") ~= true or Ask(UnitIsDeadOrGhost,"target") == true
        or Ask(UnitCanAttack,"player","target") ~= true then
        return nil
    end
    -- The actual attack's range check accounts for the player's current range.
    -- No hard-coded 35-yard maximum is used for the ranged verdict.
    local shoot = Ask(C_Spell and C_Spell.IsSpellInRange, AUTO_SHOT, "target")
    if shoot == true then return "ranged" end
    local near = Ask(CheckInteractDistance, "target", 4)
    local melee
    if shoot == false and near == true then
        -- Five-yard item probe used by range libraries; nil means unavailable.
        melee = Ask(C_Item and C_Item.IsItemInRange or IsItemInRange, 37727, "target")
    end
    local recentSwing = GetTime() - lastSwing < swingLength + .35
    return ns.Classify(shoot, near, melee, recentSwing)
end

local function Text(mode)
 if mode=="preview" then mode="ranged" end
 local api=KerimAnkaUITextAPI
 local value=db and db[mode.."Text"]
 return api and api.HunterText("range",mode,value) or (value and value~="" and value or (states[mode] or states.unknown)[1])
end
local function Render()
    if not db or not db.enabled then if bar then bar:Hide() end; return end
    local state
    if preview then
        state = preview
    else
        local ok, observed = pcall(Observe)
        state = ok and observed or nil
        if not ok then state = "unknown" end
        if not state and not db.locked then state = "preview" end
    end
    if not state then bar:Hide(); currentState=nil; return end
    local style = states[state] or states.unknown
    currentState = state
    dot:SetVertexColor(style[2],style[3],style[4],1)
    local caption=Text(state)
    label:SetText(caption)
    local key=caption..":"..tostring(KerimAnkaUIDB and KerimAnkaUIDB.language)..":"..db.fontSize..":"..db.width..":"..db.height..":"..tostring(db.outline)
    if bar.captionKey~=key then
        local font=STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
        local flags=db.outline and "OUTLINE" or ""
        if KerimAnkaUITextAPI then KerimAnkaUITextAPI.Font(label,db.fontSize,false,flags) else label:SetFont(font,db.fontSize,flags) end
        local available=math.max(30,db.width-db.height*1.35-24)
        local measured=label:GetStringWidth()
        if measured>available then
            local size=math.max(8,math.floor(db.fontSize*available/measured))
            if KerimAnkaUITextAPI then KerimAnkaUITextAPI.Font(label,size,false,flags) else label:SetFont(font,size,flags) end
        end
        bar.captionKey=key
    end
    if db.coloredText then label:SetTextColor(style[2],style[3],style[4],1)
    else label:SetTextColor(.94,.89,.74,1) end
    -- Fit a changing caption without a continuous OnUpdate animation.
    group:SetWidth(label:GetStringWidth()+7+dot:GetWidth())
    hint:SetText(preview and Hint("hunterHintPreview","PREVIEW") or (not db.locked and Hint("hunterHintRangeMove","Drag to move • Right-click: settings") or ""))
    bar:Show()
end

local function Apply()
    if not bar then return end
    bar:SetSize(db.width,db.height)
    bar.backing:ClearAllPoints()
    bar.backing:SetPoint("TOPLEFT",bar,"TOPLEFT",db.height*.5,-db.height*.16)
    bar.backing:SetPoint("BOTTOMRIGHT",bar,"BOTTOMRIGHT",-db.height*.5,db.height*.16)
    local cap = db.height * 1.05
    bar.left:SetWidth(cap); bar.right:SetWidth(cap)
    bar.middle:ClearAllPoints()
    bar.middle:SetPoint("TOPLEFT",bar,"TOPLEFT",cap,0)
    bar.middle:SetPoint("BOTTOMRIGHT",bar,"BOTTOMRIGHT",-cap,0)
    if KerimAnkaUITextAPI then KerimAnkaUITextAPI.Font(label,db.fontSize,false,db.outline and "OUTLINE" or "") else label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",db.fontSize,db.outline and "OUTLINE" or "") end
    bar.captionKey=nil
    label:SetShadowColor(0,0,0,db.shadow and 1 or 0)
    label:SetShadowOffset(db.shadow and 1 or 0,db.shadow and -1 or 0)
    dot:SetSize(math.max(8,db.fontSize*.72),math.max(8,db.fontSize*.72))
    bar:EnableMouse(not db.locked)
    bar:ClearAllPoints(); bar:SetPoint("CENTER",UIParent,"CENTER",db.x,db.y)
    Render()
end

local function OpenPanel()
    if KerimAnkaUIAPI then KerimAnkaUIAPI.OpenPage("range"); return end
    if panel then panel:Show(); SyncPanel() end
end
local function BuildBar()
    bar=CreateFrame("Frame","ForeverHunterRangeBar",UIParent)
    bar:SetFrameStrata("HIGH"); bar:SetMovable(true); bar:SetClampedToScreen(true)
    bar:RegisterForDrag("LeftButton")
    local backing=bar:CreateTexture(nil,"BACKGROUND")
    backing:SetPoint("TOPLEFT",bar,"TOPLEFT",db.height*.5,-db.height*.16)
    backing:SetPoint("BOTTOMRIGHT",bar,"BOTTOMRIGHT",-db.height*.5,db.height*.16)
    backing:SetColorTexture(0,0,0,1) -- Deliberately opaque regardless of scenery.
    bar.backing=backing
    for _,side in ipairs({"left","middle","right"}) do
        local texture=bar:CreateTexture(nil,"ARTWORK")
        texture:SetTexture(MEDIA..side..".tga","CLAMP","CLAMP","TRILINEAR")
        texture:SetVertexColor(.82,.80,.74,1)
        texture:SetPoint("TOP",bar,"TOP"); texture:SetPoint("BOTTOM",bar,"BOTTOM")
        if side=="left" then texture:SetPoint("LEFT",bar,"LEFT")
        elseif side=="right" then texture:SetPoint("RIGHT",bar,"RIGHT") end
        bar[side]=texture
    end
    group=CreateFrame("Frame",nil,bar); group:SetPoint("CENTER"); group:SetSize(120,20)
    dot=group:CreateTexture(nil,"OVERLAY")
    dot:SetTexture("Interface\\COMMON\\Indicator-Gray")
    dot:SetPoint("LEFT",group,"LEFT")
    label=group:CreateFontString(nil,"OVERLAY")
    label:SetPoint("LEFT",dot,"RIGHT",7,0)
    hint=bar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    hint:SetPoint("TOP",bar,"BOTTOM",0,-2)
    bar:SetScript("OnDragStart",function(self)
        if not db.locked and not InCombatLockdown() then dragging=true; self:StartMoving() end
    end)
    bar:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing(); dragging=false
        local x,y=self:GetCenter(); local px,py=UIParent:GetCenter()
        if x and px then db.x=x-px; db.y=y-py end
        Apply()
    end)
    bar:SetScript("OnMouseUp",function(_,button) if button=="RightButton" then OpenPanel() end end)
end

local function BuildPanel()
    panel=CreateFrame("Frame","ForeverHunterRangeOptions",UIParent,"BackdropTemplate")
    panel:SetSize(440,490); panel:SetPoint("CENTER"); panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true); panel:EnableMouse(true)
    panel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    panel:SetBackdropColor(.025,.035,.025,1); panel:SetBackdropBorderColor(.4,.32,.18,1)
    local title=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    title:SetPoint("TOPLEFT",18,-18); title:SetText("Forever Hunter Range")
    local close=CreateFrame("Button",nil,panel,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT")
    close:SetScript("OnClick",function() panel:Hide() end)
    local checks,labels={},{}
    local function Check(key,text,y)
        local button=CreateFrame("CheckButton",nil,panel,"UICheckButtonTemplate")
        button:SetPoint("TOPLEFT",16,y)
        local caption=panel:CreateFontString(nil,"OVERLAY","GameFontHighlight")
        caption:SetPoint("LEFT",button,"RIGHT",3,0); caption:SetText(text)
        button:SetScript("OnClick",function(self) db[key]=self:GetChecked() and true or false; Apply(); SyncPanel() end)
        checks[key]=button
    end
    Check("enabled","Göstergeyi etkinleştir",-48)
    Check("locked","Konumu kilitle",-80)
    Check("coloredText","Yazı rengi de durumla birlikte değişsin",-112)
    Check("outline","Yazı kenarlığı (outline)",-144)
    Check("shadow","Yazı gölgesi",-176)
    local function Stepper(key,text,y,step,minimum,maximum)
        local caption=panel:CreateFontString(nil,"OVERLAY","GameFontHighlight")
        caption:SetPoint("TOPLEFT",22,y-6); labels[key]={caption,text}
        for i,sign in ipairs({-1,1}) do
            local button=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
            button:SetSize(34,24); button:SetPoint("TOPLEFT",panel,"TOPLEFT",338+(i-1)*40,y)
            button:SetText(sign<0 and "-" or "+")
            button:SetScript("OnClick",function()
                db[key]=math.max(minimum,math.min(maximum,db[key]+sign*step)); Apply(); SyncPanel()
            end)
        end
    end
    Stepper("width","Genişlik",-220,10,150,420)
    Stepper("height","Yükseklik",-252,2,28,60)
    Stepper("fontSize","Yazı boyutu",-284,1,10,24)
    local order={"ranged","dead","melee","far","close","unknown"}
    local index=0
    local test=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    test:SetSize(190,26); test:SetPoint("TOPLEFT",18,-328); test:SetText("Durumları önizle")
    test:SetScript("OnClick",function() hubPreview=false; index=index%#order+1; preview=order[index]; Render(); SyncPanel() end)
    local live=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    live:SetSize(190,26); live:SetPoint("TOPLEFT",230,-328); live:SetText("Canlı takibe dön")
    live:SetScript("OnClick",function() hubPreview=false; preview=nil; Render(); SyncPanel() end)
    local note=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    note:SetPoint("TOPLEFT",18,-373); note:SetWidth(400); note:SetJustifyH("LEFT")
    note:SetText("Kilidi açıp barı swing timer'ın üstüne sürükle.\nArka plan opak siyahtır. Renkler ve yazı birlikte değişir.\nTOO CLOSE: yakınsın, kesin melee/dead zone ayrımı yok.\nRANGE ?: oyun menzil bilgisini vermiyor.\nÖnizleme gerçek hedef ölçümü değildir.")
    SyncPanel=function()
        for key,button in pairs(checks) do button:SetChecked(db[key]) end
        for key,entry in pairs(labels) do entry[1]:SetText(entry[2]..": "..db[key]) end
    end
    panel:SetScript("OnShow",SyncPanel); panel:Hide()
    table.insert(UISpecialFrames,"ForeverHunterRangeOptions")
    if not KerimAnkaUIAPI and Settings and Settings.RegisterCanvasLayoutCategory then
        local page=CreateFrame("Frame"); page.name="Forever Hunter Range"
        local button=CreateFrame("Button",nil,page,"UIPanelButtonTemplate")
        button:SetPoint("TOPLEFT",20,-30); button:SetSize(240,28); button:SetText("Menzil göstergesi ayarları")
        button:SetScript("OnClick",OpenPanel)
        Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(page,page.name))
    end
end

local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent",function(self,event,...)
    if event=="PLAYER_LOGIN" then
        if select(2,UnitClass("player"))~="HUNTER" then self:UnregisterAllEvents(); return end
        if type(ForeverHunterRangeDB)~="table" then ForeverHunterRangeDB={} end
        db=ForeverHunterRangeDB
        for key,value in pairs(defaults) do if type(db[key])~=type(value) then db[key]=value end end
        db.width=math.max(150,math.min(420,db.width)); db.height=math.max(28,math.min(60,db.height))
        db.fontSize=math.max(10,math.min(24,db.fontSize))
        BuildBar(); BuildPanel(); Apply()
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        -- Forever-specific: a missing event must not abort startup as in older clients.
        ns.swingEventSupported=pcall(self.RegisterEvent,self,"PLAYER_SWING")
        C_Timer.NewTicker(.15,function() if not dragging and db.enabled then Render() end end)
        Say(Hint("hunterRangeReady","Hunter Range ready. Settings: KerimAnka UI."))
    elseif event=="PLAYER_TARGET_CHANGED" or event=="PLAYER_ENTERING_WORLD" then
        lastSwing,swingLength=-100,0
        Render()
    elseif event=="PLAYER_SWING" then
        local length,weapon=...
        if not Secret(length) and not Secret(weapon) and type(length)=="number"
            and weapon==0 and length>0 and Ask(UnitCanAttack,"player","target")==true then
            lastSwing=GetTime(); swingLength=math.min(length,10)
            Render()
        end
    end
end)

SLASH_FOREVERHUNTERRANGE1="/fhr"
SlashCmdList.FOREVERHUNTERRANGE=function(input)
    if not db then return end
    local command=(input or ""):lower():match("^%s*(.-)%s*$")
    if command=="lock" then hubPreview=false; db.locked=true; preview=nil; Apply()
    elseif command=="unlock" then db.locked=false; Apply()
    elseif command=="live" then hubPreview=false; preview=nil; Render()
    elseif command=="test" then hubPreview=false; preview="ranged"; Render()
    elseif command=="status" then
        Say("Durum: "..(currentState or "hidden").." • swing olayı: "..(ns.swingEventSupported and "var" or "yok"))
    elseif command=="probe" then
        Say("Auto Shot="..tostring(Ask(C_Spell and C_Spell.IsSpellInRange,AUTO_SHOT,"target"))
            .." • yakın28="..tostring(Ask(CheckInteractDistance,"target",4))
            .." • melee5="..tostring(Ask(C_Item and C_Item.IsItemInRange or IsItemInRange,37727,"target")))
    else OpenPanel() end
    if SyncPanel then SyncPanel() end
end

ForeverHunterRangeAPI={version=1}
function ForeverHunterRangeAPI.GetSettings() return db end
function ForeverHunterRangeAPI.GetPreview() return preview end
local ranges={width={150,420},height={28,60},fontSize={10,24},x={-2000,2000},y={-1200,1200}}
function ForeverHunterRangeAPI.Set(key,value)
    if not db or InCombatLockdown() then return false end
    if type(defaults[key])=="boolean" and type(value)=="boolean" then db[key]=value
    elseif ranges[key] and type(value)=="number" and value==value and math.abs(value)<math.huge then
        db[key]=math.max(ranges[key][1],math.min(ranges[key][2],value))
    else return false end
    Apply()
    if SyncPanel then SyncPanel() end
    return true
end
function ForeverHunterRangeAPI.SetPreview(mode)
    if not db or InCombatLockdown() then return false end
    if mode~=nil and (not states[mode] or mode=="preview") then return false end
    preview=mode; hubPreview=mode~=nil
    Render()
    if SyncPanel then SyncPanel() end
    return true
end
function ForeverHunterRangeAPI.EndPreview()
    -- Only temporary samples started by the hub are stopped on page/window exit.
    -- This changes no secure attributes and also cleans up if combat began meanwhile.
    if hubPreview then
        preview=nil; hubPreview=false; Render()
        if SyncPanel then SyncPanel() end
    end
end

function ForeverHunterRangeAPI.GetText(mode) return Text(mode) end
function ForeverHunterRangeAPI.SetText(mode,value)
 if not db or InCombatLockdown() or not states[mode] or mode=="preview" or type(value)~="string" or #value>400 then return false end
 db[mode.."Text"]=value~="" and value or nil
 Render();return true
end
function ForeverHunterRangeAPI.RefreshText() if db and bar then bar.captionKey=nil;Render() end end
