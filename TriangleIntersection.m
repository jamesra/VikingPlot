function [ Verts, iAddedVerts, iTriangleVerts, FacesOne, FacesTwo, ...
           V1O, V1A, V1B, V2O,V2A,V2B] = TriangleIntersection( TriOne, TriTwo, Epsilon, varargin)
%TRIANGLEINTERSECTION Returns intersecting points for two triangles
%   Arguments (TriOne, TriTwo, [TriOneInternalVerts], [TriTwoInternalVerts]):
%   TriOne, TriOne: - 1x3 matrix of points in 3D space
%   OPTIONAL TriOneInternalVerts, TriTwoInternalVerts - Logical 1x3 matrix of points that would be inside
%   a mesh if an intersection is detected.  The triangles which would be invisible according to this data will not be returned.

%   NOTE: DOES NOT HANDLE CO-PLANAR INTERSECTION YET
%   TODO, implement as a test of a single triangle against a list of other
%   triangles for optimization

   
    Debug = true; 
    SignificantDigits = 3; 
    Verts = [];
    iAddedVerts = [];
    iTriangleVerts = []; 
    FacesOne = [];
    FacesTwo = []; 
    V1O = [];
    V2O = []; 
    V1A = [];
    V1B = []; 
    V2A = [];
    V2B = []; 
    hFig = [];
    hAxes = []; 
    
    overlap = TestBoundingBoxOverlap(TriOne, TriTwo, Epsilon); 
    if(~overlap)
        return; 
    end
    
    NTwo = cross(TriTwo(2,:) - TriTwo(1,:), TriTwo(3,:) - TriTwo(1,:));
    dTwo = dot(-NTwo, TriTwo(1,:));
    
    dToPlaneTriOne = [dot(NTwo, TriOne(1,:)) + dTwo
            dot(NTwo, TriOne(2,:)) + dTwo
            dot(NTwo, TriOne(3,:)) + dTwo]; 
        
   % dToPlaneTriOne = RoundDecimalSD(dToPlaneTriOne, SignificantDigits);
        
    iZerosTodPlaneTriOne = and(dToPlaneTriOne - Epsilon <= 0, dToPlaneTriOne + Epsilon >= 0);
    NumZerosTodPlaneTriOne = sum(iZerosTodPlaneTriOne);
    if(NumZerosTodPlaneTriOne == 3)
       %Coplanar
       
       if(Debug)
           hFig = gcf;
           set(hFig, 'Renderer', 'opengl');

           hAxes = gca;
           hold on;
            
       %     set(hAxes, 'DataAspectRatio', [1 1 1]); 
           set(hAxes, 'Color', [0.5 0.5 0.5]);

           fill3(TriOne(:,1), TriOne(:,2), TriOne(:,3), [0 1 0], 'parent', hAxes);
           fill3(TriTwo(:,1), TriTwo(:,2), TriTwo(:,3), [1 0 1], 'parent', hAxes);

           xlabel('X');
           ylabel('Y');
           zlabel('Z');
       end
        
       return;
    elseif(NumZerosTodPlaneTriOne > 0)
       %Touches the other triangle, we should add verticies to it if needed
       
    else
        if(dToPlaneTriOne(1) > 0 && ...
           dToPlaneTriOne(2) > 0 && ...
           dToPlaneTriOne(3) > 0)
           %All points above the plane, no intersection
           return;
        end

        if(dToPlaneTriOne(1) < 0 && ...
           dToPlaneTriOne(2) < 0 && ...
           dToPlaneTriOne(3) < 0)
           %All points below the plane, no intersection
           return;
        end
    end
    
    %The direction of the intersecting line through the planes
    NOne = cross(TriOne(2,:) - TriOne(1,:), TriOne(3,:) - TriOne(1,:));
    dOne = dot(-NOne, TriOne(1,:));
    dToPlaneTriTwo = [dot(NOne, TriTwo(1,:)) + dOne
                      dot(NOne, TriTwo(2,:)) + dOne
                      dot(NOne, TriTwo(3,:)) + dOne];
                  
 %   dToPlaneTriTwo = RoundDecimalSD(dToPlaneTriTwo, SignificantDigits);

    iZerosTodPlaneTriTwo = and(dToPlaneTriTwo - Epsilon <= 0, dToPlaneTriTwo + Epsilon >= 0);
    NumZerosTodPlaneTriTwo = sum(iZerosTodPlaneTriTwo);
    
    if(NumZerosTodPlaneTriTwo == 3)
       %Coplanar
       if(Debug)
            hAxes = gca;
            hold on;
       %     set(hAxes, 'DataAspectRatio', [1 1 1]); 
            set(hAxes, 'Color', [0.5 0.5 0.5]);


            fill3(TriOne(:,1), TriOne(:,2), TriOne(:,3), [0 1 0], 'parent', hAxes);
            fill3(TriTwo(:,1), TriTwo(:,2), TriTwo(:,3), [1 0 1], 'parent', hAxes);

            xlabel('X');
            ylabel('Y');
            zlabel('Z');
       end
       
       return;
    end
    
    
    if(NumZerosTodPlaneTriTwo == 0)
    
        if(dToPlaneTriTwo(1) > 0 && ...
           dToPlaneTriTwo(2) > 0 && ...
           dToPlaneTriTwo(3) > 0)
           %All points above the plane, no intersection
           return;
        end

        if(dToPlaneTriTwo(1) < 0 && ...
           dToPlaneTriTwo(2) < 0 && ...
           dToPlaneTriTwo(3) < 0)
           %All points below the plane, no intersection
           return;
        end
    end
    
    %They touch.  Check for intersecting points
    
    %If the points with zero distance are the same point, then check 
    %that the remaining verticies really intersect
    if(NumZerosTodPlaneTriOne == NumZerosTodPlaneTriTwo)
        
        dist = pdist2(TriOne(iZerosTodPlaneTriOne, :), TriTwo(iZerosTodPlaneTriTwo,:), 'euclidean', 'smallest', 1);
        if(sum(dist) <= Epsilon)
           %Check if the remaining distances are on opposite sides of the plane
           if(sum(dToPlaneTriOne(~iZerosTodPlaneTriOne) < 0) == sum(~iZerosTodPlaneTriOne))
               return;
           end
           
           if(sum(dToPlaneTriTwo(~iZerosTodPlaneTriTwo) > 0) == sum(~iZerosTodPlaneTriTwo))
               return;
           end
        end
    end
    
    %Check for one triangle resting against another without passing through
    %it.
    
    %Choose which verticies to use...
    [V1O, V1A, V1B] = FindIntersectingEdges(dToPlaneTriOne, Epsilon); 
    [V2O, V2A, V2B] = FindIntersectingEdges(dToPlaneTriTwo, Epsilon); 
                                
    DLine = cross(NOne,NTwo);
    Origin = TwoPlaneLineOrigin(DLine,NOne, NTwo, dOne, dTwo); 
    
    DLine = DLine ./ norm(DLine);
    
    
    
    ProjOneToLine = [dot(DLine, TriOne(1,:) - Origin)
                    dot(DLine, TriOne(2,:) - Origin)
                    dot(DLine, TriOne(3,:) - Origin)];
                    
    IntersectTriOne = [ProjOneToLine(V1A) + ((ProjOneToLine(V1O) - ProjOneToLine(V1A)) * (dToPlaneTriOne(V1A) / (dToPlaneTriOne(V1A) - dToPlaneTriOne(V1O)))) 
                       ProjOneToLine(V1B) + ((ProjOneToLine(V1O) - ProjOneToLine(V1B)) * (dToPlaneTriOne(V1B) / (dToPlaneTriOne(V1B) - dToPlaneTriOne(V1O))))];
                   
    [IntersectTriOne, VAB1Remap] = sort(IntersectTriOne);
    if(VAB1Remap(1) == 2)
       temp = V1A;
       V1A = V1B;
       V1B = temp;
    end
    
    ProjTwoToLine = [dot(DLine, TriTwo(1,:) - Origin)
                    dot(DLine, TriTwo(2,:) - Origin)
                    dot(DLine, TriTwo(3,:) - Origin)];
                       
    IntersectTriTwo = [ProjTwoToLine(V2A) + ((ProjTwoToLine(V2O) - ProjTwoToLine(V2A)) * (dToPlaneTriTwo(V2A) / (dToPlaneTriTwo(V2A) - dToPlaneTriTwo(V2O)))) 
                       ProjTwoToLine(V2B) + ((ProjTwoToLine(V2O) - ProjTwoToLine(V2B)) * (dToPlaneTriTwo(V2B) / (dToPlaneTriTwo(V2B) - dToPlaneTriTwo(V2O))))];
                   
    [IntersectTriTwo, VAB2Remap] = sort(IntersectTriTwo);
    if(VAB2Remap(1) == 2)
       temp = V2A;
       V2A = V2B;
       V2B = temp;
    end
    
