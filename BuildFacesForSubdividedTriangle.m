function [ Faces ] = BuildFacesForSubdividedTriangle( VO, VA, VB, iAddedVerts, OverlappingVerts, InternalVerts)
%BuildFacesForSubdividedTriangle VO, VA, VB defines a triangle which has
%had a line drawn through the interior.  
%iAddedVerts contains a sorted list of all indicies that lie on the line
%through the triangle. The first and last entry in iAddedVerts are on the edge of the triangle.
%iOverlappingVerts are verticies on the line which intersect the feature
%(Originally another intersecting triangle) which defined the line.
%InternalVerts is an optional 1x3 logical array indicating whether VO, VA, or VB are
%known to be internal to final mesh and should be removed.
%Returns an nx3 matrix of faces

    Faces =[];
    numNewVerts = length(iAddedVerts);
    
    FirstEdge = iAddedVerts(1); 
    EndEdge = iAddedVerts(end); 
        %Try to build triangles that pass through the line if they the
        %boundary triangles are not overlapping
    if(~OverlappingVerts(FirstEdge)) % && OverlappingVerts(2))
      %  if( ~InternalVerts(VA))
            Faces = [Faces;  VO iAddedVerts(2) VA ;]; %*
            
            if(numNewVerts == 2)
               if(~(OverlappingVerts(iAddedVerts(2)) && InternalVerts(VA) && InternalVerts(VB)))
                    Faces = [Faces;  iAddedVerts(2) VB VA];
                    return; 
               end
            end
      %   else
      %       Faces = [Faces;  VA iAddedVerts(1) iAddedVerts(2);];
      %   end
    else
        if(~(InternalVerts(VO) && OverlappingVerts(iAddedVerts(1)) && OverlappingVerts(iAddedVerts(2))))
            Faces = [Faces; VO iAddedVerts(2) iAddedVerts(1) ;]; %*
        end
        
        if(numNewVerts == 2)
           if(~(InternalVerts(VA) && OverlappingVerts(iAddedVerts(1)) && OverlappingVerts(iAddedVerts(2))))
              Faces = [Faces; VA iAddedVerts(1) iAddedVerts(2) ;]; %*
              if(~(InternalVerts(VB) && OverlappingVerts(iAddedVerts(2))))
                 Faces = [Faces; VB VA  iAddedVerts(2)]; %*
              end
         
           elseif(~(InternalVerts(VB) && OverlappingVerts(iAddedVerts(1)) && OverlappingVerts(iAddedVerts(2))))
              Faces = [Faces; VB iAddedVerts(1) iAddedVerts(2);];
              
           end
           
           return; %All done
           
        elseif(numNewVerts > 2)
            if(~(InternalVerts(VA) && OverlappingVerts(iAddedVerts(1)) && OverlappingVerts(iAddedVerts(2))))
              Faces = [Faces; VA iAddedVerts(1) iAddedVerts(2);];
            end
        end
           
    end

    if(~OverlappingVerts(EndEdge)) %&& OverlappingVerts(end-1)))
     %   if(~InternalVerts(VO))
            Faces = [Faces; VO VB iAddedVerts(end-1);];
     %   else
     %       Faces = [Faces; VB iAddedVerts(end-1) iAddedVerts(end);];
     %   end
    else
        if(numNewVerts > 2)
            if(~InternalVerts(VO))
                Faces = [Faces; VO iAddedVerts(end) iAddedVerts(end-1);]; %*
            end
            
            if(~InternalVerts(VB))
                Faces = [Faces; VB iAddedVerts(end-1) iAddedVerts(end);];
            end
        end
    end

    for(iVert = 2:numNewVerts-2)
        
        if(~InternalVerts(VO) || ~(OverlappingVerts(iAddedVerts(iVert)) && OverlappingVerts(iAddedVerts(iVert+1))))
            Faces = [Faces; iAddedVerts(iVert) VO iAddedVerts(iVert+1);];
        end
    end
    
    
    iBaseSourceVert = VA;
    iOtherBaseVert = VB;

    if(InternalVerts(VA) && InternalVerts(VB))
        return;
    elseif(InternalVerts(VB))
        iBaseSourceVert = VB;
        iOtherBaseVert = VA;
        for(iVert = numNewVerts-1:-1:3)
            if ~(OverlappingVerts(iAddedVerts(iVert)) && OverlappingVerts(iAddedVerts(iVert-1)))
                Faces = [Faces; iAddedVerts(iVert) iBaseSourceVert iAddedVerts(iVert-1);];
            end
        end

    %    if(~OverlappingVerts(2))
            Faces = [Faces; 
                 iAddedVerts(2) VA VB];
    %    end
             
    elseif(InternalVerts(VA))
        for(iVert = 2:numNewVerts-2)
            if ~(OverlappingVerts(iAddedVerts(iVert)) && OverlappingVerts((iVert+1)))
                Faces = [Faces; iAddedVerts(iVert) iBaseSourceVert iAddedVerts(iVert+1);];
            end
        end
        
    %    if(~OverlappingVerts(end-1))
            Faces = [Faces; 
                 iAddedVerts(end-1) VA VB];
    %    end
    else
        for(iVert = 2:numNewVerts-2)
            Faces = [Faces; iAddedVerts(iVert) iBaseSourceVert iAddedVerts(iVert+1);];
        end
        
        if(iBaseSourceVert == VA)
            Faces = [Faces;
                 iAddedVerts(end-1) VB VA ];
        else
            Faces = [Faces;
                 iAddedVerts(2) VB VA];
        end
    end
    
    