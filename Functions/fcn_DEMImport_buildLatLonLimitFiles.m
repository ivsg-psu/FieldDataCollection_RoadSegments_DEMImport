function [LatLonLimits,zipPaths] = fcn_DEMImport_buildLatLonLimitFiles(rootPathName, varargin)
% fcn_DEMImport_buildLatLonLimitFiles  extracts the latitude and
% longitude limits from the XML file listing of a DEM.
%
% FORMAT:
%
%      fcn_DEMImport_buildLatLonLimitFiles(rootPathName,(flagIgnoreLoadFiles),(figNum));
%
% INPUTS:
%
%      rootPathName - the filename, including path if necessary, of the XML
%      file for a DEM
%
%      (OPTIONAL INPUTS)
%
%      flagIgnoreLoadFiles - if set to true, will ignore previously
%      generated load files. Default is "false"
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
%     See the script: script_test_fcn_DEMImport_buildLatLonLimitFiles
%     for a full test suite.
%
% This function was written on 2026_03_21 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_03_21 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_buildLatLonLimitFiles
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
        narginchk(1,MAX_NARGIN);

        % % Check the input_path to be sure it has 2 or 3 columns, minimum 2 rows
        % % or more
        % fcn_DebugTools_checkInputsToFunctions(input_path, '2or3column_of_numbers',[2 3]);
    end
end


% The following area checks for variable argument inputs (varargin)

% Does the user want to specify the flagIgnoreLoadFiles?
% Set defaults first:
flagIgnoreLoadFiles = false; % Default case

% Check for user input
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
       flagIgnoreLoadFiles = temp;
    end
end
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

if 0==flag_do_plots
    figNum = -1;
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

filesAndFoldersInThisFolder = dir(rootPathName);
fprintf(1,'In folder: %s\n',rootPathName)

rejectNames = {'.','..'};
noContainNames = {'LAS'};

% Check for subdirectories
subfoldersInThisFolder = filesAndFoldersInThisFolder([filesAndFoldersInThisFolder.isdir]);

% Check for previous limits
limitsFileName = fullfile(rootPathName,'latlonLimitsThisBranch.mat');
if exist(limitsFileName,'file') && ~flagIgnoreLoadFiles
    load(limitsFileName,'LatLonLimits','zipPaths');
else
    LatLonLimits = [];
    zipPaths = cell(1,1);
end


for ith_folder = 1:length(subfoldersInThisFolder)
    thisFolderName = subfoldersInThisFolder(ith_folder).name;
	subfolderPath = fullfile(rootPathName,thisFolderName);
    if ~any(strcmp(rejectNames,thisFolderName)) && ~any(contains(subfolderPath,noContainNames),'all')

        [thisLatLonLimit,thisZipPath] = fcn_DEMImport_buildLatLonLimitFiles(subfolderPath, flagIgnoreLoadFiles, figNum);

		[LatLonLimits, zipPaths] = fcn_INTERNAL_conditionallyAdd(LatLonLimits, zipPaths,thisLatLonLimit, thisZipPath);

    end
end

% Filter out directories from the list
fileListFunctionsFolderNoDirectories = filesAndFoldersInThisFolder(~[filesAndFoldersInThisFolder.isdir]);

% Loop through the files in the current folder, checking for XML files. If
% one is found, process it to extract the lat and lon limits, and save the
% results as well as the file path.
for ith_file = 1:length(fileListFunctionsFolderNoDirectories)
    thisFileName = fileListFunctionsFolderNoDirectories(ith_file).name;
    if contains(thisFileName,'.zip')
        fullZipPath = fullfile(rootPathName,thisFileName);
		thisZipPath = extractAfter(fullZipPath,'LargeData');
		fprintf(1,'\t Extracting and analyzing: %s\n',thisZipPath)

		thisLatLonLimit = fcn_DEMImport_extractLimitsFromZipFile(fullZipPath, -1);

        if size(thisLatLonLimit,1)>1
            error('several XML files were found in the same zip file?');
        end
        
        [LatLonLimits, zipPaths] = fcn_INTERNAL_conditionallyAdd(LatLonLimits, zipPaths,thisLatLonLimit, thisZipPath);

    end
end

