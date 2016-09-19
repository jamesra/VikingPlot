classdef MaterialManager
    %MaterialManager Keeps track of all material definitions used by .obj
    %files and then creates a master material file used by all
    
    properties
        MaterialsTable = java.util.Properties
    end
    
    methods
        
        function obj = MaterialManager()
           obj.MaterialsTable.put('White', [0 0 0 1]);
        end
        
        %Add a material to the list if it doesn't already exist
        function UpdateMaterial(obj, Name, Color)
            entry = obj.MaterialsTable.get(Name);
            if(isempty(entry))
                obj.MaterialsTable.put(Name, Color); 
            end
            
        end
        
        function CreateMaterialFile(obj, Path, FileName)
        % CreateMaterialFile - The new material file only varies in the color of
        % the verticies

            if(~isempty(Path))
               Path = [Path filesep];
            end

            TargetPath = [Path FileName];

            hFile = fopen(TargetPath,'w');
                
            enum = obj.MaterialsTable.propertyNames;
            while enum.hasMoreElements
               MaterialName = enum.nextElement;
               obj.WriteMaterial(hFile, MaterialName);
            end;

            fclose(hFile);
        end
        
        function CreateColladaMaterialFile(obj, Path, FileName)
        % CreateMaterialFile - The new material file only varies in the color of
        % the verticies
            
            if(~isempty(Path))
               Path = [Path filesep];
            end

            TargetPath = [Path FileName];

            DOM = CreateColladaFile();                 
            obj.AppendColladaMaterials(DOM);
            
            xmlwrite(TargetPath, DOM); 
        end
        
        function AppendColladaMaterials(obj, DOM)
            
            % AppendColladaMaterials - Append the materials to the collada file
            DOMNode = DOM.getDocumentElement;

            MatLibList = DOMNode.getElementsByTagName('library_materials'); 
            MatLibNode = [];
            if(isempty(MatLibList.item(0)))
               MatLibNode = DOM.createElement('library_materials'); 
               DOMNode.appendChild( MatLibNode); 
            else
                MatLibNode = MatLibList.item(0);
            end
            
            EffectLibList = DOMNode.getElementsByTagName('library_effects'); 
            EffectLibNode = [];
            if(isempty(EffectLibList.item(0)))
               EffectLibNode = DOM.createElement('library_effects'); 
               DOMNode.appendChild( EffectLibNode); 
            else
                EffectLibNode = EffectLibList.item(0);
            end

            enum = obj.MaterialsTable.propertyNames;
            while enum.hasMoreElements
               MaterialName = enum.nextElement;
               obj.WriteColladaEffect(DOM, EffectLibNode, MaterialName);
               obj.WriteColladaMaterial(DOM, MatLibNode, MaterialName); 
            end;
        end
        
    end
    
    methods (Access = protected)
        
        function WriteMaterial(obj, hFile, Name)

            %Create an entry for the named material entry
            data = obj.MaterialsTable.get(Name);
            color = data(1:3)'
            alpha = data(4);
            
            fprintf(hFile, ['newmtl ' Name '\n']);
            fprintf(hFile, '\t#Ambient Color\n');
            fprintf(hFile, '\tKa 0 0 0\n');
            fprintf(hFile, '\t#Diffuse Color\n');
            fprintf(hFile, ['\tKd ' num2str(color) '\n']);
            fprintf(hFile, '\t#Specular Color\n');
            fprintf(hFile, ['\tKs ' num2str(color) '\n']);
            fprintf(hFile, '\t#Alpha\n');
            fprintf(hFile, ['\td ' num2str(alpha) '\n']);
            fprintf(hFile, '\t#Specular Component\n');
            fprintf(hFile, '\tNs 2.0\n');
            fprintf(hFile, '\t#Illumination Model\n');
            fprintf(hFile, '\tillum 2\n');
            fprintf(hFile, '\n');
            
        end
        
        function obj = WriteColladaEffect(obj, DOM, EffectLibNode, MaterialName)
            EffectID = [MaterialName '-fx']; 
            
            EffectNode = DOM.createElement('effect');
            EffectNode.setAttribute('id', EffectID);
            
            ProfileNode = DOM.createElement('profile_COMMON');
            
            TechniqueNode = DOM.createElement('technique');
            TechniqueNode.setAttribute('sid', 'common'); 
            
%            PhongNode = obj.CreatePhongNode(DOM, MaterialName); 
            LambertNode = obj.CreateLambertNode(DOM, MaterialName); 
%            BlinnNode = obj.CreateBlinnNode(DOM, MaterialName); 
%            ConstantNode = obj.CreateConstantNode(DOM, MaterialName); 
            
            TechniqueNode.appendChild(LambertNode);
