function [matchingTileIndexMatrix, pointTileLogicalMatrix, unmatchedPointFlags, multipleMatchFlags, numMatchesPerPoint] = ...
    fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, varargin)
%% fcn_DEMImport_assignTilesToQueryPoints
% 
% Assigns one or more DEM tile indices to each query point by checking
% whether each query latitude/longitude point lies inside each candidate
% DEM tile's latitude/longitude limits.
%
% FORMAT: 
% 
% [matchingTileIndexMatrix, unmatchedPointFlags, multipleMatchFlags, numMatchesPerPoint] = ...
%       fcn_DEMImport_assignTilesToQueryPoints(queryLatLon, overlappingLatLonLimits, (figNum))
% 
% INPUTS:
% 
%   queryLatLon: N x 2 matrix of query points in latitude and longitude
% 
%   overlappingLatLonLimits: [lat_min lat_max lon_min lon_max] M x 4 matrix
%   containing the latitude/longitude limits of the candidate DEM tiles
% 
%   (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
% 
%   matchingTileIndexMatrix : N x K matrix matching DEM tile indices,
%   padded with NaN where needed
% 
%   pointTileLogicalMatrix: N x M logical matrix describing the full
%   point-to-tile relationship
% 
%   unmatchedPointFlags: N x 1 logical, true indicates that the query
%   point matched no DEM tiles
% 
%   multipleMatchFlags: N x 1 logical, true indicates that the query
%   point matched more than one DEM tile
% 
%   numMatchesPerPoint: N x 1 vector giving the number of matching DEM
%   tiles for each query
%       point
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script:
%     script_test_fcn_DEMImport_assignTilesToQueryPoints for a full
%     test suite.
%
% This function was written on 2026_04_09 by Aneesh Batchu
% Questions or comments? abb6486@psu.edu or sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_assignTilesToQueryPoints
%   % * Wrote this code originally
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_assignTilesToQueryPoints
%   % * Modified input checking to allow mixed inputs for
%   %   % overlappingLatLonLimits 

% TO-DO:
%
% 2026_03_21 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_assignTilesToQueryPoints
%   % * Need to be able to handle cases where the input,
%   overlappingLatLonLimits, may be empty. This happens when the user might
%   do a query over a location where there is no limit definition files.


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 3; % The largest Number of argument inputs to the function
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
        narginchk(2,MAX_NARGIN);

        % Check queryLatLon input
        fcn_DebugTools_checkInputsToFunctions(queryLatLon, '2column_of_mixed')

        % Check overlappingLatLonLimits input
        fcn_DebugTools_checkInputsToFunctions(overlappingLatLonLimits, '4column_of_mixed')

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

% Number of query points
N_queryLatLon = size(queryLatLon,1);

% Number of candidate DEM tiles
M_latLonLimits = size(overlappingLatLonLimits,1);

% Preallocate storage:
% allMatches stores the tile indices for each query point in cell form
allMatches = cell(N_queryLatLon,1);

% numMatchesPerPoint stores how many DEM tiles each query point matched
numMatchesPerPoint = zeros(N_queryLatLon,1);

% pointTileLogicalMatrix stores the full point-to-tile relationship:
% rows = query points, columns = DEM tiles
pointTileLogicalMatrix = false(N_queryLatLon, M_latLonLimits);

% Split DEM limits into separate vectors to make the point-in-tile
% containment test easier to read
tileLatMin = overlappingLatLonLimits(:,1);
tileLatMax = overlappingLatLonLimits(:,2);
tileLonMin = overlappingLatLonLimits(:,3);
tileLonMax = overlappingLatLonLimits(:,4);

% Loop through each query point
for ith_queryPoint = 1:N_queryLatLon

    % Extract the latitude and longitude of the current query point
    queryLat = queryLatLon(ith_queryPoint,1);
    queryLon = queryLatLon(ith_queryPoint,2);

    % Check this query point against all candidate DEM tile limits
    %
    % A point is considered inside a tile if:
    %   lat_min <= queryLat < lat_max
    %   lon_min <= queryLon < lon_max
    pointFlags = ...
        (tileLatMin <= queryLat) & ...
        (tileLatMax >  queryLat) & ...
        (tileLonMin <= queryLon) & ...
        (tileLonMax >  queryLon);

    % Store the full logical relationship for this point
    pointTileLogicalMatrix(ith_queryPoint,:) = pointFlags(:)';

    % Convert the logical flags into actual tile indices
    matchedIndices = find(pointFlags);

    % Store the matching tile indices in a cell for this point
    allMatches{ith_queryPoint} = matchedIndices(:)';

    % Count how many tiles matched this query point
    numMatchesPerPoint(ith_queryPoint) = length(matchedIndices);
end

% Flag points that matched no tiles
unmatchedPointFlags = (numMatchesPerPoint == 0);

% Flag points that matched more than one tile
multipleMatchFlags = (numMatchesPerPoint > 1);

% Determine how many columns are needed for the NaN-padded output matrix
% K = maximum number of matches for any one point
maxMatches = max(numMatchesPerPoint);

% Build the N x K numeric matrix of matched tile indices
if isempty(maxMatches) || maxMatches == 0
    % If no points matched any tile, return a single-column NaN matrix
    matchingTileIndexMatrix = nan(N_queryLatLon,1);
else
    % Preallocate the N x K matrix with NaNs
    matchingTileIndexMatrix = nan(N_queryLatLon, maxMatches);

    % Fill each row with the tile indices that matched that point
    for ith_queryPoint = 1:N_queryLatLon
        theseMatches = allMatches{ith_queryPoint};
        if ~isempty(theseMatches)
            matchingTileIndexMatrix(ith_queryPoint,1:numel(theseMatches)) = theseMatches;
        end
    end
end


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

	currentAxis = gca;
	colorOrdering = currentAxis.ColorOrder;
	Ncolors = size(colorOrdering,1);

	plotFormat.Color = [1 1 1];
	plotFormat.Marker = '.';
	plotFormat.MarkerSize = 20;
	plotFormat.LineStyle = 'none';
	plotFormat.LineWidth = 3;
	fcn_plotRoad_plotLL(queryLatLon, (plotFormat), (figNum));

	for ith_limit = 1:size(overlappingLatLonLimits,1)
		thisLimit = overlappingLatLonLimits(ith_limit,:);

		ith_color = mod(ith_limit,Ncolors)+1;
		plotFormat.Color = colorOrdering(ith_color,:);
		plotFormat.Marker = '.';
		plotFormat.MarkerSize = 20;
		plotFormat.LineStyle = '-';
		plotFormat.LineWidth = 3;

		fcn_DEMImport_plotLatLonLimits(thisLimit, (plotFormat), (figNum));

		% Plot the query points associated with this limit. Keep any that
		% have a column-wise match
		matchingPointFlags = any(matchingTileIndexMatrix == ith_limit,2);
		pointsThisLimit = queryLatLon(matchingPointFlags,1:2);
				
		plotFormat.Marker = 'o';
		plotFormat.LineStyle = 'none';

		fcn_plotRoad_plotLL(pointsThisLimit, (plotFormat), (figNum));

	end

	if 1==0
		fprintf(1,'\nMatching tile index matrix:\n');
		disp(matchingTileIndexMatrix);

		fprintf(1,'\nPoint-to-tile logical matrix:\n');
		disp(pointTileLogicalMatrix);
	end

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