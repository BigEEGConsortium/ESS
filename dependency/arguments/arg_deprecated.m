function res = arg_deprecated(names,default,range,help,varargin)
% Declaration of a deprecated argument.
% Spec = arg_deprecated(Names,Default,Range,Options...)
%
% This type of function argument specifier behaves like arg(), but indicates that the argument in 
% question is deprecated and may become obsolete in the future. The argument will still be passed on
% to the function as normal, but will by default not be displayed in the GUI and will display a one-
% time-per-session warning (that can be disabled) when data is passed in to it.
%
% In:
%   Names : The name(s) of the argument. At least one must be specified, and if multiple are
%           specified, they must be passed in a cell array.
%           * The first name specified is the argument's "code" name, as it should appear in the
%             function's code (= the name under which arg_define() returns it to the function).
%           * The second name, if specified, is the "Human-readable" name, which is exposed in the
%             GUIs (if omitted, the code name is displayed).
%           * Further specified names are alternative names for the argument (e.g., for backwards
%             compatibility with older function syntaxes/parameter names).
%
%   Default : Optionally the default value of the argument; can be any data structure (default: []).
%
%   Range : Optionally a range of admissible values (default: []).
%           * If empty, no range is enforced.
%           * If a cell array, each cell is considered one of the allowed values.
%           * If a 2-element numeric vector, the two values are considered the numeric range of the
%             data (inclusive).
%
%   Help : The help text for this argument, optional. (default: []).
%
%   Options... : Optional name-value pairs to denote additional properties:
%                 'type' : Specify the primitive type of the parameter (default: [], indicating that
%                          it is auto-discovered from the Default and/or Range). The primitive type
%                          is one of the following strings:
%                             'logical', 'char', 'int8', 'uint8', 'int16', 'uint16', 'int32',
%                             'uint32', 'int64', 'uint64', 'denserealsingle', 'denserealdouble',
%                             'densecomplexsingle', 'densecomplexdouble', 'sparserealsingle',
%                             'sparserealdouble', 'sparsecomplexsingle', 'sparsecomplexdouble',
%                             'cellstr', 'object'.
%                          If auto-discovery was requested, but fails for some reason, the default
%                          type is set to 'denserealdouble'.
%
%                 'shape' : Specify the array shape of the parameter (default: [], indicating that
%                           it is auto-discovered from the Default and/or Range). The array shape is
%                           one of the following strings: 'scalar','row','column','matrix','empty'.
%                           If auto-discovery was requested, but fails for some reason, the default
%                           shape is set to 'matrix'.
%
% Out:
%   Spec : A cell array, that, when called as invoke_arg_internal(reptype,spec{1}{:}), yields a 
%          specification of the argument, for use by arg_define. The (internal) structure of that is 
%          as follows:
%          * Generally, this is a cell array (here: one element) of cells formatted as:
%            {Names,Assigner-Function,Default-Value}.
%          * Names is a cell array of admissible names for this argument.
%          * Assigner-Function is a function that returns the rich specifier with value assigned,
%            when called as Assigner-Function(Value).
%          * reptype is either 'rich' or 'lean', where in lean mode, the aternatives field remains
%            empty.
%
% Notes:
%   For MATLAB versions older than 2008a, type and shape checking, as well as auto-discovery, are
%   not necessarily executed.
%
% Examples:
%   function myfunction(varargin)
%   arg_define(varargin, ...
%       arg('arg1',10,[],'Some argument.'), ...
%       arg_deprecated('oldarg1',1001,[],'A legacy argument. Please don't use any more (might be dropped in the future).'));
%
% See also:
%   arg, arg_norep, arg_sub, arg_subswitch, arg_subtoggle, arg_define
%
%                                Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%                                2013-08-14

% Copyright (C) Christian Kothe, SCCN, 2013, christian@sccn.ucsd.edu
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

if nargin == 1
    res = {@invoke_arg_internal,{names,[],[],[],'displayable',false,'deprecated',true}};
elseif nargin >= 4
    res = {@invoke_arg_internal,[{names,default,range,help,'displayable',false,'deprecated',true} varargin]};
elseif nargin == 2
    res = {@invoke_arg_internal,{names,default,[],[],'displayable',false,'deprecated',true}};
else
    res = {@invoke_arg_internal,{names,default,range,[],'displayable',false,'deprecated',true}};
end
