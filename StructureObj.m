classdef StructureObj < handle
%LOCATIONOBJ - Manages 3D information for one structurse
    
    properties
        %Locations used to draw this object
        Structure = []
        
        Verts = [];
        Normals = []; 
        Faces = [];
        FaceNormals = []; 
        MapIDToIndex = [];
        
        %Name of the material used to render the object when creating .obj
        %collada file
        ColladaStructName = [];
        ColladaMaterialName = []; 
        UseCommonSphere = 0;  
        
        %Name of the material used to render the object when creating .obj
        %file 
        MaterialName = []; 
        
        %THe offset to use when writing faces to an obj file
        ObjVertexOffset = 0;
        
        Color = [.5 .5 .5];
        Alpha = 1
        
        Links = {};    %Links to valid locations, the second column is the offset of the vertex to create the faces to
        BadLinks = {}; %Links to invalid locations
        
        BadLocs = []; %Records whether a given location index is valid or not
        
        LinkGraph = []; 
        
        %This counts the number of links to each location
        %Locations with only one or fewer links get a sphere
        LocLinkCount = [];
        
        ModelTranslation = [0 0 0]; %The structure is translated to be centered on 0,0,0. This puts it in the proper position in the world.
        ModelScale = [1 1 1]; 
        
        WorldBoundingBox = zeros(2,3); %The bounding box in world coordinates
        ModelBoundingBox = zeros(2,3); %The bounding box in local coordinates
        
        ChildList = []; %StructureID of objects which are children of this structure
    end
    
    properties (SetAccess = protected )
        StructureID; 
        TypeID; 
        ParentID;
        Label;
        
        HasParent;
        NumLocs; 
        Locs;
        HasValidLocs;
    end
        
    properties (Constant = true)
        
        iID = 1;
        iParentID = 2; 
        iX = 3;
        iY = 4;
        iZ = 5;
        iRadius = 6;   
        
        %Indicies to the IDToIndex map
        iLocID = 1;
        iVertOffset = 2; 
        iVertCount = 3;
        
        numCirclePts = 6; 
        %Standard circle verticies around unit cirle
        CircleVerts = CirclePatch(StructureObj.numCirclePts, 1, [0 0 1]); 

        UnitHemisphere = SpherePatch(StructureObj.numCirclePts, 1, [0 0 1], true); 
        numHemisphereVerts = size(StructureObj.UnitHemisphere.Verts,1);
        
        UnitSphere = SpherePatch(StructureObj.numCirclePts, 1, [0 0 1]);
        numSphereVerts = size(StructureObj.UnitSphere.Verts,1);
        
        GlobalScalar = 1; %This is here to make the meshes more usable in programs like blender
        nmPerPixel = 1 * StructureObj.GlobalScalar;
        nmPerSection = 1 * StructureObj.GlobalScalar;
    end
    
    
    methods
        function obj = StructureObj( structure_data, color, alpha, MatName)
            obj.Structure = structure_data;
            obj.Color = color; 
            obj.Alpha = alpha;
            obj.MaterialName = MatName; 
            obj.ColladaStructName = ['Struct-' num2str(obj.StructureID)];
            obj.ColladaMaterialName = MatName; %[obj.ColladaStructName '-material']; 
            
            %Walk the array and create verticies for all Locs
            numLocs = obj.NumLocs;
            
            obj.Links = cell(numLocs, 1); 
            obj.BadLinks = cell(numLocs, 1);
            
            obj.BadLocs = false(numLocs,1); 
            
            %Count the number of links to each location
            obj.LocLinkCount = zeros(numLocs,1);
            
            %Create the connectivity graph
            obj.LinkGraph = sparse([],[],[],numLocs, numLocs, numLocs*4);
            
            %This is a map containing two columns.
            %Database ID  Vertex Offset
            %The index into the matrix corresponds to the index used for
            %other datastructures with location information in this object
            obj.MapIDToIndex = zeros(numLocs,3);
            
            for iLoc = 1:numLocs
               ID = obj.Locs.ID(iLoc);
               obj.MapIDToIndex(iLoc,1) = ID;
            end
        end
        
        function StructureID = get.StructureID(obj)
            StructureID = obj.Structure.ID;
        end
        
        function TypeID = get.TypeID(obj)
            TypeID = obj.Structure.TypeID;
        end
        
        function ParentID = get.ParentID(obj)
            ParentID = obj.Structure.ParentID;
        end
        
        function Label = get.Label(obj)
            Label = obj.Structure.Label;
        end
        
        function obj = set.Label(obj, value)
            obj.Structure.Label = value;
        end
        
        function hasParent = get.HasParent(obj)
           hasParent = ~isempty(obj.ParentID);
           return;
        end
        
        function numLocs = get.NumLocs(obj)
           numLocs = size(obj.Locs.ID,1);
           return;
        end
        
        function hasValid = get.HasValidLocs(obj)
            hasValid = obj.NumLocs ~= sum(obj.BadLocs);
            return 
        end
        
        function Locs = get.Locs(obj)
           Locs = obj.Structure.Locations;
           return;
        end
        
        function obj = set.Locs(obj, value)
           obj.Structure.Locations = value;
           return;
        end
                
        function obj = AddChildStructure(obj, ChildObj)
           obj.ChildList = [obj.ChildList ChildObj.StructureID];
        end
        
        function [X,Y,Z] = GetPosition(obj, iLoc)
           X = obj.Locs.X(iLoc) * obj.nmPerPixel;
           Y = obj.Locs.Y(iLoc) * obj.nmPerPixel;
           Z = obj.Locs.Z(iLoc) * obj.nmPerSection; 
        end
        
        function [X,Y,Z,Radius] = GetPositionAndRadius(obj, iLoc)
           [X,Y,Z] = obj.GetPosition(iLoc);
           Radius = obj.Locs.Radius(iLoc) * obj.nmPerPixel;
        end
        
        function DisplayPosition(obj, iLoc)
            disp(['X: ' num2str(obj.Locs.X(iLoc)) ' Y: ' num2str(obj.Locs.Y(iLoc)) ' Z: ' num2str(obj.Locs.Z(iLoc)) ' Radius: ' num2str(obj.Locs.Radius(iLoc))]);
        end
       
        %Create faces to render the link between location IDs A & B
        function obj = AddLink(obj, A, B, AValid, BValid)
            iA = find(obj.MapIDToIndex(:,obj.iID) == A); 
            iB = find(obj.MapIDToIndex(:,obj.iID) == B);
            
            if(isempty(iA) || isempty(iB))
                return; 
            end
            
            %Increment the link count for those objects
            if(BValid)
                obj.LocLinkCount(iA) = obj.LocLinkCount(iA) + 1; 
%                obj.Links{iA} = sort([obj.Links{iA} iB]);
                obj.Links{iA} = [obj.Links{iA}; iB 0];
            else
                obj.BadLocs(iB) = true;
%                obj.BadLinks{iA} = sort([obj.BadLinks{iA} iB]); 
                obj.BadLinks{iA} = [obj.BadLinks{iA} iB]; 
                
            end
            
            if(AValid)
                obj.LocLinkCount(iB) = obj.LocLinkCount(iB) + 1; 
%                obj.Links{iB} = sort([obj.Links{iB} iA]);
                obj.Links{iB} = [obj.Links{iB}; iA 0];
            else
                obj.BadLocs(iA) = true;
%                obj.BadLinks{iB} = sort([obj.BadLinks{iB} iA]); 
                obj.BadLinks{iB} = [obj.BadLinks{iB} iA]; 
            end
        end
        
        %This must be called after the last link is added so they can be
        %sorted.  It resizes the Links field so it holds the offset to the
        %vertex and the number of verticies for the link target
        function obj = EndAddLinks(obj)
            for i =1:length(obj.Links)
               if(~isempty(obj.Links{i}))
                   obj.Links{i} = sort(obj.Links{i},1);
               end
               
               if(~isempty(obj.BadLinks{i}))
                  obj.BadLinks{i} = sort(obj.BadLinks{i}); 
               end
               
               %Remove duplicates
               if(~isempty(obj.Links{i}))
                uniqueLinks = unique(obj.Links{i}(:,1));
                obj.Links{i} = cat(2,uniqueLinks,zeros(length(uniqueLinks),1));
               end
               %assert(length(unique(obj.Links{i}(:,1))) == length(obj.Links{i}(:,1)));
               
               obj.Links{i} = cat(2, obj.Links{i}, zeros(size(obj.Links{i},1),1));
            end
            
            %Figure out how far apart linked locations are on average.  If
            %a link has a length more than four std deviations from the
            %mean then print a message so users can check into it
            obj = obj.BuildConnectionMap();
        end
        
        function obj = CullVeryLongLinks(obj)
            
            numLocs = obj.NumLocs;
            [numLinks,~] = size(obj.Links);
            
            if(numLinks == 0)
                return;
            end
            
            DistanceMatrix = sparse([],[],[],numLocs, numLocs, numLocs*3);
            TotalLinks = 0;  
            
            for(iObj =1:numLinks)
                if(isempty(obj.Links{iObj}))
                    continue; 
                end
                
                objLinks = obj.Links{iObj}; 
                
                iObjA = iObj;
                iObjB = objLinks(:,1);
                iObjB = iObjB( iObjB < iObjA); %Remove objects with an ID number less than ours, prevents duplicate measurement.  Duplicates throw off std deviation.
                
                if isempty(iObjB)
                    continue;
                end
                
                [XA, YA, ZA] = obj.GetPosition(iObjA);
                [XB, YB, ZB] = obj.GetPosition(iObjB);
               
                [numObjLinks,~] = size(iObjB);
                DistanceMatrix(iObjA, iObjB) = pdist2([XA YA ZA], [XB YB ZB]);
%                 
%                 %TODO, this should not be in a for loop
%                 for(iLinkB = 1:numObjLinks)
%                     iObjB = objLinks(iLinkB,1);
%                     
%                     %Get the coordinates of the locations and calculate the
%                     %distance
%                     if(iObjB <= iObjA)
%                         continue;
%                     end
%                     
%                     DistanceMatrix(iObjA, iObjB) = pdist([XA YA ZA; 
%                                                           XB YB ZB]); 
%                 end
                
            end
            
            %%Determine median and standard deviation of link length
            Distances = full(DistanceMatrix(DistanceMatrix > 0));
            distStd = std(Distances);
            distMedian = median(Distances); 
            
            iOutliers = abs( Distances - distMedian) > (distStd*3.5);
            
            if(sum(iOutliers) > 0)
               disp('*** Found extreme distance between two linked locations ***');
               disp(['Std. Dev.: ' num2str(distStd)]);
               disp(['Median   : ' num2str(distMedian)]);
               %disp(Distances(iOutliers > 0));
            end
            
            %TODO: Remove the outliers
                        
                        
        end

        
        function obj = BuildConnectionMap(obj)
%            disp(['Building connection graph for ' num2str(obj.StructureID) ]);
            LabelNumber = 1;
            obj.LinkGraph = full(obj.LinkGraph);
            for(iLoc = 1:obj.NumLocs)
                %We won't have a connection to ourselves if we've never
                %been checked
                if(obj.LinkGraph(iLoc,iLoc) ~= 0)
                    continue;
                end
                
                connected = obj.AllConnections(iLoc);
                
                %Add these connections to the map for all the connected
                %locations
                for(iConnection = 1:length(connected))
                    iConnectedLoc = connected(iConnection);
                   obj.LinkGraph(iConnectedLoc, connected) = LabelNumber;
                   obj.LinkGraph(connected, iConnectedLoc) = LabelNumber; 
                end
                
                LabelNumber = LabelNumber+1;
            end
            
            obj.LinkGraph = sparse(obj.LinkGraph);
            
