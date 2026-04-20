function scrapeDirectoryResultPASDA = fcn_DEMImport_scrapePASDA(varargin)
% fcn_DEMImport_scrapePASDA  copies subfolders from
% PASDA website to local drive. Saves results into: 'Data' subfolder, in
% file: 'scrapeDirectoryResultPASDA.mat' 
%
% FORMAT:
%
%      scrapeDirectoryResultPASDA = fcn_DEMImport_scrapePASDA((figNum));
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
%      scrapeDirectoryResult: a cell array output of the directory scrape
%      operation. The cell array has N rows, each row being a URL that was
%      found in the directory scrape. The columns are:
%
%      Column 1: thisURL (string), 
%
%      Column 2: sourceFolderURL (string), 
%
%      Column 3: datetime (string),
%
%      Column 4: bytes (numeric), 
%
%      Column 5: flagWasScanned (numeric) - and internal placeholder to
%      determine if the subfolder or file was already scanned
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DEMImport_scrapePASDA
%     for a full test suite.
%
% This function was written on 2026_04_02 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_scrapePASDA
%   % * Wrote the code originally, using script_test_scrapeDirectory as starter


% TO-DO:
%
% 2026_04_02 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_scrapePASDA
%   % * Move fcn_INTERNAL_timeStringFromSeconds into DebugTools




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
warning('A complete "fast" scan of the pasda website produces 1384496 entries, scans 6867 folders, and takes AT LEAST 30 minutes. Press any key to continue.')
pause;


% Set this to true to do a "fast" scan, e.g. only 30 minutes, and NOT save
% any data.
flagDoScanOnly = false;

fprintf(1, 'Starting the scan process...\n');

rootHyperlink = 'https://www.pasda.psu.edu/download/';
% rootHyperlink = 'https://www.pasda.psu.edu/download/adamscounty/';

flagKeepGoing = true;

% thisURL, sourceFolderURL, date, time, bytes, flagWasScanned
maxPossibleEntries = 1500000;
scrapeDirectoryResultPASDA = cell(maxPossibleEntries,5);
scrapeDirectoryResultPASDA{1,1} = rootHyperlink;
scrapeDirectoryResultPASDA{1,2} = rootHyperlink;
scrapeDirectoryResultPASDA{1,3} = "2026";
scrapeDirectoryResultPASDA{1,4} = 0;
scrapeDirectoryResultPASDA{1,5} = 0;

tic
totalBytes = 0;
NfilesAndDirectories = 1;
Ndirectories = 1;
while flagKeepGoing
	flagsWasScanned = cell2mat(scrapeDirectoryResultPASDA(:,end));
	indexToScanNext = find(flagsWasScanned==0,1,'last');
	if isempty(indexToScanNext)
		flagKeepGoing = false; % No more URLs to scan, exit the loop
	else
		thisURL = scrapeDirectoryResultPASDA{indexToScanNext,1}; % Get the URL
		fprintf(1,'Scanning %s,',thisURL);
		thisExtension = extractAfter(thisURL,'/download/');
		[stringArrayOfFullURLs, arrayOfBytes, stringArrayOfdateAndTimeString] = getRowsOfInfoFromURL(thisURL,cat(2,'/download/',thisExtension));
		Nlinks = size(stringArrayOfFullURLs,1);

		% Shut off this URL - no need to scan again
		scrapeDirectoryResultPASDA{indexToScanNext,end} = 1;

		% update flags for new URLs
		newFlagsWasScanned = true(Nlinks,1);
		newFlagsWasScanned(arrayOfBytes==0) = 0;

		% Set any URL that does not end in "/" as NOT a URL to scan
		lastCharacters = extractAfter(stringArrayOfFullURLs, strlength(stringArrayOfFullURLs)-1);
		newFlagsWasScanned(lastCharacters~='/') = 1;


		% Build new checklist
		cellArrayOfFullURLs = cellstr(stringArrayOfFullURLs);
		cellArrayOfSourceFolderURLs = cellstr(repmat(string(thisURL),Nlinks,1));
		cellArrayOfDateAndTime = cellstr(stringArrayOfdateAndTimeString);
		cellArrayOfBytes    = num2cell(arrayOfBytes,2);
		cellArrayOfFlagWasScanned   = num2cell(newFlagsWasScanned,2);

		newCheckList = [cellArrayOfFullURLs, cellArrayOfSourceFolderURLs,cellArrayOfDateAndTime, cellArrayOfBytes, cellArrayOfFlagWasScanned];

		NthisScan = size(newCheckList,1);

		thisBytes = sum(cell2mat(cellArrayOfBytes));
		thisGBytes = fcn_DebugTools_number2string(thisBytes/1E9);
		fprintf(1,' .. GB in this folder: %s ',thisGBytes);


		% Update the old checklist with only new URLs?
		if flagDoScanOnly
			onlyDirectories = newCheckList(newFlagsWasScanned==0,:); 
			Ndirectories = Ndirectories + size(onlyDirectories,1);
			scrapeDirectoryResultPASDA = [scrapeDirectoryResultPASDA; onlyDirectories];
		else
			startIndex = NfilesAndDirectories + 1;
			endIndex = NfilesAndDirectories + NthisScan;
			scrapeDirectoryResultPASDA(startIndex:endIndex,:) = newCheckList;
		end
		NfilesAndDirectories = NfilesAndDirectories + NthisScan;
	end
	totalBytes = totalBytes + thisBytes;
	totalGBytes = fcn_DebugTools_number2string(totalBytes/1E9);
	fprintf(1,' .. GB so far: %s\n',totalGBytes);
