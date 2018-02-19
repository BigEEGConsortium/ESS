function B = permute_with_singleton(A, order)
% B = permute_with_singleton(A, order)
% Similar to MATLAB permute() function but handles singleton dimensions at the end too.
% For example an array with the size [10 20 1] can be permuted with order = [3 1]