


%% Load the file
DEM_TIFF_filename = fullfile(pwd,'Data','25001900PAN_dem','25001900PAN_dem.tif');

% Read DEM (GeoTIFF)
[Z, Rmap] = readgeoraster(DEM_TIFF_filename);   % Z = elevation matrix, R = geographicRasterReference
Z = double(Z);                           % ensure numeric

if isfield(Rmap,'MissingDataIndicator')
    Z(Z==Rmap.MissingDataIndicator) = NaN;      % handle no-data if present
end

%% Conversion from MapCellsReference to GeographicCellsReference
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

% [cols, rows] = meshgrid(1:nCols, 1:nRows);
% 
% % Convert intrinsic coordinates to projected world coordinates (xWorld,yWorld)
% [xWorld, yWorld] = intrinsicToWorld(Rmap, cols, rows);
% 
% % Convert projected coordinates to geographic (lat, lon)
% % Rmap.ProjectedCRS should contain the projected coordinate reference system
% projCRS = Rmap.ProjectedCRS;
% [latGrid, lonGrid] = projinv(projCRS, xWorld, yWorld);   % lat, lon in degrees

DEM_XML_fileName = cat(2,DEM_TIFF_filename,'.xml');

URHERE

%%%%%%%%%%%%%%%%


% Create GeographicCellsReference matching raster size and orientation.
% Preserve ColumnsStartFrom and RowsStartFrom from original if relevant.
rowsFrom = Rmap.RowsStartFrom;     % e.g., 'north' or 'south'
colsFrom = Rmap.ColumnsStartFrom;  % e.g., 'west' or 'east'

Rgeo = georefcells(latlim, lonlim, [nRows, nCols], ...
    'ColumnsStartFrom', colsFrom, 'RowsStartFrom', rowsFrom);

% Now you can use Rgeo with geographic plotting/interpolation functions



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

%%
% Interpolation
% Example road coordinates (vectors of same length)
lat = [40.8318 40.8307];
lon = [-77.9622 -77.9591];

% Interpolate elevations at lat/lon (bilinear)
alt = geointerp(Z, Rgeo, lat, lon, 'linear');   % alt in same units as DEM (typically meters)