end
elapsedTime = toc;
fprintf(1,'Total GB: %s\n',totalGBytes);
fprintf(1,'Total directories: %d\n',Ndirectories);
fprintf(1,'Total files and directories: %d\n',NfilesAndDirectories);
fprintf(1,'Elapsed scan time: %.2f seconds\n\n',elapsedTime);

saveFileName = fullfile(pwd,'Data','scrapeDirectoryResultPASDA.mat');
save(saveFileName,'scrapeDirectoryResultPASDA');

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

%% getRowsOfInfoFromURL
function [stringArrayOfFullURLs, arrayOfBytes, stringArrayOfdateAndTimeString] = getRowsOfInfoFromURL(url, prefix)



flagBadHit = false;
try
	% Read the content of the URL
	options = weboptions("ContentType","text");
	htmlText = webread(url, options);        % returns a character vector	
	if isempty(htmlText)
		warning('Empty HTML found?');
		flagBadHit = true;
	end
catch ME
	warning('Unable to read URL: %s. Error: %s', url, ME.message);
	flagBadHit = true;
end

if flagBadHit
	stringArrayOfFullURLs = "(empty)";
	arrayOfBytes = 0;
	stringArrayOfdateAndTimeString = strings(1,1);
	return
end

% lines = split(string(htmlText),'<br>');
lines = fcn_INTERNAL_goodSplit(string(htmlText), '<br>', false);


nonEmptyLines = lines(lines~="");

% Remove front and rear extra spaces
cleanLines = strip(nonEmptyLines);

% Pull out first characters
firstChars = extractBetween(cleanLines, 1, 1);

% Keep only the rows that are listings. These always start with
% numbers. Numbers are listed as digits (^\d)
isGoodLine = matches(firstChars, digitsPattern(1));

% Lines to analyze
linesToAnalyze = cleanLines(isGoodLine);
Nlines = size(linesToAnalyze,1);
intermediateContainer = strings(Nlines,2);
flagRowWasChecked = false(Nlines,1);

indicesWithAM = contains(linesToAnalyze,' AM ');
% intermediateContainer(indicesWithAM,:) = split(linesToAnalyze(indicesWithAM),' AM ');
intermediateContainer(indicesWithAM,:) = fcn_INTERNAL_goodSplit(linesToAnalyze(indicesWithAM), ' AM ', true);
stringArray = repmat(' AM ',sum(indicesWithAM),1);
intermediateContainer(indicesWithAM,1) = strcat(intermediateContainer(indicesWithAM,1), stringArray);
flagRowWasChecked(indicesWithAM,1) = true;

indicesWithPM = contains(linesToAnalyze,' PM ');
% intermediateContainer(indicesWithPM,:) = split(linesToAnalyze(indicesWithPM),' PM ');
intermediateContainer(indicesWithPM,:) = fcn_INTERNAL_goodSplit(linesToAnalyze(indicesWithPM), ' PM ', true);
stringArray = repmat(' PM ',sum(indicesWithPM),1);
intermediateContainer(indicesWithPM,1) = strcat(intermediateContainer(indicesWithPM,1), stringArray);
flagRowWasChecked(indicesWithPM,1) = true;

if ~any(flagRowWasChecked)
	disp(cleanLines);
	warning('Encountered a situation where neither AM or PM split string was found?!');

	stringArrayOfFullURLs = "(empty)";
	arrayOfBytes = 0;
	stringArrayOfdateAndTimeString = strings(1,1);
	return
end

% Extract out the date and time string. This is followed by lots of spaces
stringArrayOfdateAndTimeString = intermediateContainer(:,1);
% cellArrayOfDateAndTime = cellstr(stringArrayOfdateAndTimeString);

remainderString = strip(intermediateContainer(:,2));

% Now pull out the part before the HTML link and part after. The part
% before is the number of bytes. In the case of "dir" characters, these
% have no size and will show up as NaN values. So we have to search and
% replace NaN values and fill them with 0.
% temp2 = split(remainderString,'<A HREF="');
temp2 = fcn_INTERNAL_goodSplit(remainderString, '<A HREF="', true);


cleanLines = strip(temp2);
arrayOfBytes = str2double(cleanLines(:,1));
arrayOfBytes(isnan(arrayOfBytes)) = 0;

remainderString = temp2(:,2);

% temp3 = split(remainderString,'">');
temp3 = fcn_INTERNAL_goodSplit(remainderString, '">', true);
urlListStringFullSuffixes = temp3(:,1);

% urlListStringSuffixes = split(urlListStringFullSuffixes,prefix);
urlListStringSuffixes = fcn_INTERNAL_goodSplit(urlListStringFullSuffixes, prefix, true);

Nlinks = size(urlListStringSuffixes,1);
prefixes = repmat(string(url),Nlinks,1);
fullURLarray = cat(2,prefixes,urlListStringSuffixes(:,2));
stringArrayOfFullURLs = join(fullURLarray, "", 2);
end

%% fcn_INTERNAL_goodSplit
function splitResult = fcn_INTERNAL_goodSplit(inputString, stringForSplitting, flagForceRows)
splitResult = split(inputString,stringForSplitting);

% If the input string has only one row, split will (incorrectly) produce 2
% columns. So we need to rotate this.
if isequal(size(inputString),[1 1]) && flagForceRows
	 splitResult = splitResult';
end
end % Ends fcn_INTERNAL_goodSplit

