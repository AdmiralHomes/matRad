function [Z]=modulateDensity(Z,pixelSpacing,waterSlabDepth,numOfModulations,DensMod,Pmod)
if nargin < 6
    modulated = false;
else
    modulated = true;
end

diameters = [8 10 15 20 25 30];                         % diameters in voxel
depthsCm = [20 40 60 100 150 200 250];                  % depths in cm



if modulated
    
    DensMod(1,1)=0.001;
    DensMod(:,4)=DensMod(:,2);
    
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
    
    lungIdx = Z==253;
    numOfSamples = 50*sum(lungIdx(:));
    
    for m = 1:numOfModulations
        
        Z_mod = Z;
        
        
        zz1 = ceil(rand(numOfSamples,1)*length(DensMod));
        zz2 = rand(numOfSamples,1);
        ix = zz2 <= DensMod(zz1,4);
        newDist = zz1(ix);
        Z_mod(lungIdx) = DensMod(newDist(lungIdx),2);
        figure, histogram(Z_mod(lungIdx));
        
%         for d = diameters
%             for depth = depthsCm
%                 createSphereDcmExport(Z_mod,d,depth,pixelSpacing,waterSlabDepth,Pmod,m);
%             end
%         end
    end
    
    
else
    for d = diameters
        for depth = depthsCm
            createSphereDcmExport(Z,d,depth,pixelSpacing,waterSlabDepth);
        end
    end
end


createSchneiderConverter(DensMod);


end