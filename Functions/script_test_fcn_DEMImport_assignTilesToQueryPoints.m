%% script_test_fcn_DEMImport_assignTilesToQueryPoints
% Exercises the function: fcn_DEMImport_assignTilesToQueryPoints

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_assignTilesToQueryPoints
%   % * Wrote this code originally
% 
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_assignTilesToQueryPoints
%   % * Improved case testing

%% DEMO Case: Assign DEM tiles to LTI test-track query points

figNum = 10001;
titleString = sprintf('DEMO case: Assign DEM tiles to LTI test-track query points');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

% Define query points
mins = [40.77 -77.9];
maxs = [40.9 -77.78];
Nrows = 100;
rng(1);
LLAdata = fcn_INTERNAL_generateRandomInRange(mins,maxs,Nrows);

plotFormat.Color = [1 1 1];
plotFormat.Marker = '.';
plotFormat.MarkerSize = 20;
plotFormat.LineStyle = 'none';
plotFormat.LineWidth = 3;
fcn_plotRoad_plotLL(LLAdata(:,1:2), (plotFormat), (figNum));


queryLatLon = LLAdata(:,1:2);

% Build a bounding box around the query points
margin_deg = 0.0004;

lat_min = min(queryLatLon(:,1)) - margin_deg;
lat_max = max(queryLatLon(:,1)) + margin_deg;
lon_min = min(queryLatLon(:,2)) - margin_deg;
lon_max = max(queryLatLon(:,2)) + margin_deg;

% Function 1: keep only DEM + North entries
requiredStrings = {'\DEM\','\North\'};

[matchingLatLonLimits, matchingZipPaths, ~] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths);

% Function 2: keep only entries overlapping the local query bounding box
queryBoundingBox = [lat_min lat_max lon_min lon_max];

if 1==0
	clear plotFormat
	plotFormat.Color = [0 0.7 0];
	plotFormat.Marker = '.';
	plotFormat.MarkerSize = 10;
	plotFormat.LineStyle = '-';
	plotFormat.LineWidth = 3;
	fcn_DEMImport_plotLatLonLimits(queryBoundingBox, (plotFormat), (figNum));

	plotFormat.Color = [0 0 0.7];
	fcn_DEMImport_plotLatLonLimits(matchingLatLonLimits, (plotFormat), (figNum));
else
	% Create an empty plot
	fcn_plotRoad_plotLL([], [], (figNum));
	set(gca,'MapCenter',[40.791825771895759 -77.845533530997614],'ZoomLevel',12);

end

[overlappingLatLonLimits, ~, ~] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths, -1);

if isempty(overlappingLatLonLimits)
	error('Empty query returned');
end

% Function 3: assign DEM tiles to each query point
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, figNum);

set(gca,'MapCenter',[40.791825771895759 -77.845533530997614],'ZoomLevel',12);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(matchingTileIndexMatrix));
assert(islogical(pointTileLogicalMatrix));
assert(islogical(unmatchedPointFlags));
assert(islogical(multipleMatchFlags));
assert(isnumeric(numMatchesPerPoint));


% Check variable sizes
Nqueries = size(queryLatLon,1);
Nlimits = size(overlappingLatLonLimits,1);
assert(isequal(size(matchingTileIndexMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,2), Nlimits));
assert(isequal(size(unmatchedPointFlags), [Nqueries, 1]));
assert(isequal(size(multipleMatchFlags), [Nqueries, 1]));
assert(isequal(size(numMatchesPerPoint), [Nqueries, 1]));


% Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));
% assert(isequal(round(limitsFt/1E6,4),round([0.1900    0.2000    1.8900    1.9000],4)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

if 1==0
	% Display results
	fprintf(1,'\nNumber of query points: %.0f\n', size(queryLatLon,1));
	fprintf(1,'Number of candidate DEM tiles after Function 2: %.0f\n', size(overlappingLatLonLimits,1));

	fprintf(1,'\nmatchingTileIndexMatrix:\n');
	disp(matchingTileIndexMatrix);

	fprintf(1,'\nnumMatchesPerPoint:\n');
	disp(numMatchesPerPoint);

	fprintf(1,'\nunmatchedPointFlags:\n');
	disp(unmatchedPointFlags);

	fprintf(1,'\nmultipleMatchFlags:\n');
	disp(multipleMatchFlags);
end


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

%% TEST case: Assign DEM tiles to LTI test-track query points
figNum = 20001;
titleString = sprintf('TEST case: Assign DEM tiles to LTI test-track query points');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

% Define LTI test-track query points
% Same style as your earlier DEM interpolation test
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

queryLatLon = LLAdata(:,1:2);

% Build a bounding box around the query points
margin_deg = 0.0004;

lat_min = min(queryLatLon(:,1)) - margin_deg;
lat_max = max(queryLatLon(:,1)) + margin_deg;
lon_min = min(queryLatLon(:,2)) - margin_deg;
lon_max = max(queryLatLon(:,2)) + margin_deg;

queryBoundingBox = [lat_min lat_max lon_min lon_max];

% Function 1: keep only DEM + North entries
requiredStrings = {'\DEM\','\North\'};

[matchingLatLonLimits, matchingZipPaths, ~] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths);

% Function 2: keep only entries overlapping the local query bounding box
[overlappingLatLonLimits, ~, ~] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths);

% Function 3: assign DEM tiles to each query point
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, figNum);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(matchingTileIndexMatrix));
assert(islogical(pointTileLogicalMatrix));
assert(islogical(unmatchedPointFlags));
assert(islogical(multipleMatchFlags));
assert(isnumeric(numMatchesPerPoint));


% Check variable sizes
Nqueries = size(queryLatLon,1);
Nlimits = size(overlappingLatLonLimits,1);
assert(isequal(size(matchingTileIndexMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,2), Nlimits));
assert(isequal(size(unmatchedPointFlags), [Nqueries, 1]));
assert(isequal(size(multipleMatchFlags), [Nqueries, 1]));
assert(isequal(size(numMatchesPerPoint), [Nqueries, 1]));


% Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));
% assert(isequal(round(limitsFt/1E6,4),round([0.1900    0.2000    1.8900    1.9000],4)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

if 1==0
	% Display results
	fprintf(1,'\nNumber of query points: %.0f\n', size(queryLatLon,1));
	fprintf(1,'Number of candidate DEM tiles after Function 2: %.0f\n', size(overlappingLatLonLimits,1));

	fprintf(1,'\nmatchingTileIndexMatrix:\n');
	disp(matchingTileIndexMatrix);

	fprintf(1,'\nnumMatchesPerPoint:\n');
	disp(numMatchesPerPoint);

	fprintf(1,'\nunmatchedPointFlags:\n');
	disp(unmatchedPointFlags);

	fprintf(1,'\nmultipleMatchFlags:\n');
	disp(multipleMatchFlags);
end





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

% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

% Define LTI test-track query points
% Same style as your earlier DEM interpolation test
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

queryLatLon = LLAdata(:,1:2);

% Build a bounding box around the query points
margin_deg = 0.0004;

lat_min = min(queryLatLon(:,1)) - margin_deg;
lat_max = max(queryLatLon(:,1)) + margin_deg;
lon_min = min(queryLatLon(:,2)) - margin_deg;
lon_max = max(queryLatLon(:,2)) + margin_deg;

queryBoundingBox = [lat_min lat_max lon_min lon_max];

% Function 1: keep only DEM + North entries
requiredStrings = {'\DEM\','\North\'};

[matchingLatLonLimits, matchingZipPaths, ~] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths);

% Function 2: keep only entries overlapping the local query bounding box
[overlappingLatLonLimits, ~, ~] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths);

% Function 3: assign DEM tiles to each query point
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, []);

