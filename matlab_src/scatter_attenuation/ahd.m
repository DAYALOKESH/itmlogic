function ahd1 = ahd(td)
% AHD - Tropospheric scatter distance function
%
% Returns the function F0(D) (Eqn 6.9 of "The ITS Irregular Terrain Model, version 1.2.2:
% The Algorithm") used in the computation of tropospheric scatter attenuation,
% with the input D in meters.
%
% Parameters:
%   td - Distance in meters
%
% Returns:
%   ahd1 - The returned value for function F0(D)

    a = [133.4, 104.6, 71.8];
    b = [0.332e-3, 0.212e-3, 0.157e-3];
    c = [-4.343, -1.086, 2.171];
    
    if td <= 10e3
        i = 1;
    elseif td <= 70e3
        i = 2;
    else
        i = 3;
    end
    
    ahd1 = a(i) + b(i) * td + c(i) * log(td);
end