if ~isempty(LatLonLimits)
    save(limitsFileName,'LatLonLimits','zipPaths');
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
if flag_do_plots && ~isempty(LatLonLimits)
	Nrows = size(LatLonLimits,1);
	NpointsToFill = 6*Nrows;
	LLdataToPlot = nan(NpointsToFill,2);

	for ith_data = 1:Nrows
		thisLatLonLimit = LatLonLimits(ith_data,:);
		LLplotData = [...
			thisLatLonLimit(1) thisLatLonLimit(3);
			thisLatLonLimit(2) thisLatLonLimit(3);
			thisLatLonLimit(2) thisLatLonLimit(4);
			thisLatLonLimit(1) thisLatLonLimit(4);
			thisLatLonLimit(1) thisLatLonLimit(3);
			nan, nan;
			];
		rowsToFillStart = (ith_data-1)*6 + 1;
		rowsToFillEnd = rowsToFillStart+5;
		LLdataToPlot(rowsToFillStart:rowsToFillEnd,:) = LLplotData;
	end

	thisFigureData = get(gcf,'UserData');

	if isempty(thisFigureData)
		clear plotFormat
		plotFormat.Color = 0.25*[1 1 1];
		plotFormat.Marker = '.';
		plotFormat.MarkerSize = 10;
		plotFormat.LineStyle = '-';
		plotFormat.LineWidth = 3;
		h_inactive = fcn_plotRoad_plotLL([nan nan], (plotFormat), (figNum));

		plotFormat.Color = [0 0.7 0];
		plotFormat.Marker = '.';
		plotFormat.MarkerSize = 10;
		plotFormat.LineStyle = '-';
		plotFormat.LineWidth = 3;
		h_active = fcn_plotRoad_plotLL(LLdataToPlot, (plotFormat), (figNum));
		
		userData = struct;
		userData.h_active = h_active;
		userData.h_inactive = h_inactive;
		set(gcf,'UserData',userData);
	else
		userData = get(gcf,'UserData');
		h_active = userData.h_active;
		h_inactive = userData.h_inactive;
		oldXData = get(h_active,'LatitudeData');
		oldYData = get(h_active,'LongitudeData');
		oldInactiveXData = get(h_inactive,'LatitudeData');
		oldInactiveYData = get(h_inactive,'LongitudeData');

		oldXData = fcn_INTERNAL_fixMatrix(oldXData);
		oldYData = fcn_INTERNAL_fixMatrix(oldYData);
		oldInactiveXData = fcn_INTERNAL_fixMatrix(oldInactiveXData);
		oldInactiveYData = fcn_INTERNAL_fixMatrix(oldInactiveYData);

		newInactiveXData = [oldInactiveXData; oldXData];
		newInactiveYData = [oldInactiveYData; oldYData];

		set(h_inactive,'LatitudeData',newInactiveXData,'LongitudeData',newInactiveYData);
		set(h_active,'LatitudeData',LLdataToPlot(:,1),'LongitudeData',LLdataToPlot(:,2));

	end
	pause(0.01);

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


%% fcn_INTERNAL_conditionallyAdd
function [LatLonLimitsOut, zipPathsOut] = fcn_INTERNAL_conditionallyAdd(LatLonLimitsIn, zipPathsIn,thisLatLonLimit, thisZipPath)

% For debugging
if 1==0
	if 1==0
		tempSave = fullfile(pwd,'Data','test_fcn_INTERNAL_conditionallyAdd');
		save(tempSave,'LatLonLimitsIn', 'zipPathsIn','thisLatLonLimit', 'thisZipPath');
	end
	tempSave = fullfile(pwd,'Data','test_fcn_INTERNAL_conditionallyAdd');
	load(tempSave,'LatLonLimitsIn', 'zipPathsIn','thisLatLonLimit', 'thisZipPath');
end

allEmptyZipPathsIn = all(cellfun(@isempty, zipPathsIn));
if (~allEmptyZipPathsIn && ~isempty(thisLatLonLimit)) && size(LatLonLimitsIn,1)~=length(zipPathsIn)
	error('Stophere1');
end

% Make sure that, if one is empty, other is also
if allEmptyZipPathsIn && all(isnan(LatLonLimitsIn),'all')
	LatLonLimitsIn = [];
end

zipPathsOut = zipPathsIn;
LatLonLimitsOut = LatLonLimitsIn;

if ~iscell(thisZipPath)
	thisZipPath = {thisZipPath};
end

allEmptyThisZipPath = all(cellfun(@isempty, thisZipPath));
if allEmptyThisZipPath
	LatLonLimitsOut = nan(1,4);
	return
end

for ith_path = 1:length(thisZipPath)
	ithZipPath = thisZipPath{ith_path};
	ithLatLonLimits = thisLatLonLimit(ith_path,:);
	
	matches = strcmp(zipPathsIn,ithZipPath);
	if any(matches)
		% Replace old data
		LatLonLimitsOut(matches,:) = ithLatLonLimits;
		zipPathsOut{matches,1} = ithZipPath;
	else
		LatLonLimitsOut = [LatLonLimitsOut; ithLatLonLimits]; %#ok<AGROW>
		allEmpty = all(cellfun(@isempty, zipPathsOut));
		if allEmpty
			zipPathsOut{1,1} = ithZipPath;
		else
			zipPathsOut{end+1,1} = ithZipPath; %#ok<AGROW>
		end
	end
end

if size(LatLonLimitsOut,1)~=length(zipPathsOut)
	error('Stophere2');
end

end % Ends fcn_INTERNAL_conditionallyAdd

%% fcn_INTERNAL_fixMatrix
function outMatrix = fcn_INTERNAL_fixMatrix(inMatrix)
% Makes sure output matrix is column matrix, even if input is a row matrix
if size(inMatrix,1)==1 && size(inMatrix,2)>1
	outMatrix = inMatrix';
else
	outMatrix = inMatrix;
end
end % Ends fcn_INTERNAL_fixMatrix