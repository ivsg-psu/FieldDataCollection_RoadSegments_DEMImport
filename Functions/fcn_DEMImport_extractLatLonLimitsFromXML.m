function [limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName, varargin)
% fcn_DEMImport_extractLatLonLimitsFromXML  extracts the latitude and
% longitude limits from the XML file listing of a DEM.
%
% FORMAT:
%
%      [limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(figNum));
%
% INPUTS:
%
%      XMLfileName - the filename, including path if necessary, of the XML
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
%      limitsLatLon - the latitude and longitude limits of the DEM as given
%      by [lat_low lat_high lon_low lon_high]
%
%      limitsFt - the ft limits of the DEM as given
%      by [ west_ft east_ft south_ft north_ft]
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DEMImport_extractLatLonLimitsFromXML
%     for a full test suite.
%
% This function was written on 2026_03_21 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_03_21 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_extractLatLonLimitsFromXML
%   % * Wrote the code originally, using breakDataIntoLaps as starter
%
% 2026_04_03 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_extractLatLonLimitsFromXML
%   % * Added limitsFt output

% TO-DO:
%
% 2026_03_21 by Sean Brennan, sbrennan@psu.edu
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

% See ???
startOfLLASegmentStrings{1} = '<geoBox esriExtentType="decdegrees">';
endOfLLASegmentStrings{1} = '</geoBox';
LLAmodifierStrings{1} = 'BL';
startOfFtSegmentStrings{1} = '<nativeExtBox>';
endOfFtSegmentStrings{1} = '</nativeExtBox';
FtmodifierStrings{1} = 'BL';
westOrLeftFlag{1} = 0;

% See 20001890PAN_bl.shp.xml
startOfLLASegmentStrings{2} = '<bounding';
endOfLLASegmentStrings{2} = '</bounding';
LLAmodifierStrings{2} = 'bc';
startOfFtSegmentStrings{2} = '<lboundng>';
endOfFtSegmentStrings{2} = '</lboundng';
FtmodifierStrings{2} = 'bc';
westOrLeftFlag{2} = 1;

% See PAMAP_DEM_mosaic_Adams_1m.tif.xml
startOfLLASegmentStrings{3} = '<GeoBndBox';
endOfLLASegmentStrings{3} = '</GeoBndBox';
LLAmodifierStrings{3} = 'BL';
startOfFtSegmentStrings{3} = '<nativeExtBox>';
endOfFtSegmentStrings{3} = '</nativeExtBox';
FtmodifierStrings{3} = 'BL';
westOrLeftFlag{3} = 0;

% See 24002070PAN_bl.shp.xml
startOfLLASegmentStrings{4} = '<geoBox';
endOfLLASegmentStrings{4} = '</geoBox';
LLAmodifierStrings{4} = 'BL';
startOfFtSegmentStrings{4} = '<GeoBndBox';
endOfFtSegmentStrings{4} = '</GeoBndBox';
FtmodifierStrings{4} = 'BL';
westOrLeftFlag{4} = 0;

Nmethods = length(startOfLLASegmentStrings);

%%

Nfiles = size(XMLfileName,1);

