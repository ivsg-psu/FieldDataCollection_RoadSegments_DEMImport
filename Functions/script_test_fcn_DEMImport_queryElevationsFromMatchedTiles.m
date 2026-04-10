%% script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
% Exercises the function:
% fcn_DEMImport_queryElevationsFromMatchedTiles

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Wrote this code originally

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

[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ...
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

%% Display results
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

%% Assertions

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

