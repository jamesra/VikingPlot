function [ DOM ] = CreateColladaFile( )
%CREATECOLLADAFILE Summary of this function goes here
%   Detailed explanation goes here

    DOM = com.mathworks.xml.XMLUtils.createDocument('COLLADA');
    
    DOMNode = DOM.getDocumentElement;
    DOMNode.setAttribute('version', '1.4.1');
    DOMNode.setAttribute('xmlns', 'http://www.collada.org/2005/11/COLLADASchema'); 
    
    AssetNode = DOMNode.appendChild(DOM.createElement('asset'));
%    DOMNode.appendChild(AssetNode);
    
    ContributorNode  = AssetNode.appendChild(DOM.createElement('contributor'));
 %   AssetNode.appendChild(ContributorNode);
    
    AuthoringToolNode  = ContributorNode.appendChild(DOM.createElement('authoring_tool'));
    
    AuthoringToolNode.appendChild(DOM.createTextNode('VikingPlot'));
    
    CreatedElem = AssetNode.appendChild(DOM.createElement('created'));
    CreatedElem.appendChild(DOM.createTextNode(datestr(now, 'yyyy-mm-ddTHH:MM:SSZ')));
    
    ModifiedElem = AssetNode.appendChild(DOM.createElement('modified'));
    ModifiedElem.appendChild(DOM.createTextNode(datestr(now, 'yyyy-mm-ddTHH:MM:SSZ')));
    
    UnitElem = AssetNode.appendChild(DOM.createElement('unit'));
   % UnitElem.setAttribute('meter', '0.000000001');
    unit = ScalarForUnitToMeters('m');
    UnitElem.setAttribute('meter', num2str(unit));
    UnitElem.setAttribute('name', 'um');
    
    UpAxisElem = AssetNode.appendChild(DOM.createElement('up_axis'));
    UpAxisElem.appendChild(DOM.createTextNode('Z_UP'));
    
    
%     LibCamNode = DOM.createElement('library_cameras'); 
%     LibLightsNode = DOM.createElement('library_lights');
%     LibMatsNode = DOM.createElement('library_materials');
%     LibEffects = DOM.createElement('library_effects');
%     LibGeometries = DOM.createElement('library_geometries');
    
%    InstanceVisualSceneNode = DOM.createElement('instance_visual_scene');
%    InstanceVisualSceneNode.setAttribute('url', '#VisualSceneNode');
    
%     VisSceneLibNode = DOM.createElement('library_visual_scenes'); 
%     VisSceneNode = DOM.createElement('visual_scene');
%     VisSceneNode.setAttribute('id','VisualSceneNode'); 
%     VisSceneNode.setAttribute('name','untitled'); 
%     
%     SceneNode = DOM.createElement('scene'); 
% 
%     VisSceneLibNode.appendChild( VisSceneNode); 
       
    
    %DOMNode.appendChild(LibCamNode);
    %DOMNode.appendChild(LibLightsNode); 
    %DOMNode.appendChild(LibMatsNode); 
    %DOMNode.appendChild(LibEffects); 
    %DOMNode.appendChild(LibGeometries); 
    
   % SceneNode.appendChild(InstanceVisualSceneNode); 
    
   % DOMNode.appendChild(VisSceneLibNode);
   % DOMNode.appendChild(SceneNode); 
end

