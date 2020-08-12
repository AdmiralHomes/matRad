function X = matRad_sampleBino(n,p,numOfSamples)
% matRad function for binomial sampling
%
% call
%   X = matRad_sampleBino(n,p,numOfSamples)
%
% input
%   n:              number of independent experiments
%   p:              probability (between 0 and 1)
%   numOfSamples:   number of samples for output
%
% output
%   X:              binomial samples
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

ndimsOut = numel(numOfSamples);

if ~mod(n,1) == 0
    error('n has to be integer');
elseif ~isscalar(n)
    error('no n arrays supported');
elseif ~(all(p <= 1) && all(p >= 0))
   error('p must be between 0 and 1'); 
elseif ~(numOfSamples == numel(p))
    error('p must have numOfSamples entries')
end

X = sum(rand([numOfSamples,n]) < p', ndimsOut+1);

end
