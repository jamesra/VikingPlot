function [ hFig, hAxes ] = CreateRenderingFigure(varargin)
%CREATERENDERINGFIGURE Create the figure used to render meshes
    %WindowSize - Size of window, tuple
    %Renderer   - Renderer to use, string
    %ReverseZ   - bool, if true reverse the Z-axis

    WindowSize = [0 0 1024 768];
    renderer = 'opengl';
    ZDir = 'normal';
    light_elevation = 30;
    
    optargin = size(varargin,2);
    if(optargin >= 1)
        WindowSize = varargin{1}; 
    end
    if(optargin >= 2)
        renderer = varargin{2};
    end
    if(optargin >= 3)
        ReverseZ = varargin{3};
        if(ReverseZ)
            ZDir = 'reverse';
            light_elevation = -light_elevation;
        end
    end
    
    
    
    hFig = figure('Units', 'Pixels', ...
        'OuterPosition', WindowSize, ...
        'Renderer', renderer, ...
        'Color', [0 0 0]);

    hAxes =  axes('color', [0 0 0], ...
                  'FontWeight', 'bold', ...
                  'XColor', [.5 .5 .5], ...
                  'YColor', [.5 .5 .5], ... 
                  'ZColor', [.5 .5 .5], ...
                  'Position', [0 0 1 1], ...
                  'DataAspectRatio', [1 1 1], ...
                  'ZDir', ZDir);    

    hold on; 

    
    lightangle(45,light_elevation);
    lightangle(225,light_elevation);

end

