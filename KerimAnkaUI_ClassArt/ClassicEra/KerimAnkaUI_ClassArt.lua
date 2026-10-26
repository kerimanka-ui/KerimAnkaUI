-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Decorative artwork only. Does not modify buttons or their textures.
local events = CreateFrame("Frame")
local art = CreateFrame("Frame", "ForeverHunterArtFrame", UIParent)
-- Draw the ornament over the action buttons so the medallion covers their edges.
-- Keep mouse input disabled so the buttons remain clickable underneath.
art:SetFrameStrata("HIGH")
art:SetFrameLevel(0)
art:EnableMouse(false)
art:Hide()
local texture = art:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints()
local themes = {
    DRUID = {file="DruidWild.tga",left=.135,right=.865,top=.18,bottom=.68},
    PRIEST = {file="PriestLight.tga",left=.135,right=.865,top=.18,bottom=.68},
    MAGE = {file="MageAcademy.tga",left=.135,right=.865,top=.18,bottom=.68},
    SHAMAN = {file = "ShamanAncestralStraight.tga", left = 0.135, right = 0.865, top = 0.18, bottom = 0.68},
    WARLOCK = {file = "WarlockRitual.tga", left = 0.135, right = 0.865, top = 0.18, bottom = 0.68},
    HUNTER = {file = "HunterFrame.tga", left = 0.135, right = 0.865, top = 0.18, bottom = 0.68},
    PALADIN = {file = "PaladinConnectedAlliance.tga", left = .135, right = .865, top = .18, bottom = .68},
    WARRIOR = {file = "WarriorFrame.tga", left = 0.145, right = 0.855, top = 0.26, bottom = 0.775},
    ROGUE = {file = "RogueFrame.tga", left = 0.116, right = 0.884, top = 0.23, bottom = 0.735},
}
local _, playerClass = UnitClass("player")
local theme = themes[playerClass]

if theme then
    local path = "Interface\\AddOns\\KerimAnkaUI_ClassArt\\" .. theme.file
    if playerClass == "ROGUE" then
        texture:SetTexture(path, "CLAMP", "CLAMP", "TRILINEAR")
    else
        texture:SetTexture(path)
    end
end

