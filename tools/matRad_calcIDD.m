function IDD = matRad_calcIDD(doseCube,direction)
%MATRAD_IDD Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    direction = 'y';
end

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
