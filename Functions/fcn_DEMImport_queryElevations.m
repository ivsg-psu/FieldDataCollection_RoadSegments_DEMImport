function [mergedElevations, rawElevationMatrix, queryStatus] = ...
    fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths, varargin)
%% fcn_DEMImport_queryElevations 
% 
% Queries elevations for a set of latitude/longitude points 
%
% FORMAT: 
%       [queriedElevationsInMeters] = ...
%           fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,..
%               (requiredStrings), (mergeMethod), (localRootFolder), (figNum))
% INPUTS:
%      queryLatLon:  N x 2 matrix of query latitude/longitude points
%    
%      LatLonLimits: N x 4 matrix [lat_min lat_max lon_min lon_max] of
%      LatLon limits from DEM files
% 
%      zipPaths: N x 1 cell array of zip path strings from DEM files
%    
%      (OPTIONAL INPUTS)
%    
%      requiredStrings: cell array or string array of strings that must be in
%      the results, default is {'\DEM\', '\North\ or \South\'}
%    
%      mergeMethod: Method used to merge multiple DEM elevations for the same
%      point
%    
%          Options:
%              'first'   - use the first available DEM elevation
%              'mean'    - average all available DEM elevations
%              'median'  - take the median of all available DEM elevations
%    
%          Default:
%              'first'
%    
%      localRootFolder: Folder used to store local DEM zip files downloaded
%      from PASDA. Default: fullfile(pwd,'LargeData')
%
%      figNum: a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
% 
%   queriedElevationsInMeters: N x 1 vector of final merged elevations in meters
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
%     script_test_fcn_DEMImport_queryElevations for a full
%     test suite.
%
% This function was written on 2026_04_13 by Sean Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_13 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevations
%   % * Wrote this code originally
% 2026_04_13 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_queryElevations
%   % * Modified the instructions of the inputs


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 7; % The largest Number of argument inputs to the function
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
        fcn_DebugTools_checkInputsToFunctions(queryLatLon, '2column_of_mixed');

		% Check LatLonLimits input
        fcn_DebugTools_checkInputsToFunctions(LatLonLimits, '4column_of_mixed');

		% Check zipPaths input
        assert(size(zipPaths,1)==size(LatLonLimits,1));

    end
end

% Does user want to specify requiredStrings
requiredStrings = {'\DEM\', '\North\ or \South\'}; 
if (4 <= nargin)
    temp = varargin{1};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        requiredStrings = temp;
    end
end



% Does user want to specify mergeMethod
mergeMethod = 'first';
if (0==flag_max_speed) && (4 <= nargin)
    temp = varargin{1};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        mergeMethod = temp;
    end
end


% Does user want to specify localRootFolder
localRootFolder = fullfile(pwd,'LargeData');
if (0==flag_max_speed) && (4 <= nargin)
    temp = varargin{2};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        localRootFolder = temp;
    end
end

% Does user want to show the plots?
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


%%%%%%%%%%%%
% Step 1: keep only limits that have valid strings
[matchingLatLonLimits, matchingZipPaths, ~] = ...
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, -1); 

% Remove NaN values
goodResults = ~isnan(matchingLatLonLimits(:,1));
matchingLatLonLimits = matchingLatLonLimits(goodResults,:);
matchingZipPaths = matchingZipPaths(goodResults,:);

%%%%%%%%%%%%
% Step 2: keep only entries overlapping the local query box

% Build local query bounding box
margin_deg = 0.05;

lat_min = min(queryLatLon(:,1)) - margin_deg;
lat_max = max(queryLatLon(:,1)) + margin_deg;
lon_min = min(queryLatLon(:,2)) - margin_deg;
lon_max = max(queryLatLon(:,2)) + margin_deg;

queryBoundingBox = [lat_min lat_max lon_min lon_max];


[overlappingLatLonLimits, overlappingZipPaths, overlappingEntriesFlags] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths, 99999); %#ok<ASGLU>

if 1==0
    clear plotFormat
    plotFormat.Color = [1 1 0];
    plotFormat.Marker = '.';
    plotFormat.MarkerSize = 10;
    plotFormat.LineStyle = 'none';
    plotFormat.LineWidth = 3;

    figNum = 99999;

    fcn_plotRoad_plotLL((queryLatLon), (plotFormat), (figNum));
end

%%%%%%%%%%%
% Step 3: assign DEM tiles to query points
[matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, ...
    multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, -1); %#ok<ASGLU>


%%%%%%%%%%%
% Step 4: query elevations from matched tiles
[mergedElevations, rawElevationMatrix, queryStatus] = ...
    fcn_DEMImport_queryElevationsFromMatchedTiles( ...
        queryLatLon, matchingTileIndexMatrix, overlappingZipPaths, ...
        mergeMethod, localRootFolder, figNum);

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