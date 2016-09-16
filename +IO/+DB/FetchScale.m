function [ scale ] = FetchScale(Server, Port, Database)
%FetchData - Collect scale from a database.  Returns struct
% with XScale, XUnits, ..., ZUnits fields

    javaaddpath('.\sqljdbc4.jar'); 
    
    ConnString = ['jdbc:sqlserver://' Server ':' num2str(Port) ';database=' Database];
    disp(['Connection string: ' ConnString]); 

    conn = database(Database,...
                      'Matlab','4%w%o06', ...
                      'com.microsoft.sqlserver.jdbc.SQLServerDriver', ...
                      ConnString);

    disp(ping(conn));

    setdbprefs('DataReturnFormat','numeric');
       
    queryScale = ['SELECT dbo.XYScale()'];
    cursScale = exec(conn, queryScale); 
    cursScale = fetch(cursScale); 
    xyscale = cursScale.Data / 1000;
    close(cursScale); 
    
    disp(['X/Y Scale ' num2str(xyscale)]);
    
    queryScale = ['SELECT dbo.ZScale()'];
    cursScale = exec(conn, queryScale); 
    cursScale = fetch(cursScale); 
    zscale = cursScale.Data / 1000;
    close(cursScale); 
    
    disp(['Z Scale ' num2str(zscale)]);
    
    close(conn);  
    
    scale = struct('X', AxisScale(xyscale, 'um'), ...
                   'Y', AxisScale(xyscale, 'um'), ...
                   'Z', AxisScale(zscale, 'um'));
    
end

