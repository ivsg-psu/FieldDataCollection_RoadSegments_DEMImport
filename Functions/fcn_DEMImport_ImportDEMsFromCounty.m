function fcn_DEMImport_ImportDEMsFromCounty(varargin)
% fcn_DEMImport_ImportDEMsFromCounty  imports PAMAP DEMs from the PASDA
% database
%
% FORMAT:
%
%      fcn_DEMImport_ImportDEMsFromCounty((figNum));
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
%      (none)
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DEMImport_ImportDEMsFromCounty
%     for a full test suite.
%
% This function was written on 2026_03_13 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_03_13 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_ImportDEMsFromCounty
%   % * Wrote the code originally, using breakDataIntoLaps as starter
%
% 2026_03_25 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_ImportDEMsFromCounty
%   % * Changed root definition to start at "download" to match, exactly,
%   %   % pasda website


% TO-DO:
%
% 2026_03_13 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)



%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 1; % The largest Number of argument inputs to the function
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
        narginchk(0,MAX_NARGIN);

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
%%%%%%%%%%%%%
% PAMAP

% PAMAP North 2006 - 2008
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/60000000/66001210PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/CONT/North/2007/60000000/66001210PAN_cont.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/BL/North/2007/60000000/66001210PAN_bl.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/LAS/North/2007/60000000/66001210PAN.zip
% SouthToNorth = 1600:100:7800
% WestToEast = 1200:10:2810

% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/70000000/78001420PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/60000000/65002020PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/50000000/52002070PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/40000000/40001420PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/30000000/30001900PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/21001870PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2008/20000000/23002290PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2008/30000000/39002700PAN_dem.zip

% PAMAP South 2006 - 2008
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/South/2006/60000000/64001200PAS_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/CONT/South/2006/60000000/64001200PAS_cont.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/BL/South/2006/60000000/64001200PAS_bl.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/LAS/South/2006/60000000/64001200PAS.zip
% SouthToNorth = 1400:100:6900
% WestToEast = 1180:10:2810


prefixes = {'DEM','CONT','BL','LAS'};
suffixes = {'_dem','_cont','_bl',''};
NorthSouthDataset = {'North', 'South'};
yearsToCheck = {'2006','2007','2008'};
PASDA_URL_Prefix = 'https://www.pasda.psu.edu/download/';

% rootOfLargeDataPath = fullfile(pwd,'LargeData','download');
% rootOfLargeDataPath = fullfile(pwd,'LargeData','download');
rootOfLargeDataPath = 'D:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download';

for jth_direction = 2:2 %2
	thisDirection = NorthSouthDataset{jth_direction};

	for kth_year = 1:length(yearsToCheck)
		thisYear = yearsToCheck{kth_year};

		for SouthToNorth = 1400:100:7800
			SouthToNorthText = sprintf('%.0f',floor(SouthToNorth/1000));
			for WestToEast = 1180:10:2810

				% thisfileRoot = '25001890PAN';
				% thisfileRoot = sprintf('%.0f%.0fPAN',SouthToNorth,WestToEast);
				thisfileRoot = sprintf('%.0f%.0fPA%s',SouthToNorth,WestToEast,thisDirection(1));

				fprintf(1,'Year: %s - Attempting capture for: %s\t',thisYear, thisfileRoot);

				flag_keepGoing = true;
				for ith_prefixAndSuffix = 1:length(prefixes)
					if flag_keepGoing
						thisPrefix = prefixes{ith_prefixAndSuffix};
						thisSuffix = suffixes{ith_prefixAndSuffix};

						% Define the file name
						fileName = sprintf('%s%s.zip',thisfileRoot,thisSuffix);

						% Create the URL to the PASDA zip file
						thisURLPrefix = sprintf('%spamap/pamap_lidar/cycle1/%s/%s/%s/%s0000000/',...
							PASDA_URL_Prefix,thisPrefix, thisDirection,thisYear, SouthToNorthText);
						thisURL = sprintf('%s%s',thisURLPrefix, fileName);

						% Mirror this URL as a directory path locally
						folderPathLargeData = fcn_INTERNAL_buildAndCheckFolderPathFromURL(rootOfLargeDataPath, thisURLPrefix, PASDA_URL_Prefix);

						% Make sure function worked
						if ~exist(folderPathLargeData,'dir')
							error('Path does not exist: %s',pathToFolder);
						end

						% Define the output file with full path
						outfile = fullfile(folderPathLargeData,fileName);

						if exist(outfile,'file') && ith_prefixAndSuffix==1
							fprintf(1,'Already completed for %s \t', thisPrefix);
							flag_keepGoing = false;
						else
							% Attempt to save results to a temp zip file
							tempfile = fullfile(pwd,'tempDownloadOfDEM.zip');

							try
								tic
								websave(tempfile, thisURL);
								saveTime = toc;
								fprintf(1,'Success for %s (%.2f sec) \t', thisPrefix, saveTime)
								
								% Move temp file to permanent file
								movefile(tempfile, outfile)

							catch
								fprintf(1,'Fail for %s \t', thisPrefix);
								
								if ith_prefixAndSuffix~=1
									error('Encountered a save error after a DEM was saved but other fields not saved. This usually indicates a fundamental failure such as full disk, loss of connectivity, etc. Stopping!');
								else
									% Touch the file to indicate it was checked
									fcn_DebugTools_fileTouch(outfile,-1);
									flag_keepGoing = false;
								end
							end

						end
					end
				end % Ends loop through prefix/suffix
				fprintf(1,'\n');

			end % Ends loop through west to east
		end % Ends loop through south to north
	end % Ends loop through years
end % Ends loop through directions

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