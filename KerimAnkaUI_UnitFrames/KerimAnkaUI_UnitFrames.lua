local addonName = ...
local PATH = "Interface\\AddOns\\KerimAnkaUI_UnitFrames\\"
local W, H = 360, 360 * 686 / 2152
local frames, originals, errors = {}, {}, {}
local db, panel, pending = nil, nil, false
local deferredInit = false
local events = CreateFrame("Frame")
local layout = {
    Portrait = { .066914, .106414, .257900, .755102 },
    Health = { .350836, .457726, .597119, .148688 },
    Power = { .335502, .693878, .604554, .118076 },
}
local defaults = { nameOffsetY=0,petTextScale=1, hunterSummons=true,hunterSummonSize=26,hunterSummonGap=6,hunterSummonX=250,hunterSummonY=-8, questieTargetIcon=true, questieIconSize=26, questieIconX=-4, questieIconY=0, portraitCombatPlayer=false, portraitCombatPet=false, portraitCombatSize=24, enabled = false, hideNative = false, locked = true, scale = 1, textScale = 1,
    showToT = true, totScale = 1, showCombo = false,
    healthTextScale = 1, powerTextScale = 1, levelTextScale = 1, levelOffsetY = 4,
    pvpOffsetX = 18, pvpOffsetY = 20, classificationTextScale = 1,
    raidMarkerSize = 26, raidMarkerOffsetX = 0, raidMarkerOffsetY = 8,
    showPetHappiness = true, happinessSize = 28, happinessOffsetX = 6, happinessOffsetY = 0,
    pvpSize = 26, leaderSize = 18, restIconSize = 18, combatIconSize = 18 }
local playerClass
local hunterTheme = false
local warlockTheme, petTheme, themeGeometry = false, false, nil
local shamanTheme=false
local mageTheme=false
local druidTheme=false
local priestTheme=false
local warriorTheme=false
local paladinTheme=false
local frameFile = "LeatherFrame.tga"
local function secret(value) return issecretvalue and issecretvalue(value) or false end
local function say(text) DEFAULT_CHAT_FRAME:AddMessage("|cffb5dc97Leather Units:|r " .. text) end
local function checked(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then
        local message = secret(result) and "restricted value" or tostring(result)
        errors[message] = (errors[message] or 0) + 1
        if errors[message] == 1 then say("Testfehler: " .. message) end
    end
    return ok, result
end
local function public(fn, ...)
    local ok, value = pcall(fn, ...)
    if ok and not secret(value) then return value end
end
local function slot(parent, child, coords, mirrored)
    local W,H=parent:GetWidth(),parent:GetHeight()
    local x, y, width, height = unpack(coords)
    if mirrored then x = 1 - x - width end
    child:ClearAllPoints()
    child:SetPoint("TOPLEFT", parent, "TOPLEFT", x * W, -y * H)
    child:SetSize(width * W, height * H)
end
local function text(parent, size, width, unitName)
    local font = parent:CreateFontString(nil, "OVERLAY")
    if unitName then KerimAnkaUITextAPI.NameFont(font,size,false)
    else font:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, "OUTLINE") end
    font:SetWidth(width)
    font:SetWordWrap(false)
    font:SetShadowOffset(1, -1)
    return font
end
local function addSplitLabels(f, parent)
    if not themeGeometry then return end
    f.useSplit = true
    f.hpText:ClearAllPoints(); f.hpText:SetWidth(f.health:GetWidth() * .55)
    f.hpText:SetPoint("RIGHT", f.health, "RIGHT", -4, 0); f.hpText:SetJustifyH("RIGHT")
    f.hpPercent = text(parent, 12, f.health:GetWidth() * .4)
    f.hpPercent:SetPoint("LEFT", f.health, "LEFT", 4, 0); f.hpPercent:SetJustifyH("LEFT")
    if f.power then
        f.powerText:ClearAllPoints(); f.powerText:SetWidth(f.power:GetWidth() * .55)
        f.powerText:SetPoint("RIGHT", f.power, "RIGHT", -4, 0); f.powerText:SetJustifyH("RIGHT")
        f.powerPercent = text(parent, 11, f.power:GetWidth() * .4)
        f.powerPercent:SetPoint("LEFT", f.power, "LEFT", 4, 0); f.powerPercent:SetJustifyH("LEFT")
    end
end
-- Use Blizzard's existing UNIT_COMBAT renderer and animation, without a combat log parser.
local feedbackEvents = CreateFrame("Frame")
local feedbackUnits = {}
local function stopFeedback(f)
    local overlay = f and f.combatFeedback
    if overlay then
        overlay:SetScript("OnUpdate", nil)
        overlay.feedbackText:Hide()
        overlay:Hide()
    end
end
local function feedbackOverlay(f)
    if f.combatFeedback then return f.combatFeedback end
    local overlay = CreateFrame("Frame", nil, f)
    overlay:EnableMouse(false)
    overlay:SetAllPoints(f.portraitHolder)
    overlay:SetFrameLevel(f:GetFrameLevel() + 8)
    local label = text(overlay, 24, 200)
    label:SetPoint("CENTER", f.portraitHolder, "CENTER")
    CombatFeedback_Initialize(overlay, label, db.portraitCombatSize)
    overlay:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
        self.feedbackText:Hide()
    end)
    f.combatFeedback = overlay
    stopFeedback(f)
    return overlay
end
local function applyFeedback()
    feedbackEvents:UnregisterEvent("UNIT_COMBAT")
    wipe(feedbackUnits)
    local supported = type(CombatFeedback_Initialize) == "function"
        and type(CombatFeedback_OnCombatEvent) == "function" and type(CombatFeedback_OnUpdate) == "function"
    for _, unit in ipairs({"player", "pet"}) do
        local f = frames[unit]
        local enabled = db.enabled and supported and f and f.portraitHolder
            and (unit == "player" and db.portraitCombatPlayer or unit == "pet" and db.showPet and db.portraitCombatPet)
        if enabled then
            feedbackUnits[unit] = f
            feedbackOverlay(f).feedbackFontHeight = db.portraitCombatSize
        else stopFeedback(f) end
    end
    if feedbackUnits.player and feedbackUnits.pet then feedbackEvents:RegisterUnitEvent("UNIT_COMBAT", "player", "pet")
    elseif feedbackUnits.player then feedbackEvents:RegisterUnitEvent("UNIT_COMBAT", "player")
    elseif feedbackUnits.pet then feedbackEvents:RegisterUnitEvent("UNIT_COMBAT", "pet") end
end
feedbackEvents:SetScript("OnEvent", function(_, _, unit, event, flags, amount, damageType)
    local f = feedbackUnits[unit]
    if not f or not f:IsVisible() then return end
    local overlay = f.combatFeedback
    local ok = checked(CombatFeedback_OnCombatEvent, overlay, event, flags, amount, damageType)
    if not ok then stopFeedback(f);return end
    overlay:Show()
    overlay:SetScript("OnUpdate", function(self, elapsed)
        if not checked(CombatFeedback_OnUpdate, self, elapsed) or not self.feedbackText:IsShown() then stopFeedback(f) end
    end)
end)

-- Optional Questie bridge: use Questie's selected objective icon, without moving its frames.
local questieEvents = CreateFrame("Frame")
local questieModule, hookedQuestie, questieIcon, questieQueued
local function hideQuestieIcon()
    if questieIcon then questieIcon:Hide();questieIcon.Icon:SetTexture(nil);questieIcon.lastIcon=nil end
end
local function questieProfile()
    return Questie and Questie.db and Questie.db.profile
end
local function updateQuestieIcon()
    local f = frames.target
    local profile = questieProfile()
    if not db or not db.enabled or not db.questieTargetIcon or not questieModule
        or not profile or not profile.nameplateTargetFrameEnabled or not f or not f.portraitHolder then hideQuestieIcon();return end
    -- Respect Questie's restriction on Forever instances before querying any unit identifiers.
    if Questie.IsForever and public(IsInInstance) then hideQuestieIcon();return end
    local guid = public(UnitGUID, "target")
    if type(guid) ~= "string" or not (guid:match("^Creature%-") or guid:match("^Vehicle%-")) then hideQuestieIcon();return end
    local ok, icon = pcall(questieModule.GetIcon, guid)
    if not ok or secret(icon) or (type(icon) ~= "string" and type(icon) ~= "number") then hideQuestieIcon();return end
    if not questieIcon then
        if InCombatLockdown() then return end
        questieIcon = CreateFrame("Frame", nil, f)
        questieIcon:EnableMouse(false)
        questieIcon:SetFrameLevel(f:GetFrameLevel() + 8)
        questieIcon.Icon = questieIcon:CreateTexture(nil, "OVERLAY")
        questieIcon.Icon:SetAllPoints()
        f.questieIcon = questieIcon
    end
    questieIcon:ClearAllPoints()
    questieIcon:SetPoint("CENTER", f.portraitHolder, "TOPRIGHT", db.questieIconX, db.questieIconY)
    questieIcon:SetSize(db.questieIconSize, db.questieIconSize)
    if questieIcon.lastIcon ~= icon then questieIcon.Icon:SetTexture(icon);questieIcon.lastIcon=icon end
    questieIcon:Show()
