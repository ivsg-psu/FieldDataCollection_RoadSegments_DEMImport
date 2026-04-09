function [overlappingLatLonLimits, overlappingZipPaths, overlapEntriesFlags] = ...
    fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths, varargin)
%% fcn_DEMImport_selectEntriesByBoundingBox
%
% Keeps entries whose tile limits overlap a query latitude/longitude
% bounding box.
% 
% FORMAT:
% 
% [overlappingLatLonLimits, overlappingZipPaths, overlapEntriesFlags] = ...
%       fcn_DEMImport_selectEntriesByBoundingBox(queryBoundingBox, matchingLatLonLimits, matchingZipPaths, (figNum))
% 
% INPUTS:
% 
%   queryBoundingBox: [lat_min lat_max lon_min lon_max] 1 x 4 matrix 
% 
%   matchingLatLonLimits: [lat_min lat_max lon_min lon_max]  N x 4 matrix 
% 
%   matchingZipPaths: N x 1 cell array
%
% OUTPUTS:
% 
%   overlappingLatLonLimits : M x 4 numeric array
% 
%   overlappingZipPaths     : M x 1 cell array
% 
%   overlapRowFlags         : N x 1 logical array
%
%   (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script:
%     script_test_fcn_DEMImport_selectEntriesByBoundingBox for a full
%     test suite.
%
% This function was written on 2026_04_08 by Aneesh Batchu
% Questions or comments? abb6486@psu.edu or sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_08 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_selectEntriesByBoundingBox
%   % * Wrote this code originally

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 4; % The largest Number of argument inputs to the function
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

         % Check queryBoundingBox input
        fcn_DebugTools_checkInputsToFunctions(queryBoundingBox, '4column_of_numbers', [1 1])

        % Check matchingLatLonLimits input
        fcn_DebugTools_checkInputsToFunctions(matchingLatLonLimits, '4column_of_mixed')

        % Input checks
        if size(matchingLatLonLimits,1) ~= numel(matchingZipPaths)
            error('matchingLatLonLimits and matchingZipPaths must have same number of rows.');
        end
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

% Separate the Min and Max Latitudes and Longitudes from the query bounding
% box
queryLatMin = queryBoundingBox(1);
queryLatMax = queryBoundingBox(2);
queryLonMin = queryBoundingBox(3);
queryLonMax = queryBoundingBox(4);

% Select all the Min and Max Latitudes and Longitudes from the
% matchingLatLon tiles
tileLatMin = matchingLatLonLimits(:,1);
tileLatMax = matchingLatLonLimits(:,2);
tileLonMin = matchingLatLonLimits(:,3);
tileLonMax = matchingLatLonLimits(:,4);

% Find the entries that are within the bounding box specified by the user 
overlapEntriesFlags = ...
    (tileLatMax >= queryLatMin) & ...
    (tileLatMin <= queryLatMax) & ...
    (tileLonMax >= queryLonMin) & ...
    (tileLonMin <= queryLonMax);

% Select the entries based on the overlapEntriesFlags
overlappingLatLonLimits = matchingLatLonLimits(overlapEntriesFlags,:);
overlappingZipPaths = matchingZipPaths(overlapEntriesFlags,:);

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

    fprintf(1,'\n\n Here are the DEMs within the query bounding box:\n');
    disp(overlappingZipPaths);

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
