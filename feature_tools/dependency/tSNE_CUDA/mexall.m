function mexall(CUDA_LIB_PATH, CUTIL_INC_PATH)
%MEXALL Compiles and links CUDA implementation of t-SNE for use with MATLAB
%
%   mexall(CUDA_LIB_PATH, CUTIL_INC_PATH)
%
% The function compiles all files required to use the CUDA implementation
% of t-SNE in Matlab. The optional variable CUDA_LIB_PATH is a string
% that specifies the location of the CUDA libraries. The optional variable
% CUTIL_INC_PATH sets the location of the CUTIL include files.
%
%
% (C) Laurens van der Maaten, 2010
% University of California, San Diego


    % Set the CUDA path and compiler options 
    if ~exist('CUDA_LIB_PATH', 'var') || isempty(CUDA_LIB_PATH)
        CUDA_LIB_PATH = '/usr/local/cuda/lib'; 
        warning(['Location of CUDA not specified. Using default location: ' CUDA_LIB_PATH]);
    end
    if ~exist('CUTIL_INC_PATH', 'var') || isempty(CUTIL_INC_PATH)
        CUTIL_INC_PATH = '/Developer/GPU\ Computing/C/common/inc';
        warning(['Location of CUTIL not specified. Using default location: ' CUTIL_INC_PATH]);
    end
    PIC_Option = ' --compiler-options -fPIC ';
    
    % Compile the required files using NVCC
    filenames = {'tsne_p', 'nvmatrix', 'nvmatrix_kernel'};
    for i=1:length(filenames)
        nvccCommandLine = ['nvcc --compile ' filenames{i} '.cu -o ' filenames{i} '.o ' ... 
                                PIC_Option ' -I' matlabroot '/extern/include -I' CUTIL_INC_PATH];
        status = system(nvccCommandLine); 
        if status < 0 
            error 'Error invoking nvcc';
        end
    end
    
    % Perform the linking (using rpath)
    mexCommandLine = 'mex ('; 
    for i=1:length(filenames)
        mexCommandLine = [mexCommandLine '''' filenames{i} '.o'', '];
    end
    mexCommandLine = [mexCommandLine '''-L' CUDA_LIB_PATH ''', ''-lcudart -lcufft -lcublas -Wl,-rpath,' CUDA_LIB_PATH ''')'];
    eval(mexCommandLine);

    % Clean up object files
    for i=1:length(filenames)
        delete([filenames{i} '.o']);
    end
