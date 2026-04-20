% script_test_fcn_DEMImport_queryElevations
% tests fcn_DEMImport_queryElevations.m

% REVISION HISTORY:
%
% 2026_04_13 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_DEMImport_queryElevations
%   % * Wrote the code originally
% 
% 2026_04_13 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_DEMImport_queryElevations
%   % * Added a some DEMO and TEST cases
%
% 2026_04_15 by Sean Brennan, sbrennan@psu.edu
%  - In script_test_fcn_DEMImport_queryElevations
%    % * Added a test case to specify localRootFolder

% TO-DO:
%
% 2026_04_13 by Sean Brennan, sbrennan@psu.edu
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

%% DEMO case: show query using test track data
figNum = 10001;
titleString = sprintf('DEMO case: show query using test track data');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

%%%%%%%%%%%%%
% Define query. In this case, using LTI test-track points
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

queryLatLon = LLAdata(:,1:2);
requiredStrings = [];
mergeMethod = [];
localRootFolder = [];


[queriedElevationsInMeters] = ...
	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
(requiredStrings), (mergeMethod), (localRootFolder), (figNum));


sgtitle(titleString, 'Interpreter','none');


% Geoid-corrected truth values for comparison
geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
trueAltitude_InMeters = LLAdata(:,3);

% Difference in meters
difference_InMeters = queriedElevationsInMeters - trueAltitude_InMeters;


% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% Check variable sizes
assert(isequal(size(queriedElevationsInMeters),size(trueAltitude_InMeters)));

% Check variable values
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% DEMO case: show query using test track data, using local zip folders
figNum = 10002;
titleString = sprintf('DEMO case: show query using test track data, using local zip folders');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

%%%%%%%%%%%%%
% Define query. In this case, using LTI test-track points
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

queryLatLon = LLAdata(:,1:2);
requiredStrings = [];
mergeMethod = [];

% This folder is where the PASDA zip files will be stored locally
localRootFolder = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\';



[queriedElevationsInMeters] = ...
	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
(requiredStrings), (mergeMethod), (localRootFolder), (figNum));


sgtitle(titleString, 'Interpreter','none');


% Geoid-corrected truth values for comparison
geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
trueAltitude_InMeters = LLAdata(:,3);

% Difference in meters
difference_InMeters = queriedElevationsInMeters - trueAltitude_InMeters;


% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% Check variable sizes
assert(isequal(size(queriedElevationsInMeters),size(trueAltitude_InMeters)));

% Check variable values
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% DEMO case: show query using test track data, using local zip folders and multiple returns
figNum = 10003;
titleString = sprintf('DEMO case: show query using test track data, using local zip folders and multiple returns');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

%%%%%%%%%%%%%
% Define query. In this case, using LTI test-track points
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

queryLatLon = LLAdata(:,1:2);
requiredStrings = {'\DEM\', '\North\ or \South\'};
% requiredStrings = {'DEM'};
mergeMethod = 'mean';

% This folder is where the PASDA zip files will be stored locally
localRootFolder = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\';

[queriedElevationsInMeters] = ...
	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
(requiredStrings), (mergeMethod), (localRootFolder), (figNum));


sgtitle(titleString, 'Interpreter','none');


% Geoid-corrected truth values for comparison
geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
trueAltitude_InMeters = LLAdata(:,3);

% Difference in meters
difference_InMeters = queriedElevationsInMeters - trueAltitude_InMeters;


% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% Check variable sizes
assert(isequal(size(queriedElevationsInMeters),size(trueAltitude_InMeters)));

% Check variable values
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% DEMO case: show query using PennDOT segment data
figNum = 10004;
titleString = sprintf('DEMO case: show query using PennDOT segment data');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end


%%%%%%%%%%%%%
% Define query. In this case, using PennDOT points

flag_loadDataFilesWhenPossible = 1;

% Load the PennDOT LL data
PreviousDataFileName = 'PennDOT_LLcoordinates';
PreviouseDataFilePath = fullfile(pwd,'Data',cat(2,PreviousDataFileName,'.mat'));

