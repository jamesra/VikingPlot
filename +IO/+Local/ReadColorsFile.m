function [ colormap ] = ReadColorsFile( filename, varargin )
%READCOLORSFILE Returns a colormap with [ID R G B A] entries mapped to an ID
    
    optargin = size(varargin,2);
    
    %Parse the optional arguments
    DefaultAlpha = 1;
    if optargin > 0
        DefaultAlpha = varargin{1};
    end
        
    colormap = [];
    if(exist('StructureTypeColors.txt', 'file'))
        disp(['Parsing color definitions from ' filename]);
        try
           %TempColors = importdata('StructureTypeColors.txt'); 
           %file  = fopen(filename)
           %TempColors = textscan(file, '%d %f %f %f %f\n', 'EmptyValue', 1, 'commentstyle', '%',  'delimiter', '\n')
           %fclose(file)
           data = textread(filename, '%s', 'delimiter', '\n', 'whitespace', '');
           for iLine = 1:length(data)
               if isempty(data{iLine})
                   continue
               end
               try
                   Line = data{iLine};
                   TempColors = textscan(Line, '%d %f %f %f %f%*[^\n]', 'EmptyValue', DefaultAlpha, 'commentstyle', '%');
                   
                   %Skip the line if we did not get enough data
                   if isempty(TempColors{4})
                       continue;
                   end
                  
                   if isempty(TempColors{5})
                       TempColors{5} = DefaultAlpha;
                   end
                   
                   if isempty(colormap)
                       colormap = [double(TempColors{1}) TempColors{2} TempColors{3} TempColors{4} TempColors{5}];
                   else
                       colormap = [colormap; double(TempColors{1}) TempColors{2} TempColors{3} TempColors{4} TempColors{5}];
                   end
               catch ME
                  disp(['Cannot parse Line #' num2str(iLine)]); 
                  disp(data{iLine}); 
               end
           end
        catch ME
            disp(['Exception caught reading ' filename]); 
            disp(ME.identifier);
            disp(ME.message);
            TempColors = [];
        end   
    else
        disp([filename ' not found']);
    end

    
end

