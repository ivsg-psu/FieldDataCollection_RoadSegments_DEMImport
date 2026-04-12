% script_test_fcn_DEMImport_ImportDEMsFromPAMAP.m
% tests fcn_DEMImport_ImportDEMsFromPAMAP.m

% REVISION HISTORY:
%
% 2026_03_13 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_ImportDEMsFromPAMAP
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

%% DEMO case: load entire PAMAP database
figNum = 10001;
titleString = sprintf('DEMO case: load entire PAMAP database');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
% figure(figNum); clf;

% Call the function
fcn_DEMImport_ImportDEMsFromPAMAP((figNum));

% sgtitle(titleString, 'Interpreter','none');
% 
% % Check variable types
% assert(iscell(cell_array_of_lap_indices));
% assert(iscell(cell_array_of_entry_indices));
% assert(iscell(cell_array_of_exit_indices));
% 
% % Check variable sizes
% Nlaps = 3;
% assert(isequal(Nlaps,length(cell_array_of_lap_indices))); 
% assert(isequal(Nlaps,length(cell_array_of_entry_indices))); 
% assert(isequal(Nlaps,length(cell_array_of_exit_indices))); 
% 
% % Check variable values
% % Are the laps starting at expected points?
% assert(isequal(2,min(cell_array_of_lap_indices{1})));
% assert(isequal(102,min(cell_array_of_lap_indices{2})));
% assert(isequal(215,min(cell_array_of_lap_indices{3})));
% 
% % Are the laps ending at expected points?
% assert(isequal(88,max(cell_array_of_lap_indices{1})));
% assert(isequal(199,max(cell_array_of_lap_indices{2})));
% assert(isequal(293,max(cell_array_of_lap_indices{3})));
% 
% % Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));


%% Download DEMS

%%%%%
% USGS:

% PA North 10K QL1: 
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Bare_Earth_DEM/PA_North_QL1/67001640PAN_QL1_BE_DEM.zip
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Intensity/PA_North_QL1/67001640PAN_QL1_Intensity.zip
% SouthToNorth = 4400:100:6800
% WestToEast = 1640:10:1690

% DOWNLOADED on 03/13/2026
% PA North 10K QL2: 
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Bare_Earth_DEM/PA_North/24002510PAN_BE_DEM.zip
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Intensity/PA_North/25002000PAN_Intensity.zip
% SouthToNorth = 1900:100:6900
% WestToEast = 1590:10:2810

% PA North 5K QL1 - las cont
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Contours/PA_North_QL1/68001640PAN_SW_cont_QL1.zip
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/LAS/PA_North_QL1/68001640PAN_SW_LAS_QL1.zip
% SouthToNorth = 1900:100:6800
% WestToEast = 1640:10:1690

% PA North 5K QL2 - las cont
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Contours/PA_North/68001640PAN_SW_cont.zip
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/LAS/PA_North/68001640PAN_SW_las.zip
% SouthToNorth = 1900:100:6800
% WestToEast = 1590:10:2810

% PA South 10K QL2
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Bare_Earth_DEM/PA_South/59001670PAS_BE_DEM.zip
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Intensity/PA_South/59001670PAS_Intensity.zip
% SouthToNorth = 1400:100:6200
% WestToEast = 1660:10:2710

% PA South 5K QL2 - las cont
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/Contours/PA_South/59001670PAS_NE_cont.zip
% https://www.pasda.psu.edu/download/usgs/LiDAR2019/LAS/PA_South/59001670PAS_NE_las.zip
% SouthToNorth = 1400:100:6200
% WestToEast = 1660:10:2710

%%%%%%%%%%%%%
% PAMAP

% PAMAP North 2006 - 2008
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/60000000/66001210PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/CONT/North/2007/60000000/66001210PAN_cont.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/BL/North/2007/60000000/66001210PAN_bl.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/LAS/North/2007/60000000/66001210PAN.zip
% SouthToNorth = 1600:100:7800
% WestToEast = 1200:10:2810

% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/70000000/78001420PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/60000000/65002020PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2007/50000000/52002070PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/40000000/40001420PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/30000000/30001900PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/21001870PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2008/20000000/23002290PAN_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2008/30000000/39002700PAN_dem.zip

% PAMAP South 2006 - 2008
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/South/2006/60000000/64001200PAS_dem.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/CONT/South/2006/60000000/64001200PAS_cont.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/BL/South/2006/60000000/64001200PAS_bl.zip
% https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/LAS/South/2006/60000000/64001200PAS.zip
% SouthToNorth = 1400:100:6900
% WestToEast = 1180:10:2810


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