%     IntersectTriOne = RoundDecimalSD(IntersectTriOne, 4);
%     IntersectTriTwo = RoundDecimalSD(IntersectTriTwo, 4);
    
    %Check if the triangles do overlap on the line
    if(IntersectTriOne(2) - Epsilon <= IntersectTriTwo(1) || ...
        IntersectTriOne(1) + Epsilon >= IntersectTriTwo(2) || ...
        IntersectTriTwo(2) - Epsilon <= IntersectTriOne(1) || ...
        IntersectTriTwo(1) + Epsilon >= IntersectTriOne(2))
        %No overlap, they do not intersect
        return;
    end
    
    %Check for a triangle with two verticies at the same point on the line
    if((IntersectTriOne(1) + Epsilon >= IntersectTriOne(2) && ...
       IntersectTriOne(1) - Epsilon <= IntersectTriOne(2)) || ...
       (IntersectTriTwo(1) + Epsilon >= IntersectTriTwo(2) && ...
       IntersectTriTwo(1) - Epsilon <= IntersectTriTwo(2)))
        %If the overlap is at a midpoint on the edge then subdivide the
        %triangle.  Otherwise return
       return;
    end
    
    %OK, they definitely overlap. Unpack the optional arguments if present
    if(length(varargin) >= 1)
        TriOneInternalVerts = varargin{1};
        %Remap the ignored verticies
        %TriOneInternalVerts = [TriOneInternalVerts(V1O) TriOneInternalVerts(V1A) TriOneInternalVerts(V1B)];
    else
        TriOneInternalVerts = logical([0 0 0]);
    end
    
    if(length(varargin) >= 2)
        TriTwoInternalVerts = varargin{2};
        %Remap the ignored verticies
        %TriTwoInternalVerts = [TriTwoInternalVerts(V1O) TriTwoInternalVerts(V1A) TriTwoInternalVerts(V1B)];
    else
        TriTwoInternalVerts = logical([0 0 0]);
    end
    
    [SortedIntersections, iLineSortOrder] = sort([IntersectTriOne; IntersectTriTwo]);
    
    %Lists for tracking which triangle needs to use which new points
    iAddedVerts = [];
    iAddedVertsTriOne = [1 2]; %In the case where one triangle is contained within a second
                            %we need to make sure we don't add verts to the
                            %smaller triangle
    iAddedVertsTriTwo = [3 4];
    
    iSortedVertOrder = [1 2 3 4];
    iSortedVertOrder = iSortedVertOrder(iLineSortOrder);
    iOverlappingVerticies = []; %Index of verticies in the overlapping region
    
    
    %Create all the points in 3D space...
    AdditionalVerticies = [(DLine * IntersectTriOne(1)) + Origin;
                           (DLine * IntersectTriOne(2)) + Origin;
                           (DLine * IntersectTriTwo(1)) + Origin;
                           (DLine * IntersectTriTwo(2)) + Origin];
                           
