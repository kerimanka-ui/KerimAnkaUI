-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local ADDON_NAME = ...
local warlock=select(2,UnitClass("player"))=="WARLOCK"
local shaman=select(2,UnitClass("player"))=="SHAMAN"
local mage=select(2,UnitClass("player"))=="MAGE"
local mageUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local priest=select(2,UnitClass("player"))=="PRIEST"
local priestUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local druid=select(2,UnitClass("player"))=="DRUID"
local druidUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local warrior=select(2,UnitClass("player"))=="WARRIOR"
local function WarriorVariant() return KerimAnkaUITextAPI.WarriorSkin()==2 and "Horde" or "Alliance" end
local paladin=select(2,UnitClass("player"))=="PALADIN"
local paladinUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local function PaladinVariant()
 return KerimAnkaUITextAPI.PaladinSkin()==2 and "Horde" or "Alliance"
end
local rogue=select(2,UnitClass("player"))=="ROGUE"
local rogueUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local LEGACY_SKIN_NAME = warrior and "Forever Warrior" or paladin and "Forever Paladin" or rogue and "Forever Rogue" or druid and "Forever Druid" or priest and "Forever Priest" or mage and "Forever Mage" or shaman and "Forever Shaman" or warlock and "Forever Warlock" or "Forever Hunter"
local shamanUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.546875,0.8125},Bottom={0.546875,0.8125},Left={0.8125,0.59375},Right={0.8125,0.59375}}
local SKIN_NAME='KerimAnka UI - '..LEGACY_SKIN_NAME:gsub('^Forever ','')
local function LegacyOwnSkin(name) return warrior and name=="Forever Hunter" or paladin and name=="Forever Hunter" or rogue and name=="Forever Hunter" or druid and (name=="Forever Hunter" or name=="Forever Warlock" or name=="Forever Shaman" or name=="Forever Mage" or name=="Forever Priest") or priest and (name=="Forever Hunter" or name=="Forever Warlock" or name=="Forever Shaman" or name=="Forever Mage") or name==SKIN_NAME or (warlock or shaman or mage) and name=="Forever Hunter" or (shaman or mage) and name=="Forever Warlock" or mage and name=="Forever Shaman" end
local function OwnSkin(name)return name==SKIN_NAME or LegacyOwnSkin(name)or name==LEGACY_SKIN_NAME end
local warlockUV={TL={0.8125,0.8125},TR={0.8125,0.8125},BL={0.8125,0.8125},BR={0.8125,0.8125},Top={0.5712890625,0.8125},Bottom={0.5712890625,0.8125},Left={0.8125,0.5625},Right={0.8125,0.5625}}
local MEDIA = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\"
local shells = setmetatable({}, {__mode = "k"})
local registered = false
local hooked = false
local db
local function Settings()
    if not db then
        if type(KAClassic_ForeverDetailsHunterDB)~="table" then KAClassic_ForeverDetailsHunterDB={} end
        db=KAClassic_ForeverDetailsHunterDB
        if type(db.showTrim)~="boolean" then db.showTrim=false end
        if type(db.keepFonts)~="boolean" then db.keepFonts=true end
        if type(db.trimAlpha)~="number" then db.trimAlpha=1 end
        db.trimAlpha=math.max(.1,math.min(1,db.trimAlpha))
        for _,key in ipairs({"edgeTop","edgeBottom","edgeLeft","edgeRight"}) do
            local v=db[key]
            db[key]=type(v)=="number" and v==v and math.max(-24,math.min(48,v)) or 0
        end
    end
    return db
end

local function FitTitle(instance)
    if not instance or not OwnSkin(instance.skin) or not instance.baseframe
        or instance.toolbar_side ~= 1 or instance.attribute_text.side ~= 1 then
        return
    end
    local label = instance:GetTitleBarFontString()
    if not label then
        return
    end
    local count = instance.total_buttons_shown or 0
    local buttonWidth = count * instance.menu_icons_size * 16
        + math.max(0, count - 1) * instance.menu_icons.space
    local textLeft = 21 + instance.attribute_text.anchor[1]
    local menuRight = -32 + instance.menu_anchor[1] + instance.menu_icons_size * 16
    local width = instance.baseframe:GetWidth() + menuRight - buttonWidth - textLeft - 6
    label:SetWidth(math.max(1, width))
