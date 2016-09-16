function [ Faces ] = FlipFaces( Normal, Verts, Faces )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    for(iFace = 1:size(Faces,1))
        iA = Faces(iFace,1);
        iB = Faces(iFace,2);
        iC = Faces(iFace,3);
        A = Verts(iA,:);
        B = Verts(iB,:);
        C = Verts(iC,:);

        N = cross(C-A,B-A);
        
        dist = dot(N, Normal);
        
        if(dist > 0)
            Faces(iFace,:) = [Faces(iFace,1) Faces(iFace,3) Faces(iFace,2)];
        end
    end
    
    return;
end

