% Area Prediction Mode Script
% This script demonstrates how to run itmlogic in area prediction mode.
% Converted from Python to MATLAB.

function output = itmlogic_area(main_user_defined_parameters, distances_km)
% ITMLOGIC_AREA - Run itmlogic in area prediction mode
%
% Parameters:
%   main_user_defined_parameters - Structure with user defined parameters
%   distances_km - Array of distances in kilometers for predictions
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
    prop.klim = 5;
    
    % Surface refractivity (N-units)
    prop.ens0 = 314;
    
    % DEFINE STATISTICAL PARAMETERS
    % Confidence levels for predictions
    qc = [50, 90, 10];
    
    % Reliability levels for predictions
    qr = [1, 10, 50, 90, 99];
    
    % Refractivity scaling
    zsys = 0;
    
    % Setup intermediate quantities
    prop.lvar = 5;
    prop.kwx = 0;
    prop.klimx = 0;
    prop.mdvarx = 11;
    
    % Compute wave number, effective Earth curvature, etc.
    [prop.wn, prop.gme, prop.ens, prop.zgnd] = qlrps(prop.fmhz, zsys, ...
        prop.ens0, prop.ipol, prop.eps, prop.sgm);
    
    % Call preparatory subroutine for area mode
    % Siting criteria: 0=random, 1=with care, 2=with great care
    kst = [1, 1];  % Both antennas sited with care
    prop = qlra(kst, prop);
    
    % Compute quantiles
    ZR = qerfi(qr / 100);
    ZC = qerfi(qc / 100);
    
    % Initialize output
    output = cell(length(distances_km) * length(qc) * length(qr), 1);
    idx = 1;
    
    % Loop through distances
    for d_idx = 1:length(distances_km)
        d_meters = distances_km(d_idx) * 1000;
        
        % Call lrprop to compute reference attenuation
        prop = lrprop(d_meters, prop);
        
        % Calculate free space loss
        FS = 32.45 + 20 * log10(prop.fmhz) + 20 * log10(distances_km(d_idx));
        
        % Loop through confidence and reliability levels
        for i = 1:length(qc)
            for j = 1:length(qr)
                % Compute attenuation
                [avar_result, prop] = avar(ZR(j), 0, ZC(i), prop);
                
                % Calculate basic transmission loss
                loss = FS + avar_result;
                
                % Store results
                result.distance_km = distances_km(d_idx);
                result.confidence_level = qc(i);
                result.reliability_level = qr(j);
                result.free_space_loss_dB = FS;
                result.total_loss_dB = loss;
                result.additional_loss_dB = avar_result;
                
                output{idx} = result;
                idx = idx + 1;
            end
        end
    end
    
    % Check for warnings
    if prop.kwx == 1
        warning('Some parameters are nearly out of range.');
    elseif prop.kwx == 2
        warning('Default parameters have been substituted for impossible ones.');
    elseif prop.kwx == 3
        warning('A combination of parameters is out of range.');
    elseif prop.kwx == 4
        warning('Some parameters are out of range.');
    end
end
