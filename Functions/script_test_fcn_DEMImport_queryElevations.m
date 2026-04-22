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
%
% 2026_04_20 by Sean Brennan, sbrennan@psu.edu
%  - In script_test_fcn_DEMImport_queryElevations
%    % * Fixed bug with variable loading not working

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
expectedVariables = {...
    'FtLimits',...
    'LatLonLimits',...
    'zipPaths'...
    };


for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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


% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% % Check variable sizes
% assert(isequal(size(queriedElevationsInMeters),size(trueAltitude_InMeters)));
% 
% % Check variable values
% 
% % Geoid-corrected truth values for comparison
% geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
% LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
% trueAltitude_InMeters = LLAdata(:,3);
% 
% % Difference in meters
% difference_InMeters = queriedElevationsInMeters - trueAltitude_InMeters;
% 
% assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

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
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
end

% The following does not check variables but is more clear (does same thing as above for loop)
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

warning('backtrace','on');
warning('The following command may take a LONG time (hours). The user must uncomment to continue');
if 1==0
    % Run query
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
end

%% Query using PennDOT subsegment data
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
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
end


%%%%%%%%%%%%%
% Define query. In this case, using PennDOT subsegments

flag_loadDataFilesWhenPossible = 1;

% Load the PennDOT LL data
PreviousDataFileName = 'PennDOT_Subsegments_ECEF';
PreviouseDataFilePath = fullfile(pwd,'LargeData',cat(2,PreviousDataFileName,'.mat'));

matlabFileObject = matfile(PreviouseDataFilePath);
vars = who(matlabFileObject);
expectedVariables = {...
    'PennDOT_XYZSegments_cellArray', ...
    'PennDOT_XYZsubSegments_cellArray', ...
    'PennDOT_LLSegments_cellArray', ...
    'PennDOT_LLsubSegments_cellArray'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
end


if 1==0
    if flag_loadDataFilesWhenPossible && exist(PreviouseDataFilePath,'file')
    	load(PreviouseDataFilePath,'PennDOT_LLsubSegments_cellArray');
    else
    	error('Unable to load file: \n\t%s\nNeed to obtain this from the PennDOTSHP repo!',PreviouseDataFilePath);
    end
end

%%%%%
%  Extract elevation?

warning('backtrace','on');
warning('The following code can take a LONG time to run (1 hour or more). User must manually uncomment to continue.')

if 1==0
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
        thisMatrix = PennDOT_LLsubSegments_cellArray{ith_cell,1};

        if 1==0
            debug_figNum = 11122;
            figure(debug_figNum); 
            clf;

            originalPennDOTData = PennDOT_LLSegments_cellArray{ith_cell};
            geoplot(originalPennDOTData(:,1),originalPennDOTData(:,2),'LineWidth',5, 'MarkerSize',30);
            hold on;
            geoplot(thisMatrix(:,1),thisMatrix(:,2),'.','MarkerSize',10);
            geobasemap('satellite');
            title('LL data from PennDOT segments and subsegments')
            drawnow
        end


        [queriedElevationsInMeters] = ...
        	fcn_DEMImport_queryElevations(thisMatrix(:,1:2), LatLonLimits, zipPaths,...
            (requiredStrings), (mergeMethod), (localRootFolder), (figNum));

        newMatrix = [thisMatrix(:,1:2) queriedElevationsInMeters thisMatrix(:,3:end)];
        PennDOT_LLAsubSegments_cellArray{ith_cell,1} = newMatrix;

    end

    %%%%%%%%%%%%%%%%%%%
    % Save results
    PennDOT_LLAsubSegments_matrix = fcn_DebugTools_stackCellArrayIntoMatrix(PennDOT_LLAsubSegments_cellArray,-1);

    NewDataFileName = 'PennDOT_LLAsubSegment_coordinates';
    NewDataFilePath = fullfile(pwd,'LargeData',cat(2,NewDataFileName,'.mat'));

    % Save file
    save(NewDataFilePath,'PennDOT_LLAsubSegments_cellArray', 'PennDOT_LLAsubSegments_matrix','PennDOT_LLASegments_cellArray', 'PennDOT_LLASegments_matrix');
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
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
end


%%%%%%%%%%%%%
% Load PennDOT data
PennDOT_LLCoordinatesFile = fullfile(pwd,'Data','PennDOT_LLcoordinates.mat');

matlabFileObject = matfile(PennDOT_LLCoordinatesFile);
vars = who(matlabFileObject);
expectedVariables = {'PennDOT_LLSegments_cellArray', 'PennDOT_LLSegments_matrix', 'usableTableRows'};

for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {...
    'FtLimits',...
    'LatLonLimits',...
    'zipPaths'...
    };


for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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
(requiredStrings), (mergeMethod), (localRootFolder), ([]));

% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% % Check variable sizes
% assert(isequal(size(queriedElevationsInMeters),size(trueAltitude_InMeters)));
% 
% % Check variable values
% 
% % Geoid-corrected truth values for comparison
% geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
% LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
% trueAltitude_InMeters = LLAdata(:,3);
% 
% % Difference in meters
% difference_InMeters = queriedElevationsInMeters - trueAltitude_InMeters;
% 
% assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {...
    'FtLimits',...
    'LatLonLimits',...
    'zipPaths'...
    };


for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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

% Call function
[queriedElevationsInMeters] = ...
	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
(requiredStrings), (mergeMethod), (localRootFolder), (-1));

% Check variable types
assert(isnumeric(queriedElevationsInMeters));

% % Check variable sizes
% assert(isequal(size(queriedElevationsInMeters),size(trueAltitude_InMeters)));
% 
% % Check variable values
% 
% % Geoid-corrected truth values for comparison
% geoidHeight = egm96geoid(LLAdata(:,1), LLAdata(:,2));
% LLAdata(:,3) = LLAdata(:,3) - geoidHeight;
% trueAltitude_InMeters = LLAdata(:,3);
% 
% % Difference in meters
% difference_InMeters = queriedElevationsInMeters - trueAltitude_InMeters;
% 
% assert(all(abs(difference_InMeters(1:9,:)) < 1.0));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

%%%%%%%%%%%%%
% Load statewide DEM metadata
pamap_lidar_limitsFile = fullfile(pwd,'Data','latlonLimits_pamap_lidar.mat');

matlabFileObject = matfile(pamap_lidar_limitsFile);
vars = who(matlabFileObject);
expectedVariables = {...
    'FtLimits',...
    'LatLonLimits',...
    'zipPaths'...
    };


for ith_expectedVariable = 1:length(expectedVariables)
    thisExpectedVariable = expectedVariables{ith_expectedVariable};
    clear(thisExpectedVariable);

    if ismember(thisExpectedVariable, vars)
        commandString = sprintf('%s = matlabFileObject.(''%s'');', thisExpectedVariable, thisExpectedVariable);
        eval(commandString);
    else
        error('Variable %s not found in the limits file: %s.', ...
            thisExpectedVariable, pamap_lidar_limitsFile);
    end

    assert(exist(thisExpectedVariable,'var'));
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

Niterations = 2;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

    % Call function
    [queriedElevationsInMeters] = ...
    	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
        (requiredStrings), (mergeMethod), (localRootFolder), ([]));
end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations

    % Call function
    [queriedElevationsInMeters] = ...
    	fcn_DEMImport_queryElevations(queryLatLon, LatLonLimits, zipPaths,...
        (requiredStrings), (mergeMethod), (localRootFolder), (-1));
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
