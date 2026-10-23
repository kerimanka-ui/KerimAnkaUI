-- Cosmetic backing for the real pet action bar, on every class.
-- Parent visibility handles pet appearance/disappearance, including in combat.
-- No pet/combat values, replacement buttons, timers or per-frame polling.
local M={};ForeverPetBarPanel=M
local _,class=UnitClass("player")
local PATH="Interface\\AddOns\\KerimAnkaUI_ClassArt\\"
local frame=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
frame:EnableMouse(false);frame:Hide()
frame:SetBackdrop({bgFile=PATH..(class=="HUNTER" and "HunterBacking.tga" or "ForgedIron.tga"),
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=128,edgeSize=8,
    insets={left=2,right=2,top=2,bottom=2}})
frame:SetBackdropColor(.3,.3,.27,1)
frame:SetBackdropBorderColor(.66,.47,.2,1)
local parents={};local queued=false
local boundParent,lastPad,lastAlpha,lastBounds
local function DB()
    if type(ForeverHunterHUDDB)~="table" then ForeverHunterHUDDB={} end
    local d=ForeverHunterHUDDB
    if d.petPanelEnabled==nil then
        d.petPanelEnabled=not (class=="HUNTER" and type(ForeverHunterArtCharacterDB)=="table" and ForeverHunterArtCharacterDB.hunterPetEnabled==false)
    end
    if type(d.petPanelPadding)~="number" then d.petPanelPadding=3 end
    if type(d.petPanelAlpha)~="number" then d.petPanelAlpha=1 end
    return d
end
function M.Enabled() return DB().petPanelEnabled end
local function Queue()
    if queued then return end;queued=true
    C_Timer.After(0,function() queued=false;M.Apply() end)
end
local function Hook(parent)
    if parents[parent] then return end;parents[parent]=true
    parent:HookScript("OnShow",Queue)
    parent:HookScript("OnSizeChanged",Queue)
end
local function Public(value) return not (issecretvalue and issecretvalue(value)) end
local function Bounds(parent)
    local px,py=parent:GetLeft(),parent:GetBottom()
    local ps=parent:GetEffectiveScale()
    if not (Public(px) and Public(py) and Public(ps)) or not px or not py or not ps or ps<=0 then return end
    local bounds
    for i=1,10 do
        local button=KerimAnkaUIBarsAPI.PetButton(i)
        if button and button:IsShown() then
            Hook(button)
            local x,y,w,h=button:GetRect()
            local scale=button:GetEffectiveScale()
            if Public(x) and Public(y) and Public(w) and Public(h) and Public(scale)
                and x and y and w and h and scale and w>0 and h>0 then
                scale=scale/ps
                local l,b,r,t=x*scale-px,y*scale-py,(x+w)*scale-px,(y+h)*scale-py
                if bounds then
                    bounds.l=math.min(bounds.l,l);bounds.b=math.min(bounds.b,b)
                    bounds.r=math.max(bounds.r,r);bounds.t=math.max(bounds.t,t)
                else bounds={l=l,b=b,r=r,t=t} end
            end
        end
    end
    return bounds
end
function M.Apply()
    if InCombatLockdown() then return end
    local d=DB()
    if not d.petPanelEnabled then frame:Hide();return end
    local parent=KerimAnkaUIBarsAPI.PetParent()
    if not parent or parent==UIParent then frame:Hide();return end
    Hook(parent)
    local bounds=Bounds(parent)
    if not bounds then frame:Hide();return end
    local pad=math.max(0,math.min(12,d.petPanelPadding))
    local alpha=math.max(0,math.min(1,d.petPanelAlpha))
    if boundParent==parent and lastPad==pad and lastAlpha==alpha and lastBounds
        and lastBounds.l==bounds.l and lastBounds.r==bounds.r and lastBounds.t==bounds.t and lastBounds.b==bounds.b then frame:Show();return end
    if frame:GetParent()~=parent then frame:SetParent(parent) end
    frame:SetFrameStrata("BACKGROUND");frame:SetFrameLevel(0)
    frame:SetScale(1)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT",parent,"BOTTOMLEFT",bounds.l-pad,bounds.t+pad)
    frame:SetPoint("BOTTOMRIGHT",parent,"BOTTOMLEFT",bounds.r+pad,bounds.b-pad)
    frame:SetAlpha(alpha)
    boundParent,lastPad,lastAlpha,lastBounds=parent,pad,alpha,bounds
    -- Keep shown under the real parent even when that parent is hidden. This
    -- avoids needing protected layout writes when a pet appears during combat.
    frame:Show()
end
function M.Options()
    local function Set(k,v) if InCombatLockdown() then return end;DB()[k]=v;M.Apply() end
    return {type="group",name="Pet action bar",order=48,inline=true,
        disabled=function() return InCombatLockdown() or KerimAnkaUIBarsAPI.PetSource()=="unavailable" end,args={
        petPanelEnabled={type="toggle",order=1,get=function() return DB().petPanelEnabled end,set=function(_,v) Set("petPanelEnabled",v) end},
        petPanelAlpha={type="range",order=2,min=0,max=1,step=.05,get=function() return DB().petPanelAlpha end,set=function(_,v) Set("petPanelAlpha",v) end},
        petPanelPadding={type="range",order=3,min=0,max=12,step=1,get=function() return DB().petPanelPadding end,set=function(_,v) Set("petPanelPadding",v) end}}}
end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","UNIT_PET","PET_BAR_UPDATE","PLAYER_REGEN_ENABLED","ADDON_LOADED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",Queue)
if EventRegistry and EventRegistry.RegisterCallback then EventRegistry:RegisterCallback("EditMode.Exit",Queue,events) end
