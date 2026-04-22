% script_test_fcn_DEMImport_extractLimitsFromZipFile
% tests fcn_DEMImport_extractLimitsFromZipFile.m

% REVISION HISTORY:
%
% 2026_03_26 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_extractLimitsFromZipFile
%   % * Wrote the code originally
%
% 2026_04_17 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_extractLimitsFromZipFile
%   % * Added test case for DEM imports where fields are missing. See Test
%   %   % case 20003

% TO-DO:
%
% 2026_03_26 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)


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

%% DEMO case: build files in Data directory
figNum = 10001;
titleString = sprintf('DEMO case: simple demo of extracting limits');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);


fcn_plotRoad_plotLL([],[],figNum);
set(gca,'MapCenter',[41.2545 -78.0122], 'ZoomLevel', 6.875); % Entire state

thisURL = 'https://www.pasda.psu.edu/download/alleghenycountyimagery2015/LiDAR/ClassifiedLAS/PAALLE_PA_S_SP83_sft/13736E388029N_las.zip';

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);
zipFile = fullfile(lasDirectory,'13736E388029N_las.zip');
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime);
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLimitsFromZipFile(zipFile, figNum);

sgtitle(titleString, 'Interpreter','none');


% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable values
assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));
assert(isequal(round(limitsFt/1E6,4),round([0.3880    0.3907    1.3737    1.3763],4)));

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
titleString = sprintf('TEST case: Weird case 1');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% zipFile = 'D:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download\pamap\LidarMosaics\CountyMosaics\county_DEM_3M\PAMAP_DEM_mosaic_York_3m.zip';
% 
% % Call the function
% [limitsLatLon, limitsFt] = fcn_DEMImport_extractLimitsFromZipFile(zipFile, figNum);
% 
% sgtitle(titleString, 'Interpreter','none');
% 
% 
% % Check variable types
% assert(isnumeric(limitsLatLon));
% assert(isnumeric(limitsFt));
% 
% % Check variable sizes
% assert(isequal(size(limitsLatLon),[1 4]));
% assert(isequal(size(limitsFt),[1 4]));
% 
% % Check variable values
% assert(isequal(round(limitsLatLon,4),[39.6799   40.2378  -77.1762  -76.2045]));
% assert(isequal(round(limitsFt/1E6,4),round([0.1300    0.3300    2.1300    2.4000],4)));
% 
% % Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));


%% TEST case: Test with -2 option to avoid deleting extraction directory
figNum = 20002;
titleString = sprintf('TEST case: Test with -2 option to avoid deleting extraction directory');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Remove tmpFolder if it is there
tmpFolder = fullfile(pwd,'TempExtract');
if exist(tmpFolder,'dir')
	rmdir(tmpFolder, 's');
end

% Grab a zip file to use for testing
thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/21001790PAN_dem.zip';

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);
zipFile = fullfile(lasDirectory,'21001790PAN_dem.zip');
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end


% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLimitsFromZipFile(zipFile, -2);

sgtitle(titleString, 'Interpreter','none');

% Show that the temp folder is now there (was NOT deleted!)
assert(exist(tmpFolder,'dir'))

% Remove tmpFolder if it is there to avoid it being added to repo
tmpFolder = fullfile(pwd,'TempExtract');
if exist(tmpFolder,'dir')
	rmdir(tmpFolder, 's');
end

% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable valueslimit
assert(isequal(round(limitsLatLon,4),[40.7138   40.7414  -78.3941  -78.3578]));
assert(isequal(round(limitsFt/1E6,4),round([0.2000    0.2100    1.7900    1.8000],4)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% TEST case: Test with a DEM that has missing info
figNum = 20003;
titleString = sprintf('TEST case: Test with a DEM that has missing info');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Remove tmpFolder if it is there
tmpFolder = fullfile(pwd,'TempExtract');
if exist(tmpFolder,'dir')
	rmdir(tmpFolder, 's');
end

% Grab a zip file to use for testing
% thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2008/40000000/42002730PAN_dem.zip';
thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2008/30000000/38002680PAN_dem.zip';


% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);
zipFile = fullfile(lasDirectory,'38002680PAN_dem.zip');

% FOR DEBUGGING:
% zipFile = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\download\pamap\pamap_lidar\cycle1\DEM\North\2008\30000000\38002680PAN_dem.zip';

if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end


% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLimitsFromZipFile(zipFile, -2);

sgtitle(titleString, 'Interpreter','none');

% Show that the temp folder is now there (was NOT deleted!)
assert(exist(tmpFolder,'dir'))

% Remove tmpFolder if it is there to avoid it being added to repo
tmpFolder = fullfile(pwd,'TempExtract');
if exist(tmpFolder,'dir')
	rmdir(tmpFolder, 's');
end

% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable valueslimit
assert(isequal(round(limitsLatLon,4),[41.1522   41.1805  -75.1660  -75.1286]));
assert(isequal(round(limitsFt/1E6,4),round([0.3700    0.3800    2.6800    2.6900],4)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));




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

%% Basic example - NO FIGURE
figNum = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

thisURL = 'https://www.pasda.psu.edu/download/alleghenycountyimagery2015/LiDAR/ClassifiedLAS/PAALLE_PA_S_SP83_sft/13736E388029N_las.zip';

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);
zipFile = fullfile(lasDirectory,'13736E388029N_las.zip');
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% Call the function
limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, []);

