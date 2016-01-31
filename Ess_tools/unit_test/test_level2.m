%% Level 2 validation
obj = level2Study([fileparts(which('level1Study')) filesep 'unit_test' filesep 'dummy_level_2']);
obj.validate;