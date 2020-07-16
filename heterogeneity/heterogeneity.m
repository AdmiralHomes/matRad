phantomLength = 120;
phantomWidth = 50;
% initialize CT cubes
ct.cubeHU = {zeros(phantomWidth,phantomLength,phantomWidth)};
ct.cube = {ones(phantomWidth,phantomLength,phantomWidth)};
ct.hlut = [1,0;0,-1024];
ct.resolution.x = 1;
ct.resolution.y = 1;
ct.resolution.z = 1;
ct.cubeDim = [phantomWidth,phantomLength,phantomWidth];
ct.numOfCtScen = 1;
ct.isoCenter = [phantomWidth/2,phantomLength-25,phantomWidth/2];
%%
ixOAR = 1;
ixPTV = 2;
ixLung = 3;

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

compartment1 = phantomWidth^2*20;
compartment2 = phantomWidth^2*70;
compartment3 = phantomWidth^2*phantomLength;

cst{ixOAR,4} = {[1:compartment3]'};
cst{ixLung,4} = {[compartment1+1:compartment2]'};
cst{ixPTV,4} = {[compartment2+1:compartment3]'};

%%% Assign relative electron densities
vIxOAR = cst{1,4}{1};
vIxLung = cst{3,4}{1};

ct.cubeHU{1}(vIxOAR) = 1;  % assign HU of water
ct.cubeHU{1}(vIxLung) = -600;  % assign HU of Lung

ct.cube{1}(vIxOAR) = 1;
ct.cube{1}(vIxLung) = 0.4;


%%

pln.radiationMode = 'protons';
pln.machine       = 'Generic';
pln.propOpt.bioOptimization = 'none';   

%%
pln.numOfFractions = 1;
pln.propStf.gantryAngles  = 0;
pln.propStf.couchAngles   = 0;
pln.propStf.bixelWidth    = 2;
pln.propStf.numOfBeams    = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter     = ones(pln.propStf.numOfBeams,1) * ct.isoCenter;
pln.propOpt.runDAO        = 0;
pln.propOpt.runSequencing = 0;

pln.propDoseCalc.doseGrid.resolution.x = 1; % [mm]
pln.propDoseCalc.doseGrid.resolution.y = 1; % [mm]
pln.propDoseCalc.doseGrid.resolution.z = 1; % [mm]

load([pln.radiationMode,'_',pln.machine])
%%
stf.gantryAngle = 0;
stf.couchAngle = 0;
stf.bixelWidth = 1;
stf.radiationMode = 'protons';
stf.SAD = 10000;
stf.isoCenter = [phantomWidth/2,phantomLength-25,phantomWidth/2];
stf.numOfRays = 1;
stf.sourcePoint_bev = [0,-10000,0];
stf.sourcePoint = [0,-10000,0];
stf.numOfBixelsPerRay = 1;
stf.longitudinalSpotSpacing = 3;
stf.totalNumOfBixels = 1;
stf.ray.rayPos_bev = [0,0,0];
stf.ray.targetPoint_bev = [0,10000,0];
stf.ray.rayPos = [0,0,0];
stf.ray.targetPoint = [0,10000,0];
stf.ray.focusIx = 1;
stf.ray.rangeShifter.ID = 0;
stf.ray.rangeShifter.eqThickness = 0;
stf.ray.rangeShifter.sourceRashiDistance = 0;

stf.ray.energy = machine.data(25).energy;

clearvars -except ct cst stf pln machine

tic
Z_mod = modulateDensityDynamic(ct,cst,250);
title('Pmod = 250\mu, new')
toc
tic
Z_mod = modulateDensityDynamic(ct,cst,450);
title('Pmod = 450\mu, new')
toc
tic
Z_mod = modulateDensityDynamic(ct,cst,800);
title('Pmod = 800\mu, new')
toc

%%
%resultGUI = matRad_calcDoseDirect(ct,stf,pln,cst,1);