%            if(LabelNumber > 2)
%                disp(['Found ' num2str(LabelNumber-1) ' isolated graphs for structure ' num2str(obj.StructureID)]);
%            end
        end

        %Return a list of all locations connected to the source
        function connected = AllConnections(obj, iSource)
            qToCheck = obj.Links{iSource}(:,1); 
            qChecked = [iSource];
%            disp([num2str(iSource)]);
            
            while(~isempty(qToCheck))
                iTest = qToCheck(1);                
                qChecked = cat(1, qChecked, iTest);
                UncheckedLinks = setdiff(obj.Links{iTest}(:,1), qChecked);
                if ~isempty(UncheckedLinks)
                    qToCheck = cat(1, qToCheck, UncheckedLinks);  
                end
                qToCheck(1) = [];
            end
            
            connected = qChecked;
            
            return;
            
        end
        
        function connected = IsConnected(obj, iSource, iTarget)
            qToCheck = obj.Links{iSource}(:,1); 
            qChecked = [iSource];
%            disp([num2str(iSource) ' ' num2str(iTarget)]);
            
            while(~isempty(qToCheck))
                iTest = qToCheck(1); 
                if(iTest == iTarget)
                    connected = true;
                    return; 
                end
                
                
                qChecked = cat(1, qChecked, iTest);
                qToCheck = cat(1, qToCheck, setdiff(obj.Links{iTest}(:,1), qChecked));  
                qToCheck(1) = [];
            end
            
            connected = false;
            return;
        end
        
        function obj = ApplyZLimits(obj, MinZ, MaxZ)
            %Remove locations that are outside the Min/Max Z range
            
            for(iLoc = obj.NumLocs:-1:1) 
               
               [~, ~, Z] = obj.GetPosition(iLoc);
               
               if(~isnan(MinZ))
                   if(Z < MinZ)
                       obj.RemoveLocation(iLoc, false);
                       continue;
                   end
               end
               
               if(~isnan(MaxZ))
                   if(Z > MaxZ)
                       obj.RemoveLocation(iLoc, false);
                       continue;
                   end
               end
            end
        end
       
        function obj = CullOverlapping(obj, iObjs, iExclude)
            %Remove locations with two links (part of a process) who
            %overlap with adjacent locations.  Do not remove endpoints or
            %branch points. 
            for(i = 1:length(iObjs))
               iLoc = iObjs(i);
             
               if(isempty(obj.Links{iLoc}))
                   continue;
               end
             
               iLinked = obj.Links{iLoc}(:,1);
               if(isempty(iLinked))
                    continue; 
               end
               
               [X, Y, Z, Radius] = obj.GetPositionAndRadius(iLoc); 
               
               iIdenticalTest = intersect(iLinked, iExclude);
               iLinked = setdiff(iLinked, iExclude);

               %We only cull these if they are directly on top of the
               %location
               
               if(~isempty(iIdenticalTest))
                   for iLink = length(iIdenticalTest)
                       [AX,AY,AZ] = obj.GetPosition(iLink);

                       if(X == AX && Y == AY && Z == AZ)
                           %FindGoodLinks(obj, iLoc, iExcludeLocs, KnownGoodLinks, iSearched)
                           RemoveLocation(obj, iLink, true);
                           break;
                       end
                   end
               end
               
               %Do not bother checking locations we've already marked as bad, stop.
               if(obj.BadLocs(iLoc))
                   continue;
               end
                              
               LinkVerts = zeros(length(iLinked), 3);
               minLinkDistance = 10^100;
               
               for iLink = 1:length(iLinked)
                   iAdjacentLoc = iLinked(iLink);
                   [AX,AY,AZ, ARadius] = obj.GetPositionAndRadius(iAdjacentLoc);

                   LinkVerts(iLink,:) = [AX AY AZ]; 
                   %distance = pdist([X Y Z; AX AY AZ]);
                   SqDiff = [(X-AX)^2 (Y-AY)^2 (Z-AZ)^2];
                   sumSqDiff = sum(SqDiff);
                   Adistance = sqrt(sumSqDiff); 

                   if(Adistance < minLinkDistance)
                       minLinkDistance = Adistance; 
                   end

                   %Remove the link if the location is too close to the
                   %adjacent
                   if(Adistance < max(ARadius,Radius))
                       %Keep the larger of the two radii,
                       %TODO, linear interpolation of the radius...
                       %obj.Locs.Radius(iLoc) = mean([ARadius Radius]);
                       
                       numLinksOnAdjacent = length(obj.Links{iAdjacentLoc}(:,1));
                       if numLinksOnAdjacent == 2
                           obj.RemoveLocation(iAdjacentLoc, true);
                       elseif (numLinksOnAdjacent == 1 || numLinksOnAdjacent > 2)
                           %We shouldn't remove terminals or endpoints.  So
                           %remove ourselves
                           obj.RemoveLocation(iLoc, true);
                           break;  
                       end
                   end
               end
               
               if(length(iLinked) == 2 && obj.BadLocs(iLoc) == false)

                   LinkDistance = pdist(LinkVerts); 
                   
                   %Remove the location if the linked locations are closer
                   %together than this location is to the linked point, this is
                   %my primitive outlier detector
                   if(min(LinkDistance) < minLinkDistance)

                       RemoveLocation(obj, iLoc, true);
%                        
%                        for iLinkUpdate = 1:length(iLinked)
%                             %FindGoodLinks(obj, iLoc, iExcludeLocs, KnownGoodLinks, iSearched)
%                                 NewLinks = FindGoodLinks(obj, iLinked(iLinkUpdate), [iLinked(iLinkUpdate); iLoc], setdiff(iLinked, iLinked(iLinkUpdate)), []);
%                                 obj.Links{iLinked(iLinkUpdate)} = NewLinks;
%                                 obj.LocLinkCount(iLinked(iLinkUpdate)) = size(NewLinks,1);                     
%                        end
% 
%     %                   obj.Links{iLoc} = []; 
%                        obj.BadLocs(iLoc) = true; %Skip this location
                       continue;
                   end
               end
            end
        end
                
        %Remove locations within the radius of adjacent sections
        function obj = CullOverlappingLocations(obj)
            
%            disp(['Cull overlapping locations for ' num2str(obj.StructureID) ]);
            
            BadIndicies = find(obj.BadLocs == true); 
            
            obj = MendOverlappingTerminals(obj);
            
            PairedLocations = find(obj.LocLinkCount(:,1) == 2);
            PairedLocations = setdiff(PairedLocations, BadIndicies); 
            obj = CullOverlapping(obj, PairedLocations, []);
                        
            BadIndicies = find(obj.BadLocs == true); 
            DeadEndLocations = find(obj.LocLinkCount(:,1) == 1);
            DeadEndLocations = setdiff(DeadEndLocations, BadIndicies); 
            BranchLocations = find(obj.LocLinkCount(:,1) > 2);
            BranchLocations = setdiff(BranchLocations, BadIndicies); 
            %Leavnig this check in creates artifacts, for example cell
            %bodies become long thin rods instead of circles
            %obj = CullOverlapping(obj, DeadEndLocations, [DeadEndLocations;BranchLocations]);
        end
        
        function obj = MendOverlappingTerminals(obj)
            %Remove the zeros from consideration
            LinkedLocs = obj.LinkGraph > 0;
            
            StructureNamePrinted = false; 
            
            numLabels = length(unique(obj.LinkGraph(LinkedLocs)));
            
            for(Label = numLabels:-1:2)
                %Figure out which locations are the closest between
                %isolated graphs
                iLocsLogicalIndex = obj.LinkGraph == Label;
                [iLocRows, iLocCols] = find(obj.LinkGraph  == Label);
                iLocs = unique(iLocRows);
                
                if(obj.NumLocs == 1)
                   if(~StructureNamePrinted)
                      StructureNamePrinted =true;
                      disp(['Mend required for structure #' num2str(obj.StructureID)]);
                   end
                   disp(['    Ignoring orphan location #: ' num2str(obj.Locs.ID(iLocs))]); 
                end
                
                NotLinkedToMe = obj.LinkGraph ~= Label; 
               
                TestLocs = and(LinkedLocs, NotLinkedToMe);
                [TestLocs, Cols] = find(TestLocs > 0);
                TestLocs = unique(TestLocs); 
                
                %Figure out the two locations which are closest to each
                %other...
                Pos = [obj.Locs.X(iLocs) obj.Locs.Y(iLocs) obj.Locs.Z(iLocs)];
                
                TestPos = [obj.Locs.X(TestLocs) obj.Locs.Y(TestLocs) obj.Locs.Z(TestLocs)];
                
                %Only test the 25% of nearest locations
                %K = ceil(min([length(iLocs) length(TestLocs)]) / 4);
                K = 5; 
                
                %[iClosest, Distances] = knnsearch(Pos,TestPos, 'K', K);
                
                [D, I] = pdist2(Pos, TestPos, 'euclidean', 'Smallest', K );
                
                %D isn't sorted, sort it and find the smallest distances
                [SortedD, iSorted] = sort(D(1,:), 2);
                
                %Apply the same sorting to the indicies
                SortedD = D(:,iSorted); 
                SortedI =  I(:,iSorted);
                TestLocs = TestLocs(iSorted);
                
                %OK, starting with the nearest location, try to look for
                %overlap
                numTestPos = length(TestLocs);
                
                LinkFound = false; 
                for(iTest = 1:numTestPos)
                    iTestLoc = TestLocs(iTest); 
                    TestRadius = obj.Locs.Radius(iTestLoc) * obj.nmPerPixel;
                    
                    for(iIndexToLoc = 1:size(SortedI,1))
                        
                        iLoc = iLocs(SortedI(iIndexToLoc,iTest));
                        Radius = obj.Locs.Radius(iLoc) * obj.nmPerPixel;
                        
                        if(SortedD(iIndexToLoc, iTest) <= Radius + TestRadius)
                            obj.Links{iLoc} = [obj.Links{iLoc}; iTestLoc 0 0];
                            obj.Links{iTestLoc} = [obj.Links{iTestLoc}; iLoc 0 0];
                            obj.LocLinkCount(iLoc) = size(obj.Links{iLoc},1);                     
                            obj.LocLinkCount(iTestLoc) = size(obj.Links{iTestLoc},1);  
                
                            if(~StructureNamePrinted)
                              StructureNamePrinted =true;
                              disp(['Mend required for structure #' num2str(obj.StructureID)]);
                            end
                   
                            disp(['    Jumped gap: ' num2str(iLoc) ' (' num2str(obj.Locs.ID(iLoc)) ') -> ' num2str(iTestLoc) ' (' num2str(obj.Locs.ID(iTestLoc)) ')']);
                            disp(['        X: ' num2str(obj.Locs.UnscaledX(iLoc)) ...
                                         ' Y: ' num2str(obj.Locs.UnscaledY(iLoc)) ...
                                         ' Z: ' num2str(obj.Locs.UnscaledZ(iLoc)) ...
                                         ' DS: 4']);
                            newLabel = obj.LinkGraph(iTestLoc, iTestLoc); 
                            obj.LinkGraph(iLocsLogicalIndex) = newLabel;
                            
                            %Break the loop
                            LinkFound = true; 
                            break;
                        end
                    end
                    
                    if(LinkFound)
                        break;
                    end
                    
                end
                
                %Just use closest location in this case
                if(~LinkFound)
                    iTestLoc = TestLocs(1);
                    iLoc = iLocs(SortedI(1,1));
                    
                    obj.Links{iLoc} = [obj.Links{iLoc}; iTestLoc 0 0];
                    obj.Links{iTestLoc} = [obj.Links{iTestLoc}; iLoc 0 0];
                    obj.LocLinkCount(iLoc) = size(obj.Links{iLoc},1);                     
                    obj.LocLinkCount(iTestLoc) = size(obj.Links{iTestLoc},1); 
                    
                    if(~StructureNamePrinted)
                        StructureNamePrinted =true;
                        disp(['Mend required for structure #' num2str(obj.StructureID)]);
                    end
                            
                    disp(['    Jumped gap: ' num2str(iLoc) ' (' num2str(obj.Locs.ID(iLoc)) ') -> ' num2str(iTestLoc) ' (' num2str(obj.Locs.ID(iTestLoc)) ')']);
                            
                    newLabel = obj.LinkGraph(iTestLoc, iTestLoc); 
                    obj.LinkGraph(iLocsLogicalIndex) = newLabel;

                    %Break the loop
                    LinkFound = true; 
                end
                
            end
        end
            
        