%% TEST case: This one returns nothing since there is no portion of the path in criteria
figNum = 20001;
titleString = sprintf('TEST case: This one returns nothing since there is no portion of the path in criteria');
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
% dataSetNumber = 9;
% 
% % Load some test data 
% tempXYdata = fcn_INTERNAL_loadExampleData(dataSetNumber);
% 
% start_definition = [10 3 0 0]; % Radius 10, 3 points must pass near [0,0]
% end_definition = [30 3 0 -60]; % Radius 30, 3 points must pass near [0,-60]
% excursion_definition = []; % empty
% 
% [cell_array_of_lap_indices, ...
%     cell_array_of_entry_indices, cell_array_of_exit_indices] = ...
%     fcn_DEMImport_ImportDEMsFromPAMAP(...
%     tempXYdata,...
%     start_definition,...
%     end_definition,...
%     excursion_definition,...
%     ([]));
% 
% % Check variable types
% assert(iscell(cell_array_of_lap_indices));
% assert(iscell(cell_array_of_entry_indices));
% assert(iscell(cell_array_of_exit_indices));
% 
% % Check variable sizes
% Nlaps = 3;
% assert(isequal(Nlaps,length(cell_array_of_lap_indices))); 
% assert(isequal(Nlaps,length(cell_array_of_entry_indices))); 
% assert(isequal(Nlaps,length(cell_array_of_exit_indices))); 
% 
% % Check variable values
% % Are the laps starting at expected points?
% assert(isequal(2,min(cell_array_of_lap_indices{1})));
% assert(isequal(102,min(cell_array_of_lap_indices{2})));
% assert(isequal(215,min(cell_array_of_lap_indices{3})));
% 
% % Are the laps ending at expected points?
% assert(isequal(88,max(cell_array_of_lap_indices{1})));
% assert(isequal(199,max(cell_array_of_lap_indices{2})));
% assert(isequal(293,max(cell_array_of_lap_indices{3})));
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
% dataSetNumber = 9;
% 
% % Load some test data 
% tempXYdata = fcn_INTERNAL_loadExampleData(dataSetNumber);
% 
% start_definition = [10 3 0 0]; % Radius 10, 3 points must pass near [0,0]
% end_definition = [30 3 0 -60]; % Radius 30, 3 points must pass near [0,-60]
% excursion_definition = []; % empty
% 
% [cell_array_of_lap_indices, ...
%     cell_array_of_entry_indices, cell_array_of_exit_indices] = ...
%     fcn_DEMImport_ImportDEMsFromPAMAP(...
%     tempXYdata,...
%     start_definition,...
%     end_definition,...
%     excursion_definition,...
%     (-1));
% 
% % Check variable types
% assert(iscell(cell_array_of_lap_indices));
% assert(iscell(cell_array_of_entry_indices));
% assert(iscell(cell_array_of_exit_indices));
% 
% % Check variable sizes
% Nlaps = 3;
% assert(isequal(Nlaps,length(cell_array_of_lap_indices))); 
% assert(isequal(Nlaps,length(cell_array_of_entry_indices))); 
% assert(isequal(Nlaps,length(cell_array_of_exit_indices))); 
% 
% % Check variable values
% % Are the laps starting at expected points?
% assert(isequal(2,min(cell_array_of_lap_indices{1})));
% assert(isequal(102,min(cell_array_of_lap_indices{2})));
% assert(isequal(215,min(cell_array_of_lap_indices{3})));
% 
% % Are the laps ending at expected points?
% assert(isequal(88,max(cell_array_of_lap_indices{1})));
% assert(isequal(199,max(cell_array_of_lap_indices{2})));
% assert(isequal(293,max(cell_array_of_lap_indices{3})));
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
% dataSetNumber = 9;
% 
% % Load some test data 
% tempXYdata = fcn_INTERNAL_loadExampleData(dataSetNumber);
% 
% start_definition = [10 3 0 0]; % Radius 10, 3 points must pass near [0,0]
% end_definition = [30 3 0 -60]; % Radius 30, 3 points must pass near [0,-60]
% excursion_definition = []; % empty
% 
% 
% Niterations = 50;
% 
% % Do calculation without pre-calculation
% tic;
% for ith_test = 1:Niterations
%     % Call the function
%     [cell_array_of_lap_indices, ...
%         cell_array_of_entry_indices, cell_array_of_exit_indices] = ...
%         fcn_DEMImport_ImportDEMsFromPAMAP(...
%         tempXYdata,...
%         start_definition,...
%         end_definition,...
%         excursion_definition,...
%         ([]));
% end
% slow_method = toc;
% 
% % Do calculation with pre-calculation, FAST_MODE on
% tic;
% for ith_test = 1:Niterations
%     % Call the function
%     [cell_array_of_lap_indices, ...
%         cell_array_of_entry_indices, cell_array_of_exit_indices] = ...
%         fcn_DEMImport_ImportDEMsFromPAMAP(...
%         tempXYdata,...
%         start_definition,...
%         end_definition,...
%         excursion_definition,...
%         (-1));
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
