// --------------------------------  Utitlity functions and classes  --------------------------------------
function makeIntoArray(variable){
	if (variable.constructor != Array){
		return Array(variable);
	}
	else return variable;
}
//--------------------------------
function countArrayValues(arr) { // returns two arrays, one unique values and the other counts for them.
	var a = [], b = [], prev;

	arr.sort();
	for ( var i = 0; i < arr.length; i++ ) {
		if ( arr[i] !== prev ) {
			a.push(arr[i]);
			b.push(1);
		} else {
			b[b.length-1]++;
		}
		prev = arr[i];
	}

	return {uniqueValues:a, counts:b};
}
//--------------------------------
function textFromItemsAndCounts(itemStrings, itemCounts, quantityString){
	var text = '';
	if (arguments.length<3)
	var quantityString = '';
	for (var n= 0; n < itemStrings.length;n++) {
		if (itemStrings[n] != undefined)
		text +=  itemStrings[n].toString() + ' (' + itemCounts[n].toString() + quantityString + ')';
		if (n<itemStrings.length - 1)
		text += ', ';
	}
	return text;
}
//--------------------------------
function isAvailable(stringValue) {
	return stringValue != 'NA' || stringValue != '-' || stringValue != ' ';
}
//--------------------------------
function getLevelHierarchy(studyObj){
	var studyLevelHierarchy = [];
	var studyLevelHierarchyType = [];
	var currentLevel = study;
	while (true) {
		studyLevelHierarchy.unshift(currentLevel);
		if ("parentStudy" in currentLevel){
			studyLevelHierarchyType.unshift('level-derived');
			currentLevel = currentLevel.parentStudyObj;
		}
		else if ("studyLevel1" in currentLevel) {
			studyLevelHierarchyType.unshift('level2');
			currentLevel = currentLevel.studyLevel1;
		} else if ("eventSpecificationMethod" in currentLevel) {
			studyLevelHierarchyType.unshift('level1');
			break;
		}
	}
	return ({'studyLevelHierarchy': studyLevelHierarchy, 'studyLevelHierarchyType':studyLevelHierarchyType});
}
//-----------------------  Adding HEd Count Treemap  ---------------------------
function addTreemap(root, divId, width, height){

	var color = d3.scale.category20c();

	var treemap = d3.layout.treemap()
	.size([width, height])
	.padding(4)
	.value(function(d) { return d.size; });

	var div = d3.select(divId)
	.style("position", "relative")
	//.style("width", width + "px")
	//	.style("width", "90%")
	.style("height", height + "px");

	div.selectAll(".treemapNode")
	.data(treemap.nodes(root))
	.enter().append("div")
	.attr("class", "treemapNode")
	.style("left", function(d) { return d.x + "px"; })
	.style("top", function(d) { return d.y + "px"; })
	.style("width", function(d) { return Math.max(0, d.dx - 1) + "px"; })
	.style("height", function(d) { return Math.max(0, d.dy - 1) + "px"; })
	.style("background", function(d) { return d.children ? color(d.name) : null; })
	.text(function(d) { return d.children ? null : d.name; });
}
//--------------------------------
class LevelCollection extends Array{
	/*
	LevelCollection is an utility class that guarantees that, after inserting a
	new Level object, only the last non empty one in the hierarchy is enabled while
	lower levels are disabled.
	*/
	constructor(args){
		super(args)
	}
	pushLevel(level){
		if (level instanceof Level1){
			if (!level.isStudyEmpty()){
				for(var k=0; k < this.length;k++){
					this[k].enable = false;
				}
			}
			else level.enable = false;
		}
		this.push(level)
	}
}

