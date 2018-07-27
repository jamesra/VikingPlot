function [ DOM ] = AddToColladaVisualScene( DOM, Name, MaterialName, Translation )
%ADDTOCOLLADAVISUALSCENE Summary of this function goes here
%   Detailed explanation goes here

    DOMNode = DOM.getDocumentElement;
    
    VisLibList = DOMNode.getElementsByTagName('library_visual_scenes'); 
    if(isempty(VisLibList.item(0)))
       VisSceneLibNode = DOM.createElement('library_visual_scenes'); 
              
       VisSceneNode = DOM.createElement('visual_scene');
       VisSceneNode.setAttribute('id','VisualSceneNode'); 
       VisSceneNode.setAttribute('name','untitled'); 
       
       VisSceneLibNode.appendChild( VisSceneNode); 
       DOMNode.appendChild( VisSceneLibNode); 
 %      xmlwrite('debugcreate.xml', DOM); 
    else
%       xmlwrite('debug.xml', DOM); 
       VisSceneLibNode = VisLibList.item(0);
       if(isempty(VisLibList.item(0).getFirstChild))
           VisSceneNode = DOM.createElement('visual_scene');
           VisSceneNode.setAttribute('id','VisualSceneNode'); 
           VisSceneNode.setAttribute('name','untitled'); 
           
           VisSceneLibNode.appendChild( VisSceneNode); 
       else
           VisSceneNode = VisLibList.item(0).getFirstChild;
       end
    end
    
    Node = DOM.createElement('node');
    Node.setAttribute('id',Name);
    Node.setAttribute('name',Name);
    
    TranslateNode = DOM.createElement('translate');
    TranslateNode.setAttribute('sid', 'translate');
    TranslateNode.appendChild(DOM.createTextElement(num2str(Translation, '%g '))); 
    
    InstanceGeometryNode = DOM.createElement('instance_geometry');
    InstanceGeometryNode.setAttribute('url', ['#' Name '-geometry']);
    
    BindMaterialNode = DOM.createElement('bind_material'); 
    
    TechniqueCommonNode = DOM.createElement('technique_common'); 
    InstanceMaterialNode = DOM.createElement('instance_material'); 
    
    InstanceMaterialNode.setAttribute('symbol', [MaterialName 'SG']);
    InstanceMaterialNode.setAttribute('target', ['#' MaterialName]); 
    
    TechniqueCommonNode.appendChild(InstanceMaterialNode); 
    BindMaterialNode.appendChild(TechniqueCommonNode); 
    InstanceGeometryNode.appendChild(BindMaterialNode); 
    Node.appendChild(InstanceGeometryNode); 
    VisSceneNode.appendChild(Node); 
end

