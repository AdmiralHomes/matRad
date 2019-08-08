% matRad script
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2015 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set matRad runtime configuration
matRad_rc

%% load patient data, i.e. ct, voi, cst

%load HEAD_AND_NECK
%load TG119.mat
%load PROSTATE.mat
%load LIVER.mat
load BOXPHANTOM.mat

% meta information for treatment plan
pln.numOfFractions  = 30;
pln.radiationMode   = 'carbon';           % either photons / protons / helium / carbon
pln.machine         = 'genericAPM';

% beam geometry settings
pln.propStf.bixelWidth      = 5; % [mm] / also corresponds to lateral spot spacing for particles
%pln.propStf.longitudinalSpotSpacing = 100;
pln.propStf.gantryAngles    = 0; % [?] ;
pln.propStf.couchAngles     = 0; % [?] ; 
pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);
% optimization settings
pln.propOpt.runDAO          = false;      % 1/true: run DAO, 0/false: don't / will be ignored for particles
pln.propOpt.runSequencing   = false;      % 1/true: run sequencing, 0/false: don't / will be ignored for particles and also triggered by runDAO below

quantityOpt  = 'RBExD';     % options: physicalDose, effect, RBExD
modelName    = 'LEM';             % none: for photons, protons, carbon            % constRBE: constant RBE for photons and protons 
                                   % MCN: McNamara-variable RBE model for protons  % WED: Wedenberg-variable RBE model for protons 
                                   % LEM: Local Effect Model for carbon ions       % HEL: data-driven RBE parametrization for helium

heteroCorrBio = [];
                                   
% dose calculation settings
pln.propDoseCalc.doseGrid.resolution.x = 5; % [mm]
pln.propDoseCalc.doseGrid.resolution.y = 5; % [mm]
pln.propDoseCalc.doseGrid.resolution.z = 5; % [mm]

scenGenType  = 'nomScen';          % scenario creation type 'nomScen'  'wcScen' 'impScen' 'rndScen'                                          

% retrieve bio model parameters
pln.bioParam = matRad_bioModel(pln.radiationMode,quantityOpt, modelName);

% retrieve scenarios for dose calculation and optimziation
pln.multScen = matRad_multScen(ct,scenGenType);

%% initial visualization and change objective function settings if desired
% matRadGUI

%% generate steering file
stf = matRad_generateStf(ct,cst,pln);

%% dose calculation
if strcmp(pln.radiationMode,'photons')
    dij = matRad_calcPhotonDose(ct,stf,pln,cst,param);
    %dij = matRad_calcPhotonDoseVmc(ct,stf,pln,cst);
elseif strcmp(pln.radiationMode,'protons') || strcmp(pln.radiationMode,'helium') || strcmp(pln.radiationMode,'carbon')
    dij = matRad_calcParticleDose(ct,stf,pln,cst,param,heteroCorrBio);

end

%% inverse planning for imrt
CarbHomoOff  = matRad_fluenceOptimization(dij,cst,pln,param);
cstHetero = cst;
cstHetero{1,5}.HeterogeneityCorrection = 'Lung';
CarbHeteroOff = matRad_calcDoseDirect(ct,stf,pln,cstHetero,CarbHomoOff.w,param,heteroCorrBio);

clear dij heteroCorrBio
heteroCorrBio = true;
stf = matRad_generateStf(ct,cst,pln);

%% dose calculation
if strcmp(pln.radiationMode,'photons')
    dij = matRad_calcPhotonDose(ct,stf,pln,cst,param);
    %dij = matRad_calcPhotonDoseVmc(ct,stf,pln,cst);
elseif strcmp(pln.radiationMode,'protons') || strcmp(pln.radiationMode,'helium') || strcmp(pln.radiationMode,'carbon')
    dij = matRad_calcParticleDose(ct,stf,pln,cst,param,heteroCorrBio);

end

%% inverse planning for imrt
CarbHomoOn  = matRad_fluenceOptimization(dij,cst,pln,param);
CarbHeteroOn = matRad_calcDoseDirect(ct,stf,pln,cstHetero,CarbHomoOn.w,param,heteroCorrBio);


% %% sequencing
% if strcmp(pln.radiationMode,'photons') && (pln.propOpt.runSequencing || pln.propOpt.runDAO)
%     %resultGUI = matRad_xiaLeafSequencing(resultGUI,stf,dij,5);
%     %resultGUI = matRad_engelLeafSequencing(resultGUI,stf,dij,5);
%     resultGUI = matRad_siochiLeafSequencing(resultGUI,stf,dij,5);
% end
% 
% %% DAO
% if strcmp(pln.radiationMode,'photons') && pln.propOpt.runDAO
%    resultGUI = matRad_directApertureOptimization(dij,cst,resultGUI.apertureInfo,resultGUI,pln,param);
%    matRad_visApertureInfo(resultGUI.apertureInfo);
% end
% 
% %% start gui for visualization of result
% matRadGUI
% 
% %% indicator calculation and show DVH and QI
% [dvh,qi] = matRad_indicatorWrapper(cst,pln,resultGUI,[],[],param);
% 
% matRad_compareDose(resultGUI.physicalDose,resultGUIhetero.physicalDose,ct,cst,[1 0 0]);
