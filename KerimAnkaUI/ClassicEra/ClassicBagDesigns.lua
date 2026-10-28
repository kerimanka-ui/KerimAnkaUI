-- Classic-only resizable bag designs. Item operations stay in ClassicBags.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID~=WOW_PROJECT_CLASSIC then return end
local _,K=...
local D={};K.ClassicBagDesigns=D
local MEDIA='Interface\\AddOns\\KerimAnkaUI\\ClassicEra\\BagMedia\\'
local function Clamp(v,lo,hi,default)
 v=tonumber(v);if not v or v~=v then return default end
 return math.max(lo,math.min(hi,v))
end
function D.ID()
 return math.floor(Clamp(K.InventoryMenus.Get('bagDesign'),1,3,1))
end
-- Narrowest approved Classic screenshot: nine default 30px icons, 4px gaps.
D.MIN_WIDTH=330
function D.MinimumColumns(id,size,gap)
 size=Clamp(size,18,48,30);gap=Clamp(gap,0,16,4)
 local sidebar=0 -- Keep the same minimum item grid with or without shortcuts.
 return math.max(6,math.min(14,math.ceil((D.MIN_WIDTH-28-sidebar+gap)/(size+gap))))
end
-- Pure geometry, shared by rendering and regression tests. All y values are
-- positive distances from the top; item count includes the current search/filter.
function D.Layout(id,size,columns,count,gap,bagGap,hidden,keyring)
 id=math.floor(Clamp(id,1,3,1));size=Clamp(size,18,48,30)
 columns=math.floor(Clamp(columns,6,14,10));count=math.max(0,math.floor(Clamp(count,0,10000,0)))
 gap=Clamp(gap,0,16,4);bagGap=Clamp(bagGap,0,16,3)
 columns=math.max(columns,D.MinimumColumns(id,size,gap))
 local cell=size+gap;local rows=math.max(1,math.ceil(count/columns))
 local gridW=columns*size+(columns-1)*gap;local gridH=rows*size+(rows-1)*gap
 local n=keyring and 6 or 5;local icon=id==1 and 34 or id==2 and 32 or 30;local step=icon+bagGap
 local sidebar=id==2 and not hidden and 48 or 0
 local stripW=(n-1)*step+(keyring and 25 or icon)
 local shelfX=id==1 and 40 or 14
 local width=math.max(D.MIN_WIDTH,gridW+28+sidebar,id~=2 and not hidden and(stripW+shelfX+14)or 0)
 local searchY=id==1 and(hidden and 44 or 68)or 44
 local l={id=id,width=width,cell=cell,rows=rows,iconSize=icon,iconStep=step,sidebar=sidebar,
  itemX=14+sidebar,itemY=searchY+36,searchY=searchY,searchX=14+sidebar,searchWidth=width-112-sidebar,
  headerSize=24,headerY=3,titleX=0,titleWidth=0,icons={},controls={},hidden=hidden,keyring=keyring}
 for i=0,5 do
  if id==2 then l.icons[i]={x=i==5 and 19 or 15,y=44+i*step}
  else l.icons[i]={x=shelfX+i*step,y=id==1 and 30 or l.itemY+gridH+13}end
 end
 local contentH=gridH
 if id==2 and not hidden then contentH=math.max(gridH,44+n*icon+(n-1)*bagGap-l.itemY)end
 if id==3 and not hidden then contentH=gridH+42 end
 l.controls.minus={x=width-154,y=l.headerY};l.controls.plus={x=width-124,y=l.headerY};l.controls.shelf={x=width-94,y=l.headerY}
 l.columns=columns;l.contentH=contentH;l.wideFooter=width>=420;l.footerHeight=42;l.height=l.itemY+contentH+50
 l.recordWidth=l.wideFooter and 136 or 124
 l.footerX=14+l.recordWidth+8
 l.footerWidth=width-14-96-8-l.footerX
 return l
end


