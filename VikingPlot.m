function VikingPlot( varargin ) 

    disp('');
    disp('Version: 1.0.2016.09.15');
    disp('');

    dbstop if error

        %If no arguments passed, print usage
        if(nargin == 0)
           PrintUsage();
           return; 
        end

    %Walk through arguments, setting flags as needed
    CellIDs = []; %ID's of cells to render
    ShowAll = 0;  %Show all structures in database and ignore CellIDs
    SaveFrames = 0; %Spin rendering in a circle and save all the frames to disk
    HideChildren = 0; %Do not show child structures of structures in CellIDs
    HideLabels = 0; %Do not show labels on any structure
    HideChildLabels = 0; %Do not show labels on child structures
    RenderMode = 1; %How we render the scene:
                    %0 - Do not render, only write .obj files if requested
                    %1 - Use default Matlab renderer
                    %2 - Use OpenGL, faster but lighting isn't as good
    IsDebug = false; %Set to true to enable debug mode, single threading
    WindowSize = []; %Size of the client window
    RenderOrigin       = []; %Origin of the rendered volume window
    RenderDimensions   = []; %Dimensions of the render boundaries
    ObjPath = []; %The path to write .obj files to, if not specified .obj files are not written
    ColladaPath = []; %The path to write .dae files to, if not specified .dae files are not written
    Query = {};
    IDFileNames = {};
    InvertZ = 0;
    
    iNextQuery = 1;
    iNextIDFile = 1;
    
    [Server, Port, Database] = IO.Local.ReadConnection('ServerConnection.cfg');
    
    SkipNextArgument = false;
    NumThreads = 0;
    DefaultAlpha = 1;
    ChildScalar = 1.0;

    iArg = 1;
    while iArg <= nargin
       if(SkipNextArgument)
           SkipNextArgument = false; 
           iArg = iArg + 1;
           continue; 
       end
       
       StructureID = str2double(varargin(iArg));
       
       if ~isnan(StructureID)
           CellIDs = [CellIDs; StructureID];
           iArg = iArg + 1;
           continue;
       else

           if(strcmpi(varargin{iArg},'-SaveFrames') )
              SaveFrames = 1; 
           elseif(strcmpi(varargin{iArg},'-d') || strcmpi(varargin{iArg},'-Database'))
               Database = varargin{iArg+1};
               SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-v') || strcmpi(varargin{iArg},'-Volume'))
               Database = varargin{iArg+1};
               SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-s') ||strcmpi(varargin{iArg},'-Server'))
               Server = varargin{iArg+1};
               SkipNextArgument = true;
           elseif(strcmpi(varargin{iArg},'-e') ||strcmpi(varargin{iArg},'-Endpoint'))
               Server = varargin{iArg+1};
               if(~IsEndpoint(Server))
                   disp('-Endpoint parameter must begin with http.'); 
                   PrintUsage();
                   return;
               end
               SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-q') || strcmpi(varargin{iArg},'-Query'))
               while iArg+1 <= nargin && ~strncmpi(varargin{iArg+1} ,'-', 1)
                   Query{iNextQuery} = varargin{iArg+1};
                   iNextQuery = iNextQuery + 1;
                   iArg = iArg+1;
               end
           elseif(strcmpi(varargin{iArg},'-f') || strcmpi(varargin{iArg},'-IDFiles'))
               while iArg+1 <= nargin && ~strncmpi(varargin{iArg+1} ,'-', 1)
                   IDFileNames{iNextIDFile} = varargin{iArg+1};
                   iNextIDFile = iNextIDFile + 1;
                   iArg = iArg+1;
               end
           elseif(strcmpi(varargin{iArg},'-port'))
               Port = varargin{iArg+1};
               SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-Debug'))
               IsDebug = true; 
           elseif(strcmpi(varargin{iArg},'-Threads'))
               NumThreads = varargin{iArg+1}; 
               SkipNextArgument = true;
           elseif(strcmpi(varargin{iArg},'-h') || strcmpi(varargin{iArg},'-HideChildren') )
              HideChildren = 1; 
           elseif(strcmpi(varargin{iArg},'-HideLabels') )
              HideLabels = 1; 
           elseif(strcmpi(varargin{iArg},'-ShowChildLabels') )
              HideChildLabels = 1; 
           elseif(strcmpi(varargin{iArg},'-ScaleChildren') )
              ChildScalar = str2num(varargin{iArg+1}); 
              SkipNextArgument = true;  
           elseif(strcmpi(varargin{iArg},'-RenderMode') )
              RenderMode = str2num(varargin{iArg+1}); 
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-WindowSize') )
              WindowSize = varargin{iArg+1};
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-Origin') )
              RenderOrigin = varargin{iArg+1};
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-Dimension') )
              RenderDimensions = varargin{iArg+1};
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-Dims') )
              RenderDimensions = varargin{iArg+1};
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-DefaultAlpha'))
              DefaultAlpha = str2num(varargin{iArg+1});
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-ObjPath') )
              ObjPath = varargin{iArg+1}; 
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-ColladaPath') )
              ColladaPath = varargin{iArg+1}; 
              SkipNextArgument = true; 
           elseif(strcmpi(varargin{iArg},'-z'))
              InvertZ = 1;
           elseif(strcmpi(varargin{iArg}, '-All'))
              ShowAll = 1; 
              if(~isempty(CellIDs))
                  disp('Both -All and specific IDs where specified. Mutally exclusive options'); 
                  PrintUsage();
                  return;
              end 
           else
              disp(['Unknown argument: ' varargin(iArg)]);
              PrintUsage();
              return;
           end
           
           iArg = iArg + 1;
       end
    end

    %VIKINGPLOT is passed a string of numbers seperated by spaces, each number
    %is the number of a cell in the database.  Options are -save and -children
    
    %Read the ID Files
    
    if ~isempty(IDFileNames)
        
        endpoint = [];
        if IsEndpoint(Server)
            endpoint = [Server '/' Database '/OData'];
        end
        
        for iFile = 1:length(IDFileNames)
            IDsFromFiles = IO.Local.ReadIDsFromFile(IDFileNames{iFile}, endpoint);
            IDsFromFiles = sort(IDsFromFiles);
            disp(['Loaded IDs from file ' IDFileNames{iFile}]);
            disp(num2str(IDsFromFiles'));
            CellIDs = vertcat(CellIDs, IDsFromFiles);
        end
    end
     
    if(ShowAll)
        CellIDs =[]; 
        if IsEndpoint(Server)
           Query{iNextQuery} = 'Structures?$filter=TypeID eq 1&$select=ID';
           iNextQuery = iNextQuery + 1;
        end
    end 
    
    if(IsEndpoint(Server))
        
      endpoint = [Server '/' Database '/OData'];
      disp(['Querying OData server: ' endpoint]);
      if(~isempty(Query))
          for iQuery = 1:length(Query)
            [QueryResults, query_url] = QueryODataIDs(endpoint, Query{iQuery});
            QueryResults = sort(QueryResults');
            disp(['Query results for ' query_url]);
            disp(num2str(QueryResults));
            CellIDs = [CellIDs; QueryODataIDs(endpoint, Query{iQuery})];
          end
      end
      
      scale = IO.OData.FetchODataScale(endpoint);
      CellIDs = unique(CellIDs);
      
      [Structs, Locs, LocLinks] = IO.OData.FetchOData(endpoint, CellIDs, ~HideChildren);  
    else
      scale = IO.DB.FetchScale(Server, Port, Database);
      CellIDs = unique(CellIDs);
      
      [Structs, Locs, LocLinks] = IO.DB.FetchData(Server, Port, Database, CellIDs);
    end
    
    if(length(Structs) == 1)
        disp(['No structure data returned by server']);
        return 
    end
    
    if(length(Locs) == 1)
        disp(['No location data returned by server']);
        return 
    end

    if(isempty(WindowSize))
        PPlot2(Structs, Locs, LocLinks, scale, Database, ...
               'SaveFrames', SaveFrames, ...
               'HideChildren', HideChildren, ...
               'HideLabels', HideLabels, ...
               'ShowChildLabels', HideChildLabels, ...
               'RenderMode', RenderMode, ...
               'Debug', IsDebug, ...
               'ObjPath', ObjPath, ...
               'ScaleChildren', ChildScalar,...
               'DefaultAlpha', DefaultAlpha,...
               'ColladaPath', ColladaPath, ...
               'InvertZ', InvertZ); 
    else
        PPlot2(Structs, Locs, LocLinks, scale, Database, ...
               'SaveFrames', SaveFrames, ...
               'HideChildren', HideChildren, ...
               'HideLabels', HideLabels, ...
               'ShowChildLabels', HideChildLabels, ...
               'RenderMode', RenderMode, ...
               'ObjPath', ObjPath, ...
               'ScaleChildren', ChildScalar,...
               'DefaultAlpha', DefaultAlpha,...
               'Debug', IsDebug, ...
               'WindowSize', WindowSize, ...
               'ColladaPath', ColladaPath, ...
               'InvertZ', InvertZ); 
    end
end

function PrintUsage()
       disp('Usage: VikingPlot [-SaveFrames] [-HideChildren] [-RenderMode 0|1|2] [-ObjPath <path>] [-All] [ID_1 ID_2 ... ID_N]'); 
       disp('OData use:');
       disp('  -Endpoint, -e     OData service to connect to.  Must begin with "http".');
       disp('  -Volume, -v       Volume name on OData service');
       disp('  -Query, -q        Query for OData service, must return array of IDs or Structures.');
       disp('                      Multiple queries can be passed, either delimited by spaces or each');
       disp('                      proceeded by a -Query flag.');
       disp('');
       disp('Database use:');
       disp('  -Server, -s       Server to connect to');
       disp('  -Port             Port to connect to, default 1433');
       disp('  -Database, -d     Datbase name to connect to'); 
       disp('');
       disp('General options');
       disp('  ID_N              Any numbers, seperated by spaces, indicate structure IDs');
       disp('                      VikingPlot should render');
       disp('');
       disp('  -All              Render all structures in the database.');
       disp('  -ColladaPath      Export a .dae file for import into other 3D environments');
       disp('  -DefaultAlpha     The default value for how transparent objects are.');
       disp('                      All alphaoperations require the use of "-rendermode 2".');
       disp('                      1.0 is opaque, 0 is transparent');
       disp('  -Dimensions       Dimensions of the rendered volume.  If not specified Matlab');
       disp('                      sets this value.');
       disp('  -HideChildren     Show child structures of the specified IDs'); 
       disp('  -HideLabels       Do not label any structure'); 
       disp('  -IDFiles, -f      Load structure IDs from one or more text files, one ID per line.');
       disp('                    Multiple filenames can be passed, either delimited by spaces or each');
       disp('                    proceeded by a -IDFiles flag.');
       disp('  -ObjPath          Export an .obj file for import into other 3D environments.');
       disp('  -Origin           Origin of the rendered volume.  Set this to do multiple');
       disp('                      renderings with cells in the same relative positions.  If');
       disp('                      not specified Matlab sets this value.');
       disp('  -RenderMode       How should VikingPlot render the data:');
       disp('                      0: Do not render.  Used to save .obj files.');
       disp('                      1: Use default Matlab renderer.  Required if saving frames');
       disp('                      2: Use OpenGL hardware rendering for faster manipulation');
       disp('                         but poorer lighting quality.');
       disp('  -SaveFrames       Save a set of frames to create a movie spinning around');
       disp('                      the subject');      
       disp('  -ShowChildLabels  Show labels for child structures'); 
       disp('  -Threads          Number of threads to use for preparing model'); 
       disp('  -WindowSize       The size of the window in pixels to display, useful to');  
       disp('  -Z                Invert the Z coordinates.');
       disp(''); 
       return; 
end

