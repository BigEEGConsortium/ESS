function res = hlp_findscaling(X, scaling)
% Obtain information necessary to scale the given data. Works with hlp_applyscaling.
% Scale-Info = hlp_findscaling(Data, Scale-Mode)
%
% This is just a convenience tool to implement simple data (e.g. feature) scaling operations.
%
% In:
%   Data        : data matrix of [Observations x Variables]
%   Scale-Mode  : scaling mode, one of {std,minmax,whiten}
%
% Out:
%   Scale-Info  : scaling structure that can be used with hlp_applyscaling, to scale data
%
% Examples:
%   scaleinfo = hlp_findscaling(data,'whiten')
%   hlp_applyscaling(data,scaleinfo)
%
% See also:
%   hlp_applyscaling
%
%               Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%               2010-03-28

% Copyright (C) Christian Kothe, SCCN, 2010, christian@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU
% General Public License as published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
% even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program; if not,
% write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA

if ~exist('scaling','var') 
    scaling = 'minmax'; end

switch scaling
    case 'center'
        res = struct('add',{-mean(X)});
    case 'std'
        res = struct('add',{-mean(X)}, 'mul',{1./ std(X)});
        res.mul(~isfinite(res.mul(:))) = 1;
    case 'minmax'
        res = struct('add',{-min(X)}, 'mul',{1./ (max(X) - min(X))});
        res.mul(~isfinite(res.mul(:))) = 1;
    case 'whiten'
        [Uc,Lc] = eig(cov(X));
        res = struct('add',{-mean(X)},'project',{Uc * sqrt(inv(Lc))'});
        res.project(~isfinite(res.project(:))) = 1;
    otherwise
        if ~isempty(scaling) && ~strcmp(scaling,'none')
            error('hlp_findscaling: unknown scaling mode specified'); end
        res = struct();
end