flagWasFound = false;
for ith_file = 1:Nfiles

	thisXMLfileName = strip(XMLfileName(ith_file,:));

	if ~exist(thisXMLfileName,'file')
		warning('backtrace','on');
		warning('Unable to find XML file: %s\n Skipping\n',thisXMLfileName);
	else

		% Make sure the input file has line feeds (standard XML files are sometimes
		% just one big string!)
		info = fcn_INTERNAL_detectCRType(thisXMLfileName);

		if info.nLF==0
			tempName = fullfile(pwd,'tempXML.xml');
			fcn_INTERNAL_xmlPrettify(thisXMLfileName, tempName);
		else
			tempName = thisXMLfileName;
		end
		stringArrayOfDEMXMLfile = readlines(tempName);
		allFlags = false(Nmethods,1);
		allLimitsLatLon = nan(Nmethods,4);
		allLimitsFt = nan(Nmethods,4);

		for ith_method = 1:Nmethods
			if ~flagWasFound
				thisLLAStartOfSegmentString = startOfLLASegmentStrings{ith_method};
				thisLLAEndOfSegmentString = endOfLLASegmentStrings{ith_method};
				thisLLAModifierString = LLAmodifierStrings{ith_method};
				thisFtStartOfSegmentString = startOfFtSegmentStrings{ith_method};
				thisFtEndOfSegmentString = endOfFtSegmentStrings{ith_method};
				thisFtModifierString = FtmodifierStrings{ith_method};
				thisFlagUseWestOrLeft = westOrLeftFlag{ith_method};

				[flagWasFound, limitsLatLon, limitsFt] = fcn_INTERNAL_extractByStyle(...
					stringArrayOfDEMXMLfile, ...
					thisLLAStartOfSegmentString, thisLLAEndOfSegmentString, thisLLAModifierString, ...
					thisFtStartOfSegmentString, thisFtEndOfSegmentString, thisFtModifierString, ...
					thisFlagUseWestOrLeft);
				allFlags(ith_method,1) = flagWasFound;
				allLimitsLatLon(ith_method,:) = limitsLatLon;
				allLimitsFt(ith_method,:) = limitsFt;

			end
		end
	end

	% Extract the FT data from the file name
	if ~flagWasFound
		% Is there a row of data in lat long that is not NaN
		goodLatLonRows = ~all(isnan(allLimitsLatLon),2);
		if any(goodLatLonRows)
			possibleLatLonData = allLimitsLatLon(goodLatLonRows,:);


			% Is the data in range of -180 to 180?
			inRangeFlags = possibleLatLonData>=-180 & possibleLatLonData<=180;
			goodInRangeData = all(inRangeFlags,2);
			inRangeLatLonData = possibleLatLonData(goodInRangeData,:);
			if ~isempty(inRangeLatLonData)
				limitsLatLon = inRangeLatLonData(1,:);
				flagWasFound = 0.5;
			end

		end

		% [firstDigits, secondDigits] = fcn_INTERNAL_extractFtDigitsFromFilename(thisXMLfileName); %#ok<ASGLU>

	end


	if ~flagWasFound && Nfiles==1 && ~contains(thisXMLfileName,'XMLsWithProblems')
		warning('backtrace','on');
		warning('Unknown XML type detected. Not configured yet for processing. Filename: \n\t%s ... Copying to "XMLsWithProblems" folder.',thisXMLfileName);

		% Copy to backup location
		[~,fileOnlyName] = fileparts(thisXMLfileName);
		prefix = char(datetime('now','Format','yyyyMMddHHmmss'));
		backupLocation = fullfile(pwd,'XMLsWithProblems',cat(2,'bup_',prefix,'_',fileOnlyName,'.xml'));
		[status, msg, msgID] = copyfile(thisXMLfileName, backupLocation);
		if ~status
			error('Copy failed: %s (%s)', msg, msgID);
		end

		limitsLatLon = [nan nan nan nan];
		limitsFt = [nan nan nan nan];
		return;
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
if flag_do_plots && ~all(isnan(limitsLatLon),'all')
    LLplotData = [...
        limitsLatLon(1) limitsLatLon(3);
        limitsLatLon(2) limitsLatLon(3);
        limitsLatLon(2) limitsLatLon(4);
        limitsLatLon(1) limitsLatLon(4);
        limitsLatLon(1) limitsLatLon(3);
        ];
    clear plotFormat
    plotFormat.Color = [0 0.7 0];
    plotFormat.Marker = '.';
    plotFormat.MarkerSize = 10;
    plotFormat.LineStyle = '-';
    plotFormat.LineWidth = 3;
    fcn_plotRoad_plotLL(LLplotData, (plotFormat), (figNum));
	geolimits(limitsLatLon(1,1:2), limitsLatLon(1,3:4));
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

%% fcn_INTERNAL_extractByStyle
function [flagWasFound, limitsLatLon, limitsFt] = fcn_INTERNAL_extractByStyle(...
			stringArrayOfDEMXMLfile, ...
			thisLLAStartOfSegmentString, thisLLAEndOfSegmentString, thisLLAModifierString, ...
			thisFtStartOfSegmentString, thisFtEndOfSegmentString, thisFtModifierString, ...
			flagUseWestOrLeft)

flagBeVerbose = false;

%fcn_INTERNAL_extractByStyle(stringArrayOfDEMXMLfile, thisLLAStartOfSegmentString, thisLLAModifierString, thisFtStartOfSegmentString, thisFtModifierString, flagUseWestOrLeft)