%         function obj = MendOverlappingTerminals(obj)
%             BadIndicies = find(obj.BadLocs == true); 
%             DeadEndIndicies = find(obj.LocLinkCount(:,1) == 1);
%             DeadEndIndicies = setdiff(DeadEndIndicies, BadIndicies); 
%             
%             for(i = 1:length(DeadEndIndicies))
%                iLoc = DeadEndIndicies(i);
%                iLinked = obj.Links{iLoc};
%                
%                if(~isempty(iLinked))
%                   iLinked = iLinked(:,1);  
%                end
%                                            
%                X = obj.Locs(iLoc, obj.iX) * obj.nmPerPixel;
%                Y = obj.Locs(iLoc, obj.iY) * obj.nmPerPixel;
%                Z = obj.Locs(iLoc, obj.iZ) * obj.nmPerSection;
%                Radius = obj.Locs(iLoc, obj.iRadius) * obj.nmPerPixel;
%                
%                LinkVerts = zeros(length(iLinked), 3);
%                minLinkDistance = 10^100;
%                iBestLink = []; 
%                BestLinkRadius = 0; 
%                numLocs = size(obj.Locs,1);
%                myLabel = obj.LinkGraph(iLoc,iLoc); 
%                
%                LinkedLocs = obj.LinkGraph > 0;
%                NotLinkedToMe = obj.LinkGraph ~= myLabel; 
%                
%                TestLocs = and(LinkedLocs, NotLinkedToMe);
%                [TestLocs, Cols] = find(TestLocs > 0);
%                TestLocs = unique(TestLocs); 
%                
%                
%                for(iTestLoc = TestLocs')
%                    if(obj.BadLocs(iTestLoc))
%                        continue; 
%                    end
%                    
%                    if(iLinked == iTestLoc)
%                        continue;
%                    end
%                    
%                    if(iLoc == iTestLoc)
%                        continue;
%                    end
%                    
%                    AX = obj.Locs(iTestLoc, obj.iX) * obj.nmPerPixel;
%                    AY = obj.Locs(iTestLoc, obj.iY) * obj.nmPerPixel;
%                    AZ = obj.Locs(iTestLoc, obj.iZ) * obj.nmPerSection;
%                    ARadius = obj.Locs(iTestLoc, obj.iRadius) * obj.nmPerPixel;
% 
%                   % LinkVerts = [AX AY AZ]; 
%                    %distance = pdist([X Y Z; AX AY AZ]);
%                    SqDiff = [(X-AX)^2 (Y-AY)^2 (Z-AZ)^2];
%                    sumSqDiff = sum(SqDiff);
%                    Adistance = sqrt(sumSqDiff); 
% 
%                    if(Adistance < minLinkDistance)
%                        if(obj.LinkGraph(iTestLoc, iTestLoc) ~= myLabel)
%                         minLinkDistance = Adistance; 
%                         iBestLink = iTestLoc; 
%                         BestLinkRadius = ARadius; 
%                        end
%                    end
%                end
%                
%                if(minLinkDistance < BestLinkRadius + Radius)
%                    %Create a link if the location is too close to the
%                    %adjacent unlinked
%                    
%                    
%        %                disp(['Loc: ' num2str(iLoc)]);
%        %                disp(['Links: ' num2str(obj.Links{iLoc})]);
%                     obj.Links{iLoc} = [obj.Links{iLoc}; iBestLink 0 0];
%                     obj.Links{iBestLink} = [obj.Links{iBestLink}; iLoc 0 0];
%                     obj.LocLinkCount(iLoc) = size(obj.Links{iLoc},1);                     
%                     obj.LocLinkCount(iBestLink) = size(obj.Links{iBestLink},1);                     
% 
% %                            NewLinks = FindGoodLinks(obj, iLinked(iLinkUpdate), [iLinked(iLinkUpdate); iLoc], setdiff(iLinked, iLinkUpdate), []);
% %                           obj.Links{iLinked(iLinkUpdate)} = NewLinks;
% %                        obj.LocLinkCount(iLinked(iLinkUpdate)) = size(NewLinks,1);                     
%                         
%                     disp(['Jumped gap: ' num2str(iLoc) ' -> ' num2str(iBestLink)]);
%                    
%                end
% 
%                   
%             end
%         end


        function obj = CenterModel(obj)
            %Put the center of the model at 0,0
            %Calculate the bounding box using the valid locations
            
            if(~obj.HasValidLocs)
                return 
            end
            
            GoodLocs = ~obj.BadLocs;
            Centers = [obj.Locs.X(GoodLocs) obj.Locs.Y(GoodLocs), obj.Locs.Z(GoodLocs)];%(GoodLocs,[obj.iX obj.iY obj.iZ]);
            
            %Adjust the model so we are centered on 0,0,0. 
            if(length(Centers(:,1)) == 1)
                obj.ModelTranslation = Centers;
                
                %Objects with one location are spheres, lets use a standard
                %sphere model and scale it in COLLADA format
                Radius = obj.Locs.Radius(GoodLocs);
                obj.ModelScale = [Radius Radius Radius];
            else
                obj.ModelTranslation = median( Centers );
            end
            
            %NewLocs = obj.Locs;
              
            obj.Locs.X = obj.Locs.X - obj.ModelTranslation(1);
            obj.Locs.Y = obj.Locs.Y - obj.ModelTranslation(2);
            obj.Locs.Z = obj.Locs.Z - obj.ModelTranslation(3);
            
            %obj.Locs = NewLocs;
        end

        function obj = TranslateModel(obj, vector)
            obj.Verts(:,obj.iX) = obj.Verts(:,obj.iX) + vector(1);
            obj.Verts(:,obj.iY) = obj.Verts(:,obj.iY) + vector(2);
            obj.Verts(:,obj.iZ) = obj.Verts(:,obj.iZ) + vector(3);
        end
        
        function obj = ScaleModel(obj, scalar)
            %Calculate the bounding box using the valid locations
            
            obj.Verts = obj.Verts * scalar;
           % obj.Verts(:,obj.iY) = obj.Verts(:,obj.iY) * scalar;
            %obj.Verts(:,obj.iZ) = obj.Verts(:,obj.iZ) * scalar;
        end
        
        function [obj] = CalculateBoundingBox(obj)
            %Determine the bounding box of the model using the verticies
            obj.ModelBoundingBox = BoundingBox(obj.Verts);
            
            obj.WorldBoundingBox(1,:) = obj.ModelBoundingBox(1,:) + obj.ModelTranslation;
            obj.WorldBoundingBox(2,:) = obj.ModelBoundingBox(2,:) + obj.ModelTranslation;
        end
        
        %Create faces for the two IDs
        function Faces = CreateFaces(obj, iA, iB)
            
            if(isempty(iA) || isempty(iB))
                return; 
            end
%             
%             if(iB < iA)
%                temp = iB;
%                iB = iA;
%                iA = temp;
%             end
%             
            iAtoB = obj.Links{iA}(:,1) == iB;
            iBtoA = obj.Links{iB}(:,1) == iA;
            
            iVertStartB = obj.Links{iA}(iAtoB,2);
            iVertStartA = obj.Links{iB}(iBtoA,2);
            
            try
                assert(iVertStartB > 0);
                assert(iVertStartA > 0);
            catch
                disp(['CreateFaces error on ' num2str(obj.StructureID) ': ' num2str(iA) ' ' num2str(iB)]);
                dbstop if true;
            end
            
            %iVertStartA = obj.MapIDToIndex(iA,obj.iVertOffset);
            %iVertStartB = obj.MapIDToIndex(iB,obj.iVertOffset);
            
            iVertsA = iVertStartA:iVertStartA + obj.numCirclePts-1;
            iVertsB = iVertStartB:iVertStartB + obj.numCirclePts-1; 
            
            assert(length(iVertsA) == obj.numCirclePts);
            assert(length(iVertsB) == obj.numCirclePts);
%             iVertsA = ((iA-1)*obj.numCirclePts)+1:((iA-1)*obj.numCirclePts)+obj.numCirclePts;
%             iVertsB = ((iB-1)*obj.numCirclePts)+1:((iB-1)*obj.numCirclePts)+obj.numCirclePts;
%             
            AX = obj.Locs.X(iA) * obj.nmPerPixel;
            AY = obj.Locs.Y(iA) * obj.nmPerPixel;
            AZ = obj.Locs.Z(iA) * obj.nmPerSection;
            
            BX = obj.Locs.X(iB) * obj.nmPerPixel;
            BY = obj.Locs.Y(iB) * obj.nmPerPixel;
            BZ = obj.Locs.Z(iB) * obj.nmPerSection;
            
            A = [AX AY AZ];
            B = [BX BY BZ];
            
            assert(length(A) == 3);
            assert(length(B) == 3); 
            
            Faces = CylinderFacesOffset(obj.numCirclePts, iVertStartA-1, ...
                                                      iVertStartB-1, ...
                                                      A, B, ...
                                                      obj.Verts(iVertsA,:), ...
                                                      obj.Verts(iVertsB,:)); 
        end
        
        function Links = GetLocationLinks(obj, iLoc)
            if isempty(obj.Links{iLoc})
                Links = [];
            else
                Links = obj.Links{iLoc}(:,1);
            end
        end
        
        %Walk the graph from a bad node and locate all good links that
        %can be reached from it
        function FoundLinks = FindGoodLinks(obj, iLoc, iExcludeLocs, KnownGoodLinks, iSearched)
                        
            FoundLinks = [KnownGoodLinks; obj.Links{iLoc}(:,1)]; 
            
            %Remove links we don't want in the results
            FoundLinks = setdiff(FoundLinks, iExcludeLocs);
            
            RemoveBadLocs = ~obj.BadLocs(FoundLinks);
            FoundLinks = FoundLinks(RemoveBadLocs); 
            
            %Remove duplicates
            FoundLinks = unique(FoundLinks); 
            
            if(isempty(FoundLinks))
                return
            else
            
                %Add a column for vertex offsets
                FoundLinks = cat(2, FoundLinks, zeros(length(FoundLinks),2));
            end
        end
        
         function obj = RemoveLocation(obj, iLoc, PreserveLinks)
            %Removes a location from our structure.  Mark the location as
            %bad.  Update location links to skip the removed location
            %    PreserveLinks - Set to true if links should be relocated
            %    to remaining locations.  If false the links are removed.
            
            %iLinked = obj.Links{iLoc}(:,1);
            
            GoodLinks = GetLocationLinks(obj, iLoc);
                       
            %GoodLinks = obj.FindGoodLinks(iLoc, [iLoc], setdiff(iLinked, iLinked(iLink)), []);
            
            %obj.Links{iLinked(iLink)} = GoodLinks;
            %obj.LocLinkCount(iLinked(iLink)) = size(GoodLinks,1);          

            for(iLink = 1:length(GoodLinks))
                iLocToUpdate = GoodLinks(iLink);
                %FindGoodLinks(obj, iLoc, iExcludeLocs, KnownGoodLinks, iSearched)
                LocToUpdateLinks = GetLocationLinks(obj, iLocToUpdate);
                %Remove the location we are removing from the list
                UpdatedLinks = [];
                if(PreserveLinks)
                    UpdatedLinks = setdiff([LocToUpdateLinks;GoodLinks], [iLoc; iLocToUpdate]);
                else
                    UpdatedLinks = setdiff([LocToUpdateLinks], [iLoc]);
                end
                
                %Add the locations linked by the location we are removing
                %to the list
                UpdatedLinks = unique(UpdatedLinks);
                
                %Add columns for additional data
                if(~isempty(UpdatedLinks))
                    UpdatedLinks = cat(2, UpdatedLinks, zeros(length(UpdatedLinks),2));
                else
                    UpdatedLinks = [];
                end
                
                obj.Links{iLocToUpdate} = UpdatedLinks;
                obj.LocLinkCount(iLocToUpdate) = size(UpdatedLinks,1);                     
            end

            obj.BadLocs(iLoc) = true; %Skip this location
            obj.LocLinkCount(iLoc) = 0;
            obj.Links{iLoc} = [];
         end
             
        
        %Attempts to repair bad sections by combining adjacent nodes on
        %either side of the bad link
        function obj = JumpBadLinks(obj)
                      
           for(iLoc = 1:length(obj.Links))
%               disp(num2str(iLoc));
               if( false == obj.BadLocs(iLoc))
                   BadLinksLocal = obj.BadLinks{iLoc};
                   
                   %Add the known good links from each bad link, minus our
                   %own ID
                   for(iBadLink = 1:length(BadLinksLocal))
                       newLinks = obj.FindGoodLinks(BadLinksLocal(iBadLink), iLoc, [], []);
                       if(~isempty(newLinks) && ~isempty(obj.Links{iLoc}))
                        newLinkIDs = unique([newLinks(:,1); obj.Links{iLoc}(:,1)]);
                        obj.Links{iLoc} = cat(2,newLinkIDs,zeros(length(newLinkIDs))); 
                       elseif(~isempty(newLinks))
                           obj.Links{iLoc} = newLinks;
                       end
                   end
                   
                   obj.LocLinkCount(iLoc) = size(obj.Links{iLoc},1); 
               end
           end
        end
        
        %We update the other objects vertex index, we expect them to update
        %ours if they are created first
        function obj = SetVertexForLink(obj, iSource, iTarget, VertexOffset, numVerticies)
           LinksA = obj.Links{iTarget}; 
           
           iLinkA = LinksA(:,1) == iSource;
           LinksA(iLinkA,2) = VertexOffset; 
           LinksA(iLinkA,3) = numVerticies; 
           obj.Links{iTarget} = LinksA;
        end
        
        
        function obj = UpdateMesh(obj)
            
            if(~obj.HasParent)
                disp(['Build mesh for:  ' num2str(obj.StructureID)]);
            end
            
            %Cylinder indicies and branches, branches use the first two
            %links for rotation
            BadIndicies = find(obj.BadLocs == true); 
            
            BranchIndicies = find(obj.LocLinkCount(:,1) >= 3);
            BranchIndicies = setdiff(BranchIndicies, BadIndicies); 
            
            CylinderIndicies = find(obj.LocLinkCount(:,1) == 2);
            CylinderIndicies = setdiff(CylinderIndicies,BadIndicies); 
            
            %Draw dead ends as facing their only link and having a
            %hemisphere cap
            DeadEndIndicies = find(obj.LocLinkCount(:,1) == 1);
            DeadEndIndicies = setdiff(DeadEndIndicies,BadIndicies); 
            
            %Unlinked indicies simply get spheres
            UnlinkedIndicies = find(obj.LocLinkCount(:,1) == 0);
            UnlinkedIndicies = setdiff(UnlinkedIndicies,BadIndicies); 
            
            numHemisphereFaces = size(obj.UnitHemisphere.Faces,1);
            numSphereFaces = size(obj.UnitSphere.Faces,1);
            
            %Allocate memory to hold verticies and faces
            %numVerts = (length(CylinderIndicies) * obj.numCirclePts) + ...
            numVerts =  (length(DeadEndIndicies) * obj.numHemisphereVerts) + ...
                        (length(UnlinkedIndicies) * obj.numSphereVerts) + ...
                        (length(BranchIndicies) * obj.numSphereVerts);

            FaceCount = 0; 
            for(iLoc = 1:length(obj.Links))
               if(obj.BadLocs(iLoc))
                   continue; 
               end
               
               listLinks = obj.Links{iLoc};
               if(~isempty(listLinks))
                   listLinks = listLinks(:,1);
               end
               
               numLinks = size(listLinks,1); 
               if(numLinks <= 2)            
                   for(iLink = 1:length(listLinks))
                      if(listLinks(iLink) > iLoc)
                          if(size(obj.Links{listLinks(iLink)},1) <= 2)
                            FaceCount = FaceCount + (obj.numCirclePts * 2); %We don't run cylinders to branches
                          end

                      end
                   end
               end
               
               numLinks = length(listLinks);
            end
                    
%             FaceCount = FaceCount + ...
%                          (length(DeadEndIndicies) * numHemisphereFaces) + ... %Faces for locations with one link
%                          (length(UnlinkedIndicies) * numSphereFaces);
            
            FaceCount = (length(DeadEndIndicies) * numHemisphereFaces) + ... %Faces for locations with one link
                           (length(UnlinkedIndicies) * numSphereFaces);
                      
            FastFaceCount = (length(CylinderIndicies) * 2 * obj.numCirclePts) + ...; %Faces for locations with two links
                         (length(DeadEndIndicies) * (obj.numCirclePts + numHemisphereFaces)) + ... %Faces for locations with one link
                         (length(UnlinkedIndicies) * numSphereFaces );
                     
%            assert(FaceCount == FastFaceCount); 

            
            %Preallocate memory since this was really slow with cat
            numTriInFace = obj.numCirclePts * 2;
            obj.Faces = zeros(FaceCount, 3);
            
            iFace = 1; 
            
            %Create arrays to hold verticies
            obj.Verts = zeros(numVerts, 3);
            obj.Normals = zeros(numVerts, 3);
            
            %Figure out if the structure is a single sphere... used for
            %sharing verticies in Collada files
            obj.UseCommonSphere = length(UnlinkedIndicies) == 1 && ...
                                  length(DeadEndIndicies) == 0 && ...
                                  length(CylinderIndicies) == 0; 
            if(obj.UseCommonSphere)
               %disp(['    Is a sphere: ' num2str(obj.StructureID)]);
               iLoc = UnlinkedIndicies(1); 
               scale = obj.Locs.Radius(iLoc) * obj.nmPerPixel; 
               obj.ModelScale = [scale scale scale]; 
            end
            
            %Index into vertex arrayColors
            iVert  = 1; 
            
            %Put in the caps first so cylinders have something to attach to
            for(i = 1:length(DeadEndIndicies))
               iLoc = DeadEndIndicies(i);
               
               iVerts = iVert:iVert + obj.numHemisphereVerts-1;
%               iVerts = iVert:iVert + obj.numCirclePts-1;
               obj.MapIDToIndex(iLoc, obj.iVertOffset) = iVert;
               obj.MapIDToIndex(iLoc, obj.iVertCount) = obj.numCirclePts;
               
               iLinked = obj.Links{iLoc}(:,1); 
               iVertexOffsets = obj.Links{iLoc}(:,2); 
               
               %Send numCirclePts because the hemisphere pts should never
               %need to be refaced
               obj = obj.SetVertexForLink(iLoc, iLinked(1), iVert, obj.numCirclePts); 
               
               X = obj.Locs.X(iLoc) * obj.nmPerPixel;
               Y = obj.Locs.Y(iLoc) * obj.nmPerPixel; 
               Z = obj.Locs.Z(iLoc) * obj.nmPerSection;
               Radius = obj.Locs.Radius(iLoc) * obj.nmPerPixel;
               
               AX = obj.Locs.X(iLinked(1)) * obj.nmPerPixel;
               AY = obj.Locs.Y(iLinked(1)) * obj.nmPerPixel; 
               AZ = obj.Locs.Z(iLinked(1)) * obj.nmPerSection;
               
               P = [X Y Z];
               A = [AX AY AZ];  
               
               %If we are connecting two dead end verticied don't flip the
               %second
               Axis = A-P;
               
               %If the points are identical this is a problem in the
               %database... Not sure how to deal with this.
               if(max(Axis) == 0 && min(Axis) == 0)
               end
               
               FlipZ = false;
               if(iLinked(1) > iLoc)% && length(intersect(iLinked(1), DeadEndIndicies )) > 0)
                Axis = P-A;
                FlipZ = true; 
               end
               
               sphereStruct = SpherePatch(obj.numCirclePts, Radius, Axis, true,FlipZ); 
               sphereStruct.Verts(:,1) = sphereStruct.Verts(:,1)  + X; 
               sphereStruct.Verts(:,2) = sphereStruct.Verts(:,2)  + Y; 
               sphereStruct.Verts(:,3) = sphereStruct.Verts(:,3) + Z; 
               
               obj.Verts(iVerts,:) = sphereStruct.Verts;
               obj.Normals(iVerts,:) = sphereStruct.Normals; 
               
               sphereStruct.Faces = sphereStruct.Faces + (iVert-1);
               iFaces = iFace:iFace+numHemisphereFaces-1;
               obj.Faces(iFaces,:) = sphereStruct.Faces; 
               iFace = iFace + numHemisphereFaces;
               
               %If we have something to attach to then create faces
