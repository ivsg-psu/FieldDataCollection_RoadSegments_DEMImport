function fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive(scrapeDirectoryResult, dataStringToExtract, varargin)
% fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive  copies subfolders from
% PASDA website to local drive
%
% FORMAT:
%
%      fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive(URLtoImport, (estimatedSeconds), (figNum));
%
% INPUTS:
%
%      scrapeDirectoryResult: the cell array output of the directory scrape
%      operation (see fcn_DEMImport_scrapePASDA)
%
%      dataStringToExtract: the subfolder or identifiers to copy (for
%      example, 'pamap')
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
%      fcn_DEMImport_importZipFromURL
%      
% EXAMPLES:
%
%     See the script: script_test_fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%     for a full test suite.
%
% This function was written on 2026_04_02 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%   % * Wrote the code originally, using script_test_scrapeDirectory as starter
%
% 2026_04_11 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%   % * Moved fcn_INTERNAL_timeStringFromSeconds into DebugTools
%
% 2026_04_17 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%   % * Updated call to fcn_DEMImport_importZipFromURL for new format

% TO-DO:
%
% 2026_04_11 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_bulkCopyPASDAListingsToLocalDrive
%   % * (add items here)




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
% % Does the user want to specify the estimatedSeconds?
% % Set defaults first:
% estimatedSeconds = []; % Default case
% 
% % Check for user input
% if 3 <= nargin
%     temp = varargin{1};
%     if ~isempty(temp)
%         % Set the estimatedSeconds
%         estimatedSeconds = temp;
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

estimatedBytesPerSecond = 3.1563e+07; % Tested on 4/2/2026 on SB's personal computer
overhead = 0.0002; % Seconds
largeFileLimit = 1E10;


%% Create listings
allURLs = scrapeDirectoryResult(:,1);
isemptyFlags = cellfun(@isempty, allURLs);
goodListings = scrapeDirectoryResult(~isemptyFlags,:);

listingsToDownload = fcn_INTERNAL_extractSpecificString(goodListings, dataStringToExtract);
Nlistings = length(listingsToDownload);
bytesVector = cell2mat(listingsToDownload(:,4));
totalGBytes = fcn_DebugTools_number2string(sum(bytesVector)/1E9);
totalTime = sum(bytesVector)/estimatedBytesPerSecond;
fprintf(1,'Total GB of %s data: %s\n',dataStringToExtract, totalGBytes);
totalTimeString = fcn_DebugTools_printTimeStringFromSeconds(totalTime);
fprintf(1,'Estimated copy time, assuming all need to be copied: %s \n',totalTimeString);
fprintf(1,'Total number of listings to transfer: %.0d files and/or folders\n',Nlistings);

flag_keepGoing = 1;
if totalTime>2
	warning('This is a large total time. User must manually uncomment to continue!');
    flag_keepGoing = 0;
end

if 1==flag_keepGoing

    %% Copy remote to local drive

    for ith_listing = 1:Nlistings
    	URLtoImport = listingsToDownload{ith_listing,1};
    	bytesToCopy = listingsToDownload{ith_listing,4};
    	if bytesToCopy>largeFileLimit
    		fprintf(1,'Operation %.0d of %.0d, Size: %.3f MB is too large, skipping %s\n', ith_listing, Nlistings, bytesToCopy/1E6, URLtoImport);
        else
            if 0==bytesToCopy
        		fprintf(1,'Operation %.0d of %.0d, folder or zero-size file creation...',ith_listing, Nlistings);
            else
        		fprintf(1,'Operation %.0d of %.0d, Size: %.3f MB is being copied...',ith_listing, Nlistings, bytesToCopy/1E6);
            end

            % Call the function
    		estimatedSeconds = bytesToCopy/estimatedBytesPerSecond;
            expectedBytes = bytesToCopy;
    		PASDA_URL_Prefix = [];
    		rootOfLargeDataPath = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download';
    		saveTime = fcn_DEMImport_importZipFromURL(URLtoImport, (estimatedSeconds), (expectedBytes), (PASDA_URL_Prefix), (rootOfLargeDataPath), (-1));

    		% If the file is large, update copy estimate
    		if bytesToCopy>1E6 && saveTime>0
    			estimatedBytesPerSecond = (bytesToCopy+overhead)/saveTime;
    		elseif bytesToCopy==0
    			overhead = saveTime;
    		end

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

%% fcn_INTERNAL_extractSpecificString
function extractedListings = fcn_INTERNAL_extractSpecificString(lidarListings, dataStringToExtract)
indicesToExtract = contains(lidarListings(:,1),dataStringToExtract,'IgnoreCase',true);
extractedListings = lidarListings(indicesToExtract,:);
end % Ends fcn_INTERNAL_extractSpecificString

