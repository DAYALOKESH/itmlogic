function qtile1 = qtile(a, ir)
% QTILE - Returns the ith entry of vector after sorting
%
% This routine returns the ith entry of vector after sorting in
% descending order.
%
% Parameters:
%   a - Input data distribution
%   ir - Desired percentile (1-indexed)
%
% Returns:
%   qtile1 - Percentile value

    as_sorted = sort(a, 'descend');
    qtile1 = as_sorted(ir);
end
