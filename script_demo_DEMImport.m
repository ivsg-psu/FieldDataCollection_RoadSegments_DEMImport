
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
% - In fcn_DEMImport_ImportZipFromURL
%   % * Wrote the code originally, using breakDataIntoLaps as starter
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_ImportZipFromURL
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

% TO-DO:
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%   % * Move fcn_INTERNAL_timeStringFromSeconds into DebugTools


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
fcn_DEMImport_ImportZipFromURL(URLtoImport, (estimatedBytesPerSecond), (figNum));

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
% After the data is scraped, query it. 
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');
load(pamap_lidar_limitsFile);

kFtLimits = round(FtLimits./[100 100 1000 1000]);
pamap_lidar_table = table(LatLonLimits,kFtLimits,zipPaths);

% queryLatLon = [40.7142 -78.38];

reference_latitude = 40.86368573;
reference_longitude = -77.83592832;

queryLatLon = [reference_latitude reference_longitude];

possibleDataSources = LatLonLimits(:,1)<=queryLatLon(1,1) & LatLonLimits(:,2)>queryLatLon(1,1) & LatLonLimits(:,3)<=queryLatLon(1,2) & LatLonLimits(:,4)>queryLatLon(1,2);


pathsToFilesContainingHeightData = zipPaths(possibleDataSources);
fprintf(1,'\n\n Here are all the files (DEMs, Breaklines, Contours, etc.) that contain the above query location:\n');
disp(pathsToFilesContainingHeightData);

flagsPathsToDEMs = contains(pathsToFilesContainingHeightData,'\DEM\');
pathsToDEMs = pathsToFilesContainingHeightData(flagsPathsToDEMs);
fprintf(1,'\n\n Here are the DEMs that contain the above query location:\n');
disp(pathsToDEMs);


%% Extract height (need to functionalize script below with inputs: zip file name and path, LatLonLimits, and query
script_test_DEM_load_plot_interpolate


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

