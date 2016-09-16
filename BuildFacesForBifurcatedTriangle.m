function [ Faces ] = BuildFacesForBifurcatedTriangle(  VO, VA, VB, iLineVerts, OverlappingVerts, InternalVerts )
%BuildFacesForBifurcatedTriangle VO, VA, VB defines a triangle which has
%had a line drawn through the vertex at VO

%iAddedVerts contains a sorted list of all indicies that lie on the line
%through the triangle. The first and last entry in iAddedVerts are on the edge of the triangle.
%iOverlappingVerts are verticies on the line which intersect the feature
%(Originally another intersecting triangle) which defined the line.
%InternalVerts is an optional 1x3 logical array indicating whether VO, VA, or VB are
%known to be internal to final mesh and should be removed.
%Returns an nx3 matrix of faces

    %Determine which triangle verts are on the line...
   
    
    
    Faces =[];
    numLineVerts = length(iLineVerts);
    NovelLineVert = setdiff(iLineVerts, [VO VA VB]);
    numNewVerts = length(NovelLineVert);
    iEdgeVert = 1;
    iCenterVert = 2; 
    iLineOrder = [2:numLineVerts];
    if(iLineVerts(iEdgeVert) == VO)
       iEdgeVert = numLineVerts; 
       iLineOrder = [numLineVerts-1:-1:1];
       iCenterVert = numLineVerts -1 ; 
    end
    
    if(numNewVerts == 0)
        Faces = [VO VA VB]; 
        return;
    elseif(numNewVerts == 1)
        iLineVert = setdiff(iLineVerts, [VO VA VB]);
        
        if(NovelLineVert == iLineVerts(iEdgeVert))
            Faces = [VO VA iLineVert;
                     VO VB iLineVert]; 
        elseif(NovelLineVert == iLineVerts(iCenterVert))
            
            TriVerts = [VO VA VB]; 
            NonLineVerts = setdiff(TriVerts, iLineVerts);
            LineVerts = intersect(TriVerts, iLineVerts); 
    
            if(ismember(VO, LineVerts))
               VO = NonLineVerts(1); 
               ind = setdiff(TriVerts, [VO]);
               VA = ind(1);
               VB = ind(2); 
            end
                    
            Faces = [VO VA iLineVert;
                     VO VB iLineVert;
                     ]; 
        end
        


        return;
        
    end
    
    if(numLineVerts == 2)

       %We know the two new verts must be overlapping.  
       
       %If VO is one of the verts on the line.  We only have two triangles.
       %If either VA or VB is internal we should not add them
       if(~(InternalVerts(VA) && InternalVerts(VO) && OverlappingVerts(iLineVerts(iEdgeVert))))
            Faces = [Faces; VO VA iLineVerts(iEdgeVert);];
       end
       
       if(~(InternalVerts(VB) && InternalVerts(VO) && OverlappingVerts(iLineVerts(iEdgeVert))))
           Faces = [Faces; VO VB iLineVerts(iEdgeVert);];
       end
                
       %VA iLineVerts(iEdgeVert) VB];
            
       return;
    end

   if(~(OverlappingVerts(iLineVerts(iEdgeVert)) && OverlappingVerts(iLineVerts(iCenterVert))))
        %If they aren't overlapping use one triangle
        Faces = [Faces; VA VB iLineVerts(iCenterVert)];
   else
        if(~InternalVerts(VA))
            Faces = [Faces; 
                     VA iLineVerts(iCenterVert) iLineVerts(iEdgeVert)];
        end

        if(~InternalVerts(VB))
            Faces = [Faces;
                     VB iLineVerts(iCenterVert) iLineVerts(iEdgeVert);];
        end
   end
   
   for(i = 1:length(iLineOrder)-1)
       
       iLineVert = iLineOrder(i);
       iNextLineVert = iLineOrder(i+1);
       
       if(~(OverlappingVerts(iLineVerts(iLineVert)) && OverlappingVerts(iLineVerts(iNextLineVert))))
        %If they aren't overlapping always create triangles
            Faces = [Faces;
                     VA iLineVerts(iLineVert) iLineVerts(iNextLineVert);
                     VB iLineVerts(iLineVert) iLineVerts(iNextLineVert)];
       else
           %The are overlapping, check to see if triangle vertex is hidden
           if(~InternalVerts(VA))
            Faces = [Faces; 
                      VA iLineVerts(iLineVert) iLineVerts(iNextLineVert);];
           end
        

           if(~InternalVerts(VB))
                Faces = [Faces;
                         VB iLineVerts(iLineVert) iLineVerts(iNextLineVert);];
           end
           
       end
   end
   
%    
% 
%    if(iEdgeVert == 1)
%         if(~InternalVerts(VA))
%             Faces = [Faces; VA iLineVerts(2) iLineVerts(3);];
%         end
%         
%         if(~InternalVerts(VB))
%         
%                  
%                  VB iLineVerts(2) iLineVerts(3);];
%    else       
%         Faces = [Faces;
%                  VA iLineVerts(2) iLineVerts(1);
%                  VB iLineVerts(2) iLineVerts(1);];
%    end
%        
%    
%        
%        
%         
%         
%         
%     end
%    
   
   
   
    
end