flagWasFound = false;
limitsLatLon = [nan nan nan nan];
limitsFt = [nan nan nan nan];



% Extract LLA data
firstFoundLLAStartOfSegmentStringIndex = find(contains(stringArrayOfDEMXMLfile,thisLLAStartOfSegmentString),1,'first');
lastFoundLLAEndOfSegmentStringIndex = find(contains(stringArrayOfDEMXMLfile,thisLLAEndOfSegmentString),1,'last');
flagLLAWasFound = false;
if ~isempty(firstFoundLLAStartOfSegmentStringIndex) && ~isempty(lastFoundLLAEndOfSegmentStringIndex)
	% Start string was found
	stringArrayToSearch = stringArrayOfDEMXMLfile(firstFoundLLAStartOfSegmentStringIndex:lastFoundLLAEndOfSegmentStringIndex,:);

	% Make sure the first boundingDirection ('west') is found
	thisDirectionString = 'west';
	startString = sprintf('<%s%s',thisDirectionString, thisLLAModifierString);
	flagWasFound = fcn_INTERNAL_findLineContainingString(stringArrayToSearch, startString);

	% Force an exit if more than one instance is found
	if ~flagWasFound
		return;		
	end

	[limitsLatLon, flagLLAWasFound] = fcn_INTERNAL_extractWESNdata(stringArrayToSearch, thisLLAModifierString, 0);
end

% Extract Ft data
firstFoundFtStartOfSegmentStringIndex  = find(contains(stringArrayOfDEMXMLfile,thisFtStartOfSegmentString),1,'first');
lastFoundFtEndOfSegmentStringIndex  = find(contains(stringArrayOfDEMXMLfile,thisFtEndOfSegmentString),1,'last');
flagFtWasFound = false;
if ~isempty(firstFoundFtStartOfSegmentStringIndex) && ~isempty(lastFoundFtEndOfSegmentStringIndex)
	% Start string was found
	stringArrayToSearch = stringArrayOfDEMXMLfile(firstFoundFtStartOfSegmentStringIndex:lastFoundFtEndOfSegmentStringIndex,:);

	% Make sure the first boundingDirection ('west') is found
	thisDirectionString = 'west';
	startString = sprintf('<%s%s',thisDirectionString, thisFtModifierString);
	flagWasFound = fcn_INTERNAL_findLineContainingString(stringArrayToSearch, startString);

	% Force an exit if more than one instance is found
	if ~flagWasFound
		return;
	end

	[limitsFt, flagFtWasFound] = fcn_INTERNAL_extractWESNdata(stringArrayToSearch, thisFtModifierString, flagUseWestOrLeft);

end

if ~flagLLAWasFound || ~flagFtWasFound
	if ~flagLLAWasFound && flagFtWasFound
		if flagBeVerbose
			warning('backtrace','on');
			warning('limitsLatLon data was not found but limitsFt was.');
		end
		flagWasFound = false;
		return;
	elseif flagLLAWasFound && ~flagFtWasFound
		if flagBeVerbose
			warning('backtrace','on');
			warning('limitsLatLon data was found but limitsFt was not.');
		end
		flagWasFound = false;
		return;
	elseif ~flagLLAWasFound && ~flagFtWasFound
		if flagBeVerbose
			warning('backtrace','on');
			warning('Neither limitsLatLon data or limitsFt was found.');
		end
		flagWasFound = false;
		return;
	else
		error('Situation encountered that should never occur. Exiting');
	end
end

end % fcn_INTERNAL_extractByStyle

% %% fcn_INTERNAL_tagLinesAfterStartString
% function flagIsAfterStartOfSegment = fcn_INTERNAL_tagLinesAfterStartString(stringArrayOfDEMXMLfile, foundStartOfSegmentStringIndex, foundEndOfSegmentStringIndex)
% % Looks for a starting string and tags all lines after that string as true
% 
% NlinesOfStrings = size(stringArrayOfDEMXMLfile,1);
% 
% % startOfSegmentStringIndex = find(foundStartOfSegmentStringIndex);
% % if length(startOfSegmentStringIndex)>1
% % 	error('More than one start of segment string found inside the XML file - exiting');
% % end
% % 
% % endOfSegmentStringIndex = find(foundEndOfSegmentStringIndex);
% % if length(endOfSegmentStringIndex)>1
% % 	error('More than one end of segment string found inside the XML file - exiting');
% % end
% 
% flagIsAfterStartOfSegment = false(NlinesOfStrings,1);
% flagIsAfterStartOfSegment(foundStartOfSegmentStringIndex:foundEndOfSegmentStringIndex,1) = true;
% 
% end % Ends fcn_INTERNAL_tagLinesAfterStartString