% Check variable types
assert(isnumeric(matchingTileIndexMatrix));
assert(islogical(pointTileLogicalMatrix));
assert(islogical(unmatchedPointFlags));
assert(islogical(multipleMatchFlags));
assert(isnumeric(numMatchesPerPoint));


% Check variable sizes
Nqueries = size(queryLatLon,1);
Nlimits = size(overlappingLatLonLimits,1);
assert(isequal(size(matchingTileIndexMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,2), Nlimits));
assert(isequal(size(unmatchedPointFlags), [Nqueries, 1]));
assert(isequal(size(multipleMatchFlags), [Nqueries, 1]));
assert(isequal(size(numMatchesPerPoint), [Nqueries, 1]));


% Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));
% assert(isequal(round(limitsFt/1E6,4),round([0.1900    0.2000    1.8900    1.9000],4)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

% Define LTI test-track query points
% Same style as your earlier DEM interpolation test
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

queryLatLon = LLAdata(:,1:2);

% Build a bounding box around the query points
margin_deg = 0.0004;

lat_min = min(queryLatLon(:,1)) - margin_deg;
lat_max = max(queryLatLon(:,1)) + margin_deg;
lon_min = min(queryLatLon(:,2)) - margin_deg;
lon_max = max(queryLatLon(:,2)) + margin_deg;

queryBoundingBox = [lat_min lat_max lon_min lon_max];

% Function 1: keep only DEM + North entries
requiredStrings = {'\DEM\','\North\'};

[matchingLatLonLimits, matchingZipPaths, ~] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths);

% Function 2: keep only entries overlapping the local query bounding box
[overlappingLatLonLimits, ~, ~] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths);

% Function 3: assign DEM tiles to each query point
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, (-1));

% Check variable types
assert(isnumeric(matchingTileIndexMatrix));
assert(islogical(pointTileLogicalMatrix));
assert(islogical(unmatchedPointFlags));
assert(islogical(multipleMatchFlags));
assert(isnumeric(numMatchesPerPoint));


% Check variable sizes
Nqueries = size(queryLatLon,1);
Nlimits = size(overlappingLatLonLimits,1);
assert(isequal(size(matchingTileIndexMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,1), Nqueries));
assert(isequal(size(pointTileLogicalMatrix,2), Nlimits));
assert(isequal(size(unmatchedPointFlags), [Nqueries, 1]));
assert(isequal(size(multipleMatchFlags), [Nqueries, 1]));
assert(isequal(size(numMatchesPerPoint), [Nqueries, 1]));


% Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));
% assert(isequal(round(limitsFt/1E6,4),round([0.1900    0.2000    1.8900    1.9000],4)));


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

% Define LTI test-track query points
% Same style as your earlier DEM interpolation test
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

queryLatLon = LLAdata(:,1:2);

% Build a bounding box around the query points
margin_deg = 0.0004;

lat_min = min(queryLatLon(:,1)) - margin_deg;
lat_max = max(queryLatLon(:,1)) + margin_deg;
lon_min = min(queryLatLon(:,2)) - margin_deg;
lon_max = max(queryLatLon(:,2)) + margin_deg;

queryBoundingBox = [lat_min lat_max lon_min lon_max];

% Function 1: keep only DEM + North entries
requiredStrings = {'\DEM\','\North\'};

[matchingLatLonLimits, matchingZipPaths, ~] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths);

% Function 2: keep only entries overlapping the local query bounding box
[overlappingLatLonLimits, overlappingZipPaths, overlappingEntriesFlags] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths);




Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

	% Function 3: assign DEM tiles to each query point
	[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
		multipleMatchFlags, numMatchesPerPoint] = ...
		fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, ([]));
end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations

	% Function 3: assign DEM tiles to each query point
	[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
		multipleMatchFlags, numMatchesPerPoint] = ...
		fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, (-1));

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
function output = fcn_INTERNAL_generateRandomInRange(mins,maxs,Nrows)
allOnes = ones(Nrows,1);
output = allOnes*(maxs-mins) .* rand(Nrows,length(mins)) + allOnes*mins;
end