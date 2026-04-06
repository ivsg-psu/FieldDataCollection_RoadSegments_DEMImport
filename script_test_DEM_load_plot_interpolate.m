%% script_test_DEM_load_plot_interpolate.m

%% Load some data
figNum = 9999333;
fcn_plotRoad_plotLL([],[],figNum);
set(gca,'MapCenter',[41.2545 -78.0122], 'ZoomLevel', 6.875); % Entire state

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

% Call a function to extract limits from Zip file AND not delete the zip
% results (the -2 option)
[limitsLatLon, limitsFt] = fcn_DEMImport_extractLimitsFromZipFile(zipFile, -2);



% Load the file
tmpFolder = fullfile(pwd,'TempExtract');
DEM_TIFF_filename = fullfile(tmpFolder,'21001790PAN_dem.tif');

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
