function [matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ... 
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, varargin)
%% fcn_DEMImport_selectEntriesByZipPathStrings
%
% Selects rows whose zip path contains ALL required string fragments and
% outputs the matchingLatLonLimits and matchingZipPaths. This function does
% name/path-based selection only.
%
% FORMAT:
% 
% [matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, (figNum))
% 
% INPUTS:
% 
%   requiredStrings: cell array or string array, e.g. {'DEM','North'}
% 
%   LatLonLimits: N x 4 matrix [lat_min lat_max lon_min lon_max]
% 
%   zipPaths: N x 1 cell array of zip path strings
%
% OUTPUTS:
% 
%   matchingLatLonLimits: M x 4 matrix
% 
%   matchingZipPaths: M x 1 cell array
% 
%   matchingRowFlags: N x 1 logical matrix
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
%     script_test_fcn_DEMImport_selectEntriesByZipPathStrings for a full
%     test suite.
%
% This function was written on 2026_04_08 by Aneesh Batchu
% Questions or comments? abb6486@psu.edu or sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_08 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_selectEntriesByZipPathStrings
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

        % Check LatLonLimits input
        fcn_DebugTools_checkInputsToFunctions(LatLonLimits, '4column_of_mixed')

        % Input checks
        if ~(iscell(requiredStrings) || isstring(requiredStrings))
            error('requiredStrings must be a cell array or string array.');
        end

        if size(LatLonLimits,1) ~= numel(zipPaths)
            error('LatLonLimits and zipPaths must have the same number of rows.');
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

% Convert inputs to string arrays
requiredStrings = string(requiredStrings);
zipPaths = string(zipPaths(:));  % force column

% Match rows that contain ALL required strings
matchingEntriesFlags = true(size(zipPaths));

for ith_string = 1:numel(requiredStrings)
    matchingEntriesFlags = matchingEntriesFlags & ...
        contains(zipPaths, requiredStrings(ith_string), 'IgnoreCase', true);
end

% Apply row selection
matchingLatLonLimits = LatLonLimits(matchingEntriesFlags,:);
matchingZipPaths = zipPaths(matchingEntriesFlags);

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

    fprintf(1,'\n\n Here are the DEMs that contain the above query location:\n');
    disp(matchingZipPaths);

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
