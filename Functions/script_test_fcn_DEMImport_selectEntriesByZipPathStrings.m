%% script_test_fcn_DEMImport_selectEntriesByZipPathStrings
% Exercises the function: fcn_DEMImport_selectEntriesByZipPathStrings

% REVISION HISTORY:
% 
% 2026_04_08 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_selectEntriesByZipPathStrings
%   % * Wrote this code originally

%% Set up the workspace
close all

%% Code demos start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____                              ____   __    _____          _
%  |  __ \                            / __ \ / _|  / ____|        | |
%  | |  | | ___ _ __ ___   ___  ___  | |  | | |_  | |     ___   __| | ___
%  | |  | |/ _ \ '_ ` _ \ / _ \/ __| | |  | |  _| | |    / _ \ / _` |/ _ \
%  | |__| |  __/ | | | | | (_) \__ \ | |__| | |   | |___| (_) | (_| |  __/
%  |_____/ \___|_| |_| |_|\___/|___/  \____/|_|    \_____\___/ \__,_|\___|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Demos%20Of%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 1

close all;
fprintf(1,'Figure: 1XXXXXX: DEMO cases\n');

%% DEMO case: Select the entries when the requiredString is DEM

figNum = 10001;
titleString = sprintf('DEMO case: Select the entries when the requiredString is DEM');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load LatLonLimits and zipPaths (INPUTS)
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');


if 1==0
	% Do dumb load
	load(pamap_lidar_limitsFile);
else
	% Do smart load, one variable at a time with warnings

	matlabFileObject = matfile(pamap_lidar_limitsFile);        % returns matlab.io.MatFile object
	vars = who(matlabFileObject);             % variable names in the file (no full load)
	expectedVariables = {'LatLonLimits', 'zipPaths'};

	for ith_expectedVariable = 1:length(expectedVariables)
		thisExpectedVariable = expectedVariables{ith_expectedVariable};
		% Read a variable only if it exists
		if ismember(thisExpectedVariable, vars)
			% loads only that variable/part
			commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);',thisExpectedVariable);
			eval(commandString);
		else
			warning('Variable %s not found in the limits file: %s.', thisExpectedVariable, pamap_lidar_limitsFile);
		end
	end
end

% INPUT
requiredStrings = {'DEM'}; 

% Call the function
[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ... 
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, (figNum));


%% DEMO case: Select the entries when the requiredString is {DEM, North} 

figNum = 10001;
titleString = sprintf('DEMO case: Select the entries when the requiredString is DEM');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load LatLonLimits and zipPaths (INPUTS)
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');


if 1==0
	% Do dumb load
	load(pamap_lidar_limitsFile);
else
	% Do smart load, one variable at a time with warnings

	matlabFileObject = matfile(pamap_lidar_limitsFile);        % returns matlab.io.MatFile object
	vars = who(matlabFileObject);             % variable names in the file (no full load)
	expectedVariables = {'LatLonLimits', 'zipPaths'};

	for ith_expectedVariable = 1:length(expectedVariables)
		thisExpectedVariable = expectedVariables{ith_expectedVariable};
		% Read a variable only if it exists
		if ismember(thisExpectedVariable, vars)
			% loads only that variable/part
			commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);',thisExpectedVariable);
			eval(commandString);
		else
			warning('Variable %s not found in the limits file: %s.', thisExpectedVariable, pamap_lidar_limitsFile);
		end
	end
end

% INPUT
requiredStrings = {'\DEM\', '\North\'}; 

% Call the function
[matchingLatLonLimits, matchingZipPaths, matchingEntriesFlags] = ... 
    fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, (figNum));



