-- Optional aura/cast displays. No combat data is inferred or reconstructed.
ForeverUnitsCombatWidgets = {}
local M=ForeverUnitsCombatWidgets
local db,frames
local holders={}
local function secret(v) return issecretvalue and issecretvalue(v) or false end
local function label(parent,size)
    local t=parent:CreateFontString(nil,"OVERLAY")
    t:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",size,"OUTLINE")
    return t
end
function M.Defaults(settings)
    local defaults={targetCastEnabled=false,castWidth=240,castHeight=18,castX=0,castY=-8,castFontSize=12,castIcon=true,auraCooldown=true,auraStacks=true}
    for _,unit in ipairs({"player","target","pet"}) do
        defaults[unit.."Buffs"]=false; defaults[unit.."Debuffs"]=false
        defaults[unit.."AuraSize"]=24; defaults[unit.."AuraGap"]=4
        defaults[unit.."AuraColumns"]=8; defaults[unit.."AuraMax"]=16
        defaults[unit.."AuraX"]=0; defaults[unit.."AuraY"]=10
    end
    for k,v in pairs(defaults) do if settings[k]==nil then settings[k]=v end end
    for _,unit in ipairs({"player","target","pet"}) do
        if settings[unit.."AuraBelow"]==nil then settings[unit.."AuraBelow"]=false end
        if settings[unit.."AuraSingleRow"]==nil then settings[unit.."AuraSingleRow"]=false end
        local rows=math.ceil(settings[unit.."AuraMax"]/settings[unit.."AuraColumns"])
        for _,kind in ipairs({"Buff","Debuff"}) do
            if settings[unit..kind.."X"]==nil then settings[unit..kind.."X"]=settings[unit.."AuraX"] end
            if settings[unit..kind.."Y"]==nil then
                settings[unit..kind.."Y"]=settings[unit.."AuraY"]+(kind=="Debuff" and settings[unit.."Buffs"] and rows*(settings[unit.."AuraSize"]+settings[unit.."AuraGap"]) or 0)
            end
        end
    end
end
local function AuraButton(button)
    button:SetSize(24,24)
    local icon=button:CreateTexture(nil,"BORDER"); icon:SetAllPoints(); icon:SetTexCoord(.07,.93,.07,.93)
    button:SetIcon(icon)
    if button.SetTooltipAnchorPoint then button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT") end
    local textParent=button
    if db.auraCooldown and button.SetDurationCooldown then
        local cd=CreateFrame("Cooldown",nil,button,"CooldownFrameTemplate"); cd:SetAllPoints()
    cd:SetHideCountdownNumbers(true); cd.noCooldownCount=true
        button:SetDurationCooldown(cd)
        textParent=CreateFrame("Frame",nil,button); textParent:SetAllPoints()
        textParent:SetFrameLevel(cd:GetFrameLevel()+1)
    end
    if db.auraStacks and button.SetApplicationCount then
        local t=label(textParent,11); t:SetPoint("BOTTOMRIGHT",-1,1)
        button:SetApplicationCount(t)
    end
end
local function NativeAuras(parent,unit,filter)
    local c
    local ok=pcall(function()
        c=CreateFrame("AuraContainer",nil,parent,"CustomAuraContainerTemplate")
        c:SetEnabled(false)
        c:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT"); c:SetSize(1,1)
        c:SetFlowLayoutAnchorPoint("BOTTOMLEFT")
        c:SetFlowLayoutGrowthDirection(1,1)
        local factor=db[unit.."AuraSize"]/24
        c:SetFlowLayoutMaximumLineSize(db[unit.."AuraColumns"]*(24+db[unit.."AuraGap"]/factor)-db[unit.."AuraGap"]/factor)
        local maximum=db[unit.."AuraSingleRow"] and math.min(db[unit.."AuraMax"],db[unit.."AuraColumns"]) or db[unit.."AuraMax"]
        c:AddAuraGroup("Auras",filter,{maxFrameCount=maximum,
            layout={elementSpacing=db[unit.."AuraGap"]/factor,lineSpacing=db[unit.."AuraGap"]/factor},initializeFrame=AuraButton})
        c:SetUnit(unit)
    end)
    if ok then return c end
    if c then c:Hide(); if c.SetEnabled then pcall(c.SetEnabled,c,false) end end