% Check variable types
assert(isnumeric(limitsLatLon));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));

% Check variable values
assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

thisURL = 'https://www.pasda.psu.edu/download/alleghenycountyimagery2015/LiDAR/ClassifiedLAS/PAALLE_PA_S_SP83_sft/13736E388029N_las.zip';

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);
zipFile = fullfile(lasDirectory,'13736E388029N_las.zip');
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end

% Call the function
limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, (-1));

% Check variable types
assert(isnumeric(limitsLatLon));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));

% Check variable values
assert(isequal(round(limitsLatLon,4),[40.3788   40.3862  -79.8856  -79.8759]));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

thisURL = 'https://www.pasda.psu.edu/download/alleghenycountyimagery2015/LiDAR/ClassifiedLAS/PAALLE_PA_S_SP83_sft/13736E388029N_las.zip';

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);
zipFile = fullfile(lasDirectory,'13736E388029N_las.zip');
if ~exist(zipFile,'file')
	try
		tic
		websave(zipFile, thisURL);
		saveTime = toc;
		fprintf(1,'\tSaved temp file %s  in %.2f seconds \t', zipFile, saveTime)
	catch
		fprintf(1,'Unable to download file: %s \t', tempfile);
		error('Unable to continue!');
	end
end



Niterations = 2;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations
	% Call the function
	limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, ([]));
end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations
	% Call the function
	limitsLatLon = fcn_DEMImport_extractLimitsFromZipFile(zipFile, (-1));
end
fast_method = toc;

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

% Plot results as bar chart
figure(373737);
clf;
hold on;

X = categorical({'Normal mode','Fast mode'});
X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
Y = [slow_method fast_method ]*1000/Niterations;
bar(X,Y)
ylabel('Execution time (Milliseconds)')


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


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
% 
% function INTERNAL_plot_results(tempXYdata,cell_array_of_entry_indices,cell_array_of_lap_indices,cell_array_of_exit_indices,figNum)
% figure(figNum);
% clf
% 
% % Make first subplot
% subplot(1,3,1);  
% axis square
% hold on;
% title('Laps');
% legend_text = {};
% 
% for ith_lap = 1:length(cell_array_of_lap_indices)
%     plot(tempXYdata(cell_array_of_lap_indices{ith_lap},1),tempXYdata(cell_array_of_lap_indices{ith_lap},2),'.-','Linewidth',3);
%     legend_text = [legend_text, sprintf('Lap %d',ith_lap)]; %#ok<AGROW>    
% end
% h_legend = legend(legend_text);
% set(h_legend,'AutoUpdate','off');
% temp1 = axis;
% 
% % Make second subplot
% subplot(1,3,2);  
% axis square
% hold on;
% title('Entry');
% legend_text = {};
% 
% for ith_lap = 1:length(cell_array_of_entry_indices)
%     plot(tempXYdata(cell_array_of_entry_indices{ith_lap},1),tempXYdata(cell_array_of_entry_indices{ith_lap},2),'.-','Linewidth',3);
%     legend_text = [legend_text, sprintf('Lap %d',ith_lap)]; %#ok<AGROW>    
% end
% h_legend = legend(legend_text);
% set(h_legend,'AutoUpdate','off');
% temp2 = axis;
% 
% % Make third subplot
% subplot(1,3,3);  
% axis square
% hold on;
% title('Exit');
% legend_text = {};
% 
% for ith_lap = 1:length(cell_array_of_exit_indices)
%     plot(tempXYdata(cell_array_of_exit_indices{ith_lap},1),tempXYdata(cell_array_of_exit_indices{ith_lap},2),'.-','Linewidth',3);
%     legend_text = [legend_text, sprintf('Lap %d',ith_lap)]; %#ok<AGROW>    
% end
% h_legend = legend(legend_text);
% set(h_legend,'AutoUpdate','off');
% temp3 = axis;
% 
% % Set all axes to same value, maximum range
% max_axis = max([temp1; temp2; temp3]);
% min_axis = min([temp1; temp2; temp3]);
% good_axis = [min_axis(1) max_axis(2) min_axis(3) max_axis(4)];
% subplot(1,3,1); axis(good_axis);
% subplot(1,3,2); axis(good_axis);
% subplot(1,3,3); axis(good_axis);
% 
% 
% end
% 
% %% fcn_INTERNAL_loadExampleData
% function tempXYdata = fcn_INTERNAL_loadExampleData(dataSetNumber)
% % Call the function to fill in an array of "path" type
% laps_array = fcn_Laps_fillSampleLaps(-1);
% 
% 
% % Use the last data
% tempXYdata = laps_array{dataSetNumber};
% end % Ends fcn_INTERNAL_loadExampleData
