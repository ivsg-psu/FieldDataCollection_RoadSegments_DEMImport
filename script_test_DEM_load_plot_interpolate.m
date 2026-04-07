%% script_test_DEM_load_plot_interpolate.m

% REVISION HISTORY:
% 
% 2026_04_07 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_DEM_load_plot_interpolate
%   % * Calculated the DEM sampled altitude using the test track points
%   % * Plotted ENU DEM patch along with the DEM sampled points and true
%   %   % test track points


%% Load some data
figNum = 9999333;
fcn_plotRoad_plotLL([],[],figNum);
set(gca,'MapCenter',[41.2545 -78.0122], 'ZoomLevel', 6.875); % Entire state

% thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/21001790PAN_dem.zip';
thisURL = 'https://www.pasda.psu.edu/download/pamap/pamap_lidar/cycle1/DEM/North/2006/20000000/26001940PAN_dem.zip';


% Zip file name
% fileName = '26001940PAN_dem.zip'; 
fileName = '26001940PAN_dem.zip'; 
tifFileName = '26001940PAN_dem.tif'; 

% Define a file name and directory to save results
lasDirectory = fullfile(pwd,'LargeData','zipTestFiles_LAS');
fcn_DebugTools_makeDirectory(lasDirectory);
% zipFile = fullfile(lasDirectory,'21001790PAN_dem.zip');
zipFile = fullfile(lasDirectory,fileName);
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

% Call a function to extract limits from Zip file AND not delete the zip
% results (the -2 option)
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLimitsFromZipFile(zipFile, -2);


% Load the file 
tmpFolder = fullfile(pwd,'TempExtract');
% DEM_TIFF_filename = fullfile(tmpFolder,'21001790PAN_dem.tif');
DEM_TIFF_filename = fullfile(tmpFolder,tifFileName);

% Read DEM (GeoTIFF)
[Z, Rmap] = readgeoraster(DEM_TIFF_filename);   % Z = elevation matrix, R = geographicRasterReference
Z = double(Z);                           % ensure numeric

if isfield(Rmap,'MissingDataIndicator')
    Z(Z==Rmap.MissingDataIndicator) = NaN;      % handle no-data if present
end

%% Fix the conversion
% The default representation is in meters for x and y. We need to switch
% this to LLA

%  Conversion from MapCellsReference to GeographicCellsReference
% This section converts a MapCellsReference (projected/map coordinates) to
% a GeographicCellsReference by (1) mapping the raster intrinsic
% coordinates to projected world coordinates, (2) transforming those world
% coordinates to geographic latitude/longitude, and (3) creating a
% geographic cells reference from the geographic limits and raster size.
% Below is a concise, robust workflow and example.
% 
% Key caveat:
% This conversion assumes the projected grid maps to a regularly spaced
% geographic grid (no strong rotation/affine distortion from the
% projection). If the projection produces irregular lat/lon spacing (rare
% but possible for large extents), consider using a
% GeographicPostingsReference or resampling the raste

% Rmap: MapCellsReference (map.rasterref.MapCellsReference) from readgeoraster or other source
% Z: corresponding raster (DEM) matrix
% Output: Rgeo (GeographicCellsReference) and lat/lon grids for the sampled cells

% Create intrinsic grid (columns = x intrinsic, rows = y intrinsic)
[nRows, nCols] = size(Z);

latlim = limitsLatLon(1,1:2);
lonlim = limitsLatLon(1,3:4);


% Create GeographicCellsReference matching raster size and orientation.
% Preserve ColumnsStartFrom and RowsStartFrom from original if relevant.
rowsFrom = Rmap.RowsStartFrom;     % e.g., 'north' or 'south'
colsFrom = Rmap.ColumnsStartFrom;  % e.g., 'west' or 'east'

Rgeo = georefcells(latlim, lonlim, [nRows, nCols], ...
    'ColumnsStartFrom', colsFrom, 'RowsStartFrom', rowsFrom);

% Now we can use Rgeo with geographic plotting/interpolation functions