local chrome=setmetatable({},{__mode='k'})
local u=64/1024
local slices={
 {'TL','TOPLEFT',0,u,0,u},{'TR','TOPRIGHT',1-u,1,0,u},
 {'BL','BOTTOMLEFT',0,u,1-u,1},{'BR','BOTTOMRIGHT',1-u,1,1-u,1},
 {'Top','TOP',u,1-u,0,u},{'Bottom','BOTTOM',u,1-u,1-u,1},
 {'Left','LEFT',0,u,u,1-u},{'Right','RIGHT',1-u,1,u,1-u}}
local function NewColor(panel,layer)
 return panel:CreateTexture(nil,layer or 'BACKGROUND',nil,1)
end
function D.PaintFrame(panel,id,background,border)
 local c=chrome[panel]
 if not c then
  c={parts={}};chrome[panel]=c
  for _,p in ipairs(slices)do
   local t=panel:CreateTexture(nil,'BORDER',nil,2);c.parts[p[1]]=t
   t:SetTexCoord(p[3],p[4],p[5],p[6])
  end
  c.header=NewColor(panel);c.header:SetPoint('TOPLEFT',8,-8);c.header:SetPoint('TOPRIGHT',-8,-8);c.header:SetHeight(28)
  c.footer=NewColor(panel,'BORDER');c.footer:SetPoint('BOTTOMLEFT',12,46);c.footer:SetPoint('BOTTOMRIGHT',-12,46);c.footer:SetHeight(1)
  c.shelf=NewColor(panel);c.shelf:Hide()
 end
 local unified=panel.kaBagDesignWindow==true
 local headerHeight=30
 local edge=id==3 and 7 or id==2 and 5 or 4
 local texture=MEDIA..(id==3 and'LeatherFrame.tga'or'ClassicFrame.tga')
 for _,p in ipairs(slices)do
  local t=c.parts[p[1]]
  if c.id~=id then t:SetTexture(texture,'CLAMP','CLAMP','TRILINEAR');t:ClearAllPoints()
   if #p[1]==2 then t:SetSize(edge,edge);t:SetPoint(p[2])
   elseif p[1]=='Top'or p[1]=='Bottom'then
    t:SetHeight(edge);local a=p[1]=='Top'and'TOP'or'BOTTOM'
    t:SetPoint(a..'LEFT',edge,0);t:SetPoint(a..'RIGHT',-edge,0)
   else
    t:SetWidth(edge);local a=p[1]=='Left'and'LEFT'or'RIGHT'
    t:SetPoint('TOP'..a,0,-edge);t:SetPoint('BOTTOM'..a,0,edge)
   end
  end
  if t.SetDesaturated then t:SetDesaturated(id==2)end;t:SetVertexColor(id==2 and .5 or .8,id==2 and .55 or .8,id==2 and .6 or .8,1);if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false)end;if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0)end;t:SetShown(border and not(unified and(p[1]=='TL'or p[1]=='TR'or p[1]=='Top'or id==3 and(p[1]=='BL'or p[1]=='BR'or p[1]=='Bottom'))))
  if unified and(p[1]=='Left'or p[1]=='Right')then
   t:ClearAllPoints();local a=p[1]=='Left'and'LEFT'or'RIGHT'
   local inset=p[1]=='Right'and -2 or 0
   t:SetPoint('TOP'..a,inset,-(headerHeight-(p[1]=='Left'and 12 or 4)));t:SetPoint('BOTTOM'..a,inset,id==3 and 4 or edge)
  end
 end
 -- The header supplies the sole top edge. Suppress the native backdrop edge
 -- as well, otherwise a second rectangle remains behind the composed chrome.
 if unified then
  -- The native rectangular fill must start below the badge/header, otherwise
  -- its top-left corner remains visible outside the circular emblem.
  panel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',insets={left=2,right=3,top=headerHeight,bottom=id==3 and 4 or 2}})
  panel:SetBackdropColor(id==3 and .075 or id==2 and .025 or .035,id==3 and .065 or id==2 and .03 or .035,id==3 and .055 or id==2 and .035 or .03,background and .98 or 0)
  panel:SetBackdropBorderColor(0,0,0,0)
  c.parts.BR:ClearAllPoints();c.parts.BR:SetPoint('BOTTOMRIGHT',-2,0)
  c.parts.Bottom:ClearAllPoints();c.parts.Bottom:SetPoint('BOTTOMLEFT',edge,0);c.parts.Bottom:SetPoint('BOTTOMRIGHT',-edge-2,0)
 end
 c.id=id
 c.header:SetColorTexture(id==3 and .16 or .07,id==3 and .095 or .065,id==3 and .045 or .05,.8)
 c.header:SetShown(background)
 c.footer:SetColorTexture(id==2 and .24 or .48,id==2 and .27 or .36,id==2 and .3 or .16,.7);c.footer:Hide()
