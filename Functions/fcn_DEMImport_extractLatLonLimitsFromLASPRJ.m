function LatLonLimits = fcn_DEMImport_extractLatLonLimitsFromLASPRJ(lasFilepath, prjFilepath, varargin)
% fcn_DEMImport_extractLatLonLimitsFromLASPRJ  extracts the latitude and
% longitude limits from the LAS / PRJ file listings of a DEM.
%
% FORMAT:
%
%      LatLonLimits = fcn_DEMImport_extractLatLonLimitsFromLASPRJ(lasFilepath, prjFilepath,(figNum));
%
% INPUTS:
%
%      lasFilepath - the filename, including path if necessary, of the PRJ
%      file for a DEM
%
%      prjFilepath - the filename, including path if necessary, of the PRJ
%      file for a DEM
%
%      (OPTIONAL INPUTS)
%
%      figNum - a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
%
%      LatLonLimits - the latitude and longitude limits of the DEM as given
%      by [lat_low lat_high lon_low lon_high]
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DEMImport_extractLatLonLimitsFromLASPRJ
%     for a full test suite.
%
% This function was written on 2026_03_21 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_03_21 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_extractLatLonLimitsFromLASPRJ
%   % * Wrote the code originally, using breakDataIntoLaps as starter

% TO-DO:
%
% 2026_03_21 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)



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

% flag_do_debug = 1;

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

        % % Check the input_path to be sure it has 2 or 3 columns, minimum 2 rows
        % % or more
        % fcn_DebugTools_checkInputsToFunctions(input_path, '2or3column_of_numbers',[2 3]);
    end
end


% % The following area checks for variable argument inputs (varargin)
% 
% % Does the user want to specify the end_definition?
% % Set defaults first:
% end_zone_definition = start_zone_definition; % Default case
% flag_end_is_a_point_type = flag_start_is_a_point_type; % Inheret the start case
% % Check for user input
% if 3 <= nargin
%     temp = varargin{1};
%     if ~isempty(temp)
%         % Set the end values
%         [flag_end_is_a_point_type, end_zone_definition] = fcn_Laps_checkZoneType(temp, 'end_definition', -1);
%     end
% end
% 
% % Does the user want to specify excursion_definition?
% flag_use_excursion_definition = 0; % Default case
% flag_excursion_is_a_point_type = 1; % Default case
% if 4 <= nargin
%     temp = varargin{2};
%     if ~isempty(temp)
%         % Set the excursion values
%         [flag_excursion_is_a_point_type, excursion_definition] = fcn_Laps_checkZoneType(temp, 'excursion_definition',-1);
%         flag_use_excursion_definition = 1;
%     end
% end

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

% read WKT text
wkt = strtrim(fileread(prjFilepath));

% try to create a projcrs or geocrs from the WKT (Mapping Toolbox)
try
    % First try creating a projected CRS (projcrs accepts WKT)
    crs = projcrs(wkt);
catch
    try
        % If that fails, try geographic CRS
        crs = geocrs(wkt);
    catch
        error("Could not interpret WKT from %s as a projcrs or geocrs.", prjFilepath);
    end
end


lasReader = lasFileReader(lasFilepath);

[ptCloud, ~] = readPointCloud(lasReader, "Attributes", "Classification");
XYdata = ptCloud.Location;
x = XYdata(:,1);
y = XYdata(:,2);


% Example: convert sample X,Y from LAS files to lat/lon
% x,y are vectors read from LAS (e.g., via lasFileReader + readPointCloud)
if isa(crs,"geographicCRS")
    lon = x;
    lat = y;
else
    % projcrs -> use projinv to get lat,lon
    [lat, lon] = projinv(crs, x, y);
end

% get bounds
minLon = min(lon); 
maxLon = max(lon);
minLat = min(lat); 
maxLat = max(lat);

% Determine geographic limits 
latlim = [minLat maxLat];
lonlim = [minLon maxLon];


LatLonLimits = [latlim lonlim];

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
    LLplotData = [...
        LatLonLimits(1) LatLonLimits(3);
        LatLonLimits(2) LatLonLimits(3);
        LatLonLimits(2) LatLonLimits(4);
        LatLonLimits(1) LatLonLimits(4);
        LatLonLimits(1) LatLonLimits(3);
        ];
    clear plotFormat
    plotFormat.Color = [0 0.7 0];
    plotFormat.Marker = '.';
    plotFormat.MarkerSize = 10;
    plotFormat.LineStyle = '-';
    plotFormat.LineWidth = 3;
    fcn_plotRoad_plotLL(LLplotData, (plotFormat), (figNum));
	geolimits(latlim, lonlim);
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

