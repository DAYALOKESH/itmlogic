function dlthx1 = dlthx(pfl1, x1, x2)
% DLTHX - Interdecile range of elevations
%
% Use the terrain profile pfl1 to find delta h, interdecile range of elevations between
% point x1 and point x2, as described in Section 48 by Hufford (see references/itm.pdf).
%
% Parameters:
%   pfl1 - Terrain profile
%   x1 - Point 1
%   x2 - Point 2
%
% Returns:
%   dlthx1 - Interdecile range of elevations

    np = pfl1(1);
    xa = x1 / pfl1(2);
    xb = x2 / pfl1(2);
    dlthx1 = 0;
    
    if (xb - xa) >= 2
        ka = floor(0.1 * (xb - xa + 8));
        ka = min(max(4, ka), 25);
        n = 10 * ka - 5;
        kb = n - ka + 1;
        sn = n - 1;
        
        s = zeros(n+2, 1);
        s(1) = sn;
        s(2) = 1;
        
        xb = (xb - xa) / sn;
        k = floor(xa + 1);
        xa = xa - k;
        
        for j = 1:n
            while xa > 0 && k < np
                xa = xa - 1;
                k = k + 1;
            end
            
            if k+3 <= length(pfl1)
                s(j+2) = pfl1(k+3) + (pfl1(k+3) - pfl1(k + 2)) * xa;
            else
                s(j+2) = pfl1(end) + (pfl1(end) - pfl1(end-1)) * xa;
            end
            
            xa = xa + xb;
        end
        
        [xa, xb] = zlsq1(s, 0, sn);
        
        xb = (xb - xa) / sn;
        
        for j = 0:n-1
            s(j+3) = s(j + 3) - xa;
            xa = xa + xb;
        end
        
        dlthx1 = qtile(s(3:end), ka) - qtile(s(3:end), kb);
        
        dlthx1 = dlthx1 / (1 - 0.8 * exp(-(x2 - x1) / 50e3));
    end
end
