local _,K=...
local function JournalSettings()
 local api=ForeverQuestJournalAPI
 local db=api and api.version>=2 and api.GetSettings()
 return api,db,db and api.IsSuspended and api.IsSuspended()
end
function K.QuestSettingVisible(key)
 if key=='qjQuestieTracker' then return K.QuestieCompat~=nil end
 local _,db,suspended=JournalSettings()
 return db and not suspended
end
function K.DrawQuestPage(page,anchor)
 local w=K.UnitWidgets
 local compat=K.QuestieCompat
 local offset=0
 if compat then
  local card=w.Box(page,0,0,714,62)
  if anchor then anchor('qjQuestieTracker',card) end
  w.Text(card,K.L('qjQuestieTracker'),16,-20,550,14)
  w.Switch(card,compat.Allowed(),620,-16,function(value)
   if compat.SetAllowed(value) then K.Render() end
  end,not K.InCombat())
  w.Text(page,K.L('qjQuestieHelp'),8,-78,690,13,{.65,.70,.62})
  offset=-162
 end
 local api,db,suspended=JournalSettings()
 if not db then page:SetHeight(200);return compat~=nil end
 if suspended then
  w.Text(page,K.L('qjSafetyPaused'),8,offset,690,17,{.90,.73,.38})
  w.Text(page,K.L('qjSafetyHelp'),8,offset-55,690,14,{.65,.70,.62})
  page:SetHeight(280-offset);return true
 end
 w.Text(page,K.L('qjNativeHelp'),8,offset,690,14,{.65,.70,.62})
 local y=offset-110
 w.Text(page,K.L(api.Status()),8,y,690,13,api.IsAttached() and {.65,.70,.62} or {.90,.73,.38});y=y-76
 local box=w.Box(page,0,y,714,62)
 if anchor then anchor('qjScrollEnabled',box) end
 w.Text(box,K.L('qjScrollEnabled'),16,-20,550,14)
 w.Switch(box,db.scrollEnabled,620,-16,function(value) if api.Set('scrollEnabled',value) then K.Render() end end,not K.InCombat())
 y=y-82
 local allQuests=w.Box(page,0,y,714,62)
 if anchor then anchor('qjShowAllQuests',allQuests) end
 w.Text(allQuests,K.L('qjShowAllQuests'),16,-20,550,14)
 w.Switch(allQuests,db.showAllQuests~=false,620,-16,function(value) if api.Set('showAllQuests',value) then K.Render() end end,not K.InCombat())
 y=y-82
 w.Text(page,K.L('qjShowAllQuestsHelp'),8,y,690,13,{.65,.70,.62});y=y-105
 local grouping=w.Box(page,0,y,714,62)
 if anchor then anchor('qjGroupByZone',grouping) end
 w.Text(grouping,K.L('qjGroupByZone'),16,-20,550,14)
 w.Switch(grouping,db.groupByZone,620,-16,function(value) if api.Set('groupByZone',value) then K.Render() end end,not K.InCombat())
 y=y-82
 w.Text(page,K.L('qjZoneHelp'),8,y,690,13,{.65,.70,.62});y=y-105
 local card=w.Box(page,0,y,349,86)
 if anchor then anchor('qjScrollStep',card) end
 w.Text(card,K.L('qjScrollStep'),14,-12,310,13)
 local text=w.Text(card,tostring(db.scrollStep),14,-54,150,15)
 for _,delta in ipairs({-4,4}) do
  local change=delta
  local b=w.Button(card,change<0 and '−' or '+',change<0 and 251 or 297,-47,36,32,function()
   if api.Set('scrollStep',db.scrollStep+change) then text:SetText(tostring(db.scrollStep)) end
  end)
  if K.InCombat() then b:Disable() end
 end
 w.Text(page,K.L('qjHeightHelp'),8,y-112,690,14,{.65,.70,.62})
 page:SetHeight(-y+218)
 return true
end
