local _, K = ...
local iconPath="Interface\\AddOns\\KerimAnkaUI\\Media\\Phoenix.tga"
local button, iconLib
local function HideTooltip(self)
    if GameTooltip and GameTooltip:IsOwned(self) then GameTooltip:Hide() end
end
local function Tooltip(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_NONE")
    GameTooltip:ClearAllPoints();GameTooltip:SetPoint("TOP",self,"BOTTOM",0,-3)
    GameTooltip:SetText("KerimAnka UI")
    GameTooltip:AddLine(K.L("openTip"),1,1,1)
    GameTooltip:Show()
end
local function Toggle(self) HideTooltip(self);K.window:SetShown(not K.window:IsShown()) end
local function Position()
    if not button then return end
    local radians=math.rad(KerimAnkaUIDB.minimap.minimapPos or 220)
    button:ClearAllPoints(); button:SetPoint("CENTER",Minimap,"CENTER",math.cos(radians)*80,math.sin(radians)*80)
end
function K.UpdateLauncher()
    if iconLib then
        if KerimAnkaUIDB.minimap.hide then iconLib:Hide("KerimAnkaUI") else iconLib:Show("KerimAnkaUI") end
    elseif button then button:SetShown(not KerimAnkaUIDB.minimap.hide) end
end
function K.CreateLauncher()
    -- The suite has one Blizzard settings entry as well as one minimap icon.
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local page=CreateFrame("Frame")
        local title=page:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
        title:SetPoint("TOPLEFT",20,-20); title:SetText("KerimAnka UI")
        local open=CreateFrame("Button",nil,page,"UIPanelButtonTemplate")
        open:SetPoint("TOPLEFT",20,-60); open:SetSize(240,32); open:SetText("KerimAnka UI")
        open:SetScript("OnClick",function()
            if SettingsPanel then SettingsPanel:Hide() end
            K.ShowPage("home")
        end)
        Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(page,"KerimAnka UI"))
    end
    if LibStub then
        local broker=LibStub("LibDataBroker-1.1",true)
        iconLib=LibStub("LibDBIcon-1.0",true)
        if broker and iconLib then
            local data=broker:NewDataObject("KerimAnkaUI",{type="launcher",text="KerimAnka UI",icon=iconPath,OnClick=Toggle,OnEnter=Tooltip,OnLeave=HideTooltip})
            iconLib:Register("KerimAnkaUI",data,KerimAnkaUIDB.minimap)
            K.UpdateLauncher(); return
        end
        iconLib=nil
    end
    if not Minimap then return end
    -- Standard launcher fields/name also let collectors recognize the fallback.
    button=CreateFrame("Button","LibDBIcon10_KerimAnkaUI",Minimap)
    button:SetSize(31,31); button:SetFrameStrata("MEDIUM"); button:SetFrameLevel(Minimap:GetFrameLevel()+8)
    button.db=KerimAnkaUIDB.minimap
    button.dataObject={type="launcher",text="KerimAnka UI",icon=iconPath}
    button.icon=button:CreateTexture(nil,"ARTWORK"); button.icon:SetSize(20,20); button.icon:SetPoint("CENTER"); button.icon:SetTexture(iconPath)
    button.icon:SetTexCoord(0.08,0.92,0.08,0.92)
    local border=button:CreateTexture(nil,"OVERLAY"); border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); border:SetSize(54,54); border:SetPoint("TOPLEFT",-1,1)
    button:RegisterForClicks("LeftButtonUp"); button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick",Toggle); button:SetScript("OnEnter",Tooltip); button:SetScript("OnLeave",HideTooltip)
    button:SetScript("OnDragStart",function(self)
        HideTooltip(self)
        self:SetScript("OnUpdate",function()
            local x,y=GetCursorPosition(); local mx,my=Minimap:GetCenter(); local scale=Minimap:GetEffectiveScale()
            KerimAnkaUIDB.minimap.minimapPos=math.deg(math.atan2(y/scale-my,x/scale-mx)); Position()
        end)
    end)
    button:SetScript("OnDragStop",function(self) self:SetScript("OnUpdate",nil) end)
    Position(); K.UpdateLauncher()
end
