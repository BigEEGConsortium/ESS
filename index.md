![](/images/ESS_logo_ship.png)

EEG Study Schema (ESS) makes it easier for researcher in the field of EEG/BCI to package, share and automatize the analysis workflow of their study data. 

You can think of ESS as a "shipping container" for your EEG study data.

## Using other people’s EEG data could be painful

Often one has to do detective work to find out:

1. What happened in the experiment?
2. Which files are for which subjects/sessions?
3. What do these event codes mean?

## To remove ‘EEG data sharing pain' we have created a set of standards (HED and ESS) and tools

ESS is designed from a user-centered viewpoint that emphasizes simplicity and ease of use. It is created to contain all the information a researcher unfamiliar with a particular EEG (or MEG) Study needs to further analyze the data. It is

* An XML-based specification 
* Holds all the information necessary to analyze an EEG study: task and paradigm description, recording parameters, sensor locations, gender, handedness, age and group associations of subjects…
* Contains a table of [HED tags](http://www.hedtags.org) for event codes.  
* Both human- and machine-readable
* The XML file may be readily formatted into a readable description of the EEG study 

ESS also has a convention that specifies how to name and arrange raw session EEG recording files into folders.

## ESS 2.0

The latest version of ESS (2.0) is capable of dealing with multiple modalities (e.g. Motion Capture, Eye-Tracking,...), and studies where EEG recording parameters (e.g. sampling rate) vary across sessions. The figure below shows stages of data and tools used to transform data into ESS standard levels.

![](/images/ESS process.png)
### <a name="level1">Standardized Data Level 1</a>

Level 1 contains data without any processing, except the tagging and synchronization. To prevent misunderstanding it is important to first provide our definition of terms as Study, Task and Session:

* Session: A session is best described as a single application of EEG cap for subjects, for data to be recorded under a single study. Multiple (and potentially quite different) tasks may be recorded during each session but they should all belong to the same study.
* Study: A set of data collection efforts (Sessions) to answer one or few related scientific questions. 
* Task: Each study may contain multiple tasks. For example a baseline ‘eyes closed’ task, followed by a ‘target detection’ task and a ‘mind wandering’, eyes open, task. Each task contains a single paradigm and in combination they allow answering scientific questions investigated in the study. ESS allows for event codes to have different meanings in each task, although such event encoding is discouraged due to potential for experimenter confusion.
*EEG Recording: The file containing EEG data from one or multiple subjects. In some cases it may also contain non-EEG data (e.g. GSR, ECG or even Motion Capture and Eye tracker data). A Session may produce multiple EEG recordings.

We tried to select terms similar to ones defined in EEGLAB software. The figure below shows ESS Standardized Level 1 folder and file structure. The study_description.xml file is the “header” of ESS container and contains all the study meta data. 

![](/images/ESS level 1 schema.png)
You can see Level 1 specification at [www.eegstudy.org/schema/level1](http://www.eegstudy.org/schema/level1). 

### <a name="level2">Standardized Data Level 2</a>

Standard Data Level 2 provides a containerized, well-documented version of the data after processing by accepted pre-processing functions and annotated by an extensive summary reporting of data quality. The focus of Standard Data Level 2 is to transform the EEG data into a state that would allow the direct application of machine learning or other analysis algorithms without additional processing. The amount of preprocessing applied is minimal, because we wanted to maximize the usability across a variety of applications. 

The Standard Data Level 2 pipeline (PREP) consists of three steps: initial filtering, removal of a robust reference signal, and interpolation of bad channels. The pipeline also identifies potentially bad sections of the signal. You can access PREP code from https://github.com/VisLab/EEG-Clean-Tools . 

A Standard Data Level 2 (STDL2) collection has a well-defined folder structure documented in a studyLevel2_description.xml file (see the figure below). This XML file uniquely identifies the data collection and documents the layout of the data in a detailed manner. The XML file also contains the XML generated from the Standard Data Level 1 processing.

![](/images/ESS level 2 schema.png)
You can see Level 2 specification at www.eegstudy.org/schema/level2 .

## <a name="tools">ESS tools</a>

Free open-source MATLAB-based tools are available in [ESS Github repository](https://github.com/bigdelys/ESS) to read and write ESS XML files. You can use these tools to automate the process of loading data from study sessions and applying (e.g. EEGLAB) analysis scripts on your data.

## Download ESS-formatted EEG studies

Currently there are over 850 GB of data, from over 16 studies, available in ESS. For an up-todate list with download links please visit: www.studycatalog.org

## Example code

### Running a function on all the recording in the study
```
% load the container in to a MATLAB object
obj = level2Study('level2XmlFilePath', 'C:\Users\...\[ESS Container Folder]\');

% get all the recording files 
filenames = obj.getFilename;

% Step through all the recordings and apply a function
for i=1:length(filenames)
    [path name ext] = fileparts(filenames{i});
    EEG = pop_loadset([name ext], path);
	EEG = [YOUR FUNCTION](EEG,..)
end;
```
You can limit the tasks for which the files are obtained by using 'taskLabel' option of getFilename() method in level2Study class.

### Creating An EEGLAB STUDY

```
% load the container in to a MATLAB object
obj = level2Study('level2XmlFilePath', 'C:\Users\...\[ESS Container Folder]\');

studyFilenameAndPAth = createEeglabStudy(obj, 'C:\Users\Nima\Documents\MATLAB\tools\playground\eeglabstudy');
```

### Making sure the container has no issues (validation)
```
% load the container in to a MATLAB object
obj = level2Study('level2XmlFilePath', 'C:\Users\...\[ESS Container Folder]\');

obj = obj.validate;

```
Some minor issues, like missing UUIDs are fixed by default in the validation process, but you need to save the object afterwards.
### Combining partial runs of Level 2 or Level-derived
```
obj = level2Study; % for level-derived use "obj = levelDerivedStudy;" instead
partFolders = {'c:\...\part1\' 'c:\...\part2\' .. };
finalFolder = 'c:\...\final\'
obj = obj.combinePartialRuns(partFolders, finalFolder);

```
## People

ESS 2.0 specifications were drafted by Nima Bigdely-Shamlo ([Qusp](http://qusp.io)), Kay Robbins (University of Texas at San Antonio) and Tony Johnson (DCS Corp.). ESS 1.0 specifications were drafted by Nima Bigdely-Shamlo,  Jessica Hsi (UCSD) and Scott Makeig (Swartz Center for Computational Neueorsciece, UCSD).

Please email your questions about ESS to Nima Bigdely-Shamlo: nima.bigdely [put at sign here] qusp.io.

## License

ESS tools and schemas are released under the MIT license.

***

ESS was originally developed under HeadIT project at Swartz Center for Computational Neuroscience (SCCN) of the University of California, San Diego and funded by U.S. National Institutes of Health grants R01-MH084819 (Makeig, Grethe PIs) and R01-NS047293 (Makeig PI). ESS development is now supported by The Cognition and Neuroergonomics Collaborative Technology Alliance (CaN CTA) program of U.S Army Research Labaratory.

[© Qusp 2015] (http://qusp.io)