function xmax = findSpectralPeaks(data, threshold)
% Helper function to find peaks in a given continuous valued time series x
% Usage: xmax=chron_findpeaks(data,threshold)
% Input:
%      data     (data in time x channels/trials form or a single vector)
%      threshold (if specified returns locations of peaks at which data exceeds threshold) - optional
% Output:
%      xmax     (locations of local maxima of data in a structure array of dimensions channels/trials)
if nargin < 1
    error('findSpectralPeaks:NotEnoughArguments', 'Need data'); end;
data = change_row_to_column(data);
pp1 = [data(1,:); data(1:end-1,:)];
pp2=[data(2:end,:); data(end,:)];
xmax = struct('loc',[]);

if nargin == 1
    xmax.loc = [xmax.loc; ...
        find(data - pp1 > 0 & data - pp2 > 0)];
else
    xmax.loc=[xmax.loc; ...
        find(data - pp1 > 0 & data - pp2 > 0 & data > threshold)];
end
