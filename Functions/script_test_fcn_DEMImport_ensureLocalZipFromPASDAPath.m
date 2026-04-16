%% script_test_fcn_DEMImport_ensureLocalZipFromPASDAPath
% Exercises the function:
% fcn_DEMImport_ensureLocalZipFromPASDAPath

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_ensureLocalZipFromPASDAPath
%   % * Wrote this code originally
%
% 2026_04_15 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_ensureLocalZipFromPASDAPath
%   % * Fixed script formatting to standard form


%% DEMO Case 1: Download or confirm local existence of a known PASDA DEM zip

figNum = 10001;
titleString = sprintf('DEMO case: Ensure local PASDA DEM zip exists');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Example PASDA-relative path beginning at download\...
zipPathEntry = 'download\pamap\pamap_lidar\cycle1\DEM\North\2006\20000000\26001940PAN_dem.zip';
% thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Define a file name and directory to save results
localRootFolder = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(localRootFolder);

% Call the function
localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, (figNum));

% Assertions

% Build expected local path manually
expectedLocalZipFile = fullfile(localRootFolder,'download','pamap','pamap_lidar','cycle1','DEM','North','2006','20000000','26001940PAN_dem.zip');

% Check output type
assert(ischar(localZipFile) || isstring(localZipFile));

% Convert to char for consistent comparison
localZipFile = char(localZipFile);
expectedLocalZipFile = char(expectedLocalZipFile);

% Check exact local path match
assert(strcmp(localZipFile, expectedLocalZipFile));

% Check that the file now exists locally
assert(exist(localZipFile,'file')==2, ...
    'Expected local zip file does not exist after calling the function.');



%% DEMO Case 2: Invalid path should throw an error

badPathEntry = 'pamap\pamap_lidar\cycle1\DEM\North\2006\20000000\26001940PAN_dem.zip';

didThrowError = false;

try
    fcn_DEMImport_ensureLocalZipFromPASDAPath(badPathEntry, localRootFolder, (-1));
catch ME
    didThrowError = true;
    fprintf(1,'Expected error caught:\n%s\n', ME.message);
end

assert(didThrowError, ...
    'Expected an error when zipPathEntry does not contain ''download\''.');

%% Test cases start here. These are very simple, usually trivial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______ ______  _____ _______ _____
% |__   __|  ____|/ ____|__   __/ ____|
%    | |  | |__  | (___    | | | (___
%    | |  |  __|  \___ \   | |  \___ \
%    | |  | |____ ____) |  | |  ____) |
%    |_|  |______|_____/   |_| |_____/
%
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 2

close all;
fprintf(1,'Figure: 2XXXXXX: TEST mode cases\n');

%% TEST case: Changing localRootFolder
figNum = 20001;
titleString = sprintf('TEST case: Changing localRootFolder');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Example PASDA-relative path beginning at download\...
zipPathEntry = 'download\pamap\pamap_lidar\cycle1\DEM\North\2006\20000000\26001940PAN_dem.zip';
% thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Define a file name and directory to save results
localRootFolder = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\';

% Call the function
localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, (figNum));

% Assertions

% Build expected local path manually
expectedLocalZipFile = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download\pamap\pamap_lidar\cycle1\DEM\North\2006\20000000\26001940PAN_dem.zip';

% Check output type
assert(ischar(localZipFile) || isstring(localZipFile));

% Convert to char for consistent comparison
localZipFile = char(localZipFile);
expectedLocalZipFile = char(expectedLocalZipFile);

% Check exact local path match
assert(strcmp(localZipFile, expectedLocalZipFile));

% Check that the file now exists locally
assert(exist(localZipFile,'file')==2, ...
    'Expected local zip file does not exist after calling the function.');

%% Fast Mode Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ______        _     __  __           _        _______        _
% |  ____|      | |   |  \/  |         | |      |__   __|      | |
% | |__ __ _ ___| |_  | \  / | ___   __| | ___     | | ___  ___| |_ ___
% |  __/ _` / __| __| | |\/| |/ _ \ / _` |/ _ \    | |/ _ \/ __| __/ __|
% | | | (_| \__ \ |_  | |  | | (_) | (_| |  __/    | |  __/\__ \ |_\__ \
% |_|  \__,_|___/\__| |_|  |_|\___/ \__,_|\___|    |_|\___||___/\__|___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fast%20Mode%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 8

close all;
fprintf(1,'Figure: 8XXXXXX: FAST mode cases\n');

%% Basic example - NO FIGURE
figNum = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

% Example PASDA-relative path beginning at download\...
zipPathEntry = 'download\pamap\pamap_lidar\cycle1\DEM\North\2006\20000000\26001940PAN_dem.zip';
% thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Define a file name and directory to save results
localRootFolder = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(localRootFolder);

% Call the function
localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, ([]));

% Assertions

% Build expected local path manually
expectedLocalZipFile = fullfile(localRootFolder,'download','pamap','pamap_lidar','cycle1','DEM','North','2006','20000000','26001940PAN_dem.zip');

% Check output type
assert(ischar(localZipFile) || isstring(localZipFile));

% Convert to char for consistent comparison
localZipFile = char(localZipFile);
expectedLocalZipFile = char(expectedLocalZipFile);

% Check exact local path match
assert(strcmp(localZipFile, expectedLocalZipFile));

% Check that the file now exists locally
assert(exist(localZipFile,'file')==2, ...
    'Expected local zip file does not exist after calling the function.');

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

% Example PASDA-relative path beginning at download\...
zipPathEntry = 'download\pamap\pamap_lidar\cycle1\DEM\North\2006\20000000\26001940PAN_dem.zip';
% thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Define a file name and directory to save results
localRootFolder = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(localRootFolder);

% Call the function
localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, (-1));

% Assertions

% Build expected local path manually
expectedLocalZipFile = fullfile(localRootFolder,'download','pamap','pamap_lidar','cycle1','DEM','North','2006','20000000','26001940PAN_dem.zip');

% Check output type
assert(ischar(localZipFile) || isstring(localZipFile));

% Convert to char for consistent comparison
localZipFile = char(localZipFile);
expectedLocalZipFile = char(expectedLocalZipFile);

% Check exact local path match
assert(strcmp(localZipFile, expectedLocalZipFile));

% Check that the file now exists locally
assert(exist(localZipFile,'file')==2, ...
    'Expected local zip file does not exist after calling the function.');

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

% Example PASDA-relative path beginning at download\...
zipPathEntry = 'download\pamap\pamap_lidar\cycle1\DEM\North\2006\20000000\26001940PAN_dem.zip';
% thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Define a file name and directory to save results
localRootFolder = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(localRootFolder);

Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

    % Call the function
    localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, ([]));

end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations

    % Call the function
    localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, (-1));
end
fast_method = toc;

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

% Plot results as bar chart
figure(373737);
clf;
hold on;

X = categorical({'Normal mode','Fast mode'});
X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
Y = [slow_method fast_method ]*1000/Niterations;
bar(X,Y)
ylabel('Execution time (Milliseconds)')


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% BUG cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ____  _    _  _____
% |  _ \| |  | |/ ____|
% | |_) | |  | | |  __    ___ __ _ ___  ___  ___
% |  _ <| |  | | | |_ |  / __/ _` / __|/ _ \/ __|
% | |_) | |__| | |__| | | (_| (_| \__ \  __/\__ \
% |____/ \____/ \_____|  \___\__,_|___/\___||___/
%
% See: http://patorjk.com/software/taag/#p=display&v=0&f=Big&t=BUG%20cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All bug case figures start with the number 9

% close all;

%% BUG 

%% Fail conditions
if 1==0
    %
       
end


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




