local _, K = ...
local panelDefaults=K.panelDefaults
local font = "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-R.ttf"
local boldFont = "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-B.ttf"
local gold, white, muted = {0.73,0.62,0.41}, {0.9,0.91,0.88}, {0.59,0.63,0.61}
local pool, used, labels, labelUsed = {}, 0, {}, 0
local nav, tabs = {}, {}
local languageButton, languageMenu, languageDismiss
local UpdateLanguageLabel
local page, subtitle, heading, footer
local selection, section = "home", "overview"
local function Backdrop(frame, r,g,b, edge)
    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
    frame:SetBackdropColor(r,g,b,1)
    frame:SetBackdropBorderColor(unpack(edge or {0.23,0.25,0.22}))
end
local function CardGlow(frame,w,h,shown)
    if not shown then
        if frame.glowParts then for _,t in ipairs(frame.glowParts) do t:Hide() end end
        return
    end
    if not frame.glowParts then frame.glowParts={} end
    local uv={0,24/64,40/64,1}
    local radius=math.max(4,math.min(20,tonumber(KerimAnkaUIDB.glowRadius) or 10))
    local strength=math.max(0,math.min(1,tonumber(KerimAnkaUIDB.glowStrength) or .45))
    local color=KerimAnkaUIDB.glowColor or {0,0,0}
    local xs={-radius,radius,w-radius,w+radius}
    local ys={radius,-radius,-h+radius,-h-radius}
    for row=1,3 do
        for col=1,3 do
            local i=(row-1)*3+col
            local t=frame.glowParts[i]
            if not t then
                t=frame:CreateTexture(nil,"BACKGROUND",nil,-4)
                t:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\CardGlow.tga","CLAMP","CLAMP","LINEAR")
                if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
                if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
                frame.glowParts[i]=t
            end
            t:ClearAllPoints(); t:SetPoint("TOPLEFT",xs[col],ys[row])
            t:SetSize(xs[col+1]-xs[col],ys[row]-ys[row+1])
            t:SetTexCoord(uv[col],uv[col+1],uv[row],uv[row+1])
            t:SetVertexColor(color[1],color[2],color[3],strength); t:SetShown(i~=5)
        end
    end
end
-- Antialiased nine-slice surfaces avoid seams between overlapping circle masks.
local function Rounded(frame, r,g,b, edge, radius, shadow)
    frame:SetBackdrop(nil)
    if not frame.roundedLayers then frame.roundedLayers={} end
    local w,h=frame:GetWidth(),frame:GetHeight()
    local rad=math.min(radius or 7,w/2-1,h/2-1)
    local uv={0,0.25,0.75,1}
    local xs={0,rad,w-rad,w}
    local ys={0,-rad,-h+rad,-h}
    for layer=1,2 do
        local parts=frame.roundedLayers[layer]
        if not parts then parts={}; frame.roundedLayers[layer]=parts end
        local color=layer==1 and {r,g,b,1} or (edge or {0.33,0.36,0.32,1})
        for row=1,3 do
            for col=1,3 do
                local i=(row-1)*3+col
                local t=parts[i]
                if not t then
                    t=frame:CreateTexture(nil,"BACKGROUND",nil,layer-3)
                    local asset=layer==1 and "RoundedFill.tga" or "RoundedBorder.tga"
                    t:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\"..asset,"CLAMP","CLAMP","LINEAR")
                    if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
                    if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
                    parts[i]=t
                end
                t:ClearAllPoints(); t:SetPoint("TOPLEFT",xs[col],ys[row])
                t:SetSize(xs[col+1]-xs[col],ys[row]-ys[row+1])
                t:SetTexCoord(uv[col],uv[col+1],uv[row],uv[row+1])
                t:SetVertexColor(unpack(color)); t:SetShown(layer==1 or i~=5)
            end
        end
    end
    CardGlow(frame,w,h,shadow and KerimAnkaUIDB.cardGlow ~= false)
end
local function HideRounded(frame)
    CardGlow(frame,0,0,false)
    if frame.roundedLayers then
        for _,parts in pairs(frame.roundedLayers) do for _,t in ipairs(parts) do t:Hide() end end
    end
end
local function Text(parent, value, x,y,width,size,color)
    labelUsed = labelUsed + 1
    local text = labels[labelUsed]
    if not text then text = page:CreateFontString(nil,"OVERLAY"); labels[labelUsed] = text end
    text:SetParent(parent); text:ClearAllPoints(); text:SetPoint("TOPLEFT",x,y)
    text:SetWidth(width); K.ApplyTextFont(text,size or 13,false,""); text:SetTextColor(unpack(color or white))
    text:SetJustifyH("LEFT"); text:SetJustifyV("TOP"); text:SetWordWrap(true)
    text:SetText(value); text:Show()
    return text
end
local tooltip
function K.HideTooltip()
    if tooltip then tooltip:Hide() end
end
function K.ShowTooltip(owner, title, body)
    if not tooltip then
        tooltip=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
        tooltip:SetFrameStrata("TOOLTIP"); tooltip:SetClampedToScreen(true); tooltip:EnableMouse(false)
        Backdrop(tooltip,0.13,0.14,0.13,gold)
        tooltip.title=tooltip:CreateFontString(nil,"OVERLAY")
        K.ApplyTextFont(tooltip.title,15,true,""); tooltip.title:SetPoint("TOPLEFT",14,-12)
        tooltip.title:SetWidth(310); tooltip.title:SetJustifyH("LEFT"); tooltip.title:SetTextColor(unpack(gold))
        tooltip.body=tooltip:CreateFontString(nil,"OVERLAY")
        K.ApplyTextFont(tooltip.body,14,false,""); tooltip.body:SetWidth(310); tooltip.body:SetJustifyH("LEFT")
        tooltip.body:SetSpacing(3); tooltip.body:SetTextColor(unpack(white))
    end
    tooltip:ClearAllPoints(); tooltip:SetPoint("TOPLEFT",owner,"TOPRIGHT",8,0)
    tooltip.title:SetText(title); tooltip.body:SetText(body)
    local titleHeight=tooltip.title:GetStringHeight()
    tooltip.body:ClearAllPoints(); tooltip.body:SetPoint("TOPLEFT",14,-18-titleHeight)
    tooltip:SetSize(338,30+titleHeight+tooltip.body:GetStringHeight()); tooltip:Show()
end
local function Tip(widget, title, body)
    widget:SetScript("OnEnter", function(self)
        K.ShowTooltip(self,K.L(title),K.L(body))
    end)
    widget:SetScript("OnLeave",K.HideTooltip)
end
local function ControlGlyph(button,value)
    if button.arrowParts then for _,part in ipairs(button.arrowParts) do part:Hide() end end
    local suffix=value:sub(-3)
    if suffix=="▾" or suffix=="▴" then
        button.label:SetText(value:sub(1,-4))
        button.arrowParts=button.arrowParts or {}
        for i=1,5 do
            local part=button.arrowParts[i]
            if not part then part=button:CreateTexture(nil,"OVERLAY",nil,1);button.arrowParts[i]=part end
            part:SetColorTexture(.73,.76,.70,1)
            part:ClearAllPoints();part:SetSize(11-i*2,1)
            part:SetPoint("CENTER",button,"RIGHT",-15,suffix=="▾" and (3-i) or (i-3))
            part:Show()
        end
    end
    if button.icon then button.icon:Hide() end
    button:SetScript("OnMouseDown",nil); button:SetScript("OnMouseUp",nil)
    local names={["+"]="Plus",["−"]="Minus",["×"]="Close"}
    local name=names[value]
    if name then
        if not button.icon then button.icon=button:CreateTexture(nil,"OVERLAY",nil,1) end
        button.label:SetText("")
        button.icon:SetSize(18,18); button.icon:ClearAllPoints(); button.icon:SetPoint("CENTER")
        button.icon:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\"..name..".tga","CLAMP","CLAMP","LINEAR")
        button.icon:SetVertexColor(0.9,0.91,0.87,1); button.icon:Show()
    elseif value=="?" then K.ApplyTextFont(button.label,14,true,"") end
    if name or value=="?" then
        button:SetScript("OnMouseDown",function(self)
            Rounded(self,0.10,0.12,0.105,{0.53,0.60,0.45,1},5,false)
            if self.icon then self.icon:ClearAllPoints(); self.icon:SetPoint("CENTER",0,-1) end
        end)
        button:SetScript("OnMouseUp",function(self)
            Rounded(self,0.15,0.165,0.15,nil,5,false)
            if self.icon then self.icon:ClearAllPoints(); self.icon:SetPoint("CENTER") end
        end)
    end
end
local function Box(parent,x,y,w,h,button)
    used = used + 1
    local index = used .. (button and "b" or "f")
    local frame = pool[index]
    if not frame then
        frame = CreateFrame(button and "Button" or "Frame",nil,page,"BackdropTemplate")
        if button then
            frame.label = frame:CreateFontString(nil,"OVERLAY")
            K.ApplyTextFont(frame.label,13,false,""); frame.label:SetPoint("CENTER")
            frame.label:SetWordWrap(false)
            local highlight = frame:CreateTexture(nil,"HIGHLIGHT")
            highlight:SetAllPoints(); highlight:SetColorTexture(1,1,1,0.055)
        end
        pool[index] = frame
    end
    if frame.skinPreview then frame.skinPreview:Hide() end
    if frame.mbRowIcon then frame.mbRowIcon:Hide() end
    if frame.arSwatch then frame.arSwatch:Hide() end
    if frame.xpColorChip then frame.xpColorChip:Hide() end
    frame.xpColorTag=nil
    if frame.choiceAccent then frame.choiceAccent:Hide() end
    frame.choiceSelected=false
    frame:SetParent(parent); frame:SetFrameLevel(parent:GetFrameLevel()+1)
    frame:ClearAllPoints(); frame:SetPoint("TOPLEFT",x,y); frame:SetSize(w,h)
    frame:SetScript("OnEnter",nil); frame:SetScript("OnLeave",nil)
    if button then
        frame:Enable(); frame:SetScript("OnClick",nil)
        frame:SetScript("OnMouseDown",nil); frame:SetScript("OnMouseUp",nil)
        ControlGlyph(frame,"")
        if frame.switchParts then for _,part in ipairs(frame.switchParts) do part:Hide() end end
        frame.label:ClearAllPoints(); frame.label:SetPoint("CENTER"); frame.label:SetJustifyH("CENTER")
        K.ApplyTextFont(frame.label,13,false,"")
        frame.label:SetTextColor(unpack(white)); frame.label:SetWidth(w-10)
    end
    local tone=button and 1 or math.max(.6,math.min(1.8,tonumber(KerimAnkaUIDB.cardTone) or 1))
    Rounded(frame,0.15*tone,0.165*tone,0.15*tone,nil,button and 5 or 8,not button); frame:Show()
    return frame
