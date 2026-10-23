local _, ns = ...
local db
local function Hint(key,fallback)
    local api=KerimAnkaUITextAPI
    return api and api.Hint and api.Hint(key) or fallback
end
local function Text(key)
 local api=KerimAnkaUITextAPI
 return api and api.HunterText("aspect",key,db[key],db[key.."Custom"]) or db[key]
end
local hubPreview=false
function ns.GetSettings() return db end
local addon = CreateFrame("Frame")
local panel = CreateFrame("Frame", "HunterAspectAlertPanel", UIParent)
panel:SetSize(340, 120)
panel:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
panel:SetFrameStrata("HIGH")
panel:SetMovable(true)
panel:SetClampedToScreen(true)
panel:RegisterForDrag("LeftButton")
panel:EnableMouse(false)
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("BOTTOM", 0, 24)
title:SetWidth(330)
title:SetTextColor(1, 0.85, 0.3)
title:SetShadowColor(0, 0, 0, 1)
title:SetShadowOffset(1, -1)

local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
hint:SetPoint("BOTTOM", 0, 7)
hint:SetTextColor(1, 1, 1)

-- Use the hub's bundled Latin Extended fonts for the on-screen alert too.
-- Preserve the original warning/hint sizes and flags; never alter global fonts.
local function AlertFont(label,file,fallbackSize)
    if KerimAnkaUITextAPI then KerimAnkaUITextAPI.Font(label,fallbackSize,file=="Ubuntu-B.ttf","");return end
    local _,size,flags=label:GetFont()
    label:SetFont("Interface\\AddOns\\KerimAnkaUI\\Fonts\\"..file,size or fallbackSize,flags or "")
end
AlertFont(title,"Ubuntu-B.ttf",16)
AlertFont(hint,"Ubuntu-R.ttf",10)

local icons = {}
for i = 1, 3 do
    icons[i] = panel:CreateTexture(nil, "ARTWORK")
    icons[i]:SetSize(48, 48)
end

local glow = CreateFrame("Frame", nil, panel)
glow:SetSize(88, 88)
glow:SetPoint("CENTER", icons[1], "CENTER")
local glowTexture = glow:CreateTexture(nil, "OVERLAY")
glowTexture:SetAllPoints()
glowTexture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
glowTexture:SetBlendMode("ADD")
glowTexture:SetVertexColor(1, 0.65, 0.15)
local elapsedGlow = 0
glow:SetScript("OnUpdate", function(self, elapsed)
    elapsedGlow = elapsedGlow + elapsed
    self:SetAlpha(0.40 + 0.15 * math.sin(elapsedGlow * 3))
end)
glow:Hide()
panel:SetScript("OnHide", function() glow:Hide() end)

ns.defaults = {
    enabled = false,
    cheetahText = "Geparden aktif: Aspekti değiştir!",
    missingText = "Bir aspekt seç!",
    showText = true,
    cheetahGlow = true,
}

local function InitializeSettings()
    if type(HunterAspectAlertCharacterDB)~="table" then
        local legacy=_G.HunterAspectAlertDB
        local fresh={}
        if type(legacy)=="table" then
            for key,value in pairs(ns.defaults) do
                if type(legacy[key])==type(value) then fresh[key]=legacy[key] end
            end
            if type(legacy.position)=="table" then
                local p=legacy.position
                fresh.position={p[1],p[2],p[3],p[4]}
            end
        end
        fresh.enabled=false
        HunterAspectAlertCharacterDB=fresh
    end
    db=HunterAspectAlertCharacterDB
    for key,value in pairs(ns.defaults) do
        if type(db[key])~=type(value) then db[key]=value end
    end
end

local names, textures = {}, {}
local learned = {}
local hasLearnedAspect
local ids = {
    13165, -- Hawk
    13163, -- Monkey
    5118,  -- Cheetah
    13159, -- Pack
    13161, -- Beast
    20043, -- Wild
    34074, -- Viper, if present
    61846, -- Dragonhawk, if present
}

local initialized, unlocked, preview
local combat = false
local lastState = "initializing"
local warned = false

local function Secret(value)
    return issecretvalue and issecretvalue(value)
end

local function Message(text)
    print("|cff80dfffHunterAspectAlert:|r " .. text)
end

local function KnowsAspect(id, name)
    local checked = false
    local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
    local function Check(func, ...)
        if not func then return false end
        local ok, value = pcall(func, ...)
        if ok and not Secret(value) and type(value) == "boolean" then
            checked = true
            return value
        end
        return false
    end
    if C_SpellBook and Check(C_SpellBook.IsSpellKnown, id, bank) then return true end
    if Check(IsPlayerSpell, id) or Check(IsSpellKnown, id) then return true end
    -- A higher learned rank can replace rank 1. Search the localized name too,
    -- explicitly excluding future/unlearned and inactive-spec spellbook entries.
    if name and C_SpellBook and C_SpellBook.FindSpellBookSlotForSpell then
        local ok, slot = pcall(C_SpellBook.FindSpellBookSlotForSpell,
            name, false, false, false, false)
        if ok and not Secret(slot) then
            checked = true
            if type(slot) == "number" and slot > 0 then return true end
        end
    end
    if checked then return false end
    return nil