// --------------------------------  Parsing classes  --------------------------------------
class Level1 {
	/*
	The Level1 class implements the parsing of sudyLevel1 data embedded in ESS containers.
	Set the boolean property *enable* to render object-specific data in the html report;
	When multiple levels are combined, the utility class *LevelCollection* can handle the
	logic for enable/disable objects.
	*/
	constructor(studyLevelHierarchy) {
		this.enable = false;
		this.shortDescription = "";
		this.fullDescription = "";
		this.showNotice = false;
		this.shortDescription = "";
		this.fullDescription = "";
		this.showNotice = false;
		this.numberOfSubjects = 0;
		this.subjectGroup = [];
		this.dataRecording = [];
		this.dataRecordingsGridOptions = [];
		this.numberOfChannels = 0;
		this.modalities = [];
		this.channelLocationTypes = "";
		this.totalSize = 0;
		this.licenseType = "";
		this.fundingOrganization = [];
		this.publications = [];
		this.showPublications = false;
		this.experimenters = [];
		this.showPointOfContact = false;
		this.pointOfContact = [];
		this.rootURI = "";
		this.showLicensePart = false;
		this.licenseType = "";
		this.showLicenseLink = false;
		this.licenseLink = "";
		this.showLicenseText = false;
		this.licenseText = "";
		this.showIRBPart = false;
		this.IRBtext = "";
		this.showCopyRight = false;
		this.copyrightText  = "";
		this.lastTimeDatarecordingsFilterChanged = new Date();
		this.tasksGridOptions = {};
		this.eventsGridOptions = {};
		var study = this.parseStudy(studyLevelHierarchy, "ess:StudyLevel1");
		this.study = study;
		if (this.isStudyEmpty())
			return;
		this.enable = true;
		this.title = study.title;
		this.totalSize = study.summary.totalSize;
		this.licenseType = study.summary.license.type;
		this.rootURI = '.';
		this.eventSpecificationMethod =  study.eventSpecificationMethod;
		this.numberOfSessions = study.sessions.length;
		this.preamble = this.getPreamble();
		this.parseDescription(study)
		this.parseGroups(study);
		this.parseFundingOrg(study);
		this.parseDataRecordings(study);
		this.parsePublications(study);
		this.parseExperimenters(study);
		this.parsePointOfContact(study);
		this.parseLicense(study);
		this.parseIRB(study);
		this.parseCopyRight(study);
		this.parseTask(study);
		this.parseEvents(study);
	}
	isStudyEmpty(){
		return !this.study;
	}
	getPreamble(){
		// Returns a string that is passed to the *innerHTML* field of the
		// *preamble* element in index.html
		var EEGStudy = "eegstudy.org".link("http://www.eegstudy.org/");
		var ESSMatlab = "ESS tools (MATLAB)".link("https://github.com/BigEEGConsortium/ESS");
		var ESS_L1 = "ESS Standard Data Level 1 container".link("http://www.eegstudy.org/#level1");
		return "This study is an "+ESS_L1+". This means that it contains raw, unprocessed EEG data (and possibly other modalities) arranged in a standard manner. You use the data in the container folder as usual or use "+ESSMatlab+" to automate access and proceesing. For more information pleasee visit "+EEGStudy+".";
	}
	autoSizeAllGridColumns() {
		var allColumnIds = [];
		this.dataRecordingsGridOptions.columnDefs.forEach( function(columnDef) {
			allColumnIds.push(columnDef.field);
			if (columnDef.children)
			for (var i = 0; i < columnDef.children.length; i++) {
				allColumnIds.push(columnDef.children[i].field);
			}
		});
		this.dataRecordingsGridOptions.columnApi.autoSizeColumns(allColumnIds);
	}
	whenDataRecordingsGridIsReady (event){
		this.container.autoSizeAllGridColumns();
		// do it again in 1 second so Angular has time to dynamically render all filenames
		setTimeout(this.autoSizeAllGridColumns, 1000);
	}
	filterDataRecordingsIfNoChange(value) {
		var thisTime = new Date();
		if (thisTime.getTime() - this.lastTimeDatarecordingsFilterChanged.getTime() > 200){
			this.dataRecordingsGridOptions.api.setQuickFilter(value);
		}
	}
	onDataRecordingsFilterChanged(value) {
		this.lastTimeDatarecordingsFilterChanged = new Date();
		setTimeout(this.filterDataRecordingsIfNoChange, 300, value);
	}
	filterEventsIfNoChange(value) {
		var thisTime = new Date();
		if (thisTime.getTime() - this.lastTimeEventsFilterChanged.getTime() > 200){
			this.eventsGridOptions.api.setQuickFilter(value);
		}
	}
	onEventsFilterChanged(value) {
		this.lastTimeDatarecordingsFilterChanged = new Date();
		setTimeout(this.filterEventsIfNoChange, 300, value);
	}
	parseDescription(study){
		this.shortDescription = study.shortDescription;
		this.fullDescription = study.description;
		this.showNotice = true;
	}
	parseGroups(study){
		// count the number of subjects by looking at labIds. LabIds that are not provided,
		//  i.e. are either NA or - are assumed to be unique.
		var groups = [];
		var labsIds = [];
		var labIdValue = "";
		for (var i=0; i < study.sessions.length; i++) {
			for (var j=0; j < study.sessions[i].subjects.length; j++) {
				labIdValue = study.sessions[i].subjects[j].labId;
				if (labIdValue == 'NA' || labIdValue == '-'){
					labIdValue = Math.floor((1 + Math.random()) * 0x1000000000000).toString();
				}
				labsIds[i] = labIdValue;
				groups.push(study.sessions[i].subjects[j].group);
			}
		}
		this.numberOfSubjects = _.uniq(labsIds).length;
		this.subjectGroup = _.uniq(groups).toString();
	}
	parseFundingOrg(study){
		this.fundingOrganization = [];
		for (var i=0; i < study.projectFunding.length; i++){
			this.fundingOrganization += study.projectFunding[i].organization;
			if (study.projectFunding[i].grantId != '' && study.projectFunding[i].grantId != 'NA' && study.projectFunding[i].grantId != '-' )
				this.fundingOrganization += ' (' + study.projectFunding[i].grantId + ')';
			if (i<study.projectFunding.length - 2)
				this.fundingOrganization += ', ';
		}
	}
	parseDataRecordings(study){
		var parameterSetLabel = "";
		var numberOfChannels = 0;
		var numberOfRecordingEEGChannels = [];
		var modalitiesInDataRecording = []; // what modalities are in the data recording
		var modalitiesAndTheirChannelsText = "";
		var channelLocationTypes = [];
		this.dataRecording = [];
		var eegSamplingFrequency = [];
		for (var i=0; i < study.sessions.length; i++){
			for (var j=0; j < study.sessions[i].dataRecordings.length; j++){
				parameterSetLabel = study.sessions[i].dataRecordings[j].recordingParameterSetLabel;
				for (var k=0; k < study.recordingParameterSets.length; k++){
					if (study.recordingParameterSets[k].recordingParameterSetLabel == parameterSetLabel){
						var modalitiesInParamerSet = [];
						var  modalityNumberOfChannels = [];
						for (var m=0; m < study.recordingParameterSets[k].modalities.length; m++){
							modalitiesInParamerSet.push(study.recordingParameterSets[k].modalities[m].type);
							numberOfChannels = 1 + parseInt(study.recordingParameterSets[k].modalities[m].endChannel) - parseInt(study.recordingParameterSets[k].modalities[m].startChannel);
							modalityNumberOfChannels.push(numberOfChannels);
							if (study.recordingParameterSets[k].modalities[m].type.toUpperCase() == 'EEG'){
								numberOfRecordingEEGChannels.push(numberOfChannels);
								// using th length of dataRecording as a proxy for the number of data recordings so far
								eegSamplingFrequency[this.dataRecording.length] = study.recordingParameterSets[k].modalities[m].samplingRate;
								channelLocationTypes[this.dataRecording.length] = study.recordingParameterSets[k].modalities[m].channelLocationType;
							}
						}
						modalitiesInDataRecording = modalitiesInDataRecording.concat(_.uniq(modalitiesInParamerSet));
					}
				}
				// create text, listing modalities with their number of channels in paranthesis
				modalitiesAndTheirChannelsText = textFromItemsAndCounts(modalitiesInParamerSet, modalityNumberOfChannels);
				this.dataRecording.push({
					'sessionNumber': study.sessions[i].number,
					'taskLabel': study.sessions[i].dataRecordings[j].taskLabels.toString(),
					'sessionLabId': study.sessions[i].labId,
					'channelLocationsFilename': study.sessions[i].subjects[j].channelLocationFile,
					'subjectGroup': study.sessions[i].subjects[0].group,
					'subjectGender': study.sessions[i].subjects[0].gender,
					'subjectYOB': study.sessions[i].subjects[0].YOB,
					'subjectAge': study.sessions[i].subjects[0].age,
					'subjectLabId': study.sessions[i].subjects[0].labId,
					'subjectHandedness': study.sessions[i].subjects[0].hand,
					'filename': study.sessions[i].dataRecordings[j].filename,
					'eventInstanceFile': study.sessions[i].dataRecordings[j].eventInstanceFile,
					'originalFileNameAndPath': study.sessions[i].dataRecordings[j].originalFileNameAndPath,
					'modalitiesAndTheirChannelsText': modalitiesAndTheirChannelsText,
					'eegSamplingFrequency': eegSamplingFrequency[channelLocationTypes.length-1]
				})
			}
		}
		var result = countArrayValues(numberOfRecordingEEGChannels);
		var uniqueEEGChannelNumbers = result.uniqueValues;
		var numberOfRecordingsWithChannelNumber = result.counts;
		// form the string that contains number of EEG channels and the number of data recordings associated with each (in parenthesis)
		this.numberOfChannels = textFromItemsAndCounts(uniqueEEGChannelNumbers, numberOfRecordingsWithChannelNumber, ' recordings');

		// count the number of recordings that the same number of channels
		var result = countArrayValues(modalitiesInDataRecording);
		var uniqueModalities = result.uniqueValues;
		var numberOfRecordingsWithModality = result.counts;
		// form the string that contains different modalities and the number of data recordings associated with each (in parenthesis)
		this.modalities = textFromItemsAndCounts(uniqueModalities, numberOfRecordingsWithModality, ' recordings');

		var result = countArrayValues(channelLocationTypes);
		this.channelLocationTypes = textFromItemsAndCounts(result.uniqueValues, result.counts, ' recordings');

		var dataRecordingsColumnDefs = [
			{headerName: "Session", field: "sessionNumber", minWidth: 100, width:100, pinned: true, checkboxSelection: false},
			{headerName: "Task", field: "taskLabel", minWidth: 100, width:100, pinned: true},
			{headerName: "EEG Sampling Rate (Hz)", field: "eegSamplingFrequency", minWidth: 200, width:200},
			{headerName: "Modalities (number of channels)", field: "modalitiesAndTheirChannelsText", minWidth: 250, width:250},
			{headerName: "Session Lab Id", field: "sessionLabId", minWidth: 150, width:150},
			{headerName: "Notes", field: "notes", minWidth: 100, width:100},
			{headerName: "Filename", field: "filename", minWidth: 300, width:300,
			template: '<a href="' + this.rootURI + '/session/{{data.sessionNumber}}/{{data.filename}}""><span ng-bind="data.filename"></span></a>'},
			{headerName: "Original Filename", field: "originalFileNameAndPath", minWidth: 100, width:300},
			{headerName: "Channel Locations", field: "channelLocationsFilename", minWidth: 100, width:300,
			template: '<a href="' + this.rootURI + '/session/{{data.sessionNumber}}/{{data.channelLocationsFilename}}""><span ng-bind="data.channelLocationsFilename"></span></a>'},
			{headerName: "Subject", cellStyle:{textAlign: 'center', color: 'red'},  children: [
				{headerName: "Group", field: "subjectGroup", minWidth: 80, width:80},
				{headerName: "Gender", field: "subjectGender", minWidth: 100, width:100},
				{headerName: "YOB", field: "subjectYOB", minWidth: 100, width:100},
				{headerName: "Age", field: "subjectAge", minWidth: 70, width:70},
				{headerName: "Handedness", field: "subjectHandedness", minWidth: 130, width:130},
				{headerName: "Lab Id", field: "subjectLabId", minWidth: 130, width:130}
			]},
		];
		this.dataRecordingsGridOptions = {
			columnDefs: dataRecordingsColumnDefs,
			rowData: this.dataRecording,
			enableColResize: true,
			enableSorting: true,
			//	unSortIcon: true,
			enableFilter: true,
			suppressMenuHide: true,
			angularCompileRows: true, // for template
			onReady: this.whenDataRecordingsGridIsReady,
			container: this
		};
		// without this if there is only one row it becomes hidden.
		if (this.dataRecordingsGridOptions.rowData.length < 3){
			this.dataRecordingsGridOptions.rowHeight = 75;
		}
		// To prevent stuttering, run the grid filter only when
		// there was not a chage of value right before it.
		this.lastTimeDatarecordingsFilterChanged = new Date();
	}
	parsePublications(study){
		// Publications
		//levelStudy.publications =[{'citation': 'some citation 1', 'link': 'http://google.com', 'DOI': 'w5745874584854'},{'citation': 'some citation 2', 'link': '', 'DOI': 'gzsgsg'}];
		this.publications = [];
		var text = study.publications[0].citation;
		var link = study.publications[0].link;
		for (var i=0; i < study.publications.length; i++){
			text = study.publications[i].citation;
			link = study.publications[i].link;
			if (study.publications[i].DOI != '' || study.publications[i].DOI != 'NA' || study.publications[i].DOI != '-'){
				text = text + ', DOI: ' + study.publications[i].DOI;
				if (link == ''){
					link = 'http://dx.doi.org/' + study.publications[i].DOI;
				}
			}
			this.publications[i]= {'text': text, 'link':link};
		}
		// hide publications section when informationis not available
		this.showPublications = study.publications[0].citation != 'NA' &&  study.publications[0].citation != '-' && study.publications[0].citation != '';
	}
	parseExperimenters(study){
		this.experimenters = [];
		var middleNameSpace = ' ';
		var text = '';
		var role = '';
		for (var i=0; i < study.experimenters.length; i++){
			if (isAvailable(study.experimenters[i].givenName) || isAvailable(study.experimenters[i].familyName)){
				if (isAvailable(study.experimenters[i].additionalName))
					middleNameSpace = ' ';
				else
					middleNameSpace = '';
				text = study.experimenters[i].givenName + middleNameSpace + study.experimenters[i].additionalName + ' ' + study.experimenters[i].familyName;
			} else var text = '';
			role = study.experimenters[i].role;
			if (role != ''){
				text = role + ': ' + text;
				this.experimenters.push(text);
			}
		}
		this.showExperimenters = this.experimenters.length != 1 || this.experimenters[0] != '';
	}
	parsePointOfContact(study){
		this.showPointOfContact = study.contact.email != '' || study.contact.email != '-' || study.contact.email != '-';
		this.pointOfContact = '';
		if (isAvailable(study.contact.givenName) || isAvailable(study.contact.familyName)){
			if (isAvailable(study.contact.additionalName))
				var middleNameSpace = ' ';
			else
				var middleNameSpace = '';
			this.pointOfContact = study.contact.givenName + middleNameSpace + study.contact.additionalName + ' ' + study.contact.familyName;
		}
		if (this.pointOfContact !=''){
			this.pointOfContact += ', ';
		}
		this.pointOfContact += 'Email: ' + study.contact.email;
		if (this.pointOfContact !=''){
			this.pointOfContact += ', ';
		}
		if (this.pointOfContact !='' && isAvailable(study.contact.phone)){
			this.pointOfContact += 'Phone: ' + study.contact.phone;
		}
	}
	parseLicense(study){
		this.showLicensePart = isAvailable(study.summary.license.link) ||  isAvailable(study.summary.license.type) ||  isAvailable(study.summary.license.text);
		this.licenseType = study.summary.license.type;
		this.showLicenseLink = isAvailable(study.summary.license.link);
		this.licenseLink = study.summary.license.link;
		this.showLicenseText = isAvailable(study.summary.license.text);
		this.licenseText = study.summary.license.text;
	}
	parseIRB(study){
		this.showIRBPart = isAvailable(study.IRB);
		this.IRBtext = study.IRB;
	}
	parseCopyRight(study){
		this.showCopyRight = isAvailable(study.copyright);
		this.copyrightText  = study.copyright;
	}
	parseStudy(studyLevelHierarchy,levelType){
		for(var n=0; n < studyLevelHierarchy.length;n++){
			if(studyLevelHierarchy[n].type==levelType){
				return studyLevelHierarchy[n];
			}
		}
		return null;
	}
	parseTask(study){
		var tasksColumnDefs = [
			{headerName: "Task Label", field: "taskLabel", minWidth: 200, width:200},
			{headerName: "Description", field: "description", minWidth: 400, width:400},
			{headerName: "HED Tags", field: "tag", minWidth: 400, width:400}
		];
		this.tasksGridOptions = {
			columnDefs: tasksColumnDefs,
			rowData:study.tasks,
			enableColResize: true,
			enableSorting: true,
			enableFilter: true,
		};
		// without this if there is only one row it becomes hidden.
		if (this.tasksGridOptions.rowData.length == 1){
			this.tasksGridOptions.rowHeight = 55;
		}
	}
	parseEvents(study){
		// Events grid
		var eventsColumnDefs = [
			{headerName: "Event Code", field: "code", minWidth: 150, width:150, pinned: true},
			{headerName: "Task", field: "taskLabel", minWidth: 200, width:200},
			{headerName: "Number of Instances", field: "numberOfInstancesAsString", minWidth: 200, width:200},
			{headerName: "Label", field: "label", minWidth: 400, width:400},
			{headerName: "Description", field: "description", minWidth: 200, width:500, cellStyle: {'white-space': 'pre-wrap'}},
			{headerName: "HED Tags", field: "tag", minWidth:2300, width:600,cellStyle: {'white-space': 'pre-wrap'}}
		];
		var eventData = study.eventCodes;
		for (var i = 0; i < eventData.length; i++) {
			if (eventData[i].numberOfInstances>=0)	{
				eventData[i].numberOfInstancesAsString = eventData[i].numberOfInstances.toLocaleString();
			}
			else eventData[i].numberOfInstancesAsString = 'NA'
		}
		this.eventsGridOptions = {
		columnDefs: eventsColumnDefs,
		rowData:eventData,
		enableColResize: true,
		enableSorting: true,
		enableFilter: true,
		suppressMenuHide: true,
		rowHeight: 60
		};
	}
}