%     AdditionalVerticies = RoundDecimalSD(AdditionalVerticies, SignificantDigits); 
%     IntersectTriOne = RoundDecimalSD(IntersectTriOne, SignificantDigits);
%     IntersectTriTwo = RoundDecimalSD(IntersectTriTwo, SignificantDigits);
% 
     IntersectPoints = [IntersectTriOne; IntersectTriTwo];
%     
%     %If the rounded verticies overlap then reflect that in the IntersectTri
%     %values
     AddVertDist = pdist(AdditionalVerticies); 
     AddVertDist = squareform(AddVertDist); 
     MatchingAddVert = AddVertDist < Epsilon;
     
%     
%     %Don't match to ourselves
     MatchingAddVert(1,1) = 0; 
     MatchingAddVert(2,2) = 0; 
     MatchingAddVert(3,3) = 0; 
     MatchingAddVert(4,4) = 0;
     
     %If we match and the IntersectionPoints do not match then handle it
%     
%     if(MatchingAddVert(1,2) > 0)
%         %Snap to the left or right, depending on what is available
%         if(IntersectTriTwo(1) < IntersectTriOne(1))
%             IntersectTriOne(1) = IntersectTriTwo(1);
%             AdditionalVerticies(1,:) = AdditionalVerticies(3,:);
%         elseif(IntersectTriTwo(2) > IntersectTriTwo(2))
%             IntersectTriOne(2) = IntersectTriTwo(2); 
%             AdditionalVerticies(2,:) = AdditionalVerticies(4,:);
%         else
%             %This means they perfectly overlap, and they are too close to
%             %be seperate points...
%             assert(false);
%         end
%         
%         %IntersectTriOne(2) = IntersectTriOne(1);
%     end
%     
%     if(MatchingAddVert(3,4) > 0)
%         %Snap to the left or right, depending on what is available
%         if(IntersectTriOne(1) < IntersectTriTwo(1))
%             IntersectTriTwo(1) = IntersectTriOne(1);
%             AdditionalVerticies(3,:) = AdditionalVerticies(1,:);
%         elseif(IntersectTriTwo(2) > IntersectTriTwo(2))
%             IntersectTriTwo(2) = IntersectTriOne(2);
%             AdditionalVerticies(4,:) = AdditionalVerticies(2,:);
%         else
%             %This means they perfectly overlap, and they are too close to
%             %be seperate points...
%             assert(false);
%         end
%         
%         %IntersectTriOne(2) = IntersectTriOne(1);
%     else
% 
%         if(sum(MatchingAddVert(3,1:2) > 0))
%             IntersectTriTwo(1) = IntersectPoints(find(MatchingAddVert(3,1:2) > 0, 1, 'first'));
%         end
% 
%         if(sum(MatchingAddVert(4,1:2) > 0))
%             IntersectTriTwo(2) = IntersectPoints(find(MatchingAddVert(4,1:2) > 0, 1, 'first'));
%         end
%     end
    
    %OK, check if they intersect at the same point on the line... If they
    %do the triangle is ignored
    NoNewFacesForTriangleOne = false;
    if(IntersectTriOne(1) == IntersectTriOne(2))
        NoNewFacesForTriangleOne = true;
    end
    
    NoNewFacesForTriangleTwo = false; 
    if(IntersectTriTwo(1) == IntersectTriTwo(2))
        NoNewFacesForTriangleTwo = true;
    end
       
    if(IntersectTriOne(1) - Epsilon <= IntersectTriTwo(2) &&...
           IntersectTriOne(1) + Epsilon >= IntersectTriTwo(2))