end
local function ManualButton(parent)
    local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
    b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    b:SetBackdropColor(0,0,0,1); b:SetBackdropBorderColor(.5,.42,.25,1)
    b.icon=b:CreateTexture(nil,"ARTWORK"); b.icon:SetPoint("TOPLEFT",1,-1); b.icon:SetPoint("BOTTOMRIGHT",-1,1); b.icon:SetTexCoord(.07,.93,.07,.93)
    b.cd=CreateFrame("Cooldown",nil,b,"CooldownFrameTemplate"); b.cd:SetAllPoints()
    b.cd:SetHideCountdownNumbers(true); b.cd.noCooldownCount=true
    local carrier=CreateFrame("Frame",nil,b); carrier:SetAllPoints(); carrier:SetFrameLevel(b.cd:GetFrameLevel()+1)
    b.count=label(carrier,11); b.count:SetPoint("BOTTOMRIGHT",-1,1)
    b:SetScript("OnEnter",function(self)
        if not self.index then return end
        GameTooltip:SetOwner(self,"ANCHOR_BOTTOMLEFT")
        pcall(GameTooltip.SetUnitAura,GameTooltip,self.unit,self.index,self.filter); GameTooltip:Show()
    end)
    b:SetScript("OnLeave",function() GameTooltip:Hide() end)
    return b
end
local function Scan(holder,unit,filter)
    local get=C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    for i,b in ipairs(holder.buttons) do b:Hide(); b.index=nil end
    if not get then return end
    local size=db[unit.."AuraSize"]
    local gap=db[unit.."AuraGap"]
    local columns=db[unit.."AuraColumns"]
    local maximum=db[unit.."AuraSingleRow"] and math.min(db[unit.."AuraMax"],columns) or db[unit.."AuraMax"]
    for i=1,maximum do
        local ok,a=pcall(get,unit,i,filter)
        if not ok or secret(a) or a==nil then break end
        if type(a)~="table" then break end
        local b=holder.buttons[i]
        if not b then b=ManualButton(holder); holder.buttons[i]=b end
        b.unit,b.index,b.filter=unit,i,filter
        b:SetSize(size,size); b:ClearAllPoints()
        local below=db[unit.."AuraBelow"]
        b:SetPoint(below and "TOPLEFT" or "BOTTOMLEFT",((i-1)%columns)*(size+gap),(below and -1 or 1)*math.floor((i-1)/columns)*(size+gap))
        pcall(b.icon.SetTexture,b.icon,a.icon)
        b.count:SetText("")
        if db.auraStacks then
            if secret(a.applications) then pcall(b.count.SetFormattedText,b.count,"%d",a.applications)
            elseif type(a.applications)=="number" and a.applications>1 then b.count:SetText(a.applications) end
        end
        b.cd:Hide()
        if db.auraCooldown then
            local durationGetter=C_UnitAuras.GetAuraDuration
            if durationGetter and b.cd.SetCooldownFromDurationObject then
                local yes,duration=pcall(durationGetter,unit,a.auraInstanceID)
                if yes and not secret(duration) and duration then
                    if pcall(b.cd.SetCooldownFromDurationObject,b.cd,duration) then b.cd:Show() end
                end
            elseif not secret(a.duration) and not secret(a.expirationTime) and type(a.duration)=="number" and a.duration>0 and type(a.expirationTime)=="number" then
                b.cd:SetCooldown(a.expirationTime-a.duration,a.duration); b.cd:Show()
            end
        end
        b:SetAlpha(1); b:Show()
    end
end
local function PublicBool(fn,...)
    if not fn then return nil end
    local ok,value=pcall(fn,...)
    if ok and not secret(value) then return value and true or false end
end
local function Displayable(unit)
    if not db.enabled or PublicBool(UnitExists,unit)==false then return false end
    if PublicBool(UnitIsDeadOrGhost,unit)==true then return false end
    if unit=="target" and PublicBool(UnitIsVisible,unit)==false then return false end
    if unit=="pet" and not db.showPet then return false end
    return true
end
local function ClearHolder(h)
    if h.native then pcall(h.native.SetEnabled,h.native,false); h.nativeEnabled=false end
    for _,b in ipairs(h.buttons) do
        b.index=nil; b.icon:SetTexture(nil); b.count:SetText("")
        b:SetAlpha(0)
        if b.cd.Clear then b.cd:Clear() end
        b:Hide()
    end
    pcall(h.Hide,h)
end
function M.Clear(unit)
    for _,h in pairs(holders[unit] or {}) do ClearHolder(h) end
