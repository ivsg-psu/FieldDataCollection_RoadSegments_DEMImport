function h_geoplot = fcn_DEMImport_plotLatLonLimits(limitsLatLon, varargin)
%fcn_DEMImport_plotLatLonLimits   geoplots Latitude and Longitude data with user-defined formatting strings
%
% FORMAT:
%
%       h_geoplot = fcn_DEMImport_plotLatLonLimits(limitsLatLon, (plotFormat), (figNum))
%
% INPUTS:
%
%      limitsLatLon: an [Nx4] vector data to of LatLon limits in the
%      format: [latmin latmax lonmin lonmax]
%
%      (OPTIONAL INPUTS)
%
%      plotFormat: one of the following:
%      
%          * a format string, e.g. 'b-', that dictates the plot style
%          * a [1x3] color vector specifying the RGB ratios from 0 to 1
%          * a structure whose subfields for the plot properties to change, for example:
%            plotFormat.LineWideth = 3;
%            plotFormat.MarkerSize = 10;
%            plotFormat.Color = [1 0.5 0.5];
%            A full list of properties can be found by examining the plot
%            handle, for example: h_plot = plot(1:10); get(h_plot)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      h_geoplot: the handle to the geoplot result
%
% DEPENDENCIES:
%
%      fcn_plotRoad_plotLL
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_DEMImport_plotLatLonLimits.m 
%
%       for a full test suite.
%
% This function was written on 2026_04_10 by S. Brennan
% Questions or comments? snb10@psu.edu

% REVISION HISTORY:
% 
% 2026_04_10 by S. Brennan
% - In fcn_DEMImport_plotLatLonLimits
%   % * First write of function


% TO-DO:
% 
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 3; % The largest Number of argument inputs to the function
flag_max_speed = 0;
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS");
    MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG = getenv("MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DEMIMPORT_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DEMIMPORT_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_figNum = 999978; %#ok<NASGU>
else
    debug_figNum = []; %#ok<NASGU>
end

%% check input arguments
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

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(1,MAX_NARGIN);
    end
end

% Set plotting defaults
plotFormat = 'k';

% Check to see if user specifies plotFormat?
if 2 <= nargin
    input = varargin{1};
    if ~isempty(input)
        plotFormat = input;       
    end
end


% Default is to make a plot - this starts the plotting process
flag_do_plots = 1;
figNum = []; % Initialize the figure number to be empty
if (0==flag_max_speed) && (3<= nargin)
    temp = varargin{end};
    if ~isempty(temp)
        figNum = temp;
    else % An empty figure number is given by user, so we have to open a new one
        % create new figure with next default index
        figNum = figure;
    end
end

% Is the figure number still empty? If so, then we need to open a new
% figure
if isempty(figNum)
    % create new figure with next default index
    figNum = figure;
end

%% Write main code for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize the output
h_geoplot = 0;

% Reshape matrix so that it makes boxes out of each limit corner
LLplotDataReshaped = [...
	limitsLatLon(:,1) limitsLatLon(:,3), ...
	limitsLatLon(:,2) limitsLatLon(:,3), ...
	limitsLatLon(:,2) limitsLatLon(:,4), ...
	limitsLatLon(:,1) limitsLatLon(:,4), ...
	limitsLatLon(:,1) limitsLatLon(:,3), ...
	nan*limitsLatLon(:,1) nan*limitsLatLon(:,3)]';

temp = reshape(LLplotDataReshaped,[],1);
LLplotData = reshape(temp,2,[])';

% LLplotData = [...
% 	limitsLatLon(1) limitsLatLon(3);
% 	limitsLatLon(2) limitsLatLon(3);
% 	limitsLatLon(2) limitsLatLon(4);
% 	limitsLatLon(1) limitsLatLon(4);
% 	limitsLatLon(1) limitsLatLon(3);
% 	];


%% Any debugging?
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

if flag_do_plots == 1

	fcn_plotRoad_plotLL(LLplotData, (plotFormat), (figNum));

	minLatLon = min(LLplotData,[],1,'omitmissing');
	maxLatLong = max(LLplotData,[],1,'omitmissing');

	geolimits([minLatLon(1) maxLatLong(1)], [minLatLon(2) maxLatLong(2)]);
	currentZoom = get(gca,'ZoomLevel');
	set(gca,'ZoomLevel',currentZoom-2);
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

