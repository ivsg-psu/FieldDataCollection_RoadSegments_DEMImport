%% script_test_fcn_DEMImport_ensureLocalZipFromPASDAPath
% Exercises the function:
% fcn_DEMImport_ensureLocalZipFromPASDAPath

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_ensureLocalZipFromPASDAPath
%   % * Wrote this code originally

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
localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, figNum);

% Assertions

% Build expected local path manually
expectedLocalZipFile = fullfile(localRootFolder,'26001940PAN_dem.zip');

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
    fcn_DEMImport_ensureLocalZipFromPASDAPath(badPathEntry, localRootFolder, -1);
catch ME
    didThrowError = true;
    fprintf(1,'Expected error caught:\n%s\n', ME.message);
end

assert(didThrowError, ...
    'Expected an error when zipPathEntry does not contain ''download\''.');




