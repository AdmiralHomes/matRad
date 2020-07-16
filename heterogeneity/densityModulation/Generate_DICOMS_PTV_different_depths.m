Pmod = 250;  % Options: 250, 450, 800

DensMod = loadModDist(Pmod);

Z = zeros(200,200,60);
waterSlabDepth = 14;
pixelSpacing = 1.5;
numOfSamples = 1; % was 100

for  i=1:size(Z,1)
    for j=1:waterSlabDepth
        Z(i,j,:)=1009;
    end
    
    for j=size(Z,2)-waterSlabDepth:size(Z,2)
        Z(i,j,:)=1009;
    end
    
end

for i=1:size(Z,1)
    for j=1:size(Z,2)
        for k=1:size(Z,3)
            if Z(i,j,k)==0
                Z(i,j,k)=253;
            end
        end
    end
end

% Create non modulated files only if not already created
% if ~exist('DICOMS_NON_MODULATED')
%     [Z]=modulateDensity(Z,pixelSpacing,waterSlabDepth);
% end

[Z]=modulateDensity(Z,pixelSpacing,waterSlabDepth,numOfSamples,DensMod,Pmod);


