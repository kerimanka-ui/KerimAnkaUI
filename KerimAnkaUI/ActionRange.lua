local _,K=...
local M={};K.ActionRange=M
local records=setmetatable({},{__mode="k"})
local prefixes={"ActionButton","MultiBarBottomLeftButton","MultiBarBottomRightButton","MultiBarRightButton","MultiBarLeftButton","MultiBar5Button","MultiBar6Button","MultiBar7Button"}
local guard,queued,pending,rangeHook,providerHook
local function Public(v) return not (issecretvalue and issecretvalue(v)) end
local function Source()
 if KerimAnkaUIBarsAPI then return KerimAnkaUIBarsAPI.Resolve() end
 return "blizzard",false
end
function M.Enabled() return not (K.db and K.db.actionRange and K.db.actionRange.enabled==false) end
function M.Color()
 local c=K.db and K.db.actionRange and K.db.actionRange.color
 if type(c)=="table" then return c[1],c[2],c[3] end
 return .8,.1,.1
end
local function Active(kind)
 local source,blocked=Source();return M.Enabled() and not blocked and source==kind
end
local function ColorSafe(r,g,b,a)
 return Public(r) and Public(g) and Public(b) and Public(a) and type(r)=="number" and type(g)=="number" and type(b)=="number"
end
local function Write(record,r,g,b,a)
 guard=true;record.icon:SetVertexColor(r,g,b,a or 1);guard=false
end
local function Paint(record)
 if record.kind~="blizzard" then return end
 local slot=record.button.action
 if not Public(slot) or slot~=record.slot then record.out=nil end
 if Active("blizzard") and record.out==true and record.base then
  local r,g,b=M.Color();Write(record,r,g,b,record.base[4]);record.painted=true
 elseif record.painted and record.base then
  Write(record,unpack(record.base));record.painted=false
 end
end
local function Range(record,checks,inRange)
 if not Public(checks) or not Public(inRange) then record.out=nil
 else record.out=checks==true and (inRange==false or inRange==0) end
 local slot=record.button.action;record.slot=Public(slot) and slot or nil
 Paint(record)
end
local function Seed(record)
 if not Active("blizzard") then Range(record,false,nil);return end
 if InCombatLockdown() then record.out=nil;Paint(record);return end
 local slot=record.button.action
 if not Public(slot) or type(slot)~="number" or slot<=0 then Range(record,false,nil);return end
 local hasRange=C_ActionBar and C_ActionBar.HasRangeRequirements or ActionHasRange
 local isInRange=C_ActionBar and C_ActionBar.IsActionInRange or IsActionInRange
 if not hasRange or not isInRange then Range(record,false,nil);return end
 local ok,checks=pcall(hasRange,slot)
 if not ok or not Public(checks) or checks~=true then Range(record,false,nil);return end
 local yes,value=pcall(isInRange,slot)
 if yes then Range(record,checks,value) else Range(record,false,nil) end
end
local function Copy(value,seen)
 if type(value)~="table" then return value end
 seen=seen or {};if seen[value] then return seen[value] end
 local result={};seen[value]=result
 for k,v in pairs(value) do result[k]=Copy(v,seen) end
 return result
end
local function BTOriginal(record)
 local config=record.button.config or {}
 record.mode=config.outOfRangeColoring
 record.range=Copy(config.colors and config.colors.range)
end
local function BTApply(record)
 if InCombatLockdown() then pending=true;return end
 local enabled=Active("bartender")
 if not enabled and not record.owned then return end
 local r,g,b=M.Color()
 if enabled and record.owned and record.red==r and record.green==g and record.blue==b then return end
 local config=Copy(record.button.config or {})
 config.colors=config.colors or {}
 if enabled then
  config.outOfRangeColoring="button";config.colors.range={r,g,b}
 else config.outOfRangeColoring=record.mode;config.colors.range=Copy(record.range) end
 guard=true;record.button:UpdateConfig(config);guard=false;record.owned=enabled
 record.red,record.green,record.blue=r,g,b
end
local function Track(button,kind)
 if not button or records[button] or button.IsForbidden and button:IsForbidden() then return end
 local icon=button.icon or button.Icon
 if not icon or not icon.SetVertexColor then return end
 local record={button=button,icon=icon,kind=kind};records[button]=record
 if kind=="bartender" then
  if not button.UpdateConfig then records[button]=nil;return end
  BTOriginal(record)
  hooksecurefunc(button,"UpdateConfig",function()
   if guard then return end
   BTOriginal(record);record.owned=false;BTApply(record)
  end)
 else
  local r,g,b,a=icon:GetVertexColor()
  if ColorSafe(r,g,b,a) then record.base={r,g,b,a or 1} end
  hooksecurefunc(icon,"SetVertexColor",function(_,red,green,blue,alpha)
   if guard then return end
   record.painted=false
   record.base=ColorSafe(red,green,blue,alpha) and {red,green,blue,alpha or 1} or nil
   Paint(record)
  end)
  if button.UpdateAction then hooksecurefunc(button,"UpdateAction",function() Seed(record) end) end
  if button.HookScript then
   button:HookScript("OnHide",function() record.out=nil;Paint(record) end)
   button:HookScript("OnShow",function() Seed(record) end)
  end
 end
