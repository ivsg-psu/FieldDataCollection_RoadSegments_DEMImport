
%% Introduction to and Purpose of the Code
% This is the explanation of the code that can be found by running
%
%       script_demo_DEMImport.m
%
% This is a script to demonstrate the functions within the DEMImport code
% library. This code repo is typically located at:
%
%   https://github.com/ivsg-psu/FieldDataCollection_RoadSegments_DEMImport
%
% If you have questions or comments, please contact Sean Brennan at
% sbrennan@psu.edu
%
% The purpose of the code is to import Digital Elevation Maps. For
% Pennsylvania, these are stored at:
% https://pasda.maps.arcgis.com/apps/webappviewer/index.html?id=f8b951ee77094a81a0a3d6eaa824ebdd

% REVISION HISTORY:
% 
% 2026_03_13 by Sean Brennan, sbrennan@psu.edu
% - In script_demo_DEMImport
%   % * Created this demo script
% - In script_test_fcn_DEMImport_ImportDEMsFromPAMAP
%   % * Wrote the code originally, using breakDataIntoLaps as starter
% - In fcn_DEMImport_ImportDEMsFromPAMAP
%   % * Wrote the code originally, using breakDataIntoLaps as starter
%
% 2026_03_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_ImportDEMsFromPAMAP
%   % * Changed root definition to start at "download" to match, exactly,
%   %   % pasda website
%
% 2026_03_31 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_importZipFromURL.m
%   % * Wrote the code originally, using breakDataIntoLaps as starter
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_importZipFromURL.m
%   % * Added estimated completion time as input, actual time as output
%   % * Added error reporting
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%   % * Wrote the code originally, using script_test_scrapeDirectory as starter
% 
% 2026_04_07 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_DEM_load_plot_interpolate2
%   % * Wrote this code originally
% 
% 2026_04_07 by Sean Brennan, sbrennan@psu.edu
% - In script_test_DEM_load_plot_interpolate2
%   % * Added geoid correction to LLA hand-measured data to show that this
%   %   % causes the DEM query result to match, exactly, the test track
%   %   % results
% 
% 2026_04_08 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_queryElevationsFromSingleTile
%   % * Wrote this code originally
% - In script_test_fcn_DEMImport_queryElevationsFromSingleTile
%   % * Wrote this code originally
% - In fcn_DEMImport_selectEntriesByZipPathStrings
%   % * Wrote this code originally
% - In script_test_fcn_DEMImport_selectEntriesByZipPathStrings
%   % * Wrote this code originally
% - In fcn_DEMImport_selectEntriesByBoundingBox
%   % * Wrote this code originally
% - In script_test_fcn_DEMImport_selectEntriesByBoundingBox
%   % * Wrote this code originally
% 
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_assignTilesToQueryPoints
%   % * Wrote this code originally
% - In script_test_fcn_DEMImport_assignTilesToQueryPoints
%   % * Wrote this code originally
% - In fcn_DEMImport_ensureLocalZipFromPASDAPath
%   % * Wrote this code originally
% - In script_test_fcn_DEMImport_ensureLocalZipFromPASDAPath
%   % * Wrote this code originally
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Wrote this code originally
% - In script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Wrote this code originally
%
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In script_demo_DEMImport
%   % * Added demos showing how to do a series of queries using function
%   %   % calls
%   % * Added GPS library install
%   % * Added plotting of test track
%   % * Minor fixed throughout to prep for release
% - In fcn_DEMImport_extractLatLonLimitsFromLASPRJ
%   % * Fixed bug where outputs not filled
% - In fcn_DEMImport_extractLimitsFromZipFile
%   % * Functionalized plotting using call to fcn_DEMImport_plotLatLonLimits
% - In script_test_fcn_DEMImport_extractLatLonLimitsFromLASPRJ
%   % * Improved output checking to handle limitsFt
% - In script_test_fcn_DEMImport_plotLatLonLimits
%   % * Wrote this code originally
% - In fcn_DEMImport_plotLatLonLimits
%   % * First write of function
% - In script_test_fcn_DEMImport_selectEntriesByZipPathStrings
%   % * Improved case testing
% - In fcn_DEMImport_selectEntriesByZipPathStrings
%   % * Added plotting output using fcn_DEMImport_plotLatLonLimits
% - In script_test_fcn_DEMImport_selectEntriesByBoundingBox
%   % * Improved case testing
% - In fcn_DEMImport_selectEntriesByBoundingBox
%   % * Added plotting output using fcn_DEMImport_plotLatLonLimits
% - In fcn_DEMImport_assignTilesToQueryPoints
%   % * Modified input checking to allow mixed inputs for
%   %   % overlappingLatLonLimits 
% - In fcn_DEMImport_queryElevationsFromSingleTile
%   % * Fixed bug where reference_latitude, etc were not defined inside
%   %   % plotting function
% - In script_test_fcn_DEMImport_queryElevationsFromSingleTile
%   % * Cleaned up test scripts
% - In script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Cleaned up test scripts
% - In fcn_DEMImport_importZipFromURL.m
%   % Renamed from fcn_DEMImport_ImportZipFromURL.m
% - In fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%   % * Moved fcn_INTERNAL_timeStringFromSeconds into DebugTools
%
% (new release)
%
% 2026_04_13 by Sean Brennan, sbrennan@psu.edu
% - In script_demo_DEMImport
%   % * Added PennDOT network query example
%   % * Added PennDOT network info into Data folder
% - In script_test_fcn_DEMImport_selectEntriesByZipPathStrings
%   % * Added North or South testing case
% - In script_test_fcn_DEMImport_queryElevations
%   % * Wrote the code originally
% - In fcn_DEMImport_queryElevations
%   % * Wrote the code originally
% - In fcn_DEMImport_selectEntriesByZipPathStrings
%   % * Added ability to handle ' or ' string options
% 
% 2026_04_13 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_queryElevations
%   % * Added a some DEMO and TEST cases
% - In fcn_DEMImport_queryElevations
%   % * Modified the instructions of the inputs
% - In fcn_DEMImport_querySingleTile
%   % * Added a helper function fcn_INTERNAL_determineProjectedCRS to
%   %   % determine projected CRS (coordinate reference system) for a PASDA DEM
%   %   % tile.
%
% 2026_04_15 by Sean Brennan, sbrennan@psu.edu
%  - In script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
%    % * Added a test case to specify localRootFolder
%  - In script_test_fcn_DEMImport_queryElevations
%    % * Added a test case to specify localRootFolder
% - In fcn_DEMImport_queryElevations
%   % * Fixed bug where input arguments were not being passed in correctly
%
% 2026_04_16 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Fixed bug where input arguments are not imported if user specifies
%   %   % fast mode and where input argument count number was wrong
% - In fcn_DEMImport_queryElevationsFromSingleTile
%   % * Improved function naming to separate out CRS calculations more
%   %   % clearly
%   % * Added fcn_INTERNAL_determineProjectedCRSfromFileName to catch cases
%   %   % where CRS is corrupted (see test case 1)
%   % * Fixed output plotting to avoid connecting dots on queries
%   % * Removed unnecessary for-loop processing each point 
%   %   % individually instead of as a vector (VERY slow)
% 
% 2026_04_16 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_queryElevationsFromSingleTile
%   % * Added an option input to take queryMode as an input to extrpolate
%   %   % the queryPoints on the LatLonLimits of the DEM tile. 
% - In script_test_fcn_DEMImport_queryElevationsFromSingleTile
%   % * Added a test case to demonstrate EXTRAPOLATE query mode (20003)