end
local function Button(parent,value,x,y,w,h,click)
    local b = Box(parent,x,y,w,h or 30,true)
    b.label:SetText(value); b:SetScript("OnClick",click); ControlGlyph(b,value)
    return b
end
local function Selected(button,selected)
    button.choiceSelected=selected==true
    if not selected then
        Rounded(button,.14,.15,.14,nil,5,false)
        button.label:SetTextColor(unpack(white))
        if button.choiceAccent then button.choiceAccent:Hide() end
        return
    end
    Rounded(button,.22,.27,.19,{.77,.65,.37,1},5,false)
    button.label:SetTextColor(.98,.94,.79,1)
    if not button.choiceAccent then
        button.choiceAccent=button:CreateTexture(nil,"OVERLAY")
        button.choiceAccent:SetPoint("TOPLEFT",2,-5); button.choiceAccent:SetPoint("BOTTOMLEFT",2,5)
        button.choiceAccent:SetWidth(3); button.choiceAccent:SetColorTexture(.87,.73,.40,1)
    end
    button.choiceAccent:Show()
end
K.StyleChoice=Selected
local function Help(parent,key,x,y)
    local b = Button(parent,"?",x,y,22,22,function() end)
    b.label:SetTextColor(unpack(gold)); Tip(b,key,key.."Help")
    return b
