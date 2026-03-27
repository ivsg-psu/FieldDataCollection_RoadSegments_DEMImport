function LatLonLimits = fcn_DEMImport_extractLimitsFromZipFile(zipFile, varargin)
% fcn_DEMImport_extractLimitsFromZipFile  extracts the given zip file to a
% temporary folder, searches for XML files, uses the XML file to find
% LatLonLimits, and removes the temporary folder when done
%
% FORMAT:
%
%      LatLonLimits = fcn_DEMImport_extractLimitsFromZipFile(zipFile, (figNum));
%
% INPUTS:
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
%     See the script: script_test_fcn_DEMImport_extractLimitsFromZipFile
%     for a full test suite.
%
% This function was written on 2026_03_26 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_03_26 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_extractLimitsFromZipFile
%   % * Wrote the code originally


% TO-DO:
%
% 2026_03_26 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)



%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 2; % The largest Number of argument inputs to the function
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
		narginchk(1,MAX_NARGIN);

		% Input validation
		if ~ischar(zipFile) && ~isstring(zipFile)
			error('zipFile must be a character vector or string scalar.');
		end
		zipFile = char(zipFile);
		if ~isfile(zipFile)
			error('Zip file does not exist: %s', zipFile);
		end

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
        figNum = temp; %#ok<NASGU>
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
% Create a unique temporary folder
tmpFolder = fullfile(pwd,'TempExtract');
if exist(tmpFolder,'dir')
	rmdir(tmpFolder, 's');
end

% tmpFolder = fullfile(tmpBase, ['ziptmp_' char(java.util.UUID.randomUUID)]);
mkdir(tmpFolder);

% For debugging
% zipFile = 'C:\Users\snb10\Desktop\GitHubRepos\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\DEMsForPA\pamap\pamap_lidar\cycle1\DEM\North\2006\30000000\30001180PAN_dem.zip';

% Unzip into temporary folder
s = dir(zipFile);
filesize_bytes = s.bytes;

if filesize_bytes==0
	LatLonLimits = nan(1,4);
	return;
else
	try
		unzip(zipFile, tmpFolder);
	catch
		warning('Invalid zip file found (skipping): %s\n',zipFile);
		LatLonLimits = nan(1,4);
		return;
	end
end

% Find XML files recursively (works in modern MATLAB)
xmlfiles = dir(fullfile(tmpFolder, '**', '*.xml'));

if ~isempty(xmlfiles)

	% Build full or relative names: choose full paths
	numFiles = 0;
	names = cell(1,1);
	for k = 1:numel(xmlfiles)
		if ~contains(xmlfiles(k).name,'aux')
			numFiles = numFiles+1;
			names{numFiles} = fullfile(xmlfiles(k).folder, xmlfiles(k).name);
		end
	end

	if length(names)>1 || 0==numFiles
		error('More than 1 XML descriptor file was found in a DEM description, or 0 files, in file: \n %s \nExiting.',zipFile);
	end
	% Convert to character array (each name as a row, padded with spaces)
	xmlNames = char(names);

	% LatLonLimits = fcn_DEMImport_extractLatLonLimitsFromXML(xmlNames,(figNum*10));
	LatLonLimits = fcn_DEMImport_extractLatLonLimitsFromXML(xmlNames,-1);

else
	% Find PRJ files 
	prjfiles = dir(fullfile(tmpFolder, '**', '*.prj'));

	if ~isempty(prjfiles)

		% Build full or relative names: choose full paths
		numFiles = 0;
		names = cell(1,1);
		for k = 1:numel(prjfiles)
			if ~contains(prjfiles(k).name,'aux')
				numFiles = numFiles+1;
				names{numFiles} = fullfile(prjfiles(k).folder, prjfiles(k).name);
			end
		end

		if length(names)>1 || 0==numFiles
			error('More than 1 PRJ descriptor file was found in a DEM description, or 0 files, in file: \n %s \nExiting.',zipFile);
		end
		% Convert to character array (each name as a row, padded with spaces)
		prjFilepath = char(names);
		prefix = extractBefore(prjFilepath,'.prj');
		lasFilepath = cat(2,prefix,'.las');

		LatLonLimits = fcn_DEMImport_extractLatLonLimitsFromLASPRJ(lasFilepath, prjFilepath,-1);
	else
		error('No XML file file found in the DEM file: \n %s \n. Exiting',zipFile);
	end
end
% Ensure cleanup on function exit
rmdir(tmpFolder, 's');

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
	geolimits(LatLonLimits(1,1:2), LatLonLimits(1,3:4));
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


