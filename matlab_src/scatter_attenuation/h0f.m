function h0f1 = h0f(r, et)
% H0F - Frequency gain function for troposcatter
%
% Routine for computing the H01 "frequency gain" function described in Eqn (6.13)
% of "The ITS Irregular Terrain Model, version 1.2.2: The Algorithm" and used in
% computing troposcatter attenuation.
%
% Parameters:
%   r - Input r parameter for Eqn (6.13)
%   et - Scattering efficiency coefficient
%
% Returns:
%   h0f1 - Frequency gain value used for computing path loss

    a = [25, 80, 177, 395, 705];
    b = [24, 45, 68, 80, 105];
    
    it = floor(et);
    
    if it <= 0
        it = 1;
        q = 0;
    elseif it >= 5
        it = 5;
        q = 0;
    else
        q = et - it;
    end
    
    x = (1 / r)^2;
    h0f1 = 4.343 * log((a(it) * x + b(it)) * x + 1);
    
    if q ~= 0
        h0f1 = (1 - q) * h0f1 + q * 4.343 * ...
            log((a(it+1) * x + b(it+1)) * x + 1);
    end
end