%               for(iLink = 1:length(iLinked))
%                   if(iVertexOffsets(iLink) > 0)
%                     NewFaces = obj.CreateFaces(iLoc, iLinked(iLink));  
% 
%                     assert(min(min(obj.Faces(iFace:iFace+numTriInFace-1,:) == 0)) == 1);
%                     obj.Faces(iFace:iFace+numTriInFace-1,:) = NewFaces; 
%                     iFace = iFace + numTriInFace; 
%                   end
%               end
                   
               iVert = iVert + obj.numHemisphereVerts; 
            end
            
            %Figure out the rotation for the circles
            for(i = 1:length(CylinderIndicies))
                iLoc = CylinderIndicies(i); 
                
%                iVerts = iVert:iVert+obj.numSphereVerts-1;
%                
%                obj.MapIDToIndex(iLoc, obj.iVertOffset) = iVert; %Record the indicies the verticies start for this location
%                obj.MapIDToIndex(iLoc, obj.iVertCount) = obj.numSphereVerts; %Record the indicies the verticies start for this location
%                
%                iLinked = obj.Links{iLoc}(:,1);
% %               iVertexOffsets = obj.Links{iLoc}(:,2);
%                
%                obj = obj.SetVertexForLink(iLoc, iLinked(1), iVert, obj.numSphereVerts); 
%                obj = obj.SetVertexForLink(iLoc, iLinked(2), iVert, obj.numSphereVerts); 
%                
%                
%                X = obj.Locs(iLoc, obj.iX) * obj.nmPerPixel;
%                Y = obj.Locs(iLoc, obj.iY) * obj.nmPerPixel;
%                Z = obj.Locs(iLoc, obj.iZ) * obj.nmPerSection;
%                Radius = obj.Locs(iLoc, obj.iRadius) * obj.nmPerPixel;
%                
%                sphereStruct = SpherePatch(obj.numCirclePts, Radius, [0 0 1], false); 
%                sphereStruct.Verts(:,1) = sphereStruct.Verts(:,1)  + X; 
%                sphereStruct.Verts(:,2) = sphereStruct.Verts(:,2)  + Y; 
%                sphereStruct.Verts(:,3) = sphereStruct.Verts(:,3)  + Z; 
%                obj.Verts(iVerts,:) = sphereStruct.Verts;
%                obj.Normals(iVerts,:) = sphereStruct.Normals; 
%                F
%                iVert = iVert + obj.numSphereVerts; 
               
                    iVerts = iVert:iVert+obj.numCirclePts-1;
               obj.MapIDToIndex(iLoc, obj.iVertOffset) = iVert; %Record the indicies the verticies start for this location
               obj.MapIDToIndex(iLoc, obj.iVertCount) = obj.numCirclePts; %Record the indicies the verticies start for this location
               
            
               iLinked = obj.Links{iLoc}(:,1);
               iVertexOffsets = obj.Links{iLoc}(:,2);
               
               obj = obj.SetVertexForLink(iLoc, iLinked(1), iVert, obj.numCirclePts); 
               obj = obj.SetVertexForLink(iLoc, iLinked(2), iVert, obj.numCirclePts); 