matlabFileObject = matfile(PreviouseDataFilePath);
vars = who(matlabFileObject);
expectedVariables = {'PennDOT_LLSegments_cellArray', 'PennDOT_LLSegments_matrix', 'usableTableRows'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end


if 1==0
    if flag_loadDataFilesWhenPossible && exist(PreviouseDataFilePath,'file')
    	load(PreviouseDataFilePath,'PennDOT_LLSegments_cellArray');
    else
    	error('Unable to load file: \n\t%s\nNeed to obtain this from the PennDOTSHP repo!',PreviouseDataFilePath);
    end
end

allPennDOTPoints = vertcat(PennDOT_LLSegments_cellArray{:});


queryLatLon = allPennDOTPoints(:,1:2);
requiredStrings = {'\DEM\', '\North\ or \South\'};
% requiredStrings = {'DEM'};
mergeMethod = 'mean';

% This folder is where the PASDA zip files will be stored locally
localRootFolder = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\';


[queriedElevationsInMeters] = ...
	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
(requiredStrings), (mergeMethod), (localRootFolder), (figNum));


sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% Check variable sizes
assert(isequal(size(queriedElevationsInMeters,1),size(queryLatLon(:,1),1)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%%%%%%%%%%%%%%%%%%%
% Save results

% Save the matrix version
Npoints = size(PennDOT_LLSegments_matrix,1);
PennDOT_LLASegments_matrix = ...
    [PennDOT_LLSegments_matrix(:,1:2) nan(Npoints,1) PennDOT_LLSegments_matrix(:,3)];

validPoints = ~isnan(PennDOT_LLSegments_matrix(:,1));
PennDOT_LLASegments_matrix(validPoints,3) = queriedElevationsInMeters;

% Save the cell array version
indicies_cell_array = fcn_DebugTools_breakArrayByNans(PennDOT_LLASegments_matrix,-1);
NcellArrays = size(indicies_cell_array,2);
PennDOT_LLASegments_cellArray = cell(NcellArrays,1);
for ith_cell = 1:NcellArrays
    PennDOT_LLASegments_cellArray{ith_cell} = ...
        PennDOT_LLASegments_matrix(indicies_cell_array{ith_cell}, :);
end

NewDataFileName = 'PennDOT_LLAcoordinates';
NewDataFilePath = fullfile(pwd,'Data',cat(2,NewDataFileName,'.mat'));

% Save file
save(NewDataFilePath,'PennDOT_LLASegments_cellArray', 'PennDOT_LLASegments_matrix', 'usableTableRows');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now query using PennDOT subsegment data
figNum = 10005;
titleString = sprintf('DEMO case: show query using PennDOT subsegment data');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end


%%%%%%%%%%%%%
% Define query. In this case, using PennDOT subsegments

flag_loadDataFilesWhenPossible = 1;

% Load the PennDOT LL data
PreviousDataFileName = 'PennDOT_Subsegments';
PreviouseDataFilePath = fullfile(pwd,'LargeData',cat(2,PreviousDataFileName,'.mat'));

matlabFileObject = matfile(PreviouseDataFilePath);
vars = who(matlabFileObject);
expectedVariables = {'PennDOT_ENSegments_cellArray', 'PennDOT_ENsubSegments_cellArray', 'PennDOT_LLSegments_cellArray', 'PennDOT_LLsubSegments_cellArray'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end


if 1==0
    if flag_loadDataFilesWhenPossible && exist(PreviouseDataFilePath,'file')
    	load(PreviouseDataFilePath,'PennDOT_LLsubSegments_cellArray');
    else
    	error('Unable to load file: \n\t%s\nNeed to obtain this from the PennDOTSHP repo!',PreviouseDataFilePath);
    end
end

%%%%%
% Extract elevation

% Define variables used within the loop
requiredStrings = {'\DEM\', '\North\ or \South\'};
% requiredStrings = {'DEM'};
mergeMethod = 'mean';

% This folder is where the PASDA zip files will be stored locally
localRootFolder = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\';

% Initialize output cell array
PennDOT_LLAsubSegments_cellArray = PennDOT_LLsubSegments_cellArray;
Nsegments = size(PennDOT_LLsubSegments_cellArray,1);

% Loop through subsegments filling in height
for ith_cell = 1:Nsegments
    fprintf(1,'Checking segment %.0f of %.0f\n',ith_cell,Nsegments);
    thisMatrix = PennDOT_LLAsubSegments_cellArray{ith_cell,1};
    queryLatLon = thisMatrix(:,1:2);

    [queriedElevationsInMeters] = ...
    	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
        (requiredStrings), (mergeMethod), (localRootFolder), (figNum));
    
    newMatrix = [thisMatrix(:,1:2) queriedElevationsInMeters thisMatrix(:,3:end)];
    PennDOT_LLAsubSegments_cellArray{ith_cell,1} = newMatrix;

end



%%

%%%%%%%%%%%%%%%%%%%
% Save results
PennDOT_LLAsubSegments_matrix = fcn_DebugTools_stackCellArrayIntoMatrix(PennDOT_LLAsubSegments_cellArray,-1);

NewDataFileName = 'PennDOT_LLAsubSegment_coordinates';
NewDataFilePath = fullfile(pwd,'LargeData',cat(2,NewDataFileName,'.mat'));

% Save file
save(NewDataFilePath,'PennDOT_LLAsubSegments_cellArray', 'PennDOT_LLAsubSegments_matrix','PennDOT_LLASegments_cellArray', 'PennDOT_LLASegments_matrix');


%% Plot gradients

NewDataFileName = 'PennDOT_LLAsubSegment_coordinates';
NewDataFilePath = fullfile(pwd,'LargeData',cat(2,NewDataFileName,'.mat'));

% Save file
load(NewDataFilePath,'PennDOT_LLAsubSegments_cellArray', 'PennDOT_LLAsubSegments_matrix','PennDOT_LLASegments_cellArray', 'PennDOT_LLASegments_matrix');

Nsegments = size(PennDOT_LLAsubSegments_cellArray,1);
PennDOT_LLAGradientSubSegments_cellArray = PennDOT_LLAsubSegments_cellArray;
% Loop through subsegments filling in gradient. The last point in eachs
% subsegment has an undefined gradient - we just repeat the last point. The
% gradient is calculated by simply taking the numerical derivative.
for ith_cell = 1:Nsegments
    fprintf(1,'Gradient calculation for segment %.0f of %.0f\n',ith_cell,Nsegments);
    thisMatrix = PennDOT_LLAsubSegments_cellArray{ith_cell,1};
    altitudes = thisMatrix(:,3);

    deltaStation = 1.0; % This is the distance between substation points. Units are meters
    gradient = diff(altitudes)/deltaStation;
    fullGradient = [gradient; gradient(end)];
    Npoints = size(fullGradient,1);

    % For debugging
    if 1==1

        LLIdata = [thisMatrix(:,1:2) altitudes];
        
        debug_fig_num = 47474;
        figure(debug_fig_num); clf;

        subplot(2,2,1);
        geoplot(LLIdata(:,1),LLIdata(:,2),'LineWidth',3);
        geobasemap('satellite');

        subplot(2,2,2);

        % Specify plot style
        clear plotFormat
        plotFormat.LineStyle = 'none';
        plotFormat.LineWidth = 3;
        plotFormat.Marker = '.';
        plotFormat.MarkerSize = 5;
        colorMapString = 'turbo';

        % Reduce the colormap
        Ncolors = 40;
        colorMapMatrix = colormap(colorMapString);
        reducedColorMap = fcn_plotRoad_reduceColorMap(colorMapMatrix, Ncolors, -1);

        % % Specify the sizes (must be same size as reducedColorMap)
        % markerSizeMatrix = 2*(1:Ncolors)';
        % plotFormat.MarkerSize = markerSizeMatrix;



        setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE',sprintf('%.8',mean(LLIdata(:,1))));
        setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE',sprintf('%.8',mean(LLIdata(:,2))));
        setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE',sprintf('%.3',mean(LLIdata(:,3))));


        [h_plot, indiciesInEachPlot]  = fcn_plotRoad_plotLLI(LLIdata, (plotFormat),  (reducedColorMap), (debug_fig_num));
        % set(gca,'MapCenter', [40.864567288895223 -77.830697913696483], 'ZoomLevel',19.5);
        % title(sprintf('Example %.0d: showing use of a complex plotFormat',figNum), 'Interpreter','none');


        plot((1:Npoints)',altitudes,'k.-','MarkerSize',1,'LineWidth',1);
        subplot(2,2,3);
        plot((1:Npoints)',altitudes,'k.-','MarkerSize',1,'LineWidth',1);
        subplot(2,2,4);
        plot((1:Npoints)',fullGradient,'k.-','MarkerSize',1,'LineWidth',1);
    end
    
    newMatrix = [thisMatrix(:,1:end-1) fullGradient thisMatrix(:,end)];
    PennDOT_LLAGradientSubSegments_cellArray{ith_cell,1} = newMatrix;

end
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

%% TEST case: show query using PennDOT data
figNum = 20001;
titleString = sprintf('TEST case: show query using PennDOT data');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end


%%%%%%%%%%%%%
% Load PennDOT data
PennDOT_LLCoordinatesFile = fullfile(pwd,'Data','PennDOT_LLcoordinates.mat');

matlabFileObject = matfile(PennDOT_LLCoordinatesFile);
vars = who(matlabFileObject);
expectedVariables = {'PennDOT_LLSegments_cellArray', 'PennDOT_LLSegments_matrix', 'usableTableRows'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, PennDOT_LLCoordinatesFile);
    end
end

%%%%%%%%%%%%%
% Define query. In this case, using first 8 segments of PennDOT points
% Around 100 points, including NaNs 
LLdata = PennDOT_LLSegments_matrix(1:108,1:2);

queryLatLon = LLdata(:,1:2);
requiredStrings = [];
mergeMethod = [];
localRootFolder = []; 


[queriedElevationsInMeters] = ...
	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
(requiredStrings), (mergeMethod), (localRootFolder), (figNum));


% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% Check variable sizes
assert(isequal(size(queriedElevationsInMeters),size(LLdata(:,1))));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

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
[limitsLatLon, limitsFt] = fcn_DEMImport_queryElevations(zipFile, -2);

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


%% TEST case: Test with points on edge of tile (throws bugs)
figNum = 20003;
titleString = sprintf('TEST case: Test with points on edge of tile (throws bugs)');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {'FtLimits', 'LatLonLimits', 'zipPaths'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(thisExpectedVariable);', thisExpectedVariable);
        eval(commandString);
    else
        warning('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end
end

%%%%%%%%%%%%%
% Define query. In this case, using LTI test-track points
LLAdata = 10^2*[ ...
    0.408623058681026  -0.778365273044571   3.324661031806739
    0.408625826820178  -0.778339477029224   3.331887887573579
    0.408642921349303  -0.778309797211076   3.342002831128628
    0.408652478825565  -0.778305407027021   3.352010458840883
    0.408658264449956  -0.778313133224125   3.362028990680672
    0.408657166946469  -0.778325351582776   3.371905482598103
    0.408655973552879  -0.778330780725765   3.371955903949584
    0.408651149227589  -0.778353022705807   3.361830705141319
    0.408648709961346  -0.778363176280454   3.351862416971704
    0.408642186189148  -0.778372341008792   3.341821632205509
    0.408635182471537  -0.778374202210605   3.331882742721607
    0.408625977026710  -0.778369593792802   3.322871838456281 ];

queryLatLon = LLAdata(:,1:2);
requiredStrings = [];
mergeMethod = [];

% This folder is where the PASDA zip files will be stored locally
localRootFolder = 'G:\GitHubMirror\IVSG\FieldDataCollection\RoadSegments\DEMImport\LargeData\';



[queriedElevationsInMeters] = ...
	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
(requiredStrings), (mergeMethod), (localRootFolder), (figNum));


sgtitle(titleString, 'Interpreter','none');


% Geoid-corrected truth values for comparison
geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
trueAltitude_InMeters = LLAdata(:,3);

% Difference in meters
difference_InMeters = queriedElevationsInMeters - trueAltitude_InMeters;


% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% Check variable sizes
assert(isequal(size(queriedElevationsInMeters),size(trueAltitude_InMeters)));

% Check variable values
assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

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
limitsLatLon = fcn_DEMImport_queryElevations(zipFile, []);

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
limitsLatLon = fcn_DEMImport_queryElevations(zipFile, (-1));

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
	limitsLatLon = fcn_DEMImport_queryElevations(zipFile, ([]));
end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations
	% Call the function
	limitsLatLon = fcn_DEMImport_queryElevations(zipFile, (-1));
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
