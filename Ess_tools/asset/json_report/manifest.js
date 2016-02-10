receiveEssDocument({
	"essVersion": "2.1",
	"title": "RSVP Study",
	"shortDescription": "Rapid Serial Visual Presentation (12Hz) Target (airplane) detection without immediate response",
	"description": "The purpose of this study was to explore the neural basis of target detection in human brain and to compare the performance of brain-computer interface (BCI) methods in classification of target vs. non-target images. The data was acquired during a rapid serial visual presentation task which was composed of a sequential presentation of image clips in rapid succession (12\/s) in 4.1-s bursts, to which subjects were to indicate whether or not the satellite image clips of London presented included a small target airplane image by making one of two button presses. To indicate that they did see the target airplane feature, subjects pressed the right button and to indicate that they did not see the target airplane feature, subjects pressed the left button. During the training sessions, feedback ('correct' or 'incorrect') was given based on the subject's response, but this feedback was omitted during the testing sessions.",
	"rootURI": ".",
	"eventSpecificiationMethod": "Codes",
	"isInEssContainer": "Yes",
	"recordingParameterSets": [
		{
			"recordingParameterSetLabel": "parameter_set_1",
			"modality": [
				{
					"type": "EEG",
					"samplingRate": 256,
					"name": "BIOSEMI",
					"description": "NA",
					"startChannel": 1,
					"endChannel": 256,
					"subjectInSessionNumber": "1",
					"referenceLocation": "CMS",
					"referenceLabel": "CMS",
					"channelLocationType": "Custom",
					"channelLabel": "A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29, A30, A31, A32, B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, B11, B12, B13, B14, B15, B16, B17, B18, B19, B20, B21, B22, B23, B24, B25, B26, B27, B28, B29, B30, B31, B32, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24, C25, C26, C27, C28, C29, C30, C31, C32, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16, D17, D18, D19, D20, D21, D22, D23, D24, D25, D26, D27, D28, D29, D30, D31, D32, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, E18, E19, E20, E21, E22, E23, E24, E25, E26, E27, E28, E29, E30, E31, E32, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24, F25, F26, F27, F28, F29, F30, F31, F32, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, G14, G15, G16, G17, G18, G19, G20, G21, G22, G23, G24, G25, G26, G27, G28, G29, G30, G31, G32, H1, H2, H3, H4, H5, H6, H7, H8, H9, H10, H11, H12, H13, H14, H15, H16, H17, H18, H19, H20, H21, H22, H23, H24, EXG1, EXG2, EXG3, EXG4, EXG5, EXG6, EXG7, EXG8",
					"nonScalpChannelLabel": "EXG1, EXG2, EXG3, EXG4, EXG5, EXG6, EXG7, EXG8"
				},
				{
					"type": "Noise",
					"samplingRate": 256,
					"name": "Biosemi and experiment control",
					"description": "these channels contains a combination of non-connected EEG leads and various experiment control markers  such as image ID (channel 289). The last channel contains event codes.",
					"startChannel": 257,
					"endChannel": 290,
					"subjectInSessionNumber": "1",
					"referenceLocation": "NA",
					"referenceLabel": "NA",
					"channelLocationType": "NA",
					"channelLabel": "non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, non-connected EEG, RSVP image ID, Event code",
					"nonScalpChannelLabel": "NA"
				}
			]
		}
	],
	"eventCodes": [
		{
			"code": "1",
			"taskLabel": "main",
			"label": "non-target",
			"description": "satellite image of London without the white airplane target",
			"tag": "Event\/Label\/Non-target image, Event\/Description\/A non-target image is displayed for about 8 milliseconds, Event\/Category\/Experimental stimulus, (Item\/Natural scene\/Arial\/Satellite, Participant\/Effect\/Cognitive\/Non-target, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), Attribute\/Onset"
		},
		{
			"code": "2",
			"taskLabel": "main",
			"label": "target frames",
			"description": "satellite image of London with the white airplane target",
			"tag": "Event\/Label\/Target image, Event\/Description\/A white airplane (the RSVP target) superimposed on a satellite image is displayed., Event\/Category\/Experimental stimulus, (Item\/Object\/Vehicle\/Aircraft\/Airplane, Participant\/Effect\/Cognitive\/Target, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), (Item\/Natural scene\/Arial\/Satellite, Sensory presentation\/Visual\/Rendering type\/Screen\/2D)"
		},
		{
			"code": "4",
			"taskLabel": "main",
			"label": "no targets response",
			"description": "no targets response indicated by pressing left button using dominant hand",
			"tag": "Event\/Label\/NoTrgt BttnPress,  Event\/Description\/No-targets response indicated by pressing left button using dominant hand , Event\/Category\/Participant response, (Participant ~ Action\/Type\/Button press\/Keyboard ~ Participant\/Effect\/Body part\/Arm\/Hand\/Finger, Attribute\/Object side\/Left)"
		},
		{
			"code": "5",
			"taskLabel": "main",
			"label": "one target response",
			"description": "one target response indicated by pressing right button using dominant hand",
			"tag": "Event\/Label\/OneTrgt BttnPress,  Event\/Description\/One target response indicated by pressing right button using dominant hand, Event\/Category\/Participant response, (Participant ~ Action\/Type\/Button press\/Keyboard ~ Participant\/Effect\/Body part\/Arm\/Hand\/Finger, Attribute\/Object side\/Right)"
		},
		{
			"code": "6",
			"taskLabel": "main",
			"label": "block start",
			"description": "trials are organized into blocks, this marks the beginning of a new block of trials",
			"tag": "Event\/Label\/Block start, Event\/Description\/Trials are organized into blocks and this marks the beginning of a new block of trials, Event\/Category\/Experiment control\/Sequence\/Block, Attribute\/Onset"
		},
		{
			"code": "16",
			"taskLabel": "main",
			"label": "start of trial",
			"description": "fixation cross appears to indicated the start of a new trial followed by a burst of image clips",
			"tag": "Event\/Label\/Trial start, Event\/Description\/Fixation cross appears to indicated the start of a new trial followed by a burst of image clips, Event\/Category\/Experiment control\/Sequence\/Trial, Attribute\/Onset, Event\/Category\/Experimental stimulus\/Instruction\/Fixate, Event\/Category\/Experimental stimulus\/Instruction\/Detect, (Item\/2D shape\/Cross, Attribute\/Visual\/Color\/Gray, Attribute\/Visual\/Fixation point, Participant\/Effect\/Visual, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), Attribute\/Onset"
		},
		{
			"code": "32",
			"taskLabel": "main",
			"label": "'correct' feedback\" description",
			"description": "visual feedback 'correct' indicating that the response was correct",
			"tag": "Event\/Label\/Feedback correct, Event\/Description\/Visual feedback with the word Correct indicating that the response was correct, Event\/Category\/Experiment stimulus, Attribute\/Onset, Item\/Symbolic\/Character\/Letter, Attribute\/Visual\/Color\/White, Attribute\/Language\/Unit\/Word\/Adjective, Attribute\/Language\/Unit\/Word\/Correct, Participant\/Effect\/Visual, Sensory presentation\/Visual\/Rendering type\/Screen\/2D, Participant\/Effect\/Cognitive\/Feedback\/Correct, Participant\/Effect\/Cognitive\/Feedback\/Deterministic"
		},
		{
			"code": "64",
			"taskLabel": "main",
			"label": "'wrong' feedback",
			"description": "visual feedback 'wrong' indicating that the response was incorrect",
			"tag": "Event\/Label\/Feedback incorrect, Event\/Description\/Visual feedback with the word Wrong indicating that the response was incorrect, Event\/Category\/Experiment stimulus, Attribute\/Onset, Item\/Symbolic\/Character\/Letter, Attribute\/Visual\/Color\/White, Attribute\/Language\/Unit\/Word\/Adjective, Attribute\/Language\/Unit\/Word\/Wrong, Participant\/Effect\/Visual, Sensory presentation\/Visual\/Rendering type\/Screen\/2D, Participant\/Effect\/Cognitive\/Feedback\/Incorrect, Participant\/Effect\/Cognitive\/Feedback\/Deterministic"
		},
		{
			"code": "129",
			"taskLabel": "main",
			"label": "burst start",
			"description": "the first image of a series of images that are presented in rapid succession",
			"tag": "Event\/Label\/Non-target image, Event\/Description\/A non-target image is displayed for about 8 milliseconds, Event\/Category\/Experimental stimulus, (Item\/Natural scene\/Arial\/Satellite, Participant\/Effect\/Cognitive\/Non-target, Sensory presentation\/Visual\/Rendering type\/Screen\/2D), Attribute\/Onset"
		}
	],
	"summary": {
		"totalSize": "930.8 MB",
		"allSubjectsHealthyAndNormal": "Yes",
		"license": {
			"type": "CC0",
			"text": "The person who associated a work with this deed has dedicated the work to the public domain by waiving all of his or her rights to the work worldwide under copyright law, including all related and neighboring rights, to the extent allowed by law. You can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission. \n        In no way are the patent or trademark rights of any person affected by CC0, nor are the rights that other persons may have in the work or in how the work is used, such as publicity or privacy rights.\n        Unless expressly stated otherwise, the person who associated a work with this deed makes no warranties about the work, and disclaims liability for all uses of the work, to the fullest extent permitted by applicable law.\n        When using or citing the work, you should not imply endorsement by the author or the affirmer.",
			"link": "License.txt"
		}
	},
	"contact": {
		"name": "Nima Bigdely-Shamlo",
		"phone": "858-822-7538",
		"email": "[use FIRSTNAME from above]@sccn.ucsd.edu"
	},
	"organization": {
		"name": "Swartz Center of Computational Neuroscience, INC, UCSD",
		"logoLink": "SCCN.jpg"
	},
	"copyright": "NA",
	"IRB": "This data was recorded under the approval of the Institutional Review Board (IRB) of the University of California, San Diego (#071254).",
	"type": "essStudyLevel1",
	"dateCreated": "",
	"dateModified": "2016-02-09T18:06:47",
	"id": "eegstudy.org\/id\/f99f8510-2444-4702-91e9-7ec153254cfc",
	"projectFunding": [
		{
			"organization": "Swartz Center for Computational Neuroscience, UCSD",
			"grantId": "NA"
		}
	],
	"sessions": [
		{
			"number": "1",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp44",
			"notes": {
				"note": " ",
				"linkName": " ",
				"link": " "
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_1_task_main_subjectLabId_10__1_KMM_recording_1.bdf",
					"dataRecordingUuid": "d7d122a1-4da9-47c4-b1a2-41ad8b554f2e",
					"startDateTime": "20070315T132435",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_1_task_main_subjectLabId_10__1_KMM_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\1\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "10",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "1978",
					"age": "29",
					"hand": "right",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_1_task_main_subjectLabId_10__1_KMM_recording_1.elp"
				}
			]
		},
		{
			"number": "2",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp45",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_2_task_main_subjectLabId_19__1_3y4_recording_1.bdf",
					"dataRecordingUuid": "fbf9868c-b72e-4d88-a4de-a897e7ffc4a7",
					"startDateTime": "20070327T123832",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_2_task_main_subjectLabId_19__1_3y4_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\2\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "19",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "1984",
					"age": "23",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_2_task_main_subjectLabId_19__1_3y4_recording_1.elp"
				}
			]
		},
		{
			"number": "3",
			"taskLabel": "main",
			"purpose": "testing",
			"labId": "exp47",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_3_task_main_subjectLabId_20__1_eKd_recording_1.bdf",
					"dataRecordingUuid": "543cc187-8cf2-4bf4-aa4c-fbb2ba613940",
					"startDateTime": "20070406T155727",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_3_task_main_subjectLabId_20__1_eKd_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\3\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "20",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_3_task_main_subjectLabId_20__1_eKd_recording_1.elp"
				}
			]
		},
		{
			"number": "4",
			"taskLabel": "main",
			"purpose": "testing",
			"labId": "exp48",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_4_task_main_subjectLabId_10__1_RRZ_recording_1.bdf",
					"dataRecordingUuid": "dea384dd-21c0-4fcd-a8a0-b62fab4a9614",
					"startDateTime": "20070412T183539",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_4_task_main_subjectLabId_10__1_RRZ_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\4\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "10",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "1978",
					"age": "29",
					"hand": "right",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_4_task_main_subjectLabId_10__1_RRZ_recording_1.elp"
				}
			]
		},
		{
			"number": "5",
			"taskLabel": "main",
			"purpose": "testing",
			"labId": "exp49",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_5_task_main_subjectLabId_19__1_2YA_recording_1.bdf",
					"dataRecordingUuid": "b9a395da-2190-4a96-9f3e-4075f5f35d72",
					"startDateTime": "20070418T200711",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_5_task_main_subjectLabId_19__1_2YA_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\5\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "19",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "1984",
					"age": "23",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_5_task_main_subjectLabId_19__1_2YA_recording_1.elp"
				}
			]
		},
		{
			"number": "6",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp50",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_6_task_main_subjectLabId_20__1_siD_recording_1.bdf",
					"dataRecordingUuid": "ca4e8702-b859-47b5-b748-4d4d2d20ee05",
					"startDateTime": "20070420T155027",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_6_task_main_subjectLabId_20__1_siD_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\6\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "20",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_6_task_main_subjectLabId_20__1_siD_recording_1.elp"
				}
			]
		},
		{
			"number": "7",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp52",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_7_task_main_subjectLabId_22__1_VTs_recording_1.bdf",
					"dataRecordingUuid": "72110886-2a57-43f2-a850-4a90a09815a5",
					"startDateTime": "20070424T151950",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_7_task_main_subjectLabId_22__1_VTs_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\7\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "22",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_7_task_main_subjectLabId_22__1_VTs_recording_1.elp"
				}
			]
		},
		{
			"number": "8",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp53",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_8_task_main_subjectLabId_23_sessi_hannel_m1Q_recording_1.set",
					"dataRecordingUuid": "31e3fdc3-5726-4e8c-b08a-dd5bd1908b29",
					"startDateTime": "20070425T153203",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_8_task_main_subjectLabId_23_sessi_hannel_m1Q_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\8\\exp53_1_with_event_channel.set"
				}
			],
			"subjects": [
				{
					"labId": "23",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "M",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_8_task_main_subjectLabId_23_sessi_hannel_m1Q_recording_1.elp"
				}
			]
		},
		{
			"number": "9",
			"taskLabel": "main",
			"purpose": "testing",
			"labId": "exp54",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_9_task_main_subjectLabId_22__1_i52_recording_1.bdf",
					"dataRecordingUuid": "947f35d1-425d-44d9-be41-dd7a5aad4df5",
					"startDateTime": "20070502T192558",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_9_task_main_subjectLabId_22__1_i52_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\9\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "22",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_9_task_main_subjectLabId_22__1_i52_recording_1.elp"
				}
			]
		},
		{
			"number": "10",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp55",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_10_task_main_subjectLabId_24__1_uZ7_recording_1.bdf",
					"dataRecordingUuid": "0e4790d4-ddcb-4605-9146-27e275aa035b",
					"startDateTime": "20070504T190137",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_10_task_main_subjectLabId_24__1_uZ7_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\10\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "24",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "1988",
					"age": "19",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_10_task_main_subjectLabId_24__1_uZ7_recording_1.elp"
				}
			]
		},
		{
			"number": "11",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp56",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_11_task_main_subjectLabId_25__1_5ZD_recording_1.bdf",
					"dataRecordingUuid": "3d130fb5-e48e-4d90-ab22-1283b87254db",
					"startDateTime": "20070508T172336",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_11_task_main_subjectLabId_25__1_5ZD_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\11\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "25",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "1981",
					"age": "26",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_11_task_main_subjectLabId_25__1_5ZD_recording_1.elp"
				}
			]
		},
		{
			"number": "12",
			"taskLabel": "main",
			"purpose": "testing",
			"labId": "exp57",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_12_task_main_subjectLabId_23__1_MWp_recording_1.bdf",
					"dataRecordingUuid": "22bafa98-62a0-44ec-b1ce-aa9eb581d81f",
					"startDateTime": "20070509T153237",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_12_task_main_subjectLabId_23__1_MWp_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\12\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "23",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "M",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_12_task_main_subjectLabId_23__1_MWp_recording_1.elp"
				}
			]
		},
		{
			"number": "13",
			"taskLabel": "main",
			"purpose": "training",
			"labId": "exp58",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_13_task_main_subjectLabId_21__1_UhU_recording_1.bdf",
					"dataRecordingUuid": "441b2866-d0ba-409c-a883-0ee48a5844aa",
					"startDateTime": "20070514T140951",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_13_task_main_subjectLabId_21__1_UhU_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\13\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "21",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_13_task_main_subjectLabId_21__1_UhU_recording_1.elp"
				}
			]
		},
		{
			"number": "14",
			"taskLabel": "main",
			"purpose": "testing",
			"labId": "exp59",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_14_task_main_subjectLabId_25__1_Tph_recording_1.bdf",
					"dataRecordingUuid": "f82e3777-8091-4e12-9a27-50e27ea72075",
					"startDateTime": "20070515T154806",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_14_task_main_subjectLabId_25__1_Tph_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\14\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "25",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "1981",
					"age": "26",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_14_task_main_subjectLabId_25__1_Tph_recording_1.elp"
				}
			]
		},
		{
			"number": "15",
			"taskLabel": "main",
			"purpose": "testing",
			"labId": "exp60",
			"notes": {
				"note": "NA",
				"linkName": "NA",
				"link": "NA"
			},
			"dataRecordings": [
				{
					"filename": "eeg_RSVP_Study_session_15_task_main_subjectLabId_21__1_Qev_recording_1.bdf",
					"dataRecordingUuid": "969ba623-5495-4d57-aef9-9543e411e99d",
					"startDateTime": "20070604T144806",
					"recordingParameterSetLabel": "parameter_set_1",
					"eventInstanceFile": "event_RSVP_Study_session_15_task_main_subjectLabId_21__1_Qev_recording_1.tsv",
					"originalFileNameAndPath": "\\session\\15\\eeg_recording_1.bdf"
				}
			],
			"subjects": [
				{
					"labId": "21",
					"inSessionNumber": "1",
					"group": "normal",
					"gender": "F",
					"YOB": "NA",
					"age": "NA",
					"hand": "NA",
					"vision": "-",
					"hearing": "-",
					"height": "-",
					"weight": "-",
					"medication": {
						"caffeine": "NA",
						"alcohol": "-"
					},
					"channelLocations": "channel_locations_RSVP_Study_session_15_task_main_subjectLabId_21__1_Qev_recording_1.elp"
				}
			]
		}
	],
	"tasks": [
		{
			"taskLabel": "main",
			"tag": "Experiment context\/Sitting,Experiment context\/Indoors\/ Dim room, Paradigm\/Oddball discrimination paradigm\/Visual oddball paradigm\/Rapid Serial Visual Presentation",
			"description": "There is only one task, RSVP target detecttion, in this study"
		}
	],
	"publications": [
		{
			"citation": "NA",
			"DOI": "NA",
			"link": "NA"
		}
	],
	"experimenters": [
		{
			"name": "Nima Bigdely-Shamlo",
			"role": "Data Analysis"
		},
		{
			"name": "Andrey Vankov",
			"role": "Software Infrastructure"
		},
		{
			"name": "Rey R. Ramirez",
			"role": "Data Analysis"
		},
		{
			"name": "Scott Makeig",
			"role": "Principal Investigator"
		}
	],
	"organizations": [
		{
			"name": "Swartz Center of Computational Neuroscience, INC, UCSD",
			"logoLink": "SCCN.jpg"
		}
	]
}
);