%        return;
        iOverlappingVerticies = [1];
        iAddedVerts = [3 1 2];
        iAddedVertsTriOne = [1 2];
        iAddedVertsTriTwo =  [3 1]; %We have to remap this since the other #4 went away
%         iAddedVerts = [1];
%         iAddedVertsTriOne = [1];
%         iAddedVertsTriTwo = [1]; %We have to remap this since the other #4 went away

        AdditionalVerticies(4,:) = [];
        
        %Make sure the additional verts do not match two existing
        %verticies on each triangle
        [Distance, iDist] = pdist2(AdditionalVerticies(1,:), [TriOne; TriTwo], 'euclidean', 'Smallest', 1);
        if(sum(Distance(1:3) <= Epsilon) > 0 && sum(Distance(4:6) <= Epsilon) > 0)
            return;
        end
        
    elseif(IntersectTriOne(2) - Epsilon <= IntersectTriTwo(1) &&...
       IntersectTriOne(2) + Epsilon >= IntersectTriTwo(1))
%        return;
        iAddedVerts = [1 2 3];
        iAddedVertsTriOne = [1 2]; 
        iAddedVertsTriTwo = [2 3];
%         iAddedVerts = [2];
%         iAddedVertsTriOne = [2]; 
%         iAddedVertsTriTwo = [2];
        iOverlappingVerticies = 2;
        AdditionalVerticies(3,:) = [];
        
        [Distance, iDist] = pdist2(AdditionalVerticies(2,:), [TriOne; TriTwo],  'euclidean', 'Smallest', 1);
        if(sum(Distance(1:3) <= Epsilon) > 0 && sum(Distance(4:6) <= Epsilon) > 0)
            return;
        end
    else
        if(IntersectTriOne(1) - Epsilon <= IntersectTriTwo(1) &&...
           IntersectTriOne(1) + Epsilon >= IntersectTriTwo(1))
            iAddedVerts = [1];
            iOverlappingVerticies = [1];
            iAddedVertsTriTwo(1) =  1;
            iAddedVertsTriTwo(2) =  3; %We have to remap this since the other 3 went away
            AdditionalVerticies(3,:) = []; 

        else
            if(IntersectTriOne(1) > IntersectTriTwo(1))
                iOverlappingVerticies = [1];
                iAddedVerts = [3 1];
                iAddedVertsTriTwo = [iAddedVertsTriTwo(1) 1 iAddedVertsTriTwo(2)];
            else
                iAddedVerts = [1 3];
                iOverlappingVerticies = [3];
                iAddedVertsTriOne = [iAddedVertsTriOne(1) 3 iAddedVertsTriOne(2)];
            end
        end
    
        if(IntersectTriOne(2) - Epsilon <= IntersectTriTwo(2) && ...
           IntersectTriOne(2) + Epsilon >= IntersectTriTwo(2))
            AdditionalVerticies(iAddedVertsTriTwo(end),:) = []; 
            iAddedVertsTriTwo(end) =  2;
            iAddedVerts = [iAddedVerts 2];
            iOverlappingVerticies = [iOverlappingVerticies 2];
        else
    %        iAddedVerts = [iAddedVerts 2];
    %        iOverlappingVerticies = [iOverlappingVerticies 2];
          %  iAddedVertsTriTwo(end) =  [];
          %  iAddedVerts = [iAddedVerts 2]; 
         %   iOverlappingVerticies = [iOverlappingVerticies 2];

            if(IntersectTriOne(2) - Epsilon <= IntersectTriTwo(2))
                iAddedVertsTriTwo = [iAddedVertsTriTwo(1:end-1) 2 iAddedVertsTriTwo(end)];
                iAddedVerts = [iAddedVerts 2 iAddedVertsTriTwo(end)];
                iOverlappingVerticies = [iOverlappingVerticies 2];
            else
                iAddedVertsTriOne = [iAddedVertsTriOne(1:end-1) iAddedVertsTriTwo(end) iAddedVertsTriOne(end)];
                iAddedVerts = [iAddedVerts iAddedVertsTriTwo(end) 2];
                iOverlappingVerticies = [iOverlappingVerticies iAddedVertsTriTwo(end)];
            end
        end
    end
    
    if(Debug)
        
        set(gcf, 'Renderer', 'opengl');
        
        hAxes = gca;
       
        hold on;
        
        cla; 
        
        set(hAxes, 'DataAspectRatio', [1 1 1]); 
        set(hAxes, 'Color', [0.5 0.5 0.5]);
        
        global hOne; 
        global hTwo;
        
        if exist('hOne', 'var') && ~isempty(hOne)
            try
                delete(hOne);
            end
            hOne = [];
        end
        
        if exist('hTwo', 'var') && ~isempty(hTwo)
            try
                delete(hTwo);
            end
             hTwo = [];
        end
        
        hOne = fill3(TriOne(:,1), TriOne(:,2), TriOne(:,3), [0 1 0], 'parent', hAxes);
        hTwo = fill3(TriTwo(:,1), TriTwo(:,2), TriTwo(:,3), [1 0 1], 'parent', hAxes);

        xlabel('X');
        ylabel('Y');
        zlabel('Z');
    
