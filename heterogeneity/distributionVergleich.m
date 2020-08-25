%%
clear
load protons_GenericAPM.mat
pLung = 0.26;
energyix = 20;
Pmod = 800;
rhoLung = 1.05;
d = Pmod/1000 / (1-pLung) / rhoLung;
D = 1; % voxelsize
n = round(D/d);

X = linspace(0,200,201);
v = ones(size(X));
numOfLungVoxels = 50;
numOfSamples = 1e3;
DensMod = loadModDist(Pmod);
depths = machine.data(energyix).depths;

sumGauss = @(x,mu,SqSigma,w) (1./sqrt(2*pi*ones(numel(x),1) .* SqSigma') .* ...
        exp(-bsxfun(@minus,x,mu').^2 ./ (2* ones(numel(x),1) .* SqSigma' ))) * w;

% figure
% for i = 1:100
%     v(50:99) = matRad_sampleLungBino(n,pLung,rhoLung,numOfSamples);
%     plot(X,cumsum(v)-0.5,'r'); hold on; 
%     
%     v(50:99) = discretize(rand(numOfSamples,1),[0;cumsum(DensMod(:,2))]) / numel(DensMod(:,2)) * rhoLung;
%     plot(X,cumsum(v)-0.5,'b');
%     legend('binomial','poisson')
%     waitforbuttonpress;
% end

if isfield([machine.data.Z],{'mean'})
%    Z = machine.data(energyix).Z.profileAPM;
    Z = sumGauss(machine.data(energyix).depths, machine.data(energyix).Z.mean, machine.data(energyix).Z.width.^2,machine.data(energyix).Z.weight);
else
    Z = machine.data(energyix).Z;
end

offset = 50-50*1.05*0.26;

sigmaSq = Pmod/1000 * rhoLung*pLung*D; % from Pmod = sigma^2/t; for 1 voxel
%sigmaSq = Pmod/1000 .* machine.data(energyix).peakPos;
sigmaSq = numOfLungVoxels*sigmaSq;
ellSq = bsxfun(@plus, machine.data(energyix).Z.width'.^2, sigmaSq);

normierung = max(Z);
lungStart = 20;
clear Y* 
for i = 1:numOfSamples
    % small voxels
    v(lungStart:lungStart+numOfLungVoxels-1) = matRad_sampleLungBino(n,pLung,rhoLung,numOfLungVoxels);
    Y(i,:) = matRad_interp1(depths,Z,cumsum(v)-0.5) / normierung;
    Y(isnan(Y)) = 0;
    
    % one big voxel
    v(lungStart:lungStart+numOfLungVoxels-1) =  matRad_sampleLungBino(n*numOfLungVoxels,pLung,rhoLung,1)*ones(numOfLungVoxels,1);
    Y2(i,:) = matRad_interp1(depths,Z,cumsum(v)-0.5) / normierung;
    Y2(isnan(Y2)) = 0;
    
    % small voxels poisson
    v(lungStart:lungStart+numOfLungVoxels-1) =  DensMod(discretize(rand(numOfLungVoxels,1),[0;cumsum(DensMod(:,2))]),1);
    Y3(i,:) = matRad_interp1(depths,Z,cumsum(v)-0.5) / normierung;
    Y3(isnan(Y3)) = 0;
end

v(lungStart:lungStart+numOfLungVoxels-1) = rhoLung*pLung;
APM = sumGauss(depths,machine.data(energyix).Z.mean,ellSq',machine.data(energyix).Z.weight);
APM = matRad_interp1(depths,APM,cumsum(v)-0.5) / normierung;

Z2 = matRad_interp1(depths,Z,cumsum(v)-0.5) / normierung;

figure, plot(X,Z2,'b--'), hold on, plot(X,mean(Y)), plot(X,mean(Y2)), plot(X,mean(Y3)), plot(X,APM)%, plot(linspace(offset,length(Z)-1+offset,length(Z)),Z);
xlim([10 120])
ylim([0 1.16])
patch([lungStart lungStart lungStart+numOfLungVoxels lungStart+numOfLungVoxels],[-10 40 40 -10],'black','facealpha',0.2)

xlabel 'Depth [voxel / mm]'
ylabel 'Dose [normalized]'

y1 = 0.42;
y2 = 1.05;
x1 = 86;
x2 = 108;
legend('homogeneous','small voxels','one big voxel','small voxels poisson','analytic','Lung','Location','northwest')
patch([x1 x1 x2 x2],[y1 y2 y2 y1],'black','facealpha',0,'HandleVisibility','off')

ax1 = gca;
f2 = figure();
ax2 = copyobj(ax1,f2);


xlim([x1 x2])
ylim([y1 y2])


