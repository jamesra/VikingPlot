function [ IDs, url] = QueryODataIDs( endpoint, query )
%QUERYODATAIDS Runs an OData query and returns a list of IDs


    url = [endpoint '/' query];
    
    disp(['Executing OData query: ' url]);
    
    try 
        data = webread_odata(url, ODataWebOptions());
    catch ME
        IDs = [];
        switch ME.identifier
            case 'MATLAB:webservices:HTTP404StatusCodeError'
                disp('*** 404 error, query failed! ***');
            otherwise
                warning(getReport(ME));
                rethrow(ME);
            end
        
        return; 
    end
    
    if isstruct(data.value)
        if isfield(data.value, 'ID')
            IDs = horzcat(data.value.ID);
        else
            %Assume we only have one field, use that one
            names = fieldnames(data.value);
            IDs = vertcat(getfield(data.value, names(1)));
        end
    elseif isvector(data.value)
        IDs = data.value;
    end

    if size(IDs, 2) > 1
        IDs = IDs';
    end
end

