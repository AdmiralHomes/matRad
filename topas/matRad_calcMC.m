function [resultGUI,resultGUI_MC] = matRad_calcMC(ct,cst,pln,energyIx,weight)
% matRad example script
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2020 the matRad development team.
%
% This file is part of the matRad project. It is subject to the license
% terms in the LICENSE file found in the top-level directory of this
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part
% of the matRad project, including this file, may be copied, modified,
% propagated, or distributed except according to the terms contained in the
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pln.numOfFractions  = 1;
pln.propStf.bixelWidth      = 5; % [mm] / also corresponds to lateral spot spacing for particles
pln.propStf.longitudinalSpotSpacing = 5;
pln.propStf.gantryAngles    = 0; % [?]
pln.propStf.couchAngles     = 0; % [?]
pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
% pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);
pln.propStf.isoCenter       = ct.cubeDim/2 .* [ct.resolution.x ct.resolution.y ct.resolution.z];

% dose calculation settings
pln.propDoseCalc.doseGrid.resolution.x = 3; % [mm]
pln.propDoseCalc.doseGrid.resolution.y = 3; % [mm]
pln.propDoseCalc.doseGrid.resolution.z = 3; % [mm]
% pln.propDoseCalc.doseGrid.resolution = ct.resolution;
pln.propDoseCalc.airOffsetCorrection = true;
pln.propDoseCalc.lateralCutOff = 1;

pln.propOpt.optimizer       = 'IPOPT';
pln.propOpt.bioOptimization = 'none'; % none: physical optimization;             const_RBExD; constant RBE of 1.1;
% LEMIV_effect: effect-based optimization; LEMIV_RBExD: optimization of RBE-weighted dose
pln.propOpt.runDAO          = false;  % 1/true: run DAO, 0/false: don't / will be ignored for particles
pln.propOpt.runSequencing   = false;  % 1/true: run sequencing, 0/false: don't / will be ignored for particles and also triggered by runDAO below

pln.propMC.proton_engine = 'TOPAS';


stf = matRad_generateStfPencilBeam(pln,energyIx);

%% dose calculation
% dij = matRad_calcParticleDose(ct, stf, pln, cst);
resultGUI = matRad_calcDoseDirect(ct,stf,pln,cst,weight);
% %resultGUI = matRad_calcCubes(ones(dij.totalNumOfBixels,1),dij);
% resultGUI = matRad_fluenceOptimization(dij,cst,pln);

%% MC calculation
resultGUI_MC = matRad_calcDoseDirectMC(ct,stf,pln,cst,weight,1e4);
%% Compare Dose
%matRad_compareDose(resultGUI.physicalDose, resultGUI_MC.physicalDose, ct, cst, [1, 1, 0] , 'off', pln, [2, 2], 1, 'global');
end
