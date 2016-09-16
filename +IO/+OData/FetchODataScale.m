function [ scale ] = FetchODataScale(endpoint)
%FetchData - Collect scale from a database.  Returns struct
% with XScale, XUnits, ..., ZUnits fields

    options = ODataWebOptions();
    
    endpoint = [endpoint '/Scale'];
    
    scale = webread(endpoint, options);
end