% TO-DO:
%
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_assignTilesToQueryPoints
%   % * Need to be able to handle cases where the input,
%   overlappingLatLonLimits, may be empty. This happens when the user might
%   do a query over a location where there is no limit definition files.
%
% 2026_04_13 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * The optional inputs are ONLY filled if not in fast mode. This is a
%   %   % bug
%   % * The test script is not in standard form (variable type, then size,
%   %   % then values). Need to fix this.
% - In fcn_DEMImport_selectEntriesByBoundingBox
%   % * Need to rename the input and output variables for better clarity.
%   %   % For example, user does not know what "matching" means in
%   %   % matchingLatLonLimits. Why is this different than LatLonLimits?
%   %   % Comments in header also do not explain inputs/outputs very well
%   % * Need to rename outputs as well - current names are confusing
%   % * Need to allow user to input margin of search, with a good
%   %   % suggestion. Margin should be at least he size of the DEM box width in
%   %   % the PASDA data
%
% 2026_04_15 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * If user selects 'first' as method, it still seems to loop through
%   %   % ALL the DEM files, which can be VERY slow. Needs to only use first
%   %   % valid DEM and then stop looping
%
% 2026_04_16 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromSingleTile
%   % * The code is reporting that some queries, which are inside the
%   %   % bounding box, are not actually valid. This is a bug. See PennDOT
%   %   % demo case 10004 in script_test_fcn_DEMImport_queryElevations
% - In script_test_fcn_DEMImport_queryElevationsFromSingleTile
%   % * Created "TEST Case: Query tile with points near edges (bug case)"
%   %   % This is case 20002.
%   %   % This illustrates the error above using the tile for the test
%   %   % track. Need to fix this.

