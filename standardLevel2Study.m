classdef standardLevel2Study
    properties
        standardLevel1StudyObj % Level 1 study contains basic information about study and raw data files. 
    end;
    methods
        function obj = standardLevel2Study(standardLevel1StudyObjOrFile, varargin)
            if ischar(standardLevel1StudyObjOrFile)
                obj.standardLevel1StudyObj = standardLevel1Study('file', standardLevel1StudyObjOrFile);
            else
                obj.standardLevel1StudyObj = standardLevel1StudyObjOrFile;
            end;
        end;
    end;
end