end
function D.PaintShelf(panel,l,background)
 local c=chrome[panel];if not c then return end
 c.footer:ClearAllPoints();local footerY=l.wideFooter and 42 or 56
 c.footer:SetPoint('BOTTOMLEFT',12,footerY);c.footer:SetPoint('BOTTOMRIGHT',-12,footerY)
 c.shelf:ClearAllPoints()
 if l.id==2 then
  c.shelf:SetPoint('TOPLEFT',8,-l.itemY+4);c.shelf:SetSize(48,l.contentH+8)
 else
  c.shelf:SetPoint('TOPLEFT',8,-l.icons[0].y+4);c.shelf:SetPoint('TOPRIGHT',-8,-l.icons[0].y+4);c.shelf:SetHeight(38)
 end
 c.shelf:SetColorTexture(l.id==3 and .13 or .06,l.id==3 and .075 or .06,l.id==3 and .035 or .055,.85)
 c.shelf:SetShown(background and not l.hidden)
end
local surfaceRects={{0.009019166,0.990980834,0.050732807,0.271702368,0.112514351},{0.009019166,0.990417136,0.277339346,0.492671928,0.109707065},{0.009582864,0.990417136,0.498308906,0.717023675,0.111494253},{0.009582864,0.990417136,0.723788050,0.944757610,0.112643678}}
local iconRects={{0.005042864,0.208774584,0.209331652,0.733921816,0.971153846},{0.208774584,0.400403429,0.234552333,0.713745271,1.000000000},{0.406454866,0.600100857,0.320302648,0.658259773,1.432835821},{0.612203732,0.789712557,0.254728878,0.733921816,0.926315789},{0.797781140,0.985375693,0.284993695,0.708701135,1.107142857}}
-- Textured, scalable interior controls. No nil texture setters: Classic rejects them.
local surfaces=setmetatable({},{__mode='k'})
-- Nine-slice the control atlas: source corner widths follow source height,
-- while the destination frame thickness stays stable even on square buttons.
-- Middle columns sample a small material patch: squeezing a whole 1000px atlas
-- row into a tiny button selects deep mip levels and bleeds adjacent bands.
function D.Surface(parent,key,band,x,y,width,height,layer)
 local cache=surfaces[parent];if not cache then cache={};surfaces[parent]=cache end
 local t=cache[key]
 if not t then
  t={};cache[key]=t
  for i=1,9 do t[i]=parent:CreateTexture(nil,layer or'BACKGROUND',nil,layer=='BORDER'and 3 or layer and -8 or 3)end
 end
 if t.band==band and t.x==x and t.y==y and t.width==width and t.height==height then for _,a in ipairs(t)do a:Show()end;return t end
 local r=surfaceRects[band]
 local sourceCorner=(r[4]-r[3])*.16
 local u={r[1],r[1]+sourceCorner*.5,r[2]-sourceCorner*.5,r[2]}
 local v={r[3],r[3]+sourceCorner,r[4]-sourceCorner,r[4]}
 local edge=math.min(4,height/3,width/3)
 local dx={0,edge,width-edge,width};local dy={0,edge,height-edge,height}
 for row=1,3 do for col=1,3 do
  local a=t[(row-1)*3+col]
  if t.band~=band then a:SetTexture(MEDIA..'ControlAtlas.tga','CLAMP','CLAMP','TRILINEAR');local ua,ub=u[col],u[col+1];if col==2 then local mid=(r[1]+r[2])*.5;local half=(r[4]-r[3])*.125;ua,ub=mid-half,mid+half end;a:SetTexCoord(ua,ub,v[row],v[row+1])end
  a:ClearAllPoints();a:SetPoint('TOPLEFT',x+dx[col],-y-dy[row]);a:SetSize(dx[col+1]-dx[col],dy[row+1]-dy[row])
  if a.SetSnapToPixelGrid then a:SetSnapToPixelGrid(false)end;if a.SetTexelSnappingBias then a:SetTexelSnappingBias(0)end;a:Show()
 end end
 t.band,t.x,t.y,t.width,t.height=band,x,y,width,height
 return t
