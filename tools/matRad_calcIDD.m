function IDD = matRad_calcIDD(doseCube,direction)
% function to calculate integrated depth dose (IDD) of a simple boxphantom
% for beams in x-, y- or z-direction
% 
% call
%   IDD = matRad_calcIDD(doseCube,direction)
%
% input
%   doseCube:       calculated dose cube
%   direction:      'x','y' or 'z', direction of the beam
%
% output
%   IDD:            depth dose vector 
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
if nargin < 2
    direction = 'y';
end

doseCube(isnan(doseCube))=0;

switch direction
    case 'y'
        IDD = sum(sum(doseCube,2),3);
    case 'z'
        IDD = sum(sum(doseCube,1),3);
        IDD = permute(IDD,[2,3,1]);
    case 'x'
        IDD = sum(sum(doseCube,2),1);        
        IDD = permute(IDD,[3,1,2]);
end
end
