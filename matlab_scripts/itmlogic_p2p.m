% Point to Point (P2P) Prediction Mode Script
% Referred to as qkpfl in the original Fortran codebase
%
% This script demonstrates how to run itmlogic in point-to-point mode.
% Converted from Python to MATLAB.

function output = itmlogic_p2p(main_user_defined_parameters, surface_profile_m)
% ITMLOGIC_P2P - Run itmlogic in point to point (p2p) prediction mode
%
% Parameters:
%   main_user_defined_parameters - Structure with user defined parameters
%   surface_profile_m - Array containing surface profile measurements in meters
%
% Returns:
%   output - Cell array of structures containing model output results

    prop = main_user_defined_parameters;
    
    % DEFINE ENVIRONMENTAL PARAMETERS
    % Terrain relative permittivity
    prop.eps = 15;
    
    % Terrain conductivity (S/m)
    prop.sgm = 0.005;
    
    % Climate selection (1=equatorial, 2=continental subtropical, 
    % 3=maritime subtropical, 4=desert, 5=continental temperate,
    % 6=maritime temperate overland, 7=maritime temperate oversea)
    % Default is 5
    prop.klim = 5;
    
    % Surface refractivity (N-units): also controls effective Earth radius
    prop.ens0 = 314;
    
    % DEFINE STATISTICAL PARAMETERS
    % Confidence levels for predictions
    qc = [50, 90, 10];
    
    % Reliability levels for predictions
    qr = [1, 10, 50, 90, 99];
    
    % Number of points describing profile
    pfl = zeros(1, length(surface_profile_m) + 2);
    pfl(1) = length(surface_profile_m) - 1;
    pfl(2) = 0;  % Will be set based on profile spacing
    
    for i = 1:length(surface_profile_m)
        pfl(i+2) = surface_profile_m(i);
    end
    
    % Refractivity scaling ens=ens0*exp(-zsys/9460.)
    % (Average system elev above sea level)
    zsys = 0;
    
    % Setup some intermediate quantities
    % Initial values for AVAR control parameter
    % LVAR: 0=quantile change, 1=dist change, 2=HE change, 
    %       3=WN change, 4=MDVAR change, 5=KLIM change
    prop.lvar = 5;
    
    % Zero out error flag
    prop.kwx = 0;
    
    % Default climate/variability parameters
    prop.klimx = 0;
    prop.mdvarx = 11;
    
    % Assign terrain profile to prop structure
    prop.pfl = pfl;
    
    % Compute wave number, effective Earth curvature, surface refractivity,
    % and surface impedance
    [prop.wn, prop.gme, prop.ens, prop.zgnd] = qlrps(prop.fmhz, zsys, ...
        prop.ens0, prop.ipol, prop.eps, prop.sgm);
    
    % Call preparatory subroutine for point-to-point mode
    prop = qlrpfl(prop);
    
    % Compute quantiles using standard normal deviates
    ZR = qerfi(qr / 100);
    ZC = qerfi(qc / 100);
    
    % Calculate free space loss
    FS = 32.45 + 20 * log10(prop.fmhz) + 20 * log10(prop.dist / 1000);
    
    % Initialize output cell array
    output = cell(length(qc) * length(qr), 1);
    idx = 1;
    
    % Loop through confidence and reliability levels
    for i = 1:length(qc)
        for j = 1:length(qr)
            % Compute attenuation
            [avar_result, prop] = avar(ZR(j), 0, ZC(i), prop);
            
            % Calculate basic transmission loss
            loss = FS + avar_result;
            
            % Store results
            result.confidence_level = qc(i);
            result.reliability_level = qr(j);
            result.distance_km = prop.dist / 1000;
            result.free_space_loss_dB = FS;
            result.total_loss_dB = loss;
            result.additional_loss_dB = avar_result;
            
            output{idx} = result;
            idx = idx + 1;
        end
    end
    
    % Check for warnings
    if prop.kwx == 1
        warning('Some parameters are nearly out of range. Results should be used with caution.');
    elseif prop.kwx == 2
        warning('Default parameters have been substituted for impossible ones.');
    elseif prop.kwx == 3
        warning('A combination of parameters is out of range. Results are probably invalid.');
    elseif prop.kwx == 4
        warning('Some parameters are out of range. Results are probably invalid.');
    end
end
