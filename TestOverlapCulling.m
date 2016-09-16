%[ Structs, Locs, LocLinks ] = IO.Local.FetchLocalData('TestData\OverlapCulling');
%PPlot2(Structs,Locs,LocLinks,'Debug',1);

[ Structs, Locs, LocLinks ] = IO.Local.FetchLocalData('TestData\OverlapCullingVerticle');
PPlot2(Structs,Locs,LocLinks,1,100,'um','Debug',1);

%[ Structs, Locs, LocLinks ] = IO.Local.FetchLocalData('TestData\EndCaps');
%PPlot2(Structs,Locs,LocLinks,'Debug',1);
