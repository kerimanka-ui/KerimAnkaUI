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
-- Use the visible bar rails, inset from the full texture bounds.
function M.AuraRailInset(height,geometry,direction)
    if direction==1 then
        local name=geometry and geometry.name
        return -math.max(0,height*(name and name[2] or .25)-12)
    end
    local power=geometry and geometry.layout and geometry.layout.Power
    local fillBottom=power and power[2]+power[4] or .81
    return math.max(0,height*(1-fillBottom)-12)
end

local function AuraHeight(layout,count)
    if count==0 then return 0 end
    local size=layout.largeSize or layout.size
    local columns=layout.largeSize and math.max(1,math.floor((layout.lineWidth+layout.gap+.001)/(size+layout.gap))) or layout.columns
    return math.ceil(count/columns)*(size+layout.gap)-layout.gap
end

-- Sample layout only. Live variable sizing is delegated to the native aura container.
local function SamplePositions(layout,count)
    local result={}
    local x,y,rowHeight=0,0,0
    local width=layout.lineWidth
    for index=1,count do
        local size=layout.largeSize and index%3==1 and layout.largeSize or layout.size
        if x>0 and x+size>width then
            x=0
            y=y+rowHeight+layout.gap
            rowHeight=0
        end
        result[index]={x=x,y=layout.direction*y,size=size}
        x=x+size+layout.gap
        rowHeight=math.max(rowHeight,size)
    end
    return result,y+rowHeight
end

function M.AuraBelowFor(settings,unit,kind)
    if unit~="pet" and settings[unit.."AuraSplit"] then
        local buffBelow=not settings[unit.."AuraSwapSides"]
        if kind=="Buff" then return buffBelow end
        return not buffBelow
    end
    return settings[unit.."AuraBelow"]
end

function M.AuraLayout(settings,unit,buffs,debuffs,samples)
    local columns=math.floor(settings[unit.."AuraColumns"])
    local maximum=math.floor(settings[unit.."AuraMax"])
    if settings[unit.."AuraSingleRow"] then columns=maximum end
    local gap=settings[unit.."AuraGap"]
    local priority=unit~="pet" and settings[unit.."AuraDebuffPriority"]
    local function group(kind)
        local below=M.AuraBelowFor(settings,unit,kind)
        local direction=below and -1 or 1
        local size=settings[unit.."AuraSize"]
        if priority and kind=="Debuff" then size=math.floor(size*1.25+.5) end
        local x=settings[unit..kind.."X"] or settings[unit.."AuraX"]
        local y=settings[unit..kind.."Y"] or settings[unit.."AuraY"]
        if unit~="pet" then y=direction*math.max(0,direction*y) end
        local largeSize=unit~="pet" and settings.auraCooldown and size*21/17 or nil
        local lineWidth=columns*(size+gap)-gap+.001
        if largeSize then lineWidth=math.max(largeSize,lineWidth) end
        if largeSize and settings[unit.."AuraSingleRow"] then
            lineWidth=maximum*(largeSize+gap)-gap+.001
        end
        return {point=below and "TOPLEFT" or "BOTTOMLEFT",edge=below and "BOTTOMLEFT" or "TOPLEFT",
            direction=direction,columns=columns,maximum=maximum,size=size,largeSize=largeSize,
            lineWidth=lineWidth,gap=gap,x=x,y=y}
    end
    local layouts={Buff=group("Buff"),Debuff=group("Debuff")}
    if samples then
        for kind,layout in pairs(layouts) do
            layout.samples,layout.sampleHeight=SamplePositions(layout,math.min(layout.maximum,samples[kind]))
        end
    end
    if unit~="pet" and not settings[unit.."AuraSplit"] and buffs and debuffs then
        local direction=layouts.Buff.direction
        local firstKind=priority and direction<0 and "Debuff" or "Buff"
        local lastKind=firstKind=="Buff" and "Debuff" or "Buff"
        local first,last=layouts[firstKind],layouts[lastKind]
        first.y=direction*math.min(direction*first.y,direction*last.y)
        last.y=first.y
        last.after=firstKind
        if samples and #first.samples>0 then
            last.y=last.y+direction*(first.sampleHeight+gap)
        end
    end
    return layouts
end

