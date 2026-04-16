function [mergedElevations, rawElevationMatrix, queryStatus] = ...
    fcn_DEMImport_queryElevationsFromMatchedTiles(...
    queryLatLon, matchingTileIndexMatrix, overlappingZipPaths, varargin)
%% fcn_DEMImport_queryElevationsFromMatchedTiles 
% 
% Queries elevations for a set of latitude/longitude points using the DEM
% tile assignments produced earlier in the pipeline.
%
% This function acts as a wrapper around the single-tile DEM query
% function. It loops through the candidate DEM tiles, determines which
% query points are assigned to each tile, ensures that the required DEM zip
% file is available locally, queries elevations from that tile, and then
% merges multiple DEM results for points that belong to more than one tile.
%
% FORMAT: 
%       [mergedElevations, rawElevationMatrix, queryStatus] = ...
%           fcn_DEMImport_queryElevationsFromMatchedTiles(...
%               queryLatLon, matchingTileIndexMatrix, overlappingZipPaths,..
%               (mergeMethod), (localRootFolder), (figNum))
% INPUTS:
%   queryLatLon:  N x 2 matrix of query latitude/longitude points
% 
%   matchingTileIndexMatrix: N x K numeric matrix of tile indices (NaN
%   padded)
%
%       - each row corresponds to one query point
%       - each non-NaN entry in a row is the index of a DEM tile that
%         contains that query point
%
%   overlappingZipPaths: M x 1 cell array or string array of candidate DEM
%   zip path entries
%
%   (OPTIONAL INPUTS)
% 
%   mergeMethod: Method used to merge multiple DEM elevations for the same
%   point
%
%       Options:
%           'first'   - use the first available DEM elevation
%           'mean'    - average all available DEM elevations
%           'median'  - take the median of all available DEM elevations
%
%       Default:
%           'first'
%
%   localRootFolder: Folder used to store local DEM zip files downloaded
%   from PASDA
%
%       Default:
%           fullfile(pwd,'LargeData')
%
%      figNum: a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
% 
%   mergedElevations: N x 1 vector of final merged elevations in meters
%
%   rawElevationMatrix: N x K numeric matrix storing the raw elevation
%   returned from each matched DEM tile before merging
%
%       - rows correspond to query points
%       - columns correspond to tile-match slots from
%         matchingTileIndexMatrix
% 
%   queryStatus:
%       .unmatchedPointFlags
%       .multipleMatchFlags
%       .numValidElevationsPerPoint
%       .mergeMethod
%       .localZipFilesUsed
%
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script:
%     script_test_fcn_DEMImport_queryElevationsFromMatchedTiles for a full
%     test suite.
%
% This function was written on 2026_04_09 by Aneesh Batchu
% Questions or comments? abb6486@psu.edu or sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Wrote this code originally
%
% 2026_04_16 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Fixed bug where input arguments are not imported if user specifies
%   %   % fast mode and where input argument count number was wrong