%% Make sure we are running out of root directory
st = dbstack; 
thisFile = which(st(1).file);
[filepath,name,ext] = fileparts(thisFile);
cd(filepath);

%%% START OF STANDARD INSTALLER CODE %%%%%%%%%

%% Clear paths and folders, if needed
if 1==1
    clear flag_DEMImport_Folders_Initialized
end

if 1==0
    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;
end

if 1==0
    % Resets all paths to factory default
    restoredefaultpath;
end

%% Install dependencies
% Define a universal resource locator (URL) pointing to the repos of
% dependencies to install. Note that DebugTools is always installed
% automatically, first, even if not listed:
clear dependencyURLs dependencySubfolders
ith_repo = 0;

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary';
dependencySubfolders{ith_repo} = {'Functions','Data'};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_PathTools_GetUserInputPath';
dependencySubfolders{ith_repo} = {''};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad';
dependencySubfolders{ith_repo} = {'Functions','Data'};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/FieldDataCollection_GPSRelatedCodes_GPSClass';
dependencySubfolders{ith_repo} = {'Functions'};

% ith_repo = ith_repo+1;
% dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_GeomTools_GeomClassLibrary';
% dependencySubfolders{ith_repo} = {'Functions','Data'};

% ith_repo = ith_repo+1;
% dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_MapTools_MapGenClassLibrary';
% dependencySubfolders{ith_repo} = {'Functions','testFixtures','GridMapGen'};



%% Do we need to set up the work space?
if ~exist('flag_DEMImport_Folders_Initialized','var')
    
    % Clear prior global variable flags
    clear global FLAG_*

    % Navigate to the Installer directory
    currentFolder = pwd;
    cd('Installer');
    % Create a function handle
    func_handle = @fcn_DebugTools_autoInstallRepos;

    % Return to the original directory
    cd(currentFolder);

    % Call the function to do the install
    func_handle(dependencyURLs, dependencySubfolders, (0), (-1));

    % Add this function's folders to the path
    this_project_folders = {...
        'Functions','Data','LargeData'};
    fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders)

    flag_DEMImport_Folders_Initialized = 1;
end

%%% END OF STANDARD INSTALLER CODE %%%%%%%%%

%% Set environment flags for input checking in Laps library
% These are values to set if we want to check inputs or do debugging
setenv('MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS','1');
setenv('MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG','0');

%% Set environment flags that define the ENU origin
% This sets the "center" of the ENU coordinate system for all plotting
% functions
% Location for Test Track base station
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');


%% Set environment flags for plotting
% These are values to set if we are forcing image alignment via Lat and Lon
% shifting, when doing geoplot. This is added because the geoplot images
% are very, very slightly off at the test track, which is confusing when
% plotting data
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LAT','-0.0000008');
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LON','0.0000054');

%% Check if repo is ready for release
if 1==0
	figNum = 999999;
	repoShortName = '_DEMImport_';
	fcn_DebugTools_testRepoForRelease(repoShortName, (figNum));
end