end
local function queueQuestieIcon()
    if questieQueued or not db or not db.enabled or not db.questieTargetIcon then return end
    questieQueued = true
    C_Timer.After(0, function() questieQueued=false;updateQuestieIcon() end)
end
local function applyQuestieTarget()
    if QuestieLoader and type(QuestieLoader.ImportModule) == "function" then
        local ok, module = pcall(QuestieLoader.ImportModule, QuestieLoader, "QuestieNameplate")
        if ok and type(module) == "table" and type(module.GetIcon) == "function" then questieModule=module end
    end
    if questieModule and hookedQuestie ~= questieModule then
        hookedQuestie = questieModule
        for _, method in ipairs({"DrawTargetFrame", "UpdateNameplate", "RedrawFrameIcon"}) do
            if type(questieModule[method]) == "function" then hooksecurefunc(questieModule, method, queueQuestieIcon) end
        end
        if type(questieModule.HideCurrentTargetFrame) == "function" then hooksecurefunc(questieModule, "HideCurrentTargetFrame", hideQuestieIcon) end
    end
    for _, event in ipairs({"PLAYER_TARGET_CHANGED", "QUEST_LOG_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED"}) do
        questieEvents:UnregisterEvent(event)
        if db and db.enabled and db.questieTargetIcon and questieModule then questieEvents:RegisterEvent(event) end
    end
    updateQuestieIcon()
end
questieEvents:RegisterEvent("PLAYER_LOGIN")
questieEvents:RegisterEvent("ADDON_LOADED")
questieEvents:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon ~= "Questie" then return end
    if event == "PLAYER_LOGIN" or event == "ADDON_LOADED" then
        C_Timer.After(0, applyQuestieTarget)
    else
        if event == "PLAYER_TARGET_CHANGED" then hideQuestieIcon() end
        queueQuestieIcon()
    end
end)

-- Relocate Blizzard's existing summon widget. Its events, pool, visibility,
-- textures and countdown scripts stay native and execute without addon wrappers.
local summonEvents=CreateFrame("Frame")
local nativeSummons,summonOriginal,summonPending
local function saveSummons(f)
    local s={parent=f:GetParent(),scale=f:GetScale(),points={},spacing=f.spacing,
        leftPadding=f.leftPadding,topPadding=f.topPadding,ignore=f.ignoreFramePositionManager}
    for i=1,f:GetNumPoints() do s.points[i]={f:GetPoint(i)} end
    return s
end
local function restoreSummons()
    if not summonOriginal or not nativeSummons then return end
    local f,s=nativeSummons,summonOriginal
    f:SetParent(s.parent);f:SetScale(s.scale)
    f.spacing=s.spacing;f.leftPadding=s.leftPadding;f.topPadding=s.topPadding
    f.ignoreFramePositionManager=s.ignore
    f:ClearAllPoints();for _,point in ipairs(s.points) do f:SetPoint(unpack(point)) end
    if f.Layout then f:Layout() end
    if f.layoutParent and f.layoutParent.AddManagedFrame then f.layoutParent:AddManagedFrame(f) end
    summonOriginal=nil
end
local function applySummons()
    if InCombatLockdown() then summonPending=true;return end
    summonPending=false
    local f=_G.TotemFrame
    if not db or not db.enabled or (playerClass~="HUNTER" and playerClass~="SHAMAN") or not db.hunterSummons or not frames.player or not f then
        restoreSummons();return
    end
    if nativeSummons and nativeSummons~=f then restoreSummons() end
    nativeSummons=f
    if not summonOriginal then
        summonOriginal=saveSummons(f)
        -- Official managed-layout opt-out keeps OnShow from moving it back.
        f.ignoreFramePositionManager=true
        if f.layoutParent and f.layoutParent.RemoveManagedFrame then f.layoutParent:RemoveManagedFrame(f) end
    end
    local scale=db.hunterSummonSize/30 -- native decorative ring is 30 pixels
    f:SetParent(frames.player);f:SetScale(scale)
    f.spacing=(db.hunterSummonSize+db.hunterSummonGap)/scale-37
    f.leftPadding=0;f.topPadding=0
    f:ClearAllPoints()
    -- Offsets are configured in player-frame units, independently of icon scale.
    f:SetPoint("TOPLEFT",frames.player,"BOTTOMLEFT",db.hunterSummonX/scale,db.hunterSummonY/scale)
    if f.Layout then f:Layout() end
end
summonEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
summonEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
summonEvents:RegisterEvent("ADDON_LOADED")
summonEvents:SetScript("OnEvent",function(_,event,addon)
    if event=="ADDON_LOADED" and addon~="Blizzard_UnitFrame" then return end
    if event=="PLAYER_REGEN_ENABLED" and not summonPending then return end
    applySummons()
end)

local function setPercent(label, unit, current, maximum, isPower)
    if not secret(maximum) and type(maximum) == "number" and maximum == 0 then label:SetText("—"); return end
    local curve = CurveConstants and CurveConstants.ScaleTo100
    local ok, value
    if curve then
        if isPower and UnitPowerPercent then ok, value = pcall(UnitPowerPercent, unit, nil, false, curve)
        elseif not isPower and UnitHealthPercent then ok, value = pcall(UnitHealthPercent, unit, true, curve) end
    end
    if ok and (secret(value) or type(value) == "number") then
        checked(label.SetFormattedText, label, "%.0f%%", value)
    elseif not secret(current) and not secret(maximum) and type(current) == "number" and type(maximum) == "number" and maximum > 0 then
        label:SetFormattedText("%.0f%%", current / maximum * 100)
    else label:SetText("—") end