class Level2 extends Level1{
	/*
	The Level2 class implements the parsing of sudyLevel2-specific data embedded
	in an ESS container. The class augments Level1 with level2-specific data.
	*/
	constructor(studyLevelHierarchy){
		super(studyLevelHierarchy);
		this.enable = false;
		this.study = this.parseStudy(studyLevelHierarchy, "ess:StudyLevel2");
		if (this.isStudyEmpty())
			return;
		this.enable = true;
		this.preamble = this.getPreamble();
		this.parseDataQuality(this.study);
		this.parseLevel2(this.study);
	}
	parseDataQuality(study){
		var quality = [];
		for(var k=0;k<study.studyLevel2Files.length;k++){
			quality[k] = study.studyLevel2Files[k].dataQuality;
		}
		var uniqueQuality = quality.filter((v, i, a) => a.indexOf(v) == i);
		var dataQuality = "";
		var n = 0;
		for(var k=0;k<uniqueQuality.length;k++){
			n = quality.filter((v, i) => v == uniqueQuality[k]).length;
			dataQuality = dataQuality.concat(n.toString()," (",uniqueQuality[k],"), ");
		}
		this.dataQuality = dataQuality.substring(0,dataQuality.length-2);
	}
	parseLevel2(study){
		// Collect Level2-specific fields
		var quality = [];
		var filename = [];
		var report = [];
		var level2Id = [];
		var numberOfInterpChannels = [];
		for (var k=0; k < study.studyLevel2Files.length; k++){
			filename[k] = study.studyLevel2Files[k].studyLevel2FileName;
			report[k] = study.studyLevel2Files[k].reportFileName;
			level2Id[k] = study.studyLevel2Files[k].dataRecordingId;
			numberOfInterpChannels[k] = study.studyLevel2Files[k].interpolatedChannels.length;
			quality[k] = study.studyLevel2Files[k].dataQuality;
		}

		// Collect Level1 IDs
		var level1Id = [];
		for (var i=0; i < study.studyLevel1.sessions.length; i++){
			for (var j=0; j < study.studyLevel1.sessions[i].dataRecordings.length; j++){
				level1Id[level1Id.length] = study.studyLevel1.sessions[i].dataRecordings[j].dataRecordingId.replace("ess:recording/","");
			}
		}

		// Add Level2 fields to the Level1 table filtering by Level2 IDs
		var dataRecordingFilt = [];
		var rowData = [];
		var ind = 0;
		for (var k=0; k < level2Id.length; k++){
			ind = level1Id.indexOf(level2Id[k]);
			rowData[k] = this.dataRecordingsGridOptions.rowData[ind];
			rowData[k].filename = filename[k];
			rowData[k].reportFileName = report[k];
			rowData[k].numberOfInterpChannels = numberOfInterpChannels[k];
			rowData[k].quality = quality[k];
		}

		// Reorder some columns for presenting Level2 information
		// Remove channelLocationFile from the table because at this level
		// that information was absorbed into the .set file already
		var rmInd = this.dataRecordingsGridOptions.columnDefs.findIndex(x => x.headerName=="Channel Locations");
		this.dataRecordingsGridOptions.columnDefs.splice(rmInd,1);

		// Insert the report file next to the processed file
		var reportCol = {headerName: "Report file", field: "reportFileName", minWidth: 300, width:300,
		template: '<a href="' + this.rootURI + '/session/{{data.sessionNumber}}/{{data.reportFileName}}""><span ng-bind="data.filename"></span></a>'};
		var ind = this.dataRecordingsGridOptions.columnDefs.findIndex(x => x.headerName=="Original Filename");
		this.dataRecordingsGridOptions.columnDefs.splice(ind,0, reportCol);

		// Move notes field to the far right and put interpCol in its place
		var ind = this.dataRecordingsGridOptions.columnDefs.findIndex(x => x.headerName=="Notes");
		var tmp = this.dataRecordingsGridOptions.columnDefs[ind];
		var interpCol = {headerName: "Interpolated channels", field: "numberOfInterpChannels", minWidth: 180, width:300};
		this.dataRecordingsGridOptions.columnDefs.splice(ind,1,interpCol);
		this.dataRecordingsGridOptions.columnDefs[this.dataRecordingsGridOptions.columnDefs.length] = tmp;

		// Insert data quality column
		var qualityCol = {headerName: "Data quality", field: "quality", minWidth: 150, width:300};
		this.dataRecordingsGridOptions.columnDefs.splice(ind,0,qualityCol);

		// Update rowData
		this.dataRecordingsGridOptions.rowData = rowData

		// Make sure that the table is rendered with enough height when there are
		// only a few rows
		if (this.dataRecordingsGridOptions.rowData.length < 4){
			this.dataRecordingsGridOptions.rowHeight = 75;
		}
		this.lastTimeDatarecordingsFilterChanged = new Date();
	}
	getPreamble(){
		// Returns a string that is passed to the *innerHTML* field of the
		// *preamble* element in index.html
		var EEGStudy = "eegstudy.org".link("http://www.eegstudy.org/");
		var ESSMatlab = "ESS tools (MATLAB)".link("https://github.com/BigEEGConsortium/ESS");
		var ESS_L2 = "ESS Standard Data Level 2 container".link("http://www.eegstudy.org/#level2");
		var PREP = "PREP pipeline".link("http://vislab.github.io/EEG-Clean-Tools/");
		return "This study is an "+ESS_L2+". This means that raw EEG data has been processed with "+PREP+", i.e. re-referenced with a robust average reference. Data files have been arranged in a standard manner. You use the data in the container folder as usual or use "+ESSMatlab+" to automate access and proceesing. For more information pleasee visit "+EEGStudy+"."
	}
}