%% Start of Demo Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____ _             _            __   _____                          _____          _
%  / ____| |           | |          / _| |  __ \                        / ____|        | |
% | (___ | |_ __ _ _ __| |_    ___ | |_  | |  | | ___ _ __ ___   ___   | |     ___   __| | ___
%  \___ \| __/ _` | '__| __|  / _ \|  _| | |  | |/ _ \ '_ ` _ \ / _ \  | |    / _ \ / _` |/ _ \
%  ____) | || (_| | |  | |_  | (_) | |   | |__| |  __/ | | | | | (_) | | |___| (_) | (_| |  __/
% |_____/ \__\__,_|_|   \__|  \___/|_|   |_____/ \___|_| |_| |_|\___/   \_____\___/ \__,_|\___|
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Start%20of%20Demo%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Welcome to the demo code for the DEMImport library!')

%% DEMO case: scrape PASDA directory (takes about 30 minutes)
figNum = 10001;
titleString = sprintf('DEMO case: scrape PASDA directory (takes about 30 minutes)');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

if 1==0
	% Call the function
	fcn_DEMImport_scrapePASDA(-1)
end

%% DEMO case: load pamap (9 TB - takes about 4 days)
figNum = 10002;
titleString = sprintf('DEMO case: load pamap (9 TB - takes about 4 days)');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

if ~exist('scrapeDirectoryResultPASDA','var')
	saveFileName = fullfile(pwd,'Data','scrapeDirectoryResultPASDA.mat');
	if exist(saveFileName,'file')
		load(saveFileName,'scrapeDirectoryResultPASDA');
	else
		error('Unable to find load file for directory scrape: %s',saveFileName);
	end
end

dataStringToExtract = 'pamap';

warning('This function takes DAYS to run and requires an external attached drive with at least 10 TB of free space! You must manually edit this code to FORCE the operation to occur.')
if 1==0
	% Call the function
	fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive(scrapeDirectoryResultPASDA, dataStringToExtract, -1)
end

%% DEMO case: load 38002090PAN_dem.zip directly from the PASDA website
figNum = 10003;
titleString = sprintf('DEMO case: load 38002090PAN_dem.zip directly from the PASDA website');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

URLtoImport = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/30000000/38002090PAN_dem.zip';
estimatedBytesPerSecond = [];

% Call the function
fcn_DEMImport_importZipFromURL.m(URLtoImport, (estimatedBytesPerSecond), (figNum));

%% DEMO: process ALL data scraped under pamap_lidar folder
% This cycles through all downloaded data and builds a database of "limits"
% in latlong and in "foot" or ft coordinates (which are used by PASDA). To
% do this, it finds EVERY zip file, unzips it, scans the results for XML
% files, scrapes the XML files to determine if LLA limits and/or Ft limits
% are specified in the XML. For XML files that "fail" to be scanned, it
% puts the results into "XMLsWithProblems" folder.
% This process takes about 8 to 12 hours to complete.

figNum = 10004;
titleString = sprintf('DEMO case: process ALL data scraped under pamap_lidar folder');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

fcn_plotRoad_plotLL([],[],figNum);
set(gca,'MapCenter',[41.2545 -78.0122], 'ZoomLevel', 6.875); % Entire state

% Change this folder to match the one on the external drive
rootPathName = 'D:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download\pamap\pamap_lidar\';

% Flag is set to 1 to FORCE all files to be scanned, ignoring existing load
% files
flagIgnoreLoadFiles = 1;

warning('This function takes 8 HOURS to run and requires an external attached drive with roughly 10 TB of PASDA data downloaded (see previous steps). You must manually edit this code to FORCE the operation to occur.')
if 1==0
	% Call the function
	[LatLonLimits,zipPaths, FtLimits] = fcn_DEMImport_buildLatLonLimitFiles(rootPathName, (flagIgnoreLoadFiles), (figNum));
end

%% DEMO: show how to pull out zip locations
figNum = 10005;
titleString = sprintf('DEMO case: show how to pull out zip locations');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;


% After the data is scraped, query it. 
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');


if 1==0
	% Do dumb load
	load(pamap_lidar_limitsFile);
else
	% Do smart load, one variable at a time with warnings

	matlabFileObject = matfile(pamap_lidar_limitsFile);        % returns matlab.io.MatFile object
	vars = who(matlabFileObject);             % variable names in the file (no full load)
	expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

	for ith_expectedVariable = 1:length(expectedVariables)
		thisExpectedVariable = expectedVariables{ith_expectedVariable};
		% Read a variable only if it exists
		if ismember(thisExpectedVariable, vars)
			% loads only that variable/part
			commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);',thisExpectedVariable);
			eval(commandString);
		else
			warning('Variable %s not found in the limits file: %s.', thisExpectedVariable, pamap_lidar_limitsFile);
		end
	end
end

kFtLimits = round(FtLimits./[100 100 1000 1000]);
pamap_lidar_table = table(LatLonLimits,kFtLimits,zipPaths);

% queryLatLon = [40.7142 -78.38];

reference_latitude = 40.86368573;
reference_longitude = -77.83592832;

% queryLatLon = [reference_latitude reference_longitude];

queryLatLon = [40.7142 -78.38];

flagOfPossibleDataSources = LatLonLimits(:,1)<=queryLatLon(1,1) & LatLonLimits(:,2)>queryLatLon(1,1) & LatLonLimits(:,3)<=queryLatLon(1,2) & LatLonLimits(:,4)>queryLatLon(1,2);


pathsToFilesContainingHeightData = zipPaths(flagOfPossibleDataSources);
fprintf(1,'\n\n Here are all the files (DEMs, Breaklines, Contours, etc.) that contain the above query location:\n');
disp(pathsToFilesContainingHeightData);

% Show how to do a sub-query
flagsPathsToDEMs = contains(pathsToFilesContainingHeightData,'\DEM\');
pathsToDEMs = pathsToFilesContainingHeightData(flagsPathsToDEMs);
fprintf(1,'\n\n Here are the DEMs that contain the above query location:\n');
disp(pathsToDEMs);

%% DEMO: Show how to do a series of queries using function calls
figNum = 10006;
titleString = sprintf('DEMO case:  Show how to do a series of queries using function calls');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

%%%%%%%%%%
% Load LatLonLimits and zipPaths (INPUTS)
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');


if 1==0
	% Do dumb load
	load(pamap_lidar_limitsFile);
else
	% Do smart load, one variable at a time with warnings

	matlabFileObject = matfile(pamap_lidar_limitsFile);        % returns matlab.io.MatFile object
	vars = who(matlabFileObject);             % variable names in the file (no full load)
	expectedVariables = {'LatLonLimits', 'zipPaths'};

	for ith_expectedVariable = 1:length(expectedVariables)
		thisExpectedVariable = expectedVariables{ith_expectedVariable};
		% Read a variable only if it exists
		if ismember(thisExpectedVariable, vars)
			% loads only that variable/part
			commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);',thisExpectedVariable);
			eval(commandString);
		else
			warning('Variable %s not found in the limits file: %s.', thisExpectedVariable, pamap_lidar_limitsFile);
		end
	end
end

% INPUT
requiredStrings = {'\DEM\', '\North\'}; 

%%%%%%%%%%
% Call the function to limit by strings
[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ... 
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, (figNum));

queryBoundingBox = [40 41  -78 -77];

%%%%%%%%%%
% Call the function to limit by bounding box
[overlappingLatLonLimits, overlappingZipPaths, overlapEntriesFlags] = ...
      fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths, (figNum));

%%%%%%%%%%
% Assign DEM tiles to each query point
% Define query points
mins = [40.77 -77.9];
maxs = [40.9 -77.78];
Nrows = 100;
rng(1);
LLAdata = fcn_INTERNAL_generateRandomInRange(mins,maxs,Nrows);
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, figNum);

%% DEMO: Show how to query elevation
figNum = 10007;
titleString = sprintf('DEMO case: Show how to query elevation');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

%% PennDOT Elevation
% Calculates elevation for PennDOT segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _____                 _____   ____ _______   ______ _                 _   _
% |  __ \               |  __ \ / __ \__   __| |  ____| |               | | (_)
% | |__) |__ _ __  _ __ | |  | | |  | | | |    | |__  | | _____   ____ _| |_ _  ___  _ __
% |  ___/ _ \ '_ \| '_ \| |  | | |  | | | |    |  __| | |/ _ \ \ / / _` | __| |/ _ \| '_ \
% | |  |  __/ | | | | | | |__| | |__| | | |    | |____| |  __/\ V / (_| | |_| | (_) | | | |
% |_|   \___|_| |_|_| |_|_____/ \____/  |_|    |______|_|\___| \_/ \__,_|\__|_|\___/|_| |_|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=PennDOT+Elevation&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

sourceDataFileName = 'PennDOT_LLcoordinates';
sourceDataFilePath = fullfile(pwd,'Data',cat(2,sourceDataFileName,'.mat'));
if 1==1 && flag_loadDataFilesWhenPossible && exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,'PennDOT_LLSegments_matrix','PennDOT_LLSegments_cellArray','usableTableRows');
else
	error('Unable to find the PennDOT segments file inside the Data folder. This can be obtained form the PennDOTSHP repo.');
