classdef ImageColorMap
    %ImageColorMap Reads a set of images from a text file.  Uses these
    %images to map points to a color
    
    properties
        Images = {};
        
        Scalars = []; 
        Offsets = []; 
        Sections = []; 
        Color = [];
    end
    
    properties (Constant = true)
          
    end
    
    methods
       
        function Obj = ImageColorMap(CMapFileName)
            %If CMapFileName has a relative path before the filename we use
            %the same path to open image files
            [rel_path, FileName, ~] = fileparts(CMapFileName);
            
            if ~exist(CMapFileName, 'file')
                disp(['Image color maps not found at ' CMapFileName]);
                numRows = 0;
                Obj.Sections = zeros(numRows,1); 
                Obj.Scalars = zeros(numRows, 2);
                Obj.Offsets = zeros(numRows, 2);
                Obj.Images = cell(numRows,1); 
                return;
            end
            
            Data = importdata(CMapFileName);
            
            numRows = length(Data) - 1; %-1 for header row
            
            Obj.Sections = zeros(numRows,1); 
            Obj.Scalars = zeros(numRows, 2);
            Obj.Offsets = zeros(numRows, 2);
            Obj.Images = cell(numRows,1); 
            
            %Offsets used to read file
            iSection = 1;
            iXOffset = 2; 
            iYOffset = 3;
            iXScale = 4;
            iYScale = 5;
            iRed = 6;
            iGreen = 7;
            iBlue = 8; 
            iFilename = 9; 
            
            iNextImage = 1;
            
            for(iLine = 2:length(Data))
                C = textscan(Data{iLine}, '%d%f%f%f%f%f%f%f%s'); 
            
                XOffset = C{iXOffset};
                YOffset = C{iYOffset};
                XScale = C{iXScale};
                YScale = C{iYScale}; 
                filename = fullfile(rel_path, C{iFilename}); 
                
                %Colors are optional, if they aren't present assume [1 1 1]
                inputColor = [];
                if(isempty(C{iBlue}))
                    inputColor = [1 1 1];
                else
                    inputColor = [C{iRed} C{iGreen} C{iBlue}]; 
                end
                
                XScale = 1/XScale; 
                YScale = 1/YScale; 
                
                Obj.Sections(iLine-1, :) = C{iSection}; 
                Obj.Offsets(iLine-1, :) = [XOffset YOffset]; 
                Obj.Scalars(iLine-1, :) = [YScale XScale];
                Obj.Color(iLine-1, :) = inputColor; 
                disp(['Loading image color map: ' filename{1}]);
                if exist(filename{1}, 'file')
                    I = imread(filename{1});
                    I = single(I) ./ 255.0; %We just assume uint8
                    Obj.Images{iNextImage} = I;
                    iNextImage = iNextImage + 1;
                else
                    disp('  Could not read image!');
                end
            end
        
        end
        
        %Returns a tuple for the color that matches the coordinates.
        %Otherwise and empty array if the point can't be mapped
        %X Y Z can be a vector of multiple coordinates.  In this case
        %We blend all intersecting color maps
        function [C] = GetColor(Obj, X,Y,Z,Radius)
            C = []; 
            %Figure out which sections are overlapping
            [MatchingSections, iSections, iZ] = intersect(Obj.Sections,Z); 
            if(isempty(iSections))
                return;
            end
            
            Offset = Obj.Offsets(iSections,:); 
            Scalar = Obj.Scalars(iSections,:); 
            ChannelContrib = Obj.Color(iSections,:); 
            Radius = Radius .* max(Scalar,[],2); 
            
            P = [Y X]; 
            P = P .* Scalar; 
            P = P + Offset; 
            P = round(P); 
            P = int32(P); 
            
            Colors = zeros(length(iSections),3);
            for(i = 1:length(iSections))
                I = Obj.Images{iSections(i)};
                [YDim, XDim] = size(I);
                if(max(P(i,1) <= 0 || P(i,1) > YDim) > 0)
                    try
                        disp(['Color mapping out of bounds: ' num2str([X Y Z]) ' -> ' num2str(P)]);
                    catch e
                        
                    end
                    
                    
                    continue;
                end

                if(max(P(i,2) <= 0 || P(i,2) > XDim) > 0)
                    
                    try
                        disp(['Color mapping out of bounds: ' num2str([X Y Z]) ' -> ' num2str(P)]);
                    catch e
                        
                    end
                        
                    
                    continue;
                end
                
                
                
                W = Window(I, P(i,2), P(i,1), Radius(i) * sin(pi/4)); 
                
 %               C = squeeze(C)'; 
                C = mean(W);
                C = C .* Obj.Color(iSections(i),:); %Adjust color for this sections' map
                Colors(i,:) = C; 
            end
            
            %OK, average the colors together
            Colors(isnan(Colors)) = [];
            if(isempty(Colors))
                Colors = [0.5 0.5 0.5];
            elseif(sum(sum(Colors)) == 0)
                Colors = [0.5 0.5 0.5];
            end
            
            ColorSum = sum(Colors,1);
            ChannelDivisors = sum(ChannelContrib,1);
            
            for(iChannel = 1:3)
                if(ChannelDivisors(iChannel) < 1)
                    ChannelDivisors(iChannel) = 1; 
                end
            end
            
            C = ColorSum ./ ChannelDivisors; 
            
            if(max(C) > 1)
                disp(['Bad color ' num2str(C)]);
            end
            
            if(min(C) < 0)
                disp(['Bad color ' num2str(C)]);
            end
        end
        
    end
    
end