%            TechniqueNode.appendChild(PhongNode);
%             TechniqueNode.appendChild(BlinnNode);
%             TechniqueNode.appendChild(ConstantNode);
            
            ProfileNode.appendChild(TechniqueNode); 
            EffectNode.appendChild(ProfileNode); 
            EffectLibNode.appendChild(EffectNode);
        end
            
        function PhongNode = CreatePhongNode(obj, DOM, MaterialName)
            
            data = obj.MaterialsTable.get(MaterialName);
            Color = data(1:4);
             
            PhongNode = DOM.createElement('phong');
            
            EmissionNode = DOM.createElement('emission');
            AmbientNode = DOM.createElement('ambient');
            DiffuseNode = DOM.createElement('diffuse');
            SpecularNode = DOM.createElement('specular');
            ShininessNode = DOM.createElement('shininess');
            ReflectiveNode = DOM.createElement('reflective');
            ReflectivityNode = DOM.createElement('reflectivity');
            RefractionIndexNode = DOM.createElement('index_of_refraction');
            
            AddFloatElement(DOM, EmissionNode, 'color', [0 0 0 0]);
            AddFloatElement(DOM, AmbientNode, 'color', [0 0 0 0]);
            AddFloatElement(DOM, DiffuseNode, 'color', Color);
            AddFloatElement(DOM, SpecularNode, 'color', Color);
            AddFloatElement(DOM, ShininessNode, 'float', 2);
            AddFloatElement(DOM, ReflectiveNode, 'color', Color);
            AddFloatElement(DOM, ReflectivityNode, 'float', 0);
            AddFloatElement(DOM, RefractionIndexNode, 'float', 0);
                                    
            PhongNode.appendChild(EmissionNode);
            PhongNode.appendChild(AmbientNode);
            PhongNode.appendChild(DiffuseNode);
            PhongNode.appendChild(SpecularNode);
            PhongNode.appendChild(ShininessNode);
            PhongNode.appendChild(ReflectiveNode);
            PhongNode.appendChild(ReflectivityNode);
            PhongNode.appendChild(RefractionIndexNode);
        end
        
        function LambertNode = CreateLambertNode(obj, DOM, MaterialName)
            
            data = obj.MaterialsTable.get(MaterialName);
            Color = data(1:4);
             
            LambertNode = DOM.createElement('lambert');
            
           % EmissionNode = DOM.createElement('emission');
           % AmbientNode = DOM.createElement('ambient');
            DiffuseNode = DOM.createElement('diffuse');
            ReflectiveNode = DOM.createElement('reflective');
            ReflectivityNode = DOM.createElement('reflectivity');
            RefractionIndexNode = DOM.createElement('index_of_refraction');
            
          %  AddFloatElement(DOM, AmbientNode, 'color', [Color; 1]);
            AddFloatElement(DOM, DiffuseNode, 'color', Color);
            AddFloatElement(DOM, ReflectiveNode, 'color', Color);
            AddFloatElement(DOM, ReflectivityNode, 'float', 0);
            AddFloatElement(DOM, RefractionIndexNode, 'float', 0);
                                    
          %  LambertNode.appendChild(EmissionNode);
          %  LambertNode.appendChild(AmbientNode);
            LambertNode.appendChild(DiffuseNode);
            LambertNode.appendChild(ReflectiveNode);
            LambertNode.appendChild(ReflectivityNode);
            LambertNode.appendChild(RefractionIndexNode);
        end
        
        function BlinnNode = CreateBlinnNode(obj, DOM, MaterialName)
            Color = obj.MaterialsTable.get(MaterialName);
             
            BlinnNode = DOM.createElement('blinn');
            
            EmissionNode = DOM.createElement('emission');
            AmbientNode = DOM.createElement('ambient');
            DiffuseNode = DOM.createElement('diffuse');
            SpecularNode = DOM.createElement('specular');
            ShininessNode = DOM.createElement('shininess');
            ReflectiveNode = DOM.createElement('reflective');
            ReflectivityNode = DOM.createElement('reflectivity');
            RefractionIndexNode = DOM.createElement('index_of_refraction');
            
            AddFloatElement(DOM, EmissionNode, 'color', [0 0 0 0]);
            AddFloatElement(DOM, AmbientNode, 'color', [0 0 0 0]);
            AddFloatElement(DOM, DiffuseNode, 'color', Color);
            AddFloatElement(DOM, SpecularNode, 'color', Color);
            AddFloatElement(DOM, ShininessNode, 'float', 2);
            AddFloatElement(DOM, ReflectiveNode, 'color', Color);
            AddFloatElement(DOM, ReflectivityNode, 'float', 0);
            AddFloatElement(DOM, RefractionIndexNode, 'float', 0);
                                    
            BlinnNode.appendChild(EmissionNode);
            BlinnNode.appendChild(AmbientNode);
            BlinnNode.appendChild(DiffuseNode);
            BlinnNode.appendChild(SpecularNode);
            BlinnNode.appendChild(ShininessNode);
            BlinnNode.appendChild(ReflectiveNode);
            BlinnNode.appendChild(ReflectivityNode);
            BlinnNode.appendChild(RefractionIndexNode);
        end
        
         function ConstantNode = CreateConstantNode(obj, DOM, MaterialName)
            Color = obj.MaterialsTable.get(MaterialName);
             
            ConstantNode = DOM.createElement('constant');
            
            EmissionNode = DOM.createElement('emission');
            ReflectiveNode = DOM.createElement('reflective');
            ReflectivityNode = DOM.createElement('reflectivity');
            RefractionIndexNode = DOM.createElement('index_of_refraction');
            
            AddFloatElement(DOM, EmissionNode, 'color', [0 0 0 0]);
            AddFloatElement(DOM, ReflectiveNode, 'color', Color);
            AddFloatElement(DOM, ReflectivityNode, 'float', 0);
            AddFloatElement(DOM, RefractionIndexNode, 'float', 0);
                                    
            ConstantNode.appendChild(EmissionNode);
            ConstantNode.appendChild(ReflectiveNode);
            ConstantNode.appendChild(ReflectivityNode);
            ConstantNode.appendChild(RefractionIndexNode);
        end
        
        function obj = WriteColladaMaterial(obj, DOM, MatLibNode, MaterialName)
            MaterialNode = DOM.createElement('material'); 
            MaterialNode.setAttribute('id', MaterialName);
            MaterialNode.setAttribute('name', MaterialName);
            
            InstanceEffectNode = DOM.createElement('instance_effect');
            InstanceEffectNode.setAttribute('url', ['#' MaterialName '-fx']); 
            
            MaterialNode.appendChild(InstanceEffectNode); 
            MatLibNode.appendChild(MaterialNode);            
        end
        
    end
    
end

