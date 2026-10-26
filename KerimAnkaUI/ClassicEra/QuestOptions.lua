-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
local _,K=...
function K.DrawQuestPage(page)
 K.UnitWidgets.Text(page,'Classic Era alpha: the original quest tracker and Questie remain as configured. Custom quest scrolling is not available in this first test.',8,0,690,15,{.90,.73,.38})
 page:SetHeight(180);return true
end