end
local function Switch(parent,value,x,y,callback,available)
    local b = Button(parent,K.L(value and "on" or "off"),x,y,76,30,function() callback(not value); K.Render() end)
    b:SetBackdrop(nil)
    HideRounded(b)
    if not b.switchParts then
        b.switchParts={}
        local function Shape(w,h,layer,level,round)
            local t=b:CreateTexture(nil,layer,nil,level); t:SetSize(w,h)
            t:SetTexture(round and "Interface\\AddOns\\KerimAnkaUI\\Media\\Circle.tga" or "Interface\\Buttons\\WHITE8X8","CLAMP","CLAMP","LINEAR")
            if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
            if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
            b.switchParts[#b.switchParts+1]=t
            return t
        end
        b.trackLeft=Shape(30,30,"ARTWORK",0,true); b.trackLeft:SetPoint("LEFT",0,0)
        b.trackMiddle=Shape(46,30,"ARTWORK",0,false); b.trackMiddle:SetPoint("CENTER")
        b.trackRight=Shape(30,30,"ARTWORK",0,true); b.trackRight:SetPoint("RIGHT",0,0)
        b.knob=Shape(24,24,"OVERLAY",2,true)
    end
    local color=value and {0.30,0.53,0.30,1} or {0.27,0.29,0.28,1}
    if available == false then color={0.14,0.15,0.14,1} end
    for _,t in ipairs({b.trackLeft,b.trackMiddle,b.trackRight}) do t:SetVertexColor(unpack(color)) end
    b.knob:SetVertexColor(0.93,0.94,0.90,available == false and 0.35 or 1)
    b.knob:ClearAllPoints(); b.knob:SetPoint("CENTER",value and 23 or -23,0)
    for _,part in ipairs(b.switchParts) do part:Show() end
    K.ApplyTextFont(b.label,9,true,""); b.label:SetWidth(43)
    b.label:ClearAllPoints(); b.label:SetPoint("CENTER",value and -12 or 12,0)
    if available == false then b:Disable(); b.label:SetText("—"); b.label:SetTextColor(unpack(muted)) end
    return b
end
local function ToggleRow(key,y,getter,setter,available)
    local frame = Box(page,0,y,714,62)
    Text(frame,K.L(key),16,-20,490,15)
    Help(frame,key,584,-20)
    Switch(frame,getter(),620,-16,setter,available)
    if available == false then Text(frame,K.L("unavailable"),16,-42,540,10,muted) end
end
local function CVarToggle(option,y)
    local value = K.GetCVar(option.cvar)
    ToggleRow(option.key,y,function() return value == "0" end,
        function(enabled) K.SetCVar(option.cvar,enabled and 0 or 1) end,value ~= nil)
end
local function NumberCard(parent,key,cvar,x,y,w,low,high,step,format)
    local card = Box(parent,x,y,w,136)
    K.ApplyTextFont(Text(card,K.L(key),16,-18,w-64,16),16,true,"")
    Help(card,key,w-38,-14)
    local value = tonumber(K.GetCVar(cvar))
    Text(card,value and string.format(format,value) or K.L("unavailable"),16,-63,w-128,24,value and white or muted)
    local function Change(direction)
        if value then K.SetCVar(cvar,math.max(low,math.min(high,math.floor((value+direction*step)/step+0.5)*step))) end
        K.Render()
    end
    local a=Button(card,"−",w-100,-66,36,32,function() Change(-1) end)
    local b=Button(card,"+",w-54,-66,36,32,function() Change(1) end)
    if not value then a:Disable(); b:Disable() end
end
local function Overview()
    NumberCard(page,"zoom","cameraDistanceMaxZoomFactor",0,0,349,1,2.6,0.1,"%.1f ×")
    NumberCard(page,"queue","SpellQueueWindow",365,0,349,0,1000,10,"%.0f ms")
    local function Card(key,x,y,value,callback,available)
        local card = Box(page,x,y,349,123)
        K.ApplyTextFont(Text(card,K.L(key),16,-18,279,16),16,true,"")
        Help(card,key,311,-14)
        Text(card,K.L("saved"),16,-78,210,12,muted)
        Switch(card,value,255,-72,callback,available)
    end
    Card("errors",0,-152,K.db.hideErrors,function(v) K.SetErrors(v) end,UIErrorsFrame ~= nil)
    Card("clicks",365,-152,K.db.muteClicks,function(v) K.SetClicks(v) end,MuteSoundFile ~= nil and UnmuteSoundFile ~= nil)
    CVarToggle({key="disableDeathEffect",cvar="ffxDeath"},-294)
    local fps=K.FPS
    Text(page,K.L("fpsTitle"),0,-385,714,17,gold)
    if fps then
        Card("fpsShow",0,-416,fps.Get('enabled'),function(v) fps.Set('enabled',v) end,not K.InCombat())
        Card("fpsLock",365,-416,fps.Get('locked'),function(v) fps.Set('locked',v) end,not K.InCombat())
        local reset=Button(page,K.L('fpsReset'),0,-555,714,34,function() fps.ResetPosition() end)
        if K.InCombat() then reset:Disable() end
    end
    Text(page,K.L('fpsHomeHelp'),8,-607,690,13,muted)
    Text(page,K.L("state"),0,-720,714,17,gold)
    for i,module in ipairs(K.VisibleModules()) do
        local exists, enabled, loaded = K.ModuleState(module)
        local x = i%2 == 1 and 0 or 365
        local y = -751 - math.floor((i-1)/2)*48
        local b = Button(page,K.L(module.key=="details" and "dmDetails" or module.key),x,y,349,38,function() selection=module.key; K.Render() end)
        b.label:ClearAllPoints(); b.label:SetPoint("LEFT",12,0); b.label:SetWidth(204); b.label:SetJustifyH("LEFT")
        Text(b,K.L(K.ModuleStatus(module)),216,-9,123,11,K.ModuleStatus(module)=="loaded" and {0.58,0.76,0.48} or muted)
    end
    page:SetHeight(781+math.ceil(#K.VisibleModules()/2)*48)
end
local function Camera()
    NumberCard(page,"zoom","cameraDistanceMaxZoomFactor",0,0,714,1,2.6,0.1,"%.1f ×")
    Text(page,K.L("zoomNote"),12,-158,690,14,muted)
    page:SetHeight(230)
end
local function Combat()
    NumberCard(page,"queue","SpellQueueWindow",0,0,714,0,1000,10,"%.0f ms")
    Text(page,K.L("queueHelp"),12,-160,690,14,muted)
    page:SetHeight(245)
end
local function Alerts()
    local y=K.DrawErrorOptions(page)
    CVarToggle({key="disableDeathEffect",cvar="ffxDeath"},y-24)
    page:SetHeight(-y+120)
end
local idEdit
local soundFeedbackKey,soundFeedbackId
local function RefreshSoundSettings()
    local offset=K.scroll:GetVerticalScroll()
    K.Render();K.scroll:SetVerticalScroll(offset)
end
local function Sounds()
    Text(page,K.L("soundInfo"),0,0,714,13,muted)
    ToggleRow("clicks",-43,function() return K.db.muteClicks end,function(v) K.SetClicks(v) end,MuteSoundFile ~= nil and UnmuteSoundFile ~= nil)
    for i,option in ipairs(K.soundOptions) do CVarToggle(option,-43-i*70) end
    local y=-43-(#K.soundOptions+1)*70
    if K.SoundShortcut then
        local shortcut=K.SoundShortcut
        ToggleRow("soundShortcutShow",y,function() return shortcut.Get('enabled') end,function(v) shortcut.Set('enabled',v) end,true)
        ToggleRow("soundShortcutLock",y-70,function() return shortcut.Get('locked') end,function(v) shortcut.Set('locked',v) end,true)
        Button(page,K.L('soundShortcutReset'),0,y-140,714,34,function() shortcut.ResetPosition() end)
        y=y-196
    end
    if K.DrawSoundGroups then
        y=K.DrawSoundGroups(page,{Box=Box,Text=Text,Button=Button,Tip=Tip},y,RefreshSoundSettings)
    end
    Text(page,K.L("custom"),0,y,680,19,gold); Help(page,"custom",688,y+3)
    Text(page,K.L("fileIds"),0,y-38,700,12,muted)
    local function addSounds()
        if K.AddSounds(idEdit:GetText()) then
            idEdit:SetText("");idEdit:ClearFocus();soundFeedbackKey="soundAdded"
        else soundFeedbackKey=(MuteSoundFile and UnmuteSoundFile) and "invalidIds" or "unavailable" end
        soundFeedbackId=nil;RefreshSoundSettings()
    end
    if not idEdit then
        idEdit=CreateFrame("EditBox",nil,page,"InputBoxTemplate")
        idEdit:SetAutoFocus(false);idEdit:SetMaxLetters(360);K.ApplyTextFont(idEdit,14,false,"")
        idEdit:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    end
    idEdit:SetScript("OnEnterPressed",addSounds)
    idEdit:ClearAllPoints();idEdit:SetPoint("TOPLEFT",8,y-62);idEdit:SetSize(560,30);idEdit:Show()
    Button(page,K.L("add"),585,y-60,129,32,addSounds)
    Text(page,K.L("soundCustomInfo"),0,y-110,714,13,muted)
    if soundFeedbackKey then
        local failed=soundFeedbackKey=="invalidIds" or soundFeedbackKey=="unavailable" or soundFeedbackKey=="previewFail" or soundFeedbackKey=="soundMuteFailed" or soundFeedbackKey=="soundTestPlayed"
        local prefix=soundFeedbackId and (tostring(soundFeedbackId)..": ") or ""
        Text(page,prefix..K.L(soundFeedbackKey),0,y-185,714,13,failed and {.95,.48,.38} or gold)
    end
    local ids={};for id in pairs(K.db.sounds) do ids[#ids+1]=id end;table.sort(ids)
    local listY=y-270
    if #ids==0 then Text(page,K.L("empty"),0,listY,714,13,muted) end
    for i,id in ipairs(ids) do
        local row=Box(page,0,listY-(i-1)*96,714,84)
        Text(row,tostring(id),14,-12,130,14)
        local state=K.CustomSoundState(id)
        Text(row,K.L(state),160,-12,538,13,state=="soundMuteActive" and {.55,.90,.55} or {.95,.48,.38})
        Button(row,K.L("soundMuteTest"),16,-44,218,30,function()
            soundFeedbackKey=K.TestSoundMute(id);soundFeedbackId=id;RefreshSoundSettings()
        end)
        Button(row,K.L("listen"),246,-44,218,30,function()
            soundFeedbackId=id
            if K.PreviewSound(id) then soundFeedbackKey=nil else soundFeedbackKey=K.CustomSoundState(id)=="soundMuteFailed" and "soundMuteFailed" or "previewFail" end
            RefreshSoundSettings()
        end)
        Button(row,K.L("remove"),476,-44,222,30,function()
            K.StopPreview();K.RemoveSound(id);soundFeedbackKey="soundRemoved";soundFeedbackId=id;RefreshSoundSettings()
        end)
    end
    local bottom=listY-math.max(1,#ids)*96-16
    local stop=Button(page,K.L("stopPreview"),0,bottom,220,30,function() K.StopPreview();RefreshSoundSettings() end)
    Help(page,"stopPreview",228,bottom+3)
    if not K.previewHandle then stop:Disable() end
    Text(page,K.L("soundNote"),265,bottom,449,12,muted)
    page:SetHeight(-bottom+70)
end
local function Interface()
    local value = KerimAnkaUIDB.scale or panelDefaults.scale
    local card=Box(page,0,0,714,128)
    Text(card,K.L("scale"),16,-20,590,17); Help(card,"scale",676,-16)
    K.scaleValueText=Text(card,string.format("%.0f%%",value*100),16,-72,400,24)
    local function Scale(delta)
        local current=tonumber(KerimAnkaUIDB.scale) or panelDefaults.scale
        KerimAnkaUIDB.scale=math.max(0.65,math.min(1.3,math.floor((current+delta)*100+0.5)/100))
        -- Do not hide/reparent the clicked control and its card during OnClick.
        -- The layout is fixed; only its inherited scale and value text change.
        K.ScheduleScaleApply()
    end
    Button(card,"−",602,-72,36,32,function() Scale(-0.05) end)
    Button(card,"+",652,-72,36,32,function() Scale(0.05) end)
    ToggleRow("launcher",-148,function() return not KerimAnkaUIDB.minimap.hide end,function(v)
        KerimAnkaUIDB.minimap.hide = not v; K.UpdateLauncher()
    end,true)
    ToggleRow("cardGlow",-222,function() return KerimAnkaUIDB.cardGlow ~= false end,function(v)
        KerimAnkaUIDB.cardGlow=v
    end,true)
    ToggleRow("hideActionBarStatues",-296,function() return K.db.hideActionBarStatues==true end,function(v)
        K.SetActionBarStatues(v)
    end,not K.InCombat())
    local y=-384
    Text(page,K.L("glowStyle"),8,y,690,18,gold); y=y-38
    local presets={{"shadowPreset",{0,0,0},.55},{"lightPreset",{.8,.8,.8},.22},{"goldPreset",{.65,.5,.25},.25}}
    for i,preset in ipairs(presets) do
        local presetButton=Button(page,K.L(preset[1]),(i-1)*243,y,228,34,function()
            KerimAnkaUIDB.glowColor={unpack(preset[2])}; KerimAnkaUIDB.glowStrength=preset[3]
            KerimAnkaUIDB.cardGlow=true; K.Render()
        end)
        local color=KerimAnkaUIDB.glowColor or {0,0,0}
        local matches=KerimAnkaUIDB.cardGlow~=false and math.abs((KerimAnkaUIDB.glowStrength or .45)-preset[3])<.001
        for component=1,3 do if math.abs(color[component]-preset[2][component])>.001 then matches=false end end
        Selected(presetButton,matches)
    end
    y=y-52
    local fields={{"glowStrength",0,1,.05,.45},{"glowRadius",4,20,1,10},{"glowRed",0,1,.05,0,1},{"glowGreen",0,1,.05,0,2},{"glowBlue",0,1,.05,0,3},{"cardTone",.6,1.8,.05,1}}
    for i,field in ipairs(fields) do
        local key,low,high,step,default,component=unpack(field)
        local c=Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
        Text(c,K.L(key),14,-12,278,13)
        local tip=Button(c,"?",311,-10,22,22,function() end); Tip(tip,"glowStyle","glowStyleHelp")
        local function read()
            if component then return (KerimAnkaUIDB.glowColor or {0,0,0})[component] or default end
            return tonumber(KerimAnkaUIDB[key]) or default
        end
        local function format(v) return string.format(step<1 and "%.2f" or "%.0f",v) end
        local value=Text(c,format(read()),14,-54,150,15)
        local function change(delta)
            local requested=math.max(low,math.min(high,math.floor((read()+delta*step)/step+.5)*step))
            if component then
                KerimAnkaUIDB.glowColor=KerimAnkaUIDB.glowColor or {0,0,0}
                KerimAnkaUIDB.glowColor[component]=requested
            else KerimAnkaUIDB[key]=requested end
            -- Finish click dispatch before rebuilding the pooled controls.
            value:SetText(format(requested))
            C_Timer.After(0,function() if K.window:IsShown() then K.Render() end end)
        end
        Button(c,"−",251,-47,36,32,function() change(-1) end)
        Button(c,"+",297,-47,36,32,function() change(1) end)
    end
    y=y-math.ceil(#fields/2)*96
    Button(page,K.L("glowReset"),0,y,714,36,function()
        KerimAnkaUIDB.cardGlow=true; KerimAnkaUIDB.glowColor=nil; KerimAnkaUIDB.glowStrength=nil
        KerimAnkaUIDB.glowRadius=nil; KerimAnkaUIDB.cardTone=nil; K.Render()
    end)
    y=y-60
    Button(page,K.L("introReplay"),0,y,714,36,function() K.StartIntro(true) end)
    y=y-48
    Button(page,K.L("center"),0,y,349,38,function() K.CenterWindow() end)
    local b=Button(page,K.L("restore"),365,y,349,38,function() K.Restore() end)
    Tip(b,"restore","restoreHelp")
    Text(page,K.L("scaleHelp"),12,y-66,690,14,muted)
    page:SetHeight(-y+155)
end
local function AddonControls(module)
    local exists,enabled=K.ModuleState(module)
    local y=-page:GetHeight()-8
    local card=Box(page,0,y,714,90)
    Text(card,K.L(K.ModuleStatus(module)),16,-12,660,13,gold)
    Text(card,K.L("addonControl"),16,-53,490,15)
    local help=Button(card,"?",584,-47,22,22,function() end); Tip(help,"addonControl","addonControlHelp")
    Switch(card,enabled,620,-44,function(value) K.ToggleModule(module,value) end,exists and K.ModuleApplicable(module))
    page:SetHeight(-y+110)
end
local function Module(module)
    if module.key=="details" and K.DrawDamageMetersPage then
        if K.DrawDamageMetersPage(page) then AddonControls(module) end
        return
    end
    local exists, enabled, loaded=K.ModuleState(module)
    if loaded and K.ModuleApplicable(module) then
        if (module.key=="backdrop" or module.key=="art") and K.DrawActionBarPage and K.DrawActionBarPage(page,module.key) then AddonControls(module); return end
        if module.key=="units" and K.DrawUnitsPage and ForeverLeatherUnitsAPI and ForeverLeatherUnitsAPI.version>=2 and ForeverLeatherUnitsAPI.GetSettings() then
            K.DrawUnitsPage(page); AddonControls(module); return
        end
        if module.key=="quests" and K.DrawQuestPage and K.DrawQuestPage(page) then AddonControls(module); return end
        if module.key=="details" and K.DrawDetailsPage and K.DrawDetailsPage(page) then AddonControls(module); return end
        if module.key=="range" and K.DrawRangePage and K.DrawRangePage(page) then AddonControls(module); return end
        if module.key=="threat" and K.DrawThreatPage and K.DrawThreatPage(page) then AddonControls(module); return end
        if module.key=="aspect" and K.DrawAspectPage and K.DrawAspectPage(page) then AddonControls(module); return end
    end
    local card=Box(page,0,0,714,110)
    Text(card,module.addon,18,-18,670,19,gold)
    Text(card,K.L(K.ModuleStatus(module)),18,-59,670,16,K.ModuleStatus(module)=="loaded" and {0.58,0.76,0.48} or muted)
    ToggleRow("addonControl",-126,function() return enabled end,function(v) K.ToggleModule(module,v) end,exists and K.ModuleApplicable(module))
    Text(page,K.L("dependency"),12,-211,690,13,muted)
    Text(page,K.L(not K.ModuleApplicable(module) and "hunterOnlyHelp" or not loaded and "inactiveHelp" or module.key=="units" and "ufUpdate" or module.key=="backdrop" and "abUpdate" or module.key=="quests" and "qjUpdate" or module.key=="details" and "dtUpdate" or module.key=="range" and "hrUpdate" or module.key=="threat" and "ftUpdate" or module.key=="aspect" and "aaUpdate" or "bridge"),12,-257,690,15)
    page:SetHeight(430)
end
function K.ShowPage(key)
    if not K.window then return end
    for _,module in ipairs(K.modules) do
        if key==module.key and not K.ModuleApplicable(module) then key="home"; break end
    end
    selection=key or "home"
    K.scroll:SetVerticalScroll(0); K.window:Show(); K.Render()
end
function K.Render()
    if K.CloseCommunity then K.CloseCommunity() end
    if not page then return end
    K.UnitOptionPositions=nil
    if K.HideAspectInputs then K.HideAspectInputs() end; if K.HideRangeInputs then K.HideRangeInputs() end
    if K.HideProfileInputs then K.HideProfileInputs() end
    if K.HideExperienceInputs then K.HideExperienceInputs() end
    if selection~="profiles" and K.EndProfileSession then K.EndProfileSession() end
    if selection~="aspect" and K.EndAspectPreview then K.EndAspectPreview() end
    if K.HideThreatFontMenu then K.HideThreatFontMenu() end
    if selection~="range" and K.EndRangePreview then K.EndRangePreview() end
    if K.ConfigureUnitPreview then
        K.ConfigureUnitPreview(selection=="units" and ForeverLeatherUnitsAPI and ForeverLeatherUnitsAPI.version>=2 and ForeverLeatherUnitsAPI.GetSettings()~=nil)
    end
    if K.ConfigureExperiencePreview then K.ConfigureExperiencePreview(selection=="experience") end
    K.scaleValueText=nil
    for _,v in pairs(pool) do v:Hide() end
    for _,v in pairs(labels) do v:Hide() end
    if idEdit then idEdit:Hide() end
    used, labelUsed=0,0
    for _,v in ipairs(nav) do
        v.label:SetText(K.L(v.key))
        local selected=v.key==selection
        Rounded(v,selected and 0.20 or 0.095,selected and 0.245 or 0.105,selected and 0.17 or 0.10,
            selected and {0.43,0.53,0.34,1} or {0.095,0.105,0.10,1},6,false)
        v.accent:SetShown(selected)
        if K.RefreshModuleBadge then K.RefreshModuleBadge(v) end
    end
    for _,v in ipairs(tabs) do
        v:SetShown(selection=="home")
        v.label:SetText(K.L(v.key))
        local selected=v.key==section
        Rounded(v,selected and 0.20 or 0.115,selected and 0.225 or 0.125,selected and 0.175 or 0.115,
            selected and {0.25,0.28,0.23,1} or {0.115,0.125,0.115,1},6,false)
        v.underline:SetShown(selected)
    end
    if languageMenu then languageMenu:Hide(); languageDismiss:Hide() end
    if languageButton then UpdateLanguageLabel(); K.RefreshPanelFonts() end
    heading:SetText(K.L(selection=="home" and (section=="overview" and "quick" or section) or selection))
    subtitle:SetText(K.L(selection=="home" and "welcome" or "saved"))
    footer:SetText(K.HasPendingModuleChanges() and K.L("communityReloadWaiting") or "")
    footer:SetTextColor(unpack(K.HasPendingModuleChanges() and gold or muted))
    K.window.reload.label:SetText(K.L("reload"))
    if selection=="profiles" then K.DrawProfilesPage()
    elseif selection=="interface" then Interface()
    elseif selection=="experience" then K.DrawExperiencePage(page)
    elseif selection=="minimap" then K.DrawMinimapPage(page)
    elseif selection=="inventory" then K.DrawInventoryPage(page)
    elseif selection~="home" then
        for _,module in ipairs(K.modules) do if selection==module.key then Module(module); break end end
    elseif section=="overview" then Overview()
    elseif section=="camera" then Camera()
    elseif section=="combat" then Combat()
    elseif section=="alerts" then Alerts()
    elseif section=="sounds" then Sounds() end
    if K.reloadPrompt and K.reloadPrompt:IsShown() then
        if K.HasPendingModuleChanges() then K.ShowReloadPrompt() else K.reloadPrompt:Hide() end
    end
    if K.UpdateIntro then K.UpdateIntro() end
    -- Do not reset scroll while a user is editing a long sound list.
end
-- Separate inherited native text from Latin/Cyrillic text. A region created
-- without the native template can retain an incompatible local font on clients.
UpdateLanguageLabel=function()
    local chinese=KerimAnkaUIDB.language=="zhCN"
    languageButton.romanLabel:Hide();languageButton.chineseLabel:Hide()
    languageButton.label=chinese and languageButton.chineseLabel or languageButton.romanLabel
    languageButton.label:SetText(K.LanguageName());languageButton.label:Show()
end
local function FixedButton(parent,value,x,y,w,h,click,nativeFont)
    local b=CreateFrame("Button",nil,parent,"BackdropTemplate"); b:SetPoint("TOPLEFT",x,y); b:SetSize(w,h)
    Rounded(b,0.14,0.15,0.14,nil,5,false)
    b.label=b:CreateFontString(nil,"OVERLAY",nativeFont and "GameFontNormal" or nil); K.ApplyTextFont(b.label,13,false,"",nativeFont); b.label:SetPoint("CENTER")
    b.label:SetWidth(w-12); b.label:SetText(value); b.label:SetTextColor(unpack(white))
    local hl=b:CreateTexture(nil,"HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1,1,1,0.06)
    b:SetScript("OnClick",click)
    ControlGlyph(b,value)
    return b
end
-- One visible first-open guide per character. Never apply a layout automatically.
local introStep,introCard,introOutline,introProfiles,introShade
function K.EndIntro()
    introStep=nil
    if introCard then introCard:Hide();introOutline:Hide();introShade:Hide() end
end
function K.StartIntro(replay)
    if InCombatLockdown() or not replay and K.db.onboardingSeen then return end
    K.db.onboardingSeen=1
    introStep=1
    K.Render()
end
function K.UpdateIntro()
    if not introStep or not K.window:IsShown() then return end
    if selection=="profiles" then
        if introStep<3 then introStep=2 end
    elseif introStep>=2 then K.EndIntro();return end
    if introStep==3 and not K.db.profileTransaction then K.EndIntro();return end
    if not introCard then
        introShade=CreateFrame("Frame",nil,UIParent)
        introShade:SetAllPoints(UIParent);introShade:SetFrameStrata("DIALOG")
        introShade:EnableMouse(true)
        local dim=introShade:CreateTexture(nil,"BACKGROUND");dim:SetAllPoints();dim:SetColorTexture(.015,.025,.02,.84)
        introCard=CreateFrame("Frame",nil,K.window,"BackdropTemplate")
        introCard:SetSize(690,300);introCard:SetClampedToScreen(true)
        Backdrop(introCard,.09,.105,.09,{.78,.65,.36,1});introCard:EnableMouse(true)
        introCard.title=introCard:CreateFontString(nil,"OVERLAY")
        introCard.title:SetPoint("TOPLEFT",24,-26);introCard.title:SetWidth(642);introCard.title:SetJustifyH("LEFT")
        introCard.body=introCard:CreateFontString(nil,"OVERLAY")
        introCard.body:SetPoint("TOPLEFT",24,-72);introCard.body:SetWidth(642);introCard.body:SetJustifyH("LEFT");introCard.body:SetWordWrap(true)
        introCard.skip=FixedButton(introCard,"",24,-244,198,36,function()
            if introStep==3 and K.Profiles and not K.Profiles.CancelPending() then return end
            K.EndIntro()
        end)
        introCard.next=FixedButton(introCard,"",238,-244,428,36,function()
            if introStep==1 then K.ShowPage("profiles");return end
            -- Keep the clicked button visible. This fresh click only reloads;
            -- the preceding click has already completed all native preparation.
            if introStep==3 then K.Reload();return end
            local ready=K.ClassPresets and K.ClassPresets.Get()
            if not ready then K.EndIntro();return end
            local ok,err=K.ClassPresets.Queue()
            if not ok then if K.Message then K.Message(err) end;K.Render();return end
            local prepared,prepareError=K.ClassPresets.PrepareReload()
            if not prepared then
                K.Profiles.CancelPending()
                if K.Message then K.Message(prepareError or 'readyMeterPrepareFailed') end
                K.Render();return
            end
            introStep=3
            K.Render()
        end)
        introOutline=CreateFrame("Frame",nil,K.window,"BackdropTemplate")
        introOutline:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=2})
        introOutline:SetBackdropBorderColor(.92,.76,.40,1);introOutline:EnableMouse(false)
    end
    local data=selection=="profiles" and K.ClassPresets and K.ClassPresets.Get()
    local ready=data and K.ClassPresets.readyCard
    local target=ready or introProfiles
    introOutline:SetParent(target);introOutline:ClearAllPoints();introOutline:SetAllPoints(target)
    local level=K.window:GetFrameLevel()
    introShade:SetFrameLevel(level+45);introOutline:SetFrameLevel(level+47);introCard:SetFrameLevel(level+50)
    introCard:ClearAllPoints();introCard:SetPoint("CENTER",K.window,"CENTER",0,0)
    K.ApplyTextFont(introCard.title,21,true,"");introCard.title:SetTextColor(.94,.81,.49)
    K.ApplyTextFont(introCard.body,16,false,"");introCard.body:SetTextColor(.90,.92,.87)
    introCard.title:SetText(tostring(introStep).." / 3  "..K.L(introStep==3 and "introPreparedTitle" or introStep==1 and "introWelcome" or "introProfilesTitle"))
    introCard.body:SetText(K.L(introStep==3 and "introPreparedBody" or introStep==1 and "introWelcomeBody" or ready and "introReadyBody" or "introNoPresetBody"))
    introCard.skip.label:SetText(K.L(introStep==3 and "introCancel" or "introSkip"))
    introCard.next.label:SetText(K.L(introStep==3 and "introReload" or introStep==1 and "introGoProfiles" or ready and 'readyApply'..data.name or "introDone"))
    K.ApplyTextFont(introCard.skip.label,13,false,"");K.ApplyTextFont(introCard.next.label,14,true,"")
    introShade:Show();introOutline:Show();introCard:Show()
end
local introEvents=CreateFrame('Frame')
introEvents:RegisterEvent('PLAYER_REGEN_DISABLED')
introEvents:SetScript('OnEvent',function() K.EndIntro() end)

function K.RefreshModuleBadge(navButton)
    local badge=navButton.moduleBadge
    if not badge then return end
    local module=badge.module
    local exists,enabled,loaded=K.ModuleState(module)
    local applicable=K.ModuleApplicable(module)
    local status=K.ModuleStatus(module)
    local pending=status=="pendingOn" or status=="pendingOff"
    local color=pending and {0.50,0.37,0.16,1} or (exists and applicable and enabled and loaded and {0.29,0.52,0.29,1} or {0.24,0.27,0.25,1})
    Rounded(badge,color[1],color[2],color[3],color,8,false)
    badge.dot:ClearAllPoints(); badge.dot:SetPoint(enabled and applicable and "RIGHT" or "LEFT",enabled and applicable and -3 or 3,0)
    Rounded(badge.dot,.87,.90,.85,{.87,.90,.85,1},5,false)
    badge:SetAlpha(exists and applicable and 1 or .45)
end
local function ModuleBadge(navButton,module)
    local badge=CreateFrame("Button",nil,navButton,"BackdropTemplate")
    badge:SetSize(30,18); badge:SetPoint("RIGHT",-8,0); badge.module=module
    badge:SetHitRectInsets(-2,-2,-5,-5)
    badge:SetFrameLevel(navButton:GetFrameLevel()+2)
    badge.dot=CreateFrame("Frame",nil,badge,"BackdropTemplate"); badge.dot:SetSize(12,12); badge.dot:EnableMouse(false)
    navButton.moduleBadge=badge
    badge:SetScript("OnClick",function()
        K.HideTooltip()
        local exists,enabled=K.ModuleState(module)
        if not exists then K.Message("missing"); return end
        if enabled==nil then K.Message("addonStateUnknown"); return end
        if not K.ModuleApplicable(module) then K.Message("hunterOnlyHelp"); return end
        K.ToggleModule(module,not enabled)
    end)
    badge:SetScript("OnEnter",function(self)
        local exists,enabled=K.ModuleState(module)
        local body=K.L(K.ModuleStatus(module)).."\n\n"..K.L("badgeHelp")
        if not exists then body=K.L("missing")
        elseif not K.ModuleApplicable(module) then body=K.L("hunterOnlyHelp")
        else body=body.."\n\n"..K.L(enabled and "badgeDisable" or "badgeEnable") end
        K.ShowTooltip(self,K.L(module.key),body)
    end)
    badge:SetScript("OnLeave",K.HideTooltip)
end
function K.ShowReloadPrompt()
    if not K.window or not K.window:IsShown() or not K.HasPendingModuleChanges() then return end
    K.HideTooltip()
    local overlay=K.reloadPrompt
    if not overlay then
        overlay=CreateFrame("Frame","KerimAnkaUIReloadPrompt",K.window)
        K.reloadPrompt=overlay; overlay:SetAllPoints(K.window); overlay:SetFrameLevel(K.window:GetFrameLevel()+100)
        overlay:EnableMouse(true); overlay:EnableMouseWheel(true); overlay:SetScript("OnMouseWheel",function() end)
        local shade=overlay:CreateTexture(nil,"BACKGROUND"); shade:SetAllPoints(); shade:SetColorTexture(0,0,0,.55)
        local dialog=CreateFrame("Frame",nil,overlay,"BackdropTemplate"); dialog:SetSize(500,264); dialog:SetPoint("CENTER")
        Rounded(dialog,.15,.165,.15,{.48,.43,.31,1},10,false)
        overlay.title=dialog:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(overlay.title,20,true,""); overlay.title:SetPoint("TOPLEFT",24,-24); overlay.title:SetWidth(452); overlay.title:SetJustifyH("LEFT")
        overlay.body=dialog:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(overlay.body,14,false,""); overlay.body:SetPoint("TOPLEFT",24,-62); overlay.body:SetWidth(452); overlay.body:SetJustifyH("LEFT"); overlay.body:SetSpacing(3)
        overlay.now=FixedButton(dialog,"",24,-204,218,36,function() K.Reload() end)
        overlay.later=FixedButton(dialog,"",258,-204,218,36,function() overlay:Hide() end)
        UISpecialFrames[#UISpecialFrames+1]="KerimAnkaUIReloadPrompt"
    end
    overlay.title:SetText(K.L("reloadPromptTitle"))
    overlay.body:SetText(K.L("reloadPromptBody").."\n\n"..K.PendingModuleNames())
    overlay.now.label:SetText(K.L("reloadNow")); overlay.later.label:SetText(K.L("reloadLater"))
    overlay:Show()
end
function K.ApplyWindowScale()
    local desired=KerimAnkaUIDB.scale or panelDefaults.scale
    -- Fit small game resolutions even when the saved scale is large.
    local maxScale=math.min((UIParent:GetWidth()-24)/1000,(UIParent:GetHeight()-24)/K.window:GetHeight())
    K.window:SetScale(math.min(desired,maxScale))
end
local scaleApplyPending=false
local function RefreshScaleViewport()
    if not K.scroll then return end
    K.scroll:UpdateScrollChildRect()
    local offset=K.scroll:GetVerticalScroll()
    K.scroll:SetVerticalScroll(math.max(0,math.min(offset,K.scroll:GetVerticalScrollRange())))
    if K.scaleValueText then
        K.scaleValueText:SetFormattedText("%.0f%%",(KerimAnkaUIDB.scale or panelDefaults.scale)*100)
    end
end
function K.ScheduleScaleApply()
    if scaleApplyPending then return end
    scaleApplyPending=true
    -- Finish mouse-up/click dispatch before modifying the containing window.
    C_Timer.After(0,function()
        scaleApplyPending=false
        K.ApplyWindowScale()
        RefreshScaleViewport()
        -- Refresh clipping once more after the client settles the scaled layout.
        C_Timer.After(0,RefreshScaleViewport)
    end)
end
local resizing
function K.StopResize()
    if not resizing then return end
    K.window.grip:SetScript("OnUpdate",nil)
    resizing=nil
    local f=K.window
    local x,y=f:GetCenter(); local ux,uy=UIParent:GetCenter(); local scale=f:GetScale()
    if x and ux then
        local dx,dy=x-ux/scale,y-uy/scale
        K.db.position={x=dx,y=dy}
        f:ClearAllPoints(); f:SetPoint("CENTER",UIParent,"CENTER",dx,dy)
    end
    if f:IsShown() then K.Render(); RefreshScaleViewport() end
end
local function StartResize()
    local f=K.window
    f:StopMovingOrSizing(); K.HideTooltip()
    local x,y=GetCursorPosition(); local rootScale=UIParent:GetEffectiveScale()
    local scale=f:GetScale()
    local left,top=f:GetLeft()*scale,f:GetTop()*scale
    resizing={x=x/rootScale,y=y/rootScale,scale=scale,left=left,top=top,height=f:GetHeight()}
    f:ClearAllPoints(); f:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left/scale,top/scale)
    f.grip:SetScript("OnUpdate",function()
        if not IsMouseButtonDown("LeftButton") then K.StopResize(); return end
        local cx,cy=GetCursorPosition(); local rs=UIParent:GetEffectiveScale()
        local dx,dy=cx/rs-resizing.x,resizing.y-cy/rs
        local height=resizing.height
        local desired=resizing.scale+(dx*1000+dy*height)/(1000*1000+height*height)
        local maximum=math.min(1.3,(UIParent:GetWidth()-24)/1000,(UIParent:GetHeight()-24)/height)
        local value=math.max(math.min(0.65,maximum),math.min(maximum,desired))
        KerimAnkaUIDB.scale=value
        f:SetScale(value)
        f:ClearAllPoints(); f:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",resizing.left/value,resizing.top/value)
    end)
end
function K.CenterWindow()
    K.StopResize()
    K.db.position={x=0,y=0}; K.window:ClearAllPoints(); K.window:SetPoint("CENTER")
end
function K.LayoutWindow()
    local f=K.window
    if not f or not f.layoutParts then return end
    local height=f:GetHeight()
    f.layoutParts.sidebar:SetHeight(height-114)
    f.layoutParts.divider:SetHeight(height-114)
    local count=math.max(1,#nav-2)
    local step=math.min(45,(height-273)/math.max(1,count-1))
    local index=0
    for _,button in ipairs(nav) do
        if button.key~="profiles" and button.key~="interface" then
            button:SetHeight(math.min(39,step-3))
            button:ClearAllPoints();button:SetPoint("TOPLEFT",10,-12-index*step);index=index+1
        end
    end
    f.reload:ClearAllPoints(); f.reload:SetPoint("TOPLEFT",754,-(height-43))
    f.layoutParts.footerRule:ClearAllPoints(); f.layoutParts.footerRule:SetPoint("TOPLEFT",1,-(height-49))
    if K.ConfigureUnitPreview then K.ConfigureUnitPreview(K.unitPreviewPageAvailable) end
    if K.ConfigureExperiencePreview then K.ConfigureExperiencePreview(K.experiencePageAvailable) end
end
function K.BuildWindow()
    local f=CreateFrame("Frame","KerimAnkaUIWindow",UIParent,"BackdropTemplate")
    K.window=f; f:SetSize(1000,math.max(640,math.min(1100,tonumber(K.db.panelHeight) or panelDefaults.height))); f:SetFrameStrata("DIALOG"); Backdrop(f,0.115,0.125,0.115,{0.42,0.38,0.29,1})
    f:SetResizable(true)
    f:SetClampedToScreen(true); f:SetMovable(true); f:EnableMouse(true)
    K.ApplyWindowScale()
    local p=K.db.position or panelDefaults.position
    if type(p)=="table" and type(p.x)=="number" and type(p.y)=="number" then
        f:SetPoint("CENTER",UIParent,"CENTER",p.x,p.y)
    else f:SetPoint("CENTER") end
    f:Hide(); UISpecialFrames[#UISpecialFrames+1]="KerimAnkaUIWindow"
    local title=CreateFrame("Frame",nil,f); title:SetPoint("TOPLEFT",1,-1); title:SetSize(760,60)
    title:EnableMouse(true); title:RegisterForDrag("LeftButton")
    local function SavePosition()
        K.StopResize()
        f:StopMovingOrSizing()
        K.db.panelHeight=f:GetHeight()
        local x,y=f:GetCenter(); local ux,uy=UIParent:GetCenter()
        local scale=f:GetScale()
        if x and ux then K.db.position={x=x-ux/scale,y=y-uy/scale} end
    end
    title:SetScript("OnDragStart",function() f:StartMoving() end)
    title:SetScript("OnDragStop",SavePosition)
    f:SetScript("OnHide",function() if K.CloseCommunity then K.CloseCommunity() end; K.EndIntro();SavePosition(); if K.HideExperienceInputs then K.HideExperienceInputs() end; if languageMenu then languageMenu:Hide(); languageDismiss:Hide() end; K.StopPreview(); K.HideTooltip(); if K.EndProfileSession then K.EndProfileSession() end; if K.HideAspectInputs then K.HideAspectInputs() end; if K.HideRangeInputs then K.HideRangeInputs() end; if K.EndAspectPreview then K.EndAspectPreview() end; if K.HideThreatFontMenu then K.HideThreatFontMenu() end; if K.EndRangePreview then K.EndRangePreview() end; if K.reloadPrompt then K.reloadPrompt:Hide() end end)
    local header=f:CreateTexture(nil,"BACKGROUND",nil,1); header:SetPoint("TOPLEFT",1,-1); header:SetSize(998,63); header:SetColorTexture(0.15,0.16,0.145,1)
    local emblem=f:CreateTexture(nil,"ARTWORK"); emblem:SetPoint("TOPLEFT",17,-8); emblem:SetSize(48,48)
    emblem:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\Phoenix.tga","CLAMP","CLAMP","TRILINEAR")
    local brand=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(brand,25,true,""); brand:SetTextColor(0.79,0.69,0.49); brand:SetPoint("TOPLEFT",78,-16); brand:SetText("KerimAnka UI")
    local ver=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(ver,10,false,""); ver:SetTextColor(unpack(muted)); ver:SetPoint("TOPLEFT",80,-46); ver:SetText(K.version)
    local rule=f:CreateTexture(nil,"ARTWORK"); rule:SetPoint("TOPLEFT",1,-64); rule:SetSize(998,1); rule:SetColorTexture(0.55,0.48,0.34,0.65)
    languageButton=FixedButton(f,K.LanguageName(),782,-20,152,30,function()
        if languageMenu:IsShown() then languageMenu:Hide(); languageDismiss:Hide()
        else
            for _,row in ipairs(languageMenu.rows) do
                Selected(row,KerimAnkaUIDB.language==row.language)
            end
            languageDismiss:Show(); languageMenu:Show()
        end
    end)
    languageButton.romanLabel=languageButton.label
    K.ApplyTextFont(languageButton.romanLabel,13,false,"",false)
    languageButton.chineseLabel=languageButton:CreateFontString(nil,"OVERLAY","GameFontNormal")
    K.ApplyTextFont(languageButton.chineseLabel,13,false,"",true)
    for _,label in ipairs({languageButton.romanLabel,languageButton.chineseLabel}) do
        label:ClearAllPoints();label:SetPoint("LEFT",10,0);label:SetWidth(122)
        label:SetTextColor(unpack(white));label:SetWordWrap(false)
    end
    UpdateLanguageLabel()
    local arrow=languageButton:CreateTexture(nil,"OVERLAY")
    arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    arrow:SetSize(16,16);arrow:SetPoint("RIGHT",-5,0)
    Tip(languageButton,"language","languageHelp")
    languageDismiss=CreateFrame("Button",nil,f)
    languageDismiss:SetAllPoints(f);languageDismiss:SetFrameLevel(f:GetFrameLevel()+30)
    languageDismiss:SetScript("OnClick",function() languageMenu:Hide();languageDismiss:Hide() end)
    languageDismiss:Hide()
    languageMenu=CreateFrame("Frame",nil,f,"BackdropTemplate")
    languageMenu:SetPoint("TOPRIGHT",languageButton,"BOTTOMRIGHT",0,-5)
    languageMenu:SetSize(180,8+#K.languages*34)
    languageMenu:SetFrameLevel(f:GetFrameLevel()+32)
    Backdrop(languageMenu,.105,.115,.105,{.55,.48,.34})
    languageMenu:EnableMouse(true);languageMenu.rows={}
    for i,language in ipairs(K.languages) do
        local code=language.code
        local row=FixedButton(languageMenu,language.name,4,-4-(i-1)*34,172,32,function()
            languageMenu:Hide();languageDismiss:Hide();K.SetLanguage(code)
        end,language.native==true)
        row.language=code
        languageMenu.rows[#languageMenu.rows+1]=row
    end
    languageMenu:Hide()
    K.languageSelector=languageButton;K.languageMenu=languageMenu

    FixedButton(f,"×",950,-18,32,32,function() f:Hide() end)
    local sidebar=CreateFrame("Frame",nil,f,"BackdropTemplate"); sidebar:SetPoint("TOPLEFT",1,-65); sidebar:SetSize(199,566); Backdrop(sidebar,0.095,0.105,0.10,{0.095,0.105,0.10})
    local divider=f:CreateTexture(nil,"ARTWORK"); divider:SetPoint("TOPLEFT",201,-65); divider:SetSize(1,566); divider:SetColorTexture(0.27,0.29,0.25,0.7)
    local tabRule=f:CreateTexture(nil,"BACKGROUND",nil,2); tabRule:SetPoint("TOPLEFT",220,-112); tabRule:SetSize(745,1); tabRule:SetColorTexture(0.28,0.30,0.26,0.8)
    local function NavAccent(button)
        button.accent=button:CreateTexture(nil,"OVERLAY"); button.accent:SetPoint("LEFT",1,0)
        button.accent:SetSize(3,21); button.accent:SetColorTexture(0.52,0.72,0.43,1)
    end
    local keys={"home"}; for _,m in ipairs(K.VisibleModules()) do keys[#keys+1]=m.key;if m.key=="units" then keys[#keys+1]="minimap";keys[#keys+1]="inventory" end;if m.key=="details" then keys[#keys+1]="experience" end end
    for i,key in ipairs(keys) do
        local b=FixedButton(sidebar,K.L(key),10,-12-(i-1)*45,178,39,function()
            selection=key; K.scroll:SetVerticalScroll(0); K.Render()
        end)
        b.key=key; b.label:SetJustifyH("LEFT"); b.label:ClearAllPoints(); b.label:SetPoint("LEFT",15,0); b.label:SetWidth(151)
        for _,module in ipairs(K.modules) do
            if module.key==key and key~="details" then
                b.label:SetPoint("LEFT",12,0); b.label:SetWidth(122); b.label:SetWordWrap(false)
                ModuleBadge(b,module); break
            end
        end
        NavAccent(b); nav[#nav+1]=b
    end
    local b=FixedButton(sidebar,K.L("interface"),10,-513,178,39,function() selection="interface"; K.scroll:SetVerticalScroll(0); K.Render() end)
    b:ClearAllPoints(); b:SetPoint("BOTTOMLEFT",10,14)
    b.key="interface"; NavAccent(b); nav[#nav+1]=b
    local profiles=FixedButton(sidebar,K.L("profiles"),10,-466,178,39,function()
        selection="profiles"; K.scroll:SetVerticalScroll(0); K.Render()
    end)
    profiles:ClearAllPoints();profiles:SetPoint("BOTTOMLEFT",10,61)
    profiles.key="profiles";NavAccent(profiles);nav[#nav+1]=profiles
    introProfiles=profiles
    for i,key in ipairs({"overview","camera","combat","alerts","sounds"}) do
        local tab=FixedButton(f,K.L(key),220+(i-1)*126,-77,119,32,function()
            section=key; K.scroll:SetVerticalScroll(0); K.Render()
        end)
        tab.underline=tab:CreateTexture(nil,"OVERLAY"); tab.underline:SetPoint("BOTTOMLEFT",2,0); tab.underline:SetPoint("BOTTOMRIGHT",-2,0)
        tab.underline:SetHeight(3); tab.underline:SetColorTexture(0.52,0.72,0.43,1)
        tab.key=key; tabs[#tabs+1]=tab
    end
    heading=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(heading,25,true,""); heading:SetTextColor(unpack(white)); heading:SetPoint("TOPLEFT",222,-131)
    subtitle=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(subtitle,13,false,""); subtitle:SetTextColor(unpack(muted)); subtitle:SetPoint("TOPLEFT",222,-166); subtitle:SetWidth(730); subtitle:SetJustifyH("LEFT")
    local scroll=CreateFrame("ScrollFrame",nil,f,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",220,-205); scroll:SetSize(734,415); K.scroll=scroll
    -- Leave room around the content so the blur is not cut at the first row
    -- or the left/right viewport boundary.
    local content=CreateFrame("Frame",nil,scroll); content:SetSize(734,435); scroll:SetScrollChild(content)
    page=CreateFrame("Frame",nil,content); page:SetPoint("TOPLEFT",10,-10); page:SetSize(714,415)
    page:SetScript("OnSizeChanged",function(_,_,height) content:SetHeight(math.max(415,height+20)) end)
    footer=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(footer,11,false,""); footer:SetTextColor(unpack(muted)); footer:SetPoint("BOTTOMLEFT",300,20); footer:SetWidth(435); footer:SetJustifyH("LEFT")
    f.reload=FixedButton(f,K.L("reload"),754,-637,222,30,function() K.Reload() end); Tip(f.reload,"reload","reloadHelp")
    K.BuildCommunity(f,FixedButton,Backdrop,Tip,Selected)
    local footerRule=f:CreateTexture(nil,"ARTWORK"); footerRule:SetPoint("TOPLEFT",1,-631); footerRule:SetSize(998,1); footerRule:SetColorTexture(0.27,0.29,0.25,0.7)
    f.layoutParts={sidebar=sidebar,divider=divider,footerRule=footerRule}
    local heightGrip=CreateFrame("Button",nil,f); heightGrip:SetSize(64,10); heightGrip:SetPoint("BOTTOM",0,1)
    local line=heightGrip:CreateTexture(nil,"ARTWORK"); line:SetSize(28,2); line:SetPoint("CENTER"); line:SetColorTexture(.55,.60,.50,.8)
    local heightDragging=false
    local function StopHeightDrag()
        if not heightDragging then return end
        heightDragging=false; heightGrip:SetScript("OnUpdate",nil)
        SavePosition(); K.LayoutWindow(); RefreshScaleViewport()
    end
    heightGrip:SetScript("OnMouseDown",function(_,button)
        if button~="LeftButton" then return end
        K.StopResize(); K.HideTooltip()
        local maximum=math.max(640,math.min(1100,(UIParent:GetHeight()-24)/f:GetScale()))
        if f.SetResizeBounds then f:SetResizeBounds(1000,640,1000,maximum)
        else f:SetMinResize(1000,640); f:SetMaxResize(1000,maximum) end
        heightDragging=true; f:StartSizing("BOTTOM")
        heightGrip:SetScript("OnUpdate",function() if not IsMouseButtonDown("LeftButton") then StopHeightDrag() end end)
    end)
    heightGrip:SetScript("OnMouseUp",StopHeightDrag); heightGrip:SetScript("OnHide",StopHeightDrag)
    Tip(heightGrip,"heightResize","heightResizeHelp")
    local grip=CreateFrame("Button",nil,f); f.grip=grip; grip:SetSize(20,20); grip:SetPoint("BOTTOMRIGHT",-2,2)
    grip:SetFrameLevel(f:GetFrameLevel()+15)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    Tip(grip,"resize","resizeHelp")
    grip:SetScript("OnMouseDown",function(_,button) if button=="LeftButton" then StartResize() end end)
    grip:SetScript("OnMouseUp",function(_,button) if button=="LeftButton" then K.StopResize() end end)
    grip:SetScript("OnHide",K.StopResize)
    f:SetScript("OnSizeChanged",function() K.LayoutWindow() end)
    K.LayoutWindow()
    f:SetScript("OnShow",function() K.ApplyWindowScale();if not K.db.onboardingSeen then K.StartIntro(false) else K.Render() end end)
end
K.UnitWidgets={Selected=Selected,Box=Box,Text=Text,Button=Button,Tip=Tip,Switch=Switch,Rounded=Rounded}

-- Profile page shares the same widget pool and scrolling viewport.
do
local profileInputs={}
local profileSelection=1
local validationCode,profileStatus,applyArmed,deleteArmed,selectedArmed,fullArmed
local saveStatus,saveResultName,deleteStatus,deletedLabel
local transferStatus
local transferOpen=false
local pendingTransferCode
local function ProfileText(key) return K.L(key) end
function K.HideProfileInputs()
 if K.Profiles.profileMenu then K.Profiles.profileMenu:Hide() end
 for _,frame in pairs(profileInputs) do frame:Hide() end
end
function K.EndProfileSession()
 validationCode=nil;applyArmed=nil;deleteArmed=nil;selectedArmed=nil;fullArmed=nil;profileStatus=nil;saveStatus=nil;saveResultName=nil;deleteStatus=nil;deletedLabel=nil;transferStatus=nil
 K.Profiles.restoreArmed=nil;K.Profiles.deleteBackupArmed=nil
 for _,entry in pairs(profileInputs) do entry.edit:ClearFocus() end
 if profileInputs.code then profileInputs.code.edit:SetText("") end
end
local function ProfileInput(kind,parent,x,y,width,height)
 local entry=profileInputs[kind]
 if not entry then
  entry=CreateFrame(kind=="code" and "ScrollFrame" or "Frame",nil,parent,kind=="code" and "UIPanelScrollFrameTemplate" or nil)
  entry.edit=CreateFrame("EditBox",nil,entry,kind=="code" and nil or "InputBoxTemplate")
  entry.edit:SetAutoFocus(false);K.ApplyTextFont(entry.edit,13,false,"")
  entry.edit:SetMaxLetters(kind=="code" and K.Profiles.MAX_CODE+4096 or 48)
  entry.edit:SetMultiLine(kind=="code")
  entry.edit:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
  if kind=="code" then
   entry:SetScrollChild(entry.edit)
   entry.edit:SetWidth(width-18);entry.edit:SetHeight(height)
   entry.edit:SetScript("OnTextChanged",function(self,user)
    if user then
     validationCode=nil;applyArmed=nil;transferStatus="pfNeedsValidation"
     K.Profiles.validationInfo=nil
     local apply=K.Profiles.applyButton
     if apply then
      apply:Disable();apply.label:SetText(K.L("pfApply"))
      Rounded(apply,.14,.15,.14,nil,5,false);apply.label:SetTextColor(unpack(white))
     end
     if K.Profiles.transferStatusText then
      K.Profiles.transferStatusText:SetText(K.L("pfNeedsValidation"))
      K.Profiles.transferStatusText:SetTextColor(unpack(gold))
     end
    end
   end)
   entry.edit:SetScript("OnCursorChanged",function(self,_,cy,_,ch)
    local offset=entry:GetVerticalScroll();local pos=-cy
    if pos<offset then entry:SetVerticalScroll(math.max(0,pos))
    elseif pos+ch>offset+entry:GetHeight() then entry:SetVerticalScroll(pos+ch-entry:GetHeight()) end
   end)
  else entry.edit:SetAllPoints() end
  profileInputs[kind]=entry
 end
 entry:SetParent(parent);entry:ClearAllPoints();entry:SetPoint("TOPLEFT",x,y);entry:SetSize(width,height);entry:Show()
 return entry.edit
end
local function ProfileReport(key)
 profileStatus=key;C_Timer.After(0,function()
  if K.window:IsShown() then K.Render();if key=="pfQueued" then K.scroll:SetVerticalScroll(0) end end
 end)
end
local function RefreshProfilesInPlace()
 local offset=K.scroll:GetVerticalScroll()
 C_Timer.After(0,function()
  if K.window:IsShown() then K.Render();K.scroll:SetVerticalScroll(offset) end
 end)
end
local function TransferReport(key)
 transferStatus=key;profileStatus=nil
 RefreshProfilesInPlace()
end
local function ProfileDropdown(owner,entries)
 local menu=K.Profiles.profileMenu
 if menu and menu:IsShown() then menu:Hide();return end
 if not menu then
  menu=CreateFrame("Frame",nil,K.window,"BackdropTemplate");K.Profiles.profileMenu=menu
  Backdrop(menu,.10,.12,.10,{.43,.48,.38,1});menu:SetFrameStrata("DIALOG")
  menu.scroll=CreateFrame("ScrollFrame",nil,menu,"UIPanelScrollFrameTemplate")
  menu.scroll:SetPoint("TOPLEFT",8,-8);menu.scroll:SetPoint("BOTTOMRIGHT",-30,8)
  menu.content=CreateFrame("Frame",nil,menu.scroll);menu.content:SetWidth(636);menu.scroll:SetScrollChild(menu.content)
  menu.rows={}
 end
 menu:SetFrameLevel(K.window:GetFrameLevel()+80)
 menu:ClearAllPoints();menu:SetPoint("TOPLEFT",owner,"BOTTOMLEFT",0,-4)
 menu:SetSize(682,math.min(8,math.max(1,#entries))*34+16)
 menu.content:SetHeight(math.max(34,#entries*34))
 for _,row in ipairs(menu.rows) do row:Hide() end
 for i,entry in ipairs(entries) do
  local index=i
  local row=menu.rows[i]
  if not row then row=FixedButton(menu.content,"",0,-(i-1)*34,636,32,function() end);menu.rows[i]=row end
  row.label:SetText(K.L(entry.group=="named" and "pfNamed" or "pfCharacter")..": "..entry.key.." · "..(entry.record.class or ""))
  row:SetScript("OnClick",function()
   profileSelection=index;K.db.profileSelection={group=entry.group,key=entry.key};selectedArmed=nil;deleteArmed=nil;fullArmed=nil;menu:Hide();K.Render()
  end)
  row:Show()
 end
 menu.scroll:SetVerticalScroll(0);menu:Show()
end
function K.DrawProfilesPage()
 local P=K.Profiles
 if not P then return end
 if not P.ready then P.Initialize() end
 if P.failed then Text(page,K.L("pfFailed"),8,0,690,15,gold);page:SetHeight(130);return end
 P.transferStatusText=nil
 local y=0
 if K.ClassPresets and not K.db.profileTransaction then y=K.ClassPresets.Draw(page,{Box=Box,Text=Text,Button=Button},y) end
 local transferOffset=0
 local pending=K.db.profileTransaction~=nil
 if pending then
  local queued=Box(page,0,y,714,100)
  Text(queued,K.L("pfPendingActions"),16,-14,680,14,gold)
  Button(queued,K.L("reload"),16,-58,327,30,K.Reload)
  Button(queued,K.L("pfCancelPending"),365,-58,333,30,function()
   if P.CancelPending() then selectedArmed=nil;applyArmed=nil;ProfileReport("pfCancelled") end
  end)
  y=y-118
 end
 if P.deferredError or P.failedApply then
  Text(page,K.L("pfFailed"),8,y,690,14,gold);y=y-48
 end
 if K.FullLayout and K.FullLayout.status then
  Text(page,K.L(K.FullLayout.status),8,y,690,14,gold);y=y-100
 end
 if profileStatus and not pending then
 local status=profileStatus and ProfileText(profileStatus) or ProfileText("pfTransferHelp")
 if profileStatus=="pfValid" and P.validationInfo then status=P.validationInfo end
 P.statusText=Text(page,status,8,y,690,14,profileStatus=="pfInvalid" and {.9,.4,.3} or gold);y=y-90
 end
 Text(page,ProfileText("pfIntro"),8,y,690,13,muted);y=y-124
 local card=Box(page,0,y,714,162)
 Text(card,ProfileText("pfSaveName"),16,-12,660,14)
 local name=ProfileInput("name",card,22,-48,470,30)
 local save=Button(card,ProfileText("pfSave"),516,-46,182,34,function()
  if K.InCombat() then return end
  selectedArmed=nil
  local savedName=(name:GetText() or ""):match("^%s*(.-)%s*$")
  local ok,err=P.Save(savedName)
  if ok then
   K.db.profileSelection={group="named",key=savedName}
   name:SetText("");name:ClearFocus()
   if K.Message then K.Message("pfSaved") end
  end
  -- Keep save feedback next to its action and preserve the current viewport.
  deleteStatus=nil;deletedLabel=nil
  saveStatus=ok and "pfSaved" or err;saveResultName=ok and savedName or nil
  profileStatus=nil
  local offset=K.scroll:GetVerticalScroll()
  C_Timer.After(0,function()
   if K.window:IsShown() then K.Render();K.scroll:SetVerticalScroll(offset) end
  end)
 end)
 if pending then save:Disable() end
 if saveStatus then
  local success=saveStatus=="pfSaved"
  local color=success and {.55,.90,.55} or {.95,.48,.38}
  Rounded(card,.10,.13,.10,success and {.40,.73,.40,1} or {.82,.40,.30,1},8,true)
  local message=(saveResultName and (saveResultName..": ") or "")..ProfileText(saveStatus)
  P.saveStatusText=Text(card,message,22,-94,670,13,color)
 else P.saveStatusText=nil end
 y=y-182
 local entries=P.Entries()
 local remembered=K.db.profileSelection
 if type(remembered)=="table" then
  for index,entry in ipairs(entries) do
   if entry.group==remembered.group and entry.key==remembered.key then profileSelection=index;break end
  end
 end
 profileSelection=math.max(1,math.min(#entries,profileSelection))
 local selected=entries[profileSelection]
 local choose=Box(page,0,y,714,448)
 Text(choose,ProfileText("pfChoose"),16,-12,660,14)
 local label=selected and (ProfileText(selected.group=="named" and "pfNamed" or "pfCharacter")..": "..selected.key) or ProfileText("pfEmpty")
 local dropdown=Button(choose,label.."  ▾",16,-40,682,32,function(self) ProfileDropdown(self,entries) end)
 if not selected then dropdown:Disable() end
 if selected then Text(choose,date("%Y-%m-%d %H:%M",selected.record.stamp).." · "..(selected.record.class or ""),16,-78,660,12,muted) end
 if selected and K.ProfileLayouts then Text(choose,K.ProfileLayouts.Description(selected.record),16,-100,660,12,muted) end
 local notice=Text(choose,ProfileText(selectedArmed and "pfApplyWarning" or "pfSelectedHint"),16,-190,680,13,selectedArmed and gold or muted)
 local function HighlightApply(button)
  Rounded(button,.28,.23,.12,{.94,.77,.30,1},8,true)
  button.label:SetTextColor(1,.88,.52)
 end
 local use=Button(choose,ProfileText(selectedArmed and "pfConfirmApply" or "pfUseSelected"),16,-146,682,32,function(self)
  if not selected or K.InCombat() then return end
  if not selectedArmed then
   -- Cosmetic confirmation only: keep the clicked card and scroll position.
   selectedArmed=true;self.label:SetText(ProfileText("pfConfirmApply"));HighlightApply(self)
   notice:SetText(ProfileText("pfApplyWarning"));notice:SetTextColor(unpack(gold));return
  end
  local ok,err
  if K.ProfileLayouts then ok,err=K.ProfileLayouts.Queue(selected.record,selected.key) else ok,err=P.Apply(selected.record.code,selected.key) end
  selectedArmed=nil;ProfileReport(err or (ok and "pfQueued" or "pfFailed"))
 end)
 if selectedArmed then HighlightApply(use) end
 local load=Button(choose,ProfileText("pfLoadCode"),16,-250,327,30,function()
  if not selected then return end
  pendingTransferCode=selected.record.code;transferOpen=true
  validationCode=nil;applyArmed=nil;deleteArmed=nil;TransferReport("pfNeedsValidation")
  K.scroll:SetVerticalScroll(math.min(transferOffset,K.scroll:GetVerticalScrollRange()))
 end)
 local remove=Button(choose,ProfileText(deleteArmed and "pfConfirmDelete" or "pfDelete"),365,-250,333,30,function()
  if not selected or K.InCombat() then return end
  saveStatus=nil;saveResultName=nil;profileStatus=nil
  if not deleteArmed or deleteArmed.group~=selected.group or deleteArmed.key~=selected.key then
   deleteArmed={group=selected.group,key=selected.key};deleteStatus=nil;deletedLabel=nil
   RefreshProfilesInPlace();return
  end
  local ok=P.Delete(selected.group,selected.key)
  deletedLabel=label;deleteStatus=ok and "pfDeleted" or "pfFailed"
  deleteArmed=nil;selectedArmed=nil
  RefreshProfilesInPlace()
 end)
 if deleteArmed then
  Rounded(remove,.28,.12,.10,{.95,.48,.32,1},8,true)
  remove.label:SetTextColor(1,.75,.55)
  P.deleteStatusText=Text(choose,label..": "..ProfileText("pfConfirmDelete"),16,-294,680,13,{1,.75,.55})
 elseif deleteStatus then
  local color=deleteStatus=="pfDeleted" and {.55,.90,.55} or {.95,.48,.38}
  Rounded(choose,.10,.13,.10,deleteStatus=="pfDeleted" and {.40,.73,.40,1} or {.82,.40,.30,1},8,true)
  P.deleteStatusText=Text(choose,(deletedLabel or "")..": "..ProfileText(deleteStatus),16,-294,680,13,color)
 else P.deleteStatusText=nil end
 if not selected then load:Disable();remove:Disable();use:Disable() end
 if pending then use:Disable() end
 if selected then Text(choose,ProfileText("pfSourceHint"),16,-366,680,13,muted) end
 y=y-468
 transferOffset=-y
 Button(page,ProfileText("pfTransfer")..(transferOpen and "  ▴" or "  ▾"),0,y,714,36,function() transferOpen=not transferOpen;K.Render() end)
 y=y-48
 if transferOpen then
 local transfer=Box(page,0,y,714,374)
 Text(transfer,ProfileText("pfTransfer"),16,-12,660,15)
 local edit=ProfileInput("code",transfer,18,-44,654,144)
 if pendingTransferCode then edit:SetText(pendingTransferCode);pendingTransferCode=nil end
 local function generate()
  if K.InCombat() then return end
  local code,err=P.Encode(P.Capture())
  if not code then TransferReport(err);return end
  edit:SetText(code);edit:SetFocus();edit:HighlightText()
  validationCode=nil;applyArmed=nil;TransferReport("pfGenerated")
 end
 Button(transfer,ProfileText("pfGenerate"),16,-204,218,34,generate)
 Button(transfer,ProfileText("pfValidate"),246,-204,218,34,function()
  local value,err=P.Decode(edit:GetText())
  validationCode=value and edit:GetText() or nil;applyArmed=nil
  if value then
   local n=0;for key in pairs(value.settings) do if key~="root" and key~="appearance" then n=n+1 end end
   P.validationInfo=string.format(ProfileText("pfValidated"),value.class,n)
   TransferReport("pfValid")
  else P.validationInfo=nil;TransferReport(err) end
 end)
 local apply=Button(transfer,ProfileText(applyArmed and "pfConfirmApply" or "pfApply"),476,-204,222,34,function()
  if validationCode~=edit:GetText() then TransferReport("pfNeedsValidation");return end
  if K.InCombat() then return end
  if not applyArmed then applyArmed=true;TransferReport("pfApplyWarning");return end
  local ok,err=P.Apply(validationCode,ProfileText("pfBeforeApply"))
  applyArmed=nil
  if ok then transferStatus=nil;ProfileReport(err or "pfQueued")
  else TransferReport(err or "pfFailed") end
 end)
 if applyArmed then
  Rounded(apply,.28,.23,.12,{.94,.77,.30,1},8,true)
  apply.label:SetTextColor(1,.88,.52)
 end
 local message=transferStatus and ProfileText(transferStatus) or ProfileText("pfTransferHelp")
 if transferStatus=="pfValid" and P.validationInfo then message=P.validationInfo end
 local success=transferStatus=="pfValid"
 local warning=not transferStatus or transferStatus=="pfGenerated" or transferStatus=="pfNeedsValidation" or transferStatus=="pfApplyWarning"
 local color=success and {.55,.90,.55} or (warning and gold or {.95,.48,.38})
 P.transferStatusText=Text(transfer,message,16,-254,680,13,color)
 if validationCode~=edit:GetText() or pending then apply:Disable() end
 P.applyButton=apply
 y=y-394
 end
 local backup=K.db.profileBackup
 local backupCard=Box(page,0,y,714,140)
 Text(backupCard,ProfileText("pfBackup"),16,-12,660,15)
 Text(backupCard,backup and (date("%Y-%m-%d %H:%M",backup.stamp).." · "..(backup.name or "")) or ProfileText("pfNoBackup"),16,-44,660,13,muted)
 local restore=Button(backupCard,ProfileText(P.restoreArmed and "pfConfirmRestore" or "pfRestore"),16,-88,327,34,function()
  if K.InCombat() then return end
  if not P.restoreArmed then P.restoreArmed=true;ProfileReport("pfRestoreWarning");return end
  P.restoreArmed=nil;local ok,err=P.RestoreBackup();ProfileReport(err or (ok and "pfQueued" or "pfFailed"))
 end)
 local forget=Button(backupCard,ProfileText(P.deleteBackupArmed and "pfConfirmDelete" or "pfDeleteBackup"),365,-88,333,34,function()
  if K.InCombat() then return end
  if not P.deleteBackupArmed then P.deleteBackupArmed=true;K.Render();return end
  K.db.profileBackup=nil;P.deleteBackupArmed=nil;P.restoreArmed=nil;ProfileReport("pfDeleted")
 end)
 if not backup or pending then restore:Disable();forget:Disable() end
 y=y-160
 Text(page,ProfileText("pfBackupHelp"),8,y,690,13,muted);y=y-92
 local count=#entries
 Text(page,string.format(ProfileText("pfStorage"),P.StorageBytes()/1024,P.MAX_TOTAL/1024,count),8,y,690,13,gold);y=y-40
 Text(page,ProfileText("pfStorageHelp"),8,y,690,13,muted)
 page:SetHeight(-y+120)
end

end
