# itmlogic MATLAB Implementation

This directory contains a complete MATLAB implementation of the Longley-Rice Irregular Terrain Model (ITM), version 1.2.2. This is a direct conversion from the Python implementation at https://github.com/edwardoughton/itmlogic.

## Overview

The Irregular Terrain Model (ITM) is a radio propagation model developed by the Institute for Telecommunication Sciences (ITS) for frequencies between 20 MHz and 20 GHz. It predicts the median attenuation of a radio signal as a function of distance and the variability of signal in time and in space.

## Directory Structure

```
matlab_src/
├── diffraction_attenuation/
│   ├── adiff.m          - Diffraction attenuation computation
│   ├── aknfe.m          - Knife edge diffraction
│   └── fht.m            - Height gain function
├── los_attenuation/
│   └── alos.m           - Line-of-sight attenuation
├── scatter_attenuation/
│   ├── ahd.m            - Distance function for scatter
│   ├── ascat.m          - Scatter attenuation
│   └── h0f.m            - Frequency gain function
├── preparatory_subroutines/
│   ├── dlthx.m          - Interdecile range of elevations
│   ├── hzns.m           - Horizon parameters
│   ├── qlra.m           - Area mode preparation
│   ├── qlrpfl.m         - Point-to-point mode preparation
│   ├── qlrps.m          - General preparation
│   └── zlsq1.m          - Linear least squares fit
├── statistics/
│   ├── avar.m           - Attenuation quantile computation
│   └── curv.m           - Empirical curve fit
├── misc/
│   ├── qerf.m           - Normal complementary probability
│   ├── qerfi.m          - Inverse of qerf
│   └── qtile.m          - Percentile function
├── lrprop.m             - Main propagation function
└── README_MATLAB.md     - This file

matlab_scripts/
├── itmlogic_p2p.m       - Point-to-point mode example
└── itmlogic_area.m      - Area prediction mode example
```

## Quick Start

### Point-to-Point Mode Example

```matlab
% Add MATLAB source directories to path
addpath('matlab_src');
addpath('matlab_src/diffraction_attenuation');
addpath('matlab_src/los_attenuation');
addpath('matlab_src/scatter_attenuation');
addpath('matlab_src/preparatory_subroutines');
addpath('matlab_src/statistics');
addpath('matlab_src/misc');
addpath('matlab_scripts');

% Define user parameters
params = struct();
params.fmhz = 2400;      % Frequency in MHz
params.hg = [10, 30];    % Antenna heights in meters [transmitter, receiver]
params.ipol = 1;         % Polarization (0=horizontal, 1=vertical)

% Define terrain profile (elevation in meters)
% First point is transmitter location, last is receiver
surface_profile = [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100];

% Set profile spacing (meters between points)
profile_spacing = 1000;  % 1 km between points
pfl = zeros(1, length(surface_profile) + 2);
pfl(1) = length(surface_profile) - 1;
pfl(2) = profile_spacing;
pfl(3:end) = surface_profile;
params.pfl = pfl;

% Run point-to-point prediction
output = itmlogic_p2p(params, surface_profile);

% Display results
for i = 1:length(output)
    fprintf('Confidence: %d%%, Reliability: %d%%, Loss: %.2f dB\n', ...
        output{i}.confidence_level, output{i}.reliability_level, ...
        output{i}.total_loss_dB);
end
```

### Area Prediction Mode Example

