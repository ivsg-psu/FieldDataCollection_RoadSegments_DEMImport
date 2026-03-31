function fcn_DEMImport_ImportZipFromURL(URLtoImport, varargin)
% fcn_DEMImport_ImportZipFromURL  imports PAMAP DEMs from the PASDA
% database
%
% FORMAT:
%
%      fcn_DEMImport_ImportZipFromURL(URLtoImport, (figNum));
%
% INPUTS:
%
%      URLtoImport: a string or character array denoting the URL to import
%
%      (OPTIONAL INPUTS)
%
%      figNum - a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
%
%      (none)
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DEMImport_ImportZipFromURL
%     for a full test suite.
%
% This function was written on 2026_03_31 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_03_31 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_ImportZipFromURL
%   % * Wrote the code originally, using breakDataIntoLaps as starter

% TO-DO:
%
% 2026_03_31 by Sean Brennan, sbrennan@psu.edu
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

PASDA_URL_Prefix = 'https://www.pasda.psu.edu/download/';
rootOfLargeDataPath = 'D:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download';


% Create the URL to the directory
lastIndex = find(URLtoImport=='/',1,"last");
thisURLPrefix = URLtoImport(1:lastIndex);

% Mirror this URL as a directory path locally
folderPathLargeData = fcn_INTERNAL_buildAndCheckFolderPathFromURL(rootOfLargeDataPath, thisURLPrefix, PASDA_URL_Prefix);

% Make sure function worked
if ~exist(folderPathLargeData,'dir')
	error('Path does not exist: %s',pathToFolder);
end

% Define the output file with full path
if URLtoImport(end)=='/'
	fprintf(1,'Made directory for %s \n', URLtoImport);
else
	fileName = URLtoImport(lastIndex+1:end);
	outfile = fullfile(folderPathLargeData,fileName);

	if exist(outfile,'file') 
		fprintf(1,'Already completed for %s \n', fileName);
	else
		% Attempt to save results to a temp zip file
		tempfile = fullfile(pwd,'tempDownloadOfDEM.zip');

		try
			tic
			websave(tempfile, URLtoImport);
			saveTime = toc;
			fprintf(1,'Success for %s (%.2f sec) \n', fileName, saveTime)

			% Move temp file to permanent file
			movefile(tempfile, outfile)

		catch
			fprintf(1,'Fail for %s \n', fileName);
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

% function INTERNAL_plot_circle(center_x, center_y, radius, color, linewidth)
% 
% % Plot the center point
% % plot(center_x,center_y,'ro','Markersize',22);
% 
% % Plot circle
% angles = 0:0.01:2*pi;
% x_circle = center_x + radius * cos(angles);
% y_circle = center_y + radius * sin(angles);
% plot(x_circle,y_circle,'-','color',color,'Linewidth',linewidth);
% end


%%%%%%%%%%%%
function folderPathLargeData = fcn_INTERNAL_buildAndCheckFolderPathFromURL(rootOfPath, thisURLPrefix, PASDA_URL_Prefix)

% Given a URL, creates a folder structure that mirrors the URL

folderStructureString = extractAfter(thisURLPrefix,PASDA_URL_Prefix);
cellArrayOfFolders = strsplit(folderStructureString,'/');

if ~exist(rootOfPath,'dir')
	[status,msg,msgID] = mkdir(rootOfPath);
	if status~=1
		warning('Attempt to make directory:\n\t%s\nfailed. Details are below:\n',rootOfPath);
		fprintf(1,'\tmsg: \t%s\n',msg);
		fprintf(1,'\tmsgID: \t%s\n',msgID);
		error('unable to continue - exiting.');
	end
end

% Build folder sequence up from URL
folderPathLargeData = rootOfPath;
for ith_folder = 1:length(cellArrayOfFolders)
	thisFolder = cellArrayOfFolders{ith_folder};
	if ~isempty(thisFolder)
		folderPathLargeData = fullfile(folderPathLargeData,thisFolder);
		if ~exist(folderPathLargeData,'dir')
			[status,msg,msgID] = mkdir(folderPathLargeData);
			if status~=1
				warning('Attempt to make directory:\n\t%s\nfailed. Details are below:\n',folderPathLargeData);
				fprintf(1,'\tmsg: \t%s\n',msg);
				fprintf(1,'\tmsgID: \t%s\n',msgID);
				error('unable to continue - exiting.');
			end
		end
	end
end
end