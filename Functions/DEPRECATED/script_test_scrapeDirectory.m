saveFileName = fullfile(pwd,'Data','scrapeDirectoryResultPASDA.mat');
if exist(saveFileName,'file')
	load(saveFileName,'scrapeDirectoryResultPASDA');
else
	warning('A complete "fast" scan of the pasda website produces 1384496 entries, scans 6867 folders, and takes at least 30 minutes. A regular scan takes more than 3 hours. Be sure your time and memory capacity are sufficient! Press any key to continue.')
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
				onlyDirectories = newCheckList(newFlagsWasScanned==0,:); %#ok<UNRCH>
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
end


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

%% fcn_INTERNAL_extractSpecificString
function extractedListings = fcn_INTERNAL_extractSpecificString(lidarListings, dataStringToExtract)
indicesToExtract = contains(lidarListings(:,1),dataStringToExtract,'IgnoreCase',true);
extractedListings = lidarListings(indicesToExtract,:);
end % Ends fcn_INTERNAL_extractSpecificString