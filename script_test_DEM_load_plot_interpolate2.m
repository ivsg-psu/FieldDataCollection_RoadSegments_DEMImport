%% script_test_DEM_load_plot_interpolate2.m


% REVISION HISTORY:
% 
% 2026_04_07 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_DEM_load_plot_interpolate2
%   % * Wrote this code originally


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

%% Uncomment this to getinfo of the following

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

%% Build DEM cell-center coordinates using projected raster reference - This keeps the corect orientation of the DEM patch
[nRows, nCols] = size(Z);
[cols, rows] = meshgrid(1:nCols, 1:nRows);

% Intrinsic: raster's own internal coordinates
% World: Projected map coordinates from Rmap (In this case: Pennsylvania
% State Plane, US survey feet)
% Intrinsic to projected world coordinates
[xWorld, yWorld] = intrinsicToWorld(Rmap, cols, rows);

% DEM metadata shows: (Google: EPSG 2271) - from getinfo
% NAD83 / Pennsylvania North
% State Plane zone 3701
% US survey feet
projCRS = projcrs(2271);  % NAD83 / Pennsylvania North (ftUS)

% Projected world coordinates to geographic coordinates (LL)
[latGrid, lonGrid] = projinv(projCRS, xWorld, yWorld);

%% Define GPS object

reference_latitude = 40.86368573;
reference_longitude = -77.83592832;
reference_altitude = 344.189;

gps_object = GPS(reference_latitude, reference_longitude, reference_altitude);

%% Show how to use the results for interpolation

latlim = limitsLatLon(1,1:2);
lonlim = limitsLatLon(1,3:4);

% Interpolation example (choose middle point)
queryLat = mean(latlim);
queryLon = mean(lonlim);

% Convert query lat/lon to projected DEM coordinates (US survey feet)
[xQueryProj, yQueryProj] = projfwd(projCRS, queryLat, queryLon);

% Projected world to intrinsic raster coordinates
[xIntrinsic, yIntrinsic] = worldToIntrinsic(Rmap, xQueryProj, yQueryProj);

% Interpolate directly on DEM matrix
altitudeInFeet = interp2(Z, xIntrinsic, yIntrinsic, 'linear');
fprintf(1,'Altitude at query: %.2f feet\n',altitudeInFeet);

altitudeInMeters  = altitudeInFeet / 3.2808398950131;
fprintf(1,'Altitude at query: %.2f meters\n',altitudeInMeters);

%% Define track points
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

LLdata = LLAdata(:,1:2);
trueAltitude_InMeters = LLAdata(:,3);

%% Plot track points in lat/lon
clear plotFormat
plotFormat.Color = [1 1 0];
plotFormat.Marker = '.';
plotFormat.MarkerSize = 10;
plotFormat.LineStyle = 'none';
plotFormat.LineWidth = 3;

figNum = 9876;
fcn_plotRoad_plotLL(LLdata, plotFormat, figNum);

%% Query DEM altitudes at track points
% IMPORTANT:
% Query in the DEM's native projected coordinates, not with geointerp on a
% reconstructed geographic reference.

N = size(LLdata,1);

DEM_altitudeInFeet = nan(N,1);
DEM_altitudeInMeters  = nan(N,1);
difference_InMeters    = nan(N,1);
insideTileFlag  = false(N,1);

for ith_point = 1:N
    queryLat = LLAdata(ith_point,1);
    queryLon = LLAdata(ith_point,2);

    % Convert query lat/lon to projected DEM coordinates (US survey feet)
    [xQueryProj, yQueryProj] = projfwd(projCRS, queryLat, queryLon);

    % Check projected bounds directly against raster reference
    insideX = xQueryProj >= Rmap.XWorldLimits(1) && xQueryProj <= Rmap.XWorldLimits(2);
    insideY = yQueryProj >= Rmap.YWorldLimits(1) && yQueryProj <= Rmap.YWorldLimits(2);

    if insideX && insideY
        insideTileFlag(ith_point) = true;

        % Projected world to intrinsic raster coordinates
        [xIntrinsic, yIntrinsic] = worldToIntrinsic(Rmap, xQueryProj, yQueryProj);

        % Interpolate directly on DEM matrix
        altitudeInFeet = interp2(Z, xIntrinsic, yIntrinsic, 'linear');

        DEM_altitudeInFeet(ith_point,1) = altitudeInFeet;
        DEM_altitudeInMeters(ith_point,1)  = altitudeInFeet / 3.2808398950131;

        % Difference in meters
        difference_InMeters(ith_point,1) = DEM_altitudeInMeters(ith_point,1) - trueAltitude_InMeters(ith_point,1);
    else
        fprintf(1,'Track point outside DEM bounds: %.8f, %.8f\n', queryLat, queryLon);
    end
end

%% Print results
fprintf(1,'\n(DEM - True) in meters:\n');
disp(difference_InMeters);

resultsMatrix = [LLdata, trueAltitude_InMeters, DEM_altitudeInMeters, difference_InMeters];

fprintf(1,'Results matrix:\n');
fprintf(1,'   Latitude        Longitude        TrueAlt(m)     DEMAlt(m)      Diff(m)\n');
disp(resultsMatrix);

%% Convert true track to ENU
trackTrue_ENU = gps_object.WGSLLA2ENU( ...
    LLAdata(:,1), LLAdata(:,2), LLAdata(:,3), ...
    reference_latitude, reference_longitude, reference_altitude);

%% Convert DEM-sampled track to ENU
trackDEM_ENU = gps_object.WGSLLA2ENU( ...
    LLAdata(:,1), LLAdata(:,2), DEM_altitudeInMeters, ...
    reference_latitude, reference_longitude, reference_altitude);

%% Extract a local DEM patch around the track

% Small margin around the track in degrees
margin_deg = 0.0004;

% Extract the track LatLon
trackLat = LLAdata(:,1);
trackLon = LLAdata(:,2);

% Bounds of the bounding box
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

%% Plot 3D DEM patch with tracks
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
% axis equal;
view(3);
camlight headlight
lighting phong
colorbar;
legend('DEM patch','True track','DEM-sampled track','Location','best');

%% Plot 3D DEM patch with tracks
figure(10002); clf;
hold on;
plot3(trackTrue_ENU(:,1), trackTrue_ENU(:,2), trackTrue_ENU(:,3), ...
    'g.-', 'LineWidth', 2, 'MarkerSize', 18);
plot3(trackDEM_ENU(:,1), trackDEM_ENU(:,2), trackDEM_ENU(:,3), ...
    'b.-', 'LineWidth', 2, 'MarkerSize', 18);


xlabel('East [m]');
ylabel('North [m]');
zlabel('Up [m]');
grid on;
% axis equal;
view(3);
zlim([-30 30])
legend('True track','DEM-sampled track','Location','best');

%% Plot top view for orientation check
figure(10003); clf;
surf(Epatch, Npatch, Upatch, Upatch, 'EdgeColor', 'none');
hold on;
plot3(trackTrue_ENU(:,1), trackTrue_ENU(:,2), trackTrue_ENU(:,3), ...
    'b.-', 'LineWidth', 2, 'MarkerSize', 18);
plot3(trackDEM_ENU(:,1), trackDEM_ENU(:,2), trackDEM_ENU(:,3), ...
    'g.-', 'LineWidth', 2, 'MarkerSize', 18);

xlabel('East [m]');
ylabel('North [m]');
zlabel('Up [m]');
title('Top view: DEM patch and track');
grid on;
axis equal;
view(2);
colorbar;
legend('DEM patch','True track','DEM-sampled track','Start point','Location','best');



