function [ Node ] = ColladaAddStandardAccessor( DOM, Node, ArrayName, Count)
%COLLADAADDSTANDARDACCESSOR( DOM, Node, ArrayName, Count)
%Create a standard accessor for verticies and normals, i.e:
%<technique_common>
%   <accessor count="8" offset="0" source="#box-lib-positions-array" stride="3">
%       <param name="X" type="float"/>
%       <param name="Y" type="float"/>
%       <param name="Z" type="float"/>
%   </accessor>
%</technique_common>

    Stride = 3; 

    techniqueNode = DOM.createElement('technique_common');
    accessorNode = DOM.createElement('accessor'); 
    accessorNode.setAttribute('count', num2str(Count,'%u')); 
    accessorNode.setAttribute('offset', '0');
    accessorNode.setAttribute('stride', num2str(Stride,'%u'));
    accessorNode.setAttribute('source', ['#' ArrayName]);
    
    %Add params
    XNode = DOM.createElement('param');
    XNode.setAttribute('name', 'X');
    XNode.setAttribute('type', 'float');
    
    YNode = DOM.createElement('param');
    YNode.setAttribute('name', 'Y');
    YNode.setAttribute('type', 'float');
    
    ZNode = DOM.createElement('param');
    ZNode.setAttribute('name', 'Z');
    ZNode.setAttribute('type', 'float');
    
    accessorNode.appendChild(XNode);
    accessorNode.appendChild(YNode);
    accessorNode.appendChild(ZNode);
    techniqueNode.appendChild(accessorNode); 
    Node.appendChild(techniqueNode);
end