function M.AuraOffset(layout,index)
    if layout.samples then
        local sample=layout.samples[index]
        return sample.x,sample.y,sample.size
    end
    local step=layout.size+layout.gap
    return ((index-1)%layout.columns)*step,layout.direction*math.floor((index-1)/layout.columns)*step,layout.size
end

function M.Defaults(settings)
    local defaults={targetCastEnabled=false,castWidth=240,castHeight=18,castX=0,castY=-8,castFontSize=12,castIcon=true,auraCooldown=true,auraStacks=true}
    for _,unit in ipairs({"player","target","pet"}) do
        defaults[unit.."Buffs"]=false; defaults[unit.."Debuffs"]=false
        defaults[unit.."AuraSize"]=24; defaults[unit.."AuraGap"]=4
        defaults[unit.."AuraColumns"]=8; defaults[unit.."AuraMax"]=16
        if unit~="pet" then
            defaults[unit.."AuraDebuffPriority"]=false
            defaults[unit.."AuraSplit"]=false; defaults[unit.."AuraSwapSides"]=false
        end
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
local function NativeFlow(c,h,l)
    local factor=l.size/24
    c:SetScale(factor)
    c:ClearAllPoints()
    c:SetPoint(l.point,h,l.point,0,0)
    c:SetFlowLayoutAnchorPoint(l.point)
    local flow=AnchorUtil and AnchorUtil.FlowDirection
    c:SetFlowLayoutGrowthDirection(flow and flow.Right or 1,
        l.direction<0 and (flow and flow.Down or -1) or (flow and flow.Up or 1))
    -- Midpoint between the widths of N and N+1 icons avoids rounding at the wrap threshold.
    c:SetFlowLayoutMaximumLineSize((l.columns+.5)*(24+l.gap/factor)-l.gap/factor)
    return {elementSpacing=l.gap/factor,lineSpacing=l.gap/factor}
end
local function NativeAuras(parent,unit,filter,layout)
    local c
    local ok=pcall(function()
        c=CreateFrame("AuraContainer",nil,parent,"CustomAuraContainerTemplate")
        c:SetEnabled(false)
        c:SetSize(1,1)
        c:AddAuraGroup("Auras",filter,{maxFrameCount=layout.maximum,
            layout=NativeFlow(c,parent,layout),initializeFrame=AuraButton})
        c:SetUnit(unit)
    end)
    if ok then return c end
    if c then c:Hide(); if c.SetEnabled then pcall(c.SetEnabled,c,false) end end
end
local function ConfigureSourceLayout(c,anchor,filter,layout)
    c:ClearAllPoints()
    c:SetPoint(layout.point,anchor,layout.point,0,0)
    c:SetFlowLayoutMirroredVertically(layout.direction>0)
    c:SetSmallAuraSize(layout.size)
    c:SetLargeAuraSize(layout.largeSize)
    c:SetFlowLayoutSpacing(layout.gap,layout.gap)
    c:SetFlowLayoutMaximumLineSize(layout.lineWidth)
    c:SetMaxBuffs(filter=="HELPFUL" and layout.maximum or 0)
    c:SetMaxDebuffs(filter=="HARMFUL" and layout.maximum or 0)
    c:SetShowAuraCount(db.auraStacks)
end

local function SourceAuras(anchor,unit,filter,layout)
    local c
    local ok=pcall(function()
        c=CreateFrame("AuraContainer",nil,anchor,"TargetFrameAuraContainerTemplate")
        c:SetEnabled(false)
        ConfigureSourceLayout(c,anchor,filter,layout)
        c:SetUnit(unit)
    end)
    if ok then return c end
    if c then pcall(c.Hide,c); pcall(c.SetEnabled,c,false) end
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
    for _,b in ipairs(holder.buttons) do b:Hide(); b.index=nil end
    holder.anchor:SetHeight(0)
    if not get then return end
    local layout=holder.layout
    local shown=0
    for i=1,layout.maximum do
        local ok,a=pcall(get,unit,i,filter)
        if not ok or secret(a) or a==nil then break end
        if type(a)~="table" then break end
        local b=holder.buttons[i]
        if not b then b=ManualButton(holder); holder.buttons[i]=b end
        b.unit,b.index,b.filter=unit,i,filter
        b:SetSize(layout.size,layout.size); b:ClearAllPoints()
        local x,y=M.AuraOffset(layout,i)
        b:SetPoint(layout.point,holder.anchor,layout.point,x,y)
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
        shown=i
    end
    holder.anchor:SetHeight(AuraHeight(layout,shown))
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
    if not h.native then h.anchor:SetHeight(0) end
    pcall(h.Hide,h)
