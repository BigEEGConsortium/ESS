function makeIntoArray(variable){
	if (variable.constructor != Array){
		return Array(variable);
	}
	else return variable;
}

function count_array_values(arr) { // returns two arrays, one unique values and the other counts for them.
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

// The template code
var templateSource = document.getElementById('report-template').innerHTML;

// compile the template
var template = Handlebars.compile(templateSource);

// The div/container that we are going to display the report in
var reportPlaceholder = document.getElementById('report');

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

var extracted = {};
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
for (var i=0; i < level1Study.sessionTaskInfo.length; i++){
	for (var j=0; j < level1Study.sessionTaskInfo[i].dataRecording.length; j++){
		var parameterSetLabel = level1Study.sessionTaskInfo[i].dataRecording[j].recordingParameterSetLabel;
		for (var k=0; k < level1Study.recordingParameterSet.length; k++){
			if (level1Study.recordingParameterSet[k].recordingParameterSetLabel == parameterSetLabel){
				var modalitiesInParamerSet = [];
				for (var m=0; m < level1Study.recordingParameterSet[k].modality.length; m++){
					modalitiesInParamerSet.push(level1Study.recordingParameterSet[k].modality[m].type);
					if (level1Study.recordingParameterSet[k].modality[m].type.toUpperCase() == 'EEG'){
						numberOfRecordingEEGChannels.push (1 + parseInt(level1Study.recordingParameterSet[k].modality[m].endChannel) - parseInt(level1Study.recordingParameterSet[k].modality[m].startChannel));
					}
				}
				modalitiesInDataRecording = modalitiesInDataRecording.concat(_.uniq(modalitiesInParamerSet));
			}

		}
	}
}

extracted.numberOfSubjects = _.uniq(labsIds).length;
extracted.subjectGroup = _.uniq(groups);
extracted.eventSpecificiationMethod =  level1Study.eventSpecificiationMethod;

// count the number of recordings that the same number of channels
var result = count_array_values(numberOfRecordingEEGChannels);
var uniqueEEGChannelNumbers = result.uniqueValues;
var numberOfRecordingsWithChannelNumber = result.counts;


// form the string that contains number of EEG channels and the number of data recordings associated with each (in parenthesis)
extracted.numberOfChannels = '';
for (var i=0; i < uniqueEEGChannelNumbers.length; i++){
	extracted.numberOfChannels += uniqueEEGChannelNumbers[i].toString() + ' (' + numberOfRecordingsWithChannelNumber[i].toString() + ' recordings)';
	if (i < uniqueEEGChannelNumbers.length-1){
		extracted.numberOfChannels += ', ';
	}
}

// count the number of recordings that the same number of channels
var result = count_array_values(modalitiesInDataRecording);
var uniqueModalities = result.uniqueValues;
var numberOfRecordingsWithModality = result.counts;


// form the string that contains different modalities and the number of data recordings associated with each (in parenthesis)
extracted.modalities = '';
for (var i=0; i < uniqueModalities.length; i++){
	extracted.modalities += uniqueModalities[i].toString() + ' (' + numberOfRecordingsWithModality[i].toString() + ' recordings)';
	if (i < uniqueModalities.length-1){
		extracted.modalities += ', ';
	}
}

extracted.totalSize = level1Study.summaryInfo.totalSize;
extracted.licenseType = level1Study.summaryInfo.license.type
reportPlaceholder.innerHTML = template(extracted);
