function [ NewVerts, NewFaces, iVertsNotToPrune ] = StitchFaces( Verts, Faces, iVertsToPrune)
%STITCHFACES Given a list of verticies and list of triangle faces stitch
%the faces together where triangles overlap.  Return new verticies created
%and a copy of the Faces matrix with the fixes.  The Verts should be
%appended to the passed in Verts array
%We prune facse with indicies contained in iVertsToPrune if they overlap

Debug = true;
Epsilon = eps(max(max(abs(Verts)))) * 100; 
%Epsilon = 0.0000001; 
Precision = 3; 
NumFaces = size(Faces,1); 
NumNewFaces = size(Faces,1); 
NumVerts = size(Verts,1);

NewVerts = Verts; 
%NewVerts = RoundDecimalSD(Verts, Precision); 

NewFaces = Faces;

iNewVertOffset = NumVerts;
iNewFaceOffset = NumFaces;

iVertsNotToPrune = iVertsToPrune;
hFig = [];
hAxes = []; 

if(Debug)
    global hPatch;
    
    hFig = gcf;
    set(hFig, 'Renderer', 'opengl');
    hAxes = gca; 
 %   cla; 
    
    iX = 1; 
    iY = 2; 
    iZ = 3; 
   %Set the size of the axes display
    minX = min(Verts(:,iX));
    maxX = max(Verts(:,iX));
    minY = min(Verts(:,iY));
    maxY = max(Verts(:,iY));
    minZ = min(Verts(:,iZ));
    maxZ = max(Verts(:,iZ));
    
    absMin = min([minX minY minZ]);
    absMax = max([maxX maxY maxZ]);
    
    set(hAxes, 'XLim', [minX maxX]); 
    set(hAxes, 'YLim', [minY maxY]); 
    
    zlim = [minZ maxZ]; 
    
    set(hAxes, 'ZLim', [min(zlim) max(zlim)]); 

%     set(hAxes, 'XLim', [absMin absMax]); 
%     set(hAxes, 'YLim', [absMin absMax]); 
%     
%     zlim = [absMin absMax]; 
%     
%     set(hAxes, 'ZLim', [min(zlim) max(zlim)]);
    
    set(hAxes, 'DataAspectRatio', [1 1 1]);
    set(hAxes, 'Color', [0.5 0.5 0.5]);
    
    %hPatch = findall(hAxes, 'type', 'patch');
    if exist('hPatch', 'var') && ~isempty(hPatch)
        try
            delete(hPatch);

        end
        hPatch = [];
    end

    hPatch = patch('Parent', hAxes, ...
         'Faces', NewFaces, ...
         'Vertices', NewVerts, ...
         'FaceVertexCData', [1 0 0], ...
         'FaceAlpha', 0.5, ...
         'FaceColor', [.75 .4 .1], ...
         'EdgeColor', [0 0 1], ...
         'FaceLighting', 'phong',...
         'AmbientStrength', .2, ...
         'DiffuseStrength', .8,...
         'SpecularStrength', .02, ...
         'SpecularExponent', 15,...
         'BackFaceLighting', 'lit');

     for(iVert = 1:size(NewVerts,1))
         text(NewVerts(iVert,1)+0.001,NewVerts(iVert,2)+0.001,NewVerts(iVert,3)+0.001, ...
              num2str(iVert), ...
              'Color', [1 1 0], ...
              'FontSize', 10, ...
              'Parent', hAxes);
     end

    drawnow;
end

i = 1; 
while(i < NumNewFaces)
 %   disp(['i: ' num2str(i)]);
    TriOneFaces = NewFaces(i,:);
    TriOne = NewVerts(TriOneFaces,:);
    j = i + 1; 
    while(j <= NumNewFaces)

        TriTwoFaces = NewFaces(j,:);
        c = intersect(TriOneFaces, TriTwoFaces);
        
        if(length(c) > 1)
           %This is a valid triangle for now, leave it on the new faces list
           j = j + 1; 
           continue;
        end
         
        InternalTriOne = ismember(TriOneFaces, iVertsToPrune);
        InternalTriTwo = ismember(TriTwoFaces, iVertsToPrune);
        
        TriTwo = NewVerts(TriTwoFaces,:);
        [IntersectingPoints, iIntersectingVerts, ...
            iTriangleVerts, ...
            UnmappedFaceSetOne, UnmappedFaceSetTwo, ...
            V1O, V1A, V1B, V2O,V2A,V2B] = TriangleIntersection(TriOne, TriTwo, Epsilon, InternalTriOne, InternalTriTwo);
        
        if(isempty(IntersectingPoints))
            %This is a valid triangle for now,  leave it on the new faces list
            j = j + 1;
            continue;
        end
        
%        RoundedIntersectingPoints = RoundDecimalSD(IntersectingPoints, Precision);
        
