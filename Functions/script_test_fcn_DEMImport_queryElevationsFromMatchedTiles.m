%% script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
% Exercises the function:
% fcn_DEMImport_queryElevationsFromMatchedTiles

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Wrote this code originally
% 
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Cleaned up test scripts

%% DEMO Case: Query LTI test-track elevations using matched DEM tiles

figNum = 10001;
titleString = sprintf('DEMO case: Query elevations from matched DEM tiles');
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

% Define LTI test-track points
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

% Geoid-corrected truth values for comparison
geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
trueAltitude_InMeters = LLAdata(:,3);

% Build local query bounding box
margin_deg = 0.0004;

lat_min = min(queryLatLon(:,1)) - margin_deg;
lat_max = max(queryLatLon(:,1)) + margin_deg;
lon_min = min(queryLatLon(:,2)) - margin_deg;
lon_max = max(queryLatLon(:,2)) + margin_deg;

queryBoundingBox = [lat_min lat_max lon_min lon_max];

% Function 1: keep only DEM and North entries
requiredStrings = {'\DEM\','\North\'};

[matchingLatLonLimits, matchingZipPaths, ~] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, -1); 

% Function 2: keep only entries overlapping the local query box
[overlappingLatLonLimits, overlappingZipPaths, overlappingEntriesFlags] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths, -1); 

% Function 3: assign DEM tiles to query points
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, -1); 

% Function 4: query elevations from matched tiles
mergeMethod = 'first';

% This folder is where the PASDA zip files will be stored locally
localRootFolder = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(localRootFolder);

[mergedElevations, rawElevationMatrix, queryStatus] = ...
    fcn_DEMImport_queryElevationsFromMatchedTiles( ...
        queryLatLon, matchingTileIndexMatrix, overlappingZipPaths, ...
        mergeMethod, localRootFolder, figNum);

%%%%
%  Display results
fprintf(1,'\nMerged elevations (m):\n');
disp(mergedElevations);

fprintf(1,'\nRaw elevation matrix (m):\n');
disp(rawElevationMatrix);

fprintf(1,'\nQuery status:\n');
disp(queryStatus);

% Compare to geoid-corrected truth
difference_InMeters = mergedElevations - trueAltitude_InMeters;

fprintf(1,'\nDifference between merged DEM elevations and truth (m):\n');
disp(difference_InMeters);

%%%%
%  Assertions

% 1. Output sizes
assert(isequal(size(mergedElevations), [size(queryLatLon,1), 1]));

assert(isequal(size(rawElevationMatrix,1), size(queryLatLon,1)));

% 2. Status fields exist
assert(isfield(queryStatus,'unmatchedPointFlags'));
assert(isfield(queryStatus,'multipleMatchFlags'));
assert(isfield(queryStatus,'numValidElevationsPerPoint'));
assert(isfield(queryStatus,'mergeMethod'));
assert(isfield(queryStatus,'localZipFilesUsed'));

% 3. No unmatched points expected for this local LTI test-track demo
assert(all(~queryStatus.unmatchedPointFlags));

% 4. At least one valid elevation per point
assert(all(queryStatus.numValidElevationsPerPoint >= 1));

% 5. Merged elevations should be finite
assert(all(isfinite(mergedElevations)), ...
    'Merged elevations must be finite for all test points.');

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

%% TEST case: Weird case 1
figNum = 20001;
titleString = sprintf('TEST case: Not coded yet');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;





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
requiredStrings = {'DEM'}; 

% Call the function
[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ... 
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, ([]));

% Check variable types
assert(isnumeric(matchingLatLonLimits));
assert(isstring(matchingZipPaths));
assert(islogical(matchingEntriesFlags));

% Check variable sizes
Ninputs = size(LatLonLimits,1);
Nmatches = size(matchingLatLonLimits,1);
assert(size(matchingZipPaths,1)==Nmatches);
assert(size(matchingEntriesFlags,1)==Ninputs);
assert(size(matchingLatLonLimits,2)==4);
assert(size(matchingZipPaths,2)>=0);
assert(size(matchingEntriesFlags,2)==1);

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
requiredStrings = {'DEM'}; 

% Call the function
[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ... 
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, (-1));

% Check variable types
assert(isnumeric(matchingLatLonLimits));
assert(isstring(matchingZipPaths));
assert(islogical(matchingEntriesFlags));

% Check variable sizes
Ninputs = size(LatLonLimits,1);
Nmatches = size(matchingLatLonLimits,1);
assert(size(matchingZipPaths,1)==Nmatches);
assert(size(matchingEntriesFlags,1)==Ninputs);
assert(size(matchingLatLonLimits,2)==4);
assert(size(matchingZipPaths,2)>=0);
assert(size(matchingEntriesFlags,2)==1);

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
requiredStrings = {'DEM'}; 


Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

	% Call the function
	[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ...
		fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, ([]));

end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations

	% Call the function
	[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ...
		fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, ([]));

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

