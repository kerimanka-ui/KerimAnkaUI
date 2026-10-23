-- Static decoration only: no map mask, button, zoom or input changes.
local module = {}
ForeverClassArtMinimap = module
local files = {DRUID = "DruidMinimap",PRIEST = "PriestMinimap",MAGE = "MageMinimap",SHAMAN = "ShamanMinimap",WARLOCK = "WarlockMinimap",HUNTER = "HunterMinimap", PALADIN = "PaladinMinimap", WARRIOR = "WarriorMinimap", ROGUE = "RogueMinimap"}
local _, class = UnitClass("player")
local warlockOpening={width=0.6674641148325359,height=0.6586921850079744,x=0.4996012759170654,y=0.48564593301435405}
local shamanOpening={width=0.7232854864433812,height=0.7025518341307815,x=0.4996012759170654,y=0.44537480063795853}
local mageOpening={width=0.7129186602870813,height=0.6858054226475279,x=0.5,y=0.47208931419457734}
local priestOpening={width=0.7456140350877193,height=0.7200956937799043,x=0.4996012759170654,y=0.4700956937799043}
local druidOpening={width=0.759170653907496,height=0.7312599681020734,x=0.49760765550239233,y=0.47248803827751196}
local paladinOpenings={[1]={width=0.7288676236044657,height=0.6985645933014354,x=0.5,y=0.4984051036682616},[2]={width=0.7248803827751196,height=0.6945773524720893,x=0.5003987240829346,y=0.4988038277511962}}
local warriorOpenings={[1]={width=0.7009569377990431,height=0.6874003189792663,x=0.4996012759170654,y=0.49760765550239233},[2]={width=0.6945773524720893,height=0.6866028708133971,x=0.4996012759170654,y=0.49800637958532695}}
local artwork, hooked
local originals = {}
local writingAlpha = false
local function DB()
    if type(ForeverMinimapArtDB) ~= "table" then ForeverMinimapArtDB = {} end
    local db = ForeverMinimapArtDB
    for key, value in pairs({enabled=false, size=100, x=0, y=0, hideBorder=true, hunterMatte=true}) do
        if type(db[key]) ~= type(value) then db[key] = value end
    end
    if class=="WARLOCK" and not db.warlockObsidianInitialized then
        db.warlockObsidianInitialized=true
    end
    if class=="SHAMAN" and not db.shamanElementInitialized then
        db.shamanElementInitialized=true
    end
    if class=="MAGE" and not db.mageAstralInitialized then
        db.mageAstralInitialized=true
    end
    if class=="PRIEST" and not db.priestHaloInitialized then
        db.priestHaloInitialized=true
    end
    if class=="DRUID" and not db.druidWildInitialized then
        db.druidWildInitialized=true
    end
    return db
end
local function Borders(hide)
    for _, name in ipairs({"MinimapCompassTexture", "MinimapCompassTextureUnderlay"}) do
        local region = _G[name]
        if region and region.SetAlpha and not originals[region] then
            originals[region] = {alpha=region:GetAlpha(), hidden=false}
            hooksecurefunc(region, "SetAlpha", function(self, alpha)
                local state = originals[self]
                if writingAlpha then return end
                state.alpha = alpha
                if state.hidden then
                    writingAlpha = true
                    self:SetAlpha(0)
                    writingAlpha = false
                end
            end)
        end
    end
    for region, state in pairs(originals) do
        state.hidden = hide
        writingAlpha = true
        region:SetAlpha(hide and 0 or state.alpha)
        writingAlpha = false
    end