-- Approximate transparent opening measured from the generated artwork.
-- The medallion rises above the bottom rail, so reserve space for it.
local OPEN_LEFT, OPEN_RIGHT = theme and theme.left or 0.135, theme and theme.right or 0.865
local OPEN_TOP, OPEN_BOTTOM = theme and theme.top or 0.18, theme and theme.bottom or 0.68
local db, ticker
local currentSkin
-- The approved PNG is packed unchanged into a power-of-two TGA atlas.
-- Three UV regions make the U-shaped body; the top rail is a separate frame.
local WarlockArt
if playerClass=="WARLOCK" then
    local M={};WarlockArt=M;ForeverClassArtBarPanel=M
    local path="Interface\\AddOns\\KerimAnkaUI_ClassArt\\WarlockRitual.tga"
    local fill=CreateFrame("Frame",nil,UIParent)
    fill:SetFrameStrata("BACKGROUND");fill:SetFrameLevel(0);fill:EnableMouse(false);fill:Hide()
    local background=fill:CreateTexture(nil,"BACKGROUND")
    background:SetAllPoints();background:SetColorTexture(.025,.018,.032,1)
    local parts={}
    for i=1,3 do
        local t=art:CreateTexture(nil,"ARTWORK")
        t:SetTexture(path,"CLAMP","CLAMP","TRILINEAR");parts[i]=t
    end
    parts[1]:SetTexCoord(0,295/2048,0,500/1024)
    parts[2]:SetTexCoord(1685/2048,1983/2048,0,500/1024)
    parts[3]:SetTexCoord(0,1983/2048,500/1024,714/1024)
    local rail=CreateFrame("Frame",nil,art)
    rail:EnableMouse(false);rail:Hide()
    local top=rail:CreateTexture(nil,"ARTWORK")
    top:SetTexture(path,"CLAMP","CLAMP","TRILINEAR")
    top:SetTexCoord(295/2048,1685/2048,102/1024,180/1024)
    top:SetAllPoints()
    local activeWarlockSkin
    local function Defaults(d)
        if d.warlockSkin~=2 then d.warlockSkin=1 end
        if d.warlockBackingEnabled==nil then d.warlockBackingEnabled=true end
        if type(d.warlockBackingAlpha)~="number" then d.warlockBackingAlpha=.9 end
        if d.warlockRailEnabled==nil then d.warlockRailEnabled=true end
        if type(d.warlockRailY)~="number" then d.warlockRailY=0 end
        if type(d.warlockRailX)~="number" then d.warlockRailX=0 end
        if type(d.warlockRailWidth)~="number" then d.warlockRailWidth=100 end
        if type(d.warlockRailHeight)~="number" then d.warlockRailHeight=22 end
    end
    function M.Hide()
        fill:Hide();rail:Hide();for _,t in ipairs(parts) do t:Hide() end
    end
    local function Rect(region,x,y,w,h)
        region:ClearAllPoints();region:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",x,y)
        region:SetSize(math.max(1,w),math.max(1,h))
    end
    function M.Update(d)
        if not InCombatLockdown() then ForeverBackingColor.Paint(background,d,nil,{.025,.018,.032,1}) end
        Defaults(d)
        if not d.enabled or not art:IsShown() then M.Hide();return end
        if InCombatLockdown() then return end
        local x,y,w,h=art:GetRect()
        if not x or not y or not w or not h or w<=0 or h<=0 then M.Hide();return end
        -- Retain the Hunter-compatible reference aperture so copied and locked
        -- profiles keep their existing button opening, rather than changing DBs.
        local fel=d.warlockSkin==2
        if activeWarlockSkin~=d.warlockSkin then
            local asset=fel and "Interface\\AddOns\\KerimAnkaUI_ClassArt\\WarlockFelObsidian.tga" or path
            for _,t in ipairs(parts) do t:SetTexture(asset,"CLAMP","CLAMP","TRILINEAR") end
            top:SetTexture(asset,"CLAMP","CLAMP","TRILINEAR")
            if fel then
                parts[1]:SetTexCoord(0,270/2048,0,520/1024)
                parts[2]:SetTexCoord(1715/2048,1983/2048,0,520/1024)
                parts[3]:SetTexCoord(0,1983/2048,520/1024,735/1024)
                top:SetTexCoord(270/2048,1715/2048,180/1024,250/1024)
            else
                parts[1]:SetTexCoord(0,295/2048,0,500/1024)
                parts[2]:SetTexCoord(1685/2048,1983/2048,0,500/1024)
                parts[3]:SetTexCoord(0,1983/2048,500/1024,714/1024)
                top:SetTexCoord(295/2048,1685/2048,102/1024,180/1024)
            end
            activeWarlockSkin=d.warlockSkin
        end
        local left,right=x+w*.135,x+w*.865
        local bottom,upper=y+h*.32,y+h*.82
        local sx=(right-left)/(fel and 1445 or 1390)
        local sy=(upper-bottom)/(500-180)
        local fullLeft=left-(fel and 270 or 295)*sx
        -- Keep the complete lower beam at the source aspect ratio. Position is
        -- controlled by the shared x/y settings; never squeeze it to the screen.
        -- Previous warlockDockBottom/warlockBottomInset values are inert legacy
        -- fields so existing profile codes continue to decode without migration.
        local baseline=bottom-214*sx
        if fel then
            -- The source opening ends at y=590. Keep the entire jaw and lower
            -- beam (y=520..735) at ONE uniform scale, including its upper lip.
            -- Only the side columns adapt to the configurable opening height.
            local seam=bottom+70*sx
            sy=math.max(1,upper-seam)/(520-240)
            Rect(parts[1],fullLeft,seam,270*sx,520*sy)
            Rect(parts[2],right,seam,268*sx,520*sy)
            Rect(parts[3],fullLeft,bottom-145*sx,1983*sx,215*sx)
        else
            Rect(parts[1],fullLeft,bottom,295*sx,500*sy)
            Rect(parts[2],right,bottom,298*sx,500*sy)
            Rect(parts[3],fullLeft,baseline,1983*sx,bottom-baseline)
        end
        for _,t in ipairs(parts) do t:Show() end
        local railHeight=math.max(8,math.min(48,d.warlockRailHeight))
        local railWidth=(right-left)*math.max(50,math.min(150,d.warlockRailWidth))/100+16
        local railLeft=(left+right-railWidth)/2+math.max(-150,math.min(150,d.warlockRailX))
        -- Anchor the actual horizontal beam at source y=145, not the transparent
        -- bottom of its crop. A small overlap closes both side-column seams.
        local railCenter=upper+(fel and 25 or 35)*sy+math.max(-100,math.min(100,d.warlockRailY))
        Rect(rail,railLeft,railCenter-(fel and 35/70 or 35/78)*railHeight,railWidth,railHeight)
        rail:SetShown(d.warlockRailEnabled)
        -- Like the Hunter panel, backing follows the ACTUAL selected bars.
        -- The ornament may be locked, resized or offset independently. Using
        -- its reference aperture here moved the backing up with art.y and
        -- exposed the bottom of the buttons (also with only bars 2/3 selected).
        local barLeft,barRight,barTop,barBottom=KerimAnkaUIBarsAPI.Bounds(d.bars)
        if not barLeft then fill:Hide();return end
        local fillLeft,fillRight=barLeft-4,barRight+4
        local fillBottom,fillTop=barBottom-4,barTop+4
        if d.warlockRailEnabled then
            -- Continue the backing beneath the independently positioned rail.
            fillLeft=math.min(fillLeft,railLeft+4);fillRight=math.max(fillRight,railLeft+railWidth-4)
            fillTop=math.max(fillTop,railCenter)
        end
        Rect(fill,fillLeft,fillBottom,fillRight-fillLeft,fillTop-fillBottom)
        fill:SetAlpha(math.max(0,math.min(1,d.warlockBackingAlpha))*(d.alpha or 1))
        fill:SetShown(d.warlockBackingEnabled)
    end
    function M.Options(getDB)
        local labels={warlockBackingEnabled="Show Dark Backing",warlockBackingAlpha="Backing Opacity",
            warlockRailEnabled="Show Independent Top Rail",warlockRailY="Top Rail Vertical Offset",warlockRailHeight="Top Rail Height",
            warlockRailX="Top Rail Horizontal Offset",warlockRailWidth="Top Rail Width"}
        local function DB() local d=getDB();Defaults(d);return d end
        local function Set(key,value)
            if InCombatLockdown() then return end
            DB()[key]=value;M.Update(DB())
        end
        local function Toggle(field,order)
            return {type="toggle",name=labels[field],order=order,get=function() return DB()[field] end,set=function(_,value) Set(field,value) end}
        end
        local function Range(field,order,low,high,step)
            return {type="range",name=labels[field],order=order,min=low,max=high,step=step,
                get=function() return DB()[field] end,set=function(_,value) Set(field,value) end}
        end
        return {type="group",name="Warlock — Ruh Ritüeli",order=45,inline=true,
            disabled=function() return InCombatLockdown() end,args={
                ritualBacking=Toggle("warlockBackingEnabled",1),
                ritualOpacity=Range("warlockBackingAlpha",2,0,1,.05),
                ritualRail=Toggle("warlockRailEnabled",5),
                ritualRailY=Range("warlockRailY",6,-100,100,1),
                ritualRailHeight=Range("warlockRailHeight",7,8,48,1),
                ritualRailX=Range("warlockRailX",8,-150,150,1),
                ritualRailWidth=Range("warlockRailWidth",9,50,150,1),
            }}
    end