end
local function NativeLayout(h,unit)
    local c=h.native
    if not c then return end
    local size,gap,columns,maximum=db[unit.."AuraSize"],db[unit.."AuraGap"],db[unit.."AuraColumns"],db[unit.."AuraMax"]
    if db[unit.."AuraSingleRow"] then maximum=math.min(maximum,columns) end
    local below=db[unit.."AuraBelow"]
    local signature=table.concat({size,gap,columns,maximum,below and 1 or 0},":")
    if h.layoutSignature==signature then return end
    local factor=size/24
    c:SetScale(factor)
    c:SetFlowLayoutAnchorPoint(below and "TOPLEFT" or "BOTTOMLEFT")
    c:SetFlowLayoutGrowthDirection(1,below and -1 or 1)
    c:SetFlowLayoutMaximumLineSize(columns*(24+gap/factor)-gap/factor)
    if c.SetAuraGroupMaxFrameCount then pcall(c.SetAuraGroupMaxFrameCount,c,"Auras",maximum) end
    if c.SetAuraGroupLayout then pcall(c.SetAuraGroupLayout,c,"Auras",{elementSpacing=gap/factor,lineSpacing=gap/factor}) end
    if c.UpdateAllAuras then c:UpdateAllAuras() end
    h.layoutSignature=signature
end
local cast
local function CreateCast()
    cast=CreateFrame("Frame",nil,frames.target,"BackdropTemplate")
    cast:SetFrameLevel(frames.target:GetFrameLevel()+8)
    cast:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    cast:SetBackdropColor(.025,.025,.02,1); cast:SetBackdropBorderColor(.48,.39,.21,1)
    cast.bar=CreateFrame("StatusBar",nil,cast); cast.bar:SetPoint("TOPLEFT",1,-1); cast.bar:SetPoint("BOTTOMRIGHT",-1,1)
    cast.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8"); cast.bar:SetStatusBarColor(.65,.48,.20,1)
    cast.icon=cast:CreateTexture(nil,"ARTWORK"); cast.icon:SetPoint("RIGHT",cast,"LEFT",-3,0); cast.icon:SetTexCoord(.07,.93,.07,.93)
    cast.text=label(cast.bar,12); cast.text:SetPoint("LEFT",5,0); cast.text:SetJustifyH("LEFT"); cast.text:SetWordWrap(false)
    cast.shield=cast.bar:CreateTexture(nil,"OVERLAY"); cast.shield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield")
    cast.shield:SetPoint("RIGHT",-2,0); cast.shield:SetSize(18,20)
    cast:Hide()
end
local function CastUpdate()
    if not cast then return end
    if not db.enabled or not db.targetCastEnabled or not UnitExists("target") then cast:Hide(); cast.bar:SetScript("OnUpdate",nil); return end
    local ok,name,display,icon,startMS,endMS,_,_,uninterruptible=pcall(UnitCastingInfo,"target")
    local channel=false
    if not ok or (not secret(name) and name==nil) then
        ok,name,display,icon,startMS,endMS,_,uninterruptible=pcall(UnitChannelInfo,"target")
        channel=true
    end
    if not ok or (not secret(name) and name==nil) then cast:Hide(); cast.bar:SetScript("OnUpdate",nil); return end
    cast.bar:SetScript("OnUpdate",nil)
    local getter=channel and UnitChannelDuration or UnitCastingDuration
    local timed=false
    if getter and cast.bar.SetTimerDuration and Enum and Enum.StatusBarTimerDirection then
        local yes,duration=pcall(getter,"target")
        if yes and not secret(duration) and duration then
            local direction=channel and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime
            timed=pcall(cast.bar.SetTimerDuration,cast.bar,duration,Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.Immediate or 0,direction)
        end
    end
    if not timed and not secret(startMS) and not secret(endMS) and type(startMS)=="number" and type(endMS)=="number" and endMS>startMS then
        local start,finish=startMS/1000,endMS/1000
        cast.bar:SetMinMaxValues(0,finish-start)
        cast.bar:SetScript("OnUpdate",function(self)
            local now=GetTime()
            if now>=finish then cast:Hide(); self:SetScript("OnUpdate",nil); return end
            self:SetValue(channel and finish-now or now-start)
        end)
        timed=true
    end
    if not timed then cast:Hide(); return end
    pcall(cast.text.SetText,cast.text,name)
    pcall(cast.icon.SetTexture,cast.icon,icon)
    cast.icon:SetShown(db.castIcon)
    cast.shield:SetAlpha(0)
    if cast.shield.SetAlphaFromBoolean then pcall(cast.shield.SetAlphaFromBoolean,cast.shield,uninterruptible,1,0)
    else cast.shield:SetAlpha(not secret(uninterruptible) and uninterruptible and 1 or 0) end
    cast:Show()
