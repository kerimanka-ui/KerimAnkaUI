-- Classic Era only. Selective profile operations do not control native layouts.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local T={};K.ProfileTransfer=T
local UNIT='KAClassic_ForeverLeatherUnitsDB'
T.groups={{id='units',label='psUnits'},{id='chat',label='psChat'},{id='bags',label='psBags'}}
local rootKeys={chat={'chat','microEnabled','microLocked','microSize','microGap','microX','microY'},bags={'bagCombined','hideNativeBagBar','bagJunk','bagQuality','bagQuest','bagEmptySlots','bagItemGap','bagDesign','bagBackground','bagFrame','bagIconBorder','bagSize','bagGap','bagShortcut','classicBags','classicBank'}}
local function Copy(v)
 if type(v)~='table'then return v end
 local result={};for k,x in pairs(v)do result[k]=Copy(x)end;return result
end
local function Same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not Same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
function T.ValidSelection(selection)
 if type(selection)~='table'or getmetatable(selection)then return false end
 local n=0
 for id,v in pairs(selection)do
  if (id~='units'and id~='chat'and id~='bags')or v~=true then return false end
  n=n+1
 end
 return n>0
end
local function UnitKeys()
 local result={}
 for _,key in ipairs(K.Profiles.TransferFields(UNIT))do
  -- Initializer markers and the launcher are target-character infrastructure.
  if key~='minimap'and key~='compactMigration'and not key:find('Initialized$')then result[#result+1]=key end
 end
 return result
end
function T.ModuleSelected(selection,name)return selection.units and name==UNIT end
function T.Available(payload,id)
 if not payload or not payload.settings then return false end
 local s=payload.settings
 if id=='units'then
  local data=s[UNIT];if type(data)~='table'then return false end
  for _,key in ipairs(UnitKeys())do if data[key]~=nil then return true end end
 else
  for _,key in ipairs(rootKeys[id]or{})do if s.root and s.root[key]~=nil then return true end end
 end
 return false
end
local function Filter(payload,selection)
 local result={app='KerimAnkaUI',version=1,class=payload.class,settings={root={},appearance={}}}
 for id in pairs(selection)do
  if id=='units'then
   result.settings[UNIT]={}
   for _,key in ipairs(UnitKeys())do result.settings[UNIT][key]=Copy(payload.settings[UNIT]and payload.settings[UNIT][key])end
  else
   for _,key in ipairs(rootKeys[id])do result.settings.root[key]=Copy(payload.settings.root[key])end
  end
 end
 return result
end
function T.Decode(code)
 local P=K.Profiles
 if type(code)~='string'or #code>P.MAX_CODE+4096 then return nil,'pfTooLarge' end
 local compact=code:gsub('%s','')
 if compact:sub(1,6)=='KAUI1:'then return P.Decode(compact)end
 -- A partial export is explicitly versioned and Classic-only. Old clients reject it.
 local ids,inner=compact:match('^KAUI2:ClassicEra:([a-z,]+):(KAUI1:.*)$')
 if not ids or #compact>P.MAX_CODE then return nil,'pfInvalid'end
 local selection={};local canonical={}
 for id in ids:gmatch('[^,]+')do
  if selection[id]then return nil,'pfInvalid'end
  selection[id]=true;canonical[#canonical+1]=id
 end
 if table.concat(canonical,',')~=ids or not T.ValidSelection(selection)then return nil,'pfInvalid'end
 local payload,err=P.Decode(inner);if not payload then return nil,err end
 for id in pairs(selection)do if not T.Available(payload,id)then return nil,'pfInvalid'end end
 if not Same(Filter(payload,selection),payload)then return nil,'pfInvalid'end
 return payload,nil,selection
end
function T.Export(selection,payload)
 local P=K.Profiles;payload=payload or P.Capture()
 if not P.Validate(payload)then return nil,'pfInvalid'end
 if not selection then return P.Encode(payload)end
 if not T.ValidSelection(selection)then return nil,'psChooseOne'end
 local ids={}
 for _,g in ipairs(T.groups)do if selection[g.id]then
  if not T.Available(payload,g.id)then return nil,'psUnavailable'end
  ids[#ids+1]=g.id
 end end
 local code,err=P.Encode(Filter(payload,selection));if not code then return nil,err end
 code='KAUI2:ClassicEra:'..table.concat(ids,',')..':'..code
 if #code>P.MAX_CODE then return nil,'pfTooLarge'end
 return code
end
function T.Preview(code,selection)
 local payload,err,scope=T.Decode(code);if not payload then return nil,err end
 local chosen=selection or scope
 if chosen then
  if not T.ValidSelection(chosen)then return nil,'psChooseOne'end
  for id in pairs(chosen)do
   if scope and not scope[id]or not T.Available(payload,id)then return nil,'psUnavailable'end
  end
 end
 return payload,nil,chosen
end
function T.Apply(code,label,selection)
 local P=K.Profiles
 local payload,err,chosen=T.Preview(code,selection);if not payload then return false,err end
 if not chosen then return P.Apply(code,label)end
 local current=P.Capture()
 if chosen.units then
  -- Establish the target class defaults first; never import source migration flags.
  local data=_G[UNIT]
  local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
  if not loaded or not loaded('KerimAnkaUI_UnitFrames')or type(data)~='table'or not data.compactMigration then return false,'psEnableUnits'end
 end
 local settings=current.settings
 for id in pairs(chosen)do
  if id=='units'then
   settings[UNIT]=settings[UNIT]or{}
   for _,key in ipairs(UnitKeys())do settings[UNIT][key]=Copy(payload.settings[UNIT][key])end
  else
   for _,key in ipairs(rootKeys[id])do settings.root[key]=Copy(payload.settings.root[key])end
  end
 end
 local merged,why=P.Encode(current);if not merged then return false,why end
 return P.Apply(merged,label,nil,chosen)
end
function T.ApplySettings(payload,selection)
 if selection.bags then K.db.bagDock=nil;K.db.bagExpanded=nil end
 local s=payload.settings
 for id in pairs(selection)do
  if id=='units'then
   local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
   if loaded and loaded('KerimAnkaUI_UnitFrames')then
    _G[UNIT]=type(_G[UNIT])=='table'and _G[UNIT]or{}
    for _,key in ipairs(UnitKeys())do _G[UNIT][key]=Copy(s[UNIT][key])end
   else
    K.db.profileDeferred=K.db.profileDeferred or{}
    K.db.profileDeferred[UNIT]=Copy(s[UNIT])
   end
  else
   for _,key in ipairs(rootKeys[id])do K.db[key]=Copy(s.root[key])end
  end
 end
 if selection.bags and K.BagMode then K.BagMode.ApplySaved()end
end
function T.ApplyRecord(record,label,selection)
 if selection then return T.Apply(record.code,label,selection)end
 if K.ProfileLayouts then return K.ProfileLayouts.Queue(record,label)end
 return K.Profiles.Apply(record.code,label)
end
function T.Description(selection)
 if not selection then return K.L('psFullHint')end
 local labels={}
 for _,g in ipairs(T.groups)do if selection[g.id]then labels[#labels+1]=K.L(g.label)end end
 return table.concat(labels,', ')..'\n'..K.L('psPreserveHint')
end
function T.Draw(parent,ui,y,state,changed)
 local box=ui.Box(parent,0,y,714,state.partial and 184 or 106)
 ui.Text(box,K.L('psTitle'),16,-12,680,14)
 local function mode(partial)state.partial=partial;changed()end
 local all=ui.Button(box,K.L('psAll'),16,-42,334,32,function()mode(false)end)
 local selected=ui.Button(box,K.L('psSelected'),362,-42,336,32,function()mode(true)end)
 local function mark(b,active)
  if active then ui.Rounded(b,.20,.25,.15,{.65,.72,.39,1},6,true);b.label:SetTextColor(1,.9,.55)end
 end
 mark(all,not state.partial);mark(selected,state.partial)
 if state.partial then
  for i,g in ipairs(T.groups)do
   local id=g.id
   local b=ui.Button(box,K.L(g.label),16+(i-1)*230,-84,222,32,function()state.selection[id]=not state.selection[id]or nil;changed()end)
   mark(b,state.selection[id])
  end
  ui.Text(box,K.L('psPreserveHint'),16,-130,680,12)
 else ui.Text(box,K.L('psFullHint'),16,-82,680,12)end
 return y-(state.partial and 200 or 122)
end
