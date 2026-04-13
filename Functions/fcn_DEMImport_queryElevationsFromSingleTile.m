function [elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, varargin)
%% fcn_DEMImport_querySingleTile
%
% This function uses a single LOCAL DEM tile to interpolate elevations at
% the input query lat/lon points. This function assumes the zip file
% already exists locally.
%
% FORMAT:
%
%     [elevationsInMeters, insideTileFlag, limitsLatLon] = fcn_DEMImport_queryElevationsFromSingleTile(localZipFilePath, queryLatLon, (figNum));
%
% INPUTS:
% 
%   localZipFile: full local path to one DEM zip file
% 
%   queryLatLon: N x 2 numeric array [lat lon]
%
% OUTPUTS:
% 
%   elevationsInMeters: Elevation at queryLatLon in meters (N x 1) matrix
% 
%   insideTileFlag: Boolean matrix (N x 1) logical matrix
% 
%   limitsLatLon: 1 x 4 matrix [lat_min lat_max lon_min lon_max]
% 
%   (OPTIONAL INPUTS)
% 
%      figNum: a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script:
%     script_test_fcn_DEMImport_queryElevationsFromSingleTile for a full
%     test suite.
%
% This function was written on 2026_04_08 by Aneesh Batchu
% Questions or comments? abb6486@psu.edu or sbrennan@psu.edu

% REVISION HISTORY:
% 
% 2026_04_08 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_queryElevationsFromSingleTile
%   % * Wrote this code originally
% 
% 2026_04_10 by Sean Brennan, sbrennan@psu.edu
% - In fcn_DEMImport_queryElevationsFromSingleTile
%   % * Fixed bug where reference_latitude, etc were not defined inside
%   %   % plotting function
% 
% 2026_04_13 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_DEMImport_querySingleTile
%   % * Added a helper function fcn_INTERNAL_determineProjectedCRS to
%   %   % determine projected CRS (coordinate reference system) for a PASDA DEM
%   %   % tile.

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 3; % The largest Number of argument inputs to the function
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
        narginchk(2,MAX_NARGIN);
        
        % Check queryLatLon input
        fcn_DebugTools_checkInputsToFunctions(queryLatLon, '2column_of_numbers')
        
        % Check localZipFilePath
        if ~exist(localZipFilePath,'file')
            error('Local DEM zip file does not exist:\n%s', localZipFilePath);
        end
    end
end

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

% Extract limits and unzip results without deleting extracted contents
[limitsLatLon, ~] = fcn_DEMImport_extractLimitsFromZipFile(localZipFilePath, -2);

if 1==0
    clear plotFormat
    plotFormat.Color = [1 1 0];
    plotFormat.Marker = '.';
    plotFormat.MarkerSize = 10;
    plotFormat.LineStyle = 'none';
    plotFormat.LineWidth = 3;

    figNum = 7789;

    fcn_plotRoad_plotLL((queryLatLon), (plotFormat), (figNum));
    
    clear plotFormat
	plotFormat.Color = [0.5 0.5 1];
	plotFormat.Marker = '.';
	plotFormat.MarkerSize = 10;
	plotFormat.LineStyle = '-';
	plotFormat.LineWidth = 2;

	fcn_DEMImport_plotLatLonLimits(limitsLatLon, (plotFormat), (figNum));

end

% Build tif filename from local zip name
[~, zipNameNoExt, ~] = fileparts(localZipFilePath);
tmpFolder = fullfile(pwd,'TempExtract');
tifFileName = [zipNameNoExt '.tif'];
DEM_TIFF_filename = fullfile(tmpFolder, tifFileName);

if ~exist(DEM_TIFF_filename,'file')
    error('Expected extracted DEM tif not found:\n%s', DEM_TIFF_filename);
end

% Read DEM (GeoTIFF)
[Z, Rmap] = readgeoraster(DEM_TIFF_filename);
Z = double(Z);

% handle no-data if present
if isfield(Rmap,'MissingDataIndicator')
    Z(Z==Rmap.MissingDataIndicator) = NaN;
end

% Uncomment this to getinfo of the following

% gtinfo = geotiffinfo(DEM_TIFF_filename);
% 
% disp('GeoTIFF info')
% disp(gtinfo)
% 
% disp('GeoTIFF Codes')
% disp(gtinfo.GeoTIFFCodes)
% 
% disp('GeoTIFF Tags')
% disp(gtinfo.GeoTIFFTags)
% 
% disp('Spatial Reference')
% disp(gtinfo.SpatialRef)

