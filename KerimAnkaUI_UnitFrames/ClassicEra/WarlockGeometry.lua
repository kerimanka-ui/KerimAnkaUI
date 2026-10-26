-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- Fel Obsidian: measured alpha apertures, without changing Hunter geometry.
ForeverWarlockUnitsGeometry = {
 aspect=724/2172, frameFile="WarlockFrame.tga", maskPrefix="Warlock",
 artUV={0,2172/4096,0,724/1024},
 layout={
  Portrait={0.090699815838,0.280386740331,0.166206261510,0.487569060773},
  Health={0.290055248619,0.508287292818,0.598066298343,0.116022099448},
  Power={0.290976058932,0.661602209945,0.583793738490,0.091160220994},

 },
 name={.585,.402}, level={196/2172,556/724},
 levelSize={32/360,32/120}, levelBadgeUV={102/4096,290/4096,462/1024,650/1024},
}