%% Create a plot of the results
% Create intrinsic grid (column, row indices) and convert to lat/lon
[cols, rows] = meshgrid(1:size(Z,2), 1:size(Z,1));
[latGrid, lonGrid] = intrinsicToGeographic(Rgeo, rows, cols);

% Optional: subsample for speed (every k-th pixel)
k = 4;                    % increase k to speed up / reduce resolution
latG = latGrid(1:k:end, 1:k:end);
lonG = lonGrid(1:k:end, 1:k:end);
ZG   = Z(1:k:end, 1:k:end);

% 3D surface plot
figure
surf(lonG, fliplr(latG), ZG, ZG, "EdgeColor","none")   % color by elevation

% axis equal
xlabel("Longitude"); ylabel("Latitude"); zlabel("Elevation (m)")
demcmap(ZG)                % appropriate colormap for elevations
colorbar
% view(3)
camlight headlight
lighting phong
view([0 0 1]);

%% Show how to use the results for interpolation
% Interpolation example (choose middle point)
queryLat = mean(latlim);
queryLon = mean(lonlim);

% Interpolate elevations at lat/lon (bilinear)
altitudeInFeet = geointerp(Z, Rgeo, queryLat, queryLon, 'linear');   % alt in same units as DEM (typically meters)
fprintf(1,'Altitude at query: %.2f feet\n',altitudeInFeet);

altitudeInMeters = altitudeInFeet/3.2808398950131;
fprintf(1,'Altitude at query: %.2f meters\n',altitudeInMeters);

%% Point at the test track (base station)

reference_latitude = 40.86368573;
reference_longitude = -77.83592832;
% reference_altitude = 344.189;

queryLat = reference_latitude;
queryLon = reference_longitude;

insideLat = queryLat >= min(latlim) && queryLat <= max(latlim);
insideLon = queryLon >= min(lonlim) && queryLon <= max(lonlim);

if insideLat && insideLon
    disp('Test track is inside DEM tile');
    altitudeInFeet = geointerp(Z, Rgeo, queryLat, queryLon, 'linear');
    fprintf(1,'Altitude at test track: %.3f\n', altitudeInFeet);

    altitudeInMeters = altitudeInFeet/3.2808398950131;
    fprintf(1,'Altitude at test track: %.2f meters\n',altitudeInMeters);
else
    disp('Test track is outside DEM tile');
end

%% Points at the test track

LLAdata = 10^2*[0.408626288465135  -0.778369929981826   3.320046669623370
0.408626232120124  -0.778369867300047   3.319514415707900
0.408626169465029  -0.778369807456409   3.319508760765890
0.408626108967975  -0.778369745017785   3.319594207821479
0.408626052338119  -0.778369678394259   3.319451289668891
0.408625992074273  -0.778369616828079   3.319743399452465
0.408625937580828  -0.778369551072179   3.319710731680451
0.408625878443826  -0.778369489564534   3.319821761059105
0.408625822837575  -0.778369423682883   3.319996900062819
0.408625766990298  -0.778369357002440   3.319955558885872
0.408625707402555  -0.778369295847464   3.320133264359051];

% LLdata = latitude, longitude
LLdata = LLAdata(:,1:2);

clear plotFormat
plotFormat.Color = [1 1 0];
plotFormat.Marker = '.';
plotFormat.MarkerSize = 10;
plotFormat.LineStyle = 'none';
plotFormat.LineWidth = 3;

figNum = 124315;

fcn_plotRoad_plotLL((LLdata), (plotFormat), (figNum));

% True altitude from LLA data 
trueAltitude_m = LLAdata(:,3);

% Number of query points
N = size(LLdata,1);

% Preallocate results
DEM_altitude_m   = nan(N,1);
difference_m     = nan(N,1);   
insideTileFlag   = false(N,1);