end

local function HideSurface(parent,key)
 local t=surfaces[parent]and surfaces[parent][key];if t then for _,a in ipairs(t)do a:Hide()end end
end
function D.Glyph(texture,index)
 local r=iconRects[index];if texture.kaGlyphIndex==index then return r[5]or 1 end;texture.kaGlyphIndex=index;texture:SetTexture(MEDIA..'IconAtlas.tga','CLAMP','CLAMP','TRILINEAR');texture:SetTexCoord(r[1],r[2],r[3],r[4]);texture:SetVertexColor(.88,.88,.88,1);if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(false)end;if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0)end;return r[5]or 1
end
local function PaintSymbol(button)
 local role=button.kaRole
 if role~='plus'and role~='minus'and role~='close'and role~='clear'then return false end
 local parts=button.kaSymbol
 if not parts then
  parts={};button.kaSymbol=parts
  for i=1,2 do
   local t=button:CreateTexture(nil,'OVERLAY',nil,3);parts[i]=t;t:SetPoint('CENTER',0,0)
   if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false)end;if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0)end
  end
  if role=='plus'or role=='minus'then parts[1]:SetSize(8,2);parts[2]:SetSize(2,8)
  elseif parts[1].SetRotation and parts[2].SetRotation then
   parts[1]:SetSize(10,2);parts[2]:SetSize(2,10);parts[1]:SetRotation(math.pi/4);parts[2]:SetRotation(math.pi/4)
  else parts[1]:Hide();parts[2]:Hide();button.kaSymbolFallback=true end
 end
 if button.kaSymbolFallback then return false end
 local r,g,b=1,1,1
 if role=='close'then r,g,b=1,.8,.35 elseif role=='clear'then r,g,b=.8,.82,.84 end
 local alpha=button.IsEnabled and not button:IsEnabled()and .35 or 1
 for _,t in ipairs(parts)do t:SetColorTexture(r,g,b,alpha)end
 parts[1]:Show();parts[2]:SetShown(role~='minus')
 return true
end

function D.NewButton(name,parent,role)
 local b=CreateFrame('Button',name,parent,'BackdropTemplate');b.kaRole=role;b:EnableMouse(true);b:RegisterForClicks('LeftButtonUp')
 if b.SetPushedTextOffset then b:SetPushedTextOffset(0,0)end
 local text=b:CreateFontString(nil,'OVERLAY');text:SetPoint('CENTER');text:SetWordWrap(false);text:SetTextColor(1,1,1)
 b:SetFontString(text);b.kaLabel=text
 local size=(role=='close'or role=='minus'or role=='plus'or role=='clear')and 16 or 12
 if K.ApplyTextFont then K.ApplyTextFont(text,size,false,'')end
 if K.InventoryFont then K.InventoryFont(b,size)end
 return b
