%% script_test_fcn_DEMImport_queryElevationsFromSingleTile
% Exercises the function: fcn_DEMImport_queryElevationsFromSingleTile

% REVISION HISTORY:
% 
% 2026_04_08 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_queryElevationsFromSingleTile
%   % * Wrote this code originally
% 
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_queryElevationsFromSingleTile
%   % * Cleaned up test scripts
% 
% 2026_04_16 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_queryElevationsFromSingleTile
%   % * Added a test case to demonstrate EXTRAPOLATE query mode (20003)

%% Set up the workspace
close all

%% Code demos start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____                              ____   __    _____          _
%  |  __ \                            / __ \ / _|  / ____|        | |
%  | |  | | ___ _ __ ___   ___  ___  | |  | | |_  | |     ___   __| | ___
%  | |  | |/ _ \ '_ ` _ \ / _ \/ __| | |  | |  _| | |    / _ \ / _` |/ _ \
%  | |__| |  __/ | | | | | (_) \__ \ | |__| | |   | |___| (_) | (_| |  __/
%  |_____/ \___|_| |_| |_|\___/|___/  \____/|_|    \_____\___/ \__,_|\___|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Demos%20Of%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 1

close all;
fprintf(1,'Figure: 1XXXXXX: DEMO cases\n');

%% DEMO Case: Query test track LL points for elevation using a single DEM tile using interpolate as queryMode

figNum = 10001;
titleString = sprintf('DEMO case: Query test track LL points for elevation using a single DEM tile using interpolate as queryMode');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Zip file name
fileName = '26001940PAN_dem.zip'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);

zipFile = fullfile(lasDirectory,fileName);
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% LLA Data at the LTI test track (PennState)
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight; % Convert from ellipsoid height to sea level height
trueAltitude_InMeters = LLAdata(:,3) ;

% Full local zip file path (INPUT 1)
localZipFilePath = zipFile; 

% Query Latitudes and Longitudes (INPUT 2)
queryLatLon = LLAdata(:,1:2); 

% Query mode (INPUT 3)
queryMode = 'Interpolate'; 

% Call the function
[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), (figNum));

% Assertions

% Reference 
[limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);

% Size checks
assert(isequal(size(elevationsInMeters), [size(queryLatLon,1), 1]));
assert(isequal(size(insideTileFlag), [size(queryLatLon,1), 1]));
assert(isequal(size(limitsLatLon), size(limitsLatLon_ref)));

% Limits check
assert(max(abs(limitsLatLon(:)-limitsLatLon_ref(:))) < 1e-12, 'limitsLatLon does not match extracted reference limits.');

% Query points check
assert(all(insideTileFlag),'Expected all test-track query points to be inside the chosen DEM tile.');

difference_InMeters = elevationsInMeters - trueAltitude_InMeters;
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO Case: Query test track LL points for elevation using a single DEM tile using extrapolate as queryMode

figNum = 10001;
titleString = sprintf('DEMO case: Query test track LL points for elevation using a single DEM tile using extrapolate as queryMode');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Zip file name
fileName = '26001940PAN_dem.zip'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);

zipFile = fullfile(lasDirectory,fileName);
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% LLA Data at the LTI test track (PennState)
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight; % Convert from ellipsoid height to sea level height
trueAltitude_InMeters = LLAdata(:,3) ;

% Full local zip file path (INPUT 1)
localZipFilePath = zipFile; 

% Query Latitudes and Longitudes (INPUT 2)
queryLatLon = LLAdata(:,1:2); 

% Query mode (INPUT 3)
queryMode = 'Extrapolate'; 

% Call the function
[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), (figNum));

% Assertions

% Reference 
[limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);

% Size checks
assert(isequal(size(elevationsInMeters), [size(queryLatLon,1), 1]));
assert(isequal(size(insideTileFlag), [size(queryLatLon,1), 1]));
assert(isequal(size(limitsLatLon), size(limitsLatLon_ref)));

% Limits check
assert(max(abs(limitsLatLon(:)-limitsLatLon_ref(:))) < 1e-12, 'limitsLatLon does not match extracted reference limits.');

% Query points check
assert(all(insideTileFlag),'Expected all test-track query points to be inside the chosen DEM tile.');

difference_InMeters = elevationsInMeters - trueAltitude_InMeters;
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


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

%% TEST case: Multiple images exist in the file and their sizes are different
figNum = 20001;
titleString = sprintf('TEST case: Multiple images exist in the file and their sizes are different');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