%% fcn_INTERNAL_extractWESNdata
function [limitsLatLonDirections, flagWasFound] = fcn_INTERNAL_extractWESNdata(stringArrayToSearch, thisModifierString, flagUseWestOrLeft)
% Extractst the west, east, north, south (WESN) direction limits for either
% LLA or Ft data
flagBeVerbose = 0;

% Fill default values
limitsLatLonDirections = nan(1,4);

if flagUseWestOrLeft==0
	boundingDirections = {'south','north','west','east'};
else
	boundingDirections = {'bottom','top','left','right'};
end

flagWasFound = true;
WESNdata = nan(4,1);
for ith_direction = 1:length(boundingDirections)
    thisDirectionString = boundingDirections{ith_direction};

	% Find line of start string
    startString = sprintf('<%s%s',thisDirectionString, thisModifierString);
	[flagWasFound, startLineWhereFound] = fcn_INTERNAL_findLineContainingString(stringArrayToSearch, startString);
	if ~flagWasFound
		return;
	end

	% Find line of end string
	endString = sprintf('</%s%s',thisDirectionString, thisModifierString);
	[flagWasFound, endLineWhereFound] = fcn_INTERNAL_findLineContainingString(stringArrayToSearch, endString);
	if ~flagWasFound
		return;
	end

	% Append the lines that contain and are inbetween the start and end
	% into one line of characters
	thisLineOfCharacters = [];
	for ith_line = startLineWhereFound:endLineWhereFound
		thisLineOfCharacters = strcat(thisLineOfCharacters,stringArrayToSearch(ith_line,:));
	end

    % Look for the matching characters in this line of text, and remove
	% extra start/end spaces
    thisCharactersWithBracket = extractBetween(thisLineOfCharacters,startString,endString);
	thisCharacters = strip(extractAfter(thisCharactersWithBracket,'>'));

	% Keep data with decimal places
	if size(thisCharacters,1)>1
		goodFlags = contains(thisCharacters,'.') & abs(str2double(thisCharacters))<100;
		thisCharacters = thisCharacters(goodFlags);
	end

	% Make sure data isn't empty
	if isempty(thisCharacters) || any(size(thisCharacters)>1,'all')
		if flagBeVerbose
			warning('backtrace','on');
			warning('Unable to find numeric characters within boundingDirections strings of %s and %s. Exiting', startString, endString);
		end
		flagWasFound = false;
		return
	end

	% Save converted data
	WESNdata(ith_direction) = str2double(thisCharacters);

    
end


% Determine geographic limits (cell-centered limits)
% latlim = [min(latGrid(:)), max(latGrid(:))];
% lonlim = [min(lonGrid(:)), max(lonGrid(:))];
latlimDirectionLimits = [WESNdata(1), WESNdata(2)];
lonlimDirectionLimits = [WESNdata(3), WESNdata(4)];


limitsLatLonDirections = [latlimDirectionLimits lonlimDirectionLimits];
end % Ends fcn_INTERNAL_extractWESNdata

%% fcn_INTERNAL_findLineContainingString
function [flagWasFound,linesWhereFound] = fcn_INTERNAL_findLineContainingString(stringArrayToSearch, stringToMatch)
flagBeVerbose = false;

flagWasFound = true;
flagsLinesStringWasFound = contains(stringArrayToSearch,stringToMatch);
linesWhereFound = find(flagsLinesStringWasFound);
if isempty(linesWhereFound)
	if flagBeVerbose
		warning('backtrace','on');
		warning('The boundingDirections string: %s was not found anywhere in the XML file',stringToMatch);
	end
	flagWasFound = false;
	return;
else
	if length(linesWhereFound)>1
		if flagBeVerbose
			warning('backtrace','on');
			warning('More than one possible boundingDirections string %s found. Neither will be used', stringToMatch);
		end
		flagWasFound = false;
		return;
	end