class LevelDerived extends Level1{
	/*
	The LevelDerived class implements the parsing of sudyLevelDerived-specific data
	embedded in an ESS container. The class augments Level1 with levelDerived-specific
	data.
	*/
	constructor(studyLevelHierarchy){
		super(studyLevelHierarchy);
		this.enable = false;
		this.preamble = this.getPreamble();
		this.study = this.parseStudy(studyLevelHierarchy, "ess:StudyLevelDerived");
		if (this.isStudyEmpty())
			return;
		this.enable = true;
	}
	getPreamble(){
		// Returns a string that is passed to the *innerHTML* field of the
		// *preamble* element in index.html
		var EEGStudy = "eegstudy.org".link("http://www.eegstudy.org/");
		var ESSMatlab = "ESS tools (MATLAB)".link("https://github.com/BigEEGConsortium/ESS");
		return "This study is an ESS Standard Data Level-Derived container. This means that it contains data after one or more levels of procesing. Data files have been arranged in a standard manner. You use the data in the container folder as usual or use "+ESSMatlab+" to automate access and proceesing.  For more information pleasee visit "+EEGStudy+"."
	}
}

// --------------------------------  Decoding script  --------------------------------------
result = getLevelHierarchy(study);

// Parse Level1
level1 = new Level1(result.studyLevelHierarchy);
var collection = new LevelCollection(level1); 		// The collection object assures that only the last non empty level is enabled

// Parse Level2
level2 = new Level2(result.studyLevelHierarchy);
collection.pushLevel(level2);

// Parse LevelDerived
levelDerived = new LevelDerived(result.studyLevelHierarchy);
collection.pushLevel(levelDerived);

var extracted = {'level1':level1, 'level2':level2, 'levelDerived':levelDerived};

var d3Hierarchy = convertToD3Hierarchy(eventCodeNumberOfInstancesToTagCount(level1.study.eventCodes));

//---------------------- setting up AngularJS ----------------------------------

angular.module('essReportApp',  ["agGrid"]).controller('ReportController', function($scope) {
	// transfer key values from extracted to $scope so they are placed in the html template
	for (var key in extracted) {
		// skip loop if the property is from prototype
		if (!extracted.hasOwnProperty(key)) continue;
		$scope[key] = extracted[key];
	}
	addTreemap(d3Hierarchy, "#treemap", 1200, 800);
});
