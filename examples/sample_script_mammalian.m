% Sample script for analyzing mammalian nuclei.
% Last updated by Jessica Williams, March 23, 2020.

% This set of sections does the following:
% (1) Loads the image file to the Workspace and designates the image
% channels.
% (2) Initializes fluorescent membrane channel and finds starting contour
% parameters.
% (3) Constructs set of variables by cell.
% (4) Analyzes each nucleus: serially fits and reconstructs nuclei.

% Note: in each section, code below '% ----' dashed line does not usually 
% need to be modified.

%% (1) Set up: load movie and designate image channels.

clear all;close all;clc;

% select movie file
movie=CellVision3D.Movie('sample_image_mammalian.dv');
label='mammalian';
% movie=CellVision3D.Movie('A549_WT_Fn_Man1488_DAPI_01_1_R3D.dv');
% label='Man1';

% set channels
movie.setChannels('FluorescentMembrane3DSpherical',label);
% movie.setChannels('None','dapi','FluorescentMembrane3DSpherical',label);

% set pixel size (only for sample_image_mamalian.dv).
movie.pix2um=0.266;

% -------------------------------------------------------------------------

% load movie to RAM
movie.load();

%% (2) Initialize fluorescent membrane channel.
% Use slide bar to adjust threshold value to have colored contour match
% nuclear boundary. Note: the area calculated within this perimeter will be
% used to calculate an initial radius (of a circle) for contour fitting in 
% section 4 (circle will be shown in second figure that pops us). If cross 
% section of nucleus is non-circular, consider adjusting contour to obtain 
% a reasonable starting radius. 

% -------------------------------------------------------------------------

% get channel
channel = movie.getChannel(label);
% set the size of object to 100
channel.lobject = 100;
% pad with zeros instead of same image
channel.padsame = false;
% split the cell four way
channel.ndivision = 3;
% initialize the movie 
contours = channel.init(1);
% view
channel.view();

%% (3) Construct cell.

% -------------------------------------------------------------------------

% construct the cell only by membrane
cells = CellVision3D.CellConstructor.constructCellsByMembrane(contours);
% view result
movie.view(cells);

%% (4) Analyze cell: 3D reconstructions.
% Run the analysis based on constructed cells. Set to pause after each
% reconstruction. Press any key to continue; final reconstruction iteration
% figure will save to Current Folder but keep all iteration figures open 
% review. If desired, you may save each figure individually or type 
% 'close all' in Command Window to close all figures.

% Variables to adjust, if needed:
cost_r_num = 10; % Reasonable range to try: 1-10; original number = 10;
r_add = 1; % Reasonable range to try: 1-40 (depending on object size); 
% original number = 1.

channel.run(cells,[],[],cost_r_num,r_add,1); % Set last variable to '1' if
% you want to blend/erase bright spots within nucleus, otherwise, leave as
% '0'.

%% Extra plotting...

close all
CellVision3D.Grapher.plot3DThreePanel(cells(1).contours(1));
CellVision3D.Grapher.save('mamalian3d3panel.png');
CellVision3D.Grapher.plot3DZ(cells(1).contours(1));
CellVision3D.Grapher.save('mamalian3dZ.png');

CellVision3D.Grapher.plot2DContour(cells(1).contours(1),...
    channel, 5/movie.pix2um, 1,34);
CellVision3D.Grapher.save('mamalian2dcontour.png');
CellVision3D.Grapher.plot2DContour(cells(1).contours(1),...
    channel, 5/movie.pix2um, 1,34,true);
CellVision3D.Grapher.save('mamalian2draw.png');

%%
% CellVision3D.Grapher.save('demo.png');

