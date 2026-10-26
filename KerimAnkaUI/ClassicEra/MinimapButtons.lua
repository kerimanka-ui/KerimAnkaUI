-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
-- Independent optional icon collector. No replacement of third-party methods.
local M={};K.MinimapButtons=M
local defaults={enabled=true,locked=true,showTooltip=false,columns=6,iconSize=32,buttonStyle=1,buttonSize=32,angle=220,radius=12}
local bounds={buttonStyle={1,2},buttonSize={20,64},columns={1,12},iconSize={24,40},angle={-360,360},radius={0,80}}
local records=setmetatable({},{__mode="k"})
local known=setmetatable({},{__mode="k"})
local watched=setmetatable({},{__mode="k"})
local libraries=setmetatable({},{__mode="k"})
local button,panel,queued,pending,mutating,dragging
local total=0
function M.Get(key)
 local db=K.db and K.db.minimapButtons
 if db and db[key]~=nil then return db[key] end
 return defaults[key]
end
local function Blocked()
 return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("MinimapButtonButton")
end
function M.IsBlocked() return not not Blocked() end
local function Safe(frame)
 return frame and not (frame.IsForbidden and frame:IsForbidden()) and not (frame.IsProtected and frame:IsProtected())
end
local function MapParent(parent)
 return parent and (parent==Minimap or parent==MinimapBackdrop or parent==MinimapCluster)
end
local function Hidden(b)
 return not b:IsShown() or b.db and b.db.hide==true
end
local function Candidate(b)
 if not Safe(b) or not b.IsObjectType or b==button then return false end
 if not b:IsObjectType("Button") and not (b:IsObjectType("Frame") and b:GetScript("OnMouseUp")) then return false end
 local parent=b:GetParent()
 if not MapParent(parent) and parent~=panel then return false end
 local name=b:GetName() or ""
 -- Map pins and native controls are never inferred from an icon texture alone.
 if name:match("^Questie.*%d$") or name:match("^HandyNotes") or name:match("^TomTom") or name:match("^HereBeDragons") or name:match("^GatherMate") then return false end
 if b.showOnMouseover or b.d4NoBag or b.db and b.db.D4MMBTNALWAYSSHOW==false then return false end -- respect separate display/collection modes
 return true
end
local function Restore(b,record)
 if not Safe(b) then pending=true;return false end
 -- Another collector may have taken ownership since our last refresh.
 if b:GetParent()==panel or MapParent(b:GetParent()) then
  b:SetParent(record.parent);b:ClearAllPoints()
  for _,point in ipairs(record.points) do b:SetPoint(unpack(point)) end
  b:SetScale(record.scale);b:SetFrameStrata(record.strata);b:SetFrameLevel(record.level)
  if b.SetIgnoreParentScale and record.ignore~=nil then b:SetIgnoreParentScale(record.ignore) end
  b:SetScript("OnDragStart",record.dragStart);b:SetScript("OnDragStop",record.dragStop)
  if b.SetFixedFrameStrata and record.fixedStrata~=nil then b:SetFixedFrameStrata(record.fixedStrata) end
  if b.SetFixedFrameLevel and record.fixedLevel~=nil then b:SetFixedFrameLevel(record.fixedLevel) end
 end
 records[b]=nil
 return true
end
local function Position()
 if not button or not Minimap then return end
 local ratio=Minimap:GetEffectiveScale()/button:GetEffectiveScale()
 local angle=math.rad(M.Get("angle"));local radius=Minimap:GetWidth()/2*ratio+M.Get("radius")
 button:ClearAllPoints();button:SetPoint("CENTER",Minimap,"CENTER",math.cos(angle)*radius,math.sin(angle)*radius)
end
local function StopDrag()
 if not button then return end
 button:SetScript("OnUpdate",nil);dragging=false
end
function M.ArtPath(style)
 return "Interface\\AddOns\\KerimAnkaUI\\Media\\IconDrawer"..(style==2 and "Square" or "Round")..".tga"
end
local function Appearance()
 if not button then return end
 local size=M.Get("buttonSize");button:SetSize(size,size)
 local path=M.ArtPath(M.Get("buttonStyle"))
 button.icon:SetTexture(path,"CLAMP","CLAMP","TRILINEAR")
 button.highlight:SetTexture(path,"CLAMP","CLAMP","TRILINEAR")
