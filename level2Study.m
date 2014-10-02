classdef level2Study % change to level2Study
    % Be careful! any properties placed below will be written in the XML
    % file.
    properties         
        % version of STDL2 used. Mandatory.
        stld2Version 
        
        % study title, in case file was moved.
        title 
        
        % a unique identifier (uuid) with 32 random  alphanumeric characters and four hyphens).
        % It is used to uniquely identify each STDL2 document.
        uuid    
        
        % the URI pointing to the root folder of associated data folder. If the XML file is located
        % in the default root folder, this should be ‘.’ (current directory). If for example the data files   
        % and the root folder are placed on a remote FTP location, <rootURI> should be set to  
        % ‘ftp://domain.com/study’. The concatenation or <rootURI> and <filename> for each file
        % should always produce a valid, downloadable URI.adable URI.
        rootURI = '.';
        
        stld1 = struct('stld1Uuid', ' ',  'stld1File', ' '); 
    end;
    
    % properties that we do not want to be written/read to/from the XML
    % file are separated/distinguished here by assigning AbortSet = true.
    % This does not really change any of their behavior since AbortSet is
    % only relevant for handle classes.
    properties (AbortSet = true)
        % Filename (including path) of the ESS Standard Level 2 XML file associated with the
        % object.
        xmlFilePath
        
        % Level 1 study contains basic information about study and raw data files.
        standardLevel1StudyObj   
    end;
    
    methods
        function obj = level2Study(standardLevel1StudyObjOrFile, varargin)
            
            % if dependent files are not in the path, add all file/folders under
            % dependency to Matlab path.
            if ~(exist('arg', 'file') && exist('is_impure_expression', 'file') &&...
                    exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file'))
                thisClassFilenameAndPath = mfilename('fullpath');
                pathstr = fileparts(thisClassFilenameAndPath);
                addpath(genpath([pathstr filesep 'dependency']));
            end;
            
            
            if nargin > 0
                if ischar(standardLevel1StudyObjOrFile)
                    obj.standardLevel1StudyObj = standardLevel1Study('file', standardLevel1StudyObjOrFile);
                else
                    obj.standardLevel1StudyObj = standardLevel1StudyObjOrFile;
                end;
            end;
        end;
        
        function write(obj)
            % use xml_io tools to write XML from a Matlab structure
            propertiesToExcludeFromXMLIO = findAttrValue(obj, 'AbortSet', true);
            
            % remove fields that are flagged for not being saved to the XML
            % file.
            warning('off', 'MATLAB:structOnObject');
            xmlAsStructure = rmfield(struct(obj), propertiesToExcludeFromXMLIO);
            warning('on', 'MATLAB:structOnObject');
            
            % prevent xml_ioi from adding extra 'Item' fields and write the XML 
            Pref.StructItem = false;
            Pref.CellItem = false;
            xml_write(obj.xmlFilePath, xmlAsStructure, 'stld2', Pref);
        end;
        
        function obj = read(obj)
            Pref.Str2Num = false;
            [xmlAsStructure rootName] = xml_read(obj.xmlFilePath, Pref);
            names = fieldnames(xmlAsStructure);
            
            for i=1:length(names)
                obj.(names{i}) = xmlAsStructure.(names{i});
            end;
            
            %% TODO: convert integer values 
            
            % the assignment above is quite raw as it does not check for the
            % consistency of inner values with deeper structures
            % TODO: Perform consistency check here.
            
        end;
    end;
end