%% script_test_fcn_DEMImport_plotLatLonLimits
% Exercises the function: fcn_DEMImport_plotLatLonLimits

% REVISION HISTORY:
% 
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_plotLatLonLimits
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

%% DEMO case: Basic demo of one limit region and default plot format

figNum = 10001;
titleString = sprintf('DEMO case: Basic demo of one limit region and default plot format');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Set inputs
limitsLatLon = [40.3788   40.3862  -79.8856  -79.8759];
plotFormat = [];

% Call the function
h_geoplot = fcn_DEMImport_plotLatLonLimits(limitsLatLon, (plotFormat), (figNum)); 

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(ishandle(h_geoplot));

% Check variable sizes
assert(isequal(size(h_geoplot),[1 1]));

% Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% DEMO case: Basic demo of one limit region with user-specified plot format

figNum = 10002;
titleString = sprintf('DEMO case: Basic demo of one limit region with user-specified plot format');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Set inputs
limitsLatLon = [40.3788   40.3862  -79.8856  -79.8759];
clear plotFormat
plotFormat.Color = [0 0.7 0];
plotFormat.Marker = '.';
plotFormat.MarkerSize = 10;
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 3;

% Call the function
h_geoplot = fcn_DEMImport_plotLatLonLimits(limitsLatLon, (plotFormat), (figNum)); 

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(ishandle(h_geoplot));

% Check variable sizes
assert(isequal(size(h_geoplot),[1 1]));

% Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO case: Basic demo of many limit regions with user-specified plot format

figNum = 10003;
titleString = sprintf('DEMO case: Basic demo of many limit regions with user-specified plot format');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Set inputs

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
limitsLatLon = fcn_DEMImport_selectEntriesByZipPathStrings(requiredStrings, LatLonLimits, zipPaths, (-1));


clear plotFormat
plotFormat.Color = [0 0.7 0];
plotFormat.Marker = '.';
plotFormat.MarkerSize = 10;
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 3;

% Call the function
limitsLatLon = limitsLatLon(~isnan(limitsLatLon(:,1)),:);

h_geoplot = fcn_DEMImport_plotLatLonLimits(limitsLatLon, (plotFormat), (figNum)); 

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(ishandle(h_geoplot));

% Check variable sizes
assert(isequal(size(h_geoplot),[1 1]));

% Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% Test cases start here. These are very simple, usually trivial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______ ______  _____ _______ _____
% |__   __|  ____|/ ____|__   __/ ____|
%    | |  | |__  | (___    | | | (___
%    | |  |  __|  \___ \   | |  \___ \
%    | |  | |____ ____) |  | |  ____) |
%    |_|  |______|_____/   |_| |_____/
%
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 2

close all;
fprintf(1,'Figure: 2XXXXXX: TEST mode cases\n');

%% TEST case: Weird case 1
figNum = 20001;
titleString = sprintf('TEST case: Not coded yet');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;