end
local function maskedTexture(parent, name, mirrored, layer, pet)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetAllPoints()
    local mask = parent:CreateMaskTexture(nil, "ARTWORK")
    local maskFile = (name == "Portrait" and mirrored) and "PortraitMaskRight.tga" or (name .. "Mask.tga")
    if pet and themeGeometry then maskFile=(warriorTheme and "Warrior" or warriorTheme or paladinTheme and "Paladin" or druidTheme and "Druid" or priestTheme and "Priest" or mageTheme and "Mage" or shamanTheme and "Shaman" or warlockTheme and "Warlock" or "Hunter").."PetPortraitMask.tga"
    elseif themeGeometry then maskFile = (warriorTheme and "Warrior" or warriorTheme or paladinTheme and "Paladin" or druidTheme and "Druid" or priestTheme and "Priest" or mageTheme and "Mage" or shamanTheme and "Shaman" or warlockTheme and "Warlock" or "Hunter") .. maskFile end
    mask:SetTexture(PATH .. maskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints()
    texture:AddMaskTexture(mask)
    return texture, mask, maskFile
end
local function makeBar(button, name, mirrored)
    local bar = CreateFrame("StatusBar", nil, button)
    bar:EnableMouse(false)
    bar:SetFrameLevel(button:GetFrameLevel() + 1)
    slot(button, bar, (button.layout or layout)[name], mirrored)
    bar:SetStatusBarTexture(PATH .. "BarFill.tga", "CLAMP", "CLAMP")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    -- Mirror the frame placement/art, but keep both units' fill direction equal.
    bar:SetReverseFill(false)
    -- A live fill's dimensions can become secret. Do not attach a Lua-created
    -- mask to that texture: the opaque decorative frame clips its corners.
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(.025, .025, .02, 1)
    bar.background = bg
    return bar
end
local function updatePortrait(f,retrying)
    if not f.portrait then return end
    if not retrying then f.portraitRetries=3 end
    checked(SetPortraitTexture, f.portrait, f.unit)
    -- Crop symmetrically instead of stretching a square native portrait.
    -- Mirroring the decorative border must not mirror the actual face.
    f.portrait:SetTexCoord(unpack(f.portraitCoords))
    f.portrait:SetVertexColor(1, 1, 1, 1)
    f.portrait:SetAlpha(1)
end
local function updateIndicators(f)
    local unit = f.unit
    if f.raidMarker then
        f.raidMarkerMethod = ForeverUnitsRaidMarker.Update(f.raidMarker, unit)
    end
    if f.happiness then
        f.happinessMethod = ForeverUnitsPetHappiness.Update(f.happiness, db.showPetHappiness)
        f.happinessFrame:SetShown(f.happinessMethod == "native-display" or f.happinessMethod == "public-atlas")
    end
    if not f.pvp or unit == "pet" then return end
    local isLeader = public(UnitIsGroupLeader, unit)
    f.assistant:SetShown(isLeader == false and public(UnitInRaid, unit) ~= nil
        and public(UnitIsGroupAssistant, unit) == true)
    f.pvp:Hide(); f.pvpTimer:Hide()
    local faction = public(UnitFactionGroup, unit)
    local pvpKind
    if public(UnitIsPVPFreeForAll, unit) == true then pvpKind = "FFA"
    elseif public(UnitIsPVP, unit) == true and (faction == "Alliance" or faction == "Horde") then pvpKind = faction end
    if pvpKind then
        f.pvp:SetTexture("Interface\\TargetingFrame\\UI-PVP-" .. pvpKind)
        f.pvp:SetTexCoord(0, .65625, 0, .65625)
        f.pvp:Show()
        if unit == "player" and pvpKind ~= "FFA" and public(IsPVPTimerRunning) == true then
            local milliseconds = public(GetPVPTimer)
            if type(milliseconds) == "number" and milliseconds > 0 then
                -- Only public timer values are formatted; never invent a countdown.
                local seconds = math.ceil(milliseconds / 1000)
                f.pvpTimer:SetFormattedText("%d:%02d", math.floor(seconds / 60), seconds % 60)
                f.pvpTimer:Show()
            end
        end
    end
    f.combat:Hide(); f.resting:Hide()
    if public(UnitAffectingCombat, unit) == true then f.combat:Show()
    elseif unit == "player" and public(IsResting) == true then f.resting:Show() end
end
local function updateInfo(f)
    local unit = f.unit
    if f.leader then
        local isLeader = public(UnitIsGroupLeader, unit)
        -- Restricted or unavailable leadership is not treated as a positive.
        f.leader:SetShown(isLeader == true)
    end
    updateIndicators(f)
    local name, surname = UnitName(unit)
    if not secret(name) and name == nil then name = "—" end
    if secret(surname) or (type(surname) == "string" and surname ~= "") then
        -- Forever returns the surname as the second value (not the realm).
        checked(f.name.SetFormattedText, f.name, "%s %s", name, surname)
    else checked(f.name.SetFormattedText, f.name, "%s", name) end
    if f.compact then return end
    if unit=="pet" then
        f.level:Hide();f.skull:Hide();if f.levelBadge then f.levelBadge:Hide() end
    else
    local level = (UnitEffectiveLevel or UnitLevel)(unit)
    f.level:Show(); f.skull:Hide()
    f.level:SetTextColor(1,unit=="target" and .82 or .94,unit=="target" and 0 or .8)
    if not secret(level) and type(level) == "number" and level < 0 then
        f.level:Hide(); f.skull:Show()
    else checked(f.level.SetFormattedText, f.level, "%d", level) end
    if unit == "target" and public(UnitCanAttack,"player",unit)==true and not secret(level) and type(level) == "number" and level > 0 then
        local color
        if C_PlayerInfo and C_PlayerInfo.GetContentDifficultyCreatureForPlayer and GetDifficultyColor then
            local difficulty = public(C_PlayerInfo.GetContentDifficultyCreatureForPlayer, unit)
            if difficulty ~= nil then color = public(GetDifficultyColor, difficulty) end
        end
        if not color and GetCreatureDifficultyColor then color = public(GetCreatureDifficultyColor, level) end
        if not color and GetQuestDifficultyColor then color = public(GetQuestDifficultyColor, level) end
        if type(color) == "table" then checked(f.level.SetTextColor, f.level, color.r, color.g, color.b) end
    end
    end
    f.name:SetTextColor(1, .89, .58)
    if unit == "target" then
        local reaction = public(UnitReaction, unit, "player")
        if type(reaction) == "number" then
            if reaction <= 3 then f.name:SetTextColor(1, .35, .22)
            elseif reaction >= 5 then f.name:SetTextColor(.55, 1, .55) end
        end
        -- Only target players use class color; NPC reaction colors stay intact.
        if public(UnitIsPlayer,unit)==true then
            local ok,_,class=pcall(UnitClass,unit)
            if ok and not secret(class) and type(class)=="string" then
                local color
                if C_ClassColor and C_ClassColor.GetClassColor then color=public(C_ClassColor.GetClassColor,class) end
                if type(color)~="table" and RAID_CLASS_COLORS then color=RAID_CLASS_COLORS[class] end
                if type(color)=="table" then checked(f.name.SetTextColor,f.name,color.r,color.g,color.b) end
            end
        end
        local kind = public(UnitClassification, unit)
        local labels = { elite = "ELITE", rareelite = "RARE ELITE", rare = "RARE", worldboss = "BOSS" }
        if type(kind) == "string" then
            f.classification:SetText(labels[kind] or "")
        else
            -- No guessed classification; native classification may be restricted.
            f.classification:SetText("")
        end
    end
end
local function updateBars(f)
    local unit = f.unit
    -- Forward secret health and power straight to C UI sinks. Never divide,
    -- compare, stringify or concatenate these combat amounts in Lua.
    local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
    local percentOK, percent
    if UnitHealthPercent then percentOK, percent = pcall(UnitHealthPercent, unit) end
    if percentOK and (secret(percent) or type(percent) == "number") then
        checked(f.health.SetMinMaxValues, f.health, 0, 1)
        checked(f.health.SetValue, f.health, percent)
    else
        checked(f.health.SetMinMaxValues, f.health, 0, hpMax)
        checked(f.health.SetValue, f.health, hp)
    end
    if f.useSplit then
        checked(f.hpText.SetFormattedText, f.hpText, "%d", hp)
        setPercent(f.hpPercent, unit, hp, hpMax, false)
    else checked(f.hpText.SetFormattedText, f.hpText, "%d / %d", hp, hpMax) end
    f.health:SetStatusBarColor(.18, .88, .07)
    if f.compact then return end
    local power, powerMax = UnitPower(unit), UnitPowerMax(unit)
    checked(f.power.SetMinMaxValues, f.power, 0, powerMax)
    checked(f.power.SetValue, f.power, power)
    if f.useSplit then
        checked(f.powerText.SetFormattedText, f.powerText, "%d", power)
        setPercent(f.powerPercent, unit, power, powerMax, true)
    else checked(f.powerText.SetFormattedText, f.powerText, "%d / %d", power, powerMax) end
    f.health:SetStatusBarColor(.18, .88, .07)
    local _, token = UnitPowerType(unit)
    local color
    if not secret(token) and type(token) == "string" and PowerBarColor then color = PowerBarColor[token] end
    if color then f.power:SetStatusBarColor(color.r, color.g, color.b)
    else f.power:SetStatusBarColor(1, .76, .08) end
end
local function updateCombo()
    local f = frames.player
    if not f or not f.combo or playerClass ~= "ROGUE" then return end
    local ok, points = pcall(GetComboPoints, "player", "target")
    if not ok then points = UnitPower("player", (Enum and Enum.PowerType and Enum.PowerType.ComboPoints) or 4) end
    if not secret(points) and type(points) ~= "number" then return end
    for _, pip in ipairs(f.combo.pips) do
        -- Each pip clamps to its own range; no secret amount arithmetic.
        checked(pip.SetValue, pip, points)
    end
end
local function refresh(allPortraits, changedUnit)
    for _, f in pairs(frames) do
        if not changedUnit or f.unit==changedUnit then
            checked(updateBars, f)
            checked(updateInfo, f)
            if allPortraits then updatePortrait(f) end
        end
    end
    if not changedUnit or changedUnit=="player" then updateCombo() end
    -- Aura/cast widgets own their unit events; do not duplicate their refresh.
end
local pollTicks=0
local function pollUnits()
    if not db.enabled then return end
    pollTicks=pollTicks+1
    -- Target-of-target has incomplete unit events on some clients.
    local target=frames.targettarget
    if target then checked(updateBars,target);checked(updateInfo,target) end
    if pollTicks%5~=0 then return end
    refresh(false)
    for _,f in pairs(frames) do
        if f.unit=="targettarget" then updatePortrait(f,true)
        elseif (f.portraitRetries or 0)>0 then
            f.portraitRetries=f.portraitRetries-1;updatePortrait(f,true)
        end
    end
end
local function savePosition(f)
    local cx, cy = f:GetCenter()
    if not cx or not cy then return end
    local factor = f:GetEffectiveScale() / UIParent:GetEffectiveScale()
    db[f.unit].x = cx * factor - UIParent:GetWidth() / 2
    db[f.unit].y = cy * factor
    if f.unit == "targettarget" then db.targettarget.detached = true end
    if f.unit == "pet" then db.pet.detached = true end
end
local function registerClickCasting(f)
    -- Clique consumes this registry now, or when it initializes later.
    -- Register only after the button's OnEnter/OnLeave scripts are complete.
    ClickCastFrames = ClickCastFrames or {}
    checked(function() ClickCastFrames[f] = true end)
end
local function makeUnit(unit)
    local W,H=W,H
    local petGeometry=unit=="pet" and petTheme and ForeverPetUnitsGeometry and ForeverPetUnitsGeometry[playerClass]
    if petGeometry and petGeometry.aspect then H=W*petGeometry.aspect end
    local mirrored = unit == "target" or unit == "targettarget"
    local f = CreateFrame("Button", "ForeverLeatherUnit_" .. unit, UIParent, "SecureUnitButtonTemplate")
    f.unit = unit
    f.geometry=petGeometry and petGeometry.artUV and petGeometry or themeGeometry
    if unit=="pet" and petTheme and ForeverPetUnitsGeometry then f.layout=ForeverPetUnitsGeometry[playerClass].layout end
    f:SetSize(W, H)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(10)
    f:SetAttribute("unit", unit)
    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    f:RegisterForClicks("AnyUp")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if InCombatLockdown() or db.locked or not IsAltKeyDown() then return end
        self.dragging = true; self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        if not self.dragging then return end
        if InCombatLockdown() then pending = true; return end
        self:StopMovingOrSizing(); self.dragging = false
        savePosition(self)
    end)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        checked(GameTooltip.SetUnit, GameTooltip, self.unit)
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)
    if unit == "targettarget" then
        f.compact = true
        f:SetSize(230, 44)
        local border = CreateFrame("Frame", nil, f, "BackdropTemplate")
        border:SetAllPoints(); border:EnableMouse(false)
        border:SetBackdrop({ bgFile = PATH .. "BarFill.tga", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 } })
        border:SetBackdropColor(.075, .055, .035, .97)
        border:SetBackdropBorderColor(.48, .34, .19, 1)
        f.health = CreateFrame("StatusBar", nil, f)
        f.health:EnableMouse(false)
        f.health:SetFrameLevel(f:GetFrameLevel() + 1)
        f.health:SetPoint("BOTTOMLEFT", 7, 6)
        f.health:SetPoint("BOTTOMRIGHT", -7, 6)
        f.health:SetHeight(12)
        f.health:SetStatusBarTexture(PATH .. "BarFill.tga")
        local bg = f.health:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(); bg:SetColorTexture(.025, .025, .02, 1)
        local labels = CreateFrame("Frame", nil, f)
        labels:EnableMouse(false); labels:SetAllPoints()
        labels:SetFrameLevel(f:GetFrameLevel() + 3)
        f.name = text(labels, 13, 210, true)
        f.name:SetPoint("TOP", 2, -4)
        f.name:SetTextColor(1, .89, .58)
        f.hpText = text(labels, 10, 214)
        f.hpText:SetPoint("CENTER", f.health, "CENTER")
        addSplitLabels(f, labels)
        if hunterTheme then border:SetBackdropBorderColor(.32, .38, .18, 1) end
        frames[unit] = f
        RegisterUnitWatch(f)
        registerClickCasting(f)
        return f
    end
    local portraitHolder = CreateFrame("Frame", nil, f)
    portraitHolder:EnableMouse(false)
    slot(f, portraitHolder, (f.layout or layout).Portrait, mirrored)
    local portrait, mask, maskFile = maskedTexture(portraitHolder, "Portrait", mirrored, "ARTWORK", unit=="pet")
    -- Extend only the dark backing under the painted rim. Sharing the portrait's
    -- exact mask left the antialiased seam transparent against bright terrain.
    local backdrop = portraitHolder:CreateTexture(nil, "BACKGROUND")
    backdrop:SetPoint("TOPLEFT", portraitHolder, "TOPLEFT", -2, 2)
    backdrop:SetPoint("BOTTOMRIGHT", portraitHolder, "BOTTOMRIGHT", 2, -2)
    backdrop:SetColorTexture(.025, .025, .025, 1)
    local backingMask = portraitHolder:CreateMaskTexture(nil, "ARTWORK")
    backingMask:SetTexture(PATH .. maskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    backingMask:SetAllPoints(backdrop)
    backdrop:AddMaskTexture(backingMask)
    f.portraitBacking, f.portraitBackingMask = backdrop, backingMask
    f.portrait, f.portraitHolder = portrait, portraitHolder
    local portraitWidth, portraitHeight = portraitHolder:GetWidth(), portraitHolder:GetHeight()
    if portraitWidth >= portraitHeight then
        local crop = (1 - portraitHeight / portraitWidth) / 2
        f.portraitCoords = { 0, 1, crop, 1 - crop }
    else
        local crop = (1 - portraitWidth / portraitHeight) / 2
        f.portraitCoords = { crop, 1 - crop, 0, 1 }
    end
    f.health = makeBar(f, "Health", mirrored)
    f.power = makeBar(f, "Power", mirrored)
    local decoration = CreateFrame("Frame", nil, f)
    decoration:EnableMouse(false)
    decoration:SetAllPoints()
    decoration:SetFrameLevel(f:GetFrameLevel() + 3)
    local art = decoration:CreateTexture(nil, "ARTWORK")
    art:SetAllPoints();f.art=art;art:SetTexture(PATH .. (unit=="pet" and petTheme and ((warriorTheme or paladinTheme) and themeGeometry.File() or druidTheme and "DruidPetFrame.tga" or priestTheme and "PriestPetFrame.tga" or mageTheme and "MagePetFrame.tga" or shamanTheme and "ShamanPetFrame.tga" or warlockTheme and "WarlockPetFrame.tga" or "HunterPetFrame.tga") or frameFile), "CLAMP", "CLAMP", "TRILINEAR")
    if hunterTheme then art:SetVertexColor(.82, .82, .78) end
    if warlockTheme or shamanTheme or mageTheme or druidTheme or priestTheme or warriorTheme or paladinTheme then
        local u=f.geometry.artUV
        art:SetTexCoord(mirrored and u[2] or u[1],mirrored and u[1] or u[2],u[3],u[4])
    elseif mirrored then art:SetTexCoord(1, 0, 0, 1) end
    f.name = text(decoration, 14, W * .54 - 4, true)
    f.name:SetPoint("CENTER", f, "TOPLEFT", (mirrored and .365 or .64) * W + 2, -.27 * H)
    if themeGeometry then
        f.name:ClearAllPoints()
        f.name:SetPoint("CENTER", f, "TOPLEFT", (mirrored and (1 - themeGeometry.name[1]) or themeGeometry.name[1]) * W + 2,
            -themeGeometry.name[2] * H)
    end
    local levelLayer = decoration
    if themeGeometry then
        levelLayer = CreateFrame("Frame", nil, decoration)
        levelLayer:EnableMouse(false); levelLayer:SetAllPoints()
        levelLayer:SetFrameLevel(decoration:GetFrameLevel() + 2)
    end
    f.level = text(levelLayer, 18, 40)
    f.level:SetJustifyH("CENTER");f.level:SetJustifyV("MIDDLE")
    f.level:SetPoint("CENTER", f, "TOPLEFT", (mirrored and .892 or .108) * W, -.845 * H)
    f.level:SetTextColor(1, .94, .8)
    local levelX = themeGeometry and themeGeometry.level[1] or .108
    f.levelX = mirrored and (1 - levelX) or levelX
    f.levelY = themeGeometry and themeGeometry.level[2] or .845
    if themeGeometry then
        f.levelBadge = CreateFrame("Frame", nil, decoration)
        f.levelBadge:EnableMouse(false)
        f.levelBadge:SetFrameLevel(decoration:GetFrameLevel() + 1)
        f.levelBadge:SetPoint("CENTER", f, "TOPLEFT", f.levelX * W, -f.levelY * H)
        f.levelBadge:SetSize(themeGeometry.levelSize[1] * W, themeGeometry.levelSize[2] * H)
        local black = f.levelBadge:CreateTexture(nil, "BACKGROUND")
        black:SetAllPoints(); black:SetColorTexture(0, 0, 0, 1)
        local badgeMask = f.levelBadge:CreateMaskTexture(nil, "ARTWORK")
        badgeMask:SetTexture(PATH .. (warriorTheme and (mirrored and "WarriorLevelMaskRight.tga" or "WarriorLevelMask.tga") or paladinTheme and (mirrored and "PaladinLevelMaskRight.tga" or "PaladinLevelMask.tga") or druidTheme and (mirrored and "DruidLevelMaskRight.tga" or "DruidLevelMask.tga") or priestTheme and (mirrored and "PriestLevelMaskRight.tga" or "PriestLevelMask.tga") or mageTheme and (mirrored and "MageLevelMaskRight.tga" or "MageLevelMask.tga") or shamanTheme and (mirrored and "ShamanLevelMaskRight.tga" or "ShamanLevelMask.tga") or warlockTheme and (mirrored and "WarlockLevelMaskRight.tga" or "WarlockLevelMask.tga") or (mirrored and "HunterLevelMaskRight.tga" or "HunterLevelMask.tga")),
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        badgeMask:SetAllPoints(); black:AddMaskTexture(badgeMask)
        if unit == "pet" or warlockTheme or shamanTheme or mageTheme or druidTheme or priestTheme or warriorTheme or paladinTheme then
            local ring = f.levelBadge:CreateTexture(nil, "ARTWORK")
            ring:SetAllPoints(); ring:SetTexture(PATH .. "HunterLevelBadge.tga", "CLAMP", "CLAMP", "TRILINEAR")
            if warlockTheme or shamanTheme or mageTheme or druidTheme or priestTheme or warriorTheme or paladinTheme then
                local uv=themeGeometry.levelBadgeUV
                themeGeometry.ApplyCircle(ring)
            else ring:SetVertexColor(.82,.82,.78) end
            ring:AddMaskTexture(badgeMask)
        end
    end
    f.skull = levelLayer:CreateTexture(nil, "OVERLAY", nil, 7)
    f.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    f.skull:SetSize(16, 16); f.skull:SetPoint("CENTER", f.level, "CENTER"); f.skull:Hide()
    f.hpText = text(decoration, 12, W * .54)
    f.hpText:SetPoint("CENTER", f.health, "CENTER")
    f.powerText = text(decoration, 11, W * .54)
    f.powerText:SetPoint("CENTER", f.power, "CENTER")
    addSplitLabels(f, decoration)
    f.classification = text(decoration, 10, 100)
    f.classification:SetPoint("BOTTOM", portraitHolder, "TOP", 0, 2)
    f.classification:SetTextColor(1, .73, .25)
    f.leader = decoration:CreateTexture(nil, "OVERLAY", nil, 7)
    f.leader:SetSize(18, 18)
    f.leader:SetPoint("CENTER", portraitHolder, mirrored and "TOPRIGHT" or "TOPLEFT",
        mirrored and 1 or -1, -3)
    local leaderAtlas = "UI-HUD-UnitFrame-Player-Group-LeaderIcon"
    if C_Texture and C_Texture.GetAtlasInfo and public(C_Texture.GetAtlasInfo, leaderAtlas) then
        f.leader:SetAtlas(leaderAtlas)
    else f.leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon") end
    f.leader:Hide()
    f.assistant = decoration:CreateTexture(nil, "OVERLAY", nil, 7)
    f.assistant:SetAllPoints(f.leader)
    f.assistant:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
    f.assistant:Hide()
    local markerLayer = CreateFrame("Frame", nil, decoration)
    markerLayer:EnableMouse(false); markerLayer:SetAllPoints()
    markerLayer:SetFrameLevel(decoration:GetFrameLevel() + 4)
    f.raidMarker = markerLayer:CreateTexture(nil, "OVERLAY", nil, 7)
    f.raidMarker:SetSize(db.raidMarkerSize, db.raidMarkerSize)
    f.raidMarker:SetPoint("BOTTOM", f.name, "TOP", db.raidMarkerOffsetX, db.raidMarkerOffsetY)
    f.raidMarker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    f.raidMarker:Hide()
    if unit == "pet" and hunterTheme then
        local holder = CreateFrame("Frame", nil, decoration)
        holder:EnableMouse(true)
        holder:SetFrameLevel(decoration:GetFrameLevel() + 5)
        holder:SetPoint("LEFT", f, "RIGHT", db.happinessOffsetX / db.petScale, db.happinessOffsetY / db.petScale)
        holder:SetSize(db.happinessSize / db.petScale, db.happinessSize / db.petScale)
        f.happinessFrame = holder
        f.happiness = holder:CreateTexture(nil, "OVERLAY")
        f.happiness:SetAllPoints()
        f.happiness:SetTexture(PATH .. "PetHappiness.tga", "CLAMP", "CLAMP", "TRILINEAR")
        f.happiness:Hide()
        holder:SetScript("OnEnter", function(self)
            checked(ForeverUnitsPetHappiness.Tooltip, self)
        end)
        holder:SetScript("OnLeave", function() GameTooltip:Hide() end)
        holder:SetScript("OnHide", function(self)
            if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
        end)
    end
    f.pvp = decoration:CreateTexture(nil, "OVERLAY", nil, 7)
    f.pvp:SetSize(26, 26)
    f.pvp:SetPoint("CENTER", portraitHolder, mirrored and "TOPRIGHT" or "TOPLEFT",
        mirrored and db.pvpOffsetX or -db.pvpOffsetX, db.pvpOffsetY)
    f.pvp:Hide()
    f.pvpTimer = text(decoration, 10, 48)
    f.pvpTimer:SetPoint("BOTTOM", f.pvp, "TOP", 0, 1)
    f.pvpTimer:SetTextColor(1, .9, .65); f.pvpTimer:Hide()
    local function statusIcon(atlas, fallback, coords)
        local icon = decoration:CreateTexture(nil, "OVERLAY", nil, 7)
        icon:SetSize(18, 18)
        icon:SetPoint("CENTER", portraitHolder, mirrored and "TOPLEFT" or "TOPRIGHT", 0, -3)
        if C_Texture and C_Texture.GetAtlasInfo and public(C_Texture.GetAtlasInfo, atlas) then icon:SetAtlas(atlas)
        else icon:SetTexture(fallback); icon:SetTexCoord(unpack(coords)) end
        icon:Hide()
        return icon
    end
    f.combat = statusIcon("UI-HUD-UnitFrame-Player-CombatIcon", "Interface\\CharacterFrame\\UI-StateIcon", { .5, 1, 0, .484375 })
    f.resting = statusIcon("UI-HUD-UnitFrame-Player-RestIcon", "Interface\\CharacterFrame\\UI-StateIcon", { 0, .5, 0, .421875 })
    if unit == "player" and playerClass == "ROGUE" then
        local combo = CreateFrame("Frame", nil, decoration)
        combo:EnableMouse(false)
        combo:SetSize(100, 8)
        combo:SetPoint("BOTTOM", f.health, "TOP", 0, 4)
        combo.pips = {}
        for i = 1, 5 do
            local pip = CreateFrame("StatusBar", nil, combo, "BackdropTemplate")
            pip:EnableMouse(false)
            pip:SetSize(16, 6)
            pip:SetPoint("LEFT", (i - 1) * 21, 0)
            pip:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
            pip:SetBackdropColor(.07, .05, .03, 1)
            pip:SetBackdropBorderColor(.65, .47, .25, 1)
            pip:SetStatusBarTexture(PATH .. "BarFill.tga")
            pip:SetStatusBarColor(.4, 1, .14)
            pip:SetMinMaxValues(i - 1, i)
            pip:SetValue(0)
            combo.pips[i] = pip
        end
        f.combo = combo
    end
    frames[unit] = f
    RegisterUnitWatch(f)
    registerClickCasting(f)
    return f
end
-- Alpha does not prevent a child frame from receiving clicks or tooltips.
-- Keep the native unit frames updating; only suppress their mouse input.
local nativeMouseStates={}
local function nativeMouseAllowed()
    return db and db.enabled and db.hideNative
end
local function enforceNativeMouse(frame,state)
    if state.changing or not state.suppressed or not nativeMouseAllowed() then return end
    if InCombatLockdown() then pending=true; return end
    state.changing=true
    frame:EnableMouse(false)
    state.changing=false
end
local function suppressNativeMouse(frame)
    local state=nativeMouseStates[frame]
    if not state then
        state={}
        nativeMouseStates[frame]=state
        for _,method in ipairs({"EnableMouse","SetMouseClickEnabled","SetMouseMotionEnabled"}) do
            if type(frame[method])=="function" then
                hooksecurefunc(frame,method,function() enforceNativeMouse(frame,state) end)
            end
        end
    end
    if not state.suppressed then
        state.mouse=frame:IsMouseEnabled()
        if frame.IsMouseClickEnabled then state.click=frame:IsMouseClickEnabled() end
        if frame.IsMouseMotionEnabled then state.motion=frame:IsMouseMotionEnabled() end
        state.suppressed=true
    end
    enforceNativeMouse(frame,state)
    -- Follow the current hierarchy, so the adopted native summon row and our
    -- custom unit frames are not included in this suppression.
    for _,child in ipairs({frame:GetChildren()}) do suppressNativeMouse(child) end
end
local function restoreNativeMouse()
    for frame,state in pairs(nativeMouseStates) do
        if state.suppressed then
            state.suppressed=false
            frame:EnableMouse(state.mouse)
            if state.click~=nil and frame.SetMouseClickEnabled then frame:SetMouseClickEnabled(state.click) end
            if state.motion~=nil and frame.SetMouseMotionEnabled then frame:SetMouseMotionEnabled(state.motion) end
        end
    end
end

local function nativeVisibility()
    if InCombatLockdown() then pending=true; return end
    local suppress = db.enabled and db.hideNative
    for _, frame in pairs({ PlayerFrame, TargetFrame, TargetFrameToT, petTheme and PetFrame or nil }) do
        if frame then
            local saved = originals[frame]
            if not saved then
                saved = { alpha = frame:GetAlpha() }
                originals[frame] = saved
                hooksecurefunc(frame, "SetAlpha", function()
                    if db and db.enabled and db.hideNative and not saved.changing then
                        saved.changing = true; frame:SetAlpha(0); saved.changing = false
                    end
                end)
            end
            saved.changing = true
            frame:SetAlpha(suppress and 0 or saved.alpha)
            if suppress then suppressNativeMouse(frame) end
            saved.changing = false
        end
    end
    if not suppress then restoreNativeMouse() end
end
-- Rescan after native target/pet updates to include newly created children.
-- No polling and no protected mouse changes during combat.
local nativeMouseEvents=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_ENTERING_WORLD","PLAYER_TARGET_CHANGED","UNIT_PET"}) do nativeMouseEvents:RegisterEvent(event) end
local nativeMouseQueued=false
nativeMouseEvents:SetScript("OnEvent",function(_,event,unit)
    if not nativeMouseAllowed() or (event=="UNIT_PET" and unit~="player") then return end
    if InCombatLockdown() then pending=true; return end
    if nativeMouseQueued then return end
    nativeMouseQueued=true
    C_Timer.After(0,function()
        nativeMouseQueued=false
        nativeVisibility()
    end)
end)
local function apply()
    if InCombatLockdown() then pending = true; say("Änderung nach dem Kampf."); return end
    pending = false
    if warriorTheme or paladinTheme then frameFile=themeGeometry.File();themeGeometry.frameFile=frameFile end
    for unit, f in pairs(frames) do
        if (warriorTheme or paladinTheme) and f.art then f.art:SetTexture(PATH..frameFile,"CLAMP","CLAMP","TRILINEAR") end
        local H=((shamanTheme or mageTheme or priestTheme or druidTheme or warriorTheme or paladinTheme) and unit=="pet") and f:GetHeight() or H
        f:StopMovingOrSizing(); f.dragging = false
        local scale = db.scale * (unit == "targettarget" and db.totScale or (unit == "pet" and db.petScale or 1))
        f:SetScale(scale)
        f:ClearAllPoints()
        if unit == "pet" and not db.pet.detached then
            f:SetPoint("TOPLEFT", frames.player, "BOTTOMLEFT", 0, -5 / scale)
        elseif unit == "targettarget" and not db.targettarget.detached then
            f:SetPoint("CENTER", UIParent, "BOTTOM", (db.player.x + db.target.x) / (2 * scale),
                ((db.player.y + db.target.y) / 2 + (petTheme and -8 or (H * db.scale / 2 + 28))) / scale)
        else f:SetPoint("CENTER", UIParent, "BOTTOM", db[unit].x / scale, db[unit].y / scale) end
        KerimAnkaUITextAPI.NameFont(f.name, (f.compact and 13 or 14) * db.textScale, false)
        f.hpText:SetFont(STANDARD_TEXT_FONT, (f.compact and 10 or 12) * db.healthTextScale, "OUTLINE")
        if f.useSplit then
            local fontFactor = unit == "pet" and (1 / db.petScale) or 1
            KerimAnkaUITextAPI.NameFont(f.name, (f.compact and 13 or 14) * db.textScale * fontFactor, false)
            f.hpText:SetFont(STANDARD_TEXT_FONT, (f.compact and 10 or 12) * db.healthTextScale * fontFactor, "OUTLINE")
            f.hpPercent:SetFont(STANDARD_TEXT_FONT, (f.compact and 10 or 12) * db.healthTextScale * fontFactor, "OUTLINE")
            if f.powerPercent then f.powerPercent:SetFont(STANDARD_TEXT_FONT, 11 * db.powerTextScale * fontFactor, "OUTLINE") end
        end
        if not f.compact then
            if f.happinessFrame then
                -- Keep this small status icon readable when shrinking just the pet frame.
                local size = db.happinessSize / db.petScale
                f.happinessFrame:SetSize(size, size)
                f.happinessFrame:ClearAllPoints()
                f.happinessFrame:SetPoint("LEFT", f, "RIGHT", db.happinessOffsetX / db.petScale, db.happinessOffsetY / db.petScale)
            end
            f.raidMarker:SetSize(db.raidMarkerSize, db.raidMarkerSize)
            f.raidMarker:ClearAllPoints()
            f.raidMarker:SetPoint("BOTTOM", f.name, "TOP", db.raidMarkerOffsetX, db.raidMarkerOffsetY)
            local levelFontFactor = unit == "pet" and (1 / db.petScale) or 1
            f.level:SetFont(STANDARD_TEXT_FONT, 14 * db.levelTextScale * levelFontFactor, "OUTLINE")
            if not warlockTheme and not shamanTheme and not mageTheme and not druidTheme and not priestTheme and not warriorTheme and not paladinTheme and f.levelBadge and unit == "pet" then
                -- Keep the pet's level badge readable independently of pet-frame shrinking.
                local badgeSize = math.max(30, 18 * db.levelTextScale + 12) / db.petScale
                f.levelBadge:SetSize(badgeSize, badgeSize)
            end
            f.level:ClearAllPoints()
            f.level:SetPoint("CENTER", f, "TOPLEFT", f.levelX * W, -f.levelY * H + db.levelOffsetY)
            if unit=="pet" then f.level:Hide();if f.levelBadge then f.levelBadge:Hide() end end
            f.powerText:SetFont(STANDARD_TEXT_FONT, 11 * db.powerTextScale * (unit == "pet" and (1 / db.petScale) or 1), "OUTLINE")
            if warlockTheme or shamanTheme or mageTheme or druidTheme or priestTheme or warriorTheme or paladinTheme then themeGeometry.ApplyLabels(f,db,unit,W,H,STANDARD_TEXT_FONT,unit=="target") end
            f.skull:SetSize(16 * db.levelTextScale * levelFontFactor, 16 * db.levelTextScale * levelFontFactor)
            f.classification:SetFont(STANDARD_TEXT_FONT, 12 * db.classificationTextScale, "OUTLINE")
            f.pvp:ClearAllPoints()
            f.pvp:SetSize(db.pvpSize,db.pvpSize)
            f.leader:SetSize(db.leaderSize,db.leaderSize)
            f.resting:SetSize(db.restIconSize,db.restIconSize)
            f.combat:SetSize(db.combatIconSize,db.combatIconSize)
            f.pvp:SetPoint("CENTER", f.portraitHolder, unit == "player" and "TOPLEFT" or "TOPRIGHT",
                unit == "player" and -db.pvpOffsetX or db.pvpOffsetX, db.pvpOffsetY)
        end
        if f.combo then f.combo:SetShown(db.showCombo) end
        if db.enabled and (unit ~= "targettarget" or db.showToT) and (unit ~= "pet" or db.showPet) then RegisterUnitWatch(f)
        else UnregisterUnitWatch(f); f:Hide() end
    end
    applySummons()
    applyQuestieTarget()
    applyFeedback()
    nativeVisibility()
    if ForeverUnitsCombatWidgets then checked(ForeverUnitsCombatWidgets.Apply,db,frames) end
    refresh(true)
end
local function buildPanel()
    panel = CreateFrame("Frame", "ForeverLeatherUnitsPanel", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(460, 720); panel:SetPoint("CENTER"); panel:SetFrameStrata("DIALOG")
    panel:SetScale(math.min(1, (UIParent:GetHeight() - 40) / 720))
    panel:SetMovable(true); panel:SetClampedToScreen(true); panel:EnableMouse(true)
    local position = db.panelPosition
    local validPoints = { TOPLEFT=true, TOP=true, TOPRIGHT=true, LEFT=true, CENTER=true,
        RIGHT=true, BOTTOMLEFT=true, BOTTOM=true, BOTTOMRIGHT=true }
    if type(position) == "table" and validPoints[position.point] and validPoints[position.relativePoint]
        and type(position.x) == "number" and type(position.y) == "number" then
        panel:ClearAllPoints()
        panel:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
    end
    local function stopPanelDrag()
        if not panel.dragging then return end
        panel:StopMovingOrSizing(); panel.dragging = false
        local point, _, relativePoint, x, y = panel:GetPoint()
        db.panelPosition = { point=point, relativePoint=relativePoint, x=x, y=y }
    end
    local dragHandle = CreateFrame("Frame", nil, panel)
    dragHandle:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -3)
    dragHandle:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -34, -3)
    dragHandle:SetHeight(27); dragHandle:SetFrameLevel(panel:GetFrameLevel() + 10)
    dragHandle:EnableMouse(true); dragHandle:RegisterForDrag("LeftButton")
    dragHandle:SetScript("OnDragStart", function() panel.dragging = true; panel:StartMoving() end)
    dragHandle:SetScript("OnDragStop", stopPanelDrag)
    panel:SetScript("OnHide", stopPanelDrag)
    if panel.CloseButton then panel.CloseButton:SetScript("OnClick", function() panel:Hide() end) end
    panel.TitleText:SetText("Forever Units — " .. (hunterTheme and "Hunter" or "Leather") .. " 0.11.2")
    UISpecialFrames[#UISpecialFrames + 1] = "ForeverLeatherUnitsPanel"
    local note = text(panel, 12, 420)
    note:SetWordWrap(true); note:SetJustifyH("LEFT")
    note:SetPoint("TOPLEFT", 20, -42)
    note:SetText("Fenster: oben an der Titelleiste ziehen. ALT + Ziehen: Unit-Frames.\nErst prüfen, danach Blizzard-Frames ausblenden.")
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -90); scroll:SetPoint("BOTTOMRIGHT", -32, 108)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(410, 850); scroll:SetScrollChild(content)
    panel.checks = {}
    local y = 0
    local function check(key, title)
        local c = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        c:SetPoint("TOPLEFT", 18, y); c.text:SetText(title)
        c:SetScript("OnClick", function(self) db[key] = self:GetChecked() and true or false; apply() end)
        panel.checks[key] = c; y = y - 35
    end
    check("enabled", hunterTheme and "Hunter-Rahmen aktiviert" or "Neue Leder-Frames aktiviert")
    check("hideNative", hunterTheme and "Blizzard Spieler/Ziel/Begleiter ausblenden" or "Blizzard Spieler-/Ziel-Frames ausblenden")
    check("locked", "Positionen sperren")
    check("showToT", "Ziel des Ziels: kompakte Leiste anzeigen")
    if not hunterTheme then check("showCombo", "Zusätzliche Rogue-Combopunkte anzeigen") end
    if hunterTheme then check("showPet", "Begleiter-Rahmen anzeigen") end
    if hunterTheme then check("showPetHappiness", "Begleiter-Zufriedenheit anzeigen") end
    y = y - 15
    panel.sliders = {}
    local function slider(key, title, low, high, step)
        local s = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
        s:SetPoint("TOPLEFT", 35, y); s:SetWidth(350)
        s:SetMinMaxValues(low, high); s:SetValueStep(step or .05); s:SetObeyStepOnDrag(true)
        s.Low:SetText(tostring(low)); s.High:SetText(tostring(high))
        s:SetScript("OnValueChanged", function(_, value)
            s.Text:SetText(title .. ": " .. string.format(step == 1 and "%.0f" or "%.2f", value))
            if panel.updating then return end
            db[key] = value; apply()
        end)
        panel.sliders[key] = s; y = y - 62
    end
    slider("scale", "Rahmengröße", hunterTheme and .45 or .55, 1.6)
    slider("textScale", "Namensgröße", .75, 1.5)
    slider("healthTextScale", "Lebenspunkte: Zahlengröße", .75, 2)
    slider("powerTextScale", "Energie / Mana: Zahlengröße", .75, 2)
    slider("levelTextScale", "Level: Zahlengröße", .6, 1.5)
    slider("levelOffsetY", "Level: Höhe (+ nach oben)", -10, 12, 1)
    slider("totScale", "Ziel des Ziels: Größe", .65, 1.4)
    if hunterTheme then slider("petScale", "Begleiter: Größe", .45, 1.1) end
    slider("pvpOffsetX", "PvP-Symbol: seitlich (+ nach außen)", -30, 45, 1)
    slider("pvpOffsetY", "PvP-Symbol: Höhe (+ nach oben)", -45, 45, 1)
    slider("classificationTextScale", "Elite / Rare: Textgröße", .8, 2)
    slider("raidMarkerSize", "Zielmarkierung: Größe", 16, 48, 1)
    slider("raidMarkerOffsetX", "Zielmarkierung: seitlich", -100, 100, 1)
    slider("raidMarkerOffsetY", "Zielmarkierung: Höhe", 0, 50, 1)
    if hunterTheme then
        slider("happinessSize", "Zufriedenheit: Symbolgröße", 16, 48, 1)
        slider("happinessOffsetX", "Zufriedenheit: seitlich", -100, 100, 1)
        slider("happinessOffsetY", "Zufriedenheit: Höhe", -60, 60, 1)
    end
    content:SetHeight(-y + 35)
    local center = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    center:SetSize(250, 28); center:SetPoint("BOTTOM", 0, 64)
    center:SetText("Ziel des Ziels zentrieren")
    center:SetScript("OnClick", function() db.targettarget.detached = false; apply() end)
    local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reset:SetSize(180, 28); reset:SetPoint("BOTTOMLEFT", 20, 22)
    reset:SetText("Positionen zurücksetzen")
    reset:SetScript("OnClick", function()
        db.player = { x = -205, y = 280 }; db.target = { x = 205, y = 280 }
        db.targettarget = { x = 205, y = 200, detached = false }; apply()
        if hunterTheme then db.pet.detached = false; apply() end
    end)
    local off = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    off:SetSize(180, 28); off:SetPoint("BOTTOMRIGHT", -20, 22)
    off:SetText("Blizzard wiederherstellen")
    off:SetScript("OnClick", function() db.hideNative = false; db.enabled = false; apply(); panel:Hide() end)
end
local function openPanel()
    if KerimAnkaUIAPI then KerimAnkaUIAPI.OpenPage("units"); return end
    if not panel then buildPanel() end
    panel.updating = true
    for key, control in pairs(panel.checks) do control:SetChecked(db[key]) end
    for key, control in pairs(panel.sliders) do control:SetValue(db[key]) end
    panel.updating = false; panel:Show()
end
local minimapLauncher
local function createMinimapLauncher()
    if KerimAnkaUIAPI then return end
    if minimapLauncher then return end
    db.minimap = db.minimap or { minimapPos = 245 }
    local iconPath = "Interface\\Icons\\INV_Chest_Leather_05"
    local function tooltip(tip)
        tip:AddLine("Forever Leather Units")
        tip:AddLine("Klicken: Rahmen-Einstellungen öffnen", 1, 1, 1)
        tip:AddLine("Ziehen: Symbol verschieben", .7, .7, .7)
    end
    local broker = LibStub and LibStub("LibDataBroker-1.1", true)
    local icons = LibStub and LibStub("LibDBIcon-1.0", true)
    if broker and icons then
        minimapLauncher = broker:NewDataObject("ForeverLeatherUnits", {
            type = "launcher", label = "Forever Leather Units", icon = iconPath,
            OnClick = function() openPanel() end,
            OnTooltipShow = tooltip,
        })
        icons:Register("ForeverLeatherUnits", minimapLauncher, db.minimap)
        return
    end
    -- Standalone fallback if no other addon provides the broker/icon libraries.
    if not Minimap then return end
    local button = CreateFrame("Button", "ForeverLeatherUnitsMinimapButton", Minimap)
    minimapLauncher = button
    button:SetSize(31, 31); button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 10)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20); icon:SetPoint("CENTER", -1, 1)
    icon:SetTexture(iconPath); icon:SetTexCoord(.08, .92, .08, .92)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53); border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    local function position()
        local angle = math.rad(db.minimap.minimapPos or 245)
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER",
            math.cos(angle) * (Minimap:GetWidth() / 2 + 10),
            math.sin(angle) * (Minimap:GetHeight() / 2 + 10))
    end
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function() openPanel() end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT"); tooltip(GameTooltip); GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            local cx, cy = Minimap:GetCenter()
            if not cx or not cy then return end
            db.minimap.minimapPos = math.deg(math.atan2(y / scale - cy, x / scale - cx))
            position()
        end)
    end)
    button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    position()