localZipFilePath = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download\pamap\pamap_lidar\cycle1\DEM\North\2008\10000000\17002190PAN_dem.zip';

% Reference 
[limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);
meanLatLon = [mean(limitsLatLon_ref(1,1:2)) mean(limitsLatLon_ref(1,3:4))];

Nqueries = 100;
variationLL = 0.001;
rng(1); % For repeatability
queryLatLon = repmat(meanLatLon,Nqueries,1) + variationLL*randn(Nqueries,2);

% ONLY FOR TESTING FAIL CASE --> queryLatLon = [queryLatLon; meanLatLon+[1 1]; meanLatLon-[1 1]];

% Query mode 
queryMode = 'Interpolate';

[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), (figNum));

% Size checks
assert(isequal(size(elevationsInMeters), [size(queryLatLon,1), 1]));
assert(isequal(size(insideTileFlag), [size(queryLatLon,1), 1]));
assert(isequal(size(limitsLatLon), size(limitsLatLon_ref)));

% Limits check
assert(max(abs(limitsLatLon(:)-limitsLatLon_ref(:))) < 1e-12, 'limitsLatLon does not match extracted reference limits.');

% Query points check
assert(all(insideTileFlag),'Expected all test-track query points to be inside the chosen DEM tile.');

% difference_InMeters = elevationsInMeters - 129.6037;
% assert(all(abs(difference_InMeters) < 1.0,'all'));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% TEST Case: Query tile with points near edges using INTERPOLATE (bug case)

figNum = 20002;
titleString = sprintf('TEST Case: Query tile with points near edges using INTERPOLATE (bug case)');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Zip file name
fileName = '26001940PAN_dem.zip'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);

zipFile = fullfile(lasDirectory,fileName);
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

thisTileLimitsLatLon = [40.852772999999999  40.880246999999997 -77.853061999999994 -77.816872000000004];

% LLA Data at the LTI test track (PennState)
LLAdata = [ ...
    thisTileLimitsLatLon(1,1) thisTileLimitsLatLon(1,3);
    thisTileLimitsLatLon(1,1) thisTileLimitsLatLon(1,4);
    thisTileLimitsLatLon(1,2) thisTileLimitsLatLon(1,3);
    thisTileLimitsLatLon(1,2) thisTileLimitsLatLon(1,4);
    ];

% Full local zip file path (INPUT 1)
localZipFilePath = zipFile; 

% Query Latitudes and Longitudes (INPUT 2)
queryLatLon = LLAdata(:,1:2); 

% Query mode (INPUT 3)
queryMode = 'Interpolate';

% Call the function
[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), (figNum));

% Assertions

% Reference 
[limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);

% Size checks
assert(isequal(size(elevationsInMeters), [size(queryLatLon,1), 1]));
assert(isequal(size(insideTileFlag), [size(queryLatLon,1), 1]));
assert(isequal(size(limitsLatLon), size(limitsLatLon_ref)));

% Limits check
assert(max(abs(limitsLatLon(:)-limitsLatLon_ref(:))) < 1e-12, 'limitsLatLon does not match extracted reference limits.');

% Query points check
assert(all(isnan(elevationsInMeters)),'Expected altitudes of the queryPoints to be NaN');
assert(all(insideTileFlag),'Expected all test-track query points to be inside the chosen DEM tile.');


% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% TEST Case: Query tile with points near edges using EXTRAPOLATE

figNum = 20003;
titleString = sprintf('TEST Case: Query tile with points near edges using EXTRAPOLATE');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Zip file name
fileName = '26001940PAN_dem.zip'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);

zipFile = fullfile(lasDirectory,fileName);
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

thisTileLimitsLatLon = [40.852772999999999  40.880246999999997 -77.853061999999994 -77.816872000000004];

% LLA Data at the LTI test track (PennState)
LLAdata = [ ...
    thisTileLimitsLatLon(1,1) thisTileLimitsLatLon(1,3);
    thisTileLimitsLatLon(1,1) thisTileLimitsLatLon(1,4);
    thisTileLimitsLatLon(1,2) thisTileLimitsLatLon(1,3);
    thisTileLimitsLatLon(1,2) thisTileLimitsLatLon(1,4);
    ];

