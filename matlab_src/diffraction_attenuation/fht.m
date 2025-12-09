function fht1 = fht(x, pk)
% FHT - Height gain function for diffraction attenuation
%
% Supporting function for the height gain in the "three radii method" used in the
% computation of diffractive attenuation, as described in equations (4.20) and (6.2)-(6.7)
% of "The ITS Irregular Terrain Model, version 1.2.2: The Algorithm" with inputs
% corresponding to the "x" and "K" parameters of these equations.
%
% Parameters:
%   x - x parameter specified in equations (4.20) and (6.2)-(6.7)
%   pk - k parameter specified in equations (4.20) and (6.2)-(6.7)
%
% Returns:
%   fht1 - Estimated diffractive attenuation

    if x < 200
        w = -log(pk);
        
        if pk < 1e-5 || (x * w^3) > 5495
            fht1 = -117;
            if x > 1
                fht1 = 17.372 * log(x) + fht1;
            end
        else
            fht1 = 2.5e-5 * x^2 / pk - 8.686 * w - 15;
        end
    else
        fht1 = 0.05751 * x - 4.343 * log(x);
        
        if x < 2000
            w = 0.0134 * x * exp(-0.005 * x);
            fht1 = (1 - w) * fht1 + w * (17.372 * log(x) - 117);
        end
    end
end
