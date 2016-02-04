// --------------------------------  Functions  --------------------------------------
function makeIntoArray(variable){
	if (variable.constructor != Array){
		return Array(variable);
	}
	else return variable;
}

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

function textFromItemsAndCounts(itemStrings, itemCounts, quantityString){
	var text = '';
	if (arguments.length<3)
	var quantityString = '';
	for (var n= 0; n < itemStrings.length;n++) {
		item = itemStrings[n];
		if (typeof(stringValue) != 'string')
		item = item.toString();
		text += item + ' (' + itemCounts[n].toString() + quantityString + ')';
		if (n<itemStrings.length - 1)
		text += ', ';
	}
	return text;
}

// ---------------------------------------------------------------------

level1Study = study.parentStudyObj.level1StudyObj;

// make key variables read from JSON to all be arrays.
level1Study.sessionTaskInfo = makeIntoArray(level1Study.sessionTaskInfo);
for (var i=0; i < level1Study.sessionTaskInfo.length; i++) {
	level1Study.sessionTaskInfo[i].dataRecording  = makeIntoArray(level1Study.sessionTaskInfo[i].dataRecording);
	level1Study.sessionTaskInfo[i].subject  = makeIntoArray(level1Study.sessionTaskInfo[i].subject);
}

level1Study.recordingParameterSet = makeIntoArray(level1Study.recordingParameterSet);
for (var k=0; k < level1Study.recordingParameterSet.length; k++){
	level1Study.recordingParameterSet[k].modality = makeIntoArray(level1Study.recordingParameterSet[k].modality);
	for (var k=0; k < level1Study.recordingParameterSet.length; k++){

	}
}

extracted = {};
extracted.shortDescription = level1Study.studyShortDescription;
extracted.title = study.title;
extracted.fullDescription = level1Study.studyDescription;

extracted.numberOfSessions = level1Study.sessionTaskInfo.length;

// count the number of subjects by looking at labIds. LabIds that are not provided,
//  i.e. are either NA or - are assumed to be unique.
var labsIds = [];
var groups = [];
for (var i=0; i < level1Study.sessionTaskInfo.length; i++) {
	for (var j=0; j < level1Study.sessionTaskInfo[i].subject.length; j++) {
		var labIdValue = level1Study.sessionTaskInfo[i].subject[j].labId;
		if (labIdValue == 'NA' || labIdValue == '-'){
			labIdValue = Math.floor((1 + Math.random()) * 0x1000000000000).toString();
		}
		labsIds[i] = labIdValue;
		groups.push(level1Study.sessionTaskInfo[i].subject[j].group);
	}
}

