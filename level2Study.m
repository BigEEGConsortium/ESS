classdef level2Study
    % Be careful! any properties placed below will be written in the XML
    % file.
    properties         
        % version of STDL2 used. Mandatory.
        studyLevel2SchemaVersion = ' ';
        
        % study title, in case file was moved.
        title = ' ';
        
        % a unique identifier (uuid) with 32 random  alphanumeric characters and four hyphens).
        % It is used to uniquely identify each STDL2 document.
        uuid = ' ';   
        
        % the URI pointing to the root folder of associated data folder. If the XML file is located
        % in the default root folder, this should be ‘.’ (current directory). If for example the data files   
        % and the root folder are placed on a remote FTP location, <rootURI> should be set to  
        % ‘ftp://domain.com/study’. The concatenation or <rootURI> and <filename> for each file
        % should always produce a valid, downloadable URI.adable URI.
        rootURI = '.';
        
        % Filters have a similar definition here as in BCILAB. They receive as input the EEG data
        % and output a transformation of the data that can be the input to other filters.
        % Here we are assuming a number of filters to have been executed on the data,
        % in the order specified in executionOrder (multiple numbers here mean multiple filter
        % runs.
        filters = struct('filter', struct('filterLabel', ' ', 'executionOrder', ' ', ...
            'softwareEnvironment', ' ', 'softwarePackage', ' ', 'functionName', ' ',...
            'parameters', struct('parameter', struct('name', ' ', 'value', ' ')), 'recordingParemeterSetLabel', ' ')); 
        
        % files containing EEGLAB datasets, each recording gets its own studyLevel2 file
        % (we do not combine datasets).
        studyLevel2Files = struct('studyLevel2File', struct('studyLevel2FileName', ' ', ...
            'dataRecordingUuid', ' ', 'noisyParametersFile', ' ', 'averageReferenceChannels', ' ', ...
            'rereferencedChannels', ' ', 'interpolatedChannels', ' ', 'nonInterpolatableChannels',  ' '));
    end;
    
    % properties that we do not want to be written/read to/from the XML
    % file are separated/distinguished here by assigning AbortSet = true.
    % This does not really change any of their behavior since AbortSet is
    % only relevant for handle classes.
    properties (AbortSet = true)
        % Filename (including path) of the ESS Standard Level 2 XML file associated with the
        % object.
        level2XmlFilePath
        
        % Filename (including path) of the ESS Standard Level 1 XML file
        % based on which level 2 data may be computed. Could be kept empty
        % if not available.
        level1XmlFilePath
        
        % Level 1 study contains basic information about study and raw data files.
        % It is created based on level1XmlFilePath input parameter
        level1StudyObj            
        
        % ESS-convention level 2 folder where all level 2 data are
        % organized during level 1 -> 2 conversion using the pipeline.
        level2Folder
    end;
    
    methods
        function obj = level2Study(varargin)
            
            % if dependent files are not in the path, add all file/folders under
            % dependency to Matlab path.
            if ~(exist('arg', 'file') && exist('is_impure_expression', 'file') &&...
                    exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file'))
                thisClassFilenameAndPath = mfilename('fullpath');
                pathstr = fileparts(thisClassFilenameAndPath);
                addpath(genpath([pathstr filesep 'dependency']));
            end;
            
            
            inputOptions = arg_define(1,varargin, ...
                arg('level1XmlFilePath', '','','ESS Standard Level 1 XML Filename.', 'type', 'char'), ...
                arg('level2XmlFilePath', '','','ESS Standard Level 2 XML Filename.', 'type', 'char'), ...             
                arg('createNewFile', false,[],'Always create a new file. Forces the creation of a new (partially empty, filled according to input parameters) ESS file. Use with caution since this forces an un-promted overwrite if an ESS file already exists in the specified path.', 'type', 'cellstr') ...
                );
            
            if nargin > 0
                obj.level1StudyObj = level1Study(inputOptions.level1XmlFilePath);
                obj.level1XmlFilePath = inputOptions.level1XmlFilePath;
            end;
        end;
        
        function obj = write(obj, level2XmlFilePath)
            
            % assign the input file path as the object path and write
            % there.
            if nargin > 1
                obj.level2XmlFilePath = level2XmlFilePath;
            end;
            
            % use xml_io tools to write XML from a Matlab structure
            propertiesToExcludeFromXMLIO = findAttrValue(obj, 'AbortSet', true);
            
            % remove fields that are flagged for not being saved to the XML
            % file.
            warning('off', 'MATLAB:structOnObject');
            xmlAsStructure = rmfield(struct(obj), propertiesToExcludeFromXMLIO);
            warning('on', 'MATLAB:structOnObject');
            
            % include level 1 xml in studyLevel1 field.
            xmlAsStructure.studyLevel1 = xml_read (obj.level1XmlFilePath);
            
            % prevent xml_ioi from adding extra 'Item' fields and write the XML 
            Pref.StructItem = false;
            Pref.CellItem = false;
            xml_write(obj.level2XmlFilePath, xmlAsStructure, 'studyLevel2', Pref);
        end;
        
        function obj = read(obj)
            Pref.Str2Num = false;
            [xmlAsStructure rootName] = xml_read(obj.level2XmlFilePath, Pref);
            names = fieldnames(xmlAsStructure);
            
            for i=1:length(names)
                obj.(names{i}) = xmlAsStructure.(names{i});
            end;
            
            %% TODO: convert integer values 
            
            % the assignment above is quite raw as it does not check for the
            % consistency of inner values with deeper structures
            % TODO: Perform consistency check here, or use XSD validation.
            
        end;
        
        function obj = createLevel2Study(obj, level2Folder, varargin)
            obj.level2Folder = level2Folder;
            
            % make top folders
            mkdir(level2Folder);
            mkdir([level2Folder filesep 'session']);
            mkdir([level2Folder filesep 'additional_data']);
            
            % process each session before moving to the other
            for i=1:length(obj.level1StudyObj.sessionTaskInfo)
                for j=1:length(obj.level1StudyObj.sessionTaskInfo(i).dataRecording)
                    fileNameFromObj = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(j).filename;
                    
                    % read data
                    
                    % copy and rename the data recording files
                    level1FileFolder = fileparts(obj.level1XmlFilePath);
                    
                    if isempty(obj.rootURI)
                        rootFolder = level1FileFolder;
                    elseif obj.rootURI(1) == '.'
                        rootFolder = [level1FileFolder filesep obj.rootURI(2:end)];
                    end;
                    
                    % search for the file both next to the xml file and in the standard ESS
                    % convention location
                    nextToXMLFilePath = [rootFolder filesep fileNameFromObj];
                    fullEssFilePath = [rootFolder filesep 'session' filesep obj.sessionTaskInfo(i).sessionNumber filesep fileNameFromObj];
                    
                    if ~isempty(fileNameFromObj) && exist(fullEssFilePath, 'file')
                        fileFinalPath = fullEssFilePath;
                    elseif ~isempty(fileNameFromObj) && exist(nextToXMLFilePath, 'file')
                        fileFinalPath = nextToXMLFilePath;
                    elseif ~isempty(fileNameFromObj) % when the file is specified but cannot be found on disk
                        fileFinalPath = [];
                        fprintf('File specified for data recoding %d of sesion number %s does not exist, \r         i.e. cannot find either %s or %s.\n', j, obj.sessionTaskInfo(i).sessionNumber, nextToXMLFilePath, fullEssFilePath);
                        fprintf('You might want to run validate() routine.\n');
                    else % the file name is empty
                        fileFinalPath = [];
                        fprintf('You have not specified any file for data recoding %d of sesion number %s\n', j, obj.sessionTaskInfo(i).sessionNumber);
                        fprintf('You might want to run validate() routine.\n');
                    end;
                    
                    % run the pipeline
                    
                    % lets assume we got EEG variable
                    % write data
                    sessionFolder = [level2Folder filesep 'session' filesep obj.level1StudyObj.sessionTaskInfo(i).sessionNumber];
                    if ~exist(sessionFolder, 'dir')
                        mkdir(sessionFolder);
                    end;
                    
                    % if recording file name matches ESS Level 1 convention
                    % then just modify it a bit to conform to level2
                    [path name ext] = fileparts(fileFinalPath);
                    % see if the file name is already in ESS
                    % format, hence no name change is necessary
                    itMatches = level1Study.fileNameMatchesEssConvention([name ext], 'eeg', obj.level1StudyObj.studyTitle, obj.sessionTaskInfo(i).sessionNumber,...
                        subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j);
                                        
                    if itMatches
                        % change the eeg_ at the beginning to
                        % eeg_studyLevel2_
                        filenameInEss = [eeg_studyLevel2_ name(5:end) ext];
                    else % convert to ess convention
                        filenameInEss = obj.essConventionFileName('eeg', ['studyLevel2_' obj.studyTitle], obj.sessionTaskInfo(i).sessionNumber,...
                            subjectInSessionNumber, obj.sessionTaskInfo(i).taskLabel, j, name, extension);
                    end;
                    
                end;
            end;
            
            obj.write('studyLevel2_description.xml');
        end;
    end;
end