end
function module.Apply()
    local db = DB()
    local map = _G.Minimap
    local parent = _G.MinimapBackdrop
    local active = files[class] and db.enabled and map and parent and map:IsVisible()
    if not active then
        if artwork then artwork:Hide() end
        Borders(false)
        return
    end
    if not artwork then
        -- Same parent as Blizzard's ring; child buttons (including DielFrame)
        -- continue to render above this texture. Textures do not intercept clicks.
        artwork = parent:CreateTexture(nil, "OVERLAY", nil, 7)
    end
    local filename = class=="WARRIOR" and (KerimAnkaUITextAPI.WarriorSkin()==2 and "WarriorMapHorde" or "WarriorMapAlliance") or class=="PALADIN" and (KerimAnkaUITextAPI.PaladinSkin()==2 and "PaladinMapHorde" or "PaladinMapAlliance") or class == "HUNTER" and db.hunterMatte and "HunterMinimapMatte" or files[class]
    local path = "Interface\\AddOns\\KerimAnkaUI_ClassArt\\" .. filename .. ".tga"
    if artwork.file ~= path then
        if class == "ROGUE" or class == "HUNTER" or class=="WARLOCK" or class=="SHAMAN" or class=="MAGE" or class=="PRIEST" or class=="DRUID" or class=="PALADIN" or class=="WARRIOR" then
            artwork:SetTexture(path, "CLAMP", "CLAMP", "TRILINEAR")
        else
            artwork:SetTexture(path)
        end
        artwork.file = path
    end
    local ratio = map:GetEffectiveScale() / parent:GetEffectiveScale()
    artwork:ClearAllPoints()
    if class=="WARLOCK" or class=="SHAMAN" or class=="MAGE" or class=="PRIEST" or class=="DRUID" or class=="PALADIN" or class=="WARRIOR" then
        -- The source is packed without resampling. Align its measured alpha
        -- aperture, not the canvas center or a guessed shared opening ratio.
        local o=class=="WARRIOR" and warriorOpenings[KerimAnkaUITextAPI.WarriorSkin()] or class=="PALADIN" and paladinOpenings[KerimAnkaUITextAPI.PaladinSkin()] or class=="DRUID" and druidOpening or class=="PRIEST" and priestOpening or class=="MAGE" and mageOpening or class=="SHAMAN" and shamanOpening or warlockOpening
        local w=map:GetWidth()*ratio/o.width*db.size/100
        local h=map:GetHeight()*ratio/o.height*db.size/100
        artwork:SetTexCoord(0,1254/2048,0,1254/2048)
        artwork:SetSize(w,h)
        artwork:SetPoint("CENTER",map,"CENTER",db.x+(.5-o.x)*w,db.y+(o.y-.5)*h)
    else
        artwork:SetTexCoord(0,1,0,1)
        artwork:SetPoint("CENTER", map, "CENTER", db.x, db.y)
        local opening = class == "ROGUE" and 0.72 or 0.70
        artwork:SetSize(map:GetWidth() * ratio / opening * db.size / 100,
            map:GetHeight() * ratio / opening * db.size / 100)
    end
    artwork:Show()
    Borders(db.hideBorder)
    if not hooked then
        hooked = true
        map:HookScript("OnSizeChanged", module.Apply)
        map:HookScript("OnShow", module.Apply)
        map:HookScript("OnHide", module.Apply)
    end
end
function module.Options()
    local function Range(key, title, order, low, high)
        return {type="range", name=title, order=order, min=low, max=high, step=1, width="full",
            get=function() return DB()[key] end,
            set=function(_, value) DB()[key]=value; module.Apply() end}
    end
    return {type="group", name="Minimap süslemesi", order=40, inline=true,
        disabled=function() return not files[class] or InCombatLockdown() end,
        args={
            info={type="description", order=1, name="Haritayla birlikte hareket eder ve ölçeklenir. Bu ayarlar action bar süslemesini etkilemez."},
            enabled={type="toggle", name="Minimap süslemesini göster", order=2, width="full",
                get=function() return DB().enabled end,
                set=function(_, value) DB().enabled=value; module.Apply() end},
            size=Range("size", "Çerçeve boyutu (%)", 3, 80, 130),
            x=Range("x", "Sağ / sol düzeltme", 4, -40, 40),
            y=Range("y", "Yukarı / aşağı düzeltme", 5, -40, 40),
            hideBorder={type="toggle", name="Blizzard minimap kenarlığını gizle", order=6, width="full",
                desc="Yalnızca minimap kenarlığını gizler. Action bar yan süslerini değiştirmez. Güneş düğmesine dokunmaz.",
                get=function() return DB().hideBorder end,
                set=function(_, value) DB().hideBorder=value; module.Apply() end},
            hunterMatte={type="toggle", name="Hunter: mat minimap görünümü", order=6.5, width="full",
                hidden=function() return class ~= "HUNTER" end,
                desc="Küçük parlamaları azaltan mat görsel. Kapatınca önceki Hunter görseli kullanılır.",
                get=function() return DB().hunterMatte end,
                set=function(_, value) DB().hunterMatte=value; module.Apply() end},
            reset={type="execute", name="Minimap ayarlarını sıfırla", order=7,
                func=function() ForeverMinimapArtDB=nil; module.Apply() end},
        }}
end
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("CVAR_UPDATE")
events:SetScript("OnEvent", function(_, event, cvar)
    if event == "CVAR_UPDATE" and cvar ~= "rotateMinimap" then return end
    module.Apply()
    if event == "PLAYER_LOGIN" then
        C_Timer.After(1, module.Apply)
        C_Timer.After(3, module.Apply)
    end
end)
