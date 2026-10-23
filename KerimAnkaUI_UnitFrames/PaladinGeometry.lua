ForeverPaladinUnitsGeometry={
 aspect=724/2172,frameFile="PaladinUnitAlliance.tga",artUV={0,2172/4096,0,724/1024},
 name={.60,.335},nameHeight=.19,nameWidth=.55,
 level={.085,.80},levelSize={36/360,36/120},
 layout={
  Portrait={0.060313075506,0.178176795580,0.191528545120,0.569060773481},
  Health={0.302486187845,0.468232044199,0.660220994475,0.114640883978},
  Power={0.302486187845,0.636740331492,0.659300184162,0.111878453039},
 },
}
function ForeverPaladinUnitsGeometry.File()
 return KerimAnkaUITextAPI.PaladinSkin()==2 and "PaladinUnitHorde.tga" or "PaladinUnitAlliance.tga"
end