// look into recordingParameterSets associated with session records
var numberOfRecordingEEGChannels = [];
var modalitiesInDataRecording = []; // what modalities are in the data recording
var channelLocationTypes = [];
var dataRecording = [];
var eegSamplingFrequency = [];
for (var i=0; i < level1Study.sessionTaskInfo.length; i++){
	for (var j=0; j < level1Study.sessionTaskInfo[i].dataRecording.length; j++){
		var parameterSetLabel = level1Study.sessionTaskInfo[i].dataRecording[j].recordingParameterSetLabel;
		for (var k=0; k < level1Study.recordingParameterSet.length; k++){
			if (level1Study.recordingParameterSet[k].recordingParameterSetLabel == parameterSetLabel){
				var modalitiesInParamerSet = [];
				var  modalityNumberOfChannels = [];
				for (var m=0; m < level1Study.recordingParameterSet[k].modality.length; m++){
					modalitiesInParamerSet.push(level1Study.recordingParameterSet[k].modality[m].type);
					var numberOfChannels = 1 + parseInt(level1Study.recordingParameterSet[k].modality[m].endChannel) - parseInt(level1Study.recordingParameterSet[k].modality[m].startChannel);
					modalityNumberOfChannels.push(numberOfChannels);
					if (level1Study.recordingParameterSet[k].modality[m].type.toUpperCase() == 'EEG'){
						numberOfRecordingEEGChannels.push (numberOfChannels);
						// using th length of dataRecording as a proxy for the numberof data recordings so far
						eegSamplingFrequency[dataRecording.length] = level1Study.recordingParameterSet[k].modality[m].samplingRate;
						channelLocationTypes[dataRecording.length] = level1Study.recordingParameterSet[k].modality[m].channelLocationType;
					}
				}
				modalitiesInDataRecording = modalitiesInDataRecording.concat(_.uniq(modalitiesInParamerSet));
			}

		}

		// create text, listing modalities with their number of channels in paranthesis
		modalitiesAndTheirChannelsText = textFromItemsAndCounts(modalitiesInParamerSet, modalityNumberOfChannels);

		dataRecording.push({
			'sessionNumber': level1Study.sessionTaskInfo[i].sessionNumber,
			'taskLabel': level1Study.sessionTaskInfo[i].taskLabel,
			'purpose': level1Study.sessionTaskInfo[i].taskLabel,
			'sessionLabId': level1Study.sessionTaskInfo[i].labId,
			'channelLocationsFilename': level1Study.sessionTaskInfo[i].subject[0].channelLocations,
			'subjectGroup': level1Study.sessionTaskInfo[i].subject[0].group,
			'subjectGender': level1Study.sessionTaskInfo[i].subject[0].gender,
			'subjectYOB': level1Study.sessionTaskInfo[i].subject[0].YOB,
			'subjectAge': level1Study.sessionTaskInfo[i].subject[0].age,
			'subjectLabId': level1Study.sessionTaskInfo[i].subject[0].labId,
			'subjectHandedness': level1Study.sessionTaskInfo[i].subject[0].hand,
			'filename': level1Study.sessionTaskInfo[i].dataRecording[j].filename,
			'eventInstanceFile': level1Study.sessionTaskInfo[i].dataRecording[j].eventInstanceFile,
			'originalFileNameAndPath': level1Study.sessionTaskInfo[i].dataRecording[j].originalFileNameAndPath,
			'modalitiesAndTheirChannelsText': modalitiesAndTheirChannelsText,
			'eegSamplingFrequency': eegSamplingFrequency[channelLocationTypes.length-1]
		})
	}
}

extracted.numberOfSubjects = _.uniq(labsIds).length;
extracted.subjectGroup = _.uniq(groups).toString();
extracted.eventSpecificiationMethod =  level1Study.eventSpecificiationMethod;

// count the number of recordings that the same number of channels
var result = countArrayValues(numberOfRecordingEEGChannels);
var uniqueEEGChannelNumbers = result.uniqueValues;
var numberOfRecordingsWithChannelNumber = result.counts;

// form the string that contains number of EEG channels and the number of data recordings associated with each (in parenthesis)
extracted.numberOfChannels = textFromItemsAndCounts(uniqueEEGChannelNumbers, numberOfRecordingsWithChannelNumber, ' recordings')

// count the number of recordings that the same number of channels
var result = countArrayValues(modalitiesInDataRecording);
var uniqueModalities = result.uniqueValues;
var numberOfRecordingsWithModality = result.counts;


// form the string that contains different modalities and the number of data recordings associated with each (in parenthesis)
extracted.modalities = textFromItemsAndCounts(uniqueModalities, numberOfRecordingsWithModality, ' recordings')

var result = countArrayValues(channelLocationTypes);
extracted.channelLocationTypes = textFromItemsAndCounts(result.uniqueValues, result.counts, ' recordings');

extracted.totalSize = level1Study.summaryInfo.totalSize;
extracted.licenseType = level1Study.summaryInfo.license.type;
extracted.fundingOrganization = level1Study.projectInfo.organization;

// Publications
//level1Study.publicationsInfo =[{'citation': 'some citation 1', 'link': 'http://google.com', 'DOI': 'w5745874584854'},{'citation': 'some citation 2', 'link': '', 'DOI': 'gzsgsg'}];

