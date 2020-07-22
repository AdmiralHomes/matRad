function [ct]=matRad_modulateDensity(ct,cst,Pmod)
% matRad density modulation function
% 
% call
%   ct = matRad_modulateDensity(ct,cst,Pmod)
%
% input
%   ct:             ct struct
%   cst:            matRad cst struct
%   Pmod:           Modulation power according to which the modulation will
%                   be created
%
% output
%   ct:             ct struct with modulated density cube
%
% References
%   [1] https://iopscience.iop.org/article/10.1088/1361-6560/aa641f
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

global matRad_cfg;
matRad_cfg =  MatRad_Config.instance();

DensMod = loadModDist(Pmod);

DensMod(1,1)=0.001;
DensMod(:,4)=DensMod(:,2);

%normalize density distribution
DensMod(:,4) = DensMod(:,4) / sum(DensMod(:,4));

%Connect each density-probability-couple with a number that will later be transformed the HU-Value:
%The maximum HU-Value of the HU set by Schneider etal is 2995: So the HU of the modulated density must be at least 2995+1=2996 ; This values is prerocessed with the later used RescaleIntercept and RescaleSlope. See also calculation for Threshold_HU_Value_to_double.
Min_HU_for_DensMod_in_double=((2995+1000)/1);

%HU as double in row 2:
for i=1:length(DensMod)
    DensMod(i,2)=Min_HU_for_DensMod_in_double+i; %For i=1 the HU value is then 2996, the corresponding double is 3996
end
%Real HU values in row 3:
for i=1:length(DensMod)
    DensMod(i,3)=DensMod(i,2)*1-1000; %For i=1 the HU value is then 2996, the corresponding double is 3996
end

% get all unique lung indices from lung segmentations
idx = contains(cst(:,2),'Lung');
if sum(idx)==0
    matRad_cfg.dispError('No lung segmentation found in cst.\n');    
end
lungIdx = [cst{idx,4}];
lungIdx = unique([lungIdx{:}]);

% descrete sampling of the density distribution
P = [0; cumsum(DensMod(:,4))];
ct.cube{1}(lungIdx) = discretize(rand(numel(lungIdx),1),P);

% plot histogram of the the lung density distribution
figure, histogram(ct.cube{1}(lungIdx))

end