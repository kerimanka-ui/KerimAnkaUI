-- Classic Era/Hardcore only: no execution in Forever or Retail.
local _, K = ...
local panelDefaults=K.panelDefaults
local font = "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-R.ttf"
local boldFont = "Interface\\AddOns\\KerimAnkaUI\\Fonts\\Ubuntu-B.ttf"
local gold, white, muted = {0.73,0.62,0.41}, {0.9,0.91,0.88}, {0.59,0.63,0.61}
local pool, used, labels, labelUsed = {}, 0, {}, 0
local nav, tabs = {}, {}
local textSizeButtons={}
local languageButton, languageMenu, languageDismiss
local UpdateLanguageLabel
local page, subtitle, heading, footer
local selection, section = "home", "overview"
local search = {active=false, position=0, targets={}}
local appearanceFields={{"glowStrength",0,1,.05,.45},{"glowRadius",4,20,1,10},{"glowRed",0,1,.05,0,1},{"glowGreen",0,1,.05,0,2},{"glowBlue",0,1,.05,0,3},{"cardTone",.6,1.8,.05,1}}

function search.Anchor(key, frame)
    local entry=search.destination
    if entry and (entry.key==key or entry.modeKey==key) then search.targets[key]=frame end
end
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
    text:SetWidth(width);text:SetHeight(0); K.ApplyTextFont(text,size or 13,false,""); text:SetTextColor(unpack(color or white))
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
    frame:SetAlpha(1)
    if frame.homeThumb then frame.homeThumb:Hide()end
    if frame.skinPreview then frame.skinPreview:Hide() end
    if frame.mbRowIcon then frame.mbRowIcon:Hide() end
    if frame.arSwatch then frame.arSwatch:Hide() end
    if frame.backingSwatch then frame.backingSwatch:Hide()end
    if frame.cursorSwatch then frame.cursorSwatch:Hide()end
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

-- Session-only presentation state. Expanding a group never changes gameplay settings.
local homeOpen={fps=true,modules=true,audio=true,shortcut=false,cast=false,swing=false,custom=false}
local function HomeRefresh()
 local position=K.scroll:GetVerticalScroll();K.HideTooltip();K.Render()
 K.scroll:SetVerticalScroll(math.min(position,K.scroll:GetVerticalScrollRange()))
end
local function HomeSwitch(parent,value,x,y,callback,available)
 local b=Button(parent,'',x,y,76,26,function()callback(not value);HomeRefresh()end)
 Rounded(b,value and .30 or .25,value and .49 or .28,value and .27 or .24,nil,12,false)
 if not b.homeThumb then b.homeThumb=CreateFrame('Frame',nil,b,'BackdropTemplate');b.homeThumb:EnableMouse(false)end
 local t=b.homeThumb;t:ClearAllPoints();t:SetPoint('TOPLEFT',value and 53 or 3,-3);t:SetSize(20,20)
 t:SetFrameLevel(b:GetFrameLevel()+1);Rounded(t,.86,.90,.83,{.79,.84,.75,1},10,false);t:Show()
 b.label:ClearAllPoints();b.label:SetPoint(value and 'LEFT'or'RIGHT',value and 5 or -5,0)
 b.label:SetWidth(44);K.ApplyTextFont(b.label,9,true,'');b.label:SetText(K.L(value and'on'or'off'));local textWidth=b.label:GetStringWidth();if textWidth>44 then K.ApplyTextFont(b.label,9*44/textWidth,true,'')end;b.label:SetTextColor(unpack(white))
 b:SetAlpha(available==false and .45 or 1);if available==false then b:Disable()end
 return b
end
local function HomeToggle(parent,key,x,y,width,value,callback,available)
 local c=Box(parent,x,y,width,64)
 search.Anchor(key,c)
 local title=Text(c,K.L(key),13,-13,width-142,13,white);title:SetHeight(44)
 Help(c,key,width-124,-20);HomeSwitch(c,value,width-90,-19,callback,available)
 return c
end
local function HomeFold(id,title,y,draw)
 local header=Button(page,'',0,y,714,42,function()homeOpen[id]=not homeOpen[id];HomeRefresh()end)
 Text(header,K.L(title),13,-12,650,15,gold)
 Text(header,homeOpen[id]and'−'or'+',677,-10,24,18,white)
 y=y-54
 if homeOpen[id]then y=draw(y)end
 return y-12
end
local function HomeNumber(key,cvar,x,y,width,low,high,step,format)
 local c=Box(page,x,y,width,94);Text(c,K.L(key),13,-13,width-55,14,white);Help(c,key,width-35,-11)
 search.Anchor(key,c)
 local current=tonumber(K.GetCVar(cvar))
 Text(c,current and string.format(format,current)or K.L('unavailable'),13,-51,width-117,22,white)
 for i,direction in ipairs({-1,1})do
  local delta=direction
  local button=Button(c,delta<0 and'−'or'+',width-94+(i-1)*43,-49,35,30,function()
   if current then K.SetCVar(cvar,math.max(low,math.min(high,math.floor((current+delta*step)/step+.5)*step)))end
   HomeRefresh()
  end)
  if not current then button:Disable()end
 end
end
local function HomeWidgets()
 local widgets={};for key,value in pairs(K.UnitWidgets)do widgets[key]=value end
 widgets.Switch=HomeSwitch
 return widgets
