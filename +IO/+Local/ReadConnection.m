function [ server, port, database ] = ReadConnection( filepath )
%READCONNECTION Read default connection settings from a file
% File should contain three lines
% SERVER
% 

    server = [];
    database = 'rabbit';
    port = 1433;
    
    try        
        fid = fopen(filepath);

        server = fgetl(fid);
        database = fgetl(fid);
        
        if IsEndpoint(server)
            port = [];
        else
            port = str2num(fgetl(fid));
        end
        
        fclose(fid);
    catch err
        
        disp(['Unable to read or parse server connection file' filepath]);
        disp(['    Error: ' err.identifier]);
        disp(['Expecting three line file:']);
        disp(['    First line is server/endpoing name.  Endpoints start with "http", anything else is considered a database server']);
        disp(['    Second line is database/volume name']);
        disp(['    Third line is port number, usually 1433']);
    end

end