%               iVerts = ((iLoc-1)*obj.numCirclePts)+1:((iLoc-1)*obj.numCirclePts)+obj.numCirclePts;
              
               X = obj.Locs.X(iLoc) * obj.nmPerPixel;
               Y = obj.Locs.Y(iLoc) * obj.nmPerPixel;
               Z = obj.Locs.Z(iLoc) * obj.nmPerSection;
               Radius = obj.Locs.Radius(iLoc) * obj.nmPerPixel;
               
               AX = obj.Locs.X(iLinked(1)) * obj.nmPerPixel;
               AY = obj.Locs.Y(iLinked(1)) * obj.nmPerPixel;
               AZ = obj.Locs.Z(iLinked(1)) * obj.nmPerSection;
               
               BX = obj.Locs.X(iLinked(2)) * obj.nmPerPixel;
               BY = obj.Locs.Y(iLinked(2)) * obj.nmPerPixel; 
               BZ = obj.Locs.Z(iLinked(2)) * obj.nmPerSection;
               
               P = [X Y Z];
               A = [AX AY AZ]; 
               B = [BX BY BZ];
               
               [angle, axis] = AngleAndAxis(A-P,B-P);
               
               if(angle <= pi)
                    angle = pi - angle;
              
               end

               RotMat = [];
               if(mod(angle,pi) < .0001 && mod(angle, pi) > -.0001)
                    RotMat = eye(3); 
               else
                    RotMat = RotationMatrix(angle/2, axis); 
               end
               
               [locVerts, locNormals] = CirclePatch(obj.numCirclePts, Radius, A-P);
               
               %Rotate the verticies
               locVerts = locVerts * RotMat; 
               locNormals = locNormals * RotMat; 
               
               %Translate the position of the two arrays
               locVerts = TranslateVerts(locVerts, [X Y Z]);  
               
               obj.Verts(iVerts, :) = locVerts; 
               obj.Normals(iVerts,:) = locNormals; 
               
               %If we have something to attach to then create faces
%               for(iLink = 1:length(iLinked))
%                   
%                  if(iVertexOffsets(iLink) > 0)
%                     NewFaces = obj.CreateFaces(iLoc, iLinked(iLink));  
% 
%                     assert(min(min(obj.Faces(iFace:iFace+numTriInFace-1,:) == 0)) == 1);
%                     obj.Faces(iFace:iFace+numTriInFace-1,:) = NewFaces; 
%                     iFace = iFace + numTriInFace; 
%                  end
%               end
               
               iVert = iVert + obj.numCirclePts;
            end

            %Draw the first two links as a cylinder.  Add another circle
            %perpendicular to the third link for the branch.
            for(i = 1:length(BranchIndicies))
               iLoc = BranchIndicies(i); 
               iVerts = iVert:iVert+obj.numSphereVerts-1;
               obj.MapIDToIndex(iLoc, obj.iVertOffset) = iVert; %Record the indicies the verticies start for this location
               obj.MapIDToIndex(iLoc, obj.iVertCount) = obj.numSphereVerts; %Record the indicies the verticies start for this location
               
               iLinked = obj.Links{iLoc}(:,1);
%               iVertexOffsets = obj.Links{iLoc}(:,2);
               
               for(iLink = 1:size(iLinked,1))
                obj = obj.SetVertexForLink(iLoc, iLinked(iLink), iVert, obj.numSphereVerts); 
               end
               
               [X, Y, Z] = obj.GetPosition(iLoc);
               Radius = obj.Locs.Radius(iLoc) * obj.nmPerPixel;
               
               sphereStruct = SpherePatch(obj.numCirclePts, Radius, [0 0 1], false); 
               sphereStruct.Verts(:,1) = sphereStruct.Verts(:,1)  + X; 
               sphereStruct.Verts(:,2) = sphereStruct.Verts(:,2)  + Y; 
               sphereStruct.Verts(:,3) = sphereStruct.Verts(:,3)  + Z; 
               obj.Verts(iVerts,:) = sphereStruct.Verts;
               obj.Normals(iVerts,:) = sphereStruct.Normals; 
               
               iVert = iVert + obj.numSphereVerts; 
               
%                AX = obj.Locs(iLinked(1), obj.iX) * obj.nmPerPixel;
%                AY = obj.Locs(iLinked(1), obj.iY) * obj.nmPerPixel;
%                AZ = obj.Locs(iLinked(1), obj.iZ) * obj.nmPerSection;
%                
%                BX = obj.Locs(iLinked(2), obj.iX) * obj.nmPerPixel;
%                BY = obj.Locs(iLinked(2), obj.iY) * obj.nmPerPixel; 
%                BZ = obj.Locs(iLinked(2), obj.iZ) * obj.nmPerSection;
%                
%                P = [X Y Z];
%                A = [AX AY AZ]; 
%                B = [BX BY BZ];
%                
%                [angle, axis] = AngleAndAxis(A-P,B-P);
%                
%                if(angle < pi)
%                     angle = pi - angle;
%                end
% 
%                RotMat = [];
%                if(mod(angle,pi) < .0001 && mod(angle, pi) > -.0001)
%                     RotMat = eye(3); 
%                else
%                     RotMat = RotationMatrix(angle/2, axis); 
%                end
%                
%                [locVerts, locNormals] = CirclePatch(obj.numCirclePts, Radius, A-P);
%                
%                %Rotate the verticies
%                locVerts = locVerts * RotMat; 
%                locNormals = locNormals * RotMat; 
%                
%                %Translate the position of the two arrays
%                locVerts = TranslateVerts(locVerts, [X Y Z]);  
%                
%                obj.Verts(iVerts, :) = locVerts; 
%                obj.Normals(iVerts,:) = locNormals; 
%                
%                %Create faces for first two cylinders
% %               for(iLink = 1:2)
%                    
% %                  if(iVertexOffsets(iLink) > 0)
% %                     NewFaces = obj.CreateFaces(iLoc, iLinked(iLink));  
% % 
% %                     assert(min(min(obj.Faces(iFace:iFace+numTriInFace-1,:) == 0)) == 1);
% %                     obj.Faces(iFace:iFace+numTriInFace-1,:) = NewFaces; 
% %                     iFace = iFace + numTriInFace; 
% %                  end
% %               end
%                
%                iVert = iVert + obj.numCirclePts;
%                
%                %OK, create the perpendicular circles
%                for(iLink = 3:length(iLinked))
%                    %Set the map to the next unused set of verticies
%                    %This is asking for trouble... maybe I should just
%                    %create dummy locations and links instead???
% %                   obj.MapIDToIndex(iLoc, obj.iVertOffset) = iVert; %Record the indicies the verticies start for this location
%                    iVerts = iVert:iVert + obj.numHemisphereVerts-1;
%                     
%                    obj = obj.SetVertexForLink(iLoc, iLinked(iLink), iVert); 
%                
%                    AX = obj.Locs(iLinked(iLink), obj.iX) * obj.nmPerPixel;
%                    AY = obj.Locs(iLinked(iLink), obj.iY) * obj.nmPerPixel; 
%                    AZ = obj.Locs(iLinked(iLink), obj.iZ) * obj.nmPerSection;
%                
%                    P = [X Y Z];
%                    A = [AX AY AZ]; 
% 
%                    %If we are connecting two dead end verticied don't flip the
%                    %second
%                    Axis = A-P;
%                    FlipZ = false; 
%                    if(iLinked(iLink) > iLoc)% && length(intersect(iLinked(1), DeadEndIndicies )) > 0)
%                     Axis = P-A;
%                     FlipZ = true; 
%                    end
% 
%                    sphereStruct = SpherePatch(obj.numCirclePts, Radius, Axis, true,FlipZ); 
%                    sphereStruct.Verts(:,1) = sphereStruct.Verts(:,1)  + X; 
%                    sphereStruct.Verts(:,2) = sphereStruct.Verts(:,2)  + Y; 
%                    sphereStruct.Verts(:,3) = sphereStruct.Verts(:,3) + Z; 
% 
%                    obj.Verts(iVerts,:) = sphereStruct.Verts;
%                    obj.Normals(iVerts,:) = sphereStruct.Normals; 
% 
%                    sphereStruct.Faces = sphereStruct.Faces + (iVert-1);
%                    iFaces = iFace:iFace+numHemisphereFaces-1;
%                    obj.Faces(iFaces,:) = sphereStruct.Faces; 
%                    iFace = iFace + numHemisphereFaces;
% 
%                    %If we have something to attach to then create faces
%                    %Branch to branch can this blow up?
% %                   if(iVertexOffsets(iLink) > 0)
% %                         NewFaces = obj.CreateFaces(iLoc, iLinked(iLink));  
% % 
% %                         assert(min(min(obj.Faces(iFace:iFace+numTriInFace-1,:) == 0)) == 1);
% %                         obj.Faces(iFace:iFace+numTriInFace-1,:) = NewFaces; 
% %                         iFace = iFace + numTriInFace; 
% %                   end
%                    
%                    iVert = iVert + obj.numHemisphereVerts; 
%                end
            end
                        
            if(length(UnlinkedIndicies) > 0)
%                disp(['Unlinked locations: ' num2str(length(UnlinkedIndicies))]);
                
                for(i = 1:length(UnlinkedIndicies))
                    iLoc = UnlinkedIndicies(i);
                    X = obj.Locs.X(iLoc) * obj.nmPerPixel;
                    Y = obj.Locs.Y(iLoc) * obj.nmPerPixel; 
                    Z = obj.Locs.Z(iLoc) * obj.nmPerSection;
                    Radius = obj.Locs.Radius(iLoc) * obj.nmPerPixel;

                    iVerts = iVert:iVert + obj.numSphereVerts-1;
                    obj.MapIDToIndex(iLoc, obj.iVertOffset) = iVert;
                    obj.MapIDToIndex(iLoc, obj.iVertCount) =  obj.numSphereVerts;
                     
                    sphereStruct = SpherePatch(obj.numCirclePts, Radius, [0 0 1], false); 
                    sphereStruct.Verts(:,1) = sphereStruct.Verts(:,1)  + X; 
                    sphereStruct.Verts(:,2) = sphereStruct.Verts(:,2)  + Y; 
                    sphereStruct.Verts(:,3) = sphereStruct.Verts(:,3)  + Z; 
                    obj.Verts(iVerts,:) = sphereStruct.Verts;
                    obj.Normals(iVerts,:) = sphereStruct.Normals; 
                    sphereStruct.Faces = sphereStruct.Faces + (iVert-1);

                   iFaces = iFace:iFace+numSphereFaces-1;
                   obj.Faces(iFaces,:) = sphereStruct.Faces; 
                   
                   iFace = iFace + numSphereFaces;
                   iVert = iVert + obj.numSphereVerts; 
                end
            end
            
            %Count faces required
