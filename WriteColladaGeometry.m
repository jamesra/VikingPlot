function [ DOM ] = WriteColladaGeometry( DOM, Name, materialID, Verts, Faces, Normals)
%WRITECOLLADAGEOMETRY Summary of this function goes here
%   Detailed explanation goes here

    DOMNode = DOM.getDocumentElement;
    
    GeoLibList = DOMNode.getElementsByTagName('library_geometries'); 
    GeoLibNode = [];
    if(isempty(GeoLibList.item(0)))
       GeoLibNode = DOM.createElement('library_geometries'); 
       DOMNode.appendChild( GeoLibNode); 
    else
       GeoLibNode = GeoLibList.item(0);
    end
    
    %Calculate our sizes
    [NumVerts,NumDims] = size(Verts); 
    NumNormals = size(Normals,1); 
    NumFaces = size(Faces,1); 
    
    assert(NumVerts == NumNormals);    
    
    %Save the names we will use
    %MaterialName = [Name '-material'];
    GeometryID = [Name '-geometry'];
    PositionsID = [Name '-geometry-positions']; 
    PositionsArrayID = [PositionsID '-array'];
    VerticiesID = [Name '-geometry-vertices'];
    
    NormalsID = [Name '-geometry-normals'];
    NormalsArrayID = [NormalsID '-array'];
        
    %Create a geometry object
    GeoNode = DOM.createElement('geometry'); 
    GeoNode.setAttribute('id', GeometryID);
    GeoNode.setAttribute('name', Name);
    
    %Create a mesh
    MeshNode = DOM.createElement('mesh');
    
    %Create an array of verticies and normals
    PosSourceNode = DOM.createElement('source'); 
    PosSourceNode.setAttribute('id', PositionsID); 
    PosSourceNode.setAttribute('name', 'vertices'); 
    
    %Add vert array
    PosArrayNode = DOM.createElement('float_array');
    PosArrayNode.setAttribute('id', PositionsArrayID);
    PosArrayNode.setAttribute('count', num2str(NumVerts * 3, '%u'));
    PosArrayNode.appendChild(DOM.createTextNode(num2str(reshape(Verts',1,[]),'%g %g %g\n')));
    
    PosSourceNode.appendChild(PosArrayNode);
    ColladaAddStandardAccessor(DOM, PosSourceNode, PositionsArrayID, NumVerts); 
    
    %Add normal array
    %Create an array of verticies and normals
    NormalSourceNode = DOM.createElement('source'); 
    NormalSourceNode.setAttribute('id', NormalsID); 
    NormalSourceNode.setAttribute('name', 'normals'); 
    
    NormalArrayNode = DOM.createElement('float_array');
    NormalArrayNode.setAttribute('id', NormalsArrayID);
    NormalArrayNode.setAttribute('count', num2str(NumNormals * 3, '%u'));
    NormalArrayNode.appendChild(DOM.createTextNode(num2str(reshape(Normals',1,[]),'%g %g %g\n')));
    
    NormalSourceNode.appendChild(NormalArrayNode);
    ColladaAddStandardAccessor(DOM, NormalSourceNode, NormalsArrayID, NumNormals);
    
    %OK, add verticies reference
    VertNode = DOM.createElement('vertices');
    VertNode.setAttribute('id', VerticiesID); 
    
    VertInputNode = DOM.createElement('input');
    VertInputNode.setAttribute('semantic', 'POSITION');
    VertInputNode.setAttribute('source', ['#' PositionsID]); 
    
    VertNode.appendChild(VertInputNode); 
    
    %Create a list of polygons
    TriNode = DOM.createElement('triangles');
    if(~isempty(materialID))
        TriNode.setAttribute('material', materialID);
    end
    TriNode.setAttribute('count', num2str(NumFaces,'%u'));
    
%     if(~isempty(MaterialName))
%         TriNode.setAttribute('material', MaterialName);
%     end
    
    TriVertNode = DOM.createElement('input');
    TriVertNode.setAttribute('offset', '0');
    TriVertNode.setAttribute('semantic', 'VERTEX');
    TriVertNode.setAttribute('source', ['#' VerticiesID]);
    
    TriNormalNode = DOM.createElement('input');
    TriNormalNode.setAttribute('offset', '0');
    TriNormalNode.setAttribute('semantic', 'NORMAL');
    TriNormalNode.setAttribute('source', ['#' NormalsID]);
    
    TriFacesNode = DOM.createElement('p'); 
    %Subtract one because COLLADA indexes from 0, not from 1 like Matlab
    %does
    TriFacesNode.appendChild(DOM.createTextNode(num2str(reshape([Faces(:,1) Faces(:,3) Faces(:,2)]', 1,[])-1, '%u %u %u\n'))); 
    
    TriNode.appendChild(TriVertNode);
    TriNode.appendChild(TriNormalNode);
    TriNode.appendChild(TriFacesNode);
    
    MeshNode.appendChild(PosSourceNode); 
    MeshNode.appendChild(NormalSourceNode); 
    MeshNode.appendChild(VertNode); 
    MeshNode.appendChild(TriNode); 
    
    GeoNode.appendChild(MeshNode); 
    
    GeoLibNode.appendChild(GeoNode);    
end