end

local function CopyTable(source)
    local result = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = CopyTable(value)
        else
            result[key] = value
        end
    end
    return result
end

local paladinPieces=setmetatable({},{__mode="k"})
local function NewPiece(parent, name)
    local texture = parent:CreateTexture(nil, "OVERLAY")
    texture:SetTexture(MEDIA .. (warrior and "Warrior"..WarriorVariant().."\\" or paladin and "Paladin"..PaladinVariant().."\\" or rogue and "Rogue\\" or druid and "Druid\\" or priest and "Priest\\" or mage and "Mage\\" or shaman and "Shaman\\" or warlock and "Warlock\\" or "") .. name .. ".tga", "CLAMP", "CLAMP", "TRILINEAR")
    -- Files contain padded crops; the useful UV rectangle is generated alongside them.
    local uv = ((warrior or paladin) and paladinUV or rogue and rogueUV or druid and druidUV or priest and priestUV or mage and mageUV or shaman and shamanUV or warlock and warlockUV or ForeverDetailsHunterUV)[name]
    texture:SetTexCoord(0, uv[1], 0, uv[2])
    if warrior or paladin then paladinPieces[texture]=name end
    return texture
end

local function CreateShell(instance)
    local base = instance.baseframe
    local bounds = base.fullWindowFrame
    if not bounds then
        return
    end
    local shell = CreateFrame("Frame", nil, base)
    shell:EnableMouse(false)
    -- Draw only the outer trim. Rows, title text, menus and resize controls remain native.
    shell:SetFrameStrata(base:GetFrameStrata())
    shell:SetFrameLevel(base:GetFrameLevel() + 1)
    shell:SetPoint("TOPLEFT", bounds, "TOPLEFT", -14, 14)
    shell:SetPoint("BOTTOMRIGHT", bounds, "BOTTOMRIGHT", 14, -14)
    local corner = 32
    for _, item in ipairs({
        {"TL", "TOPLEFT"}, {"TR", "TOPRIGHT"},
        {"BL", "BOTTOMLEFT"}, {"BR", "BOTTOMRIGHT"},
    }) do
        local texture = NewPiece(shell, item[1])
        texture:SetSize(corner, corner)
        texture:SetPoint(item[2], shell, item[2])
    end
    local top = NewPiece(shell, "Top")
    top:SetHeight(corner)
    top:SetPoint("TOPLEFT", shell, "TOPLEFT", corner, 0)
    top:SetPoint("TOPRIGHT", shell, "TOPRIGHT", -corner, 0)
    local bottom = NewPiece(shell, "Bottom")
    bottom:SetHeight(corner)
    bottom:SetPoint("BOTTOMLEFT", shell, "BOTTOMLEFT", corner, 0)
    bottom:SetPoint("BOTTOMRIGHT", shell, "BOTTOMRIGHT", -corner, 0)
    local left = NewPiece(shell, "Left")
    left:SetWidth(corner)
    left:SetPoint("TOPLEFT", shell, "TOPLEFT", 0, -corner)
    left:SetPoint("BOTTOMLEFT", shell, "BOTTOMLEFT", 0, corner)
    local right = NewPiece(shell, "Right")
    right:SetWidth(corner)
    right:SetPoint("TOPRIGHT", shell, "TOPRIGHT", 0, -corner)
    right:SetPoint("BOTTOMRIGHT", shell, "BOTTOMRIGHT", 0, corner)
    shells[base] = shell
    return shell
end

local function RefreshShell(instance)
    if not instance or not instance.baseframe then
        return
    end
    local shell = shells[instance.baseframe]
    if not OwnSkin(instance.skin) then
        if shell then
            shell:Hide()
        end
        return
    end
    shell = shell or CreateShell(instance)
    if shell then
        shell:SetFrameStrata(instance.baseframe:GetFrameStrata())
        shell:SetFrameLevel(instance.baseframe:GetFrameLevel() + 1)
        local settings=Settings()
        shell:ClearAllPoints()
        shell:SetPoint("TOPLEFT",instance.baseframe.fullWindowFrame,"TOPLEFT",-math.max(0,14+settings.edgeLeft),math.max(0,14+settings.edgeTop))
        shell:SetPoint("BOTTOMRIGHT",instance.baseframe.fullWindowFrame,"BOTTOMRIGHT",math.max(0,14+settings.edgeRight),-math.max(0,14+settings.edgeBottom))
        shell:SetAlpha(Settings().trimAlpha)
        shell:SetShown(Settings().showTrim)
        FitTitle(instance)
    end