end
end % Ends fcn_INTERNAL_findLineContainingString

%% fcn_INTERNAL_detectCRType
function info = fcn_INTERNAL_detectCRType(fname)
% detectCRType  Detect carriage-return / line-feed style in a file
%   info = detectCRType(fname) returns a struct with fields:
%     nCRLF  - number of CRLF occurrences (13,10)
%     nLF    - number of lone LF occurrences
%     nCR    - number of lone CR occurrences
%     totalLines - nCRLF + nLF + nCR
%     type   - 'CRLF', 'LF', 'CR', 'Mixed', or 'None'
try
	fid = fopen(fname, 'rb');
catch
	disp('Stop here');
end

if fid < 0
    error('Cannot open file: %s', fname);
end
data = fread(fid, Inf, '*uint8');
fclose(fid);

if isempty(data)
    info = struct('nCRLF',0,'nLF',0,'nCR',0,'totalLines',0,'type','None');
    return;
end

b = data(:);
isCR = (b == 13);
isLF = (b == 10);

% Count CRLF occurrences: CR followed by LF
crlfIdx = find(isCR(1:end-1) & isLF(2:end));
nCRLF = numel(crlfIdx);

% Count total LFs and CRs
totalLF = sum(isLF);
totalCR = sum(isCR);

% Lone LFs (not part of CRLF)
nLF = totalLF - nCRLF;

% Lone CRs (CR not part of CRLF)
nCR = totalCR - nCRLF;

totalLines = nCRLF + nLF + nCR;

% Decide predominant type
counts = [nCRLF, nLF, nCR];
names = {'CRLF','LF','CR'};
if totalLines == 0
    t = 'None';
else
    [m, idx] = max(counts);
    if m == 0
        t = 'None';
    elseif sum(counts>0) == 1
        t = names{idx};
    else
        t = 'Mixed';
    end
end

info = struct('nCRLF',nCRLF,'nLF',nLF,'nCR',nCR,'totalLines',totalLines,'type',t);
end

%%
function fcn_INTERNAL_xmlPrettify(inFile, outFile)

flagBeVerbose = false;

% xmlPrettify  Read XML and write a pretty-printed version with line feeds
%   xmlPrettify(inFile, outFile)
if nargin < 2
    outFile = inFile;
end

% Read XML DOM (works even if input has no line feeds)
try
	doc = xmlread(inFile, 'AllowDoctype',true);
	% xmlwrite outputs with indentation and line breaks
	xmlwrite(outFile, doc);
catch
	if flagBeVerbose
		warning('backtrace','on');
		warning('Unable to read XML file: %s\nDefaulting outFile to inFile', inFile);
	end
	[status, msg, msgID] = copyfile(inFile, outFile);
	if ~status
		error('Copy failed of file: %s\n Error was: %s (%s)', inFile, msg, msgID);
	end
end


end

function [firstDigits, secondDigits] = fcn_INTERNAL_extractFtDigitsFromFilename(thisXMLfileName)

firstDigits = [];
secondDigits = [];

% Check filename digits. First get the file name
[~,filename] = fileparts(thisXMLfileName);
filenamepart1 = filename;
if contains(filenamepart1,'.','IgnoreCase',true)
	filenamepart1 = extractBefore(filenamepart1,'.');
end
filenamepart2 = filenamepart1;
if contains(filenamepart2,'_','IgnoreCase',true)
	lastUnderscore = find(filenamepart2=='_',1,'last');
	filenamepart2 = filenamepart2(1,(lastUnderscore+1):end);
end

% Find which values are digits
isDigit = isstrprop(filenamepart2, 'digit');
lastCharacter = find(~isDigit,1,'last');
if lastCharacter < length(filenamepart2)
		
	remainingDigitCharacters = filenamepart2(1,lastCharacter+1:end);
	
	% Are there an even number of characters?
	if 0==mod(length(remainingDigitCharacters),2)
		eachLength = round(length(remainingDigitCharacters)/2);
		firstCharacters = remainingDigitCharacters(1,1:eachLength);
		secondCharacters = remainingDigitCharacters(1,(eachLength+1):end);
	end

	firstDigits = str2double(firstCharacters);
	secondDigits = str2double(secondCharacters);
end

end