%         line([Origin(1) Origin(1) + DLine(1)], ...
%              [Origin(2) Origin(2) + DLine(2)], ...
%              [Origin(3) Origin(3) + DLine(3)], ...
%              'color', [0 0 1], 'parent', hAxes, 'MarkerSize', 12);

        global hText;
         
        if exist('hText', 'var') && ~isempty(hText)
            try
                delete(hText);
            end
            hText = [];
        end
        
        TempVerts = [TriOne; TriTwo];
        for(iVert = 1:size(TempVerts,1))
             
             hNew = text(TempVerts(iVert,1)+0.001,TempVerts(iVert,2)+0.001,TempVerts(iVert,3)+0.001, ...
                     num2str(iVert), ...
                     'Color', [1 1 0], ...
                     'FontSize', 10, ...
                     'Parent', hAxes);
             hText = [hText hNew]; 
        end
        
        global iNextFile
        
        if exist('iNextFile', 'var')
            iNextFile = iNextFile + 1; 
        else
            iNextFile = 1; 
        end
        
        drawnow;

%        saveas(hFig,['D:\temp\MeshStitch' num2str(iNextFile) '.png'], 'png');
                  
    end
    
    %Contains all verticies, TriOne = 1 2 3, TriTwo = 4 5 6, Intersecting = 7 [8 9 10]
    Verts = [TriOne;
             TriTwo;
             AdditionalVerticies(iAddedVerts,:)];     
    
    InternalVerts = [TriOneInternalVerts TriTwoInternalVerts];
    
    %Sort so they still match indicies
    [iSortedAddedVerts, iRemapValues] = sort(iAddedVerts);
    iAddedVertsTriOne = iRemapValues(iAddedVertsTriOne);
    iAddedVertsTriTwo = iRemapValues(iAddedVertsTriTwo);
    iOverlappingVerticies = iRemapValues(iOverlappingVerticies);
    
    OverlappingVerticies = logical(zeros(1,size(Verts,1)));
    OverlappingVerticies(iOverlappingVerticies+6) = true;
    
    %Adjust indicies so they can be used with Verts matrix
    V2O = V2O + 3;
    V2A = V2A + 3;
    V2B = V2B + 3;
    iAddedVerts = iAddedVerts + 6;
    iSortedAddedVerts = iSortedAddedVerts + 6; 
    iOverlappingVerticies = iOverlappingVerticies + 6;
    iAddedVertsTriOne = iAddedVertsTriOne + 6;
    iAddedVertsTriTwo = iAddedVertsTriTwo + 6;
    
    if(Debug)
       for(iVert = iSortedAddedVerts)
             text(Verts(iVert,1)+0.001,Verts(iVert,2)+0.001,Verts(iVert,3)-0.001, ...
                     num2str(iVert), ...
                     'Color', [0 0 1], ...
                     'FontSize', 10, ...
                     'Parent', gca);
       end
    end
    
    
    iTriOne = [1 2 3];
    iTriTwo = [4 5 6];
            
    BifurcateTriOne = false;
    BifurcateTriTwo = false; 
    
    %Need to handle case where triangles share verticies and an
    %intersection point...
    [DistanceBetweenTri, iDistTriOne] = pdist2(TriOne, TriTwo, 'euclidean', 'Smallest', 1);

    TriTwoRemoveMatch = DistanceBetweenTri <= Epsilon;
    if(sum(TriTwoRemoveMatch) > 0)

        BifurcateTriOne = true; 
        BifurcateTriTwo = true; 
        
        iTri = [1 2 3 4 5 6];

        TriOneDuplicate = iDistTriOne(TriTwoRemoveMatch);
        TriTwoDuplicate = iTriTwo(TriTwoRemoveMatch);

        if(V2A == TriTwoDuplicate)
            V2A = V1A;
        elseif(V2B == TriTwoDuplicate)
            V2B = V1B;
        else
            V2O = V1O; 
        end
    end

    [Distance, iDist] = pdist2([TriOne; TriTwo], Verts(iSortedAddedVerts,:), 'euclidean', 'Smallest', 1);

    RemoveMatch = Distance <= Epsilon;
    
    BifurcateTriOne = BifurcateTriOne || sum(iDist(RemoveMatch) <= 3) > 0; 
    BifurcateTriTwo = BifurcateTriTwo || sum(and(iDist(RemoveMatch) >= 4, iDist(RemoveMatch) <= 6)) > 0;

    if(sum(RemoveMatch) > 0)
        %OK, one of the verticies lies on the line.  This means we need to
        %bifurcate one or both of the triangles instead of subdividing.
        
        [TriOneRemoveVerts, iTriOneRemoveVerts, iTriOneReplacementIndex] = intersect(iAddedVertsTriOne, iSortedAddedVerts(RemoveMatch));
        [TriTwoRemoveVerts, iTriTwoRemoveVerts, iTriTwoReplacementIndex] = intersect(iAddedVertsTriTwo, iSortedAddedVerts(RemoveMatch));

        ReplacementIndex = iDist(RemoveMatch);
        ReplacementIndexTriOne = ReplacementIndex(iTriOneReplacementIndex);
        ReplacementIndexTriTwo = ReplacementIndex(iTriTwoReplacementIndex);

        %Find the indicies above the one we are removing        
        RemovedVerts = unique([TriOneRemoveVerts TriTwoRemoveVerts]);
        OverlappingVerticies(ReplacementIndex) = OverlappingVerticies(iSortedAddedVerts(RemoveMatch));
        iVertsToRemove = iSortedAddedVerts(RemoveMatch);
        Verts(iVertsToRemove,:) = [];
        OverlappingVerticies(iVertsToRemove) = [];

        for(Removed = sort(RemovedVerts, 'descend'))
            iReplacedVertOne = iAddedVertsTriOne > Removed;
            iAddedVertsTriOne(iReplacedVertOne) = iAddedVertsTriOne(iReplacedVertOne) - 1;

            iReplacedVertTwo = iAddedVertsTriTwo > Removed;
            iAddedVertsTriTwo(iReplacedVertTwo) = iAddedVertsTriTwo(iReplacedVertTwo) - 1;

            iReplaceAddedVerts = iSortedAddedVerts > Removed;
            iSortedAddedVerts(iReplaceAddedVerts) = iSortedAddedVerts(iReplaceAddedVerts) - 1;
        end

        iAddedVertsTriOne(iTriOneRemoveVerts) = ReplacementIndexTriOne;
        iAddedVertsTriTwo(iTriTwoRemoveVerts) = ReplacementIndexTriTwo;

        iSortedAddedVerts(RemoveMatch) = []; 
    else
        iTriOneRemoveVerts = []; 
        iTriTwoRemoveVerts = []; 
    end

        %Remove intersections that are already verticies
    