end
function M.Apply(settings,unitFrames)
    db,frames=settings,unitFrames
    for _,unit in ipairs({"player","target","pet"}) do
        local parent=frames[unit]
        if parent then
            holders[unit]=holders[unit] or {}
            for index,filter in ipairs({"HELPFUL","HARMFUL"}) do
                local key=index==1 and "Buffs" or "Debuffs"
                local h=holders[unit][key]
                if not h and db[unit..key] then
                    h=CreateFrame("Frame",nil,parent); h:SetFrameLevel(parent:GetFrameLevel()+10); h:SetSize(1,1)
                    h.native=NativeAuras(h,unit,filter); h.buttons={}
                    holders[unit][key]=h
                end
                if h then
                    h:ClearAllPoints()
                    local kind=index==1 and "Buff" or "Debuff"
                    local below=db[unit.."AuraBelow"]
                    h:SetPoint(below and "TOPLEFT" or "BOTTOMLEFT",parent,below and "BOTTOMLEFT" or "TOPLEFT",db[unit..kind.."X"],db[unit..kind.."Y"])
                    if h.native then NativeLayout(h,unit) end
                end
            end
        end
    end
    if not cast and frames.target then CreateCast() end
    if cast then
        cast:SetSize(db.castWidth,db.castHeight); cast:ClearAllPoints(); cast:SetPoint("TOP",frames.target,"BOTTOM",db.castX,db.castY)
        cast.icon:SetSize(db.castHeight,db.castHeight); cast.text:SetWidth(db.castWidth-30)
        cast.text:SetFont(STANDARD_TEXT_FONT,db.castFontSize,"OUTLINE")
    end
    M.Refresh(true)
end
function M.Refresh(force,changedUnit,refreshCast)
    if not db then return end
    for unit,groups in pairs(holders) do
        if not changedUnit or unit==changedUnit then
        for key,h in pairs(groups) do
            local active=db[unit..key] and Displayable(unit)
            if not active then ClearHolder(h)
            else
                pcall(h.Show,h)
                if h.native then
                    local resumed=not h.nativeEnabled
                    if resumed then
                        local unitOK=pcall(h.native.SetUnit,h.native,unit)
                        local enableOK=pcall(h.native.SetEnabled,h.native,true)
                        h.nativeEnabled=unitOK and enableOK
                    end
                    if (force or resumed) and h.native.UpdateAllAuras then pcall(h.native.UpdateAllAuras,h.native) end
                else Scan(h,unit,key=="Buffs" and "HELPFUL" or "HARMFUL") end
            end
        end
        end
    end
    if refreshCast~=false then CastUpdate() end
end
local events=CreateFrame("Frame")
for _,event in ipairs({"UNIT_AURA","PLAYER_TARGET_CHANGED","UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_DELAYED","UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_UPDATE","UNIT_SPELLCAST_CHANNEL_STOP","UNIT_SPELLCAST_INTERRUPTIBLE","UNIT_SPELLCAST_NOT_INTERRUPTIBLE"}) do pcall(events.RegisterEvent,events,event) end
for _,event in ipairs({"UNIT_HEALTH","UNIT_FLAGS","UNIT_CONNECTION","UNIT_PET","PLAYER_ENTERING_WORLD","PLAYER_REGEN_ENABLED"}) do pcall(events.RegisterEvent,events,event) end
events:SetScript("OnEvent",function(_,event,unit)
    if event:sub(1,5)=="UNIT_" and unit and unit~="player" and unit~="target" and unit~="pet" then return end
    if db then
        if event=="PLAYER_TARGET_CHANGED" then M.Clear("target") end
        if event=="UNIT_PET" then M.Clear("pet") end
        local castEvent=event:match("^UNIT_SPELLCAST_")~=nil
        -- Native aura containers receive their own spellcast-independent events.
        -- Only cast/target lifecycle events restart the cast timer.
        if castEvent then if not unit or unit=="target" then CastUpdate() end;return end
        local changed=event=="UNIT_PET" and "pet" or unit
        local refreshCast=event=="PLAYER_TARGET_CHANGED" or event=="PLAYER_ENTERING_WORLD" or (event=="UNIT_CONNECTION" and unit=="target")
        M.Refresh(event=="PLAYER_TARGET_CHANGED" or event=="PLAYER_ENTERING_WORLD" or event=="UNIT_AURA" or event=="PLAYER_REGEN_ENABLED" or event=="UNIT_PET" or event=="UNIT_CONNECTION",changed,refreshCast)
    end
end)