end

local function IsTravelling()
    local taxi = UnitOnTaxi and UnitOnTaxi("player")
    local flying = IsFlying and IsFlying()
    if Secret(taxi) or Secret(flying) then return nil end
    return taxi or flying or false
end

local function LoadSpells()
    names, textures = {}, {}
    learned = {}
    local anyLearned, unknown = false, false
    for _, id in ipairs(ids) do
        local info = C_Spell.GetSpellInfo(id)
        if info and not Secret(info.name) and info.name then
            names[info.name] = id
            textures[id] = info.iconID
        end
        local name = info and not Secret(info.name) and info.name or nil
        local known = KnowsAspect(id, name)
        learned[id] = known == true
        if known == true then anyLearned = true end
        if known == nil then unknown = true end
    end
    if anyLearned then
        hasLearnedAspect = true
    elseif unknown then
        hasLearnedAspect = nil
    else
        hasLearnedAspect = false
    end
end

local function ShowWarning(mode)
    if KerimAnkaUITextAPI then KerimAnkaUITextAPI.Font(title,16,true,"") end
    for _, icon in ipairs(icons) do
        icon:Hide()
        icon:ClearAllPoints()
    end

    if mode == "cheetah" then
        icons[1]:SetTexture(textures[5118] or 132242)
        icons[1]:SetPoint("TOP", panel, "TOP", 0, -10)
        icons[1]:Show()
        title:SetText(Text("cheetahText"))
    else
        local display = {}
        -- Explicit previews still demonstrate the layout on a level 1 character.
        for _, id in ipairs({13165, 13163, 5118}) do
            if learned[id] or preview or unlocked then
                display[#display + 1] = id
            end
        end
        if #display == 0 then
            for _, id in ipairs(ids) do
                if learned[id] and #display < 3 then display[#display + 1] = id end
            end
        end
        for i, id in ipairs(display) do
            icons[i]:SetTexture(textures[id] or 134400)
            icons[i]:SetPoint("TOP", panel, "TOP", (i - (#display + 1) / 2) * 58, -10)
            icons[i]:Show()
        end
        title:SetText(Text("missingText"))
    end
    title:SetShown(db.showText)
    glow:SetShown(mode == "cheetah" and db.cheetahGlow)

    if unlocked then
        hint:SetText(Hint("hunterHintMove","Drag to move • Lock in settings"))
    elseif preview then
        hint:SetText(Hint("hunterHintPreview","PREVIEW"))
    else
        hint:SetText("")
    end
    panel:Show()
end

-- Never interpret restricted aura fields as proof of a missing aspect.
local function ReadAspect()
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then
        return "unknown"
    end
    if not next(names) then return "unknown" end

    local otherAspect = false
    local unknown = false
    for i = 1, 255 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if Secret(aura) then return "unknown" end
        if not aura then
            if otherAspect then return "active" end
            return unknown and "unknown" or "missing"
        end
        if Secret(aura.name) then
            unknown = true
        else
            local id = names[aura.name]
            if id == 5118 then return "cheetah" end
            if id then otherAspect = true end
        end
    end
    return otherAspect and "active" or "unknown"
end

local function Update()
    if not initialized then return end
    if not db.enabled then panel:Hide(); return end
    local travelOK, travelling = pcall(IsTravelling)
    if not travelOK or travelling == nil or travelling then
        lastState = travelOK and travelling and "travelling" or "unknown"
        panel:Hide()
        return
    end
    if preview or unlocked then
        ShowWarning(preview or "missing")
        return
    end

    local ok, state = pcall(function()
        if UnitIsDeadOrGhost("player") then return "dead" end
        if hasLearnedAspect == false then return "unlearned" end
        if hasLearnedAspect == nil then return "unknown" end
        return ReadAspect()
    end)
    if not ok then state = "unknown" end
    lastState = state

    if state == "unknown" then
        panel:Hide()
        if not warned then
            Message(Hint("hunterAspectUnknown","Aspect information is unavailable or restricted. The alert is hidden to avoid an incorrect warning."))
            warned = true
        end
    elseif state == "missing" then
        ShowWarning("missing")
    elseif state == "cheetah" and combat then
        ShowWarning("cheetah")
    else
        panel:Hide()
    end
end

panel:SetScript("OnDragStart", function(self)
    if unlocked then self:StartMoving() end
end)
panel:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    db.position = {point, relativePoint, x, y}
end)

function ns.SetLocked(locked)
    if locked and unlocked then
        panel:StopMovingOrSizing()
        local point, _, relativePoint, x, y = panel:GetPoint()
        db.position = {point, relativePoint, x, y}
    end
    unlocked = not locked
    if locked then preview = nil; hubPreview=false end
    panel:EnableMouse(unlocked)
    Update()
end

function ns.IsLocked() return not unlocked end
function ns.Preview(mode)
    hubPreview=false
    preview = mode
    if not mode then ns.SetLocked(true) else Update() end
end
function ns.ResetPosition()
    panel:StopMovingOrSizing()
    db.position = nil
    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    Update()
end
function ns.Refresh() Update() end

addon:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        local _, class = UnitClass("player")
        if class ~= "HUNTER" then
            self:UnregisterAllEvents()
            return
        end

        InitializeSettings()
        local p = db.position
        if type(p) == "table"
            and type(p[1]) == "string" and type(p[2]) == "string"
            and type(p[3]) == "number" and type(p[4]) == "number" then
            panel:ClearAllPoints()
            panel:SetPoint(p[1], UIParent, p[2], p[3], p[4])
        end

        LoadSpells()
        combat = InCombatLockdown()
        initialized = true
        self:RegisterUnitEvent("UNIT_AURA", "player")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_DEAD")
        self:RegisterEvent("PLAYER_ALIVE")
        self:RegisterEvent("PLAYER_UNGHOST")
        self:RegisterEvent("SPELLS_CHANGED")
        self:RegisterEvent("PLAYER_CONTROL_LOST")
        self:RegisterEvent("PLAYER_CONTROL_GAINED")
        -- Flight starts/landings don't always send an aura or combat event.
        -- Poll only travel flags; scan auras only when the travel state changes.
        local lastTravel
        self.travelTicker = C_Timer.NewTicker(0.5, function()
            local ok, travelling = pcall(IsTravelling)
            local state = ok and travelling ~= nil and (travelling and "travel" or "ground") or "unknown"
            if state ~= lastTravel then
                lastTravel = state
                Update()
            end
        end)
        if ns.RegisterOptions then ns.RegisterOptions() end
        Message(Hint("hunterAspectReady","Aspect Alert ready. Settings: KerimAnka UI."))
    elseif event == "PLAYER_REGEN_DISABLED" then
        combat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        combat = false
    elseif event == "PLAYER_ENTERING_WORLD" then
        combat = InCombatLockdown()
        LoadSpells()
    elseif event == "SPELLS_CHANGED" then
        LoadSpells()
    end
    Update()
end)
addon:RegisterEvent("PLAYER_LOGIN")

SLASH_HUNTERASPECTALERT1 = "/haa"
SlashCmdList.HUNTERASPECTALERT = function(input)
    if not initialized then return end
    local command = input:lower():match("^%s*(.-)%s*$")
    if command == "" or command == "settings" or command == "ayar" then
        ns.OpenOptions()
        return
    elseif command == "test" then
        hubPreview=false; preview = "cheetah"
    elseif command == "test missing" then
        hubPreview=false; preview = "missing"
    elseif command == "off" or command == "lock" then
        ns.SetLocked(true)
    elseif command == "unlock" then
        ns.SetLocked(false)
    elseif command == "reset" then
        ns.ResetPosition()
    elseif command == "status" then
        Update()
        Message("Durum: " .. lastState
            .. " | Savaş: " .. (combat and "evet" or "hayır"))
        return
    else
        Message("/haa test | /haa test missing | /haa off | "
            .. "/haa unlock | /haa lock | /haa reset | /haa status")
        return
    end
    Update()
end


HunterAspectAlertAPI={version=1}
function HunterAspectAlertAPI.GetSettings() return db end
function HunterAspectAlertAPI.GetPreview() return preview end
function HunterAspectAlertAPI.IsLocked() return ns.IsLocked() end
function HunterAspectAlertAPI.Set(key,value)
    if not initialized or InCombatLockdown() then return false end
    if (key=="enabled" or key=="showText" or key=="cheetahGlow") and type(value)=="boolean" then db[key]=value
    elseif (key=="cheetahText" or key=="missingText") and type(value)=="string" and #value<=400 then db[key]=value;db[key.."Custom"]=value~=""
    else return false end
    Update(); return true
end
function HunterAspectAlertAPI.SetLocked(value)
    if not initialized or InCombatLockdown() or type(value)~="boolean" then return false end
    ns.SetLocked(value); return true
end
function HunterAspectAlertAPI.ResetPosition()
    if not initialized or InCombatLockdown() then return false end
    ns.ResetPosition(); return true
end
function HunterAspectAlertAPI.ResetTexts()
    if not initialized or InCombatLockdown() then return false end
    db.cheetahText=""; db.missingText="";db.cheetahTextCustom=false;db.missingTextCustom=false
    Update(); return true
end
function HunterAspectAlertAPI.SetPreview(mode)
    if not initialized or InCombatLockdown() then return false end
    if mode~=nil and mode~="cheetah" and mode~="missing" then return false end
    preview=mode; hubPreview=mode~=nil; Update(); return true
end
function HunterAspectAlertAPI.EndPreview()
    if hubPreview then preview=nil; hubPreview=false; Update() end
end

function HunterAspectAlertAPI.GetText(key) if db then return Text(key) end end
function HunterAspectAlertAPI.RefreshText()
 if not initialized then return end
 if KerimAnkaUITextAPI then KerimAnkaUITextAPI.Font(title,16,true,"");KerimAnkaUITextAPI.Font(hint,10,false,"") end
 Update()
end
