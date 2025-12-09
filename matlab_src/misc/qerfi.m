function qerfi1 = qerfi(q)
% QERFI - The inverse of qerf
%
% The inverse of qerf - the solution for x to q = Q(x). The approximation
% is due to Hastings, Jr. (1995) and the maximum error should be 4.5x10^-4.
%
% Parameters:
%   q - Confidence levels for predictions (e.g. [0.01, 0.1, 0.5, 0.9, 0.99])
%
% Returns:
%   qerfi1 - Inverse of the standard normal complementary probability

    c0 = 2.515516698;
    c1 = 0.802853;
    c2 = 0.010328;
    d1 = 1.432788;
    d2 = 0.189269;
    d3 = 0.001308;
    
    x = 0.5 - q;
    
    t = max(0.5 - abs(x), 0.000001);
    
    output = zeros(size(q));
    
    for index = 1:length(t)
        interim_result = sqrt(-2 * log(t(index)));
        
        qerfi1_temp = interim_result - ...
            ((c2 * interim_result + c1) * interim_result + c0) / ...
            (((d3 * interim_result + d2) * interim_result + d1) * ...
            interim_result + 1);
        
        if x(index) < 0
            qerfi1_temp = -qerfi1_temp;
        end
        
        output(index) = round(qerfi1_temp * 10000) / 10000;
    end
    
    qerfi1 = output;
end