end

local function RegisterSkin()
    if registered then
        return true
    end
    local details = _G.Details
    if not details or not details.GetSkin or not details.InstallSkin then
        return false
    end
    local baseSkin = details:GetSkin("Minimalistic")
    if not baseSkin or not details.ChangeSkin then
        return false
    end
    -- Use the installed Details version's layout schema instead of embedding a fork.
    local skin = CopyTable(baseSkin)
    skin.file = MEDIA .. "Blank"
    skin.no_cache = true
    skin.is_cached_skin = nil
    skin.callback = nil
    skin.control_script = nil
    skin.skin_options = nil
    skin.author = "KerimAnka UI"
    skin.version = "0.2.0"
    skin.site = ""
    skin.desc = warrior and "Dark iron Warrior frame with linked Alliance and Horde cloth." or paladin and "Antique gold Paladin frame, following the Alliance or Horde appearance choice. Native Details data and controls." or rogue and "Dark stitched leather, antique brass, steel dagger clasps and poison emeralds. Native Details data and controls." or druid and "Dark ironwood, aged bronze, amber and autumn oak leaves. Native Details data and controls." or priest and "Antique gold, satin silver and ivory pearl clasps. Native Details data and controls." or mage and "Midnight navy, aged gold and silver celestial clasps. Native Details data and controls." or shaman and "Basalt, bronze and turquoise elemental spirals. Native Details data and controls." or warlock and "Obsidian, gold and fel gems. Native Details data and controls." or "Matte walnut, aged bronze and leaves. Native Details data and controls."
    local config = skin.instance_cprops
    config.color = {1, 1, 1, 1}
    config.bg_r, config.bg_g, config.bg_b, config.bg_alpha = 0.025, 0.030, 0.025, 0.92
    config.show_sidebars = false
    config.show_statusbar = false
    config.skin_custom = ""
    config.fullborder_shown = false
    config.rowareaborder_shown = false
    config.rounded_corner_enabled = false
    config.titlebar_shown = true
    config.titlebar_height = 20
    config.titlebar_texture_color = {0.045, 0.040, 0.030, 0.98}
    config.menu_icons_size = 0.78
    config.menu_icons_alpha = 0.9
    -- ball_r starts 32px left of the window edge. With a 12.48px button,
    -- x=8 leaves 11.52px of right padding instead of the old near-zero gap.
    config.menu_anchor = {8, 0, side = 2}
    -- ball ends 21px from the left. Place the text at x=31 and its 16px
    -- native attribute icon at x=11; neither crosses into the next window.
    config.attribute_text.anchor = {10, 3}
    config.attribute_text.text_size = 12
    config.attribute_text.text_color = {0.92, 0.84, 0.63, 1}
    config.row_info.height = 21
    config.row_info.font_size = 16
    -- Width is base width + right, not base width - left - right.
    -- With left=6 and right=-14, the row ends 8px inside the window.
    config.row_info.space.left = 6
    config.row_info.space.right = -14
    config.row_info.space.left_noborder = 6
    config.row_info.space.right_noborder = -14
    config.row_info.alpha = 1
    config.wallpaper.enabled = false

    if not hooked then
        hooksecurefunc(details, "ChangeSkin", RefreshShell)
        hooksecurefunc(details, "RefreshAttributeTextSize", FitTitle)
        -- Native methods can reparent or change strata while keeping the same skin.
        if details.SetFrameStrata then hooksecurefunc(details, "SetFrameStrata", RefreshShell) end
        hooked=true
    end
    registered = details:InstallSkin(SKIN_NAME, skin) == true
    if registered and details.GetAllInstances then
        for id, instance in ipairs(details:GetAllInstances()) do
            if not InCombatLockdown()and OwnSkin(instance.skin)and instance.skin~=SKIN_NAME then ForeverDetailsHunterAPI.Apply(id,SKIN_NAME)end
            RefreshShell(instance)
        end
    end
    return registered
end

local function Instances()
    local details=_G.Details
    return details and details.GetAllInstances and details:GetAllInstances() or {}
