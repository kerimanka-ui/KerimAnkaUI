local _,K=...
-- Public project links only. GitHub stays unset until the repository exists.
K.communityLinks={github=nil,twitch="https://www.twitch.tv/kerimanka"}
local popup,dismiss
function K.CloseCommunity()
 if popup then popup:Hide() end
 if dismiss then dismiss:Hide() end
end
function K.BuildCommunity(parent,Button,Backdrop,Tip,Selected)
 local buttons={}
 local function Label(owner,size,bold)
  local t=owner:CreateFontString(nil,"OVERLAY")
  K.ApplyTextFont(t,size,bold,"");t:SetTextColor(.90,.91,.88)
  t:SetJustifyH("LEFT");t:SetWordWrap(true)
  return t
 end
 dismiss=CreateFrame("Button",nil,parent)
 dismiss:SetAllPoints(parent);dismiss:SetFrameLevel(parent:GetFrameLevel()+34)
 dismiss:SetScript("OnClick",K.CloseCommunity);dismiss:Hide()
 popup=CreateFrame("Frame","KerimAnkaUICommunityPopup",parent,"BackdropTemplate")
 popup:SetSize(420,180);popup:SetFrameLevel(parent:GetFrameLevel()+36)
 popup:SetClampedToScreen(true);popup:EnableMouse(true)
 Backdrop(popup,.105,.115,.105,{.73,.62,.41})
 popup.title=Label(popup,15,true);popup.title:SetPoint("TOPLEFT",16,-14);popup.title:SetWidth(355);popup.title:SetTextColor(.79,.69,.49)
 popup.body=Label(popup,13,false);popup.body:SetPoint("TOPLEFT",16,-45);popup.body:SetWidth(388)
 popup.copy=Label(popup,12,false);popup.copy:SetPoint("BOTTOMLEFT",16,16);popup.copy:SetWidth(388)
 popup.copy:SetTextColor(.65,.70,.66)
 popup.edit=CreateFrame("EditBox",nil,popup,"InputBoxTemplate")
 popup.edit:SetPoint("TOPLEFT",22,-100);popup.edit:SetSize(376,28)
 popup.edit:SetAutoFocus(false);popup.edit:SetMaxLetters(2048)
 -- URLs always use the bundled Latin font, including while Chinese is selected.
 K.ApplyTextFont(popup.edit,13,false,"",false)
 popup.edit:SetScript("OnEscapePressed",K.CloseCommunity)
 popup.edit:SetScript("OnEnterPressed",K.CloseCommunity)
 popup.edit:SetScript("OnMouseUp",function(self) self:HighlightText() end)
 popup.edit:SetScript("OnTextChanged",function(self,userInput)
  if userInput then self:SetText(self.address or "");self:HighlightText() end
 end)
 popup.close=Button(popup,"×",382,-10,26,26,K.CloseCommunity)
 popup:SetScript("OnHide",function()
  popup.edit:ClearFocus();dismiss:Hide()
  for _,b in pairs(buttons) do Selected(b,false) end
 end)
 UISpecialFrames[#UISpecialFrames+1]="KerimAnkaUICommunityPopup"
 popup:Hide()
 local function Open(key)
  local owner=buttons[key]
  if popup:IsShown() and popup.key==key then K.CloseCommunity();return end
  K.HideTooltip()
  local address=K.communityLinks[key]
  local ready=type(address)=="string" and address:match("^https://")~=nil
  popup.key=key
  popup:ClearAllPoints();popup:SetPoint("BOTTOMLEFT",owner,"TOPLEFT",0,10)
  popup.title:SetText(K.L(key=="github" and "communityGithubTitle" or "communityTwitchTitle"))
  popup.body:SetText(K.L(ready and (key=="github" and "communityGithubHelp" or "communityTwitchHelp") or "communityPending"))
  popup.copy:SetText(K.L("communityCopy"));popup.copy:SetShown(ready)
  popup.edit.address=ready and address or "";popup.edit:SetText(popup.edit.address);popup.edit:SetShown(ready)
  for id,b in pairs(buttons) do Selected(b,id==key) end
  dismiss:Show();popup:Show()
  if ready then popup.edit:SetFocus();popup.edit:HighlightText() end
 end
 for i,key in ipairs({"github","twitch"}) do
  local id=key
  local b=Button(parent,id=="github" and "GitHub" or "Twitch",0,0,126,30,function() Open(id) end)
  b:ClearAllPoints();b:SetPoint("BOTTOMLEFT",20+(i-1)*138,12)
  b.label:ClearAllPoints();b.label:SetPoint("LEFT",37,0);b.label:SetWidth(80);b.label:SetJustifyH("LEFT")
  K.ApplyTextFont(b.label,13,false,"",false)
  local icon=b:CreateTexture(nil,"ARTWORK");icon:SetSize(20,20);icon:SetPoint("LEFT",10,0)
  icon:SetTexture("Interface\\AddOns\\KerimAnkaUI\\Media\\Community"..(id=="github" and "GitHub" or "Twitch")..".tga")
  icon:SetVertexColor(.90,.91,.88,1)
  Tip(b,id=="github" and "communityGithubTitle" or "communityTwitchTitle",id=="github" and "communityGithubHelp" or "communityTwitchHelp")
  buttons[id]=b
 end
 parent.community=buttons;K.communityPopup=popup
end
