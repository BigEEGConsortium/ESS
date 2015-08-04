% if dependent files are not in the path, add all file/folders under
% dependency to Matlab path.
if ~(exist('uniqe_file_to_test_ESS_path', 'file') && exist('is_impure_expression', 'file') &&...
        exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file'))
    thisClassFilenameAndPath = mfilename('fullpath');
    pathstr = fileparts(thisClassFilenameAndPath);
    addpath(genpath([pathstr filesep 'dependency']));
end;