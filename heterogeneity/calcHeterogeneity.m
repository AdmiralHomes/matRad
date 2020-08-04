pln.radiationMode   = 'carbon';     % either photons / protons / carbon
pln.machine         = 'Generic';
load([pln.radiationMode,'_',pln.machine]);

Pmod = 800;

energy = [machine.data(11).energy, machine.data(48).energy, machine.data(95).energy, machine.data(121).energy];
energy = energy(3);

load BOXPHANTOM_LUNG.mat

% meta information for treatment plan
pln.radiationMode   = 'carbon';     % either photons / protons / carbon
pln.machine         = 'Generic';
%pln.machine         = 'generic_TOPAS_cropped';
%pln.radiationMode   = 'protons';

pln.numOfFractions  = 1;

% beam geometry settings
pln.propStf.bixelWidth      = 50; % [mm] / also corresponds to lateral spot spacing for particles
pln.propStf.longitudinalSpotSpacing = 50;
pln.propStf.gantryAngles    = 0; % [?] 
pln.propStf.couchAngles     = 0; % [?]
pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);
%pln.propStf.isoCenter       = [51 0 51];
                            
% dose calculation settings
pln.propDoseCalc.doseGrid.resolution.x = 5; % [mm]
pln.propDoseCalc.doseGrid.resolution.y = 5; % [mm]
pln.propDoseCalc.doseGrid.resolution.z = 5; % [mm]
%pln.propDoseCalc.doseGrid.resolution = ct.resolution;
pln.propDoseCalc.airOffsetCorrection = true;
pln.propDoseCalc.lateralCutOff = 1;

% optimization settings
pln.propOpt.optimizer       = 'IPOPT';
pln.propOpt.bioOptimization = 'none'; % none: physical optimization;             const_RBExD; constant RBE of 1.1;
                                      % LEMIV_effect: effect-based optimization; LEMIV_RBExD: optimization of RBE-weighted dose
pln.propOpt.runDAO          = false;  % 1/true: run DAO, 0/false: don't / will be ignored for particles
pln.propOpt.runSequencing   = false;  % 1/true: run sequencing, 0/false: don't / will be ignored for particles and also triggered by runDAO below

pln.propMC.proton_engine = 'TOPAS';
%pln.propMC.proton_engine = 'MCsquare';

%% generate steering file
stf = matRad_generateStf(ct,cst,pln);

%stf.ray = struct; 
stf.ray.rayPos_bev = [0,0,0];
stf.ray.targetPoint_bev = [0,10000,0];
stf.ray.rayPos = [0,0,0];
stf.ray.targetPoint = [0,10000,0];
stf.ray.energy = energy;
stf.ray.focusIx = 1;
stf.ray.rangeShifter = struct;
stf.ray.rangeShifter.ID = 0;
stf.ray.rangeShifter.eqThickness = 0;
stf.ray.rangeShifter.sourceRashiDistance = 0;

stf.totalNumOfBixels = 1;
stf.numOfBixelsPerRay = 1;

%%
ct = matRad_modulateDensity(ct,cst,Pmod);
%%
samples = 1e5;
P = [250 450 800];
Results = [];
for i = 1:3
Pmod = P(i);
pLung = 0.26;
rhoLung = 1.05;
rhoWater = 1;
rhoMean = rhoLung * pLung;

d = Pmod/1000 / (1-pLung) / rhoLung;
D = ct.resolution.y;

n = round(D/d);

v = binornd(n,pLung,[samples,1]) / n * rhoLung;

%v = binopdf(0:25,n,pLung);

[mean,variance] = binostat(n,pLung);
sigma = sqrt(variance);
% 
% Results{1,1} = 'Pmod';
% Results{1,2} = 'n';
% Results{1,3} = 'mean*d';
% Results{1,4} = 'sigma';
% Results{1,5} = 'sigma*d';
% Results{i+1,1} = Pmod;
% Results{i+1,2} = n;
% Results{i+1,3} = mean*d;
% Results{i+1,4} = sigma;
% Results{i+1,5} = sigma*d;


end
%figure, plot(v)
%%
% samp = binornd(9,0.26,100);
% figure, hist((samp/9)*1.05)
% samp = binornd(155,0.26,1000);
% figure, hist((samp/155)*1.05)
% 
% samp = binornd(9,0.26,1000);
% figure, hist((samp/9)*1.05)
% samp = binornd(155,0.26,1000);
% figure, hist((samp/155)*1.05)
% clear, cls
% clear, clc


densityvar = @(n,p,ns) std(binornd(n,p,[ns 1]) / n * 1.05);
densityvar(12,0.26,10000)
%%
weplsamples = @(n,p,ns,nv) sum(binornd(n,p,[ns nv]) / n * 1.05,2);

%%


