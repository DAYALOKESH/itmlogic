% EXAMPLE_P2P_SIMPLE.m
% Simple example demonstrating point-to-point mode of ITM
%
% This example calculates path loss between a transmitter and receiver
% over a simple terrain profile.

% Clear workspace
clear all;
close all;
clc;

% Add all necessary paths
addpath('matlab_src');
addpath('matlab_src/diffraction_attenuation');
addpath('matlab_src/los_attenuation');
addpath('matlab_src/scatter_attenuation');
addpath('matlab_src/preparatory_subroutines');
addpath('matlab_src/statistics');
addpath('matlab_src/misc');

fprintf('========================================\n');
fprintf('ITM Point-to-Point Example\n');
fprintf('========================================\n\n');

%% Define basic parameters
prop = struct();

% Frequency: 2.4 GHz
prop.fmhz = 2400;
fprintf('Frequency: %.1f MHz (%.2f GHz)\n', prop.fmhz, prop.fmhz/1000);

% Antenna heights
prop.hg = [30, 10];  % [transmitter, receiver] in meters
fprintf('Transmitter height: %.1f m\n', prop.hg(1));
fprintf('Receiver height: %.1f m\n\n', prop.hg(2));

% Polarization: vertical
prop.ipol = 1;

%% Define terrain profile
% Create a simple profile with some terrain variation
% Distance: 50 km total, 500m spacing between points
distance_km = 50;
spacing_m = 500;
num_points = floor(distance_km * 1000 / spacing_m) + 1;

% Create terrain: flat at 100m with a hill in the middle
terrain_elevation = 100 * ones(1, num_points);
hill_center = floor(num_points / 2);
hill_width = floor(num_points / 4);
for i = 1:num_points
    if abs(i - hill_center) < hill_width
        % Gaussian hill shape
        terrain_elevation(i) = 100 + 150 * exp(-((i - hill_center) / (hill_width/2))^2);
    end
end

fprintf('Terrain profile: %d points, %.1f m spacing\n', num_points, spacing_m);
fprintf('Total distance: %.1f km\n\n', distance_km);

%% Set up terrain profile array
pfl = zeros(1, num_points + 2);
pfl(1) = num_points - 1;  % Number of points minus 1
pfl(2) = spacing_m;        % Spacing in meters
pfl(3:end) = terrain_elevation;
prop.pfl = pfl;

%% Environmental parameters
prop.eps = 15;       % Terrain relative permittivity
prop.sgm = 0.005;    % Terrain conductivity (S/m)
prop.klim = 5;       % Continental temperate climate
prop.ens0 = 314;     % Surface refractivity

% Setup
zsys = 0;            % Average system elevation above sea level
prop.lvar = 5;
prop.kwx = 0;
prop.klimx = 0;
prop.mdvarx = 11;

fprintf('Environmental parameters:\n');
fprintf('  Permittivity: %.1f\n', prop.eps);
fprintf('  Conductivity: %.4f S/m\n', prop.sgm);
fprintf('  Climate: Continental temperate\n');
fprintf('  Surface refractivity: %d N-units\n\n', prop.ens0);

%% Run calculations

% Compute wave number, effective Earth curvature, etc.
[prop.wn, prop.gme, prop.ens, prop.zgnd] = qlrps(prop.fmhz, zsys, ...
    prop.ens0, prop.ipol, prop.eps, prop.sgm);

% Call preparatory subroutine for point-to-point mode
prop = qlrpfl(prop);

%% Calculate path loss for different confidence/reliability levels

% Confidence and reliability levels
qc = [10, 50, 90];  % Confidence (% of situations)
qr = [10, 50, 90];  % Reliability (% of time)

% Compute quantiles
ZR = qerfi(qr / 100);
ZC = qerfi(qc / 100);

% Calculate free space loss
FS = 32.45 + 20 * log10(prop.fmhz) + 20 * log10(prop.dist / 1000);

fprintf('========================================\n');
fprintf('RESULTS\n');
fprintf('========================================\n\n');
fprintf('Free space loss: %.2f dB\n', FS);
fprintf('Distance: %.2f km\n\n', prop.dist / 1000);

fprintf('Path Loss Results:\n');
fprintf('%-15s %-15s %-15s\n', 'Confidence %', 'Reliability %', 'Loss (dB)');
fprintf('%-15s %-15s %-15s\n', '-----------', '------------', '---------');

results = [];
for i = 1:length(qc)
    for j = 1:length(qr)
        % Compute attenuation variability
        [avar_result, prop] = avar(ZR(j), 0, ZC(i), prop);
        
        % Calculate total path loss
        total_loss = FS + avar_result;
        
        fprintf('%-15d %-15d %-15.2f\n', qc(i), qr(j), total_loss);
        
        results = [results; qc(i), qr(j), total_loss];
    end
end

%% Plot terrain profile
figure('Position', [100, 100, 1000, 400]);

subplot(2, 1, 1);
distances = (0:num_points-1) * spacing_m / 1000;
plot(distances, terrain_elevation, 'b-', 'LineWidth', 2);
hold on;
plot(0, terrain_elevation(1) + prop.hg(1), 'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(distances(end), terrain_elevation(end) + prop.hg(2), 'gs', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
xlabel('Distance (km)');
ylabel('Elevation (m)');
title('Terrain Profile');
legend('Terrain', 'Transmitter', 'Receiver');
grid on;

%% Plot path loss vs confidence for 50% reliability
subplot(2, 1, 2);
idx_50 = results(:, 2) == 50;
conf_levels = results(idx_50, 1);
losses_50 = results(idx_50, 3);
plot(conf_levels, losses_50, 'ro-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('Confidence Level (%)');
ylabel('Path Loss (dB)');
title('Path Loss vs Confidence Level (50% Reliability)');
grid on;

fprintf('\n========================================\n');
fprintf('Example complete!\n');
fprintf('========================================\n');

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
