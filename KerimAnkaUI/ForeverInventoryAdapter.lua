local _,K=...
local A={};K.ForeverInventoryAdapter=A
function A.LastBag()
 local n=tonumber(NUM_TOTAL_BAG_FRAMES)or tonumber(NUM_BAG_SLOTS)or 4
 return math.max(4,math.min(5,n))
end
function A.BagIDs()local t={};for id=0,A.LastBag()do t[#t+1]=id end;return t end
function A.BankIDs()
 if C_Bank and C_Bank.FetchPurchasedBankTabIDs and Enum and Enum.BankType then
  local ok,ids=pcall(C_Bank.FetchPurchasedBankTabIDs,Enum.BankType.Character)
  if ok and type(ids)=='table'and #ids>0 then
   local valid={};for _,id in ipairs(ids)do if not(issecretvalue and issecretvalue(id))and type(id)=='number'then valid[#valid+1]=id end end
   if #valid>0 then return valid end
  end
 end
 local ids={-1};for i=1,math.min(7,tonumber(NUM_BANKBAGSLOTS)or 6)do ids[#ids+1]=4+i end;return ids
end
function A.ContainerButtonReady()
 return C_Container and (ContainerFrameItemButtonMixin or ContainerFrameItemButton_OnLoad)and SetItemButtonTexture and SetItemButtonCount
end
function A.IsSecret(value)return issecretvalue and issecretvalue(value)or false end

function A.PlayerDisplayName()
 local name,surname=UnitName('player')
 if A.IsSecret(name)then return '' end
 if A.IsSecret(surname)then return name or '' end
 -- Forever's second UnitName value is the surname, not the server.
 if type(surname)=='string'and surname~=''then return (name or '')..' '..surname end
 return name or ''
end

function A.UpdateQuestMarker(button,bag,slot,hasItem)
 if not button.UpdateQuestItem then return end
 local q=hasItem and C_Container.GetContainerItemQuestInfo and C_Container.GetContainerItemQuestInfo(bag,slot)
 if type(q)=='table'and not A.IsSecret(q.isQuestItem)and not A.IsSecret(q.questID)and not A.IsSecret(q.isActive)then
  button:UpdateQuestItem(q.isQuestItem,q.questID,q.isActive)
 else
  button:UpdateQuestItem(false,nil,false)
 end
end

A.unsupportedEvents={}
function A.RegisterEvent(frame,event)
 if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(event)then A.unsupportedEvents[event]=true;return false end
 local ok=pcall(frame.RegisterEvent,frame,event)
 if not ok then A.unsupportedEvents[event]=true end
 return ok
end
