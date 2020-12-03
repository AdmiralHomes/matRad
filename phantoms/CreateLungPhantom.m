%% Example: Generate your own phantom geometry
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2018 the matRad development team.
%
% This file is part of the matRad project. It is subject to the license
% terms in the LICENSE file found in the top-level directory of this
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part
% of the matRad project, including this file, may be copied, modified,
% propagated, or distributed except according to the terms contained in the
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% In this example we will show
% (i) how to create arbitrary ct data (resolution, ct numbers)
% (ii) how to create a cst structure containing the volume of interests of the phantom
% (iii) generate a treatment plan for this phantom

%% set matRad runtime configuration
matRad_rc


%% Create the VOI data for the phantom
% Now we define structures a contour for the phantom and a target

ixOAR = 1;
ixPTV = 2;
ixLung = 3;

% define general VOI properties
cst{ixOAR,1} = 0;
cst{ixOAR,2} = 'contour';
cst{ixOAR,3} = 'OAR';

cst{ixPTV,1} = 1;
cst{ixPTV,2} = 'target';
cst{ixPTV,3} = 'TARGET';

cst{ixLung,1} = 3;
cst{ixLung,2} = 'Lung';
cst{ixLung,3} = 'OAR';

% define optimization parameter for both VOIs
cst{ixOAR,5}.TissueClass = 1;
cst{ixOAR,5}.alphaX      = 0.1000;
cst{ixOAR,5}.betaX       = 0.0500;
cst{ixOAR,5}.Priority    = 2;
cst{ixOAR,5}.Visible     = 1;
cst{ixOAR,5}.visibleColor     = [1 0 0];
cst{ixOAR,6}.type        = 'square overdosing';
cst{ixOAR,6}.dose        = 5;
cst{ixOAR,6}.penalty     = 100;
cst{ixOAR,6}.EUD         = NaN;
cst{ixOAR,6}.volume      = NaN;
cst{ixOAR,6}.coverage    = NaN;
cst{ixOAR,6}.robustness  = 'none';

cst{ixPTV,5}.TissueClass = 1;
cst{ixPTV,5}.alphaX      = 0.1000;
cst{ixPTV,5}.betaX       = 0.0500;
cst{ixPTV,5}.Priority    = 1;
cst{ixPTV,5}.Visible     = 1;
cst{ixPTV,5}.visibleColor     = [0 1 0];
cst{ixPTV,6}.type        = 'square deviation';
cst{ixPTV,6}.dose        = 60;
cst{ixPTV,6}.penalty     = 800;
cst{ixPTV,6}.EUD         = NaN;
cst{ixPTV,6}.volume      = NaN;
cst{ixPTV,6}.coverage    = NaN;
cst{ixPTV,6}.robustness  = 'none';

cst{ixLung,5}.TissueClass = 1;
cst{ixLung,5}.alphaX      = 0.1000;
cst{ixLung,5}.betaX       = 0.0500;
cst{ixLung,5}.Priority    = 2;
cst{ixLung,5}.Visible     = 1;
cst{ixLung,5}.visibleColor     = [0 0 1];
cst{ixLung,6}.type        = 'square overdosing';
cst{ixLung,6}.dose        = 42;
cst{ixLung,6}.penalty     = 400;
cst{ixLung,6}.EUD         = NaN;
cst{ixLung,6}.volume      = NaN;
cst{ixLung,6}.coverage    = NaN;
cst{ixLung,6}.robustness  = 'none';
%%


%% Create a CT image series
xDim = 50;
yDim = 120;
zDim = 50;

ct.cubeDim      = [xDim yDim zDim];
ct.resolution.x = 1;
ct.resolution.y = 1;
ct.resolution.z = 1;
ct.numOfCtScen  = 1;


%% Lets create either a cubic or a spheric phantom
iso = [25,95,25];
offset = -10;
% create an ct image series with zeros - it will be filled later
ct.cubeHU{1} = ones(ct.cubeDim) * -1024;
ct.cube{1} = ones(ct.cubeDim) * 0.005;


centerP_corr = iso - [15+offset,0,0];
height_corr = 120;
width_corr = 50;
depth_corr = 50;


mask = zeros(ct.cubeDim);

for i=-height_corr/2+1:height_corr/2
    for j=-width_corr/2:width_corr/2
        for k=-depth_corr/2:depth_corr/2
            mask(centerP_corr(1)+i,centerP_corr(2)+j,centerP_corr(3)+k) = 1;
        end
    end
end

centerP_corr = iso - [85+offset,0,0];
height_corr = 10;
width_corr = 80;
depth_corr = 80;

for i=-height_corr/2+1:height_corr/2
    for j=-width_corr/2:width_corr/2
        for k=-depth_corr/2:depth_corr/2
            mask(centerP_corr(1)+i,centerP_corr(2)+j,centerP_corr(3)+k) = 1;
        end
    end
end

cst{1,4}{1} = find(mask == 1);


centerP_corr = iso - [70+offset,0,0];
height_corr = 20;
width_corr = 80;
depth_corr = 80;


mask = zeros(ct.cubeDim);

for i=-height_corr/2+1:height_corr/2
    for j=-width_corr/2:width_corr/2
        for k=-depth_corr/2:depth_corr/2
            mask(centerP_corr(1)+i,centerP_corr(2)+j,centerP_corr(3)+k) = 1;
        end
    end
end
cst{3,4}{1} = find(mask == 1);


centerP_corr = iso + [0,0,0];
height_corr = 30;
width_corr = 30;
depth_corr = 30;


mask = zeros(ct.cubeDim);

for i=-height_corr/2:height_corr/2
    for j=-width_corr/2:width_corr/2
        for k=-depth_corr/2:depth_corr/2
            mask(centerP_corr(1)+i,centerP_corr(2)+j,centerP_corr(3)+k) = 1;
        end
    end
end
cst{2,4}{1} = find(mask == 1);


%% Assign relative electron densities
vIxOAR = cst{1,4}{1};
%vIxPTV = cst{2,4}{1};
vIxLung = cst{3,4}{1};

ct.cubeHU{1}(vIxOAR) = 1;  % assign HU of water
%ct.cubeHU{1}(vIxPTV) = 1;  % assign HU of water
ct.cubeHU{1}(vIxLung) = -600;  % assign HU of Lung

ct.cube{1}(vIxOAR) = 1;
ct.cube{1}(vIxLung) = 0.4;

disp('Done!');
%%
figure
plane = 3;
slice = iso(3);
matRad_plotCtSlice(gca,ct.cubeHU,1,plane,slice)
matRad_plotVoiContourSlice(gca,cst,ct.cube,1,[],plane,slice)
plot(iso(2),iso(1),'x')

%%
%clearvars -except ct cst
%save('BOXPHANTOM_LUNG_NARROW_1mm.mat')