end
function M.Refresh()
 if InCombatLockdown() then pending=true;return end
 pending=false
 if not rangeHook and type(ActionButton_UpdateRangeIndicator)=="function" then
  rangeHook=true
  hooksecurefunc("ActionButton_UpdateRangeIndicator",function(button,checks,inRange)
   local record=records[button]
   if record and record.kind=="blizzard" then Range(record,checks,inRange) end
  end)
 end
 if not providerHook and KerimAnkaUIBarsAPI and KerimAnkaUIBarsAPI.Refresh then
  providerHook=true;hooksecurefunc(KerimAnkaUIBarsAPI,"Refresh",function() M.Queue() end)
 end
 for _,prefix in ipairs(prefixes) do for i=1,12 do Track(_G[prefix..i],"blizzard") end end
 for i=1,120 do Track(_G["BT4Button"..i],"bartender") end
 for _,record in pairs(records) do
  if record.kind=="bartender" then BTApply(record) else Seed(record) end
 end
end
function M.Queue()
 if queued then return end
 queued=true;C_Timer.After(0,function() queued=false;M.Refresh() end)
end
function M.SetEnabled(value)
 if InCombatLockdown() or type(value)~="boolean" then return false end
 K.db.actionRange=K.db.actionRange or {};K.db.actionRange.enabled=value;M.Refresh();return true
end
function M.SetColor(color,restore)
 if InCombatLockdown() and not restore then return false end
 if color~=nil then
  if type(color)~="table" or #color~=3 then return false end
  for _,v in ipairs(color) do if not Public(v) or type(v)~="number" or v~=v or v<0 or v>1 then return false end end
 end
 K.db.actionRange=K.db.actionRange or {};K.db.actionRange.color=color and {unpack(color)} or nil
 if InCombatLockdown() then pending=true else M.Refresh() end
 return true
end
function M.OpenColorPicker(onChange)
 if InCombatLockdown() then return false end
 local picker=ColorPickerFrame
 if not picker or not picker.SetupColorPickerAndShow then return false end
 local db=K.db and K.db.actionRange;local before=db and db.color and {unpack(db.color)}
 local r,g,b=M.Color()
 picker:SetupColorPickerAndShow({r=r,g=g,b=b,hasOpacity=false,
  swatchFunc=function() local red,green,blue=picker:GetColorRGB();if M.SetColor({red,green,blue}) and onChange then onChange() end end,
  cancelFunc=function() M.SetColor(before,true);if onChange then onChange() end end})
 if picker.Raise then picker:Raise() end
 return true
end
local frame=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","ADDON_LOADED","ACTIONBAR_PAGE_CHANGED","ACTIONBAR_SLOT_CHANGED","UPDATE_BONUS_ACTIONBAR","UPDATE_SHAPESHIFT_FORM","PLAYER_TARGET_CHANGED","PLAYER_REGEN_ENABLED"}) do frame:RegisterEvent(event) end
frame:SetScript("OnEvent",function(_,event)
 if event=="PLAYER_TARGET_CHANGED" then
  for _,record in pairs(records) do if record.kind=="blizzard" then record.out=nil;Paint(record) end end
 end
 if event=="PLAYER_REGEN_ENABLED" and not pending then return end
 M.Queue()
end)
function K.DrawActionRange(page,w,y)
 local card=w.Box(page,0,y,714,124)
 w.Text(card,K.L("arEnabled"),16,-14,540,14)
 local help=w.Button(card,"?",584,-12,22,22,function() end);w.Tip(help,"arEnabled","arHelp")
 w.Switch(card,M.Enabled(),620,-10,function(value) M.SetEnabled(value) end,not InCombatLockdown())
 local r,g,b=M.Color()
 local color=w.Button(card,K.L("arColor"),16,-65,320,36,function() M.OpenColorPicker(function() if K.Render then K.Render() end end) end)
 if not color.arSwatch then color.arSwatch=color:CreateTexture(nil,"ARTWORK") end
 color.arSwatch:ClearAllPoints();color.arSwatch:SetPoint("RIGHT",-10,0);color.arSwatch:SetSize(18,18);color.arSwatch:SetColorTexture(r,g,b,1);color.arSwatch:Show()
 w.Button(card,K.L("arReset"),350,-65,348,36,function() if M.SetColor(nil) and K.Render then K.Render() end end)
 return y-142
end
