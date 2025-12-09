function [the, dl] = hzns(pfl, dist, hg, gme)
% HZNS - Find horizon parameters
%
% Subroutine to find horizon parameters as described in Section 48 by Hufford
% (see references/itm.pdf).
%
% Parameters:
%   pfl - Terrain profile in meters
%   dist - Distance in meters
%   hg - Heights of transmitter and receiver off ground (meters) [2 elements]
%   gme - Effective earth curvature
%
% Returns:
%   the - Horizon take-off angle [2 elements]
%   dl - Horizon distances [2 elements]

    np = pfl(1);
    xi = pfl(2);
    za = pfl(3) + hg(1);
    zb = pfl(np + 3) + hg(2);
    qc = 0.5 * gme;
    q = qc * dist;
    the(2) = (zb - za) / dist;
    the(1) = the(2) - q;
    the(2) = -the(2) - q;
    dl(1) = dist;
    dl(2) = dist;
    
    if np >= 2
        sa = 0;
        sb = dist;
        wq = 1;
        
        for i = 2:np
            sa = sa + xi;
            sb = sb - xi;
            
            q = pfl(i+2) - (qc * sa + the(1)) * sa - za;
            
            if q > 0
                the(1) = the(1) + q / sa;
                dl(1) = sa;
                wq = 0;
            end
            
            if wq == 0
                q = pfl(i + 2) - (qc * sb + the(2)) * sb - zb;
                if q > 0
                    the(2) = the(2) + q / sb;
                    dl(2) = sb;
                end
            end
        end
    end
end