%        IntersectingPoints = RoundedIntersectingPoints;
%       disp(num2str(IntersectingPoints));
        disp(['i: ' num2str(i) ' j: ' num2str(j)]);
        
        %Check if the new verticies overlap with the known verticies
        [Distance, iDist] = pdist2(NewVerts, IntersectingPoints(iIntersectingVerts,:), 'euclidean', 'Smallest', 1);
        
        MergeEpsilon = 0.0001;
        Match = Distance <= MergeEpsilon;
        %Match = Distance <= Epsilon;

        iNovelIntersectingVerts = iIntersectingVerts(~Match);

        %OK, figure out the new faces for the intersecting triangles.
        NewVerts = cat(1, NewVerts, IntersectingPoints(iNovelIntersectingVerts,:));
        iNewVerts = zeros(1, length(iIntersectingVerts));
        iNewVerts(~Match) = iNovelIntersectingVerts - (min(iNovelIntersectingVerts)-1) + iNewVertOffset;
        iNewVerts(Match) = iDist(Match);
        iVertsNotToPrune = setdiff(iVertsNotToPrune, iDist(Match));
        
        iUsedTriOneFaces = iTriangleVerts(iTriangleVerts <= 3);
        iUsedTriTwoFaces = iTriangleVerts(and(iTriangleVerts >= 4, iTriangleVerts <= 6)) - 3;
        
        VertIndexMap = [TriOneFaces(iUsedTriOneFaces) TriTwoFaces(iUsedTriTwoFaces) iNewVerts]';
        
        iMappedIntersectingVerts = length(iUsedTriOneFaces) + length(iUsedTriTwoFaces) + 1:length(VertIndexMap);
        
        %Remove any triangle verts which were not used
        
        %OK, add the new set of faces to our list
        FaceSetOne = [VertIndexMap(UnmappedFaceSetOne(:,1)) VertIndexMap(UnmappedFaceSetOne(:,2)) VertIndexMap(UnmappedFaceSetOne(:,3))];
        FaceSetTwo = [VertIndexMap(UnmappedFaceSetTwo(:,1)) VertIndexMap(UnmappedFaceSetTwo(:,2)) VertIndexMap(UnmappedFaceSetTwo(:,3))];
                
         %Make sure none of the faces have duplicate values
%        u = unique(FaceSetOne, 'rows');
%        u2 = unique(FaceSetTwo, 'rows');
                        
        NumFacesInOne = size(FaceSetOne,1);
        NumFacesInTwo = size(FaceSetTwo,1);
        
        for(iFaceOne = NumFacesInOne:-1:1)
           Face = FaceSetOne(iFaceOne,:);
           u = unique(Face);
           if(length(u) < 3)
               FaceSetOne(iFaceOne,:) = [];
           end
           %assert(length(u) == 3);  
        end
        
        for(iFaceTwo = NumFacesInTwo:-1:1)
           Face = FaceSetTwo(iFaceTwo,:);
           u = unique(Face);
           if(length(u) < 3)
               FaceSetTwo(iFaceTwo,:) = [];
           end
           %assert(length(u) == 3); 
        end
        
        NumFacesInOne = size(FaceSetOne,1);
        NumFacesInTwo = size(FaceSetTwo,1);
                
        %Subtract two for the faces we are replacing with new ones
        NumNewFaces = size(NewFaces,1) + NumFacesInOne + NumFacesInTwo - 2;
        
        %replace j, and i Face entries, then append extra faces
        NewFaces = cat(1, NewFaces(1:i-1,:), ...
                    FaceSetOne, ...
                    NewFaces(i+1:j-1,:), ... 
                    FaceSetTwo, ...
                    NewFaces(j+1:end,:));
        
        %Update the faces we are comparing with
        TriOneFaces = NewFaces(i,:);
        TriOne = NewVerts(TriOneFaces,:);
        
        NumNewFaces = size(NewFaces,1);
                
        iNewVertOffset = size(NewVerts,1);
       
        if(Debug)
            
            %hPatch = findall(hAxes, 'type', 'patch');
            if exist('hPatch', 'var') && ~isempty(hPatch)
                try
                    delete(hPatch);
                end
                hPatch = [];   
            end
        
 %           cla;
            hAxes = gca; 

            set(gcf, 'Renderer', 'opengl'); 
            set(hAxes, 'DataAspectRatio', [1 1 1]);
            set(hAxes, 'Color', [0.5 0.5 0.5]);

            hPatch = patch('Parent', hAxes, ...
                 'Faces', NewFaces, ...
                 'Vertices', NewVerts, ...
                 'FaceVertexCData', [1 0 0], ...
                 ...%'VertexNormals', obj.Normals, ...
                 'FaceAlpha', 0.5, ...
                 'FaceColor', [.75 .4 .1], ...
                 'EdgeColor', [0 0 1], ...
                 'FaceLighting', 'phong',...
                 'AmbientStrength', .2, ...
                 'DiffuseStrength', .8,...
                 'SpecularStrength', .02, ...
                 'SpecularExponent', 15,...
                 'BackFaceLighting', 'lit');

             for(iVert = size(NewVerts,1)-sum(Match):size(NewVerts,1))
                 text(NewVerts(iVert,1)+0.001,NewVerts(iVert,2)+0.001,NewVerts(iVert,3)+0.001, ...
                      num2str(iVert), ...
                      'Color', [1 1 0], ...
                      'FontSize', 10, ...
                      'Parent', hAxes);
             end

             drawnow;
        end
        
        j = j + 1; 
    end
    
    i = i + 1; 

end

%TODO, walk the faces and eliminate any extra triangles




