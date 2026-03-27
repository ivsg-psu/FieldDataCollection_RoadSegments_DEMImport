% prj file path
prjFilepath = "C:\Users\snb10\Desktop\GitHubRepos\IVSG\FieldDataCollection\RoadSegments\DEMImport\TempExtract\13736E388029N.prj";
lasFilepath = "C:\Users\snb10\Desktop\GitHubRepos\IVSG\FieldDataCollection\RoadSegments\DEMImport\TempExtract\13736E388029N.las";

% read WKT text
wkt = strtrim(fileread(prjFilepath));

% try to create a projcrs or geocrs from the WKT (Mapping Toolbox)
crs = [];
try
    % First try creating a projected CRS (projcrs accepts WKT)
    crs = projcrs(wkt);
catch
    try
        % If that fails, try geographic CRS
        crs = geocrs(wkt);
    catch
        error("Could not interpret WKT from %s as a projcrs or geocrs.", prjFilepath);
    end
end


lasReader = lasFileReader(lasFilepath);

[ptCloud, ptAttributes] = readPointCloud(lasReader, "Attributes", "Classification");
XYdata = ptCloud.Location;
x = XYdata(:,1);
y = XYdata(:,2);


% Example: convert sample X,Y from LAS files to lat/lon
% x,y are vectors read from LAS (e.g., via lasFileReader + readPointCloud)
if isa(crs,"geographicCRS")
    lon = x;
    lat = y;
else
    % projcrs -> use projinv to get lat,lon
    [lat, lon] = projinv(crs, x, y);
end

% get bounds
minLon = min(lon); maxLon = max(lon);
minLat = min(lat); maxLat = max(lat);
