-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local API={version=4};ForeverQuestJournalAPI=API
function API.GetSettings() return {scrollEnabled=false,groupByZone=true,scrollStep=48} end
function API.IsAttached() return false end
function API.IsSuspended() return true end
function API.Status() return 'qjNativeWaiting' end
function API.GetDiagnostics() return {layouts=0,repairs=0,scans=0} end
function API.Set() return false end