% % DEM metadata shows: (Google: EPSG 2271) - from getinfo
% % NAD83 / Pennsylvania North
% % State Plane zone 3701
% % US survey feet
% projCRS = projcrs(2271);  % NAD83 / Pennsylvania North (ftUS)

% Read GeoTIFF metadata and determine the correct projected CRS
gtinfo = geotiffinfo(DEM_TIFF_filename);
projCRS = fcn_INTERNAL_determineProjectedCRS(gtinfo);


N = size(queryLatLon,1);
elevationsInFeet = nan(N,1);
elevationsInMeters = nan(N,1);
insideTileFlag = false(N,1);

for ith_queryPoint = 1:N
    queryLat = queryLatLon(ith_queryPoint,1);
    queryLon = queryLatLon(ith_queryPoint,2);

    % Convert lat/lon to projected DEM coordinates
    [xQueryProj, yQueryProj] = projfwd(projCRS, queryLat, queryLon);

    % % Check projected bounds directly against raster reference
    % insideX = xQueryProj >= Rmap.XWorldLimits(1) && xQueryProj <= Rmap.XWorldLimits(2);
    % insideY = yQueryProj >= Rmap.YWorldLimits(1) && yQueryProj <= Rmap.YWorldLimits(2);

    % Convert projected world coordinates to intrinsic raster coordinates
    [xIntrinsic, yIntrinsic] = worldToIntrinsic(Rmap, xQueryProj, yQueryProj);

    % Check bounds in intrinsic coordinates rather than world limits
    insideX = xIntrinsic >= Rmap.XIntrinsicLimits(1) && xIntrinsic <= Rmap.XIntrinsicLimits(2);
    insideY = yIntrinsic >= Rmap.YIntrinsicLimits(1) && yIntrinsic <= Rmap.YIntrinsicLimits(2);
   

    if insideX && insideY
        insideTileFlag(ith_queryPoint) = true;

        % % Convert projected world coords to intrinsic raster coords
        % [xIntrinsic, yIntrinsic] = worldToIntrinsic(Rmap, xQueryProj, yQueryProj);

        % Interpolate directly on DEM matrix
        elevationsInFeet(ith_queryPoint) = interp2(Z, xIntrinsic, yIntrinsic, 'linear');
        elevationsInMeters(ith_queryPoint) = elevationsInFeet(ith_queryPoint) / 3.2808398950131;
    else
        if 1==0
            fprintf(1,'Query point outside DEM bounds: %.8f, %.8f\n', queryLat, queryLon);
        end
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
if flag_do_plots

    % Define GPS Object
    reference_latitude = 40.86368573;
    reference_longitude = -77.83592832;
    reference_altitude = 344.189;

    gps_object = GPS(reference_latitude, reference_longitude, reference_altitude);

    [Epatch, Npatch, Upatch, trackDEM_ENU] = fcn_INTERNAL_plotQueryPatchAndPoints(Z, Rmap, projCRS, queryLatLon, elevationsInMeters, gps_object);

    % Plot 3D DEM patch with tracks
    figure(figNum)

    surf(Epatch, Npatch, Upatch, Upatch, 'EdgeColor', 'none');
    hold on;
    plot3(trackDEM_ENU(:,1), trackDEM_ENU(:,2), trackDEM_ENU(:,3), ...
        'g.-', 'LineWidth', 2, 'MarkerSize', 18);

    % axis equal;
    xlabel('East [m]');
    ylabel('North [m]');
    zlabel('Up [m]');
    % title('Local DEM patch with query points and elevation');
    grid on;
    % axis equal;
    view(3);
    camlight headlight
    lighting phong
    colorbar;
    legend('DEM patch','DEM-sampled points','Location','best');

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

function [Epatch, Npatch, Upatch, trackDEM_ENU] = fcn_INTERNAL_plotQueryPatchAndPoints(Z, Rmap, projCRS, queryLatLon, elevationsInMeters, gps_object)

reference_latitude = 40.86368573;
reference_longitude = -77.83592832;
reference_altitude = 344.189;

% Build projected world coordinates using projected raster reference
% when plotting- This keeps the corect orientation of the DEM patch
[nRows, nCols] = size(Z);
[cols, rows] = meshgrid(1:nCols, 1:nRows);

