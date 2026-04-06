% script_test_fcn_DEMImport_extractLatLonLimitsFromXML.m
% tests fcn_DEMImport_extractLatLonLimitsFromXML.m

% REVISION HISTORY:
%
% 2026_03_21 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_extractLatLonLimitsFromXML
%   % * Wrote the code originally, using breakDataIntoLaps as starter

% TO-DO:
%
% 2026_03_13 by Sean Brennan, sbrennan@psu.edu
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


%% DEMO case: load 20001890PAN_bl.shp.xml
figNum = 10001;
titleString = sprintf('DEMO case: load 20001890PAN_bl.shp.xml');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

XMLfileName = fullfile(pwd,'Data','XMLexamples','20001890PAN_bl.shp.xml');

% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable values                low       high     left       right
assert(isequal(round(limitsLatLon,4),[40.6878   40.7153  -78.0332  -77.9970]));
assert(isequal(round(limitsFt/1E6,4),round([0.1900    0.2000    1.8900    1.9000],4)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO case: load PAMAP_DEM_mosaic_Adams_1m
figNum = 10002;
titleString = sprintf('DEMO case: load PAMAP_DEM_mosaic_Adams_1m');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

XMLfileName = fullfile(pwd,'Data','XMLexamples','PAMAP_DEM_mosaic_Adams_1m.tif.xml');

% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable values
assert(isequal(round(limitsLatLon,4),[39.6872   40.0742  -77.4959  -76.9228]));
assert(isequal(round(limitsFt/1E6,4),round([0.1300    0.2700    2.0400    2.2000],4)));

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

%% TEST case: cell array input
figNum = 20001;
titleString = sprintf('TEST case: cell array input');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% clear XMLfileName
% XMLfileName(1,:) = 'C:\Users\snb10\Desktop\GitHubRepos\IVSG\FieldDataCollection\RoadSegments\DEMImport\TempExtract\PAMAP_DEM3mMosaics.xml          ';
% XMLfileName(2,:) = 'C:\Users\snb10\Desktop\GitHubRepos\IVSG\FieldDataCollection\RoadSegments\DEMImport\TempExtract\PAMAP_DEM_mosaic_York_3m.tif.xml';
% 
% % Call the function
% [limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(figNum));
% 
% sgtitle(titleString, 'Interpreter','none');
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

%% TEST case: 24002070PAN_bl.shp.xml
figNum = 20002;
titleString = sprintf('TEST case: 24002070PAN_bl.shp.xml');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

XMLfileName = fullfile(pwd,'Data','XMLexamples','24002070PAN_bl.shp.xml');

% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable values
assert(isequal(round(limitsLatLon,4),[40.7972   40.8248  -77.3834  -77.3471]));
assert(isequal(round(limitsFt/1E6,4),round([0.2300    0.2400    2.0700    2.0800],4)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% TEST case: bup_20260404034020_17spe165280.tif.xml
figNum = 20003;
titleString = sprintf('TEST case: bup_20260404034020_17spe165280.tif.xml');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

XMLfileName = fullfile(pwd,'Data','XMLexamples','bup_20260404034020_17spe165280.tif.xml');

% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable values
assert(isequal(round(limitsLatLon,4),[39.9939   40.0077  -79.6351  -79.6178]));
assert(all(isnan(limitsFt),'all'));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% TEST case: all of the XML files in XMLsWithProblems
figNum = 20003;
titleString = sprintf('TEST case: all of the XML files in XMLsWithProblems');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

folderToCheck = fullfile(pwd,'XMLsWithProblems');
filesToCheck = dir(cat(2,folderToCheck,filesep,'*.xml'));
NfilesChecked = length(filesToCheck);
filesBroken = false(NfilesChecked,1);
for ith_file = 1:NfilesChecked
	thisFile = filesToCheck(ith_file).name;
	XMLfileName = fullfile(pwd,'XMLsWithProblems',thisFile);
	
	% Call the function
	[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(figNum));

	% Check variable types
	assert(isnumeric(limitsLatLon));
	assert(isnumeric(limitsFt));

	% Check variable sizes
	assert(isequal(size(limitsLatLon),[1 4]));
	assert(isequal(size(limitsFt),[1 4]));

	% % Check variable values
	% assert(isequal(round(limitsLatLon,4),[39.9939   40.0077  -79.6351  -79.6178]));
	% assert(all(isnan(limitsFt),'all'));

	% Make sure plot opened up
	assert(isequal(get(gcf,'Number'),figNum));

	if all(isnan([limitsLatLon limitsFt]),'all')
		filesBroken(ith_file,1) = true;
		fprintf(1,'This file is broken: %s \n',thisFile);
	else
		fprintf(1,'This file works: %s \n',thisFile);
		set(gca,'MapCenter',[41.2545 -78.0122], 'ZoomLevel', 6.875); % Entire state
		drawnow
	end
end

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

XMLfileName = fullfile(pwd,'Data','XMLexamples','20001890PAN_bl.shp.xml');

% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,([]));


% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable values                low       high     left       right
assert(isequal(round(limitsLatLon,4),[40.6878   40.7153  -78.0332  -77.9970]));
assert(isequal(round(limitsFt/1E6,4),round([0.1900    0.2000    1.8900    1.9000],4)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

XMLfileName = fullfile(pwd,'Data','XMLexamples','20001890PAN_bl.shp.xml');

% Call the function
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(-1));


% Check variable types
assert(isnumeric(limitsLatLon));
assert(isnumeric(limitsFt));

% Check variable sizes
assert(isequal(size(limitsLatLon),[1 4]));
assert(isequal(size(limitsFt),[1 4]));

% Check variable values                low       high     left       right
assert(isequal(round(limitsLatLon,4),[40.6878   40.7153  -78.0332  -77.9970]));
assert(isequal(round(limitsFt/1E6,4),round([0.1900    0.2000    1.8900    1.9000],4)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);


XMLfileName = fullfile(pwd,'Data','XMLexamples','20001890PAN_bl.shp.xml');

% Call the function

Niterations = 5;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations
    % Call the function
	[limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,([]));
end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations
    % Call the function
    [limitsLatLon, limitsFt] = fcn_DEMImport_extractLatLonLimitsFromXML(XMLfileName,(-1));
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