end

local ShamanArt
if playerClass=="SHAMAN" then ShamanArt=ForeverCreateShamanArt(art);ForeverClassArtBarPanel=ShamanArt end

local MageArt
if playerClass=="MAGE" then MageArt=ForeverCreateMageArt(art);ForeverClassArtBarPanel=MageArt end

local PriestArt
if playerClass=="PRIEST" then PriestArt=ForeverCreatePriestArt(art);ForeverClassArtBarPanel=PriestArt end

local DruidArt
if playerClass=="DRUID" then DruidArt=ForeverCreateDruidArt(art);ForeverClassArtBarPanel=DruidArt end

local PaladinArt
if playerClass=="PALADIN" then PaladinArt=ForeverCreatePaladinArt(art);ForeverClassArtBarPanel=PaladinArt end

local function LayoutSkin()
    if WarlockArt or ShamanArt or MageArt or PriestArt or DruidArt or PaladinArt then texture:Hide();return end
    if playerClass=="WARRIOR" then
        local choice=db.warriorAction or 1
        local file=choice==3 and "WarriorBlackIron.tga" or choice==4 and "WarriorArena.tga" or KerimAnkaUITextAPI.WarriorSkin()==2 and "WarriorHorde.tga" or "WarriorFrame.tga"
        if currentSkin~=file then
            texture:SetTexture("Interface\\AddOns\\KerimAnkaUI_ClassArt\\"..file,"CLAMP","CLAMP","TRILINEAR")
            texture:SetTexCoord(0,1,0,1);currentSkin=file
        end
        texture:ClearAllPoints()
        if choice==3 or choice==4 then
            local l,r,t,b=choice==3 and 240/2172 or 220/2172,choice==3 and 1930/2172 or 1940/2172,choice==3 and 195/724 or 180/724,choice==3 and 560/724 or 555/724
            local width=art:GetWidth()*(OPEN_RIGHT-OPEN_LEFT)/(r-l)
            local height=art:GetHeight()*(OPEN_BOTTOM-OPEN_TOP)/(b-t)
            texture:SetSize(width,height)
            texture:SetPoint("TOPLEFT",art,"TOPLEFT",art:GetWidth()*OPEN_LEFT-width*l,-art:GetHeight()*OPEN_TOP+height*t)
        else texture:SetAllPoints(art) end
        return
    end
    local skin=playerClass=="HUNTER" and db and db.artSkin==2 and 2 or 1
    if skin~=currentSkin then
        local file=skin==2 and "HunterSimpleMetal.tga" or theme.file
        texture:SetTexture("Interface\\AddOns\\KerimAnkaUI_ClassArt\\"..file,"CLAMP","CLAMP","TRILINEAR")
        currentSkin=skin
    end
    texture:ClearAllPoints()
    if skin==2 then
        -- Map the new asset's safe aperture to the same existing bar opening.
        -- Locked anchors and all saved width/height/position values stay untouched.
        local l,r,t,b=182/2172,1990/2172,157/724,451/724
        local width=art:GetWidth()*(OPEN_RIGHT-OPEN_LEFT)/(r-l)
        local height=art:GetHeight()*(OPEN_BOTTOM-OPEN_TOP)/(b-t)
        texture:SetSize(width,height)
        texture:SetPoint("TOPLEFT",art,"TOPLEFT",art:GetWidth()*OPEN_LEFT-width*l,-art:GetHeight()*OPEN_TOP+height*t)
    else texture:SetAllPoints(art) end
