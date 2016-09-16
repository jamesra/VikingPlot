classdef StructureManager
    %STRUCTUREMANAGER Summary of this class goes here
    %   Detailed explanation goes here
     
    properties
        IDToObjTable
    end
    
    methods
        
        function obj = StructureManager(size)
            obj.IDToObjTable = containers.Map('KeyType', 'int64', 'ValueType', 'any');
        end
        
        %Add a material to the list if it doesn't already exist
        function obj = put(obj, ID, data)
            ID = int64(ID);
            m = obj.IDToObjTable;
            m(ID) = data; 
        end
        
        function val = get(obj, ID)
%            if ~obj.IDToObjTable.containsKey(ID)
%                error('ID not in dictionary')
%            end
            ID = int64(ID);
            m = obj.IDToObjTable;
            if isKey(m, ID)
               val = m(ID); 
            else
               val = [];
            end
        end
        
        function obj = remove(obj,ID)
%            if ~obj.IDToObjTable.containsKey(ID)
%                error('ID not in dictionary')
%            end
            ID = int64(ID);
            m = obj.IDToObjTable;
            remove(m, ID);
        end
        
        function cells = toCellArray(obj)
            m = obj.IDToObjTable;
            cells =  values(m);
        end
         
    end
    
end

