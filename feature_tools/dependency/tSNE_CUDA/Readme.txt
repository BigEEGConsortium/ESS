Introduction
============

This is an implementation of t-SNE in CUDA, designed to run in Matlab. The document gives a brief description of how to install and use the CUDA implementation of t-SNE.

?? Laurens van der Maaten, 2010
University of California, San Diego


Installation instructions
=========================

Step 1
- Make sure you have a CUDA-enabled GPU. A list of CUDA-enabled GPUs is available from http://www.nvidia.com/object/cuda_gpus.html

Step 2
- Download and install the CUDA Developer Drivers and the CUDA Toolkit. The software has been tested for CUDA 3.x, but may work on earlier versions as well. Both the drivers and the toolkit are available from http://developer.nvidia.com

Step 3
- Add the folder in which NVCC is located to the PATH. On *nix systems, NVCC is typically located in /usr/local/cuda/bin, and one can use the SETENV or EXPORT command to update the PATH (depending on the used shell). On Windows systems, the PATH can be set trough the configuration screen (under Environment variables).

Step 4
- Start Matlab, and use the MEXALL function to compile the code. The MEXALL function has two input arguments that allows you to specify the location of the CUDA libraries and of the CUTIL include file (cutil_inline.h). If no location is specified, the default location for Macs are tried (/usr/local/cuda/lib and /Developer/GPU\ Computing/C/common/inc, respectively).

Step 5
- The TSNE, TSNE_D, and TSNE_P functions are now ready to use. If compilation of the CUDA software failed, the functions will fall back on a Matlab implementation of t-SNE.


Potential pitfalls
==================

- Please make sure that your CUDA version is built for the same architecture as your Matlab version. For instance, it is not possible to combine a 64-bit CUDA version with a 32-bit Matlab version. Using a 32-bit CUDA version with 64-bit Matlab is possible, but requires some changes to the MEXALL function (i.e., the -m32 switch needs to be added).

- If the CUDA code does not start at runtime, please check whether the dynamic linker can find the required CUDA libraries (cudart, cublas, cufft). It might be necessary to set the LD_LIBRARY_PATH or DYLD_LIBRARY_PATH environment variables. Please run Matlab without GUI to make sure you see all error messages.

- If the CUDA code starts, but suddenly quits with an unclear error message, you might have run out of GPU memory. Please try to reduce the number of data points in the data, or find a GPU with more RAM. 


Contact
=======

For questions, suggestions, or bugfixes, please contact me at:

			lvdmaaten@gmail.com

(But do not email me with questions that are answered in this document!)