end
local function EnsureUI()
 if button or not Minimap then return end
 button=CreateFrame("Button","KerimAnkaUIIconDrawer",UIParent)
 button:SetFrameStrata("MEDIUM");button:SetFrameLevel(Minimap:GetFrameLevel()+12)
 local icon=button:CreateTexture(nil,"ARTWORK");icon:SetAllPoints();button.icon=icon
 local highlight=button:CreateTexture(nil,"HIGHLIGHT");highlight:SetAllPoints()
 highlight:SetBlendMode("ADD");highlight:SetAlpha(.18);button.highlight=highlight
 Appearance()
 -- Background textures stay on the panel's own level. A BackdropTemplate
 -- may create an additional NineSlice frame above the original button levels.
 -- The container itself never needs mouse input; original icons handle it.
 panel=CreateFrame("Frame","KerimAnkaUIIconPanel",UIParent)
 panel:SetFrameStrata("DIALOG");panel:SetClampedToScreen(true);panel:EnableMouse(false)
 local fill=panel:CreateTexture(nil,"BACKGROUND");fill:SetAllPoints();fill:SetColorTexture(.07,.09,.07,.97)
 for _,edge in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
  local line=panel:CreateTexture(nil,"BORDER");line:SetColorTexture(.55,.48,.31,1)
  if edge=="TOP" or edge=="BOTTOM" then
   line:SetHeight(1);line:SetPoint(edge.."LEFT",panel,edge.."LEFT");line:SetPoint(edge.."RIGHT",panel,edge.."RIGHT")
  else
   line:SetWidth(1);line:SetPoint("TOP"..edge,panel,"TOP"..edge);line:SetPoint("BOTTOM"..edge,panel,"BOTTOM"..edge)
  end
 end
 panel:Hide()
 panel:HookScript("OnShow",function() M.Queue() end)
 button:RegisterForClicks("LeftButtonUp","RightButtonUp");button:RegisterForDrag("LeftButton")
 button:SetScript("OnClick",function(_,mouse)
  if dragging then return end
  if mouse=="RightButton" then panel:Hide();if K.ShowPage then K.ShowPage("minimap") end;return end
  if not InCombatLockdown() then M.Refresh() end
  if total>0 then panel:SetShown(not panel:IsShown()) end
 end)
 button:SetScript("OnEnter",function(self) if not M.Get("showTooltip") then return end;K.ShowTooltip(self,K.L("mbTitle"),K.L("mbClick").."\n"..tostring(total).." "..K.L("mbCount")) end)
 button:SetScript("OnLeave",function() if K.HideTooltip then K.HideTooltip() end end)
 button:SetScript("OnDragStart",function(self)
  if M.Get("locked") or InCombatLockdown() then return end
  panel:Hide();dragging=true
  -- A cursor update exists only during an explicit drag, never while idle.
  self:SetScript("OnUpdate",function()
   if InCombatLockdown() then StopDrag();return end
   local x,y=GetCursorPosition();local mx,my=Minimap:GetCenter();local scale=Minimap:GetEffectiveScale()
   local angle=math.deg(math.atan2(y/scale-my,x/scale-mx))
   K.db.minimapButtons=K.db.minimapButtons or {};K.db.minimapButtons.angle=angle;Position()
  end)
 end)
 button:SetScript("OnDragStop",function() StopDrag() end)
 button:SetScript("OnHide",StopDrag)
 Minimap:HookScript("OnSizeChanged",function() M.Queue() end)
 hooksecurefunc(Minimap,"SetScale",function() M.Queue() end)
end
local function Watch(b)
 if watched[b] then return end
 watched[b]=true
 -- Hooks observe explicit methods, not visibility inherited from our hidden panel.
 for _,method in ipairs({"Show","Hide","SetShown","SetPoint","ClearAllPoints","SetParent","SetScale","SetFrameStrata","SetFrameLevel","SetFixedFrameStrata","SetFixedFrameLevel"}) do
  if type(b[method])=="function" then
   hooksecurefunc(b,method,function() if not mutating and M.Get("enabled") then M.Queue() end end)
  end
 end
 hooksecurefunc(b,"SetScript",function(_,key) if not mutating and M.Get("enabled") and (key=="OnDragStart" or key=="OnDragStop") then M.Queue() end end)
