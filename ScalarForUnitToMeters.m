function scalar = ScalarForUnitConversion( source_units)
%SCALARFORUNITCONVERSION Given metric units, returns the scalar to convert
%to meters
    scalar = 1;
    if strcmpi(source_units, 'nm')
        scalar = .000000001;
    elseif strcmpi(source_units, 'um')
        scalar = .000001;
    elseif strcmpi(source_units, 'mm')
        scalar = .001;
    elseif strcmpi(source_units, 'cm')
        scalar = .01;
    elseif strcmpi(source_units, 'm')
        scalar = 1;
    elseif strcmpi(source_units, 'km')
        scalar = 1000;
    end
end

