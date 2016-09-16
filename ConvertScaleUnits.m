function scale = ConvertScaleUnits( scale, desired_units )
%CONVERTSCALEUNITS Converts a scale structure to the desired units
    
    scale.X.Value = scale.X.Value * ScalarForUnitConversion(scale.X.Units, desired_units);
    scale.Y.Value = scale.Y.Value * ScalarForUnitConversion(scale.Y.Units, desired_units);
    scale.Z.Value = scale.Z.Value * ScalarForUnitConversion(scale.Z.Units, desired_units);


end