% % Reference 
% [limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(zipFile, -2);
% 
% % LLA Data 
% LLAdata = [ ...
%     limitsLatLon_ref(1,1) limitsLatLon_ref(1,3);
%     limitsLatLon_ref(1,1) limitsLatLon_ref(1,4);
%     limitsLatLon_ref(1,2) limitsLatLon_ref(1,3);
%     limitsLatLon_ref(1,2) limitsLatLon_ref(1,4);
%     ];

% Full local zip file path (INPUT 1)
localZipFilePath = zipFile; 

% Query Latitudes and Longitudes (INPUT 2)
queryLatLon = LLAdata(:,1:2); 

% Query mode (INPUT 3)
queryMode = 'Extrapolate';

% Call the function
[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), (figNum));

% Assertions

% Reference 
[limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);

% Size checks
assert(isequal(size(elevationsInMeters), [size(queryLatLon,1), 1]));
assert(isequal(size(insideTileFlag), [size(queryLatLon,1), 1]));
assert(isequal(size(limitsLatLon), size(limitsLatLon_ref)));

% Limits check
assert(max(abs(limitsLatLon(:)-limitsLatLon_ref(:))) < 1e-12, 'limitsLatLon does not match extracted reference limits.');

% Query points check
assert(all(~isnan(elevationsInMeters)),'Expected all query points to be extrapolated');

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));
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

thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Zip file name
fileName = '26001940PAN_dem.zip'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);

zipFile = fullfile(lasDirectory,fileName);
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% LLA Data at the LTI test track (PennState)
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight; % Convert from ellipsoid height to sea level height
trueAltitude_InMeters = LLAdata(:,3) ;

% Full local zip file path (INPUT 1)
localZipFilePath = zipFile; 

% Query Latitudes and Longitudes (INPUT 2)
queryLatLon = LLAdata(:,1:2); 

% Query mode (INPUT 3)
queryMode = 'interpolate';

% Call the function
[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), ([]));

% Assertions

% Reference 
[limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);

% Size checks
assert(isequal(size(elevationsInMeters), [size(queryLatLon,1), 1]));
assert(isequal(size(insideTileFlag), [size(queryLatLon,1), 1]));
assert(isequal(size(limitsLatLon), size(limitsLatLon_ref)));

% Limits check
assert(max(abs(limitsLatLon(:)-limitsLatLon_ref(:))) < 1e-12, 'limitsLatLon does not match extracted reference limits.');

% Query points check
assert(all(insideTileFlag),'Expected all test-track query points to be inside the chosen DEM tile.');

difference_InMeters = elevationsInMeters - trueAltitude_InMeters;
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Zip file name
fileName = '26001940PAN_dem.zip'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);

zipFile = fullfile(lasDirectory,fileName);
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% LLA Data at the LTI test track (PennState)
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight; % Convert from ellipsoid height to sea level height
trueAltitude_InMeters = LLAdata(:,3) ;

% Full local zip file path (INPUT 1)
localZipFilePath = zipFile; 

% Query Latitudes and Longitudes (INPUT 2)
queryLatLon = LLAdata(:,1:2); 

% Query mode (INPUT 3)
queryMode = 'interpolate';

% Call the function
[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), (-1));

% Assertions

% Reference 
[limitsLatLon_ref, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);

% Size checks
assert(isequal(size(elevationsInMeters), [size(queryLatLon,1), 1]));
assert(isequal(size(insideTileFlag), [size(queryLatLon,1), 1]));
assert(isequal(size(limitsLatLon), size(limitsLatLon_ref)));

% Limits check
assert(max(abs(limitsLatLon(:)-limitsLatLon_ref(:))) < 1e-12, 'limitsLatLon does not match extracted reference limits.');

% Query points check
assert(all(insideTileFlag),'Expected all test-track query points to be inside the chosen DEM tile.');

difference_InMeters = elevationsInMeters - trueAltitude_InMeters;
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';

% Zip file name
fileName = '26001940PAN_dem.zip'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);

zipFile = fullfile(lasDirectory,fileName);
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% LLA Data at the LTI test track (PennState)
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

LLdata = LLAdata(:,1:2);
geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight; % Convert from ellipsoid height to sea level height
trueAltitude_InMeters = LLAdata(:,3) ;

% Full local zip file path (INPUT 1)
localZipFilePath = zipFile; 

% Query Latitudes and Longitudes (INPUT 2)
queryLatLon = LLAdata(:,1:2); 

% Query mode (INPUT 3)
queryMode = 'interpolate';

Niterations = 1;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

	% Call the function
	[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), ([]));

end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations

	% Call the function
	[elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (queryMode), (-1));

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