end
function D.PaintButton(button,id)
 -- Mark success only after all work completes; a failed paint must be retryable.
 for _,key in ipairs({'Left','Middle','Right'})do if button[key]then button[key]:Hide()end end
 local normal=button.GetNormalTexture and button:GetNormalTexture();if normal then normal:Hide()end
 if not button.kaDesignStateTextures then
  if button.SetPushedTexture then button:SetPushedTexture('Interface\\Buttons\\WHITE8X8');local t=button:GetPushedTexture();if t then t:SetVertexColor(1,1,1,.04)end end
  if button.SetHighlightTexture then button:SetHighlightTexture('Interface\\Buttons\\WHITE8X8','BLEND');local t=button:GetHighlightTexture();if t then t:SetVertexColor(1,1,1,.035)end end
  button.kaDesignStateTextures=true
 end
 local role=button.kaRole
 if button.kaCompactFace and id~=2 then
  button:SetBackdropColor(0,0,0,0);button:SetBackdropBorderColor(0,0,0,0);button.kaCompactFace=nil
 end
 if id==2 and role~='clear'and role~='records'then
  -- One native backdrop fills the actual button bounds, including the rim.
  -- Do not lay a narrower gray atlas centre over a differently coloured face.
  HideSurface(button,'Face')
  button:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1,insets={left=1,right=1,top=1,bottom=1}})
  button:SetBackdropColor(role=='close'and .22 or .055,role=='close'and .02 or .06,role=='close'and .015 or .065,1)
  button:SetBackdropBorderColor(.4,.39,.34,1);button.kaCompactFace=true
 elseif role=='clear' or(id==2 and role=='records')then HideSurface(button,'Face')
 else local face=role=='close'and 1 or(id==1 and(role=='settings'or role=='shelf'))and 2 or id
  local surfaces=D.Surface(button,'Face',face,0,0,button:GetWidth(),button:GetHeight())
  for _,t in ipairs(surfaces)do t:SetVertexColor(id==3 and .95 or 1,id==3 and .85 or 1,id==3 and .7 or 1,1)end
 end
 -- A chamfered face follows the inner bevel instead of covering it with a
 -- rectangular overlay. Five joined strips leave only the four corner cuts.
 local fittedFace=(id==1 and(role=='settings'or role=='shelf'))or(id==3 and(role=='settings'or role=='shelf'or role=='plus'or role=='minus'or role=='close'))
 if fittedFace then
  local face=button.kaFittedFace
  if not face then
   face={};button.kaFittedFace=face
   for i=1,5 do
    local t=button:CreateTexture(nil,'BACKGROUND',nil,4);face[i]=t
    if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false)end
    if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0)end
   end
  end
  local w,h=button:GetWidth(),button:GetHeight()
  local material=id==1 and 'gray'or role=='close'and 'red'or 'leather'
  if face.width~=w or face.height~=h or face.material~=material then
   local rows={{5,3,1},{4,4,1},{3,5,math.max(1,h-10)},{4,h-5,1},{5,h-4,1}}
   for i,row in ipairs(rows)do
    local t=face[i];t:ClearAllPoints();t:SetPoint('TOPLEFT',row[1],-row[2]);t:SetSize(math.max(1,w-row[1]*2),row[3])
    if material=='leather'then
     t:SetTexture(MEDIA..'ControlAtlas.tga','CLAMP','CLAMP','TRILINEAR')
     local start=(row[2]-3)/math.max(1,h-6);local finish=(row[2]+row[3]-3)/math.max(1,h-6)
     t:SetTexCoord(.48,.52,.56+.09*start,.56+.09*finish);t:SetVertexColor(.95,.85,.7,1)
    else
     if material=='gray'then t:SetColorTexture(.12,.13,.14,1)else t:SetColorTexture(.24,.025,.02,1)end
     t:SetVertexColor(1,1,1,1)
    end
   end
   face.width,face.height,face.material=w,h,material
  end
  for _,t in ipairs(face)do t:Show()end
 elseif button.kaFittedFace then for _,t in ipairs(button.kaFittedFace)do t:Hide()end end
 local glyph=role=='settings'and 2 or role=='shelf'and 3 or role=='records'and 5
 if glyph then
  if not button.icon then button.icon=button:CreateTexture(nil,'OVERLAY')end
  local aspect=D.Glyph(button.icon,glyph);button.icon:ClearAllPoints()
  local size=role=='records'and 17 or 16;button.icon:SetSize(size*math.min(1,aspect),size*math.min(1,1/aspect))
  if role=='records'then button.icon:SetPoint('LEFT',8,0)else button.icon:SetPoint('CENTER')end
 end
 if button.kaLabel then
  button.kaLabel:ClearAllPoints();button.kaLabel:SetPoint('CENTER',role=='records'and 10 or 0,0)
  button.kaLabel:SetWidth(math.max(1,button:GetWidth()-(role=='records'and 34 or 4)));button.kaLabel:SetHeight(button:GetHeight());button.kaLabel:SetJustifyH('CENTER')
  if button.kaLabel.SetJustifyV then button.kaLabel:SetJustifyV('MIDDLE')end
  if role=='close'then button:SetText('×');button.kaLabel:SetTextColor(1,.8,.35)
  elseif role=='clear'then button:SetText('×');button.kaLabel:SetTextColor(.8,.82,.84)end
 end
 if button.kaLabel then button.kaLabel:SetShown(not PaintSymbol(button))end
 button.kaBagButtonDesign=id
