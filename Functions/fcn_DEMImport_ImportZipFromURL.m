function saveTime = fcn_DEMImport_importZipFromURL(URLtoImport, varargin)
% fcn_DEMImport_importZipFromURL  imports PAMAP DEMs from the PASDA
% database
%
% FORMAT:
%
%      fcn_DEMImport_importZipFromURL(URLtoImport, (estimatedSeconds), (PASDA_URL_Prefix), (rootOfLargeDataPath), (figNum));
%
% INPUTS:
%
%      URLtoImport: a string or character array denoting the URL to import
%
%      (OPTIONAL INPUTS)
%
%      estimatedSeconds - an estimate of the download time in seconds
% 
%      PASDA_URL_Prefix = 'https://www.pasda.psu.edu/download/';
%
%      rootOfLargeDataPath = 'D:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download';
%
%      figNum - a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
%
%      saveTime: the actual number of seconds the download required
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DEMImport_importZipFromURL
%     for a full test suite.
%
% This function was written on 2026_03_31 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_03_31 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_importZipFromURL
%   % * Wrote the code originally, using breakDataIntoLaps as starter
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_importZipFromURL
%   % * Added estimated completion time as input, actual time as output
%   % * Added error reporting
%
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_importZipFromURL
%   % * Added estimated completion time as input, actual time as output
%   % * Added error reporting

% TO-DO:
%
% 2026_03_31 by Sean Brennan, sbrennan@psu.edu
% - Nothing to add here




%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 5; % The largest Number of argument inputs to the function
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

% Does the user want to specify the estimatedSeconds?
% Set defaults first:
estimatedSeconds = []; % Default case

% Check for user input
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        % Set the estimatedSeconds
        estimatedSeconds = temp;
    end
end

% Does the user want to specify PASDA_URL_Prefix?
PASDA_URL_Prefix = 'https://www.pasda.psu.edu/download/'; % Default value
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        PASDA_URL_Prefix = temp;
    end
end


% Does the user want to specify rootOfLargeDataPath?
rootOfLargeDataPath = 'D:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download';
if 4 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        rootOfLargeDataPath = temp;
    end
end


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
tic

% Create the URL to the directory
lastIndex = find(URLtoImport=='/',1,"last");
thisURLPrefix = URLtoImport(1:lastIndex);

% Mirror this URL as a directory path locally
folderPathLargeData = fcn_INTERNAL_buildAndCheckFolderPathFromURL(rootOfLargeDataPath, thisURLPrefix, PASDA_URL_Prefix);

% Make sure function worked
if ~exist(folderPathLargeData,'dir')
	error('Path does not exist: %s',pathToFolder);
end

% Is an estimate provided?
if ~isempty(estimatedSeconds)
	fprintf(1,'Estimating %.2f sec to complete. ',estimatedSeconds)
end

% Define the output file with full path
if URLtoImport(end)=='/'
	fprintf(1,'Made directory for %s \n', URLtoImport);
	saveTime = toc;
else
	fileName = URLtoImport(lastIndex+1:end);
	outfile = fullfile(folderPathLargeData,fileName);

	if exist(outfile,'file') 
		fprintf(1,'Already completed for %s \n', fileName);
		saveTime = -1;
	else
		% Attempt to save results to a temp zip file
		tempfile = fullfile(pwd,'tempDownloadOfDEM.zip');

		try

			if 1==1
				websave(tempfile, URLtoImport);
			else
				% Does not work
				fcn_INTERNAL_downloadWithProgress(tempfile, URLtoImport);
			end

			saveTime = toc;
			fprintf(1,'Success for %s (%.2f sec) \n', fileName, saveTime)

			% Move temp file to permanent file
			movefile(tempfile, outfile)

		catch ME
			fprintf(1,'Fail for %s. Returned error: %s\n', fileName, ME.message);
			saveTime = toc;
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

% %% fcn_INTERNAL_downloadWithProgress
% function fcn_INTERNAL_downloadWithProgress(outFile, urlStr)
% % Read the remote stream in chunks, get content length from the connection,
% % update a waitbar or dialog.
% url = java.net.URL(urlStr);
% conn = url.openConnection();
% conn.setRequestProperty('User-Agent','MATLAB');
% total = conn.getContentLengthLong();
% in = conn.getInputStream();
% fos = java.io.FileOutputStream(outFile);
% 
% bsize = 8192*2^10;
% buffer = zeros(1,bsize,'uint8');
% nread = 0;
% handle_bar = waitbar(0,'Downloading...');
% try
% 	while true
% 		% read up to bsize bytes
% 		bytesRead = in.read(buffer, 0, bsize);
% 		if bytesRead == -1
% 			break
% 		end
% 		% write to file
% 		fos.write(buffer, 0, bytesRead);
% 		nread = nread + bytesRead;
% 		if total > 0
% 			waitbar(double(nread)/double(total), handle_bar, sprintf('%.1f%%', 100*double(nread)/double(total)));
% 		else
% 			waitbar(0.5, handle_bar, sprintf('Read %d bytes', nread)); % unknown length
% 		end
% 		drawnow
% 	end
% catch ME
% 	close(handle_bar)
% 	in.close(); fos.close();
% 	rethrow(ME)
% end
% close(handle_bar)
% in.close();
% fos.close();
% end % Ends fcn_INTERNAL_downloadWithProgress

%% fcn_INTERNAL_downloadWithProgress
function fcn_INTERNAL_downloadWithProgress(outFile, urlStr)

req = matlab.net.http.RequestMessage('GET');
progressFn = @(bytesRead, totalBytes) fprintf(1, 'Downloaded %d / %d bytes (%.1f%%)\n', ...
	bytesRead, totalBytes, 100*bytesRead/max(1,totalBytes));
options = matlab.net.http.HTTPOptions('ProgressMonitor', progressFn);
resp = req.send(urlStr, options);
% Save body if needed:
if resp.StatusCode == 200
	fid = fopen(outFile,'w');
	fwrite(fid, resp.Body.Data);
	fclose(fid);
end
end


%% fcn_INTERNAL_buildAndCheckFolderPathFromURL
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
end % Ends fcn_INTERNAL_buildAndCheckFolderPathFromURL