%           FaceCount = 0; 
            
%             for(iLoc = 1:length(obj.Links))
%                if(obj.BadLocs(iLoc))
%                    continue; 
%                end
%                
%                FaceCount = length(obj.Links{iLoc}); 
%             end
            

            
            %Create faces for all cylinders
            for(iLoc = 1:length(obj.Links))
                
               if(obj.BadLocs(iLoc))
                   continue; 
               end
               
               BranchFaces = [];                
               listLinks =  obj.Links{iLoc};
               numLinks = size(listLinks,1);
               interiorVerts = []; 
               for(iLink = 1:size(listLinks,1))
                  if(listLinks(iLink,1) > iLoc)
                      %Branches are special, don't draw cylinders to
                      %them
%                       if( size(obj.Links{listLinks(iLink)},1) <= 2 && ...
%                           size(listLinks,1) <= 2)
%                           NewFaces = obj.CreateFaces(iLoc, listLinks(iLink,1));  
% 
%                           assert(min(min(obj.Faces(iFace:iFace+numTriInFace-1,:) == 0)) == 1);
%                           obj.Faces(iFace:iFace+numTriInFace-1,:) = NewFaces; 
%                           iFace = iFace + numTriInFace; 
%                       else
                       %Use delaunay to build faces
                       [NewFaces, iNewInteriorVerts] = obj.CreateBranchFaces(iLoc,listLinks(iLink,:));
                       interiorVerts = union(interiorVerts, iNewInteriorVerts);
                       BranchFaces = cat(1, BranchFaces,NewFaces); 
%                       end
                  end
               end
               
               if(~isempty(BranchFaces))
                   UniqueBranchFaces = UniqueFaces(BranchFaces);

                   %Save some time by removing faces we know are entirely
                   %interior
                   iInteriorFaces = sum(ismember(UniqueBranchFaces, interiorVerts),2);
                   iPureInteriorFaces = sum(ismember(UniqueBranchFaces, interiorVerts),2) >= 3;
                   UniqueBranchFaces(iPureInteriorFaces,:) = [];

                   iStartVert = obj.MapIDToIndex(iLoc,obj.iVertOffset);
                   LocVertCount = obj.MapIDToIndex(iLoc, obj.iVertCount); 
                   iLocVerts = iStartVert:iStartVert+LocVertCount-1; 

                   NewVerts = obj.Verts; 
                   NewFaces = UniqueBranchFaces; 
                 %  [NewVerts, NewFaces, iVertsNotToPrune] = StitchFaces(obj.Verts, UniqueBranchFaces, interiorVerts);
                    

                   %trep = TriRep(NewFaces, NewVerts);

                   %[FF, xf] = freeBoundary(trep);

                   %Remove Faces which are part of interior verticies
%REMOVE                   iInteriorFaces = logical(sum(ismember(NewFaces, iVertsNotToPrune),2));
%REMOVE                   NewFaces(iInteriorFaces,:) = [];
    %                
                   obj.Verts = NewVerts;
                   obj.Faces = cat(1, NewFaces, obj.Faces);
                   %obj.Faces = cat(1, xf, obj.Faces);
               end
               
            end
            
            if(iFace-1 ~= FaceCount)
                disp(['Face count mismatch: ' num2str(iFace) ' ' num2str(FaceCount)]);
            end
        end
        
        function [Faces, interiorVerts] = CreateBranchFaces(obj, iLoc,listLinks)
             %listLinks =  obj.Links{iLoc};
             numLinks = size(listLinks,1);