end
function D.SkinSearch(search,id,l)
 local parent=search:GetParent();l=l or{searchX=0,searchY=0}
 HideSurface(search,'Search')
 D.Surface(parent,'SearchField',4,l.searchX,l.searchY,search:GetWidth(),search:GetHeight())
 if search:GetFrameLevel()<=parent:GetFrameLevel()then search:SetFrameLevel(parent:GetFrameLevel()+2)end
 D.SearchFocus(search,search.HasFocus and search:HasFocus())
 if not search.kaSearchGlyph then
  search.kaSearchGlyph=search:CreateTexture(nil,'OVERLAY');search.kaSearchGlyph:SetPoint('LEFT',7,0);search.kaSearchGlyph:SetSize(15,15)
 end
 local aspect=D.Glyph(search.kaSearchGlyph,4);search.kaSearchGlyph:SetSize(15*math.min(1,aspect),15*math.min(1,1/aspect));if not search.kaInsetsSet then search.kaInsetsSet=true;search:SetTextInsets(27,27,0,0)end
end
function D.SkinItem(button,id,occupied)
 -- Never place opaque decoration on an occupied native item button.
 if occupied or button.kaClassicBankItem then HideSurface(button,'Slot');return end
 D.Surface(button,'Slot',4,0,0,button:GetWidth(),button:GetHeight(),'BACKGROUND')
end
function D.SkinShortcut(button)
 -- Native shortcut icons already contain their own visual edge. A second
 -- recessed face creates a pale double ring around equipped bags and keys.
 HideSurface(button,'BagSlot')
