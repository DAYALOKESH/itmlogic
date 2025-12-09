function [wn, gme, ens, zgnd] = qlrps(fmhz, zsys, en0, ipol, eps, sgm)
% QLRPS - General preparatory subroutine
%
% General preparatory subroutine as in Section 41 by Hufford (see references/itm.pdf).
%
% Parameters:
%   fmhz - Carrier frequency
%   zsys - General system elevation
%   en0 - Surface refractivity reduced to sea level
%   ipol - Polarization
%   eps - Ground constants
%   sgm - Ground constants
%
% Returns:
%   wn - Wave number
%   gme - Effective earth curvature
%   ens - Surface refractivity
%   zgnd - Surface impedance

    gma = 157e-9;
    wn = fmhz / 47.7;
    ens = en0;
    
    if zsys ~= 0
        ens = ens * exp(-zsys / 9460);
    end
    
    gme = gma * (1 - 0.04665 * exp(ens / 179.3));
    
    zq = complex(eps, 376.62 * sgm / wn);
    
    zgnd = sqrt(zq - 1);
    
    if ipol ~= 0
        zgnd = zgnd / zq;
    end
end