end
local function Overview()
 HomeNumber('zoom','cameraDistanceMaxZoomFactor',0,0,349,1,2.6,.1,'%.1f ×')
 HomeNumber('queue','SpellQueueWindow',365,0,349,0,1000,10,'%.0f ms')
 HomeToggle(page,'errors',0,-108,349,K.db.hideErrors,function(v)K.SetErrors(v)end,UIErrorsFrame~=nil)
 HomeToggle(page,'clicks',365,-108,349,K.db.muteClicks,function(v)K.SetClicks(v)end,MuteSoundFile~=nil and UnmuteSoundFile~=nil)
 local death=K.GetCVar('ffxDeath')
 HomeToggle(page,'disableDeathEffect',0,-184,714,death=='0',function(v)K.SetCVar('ffxDeath',v and 0 or 1)end,death~=nil)
 local y=HomeFold('fps','fpsTitle',-264,function(at)
  local fps=K.FPS;if not fps then Text(page,K.L('unavailable'),13,at,680,13,muted);return at-40 end
  local allowed=not InCombatLockdown()
  HomeToggle(page,'fpsShow',0,at,349,fps.Get('enabled'),function(v)fps.Set('enabled',v)end,allowed)
  HomeToggle(page,'fpsLock',365,at,349,fps.Get('locked'),function(v)fps.Set('locked',v)end,allowed)
  HomeToggle(page,'fpsShowMS',0,at-76,349,fps.Get('showMS'),function(v)fps.Set('showMS',v)end,allowed)
  local reset=Button(page,K.L('fpsReset'),365,at-90,349,34,function()fps.ResetPosition();HomeRefresh()end)
  if not allowed then reset:Disable()end
  Text(page,K.L('fpsHomeHelp'),10,at-154,694,12,muted):SetHeight(48)
  return at-210
 end)
 y=HomeFold('modules','state',y,function(at)
  local modules=K.VisibleModules()
  for i,module in ipairs(modules)do
   local entry=module;local status=K.ModuleStatus(module)
   if module.key=='quests'and ForeverQuestJournalAPI and ForeverQuestJournalAPI.IsSuspended and ForeverQuestJournalAPI.IsSuspended()then status='homeSuspended'end
   local x=i%2==1 and 0 or 365;local yy=at-math.floor((i-1)/2)*58
   local button=Button(page,'',x,yy,349,48,function()selection=entry.key;K.scroll:SetVerticalScroll(0);K.Render()end)
   Text(button,K.L(module.key=='details'and'dmDetails'or module.key),12,-8,325,13,white)
   Text(button,K.L(status),12,-28,325,11,status=='loaded'and{.58,.76,.48}or muted)
  end
  return at-math.ceil(#modules/2)*58
 end)
 page:SetHeight(-y+12)
end
local function Combat()
 HomeNumber('queue','SpellQueueWindow',0,0,714,0,1000,10,'%.0f ms')
 Text(page,K.L('queueHelp'),12,-108,690,13,muted):SetHeight(52)
 page:SetHeight(200)
end
local function Alerts()
    local widgets=HomeWidgets()
    widgets.SearchAnchor=search.Anchor
    local y=K.DrawErrorOptions(page,widgets)
    local death=K.GetCVar('ffxDeath')
    HomeToggle(page,'disableDeathEffect',0,y-24,714,death=='0',function(v)K.SetCVar('ffxDeath',v and 0 or 1)end,death~=nil)
    page:SetHeight(-y+120)
end
local idEdit
local soundFeedbackKey,soundFeedbackId
local soundShortcutSizeLabels={
    en="Sound shortcut size",tr="Ses kısayolu boyutu",de="Größe der Tonverknüpfung",
    frFR="Taille du raccourci audio",itIT="Dimensione scorciatoia audio",esES="Tamaño del acceso directo de sonido",
    ptBR="Tamanho do atalho de som",ruRU="Размер ярлыка звука",zhCN="声音快捷按钮大小",
}
for language,label in pairs(soundShortcutSizeLabels) do K.locales[language].soundShortcutSize=label end
local function DrawSoundShortcutSize(shortcut,y)
    local card=Box(page,0,y,714,82)
    search.Anchor("soundShortcutSize",card)
    Text(card,K.L("soundShortcutSize"),14,-12,540,14)
    local value=Text(card,tostring(shortcut.Get("size")),14,-48,170,16)
    for i,delta in ipairs({-2,2}) do
        local step=delta
        local button=Button(card,step<0 and "−" or "+",610+(i-1)*43,-39,36,30,function()
            if shortcut.Set("size",shortcut.Get("size")+step) then value:SetText(tostring(shortcut.Get("size"))) end
        end)
        if K.InCombat() then button:Disable() end
    end
    return y-96
end
local function RefreshSoundSettings()
    local offset=K.scroll:GetVerticalScroll()
    K.Render();K.scroll:SetVerticalScroll(offset)
end
local function Sounds()
    Text(page,K.L('soundInfo'),0,0,714,13,muted):SetHeight(44)
    local y=HomeFold('audio','homeAudio',-58,function(at)
        HomeToggle(page,'clicks',0,at,714,K.db.muteClicks,function(v)K.SetClicks(v)end,MuteSoundFile~=nil and UnmuteSoundFile~=nil)
        at=at-76
        for i,option in ipairs(K.soundOptions)do
            local entry=option;local value=K.GetCVar(entry.cvar)
            HomeToggle(page,entry.key,i%2==1 and 0 or 365,at-math.floor((i-1)/2)*76,349,value=='0',function(v)K.SetCVar(entry.cvar,v and 0 or 1)end,value~=nil)
        end
        return at-math.ceil(#K.soundOptions/2)*76
    end)
    if K.SoundShortcut then
        y=HomeFold('shortcut','soundShortcutShow',y,function(at)
            local shortcut=K.SoundShortcut
            HomeToggle(page,'soundShortcutShow',0,at,349,shortcut.Get('enabled'),function(v)shortcut.Set('enabled',v)end,true)
            HomeToggle(page,'soundShortcutLock',365,at,349,shortcut.Get('locked'),function(v)shortcut.Set('locked',v)end,true)
            at=at-82
            at=DrawSoundShortcutSize(shortcut,at)
            Button(page,K.L('soundShortcutReset'),0,at,714,34,function()shortcut.ResetPosition();HomeRefresh()end)
            return at-50
        end)
    end
    if K.DrawSoundGroups then y=K.DrawSoundGroups(page,{Box=Box,Text=Text,Button=Button,Tip=Tip},y,RefreshSoundSettings,search.destination,search.Anchor)-12 end
    local customHeader=Button(page,'',0,y,714,42,function()homeOpen.custom=not homeOpen.custom;HomeRefresh()end)
    Text(customHeader,K.L('custom'),13,-12,650,15,gold);Text(customHeader,homeOpen.custom and'−'or'+',677,-10,24,18,white)
    y=y-54
    if not homeOpen.custom then page:SetHeight(-y+20);return end
    Help(page,"custom",680,y+3)
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
    search.Anchor("scale",card)
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
    HomeToggle(page,"launcher",0,-148,714,not KerimAnkaUIDB.minimap.hide,function(v)
        KerimAnkaUIDB.minimap.hide = not v; K.UpdateLauncher()
    end,true)
    HomeToggle(page,"cardGlow",0,-222,714,KerimAnkaUIDB.cardGlow ~= false,function(v)
        KerimAnkaUIDB.cardGlow=v
    end,true)
    HomeToggle(page,"hideActionBarStatues",0,-296,714,K.db.hideActionBarStatues==true,function(v)
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
        search.Anchor(preset[1],presetButton)
        local color=KerimAnkaUIDB.glowColor or {0,0,0}
        local matches=KerimAnkaUIDB.cardGlow~=false and math.abs((KerimAnkaUIDB.glowStrength or .45)-preset[3])<.001
        for component=1,3 do if math.abs(color[component]-preset[2][component])>.001 then matches=false end end
        Selected(presetButton,matches)
    end
    y=y-52
    for i,field in ipairs(appearanceFields) do
        local key,low,high,step,default,component=unpack(field)
        local c=Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
        search.Anchor(key,c)
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
    y=y-math.ceil(#appearanceFields/2)*96
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
    local switch=(module.key=='backdrop'or module.key=='art'or module.key=='details'or module.key=='threat'or module.key=='range'or module.key=='aspect')and HomeSwitch or Switch
    switch(card,enabled,620,-44,function(value) K.ToggleModule(module,value) end,exists and K.ModuleApplicable(module))
    page:SetHeight(-y+110)
end
local function Module(module)
    if module.key=="details" and K.DrawDamageMetersPage then
        if K.DrawDamageMetersPage(page,search.destination,search.Anchor) then AddonControls(module) end
        return
    end
    local exists, enabled, loaded=K.ModuleState(module)
    if loaded and K.ModuleApplicable(module) then
        if (module.key=="backdrop" or module.key=="art") and K.DrawActionBarPage and K.DrawActionBarPage(page,module.key,search.destination,search.Anchor) then AddonControls(module); return end
        if module.key=="units" and K.DrawUnitsPage and ForeverLeatherUnitsAPI and ForeverLeatherUnitsAPI.version>=2 and ForeverLeatherUnitsAPI.GetSettings() then
            K.DrawUnitsPage(page,function()if not K.UnitSettingsView then AddonControls(module)end end); return
        end
        if module.key=="quests" and K.DrawQuestPage and K.DrawQuestPage(page,search.Anchor) then AddonControls(module); return end
        if module.key=="details" and K.DrawDetailsPage and K.DrawDetailsPage(page) then AddonControls(module); return end
        if module.key=="range" and K.DrawRangePage and K.DrawRangePage(page,search.Anchor) then AddonControls(module); return end
        if module.key=="threat" and K.DrawThreatPage and K.DrawThreatPage(page,search.destination,search.Anchor) then AddonControls(module); return end
        if module.key=="aspect" and K.DrawAspectPage and K.DrawAspectPage(page,search.Anchor) then AddonControls(module); return end
    end
    local card=Box(page,0,0,714,110)
    Text(card,module.addon,18,-18,670,19,gold)
    Text(card,K.L(K.ModuleStatus(module)),18,-59,670,16,K.ModuleStatus(module)=="loaded" and {0.58,0.76,0.48} or muted)
    ToggleRow("addonControl",-126,function() return enabled end,function(v) K.ToggleModule(module,v) end,exists and K.ModuleApplicable(module))
    Text(page,K.L("dependency"),12,-211,690,13,muted)
    Text(page,K.L(not K.ModuleApplicable(module) and "hunterOnlyHelp" or not loaded and "inactiveHelp" or module.key=="units" and "ufUpdate" or module.key=="backdrop" and "abUpdate" or module.key=="quests" and "qjUpdate" or module.key=="details" and "dtUpdate" or module.key=="range" and "hrUpdate" or module.key=="threat" and "ftUpdate" or module.key=="aspect" and "aaUpdate" or "bridge"),12,-257,690,15)
    page:SetHeight(430)
end

local chatResetArmed=false
local chatSettingsTab='appearance'
local function ChatPage()
 local C=K.Chat;if not C then return end
 local tabNames={{'appearance','csAppearance'},{'layout','csLayout'},{'visibility','csVisibility'},{'micro','csMicro'}}
 for i,entry in ipairs(tabNames)do
  local id=entry[1]
  local button=Button(page,K.L(entry[2]),(i-1)*180,0,174,36,function()
   chatSettingsTab=id;chatResetArmed=false;K.scroll:SetVerticalScroll(0);K.Render()
  end)
  Selected(button,chatSettingsTab==id)
 end
 local d=C.ManagedBounds()
 if not d then Text(page,K.L('unavailable'),12,-65,690,14,muted);page:SetHeight(140);return end
 local function Toggle(label,y,value,apply,help,key)
  local box=Box(page,0,y,714,64)
  search.Anchor(key,box)
  Text(box,label,13,-14,550,14,white):SetHeight(40)
  if help then
   local question=Button(box,'?',584,-19,22,26,function()end)
   question:SetScript('OnEnter',function(self)K.ShowTooltip(self,label,help)end);question:SetScript('OnLeave',K.HideTooltip)
  end
  HomeSwitch(box,value,624,-19,function(v)if apply(v)~=false then chatResetArmed=false end end,not InCombatLockdown())
 end
 local function Number(key,label,x,y,step)
  local default=key=='microSize'and 32 or 4;local value=math.floor(d[key]or default)
  local box=Box(page,x,y,349,94);Text(box,label,13,-13,310,14,white)
  search.Anchor(key,box)
  Text(box,tostring(value),13,-53,220,21,white)
  for i,delta in ipairs({-step,step})do
   local change=delta
   local button=Button(box,delta<0 and'−'or'+',255+(i-1)*43,-51,35,30,function()
    if C.SetLayout(key,(d[key]or default)+change)then C.Refresh();HomeRefresh()end
   end)
   if InCombatLockdown()then button:Disable()end
  end
 end
 if chatSettingsTab=='appearance'then
  Text(page,C.Text('Hazır temalar','Preset themes'),12,-60,690,18,gold)
  Text(page,C.Text('Tema tüm chat pencerelerine uygulanır. Serbest renk seçimi kapalıdır.','The theme applies to all chat windows. Free color selection is disabled.'),12,-91,690,13,muted):SetHeight(40)
  for i,t in ipairs(C.themes)do
   local id=i;local selected=C.ThemeID()==id
   local card=Button(page,'',(i-1)*243,-140,228,148,function()if C.SetTheme(id)~=false then chatResetArmed=false;HomeRefresh()end end)
   search.Anchor('chatTheme:'..t.en,card)
   Selected(card,selected)
   local preview=Box(card,12,-12,204,62);Rounded(preview,t.body[1],t.body[2],t.body[3],{.3,.33,.29,1},5,false)
   Text(card,C.Text(t.name,t.en),12,-85,204,14,white):SetHeight(30)
   if selected then Text(card,C.Text('Seçili','Selected'),12,-120,204,12,gold)end
  end
  Text(page,C.Text('Yazı boyutu, filtre ve kanallar için sekmeye sağ tıkla; bu işlemler Blizzard menüsünde kalır.','Right-click a tab for font size, filters and channels; these remain in the Blizzard menu.'),12,-308,690,13,muted):SetHeight(48)
  Toggle(C.Text('Kanal türüne göre sekme renkleri: ','Tab colors by channel type: '):gsub(':%s*$',''),-372,d.channelColors,function(v)return C.SetChannelColors(v)end,nil,'channelColors')
  Text(page,C.Text('Lonca yeşil, grup mavi, raid ve savaş kaydı sıcak tonlar. Karışık kanallar nötr kalır.','Guild is green, party blue, raid and combat log warm tones. Mixed channels stay neutral.'),12,-450,690,13,muted):SetHeight(44)
  local bottom=HomeFold('chatReset','csReset',-510,function(y)
   Text(page,C.Text('Chat görünümü, konumu ve boyutu sıfırlanacak. Mesajlar, kanallar ve filtreler korunur. Onaylamak için tekrar bas.','Chat appearance, position and size will reset. Messages, channels and filters are preserved. Press again to confirm.'),12,y,690,13,chatResetArmed and gold or muted):SetHeight(58)
   local reset=Button(page,chatResetArmed and C.Text('Onayla: tüm Chat ayarlarını sıfırla','Confirm: reset all Chat settings')or C.Text('Chat görünümünü varsayılana döndür','Restore default Chat settings'),0,y-72,714,36,function()
    if chatResetArmed then if C.ResetChatSettings()then chatResetArmed=false end else chatResetArmed=true end;HomeRefresh()
   end)
   if InCombatLockdown()then reset:Disable()end
   if chatResetArmed then Button(page,C.Text('Vazgeç','Cancel'),0,y-120,714,34,function()chatResetArmed=false;HomeRefresh()end)end
   return y-(chatResetArmed and 170 or 122)
  end)
  page:SetHeight(-bottom+12)
 elseif chatSettingsTab=='layout'then
  Text(page,K.L('csLayout'),12,-60,690,18,gold)
  local modes={{'Otomatik','Automatic'},{'Dikey','Vertical'},{'Yatay','Horizontal'}}
  for i,n in ipairs(modes)do local id=i
   local choice=Button(page,C.Text(n[1],n[2]),(i-1)*240,-101,232,34,function()C.SetLayout('controlMode',id);HomeRefresh()end)
   search.Anchor('chatMode:'..n[2],choice)
   Selected(choice,(d.controlMode or 1)==id);if InCombatLockdown()then choice:Disable()end
  end
  Number('width',C.Text('Genişlik','Width'),0,-155,10);Number('height',C.Text('Yükseklik','Height'),365,-155,10)
  local edit=Button(page,C.Text('Konumu düzenle','Edit position'),0,-270,350,36,function()C.OpenEditor()end)
  if InCombatLockdown()then edit:Disable()end
  Toggle(C.Text('Boyut tutamacı: ','Resize handle: '):gsub(':%s*$',''),-326,d.unlocked,function(v)return C.SetLayout('unlocked',v)end,nil,'unlocked')
  Text(page,C.Text('Sol düğme aralıkları sabittir. Otomatik düzen kısa pencerede yataya geçer.','Side button spacing is fixed. Automatic layout turns horizontal in short windows.'),12,-411,690,13,muted):SetHeight(52)
  page:SetHeight(480)
 elseif chatSettingsTab=='visibility'then
  Text(page,K.L('csVisibility'),12,-60,690,18,gold)
  Text(page,C.Text('Mouse uzaktayken görünürlük','Visibility away from the chat'),12,-95,690,14,white)
  local modes={{'Her zaman görünür','Always visible'},{'Yazılar görünür','Messages visible'},{'Tamamen gizle','Hide all'}}
  for i,n in ipairs(modes)do local id=i
   local choice=Button(page,C.Text(n[1],n[2]),(i-1)*240,-140,232,36,function()C.SetVisibilityMode(id);chatResetArmed=false;HomeRefresh()end)
   search.Anchor('chatVisibility:'..n[2],choice)
   Selected(choice,(d.visibilityMode or 1)==id);if InCombatLockdown()then choice:Disable()end
  end
  local description=({'csAlwaysHelp','csMessagesHelp','csHideHelp'})[d.visibilityMode or 1]or'csAlwaysHelp'
  local box=Box(page,0,-198,714,154);Text(box,K.L(description),14,-16,686,14,white):SetHeight(60)
  Text(box,C.Text('Mouse ile üzerine gelince veya yazarken görünür. Savaşta ve düzenlenirken gizlenmez.','Reveals on hover or while typing. Stays visible in combat and while editing.'),14,-89,686,13,muted):SetHeight(52)
  page:SetHeight(378)
 else
  Text(page,K.L('csMicro'),12,-60,690,18,gold)
  Toggle(C.Text('Mikro menü: ','Micro menu: '):gsub(':%s*$',''),-104,K.InventoryMenus.Get('microEnabled')==true,function(v)return K.InventoryMenus.Set('microEnabled',v)end,nil,'microEnabled')
  Number('microSize',C.Text('Alt menü boyutu','Micro menu size'),0,-191,1)
  Number('microGap',C.Text('Alt menü aralığı','Micro menu spacing'),365,-191,1)
  page:SetHeight(312)
 end
end
-- Only these settings have verified routes and anchors in the prototype.
local searchGroups = {
    {"home","overview",nil,{"zoom","queue","errors","clicks","disableDeathEffect"}},
    {"home","overview","fps",{"fpsShow","fpsLock","fpsShowMS"},"FPS"},
    {"home","combat",nil,{"queue"}},
    {"home","alerts",nil,{"disableDeathEffect","errorShowAll","errorImportantOnly","errorCustom"}},
    {"home","sounds","audio",{"clicks"}},
    {"home","sounds","shortcut",{"soundShortcutShow","soundShortcutLock"},"SoundShortcut"},
    {"interface",nil,nil,{"scale","launcher","cardGlow","hideActionBarStatues"}},
}
local cursorSearch={
    {"cursorHelp",{"cursorEnabled","cursorRing","cursorSquare","cursorPlus","cursorReticle","cursorLight",
        "cursorSize","cursorAlpha","cursorColor","cursorAlways","cursorCombat","cursorPeace"}},
    {"cursorCameraHelp",{"cursorCamera","cursorDotCamera"}},
    {"cursorTimingHelp",{"cursorGCD","cursorCast","cursorGCDGap","cursorCastGap","cursorThickness","cursorCountdown"}},
    {"cursorEffectsHelp",{"cursorDot","cursorTrail","cursorRibbon","cursorSparkles","cursorRibbonSparkles",
        "cursorNativeBlueFlow","cursorNativeBlueArc","cursorNativeGreenArc"}},
    {"cursorNativeHelp",{"cursorNativeScale","cursorNativeAlpha","cursorNativeX","cursorNativeY"}},
    {"cursorNativePolicyHelp",{"cursorNativeCamera","cursorNativeFadeIdle"}},
}
local rangeSearch={
    {"hrHelp",{"hr_enabled","hr_locked","hr_coloredText","hr_outline","hr_shadow",
        "hr_width","hr_height","hr_fontSize","hr_x","hr_y"}},
    {"hunterTextHelp",{"hunterRange_ranged","hunterRange_dead","hunterRange_melee","hunterRange_far","hunterRange_close","hunterRange_unknown"}},
}
local aspectSearch={
    {"aaHelp",{"aaEnabled","aaLock","aaText","aaGlow"}},
    {"aaHideMountedHelp",{"aaHideMounted"}},
    {"hunterTextHelp",{"aaCheetah","aaPack","aaMissing"}},
}
local threatSearch={
    {"general","ftGroupGeneral","ftHelp",{"ft_enabled","ft_locked","ft_raw","ft_showPercent"}},
    {"appearance","ftGroupAppearance","ftHelp",{"ft_autoColor","ft_bold","ft_outline","ft_shadow","ft_size","ft_alpha"}},
    {"appearance","ftGroupAppearance","ftFontHelp",{"ftFont"}},
    {"appearance","ftGroupAppearance","ftColorHelp",{"ftGold","ftWhite","ftGreen","ftRed","ftBlue"}},
    {"position","ftGroupPosition","ftHelp",{"ft_x","ft_y"}},
}
local meterSearch={
    {"blizzard","dmBlizzard","dmHelp",{"dmEnabled","dmTrim","dmTrimAlpha","dmBackground","dmPadding"}},
    {"blizzard","dmBlizzard","dmEdgeHelp",{"dmEdgeTop","dmEdgeBottom","dmEdgeLeft","dmEdgeRight"}},
    {"details","dmDetails","dtHelp",{"dtTrim","dtFonts","dtAlpha"}},
    {"details","dmDetails","dmEdgeHelp",{"dmEdgeTop","dmEdgeBottom","dmEdgeLeft","dmEdgeRight"}},
    {"details","dmDetails","dtSelection",{"dtWindows"}},
    {"tracker","atTab","atHelp",{"atEnable","atGCD","atMelee","atRanged","atCount","atSize","atGap","atAlpha","atLock"}},
    {"tracker","atTab","atHelp",{"atRight","atLeft","atDown","atUp"},"atDirection"},
}
local function MeterResultAvailable(entry)
    if not K.DrawDamageMetersPage then return false end
    if entry.tab=="blizzard" then return K.NativeMeter~=nil end
    if entry.tab=="tracker" then return K.DrawActionTrackerPage~=nil end
    local api=ForeverDetailsHunterAPI
    return api and api.version>=1 and api.GetSettings()~=nil and
        (entry.key~="details:dtWindows" or #api.GetWindows()>0)
end
local function ThreatResultAvailable()
    return K.DrawThreatPage and ForeverThreatAPI and ForeverThreatAPI.GetSettings()~=nil
end
local questSearch={
    {"qjQuestieTracker","qjQuestieHelp"},{"qjScrollEnabled","qjNativeHelp"},
    {"qjShowAllQuests","qjShowAllQuestsHelp"},{"qjGroupByZone","qjZoneHelp"},{"qjScrollStep","qjNativeHelp"},
}
local function SearchModuleLoaded(category)
    for _,module in ipairs(K.modules) do
        if module.key==category then
            local _,_,loaded=K.ModuleState(module)
            return loaded and K.ModuleApplicable(module)
        end
    end
    return false
end
local function QuestResultAvailable(entry)
    return K.DrawQuestPage and K.QuestSettingVisible and SearchModuleLoaded(entry.category) and K.QuestSettingVisible(entry.key)
end
local backdropSearch={
    {"appearance","bdAppearance","abHelp",{"abShow","abShade","abBorder","abSlot"}},
    {"appearance","bdAppearance","bdSharedColorHelp",{"backingColorTitle"}},
    {"labels","bdLabels","hideNativeHotkeysHelp",{"hideNativeHotkeys"}},
    {"labels","bdLabels","hideNativeMacroNamesHelp",{"hideNativeMacroNames"}},
    {"labels","bdLabels","arHelp",{"arEnabled","arColor"}},
    {"bars","bdBars","bdScopeHelp",{"bdStyledBars"}},
}
local function BackdropResultAvailable(entry)
    return K.DrawActionBarPage and K.BackdropSettingVisible and SearchModuleLoaded(entry.category) and K.BackdropSettingVisible(entry.key)
end
local classArtSearch={
    {"design","artPageDesign","abArtHelp",{"abArt"}},
    {"design","artPageDesign","hideActionBarStatuesHelp",{"hideActionBarStatues"}},
    {"design","artPageDesign","artSkinHelp",{"artSkins"}},
    {"design","artPageDesign","art_artExtraHelp",{"artSelectedDetails"},"details"},
    {"design","artPageDesign","artPetHelp",{"artPetGroup"},"pet"},
    {"design","artPageDesign","bdSharedColorHelp",{"backingColorTitle"},"color"},
    {"layout","artPageLayout","abArtHelp",{"abLock","abFollow","abWidth","abHeight","abX","abY","abAlpha","abGap"}},
    {"bars","artPageBars","barsSourceHelp",{"barsSource"}},
    {"bars","artPageBars","artScopeHelp",{"artDecoratedBars"}},
}
local function ClassArtResultAvailable(entry)
    return K.DrawActionBarPage and K.ClassArtSettingVisible and SearchModuleLoaded(entry.category) and K.ClassArtSettingVisible(entry.key)
end
local function HunterResultAvailable(entry)
    if select(2,UnitClass("player"))~="HUNTER" then return false end
    local api
    if entry.category=="range" then
        api=ForeverHunterRangeAPI
        if not api or api.version<1 or not K.DrawRangePage then return false end
    else
        api=HunterAspectAlertAPI
        if not api or not K.DrawAspectPage then return false end
    end
    local settings=api.GetSettings()
    if not settings then return false end
    if entry.key=="hr_showNumericRange" then
        return settings.showNumericRange~=nil or settings.showEstimatedRange~=nil
    elseif entry.key=="hr_showEstimatedRange" then
        return settings.showEstimatedRange~=nil
    elseif entry.groupLabel=="hunterTextTitle" and entry.category=="range" then
        return api.GetText and api.SetText
    end
    return true
end
local commonSearchAliases = {
    zoom="zoom",queue="spellqueue spellqueuewindow",fpsShow="fps",fpsLock="fps",
    fpsShowMS="fps ping ms",launcher="minimap",scale="ui scale",
}
local localeSearchAliases = {
    en={zoom="camera",fpsShow="frame rate framerate",fpsShowMS="lag",
        hideActionBarStatues="gryphon griffon wyvern"},
    tr={zoom="yakınlaştırma",queue="büyü kuyruğu",fpsShow="kare hızı",fpsShowMS="gecikme",
        launcher="mini harita simge",scale="ölçek arayüz boyutu",music="müzik",disableDeathEffect="ölüm hayalet",
        hideActionBarStatues="grifon"},
    de={fpsShow="bilder pro sekunde",scale="skalierung",disableDeathEffect="graustufen",
        hideActionBarStatues="greif wyvern"},
    ruRU={zoom="зум",fpsShow="частота кадров",fpsShowMS="пинг"},
    zhCN={zoom="镜头 缩放",queue="法术队列",launcher="小地图",fpsShowMS="延迟"},
}
local chatSearch = {
    {"appearance","csAppearance","channelColors","Tab colors by channel type: ","Guild is green, party blue, raid and combat log warm tones. Mixed channels stay neutral."},
    {"layout","csLayout","width","Width","Open appearance, layout and micro menu settings."},
    {"layout","csLayout","height","Height","Open appearance, layout and micro menu settings."},
    {"layout","csLayout","unlocked","Resize handle: ","Hold and drag to resize."},
    {"micro","csMicro","microEnabled","Micro menu: ","Open appearance, layout and micro menu settings."},
    {"micro","csMicro","microSize","Micro menu size","Open appearance, layout and micro menu settings."},
    {"micro","csMicro","microGap","Micro menu spacing","Open appearance, layout and micro menu settings."},
}
local experienceSearch = {
    {"general","xpPageGeneral",nil,{"xpEnabled","xpLocked","xpHideNative","xpWidth"}},
    {"content","xpPageContent",nil,{"xpShowRep","xpShowPet","xpShowTime","xpShowRate","xpShowQuest","xpShowRested"}},
    {"appearance","xpPageAppearance",nil,{"xpTrim","xpShowBackground","xpClassColor","xpTexturedBars",
        "xpPanelSpace","xpFrameSize","xpBackgroundAlpha","xpHeight","xpSubHeight"}},
    {"appearance","xpPageAppearance","colors",{"xpColorMain","xpColorQuest","xpColorRested","xpColorRep","xpColorPet"}},
    {"text","xpPageText",nil,{"xpLabelVisible","xpTextX","xpTextY","xpTextSize"}},
    {"text","xpPageText","textColor",{"xpTextColor"}},
}
local experienceHelp={xpTexturedBars="xpTexturedBarsHelp",xpShowBackground="xpShowBackgroundHelp"}
local minimapSearch = {
    {"appearance","mmPageAppearance","art_artExtraHelp",nil,{"art_enabled","art_size","art_x","art_y","art_hideBorder","art_hunterMatte"}},
    {"details","mmPageDetails","mcHelp",nil,{"mcEnabled","mcX","mcY","mcSize","mcOutline","xpFontGame","xpFontRegular","xpFontBold"}},
    {"addons","mbTitle","mbHelp",nil,{"mbEnabled","mbLocked","mbRound","mbSquare"}},
    {"addons","mbTitle","mbHelp","panel",{"mbShowTooltip","mbColumns","mbSize"}},
    {"addons","mbTitle","mbHelp","position",{"mbButtonSize","mbAngle","mbRadius"}},
}
local minimapHelp={art_hideBorder="art_hideBorderHelp"}
local inventorySearch={
    {"settings","bgAppearance","imCombinedBags","imCombinedBagsHelp"},
    {"settings","bgAppearance","imBagDesign1","imBagDesignHelp1"},
    {"settings","bgAppearance","imBagDesign2","imBagDesignHelp2"},
    {"settings","bgAppearance","imBagDesign3","imBagDesignHelp3"},
    {"settings","bgAppearance","bgOrganized","bgOrganizedHelp",nil,"ClassicBagsOrganized"},
    {"settings","bgAppearance","imJunk","imItemLooksHelp","looks"},
    {"settings","bgAppearance","imQuality","imItemLooksHelp","looks"},
    {"settings","bgAppearance","imQuestItems","imQuestItemsHelp","looks"},
    {"settings","bgAppearance","imEmptySlots","imEmptySlotsHelp","looks"},
    {"settings","bgAppearance","imItemGap","imItemLooksHelp","looks"},
    {"settings","bgAppearance","imBagSize","imBagHelp","looks"},
    {"shortcut","bgShortcut","bsEnabled","bsHelp",nil,"BagShortcut"},
    {"shortcut","bgShortcut","bsLocked","bsHelp",nil,"BagShortcut"},
    {"shortcut","bgShortcut","bsSize","bsHelp",nil,"BagShortcut"},
    {"shortcut","bgShortcut","imBagBackground","imBagAppearanceHelp","strip"},
    {"shortcut","bgShortcut","imBagFrame","imBagAppearanceHelp","strip"},
    {"shortcut","bgShortcut","imHideNativeBar","imHideNativeBarHelp","strip"},
    {"shortcut","bgShortcut","imBagShortcutGap","imBagShortcutGapHelp","strip"},
    {"sorting","bgSorting","bagSortDaily","bagSortHelp",nil,"ClassicInventoryStyle"},
    {"sorting","bgSorting","bagSortLegacy","bagSortHelp",nil,"ClassicInventoryStyle"},
    {"sorting","bgSorting","bagSortCustom","bagSortHelp",nil,"ClassicInventoryStyle"},
    {"sorting","bgSorting","bagSortHearth","bagSortHelp",nil,"ClassicInventoryStyle"},
    {"sorting","bgSorting","bagSortOrder","bagSortHelp",nil,"ClassicInventoryStyle"},
    {"sorting","bgSorting","merchantAutoJunk","merchantAutoJunkHelp",nil,"ClassicMerchant"},
    {"sorting","bgSorting","lsTitle","lsHelp",nil,"LootSpace"},
}
local inventoryFoldLabels={looks="bgItemLooks",strip="bgStrip"}
local function MinimapResultAvailable(entry)
    if entry.tab=="appearance" then
        return ForeverClassArtMinimap and (entry.key~="art_hunterMatte" or select(2,UnitClass("player"))=="HUNTER")
    end
    if entry.tab=="details" then return K.DrawMinimapCoordinates end
    return K.DrawMinimapButtons
end
local unitSearchTabs={general="usGeneral",auras="usAuras",indicators="usIndicators",position="usPosition",class="usClass"}
local unitSearchContexts={{"player","upPlayer"},{"target","upTarget"},{"pet","upPet"},{"targettarget","usToT"}}
local function UnitSearchAvailable()
    local api=ForeverLeatherUnitsAPI
    return api and api.version>=2 and K.UnitSettingsModel and K.UnitSettingsView and api.GetSettings()~=nil
end
local alertFilters = {"error_target","error_movement","error_range","error_direction","error_cooldown","error_resources"}
local alertModeHelp = {errorShowAll="errorShowHelp",errorImportantOnly="errorImportantHelp",errorCustom="errorCustomHelp"}
local characterFold = {}
for equivalent, variants in pairs({
    a="àáâãäåÀÁÂÃÄÅ", c="çÇ", e="èéêëÈÉÊË", g="ğĞ",
    i="ìíîïİıÌÍÎÏ", n="ñÑ", o="òóôõöøÒÓÔÕÖØ", s="şŞ",
    u="ùúûüÙÚÛÜ", y="ýÿÝŸ", ss="ßẞ", ae="æÆ", oe="œŒ",
}) do
    for variant in variants:gmatch("[\194-\244][\128-\191]+") do characterFold[variant]=equivalent end
end
do
    local lower = "абвгдежзийклмнопрстуфхцчшщъыьэюяе"
    local at = 1
    for upper in ("АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯЁ"):gmatch("[\194-\244][\128-\191]+") do
        characterFold[upper]=lower:sub(at,at+1)
        at=at+2
    end
    characterFold["ё"]="е"
    -- Ignore decomposed Latin accent marks (U+0300 through U+036F).
    for byte=128,191 do characterFold[string.char(204,byte)]="" end
    for byte=128,175 do characterFold[string.char(205,byte)]="" end
    for _,space in ipairs({" "," ","　","（","）","·","，","。","、","：","’","‘","ʼ","–","—","«","»"}) do characterFold[space]=" " end
end
local germanFold={["ä"]="ae",["Ä"]="ae",["ö"]="oe",["Ö"]="oe",["ü"]="ue",["Ü"]="ue"}
function search.Normalize(value, german)
    if german then
        value=value:gsub("([aAoOuU])̈",function(letter) return letter:lower().."e" end)
        value=value:gsub("[\194-\244][\128-\191]+",germanFold)
    end
    -- Fullwidth Latin letters and digits occur in Chinese keyboard input.
    value=value:gsub("［"," "):gsub("］"," "):gsub("\239[\188\189][\128-\191]",function(char)
        local _,middle,last=char:byte(1,3)
        local offset=(middle-188)*64+last-128
        if (offset>=16 and offset<=25) or (offset>=33 and offset<=58) or (offset>=65 and offset<=90) then
            return string.char(offset+32)
        end
        return char
    end)
    return (value:gsub("[\194-\244][\128-\191]+",characterFold):lower()
        :gsub("[%p%c]", " "):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", ""))
end
function search.Path(entry, translate)
    local path=translate(entry.category)
    local tab=entry.section or entry.tabLabel
    if tab then path=path.." › "..translate(tab) end
    if entry.modeKey then path=path.." › "..translate(entry.modeKey) end
    if entry.groupLabel then path=path.." › "..translate(entry.groupLabel) end
    if entry.unitLabel then path=path.." › "..translate(entry.unitLabel) end
    if entry.cardLabel and entry.cardLabel~=entry.unitLabel and entry.cardLabel~=entry.key then
        path=path.." › "..translate(entry.cardLabel)
    end
    return path
end
function search.Name(entry,translate)
    return (translate(entry.label or entry.key):gsub(":%s*$",""):gsub("：%s*$",""))
end
function search.Index()
    local language=KerimAnkaUIDB.language or "en"
    local unitsAvailable=not not UnitSearchAvailable()
    local chatThemes=K.Chat and K.Chat.themes
    local soundGroups=K.SoundGroups and K.SoundGroups.groups
    if search.indexLanguage==language and search.indexUnits==unitsAvailable and
        search.indexChatThemes==chatThemes and search.indexSoundGroups==soundGroups then return search.index end
    local index={}
    local aliases=localeSearchAliases[language] or {}
    local function Add(entry)
        local key=entry.key
        entry.help=entry.help or key.."Help"
        local name=search.Name(entry,K.L)
        local terms=table.concat({name,search.Path(entry,K.L),commonSearchAliases[key] or "",aliases[key] or ""}," ")
        entry.name=" "..search.Normalize(name)
        entry.terms=" "..search.Normalize(terms)
        if language=="de" then
            entry.alternateName=" "..search.Normalize(name,true)
            entry.alternateTerms=" "..search.Normalize(terms,true)
        end
        index[#index+1]=entry
    end
    for _,group in ipairs(searchGroups) do
        for _,key in ipairs(group[4]) do
            Add({category=group[1],section=group[2],fold=group[3],key=key,feature=group[5],help=alertModeHelp[key]})
        end
    end
    Add({category="home",section="alerts",key="keepImportantErrors",modeKey="errorImportantOnly",mode=2})
    for _,key in ipairs(alertFilters) do
        Add({category="home",section="alerts",key=key,modeKey="errorCustom",mode=3,help="errorCustomHelp"})
    end
    for _,option in ipairs(K.soundOptions) do Add({category="home",section="sounds",fold="audio",key=option.key}) end
    Add({category="home",section="sounds",fold="shortcut",key="soundShortcutSize",
        help="soundShortcutShowHelp",feature="SoundShortcut"})
    for _,group in ipairs(soundGroups or {}) do
        Add({category="home",section="sounds",key=group.title,help=group.help,feature="DrawSoundGroups"})
    end
    for _,field in ipairs(appearanceFields) do Add({category="interface",key=field[1],help="glowStyleHelp"}) end
    for _,key in ipairs({"shadowPreset","lightPreset","goldPreset"}) do
        Add({category="interface",key=key,help="glowStyleHelp"})
    end
    for _,field in ipairs(chatSearch) do
        Add({category="chat",tab=field[1],tabLabel=field[2],key=field[3],label=field[4],help=field[5],feature="Chat"})
    end
    for _,theme in ipairs(chatThemes or {}) do
        Add({category="chat",tab="appearance",tabLabel="csAppearance",key="chatTheme:"..theme.en,label=theme.en,
            help="The theme applies to all chat windows. Free color selection is disabled.",feature="Chat"})
    end
    for _,label in ipairs({"Automatic","Vertical","Horizontal"}) do
        Add({category="chat",tab="layout",tabLabel="csLayout",key="chatMode:"..label,label=label,
            help="Side button spacing is fixed. Automatic layout turns horizontal in short windows.",feature="Chat"})
    end
    for i,label in ipairs({"Always visible","Messages visible","Hide all"}) do
        Add({category="chat",tab="visibility",tabLabel="csVisibility",key="chatVisibility:"..label,label=label,
            help=({"csAlwaysHelp","csMessagesHelp","csHideHelp"})[i],feature="Chat"})
    end
    for _,group in ipairs(experienceSearch) do
        for _,key in ipairs(group[4]) do
            Add({category="experience",tab=group[1],tabLabel=group[2],optionsFold=group[3],
                key=key,help=experienceHelp[key] or "xpHelp",feature="Experience"})
        end
    end
    for _,group in ipairs(minimapSearch) do
        for _,key in ipairs(group[5]) do
            Add({category="minimap",tab=group[1],tabLabel=group[2],optionsFold=group[4],
                key=key,help=minimapHelp[key] or group[3],available=MinimapResultAvailable})
        end
    end
    for _,field in ipairs(inventorySearch) do
        Add({category="inventory",tab=field[1],tabLabel=field[2],key=field[3],help=field[4],
            optionsFold=field[5],groupLabel=field[2]=="bgSorting" and field[3]=="bagSortOrder" and "bagSortCustom" or inventoryFoldLabels[field[5]],
            feature=field[6] or "InventoryMenus"})
    end
    for _,group in ipairs(cursorSearch) do
        for _,key in ipairs(group[2]) do
            Add({category="home",section="cursor",key=key,help=group[1],feature="DrawCursorPage"})
        end
    end
    for _,group in ipairs(rangeSearch) do
        for _,key in ipairs(group[2]) do
            Add({category="range",key=key,help=group[1],available=HunterResultAvailable,
                groupLabel=group[1]=="hunterTextHelp" and "hunterTextTitle" or nil})
        end
    end
    for _,key in ipairs({"hr_showNumericRange","hr_showEstimatedRange"}) do
        Add({category="range",key=key,available=HunterResultAvailable})
    end
    for _,group in ipairs(aspectSearch) do
        for _,key in ipairs(group[2]) do
            Add({category="aspect",key=key,help=group[1],available=HunterResultAvailable})
        end
    end
    for _,group in ipairs(threatSearch) do
        for _,key in ipairs(group[4]) do
            Add({category="threat",key=key,help=group[3],optionsFold=group[1],groupLabel=group[2],
                available=ThreatResultAvailable})
        end
    end
    for _,group in ipairs(meterSearch) do
        for _,label in ipairs(group[4]) do
            Add({category="details",tab=group[1],tabLabel=group[2],key=group[1]..":"..label,
                label=label,help=group[3],groupLabel=group[5],available=MeterResultAvailable})
        end
    end
    for _,field in ipairs(questSearch) do
        Add({category="quests",key=field[1],help=field[2],available=QuestResultAvailable})
    end
    for _,group in ipairs(backdropSearch) do
        for _,key in ipairs(group[4]) do
            Add({category="backdrop",tab=group[1],tabLabel=group[2],key=key,help=group[3],available=BackdropResultAvailable})
        end
    end
    for _,group in ipairs(classArtSearch) do
        for _,key in ipairs(group[4]) do
            Add({category="art",tab=group[1],tabLabel=group[2],key=key,help=group[3],optionsFold=group[5],
                available=ClassArtResultAvailable})
        end
    end
    if unitsAvailable then
        local model=K.UnitSettingsModel
        for _,context in ipairs(unitSearchContexts) do
            local unit,unitLabel=context[1],context[2]
            if unit~="pet" or model.Facts().pet then
                for _,card in ipairs(model.Cards(unit)) do
                    local global=card.tab=="general" or card.id=="auraCommon" or card.id=="tot"
                    local first=card.id=="tot" and unit=="targettarget" or card.id~="tot" and unit=="player"
                    if (not global or first) and model.CardVisible(card,unit) then
                        for _,key in ipairs(model.Keys(card,unit)) do
                            Add({category="units",tab=card.tab,tabLabel=unitSearchTabs[card.tab],key="uf_"..key,
                                unit=unit,unitOption=key,unitLabel=not global and unitLabel or nil,
                                card=card.id,cardLabel=card.title,help=card.tab=="auras" and "usAuraFlowHelp" or "ufHelp"})
                        end
                    end
                end
            end
        end
    end
    search.index,search.indexLanguage,search.indexUnits=index,language,unitsAvailable
    search.indexChatThemes,search.indexSoundGroups=chatThemes,soundGroups
    return index
end
function search.Find(query, category)
    local phrase=search.Normalize(query)
    if phrase=="" then return {} end
    local language=KerimAnkaUIDB.language
    local function Prefix(value)
        -- Chinese labels do not normally delimit words with spaces.
        return language=="zhCN" and value:find("[\128-\255]") and value or " "..value
    end
    local words,alternateWords={},{}
    for word in phrase:gmatch("%S+") do words[#words+1]=Prefix(word) end
    local alternatePhrase
    if language=="de" then
        alternatePhrase=" "..search.Normalize(query,true)
        for word in alternatePhrase:gmatch("%S+") do alternateWords[#alternateWords+1]=" "..word end
    end
    local preferred={queue="combat",disableDeathEffect="alerts",clicks="sounds"}
    local best, order = {}, {}
    for _,entry in ipairs(search.Index()) do
        if (not category or category==entry.category) and (not entry.feature or K[entry.feature]) then
            local matches=true
            for i,word in ipairs(words) do
                if not entry.terms:find(word,1,true) and
                    not (entry.alternateTerms and entry.alternateTerms:find(alternateWords[i],1,true)) then
                    matches=false; break
                end
            end
            if matches and (not entry.available or entry.available(entry)) then
                local nameMatch=entry.name:find(Prefix(phrase),1,true)~=nil or
                    (entry.alternateName and entry.alternateName:find(alternatePhrase,1,true)~=nil)
                local score=(nameMatch and 2 or 0)+(preferred[entry.key]==entry.section and 1 or 0)
                local previous=best[entry.key]
                if not previous then order[#order+1]=entry.key end
                if not previous or score>previous.score then
                    best[entry.key]={entry=entry,score=score,nameMatch=nameMatch}
                end
            end
        end
    end
    local names, other = {}, {}
    for _,key in ipairs(order) do
        local match=best[key]
        local results=match.nameMatch and names or other
        results[#results+1]=match.entry
    end
    for _,entry in ipairs(other) do names[#names+1]=entry end
    return names
end
local searchText = {
    en={"Search settings","All categories","This category","Back to results","No matching settings.","Open the setting after combat.","This setting is unavailable."},
    de={"Einstellungen suchen","Alle Kategorien","Diese Kategorie","Zurück zu den Ergebnissen","Keine passenden Einstellungen.","Öffne die Einstellung nach dem Kampf.","Diese Einstellung ist nicht verfügbar."},
    tr={"Ayar ara","Tüm kategoriler","Bu kategori","Sonuçlara dön","Eşleşen ayar bulunamadı.","Ayarı savaş bittikten sonra aç.","Bu ayar kullanılamıyor."},
    zhCN={"搜索设置","所有类别","当前类别","返回搜索结果","没有匹配的设置。","请在战斗结束后打开设置。","此设置不可用。"},
    frFR={"Rechercher un réglage","Toutes les catégories","Cette catégorie","Retour aux résultats","Aucun réglage correspondant.","Ouvrez le réglage après le combat.","Ce réglage est indisponible."},
    itIT={"Cerca impostazioni","Tutte le categorie","Questa categoria","Torna ai risultati","Nessuna impostazione trovata.","Apri l’impostazione dopo il combattimento.","Questa impostazione non è disponibile."},
    esES={"Buscar ajustes","Todas las categorías","Esta categoría","Volver a los resultados","No se encontraron ajustes.","Abre el ajuste después del combate.","Este ajuste no está disponible."},
    ptBR={"Buscar configurações","Todas as categorias","Esta categoria","Voltar aos resultados","Nenhuma configuração encontrada.","Abra a configuração após o combate.","Esta configuração está indisponível."},
    ruRU={"Поиск настроек","Все категории","Эта категория","К результатам","Подходящих настроек нет.","Откройте настройку после боя.","Эта настройка недоступна."},
}
function search.Text(index)
    return (searchText[KerimAnkaUIDB.language] or searchText.en)[index]
end
local selectAlertMode = {
    en="Select the highlighted mode.", de="Markierten Modus auswählen.", tr="Vurgulanan modu seç.",
    zhCN="请选择高亮的模式。", frFR="Sélectionnez le mode indiqué.", itIT="Seleziona la modalità evidenziata.",
    esES="Selecciona el modo resaltado.", ptBR="Selecione o modo destacado.", ruRU="Выберите выделенный режим.",
}
function search.Scroll(position)
    K.scroll:UpdateScrollChildRect()
    K.scroll:SetVerticalScroll(math.max(0,math.min(position,K.scroll:GetVerticalScrollRange())))
end
function search.Leave(keepFocus)
    search.arrival=nil
    if not search.active then return end
    search.position=K.scroll:GetVerticalScroll()
    search.active=false
    if not keepFocus then search.input:ClearFocus() end
end
function search.Open(restore)
    search.arrival=nil
    local showingResults=search.active
    if not search.active then
        search.originScroll=K.scroll:GetVerticalScroll()
        if not restore then search.category=selection end
    end
    if not restore then search.position=0 end
    search.active=true
    K.HideTooltip()
    if showingResults then
        search.ResetCards()
        search.UpdateControls()
        search.Draw()
        if K.QueuePanelTextFit then K.QueuePanelTextFit() end
    else K.Render() end
    search.Scroll(search.position)
end
function search.Jump(entry)
    if K.InCombat() then subtitle:SetText(search.Text(6)); return end
    if K.LayoutEditor and K.LayoutEditor.IsActive() then return end
    search.Leave()
    K.HideTooltip()
    if entry.fold then homeOpen[entry.fold]=true end
    if entry.category=="chat" then chatSettingsTab=entry.tab end
    search.destination=entry
    K.ShowPage(entry.category,entry.section)
    search.destination=nil
    if entry.unitOption then
        if K.JumpToUnitOption(entry.unitOption,entry) then
            search.arrival=entry
            search.UpdateControls()
        else subtitle:SetText(search.Text(7)) end
        return
    end
    local target=search.targets[entry.key] or (entry.modeKey and search.targets[entry.modeKey])
    search.targets[entry.key]=nil
    if entry.modeKey then search.targets[entry.modeKey]=nil end
    if not target then subtitle:SetText(search.Text(7)); return end
    search.arrival=entry
    search.UpdateControls()
    local serial=search.renderSerial
    C_Timer.After(0,function()
        if search.renderSerial~=serial or search.arrival~=entry or not target:IsVisible() then return end
        local top,pageTop=target:GetTop(),page:GetTop()
        if not top or not pageTop then subtitle:SetText(search.Text(7)); return end
        local centerOffset=math.max(0,(K.scroll:GetHeight()-target:GetHeight())/2)
        search.Scroll(pageTop-top-centerOffset)
        local outline=search.outline
        outline:ClearAllPoints()
        outline:SetAllPoints(target)
        outline:SetFrameLevel(target:GetFrameLevel()+6)
        outline:Show()
        outline.pulse:Play()
        C_Timer.After(3.6,function() if search.renderSerial==serial then outline:Hide() end end)
    end)
end
function search.Draw()
    local results=search.Find(search.input:GetText(),search.scoped and search.category)
    for i,entry in ipairs(results) do
        local row=Button(page,"",0,-(i-1)*94,714,86,function() search.Jump(entry) end)
        local title=search.Name(entry,K.L)
        local path=search.Path(entry,K.L)
        local help=K.L(entry.help)
        local summary=help:match("^(.-%.)%s") or help:match("^(.-。)") or help
        local label=Text(row,title,13,-7,688,15,white); label:SetHeight(21); label:SetWordWrap(false)
        label=Text(row,path,13,-29,688,12,gold); label:SetHeight(17); label:SetWordWrap(false)
        Text(row,summary,13,-49,688,12,muted):SetHeight(32)
        row:SetScript("OnEnter",function(self) K.ShowTooltip(self,title,path.."\n"..help) end)
        row:SetScript("OnLeave",K.HideTooltip)
    end
    if #results==0 then Text(page,search.Text(5),12,-14,690,14,muted) end
    page:SetHeight(math.max(80,#results*94))
end
function search.ResetCards()
    for _,frame in pairs(pool) do frame:Hide() end
    for _,label in pairs(labels) do label:Hide() end
    used, labelUsed=0,0
end
function K.ShowPage(key,homeSection)
    if K.LayoutEditor and K.LayoutEditor.IsActive() then K.LayoutEditor.Finish(true) end
    if key=="home" and homeSection=="imMicro" then key="chat";homeSection=nil end
    if homeSection then section=homeSection=="camera"and"overview"or homeSection end
    if not K.window then return end
    search.Leave()
    for _,module in ipairs(K.modules) do
        if key==module.key and not K.ModuleApplicable(module) then key="home"; break end
    end
    if key~="chat" then chatResetArmed=false end
    selection=key or "home"
    K.scroll:SetVerticalScroll(0); K.openingPage=true; K.window:Show(); K.openingPage=nil; K.Render()
end
function K.Render()
    local view=search.active and "search" or selection
    local searchScroll=(search.active or search.arrival) and K.scroll:GetVerticalScroll()
    if search.outline then search.outline:Hide(); search.renderSerial=(search.renderSerial or 0)+1 end
    if K.UnitSettingsView and (view~='units' or not ForeverLeatherUnitsAPI or not ForeverLeatherUnitsAPI.GetSettings())then K.UnitSettingsView.Hide()end
    K.economySettingsVisible=view=='economy'
    if K.ClassicEconomyView and view~='economy' then K.ClassicEconomyView.Hide() end
    if selection~="chat" then chatResetArmed=false end
    if K.CancelUnitPageBuild then K.CancelUnitPageBuild() end
    if K.layoutEditButton then K.layoutEditButton.label:SetText(K.L('leTitle')) end
    if K.CloseCommunity then K.CloseCommunity() end
    if not page then return end
    K.UnitOptionPositions=nil
    if K.HideAspectInputs then K.HideAspectInputs() end; if K.HideRangeInputs then K.HideRangeInputs() end
    if K.HideProfileInputs then K.HideProfileInputs() end
    if K.HideExperienceInputs then K.HideExperienceInputs() end
    if view~="profiles" and K.EndProfileSession then K.EndProfileSession() end
    if view~="aspect" and K.EndAspectPreview then K.EndAspectPreview() end
    if K.HideThreatFontMenu then K.HideThreatFontMenu() end
    if view~="range" and K.EndRangePreview then K.EndRangePreview() end
    if K.ConfigureUnitPreview then
        K.ConfigureUnitPreview(view=="units" and ForeverLeatherUnitsAPI and ForeverLeatherUnitsAPI.version>=2 and ForeverLeatherUnitsAPI.GetSettings()~=nil)
    end
    if K.ConfigureExperiencePreview then K.ConfigureExperiencePreview(view=="experience") end
    K.scaleValueText=nil
    search.ResetCards()
    if idEdit then idEdit:Hide() end
    for _,v in ipairs(nav) do
        v.label:SetText(v.key=="chat" and K.Chat and K.L("chat")or K.L(v.key))
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
    if languageButton then UpdateLanguageLabel() end
    heading:SetText(selection=="chat" and K.Chat and K.L("chat")or K.L(selection=="home" and (section=="overview" and "quick" or section) or selection))
    subtitle:SetText(K.L(selection=="home" and "welcome" or "saved"))
    search.UpdateControls()
    footer:SetText(K.HasPendingModuleChanges() and K.L("communityReloadWaiting") or "")
    footer:SetTextColor(unpack(K.HasPendingModuleChanges() and gold or muted))
    K.window.reload.label:SetText(K.L("reload"))
    if search.active then search.Draw()
    elseif selection=="profiles" then K.DrawProfilesPage()
    elseif selection=="interface" then Interface()
    elseif selection=="experience" then K.DrawExperiencePage(page,search.destination,search.Anchor)
    elseif selection=="minimap" then K.DrawMinimapPage(page,search.destination,search.Anchor)
    elseif selection=="inventory" then K.DrawInventoryPage(page,search.destination,search.Anchor)
    elseif selection=="economy" then K.DrawEconomyPage(page)
    elseif selection=="chat" and K.Chat then ChatPage()
    elseif selection~="home" then
        for _,module in ipairs(K.modules) do if selection==module.key then Module(module); break end end
    elseif section=="overview" then Overview()
    elseif section=="combat" then Combat()
    elseif section=="alerts" then Alerts()
    elseif section=="sounds" then Sounds()
    elseif section=="cursor" and K.DrawCursorPage then K.DrawCursorPage(page,HomeWidgets(),HomeRefresh,search.Anchor)
    end
    if K.reloadPrompt and K.reloadPrompt:IsShown() then
        if K.HasPendingModuleChanges() then K.ShowReloadPrompt() else K.reloadPrompt:Hide() end
    end
    for i,button in ipairs(textSizeButtons)do Selected(button,K.PanelTextSize()==i)end
    if K.QueuePanelTextFit then K.QueuePanelTextFit()end
    if K.UpdateIntro then K.UpdateIntro() end
    if searchScroll then search.Scroll(searchScroll) end
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
function search.UpdateControls()
    local hasQuery=search.Normalize(search.input:GetText())~=""
    search.hint:SetText(search.Text(1))
    search.hint:SetShown(search.input:GetText()=="" and not search.input:HasFocus())
    search.clear:SetShown(search.input:GetText()~="")
    search.back:SetShown(hasQuery and not search.active)
    search.back.label:SetText(search.Text(4))
    search.scope:SetShown(search.active)
    search.scope.label:SetText(search.Text(search.scoped and 3 or 2))
    Selected(search.scope,search.scoped)
    subtitle:SetWidth(hasQuery and 486 or 730)
    if search.active then
        heading:SetText(search.Text(1))
        subtitle:SetText(search.scoped and K.L(search.category) or "")
    elseif search.arrival and (not hasQuery or search.arrival.category~=selection or
        (search.arrival.section and search.arrival.section~=section) or
        (search.arrival.category=="chat" and search.arrival.tab~=chatSettingsTab) or
        (search.arrival.category=="experience" and search.arrival.tab~=K.GetExperienceSettingsTab()) or
        (search.arrival.category=="minimap" and search.arrival.tab~=K.GetMinimapSettingsTab()) or
        (search.arrival.category=="inventory" and search.arrival.tab~=K.GetInventorySettingsTab()) or
        (search.arrival.category=="details" and search.arrival.tab~=K.GetDamageMeterSettingsTab())) then
        search.arrival=nil
        search.outline:Hide()
        subtitle:SetText(K.L(selection=="home" and "welcome" or "saved"))
    elseif search.arrival then
        local entry=search.arrival
        local detail=search.Name(entry,K.L)
        if entry.mode and K.ErrorMode()~=entry.mode then
            detail=detail.." · "..(selectAlertMode[KerimAnkaUIDB.language] or selectAlertMode.en)
        end
        subtitle:SetText(search.Path(entry,K.L).."\n"..detail)
    end
end
function search.CloseResults(keepFocus)
    if not search.active then
        if not keepFocus then search.input:ClearFocus() end
        return
    end
    search.Leave(keepFocus)
    K.HideTooltip()
    K.Render()
    search.Scroll(search.originScroll)
end
function K.ClearUnitSearchArrival()
    if search.arrival and search.arrival.category=="units" then
        search.arrival=nil
        subtitle:SetText(K.L("saved"))
    end
end
function search.Build(parent)
    local field=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    field:SetPoint("TOPLEFT",304,-20); field:SetSize(184,30)
    local function StyleField(focused)
        Rounded(field,.095,.105,.10,focused and gold or {.37,.40,.35,1},5,false)
    end
    StyleField(false)
    local input=CreateFrame("EditBox",nil,field)
    input:SetPoint("TOPLEFT",9,0); input:SetSize(144,30); input:SetAutoFocus(false)
    input:SetTextColor(unpack(white)); input:SetMaxLetters(96)
    K.ApplyTextFont(input,13,false,"")
    search.input=input
    search.lastText=input:GetText()
    search.hint=input:CreateFontString(nil,"OVERLAY")
    search.hint:SetPoint("LEFT",0,0); search.hint:SetWidth(144)
    search.hint:SetWordWrap(false)
    search.hint:SetJustifyH("LEFT"); search.hint:SetTextColor(unpack(muted))
    K.ApplyTextFont(search.hint,13,false,"")
    local clear=CreateFrame("Button",nil,field)
    clear:SetPoint("RIGHT",-4,0); clear:SetSize(26,28)
    clear:SetFrameLevel(input:GetFrameLevel()+1)
    local icon=clear:CreateTexture(nil,"ARTWORK")
    icon:SetSize(12,12); icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\Close.tga")
    icon:SetVertexColor(unpack(muted))
    clear:SetScript("OnEnter",function() icon:SetVertexColor(unpack(white)) end)
    clear:SetScript("OnLeave",function() icon:SetVertexColor(unpack(muted)) end)
    clear:SetScript("OnClick",function()
        input:SetText("")
        input:SetFocus()
    end)
    search.clear=clear
    search.back=FixedButton(parent,"",721,-164,236,28,function() search.Open(true) end)
    search.scope=FixedButton(parent,"",721,-164,236,28,function()
        search.scoped=not search.scoped
        search.Open(false)
    end)
    local outline=CreateFrame("Frame",nil,page,"BackdropTemplate")
    local pixel="Interface\\Buttons\\WHITE8X8"
    outline:SetBackdrop({bgFile=pixel,edgeFile=pixel,edgeSize=3})
    outline:SetBackdropColor(.96,.73,.32,.18)
    outline:SetBackdropBorderColor(1,.84,.45,1)
    outline:EnableMouse(false); outline:Hide()
    outline.pulse=outline:CreateAnimationGroup()
    outline.pulse:SetLooping("BOUNCE")
    local fade=outline.pulse:CreateAnimation("Alpha")
    fade:SetFromAlpha(1); fade:SetToAlpha(.53); fade:SetDuration(.6)
    outline:SetScript("OnHide",function() outline.pulse:Stop() end)
    search.outline=outline
    input:SetScript("OnEditFocusGained",function() StyleField(true); search.hint:Hide() end)
    input:SetScript("OnEditFocusLost",function(self) StyleField(false); search.hint:SetShown(self:GetText()=="") end)
    input:SetScript("OnEscapePressed",function() search.CloseResults() end)
    input:SetScript("OnEnterPressed",function(self)
        if not search.active and search.Normalize(self:GetText())~="" then search.Open(false) end
        self:ClearFocus()
    end)
    input:SetScript("OnTextChanged",function(self)
        local text=self:GetText()
        if text==search.lastText then return end
        search.lastText=text
        if search.Normalize(text)~="" then search.Open(false)
        else
            search.CloseResults(true)
            search.UpdateControls()
        end
    end)
    search.UpdateControls()
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
        C_Timer.After(0,function() RefreshScaleViewport();if K.ClassicEconomyView then K.ClassicEconomyView.Reflow() end end)
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
    if f:IsShown() then
        -- Scaling this fixed-width page changes its viewport, not its option cards.
        if not search.active and not search.arrival then
            if selection=="units" and K.UnitOptionPositions and not K.unitPageBuilding then
                if K.UpdateUnitPreview then K.UpdateUnitPreview()end
            else K.Render()end
        end
        RefreshScaleViewport();if K.ClassicEconomyView then K.ClassicEconomyView.Reflow() end
    end
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
-- Module entries share one left edge; Profiles and Interface stay centered.
-- Long titles can use two lines
-- at the selected panel text size instead of shrinking beside a module badge.
local function StyleNavigationLabel(button)
 local label=button.label
 local centered=button.key=='profiles'or button.key=='interface'
 label:ClearAllPoints()
 if centered then label:SetPoint('CENTER')else label:SetPoint('LEFT',12,0)end
 label:SetWidth(button.moduleBadge and 122 or 151);label:SetHeight(34)
 label:SetJustifyH(centered and'CENTER'or'LEFT');label:SetJustifyV('MIDDLE');label:SetWordWrap(true)
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
        StyleNavigationLabel(button)
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
    local title=CreateFrame("Frame",nil,f); title:SetPoint("TOPLEFT",1,-1); title:SetSize(291,60)
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
    f:SetScript("OnHide",function() if K.CancelUnitPageBuild then K.CancelUnitPageBuild() end; if K.CloseCommunity then K.CloseCommunity() end; K.EndIntro();SavePosition(); if K.HideExperienceInputs then K.HideExperienceInputs() end; if languageMenu then languageMenu:Hide(); languageDismiss:Hide() end; K.StopPreview(); K.HideTooltip(); if K.EndProfileSession then K.EndProfileSession() end; if K.HideAspectInputs then K.HideAspectInputs() end; if K.HideRangeInputs then K.HideRangeInputs() end; if K.EndAspectPreview then K.EndAspectPreview() end; if K.HideThreatFontMenu then K.HideThreatFontMenu() end; if K.EndRangePreview then K.EndRangePreview() end; if K.reloadPrompt then K.reloadPrompt:Hide() end end)
    local header=f:CreateTexture(nil,"BACKGROUND",nil,1); header:SetPoint("TOPLEFT",1,-1); header:SetSize(998,63); header:SetColorTexture(0.15,0.16,0.145,1)
    local emblem=f:CreateTexture(nil,"ARTWORK"); emblem:SetPoint("TOPLEFT",17,-8); emblem:SetSize(48,48)
    emblem:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\Phoenix.tga","CLAMP","CLAMP","TRILINEAR")
    local brand=f:CreateFontString(nil,"OVERLAY")
    brand.panelTextFixed=true
    K.ApplyTextFont(brand,25,true,"")
    brand:SetTextColor(0.79,0.69,0.49)
    brand:SetPoint("TOPLEFT",78,-16); brand:SetWidth(214); brand:SetWordWrap(false)
    brand:SetJustifyH("LEFT"); brand:SetText("KerimAnka UI")
    local ver=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(ver,10,false,""); ver:SetTextColor(unpack(muted)); ver:SetPoint("TOPLEFT",80,-46); ver:SetText(K.version)
    local rule=f:CreateTexture(nil,"ARTWORK"); rule:SetPoint("TOPLEFT",1,-64); rule:SetSize(998,1); rule:SetColorTexture(0.55,0.48,0.34,0.65)
    local layoutButton=FixedButton(f,K.L('leTitle'),504,-20,258,30,function()if K.LayoutEditor then K.LayoutEditor.Toggle()end end)
    layoutButton:SetFrameLevel(title:GetFrameLevel()+2); layoutButton:EnableMouse(true)
    K.layoutEditButton=layoutButton
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
    local keys={"home"}; for _,m in ipairs(K.VisibleModules()) do keys[#keys+1]=m.key;if m.key=="units" then keys[#keys+1]="minimap";keys[#keys+1]="inventory";keys[#keys+1]="economy" end;if m.key=="details" then keys[#keys+1]="experience" end end

    for i,key in ipairs(keys) do
        local b=FixedButton(sidebar,K.L(key),10,-12-(i-1)*45,178,39,function()
            search.Leave(); selection=key; K.scroll:SetVerticalScroll(0); K.Render()
        end)
        b.key=key
        for _,module in ipairs(K.modules) do
            if module.key==key and key~="details" then
                ModuleBadge(b,module); break
            end
        end
        StyleNavigationLabel(b); NavAccent(b); nav[#nav+1]=b
    end
    local b=FixedButton(sidebar,K.L("interface"),10,-513,178,39,function() search.Leave(); selection="interface"; K.scroll:SetVerticalScroll(0); K.Render() end)
    b:ClearAllPoints(); b:SetPoint("BOTTOMLEFT",10,14)
    b.key="interface"; StyleNavigationLabel(b); NavAccent(b); nav[#nav+1]=b
    local profiles=FixedButton(sidebar,K.L("profiles"),10,-466,178,39,function()
        search.Leave(); selection="profiles"; K.scroll:SetVerticalScroll(0); K.Render()
    end)
    profiles:ClearAllPoints();profiles:SetPoint("BOTTOMLEFT",10,61)
    profiles.key="profiles";StyleNavigationLabel(profiles);NavAccent(profiles);nav[#nav+1]=profiles
    introProfiles=profiles
    for i,key in ipairs({"overview","combat","alerts","sounds","cursor"}) do
        local tab=FixedButton(f,K.L(key),220+(i-1)*149,-77,141,32,function()
            search.Leave(); section=key; K.scroll:SetVerticalScroll(0); K.Render()
        end)
        tab.underline=tab:CreateTexture(nil,"OVERLAY"); tab.underline:SetPoint("BOTTOMLEFT",2,0); tab.underline:SetPoint("BOTTOMRIGHT",-2,0)
        tab.underline:SetHeight(3); tab.underline:SetColorTexture(0.52,0.72,0.43,1)
        tab.key=key; tabs[#tabs+1]=tab
    end
    heading=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(heading,25,true,""); heading:SetTextColor(unpack(white)); heading:SetPoint("TOPLEFT",222,-131)
    heading:SetWidth(330);heading:SetHeight(32);heading:SetWordWrap(false);heading:SetJustifyH("LEFT");heading:SetJustifyV("TOP")
    for i,key in ipairs({'panelTextNormal','panelTextLarge','panelTextLargest'})do
        local value=i
        local button=FixedButton(f,'A',854+(i-1)*37,-129,32,30,function()K.SetPanelTextSize(value)end)
        button.label.panelTextFixed=true;K.ApplyTextFont(button.label,11+(i-1)*3,true,'')
        Tip(button,key,'panelTextHelp');textSizeButtons[i]=button
    end
    subtitle=f:CreateFontString(nil,"OVERLAY"); K.ApplyTextFont(subtitle,13,false,""); subtitle:SetTextColor(unpack(muted)); subtitle:SetPoint("TOPLEFT",222,-166); subtitle:SetWidth(730); subtitle:SetJustifyH("LEFT")
    local scroll=CreateFrame("ScrollFrame",nil,f,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",220,-205); scroll:SetSize(734,415); K.scroll=scroll
    -- Leave room around the content so the blur is not cut at the first row
    -- or the left/right viewport boundary.
    local content=CreateFrame("Frame",nil,scroll); content:SetSize(734,435); scroll:SetScrollChild(content)
    page=CreateFrame("Frame",nil,content); page:SetPoint("TOPLEFT",10,-10); page:SetSize(714,415)
    page:SetScript("OnSizeChanged",function(_,_,height) content:SetHeight(math.max(415,height+20)) end)
    search.Build(f)
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
        SavePosition(); K.LayoutWindow(); RefreshScaleViewport();if K.ClassicEconomyView then K.ClassicEconomyView.Reflow() end
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
    f:SetScript("OnShow",function() K.ApplyWindowScale();if not K.db.onboardingSeen then K.StartIntro(false) elseif not K.openingPage then K.Render() end end)
end
K.UnitWidgets={Selected=Selected,Box=Box,Text=Text,Button=Button,Tip=Tip,Switch=HomeSwitch,Rounded=Rounded}

-- Profile workflow implementation is separate from the shared panel widgets.
function K.DrawProfilesPage()
 K.ProfilePage.Draw({page=page,Box=Box,Text=Text,Button=Button,FixedButton=FixedButton,
  Backdrop=Backdrop,Rounded=Rounded,gold=gold,muted=muted,white=white})
end

-- Shared compact settings widgets for grouped Classic pages.
K.CompactSettingsWidgets=HomeWidgets