%    if(NumZerosTodPlaneTriOne >= 1 || NumZerosTodPlaneTriTwo >= 1)
    
%    if(sum(ismember([V1O V1A V1B], iAddedVertsTriOne)) > 0) %NumZerosTodPlaneTriOne >= 1)
    if(NoNewFacesForTriangleOne)
        FacesOne = [V1O V1A V1B]; 
    elseif(BifurcateTriOne)
        if(VAB1Remap(1) == 2)
            FacesOne = BuildFacesForBifurcatedTriangle(V1A, V1B, V1O,  iAddedVertsTriOne, OverlappingVerticies, InternalVerts);
        else
            FacesOne = BuildFacesForBifurcatedTriangle(V1B, V1O, V1A,  iAddedVertsTriOne, OverlappingVerticies, InternalVerts);
        end

        iAddedVertsTriOne(iTriOneRemoveVerts) = [];
    else
        FacesOne = BuildFacesForSubdividedTriangle(V1O, V1A, V1B,  iAddedVertsTriOne, OverlappingVerticies, InternalVerts);
    end

    %if(NumZerosTodPlaneTriTwo >= 1)
    %if(sum(ismember([V2O V2A V2B], iAddedVertsTriTwo)) > 0)
    if(NoNewFacesForTriangleTwo)
        FacesOne = [V2O V2A V2B]; 
    elseif(BifurcateTriTwo)
        %Need to handle case of NumZerosToPlane == 2 where we create
        %two triangles
        if(VAB2Remap(1) == 2)
            FacesTwo = BuildFacesForBifurcatedTriangle( V2A, V2B, V2O, iAddedVertsTriTwo, OverlappingVerticies, InternalVerts);
        else
            FacesTwo = BuildFacesForBifurcatedTriangle( V2B, V2O, V2A, iAddedVertsTriTwo, OverlappingVerticies, InternalVerts);
        end

        iAddedVertsTriTwo(iTriTwoRemoveVerts) = [];
    else
        FacesTwo = BuildFacesForSubdividedTriangle(V2O, V2A, V2B, iAddedVertsTriTwo, OverlappingVerticies, InternalVerts);
    end

    %Remove any verts that should have been replaced earlier
    if(sum(TriTwoRemoveMatch) > 0)
