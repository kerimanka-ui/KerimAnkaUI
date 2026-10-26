-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Rogue decoration only. No protected buttons, portraits or combat values changed.
local _, class = UnitClass("player")
if class ~= "ROGUE" then return end
local M = {}
ForeverClassArtRogue = M
ForeverClassArtBarPanel = M
local panel = CreateFrame("Frame", nil, UIParent)
panel:SetFrameStrata("BACKGROUND")
panel:SetFrameLevel(0)
panel:EnableMouse(false)
panel:Hide()
local fill = panel:CreateTexture(nil, "BACKGROUND", nil, -8)
fill:SetAllPoints()
fill:SetTexture("Interface\\AddOns\\KerimAnkaUI_ClassArt\\RogueBacking.tga")

local function Defaults(d)
    if d.rogueBackingEnabled == nil then d.rogueBackingEnabled = true end
    if type(d.rogueBackingAlpha) ~= "number" then d.rogueBackingAlpha = 1 end
    if d.rogueDockBottom == nil then d.rogueDockBottom = false end
    if type(d.rogueBottomInset) ~= "number" then d.rogueBottomInset = 0 end
end

function M.Position(art, d)
    Defaults(d)
    -- Manual placement must stay unrestricted, including negative screen offsets.
    if not d.rogueDockBottom then return end
    local left, bottom, width, height = art:GetRect()
    if not left or not bottom or not width or not height then return end
    -- Measured alpha bounds: the badge is the lowest visible pixel (v=0.91).
    -- Include a small safety margin; transparent PNG padding may sit offscreen.
    local lowest = 0.085 * height
    local target = d.rogueBottomInset - lowest
    if target ~= bottom then
        art:ClearAllPoints()
        art:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, target)
    end
end

function M.Hide() panel:Hide() end
function M.Update(d)
    Defaults(d)
    local art = _G.ForeverHunterArtFrame
    if not d.enabled or not d.rogueBackingEnabled or not art or not art:IsShown() then
        panel:Hide(); return
    end
    if InCombatLockdown() then return end
    ForeverBackingColor.Paint(fill,d,"Interface\\AddOns\\KerimAnkaUI_ClassArt\\RogueBacking.tga",{1,1,1,1})
    -- Follow the artwork, including locked layout and bottom docking.
    -- The fill overlaps the opaque rails so it cannot leave a slit at the joins.
    local w, h = art:GetWidth(), art:GetHeight()
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", art, "TOPLEFT", w * 0.105, -h * 0.205)
    panel:SetPoint("BOTTOMRIGHT", art, "TOPLEFT", w * 0.895, -h * 0.795)
    panel:SetAlpha(math.max(0, math.min(1, d.rogueBackingAlpha)) * (d.alpha or 1))
    panel:Show()
end

function M.Options(getDB)
    local function DB() local d = getDB(); Defaults(d); return d end
    local function Set(key, value)
        DB()[key] = value
        -- The main layout ticker applies position settings out of combat.
        M.Update(DB())
    end
    return {type="group", name="Rogue — Zehir Ustası deri panel", order=45, inline=true,
        disabled=function() return InCombatLockdown() end,
        args={
            info={type="description", order=1, name="Deri arka panel kapalı çerçeveyle birlikte hareket eder. Alt kenara yaslama yalnızca süslemeyi taşır; yetenek barlarının yerini Bartender'dan ayarlayabilirsin."},
            enabled={type="toggle", name="Deri arka paneli göster", order=2, width="full",
                get=function() return DB().rogueBackingEnabled end,
                set=function(_, v) Set("rogueBackingEnabled", v) end},
            alpha={type="range", name="Deri arka panel görünürlüğü", order=3, min=0, max=1, step=.05, width="full",
                get=function() return DB().rogueBackingAlpha end,
                set=function(_, v) Set("rogueBackingAlpha", v) end},
            dock={type="toggle", name="Süslemeyi ekranın altına yasla", order=4, width="full",
                desc="Çanta ve ortadaki amblemi görünür tutar. Açıkken genel yukarı/aşağı ayarı yerine aşağıdaki alt kenar payı kullanılır.",
                get=function() return DB().rogueDockBottom end,
                set=function(_, v) Set("rogueDockBottom", v) end},
            inset={type="range", name="Alt kenardan yükseklik", order=5, min=-200, max=200, step=1, width="full",
                desc="Negatif değer süslemeyi daha aşağı indirir; istersen alt parçaları ekran dışına taşıyabilirsin.",
                disabled=function() return InCombatLockdown() or not DB().rogueDockBottom end,
                get=function() return DB().rogueBottomInset end,
                set=function(_, v) Set("rogueBottomInset", v) end},
        }}
end