% TO-DO:
%
% 2026_04_13 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * The optional inputs are ONLY filled if not in fast mode. This is a
%   %   % bug
%   % * The test script is not in standard form (variable type, then size,
%   %   % then values). Need to fix this.

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 6; % The largest Number of argument inputs to the function
flag_max_speed = 0; % The default. This runs code with all error checking
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS");
    MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG = getenv("MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS);
    end
end

if flag_do_debug % If debugging is on, print on entry/exit to the function
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_figNum = 999978; %#ok<NASGU>
else
    debug_figNum = []; %#ok<NASGU>
end

%% check input arguments?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0==flag_max_speed
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(3,MAX_NARGIN);

        % Check queryLatLon input
        fcn_DebugTools_checkInputsToFunctions(queryLatLon, '2column_of_mixed')

    end
end


% Does user want to specify mergeMethod
mergeMethod = 'first';
if (4 <= nargin)
    temp = varargin{1};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        mergeMethod = temp;
    end
end


% Does user want to specify localRootFolder
localRootFolder = fullfile(pwd,'LargeData');
if (5 <= nargin)
    temp = varargin{2};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        localRootFolder = temp;
    end
end

% Does user want to show the plots?
figNum = [];
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
    temp = varargin{end};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        figNum = temp;
        flag_do_plots = 1;
    end
end


%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of query points
N_queryPoints = size(queryLatLon,1);

% Number of tile slots per query point in the compact N x K matrix
K_tileSlots = size(matchingTileIndexMatrix,2);

% Number of candidate DEM zip paths
M_tiles = numel(overlappingZipPaths);

% Preallocate matrix of raw elevations before merging
rawElevationMatrix = nan(N_queryPoints, K_tileSlots);

% Keep track of which local zip file was used for each tile index
localZipFilesUsed = cell(M_tiles,1);

% Loop over tile indices, not over query points.
% This avoids repeatedly opening the same DEM tile for many points.
NfoundTotal = 0;
for tileIdx = 1:M_tiles
    thisZipPathEntry = overlappingZipPaths{tileIdx};

    if flag_do_plots
        fprintf(1,'Processing file: %s',thisZipPathEntry);
    end

    % Find all occurrences of this tile index inside the N x K match matrix.
    % pointRows tells us which query points belong to this tile.
    % pointCols tells us which slot in rawElevationMatrix should receive
    % the returned elevation.
    [pointRows, pointCols] = find(matchingTileIndexMatrix == tileIdx);
    
    NfoundTotal = NfoundTotal + length(pointRows);
    fprintf(1,' %.0f found here, percent done overall: %.2f\n',length(pointRows), NfoundTotal*100/N_queryPoints);
    

    % If no query point uses this tile, skip it
    if isempty(pointRows)
        continue;
    end

    % Resolve/download the local zip file for this tile if needed
    localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(thisZipPathEntry, localRootFolder);
    localZipFilesUsed{tileIdx} = localZipFile;

    % Pull out only the query points assigned to this tile
    theseQueryPoints = queryLatLon(pointRows,1:2);

    % Query elevations from this one tile
    [tileElevations, insideTileFlag] = ...
        fcn_DEMImport_queryElevationsFromSingleTile(localZipFile, theseQueryPoints, -1);

    % Write returned elevations back into the raw elevation matrix
    for nElevations = 1:numel(pointRows)
        if insideTileFlag(nElevations)
            rawElevationMatrix(pointRows(nElevations), pointCols(nElevations)) = tileElevations(nElevations);
        end
    end
end

%% Merge multiple tile elevations for each query point

mergedElevations = nan(N_queryPoints,1);

for ith_queryPoint = 1:N_queryPoints

    % Pull out all valid raw DEM elevations for this point
    theseValues = rawElevationMatrix(ith_queryPoint, ~isnan(rawElevationMatrix(ith_queryPoint,:)));

    % If no DEM produced a valid value, leave as NaN
    if isempty(theseValues)
        mergedElevations(ith_queryPoint) = NaN;

    % Otherwise merge according to the selected method
    else
        switch lower(mergeMethod)
            case 'first'
                mergedElevations(ith_queryPoint) = theseValues(1);

            case 'mean'
                mergedElevations(ith_queryPoint) = mean(theseValues, 'omitnan');

            case 'median'
                mergedElevations(ith_queryPoint) = median(theseValues, 'omitnan');

            otherwise
                error('Unknown mergeMethod: %s. Use ''first'', ''mean'', or ''median''.', mergeMethod);
        end
    end
end

%% Build status output structure

queryStatus = struct;
queryStatus.unmatchedPointFlags = all(isnan(rawElevationMatrix),2);
queryStatus.multipleMatchFlags = sum(~isnan(rawElevationMatrix),2) > 1;
queryStatus.numValidElevationsPerPoint = sum(~isnan(rawElevationMatrix),2);
queryStatus.mergeMethod = mergeMethod;
queryStatus.localZipFilesUsed = localZipFilesUsed;

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots

    figure(figNum);
    close(figNum);

    fprintf(1,'\nMerged elevations:\n');
    disp(mergedElevations);

    fprintf(1,'\nRaw elevation matrix:\n');
    disp(rawElevationMatrix);

    fprintf(1,'\nNumber of valid elevations per point:\n');
    disp(queryStatus.numValidElevationsPerPoint);

end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function

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