%        for(iDuplicate = 1:length(TriTwoDuplicate))
            FacesOne(FacesOne == TriTwoDuplicate(iDuplicate)) = TriOneDuplicate(iDuplicate);
%        end
        
%        for(iDuplicate = 1:length(TriTwoDuplicate))
            FacesTwo(FacesTwo == TriTwoDuplicate(iDuplicate)) = TriOneDuplicate(iDuplicate);
%        end
    end
        
%    else
%        FacesOne = BuildFacesForSubdividedTriangle(V1O, V1A, V1B, iAddedVertsTriOne, OverlappingVerticies, InternalVerts);
%        FacesTwo = BuildFacesForSubdividedTriangle(V2O, V2A, V2B, iAddedVertsTriTwo, OverlappingVerticies, InternalVerts);
%    end

    %Remove any unused verticies
    NewFaces = [FacesOne;FacesTwo];   
    NumFaces = size(NewFaces,1); 
    
    %Make sure none of the faces have duplicate values
    for(iFaceOne = NumFaces:-1:1)
       Face = NewFaces(iFaceOne,:);
       u = unique(Face);
       assert(length(u) == 3);  
    end
       
    [MappedVerts, MappedFaces] = RemoveUnusedVerts(Verts, NewFaces);
    
    iMappedVerts = unique(MappedFaces); 
    iUnmappedVerts = unique(NewFaces); 
        
    iTriangleVerts = iUnmappedVerts(iUnmappedVerts <= 6);
    
    iNewVertStart = iUnmappedVerts > 6;
    minNewVert = min(iMappedVerts(iNewVertStart));
    maxNewVert = max(iMappedVerts(iNewVertStart));
    
    Verts = MappedVerts;
    
    iAddedVerts = minNewVert:maxNewVert;
    NewFaces = MappedFaces;
    FacesOne = NewFaces(1:size(FacesOne,1),:);
    FacesTwo = NewFaces(size(FacesOne,1)+1:end,:);
    
    %Check if the new verticies overlap with the know verticies
    %Patch up the normals so they face the correct way
    
    FacesOne = FlipFaces(NOne, Verts, FacesOne);
    FacesTwo = FlipFaces(NTwo, Verts, FacesTwo);
    
        
    LastErrorCheck = [FacesOne; FacesTwo]; 
    NumFaces = size(LastErrorCheck,1);
     %Make sure none of the faces have duplicate values
    for(iFaceOne = NumFaces:-1:1)
       Face = LastErrorCheck(iFaceOne,:);
       u = unique(Face);
       assert(length(u) == 3);  
    end

end