level1Study.publicationsInfo = makeIntoArray(level1Study.publicationsInfo);
extracted.publications = [];
for (var i=0; i < level1Study.publicationsInfo.length; i++){
	var text = level1Study.publicationsInfo[i].citation;
	var link = level1Study.publicationsInfo[i].link;
	if (level1Study.publicationsInfo[i].DOI != ''){
		text = text + ', DOI: ' + level1Study.publicationsInfo[i].DOI;
		if (link == ''){
			link = 'http://dx.doi.org/' + level1Study.publicationsInfo[i].DOI;
		}
	}
	extracted.publications[i]= {'text': text, 'link':link};
}
// hide publications section when informationis not available
extracted.showPublications = extracted.publications.length != 1 || extracted.publications[0].text != '';

// experimenters
level1Study.experimentersInfo = makeIntoArray(level1Study.experimentersInfo);
extracted.experimenters = [];
for (var i=0; i < level1Study.experimentersInfo.length; i++){
	var text = level1Study.experimentersInfo[i].name;
	var role = level1Study.experimentersInfo[i].role;
	if (role != ''){
		text = role + ': ' + text;
		extracted.experimenters.push(text);
	}
}
// hide publications section when informationis not available
extracted.showExperimenters = extracted.experimenters.length != 1 || extracted.experimenters[0] != '';

var columnDefs = [
	{headerName: "Session", field: "sessionNumber", minWidth: 100, width:100, pinned: true, checkboxSelection: false},
	{headerName: "Task", field: "taskLabel", minWidth: 100, width:100, pinned: true},
	{headerName: "Purpose", field: "purpose", minWidth: 100, width:100},
	{headerName: "EEG Sampling Rate (Hz)", field: "eegSamplingFrequency", minWidth: 200, width:200},
	{headerName: "Modalities (number of channels)", field: "modalitiesAndTheirChannelsText", minWidth: 250, width:250},
	{headerName: "Session Lab Id", field: "sessionLabId", minWidth: 150, width:150},
	{headerName: "Notes", field: "notes", minWidth: 100, width:100},
	{headerName: "Filename", field: "filename", minWidth: 100, width:300},
	{headerName: "Original Filename", field: "originalFileNameAndPath", minWidth: 100, width:300},
	{headerName: "Channel Locations", field: "channelLocationsFilename", minWidth: 100, width:300},
	{headerName: "Subject", cellStyle:{textAlign: 'center', color: 'red'},  children: [
		{headerName: "Group", field: "subjectGroup", minWidth: 80, width:80},
		{headerName: "Gender", field: "subjectGender", minWidth: 100, width:100},
		{headerName: "YOB", field: "subjectYOB", minWidth: 100, width:100},
		{headerName: "Age", field: "subjectAge", minWidth: 70, width:70},
		{headerName: "Handedness", field: "subjectHandedness", minWidth: 130, width:130},
		{headerName: "Lab Id", field: "subjectLabId", minWidth: 130, width:130}
	]},
];

var rowData = dataRecording;

function autoSizeAllGridColumns() {
	var allColumnIds = [];
	columnDefs.forEach( function(columnDef) {
		allColumnIds.push(columnDef.field);
		if (columnDef.children)
		for (var i = 0; i < columnDef.children.length; i++) {
			allColumnIds.push(columnDef.children[i].field);
		}
	});
	extracted.gridOptions.columnApi.autoSizeColumns(allColumnIds);
}

function whenGridIsReady (event){
	autoSizeAllGridColumns();
}

extracted.gridOptions = {
	columnDefs: columnDefs,
	rowData: rowData,
	enableColResize: true,
	enableSorting: true,
//	unSortIcon: true,
	enableFilter: true,
	onReady: whenGridIsReady
};


function onFilterChanged(value) {
    extracted.gridOptions.api.setQuickFilter(value);
}


angular.module('essReportApp',  ["agGrid"]).controller('ReportController', function($scope) {
	// transfer key values from extracted to $scope so they are placed in the html template
	for (var key in extracted) {
		// skip loop if the property is from prototype
		if (!extracted.hasOwnProperty(key)) continue;
		$scope[key] = extracted[key];
	}
	//extracted.gridOptions.api.addEventListener('read', autoSizeAllGridColumns);
});