end
local OpenPanel, RefreshPanel

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function Reset()
    if type(KAClassic_ForeverHunterArtCharacterDB)=="table" and KerimAnkaUIBarsAPI.Resolve()=="blizzard" then
        KAClassic_ForeverHunterArtCharacterDB.nativeLayout=nil
        db=KerimAnkaUIBarsAPI.View(KAClassic_ForeverHunterArtCharacterDB,"art")
        return
    end
    KAClassic_ForeverHunterArtCharacterDB = {
        enabled = false, bars = {1, 3, 4, 5, 6},
        gap = 4, x = 0, y = 0, alpha = 1,
        width = 100, height = 100,
    }
    db = KAClassic_ForeverHunterArtCharacterDB
end

local function Update()
    db=KerimAnkaUIBarsAPI.View(KAClassic_ForeverHunterArtCharacterDB,"art")
    local _,blocked=KerimAnkaUIBarsAPI.Resolve()
    if blocked then art:Hide();if ForeverClassArtBarPanel then ForeverClassArtBarPanel.Hide() end;return end
    if not db or not theme then art:Hide(); if ForeverClassArtBarPanel then ForeverClassArtBarPanel.Hide() end; return end
    if not db.enabled then art:Hide(); if ForeverClassArtBarPanel then ForeverClassArtBarPanel.Hide() end; return end
    -- Keep the last layout during combat; recompute after combat ends.
    if InCombatLockdown() then return end

    if db.locked then
        local anchor = db.locked
        local width = anchor.width * db.width / 100
        local height = anchor.height * db.height / 100
        art:ClearAllPoints()
        art:SetSize(width, height)
        art:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
            anchor.left + (anchor.width - width) / 2 + db.x,
            anchor.bottom + (anchor.height - height) / 2 + db.y)
        if ForeverClassArtRogue then ForeverClassArtRogue.Position(art, db) end
        LayoutSkin()
        art:SetAlpha(db.alpha)
        art:Show()
        if ForeverClassArtBarPanel then ForeverClassArtBarPanel.Update(db) end
        return
    end

    local left,right,top,bottom=KerimAnkaUIBarsAPI.Bounds(db.bars)
    if not left then art:Hide(); if ForeverClassArtBarPanel then ForeverClassArtBarPanel.Hide() end; return end
    local width = (right - left + 2 * db.gap) / (OPEN_RIGHT - OPEN_LEFT) * db.width / 100
    local height = (top - bottom + 2 * db.gap) / (OPEN_BOTTOM - OPEN_TOP) * db.height / 100
    art:ClearAllPoints()
    art:SetSize(width, height)
    art:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
        (left + right) / 2 - (OPEN_LEFT + OPEN_RIGHT) * width / 2 + db.x,
        (bottom + top) / 2 - (1 - (OPEN_TOP + OPEN_BOTTOM) / 2) * height + db.y)
    if ForeverClassArtRogue then ForeverClassArtRogue.Position(art, db) end
    LayoutSkin()
    art:SetAlpha(db.alpha)
    art:Show()
    if ForeverClassArtBarPanel then ForeverClassArtBarPanel.Update(db) end
