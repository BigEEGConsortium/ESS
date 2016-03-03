var _ = require("underscore");
var fs = require('fs');

function median(values) {
	values.sort( function(a,b) {return a - b;} );
	var half = Math.floor(values.length/2);
	if(values.length % 2)
	return values[half];
	else
	return (values[half-1] + values[half]) / 2.0;
}

function hedStringToTags(hedString){
	hedString = hedString.trim();
	hedString = hedString.replace(/\(/g, ""); // need to use g to make it global replace
	hedString = hedString.replace(/\)/g, "");
	hedString = hedString.replace(/~/g, ",");
	hedString = hedString.replace(/\\/g, "/");
	var hedTags = hedString.split(',');
	return hedTags;
}

function trimHedTag(hedTag){
	var trimmedTag = hedTag.trim();
	trimmedTag = trimmedTag.replace("\\", "/");
	// remove the trailing /
	if (trimmedTag.indexOf('/', 0) == 0){
		trimmedTag = trimmedTag.slice(1, trimmedTag.length-1);
	}
	// remove the leading /
	if (trimmedTag.lastIndexOf('/') == trimmedTag.length-1){ // remove the trailing /
		trimmedTag = trimmedTag.slice(0, trimmedTag.length-1);
	}
	return trimmedTag;
}

function makeAllParentHedTags(hedTag)
{
	var parentTags = [];
	hedTag = trimHedTag(hedTag); // leading and trailing /s can mess this algorithm up.
	parentTags[0] = hedTag;
	var startSearchIndex = 0;
	var i = 0;
	while (i>-1 && startSearchIndex < hedTag.length) {
		var i = hedTag.indexOf('/', startSearchIndex);
		if (i>-1){
			startSearchIndex = i+1;
			parentTags.push(hedTag.slice(0, i));
		}
	}
	return 	parentTags
}

function eventCodeNumberOfInstancesToTagCount (eventArray, ignoreTagArray){ // assumes event object has 'numberOfInstances' and 'tag' fields.
// ignoreTagArray contains tags that are not to be counted and are fully removed.
var ignoreTagArray = typeof ignoreTagArray !== 'undefined' ?  ignoreTagArray :['Event/Label', 'Event/Description'];
var tagAndCount = [];
for (var i = 0; i < eventArray.length; i++) {
	var parentHedTags = [];
	var eventHedTags = hedStringToTags(eventArray[i].tag);

	// remove all the tags to be ignored
	for (var j = 0; j < eventHedTags.length; j++) {
		//eventHedTags[j]
	}

	for (var j = 0; j < eventHedTags.length; j++) {
		parentHedTags = parentHedTags.concat(makeAllParentHedTags(eventHedTags[j]));
	}

	parentHedTags = _.uniq(parentHedTags); // remove repeats in each hed string

	for (var k = 0; k < parentHedTags.length; k++) {
		if (parentHedTags[k] in tagAndCount){
			tagAndCount[parentHedTags[k]].count = tagAndCount[parentHedTags[k]].count + eventArray[i].numberOfInstances;
			tagAndCount[parentHedTags[k]].logCount = tagAndCount[parentHedTags[k]].logCount + Math.log(eventArray[i].numberOfInstances);
		}
		else {
			tagAndCount[parentHedTags[k]] = {};
			tagAndCount[parentHedTags[k]].count = eventArray[i].numberOfInstances;
			tagAndCount[parentHedTags[k]].logCount = Math.log(eventArray[i].numberOfInstances);

		}
	}
}

return tagAndCount;
}

function isTagChild(parentTag, potentialChild){
	// self is defined here as NOT a child
	if (parentTag == potentialChild){
		return false;
	}
	return potentialChild.indexOf(parentTag + '/') > -1;
}

function isTagImmediateChild(parentTag, potentialImmediateChild){ // returns true only if the potential child only is  only level HED level lower
	if (isTagChild(parentTag, potentialImmediateChild))
	{
		var difference = potentialImmediateChild.slice(parentTag.length+1, potentialImmediateChild.length);
		return  difference.indexOf('/') == -1; // there are / s left so there is no other level in between
	}
	else return false;
}

