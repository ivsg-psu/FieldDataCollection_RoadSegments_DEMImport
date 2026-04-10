%% script_test_fcn_DEMImport_assignTilesToQueryPoints
% Exercises the function: fcn_DEMImport_assignTilesToQueryPoints

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_assignTilesToQueryPoints
%   % * Wrote this code originally

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

[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths);

% Function 2: keep only entries overlapping the local query bounding box
[overlappingLatLonLimits, overlappingZipPaths, overlappingEntriesFlags] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths);

% Function 3: assign DEM tiles to each query point
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, figNum);

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

% Assertions

% Check output sizes
assert(isequal(size(matchingTileIndexMatrix,1), size(queryLatLon,1)));
assert(isequal(size(pointTileLogicalMatrix,1), size(queryLatLon,1)));
assert(isequal(size(pointTileLogicalMatrix,2), size(overlappingLatLonLimits,1)));
assert(isequal(size(unmatchedPointFlags), [size(queryLatLon,1), 1]));
assert(isequal(size(multipleMatchFlags), [size(queryLatLon,1), 1]));
assert(isequal(size(numMatchesPerPoint), [size(queryLatLon,1), 1]));
