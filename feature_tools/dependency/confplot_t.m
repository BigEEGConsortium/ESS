function varargout = confplot_t(x,y,s,N,P,CM,varargin)
%
%CONFPLOT_T Linear plot with graded confidence/error boundaries.
%
%   [handle] = CONFPLOT_T(x,y,s,N,P,CM,[revCM?],[lim],[gamma],[fig]) 
%
%   plots the graph of vector X vs. vector Y with a graded error 
%   boundary which varies in color or shades of gray according to a t
%   distribution for sample size N, at the probabilities in P.
%
%   Required parameters:
%   x, y, s, and N are vectors of the same size.
%   s is the standard deviation of y at each point in x.
%   N is the number of observations (y) at each point in x.
%      N may be a scalar if the number of observation is constant.
%   P is a discrete monotonic set of probabilities in the range (0,0.5].
%      P determines the extent of the error boundary, and also the its
%      granularity (smoothness). For example, P = [0.01:0.01:0.5]
%   CM is a function handle to a color-map-generating function, passed in
%      using the @ syntaxt. For example, @gray.
%   
%  Optional parameters:
%  [revCM?] Reverse the order of the colors in the colormap? (1/0)
%  [lim]    Limits on the range of meaningful values in y.
%           For example, if y are correlation coefficients, then y must be in
%           the range [-1,1]. This prevents the error boundary from "spilling"
%           out beyond what makes sense for y.
%  [gamma]  Allows for gamma correction. If you don't know what gamma
%           correction is about, just know that gamma is applied as an
%           exponent to the color map, like this: CM.^gamma.
%  [fig]    If you want the plot to show up in a specific figure, pass in the
%           figure handle here. The default is to plot within the currently
%           active figure, or open a new figure if none is open.
%
%  Returns: an optional figure handle
%
%  � 2008 Aaron Schurger, Department of Psychology, Princeton University
%  January 2008
%
% CAVEAT: Not intended as a replacement for proper statistical tests.
%
% Sample data (pupil diameter measured over a three-second interval after
% appearance of a visual stimulus):
%
% T = [0.0167 0.1833 0.3500 0.5167 0.6833 0.8500 1.0167 1.1833 1.3500 1.5167 1.6833 1.8500 2.0167 2.1833 2.3500 2.5167 2.6833 2.8500];
% M = [6.343, 6.355, 6.262, 5.928, 5.678, 5.505, 5.378, 5.359, 5.408, 5.496, 5.613, 5.736, 5.867, 5.999, 6.113, 6.195, 6.244, 6.269];
% S = [0.347, 0.344, 0.384, 0.419, 0.468, 0.447, 0.418, 0.420, 0.426, 0.430, 0.424, 0.409, 0.388, 0.375, 0.351, 0.328, 0.314, 0.310];
% N = 27;
% confplot_t(T,M,S,N,[0.01:0.01:0.5],@gray,1);
% or try...
% set(gca,'color',[0 0 0];
% confplot_t(T,M,S,N,[0.01:0.01:0.5],@copper,0);
% or try...
% set(gca,'color',[0 0 1];
% confplot_t(T,M,S,N,[0.01:0.01:0.5],@winter,0);
%


% Copyright (c) 2008, Aaron Schurger
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

[revCM,LIM,gamma,h] = parseVarargin(varargin);
s(s==0)=eps; % in case of zeros in the variance

if any(isnan(x)) | any(isnan(y))
    warning('Nan''s detected in x and/or y. Values will be interpolated, and display may not be accurate.');
    OK = ~(isnan(x) | isnan(y));
else
    OK = true(size(x));
end

if h; figure(h); end

% Make sure that probabilities are in sort order with no repeats, 
% if not already. 
P = sort(unique(str2num(num2str(P))));
nP = length(P);

% Prepare the color map
G = feval(CM,nP+2).^gamma;
G = G(2:nP+1,:);

% Reverse the color map (if flag has been set).
% & is used instead of && in order to be compatible with MatLab 6.
if size(G,1) > 1 & revCM
    G = G(nP:-1:1,:);
end

% N may be a scalar, in which case the same number of observations is
% assumed at each value of x. Otherwise, N should be the same length as x,
% it which case each value in N is the number of observations for the
% corresponding value in x.
nN = length(N);
if nN == 1
    N = repmat(N,size(x));
elseif ~(nN==length(x))
   error('If N is not a scalar, then it must be the same size as x.');
end

H = zeros(nP,1);
for i=1:nP
    df = N-1;
    E = tinv(1-P(i),df) .* (s./sqrt(N));
    E(isnan(E))=eps;
    H(i) = confplot(x(OK),y(OK),E(OK),G(i,:),LIM, (i~=1));
end

axis auto
if nargout>0; varargout{1} = H; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = confplot(x,y,E,C,LIM, noLine)
%
% Plots a single error boundary, at one specific level of confidence.
%
%  Code below adapted from confplot.m
%
%  � 2002 - Michele Giugliano, PhD (http://www.giugliano.info)
%  (Bern, Monday Nov 4th, 2002 - 19:02)
%  $Revision: 1.0 $  $Date: 2002/11/11 14:36:08 $
%                        

z1 = y + E;
z2 = y - E;

s = size(x);
if s(1)==1
    X = [x, x(s(2):-1:1)];
    Y = min(max([z1, z2(s(2):-1:1)],LIM(1)),LIM(2));
else
    X = [x; x(s(1):-1:1)];
    Y = min(max([z1; z2(s(1):-1:1)],LIM(1)),LIM(2));
end

H = patch(X,Y,C);
if noLine
    set(H,'LineStyle','none');
else
    set(H,'EdgeColor',[0.8 0.8 0.8])
end;
hold on;

set(gca,'Layer','top');               

if (nargout>0); varargout{1} = H; end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [revCM, LIM,gamma,h] = parseVarargin(v)

% decide whether or not to reverse the color map
if ~isempty(v)
    revCM = v{1};
else
    revCM = 0;
end

% set upper and lower limits on the possible values of y
if length(v)>1
    LIM = v{2};
else
    LIM = [-inf inf];
end

% optional gamma correction parameter
if length(v)>2
    gamma = v{3};
else
    gamma = 1;
end

% assign to a specific figure, if desired
if length(v)>3
    h = v{4};
else
    h = 0;
end
