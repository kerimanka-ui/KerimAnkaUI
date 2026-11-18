local _, ns = ...
local db
local function Hint(key,fallback)
    local api=KerimAnkaUITextAPI
    return api and api.Hint and api.Hint(key) or fallback
end
local function Text(key)
 local api=KerimAnkaUITextAPI
 local value=api and api.HunterText("aspect",key,db[key],db[key.."Custom"]) or db[key]
 if key=="packText" and value=="" then return Hint("hunterAspect_packText","Pack active: Switch aspect!") end
 return value
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
for i = 1, 8 do
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
    packText = "",
    warnCheetah = true,
    warnPack = true,
    missingText = "Bir aspekt seç!",
    showText = true,
    cheetahGlow = true,
    hideWhileMounted = false,
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

local names, textures, spellNames, spellLevels = {}, {}, {}, {}
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
local speedAspects = {
    {id=5118,mode="cheetah",text="cheetahText",setting="warnCheetah",slot="KerimAnkaCheetah",filter="HELPFUL",icon=132242},
    {id=13159,mode="pack",text="packText",setting="warnPack",slot="KerimAnkaPack",filter="HELPFUL|PLAYER",icon=134400},
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

local function MountedState()
    if not IsMounted then return nil end
    local ok, mounted = pcall(IsMounted)
    if not ok or Secret(mounted) or type(mounted) ~= "boolean" then return nil end
    return mounted
end

local function LoadSpells()
    names, textures = {}, {}
    spellNames, spellLevels = {}, {}
    learned = {}
    local anyLearned, unknown = false, false
    for _, id in ipairs(ids) do
        local info = C_Spell.GetSpellInfo(id)
        if Secret(info) then info=nil end
        if info and not Secret(info.name) and info.name then
            names[info.name] = id
            spellNames[id] = info.name
            if not Secret(info.iconID) and type(info.iconID)=="number" then textures[id] = info.iconID end
        end
        if C_Spell.GetSpellLevelLearned then
            local ok,level=pcall(C_Spell.GetSpellLevelLearned,id)
            if ok and not Secret(level) and type(level)=="number" and level>0 and level<math.huge and level%1==0 then spellLevels[id]=level end
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

    if mode == "cheetah" or mode == "pack" then
        local spec=speedAspects[mode=="pack" and 2 or 1]
        icons[1]:SetSize(48,48)
        icons[1]:SetTexture(textures[spec.id] or spec.icon)
        icons[1]:SetPoint("TOP", panel, "TOP", 0, -10)
        icons[1]:Show()
        title:SetText(Text(spec.text))
    else
        local display = {}
        -- Explicit previews still demonstrate the layout on a level 1 character.
        for i, id in ipairs(ids) do
            if learned[id] or (i<=6 and (preview or unlocked)) then
                display[#display + 1] = id
            end
        end
        local size=math.min(48,(340-math.max(0,#display-1)*10)/math.max(1,#display))
        for i, id in ipairs(display) do
            icons[i]:SetSize(size,size)
            icons[i]:SetTexture(textures[id] or 134400)
            icons[i]:SetPoint("TOP", panel, "TOP", (i - (#display + 1) / 2) * (size+10), -10)
            icons[i]:Show()
        end
        title:SetText(Text("missingText"))
    end
    title:SetShown(db.showText)
    glow:SetShown((mode == "cheetah" or mode == "pack") and db.cheetahGlow)

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
            if id == 13159 then
                if Secret(aura.sourceUnit) or aura.sourceUnit==nil then unknown=true
                elseif aura.sourceUnit=="player" then return "pack" end
            elseif id then otherAspect = true end
        end
    end
    return otherAspect and "active" or "unknown"
end

-- Configure a native display outside restrictions. The game matches Cheetah and
-- owns the slot's visibility; addon code never reads that managed state back.
local nativeHost, nativeTitle, nativeGlow, nativeContainer
local nativeAttempted = false
local nativeVisualDirty = true
local function PublicBoolean(func, ...)
    if type(func) ~= "function" then return nil end
    local ok, value = pcall(func, ...)
    if not ok or Secret(value) or type(value) ~= "boolean" then return nil end
    return value
end
local function CanConfigureNative()
    return not combat and PublicBoolean(InCombatLockdown) == false
        and C_Secrets and PublicBoolean(C_Secrets.ShouldAurasBeSecret) == false
end
local function NativeVisible(visible)
    if nativeHost then nativeHost:SetAlpha(visible and 1 or 0) end
end
local function PrepareNative()
    if nativeHost then return true end
    if nativeAttempted or not CanConfigureNative() then return false end
    nativeAttempted = true
    local ready, host, nativeText, glowRegion, nativeOwner = pcall(function()
        if C_AddOns and C_AddOns.LoadAddOn then
            local loaded = C_AddOns.LoadAddOn("Blizzard_AuraContainer")
            if Secret(loaded) or loaded ~= true then return end
        end
        local parent = CreateFrame("Frame", nil, UIParent)
        parent:SetSize(340, 120)
        parent:SetPoint("CENTER", panel, "CENTER")
        parent:SetFrameStrata("HIGH")
        parent:SetAlpha(0)
        parent:Show()
        local container = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
        container:SetSize(340, 120)
        container:SetPoint("CENTER", parent, "CENTER")
        container:SetEnabled(false)
        container:SetUnit("player")
        local labels, borders = {}, {}
        for _,spec in ipairs(speedAspects) do
        local nativeLabel, nativeBorder, complete
        container:AddAuraSlot(spec.slot, spec.filter, {
            candidateFilters = {includeSpellIDs = {[spec.id] = true}},
            initializeFrame = function(button)
                button:SetSize(340, 120)
                button:SetPoint("CENTER", container, "CENTER")
                button:EnableMouse(false)
                local icon = button:CreateTexture(nil, "ARTWORK")
                icon:SetSize(48, 48)
                icon:SetPoint("TOP", button, "TOP", 0, -10)
                icon:SetTexture(textures[spec.id] or spec.icon)
                nativeLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                nativeLabel:SetPoint("BOTTOM", button, "BOTTOM", 0, 24)
                nativeLabel:SetWidth(330)
                nativeLabel:SetTextColor(1, 0.85, 0.3)
                nativeLabel:SetShadowColor(0, 0, 0, 1)
                nativeLabel:SetShadowOffset(1, -1)
                AlertFont(nativeLabel, "Ubuntu-B.ttf", 16)
                nativeLabel:SetText(Text(spec.text))
                nativeLabel:SetShown(db.showText)
                nativeBorder = button:CreateTexture(nil, "OVERLAY")
                nativeBorder:SetSize(88, 88)
                nativeBorder:SetPoint("CENTER", icon, "CENTER")
                nativeBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                nativeBorder:SetBlendMode("ADD")
                nativeBorder:SetVertexColor(1, 0.65, 0.15)
                nativeBorder:SetShown(db.cheetahGlow)
                local pulse = nativeBorder:CreateAnimationGroup()
                pulse:SetLooping("BOUNCE")
                local alpha = pulse:CreateAnimation("Alpha")
                alpha:SetFromAlpha(0.25)
                alpha:SetToAlpha(0.55)
                alpha:SetDuration(0.75)
                button:AddAuraShownAnimation(pulse)
                complete = true
            end,
        })
        if not complete then return end
        labels[spec.mode],borders[spec.mode]=nativeLabel,nativeBorder
        container:SetAuraSlotEnabled(spec.slot,db[spec.setting])
        end
        container:Show()
        container:SetEnabled(true)
        return parent, labels, borders, container
    end)
    if not ready or not host then return false end
    nativeHost, nativeTitle, nativeGlow, nativeContainer = host, nativeText, glowRegion, nativeOwner
    nativeVisualDirty = false
    return true
end
local function SyncNativeVisual()
    if not nativeHost or not nativeVisualDirty or not CanConfigureNative() then return end
    for _,spec in ipairs(speedAspects) do
        nativeTitle[spec.mode]:SetText(Text(spec.text))
        nativeTitle[spec.mode]:SetShown(db.showText)
        nativeGlow[spec.mode]:SetShown(db.cheetahGlow)
        AlertFont(nativeTitle[spec.mode], "Ubuntu-B.ttf", 16)
        nativeContainer:SetAuraSlotEnabled(spec.slot,db[spec.setting])
    end
    nativeVisualDirty = false
end

local function Update()
    if not initialized then return end
    NativeVisible(false)
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

    if db.hideWhileMounted then
        local mounted = MountedState()
        if mounted == nil or mounted then
            lastState = mounted == nil and "unknown" or "mounted"
            panel:Hide()
            return
        end
    end

    PrepareNative()
    SyncNativeVisual()
    local nativeCombat = nativeHost and combat and hasLearnedAspect == true
        and PublicBoolean(UnitIsDeadOrGhost, "player") == false
    if nativeCombat then
        NativeVisible(true)
        -- Keep missing-aspect detection only where aura access is explicitly public.
        -- Under restrictions the native Cheetah slot draws without Lua aura queries.
        if PublicBoolean(C_Secrets and C_Secrets.ShouldAurasBeSecret) ~= false then
            lastState = "native-combat"
            panel:Hide()
            return
        end
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
        if not nativeCombat and not warned then
            Message(Hint("hunterAspectUnknown","Aspect information is unavailable or restricted. The alert is hidden to avoid an incorrect warning."))
            warned = true
        end
    elseif state == "missing" then
        ShowWarning("missing")
    elseif (state == "cheetah" or state == "pack") and combat then
        local allowed=state=="pack" and db.warnPack or state=="cheetah" and db.warnCheetah
        if nativeCombat or not allowed then panel:Hide() else ShowWarning(state) end
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
        self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
        -- Flight starts/landings don't always send an aura or combat event.
        -- Poll only travel flags; scan auras only when the travel state changes.
        local lastTravel
        self.travelTicker = C_Timer.NewTicker(0.5, function()
            local ok, travelling = pcall(IsTravelling)
            local state = ok and travelling ~= nil and (travelling and "travel" or "ground") or "unknown"
            if db.hideWhileMounted then
                local mounted = MountedState()
                state = state .. (mounted == nil and ":unknown" or mounted and ":mounted" or ":unmounted")
            end
            if state ~= lastTravel then
                lastTravel = state
                Update()
            end
        end)
        if ns.RegisterOptions then ns.RegisterOptions() end
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
    elseif command == "test pack" then
        hubPreview=false; preview = "pack"
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
function HunterAspectAlertAPI.GetAspectCatalog()
    if not initialized then return {} end
    local result={}
    for i,id in ipairs(ids) do
        if i<=6 or learned[id] then
            result[#result+1]={id=id,name=spellNames[id] or tostring(id),iconID=textures[id],level=spellLevels[id],learned=learned[id]==true,
                warning=id==5118 and "warnCheetah" or id==13159 and "warnPack" or nil}
        end
    end
    return result
end
function HunterAspectAlertAPI.CanSetCombatWarnings()
    return initialized and not InCombatLockdown() and (not nativeHost or CanConfigureNative()) or false
end
function HunterAspectAlertAPI.GetPreview() return preview end
function HunterAspectAlertAPI.IsLocked() return ns.IsLocked() end
function HunterAspectAlertAPI.Set(key,value)
    if not initialized or InCombatLockdown() then return false end
    if (key=="warnCheetah" or key=="warnPack") and not HunterAspectAlertAPI.CanSetCombatWarnings() then return false end
    if (key=="enabled" or key=="showText" or key=="cheetahGlow" or key=="hideWhileMounted" or key=="warnCheetah" or key=="warnPack") and type(value)=="boolean" then db[key]=value
    elseif (key=="cheetahText" or key=="packText" or key=="missingText") and type(value)=="string" and #value<=400 then db[key]=value;db[key.."Custom"]=value~=""
    else return false end
    nativeVisualDirty = true
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
    db.cheetahText=""; db.packText=""; db.missingText="";db.cheetahTextCustom=false;db.packTextCustom=false;db.missingTextCustom=false
    nativeVisualDirty = true
    Update(); return true
end
function HunterAspectAlertAPI.SetPreview(mode)
    if not initialized or InCombatLockdown() then return false end
    if mode~=nil and mode~="cheetah" and mode~="pack" and mode~="missing" then return false end
    preview=mode; hubPreview=mode~=nil; Update(); return true
end
function HunterAspectAlertAPI.EndPreview()
    if hubPreview then preview=nil; hubPreview=false; Update() end
end

function HunterAspectAlertAPI.GetText(key) if db then return Text(key) end end
function HunterAspectAlertAPI.RefreshText()
 if not initialized then return end
 nativeVisualDirty = true
 if KerimAnkaUITextAPI then KerimAnkaUITextAPI.Font(title,16,true,"");KerimAnkaUITextAPI.Font(hint,10,false,"") end
 Update()
end
