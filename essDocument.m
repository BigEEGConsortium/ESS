classdef essDocument
    % Allow reading, writing and manipulatoion of information contained in ESS-formatted XML files.
    % EEG Studdy Schema (ESS) contains EEG study meta-data information (subject information, sessions file
    % associations...). On read data are loaded in the object properties, you can change this data
    % (e.g. add a ne session) and then save using the write() method into a =new ESS XML file.
    %
    % Written by Nima Bigdely-Shamlo and Jessica Hsi.
    % Copyright © 2014 Syntrogi, Inc.
    % Copyright © 2013-2014 University of California San Diego.
    % Released under BSD License.
    
    properties
        essVersion = ' ';
        studyTitle = ' ';
        studyDescription = ' ';
        studyUuid = ' ';
        projectInfo = struct('organization', ' ',  'grantId', ' ');
        sessionInfo = struct('number', ' ', 'taskLabel', ' ', 'purpose', ' ', 'labId', ' ',...
            'channels', ' ', 'eegSamplingRate', ' ', 'eegRecording', {{' '}},...
            'note', ' ', 'linkName', ' ', 'link', ' ', 'subject', struct('labId', ' ',...
            'inSessionNumber', ' ', 'group', ' ', 'gender', ' ', 'YOB', ' ', 'age', ' ', 'hand', ' ', 'vision', ' ', ...
            'hearing', ' ', 'height', ' ', 'weight', ' ', 'channelLocations', ' ', ...
            'channelLocationType', ' ', 'medication', struct('caffeine', ' ', 'alcohol', ' ')));        
        tasksInfo = struct('taskLabel', ' ', 'tag', ' ', 'description', ' ');
        eventCodesInfo = struct('code', ' ', 'taskLabel', ' ', 'condition', struct(...
            'label', ' ', 'description', ' ', 'tag', ' '));
        summaryInfo = struct('totalSize', ' ', 'allSubjectsHealthyAndNormal', ' ', 'recordedModalities', ...
            struct('name', ' ', 'recordingDevice', ' ', 'numberOfSensors', ' ', 'numberOfChannels', ' ',...
            'numberOfCameras',' '), 'license', struct('type', ' ', 'text', ' ', 'link',' '));
        publicationsInfo = struct('citation', ' ', 'DOI', ' ', 'link', ' ');
        experimentersInfo = struct('name', ' ', 'role', ' ');
        contactInfo = struct ('name', ' ', 'phone', ' ', 'email', ' ');
        organizationInfo = struct('name', ' ', 'logoLink', ' ');
        copyrightInfo = ' ';
        irbInfo = ' ';
        
        % internal variables
        essFilePath        % the file (including folder) associated with the document (e.g. the file the document was last saved to , or originally read from) 
    end;
    
    methods
        
        function obj = essDocument(essFilePath, varargin)
            % obj = essDocument(essFilePath)
            % create a instance of the object. If essFilePath is provided (optimal) it also read the
            % file.                       
            
            % read the ESS File is provided.
            if nargin > 0
                obj.essFilePath = essFilePath;
                
                if exist(obj.essFilePath, 'file') % read the ESS information from the file                
                    obj = obj.read(essFilePath);
                else  
                    % input file did not exist. Create an ESS file at that located 
                    % and populate it with empty fields according to input
                    % values.
                    
                    % prepare the object based on input values.
                    % assigns a random UUID.
                    obj.essVersion = '2.0';
                    obj.studyUuid = char(java.util.UUID.randomUUID);
                    
                    % ToDo: here we sneed to replicate sessions, subjects
                    % and taks based onthe numbers provided.
                    
                    obj = obj.write(obj.essFilePath);
                    fprintf('Input file does not exist, creating  a new ESS file with empty fields at %s.\n', obj.essFilePath);
                end;
            end;
        end;
        
        function outString  = readStringFromNode(obj, node)
            firstChild = node.getFirstChild;
            if isempty(firstChild)
                outString = '';
            else
                outString = strtrim(char(firstChild.getData));
            end;
        end;
        
        function obj = read(obj, essFilePath)
            
            function result = nodeExistsAndHasAChild(node)
                result = node.getLength > 0 && ~isempty( node.item(0).getFirstChild);
            end
            
            
            %  obj = read(essFilePath);
            %
            % Reads the information contained an ESS-formatted XML file and placed it into object properties.
            
            xmlDocument = xmlread(essFilePath);
            potentialStudyNodeArray = xmlDocument.getElementsByTagName('study');
            
            if potentialStudyNodeArray.getLength == 0
                error('The XML file does not contain a study node.');
            elseif potentialStudyNodeArray.getLength == 1
                studyNode = potentialStudyNodeArray.item(0);
            else
                error('The XML file contains more than one study node.');
            end;
            
            % read ESS version.
            currentNode = studyNode; 
            potentialEssVersionNodeArray = currentNode.getElementsByTagName('essVersion');
            obj.essVersion = obj.readStringFromNode(potentialEssVersionNodeArray.item(0));            
                       
            potentialDescriptionNodeArray = currentNode.getElementsByTagName('description');
            if nodeExistsAndHasAChild(potentialDescriptionNodeArray)
                obj.studyDescription = strtrim(char(potentialDescriptionNodeArray.item(0).getFirstChild.getData));
            else
                obj.studyDescription = '';
            end;
            
            
            potentialTitleNodeArray = currentNode.getElementsByTagName('title');
            if nodeExistsAndHasAChild(potentialTitleNodeArray)
                obj.studyTitle = strtrim(char(potentialTitleNodeArray.item(0).getFirstChild.getData));
            else
                obj.studyTitle = '';
            end;
            
            potentialTitleNodeArray = currentNode.getElementsByTagName('uuid');
            if nodeExistsAndHasAChild(potentialTitleNodeArray)
                obj.studyUuid = obj.readStringFromNode(potentialTitleNodeArray.item(0));
            else
                obj.studyUuid = '';
            end;                        
            
            % start project node
            potentialProjectNodeArray = currentNode.getElementsByTagName('project');
            if nodeExistsAndHasAChild(potentialProjectNodeArray)
                obj.projectInfo = strtrim(char(potentialProjectNodeArray.item(0).getFirstChild.getData));
                
                potentialFundingNodeArray = currentNode.getElementsByTagName('funding'); % inside <Sessions> .. find <session> <session>
                if potentialFundingNodeArray.getLength > 0
                    
                    for fundingCounter = 0:(potentialFundingNodeArray.getLength-1)
                        currentNode = potentialFundingNodeArray.item(fundingCounter); % select a session and make it the current node.
                        fundingNode = currentNode;
                        
                        potentialFundingOrganizationNodeArray = currentNode.getElementsByTagName('organization');
                        
                        % to distinguish this from the organization node at the top level we need to
                        % look at its parent
                        theItemNumber = [];
                        for itemCounter = 0:(potentialFundingOrganizationNodeArray.getLength-1)
                            if potentialFundingOrganizationNodeArray.item(itemCounter).getParentNode == fundingNode
                                theItemNumber = itemCounter;
                            end;
                        end;
                        
                        if ~isempty(theItemNumber)
                            obj.projectInfo(fundingCounter+1).organization = obj.readStringFromNode(potentialFundingOrganizationNodeArray.item(theItemNumber));
                        else
                            obj.projectInfo(fundingCounter+1).organization  = '';
                        end;
                        
                        potentialFundingGrantIdNodeArray = currentNode.getElementsByTagName('grantId');
                        if potentialFundingGrantIdNodeArray.getLength > 0
                            obj.projectInfo(fundingCounter+1).grantId = obj.readStringFromNode(potentialFundingGrantIdNodeArray.item(0));
                        else
                            obj.projectInfo(fundingCounter+1).grantId = '';
                        end;
                    end;
                end;
            else %project information has not been provided, we need to create the appropriate subfields though.
                obj.projectInfo = struct('organization', '', 'grantId', '');
            end;
            
            
            
            % start tasks node
            currentNode = studyNode;
            potentialTasksNodeArray = currentNode.getElementsByTagName('tasks');
            if nodeExistsAndHasAChild(potentialTasksNodeArray)
                obj.tasksInfo = strtrim(char(potentialTasksNodeArray.item(0).getFirstChild.getData));
                
                potentialTaskNodeArray = currentNode.getElementsByTagName('task'); % inside <Sessions> .. find <session> <session>
                if potentialTaskNodeArray.getLength > 0
                    
                    for taskCounter = 0:(potentialTaskNodeArray.getLength-1)
                        currentNode = potentialTaskNodeArray.item(taskCounter); % select a session and make it the current node.
                        singleTaskNode = currentNode;
                        
                        potentialTaskLabelNodeArray = currentNode.getElementsByTagName('taskLabel');
                        if potentialTaskLabelNodeArray.getLength > 0
                            obj.tasksInfo(taskCounter+1).taskLabel = obj.readStringFromNode(potentialTaskLabelNodeArray.item(0));
                        else
                            obj.tasksInfo(taskCounter+1).taskLabel  = '';
                        end;
                        
                        potentialTaskTagNodeArray = currentNode.getElementsByTagName('tag');
                        if potentialTaskTagNodeArray.getLength > 0
                            obj.tasksInfo(taskCounter+1).tag = obj.readStringFromNode(potentialTaskTagNodeArray.item(0));
                        else
                            obj.tasksInfo(taskCounter+1).tag = '';
                        end;
                        
                        potentialTaskDescriptionNodeArray = currentNode.getElementsByTagName('description');
                        if potentialTaskDescriptionNodeArray.getLength > 0
                            obj.tasksInfo(taskCounter+1).description = obj.readStringFromNode(potentialTaskDescriptionNodeArray.item(0));
                        else
                            obj.tasksInfo(taskCounter+1).description = '';
                        end;
                    end;
                end;
            else
                obj.tasksInfo= [];
            end;
            
            
            
            
            currentNode = studyNode;
            potentialSessionsNodeArray = currentNode.getElementsByTagName('sessions');
            if potentialSessionsNodeArray.getLength > 0
                currentNode = potentialSessionsNodeArray.item(0);
                
                potentialSessionNodeArray = currentNode.getElementsByTagName('session'); % inside <Sessions> .. find <session> <session>
                if potentialSessionNodeArray.getLength > 0
                    %number of session
                    for sessionCounter = 0:(potentialSessionNodeArray.getLength-1)
                        currentNode = potentialSessionNodeArray.item(sessionCounter); % select a session and make it the current node.
                        singleSessionNode = currentNode;
                        
                        % currentNode is now a single-session node.
                        potentialNumberNodeArray = currentNode.getElementsByTagName('number');
                        if potentialNumberNodeArray.getLength > 0
                            obj.sessionInfo(sessionCounter+1).number = obj.readStringFromNode(potentialNumberNodeArray.item(0));
                        else
                            obj.sessionInfo(sessionCounter+1).number= '';
                        end;
                        
                        potentialTaskLabelNodeArray = currentNode.getElementsByTagName('taskLabel');
                        if potentialTaskLabelNodeArray.getLength > 0
                            obj.sessionInfo(sessionCounter+1).taskLabel = obj.readStringFromNode(potentialTaskLabelNodeArray.item(0));
                        else
                            obj.sessionInfo(sessionCounter+1).number= '';
                        end;
                        
                        
                        potentialPurposeNodeArray = currentNode.getElementsByTagName('purpose');
                        if potentialPurposeNodeArray.getLength > 0
                            obj.sessionInfo(sessionCounter+1).purpose = obj.readStringFromNode(potentialPurposeNodeArray.item(0));
                        else
                            obj.sessionInfo(sessionCounter+1).purpose= '';
                        end;
                        
                        potentialLabIdNodeArray = currentNode.getElementsByTagName('labId');
                        if potentialLabIdNodeArray.getLength > 0
                            obj.sessionInfo(sessionCounter+1).labId = obj.readStringFromNode(potentialLabIdNodeArray.item(0));
                        else
                            obj.sessionInfo(sessionCounter+1).labId= '';
                        end;
                        
                        
                        potentialChannelNodeArray = currentNode.getElementsByTagName('channels');
                        if potentialChannelNodeArray.getLength > 0
                            obj.sessionInfo(sessionCounter+1).channels = obj.readStringFromNode(potentialChannelNodeArray.item(0));
                        else
                            obj.sessionInfo(sessionCounter+1).channels= '';
                        end;
                        
                        potentialEegSamplingRateNodeArray = currentNode.getElementsByTagName('eegSamplingRate');
                        if potentialEegSamplingRateNodeArray.getLength > 0
                            obj.sessionInfo(sessionCounter+1).eegSamplingRate= obj.readStringFromNode(potentialEegSamplingRateNodeArray.item(0));
                        else
                            obj.sessionInfo(sessionCounter+1).eegSamplingRate= '';
                        end;
                        
                        potentialEegRecordingsNodeArray = currentNode.getElementsByTagName('eegRecordings'); % inside <eegRecordings> find <eegRecording>
                        if potentialEegRecordingsNodeArray.getLength > 0
                            potentialEegRecordingNodeArray = currentNode.getElementsByTagName('eegRecording');
                            for eegRecordingCounter = 0:(potentialEegRecordingNodeArray.getLength-1)
                                if  potentialEegRecordingNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).eegRecording{eegRecordingCounter+1}= obj.readStringFromNode(potentialEegRecordingNodeArray.item(eegRecordingCounter));
                                end;
                            end;
                        end;
                        
                        potentialNotesNodeArray = currentNode.getElementsByTagName('notes'); % inside <notes>
                        if potentialNotesNodeArray.getLength > 0
                            potentialNoteNodeArray = currentNode.getElementsByTagName('note');
                            if  potentialNoteNodeArray.getLength > 0
                                obj.sessionInfo(sessionCounter+1).note= obj.readStringFromNode(potentialNoteNodeArray.item(0));
                            else
                                obj.sessionInfo(sessionCounter+1).note= '';
                            end;
                            
                            currentNode = potentialNotesNodeArray.item(0);
                            potentialLinkNameNodeArray = currentNode.getElementsByTagName('linkName');
                            if  potentialLinkNameNodeArray.getLength > 0
                                obj.sessionInfo(sessionCounter+1).linkName = obj.readStringFromNode(potentialLinkNameNodeArray.item(0)); % the if empty line
                            else
                                obj.sessionInfo(sessionCounter+1).linkName= '';
                            end;
                            
                            potentialLinkNodeArray = currentNode.getElementsByTagName('link');
                            if  potentialLinkNodeArray.getLength > 0
                                obj.sessionInfo(sessionCounter+1).link  = obj.readStringFromNode(potentialLinkNodeArray.item(0));
                            else
                                obj.sessionInfo(sessionCounter+1).link= '';
                            end;
                            
                        end;
                        
                        
                        
                        potentialSubjectNodeArray = singleSessionNode.getElementsByTagName('subject'); % inside <subject> for each session
                        
                        if potentialSubjectNodeArray.getLength > 0
                            for sessionSubjectCounter = 0:(potentialSubjectNodeArray.getLength-1)
                                
                                currentNode = potentialSubjectNodeArray.item(sessionSubjectCounter); % select a subject and make it the current node.
                                
                                potentialSubjectLabIdNodeArray = currentNode.getElementsByTagName('labId');
                                if potentialSubjectLabIdNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).labId = obj.readStringFromNode(potentialSubjectLabIdNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).labId= '';
                                end;
                                
                                potentialSubjectInSessionNumberNodeArray = currentNode.getElementsByTagName('inSessionNumber');
                                if potentialSubjectInSessionNumberNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).inSessionNumber = obj.readStringFromNode(potentialSubjectInSessionNumberNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).inSessionNumber = '';
                                end;
                                
                                potentialGroupNodeArray = currentNode.getElementsByTagName('group');
                                if potentialGroupNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).group = obj.readStringFromNode(potentialGroupNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).group= '';
                                end;
                                
                                potentialGenderNodeArray = currentNode.getElementsByTagName('gender');
                                if potentialGenderNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).gender = obj.readStringFromNode(potentialGenderNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).gender= '';
                                end;
                                
                                potentialYearOfBirthNodeArray = currentNode.getElementsByTagName('YOB');
                                if potentialYearOfBirthNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).YOB = obj.readStringFromNode(potentialYearOfBirthNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).YOB= '';
                                end;
                                
                                potentialAgeNodeArray = currentNode.getElementsByTagName('age');
                                if potentialAgeNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).age = obj.readStringFromNode(potentialAgeNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).age= '';
                                end;
                                
                                potentialHandNodeArray = currentNode.getElementsByTagName('hand');
                                if potentialHandNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hand = obj.readStringFromNode(potentialHandNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hand= '';
                                end;
                                
                                potentialVisionNodeArray = currentNode.getElementsByTagName('vision');
                                if potentialVisionNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).vision = obj.readStringFromNode(potentialVisionNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).vision= '';
                                end;
                                
                                potentialHearingNodeArray = currentNode.getElementsByTagName('hearing');
                                if potentialHearingNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hearing = obj.readStringFromNode(potentialHearingNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).hearing= '';
                                end;
                                
                                potentialHeightNodeArray = currentNode.getElementsByTagName('height');
                                if potentialHeightNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).height = obj.readStringFromNode(potentialHeightNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).height= '';
                                end;
                                
                                potentialWeightNodeArray = currentNode.getElementsByTagName('weight');
                                if potentialWeightNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).weight = obj.readStringFromNode(potentialWeightNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).weight= '';
                                end;
                                
                                potentialChannelLocationsNodeArray = currentNode.getElementsByTagName('channelLocations');
                                if potentialChannelLocationsNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).channelLocations = obj.readStringFromNode(potentialChannelLocationsNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).channelLocations= '';
                                end;
                                
                                potentialChannelLocationTypeNodeArray = currentNode.getElementsByTagName('channelLocationType');
                                if potentialChannelLocationTypeNodeArray.getLength > 0
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).channelLocationType = obj.readStringFromNode(potentialChannelLocationTypeNodeArray.item(0));
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).channelLocationType= '';
                                end;
                                
                                potentialMedicationNodeArray = currentNode.getElementsByTagName('medication');
                                if potentialMedicationNodeArray.getLength > 0
                                    potentialCaffeineNodeArray = currentNode.getElementsByTagName('caffeine');
                                    if potentialCaffeineNodeArray.getLength > 0
                                        obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.caffeine = obj.readStringFromNode(potentialMedicationNodeArray.item(0));
                                    else
                                        obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.caffeine= '';
                                    end
                                    
                                    potentialAlcoholNodeArray = currentNode.getElementsByTagName('alcohol');
                                    if potentialAlcoholNodeArray.getLength > 0
                                        obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.alcohol = obj.readStringFromNode(potentialAlcoholNodeArray.item(0));
                                    else
                                        obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.alcohol= '';
                                    end
                                else
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.caffeine= '';
                                    obj.sessionInfo(sessionCounter+1).subject(sessionSubjectCounter+1).medication.alcohol= '';
                                end;
                                
                            end;
                        else % if subject node is not provided, use an empty array.
                            obj.sessionInfo(sessionCounter+1).subject = [];
                        end; %end subject info
                        
                        
                    end;%ends specific session node, end for loop                                                            
                end;
                                
            end; %ends sessions node
            
            
            
            
            currentNode = studyNode;
            
            %start event codes
            potentialEventCodesNodeArray = currentNode.getElementsByTagName('eventCodes');
            if potentialEventCodesNodeArray.getLength > 0
                obj.eventCodesInfo = strtrim(char(potentialEventCodesNodeArray.item(0).getFirstChild.getData));
                
                potentialEventCodeNodeArray = currentNode.getElementsByTagName('eventCode'); % inside <Sessions> .. find <session> <session>
                if potentialEventCodeNodeArray.getLength > 0
                    
                    for eventCodeCounter = 0:(potentialEventCodeNodeArray.getLength-1)
                        currentNode = potentialEventCodeNodeArray.item(eventCodeCounter); % select a session and make it the current node.
                        singleEventCodeNode = currentNode;
                        
                        potentialCodeNodeArray = currentNode.getElementsByTagName('code');
                        if potentialCodeNodeArray.getLength > 0
                            obj.eventCodesInfo(eventCodeCounter+1).code = obj.readStringFromNode(potentialCodeNodeArray.item(0));
                        else
                            obj.eventCodesInfo(eventCodeCounter+1).code = '';
                        end;
                        
                        potentialCodeTaskLabelNodeArray = currentNode.getElementsByTagName('taskLabel');
                        if potentialCodeTaskLabelNodeArray.getLength > 0
                            obj.eventCodesInfo(eventCodeCounter+1).taskLabel = obj.readStringFromNode(potentialCodeTaskLabelNodeArray.item(0));
                        else
                            obj.eventCodesInfo(eventCodeCounter+1).taskLabel = '';
                        end;
                        
                        potentialCodeConditionNodeArray = singleEventCodeNode.getElementsByTagName('condition');
                        if potentialCodeConditionNodeArray.getLength > 0
                            for codeConditionCounter = 0:(potentialCodeConditionNodeArray.getLength-1)
                                currentNode = potentialCodeConditionNodeArray.item(codeConditionCounter); % select a session and make it the current node.
                                singleCodeNode = currentNode;
                                
                                potentialConditionLabelArray = currentNode.getElementsByTagName('label');
                                if potentialConditionLabelArray.getLength > 0
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).label = obj.readStringFromNode(potentialConditionLabelArray.item(0));
                                else
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).label = '';
                                end;
                                
                                potentialConditionDescriptionArray = currentNode.getElementsByTagName('description');
                                if potentialConditionDescriptionArray.getLength > 0
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).description = obj.readStringFromNode(potentialConditionDescriptionArray.item(0));
                                else
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).description = '';
                                end;
                                
                                potentialConditionTagArray = currentNode.getElementsByTagName('tag');
                                if potentialConditionTagArray.getLength > 0
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).tag = obj.readStringFromNode(potentialConditionTagArray.item(0));
                                else
                                    obj.eventCodesInfo(eventCodeCounter+1).condition(codeConditionCounter+1).tag = '';
                                end;
                            end;
                            
                        end;
                    end;
                    
                    
                end;
                
            end; %ends event codes
            
            
            %starts summary info
            currentNode = studyNode;
            potentialSummaryNodeArray = currentNode.getElementsByTagName('summary');
            if potentialSummaryNodeArray.getLength > 0
                obj.summaryInfo = strtrim(char(potentialSummaryNodeArray.item(0).getFirstChild.getData));
                
                potentialTotalSizeArray = currentNode.getElementsByTagName('totalSize');
                if potentialTotalSizeArray.getLength > 0
                    obj.summaryInfo.totalSize = obj.readStringFromNode(potentialTotalSizeArray.item(0));
                else isempty(obj.summaryInfo.totalSize)
                    obj.summaryInfo.totalSize= '';
                end;
                potentialAllSubjectsHealthyAndNormalArray = currentNode.getElementsByTagName('allSubjectsHealthyAndNormal');
                if potentialAllSubjectsHealthyAndNormalArray.getLength > 0
                    obj.summaryInfo.allSubjectsHealthyAndNormal = obj.readStringFromNode(potentialAllSubjectsHealthyAndNormalArray.item(0));
                else
                    obj.summaryInfo.allSubjectsHealthyAndNorma= '';
                end;
                
                potentialRecordedModalitiesNodeArray = currentNode.getElementsByTagName('recordedModalities'); % inside <Sessions> .. find <session> <session>
                if potentialRecordedModalitiesNodeArray.getLength > 0
                    obj.summaryInfo.recordedModalities = strtrim(char(potentialRecordedModalitiesNodeArray.item(0).getFirstChild.getData));
                    
                    
                    potentialModalityNodeArray = currentNode.getElementsByTagName('modality'); % inside <Sessions> .. find <session> <session>
                    if potentialModalityNodeArray.getLength > 0
                        for modalitycounter = 0:(potentialModalityNodeArray.getLength-1)
                            currentNode = potentialModalityNodeArray.item(modalitycounter); % select a session and make it the current node.
                            singleModalityNode = currentNode;
                            
                            potentialNameNodeArray = currentNode.getElementsByTagName('name');
                            if potentialNameNodeArray.getLength > 0
                                obj.summaryInfo.recordedModalities(modalitycounter+1).name = obj.readStringFromNode(potentialNameNodeArray.item(0));
                            else
                                obj.summaryInfo.recordedModalities(modalitycounter+1).name = '';
                            end;
                            
                            potentialRecordingDeviceNodeArray = currentNode.getElementsByTagName('recordingDevice');
                            if potentialRecordingDeviceNodeArray.getLength > 0
                                obj.summaryInfo.recordedModalities(modalitycounter+1).recordingDevice = obj.readStringFromNode(potentialRecordingDeviceNodeArray.item(0));
                            else
                                obj.summaryInfo.recordedModalities(modalitycounter+1).recordingDevice = '';
                            end;
                            
                            potentialNumberOfSensorsArray = currentNode.getElementsByTagName('numberOfSensors');
                            if potentialNumberOfSensorsArray.getLength > 0
                                obj.summaryInfo.recordedModalities(modalitycounter+1).numberOfSensors = obj.readStringFromNode(potentialNumberOfSensorsArray.item(0));
                            else
                                obj.summaryInfo.recordedModalities(modalitycounter+1).numberOfSensors = '';
                            end;
                            
                            potentialNumberOfChannelsArray = currentNode.getElementsByTagName('numberOfChannels');
                            if potentialNumberOfChannelsArray.getLength > 0
                                obj.summaryInfo.recordedModalities(modalitycounter+1).numberOfChannels = obj.readStringFromNode(potentialNumberOfChannelsArray.item(0));
                            else
                                obj.summaryInfo.recordedModalities(modalitycounter+1).numberOfChannels = '';
                            end;
                            
                            potentialNumberOfCamerasArray = currentNode.getElementsByTagName('numberOfCameras');
                            if potentialNumberOfCamerasArray.getLength > 0
                                obj.summaryInfo.recordedModalities(modalitycounter+1).numberOfCameras = obj.readStringFromNode(potentialNumberOfCamerasArray.item(0));
                            else
                                obj.summaryInfo.recordedModalities(modalitycounter+1).numberOfCameras = '';
                            end;
                        end;
                        
                    end;
                end;
                currentNode = studyNode;
                potentialLicenseNodeArray = currentNode.getElementsByTagName('license');
                if potentialLicenseNodeArray.getLength > 0
                    currentNode = potentialLicenseNodeArray.item(0);
                    obj.summaryInfo.license = strtrim(char(potentialLicenseNodeArray.item(0).getFirstChild.getData));
                    potentialLicenseTypeArray = currentNode.getElementsByTagName('type');
                    if potentialLicenseTypeArray.getLength > 0
                        obj.summaryInfo.license.type = obj.readStringFromNode(potentialLicenseTypeArray.item(0));
                    end;
                    if isempty(obj.summaryInfo.license.type)
                        obj.summaryInfo.license.type= '';
                    end;
                    
                    potentialLicenseTextArray = currentNode.getElementsByTagName('text');
                    if potentialLicenseTextArray.getLength > 0
                        obj.summaryInfo.license.text = obj.readStringFromNode(potentialLicenseTextArray.item(0));
                    end;
                    
                    potentialLicenseLinkArray = currentNode.getElementsByTagName('link');
                    if potentialLicenseLinkArray.getLength > 0
                        obj.summaryInfo.license.link = obj.readStringFromNode(potentialLicenseLinkArray.item(0));
                    end;
                    
                end;
                
            end;%end summary info
            
            
            %start publications info
            currentNode = studyNode;
            
            potentialPublicationsNodeArray = currentNode.getElementsByTagName('publications');
            if potentialPublicationsNodeArray.getLength > 0
                obj.publicationsInfo = strtrim(char(potentialPublicationsNodeArray.item(0).getFirstChild.getData));
                
                potentialPublicationNodeArray = currentNode.getElementsByTagName('publication'); % inside <Sessions> .. find <session> <session>
                if potentialPublicationNodeArray.getLength > 0
                    
                    for publicationCounter = 0:(potentialPublicationNodeArray.getLength-1)
                        currentNode = potentialPublicationNodeArray.item(publicationCounter); % select a session and make it the current node.
                        singlePublicationNode = currentNode;
                        
                        potentialPublicationCitationNodeArray = currentNode.getElementsByTagName('citation');
                        if potentialPublicationCitationNodeArray.getLength > 0
                            obj.publicationsInfo(publicationCounter+1).citation = obj.readStringFromNode(potentialPublicationCitationNodeArray.item(0));
                        else
                            obj.publicationsInfo(publicationCounter+1).citation ='';
                        end;
                        
                        potentialPublicationDOINodeArray = currentNode.getElementsByTagName('DOI');
                        if potentialPublicationDOINodeArray.getLength > 0
                            obj.publicationsInfo(publicationCounter+1).DOI = obj.readStringFromNode(potentialPublicationDOINodeArray.item(0));
                        else
                            obj.publicationsInfo(publicationCounter+1).DOI = '';
                        end;
                        
                        potentialPublicationLinkNodeArray = currentNode.getElementsByTagName('link');
                        if potentialPublicationLinkNodeArray.getLength > 0
                            obj.publicationsInfo(publicationCounter+1).link = obj.readStringFromNode(potentialPublicationLinkNodeArray.item(0));
                        else
                            obj.publicationsInfo(publicationCounter+1).link = '';
                        end;
                    end;
                    
                    
                end;
            else % if subject node is not provided, use an empty array.
                obj.publicationsInfo = [];
            end; %end publications info
            
            
            %start experimenters
            currentNode = studyNode;
            potentialExperimentersNodeArray = currentNode.getElementsByTagName('experimenters');
            if potentialExperimentersNodeArray.getLength > 0
                obj.experimentersInfo = strtrim(char(potentialExperimentersNodeArray.item(0).getFirstChild.getData));
                
                potentialExperimenterNodeArray = currentNode.getElementsByTagName('experimenter'); % inside <Sessions> .. find <session> <session>
                if potentialExperimenterNodeArray.getLength > 0
                    
                    for experimenterCounter = 0:(potentialExperimenterNodeArray.getLength-1)
                        currentNode = potentialExperimenterNodeArray.item(experimenterCounter); % select a session and make it the current node.
                        singleExperimenterNode = currentNode;
                        %name is not showing up
                        potentialExperimenterNameNodeArray = currentNode.getElementsByTagName('name');
                        if potentialExperimenterNameNodeArray.getLength > 0
                            obj.experimentersInfo(experimenterCounter+1).name = obj.readStringFromNode(potentialExperimenterNameNodeArray.item(0));
                        else
                            obj.experimentersInfo(experimenterCounter+1).name = '';
                        end;
                        
                        potentialExperimenterRoleNodeArray = currentNode.getElementsByTagName('role');
                        if potentialExperimenterRoleNodeArray.getLength > 0
                            obj.experimentersInfo(experimenterCounter+1).role = obj.readStringFromNode(potentialExperimenterRoleNodeArray.item(0));
                        else
                            obj.experimentersInfo(experimenterCounter+1) = '';
                        end;
                    end;
                    
                    
                end;
            else
                obj.experimentersInfo= [];
            end; %end experimenters information
            
            
            % start contact info
            currentNode = studyNode;
            
            potentialContactNodeArray = currentNode.getElementsByTagName('contact');
            if potentialContactNodeArray.getLength > 0
                obj.contactInfo = struct;
                currentNode = potentialContactNodeArray.item(0); % go inside the contact node
                potentialContactNameNodeArray = currentNode.getElementsByTagName('name');
                if potentialContactNameNodeArray.getLength > 0
                    obj.contactInfo.name = obj.readStringFromNode(potentialContactNameNodeArray.item(0));
                else
                    obj.contactInfo.name = '';
                end;
                
                potentialContactPhoneNodeArray = currentNode.getElementsByTagName('phone');
                if potentialContactPhoneNodeArray.getLength > 0
                    obj.contactInfo.phone = obj.readStringFromNode(potentialContactPhoneNodeArray.item(0));
                else
                    obj.contactInfo.phone= '';
                end;
                potentialContactEmailNodeArray = currentNode.getElementsByTagName('email');
                if potentialContactEmailNodeArray.getLength > 0
                    obj.contactInfo.email = obj.readStringFromNode(potentialContactEmailNodeArray.item(0));
                else
                    obj.contactInfo.email= '';
                end;
            else
                obj.contactInfo = [];
            end;%end contact info
            
            
            %start organization info
            currentNode = studyNode; % going back to the study node.
            potentialOrgNodeArray = currentNode.getElementsByTagName('organization');
            
            % there are two 'organization' nodes in the ESS, the one that is under <project<funding> and
            % says the organization that has funded the projects, e.g. NIH or NSF and then there is
            % the organization node that is under the study node and contain name and logoLink info.
            % here we need to find the one that is under the study node.
            theItemNumber = [];
            for itemCounter = 0:(potentialOrgNodeArray.getLength-1)
                if potentialOrgNodeArray.item(itemCounter).getParentNode == studyNode
                    theItemNumber = itemCounter;
                end;
            end;
            
            if ~isempty(theItemNumber)
                currentNode = potentialOrgNodeArray.item(theItemNumber);
                potentialOrgNameNodeArray = currentNode.getElementsByTagName('name');
                if potentialOrgNameNodeArray.getLength > 0
                    obj.organizationInfo.name = obj.readStringFromNode(potentialOrgNameNodeArray.item(0));
                else
                    obj.organizationInfo.name = '';
                end;
                
                potentialOrganizationLogoNodeArray = currentNode.getElementsByTagName('logoLink');
                if potentialOrganizationLogoNodeArray.getLength > 0
                    obj.organizationInfo.logoLink = obj.readStringFromNode(potentialOrganizationLogoNodeArray.item(0));
                else
                    obj.organizationInfo.logoLink ='';
                end;
            else
                obj.organizationInfo = struct('name', '', 'logoLink', '');
                
            end;%end organization Info
            
            currentNode = studyNode;
            potentialCopyrightNodeArray = currentNode.getElementsByTagName('copyright');
            if potentialCopyrightNodeArray.getLength > 1
                obj.copyrightInfo = obj.readStringFromNode(potentialCopyrightNodeArray.item(0));
            else
                obj.copyrightInfo = '';
            end;%end copyright Info
            
            currentNode = studyNode;
            potentialIRBNodeArray = currentNode.getElementsByTagName('IRB');
            if potentialIRBNodeArray.getLength > 0
                obj.irbInfo = obj.readStringFromNode(potentialIRBNodeArray.item(0));
            else
                obj.irbInfo = '';
            end;
            
        end;
        
        function obj = write(obj, essFilePath)
            % obj = write(essFilePath)
            %
            % writes the information contained in object p into an ESS-formatted XML file.
            
            if nargin < 2
                error('Please provide the name of the output file in the first input argument');
            end;
            
            docNode = com.mathworks.xml.XMLUtils.createDocument('study');
            docRootNode = docNode.getDocumentElement;
            
            essVersionElement = docNode.createElement('essVersion');
            essVersionElement.appendChild(docNode.createTextNode(obj.essVersion));
            docRootNode.appendChild(essVersionElement);
            
            titleElement = docNode.createElement('title');
            titleElement.appendChild(docNode.createTextNode(obj.studyTitle));
            docRootNode.appendChild(titleElement);
            
            descriptionElement = docNode.createElement('description');
            descriptionElement.appendChild(docNode.createTextNode(obj.studyDescription));
            docRootNode.appendChild(descriptionElement);
            
            uuidElement = docNode.createElement('uuid');
            uuidElement.appendChild(docNode.createTextNode(obj.studyUuid));
            docRootNode.appendChild(uuidElement);
            
            projectElement = docNode.createElement('project');
            projectRootNode=docRootNode.appendChild(projectElement);
            
            for y=1:length(obj.projectInfo)
                fundingElement = docNode.createElement('funding');
                fundingRootNode= projectRootNode.appendChild(fundingElement);
                
                fundingOrganizationElement = docNode.createElement('organization');
                fundingOrganizationElement.appendChild(docNode.createTextNode(obj.projectInfo(y).organization));
                fundingRootNode.appendChild(fundingOrganizationElement);
                
                fundingGrantIdElement = docNode.createElement('grantId');
                fundingGrantIdElement.appendChild(docNode.createTextNode(obj.projectInfo(y).grantId));
                fundingRootNode.appendChild(fundingGrantIdElement);
                
            end;
            
            sessionsElement = docNode.createElement('sessions');
            sessionsRootNode = docRootNode.appendChild(sessionsElement);
            %docRootNode.appendChild(sessionsElement);
            
            for i=1:length(obj.sessionInfo)
                sessionElement = docNode.createElement('session');
                sessionRootNode= sessionsRootNode.appendChild(sessionElement);
                
                numberElement = docNode.createElement('number');
                numberElement.appendChild(docNode.createTextNode (obj.sessionInfo(i).number));
                sessionRootNode.appendChild(numberElement);
                
                sessionTaskLabelElement = docNode.createElement('taskLabel');
                sessionTaskLabelElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).taskLabel));
                sessionRootNode.appendChild(sessionTaskLabelElement);
                
                purposeElement = docNode.createElement('purpose');
                purposeElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).purpose));
                sessionRootNode.appendChild(purposeElement);
                
                labIdElement = docNode.createElement('labId');
                labIdElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).labId));
                sessionRootNode.appendChild(labIdElement);
                
                for j=1:length(obj.sessionInfo(i).subject)
                    subjectElement = docNode.createElement('subject');
                    subjectRootNode= sessionRootNode.appendChild(subjectElement);
                    
                    subjectLabIdElement = docNode.createElement('labId');
                    subjectLabIdElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).labId));
                    subjectRootNode.appendChild(subjectLabIdElement);                    
                    
                    subjectInSessionNumberElement = docNode.createElement('inSessionNumber');
                    subjectInSessionNumberElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).inSessionNumber));
                    subjectRootNode.appendChild(subjectInSessionNumberElement);
                    
                    subjectGroupElement = docNode.createElement('group');
                    subjectGroupElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).group));
                    subjectRootNode.appendChild(subjectGroupElement);
                    
                    subjectGenderElement = docNode.createElement('gender');
                    subjectGenderElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).gender));
                    subjectRootNode.appendChild(subjectGenderElement);
                    
                    subjectYOBElement = docNode.createElement('YOB');
                    subjectYOBElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).YOB));
                    subjectRootNode.appendChild(subjectYOBElement);
                    
                    subjectAgeElement = docNode.createElement('age');
                    subjectAgeElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).age));
                    subjectRootNode.appendChild(subjectAgeElement);
                    
                    subjectHandElement = docNode.createElement('hand');
                    subjectHandElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).hand));
                    subjectRootNode.appendChild(subjectHandElement);
                    
                    subjectVisionElement = docNode.createElement('vision');
                    subjectVisionElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).vision));
                    subjectRootNode.appendChild(subjectVisionElement);
                    
                    subjectHearingElement = docNode.createElement('hearing');
                    subjectHearingElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).hearing));
                    subjectRootNode.appendChild(subjectHearingElement);
                    
                    subjectHeightElement = docNode.createElement('height');
                    subjectHeightElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).height));
                    subjectRootNode.appendChild(subjectHeightElement);
                    
                    subjectWeightElement = docNode.createElement('weight');
                    subjectWeightElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).weight));
                    subjectRootNode.appendChild(subjectWeightElement);
                    
                    subjectMedicationElement = docNode.createElement('medication');
                    medicationRootNode= subjectRootNode.appendChild(subjectMedicationElement);
                    
                    % caffeine and alcohol elements producing error
                    caffeineElement = docNode.createElement('caffeine');
                    caffeineElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).medication.caffeine));
                    medicationRootNode.appendChild(caffeineElement);
                    
                    alcoholElement = docNode.createElement('alcohol');
                    alcoholElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).medication.alcohol));
                    medicationRootNode.appendChild(alcoholElement);
                    
                    
                    subjectChannelLocationsElement = docNode.createElement('channelLocations');
                    subjectChannelLocationsElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).channelLocations));
                    subjectRootNode.appendChild(subjectChannelLocationsElement);
                    
                    subjectChannelLocationTypeElement = docNode.createElement('channelLocationType');
                    subjectChannelLocationTypeElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).subject(j).channelLocationType));
                    subjectRootNode.appendChild(subjectChannelLocationTypeElement);
                end;
                
                channelsElement = docNode.createElement('channels');
                channelsElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).channels));
                sessionRootNode.appendChild(channelsElement);
                
                eegSamplingRateElement = docNode.createElement('eegSamplingRate');
                eegSamplingRateElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).eegSamplingRate));
                sessionRootNode.appendChild(eegSamplingRateElement);
                
                notesElement = docNode.createElement('notes');
                notesRootNode= sessionRootNode.appendChild(notesElement);
                
                noteElement = docNode.createElement('note');
                noteElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).note));
                notesRootNode.appendChild(noteElement);
                
                noteLinkNameElement = docNode.createElement('linkName');
                noteLinkNameElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).linkName));
                notesRootNode.appendChild(noteLinkNameElement);
                
                noteLinkElement = docNode.createElement('link');
                noteLinkElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).link));
                notesRootNode.appendChild(noteLinkElement);
                
                eegRecordingsElement = docNode.createElement('eegRecordings');
                eegRecordingsRootNode= sessionRootNode.appendChild(eegRecordingsElement);
                
                for k=1:length(obj.sessionInfo(i).eegRecording)
                    eegRecordingElement = docNode.createElement('eegRecording');
                    eegRecordingElement.appendChild(docNode.createTextNode(obj.sessionInfo(i).eegRecording{k}));
                    eegRecordingsRootNode.appendChild(eegRecordingElement);
                end;
            end;
            
            tasksElement = docNode.createElement('tasks');
            tasksRootNode=docRootNode.appendChild(tasksElement);
            
            for m=1:length(obj.tasksInfo)
                taskElement = docNode.createElement('task');
                taskRootNode= tasksRootNode.appendChild(taskElement);
                
                taskLabelElement = docNode.createElement('taskLabel');
                taskLabelElement.appendChild(docNode.createTextNode(obj.tasksInfo(m).taskLabel));
                taskRootNode.appendChild(taskLabelElement);
                
                taskTagElement = docNode.createElement('tag');
                taskTagElement.appendChild(docNode.createTextNode(obj.tasksInfo(m).tag));
                taskRootNode.appendChild(taskTagElement);
                
                taskDescriptionElement = docNode.createElement('description');
                taskDescriptionElement.appendChild(docNode.createTextNode(obj.tasksInfo(m).description));
                taskRootNode.appendChild(taskDescriptionElement);
            end;
            
            eventCodesElement = docNode.createElement('eventCodes');
            eventCodesRootNode=docRootNode.appendChild(eventCodesElement);
            
            for n=1:length(obj.eventCodesInfo)
                eventCodeElement = docNode.createElement('eventCode');
                eventCodeRootNode=eventCodesRootNode.appendChild(eventCodeElement);
                
                eventCodeNodeElement = docNode.createElement('code');
                eventCodeNodeElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).code));
                eventCodeRootNode.appendChild(eventCodeNodeElement);
                
                eventCodeTaskLabelElement = docNode.createElement('taskLabel');
                eventCodeTaskLabelElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).taskLabel));
                eventCodeRootNode.appendChild(eventCodeTaskLabelElement);
                
                for p= 1:length(obj.eventCodesInfo(n).condition)
                    eventCodeConditionElement = docNode.createElement('condition');
                    eventCodeConditionRootNode=eventCodeRootNode.appendChild(eventCodeConditionElement);
                    
                    eventCodeConditionLabelElement = docNode.createElement('label');
                    eventCodeConditionLabelElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).condition(p).label));
                    eventCodeConditionRootNode.appendChild(eventCodeConditionLabelElement);
                    
                    eventCodeConditionDescriptionElement = docNode.createElement('description');
                    eventCodeConditionDescriptionElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).condition(p).description));
                    eventCodeConditionRootNode.appendChild(eventCodeConditionDescriptionElement);
                    
                    eventCodeConditionTagElement = docNode.createElement('tag');
                    eventCodeConditionTagElement.appendChild(docNode.createTextNode(obj.eventCodesInfo(n).condition(p).tag));
                    eventCodeConditionRootNode.appendChild(eventCodeConditionTagElement);
                end;
            end;
            
            summaryElement = docNode.createElement('summary');
            summaryRootNode=docRootNode.appendChild(summaryElement);
            
            summaryRecordedModalitiesElement = docNode.createElement('recordedModalities');
            summaryModalitiesRootNode=summaryRootNode.appendChild(summaryRecordedModalitiesElement);
            
            for q=1:length(obj.summaryInfo.recordedModalities)
                summaryModalityElement = docNode.createElement('modality');
                summaryModalityRootNode=summaryModalitiesRootNode.appendChild(summaryModalityElement);
                
                summaryModalityNameElement = docNode.createElement('name');
                summaryModalityNameElement.appendChild(docNode.createTextNode(obj.summaryInfo.recordedModalities(q).name));
                summaryModalityRootNode.appendChild(summaryModalityNameElement);
                
                summaryRecordingDeviceElement = docNode.createElement('recordingDevice');
                summaryRecordingDeviceElement.appendChild(docNode.createTextNode(obj.summaryInfo.recordedModalities(q).recordingDevice));
                summaryModalityRootNode.appendChild(summaryRecordingDeviceElement);
                
                summaryNumberOfSensorsElement = docNode.createElement('numberOfSensors');
                summaryNumberOfSensorsElement.appendChild(docNode.createTextNode(obj.summaryInfo.recordedModalities(q).numberOfSensors));
                summaryModalityRootNode.appendChild(summaryNumberOfSensorsElement);
                
                summaryNumberOfChannelsElement = docNode.createElement('numberOfChannels');
                summaryNumberOfChannelsElement.appendChild(docNode.createTextNode(obj.summaryInfo.recordedModalities(q).numberOfChannels));
                summaryModalityRootNode.appendChild(summaryNumberOfChannelsElement);
                
                summaryNumberOfCamerasElement = docNode.createElement('numberOfCameras');
                summaryNumberOfCamerasElement.appendChild(docNode.createTextNode(obj.summaryInfo.recordedModalities(q).numberOfCameras));
                summaryModalityRootNode.appendChild(summaryNumberOfCamerasElement);
            end;
            
            summaryTotalSizeElement = docNode.createElement('totalSize');
            summaryTotalSizeElement.appendChild(docNode.createTextNode(obj.summaryInfo.totalSize));
            summaryRootNode.appendChild(summaryTotalSizeElement);
            
            summaryAllSubjectsElement = docNode.createElement('allSubjectsHealthyAndNormal');
            summaryAllSubjectsElement.appendChild(docNode.createTextNode(obj.summaryInfo.allSubjectsHealthyAndNormal));
            summaryRootNode.appendChild(summaryAllSubjectsElement);
            
            summaryLicenseElement = docNode.createElement('license');
            summaryLicenseRootNode=summaryRootNode.appendChild(summaryLicenseElement);
            
            summaryLicenseTypeElement = docNode.createElement('type');
            summaryLicenseTypeElement.appendChild(docNode.createTextNode(obj.summaryInfo.license.type));
            summaryLicenseRootNode.appendChild(summaryLicenseTypeElement);
            
            summaryLicenseTextElement = docNode.createElement('text');
            summaryLicenseTextElement.appendChild(docNode.createTextNode(obj.summaryInfo.license.text));
            summaryLicenseRootNode.appendChild(summaryLicenseTextElement);
            
            summaryLicenseLinkElement = docNode.createElement('link');
            summaryLicenseLinkElement.appendChild(docNode.createTextNode(obj.summaryInfo.license.link));
            summaryLicenseRootNode.appendChild(summaryLicenseLinkElement);
            
            publicationsElement = docNode.createElement('publications');
            publicationsRootNode=docRootNode.appendChild(publicationsElement);
            
            for r= 1: length(obj.publicationsInfo)
                publicationElement = docNode.createElement('publication');
                publicationRootNode=publicationsRootNode.appendChild(publicationElement);
                
                publicationCitationElement = docNode.createElement('citation');
                publicationCitationElement.appendChild(docNode.createTextNode(obj.publicationsInfo(r).citation));
                publicationRootNode.appendChild(publicationCitationElement);
                
                publicationDoiElement = docNode.createElement('DOI');
                publicationDoiElement.appendChild(docNode.createTextNode(obj.publicationsInfo(r).DOI));
                publicationRootNode.appendChild(publicationDoiElement);
                
                publicationLinkElement = docNode.createElement('link');
                publicationLinkElement.appendChild(docNode.createTextNode(obj.publicationsInfo(r).link));
                publicationRootNode.appendChild(publicationLinkElement);
                
            end;
            
            experimentersElement = docNode.createElement('experimenters');
            experimentersRootNode=docRootNode.appendChild(experimentersElement);
            
            for x=1:length(obj.experimentersInfo)
                experimenterElement = docNode.createElement('experimenter');
                experimenterRootNode=experimentersRootNode.appendChild(experimenterElement);
                
                experimenterNameElement = docNode.createElement('name');
                experimenterNameElement.appendChild(docNode.createTextNode(obj.experimentersInfo(x).name));
                experimenterRootNode.appendChild(experimenterNameElement);
                
                experimenterRoleElement = docNode.createElement('role');
                experimenterRoleElement.appendChild(docNode.createTextNode(obj.experimentersInfo(x).role));
                experimenterRootNode.appendChild(experimenterRoleElement);
            end;
            
            contactElement = docNode.createElement('contact');
            contactRootNode=docRootNode.appendChild(contactElement);
            
            contactNameElement = docNode.createElement('name');
            contactNameElement.appendChild(docNode.createTextNode(obj.contactInfo.name));
            contactRootNode.appendChild(contactNameElement);
            
            contactPhoneElement = docNode.createElement('phone');
            contactPhoneElement.appendChild(docNode.createTextNode(obj.contactInfo.phone));
            contactRootNode.appendChild(contactPhoneElement);
            
            contactEmailElement = docNode.createElement('email');
            contactEmailElement.appendChild(docNode.createTextNode(obj.contactInfo.email));
            contactRootNode.appendChild(contactEmailElement);
            
            organizationElement = docNode.createElement('organization');
            organizationRootNode=docRootNode.appendChild(organizationElement);
            
            organizationNameElement = docNode.createElement('name');
            organizationNameElement.appendChild(docNode.createTextNode(obj.organizationInfo.name));
            organizationRootNode.appendChild(organizationNameElement);
            
            organizationLogoLinkElement = docNode.createElement('logoLink');
            organizationLogoLinkElement.appendChild(docNode.createTextNode(obj.organizationInfo.logoLink));
            organizationRootNode.appendChild(organizationLogoLinkElement);
            
            copyrightElement = docNode.createElement('copyright');
            copyrightElement.appendChild(docNode.createTextNode(obj.copyrightInfo));
            docRootNode.appendChild(copyrightElement);
            
            IrbElement = docNode.createElement('IRB');
            IrbElement.appendChild(docNode.createTextNode(obj.irbInfo));
            docRootNode.appendChild(IrbElement);
            
            proc = docNode.createProcessingInstruction('xml-stylesheet', 'type="text/xsl" href="xml_style.xsl"');
            
            docNode.insertBefore(proc, docNode.getFirstChild());
            
            xmlwrite(essFilePath, docNode);
        end;
    end;
end