% Loop through all points
for ith_point = 1:N
    queryLat = LLdata(ith_point,1);
    queryLon = LLdata(ith_point,2);

    insideLat = queryLat >= min(latlim) && queryLat <= max(latlim);
    insideLon = queryLon >= min(lonlim) && queryLon <= max(lonlim);

    if insideLat && insideLon
        insideTileFlag(ith_point) = true;

        % DEM interpolation (in feet)
        altitude_query = geointerp(Z, Rgeo, queryLat, queryLon, 'linear');

        % Convert DEM feet to meters
        DEM_altitude_m(ith_point,1) = altitude_query/3.2808398950131;

        % Difference: DEM altitude minus true altitude
        difference_m(ith_point,1) = DEM_altitude_m(ith_point,1) - trueAltitude_m(ith_point,1);
    else
        fprintf(1, 'This test track LatLon is outside DEM tile: %.3f, %.3f\n',queryLat,queryLon);
    end
end

% Print only the differences
fprintf(1,'(DEM - True) in meters:\n');
disp(difference_m);

% Store all results in a separate matrix
resultsMatrix = [LLdata, trueAltitude_m, DEM_altitude_m, difference_m];

% Print the results
fprintf(1, 'Results matrix:\n');
fprintf(1, '   Latitude        Longitude        TrueAlt(m)     DEMAlt(m)      Diff(m)\n');
disp(resultsMatrix);

%% Points at the test track at different locations

LLAdata = 10^2*[  0.408623058681026  -0.778365273044571   3.324661031806739
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
    0.408625977026710  -0.778369593792802   3.322871838456281];

% LLdata = latitude, longitude
LLdata = LLAdata(:,1:2);

clear plotFormat
plotFormat.Color = [1 1 0];
plotFormat.Marker = '.';
plotFormat.MarkerSize = 10;
plotFormat.LineStyle = 'none';
plotFormat.LineWidth = 3;

figNum = 9876;

fcn_plotRoad_plotLL((LLdata), (plotFormat), (figNum));

% True altitude from LLA data 
trueAltitude_m = LLAdata(:,3);

% Number of query points
N = size(LLdata,1);

% Preallocate results
DEM_altitude_m   = nan(N,1);
difference_m     = nan(N,1);   
insideTileFlag   = false(N,1);

% Loop through all points
for ith_point = 1:N
    queryLat = LLdata(ith_point,1);
    queryLon = LLdata(ith_point,2);

    insideLat = queryLat >= min(latlim) && queryLat <= max(latlim);
    insideLon = queryLon >= min(lonlim) && queryLon <= max(lonlim);

    if insideLat && insideLon
        insideTileFlag(ith_point) = true;

        % DEM interpolation (in feet)
        altitude_query = geointerp(Z, Rgeo, queryLat, queryLon, 'linear');

        % Convert DEM feet to meters
        DEM_altitude_m(ith_point,1) = altitude_query/3.2808398950131;

        % Difference: DEM altitude minus true altitude
        difference_m(ith_point,1) = DEM_altitude_m(ith_point,1) - trueAltitude_m(ith_point,1);
    else
        fprintf(1, 'This test track LatLon is outside DEM tile: %.3f, %.3f\n',queryLat,queryLon);
    end
end

% Print only the differences
fprintf(1,'(DEM - True) in meters:\n');
disp(difference_m);

% Store all results in a separate matrix
resultsMatrix = [LLdata, trueAltitude_m, DEM_altitude_m, difference_m];

% Print the results
fprintf(1, 'Results matrix:\n');
fprintf(1, '   Latitude        Longitude        TrueAlt(m)     DEMAlt(m)      Diff(m)\n');
disp(resultsMatrix);

%% Define reference origin for ENU

reference_latitude = 40.86368573;
reference_longitude = -77.83592832;
reference_altitude = 344.189;

gps_object = GPS(reference_latitude, reference_longitude, reference_altitude);

% Small margin around the track in degrees
margin_deg = 0.01;

trackLat = LLAdata(:,1);
trackLon = LLAdata(:,2);

lat_min_local = min(trackLat) - margin_deg;
lat_max_local = max(trackLat) + margin_deg;
lon_min_local = min(trackLon) - margin_deg;
lon_max_local = max(trackLon) + margin_deg;

