classdef Rectangle
    %RECTANGLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X;
        Y;
    end
    
    methods
        function obj = Rectangle(MinX, MinY, MaxX, MaxY)
            %RECTANGLE Construct an instance of this class
            %   Detailed explanation goes here
            obj.X = RangeObj(MinX, MaxX);
            obj.Y = RangeObj(MinY, MaxY);
        end
        
        function result = Contains(obj,point)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            result = ~obj.X.Contains(point(0)) || ~obj.Y.Contains(point(1)) 
        end
    end
end

