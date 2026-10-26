-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _, ns = ...
local window, refresh
local function Config() return ns.GetSettings() end

local function Label(parent, text, x, y, template)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(text)
    return label
end

local function Button(parent, text, x, y, width, callback)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button:SetSize(width, 26)
    button:SetText(text)
    button:SetScript("OnClick", callback)
    return button
end

local function BuildOptions()
    window = CreateFrame("Frame", "HunterAspectAlertOptions", UIParent, "BackdropTemplate")
    window:SetSize(520, 470)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", function(self) self:StartMoving() end)
    window:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    window:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    table.insert(UISpecialFrames, "HunterAspectAlertOptions")
    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)

    Label(window, "Hunter Aspect Alert", 22, -20, "GameFontNormalLarge")
    Label(window, "Ayarlar otomatik kaydedilir. Uyarı arka planı tamamen şeffaftır.", 22, -48, "GameFontHighlightSmall")

    local lock = Button(window, "", 22, -76, 230, function()
        local wasLocked = ns.IsLocked()
        ns.SetLocked(not wasLocked)
        refresh()
        if wasLocked then window:Hide() end
    end)
    Button(window, "Konumu sıfırla", 270, -76, 225, function() ns.ResetPosition() end)
    Label(window, "Kilidi açınca panel kapanır; ikonları sürükle. /haa ile geri dön.", 22, -108, "GameFontHighlightSmall")

    local checks = {}
    local function Checkbox(key, text, y)
        local check = CreateFrame("CheckButton", nil, window, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", 18, y)
        check:SetSize(28, 28)
        Label(check, text, 32, -7)
        check:SetScript("OnClick", function(self)
            Config()[key] = not not self:GetChecked()
            ns.Refresh()
        end)
        checks[key] = check
    end
    Checkbox("showText", "Uyarı yazılarını göster", -137)
    Checkbox("cheetahGlow", "Savaşta Geparden ikonuna hafif parlama ekle", -170)

    local edits = {}
    local function TextInput(key, text, y)
        Label(window, text, 22, y)
        local edit = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
        edit:SetPoint("TOPLEFT", 28, y - 22)
        edit:SetSize(455, 28)
        edit:SetAutoFocus(false)
        edit:SetMaxLetters(100)
        edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        edit:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                Config()[key] = self:GetText();Config()[key.."Custom"]=self:GetText()~=""
                ns.Refresh()
            end
        end)
        edits[key] = edit
    end
    TextInput("cheetahText", "Geparden savaş uyarısı — kendi metnini yaz:", -218)
    TextInput("missingText", "Aspekt yok uyarısı — kendi metnini yaz:", -284)

    Button(window, "Geparden önizle", 22, -354, 150, function()
        ns.Preview("cheetah")
        window:Hide()
    end)
    Button(window, "Aspekt yok önizle", 182, -354, 150, function()
        ns.Preview("missing")
        window:Hide()
    end)
    Button(window, "Önizlemeyi bitir", 342, -354, 153, function()
        ns.Preview(nil)
        refresh()
    end)
    Button(window, "Metinleri varsayılana döndür", 22, -393, 260, function()
        Config().cheetahText = "";Config().cheetahTextCustom=false
        Config().missingText = "";Config().missingTextCustom=false
        refresh()
        ns.Refresh()
    end)
    Label(window, "Aspekt yokken parlama gösterilmez. Önizlemeyi kapatmak: /haa off", 22, -434, "GameFontHighlightSmall")

    refresh = function()
        lock:SetText(ns.IsLocked() and "Konum kilidini aç / taşı" or "Konumu kilitle")
        for key, check in pairs(checks) do check:SetChecked(Config()[key]) end
        for key, edit in pairs(edits) do
            edit:SetText(HunterAspectAlertAPI.GetText(key))
            edit:ClearFocus()
        end
    end
    window:SetScript("OnShow", refresh)
    refresh()
end

function ns.OpenOptions()
    if KerimAnkaUIAPI then KerimAnkaUIAPI.OpenPage("aspect"); return end
    if not window then BuildOptions() end
    window:Show()
    window:Raise()
end

function ns.RegisterOptions()
    if KerimAnkaUIAPI then return end
    if not Settings or not Settings.RegisterCanvasLayoutCategory then return end
    local page = CreateFrame("Frame")
    page:Hide()
    Label(page, "Hunter Aspect Alert", 20, -20, "GameFontNormalLarge")
    Label(page, "Konum, uyarı metinleri ve Geparden parlaması.", 20, -54)
    Button(page, "Ayar panelini aç", 20, -90, 220, function()
        if SettingsPanel then SettingsPanel:Hide() end
        ns.OpenOptions()
    end)
    local category = Settings.RegisterCanvasLayoutCategory(page, "Hunter Aspect Alert")
    Settings.RegisterAddOnCategory(category)
end