% Intrinsic: raster's own internal coordinates
% World: Projected map coordinates from Rmap (In this case: Pennsylvania
% State Plane, US survey feet)
% Intrinsic to projected world coordinates
[xWorld, yWorld] = intrinsicToWorld(Rmap, cols, rows);

% Projected world coordinates to geographic coordinates (LL)
[latGrid, lonGrid] = projinv(projCRS, xWorld, yWorld);

% Bounding box around query points with small margin
margin_deg = 0.0004;
lat_min_local = min(queryLatLon(:,1)) - margin_deg;
lat_max_local = max(queryLatLon(:,1)) + margin_deg;
lon_min_local = min(queryLatLon(:,2)) - margin_deg;
lon_max_local = max(queryLatLon(:,2)) + margin_deg;

% Find DEM cells inside local patch (DEM tile)
patchMask = latGrid >= lat_min_local & latGrid <= lat_max_local & ...
    lonGrid >= lon_min_local & lonGrid <= lon_max_local;

if ~any(patchMask(:))
    warning('No DEM cells found in local patch for plotting.');
    return;
end

% Bounding box indices of the selected patch
[row_idx, col_idx] = find(patchMask);
row_min = min(row_idx);
row_max = max(row_idx);
col_min = min(col_idx);
col_max = max(col_idx);

% Extract local DEM patch from the original DEM tile
latPatch = latGrid(row_min:row_max, col_min:col_max);
lonPatch = lonGrid(row_min:row_max, col_min:col_max);
Zpatch_ft = Z(row_min:row_max, col_min:col_max);

% Convert DEM altitude from feet to meters
Zpatch_m = Zpatch_ft / 3.2808398950131;

% Remove invalid cells
goodPatch = ~isnan(latPatch) & ~isnan(lonPatch) & ~isnan(Zpatch_ft);


% Convert local DEM patch to ENU
DEMpatch_LLA = [latPatch(goodPatch), lonPatch(goodPatch), Zpatch_m(goodPatch)];
DEMpatch_ENU = gps_object.WGSLLA2ENU( ...
    DEMpatch_LLA(:,1), DEMpatch_LLA(:,2), DEMpatch_LLA(:,3), ...
    reference_latitude, reference_longitude, reference_altitude);

% Separate patch grids for plotting
Epatch = nan(size(latPatch));
Npatch = nan(size(latPatch));
Upatch = nan(size(latPatch));

Epatch(goodPatch) = DEMpatch_ENU(:,1);
Npatch(goodPatch) = DEMpatch_ENU(:,2);
Upatch(goodPatch) = DEMpatch_ENU(:,3);

%% Convert DEM-sampled track to ENU
trackDEM_ENU = gps_object.WGSLLA2ENU( ...
    queryLatLon(:,1), queryLatLon(:,2), elevationsInMeters, ...
    reference_latitude, reference_longitude, reference_altitude);
end

%% fcn_INTERNAL_determineProjectedCRS

function projCRS = fcn_INTERNAL_determineProjectedCRS(gtinfo)
% Determines the correct feet-based projected CRS for a PASDA DEM tile.
%
% This helper assumes the DEM tiles should be queried in Pennsylvania State
% Plane US survey feet coordinates, and only determines whether the tile
% is in the North or South zone.

if ~isfield(gtinfo,'GeoTIFFTags') || ~isfield(gtinfo.GeoTIFFTags,'GeoAsciiParamsTag')
    error('GeoAsciiParamsTag not found in GeoTIFF metadata.');
end

geoAsciiText = lower(string(gtinfo.GeoTIFFTags.GeoAsciiParamsTag));

% Check for Pennsylvania North / FIPS 3701
if contains(geoAsciiText, "pennsylvania_north") && ...
   contains(geoAsciiText, "3701")

    projCRS = projcrs(2271);   % NAD83 / Pennsylvania North (ftUS)

% Check for Pennsylvania South / FIPS 3702
elseif contains(geoAsciiText, "pennsylvania_south") && ...
       contains(geoAsciiText, "3702")

    projCRS = projcrs(2272);   % NAD83 / Pennsylvania South (ftUS)

else
    error(['Unable to determine Pennsylvania State Plane zone from ' ...
           'GeoAsciiParamsTag.']);
end
end