end
local function Available(instance)
    return instance and instance.baseframe and instance.bgframe and instance.ChangeSkin
        and type(instance.row_info)=="table" and type(instance.attribute_text)=="table"
        and instance.IsEnabled and instance:IsEnabled()
end
ForeverDetailsHunterAPI={version=1,skinName=SKIN_NAME}
function ForeverDetailsHunterAPI.RefreshAppearance()
    if not (warrior or paladin) or InCombatLockdown() then return end
    local prefix=MEDIA..(warrior and "Warrior"..WarriorVariant() or "Paladin"..PaladinVariant()).."\\"
    for texture,name in pairs(paladinPieces) do texture:SetTexture(prefix..name..".tga","CLAMP","CLAMP","TRILINEAR") end
end
function ForeverDetailsHunterAPI.GetSettings() return Settings() end
function ForeverDetailsHunterAPI.GetWindows()
    local result={}
    for id,instance in pairs(Instances()) do
        if type(id)=="number" and Available(instance) then result[#result+1]={id=id,skin=instance.skin or ""} end
    end
    table.sort(result,function(a,b) return a.id<b.id end)
    return result
end
function ForeverDetailsHunterAPI.GetSkins()
    local result={}
    for name in pairs(_G.Details and Details.skins or {}) do if type(name)=="string" then result[#result+1]=name end end
    table.sort(result)
    return result
end
function ForeverDetailsHunterAPI.IsReady() return registered end
function ForeverDetailsHunterAPI.Set(key,value)
    if InCombatLockdown() then return false,"combat" end
    local settings=Settings()
    if (key=="showTrim" or key=="keepFonts") and type(value)=="boolean" then settings[key]=value
    elseif key=="trimAlpha" and type(value)=="number" and value==value and math.abs(value)<math.huge then
        settings.trimAlpha=math.max(.1,math.min(1,value))
    elseif (key=="edgeTop" or key=="edgeBottom" or key=="edgeLeft" or key=="edgeRight") and type(value)=="number" and value==value and math.abs(value)<math.huge then
        settings[key]=math.max(-24,math.min(48,value))
    else return false,"setting" end
    for _,instance in pairs(Instances()) do if instance.baseframe then RefreshShell(instance) end end
    return true
end
function ForeverDetailsHunterAPI.Apply(id,skinName)
    if InCombatLockdown() then return false,"combat" end
    if type(skinName)=='string'and OwnSkin(skinName)then skinName=SKIN_NAME end
    if not registered or type(skinName)~="string" or not Details:GetSkin(skinName) then return false,"skin unavailable" end
    local instance=Instances()[id]
    if not Available(instance) then return false,"window unavailable" end
    if instance.skin==skinName then RefreshShell(instance); return true end
    local fonts
    if Settings().keepFonts then
        if not instance.SetBarTextFontSize or not instance.SetBarTextFontFace or not instance.AttributeMenu then
            return false,"font preservation API unavailable"
        end
        fonts={rowSize=instance.row_info.font_size,rowFace=instance.row_info.font_face,
            titleSize=instance.attribute_text.text_size,titleFace=instance.attribute_text.text_face}
    end
    local ok,err=pcall(function()
        -- Same per-instance method used by Details' native skin selector.
        instance:ChangeSkin(skinName)
        if fonts then
            if fonts.rowFace then instance:SetBarTextFontFace(fonts.rowFace) end
            if fonts.rowSize then instance:SetBarTextFontSize(fonts.rowSize) end
            instance:AttributeMenu(nil,nil,nil,fonts.titleFace,fonts.titleSize)
        end
        RefreshShell(instance)
    end)
    if not ok then return false,tostring(err) end
    if instance.skin==skinName then return true end
    return false,"skin not applied"
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    Settings()
    self:UnregisterAllEvents()
    if RegisterSkin() then
        return
    end
    -- Details may finish constructing its built-in skins after PLAYER_LOGIN.
    local attempts = 0
    local function Retry()
        attempts = attempts + 1
        if RegisterSkin() then
            return
        end
        if attempts < 30 then
            C_Timer.After(1, Retry)
        else
            print("KerimAnka UI Details: Details skin API is not ready; skin was not registered.")
        end
    end
    C_Timer.After(1, Retry)
end)