%             disp(num2str(iLoc));
             
             %if (numLinks ~= 1)
             %   disp(num2str(numLinks)); 
             %end
             
             iStartVert = obj.MapIDToIndex(iLoc,obj.iVertOffset);
             LocVertCount = obj.MapIDToIndex(iLoc, obj.iVertCount); 
             iLocVerts = iStartVert:iStartVert+LocVertCount-1; 
             
             %We only use this for cylinders
             CapMap = zeros(LocVertCount,1);
             CapNumber = 1; 
             CapMap(1:obj.numCirclePts) = CapNumber; 
             CapNumber = CapNumber +1;
             
             BlobVerts = obj.Verts(iLocVerts,:);
             VertMap = iLocVerts'; %Map BlobVert index to obj.Vert index
             for(iLink = 1:numLinks)
                Offset = listLinks(iLink,2);
                NumVerts = listLinks(iLink,3); 
                iVerts = Offset:Offset+NumVerts-1;
                BlobVerts = [BlobVerts; obj.Verts(iVerts,:)];
                VertMap = [VertMap; iVerts'];
                iCapIndex = length(CapMap)+1;
                CapMap = [CapMap; zeros(NumVerts,1)];
                CapMap(iCapIndex:iCapIndex+obj.numCirclePts) = CapNumber;
                CapNumber = CapNumber+1;
             end
             
             DT = DelaunayTri(BlobVerts);
             k = convexHull(DT);
             
             interiorVerts = setdiff(1:size(BlobVerts,1), unique(k));
             
             Epsilon = 0.000001;
             
%              %It appears if a point is on a triangle for the convex hull it
%              %is not included.
             Normals = cross(BlobVerts(k(:,2),:) - BlobVerts(k(:,1),:), BlobVerts(k(:,3),:) - BlobVerts(k(:,1),:));
             dNorm = dot(-Normals, BlobVerts(k(:,1),:),2);
             
             numNormals = size(Normals, 1);
             ValidatedInteriorVerts = interiorVerts;
             for(iVert = interiorVerts)
                verts = repmat(BlobVerts(iVert, :), numNormals, 1);
                distances = abs(dot(Normals, verts,2) + dNorm);
                if(sum(distances <= Epsilon) > 0)
                   disp([num2str(VertMap(iVert)) ' is not an interior vertex']);
                   ValidatedInteriorVerts = setdiff(ValidatedInteriorVerts, iVert);
                end
             end
%             distance = dot(Normals, BlobVerts + dNorm);
%              Distances = 
%              
%              NTwo = cross(TriTwo(2,:) - TriTwo(1,:), TriTwo(3,:) - TriTwo(1,:));
%              dTwo = dot(-NTwo, TriTwo(1,:));
%              
             
             
             %If we only have two links remove the faces on the ends of
             %the cylinder
             if(numLinks == 1 || numLinks == 2)
                 T = [CapMap(k(:,1)) CapMap(k(:,2)) CapMap(k(:,3))];
                 
                 %Identify cap faces
                 numFaces = size(T,1);
                 iFace = 1;
                 while(iFace <= numFaces)
                    if(max(T(iFace,:)) == min(T(iFace,:)))
                        if(T(iFace,:) ~= 0)
                            T(iFace,:) = []; 
                            k(iFace,:) = []; 
                            iFace = iFace -1;
                            numFaces = numFaces -1;
                        end
                    end
                    
                    iFace = iFace +1 ;
                 end
             end
             
             %Map the indicies back to the original offsets
             Faces = [VertMap(k(:,2)) VertMap(k(:,1)) VertMap(k(:,3))];
             
             interiorVerts = [VertMap(ValidatedInteriorVerts)];
             %Faces = [VertMap(k(:,1)) VertMap(k(:,2)) VertMap(k(:,3))];
        end
        
        
        function obj = CleanMesh(obj)
            
            obj.Faces = UniqueFaces(obj.Faces);
            [obj.Verts, obj.Faces] = RemoveUnusedVerts(obj.Verts, obj.Faces); 
            
            return; 
            
            Debug = true; 
            
            if(Debug)
                    cla;

                    set(gcf, 'Renderer', 'opengl');
                    set(gca, 'DataAspectRatio', [1 1 1]);
                    set(gca, 'Color', [0.5 0.5 0.5]);

                    patch('Faces', obj.Faces, ...
                         'Vertices', obj.Verts, ...
                         'FaceVertexCData', [1 0 0], ...
                         ...%'VertexNormals', obj.Normals, ...
                         'FaceAlpha', obj.Alpha, ...
                         'FaceColor', [.75 .4 .1], ...
                         'EdgeColor', [0 0 1], ...
                         'FaceLighting', 'phong',...
                         'AmbientStrength', .2, ...
                         'DiffuseStrength', .8,...
                         'SpecularStrength', .02, ...
                         'SpecularExponent', 15,...
                         'BackFaceLighting', 'lit');

                     for(iVert = 1:size(obj.Verts,1))
                         text(obj.Verts(iVert,1)+0.001,obj.Verts(iVert,2)+0.001,obj.Verts(iVert,3)+0.001, ...
                                 num2str(iVert), ...
                                 'Color', [1 1 0], ...
                                 'FontSize', 10);
                     end

                    drawnow;


            end
                
            
            while(1)
                 %Cut off jagged edges
                 if(isempty(obj.Faces))
                    break; 
                 end
                
                 NewFaces = []; 
                
                 trep = TriRep(obj.Faces, obj.Verts);
                %k = convexHull(trep); 

                 Epsilon = 0.0001;

    %           obj.Faces = k; 
                 [FF, xf] = freeBoundary(trep);

                 
                 if(isempty(FF))
                     break;
                 end
                 
                 [Distance, iDist] = pdist2( obj.Verts, xf, 'euclidean', 'Smallest', 1);

                 if(Debug)
                     hold on;
                     for(iFace = 1:length(FF))
                        iLine = FF(iFace,:); 
                        line([xf(iLine(1),1) xf(iLine(2),1)], [xf(iLine(1),2) xf(iLine(2),2)], [xf(iLine(1),3) xf(iLine(2),3)], ...
                            'LineWidth', 3, ...
                            'Color', [1 0 0]);
                     end
                     
                     drawnow; 
                 end
%                  trisurf(FF, xf(:,1),xf(:,2),xf(:,3), ...
%                      'FaceColor','cyan', 'FaceAlpha', 0.8);
         
                 %Remap FF coords
                 Remap = iDist(Distance == 0);

                 FFRemap = Remap(FF);
                 numFreeEdges = size(FFRemap,1); 
                 
                 %Fetch the verticies
                 iFacesWithFreeFaceVertex = ismember(obj.Faces, FFRemap);
                 iFreeFaceTrianglesSum = sum(iFacesWithFreeFaceVertex,2);                 
                 iFreeFaceTriangles = find(iFreeFaceTrianglesSum >= 1);
                 iFreeFaceTrianglesToRemove = []; 
                 
                 for(iTri = iFreeFaceTriangles')
                    Face = obj.Faces(iTri,:);
% 
                    for(iSecond = 1:numFreeEdges)
                        iMatchingVerts = ismember(Face,FFRemap(iSecond,:));
                        if(sum(iMatchingVerts) >= 2)
                            iFreeFaceTrianglesToRemove = [iFreeFaceTrianglesToRemove iTri];
                            break; 
                        end
                    end
                     
                 end
                 
             %    iFreeFaceTrianglesToRemove = iFreeFaceTrianglesSum >= 2; 
                 
                 FreeFaceTriangles = obj.Faces(sum(iFreeFaceTriangles,2) > 0, :);
                 
                 for(iFreeFace = 1:numFreeEdges)
                    
                     %Find other triangles which use these verticies
                     V1 = FFRemap(iFreeFace,1);
                     V2 = FFRemap(iFreeFace,2);
                     
                     iV1Tri = ismember(FreeFaceTriangles, V1);
                     iV2Tri = ismember(FreeFaceTriangles, V2);
                     
                     %Find nodes which exist in both V1 and V2
                     V1Tri = FreeFaceTriangles(find(sum(iV1Tri,2)),:);
                     V2Tri = FreeFaceTriangles(find(sum(iV2Tri,2)),:);
                     
                     V1Edges = unique(V1Tri);
                     V2Edges = unique(V2Tri);
                     
                     %Remove direct links to the other vertex
                     V1Edges(V1Edges == V2) = [];
                     V2Edges(V2Edges == V1) = []; 
                     
                     %OK, see if any of these are shared
                     SharedVerts = intersect(V1Edges, V2Edges);
                     
                     %Find if these shared verts are on the midline
                     P1 = obj.Verts(V1,:);
                     P2 = obj.Verts(V2,:); 
                     L = P2 - P1;
                     LNorm = L ./ norm(L);
                     DistL = pdist2(P1,P2);
                     
                     for(i = 1:length(SharedVerts))
                     
                         iVert = SharedVerts(i); 
                         
                         T1 = obj.Verts(iVert,:);
                         DistT = pdist2(P1, T1);
                         %Check if the distance is too high for the point
                         %to be on the line segment
                         if(DistT > DistL)
                             continue; 
                         end
                         
                         L2 = T1 - P1;
                         L2Norm = L2 ./ norm(L2); 
                         
                         DistQ = dot(L2, LNorm);
                         
                         if(abs(DistT - DistQ) > Epsilon) 
                            continue;
                         end
                         
                         %OK, the point is on the line.  Fix the FreeEdge
                         iOldFace = sum(ismember(FreeFaceTriangles, [V1 V2]),2) >= 2;
                      
                         OldFace = FreeFaceTriangles(iOldFace,:);
                         
                         if(isempty(OldFace))
                             break;
                         end
                         
                         OddVertex = setdiff(OldFace, [V1 V2], 'rows');
                         if(OddVertex == iVert)
                             break; 
                         end
                         
                         NewFaces = [NewFaces; 
                                     iVert V1 OddVertex;
                                     V2 iVert OddVertex;];
                         break;
                         
                         
                     end
        
                     %Remove triangles directly connected to V2
%                      iV2inV1 = ismember(V1Tri, V2);
%                      iV1inV2 = ismember(V2Tri, V1);
%                      
%                      V1Tri(logical(sum(iV2inV1,2))) = [];
%                      V2Tri(logical(sum(iV1inV2,2))) = [];
                 end
                 
%                  %Find if the potential free triangles have two edges which are
%                  %free
%                  intersectCount = zeros(length(iFaces),1);
%                  for(i = 1:length(intersectCount))
%                     Face = obj.Faces(iFaces(i),:);
% 
%                     for(iSecond = 1:numFreeEdges)
%                         iMatchingVerts = ismember(Face,FFRemap(iSecond,:));
%                         if(sum(iMatchingVerts) >= 2)
%                             
%                             intersectCount(i) = intersectCount(i) + 1; 
%                         end
%                     end
%                  end
% 
%                  iRemoveFaces = intersectCount > 0; 
                  
%                   if(sum(iRemoveFaces) == 0)
%                       break; 
%                   end
 
                  obj.Faces(iFreeFaceTrianglesToRemove,:) = []; 
                  
                  obj.Faces = [obj.Faces; NewFaces];
%                  
                 if(Debug)
%                    cla;

                    set(gcf, 'Renderer', 'opengl');
                    set(gca, 'DataAspectRatio', [1 1 1]);
                    set(gca, 'Color', [0.5 0.5 0.5]);

                    patch('Faces', obj.Faces, ...
                         'Vertices', [obj.Verts(:,1) + obj.ModelTranslation(1) obj.Verts(:,2) + obj.ModelTranslation(2) obj.Verts(:,3) + obj.ModelTranslation(3)] , ...
                         'FaceVertexCData', [1 0 0], ...
                         ...%'VertexNormals', obj.Normals, ...
                         'FaceAlpha', obj.Alpha, ... 
                         'FaceColor', [.75 .4 .1], ...
                         'EdgeColor', [0 0 1], ...
                         'FaceLighting', 'phong',...
                         'AmbientStrength', .2, ...
                         'DiffuseStrength', .8,...
                         'SpecularStrength', .02, ...
                         'SpecularExponent', 15,...
                         'BackFaceLighting', 'unlit');

                     for(iVert = 1:size(obj.Verts,1))
                         text(obj.Verts(iVert,1)+0.001,obj.Verts(iVert,2)+0.001,obj.Verts(iVert,3)+0.001, ...
                                 num2str(iVert), ...
                                 'Color', [1 1 0], ...
                                 'FontSize', 10);
                     end

                    drawnow;


                end
            end
               
            [obj.Verts, obj.Faces] = RemoveUnusedVerts(obj.Verts, obj.Faces); 
                        
        end
        
        
         function obj = UpdateNormals(obj)
            %We get spheres correct, so don't do this if we don't have links
            if(obj.NumLocs == 1)
                return;
            end
            
             newNormals = zeros(size(obj.Verts));
             obj.FaceNormals = zeros(size(obj.Faces)); 
            
             for(iFace = 1:size(obj.Faces,1))
                iA = obj.Faces(iFace,1);
                iB = obj.Faces(iFace,2);
                iC = obj.Faces(iFace,3);
                A = obj.Verts(iA,:);
                B = obj.Verts(iB,:);
                C = obj.Verts(iC,:);
                
                N = cross(C-A,B-A);
                
                newNormals(iA,:) = newNormals(iA,:) + N;
                newNormals(iB,:) = newNormals(iB,:) + N;
                newNormals(iC,:) = newNormals(iC,:) + N;
                
                obj.FaceNormals(iFace,:) = N ./ norm(N); 
             end
             
             for(iNorm = 1:size(newNormals,1))
                 newNormals(iNorm,:) = newNormals(iNorm,:) ./ norm(newNormals(iNorm,:));
             end
             
             obj.Normals = newNormals; 
         end
        
        function obj = Draw(obj, UseOpenGL)
            
            FaceLighting = 'phong'; 
            if(UseOpenGL)
                FaceLighting = 'gouraud';
            end
            
            if(~obj.HasParent)
                disp(['Rendering ' num2str(obj.StructureID)]);
            end
            
            patch('Faces', obj.Faces, ...
             'Vertices', [obj.Verts(:,1) + obj.ModelTranslation(1) obj.Verts(:,2) + obj.ModelTranslation(2) obj.Verts(:,3) + obj.ModelTranslation(3)], ...
             'FaceVertexCData', obj.Color, ...
             'VertexNormals', obj.Normals, ...
             'FaceColor', obj.Color, ...'none', ... % obj.Color, ... %
             'FaceAlpha', obj.Alpha, ... 
             'EdgeColor', 'none', ...%[0 0 1], ...
             'FaceLighting', FaceLighting,...
             'AmbientStrength', .2, ...
             'DiffuseStrength', .8,...
             'SpecularStrength', .02, ...
             'SpecularExponent', 15,...
             'BackFaceLighting', 'unlit');
         
         %Create faces for all cylinders
%          
%             for(iLoc = 1:length(obj.Links))
%                if(obj.BadLocs(iLoc))
%                    continue; 
%                end
%                
%                listLinks =  obj.Links{iLoc};
%                numLinks = size(listLinks,1);
%                for(iLink = 1:size(listLinks,1))
%                   if(listLinks(iLink,1) > iLoc)
%                     X = obj.Locs(iLoc, obj.iX) * obj.nmPerPixel;
%                     Y = obj.Locs(iLoc, obj.iY) * obj.nmPerPixel;
%                     Z = obj.Locs(iLoc, obj.iZ) * obj.nmPerSection;
%                     Radius = obj.Locs(iLoc, obj.iRadius) * obj.nmPerPixel;
%                     
%                     iLinked = listLinks(iLink,1);
%                     BX = obj.Locs(iLinked, obj.iX) * obj.nmPerPixel;
%                     BY = obj.Locs(iLinked, obj.iY) * obj.nmPerPixel;
%                     BZ = obj.Locs(iLinked, obj.iZ) * obj.nmPerSection;
%                     BRadius = obj.Locs(iLinked, obj.iRadius) * obj.nmPerPixel;
%                     
%                     line([X BX], [Y BY], [Z BZ]);
%                   end
%                end
%             end

%            mesh(obj.Verts);
         
         
%             BadIndicies = find(obj.BadLocs == true); 
%             %Render spheres for locations with one or fewer links
%             SphereIndicies = find(obj.LocLinkCount(:,1) == 1);
%             SphereIndicies = setdiff(SphereIndicies,BadIndicies); 
%  %           LocationIDs = obj.MapIDToIndex(SphereIndicies); 
%             for(i = 1:length(SphereIndicies))
%                iLoc = SphereIndicies(i);
%                ID = obj.Locs(iLoc, obj.iID); 
%                X = obj.Locs(iLoc, obj.iX) * obj.nmPerPixel;
%                Y = obj.Locs(iLoc, obj.iY) * obj.nmPerPixel; 
%                Z = obj.Locs(iLoc, obj.iZ); 
%                Radius = obj.Locs(iLoc, obj.iRadius) * obj.nmPerPixel;    
%                               
%                Z = Z * obj.nmPerSection;
%                
%                [Sx, Sy, Sz] = sphere(12);
%                 Sx = (Sx .* Radius) + X(1); 
%                 Sy = (Sy .* Radius) + Y(1); 
%                 Sz = (Sz .* Radius) + Z(1); 
%                 
%                 surf(Sx,Sy,Sz, ...
%                      'FaceColor', obj.Color, ...
%                      'EdgeColor', 'none', ...
%                      'FaceLighting', FaceLighting,...
%                      'AmbientStrength',.3, ...
%                      'DiffuseStrength',.8,...
%                      'SpecularStrength',.9, ...
%                      'SpecularExponent',15,...
%                      'BackFaceLighting','unlit');                
%                 
%             end
        end
        
        function obj = DrawNormals(obj, recalculate, color)
            ObjTriRep = TriRep(obj.Faces, obj.Verts);
            TriCenters = ObjTriRep.incenters(); 
            Norms = []; 
            
            if(recalculate)
                Norms = ObjTriRep.faceNormals();
                Norms = Norms ./ 3;
            else
                Norms = obj.FaceNormals; 
                Norms = Norms ./ 3;
            end
            
            scale = 0;
            
            quiver3(TriCenters(:,1), TriCenters(:,2), TriCenters(:,3), ...
                    Norms(:,1), Norms(:,2), Norms(:,3), scale, ...
                    'Color', color, 'LineWidth', 2);
            
            
        end
        
        function label_str = GetLabel(obj)
            if ~isempty(obj.Label)
               label_str = sprintf('%d\n%s', obj.StructureID, obj.Label);
            else
               label_str = num2str(obj.StructureID); 
            end
            
        end
        
        function RenderLabelText(obj)
            GoodIndicies = find(obj.BadLocs == false); 
            
            meanX = (median(obj.Locs.X(GoodIndicies)) * obj.nmPerPixel) + obj.ModelTranslation(1);
            meanY = (median(obj.Locs.Y(GoodIndicies)) * obj.nmPerPixel) + obj.ModelTranslation(2);
            maxZ = (max(obj.Locs.Z(GoodIndicies)) * obj.nmPerSection)  + obj.ModelTranslation(3);
            maxRadius = max(obj.Locs.Radius(GoodIndicies)) * obj.nmPerPixel;
            
            FontSize = 8;
            FontWeight = 'normal'; 
            if(~obj.HasParent)
                FontSize = 14;
                FontWeight = 'bold'; 
            end 
            
            text(meanX,meanY,maxZ+(maxRadius*1.5), ...
                 obj.GetLabel(), ...
                 'Color', obj.Color, ...
                 'FontSize', FontSize, ...
                 'FontWeight', FontWeight);
            
%              for(iLoc = 1:size(obj.Locs,1))
%                  X = obj.Locs(iLoc, obj.iX) * obj.nmPerPixel;
%                  Y = obj.Locs(iLoc, obj.iY) * obj.nmPerPixel;
%                  Z = obj.Locs(iLoc, obj.iZ) * obj.nmPerSection;
%                  
%                  text(X,Y,Z, ...
%                      num2str(iLoc), ...
%                      'Color',[1 1 1] - obj.Color, ...
%                      'FontSize', 7, ...
%                      'FontWeight', FontWeight);
%              end
        end
        
        function [DOM, ParentNode, Node] = UpdateColladaFile(obj, DOM, ParentNode, ParentTranslation, MaterialURL)
            
            
            %See if we can be represented as a sphere.  Otherwise write the
            %entire geometry
            MaterialTarget = [MaterialURL '#' obj.MaterialName]; 
            GeometryTarget = ['#' obj.ColladaStructName '-geometry'];
            Scale = []; 
            
            if(~obj.UseCommonSphere)
                DOM = WriteColladaGeometry(DOM, obj.ColladaStructName, MaterialTarget, ...
                                                    obj.Verts, ...
                                                    obj.Faces, ...
                                                    obj.Normals);
                                                
                                   
            else
                GeometryTarget = ['CommonGeometry.dae#sphere-geometry'];
                Scale = obj.ModelScale; 
                
            end
                                                
            [DOM, ParentNode, Node] = AddColladaNode(DOM, ...
                           ParentNode,    ...
                           num2str(obj.StructureID), ...
                           GeometryTarget, ...
                           obj.ColladaMaterialName, ...
                           MaterialTarget, ...
                           obj.ModelTranslation, ...
                           obj.ModelTranslation - ParentTranslation, ...
                           Scale);        
                                    
            
            
            
                                                
%             DOM = AddToColladaVisualScene(DOM,StructName, ...
%                                              obj.MaterialName, ...
%                                              obj.ModelTranslation); 
        end
        
        
        
        function [GeometryDOM, Node] = CreateColladaGeometryFile(obj, Path, MaterialURL)
            if(~isempty(Path))
                Path = [Path filesep];
            end
                                    
            GeometryDOM = CreateColladaFile(); 
            
            DOMNode = GeometryDOM.getDocumentElement;
            
            MaterialTarget = [MaterialURL '#' obj.MaterialName]; 
                       
            GeometryDOM = WriteColladaGeometry(GeometryDOM, ...
                                                obj.ColladaStructName, ...
                                                MaterialTarget, ...
                                                obj.Verts, ...
                                                obj.Faces, ...
                                                obj.Normals);

            LibNodes = GeometryDOM.createElement('library_nodes');
            
            
            GeometryTarget = ['#' obj.ColladaStructName '-geometry'];
            
        
            [GeometryDOM, LibNodes, Node] = AddColladaNode(GeometryDOM, ...
                           LibNodes,    ...
                           num2str(obj.StructureID), ...
                           GeometryTarget, ...
                           obj.ColladaMaterialName, ...
                           MaterialTarget, ...
                           obj.ModelTranslation, ...
                           [], []); 
                       
            DOMNode.appendChild(LibNodes);
            
%             LibVisualScenes = GeometryDOM.createElement('library_visual_scenes');
%             VisSceneNode = GeometryDOM.createElement('visual_scene');
%             SceneNode = GeometryDOM.createElement('node');
%             
%             VisSceneNode.setAttribute('id',[StructName '-Scene']); 
%             VisSceneNode.setAttribute('name', [StructName '-Scene']);
%             
%             NodeRef = GeometryDOM.createElement('instance_node');
%             NodeRef.setAttribute('url', ['#NodeID-'  num2str(obj.StructureID)]);
%             
%             SceneNode.appendChild(NodeRef); 
%             VisSceneNode.appendChild(SceneNode); 
%             LibVisualScenes.appendChild(VisSceneNode); 
%             DOMNode.appendChild(LibVisualScenes); 
            
            
                                                        
%             GeometryDOM = AddToColladaVisualScene(GeometryDOM,num2str(obj.StructureID), ...
%                                              obj.MaterialName, ...
%                                              obj.ModelTranslation);
        end
        
                
        function obj = UpdateColladaSceneFile(obj, DOM, SceneCenter)
        %Add a reference to this structure to the scene.
        
            DOMNode = DOM.getDocumentElement;
            
            UrlFile = [num2str(obj.StructureID) '.dae']; 
    
            VisSceneLibList = DOMNode.getElementsByTagName('library_visual_scenes'); 
            VisSceneLibNode = [];
            if(isempty(VisSceneLibList.item(0)))
               VisSceneLibNode = DOM.createElement('library_visual_scenes'); 
               DOMNode.appendChild( VisSceneLibNode); 
            else
               VisSceneLibNode = VisSceneLibList.item(0);
            end
            
            VisSceneList = DOMNode.getElementsByTagName('visual_scene'); 
            VisSceneNode = []; 
            if(isempty(VisSceneList.item(0)))
               VisSceneNode = DOM.createElement('visual_scene'); 
               VisSceneNode.setAttribute('id',['VisualSceneNode']); 
               VisSceneNode.setAttribute('name', 'untitled');
               VisSceneLibNode.appendChild( VisSceneNode);
            else
               VisSceneNode = VisSceneList.item(0);
            end
                                    
            NewSceneNode = DOM.createElement('node');
            NewSceneNode.setAttribute('name', ['node-' obj.ColladaStructName]); 
            
            NodeRef = DOM.createElement('instance_node');
            NodeRef.setAttribute('url', [UrlFile '#NodeID-'  num2str(obj.StructureID)]);
            
            
            TranslateNode = DOM.createElement('translate'); 
            TranslateNode.setAttribute('sid', 'translate'); 
            TranslateNode.appendChild(DOM.createTextNode( num2str((obj.ModelTranslation - SceneCenter),'%g '))) ;
            
            NewSceneNode.appendChild(TranslateNode); 
            NewSceneNode.appendChild(NodeRef); 
            
            VisSceneNode.appendChild(NewSceneNode); 
            VisSceneLibNode.appendChild(VisSceneNode);
            
            SceneNodeList = DOMNode.getElementsByTagName('scene'); 
            SceneNode = [];
            if(isempty(SceneNodeList.item(0)))
               SceneNode = DOM.createElement('scene');
               SceneInstanceNode = DOM.createElement('instance_visual_scene');
               SceneInstanceNode.setAttribute('url', ['#VisualSceneNode']);
               SceneNode.appendChild(SceneInstanceNode);               
            
               DOMNode.appendChild( SceneNode);
            else
               SceneNode = SceneNodeList.item(0);
            end
            
%             SceneInstanceNode = DOM.createElement('instance_visual_scene');
%             SceneInstanceNode.setAttribute('name', obj.ColladaStructName);
%             SceneInstanceNode.setAttribute('sid', obj.ColladaStructName);
%             SceneInstanceNode.setAttribute('url', ['#scene-' obj.ColladaStructName]);
%             SceneNode.appendChild(SceneInstanceNode);                
            
        end
        
        function obj = WriteColladaFile(obj, Path)
            if(~isempty(Path))
                Path = [Path filesep];
            end
            
            TargetPath = [Path num2str(obj.StructureID) '.dae'];
            
            DOM = CreateColladaFile();   
            
            DOM = WriteColladaGeometry(DOM, num2str(obj.StructureID), ...
                                                    obj.Verts, ...
                                                    obj.Faces, ...
                                                    obj.Normals);
                                                
            AddToColladaVisualScene(DOM,num2str(obj.StructureID), ...
                                             obj.ColladaMaterialName, ...
                                             obj.ModelTranslation); 
                                                
            xmlwrite(TargetPath, DOM);
        end
        
        
        
        function obj = WriteObjFile(obj, ObjPath, MtlFile)
            if(~isempty(ObjPath))
               ObjPath = [ObjPath filesep];
            end
            
            TargetPath = [ObjPath num2str(obj.StructureID) '.obj'];
            
            hFile = fopen(TargetPath,'w');
            
            fprintf(hFile, ['mtllib ' MtlFile '\n']);
            
            
            obj.WriteVerts(hFile);
            
            obj.WriteNormals(hFile); 
            
            obj.WriteFaces(hFile,0);
            
            fclose(hFile);
        end
        
        function NumVerts = WriteVerts(obj, hFile)
            
            fprintf(hFile, 'v %.2f %.2f %.2f\n', obj.Verts(:,1), ...
                    obj.Verts(:,2), ...
                    obj.Verts(:,3));
                
%             for(iVert = 1:length(obj.Verts))
%             %    fprintf(hFile, ['v ' num2str(obj.Verts(iVert,:)) '\n']);
%                 fprintf(hFile, 'v %.2f %.2f %.2f\n', obj.Verts(iVert,1), ...
%                     obj.Verts(iVert,2), ...
%                     obj.Verts(iVert,3));
%             end
                        
            NumVerts = length(obj.Verts);
        end
        
        function NumVerts = WriteNormals(obj, hFile)
           
             fprintf(hFile, 'vn %.2f %.2f %.2f\n', obj.Normals(:,1), ...
                     obj.Normals(:,2), ...
                     obj.Normals(:,3));
                 
%             for(iNormal = 1:length(obj.Normals))
%                 %fprintf(hFile, ['vn ' num2str(obj.Verts(iNormal,:)) '\n']);
%                 fprintf(hFile, 'vn %.2f %.2f %.2f\n', obj.Normals(iNormal,1), ...
%                     obj.Normals(iNormal,2), ...
%                     obj.Normals(iNormal,3));
%             end
                        
            NumVerts = length(obj.Normals);
        end
        
        function obj = WriteFaces(obj, hFile, Offset)
            
            fprintf(hFile, ['g ' obj.MaterialName '\n']); 
            
            fprintf(hFile, ['usemtl ' obj.MaterialName '\n']);
            
            
            FacesCopy = obj.Faces;
            FacesCopy = FacesCopy + Offset;
            
            fprintf(hFile, 'f %d//%d %d//%d %d//%d\n', ...
                    FacesCopy(:,1), FacesCopy(:,1), ...
                    FacesCopy(:,2), FacesCopy(:,3),...
                    FacesCopy(:,3), FacesCopy(:,3));
            
%             for(iFace = 1:length(obj.Faces))
%                 fprintf(hFile, 'f %d//%d %d//%d %d//%d\n', ...
%                     FacesCopy(iFace,1), FacesCopy(iFace,1), ...
%                     FacesCopy(iFace,2), FacesCopy(iFace,3),...
%                     FacesCopy(iFace,3), FacesCopy(iFace,3));
%             end
            
            fprintf(hFile, '\n'); 
        end
    end
    
end