%% Fast Mode Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ______        _     __  __           _        _______        _
% |  ____|      | |   |  \/  |         | |      |__   __|      | |
% | |__ __ _ ___| |_  | \  / | ___   __| | ___     | | ___  ___| |_ ___
% |  __/ _` / __| __| | |\/| |/ _ \ / _` |/ _ \    | |/ _ \/ __| __/ __|
% | | | (_| \__ \ |_  | |  | | (_) | (_| |  __/    | |  __/\__ \ |_\__ \
% |_|  \__,_|___/\__| |_|  |_|\___/ \__,_|\___|    |_|\___||___/\__|___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fast%20Mode%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 8

close all;
fprintf(1,'Figure: 8XXXXXX: FAST mode cases\n');

% %% Basic example - NO FIGURE
% figNum = 80001;
% fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
% figure(figNum); close(figNum);
% 
% thisURL = 'https://www.pasda.psu.edu/download/alleghenycountyimagery2015/LiDAR/ClassifiedLAS/PAALLE_PA_S_SP83_sft/13736E388029N_las.zip';
% 
% % Define a file name and directory to save results
% lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
% fcn_DebugTools_makeDirectory(lasDirectory);
% zipFile = fullfile(lasDirectory,'13736E388029N_las.zip');
% if ~exist(zipFile,'file')
% 	try
% 		tic
% 		websave(zipFile, thisURL);
% 		saveTime = toc;
% 		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
% 	catch
% 		fprintf(1,'Unable to download file: %s \t', tempfile);
% 		error('Unable to continue!');
% 	end
% end
% 
% % Call the function
% limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, []);
% 
% % Check variable types
% assert(isnumeric(limitsLatLon));
% 
% % Check variable sizes
% assert(isequal(size(limitsLatLon),[1 4]));
% 
% % Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));
% 
% 
% % Make sure plot did NOT open up
% figHandles = get(groot, 'Children');
% assert(~any(figHandles==figNum));
% 
% 
% %% Basic fast mode - NO FIGURE, FAST MODE
% figNum = 80002;
% fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
% figure(figNum); close(figNum);
% 
% thisURL = 'https://www.pasda.psu.edu/download/alleghenycountyimagery2015/LiDAR/ClassifiedLAS/PAALLE_PA_S_SP83_sft/13736E388029N_las.zip';
% 
% % Define a file name and directory to save results
% lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
% fcn_DebugTools_makeDirectory(lasDirectory);
% zipFile = fullfile(lasDirectory,'13736E388029N_las.zip');
% if ~exist(zipFile,'file')
% 	try
% 		tic
% 		websave(zipFile, thisURL);
% 		saveTime = toc;
% 		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
% 	catch
% 		fprintf(1,'Unable to download file: %s \t', tempfile);
% 		error('Unable to continue!');
% 	end
% end
% 
% % Call the function
% limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, (-1));
% 
% % Check variable types
% assert(isnumeric(limitsLatLon));
% 
% % Check variable sizes
% assert(isequal(size(limitsLatLon),[1 4]));
% 
% % Check variable values
% assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));
% 
% % Make sure plot did NOT open up
% figHandles = get(groot, 'Children');
% assert(~any(figHandles==figNum));
% 
% 
% %% Compare speeds of pre-calculation versus post-calculation versus a fast variant
% figNum = 80003;
% fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
% figure(figNum);
% close(figNum);
% 
% thisURL = 'https://www.pasda.psu.edu/download/alleghenycountyimagery2015/LiDAR/ClassifiedLAS/PAALLE_PA_S_SP83_sft/13736E388029N_las.zip';
% 
% % Define a file name and directory to save results
% lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
% fcn_DebugTools_makeDirectory(lasDirectory);
% zipFile = fullfile(lasDirectory,'13736E388029N_las.zip');
% if ~exist(zipFile,'file')
% 	try
% 		tic
% 		websave(zipFile, thisURL);
% 		saveTime = toc;
% 		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
% 	catch
% 		fprintf(1,'Unable to download file: %s \t', tempfile);
% 		error('Unable to continue!');
% 	end
% end
% 
% 
% 
% Niterations = 2;
% 
% % Do calculation without pre-calculation
% tic;
% for ith_test = 1:Niterations
% 	% Call the function
% 	limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, ([]));
% end
% slow_method = toc;
% 
% % Do calculation with pre-calculation, FAST_MODE on
% tic;
% for ith_test = 1:Niterations
% 	% Call the function
% 	limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, (-1));
% end
% fast_method = toc;
% 
% % Make sure plot did NOT open up
% figHandles = get(groot, 'Children');
% assert(~any(figHandles==figNum));
% 
% % Plot results as bar chart
% figure(373737);
% clf;
% hold on;
% 
% X = categorical({'Normal mode','Fast mode'});
% X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
% Y = [slow_method fast_method ]*1000/Niterations;
% bar(X,Y)
% ylabel('Execution time (Milliseconds)')
% 
% 
% % Make sure plot did NOT open up
% figHandles = get(groot, 'Children');
% assert(~any(figHandles==figNum));


%% BUG cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ____  _    _  _____
% |  _ \| |  | |/ ____|
% | |_) | |  | | |  __    ___ __ _ ___  ___  ___
% |  _ <| |  | | | |_ |  / __/ _` / __|/ _ \/ __|
% | |_) | |__| | |__| | | (_| (_| \__ \  __/\__ \
% |____/ \____/ \_____|  \___\__,_|___/\___||___/
%
% See: http://patorjk.com/software/taag/#p=display&v=0&f=Big&t=BUG%20cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All bug case figures start with the number 9

% close all;

%% BUG 

%% Fail conditions
if 1==0
    %
       
end


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




