%% LevelDerived creation
level2Folder = [fileparts(which('level1Study')) filesep 'unit_test' filesep 'dummy_level_2'];

obj = levelDerivedStudy('parentStudyXmlFilePath', level2Folder); % this load the data but does not make a Level-derived 2 container yet (Obj it is still mostly empty).
twiceFunction = @(x,y) x;
callbackAndParameters = {twiceFunction, 'cutoff', 5};

temporaryDir = [tempdir filesep 'dummy_level_derived'];
if exist(temporaryDir, 'file')
    rmdir(temporaryDir, 's');
end;

fprintf('\n--------------------------------------\n');
fprintf('Output Level-drived folder: %s\n', temporaryDir);
fprintf('--------------------------------------\n\n');

% this command starts applying the ASR function to all the recordings and makes a fully-realized Level-derived object.
obj = obj.createLevelDerivedStudy(callbackAndParameters, ...
    'levelDerivedFolder', temporaryDir, 'filterLabel', 'same', 'filterDescription', 'no changhe');

[obj issues] = obj.validate;
assert(isempty(issues));

%% LevelDerived combination of partial runs

partialLevelDerivedFolder1 = [fileparts(which('level1Study')) filesep 'unit_test' filesep 'dummy_level_derived_partial_1'];
partialLevelDerivedFolder2 = [fileparts(which('level1Study')) filesep 'unit_test' filesep 'dummy_level_derived_partial_2'];
combinedDirectory = [tempdir filesep 'dummy_level_derived_combined'];
if exist(combinedDirectory, 'file')
    rmdir(combinedDirectory, 's');
end;

obj = levelDerivedStudy;
obj = obj.combinePartialRuns({partialLevelDerivedFolder1 partialLevelDerivedFolder2}, combinedDirectory);

[obj issues] = obj.validate;
assert(isempty(issues));

%% LevelDerived creation from another LevelDerived

levelDerivedFolderParent = [fileparts(which('levelStudy')) filesep 'unit_test' filesep 'dummy_level_derived_full'];

obj = levelDerivedStudy('parentStudyXmlFilePath', levelDerivedFolderParent); % this load the data but does not make a Level-derived container yet (Obj it is still mostly empty).
twiceFunction = @(x,y) x;
callbackAndParameters = {twiceFunction, 'cutoff', 5};

temporaryDir = [tempdir filesep 'dummy_level_derived_from_derived'];
if exist(temporaryDir, 'file')
    rmdir(temporaryDir, 's');
end;

fprintf('\n--------------------------------------\n');
fprintf('Output Level-drived folder: %s\n', temporaryDir);
fprintf('--------------------------------------\n\n');

% this command starts applying the ASR function to all the recordings and makes a fully-realized Level-derived object.
obj = obj.createLevelDerivedStudy(callbackAndParameters, ...
    'levelDerivedFolder', temporaryDir, 'filterLabel', 'twice-value', 'filterDescription', 'twice the value');

[obj issues] = obj.validate;
assert(isempty(issues));