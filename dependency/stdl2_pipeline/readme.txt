% Version -0.1
% This version is still in progress and is the latest as of 9-15-14.
% It still needs:
%    1)  Automatic line noise peak finding --- approximate peaks now
%        have to be set.
%    2)  Elimination of places where signal is not recorded 
%        (e.g., bad on most or all channels.)
%    3)  Haven't decided how to pad the tapers for removing line noise
%        so there is always a small segment at end that is not cleaned.
%    4)  Haven't finalized how the results are reported.
%
% Written by Kay Robbins September 15, 2014
%
% To run, call the standardLevel2Pipeline function. The
% runStandardLevel2Pipeline shows and example of how to setup.
%
% Note: you must make sure that the EEGLAB is in the path and that 
% the utilities subdirectory is in the path.