% Find DEM cells inside local patch (DEM tile)
patchMask = latGrid >= lat_min_local & latGrid <= lat_max_local & ...
            lonGrid >= lon_min_local & lonGrid <= lon_max_local;

if ~any(patchMask(:))
    error('No DEM cells found in local patch. Increase margin_deg.');
end

% Bounding box of the selected patch
[row_idx, col_idx] = find(patchMask);

row_min = min(row_idx);
row_max = max(row_idx);
col_min = min(col_idx);
col_max = max(col_idx);

% Extract local DEM patch from the original DEM tile
latPatch = latGrid(row_min:row_max, col_min:col_max);
lonPatch = lonGrid(row_min:row_max, col_min:col_max);
Zpatch_ft = Z(row_min:row_max, col_min:col_max);

% Remove invalid cells
goodPatch = ~isnan(latPatch) & ~isnan(lonPatch) & ~isnan(Zpatch_ft);

% Convert DEM altitude from feet to meters
Zpatch_m = Zpatch_ft / 3.2808398950131;

% Convert local DEM patch to ENU
DEMpatch_LLA = [latPatch(goodPatch), lonPatch(goodPatch), Zpatch_m(goodPatch)];
DEMpatch_ENU = gps_object.WGSLLA2ENU(DEMpatch_LLA(:,1), DEMpatch_LLA(:,2), DEMpatch_LLA(:,3),...
    reference_latitude, reference_longitude, reference_altitude);


% Separate patch grids for plotting
Epatch = nan(size(latPatch));
Npatch = nan(size(latPatch));
Upatch = nan(size(latPatch));

Epatch(goodPatch) = DEMpatch_ENU(:,1);
Npatch(goodPatch) = DEMpatch_ENU(:,2);
Upatch(goodPatch) = DEMpatch_ENU(:,3);

% Convert true track points to ENU
trackTrue_ENU = gps_object.WGSLLA2ENU( ...
    LLAdata(:,1), LLAdata(:,2), LLAdata(:,3), ...
    reference_latitude, reference_longitude, reference_altitude);

% Convert DEM-sampled track points to ENU
trackDEM_ENU = gps_object.WGSLLA2ENU( ...
    LLAdata(:,1), LLAdata(:,2), DEM_altitude_m, ...
    reference_latitude, reference_longitude, reference_altitude);


%% Plot 3D DEM patch with the sampled and true test track points

figure(10001); clf;
surf(Epatch, Npatch, Upatch, Upatch, 'EdgeColor', 'none');
hold on;
plot3(trackTrue_ENU(:,1), trackTrue_ENU(:,2), trackTrue_ENU(:,3), ...
    'b.-', 'LineWidth', 2, 'MarkerSize', 18);
plot3(trackDEM_ENU(:,1), trackDEM_ENU(:,2), trackDEM_ENU(:,3), ...
    'g.-', 'LineWidth', 2, 'MarkerSize', 18);


xlabel('East [m]');
ylabel('North [m]');
zlabel('Up [m]');
title('Local DEM patch with true track and DEM track');
grid on;
axis equal;
view(3);
camlight headlight;
lighting phong;
colorbar;
legend('DEM patch','True track','DEM-sampled track','Location','best');


%% Plot 3D DEM sampled and true test track points
figure(10002);clf;
hold on;
plot3(points_ENU(:,1), points_ENU(:,2), points_ENU(:,3), ...
    'g.-', 'LineWidth', 2, 'MarkerSize', 18);
plot3(points_EN_DEMAlt(:,1), points_EN_DEMAlt(:,2), points_EN_DEMAlt(:,3), ...
    'b.-', 'LineWidth', 2, 'MarkerSize', 18);

xlabel('East [m]');
ylabel('North [m]');
zlabel('Up [m]');
grid on;
% axis equal;
view(3);
zlim([-30 30])
legend('True track','DEM-sampled track','Location','best');