end

%% Test Track Plotting
% Creates an image of the test track using DEMs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _______        _     _______             _      _____  _       _   _   _
% |__   __|      | |   |__   __|           | |    |  __ \| |     | | | | (_)
%    | | ___  ___| |_     | |_ __ __ _  ___| | __ | |__) | | ___ | |_| |_ _ _ __   __ _
%    | |/ _ \/ __| __|    | | '__/ _` |/ __| |/ / |  ___/| |/ _ \| __| __| | '_ \ / _` |
%    | |  __/\__ \ |_     | | | | (_| | (__|   <  | |    | | (_) | |_| |_| | | | | (_| |
%    |_|\___||___/\__|    |_|_|  \__,_|\___|_|\_\ |_|    |_|\___/ \__|\__|_|_| |_|\__, |
%                                                                                  __/ |
%                                                                                 |___/
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Test+Track+Plotting&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§


% Files are from:
% https://www.pasda.psu.edu/download/psu_opp/2022Orthophotos/LIDAR/las/255019425.las
% https://www.pasda.psu.edu/download/psu_opp/2022Orthophotos/LIDAR/las/255019450.las
% etc.

files = {'255019425.las','255019450.las','257519425.las','257519450.las'};

cameraViewfilename = fullfile('C:\Users\snb10\Desktop\GitHubRepos\IVSG\FieldDataCollection\RoadSegments\DEMImport','Data','pcshow_cameraview.mat');


loc = [];
intensity = [];
for ith_file = 1:length(files)
	thisFile = files{ith_file};
	filepath = fullfile('C:\Users\snb10\Desktop\To_DeleteTemp\',thisFile);

	lasReader = lasFileReader(filepath);

	[ptCloud, ptAttributes] = readPointCloud(lasReader, "Attributes", "Classification");

	loc = [loc; ptCloud.Location];   %#ok<AGROW> % Nx3
	intensity = [intensity; ptCloud.Intensity]; %#ok<AGROW> % Nx1
end


%%%%
%  Colorize by height

z = double(loc(:,3));
if isempty(z)
    error('No points read from file.');
end

% Normalize Z to [0,1]
zmin = 1150; % min(z);
zmax = 1375; % max(z);

z = min(z,zmax);
z = max(z,zmin);

locModified = loc;
locModified(:,3) = min(locModified(:,3),zmax);
locModified(:,3) = max(locModified(:,3),zmin);

if zmax > zmin
    znorm1 = (z - zmin) / (zmax - zmin);
else
    znorm1 = zeros(size(z)); % all equal height
end

znorm = znorm1;

% Map normalized heights to a colormap (choose colormap and resolution)
nColors = 256;
cmap = parula(nColors);                      % nColors x 3
idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

% Show point cloud with color
figure(1234);
clf;

pcshow(locModified, colors)
title('Point Cloud Colored by Height (Z)')
xlabel('X'); ylabel('Y'); zlabel('Z')
colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
colormap(parula)

% Set a good camera view
s = load(cameraViewfilename);      % contains cam
fcn_INTERNAL_setCameraView(s.cam);

% Save new camera view?
if 1==0
	cam = getCameraView(gca, filename);
end

%%%%
%  Colorize by intensity

z = double(intensity);
if isempty(z)
    error('No points read from file.');
end

% Normalize Z to [0,1]
zmin = min(z);
zmax = 2000; % max(z);

z = min(z,zmax);
z = max(z,zmin);

if zmax > zmin
    znorm2 = (z - zmin) / (zmax - zmin);
else
    znorm2 = zeros(size(z)); % all equal height
end

znorm = znorm2;

% Map normalized heights to a colormap (choose colormap and resolution)
nColors = 256;
cmap = parula(nColors);                      % nColors x 3
idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

% Show point cloud with color
figure(2345);
clf;

pcshow(locModified, colors)
title('Point Cloud Colored by Height (Z)')
xlabel('X'); ylabel('Y'); zlabel('Z')
colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
colormap(parula)

% Set a good camera view
s = load(cameraViewfilename);      % contains cam
fcn_INTERNAL_setCameraView(s.cam);

%%%%%
%  Save image?
if flag_exportFigures
	h_fig = gcf;
	figFileName = fullfile(pwd,'Images','testTrackDEM_Intensity.png');
	exportgraphics(h_fig,figFileName,'Resolution',300)
end



%%%%%
%  Colorize by blended height and intensity
if 1==0
	znorm = 0.5*znorm2 + 0.5*znorm1;
	znorm = min(znorm,1);
	znorm = max(znorm,0);

	% Map normalized heights to a colormap (choose colormap and resolution)
	nColors = 256;
	cmap = parula(nColors);                      % nColors x 3
	idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
	colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

	% Show point cloud with color
	figure(3456);
	clf;

	pcshow(locModified, colors)
	title('Point Cloud Colored by Height (Z)')
	xlabel('X'); ylabel('Y'); zlabel('Z')
	colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
	colormap(parula)

	% Set a good camera view
	s = load(cameraViewfilename);      % contains cam
	fcn_INTERNAL_setCameraView(s.cam);
end

%%%%%%%
%  Colorize by whichever of height and intensity is furthest from each mean
diff1 = abs(znorm1 - mean(znorm1,'all','omitmissing'));
% diff1 = (znorm1 -0.5);
diff2 = abs(znorm2 - mean(znorm2,'all','omitmissing'));
diffs = [diff1 diff2];
[~,ind] = max(diffs,[],2);

znorm = znorm1;
znorm(ind==2) = znorm2(ind==2);

% Map normalized heights to a colormap (choose colormap and resolution)
nColors = 256;
cmap = parula(nColors);                      % nColors x 3
idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

% Show point cloud with color
figure(4567);
clf;

pcshow(locModified, colors)
title('Point Cloud Colored by Height (Z)')
xlabel('X'); ylabel('Y'); zlabel('Z')
colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
colormap(parula)

% Set a good camera view
s = load(cameraViewfilename);      % contains cam
fcn_INTERNAL_setCameraView(s.cam);


%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

%% function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
% Clear out the variables
clear global flag* FLAG*
clear flag*
clear path

% Clear out any path directories under Utilities
path_dirs = regexp(path,'[;]','split');
utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir});
    end
end

% Delete the Utilities folder, to be extra clean!
if  exist(utilities_dir,'dir')
    [status,message,message_ID] = rmdir(utilities_dir,'s');
    if 0==status
        error('Unable remove directory: %s \nReason message: %s \nand message_ID: %s\n',utilities_dir, message,message_ID);
    end
end

end % Ends fcn_INTERNAL_clearUtilitiesFromPathAndFolders

%% fcn_INTERNAL_generateRandomInRange
function output = fcn_INTERNAL_generateRandomInRange(mins,maxs,Nrows)
allOnes = ones(Nrows,1);
output = allOnes*(maxs-mins) .* rand(Nrows,length(mins)) + allOnes*mins;
end % Ends fcn_INTERNAL_generateRandomInRange

function cam = getCameraView(ax, filename)
% getCameraView  Get camera settings from axes and optionally save to file
% cam = getCameraView(ax)
% cam = getCameraView(ax, filename)
% ax       : axes handle (use gca if omitted)
% filename : optional .mat filename to save the camera struct
%
% cam is a struct with fields: Position, Target, UpVector, ViewAngle, Projection

if nargin < 1 || isempty(ax)
    ax = gca;
end

cam.Position   = campos(ax);
cam.Target     = camtarget(ax);
cam.UpVector   = camup(ax);
cam.ViewAngle  = camva(ax);
cam.Projection = camproj(ax);

if nargin == 2 && ~isempty(filename)
    save(filename, 'cam');
end
end

%% fcn_INTERNAL_setCameraView
function fcn_INTERNAL_setCameraView(cam, ax)
% setCameraView  Apply a camera struct to axes used by pcshow
% setCameraView(cam)
% setCameraView(cam, ax)
% cam : struct returned by getCameraView (or loaded from .mat)
% ax  : target axes handle (defaults to gca)

if nargin < 2 || isempty(ax)
    ax = gca;
end

if ischar(cam) || isstring(cam)           % support passing a filename
    s = load(cam, 'cam');
    cam = s.cam;
end

% Apply in sensible order: projection, position/target, upvector, viewangle
camproj(ax, cam.Projection);
camup(ax, cam.UpVector);
campos(ax, cam.Position);
camtarget(ax, cam.Target);
camva(ax, cam.ViewAngle);
drawnow;
end % Ends fcn_INTERNAL_setCameraView