function getChildD3Hierarchy(currentTag, tagCount, useLogCount){

	// make a numerical array containing just counts
	var countArray = [];
	for (var tag in tagCount) {
		if (tagCount.hasOwnProperty(tag)) {
			countArray.push(tagCount[tag].count);
		}
	}

	var useLogCount = typeof useLogCount !== 'undefined' ?  useLogCount : Math.max.apply(null, countArray) > 10 * median(countArray);

	var currentTagHierarchy = {};
	console.log(useLogCount);
	currentTagHierarchy.name = currentTag + ' (' + tagCount[currentTag].count + ')';
	if (useLogCount){
		currentTagHierarchy.size = tagCount[currentTag].logCount;
	} else {
		currentTagHierarchy.size = tagCount[currentTag].count;
	}

	for (var tag in tagCount) {
		if (tagCount.hasOwnProperty(tag)) {
			if (isTagImmediateChild(currentTag, tag)){

				if (currentTagHierarchy.hasOwnProperty('children') == false) { // onbly add children property is a child exists
					currentTagHierarchy.children = [];
				}

				currentTagHierarchy.children.push(getChildD3Hierarchy(tag, tagCount));
			}
		}
	}
	return currentTagHierarchy;
}

function convertToD3Hierarchy(tagCount, useLogCount){

	var hierarchy = {};
	hierarchy.name = 'HED';
	hierarchy.children = [];
	// find the topmost tags as they have no parents
	var tagHasAnyParent = [];
	for (var tag1 in tagCount) {
		if (tagCount.hasOwnProperty(tag1)){
			tagHasAnyParent[tag1] = false;
			for (var tag2 in tagCount) {
				if (tagCount.hasOwnProperty(tag2)){
					tagHasAnyParent[tag1] = tagHasAnyParent[tag1] | isTagChild(tag2, tag1);
				}
			}
		}
	}

	for (var tag in tagCount) {
		if (tagCount.hasOwnProperty(tag)){
			if (tagHasAnyParent[tag] == false){
				hierarchy.children.push(getChildD3Hierarchy(tag, tagCount, useLogCount));
			}
		}
	}

	return hierarchy;
}

// ---------------------------------------- test -------------------------

//var eventArray = [{numberOfInstances:5, tag:'/Participant/Effect/Cognitive/Target/'},
//{numberOfInstances:10, tag:'Event/Categorty/Stimulus'},{numberOfInstances:10, tag:'Event/Categorty/Check, Event/Categorty'}];

