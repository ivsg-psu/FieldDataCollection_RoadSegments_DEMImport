function localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, varargin)
%% fcn_DEMImport_ensureLocalZipFromPASDAPath 
% 
% Ensures that a PASDA zip file exists locally. If the file is not already
% present under the local root folder, this function reconstructs the PASDA
% download URL from the path entry and downloads the zip file.
%
% FORMAT:
% 
% localZipFile = fcn_DEMImport_ensureLocalZipFromPASDAPath(zipPathEntry, localRootFolder, (figNum))
% 
% INPUTS:
% 
%   zipPathEntry: path entry from zipPaths. This may be:
%                     (a) a PASDA-relative path starting at download\...
%                     (b) a local/full path containing \download\...
%   localRootFolder: local root folder where the 'download' tree should live
%                     Example:
%                     fullfile(pwd,'LargeData')
%
%   (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
% 
% OUTPUT:
% 
%   localZipFile: full local path to the zip file
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script:
%     script_test_fcn_DEMImport_ensureLocalZipFromPASDAPath for a full
%     test suite.
%
% This function was written on 2026_04_09 by Aneesh Batchu
% Questions or comments? abb6486@psu.edu or sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_09 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_ensureLocalZipFromPASDAPath
%   % * Wrote this code originally
%
% 2026_04_15 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromMatchedTiles
%   % * Fixed bug where localRootFolder was not being appended correctly to
%   %   % file path

% TO-DO:
%
% 2026_04_13 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_ensureLocalZipFromPASDAPath
%   (add items here)


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

        % Check zipPathEntry
        if ~(ischar(zipPathEntry) || isstring(zipPathEntry))
            error('zipPathEntry must be a character vector or string.');
        end

        % Check localRootFolder
        if ~(ischar(localRootFolder) || isstring(localRootFolder))
            error('localRootFolder must be a character vector or string.');
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

% Convert input types to char for consistent string processing
zipPathEntry = char(zipPathEntry);
localRootFolder = char(localRootFolder);

% Normalize slashes so path parsing is easier and consistent.
% This converts any forward slashes into Windows-style backslashes.
normalizedPath = strrep(zipPathEntry, '/', '\');

% Extract only the substring beginning at 'download\'
% This is the portion that mirrors the PASDA website path structure.
token = regexp(normalizedPath, 'download\\.*$', 'match', 'once');

if isempty(token)
    error(['Unable to find the ''download\'' portion in zipPathEntry.\n' ...
        'Input path was: \n' '%s'], zipPathEntry);
end

% Keep the PASDA-relative path for URL reconstruction
relativePASDAPath = token;

% Extract only the zip filename for local storage
[zipFilePath, zipFileName, zipExt] = fileparts(relativePASDAPath);
fullPath = fullfile(localRootFolder,zipFilePath);
localZipFile = fullfile(fullPath, [zipFileName zipExt]);

% If the file is already present locally, return immediately
if exist(localZipFile, 'file')
    if flag_do_debug
        fprintf(1,'Local zip already exists. No download needed:\n%s\n', localZipFile);
    end
    return;
end

% Ensure the containing folder exists before downloading
localZipFolder = fileparts(localZipFile);
if ~exist(localZipFolder, 'dir')
    mkdir(localZipFolder);
end

% Convert the relative path into a PASDA-compatible URL path:
%   backslashes -> forward slashes
relativeURLPath = strrep(relativePASDAPath, '\', '/');

% Remove any accidental leading slash
relativeURLPath = regexprep(relativeURLPath, '^/+', '');

% Build the full PASDA URL
fullURL = ['https://www.pasda.psu.edu/' relativeURLPath];

% Download the missing zip file
fprintf(1, 'Downloading missing DEM zip from PASDA:\n%s\n', fullURL);
try
    websave(localZipFile, fullURL);
catch ME
    error(['Failed to download DEM zip from PASDA.\n' ...
        'URL: %s\n' ...
        'Local target: %s\n' ...
        'Reason: %s'], ...
        fullURL, localZipFile, ME.message);
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

    figure(figNum);
    close(figNum);

    fprintf(1,'\nPASDA path resolution summary:\n');
    fprintf(1,'Input zipPathEntry:\n%s\n\n', zipPathEntry);
    fprintf(1,'Relative PASDA/local path:\n%s\n\n', relativePASDAPath);
    fprintf(1,'Resolved local zip file:\n%s\n\n', localZipFile);
    fprintf(1,'Resolved PASDA URL:\n%s\n\n', fullURL);

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