function [ Structs, Locs, LocLinks ] = FetchLocalData(path)
%FetchData - Collect data from a database

    
    Structs = [];
    Locs = []; 
    LocLinks = []; 
    
    Struct_filename = fullfile(path,'structures.txt');
    Locations_filename = fullfile(path,'locations.txt');
    LocLink_filename = fullfile(path,'locationlinks.txt');
    
    Structs = ReadStructuresFromFile(Struct_filename);
    Locs = ReadLocationsFromFile(Locations_filename);
    LocLinks = ReadLocationLinksFromFile(LocLink_filename);
    disp('Structures');
    disp(Structs);    
    disp('Locations');
    disp(Locs);   
    disp('Location Links');
    disp(LocLinks);    
end