end
local interiors=setmetatable({},{__mode='k'})
function D.Interior(panel,l,background)
 local c=interiors[panel]
 if not c then
  c={};interiors[panel]=c
  c.body=panel:CreateTexture(nil,'BACKGROUND',nil,-7);c.body:SetPoint('TOPLEFT',7,-7);c.body:SetPoint('BOTTOMRIGHT',-7,7)
  c.footerBody=panel:CreateTexture(nil,'BACKGROUND',nil,-5)
  c.sidebarDivider=panel:CreateTexture(nil,'BORDER');c.sidebarDivider:SetWidth(1)
  c.sidebarBody=panel:CreateTexture(nil,'BACKGROUND',nil,-6)
  c.moneyDivider=panel:CreateTexture(nil,'BORDER');c.moneyDivider:SetPoint('BOTTOMRIGHT',-118,10);c.moneyDivider:SetSize(1,26)
  c.rackTopLine=panel:CreateTexture(nil,'BORDER',nil,4);c.rackTopLine:SetHeight(1)
  c.line=panel:CreateTexture(nil,'BORDER');c.line:SetPoint('TOPLEFT',10,-48);c.line:SetPoint('TOPRIGHT',-10,-48);c.line:SetHeight(1)
 end
 local r=surfaceRects[l.id==2 and 2 or 3]
 c.body:SetTexture(MEDIA..'ControlAtlas.tga','CLAMP','CLAMP','TRILINEAR')
 if l.id==3 then
  -- Use a near-square leather sample, avoiding the old flattened banner grain.
  local u,v=(r[1]+r[2])*.5,(r[3]+r[4])*.5
  c.body:SetTexCoord(u-40/1024,u+40/1024,v-40/512,v+40/512)
  c.body:SetVertexColor(.72,.66,.56,.96)
 else
  c.body:SetTexCoord(r[1]+.15*(r[2]-r[1]),r[2]-.15*(r[2]-r[1]),r[3]+.16*(r[4]-r[3]),r[3]+.37*(r[4]-r[3]))
  c.body:SetVertexColor(l.id==1 and .5 or .55,l.id==1 and .48 or .56,l.id==1 and .44 or .56,.9)
 end
 if c.body.SetDesaturated then c.body:SetDesaturated(l.id==3)end;c.body:SetShown(background)
 local old=chrome[panel];if old then old.header:Hide();old.shelf:Hide()end
 HideSurface(panel,'Title')
 local unified=panel.kaBagDesignWindow==true
 local headerHeight=30
 c.body:ClearAllPoints();c.body:SetPoint('TOPLEFT',7,unified and -headerHeight or -7);c.body:SetPoint('BOTTOMRIGHT',-7,7)
 local header=D.Surface(panel,'Header',l.id==3 and 3 or 2,unified and 0 or 8,unified and 0 or 6,unified and l.width-2 or l.width-16,unified and headerHeight or 36)
 for i,t in ipairs(header)do
  t:SetVertexColor(l.id==3 and .95 or .7,l.id==3 and .83 or .7,l.id==3 and .68 or .7,1);t:SetShown(background and not(unified and(i==1 or i==4 or i==7)))
 end
 if unified then
  -- The badge replaces the left header cap. Top/bottom rules emerge from its
  -- centre, while body sides start at the bottom rule with no parallel rail.
  header[2]:ClearAllPoints();header[2]:SetPoint('TOPLEFT',14,0);header[2]:SetWidth(l.width-20)
  header[8]:ClearAllPoints();header[8]:SetPoint('TOPLEFT',0,-headerHeight+4);header[8]:SetWidth(l.width-6)
  header[5]:ClearAllPoints();header[5]:SetPoint('TOPLEFT',14,-4);header[5]:SetWidth(l.width-20)
 end
 c.line:SetColorTexture(l.id==3 and .64 or l.id==2 and .32 or .48,l.id==3 and .47 or .36,l.id==3 and .24 or l.id==2 and .4 or .18,l.id==3 and 1 or .8)
 if c.line.SetDrawLayer then c.line:SetDrawLayer('BORDER',l.id==3 and 4 or 0)end
 local footerHeight=l.footerHeight
 c.line:ClearAllPoints();c.line:SetPoint('BOTTOMLEFT',l.id==3 and 0 or 4,footerHeight);c.line:SetPoint('BOTTOMRIGHT',l.id==3 and -2 or -6,footerHeight);c.line:SetShown(K.InventoryMenus.Get('bagFrame')~=false and(l.id~=3 or not l.hidden))
 c.footerBody:ClearAllPoints();c.footerBody:SetPoint('BOTTOMLEFT',4,4);c.footerBody:SetPoint('BOTTOMRIGHT',-6,4);c.footerBody:SetHeight(footerHeight-4);c.footerBody:SetColorTexture(.045,.04,.03,.88);c.footerBody:SetShown(background)
 c.moneyDivider:SetColorTexture(.3,.32,.34,.7);c.moneyDivider:Hide()
 D.Glyph(panel.kaBagBadge,1);panel.kaBagBadge:ClearAllPoints();panel.kaBagBadge:SetPoint('TOPLEFT',unified and -8 or 8,unified and 2 or -3);panel.kaBagBadge:SetSize(44,44);panel.kaBagBadge:Show()
 -- The bottom rack is part of the leather design, not a permanent empty shelf.
 if l.id==3 then
  c.footerBody:Hide()
  local footer=D.Surface(panel,'LeatherFooter',3,0,l.height-l.footerHeight,l.width-2,l.footerHeight,'BORDER')
  for _,t in ipairs(footer)do t:SetVertexColor(.78,.65,.48,1);t:SetShown(background)end
  if not l.hidden then
   local rackY=l.icons[0].y-7
   local rack=D.Surface(panel,'LeatherTray',3,0,rackY,l.width-2,l.height-l.footerHeight-rackY,'BORDER')
   for _,t in ipairs(rack)do t:SetVertexColor(.86,.74,.56,1);t:SetShown(background)end
   -- Open the touching caps: the rack and footer form one leather panel,
   -- separated only by the existing horizontal rule, with no recessed gap.
   for i=7,9 do rack[i]:Hide()end
   -- The rack's upper corners are square, continuing the straight side rails.
   for i=1,3 do rack[i]:Hide()end
   local rackX={rack.x,rack.x+4,rack.x+rack.width-4}
   for i=4,6 do
    rack[i]:ClearAllPoints();rack[i]:SetPoint('TOPLEFT',rackX[i-3],-rack.y);rack[i]:SetHeight(rack.height)
   end
   for i=1,3 do footer[i]:Hide()end
   local x={footer.x,footer.x+4,footer.x+footer.width-4}
   for i=4,6 do
    footer[i]:ClearAllPoints();footer[i]:SetPoint('TOPLEFT',x[i-3],-footer.y);footer[i]:SetHeight(footer.height-4)
   end
  else HideSurface(panel,'LeatherTray')end
 else HideSurface(panel,'LeatherFooter');HideSurface(panel,'LeatherTray')end
 local rackY=l.icons[0].y-7
 c.rackTopLine:ClearAllPoints();c.rackTopLine:SetPoint('TOPLEFT',0,-rackY);c.rackTopLine:SetPoint('TOPRIGHT',-2,-rackY)
 c.rackTopLine:SetColorTexture(.64,.47,.24,1);c.rackTopLine:SetShown(l.id==3 and not l.hidden and K.InventoryMenus.Get('bagFrame')~=false)
 local showSidebar=l.id==2 and not l.hidden
 c.sidebarDivider:ClearAllPoints();c.sidebarDivider:SetPoint('TOPLEFT',58,-headerHeight);c.sidebarDivider:SetPoint('BOTTOMLEFT',58,l.footerHeight)
 c.sidebarDivider:SetColorTexture(.32,.33,.31,.8);c.sidebarDivider:SetShown(showSidebar and K.InventoryMenus.Get('bagFrame')~=false)
 c.sidebarBody:ClearAllPoints();c.sidebarBody:SetPoint('TOPLEFT',4,-headerHeight);c.sidebarBody:SetPoint('BOTTOMLEFT',4,l.footerHeight);c.sidebarBody:SetWidth(54)
 c.sidebarBody:SetColorTexture(.025,.028,.03,.85);c.sidebarBody:SetShown(showSidebar and background)
 HideSurface(panel,'Tray')
 -- Bag shortcut frames already provide their own edges; no extra shelf plate.

end
function D.SearchFocus(search,focused)
 -- Focus is communicated by the native caret and placeholder, not an outer line.
 for _,t in ipairs(search.kaFocusEdges or{})do t:Hide()end
end

function D.CapacityFont(region)
 local code=KAClassic_KerimAnkaUIDB and KAClassic_KerimAnkaUIDB.language or'en'
 if region.kaCapacityLanguage==code then return end
 -- Match the existing readable inventory text; language-aware font fallback
 -- and font objects are owned by InventoryFont, not recreated per refresh.
 K.InventoryFont(region,12)
 region:SetTextColor(.9,.9,.86,1);region.kaCapacityLanguage=code
end
