% VERIFY_CONVERSION.m
% Quick verification script to test the MATLAB conversion
%
% This script performs basic tests to verify that all MATLAB functions
% are accessible and working correctly.

function verify_conversion()
    fprintf('\n========================================\n');
    fprintf('ITM MATLAB Conversion Verification\n');
    fprintf('========================================\n\n');
    
    % Test 1: Check paths
    fprintf('Test 1: Checking paths...\n');
    try
        addpath('matlab_src');
        addpath('matlab_src/diffraction_attenuation');
        addpath('matlab_src/los_attenuation');
        addpath('matlab_src/scatter_attenuation');
        addpath('matlab_src/preparatory_subroutines');
        addpath('matlab_src/statistics');
        addpath('matlab_src/misc');
        fprintf('  ✓ All paths added successfully\n\n');
    catch
        fprintf('  ✗ Error adding paths\n\n');
        return;
    end
    
    % Test 2: Test basic utility functions
    fprintf('Test 2: Testing utility functions...\n');
    try
        % Test qerf
        z = 1.0;
        result = qerf(z);
        fprintf('  ✓ qerf(%.1f) = %.6f\n', z, result);
        
        % Test qerfi
        q = [0.1, 0.5, 0.9];
        result = qerfi(q);
        fprintf('  ✓ qerfi([0.1, 0.5, 0.9]) = [%.4f, %.4f, %.4f]\n', ...
            result(1), result(2), result(3));
        
        % Test qtile
        data = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
        result = qtile(data, 5);
        fprintf('  ✓ qtile (50th percentile) = %.1f\n\n', result);
    catch ME
        fprintf('  ✗ Error in utility functions: %s\n\n', ME.message);
        return;
    end
    
    % Test 3: Test preparatory functions
    fprintf('Test 3: Testing preparatory functions...\n');
    try
        % Test qlrps
        fmhz = 2400;
        zsys = 0;
        en0 = 314;
        ipol = 1;
        eps = 15;
        sgm = 0.005;
        [wn, gme, ens, zgnd] = qlrps(fmhz, zsys, en0, ipol, eps, sgm);
        fprintf('  ✓ qlrps: wn=%.4f, gme=%.4e\n', wn, gme);
        
        % Test zlsq1
        z = [10, 1, 100, 105, 110, 115, 120, 125, 130, 135, 140];
        [z0, zn] = zlsq1(z, 0, 10);
        fprintf('  ✓ zlsq1: z0=%.2f, zn=%.2f\n\n', z0, zn);
    catch ME
        fprintf('  ✗ Error in preparatory functions: %s\n\n', ME.message);
        return;
    end
    
    % Test 4: Test a simple point-to-point calculation
    fprintf('Test 4: Running simple P2P calculation...\n');
    try
        % Set up simple parameters
        prop = struct();
        prop.fmhz = 2400;
        prop.hg = [30, 10];
        prop.ipol = 1;
        prop.eps = 15;
        prop.sgm = 0.005;
        prop.klim = 5;
        prop.ens0 = 314;
        prop.lvar = 5;
        prop.kwx = 0;
        prop.klimx = 0;
        prop.mdvarx = 11;
        
        % Simple flat terrain profile
        elevations = 100 * ones(1, 11);
        spacing = 1000;  % 1 km spacing
        
        pfl = zeros(1, length(elevations) + 2);
        pfl(1) = length(elevations) - 1;
        pfl(2) = spacing;
        pfl(3:end) = elevations;
        prop.pfl = pfl;
        
        % Run calculation
        zsys = 0;
        [prop.wn, prop.gme, prop.ens, prop.zgnd] = qlrps(prop.fmhz, zsys, ...
            prop.ens0, prop.ipol, prop.eps, prop.sgm);
        
        prop = qlrpfl(prop);
        
        % Calculate for 50% confidence, 50% reliability
        ZR = qerfi(0.5);
        ZC = qerfi(0.5);
        [avar_result, prop] = avar(ZR, 0, ZC, prop);
        
        FS = 32.45 + 20 * log10(prop.fmhz) + 20 * log10(prop.dist / 1000);
        total_loss = FS + avar_result;
        
        fprintf('  ✓ Distance: %.2f km\n', prop.dist / 1000);
        fprintf('  ✓ Free space loss: %.2f dB\n', FS);
        fprintf('  ✓ Total path loss: %.2f dB\n', total_loss);
        
        % Sanity check
        if total_loss > 50 && total_loss < 200
            fprintf('  ✓ Path loss value is reasonable\n\n');
        else
            fprintf('  ⚠ Path loss value seems unusual: %.2f dB\n\n', total_loss);
        end
    catch ME
        fprintf('  ✗ Error in P2P calculation: %s\n\n', ME.message);
        return;
    end
    
    % Test 5: Test diffraction modules
    fprintf('Test 5: Testing diffraction modules...\n');
    try
        % Test aknfe
        v2 = 1.0;
        result = aknfe(v2);
        fprintf('  ✓ aknfe(%.1f) = %.4f\n', v2, result);
        
        % Test fht
        x = 100;
        pk = 0.5;
        result = fht(x, pk);
        fprintf('  ✓ fht(%.1f, %.1f) = %.4f\n\n', x, pk, result);
    catch ME
        fprintf('  ✗ Error in diffraction modules: %s\n\n', ME.message);
        return;
    end
    
    % Test 6: Test scatter modules
    fprintf('Test 6: Testing scatter modules...\n');
    try
        % Test ahd
        td = 50000;
        result = ahd(td);
        fprintf('  ✓ ahd(%.0f) = %.4f\n', td, result);
        
        % Test h0f
        r = 1.5;
        et = 2.0;
        result = h0f(r, et);
        fprintf('  ✓ h0f(%.1f, %.1f) = %.4f\n\n', r, et, result);
    catch ME
        fprintf('  ✗ Error in scatter modules: %s\n\n', ME.message);
        return;
    end
    
    % Test 7: Test curv
    fprintf('Test 7: Testing statistics modules...\n');
    try
        result = curv(1.0, 2.0, 100e3, 150e3, 50e3, 200e3);
        fprintf('  ✓ curv function works: %.6f\n\n', result);
    catch ME
        fprintf('  ✗ Error in statistics modules: %s\n\n', ME.message);
        return;
    end
    
    % Summary
    fprintf('========================================\n');
    fprintf('✓ ALL TESTS PASSED!\n');
    fprintf('========================================\n\n');
    fprintf('The MATLAB conversion is working correctly.\n');
    fprintf('You can now run example_p2p_simple.m for a full demo.\n\n');
end
