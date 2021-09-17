classdef RangeObj
    properties
        MinVal = NaN
        MaxVal = NaN
        
    end
    
    properties (SetAccess = protected )
        Length;
    end
    
    methods
        function obj = RangeObj(min_val, max_val)
            obj.MinVal = min_val;
            obj.MaxVal = max_val;
        end
        
        function result = Contains(value)
            result = value < obj.MinVal || value > obj.MaxVal;
        end
        
        function length = get.Length(obj)
            length = obj.MaxVal - obj.MinVal;
            if(length < 0)
                length = 0;
            end
        end
    end
end
        