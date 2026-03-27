
% Files are from:
% https://www.pasda.psu.edu/download/psu_opp/2022Orthophotos/LIDAR/las/255019425.las
% https://www.pasda.psu.edu/download/psu_opp/2022Orthophotos/LIDAR/las/255019450.las
% etc.

files = {'255019425.las','255019450.las','257519425.las','257519450.las'};

cameraViewfilename = fullfile('C:\Users\snb10\Desktop\GitHubRepos\IVSG\FieldDataCollection\RoadSegments\DEMImport','Data','pcshow_cameraview.mat');


loc = [];
intensity = [];
for ith_file = 1:length(files)
	thisFile = files{ith_file};
	filepath = fullfile('C:\Users\snb10\Desktop\To_DeleteTemp\',thisFile);

	lasReader = lasFileReader(filepath);

	[ptCloud, ptAttributes] = readPointCloud(lasReader, "Attributes", "Classification");

	loc = [loc; ptCloud.Location];   %#ok<AGROW> % Nx3
	intensity = [intensity; ptCloud.Intensity]; %#ok<AGROW> % Nx1
end


%% Colorize by height

z = double(loc(:,3));
if isempty(z)
    error('No points read from file.');
end

% Normalize Z to [0,1]
zmin = 1150; % min(z);
zmax = 1375; % max(z);

z = min(z,zmax);
z = max(z,zmin);

locModified = loc;
locModified(:,3) = min(locModified(:,3),zmax);
locModified(:,3) = max(locModified(:,3),zmin);

if zmax > zmin
    znorm1 = (z - zmin) / (zmax - zmin);
else
    znorm1 = zeros(size(z)); % all equal height
end

znorm = znorm1;

% Map normalized heights to a colormap (choose colormap and resolution)
nColors = 256;
cmap = parula(nColors);                      % nColors x 3
idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

% Show point cloud with color
figure(1234);
clf;

pcshow(locModified, colors)
title('Point Cloud Colored by Height (Z)')
xlabel('X'); ylabel('Y'); zlabel('Z')
colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
colormap(parula)

% Set a good camera view
s = load(cameraViewfilename);      % contains cam
setCameraView(s.cam);

% Save new camera view?
if 1==0
	cam = getCameraView(gca, filename);
end

%% Colorize by intensity

z = double(intensity);
if isempty(z)
    error('No points read from file.');
end

% Normalize Z to [0,1]
zmin = min(z);
zmax = 2000; % max(z);

z = min(z,zmax);
z = max(z,zmin);

if zmax > zmin
    znorm2 = (z - zmin) / (zmax - zmin);
else
    znorm2 = zeros(size(z)); % all equal height
end

znorm = znorm2;

% Map normalized heights to a colormap (choose colormap and resolution)
nColors = 256;
cmap = parula(nColors);                      % nColors x 3
idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

% Show point cloud with color
figure(2345);
clf;

pcshow(locModified, colors)
title('Point Cloud Colored by Height (Z)')
xlabel('X'); ylabel('Y'); zlabel('Z')
colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
colormap(parula)

% Set a good camera view
s = load(cameraViewfilename);      % contains cam
setCameraView(s.cam);

%% Save image?
if flag_exportFigures
	h_fig = gcf;
	figFileName = fullfile(pwd,'Images','testTrackDEM_Intensity.png');
	exportgraphics(h_fig,figFileName,'Resolution',300)
end



%% Colorize by blended height and intensity
if 1==0
	znorm = 0.5*znorm2 + 0.5*znorm1;
	znorm = min(znorm,1);
	znorm = max(znorm,0);

	% Map normalized heights to a colormap (choose colormap and resolution)
	nColors = 256;
	cmap = parula(nColors);                      % nColors x 3
	idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
	colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

	% Show point cloud with color
	figure(3456);
	clf;

	pcshow(locModified, colors)
	title('Point Cloud Colored by Height (Z)')
	xlabel('X'); ylabel('Y'); zlabel('Z')
	colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
	colormap(parula)

	% Set a good camera view
	s = load(cameraViewfilename);      % contains cam
	setCameraView(s.cam);
end

%% Colorize by whichever of height and intensity is furthest from each mean
diff1 = abs(znorm1 - mean(znorm1,'all','omitmissing'));
% diff1 = (znorm1 -0.5);
diff2 = abs(znorm2 - mean(znorm2,'all','omitmissing'));
diffs = [diff1 diff2];
[~,ind] = max(diffs,[],2);

znorm = znorm1;
znorm(ind==2) = znorm2(ind==2);

% Map normalized heights to a colormap (choose colormap and resolution)
nColors = 256;
cmap = parula(nColors);                      % nColors x 3
idx = max(1, round(znorm*(nColors-1)) + 1);  % indices 1..nColors
colors = uint8(255 * cmap(idx, :));          % Nx3 uint8

% Show point cloud with color
figure(4567);
clf;

pcshow(locModified, colors)
title('Point Cloud Colored by Height (Z)')
xlabel('X'); ylabel('Y'); zlabel('Z')
colorbar('Ticks',[0 1], 'TickLabels', [num2str(zmin) ' ' num2str(zmax)])
colormap(parula)

% Set a good camera view
s = load(cameraViewfilename);      % contains cam
setCameraView(s.cam);

%% Functions follow
function cam = getCameraView(ax, filename)
% getCameraView  Get camera settings from axes and optionally save to file
% cam = getCameraView(ax)
% cam = getCameraView(ax, filename)
% ax       : axes handle (use gca if omitted)
% filename : optional .mat filename to save the camera struct
%
% cam is a struct with fields: Position, Target, UpVector, ViewAngle, Projection

if nargin < 1 || isempty(ax)
    ax = gca;
end

cam.Position   = campos(ax);
cam.Target     = camtarget(ax);
cam.UpVector   = camup(ax);
cam.ViewAngle  = camva(ax);
cam.Projection = camproj(ax);

if nargin == 2 && ~isempty(filename)
    save(filename, 'cam');
end
end

function setCameraView(cam, ax)
% setCameraView  Apply a camera struct to axes used by pcshow
% setCameraView(cam)
% setCameraView(cam, ax)
% cam : struct returned by getCameraView (or loaded from .mat)
% ax  : target axes handle (defaults to gca)

if nargin < 2 || isempty(ax)
    ax = gca;
end

if ischar(cam) || isstring(cam)           % support passing a filename
    s = load(cam, 'cam');
    cam = s.cam;
end

% Apply in sensible order: projection, position/target, upvector, viewangle
camproj(ax, cam.Projection);
camup(ax, cam.UpVector);
campos(ax, cam.Position);
camtarget(ax, cam.Target);
camva(ax, cam.ViewAngle);
drawnow;
end

