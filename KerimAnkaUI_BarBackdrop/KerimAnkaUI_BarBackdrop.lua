-- Forever Bar Backdrop
-- Selected native Blizzard or Bartender action bars.

local events = CreateFrame("Frame")
local tracked = {}
local ApplyAll,QueueApply
local applying,queued,pending
local function Editing()
    return EditModeManagerFrame and EditModeManagerFrame.IsEditModeActive and EditModeManagerFrame:IsEditModeActive()
end
QueueApply=function()
    if applying then return end
    if InCombatLockdown() or Editing() then pending=true;return end
    if queued then return end
    queued=true
    C_Timer.After(0,function() queued=false;ApplyAll() end)
end

local db
local defaults={enabled=false,shade=.18,border=1,slotAlpha=1}
local selected={}
local mainSlots={}
local mainLayer
local function MainLayerLevel()
    -- A shared opaque slot backing must stay below EVERY main-bar button.
    -- Drag/grid transitions can temporarily raise individual containers.
    -- Choosing an arbitrary button (or clamping to the bar's own level)
    -- could leave the backing above icons after the cursor was cleared.
    local lowest
    for button in pairs(mainSlots) do
        local level=button:GetFrameLevel()
        lowest=lowest and math.min(lowest,level) or level
    end
    return math.max(0,(lowest or MainActionBar:GetFrameLevel())-1)
end
local function MainLayer(button)
    if not mainLayer then
        -- Main-bar button containers can hide individually for empty slots.
        -- Decoration belongs to the whole bar, below its protected buttons.
        mainLayer=CreateFrame("Frame",nil,UIParent)
        -- Independent cosmetic carrier: never add addon fields/children to
        -- MainActionBar's LayoutFrame enumeration.
        mainLayer:SetAllPoints(MainActionBar)
        mainLayer:SetFrameLevel(MainLayerLevel())
        mainLayer:EnableMouse(false)
        local function UpdateMainSlots()
            for button,saved in pairs(tracked) do
                if saved.mainIndex and saved.updateSlot then saved.updateSlot(button) end
            end
        end
        MainActionBar:HookScript("OnShow",UpdateMainSlots)
        MainActionBar:HookScript("OnHide",UpdateMainSlots)
    end
    mainLayer:SetFrameLevel(MainLayerLevel())
    if MainActionBar.GetEffectiveScale and UIParent.GetEffectiveScale then
        mainLayer:SetScale(MainActionBar:GetEffectiveScale()/UIParent:GetEffectiveScale())
    end
    if MainActionBar.GetFrameStrata then mainLayer:SetFrameStrata(MainActionBar:GetFrameStrata()) end
    return mainLayer
end
local function Selected(button)
    return db and db.enabled and selected[button]==true or false
end
local function UpdateSlot(button)
    local saved=tracked[button]
    if not saved then return end
    local visible=Selected(button)
    if saved.mainIndex then
        local count=MainActionBar.numButtons
        visible=visible and MainActionBar:IsVisible() and saved.mainIndex<=(type(count)=="number" and count or 12)
    else
        visible=visible and button:IsVisible()
    end
    if button.ForeverBarSlotBase then button.ForeverBarSlotBase:SetShown(visible) end
    button.ForeverBarBackdrop:SetShown(visible)
    if saved.mainIndex then button.ForeverOuterBorder:SetShown(visible and db.border>0) end
end
local function Restore(button)
    local saved=tracked[button]
    if not saved or not saved.active then return end
    saved.active=false
    if button.ForeverBarSlotBase then button.ForeverBarSlotBase:Hide() end
    button.ForeverBarBackdrop:Hide(); button.ForeverOuterBorder:Hide()
    if saved.atlas and button.SetNormalAtlas then button:SetNormalAtlas(saved.atlas)
    else button:SetNormalTexture(saved.texture) end
    local normal=button:GetNormalTexture()
    if normal then
        normal:SetVertexColor(unpack(saved.color)); normal:SetAlpha(saved.alpha)
    end
end

local function TintFrame(button)
    if InCombatLockdown() or Editing() then pending=true;return end
    if not tracked[button] or not tracked[button].active or not Selected(button) then return end
    local normal = button:GetNormalTexture()

    if normal then
        normal:SetAlpha(1)
        normal:SetVertexColor(
            db.shade, db.shade, db.shade, 1
        )
    end
end

local function ApplyButton(button)
    if InCombatLockdown() or Editing() then
        pending=true;return
    end

    if not Selected(button) then Restore(button); return end
    if not tracked[button] then
        local normal=button:GetNormalTexture()
        tracked[button]={active=true,texture=normal and normal:GetTexture(),
            atlas=normal and normal.GetAtlas and normal:GetAtlas(),
            color=normal and {normal:GetVertexColor()} or {1,1,1,1},
            alpha=normal and normal:GetAlpha() or 1,mainIndex=mainSlots[button],updateSlot=UpdateSlot}
        -- Original textured backdrop, beneath the button.
        local decorationParent=mainSlots[button] and MainLayer(button) or button:GetParent()
        -- Blizzard combines SlotBackground (the dark fill) with SlotArt
        -- (the transparent slot decoration). Empty main buttons are hidden,
        -- so their native SlotBackground disappears too. Carry both layers
        -- independently; never show or modify the protected action button.
        if mainSlots[button] then
            local base=decorationParent:CreateTexture(nil,"BACKGROUND",nil,-8)
            base:SetAtlas("UI-HUD-ActionBar-IconFrame-Background")
            base:SetAllPoints(button)
            button.ForeverBarSlotBase=base
        end
        local slot = decorationParent:CreateTexture(
            nil, "BACKGROUND", nil, -7
        )
        slot:SetAtlas("ui-hud-actionbar-iconframe-slot")
        slot:SetAllPoints(button)
        button.ForeverBarBackdrop = slot

        -- Slightly larger black copy of the textured frame.
        local outerParent=mainSlots[button] and decorationParent or button
        local outer = outerParent:CreateTexture(
            nil, "BACKGROUND", nil, -6
        )
        outer:SetAtlas("UI-HUD-ActionBar-IconFrame-AddRow")
        outer:SetVertexColor(0, 0, 0, 1)
        button.ForeverOuterBorder = outer

        button:HookScript("OnShow", function(self)
            UpdateSlot(self)
            QueueApply()
        end)

        button:HookScript("OnHide", function(self)
            UpdateSlot(self)
        end)

        hooksecurefunc(button, "SetNormalTexture", QueueApply)

        if button.SetNormalAtlas then
            hooksecurefunc(button, "SetNormalAtlas", QueueApply)
        end

        tracked[button].active = true
    end

    tracked[button].active=true
    if button.ForeverBarSlotBase then button.ForeverBarSlotBase:SetAlpha(db.slotAlpha) end
    button.ForeverBarBackdrop:SetAlpha(db.slotAlpha)
    local BORDER_EXTRA=db.border
    local outer = button.ForeverOuterBorder

    if BORDER_EXTRA > 0 then
        outer:ClearAllPoints()
        outer:SetPoint(
            "TOPLEFT", button, "TOPLEFT",
            -BORDER_EXTRA, BORDER_EXTRA
        )
        outer:SetPoint(
            "BOTTOMRIGHT", button, "BOTTOMRIGHT",
            BORDER_EXTRA, -BORDER_EXTRA
        )
        outer:Show()
    else
        outer:Hide()
    end

    if button.SetNormalAtlas then
        button:SetNormalAtlas(
            "UI-HUD-ActionBar-IconFrame-AddRow"
        )
    end

    TintFrame(button)
    UpdateSlot(button)
end

ApplyAll=function()
    if InCombatLockdown() or Editing() then
        pending=true;return
    end

    db=KerimAnkaUIBarsAPI.View(ForeverBarBackdropCharacterDB,"backdrop")
    if not db then return end
    applying=true;pending=false
    selected={};mainSlots={}
    local native=KerimAnkaUIBarsAPI.Resolve()=="blizzard"
    if db.enabled then KerimAnkaUIBarsAPI.ForEach(db.bars,function(button,bar,index)
        selected[button]=true
        if native and bar==1 and MainActionBar then mainSlots[button]=index end
    end) end
    for button in pairs(tracked) do if not Selected(button) then Restore(button) end end
    for button in pairs(mainSlots) do MainLayer(button);break end
    for button in pairs(selected) do ApplyButton(button) end
    applying=false
end

if EventRegistry and EventRegistry.RegisterCallback then
    EventRegistry:RegisterCallback("EditMode.Exit",QueueApply,events)
end

local function RegisterUpdates()
    if events.callbacksReady or not LibStub then
        return
    end

    local lib = LibStub("LibActionButton-1.0", true)

    if not lib or not lib.RegisterCallback then
        return
    end

    lib.RegisterCallback(
        events,
        "OnButtonUpdate",
        function(_, button)
            if tracked[button] then
                QueueApply()
            end
        end
    )

    events.callbacksReady = true
end

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
events:RegisterEvent("ACTIONBAR_SHOWGRID")
events:RegisterEvent("ACTIONBAR_HIDEGRID")
events:RegisterEvent("CURSOR_CHANGED")
events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")

events:SetScript("OnEvent", function(_, event)
    if event=="PLAYER_LOGIN" then
        if type(ForeverBarBackdropCharacterDB)~="table" then ForeverBarBackdropCharacterDB={} end
        db=ForeverBarBackdropCharacterDB
        for key,value in pairs(defaults) do if type(db[key])~=type(value) then db[key]=value end end
        db.shade=math.max(0,math.min(1,db.shade)); db.border=math.max(0,math.min(6,db.border))
        db.slotAlpha=math.max(0,math.min(1,db.slotAlpha))
        local bars,seen={},{}
        for _,bar in ipairs(type(db.bars)=="table" and db.bars or {1,3,4,5,6}) do
            if type(bar)=="number" and bar==math.floor(bar) and bar>=1 and bar<=10 and not seen[bar] then
                bars[#bars+1]=bar; seen[bar]=true
            end
        end
        db.bars=#bars>0 and bars or {1,3,4,5,6}
    end
    RegisterUpdates()
    QueueApply()

    -- Refresh once after native drag/grid handlers finish. Do not change
    -- protected ShowGrid/HideGrid, actions, cursor contents or button alpha.
    if event=="ACTIONBAR_SHOWGRID" or event=="ACTIONBAR_HIDEGRID"
        or event=="CURSOR_CHANGED" or event=="ACTIONBAR_SLOT_CHANGED" then return end
    if event ~= "PLAYER_REGEN_ENABLED" then
        C_Timer.After(1, QueueApply)
        C_Timer.After(3, QueueApply)
    end
end)
-- Stable settings adapter. Actions change decoration only, outside combat.
ForeverBarBackdropAPI={version=1}
function ForeverBarBackdropAPI.GetSettings() return KerimAnkaUIBarsAPI.View(ForeverBarBackdropCharacterDB,"backdrop") end
function ForeverBarBackdropAPI.Refresh() ApplyAll() end
function ForeverBarBackdropAPI.Set(key,value)
    db=KerimAnkaUIBarsAPI.View(ForeverBarBackdropCharacterDB,"backdrop")
    if not db or InCombatLockdown() then return false end
    if key=="enabled" and type(value)=="boolean" then db.enabled=value
    elseif (key=="shade" or key=="border" or key=="slotAlpha") and type(value)=="number" and value==value and math.abs(value)<math.huge then
        db[key]=math.max(0,math.min(key=="border" and 6 or 1,value))
    elseif key=="bars" and type(value)=="table" then
        local bars,seen={},{}
        for _,bar in ipairs(value) do
            if type(bar)~="number" or bar~=math.floor(bar) or bar<1 or bar>KerimAnkaUIBarsAPI.Count() then return false end
            if not seen[bar] then bars[#bars+1]=bar; seen[bar]=true end
        end
        if #bars==0 then return false end
        db.bars=bars
    else return false end
    ApplyAll(); return true
end