end
local function Collect(b,name,registered)
 if not Candidate(b) then return end
 if not registered then
  local n=b:GetName() or ""
  if issecurevariable and issecurevariable(_G,n) then return end
  local lower=n:lower()
  -- Structural naming conventions, not addon-name exceptions. Libraries may
  -- put MinimapButton at the beginning, middle or end of an icon's name.
  if not (lower:find("libdbicon",1,true) or lower:find("minimapbutton",1,true) or lower:find("minimapicon",1,true)
   or lower:find("minimapframe",1,true) or lower:match("[_%-]minimap[_%-]") or lower:match("minimap$")) then return end
  if b:IsObjectType("Button") and not b:GetScript("OnClick") and not b:GetScript("OnMouseUp") then return end
 end
 local id=b:GetName() or name and ("registered:"..name)
 if type(id)~="string" or #id==0 or #id>160 then return end
 local label=b.dataObject and (b.dataObject.label or b.dataObject.text)
 if type(label)~="string" or label=="" then label=name or id:gsub("^LibDBIcon10_",""):gsub("^MinimapButton_D4Lib_LibDBIcon_","") end
 local icon=b.icon and b.icon.GetTexture and b.icon:GetTexture()
 known[b]={id=id,label=label:sub(1,100),texture=icon}
 Watch(b)
 if not M.IsIncluded(id) then return end
 if Hidden(b) or (b.GetAlpha and b:GetAlpha()==0) or records[b] then return end
 local points={};for i=1,b:GetNumPoints() do points[i]={b:GetPoint(i)} end
 records[b]={parent=b:GetParent(),points=points,scale=b:GetScale(),strata=b:GetFrameStrata(),level=b:GetFrameLevel(),fixedStrata=b.HasFixedFrameStrata and b:HasFixedFrameStrata(),fixedLevel=b.HasFixedFrameLevel and b:HasFixedFrameLevel(),
  ignore=b.IsIgnoringParentScale and b:IsIgnoringParentScale(),dragStart=b:GetScript("OnDragStart"),dragStop=b:GetScript("OnDragStop"),name=name or b:GetName() or ""}
end
local function Registry()
 if not LibStub then return end
 local lib=LibStub("LibDBIcon-1.0",true)
 if lib and lib.GetButtonList and lib.GetMinimapButton then
 if not libraries[lib] and lib.RegisterCallback then
  libraries[lib]=true
  lib.RegisterCallback(M,"LibDBIcon_IconCreated",function() M.Queue() end)
 end
 for _,name in ipairs(lib:GetButtonList()) do Collect(lib:GetMinimapButton(name),name,true) end
 end
 local mapLib=LibStub("LibMapButton-1.1",true)
 if mapLib and type(mapLib.buttons)=="table" then
  for name,icon in pairs(mapLib.buttons) do Collect(icon,tostring(name),true) end
 end
