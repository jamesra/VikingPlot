function [ Structs, Locs, LocLinks ] = FetchData(Server, Port, Database, cellIDs )
%FetchData - Collect data from a database

    javaaddpath('.\sqljdbc4.jar'); 
    
    ConnString = ['jdbc:sqlserver://' Server ':' num2str(Port) ';database=' Database];
    disp(['Connection string: ' ConnString]); 

    conn = database(Database,...
                      'Matlab','4%w%o06', ...
                      'com.microsoft.sqlserver.jdbc.SQLServerDriver', ...
                      ConnString);

    disp(ping(conn));

    setdbprefs('DataReturnFormat','numeric');
    
    Structs = [];
    Locs = []; 
    LocLinks = []; 
    
%    setdbprefs('FetchInBatches', 'yes')
%    setdbprefs('FetchBatchSize', '10000')
    
    %Request everything if cellIDs is empty
    if(isempty(cellIDs))
        queryStructs = ['EXECUTE SelectAllStructures'];
        disp(queryStructs); 
        cursStructs = exec(conn, queryStructs); 
        cursStructs = fetch(cursStructs); 
        Structs = cursStructs.Data; 
        close(cursStructs); 
        
        queryLocs = ['EXECUTE SelectAllStructureLocations'];
        disp(queryLocs); 
        cursLocs = exec(conn, queryLocs); 

        cursLocs = fetch(cursLocs); 
        Locs = [Locs; cursLocs.Data];
        close(cursLocs); 
        
        queryLocLinks = ['EXECUTE SelectAllStructureLocationLinks'];
        disp(queryLocLinks); 
        cursLocLinks = exec(conn, queryLocLinks); 

        cursLocLinks = fetch(cursLocLinks); 
        LocLinks = [LocLinks; cursLocLinks.Data(:,1:2)];
        close(cursLocLinks); 
    else
        for(iID = 1:length(cellIDs))
            ID = cellIDs(iID);
            
            queryStructs = ['EXECUTE SelectStructure ' num2str(ID)];
            disp(queryStructs); 
            cursStructs = exec(conn, queryStructs); 
            
            cursStructs = fetch(cursStructs); 
            if(~strcmpi(cursStructs.Data, 'No Data'))
                Structs = [Structs; cursStructs.Data]; 
            end
            close(cursStructs); 
            
            queryLocs = ['EXECUTE SelectStructureLocations ' num2str(ID)];
            disp(queryLocs); 
            cursLocs = exec(conn, queryLocs); 

            cursLocs = fetch(cursLocs); 
            if(~strcmpi(cursLocs.Data, 'No Data'))
                Locs = [Locs; cursLocs.Data];
            end
            close(cursLocs); 

            queryLocLinks = ['EXECUTE SelectStructureLocationLinks ' num2str(ID)];
            disp(queryLocLinks); 
            cursLocLinks = exec(conn, queryLocLinks); 

            cursLocLinks = fetch(cursLocLinks); 
            if(~strcmpi(cursLocLinks.Data, 'No Data'))
                LocLinks = [LocLinks; cursLocLinks.Data(:,1:2)];
            end
            close(cursLocLinks); 
        end
    end
    
    close(conn); 
    
    
end

