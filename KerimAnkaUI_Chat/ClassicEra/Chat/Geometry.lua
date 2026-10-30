if select(2,...).blocked then return end
-- Pure geometry: coordinates are in UIParent units. Native chat is not moved.
if WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,N=...;local K=N.host
local C={};K.Chat=C
function C.Geometry(x,y,w,h,screenWidth,microSize,quickHeight,side,typing)
 if not x or not y or not w or not h or w<=0 or h<=0 then return end
 local rightSide=side=='right'
 local left=math.max(2,x-(rightSide and 10 or 38))
 local right=math.min(screenWidth-2,x+w+(rightSide and 38 or 10))
 local footer=microSize and microSize+6 or 0
 -- The native default bottom is usually 65. Leave input and menu room below it.
 -- Reserve the entry row even when it is not focused. Enter never moves the footer.
 local inputSpace=29
 local bottom=math.max(2,y-inputSpace-footer)
 local inputBottom=bottom+footer
 -- Native dock tabs start three pixels above the message viewport.
 -- Six pixels put the new tab feet onto the body rail rather than across its face.
 local top=y+h+(quickHeight or 0)+6
 return {x=left,y=bottom,width=right-left,height=top-bottom,
  anchorX=x,anchorY=y,
  contentX=x-left,railX=rightSide and x+w-left+6 or x-left-6,contentTop=top-y-h,footer=footer,
  inputX=left+8,inputY=inputBottom,inputWidth=math.max(1,right-left-42),inputHeight=26,
  microX=left+10,microY=bottom+3,microWidth=right-left-20,microHeight=microSize}
end

-- Keep buttons readable; unusually narrow windows wrap instead of scaling icons down.
function C.MicroHeight(width)
 local count=0
 if MicroMenu then for _,b in ipairs({MicroMenu:GetChildren()})do
  if b.layoutIndex and b:IsObjectType('Button')and b:IsShown()then count=count+1 end
 end end
 local columns=math.max(1,math.floor((math.max(1,width)+4)/36))
 local rows=math.max(1,math.ceil(count/columns))
 return rows*32+(rows-1)*4
end
