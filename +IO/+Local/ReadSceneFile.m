function [ value ] = ReadSceneFile( filename, varargin )
%READCOLORSFILE Returns a colormap with [ID R G B A] entries mapped to an ID
    
    if ~exist(filename, 'file')
        disp(['Input scene file does not exist: ' filename]);
        return;
    end
    
    jsontext = fileread(filename);
    value = jsondecode(jsontext); 
end