var eventArray =
[
	{
		"code": "1",
		"taskLabel": "main",
		"label": "non-target",
		"description": "satellite image of London without the white airplane target",
		"tag": "Event\/Label\/Non-target image, Event\/Description\/A non-target image is displayed for about 8 milliseconds, Event\/Category\/Experimental stimulus, (Item\/Natural scene\/Arial\/Satellite, Participant\/Effect\/Cognitive\/Expected\/Non-target, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), Attribute\/Onset",
		"numberOfInstances": 333917
	},
	{
		"code": "2",
		"taskLabel": "main",
		"label": "target frames",
		"description": "satellite image of London with the white airplane target",
		"tag": "Event\/Label\/Target image, Event\/Description\/A white airplane as the RSVP target superimposed on a satellite image is displayed., Event\/Category\/Experimental stimulus, (Item\/Object\/Vehicle\/Aircraft\/Airplane, Participant\/Effect\/Cognitive\/Target, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), (Item\/Natural scene\/Arial\/Satellite, Sensory presentation\/Visual\/Rendering type\/Screen\/2D)",
		"numberOfInstances": 3976
	},
	{
		"code": "4",
		"taskLabel": "main",
		"label": "no targets response",
		"description": "no targets response indicated by pressing left button using dominant hand",
		"tag": "Event\/Label\/NoTrgt BttnPress,  Event\/Description\/No-targets response indicated by pressing left button using dominant hand , Event\/Category\/Participant response, (Participant ~ Action\/Button press\/Keyboard ~ Participant\/Effect\/Body part\/Arm\/Hand\/Finger, Attribute\/Object side\/Left)",
		"numberOfInstances": 5010
	},
	{
		"code": "5",
		"taskLabel": "main",
		"label": "one target response",
		"description": "one target response indicated by pressing right button using dominant hand",
		"tag": "Event\/Label\/OneTrgt BttnPress,  Event\/Description\/One target response indicated by pressing right button using dominant hand, Event\/Category\/Participant response, (Participant ~ Action\/Button press\/Keyboard ~ Participant\/Effect\/Body part\/Arm\/Hand\/Finger, Attribute\/Object side\/Right)",
		"numberOfInstances": 4454
	},
	{
		"code": "6",
		"taskLabel": "main",
		"label": "block start",
		"description": "trials are organized into blocks, this marks the beginning of a new block of trials",
		"tag": "Event\/Label\/Block start, Event\/Description\/Trials are organized into blocks and this marks the beginning of a new block of trials, Event\/Category\/Experiment control\/Sequence\/Block, Attribute\/Onset",
		"numberOfInstances": 1224
	},
	{
		"code": "16",
		"taskLabel": "main",
		"label": "start of trial",
		"description": "fixation cross appears to indicated the start of a new trial followed by a burst of image clips",
		"tag": "Event\/Label\/Trial start, Event\/Description\/Fixation cross appears to indicated the start of a new trial followed by a burst of image clips, Event\/Category\/Experiment control\/Sequence\/Trial, Attribute\/Onset, Event\/Category\/Experimental stimulus\/Instruction\/Fixate, Event\/Category\/Experimental stimulus\/Instruction\/Detect, (Item\/2D shape\/Cross, Attribute\/Visual\/Color\/Gray, Attribute\/Visual\/Fixation point, Participant\/Effect\/Visual, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), Attribute\/Onset",
		"numberOfInstances": 6912
	},
	{
		"code": "32",
		"taskLabel": "main",
		"label": "'correct' feedback\" description",
		"description": "visual feedback 'correct' indicating that the response was correct",
		"tag": "Event\/Label\/Feedback correct, Event\/Description\/Visual feedback with the word Correct indicating that the response was correct, Event\/Category\/Experimental stimulus, Attribute\/Onset, Item\/Symbolic\/Character\/Letter, Attribute\/Visual\/Color\/White, Attribute\/Language\/Unit\/Word\/Adjective, Attribute\/Language\/Unit\/Word\/Correct, Participant\/Effect\/Visual, Sensory presentation\/Visual\/Rendering type\/Screen\/2D, Participant\/Effect\/Cognitive\/Feedback\/Correct, Participant\/Effect\/Cognitive\/Feedback\/Deterministic",
		"numberOfInstances": 3550
	},
	{
		"code": "64",
		"taskLabel": "main",
		"label": "'wrong' feedback",
		"description": "visual feedback 'wrong' indicating that the response was incorrect",
		"tag": "Event\/Label\/Feedback incorrect, Event\/Description\/Visual feedback with the word Wrong indicating that the response was incorrect, Event\/Category\/Experimental stimulus, Attribute\/Onset, Item\/Symbolic\/Character\/Letter, Attribute\/Visual\/Color\/White, Attribute\/Language\/Unit\/Word\/Adjective, Attribute\/Language\/Unit\/Word\/Wrong, Participant\/Effect\/Visual, Sensory presentation\/Visual\/Rendering type\/Screen\/2D, Participant\/Effect\/Cognitive\/Feedback\/Incorrect, Participant\/Effect\/Cognitive\/Feedback\/Deterministic",
		"numberOfInstances": 259
	},
	{
		"code": "129",
		"taskLabel": "main",
		"label": "burst start",
		"description": "the first image of a series of images that are presented in rapid succession",
		"tag": "Event\/Label\/Non-target image, Event\/Description\/A non-target image is displayed for about 8 milliseconds, Event\/Category\/Experimental stimulus, (Item\/Natural scene\/Arial\/Satellite, Participant\/Effect\/Cognitive\/Expected\/Non-target, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), Attribute\/Onset",
		"numberOfInstances": 6906
	}
];

for (var i = 0; i < eventArray.length; i++) {
	//	eventArray[i].numberOfInstances = Math.log(eventArray[i].numberOfInstances) ;
}

//console.log(isTagImmediateChild('Participant/Effect', 'Participant/Effect/Cognitive'));
var tagCount = eventCodeNumberOfInstancesToTagCount(eventArray);
//console.log(tagCount);

//console.log(hedStringToTags('Event/Categorty/check, Event/Categorty'));
//console.log(makeAllParentHedTags('/Participant/Effect/Cognitive/Target/'));
var d3hierarchyJson = JSON.stringify(convertToD3Hierarchy(tagCount));
//console.log(d3hierarchyJson);
fs.writeFile("/home/nima/Documents/mycode/matlab/ESS_scripts/treemap/hedcount.json", d3hierarchyJson, function(err) {
	if(err) {
		return console.log(err);
	}

	console.log("The file was saved!");
});
