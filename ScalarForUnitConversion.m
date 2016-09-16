function scalar = ScalarForUnitConversion( source_units, desired_units )
%SCALARFORUNITCONVERSION Given metric units, returns the scalar to convert

    source_unit_scalar = ScalarForUnitToMeters(source_units);
    desired_unit_scalar = ScalarForUnitToMeters(desired_units);
    
    scalar = source_unit_scalar / desired_unit_scalar;
        


end

