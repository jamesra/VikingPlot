function [DOM, ParentNode, Node] = AddColladaNode( DOM, ...
                                                   ParentNode, ...
                                                   StructID,  ...
                                                   GeometryTarget, ...
                                                   MaterialSymbol,  ...
                                                   MaterialTarget, ...
                                                   WorldPosition, ...
                                                   Translate,  ...
                                                   Scale)
%ADDCOLLADANODE Summary of this function goes here
%   Detailed explanation goes here

%     if(isempty(GeometryURL))
%        GeometryURL =  ['#' Name '-geometry']; 
%     end
%     
%     if(isempty(MaterialURL))
%         MaterialURL = ['#' MaterialName]; 
%     end

    WorldNode = []; 
    Node = DOM.createElement('node');
    Node.setAttribute('id', ['NodeID-' StructID]);
    Node.setAttribute('name',['NodeID-' StructID]);
    
    if(~isempty(Translate))
        TranslateNode = DOM.createElement('translate');
        TranslateNode.setAttribute('sid', 'translate');
        TranslateNode.appendChild(DOM.createTextNode(num2str(Translate, '%g '))); 
        Node.appendChild(TranslateNode); 
    end
    
    if(~isempty(Scale))
        ScaleNode = DOM.createElement('scale');
        ScaleNode.setAttribute('sid', 'scale');
        ScaleNode.appendChild(DOM.createTextNode(num2str(Scale, '%g '))); 
        Node.appendChild(ScaleNode); 
    end
    
    if(~isempty(WorldPosition))
       WorldNode = DOM.createElement('extra'); 
       %WorldNode.setAttribute('id', 'world_position']);
       WorldNode.setAttribute('name', 'world_position');
       WorldNode.setAttribute('type', 'float3'); 
       WorldNode.appendChild(DOM.createTextNode(num2str(WorldPosition, '%g ')));
    end
    
    InstanceGeometryNode = DOM.createElement('instance_geometry');
    InstanceGeometryNode.setAttribute('url', GeometryTarget);
    
    BindMaterialNode = DOM.createElement('bind_material'); 
    
    TechniqueCommonNode = DOM.createElement('technique_common'); 
    InstanceMaterialNode = DOM.createElement('instance_material'); 
    
    InstanceMaterialNode.setAttribute('symbol', MaterialSymbol);
    InstanceMaterialNode.setAttribute('target', MaterialTarget); 
    
    TechniqueCommonNode.appendChild(InstanceMaterialNode);
    BindMaterialNode.appendChild(TechniqueCommonNode);
    InstanceGeometryNode.appendChild(BindMaterialNode);
    
    Node.appendChild(InstanceGeometryNode);
    if(~isempty(WorldNode))
        %      Node.appendChild(WorldNode);
    end
    
    ParentNode.appendChild(Node);
end

