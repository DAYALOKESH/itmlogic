function [z0, zn] = zlsq1(z, x1, x2)
% ZLSQ1 - Linear least squares fit
%
% A linear least squares fit between x1 and x2, to the function described
% by the array z.
%
% Evaluates a least squares fit to an input function z (in the form of a terrain profile
% having first element the number of profile samples, second element the spacing between
% them, and third through end elements the profile data) between horizontal locations
% x1 and x2. Returns the interpolated heights at location 0 and the end of the profile.
%
% Parameters:
%   z - Terrain profile in meters
%   x1 - Location 1
%   x2 - Location 2
%
% Returns:
%   z0 - Interpolated height
%   zn - Interpolated height

    xn = z(1);
    
    xa = floor(max(x1 / z(2), 0));
    xb = xn - floor(max(xn - x2 / z(2), 0));
    
    if xb <= xa
        xa = max(xa - 1, 0);
        xb = xn - max(xn - xb + 1, 0);
    end
    
    ja = xa;
    jb = xb;
    n = jb - ja;
    xa = xb - xa;
    x = -0.5 * xa;
    xb = xb + x;
    
    a = 0.5 * (z(ja + 3) + z(jb + 3));
    b = 0.5 * (z(ja + 3) - z(jb + 3)) * x;
    
    for i = 2:n
        ja = ja + 1;
        x = x + 1;
        a = a + z(ja + 3);
        b = b + z(ja + 3) * x;
    end
    
    if xa ~= 0
        a = a / xa;
    end
    b = b * 12 / ((xa * xa + 2) * xa);
    
    z0 = a - b * xb;
    zn = a + (b * (xn - xb));
end