end
function M.Clear(unit)
    for _,h in pairs(holders[unit] or {}) do ClearHolder(h) end
end
local function NativeLayout(h,layout,unit,filter)
    local useSource=layout.largeSize~=nil
    if not h.native or h.usingSource~=useSource then
        if h.usingSource~=nil then ClearHolder(h) end
        if h.native then h.native:Hide() end
        h.usingSource=useSource
        h.layoutSignature=nil
        if useSource and not h.sourceAttempted then
            h.sourceAttempted=true
            h.source=SourceAuras(h.anchor,unit,filter,layout)
        end
        if useSource and h.source then
            h.native=h.source
        else
            if not h.customAttempted then
                h.customAttempted=true
                h.custom=NativeAuras(h.anchor,unit,filter,layout)
            end
            h.native=h.custom
        end
        if h.native then h.native:Show() end
    end
    local c=h.native
    if not c then return end
    local signature=table.concat({layout.size,layout.gap,layout.columns,layout.maximum,layout.direction,layout.lineWidth,tostring(db.auraStacks)},":")
    if h.layoutSignature==signature then return end
    if c==h.source then
        ConfigureSourceLayout(c,h.anchor,filter,layout)
    else
        local options=NativeFlow(c,h.anchor,layout)
        c:SetAuraGroupMaxFrameCount("Auras",layout.maximum)
        c:SetAuraGroupLayout("Auras",options)
    end
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
            local layouts=M.AuraLayout(db,unit,db[unit.."Buffs"],db[unit.."Debuffs"])
            for index,filter in ipairs({"HELPFUL","HARMFUL"}) do
                local key=index==1 and "Buffs" or "Debuffs"
                local layout=layouts[index==1 and "Buff" or "Debuff"]
                local h=holders[unit][key]
                if not h and db[unit..key] then
                    h=CreateFrame("Frame",nil,parent); h:SetFrameLevel(parent:GetFrameLevel()+10); h:SetSize(1,1)
                    -- Keep the editor handle on public geometry. The display anchor may
                    -- inherit a secret-sized native container's position.
                    h.anchor=CreateFrame("Frame",nil,h,"DisableUntrustedLayoutScriptsTemplate")
                    h.anchor:SetSize(1,1)
                    h.buttons={}
                    holders[unit][key]=h
                end
                if h then
                    h.layout=layout
                    NativeLayout(h,layout,unit,filter)
                end
            end
            local group=holders[unit]
            for _,h in pairs(group) do
                local layout=h.layout
                local inset=unit~="pet" and M.AuraRailInset(parent:GetHeight(),parent.geometry,layout.direction) or 0
                h:ClearAllPoints()
                h:SetPoint(layout.point,parent,layout.edge,layout.x,layout.y+inset)
                h.anchor:ClearAllPoints()
            end
            for _,h in pairs(group) do
                local layout=h.layout
                if layout.after then
                    local first=group[layout.after.."s"]
                    -- Native anchor targets forbid untrusted layout scripts. The display
                    -- anchor explicitly opts in and never reads the resulting geometry.
                    local anchored=pcall(h.anchor.SetPoint,h.anchor,layout.point,first.native or first.anchor,
                        layout.edge,layout.x-first.layout.x,layout.direction*layout.gap)
                    if not anchored then
                        -- Keep both groups visible even if a client rejects native anchor chaining.
                        local reserve=AuraHeight(first.layout,first.layout.maximum)+layout.gap
                        h.anchor:SetPoint(layout.point,h,layout.point,0,layout.direction*reserve)
                    end
                else
                    h.anchor:SetPoint(layout.point,h,layout.point,0,0)
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
                    if h.native==h.source then
                        pcall(h.native.SetPlayerIsTarget,h.native,unit=="player" or PublicBool(UnitIsUnit,"player",unit)==true)
                        pcall(h.native.SetTargetIsFriendly,h.native,unit=="player" or PublicBool(UnitIsFriend,"player",unit)==true)
                    end
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

function M.GetLayoutElements()return holders,cast end
