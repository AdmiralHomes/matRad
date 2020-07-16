function [Z_mod]=modulateDensityDynamic(ct,cst,Pmod)

DensMod = loadModDist(Pmod);

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


idx = contains(cst(:,2),'Lung');
lungIdx = [cst{idx,4}];
lungIdx = unique([lungIdx{:}]);

Z_mod = ct.cube{1};

numOfSamples = 50*length(lungIdx);

zz1 = ceil(rand(numOfSamples,1)*length(DensMod));
zz2 = rand(numOfSamples,1);
ix = zz2 <= DensMod(zz1,4);
newDist = zz1(ix);
Z_mod(lungIdx) = DensMod(newDist(lungIdx),2);

figure, histogram(Z_mod(lungIdx))

createSchneiderConverter(DensMod);

end