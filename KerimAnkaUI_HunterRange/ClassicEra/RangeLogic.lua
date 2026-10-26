-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,ns=...
local function Ask(fn,...)
 if type(fn)~='function'then return nil end
 local ok,v=pcall(fn,...)
 if not ok or(issecretvalue and issecretvalue(v))then return nil end
 if v==true or v==1 then return true end
 if v==false or v==0 then return false end
 return nil
end
local families={
 {2974,14267,14268}, -- Wing Clip: primary instant melee-range check.
 {1495,14269,14270,14271}, -- Mongoose Bite; range does not require usability.
 {19306,20909,20910}, -- Counterattack, when learned.
 -- Raptor Strike is next-swing: Classic can report true at any distance.
}
local probes,names={},{}
local function Name(id)
 if names[id]then return names[id]end
 local value
 if GetSpellInfo then local ok,n=pcall(GetSpellInfo,id);if ok then value=n end end
 if not value and C_Spell and C_Spell.GetSpellInfo then
  local ok,info=pcall(C_Spell.GetSpellInfo,id);if ok and type(info)=='table'then value=info.name end
 end
 if type(value)=='string'then names[id]=value;return value end
end
-- Classic Era five-yard hostile-item probe, without owning/using the item.
-- Only trust it once the item's metadata is cached; never convert nil to false.
local MELEE_ITEM=8149 -- Voodoo Charm (Classic five-yard range probe).
local itemReady,itemRequested=false,false
local function ItemReady()
 if itemReady then return true end
 local info=C_Item and C_Item.GetItemInfo or GetItemInfo
 if type(info)=="function" then
  local ok,name=pcall(info,MELEE_ITEM)
  if ok and not (issecretvalue and issecretvalue(name)) and type(name)=="string" and name~="" then itemReady=true;return true end
 end
 if not itemRequested and C_Item and type(C_Item.RequestLoadItemDataByID)=="function" then
  itemRequested=true;pcall(C_Item.RequestLoadItemDataByID,MELEE_ITEM)
 end
 return false
end
function ns.ItemMeleeRange(unit)
 if not ItemReady() then return nil end
 local value=Ask(C_Item and C_Item.IsItemInRange,MELEE_ITEM,unit)
 if value~=nil then return value end
 return Ask(IsItemInRange,MELEE_ITEM,unit)
end
function ns.RefreshRangeSpells()
 probes={};names={}
 ItemReady()
 for _,ranks in ipairs(families)do
  for i=#ranks,1,-1 do
   local id=ranks[i]
   if Ask(IsSpellKnown,id)==true or Ask(IsPlayerSpell,id)==true then
    local hasRange=Ask(C_Spell and C_Spell.SpellHasRange,id)
    if hasRange==nil then hasRange=Ask(SpellHasRange,Name(id))end
    if hasRange~=false then probes[#probes+1]=id end
    break
   end
  end
 end
end
function ns.SpellRange(id,unit)
 local value=Ask(C_Spell and C_Spell.IsSpellInRange,id,unit)
 if value~=nil then return value end
 local name=Name(id)
 if name then return Ask(IsSpellInRange,name,unit)end
 return nil
end
function ns.MeleeRange(unit)
 for _,id in ipairs(probes)do
  local value=ns.SpellRange(id,unit)
  -- A valid Wing Clip result is authoritative; cooldown/resources are irrelevant.
  if value~=nil then return value end
 end
 return ns.ItemMeleeRange(unit)
end
function ns.MeleeProbeText()return table.concat(probes,',')end
-- Only current, valid spell measurements may assert melee or dead zone.
function ns.Classify(shoot,near,melee)
 if melee==true then return 'melee'end
 if shoot==true then return 'ranged'end
 if shoot~=false then return 'unknown'end
 if near==false then return 'far'end
 if near~=true then return 'unknown'end
 if melee==false then return 'dead'end
 return 'close'
end
