-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
local M={};K.SoundGroups=M
-- FileDataID/name pairs checked against wowdev/wow-listfile parts/sound.csv.
-- Bow draw, gunfire and gun reload have been confirmed by our user in Forever.
M.groups={
 {id='bow',title='sgBow',help='sgBowHelp',verified=true,files={
  {567677,'BowPullback'},{567675,'BowPullback02'},{567676,'BowPullback03'}}},
 {id='gun',title='sgGun',help='sgGunHelp',verified=true,files={
  {567721,'GunFire01'},{567718,'GunFire02'},{567722,'GunFire03'}}},
 {id='reload',title='sgReload',help='sgReloadHelp',verified=true,files={
  {567719,'GunLoad01'},{567720,'GunLoad02'},{567723,'GunLoad03'}}},
 {id='wand',title='sgWand',help='sgWandHelp',files={
  {569185,'ShootWandLaunchArcane'},{568765,'ShootWandLaunchFire'},
  {569719,'ShootWandLaunchHoly'},{568090,'ShootWandLaunchIce'},
  {568228,'ShootWandLaunchLightning'},{569151,'ShootWandLaunchNature'},
  {568950,'ShootWandLaunchPoison'},{568935,'ShootWandLaunchShadow'}}},
}
local function Group(id)
 for _,g in ipairs(M.groups) do if g.id==id then return g end end
end
function M.State(id)
 local g=Group(id);if not g then return end
 local count,failed=0,false
 for _,file in ipairs(g.files) do
  if K.db and K.db.sounds and K.db.sounds[file[1]] then
   count=count+1
   if K.CustomSoundState(file[1])~='soundMuteActive' then failed=true end
  end
 end
 return failed and 'soundMuteFailed' or count==#g.files and 'sgEnabled' or count>0 and 'sgPartial' or 'sgDisabled',count,#g.files
end
function M.Set(id,enabled)
 local g=Group(id)
 if not g or type(enabled)~='boolean' then return false,'sgFailed' end
 if not MuteSoundFile or not UnmuteSoundFile then return false,'unavailable' end
 if not K.db or type(K.db.sounds)~='table' then return false,'sgFailed' end
 if enabled then
  local ids={};for _,file in ipairs(g.files) do ids[#ids+1]=file[1] end
  -- Existing atomic validation enforces the shared 30-entry custom list limit.
  if not K.AddSounds(table.concat(ids,',')) then return false,'invalidIds' end
 else
  K.StopPreview()
  for _,file in ipairs(g.files) do K.db.sounds[file[1]]=nil end
  if not K.ApplySounds() then return false,'soundMuteFailed' end
 end
 local state=M.State(id)
 if state=='soundMuteFailed' then return false,state end
 return true,enabled and 'sgMuted' or 'sgRestored'
end
local open,expanded=false,nil
local cursors={}
local feedback,feedbackName,feedbackError
local function Result(key,name,failed)
 feedback=key;feedbackName=name;feedbackError=failed
end
function K.DrawSoundGroups(page,w,y,refresh)
 local top=w.Button(page,K.L('sgTitle')..(open and '  ▴' or '  ▾'),0,y,714,36,function()
  open=not open;refresh()
 end)
 w.Tip(top,'sgTitle','sgHelp')
 y=y-54
 if not open then return y end
 w.Text(page,K.L('sgHelp'),8,y,698,13,{.65,.70,.62});y=y-100
 if feedback then
  local message=(feedbackName and (K.L(feedbackName)..': ') or '')..K.L(feedback)
  w.Text(page,message,8,y,698,13,feedbackError and {.95,.48,.38} or {.55,.90,.55})
 end
 y=y-82
 for _,group in ipairs(M.groups) do
  local g=group
  local state,count,total=M.State(g.id)
  local card=w.Box(page,0,y,714,214)
  w.Text(card,K.L(g.title),16,-14,680,16)
  w.Text(card,K.L(g.verified and 'sgVerified' or 'sgPending'),16,-42,680,12,g.verified and {.55,.90,.55} or {.83,.70,.42})
  w.Text(card,K.L(g.help),16,-65,680,13,{.65,.70,.62})
  w.Text(card,K.L(state)..' · '..count..'/'..total,16,-125,680,13,state=='sgEnabled' and {.55,.90,.55} or {.83,.70,.42})
  local listen=w.Button(card,K.L('listen'),16,-158,218,32,function()
   cursors[g.id]=(cursors[g.id] or 0)%#g.files+1
   local ok=K.PreviewSound(g.files[cursors[g.id]][1])
   Result(ok and 'sgListenHelp' or 'previewFail',g.title,not ok);refresh()
  end)
  w.Tip(listen,'listen','sgListenHelp')
  local toggle=w.Button(card,K.L(count==total and 'sgUnmute' or 'sgMute'),246,-158,218,32,function()
   local ok,key=M.Set(g.id,count~=total);Result(key,g.title,not ok);refresh()
  end)
  w.Button(card,K.L(expanded==g.id and 'sgHideFiles' or 'sgFiles'),476,-158,222,32,function()
   expanded=expanded~=g.id and g.id or nil;refresh()
  end)
  if not PlaySoundFile or not MuteSoundFile or not UnmuteSoundFile then listen:Disable() end
  if not MuteSoundFile or not UnmuteSoundFile then toggle:Disable() end
  y=y-230
  if expanded==g.id then
   local detail=w.Box(page,0,y,714,#g.files*42+16)
   for i,file in ipairs(g.files) do
    local entry=file
    w.Text(detail,tostring(entry[1])..' · '..entry[2],16,-14-(i-1)*42,550,12)
    local play=w.Button(detail,K.L('listen'),586,-8-(i-1)*42,112,30,function()
     local ok=K.PreviewSound(entry[1]);Result(ok and 'sgListenHelp' or 'previewFail',g.title,not ok);refresh()
    end)
    if not PlaySoundFile or not MuteSoundFile or not UnmuteSoundFile then play:Disable() end
   end
   y=y-(#g.files*42+32)
  end
 end
 return y-8
end
