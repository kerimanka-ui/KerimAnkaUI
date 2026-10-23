local _,K=...
function K.DrawQuestPage(page)
 local w=K.UnitWidgets
 local compat=K.QuestieCompat
 local offset=0
 if compat then
  local card=w.Box(page,0,0,714,62)
  w.Text(card,K.L('qjQuestieTracker'),16,-20,550,14)
  w.Switch(card,compat.Allowed(),620,-16,function(value)
   if compat.SetAllowed(value) then K.Render() end
  end,not K.InCombat())
  w.Text(page,K.L('qjQuestieHelp'),8,-78,690,13,{.65,.70,.62})
  offset=-162
 end
 local api=ForeverQuestJournalAPI
 local db=api and api.version>=2 and api.GetSettings()
 if not db then page:SetHeight(200);return compat~=nil end
 if api.IsSuspended and api.IsSuspended() then
  w.Text(page,K.L('qjSafetyPaused'),8,offset,690,17,{.90,.73,.38})
  w.Text(page,K.L('qjSafetyHelp'),8,offset-55,690,14,{.65,.70,.62})
  page:SetHeight(280-offset);return true
 end
 w.Text(page,K.L('qjNativeHelp'),8,offset,690,14,{.65,.70,.62})
 local y=offset-110
 w.Text(page,K.L(api.Status()),8,y,690,13,api.IsAttached() and {.65,.70,.62} or {.90,.73,.38});y=y-76
 local box=w.Box(page,0,y,714,62)
 w.Text(box,K.L('qjScrollEnabled'),16,-20,550,14)
 w.Switch(box,db.scrollEnabled,620,-16,function(value) if api.Set('scrollEnabled',value) then K.Render() end end,not K.InCombat())
 y=y-82
 local grouping=w.Box(page,0,y,714,62)
 w.Text(grouping,K.L('qjGroupByZone'),16,-20,550,14)
 w.Switch(grouping,db.groupByZone,620,-16,function(value) if api.Set('groupByZone',value) then K.Render() end end,not K.InCombat())
 y=y-82
 w.Text(page,K.L('qjZoneHelp'),8,y,690,13,{.65,.70,.62});y=y-105
 local card=w.Box(page,0,y,349,86)
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