end

ForeverClassArtLayoutAPI={
    Refresh=Update,
    GetSettings=function() return KerimAnkaUIBarsAPI.View(KAClassic_ForeverHunterArtCharacterDB,"art") end,
}

-- Class-specific choices share the same unchanged layout controls.
ForeverClassArtSkins={
    Count=function() return (playerClass=="WARRIOR" or playerClass=="MAGE" or playerClass=="DRUID") and 4 or 2 end,
    Get=function() if playerClass=="WARRIOR" then return db and (db.warriorAction==3 or db.warriorAction==4) and db.warriorAction or KerimAnkaUITextAPI.WarriorSkin() end;if playerClass=="PALADIN" then return KerimAnkaUITextAPI.PaladinSkin() end;if playerClass=="DRUID" then return db and (db.druidSkin==1 or db.druidSkin==2 or db.druidSkin==3 or db.druidSkin==4) and db.druidSkin or 3 end;if playerClass=="PRIEST" then return db and db.priestSkin==2 and 2 or 1 end;if playerClass=="MAGE" then return db and (db.mageSkin==1 or db.mageSkin==2 or db.mageSkin==3 or db.mageSkin==4) and db.mageSkin or 4 end;return db and (playerClass=="WARLOCK" and db.warlockSkin==2 or playerClass=="SHAMAN" and db.shamanSkin==2 or playerClass=="HUNTER" and db.artSkin==2) and 2 or 1 end,
    Set=function(id)
        if (playerClass~="HUNTER" and playerClass~="WARLOCK" and playerClass~="SHAMAN" and playerClass~="MAGE" and playerClass~="PRIEST" and playerClass~="DRUID" and playerClass~="PALADIN" and playerClass~="WARRIOR") or not db or InCombatLockdown() or (id~=1 and id~=2 and not ((playerClass=="MAGE" or playerClass=="DRUID" or playerClass=="WARRIOR") and (id==3 or id==4))) then return false end
        if playerClass=="WARRIOR" then
            db.warriorAction=(id==3 or id==4) and id or 1
            if id==1 or id==2 then db.warriorSkin=id end
        elseif playerClass=="PALADIN" then db.paladinSkin=id elseif playerClass=="DRUID" then db.druidSkin=id elseif playerClass=="PRIEST" then db.priestSkin=id elseif playerClass=="MAGE" then db.mageSkin=id elseif playerClass=="WARLOCK" then db.warlockSkin=id elseif playerClass=="SHAMAN" then db.shamanSkin=id else db.artSkin=id end
        Update()
        if playerClass=="PALADIN" or playerClass=="WARRIOR" then
            if ForeverClassArtMinimap then ForeverClassArtMinimap.Apply() end
            if ForeverLeatherUnitsAPI then ForeverLeatherUnitsAPI.Apply() end
            if KerimAnkaUIAPI and KerimAnkaUIAPI.RefreshMeterAppearance then KerimAnkaUIAPI.RefreshMeterAppearance() end
        end
        return true
    end,
    Available=function() return (playerClass=="HUNTER" or playerClass=="WARLOCK" or playerClass=="SHAMAN" or playerClass=="MAGE" or playerClass=="PRIEST" or playerClass=="DRUID" or playerClass=="PALADIN" or playerClass=="WARRIOR") and db~=nil end,
    Name=function(id)
        if playerClass=="WARRIOR" then return id==4 and "artSkinWarriorArena" or id==3 and "artSkinWarriorIron" or id==2 and "artSkinWarriorHorde" or "artSkinWarriorAlliance" end
        if playerClass=="PALADIN" then return id==2 and "artSkinPaladinHorde" or "artSkinPaladinAlliance" end
        if playerClass=="DRUID" then return id==4 and "artSkinDruidSeasons" or id==3 and "artSkinDruidWild" or id==2 and "artSkinDruidMoon" or "artSkinDruidGrove" end
        if playerClass=="PRIEST" then return id==2 and "artSkinPriestShadow" or "artSkinPriestLight" end
        if playerClass=="MAGE" then return id==4 and "artSkinMageAcademy" or id==3 and "artSkinMageFrost" or id==2 and "artSkinMageFire" or "artSkinMageArcane" end
        if playerClass=="SHAMAN" then return id==2 and "artSkinElements" or "artSkinAncestral" end
        if playerClass=="WARLOCK" then return id==2 and "artSkinFel" or "artSkinRitual" end
        return id==2 and "artSkinMetal" or "artSkinHunter"
    end,
    PreviewTexCoord=function()
        if playerClass=="PALADIN" then return 0,1774/2048,0,466/512 end
        if playerClass=="SHAMAN" or playerClass=="MAGE" or playerClass=="PRIEST" or playerClass=="DRUID" then return 0,1774/2048,0,887/1024 end
        if playerClass=="WARLOCK" then return 0,1983/2048,0,793/1024 end
        return 0,1,0,1
    end,
    Path=function(id)
        local file
        if playerClass=="WARRIOR" then file=id==4 and "WarriorArena.tga" or id==3 and "WarriorBlackIron.tga" or id==2 and "WarriorHorde.tga" or "WarriorFrame.tga"
        elseif playerClass=="PALADIN" then file=id==2 and "PaladinConnectedHorde.tga" or "PaladinConnectedAlliance.tga"
        elseif playerClass=="DRUID" then file=id==4 and "DruidSeasons.tga" or id==3 and "DruidWild.tga" or id==2 and "DruidMoon.tga" or "DruidGrove.tga"
        elseif playerClass=="PRIEST" then file=id==2 and "PriestShadow.tga" or "PriestLight.tga"
        elseif playerClass=="MAGE" then file=id==4 and "MageAcademy.tga" or id==3 and "MageFrost.tga" or id==2 and "MageFire.tga" or "MageArcane.tga"
        elseif playerClass=="SHAMAN" then file=id==2 and "ShamanElements.tga" or "ShamanAncestralStraight.tga"
        elseif playerClass=="WARLOCK" then file=id==2 and "WarlockFelObsidian.tga" or "WarlockRitual.tga"
        else file=id==2 and "HunterSimpleMetal.tga" or "HunterFrame.tga" end
        return "Interface\\AddOns\\KerimAnkaUI_ClassArt\\"..file
    end,
}