end
function M.Refresh()
 if InCombatLockdown() then pending=true;return end
 pending=false;mutating=true
 if not M.Get("enabled") or Blocked() then
  for b,record in pairs(records) do Restore(b,record) end
  total=0
  if panel then panel:Hide() end
  if button then button:Hide() end
  mutating=false;return
 end
 EnsureUI()
 if not panel then mutating=false;return end
 Appearance()
 Registry()
 for _,parent in ipairs({Minimap or false,MinimapBackdrop or false,MinimapCluster or false}) do
  if parent and not (parent.IsForbidden and parent:IsForbidden()) and parent.GetChildren then for _,b in ipairs({parent:GetChildren()}) do Collect(b,nil,false) end end
 end
 local list={}
 for b,record in pairs(records) do
  if not Candidate(b) or known[b] and not M.IsIncluded(known[b].id) or b.db and b.db.hide==true or b.showOnMouseover then
   Restore(b,record)
  elseif b:IsShown() then list[#list+1]=b end
 end
 table.sort(list,function(a,b) return records[a].name<records[b].name end)
 total=#list
 local columns=math.min(M.Get("columns"),math.max(1,total));local cell=M.Get("iconSize")+6
 panel:SetSize(columns*cell+16,math.max(1,math.ceil(total/columns))*cell+16)
 panel:ClearAllPoints()
 -- Open flush beside the drawer, towards the left-hand free space. Only
 -- mirror at the left screen edge, where clamping would cover the drawer.
 local left=button.GetLeft and button:GetLeft()
 if left and left<panel:GetWidth() then panel:SetPoint("TOPLEFT",button,"TOPRIGHT",0,0)
 else panel:SetPoint("TOPRIGHT",button,"TOPLEFT",0,0) end
 for i,b in ipairs(list) do
  local width,height=b:GetWidth(),b:GetHeight()
  -- LibDBIcon buttons lock their levels/strata. Release only while owned so
  -- later parent raising and strata changes carry every icon with the panel.
  -- Capture/restore both flags instead of permanently changing library behavior.
  local record=records[b]
  if b.SetFixedFrameStrata and record.fixedStrata~=nil then b:SetFixedFrameStrata(false) end
  if b.SetFixedFrameLevel and record.fixedLevel~=nil then b:SetFixedFrameLevel(false) end
  b:SetParent(panel);b:ClearAllPoints()
  if b.SetIgnoreParentScale then b:SetIgnoreParentScale(false) end
  b:SetScale(M.Get("iconSize")/math.max(width,height,1))
  b:SetFrameStrata(panel:GetFrameStrata());b:SetFrameLevel(panel:GetFrameLevel()+10)
  local scale=b:GetScale()
  b:SetPoint("CENTER",panel,"TOPLEFT",(8+(i-1)%columns*cell+cell/2)/scale,-(8+math.floor((i-1)/columns)*cell+cell/2)/scale)
  b:SetScript("OnDragStart",nil);b:SetScript("OnDragStop",nil)
 end
 -- Hidden buttons keep their own Hide state while remaining eligible for later Show.
 if total==0 then panel:Hide() end
 Position();button:Show()
 mutating=false
end
function M.Queue()
 if mutating or queued then return end
 queued=true
 C_Timer.After(.1,function() queued=false;M.Refresh() end)
end
function M.Set(key,value)
 if InCombatLockdown() or defaults[key]==nil then return false end
 if key=="enabled" and value==true and Blocked() then return false end
 if type(defaults[key])=="boolean" then if type(value)~="boolean" then return false end
 else
  if type(value)~="number" or value~=value or math.abs(value)==math.huge then return false end
  value=math.max(bounds[key][1],math.min(bounds[key][2],math.floor(value+.5)))
 end
 K.db.minimapButtons=K.db.minimapButtons or {};K.db.minimapButtons[key]=value
 if key=="showTooltip" and not value and K.HideTooltip then K.HideTooltip() end
 M.Refresh();return true
end
function M.IsIncluded(id)
 local db=K.db and K.db.minimapButtons
 return not (db and db.excluded and db.excluded[id]==true)
end
function M.Icons()
 local result={}
 for b,entry in pairs(known) do
  if Candidate(b) and not Hidden(b) and (not b.GetAlpha or b:GetAlpha()>0) then
   result[#result+1]={id=entry.id,label=entry.label,texture=entry.texture,included=M.IsIncluded(entry.id)}
  end
 end
 table.sort(result,function(a,b) return a.label==b.label and a.id<b.id or a.label<b.label end)
 return result
end
function M.SetIncluded(id,value)
 if InCombatLockdown() or type(value)~="boolean" or type(id)~="string" or #id>160 then return false end
 local found=false;for _,entry in pairs(known) do if entry.id==id then found=true;break end end
 if not found then return false end
 K.db.minimapButtons=K.db.minimapButtons or {}
 local db=K.db.minimapButtons;db.excluded=db.excluded or {}
 if value then db.excluded[id]=nil
 else
  local count=0;for _ in pairs(db.excluded) do count=count+1 end
  if count>=128 and not db.excluded[id] then return false end
  db.excluded[id]=true
 end
 M.Refresh();return true
end
function M.Status() return Blocked() and "mbConflict" or "mbHelp" end
function M.Count() return total end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","ADDON_LOADED","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",function(_,event)
 if event=="PLAYER_REGEN_DISABLED" then StopDrag();return end
 if event=="PLAYER_REGEN_ENABLED" and not pending then return end
 M.Queue()
 if event=="PLAYER_LOGIN" then C_Timer.After(1,function() M.Queue() end) end
end)

function K.DrawMinimapButtons(page,w,y)
 w.Text(page,K.L("mbTitle"),8,y,690,18,{.73,.62,.41});y=y-36
 w.Text(page,K.L(M.Status()),8,y,690,13,M.IsBlocked() and {1,.72,.30} or {.65,.70,.62});y=y-112
 w.Text(page,K.L("mbClick"),8,y,690,13,{.65,.70,.62});y=y-76
 w.Text(page,K.L("mbAppearance"),8,y,690,16,{.73,.62,.41});y=y-32
 for i,key in ipairs({"mbRound","mbSquare"}) do
  local style=i
  local choice=w.Button(page,K.L(key),(i-1)*365,y,349,50,function()
   if M.Set("buttonStyle",style) and K.Render then K.Render() end
  end)
  if not choice.mbRowIcon then choice.mbRowIcon=choice:CreateTexture(nil,"ARTWORK") end
  choice.mbRowIcon:SetTexture(M.ArtPath(style));choice.mbRowIcon:ClearAllPoints()
  choice.mbRowIcon:SetPoint("LEFT",14,0);choice.mbRowIcon:SetSize(36,36);choice.mbRowIcon:Show()
  w.Selected(choice,M.Get("buttonStyle")==style)
 end
 y=y-68
 for i,f in ipairs({{"enabled","mbEnabled"},{"locked","mbLocked"},{"showTooltip","mbShowTooltip"},{"columns","mbColumns",1,12},{"iconSize","mbSize",24,40},{"buttonSize","mbButtonSize",20,64},{"angle","mbAngle",-360,360},{"radius","mbRadius",0,80}}) do
  local key,label,low,high=unpack(f)
  local card=w.Box(page,(i-1)%2*365,y-math.floor((i-1)/2)*96,349,86)
  w.Text(card,K.L(label),14,-12,278,13)
  local help=w.Button(card,"?",311,-10,22,22,function() end);w.Tip(help,label,"mbHelp")
  if low then
   local text=w.Text(card,tostring(M.Get(key)),14,-54,150,15)
   for _,delta in ipairs({-1,1}) do
    local d=delta
    w.Button(card,d<0 and "−" or "+",d<0 and 251 or 297,-47,36,32,function()
     if M.Set(key,M.Get(key)+d) then text:SetText(tostring(M.Get(key))) end
    end)
   end
  else
   local blocked=key=="enabled" and M.IsBlocked()
   w.Switch(card,not blocked and M.Get(key),255,-48,function(value) M.Set(key,value) end,not blocked and not InCombatLockdown())
  end
 end
 y=y-404
 w.Text(page,K.L("mbPreferences"),8,y,690,18,{.73,.62,.41});y=y-36
 w.Text(page,K.L("mbPreferencesHelp"),8,y,690,13,{.65,.70,.62});y=y-72
 if not InCombatLockdown() then M.Refresh() end
 local icons=M.Icons()
 if #icons==0 then w.Text(page,K.L("mbEmpty"),8,y,690,13);return y-60 end
 for _,item in ipairs(icons) do
  local entry=item
  local card=w.Box(page,0,y,714,70)
  if not card.mbRowIcon then card.mbRowIcon=card:CreateTexture(nil,"ARTWORK") end
  card.mbRowIcon:SetTexture(entry.texture or "Interface\\AddOns\\KerimAnkaUI\\Media\\Phoenix.tga")
  card.mbRowIcon:ClearAllPoints();card.mbRowIcon:SetPoint("LEFT",14,0);card.mbRowIcon:SetSize(30,30);card.mbRowIcon:Show()
  w.Text(card,entry.label,58,-12,480,14)
  w.Text(card,K.L("mbCollect"),58,-37,480,12,{.65,.70,.62})
  w.Switch(card,entry.included,620,-22,function(value)
   if M.SetIncluded(entry.id,value) and K.Render then K.Render() end
  end,not InCombatLockdown())
  y=y-80
 end
 return y
end
