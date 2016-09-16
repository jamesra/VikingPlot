function [ MappedVerts, MappedFaces] = RemoveUnusedVerts( Verts, Faces )
%REMOVEUNUSEDVERTS Given a list of verticies and faces, returns a list
%of verts with unused verticies removed and face indicies adjusted

    UsedVerts = unique(Faces);  %Returns sorted list
    UnusedVerts = setdiff(1:size(Verts,1), UsedVerts);

    %Yank the unused verticies
    MappedVerts = Verts(UsedVerts,:);
    MappedFaces = Faces;

    for(iVert = UnusedVerts)
        iAdjustedFaces = Faces > iVert;
        MappedFaces(iAdjustedFaces) = MappedFaces(iAdjustedFaces) - 1;
    end

end

