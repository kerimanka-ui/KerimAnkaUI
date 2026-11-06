-- Own tab artwork mirrors native conversation state. It never selects/closes a tab.
if select(2,...).blocked then return end
local _,N=...;local K=N.host;local C=K.Chat
local function Secret(v)return issecretvalue and issecretvalue(v)end
local function Alert(tab)
 if ChatFrameUtil and ChatFrameUtil.IsTabAlerting then
  local ok,value=pcall(ChatFrameUtil.IsTabAlerting,tab)
  return ok and not Secret(value)and value==true
 end
 return false
end
local function Glyph(plate,tab)
 if not plate.conversationGlyph then
  local icon=plate:CreateTexture(nil,'OVERLAY');icon:SetSize(13,13);icon:SetPoint('LEFT',plate,'LEFT',7,0);plate.conversationGlyph=icon
 end
 local target=plate.conversationGlyph;local source=tab.conversationIcon
 local atlas=source and source.GetAtlas and source:GetAtlas()
 if not Secret(atlas)and type(atlas)=='string'and atlas~=''then target:SetAtlas(atlas)
 else
  local texture=source and source.GetTexture and source:GetTexture()
  if not Secret(texture)and(type(texture)=='number'or type(texture)=='string')then
   target:SetTexture(texture)
   if source.GetTexCoord then target:SetTexCoord(source:GetTexCoord())end
  else target:SetTexture('Interface\\AddOns\\KerimAnkaUI_Chat\\Chat\\Media\\SimpleSocial.tga')end
 end
 local color=plate.accent or {.7,.75,.7};target:SetVertexColor(color[1],color[2],color[3],1);target:Show()
end
function C.UpdateConversationIndicator(tab,selected)
 local record=C.records[tab];local plate=record and record.tabChrome
 if not plate then return end
 local frame=record.chatFrame
 if C.IsClosedConversation and C.IsClosedConversation(frame)then
  plate:Hide();if plate.unreadPulse then plate.unreadPulse:Stop()end
  return
 end
 local kind=frame and frame.chatType
 local private=not Secret(kind)and(kind=='WHISPER'or kind=='BN_WHISPER')
 if plate.label then
  local size=13;local native=tab.GetFontString and tab:GetFontString()
  if native and native.GetFont then local _,n=native:GetFont();if not Secret(n)and type(n)=='number'then size=n end end
  local apply=KerimAnkaUITextAPI and KerimAnkaUITextAPI.Font or K.ApplyTextFont
  if apply then apply(plate.label,size,false,'')end
 end
 if private then
  Glyph(plate,tab)
  if plate.label then
   plate.label:ClearAllPoints();plate.label:SetPoint('LEFT',plate,'LEFT',25,0);plate.label:SetPoint('RIGHT',plate,'RIGHT',-6,0);plate.label:SetJustifyH('LEFT')
  end
 else
  if plate.conversationGlyph then plate.conversationGlyph:Hide()end
  if plate.label then plate.label:SetJustifyH('CENTER')end
 end
 if not plate.unreadLine then
  local line=plate:CreateTexture(nil,'OVERLAY');line:SetPoint('BOTTOMLEFT',5,0);line:SetPoint('BOTTOMRIGHT',-5,0);line:SetHeight(3);plate.unreadLine=line
 end
 local unread=not selected and Alert(tab)
 plate.unreadLine:SetShown(unread)
 if unread then
  local color=plate.accent or {.75,.68,.45};plate.unreadLine:SetColorTexture(color[1],color[2],color[3],1)
  if not plate.unreadPulse then
   local anim=plate.unreadLine:CreateAnimationGroup();local alpha=anim:CreateAnimation('Alpha');alpha:SetFromAlpha(.35);alpha:SetToAlpha(1);alpha:SetDuration(.8);anim:SetLooping('BOUNCE');plate.unreadPulse=anim
  end
  if not plate.unreadPulse:IsPlaying()then plate.unreadPulse:Play()end
 elseif plate.unreadPulse then plate.unreadPulse:Stop()end
end
local UpdateTab=C.UpdateTab
function C.UpdateTab(tab,selected)
 UpdateTab(tab,selected)
 if C.Enabled()then C.UpdateConversationIndicator(tab,selected)end
end
local function Changed(frame)
 if not C.Enabled()or not frame or not frame.GetName then return end
 local tab=_G[frame:GetName()..'Tab'];if not tab then return end
 local record=C.records[tab];if record and record.tabChrome then
  local selected=GENERAL_CHAT_DOCK and frame==FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK)
  C.UpdateTab(tab,selected)
 end
end
for _,name in ipairs({'FCF_StartAlertFlash','FCF_StopAlertFlash','FCF_FlashTab','FCF_SetTemporaryWindowType'})do C.Hook(name,Changed)end