end
SLASH_FOREVERLEATHERUNITS1 = "/flu"
SlashCmdList.FOREVERLEATHERUNITS = function(message)
    local command = (message or ""):lower():match("^%s*(%S+)")
    if command == "off" then db.hideNative = false; db.enabled = false; apply()
    elseif command == "on" then db.enabled = true; apply()
    elseif command == "status" then
        say("Version 0.11.2; " .. (hunterTheme and "Hunter" or "Leather") .. "; Frames " .. (db.enabled and "AN" or "AUS") .. "; native " .. (db.hideNative and "versteckt" or "sichtbar"))
        say("Click-Casting: Spieler, Ziel und Ziel des Ziels im ClickCastFrames-Register.")
        local count = 0
        for message, n in pairs(errors) do count = count + n; say(message .. " (" .. n .. ")") end
        say("Testfehler: " .. count)
    elseif command == "windowreset" then
        if panel and panel.dragging then panel:StopMovingOrSizing(); panel.dragging = false end
        db.panelPosition = nil
        if panel then panel:ClearAllPoints(); panel:SetPoint("CENTER") end
        openPanel()
    elseif command == "marker" then
        local ok, marker = pcall(GetRaidTargetIndex, "target")
        if not ok then say("Zielmarkierung: API nicht verfügbar.")
        elseif secret(marker) then say("Zielmarkierung: geschützter Index; direkte native Anzeige.")
        elseif type(marker) == "number" then say("Zielmarkierung: " .. marker)
        else say("Zielmarkierung: keine lesbare Markierung am Ziel.") end
        if frames.target then say("Anzeigepfad: " .. (frames.target.raidMarkerMethod or "noch nicht aktualisiert")) end
    elseif command == "petmood" then
        local ok, happiness = ForeverUnitsPetHappiness.Read()
        say("API: " .. ForeverUnitsPetHappiness.APIName())
        if not ok then say("Zufriedenheit: API nicht verfügbar.")
        elseif secret(happiness) then say("Zufriedenheit: geschützter Wert; direkte native Anzeige.")
        elseif type(happiness) == "number" then say("Zufriedenheit: " .. happiness .. " (1=unglücklich, 2=zufrieden, 3=glücklich)")
        else say("Zufriedenheit: keine Daten / kein aktiver Begleiter.") end
        if frames.pet then say("Anzeigepfad: " .. (frames.pet.happinessMethod or "noch nicht aktualisiert")) end
    else openPanel() end
