% check Structable dependency
assert(exist('Structable','class')==8,'Structable must be on the path');

% create object
obj = MyClassHierarchy;

% convert object to struct
st = obj.toStruct;

% ready to compare
fprintf('Use the command line or workspace explorer to compare obj and st.\n');