local function Message(text)
    print("|cff80c070Forever Class Art:|r " .. text)
end

SLASH_FOREVERHUNTERART1 = "/fha"
SlashCmdList.FOREVERHUNTERART = function(input, silent)
    db=KerimAnkaUIBarsAPI.View(KAClassic_ForeverHunterArtCharacterDB,"art")
    if not db then return end
    if not theme then Message("No artwork selected for this class yet."); return end
    local cmd, args = input:match("^%s*(%S*)%s*(.-)%s*$")
    cmd = cmd:lower()
    if cmd == "" or cmd == "options" or cmd == "panel" then
        if OpenPanel then OpenPanel() end
        return
    elseif cmd == "hide" then db.enabled = false
    elseif cmd == "show" then db.enabled = true
    elseif cmd == "reset" then Reset()
    elseif cmd == "lock" then
        if InCombatLockdown() then Message("Use /fha lock outside combat."); return end
        if db.locked then Message("Already locked. Use width, height, x or y to adjust."); return end
        Update()
        if not art:IsShown() or not art:GetLeft() then
            Message("Show your bars and use /fha show before locking."); return
        end
        db.locked = {
            left = art:GetLeft() - db.x, bottom = art:GetBottom() - db.y,
            width = art:GetWidth(), height = art:GetHeight(),
        }
        db.width, db.height = 100, 100
    elseif cmd == "auto" then
        db.locked = nil
        db.width, db.height = 100, 100
        -- Fit to the selected bars also clears offsets left by manual movement.
        db.x, db.y = 0, 0
    elseif cmd == "bars" then
        local bars, seen = {}, {}
        for token in args:gmatch("%S+") do
            local n = tonumber(token)
            if not n or n ~= math.floor(n) or n < 1 or n > KerimAnkaUIBarsAPI.Count() then
                Message("Use bar numbers 1-10: /fha bars 1 3 4")
                return
            end
            if not seen[n] then bars[#bars + 1] = n; seen[n] = true end
        end
        if #bars == 0 then Message("Example: /fha bars 1 3 4"); return end
        db.bars = bars
    elseif cmd == "gap" or cmd == "x" or cmd == "y" or cmd == "alpha"
        or cmd == "width" or cmd == "height" then
        local n = tonumber(args)
        if not n or n ~= n or math.abs(n) == math.huge then
            Message("Enter a number, for example /fha gap 6"); return
        end
        if cmd == "gap" then
            if db.locked then Message("Locked mode: use width and height instead of gap."); return end
            n = math.max(0, math.min(50, n))
        elseif cmd == "width" or cmd == "height" then n = math.max(20, math.min(300, n))
        elseif cmd == "alpha" then n = math.max(0, math.min(1, n))
        else n = math.max(-500, math.min(500, n)) end
        db[cmd] = n
    else
        Message("/fha lock | auto | width 95 | height 100 | x 0 | y 0")
        Message("/fha bars 1 3 4 | gap 4 | alpha 1 | hide | show | reset")
        Message(db.locked and "Fixed artwork size and position." or "Automatically following bars.")
        Message("Current bars: " .. table.concat(db.bars, ", "))
        return
    end
    Update()
    if RefreshPanel then RefreshPanel() end
    if not silent then
        Message(InCombatLockdown() and "Layout will update after combat." or "Updated.")
    end
end

local function SetupPanel()
    if KerimAnkaUIAPI then
        OpenPanel=function() KerimAnkaUIAPI.OpenPage("art") end
        return
    end
    local config = LibStub and LibStub("AceConfig-3.0", true)
    local dialog = LibStub and LibStub("AceConfigDialog-3.0", true)
    local registry = LibStub and LibStub("AceConfigRegistry-3.0", true)
    if not config or not dialog then
        OpenPanel = function() Message("KerimAnka UI ayar paneli bulunamadi.") end
        return
    end
    local app = "ForeverClassArt"
    RefreshPanel = function() if registry then registry:NotifyChange(app) end end
    OpenPanel = function() dialog:Open(app) end
    local function Run(command)
        if InCombatLockdown() then return end
        SlashCmdList.FOREVERHUNTERART(command, true)
    end
    local function Range(key, label, description, order, minimum, maximum, step)
        return {
            type = "range", name = label, desc = description, order = order,
            min = minimum, max = maximum, step = step, width = "full",
            get = function() return db[key] end,
            set = function(_, value) Run(key .. " " .. tostring(value)) end,
            disabled = function()
                return not theme or InCombatLockdown() or (key == "gap" and db.locked ~= nil)
            end,
        }
    end
    local names = {DRUID="Druid",PRIEST="Priest",MAGE="Mage",HUNTER = "Avcı", PALADIN = "Mavi Muhafız", WARRIOR = "Kara Demir", ROGUE = "Zehir Ustası", WARLOCK = "Ruh Ritüeli", SHAMAN = "Ata Totemleri"}
    local options = {
        type = "group", name = "Forever Class Art", args = {
            intro = {type = "description", order = 1, fontSize = "medium", name = function()
                local mode = db.locked and "Sabit boyut ve konum" or "Barları otomatik takip ediyor"
                return (names[playerClass] or "Bu sınıf için tasarım yok") .. " — " .. mode
                    .. "\nAyarlar yalnızca bu karaktere kaydedilir. Değişiklikleri anında görebilirsin."
                    .. (InCombatLockdown() and "\nSavaş bitince ayarlar açılacak." or "")
            end},
            enabled = {type = "toggle", name = "Süslemeyi göster", order = 2,
                disabled = function() return not theme or InCombatLockdown() end,
                get = function() return db.enabled end,
                set = function(_, value) Run(value and "show" or "hide") end},
            lock = {type = "execute", name = "Bu boyutta sabitle", order = 3,
                desc = "Mevcut boyutu ve konumu korur; barları değiştirmek süslemeyi değiştirmez.",
                disabled = function() return not theme or InCombatLockdown() or db.locked ~= nil or not db.enabled end,
                func = function() Run("lock") end},
            auto = {type = "execute", name = "Barlara otomatik uydur", order = 4,
                desc = "Barları yeniden takip eder. Genişlik ve yükseklik yüzde 100 olur.",
                disabled = function() return not theme or InCombatLockdown() end,
                func = function() Run("auto") end},
            width = Range("width", "Genişlik (%)", "Yanları içeri veya dışarı alır; yükseklik değişmez.", 10, 20, 300, 1),
            height = Range("height", "Yükseklik (%)", "Süslemenin yüksekliğini ayarlar.", 11, 20, 300, 1),
            x = Range("x", "Sağ / sol konum", "Pozitif değer sağa, negatif değer sola taşır.", 12, -500, 500, 1),
            y = Range("y", "Yukarı / aşağı konum", "Pozitif değer yukarı, negatif değer aşağı taşır.", 13, -500, 500, 1),
            alpha = Range("alpha", "Görünürlük", "1 tamamen görünür, 0 tamamen şeffaf.", 14, 0, 1, 0.05),
            gap = Range("gap", "Barlarla arasındaki boşluk", "Yalnızca otomatik takipte kullanılır. Sabit modda genişlik ve yüksekliği ayarla.", 15, 0, 50, 1),
            bars = {type = "input", name = "Çevrelenecek barlar", order = 20, width = "full",
                desc = "Bar numaralarını boşlukla ayır. Örnek: 1 3 4. Sabit modda takip kapalıdır.",
                disabled = function() return not theme or InCombatLockdown() or db.locked ~= nil end,
                get = function() return table.concat(db.bars, " ") end,
                validate = function(_, value)
                    local count = 0
                    for token in value:gmatch("%S+") do
                        local n = tonumber(token)
                        if not n or n ~= math.floor(n) or n < 1 or n > KerimAnkaUIBarsAPI.Count() then
                            return "1 ile 10 arasındaki bar numaralarını boşlukla ayır."
                        end
                        count = count + 1
                    end
                    return count > 0 or "En az bir bar seç."
                end,
                set = function(_, value) Run("bars " .. value) end},
            reset = {type = "execute", name = "Bu karakterin ayarlarını sıfırla", order = 30,
                confirm = true, confirmText = "Bu karakterin süsleme boyutu ve konumu sıfırlansın mı?",
                disabled = function() return not theme or InCombatLockdown() end,
                func = function() Run("reset") end},
        },
    }
    if ForeverClassArtMinimap then options.args.minimap = ForeverClassArtMinimap.Options() end
    if ForeverClassArtBarPanel then options.args.backing = ForeverClassArtBarPanel.Options(function() return db end) end
    config:RegisterOptionsTable(app, options)
    dialog:SetDefaultSize(app, 560, 650)
    dialog:AddToBlizOptions(app, "Forever Class Art")

    -- Optional libraries may be supplied by another installed addon.
    local broker = LibStub("LibDataBroker-1.1", true)
    local icon = LibStub("LibDBIcon-1.0", true)
    if broker and icon then
        if type(KAClassic_ForeverClassArtMinimapDB) ~= "table" then
            KAClassic_ForeverClassArtMinimapDB = {minimapPos = 220}
        end
        local launcher = broker:NewDataObject(app, {
            type = "launcher", label = "Forever Class Art",
            icon = "Interface\\Icons\\INV_Shield_05",
            OnClick = function() OpenPanel() end,
            OnTooltipShow = function(tip)
                tip:AddLine("Forever Class Art")
                tip:AddLine("Süsleme ayarlarını açmak için tıkla.", 1, 1, 1)
                tip:AddLine("Simgeyi harita etrafında sürükleyebilirsin.", 0.7, 0.7, 0.7)
            end,
        })
        icon:Register(app, launcher, KAClassic_ForeverClassArtMinimapDB)
    end
end

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if type(KAClassic_ForeverHunterArtCharacterDB) ~= "table" then
            -- Preserve the previous account-wide Hunter layout, without sharing
            -- mutable settings between characters or overwriting its backup.
            if playerClass == "HUNTER" and type(KAClassic_ForeverHunterArtDB) == "table" then
                KAClassic_ForeverHunterArtCharacterDB = Copy(KAClassic_ForeverHunterArtDB)
                KAClassic_ForeverHunterArtCharacterDB.enabled=false
            else
                Reset()
            end
        end
        do
            db = KAClassic_ForeverHunterArtCharacterDB
            if type(db.bars) ~= "table" or #db.bars == 0 then db.bars = {1,3,4,5,6} end
            if db.enabled == nil then db.enabled = false end
            if db.artSkin~=2 then db.artSkin=1 end
            for key, value in pairs({gap=4, x=0, y=0, alpha=1, width=100, height=100}) do
                if type(db[key]) ~= "number" then db[key] = value end
            end
        end
        SetupPanel()
        if theme then ticker = C_Timer.NewTicker(0.25, Update) end
    end
    Update()
    if RefreshPanel then RefreshPanel() end
end)