end
events:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_REGEN_ENABLED" and deferredInit then
        deferredInit = false
        events:GetScript("OnEvent")(events, "PLAYER_LOGIN")
        return
    end
    if event == "PLAYER_LOGIN" then
        ForeverLeatherUnitsDB = ForeverLeatherUnitsDB or {}
        db = ForeverLeatherUnitsDB
        local _, class = UnitClass("player")
        playerClass = class
        hunterTheme = class == "HUNTER" and ForeverHunterUnitsGeometry ~= nil
        warlockTheme = class == "WARLOCK" and ForeverWarlockUnitsGeometry ~= nil
        warriorTheme = class == "WARRIOR" and ForeverWarriorUnitsGeometry ~= nil
        paladinTheme = class == "PALADIN" and ForeverPaladinUnitsGeometry ~= nil
        priestTheme = class == "PRIEST" and ForeverPriestUnitsGeometry ~= nil
        druidTheme = class == "DRUID" and ForeverDruidUnitsGeometry ~= nil
        mageTheme = class == "MAGE" and ForeverMageUnitsGeometry ~= nil
        shamanTheme = class == "SHAMAN" and ForeverShamanUnitsGeometry ~= nil
        petTheme = hunterTheme or warlockTheme or shamanTheme or mageTheme or druidTheme or priestTheme or warriorTheme or paladinTheme
        themeGeometry = warriorTheme and ForeverWarriorUnitsGeometry or paladinTheme and ForeverPaladinUnitsGeometry or druidTheme and ForeverDruidUnitsGeometry or priestTheme and ForeverPriestUnitsGeometry or mageTheme and ForeverMageUnitsGeometry or shamanTheme and ForeverShamanUnitsGeometry or warlockTheme and ForeverWarlockUnitsGeometry or hunterTheme and ForeverHunterUnitsGeometry or nil
        if warriorTheme or paladinTheme then
            H=W*themeGeometry.aspect;layout=themeGeometry.layout;frameFile=themeGeometry.File()
            -- Older Paladin profiles never initialized a pet position. Repair
            -- these defaults even when the theme migration already ran.
            if db.showPet==nil then db.showPet=true end
            db.petScale=db.petScale or .60
            if type(db.pet)~="table" then db.pet={x=-205,y=220,detached=false} end
            if db.pet.x==nil then db.pet.x=-205 end
            if db.pet.y==nil then db.pet.y=220 end
            if not db[warriorTheme and "warriorThemeInitialized" or "paladinThemeInitialized"] then
                if db.levelOffsetY==nil or db.levelOffsetY==4 then db.levelOffsetY=0 end
                db[warriorTheme and "warriorThemeInitialized" or "paladinThemeInitialized"]=true
            end
        end
        if priestTheme then
            H=W*themeGeometry.aspect;layout=themeGeometry.layout;frameFile=themeGeometry.frameFile
            if not db.priestThemeInitialized then
                if db.levelOffsetY==nil or db.levelOffsetY==4 then db.levelOffsetY=0 end
                db.priestThemeInitialized=true
            end
            if db.showPet==nil then db.showPet=true end
            db.petScale=db.petScale or .60
            db.pet=db.pet or {x=-205,y=220,detached=false}
        end
        if druidTheme then
            H=W*themeGeometry.aspect;layout=themeGeometry.layout;frameFile=themeGeometry.frameFile
            if not db.druidThemeInitialized then
                if db.levelOffsetY==nil or db.levelOffsetY==4 then db.levelOffsetY=0 end
                db.druidThemeInitialized=true
            end
            if db.showPet==nil then db.showPet=true end
            db.petScale=db.petScale or .60
            db.pet=db.pet or {x=-205,y=220,detached=false}
        end
        if mageTheme then
            H=W*themeGeometry.aspect;layout=themeGeometry.layout;frameFile=themeGeometry.frameFile
            if not db.mageThemeInitialized then
                if db.levelOffsetY==nil or db.levelOffsetY==4 then db.levelOffsetY=0 end
                db.mageThemeInitialized=true
            end
            if db.showPet==nil then db.showPet=true end
            db.petScale=db.petScale or .60
            db.pet=db.pet or {x=-205,y=220,detached=false}
        end
        if shamanTheme then
            H=W*themeGeometry.aspect;layout=themeGeometry.layout;frameFile=themeGeometry.frameFile
            if not db.shamanThemeInitialized then
                if db.levelOffsetY==nil or db.levelOffsetY==4 then db.levelOffsetY=0 end
                db.shamanThemeInitialized=true
            end
            if db.showPet==nil then db.showPet=true end
            db.petScale=db.petScale or .60
            db.pet=db.pet or {x=-205,y=220,detached=false}
        end
        if warlockTheme then
            H=W*themeGeometry.aspect;layout=themeGeometry.layout;frameFile=themeGeometry.frameFile
            if not db.warlockThemeInitialized then
                if db.levelOffsetY==nil or db.levelOffsetY==4 then db.levelOffsetY=0 end
                db.warlockThemeInitialized=true
            end
            if db.showPet==nil then db.showPet=true end
            db.petScale=db.petScale or .60
            db.pet=db.pet or {x=-205,y=220,detached=false}
        end
        if hunterTheme then
            H = W * ForeverHunterUnitsGeometry.aspect
            layout = ForeverHunterUnitsGeometry.layout
            frameFile = "HunterFrame.tga"
            if not db.hunterThemeInitialized then
                db.scale = .65; db.totScale = 1; db.petScale = .60
                db.levelOffsetY = 0
                db.textScale = db.textScale or 1.1
                db.healthTextScale = db.healthTextScale or 1.15
                db.powerTextScale = db.powerTextScale or 1.15
                db.compactMigration = true; db.showCombo = false
                db.hunterThemeInitialized = true
            end
            if db.showPet == nil then db.showPet = true end
            db.petScale = db.petScale or .60
            db.pet = db.pet or { x = -205, y = 220, detached = false }
        end
        if not db.healthTextScale then db.healthTextScale = db.textScale or 1 end
        if not db.powerTextScale then db.powerTextScale = db.textScale or 1 end
        if not db.levelTextScale then db.levelTextScale = 1 end
        if not db.compactMigration then
            db.showCombo = false
            if db.totScale then db.totScale = math.max(.65, math.min(1.4, db.totScale / .6)) end
            db.compactMigration = true
        end
        for key, value in pairs(defaults) do if db[key] == nil then db[key] = value end end
        if ForeverUnitsCombatWidgets then ForeverUnitsCombatWidgets.Defaults(db) end
        createMinimapLauncher()
        if not db.player then db.player = { x = -205, y = 280 } end
        if not db.target then db.target = { x = 205, y = 280 } end
        if not db.targettarget then db.targettarget = { x = 205, y = 200, detached = false } end
        if InCombatLockdown() then
            deferredInit = true
            events:RegisterEvent("PLAYER_REGEN_ENABLED")
            say("Leder-Frames werden nach dem Kampf erstellt.")
            return
        end
        makeUnit("player"); makeUnit("target"); makeUnit("targettarget")
        if petTheme then makeUnit("pet") end
        for _, name in ipairs({ "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_NAME_UPDATE", "UNIT_LEVEL", "UNIT_CLASSIFICATION_CHANGED", "UNIT_FLAGS", "UNIT_FACTION" }) do
            if petTheme then events:RegisterUnitEvent(name, "player", "target", "targettarget", "pet")
            else events:RegisterUnitEvent(name, "player", "target", "targettarget") end
        end
        events:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player", "target", "targettarget")
        events:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player", "target", "targettarget")
        events:RegisterUnitEvent("UNIT_TARGET", "target")
        events:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        if petTheme then events:RegisterUnitEvent("UNIT_PET", "player") end
        if hunterTheme then
            -- Optional Classic events: a missing beta event must not stop setup.
            pcall(events.RegisterEvent, events, "UNIT_HAPPINESS")
            pcall(events.RegisterEvent, events, "PET_UI_UPDATE")
        end
        events:RegisterEvent("PLAYER_LEVEL_UP")
        for _, name in ipairs({ "PLAYER_TARGET_CHANGED", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "PORTRAITS_UPDATED", "PLAYER_LOGOUT", "PARTY_LEADER_CHANGED", "GROUP_ROSTER_UPDATE", "RAID_TARGET_UPDATE", "PLAYER_UPDATE_RESTING", "PVP_TIMER_UPDATE" }) do events:RegisterEvent(name) end
        apply()
        -- Target-of-target changes may not deliver every filtered unit event.
        -- Short polling also retries portrait/model data once it has loaded.
        C_Timer.NewTicker(.2, pollUnits)
    elseif event == "PLAYER_LOGOUT" then
        -- These frames are not destroyed. Native alpha/mouse restoration is
        -- handled out of combat by /flu off or by disabling the addon + reload.
    elseif event == "PLAYER_REGEN_DISABLED" then
        for _, f in pairs(frames) do
            if f.dragging then pending = true end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if pending then apply() end
        refresh(false)
    else
        if event=="UNIT_HEALTH" or event=="UNIT_MAXHEALTH" or event=="UNIT_POWER_FREQUENT" or event=="UNIT_MAXPOWER" or event=="UNIT_DISPLAYPOWER" or event=="UNIT_POWER_UPDATE" then
            if frames[unit] then checked(updateBars,frames[unit]) end
            if unit=="player" then updateCombo() end
            return
        end
        if event == "PLAYER_TARGET_CHANGED" then frames.target.classification:SetText("") end
        local portrait=event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" or event == "UNIT_TARGET" or event == "PORTRAITS_UPDATED" or event=="UNIT_PET"
        local changed=event=="UNIT_PET" and "pet" or (event~="UNIT_TARGET" and unit or nil)
        refresh(portrait,changed)
    end
end)
events:RegisterEvent("PLAYER_LOGIN")
-- Shared settings adapter; the hub edits the original per-character database.
ForeverLeatherUnitsAPI = {
    version=2,
    GetSettings=function() return db end,
    Apply=function() if db then apply() end end,
    IsHunter=function() return hunterTheme end,
    IsWarlock=function() return warlockTheme end,
    IsShaman=function() return shamanTheme end,
    IsMage=function() return mageTheme end,
    IsDruid=function() return druidTheme end,
    IsPriest=function() return priestTheme end,
    IsWarrior=function() return warriorTheme end,
    IsPaladin=function() return paladinTheme end,
    SupportsPet=function() return petTheme end,
    GetGeometry=function() return themeGeometry end,
    GetPetGeometry=function() return ForeverPetUnitsGeometry and ForeverPetUnitsGeometry[playerClass] end,
}