```matlab
% Add paths (as above)
addpath('matlab_src');
addpath('matlab_src/diffraction_attenuation');
addpath('matlab_src/los_attenuation');
addpath('matlab_src/scatter_attenuation');
addpath('matlab_src/preparatory_subroutines');
addpath('matlab_src/statistics');
addpath('matlab_src/misc');
addpath('matlab_scripts');

% Define parameters
params = struct();
params.fmhz = 2400;      % Frequency in MHz
params.hg = [30, 10];    % Antenna heights [transmitter, receiver] in meters
params.ipol = 1;         % Vertical polarization
params.dh = 100;         % Terrain irregularity parameter (meters)

% Define distances for prediction (in km)
distances = [1, 5, 10, 20, 50, 100];

% Run area prediction
output = itmlogic_area(params, distances);

% Plot results for 50% confidence, 50% reliability
figure;
losses = zeros(length(distances), 1);
idx = 1;
for i = 1:length(output)
    if output{i}.confidence_level == 50 && output{i}.reliability_level == 50
        losses(idx) = output{i}.total_loss_dB;
        idx = idx + 1;
    end
end
plot(distances, losses, '-o', 'LineWidth', 2);
xlabel('Distance (km)');
ylabel('Path Loss (dB)');
title('ITM Path Loss Prediction');
grid on;
```

## Key Parameters

### Required Parameters

- `fmhz`: Frequency in MHz (20-20,000 MHz)
- `hg`: Antenna heights in meters [transmitter, receiver]
- `ipol`: Polarization (0=horizontal, 1=vertical)

### Environmental Parameters

- `eps`: Terrain relative permittivity (default: 15)
- `sgm`: Terrain conductivity in S/m (default: 0.005)
- `ens0`: Surface refractivity in N-units (default: 314)
- `klim`: Climate selection:
  - 1 = Equatorial
  - 2 = Continental Subtropical
  - 3 = Maritime Subtropical
  - 4 = Desert
  - 5 = Continental Temperate (default)
  - 6 = Maritime Temperate Overland
  - 7 = Maritime Temperate Oversea

### Mode-Specific Parameters

**Point-to-Point Mode:**
- `pfl`: Terrain profile array (see format below)

**Area Prediction Mode:**
- `dh`: Terrain irregularity parameter in meters

### Terrain Profile Format

The terrain profile array `pfl` has the following format:
```
pfl(1) = number of elevation points - 1
pfl(2) = distance between points in meters
pfl(3:end) = elevation points in meters
```

## Output

Both modes return a cell array of structures with the following fields:
- `distance_km`: Distance in kilometers
- `confidence_level`: Confidence level (%)
- `reliability_level`: Reliability level (%)
- `free_space_loss_dB`: Free space path loss
- `total_loss_dB`: Total path loss including terrain effects
- `additional_loss_dB`: Additional attenuation beyond free space

## Notes

1. **Coordinate System**: All heights and elevations are in meters above ground level
2. **Distance Units**: Internal calculations use meters; user interfaces typically use kilometers
3. **Array Indexing**: MATLAB uses 1-based indexing (unlike Python's 0-based)
4. **Complex Numbers**: The code properly handles complex impedance calculations
5. **Warnings**: Check `prop.kwx` for parameter validity warnings:
   - 0 = No warnings
   - 1 = Parameters nearly out of range
   - 2 = Default parameters substituted
   - 3 = Parameter combination out of range
   - 4 = Parameters out of range

## References

1. Hufford, G. A., A. G. Longley, and W. A. Kissick (1982), "A guide to the use of the ITS Irregular Terrain Model in the area prediction mode," NTIA Report 82-100.

2. Hufford, G. A. (1995), "The ITS Irregular Terrain Model, version 1.2.2, the Algorithm."

3. Oughton, E.J., Russell, T., Johnson, J., Yardim, C., Kusuma, J., 2020. "itmlogic: The Irregular Terrain Model by Longley and Rice." Journal of Open Source Software 5, 2266. https://doi.org/10.21105/joss.02266

## License

This code maintains the same licensing as the original Python implementation. The ITM software was developed by NTIA with appropriate disclaimers regarding accuracy and fitness for purpose.

## Contributors

MATLAB conversion by GitHub Copilot based on the original Python implementation by:
- Edward J. Oughton (University of Oxford)
- Tom Russell (University of Oxford)
- Joel Johnson (The Ohio State University)
- Caglar Yardim (The Ohio State University)
- Julius Kusuma (Facebook Research)
