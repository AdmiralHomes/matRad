%% for 3 energies niedrig mittel und high energy
clear
matRad_rc
pln.radiationMode   = 'carbon';     % either photons / protons / carbon
% pln.machine         = 'HITfixedBL';
pln.machine         = 'HITgantry';
% pln.machine         = 'HITgenericRIFI3MMTOPAS_Water_forNiklas';
load([pln.radiationMode,'_',pln.machine]);
load BOXPHANTOM_ALLWATER.mat

cd A:\matRad_Noa\topas\energyspreadHIT

energySelect = 1:40:length([machine.data.energy]);
energySelect = energySelect(4);
energy = [machine.data(energySelect).energy];
weight = 1;

% ct.resolution.x = 1;
% ct.resolution.y = 1;
% ct.resolution.z = 1;
% ct.cubeDim = [360,360,360];
% ct.cubeHU{1} = ones(ct.cubeDim) * ct.cubeHU{1}(1);
% ct.cube{1} = ones(ct.cubeDim) * ct.cube{1}(1);
% cst{1,4}{1,1} = [1:prod(ct.cubeDim)]';
% cst{2,4}{1,1} = [];
% 
% idx = zeros(360,360,360);
% for i = 160:200
%     for j = 160:200
%         for k = 160:200
%             idx(i,j,k) = 1;
%         end
%     end
% end
% cst{2,4}{1,1} = find(idx == 1);


%%
for i = energySelect
    if ~isfile(['energy_',num2str(i,'%03d'),'_vacuum.mat'])
        [resultGUI,resultGUI_MC] = matRad_calcMC(ct,cst,pln,i,weight);
        cd A:\matRad_Noa\topas\energyspreadHIT
        save(['energy_',num2str(i,'%03d'),'_vacuum.mat'],'resultGUI*')
        clear resultGUI*
    end
end
%%
for i = energySelect
    if ~isfile(['energy_',num2str(i,'%03d'),'_air.mat'])
        [resultGUI,resultGUI_MC] = matRad_calcMC(ct,cst,pln,i,weight);
        cd A:\matRad_Noa\topas\energyspreadHIT
        save(['energy_',num2str(i,'%03d'),'_air.mat'],'resultGUI*')
        clear resultGUI*
    end
end
% pause(10)
% system('shutdown -s')
%%

% files = dir('*.mat');
% 
% figure, hold on
% for i = 1:numel(files)
%     load(files(i).name,'resultGUI*')
%     j = str2num(files(i).name(8:end-4));
%     plot(matRad_calcIDD(resultGUI.physicalDose,'y'),'DisplayName','matRad')
%     txt = ['Energy = ',num2str(machine.data(j).energy)];
%     plot(matRad_calcIDD(resultGUI_MC.physicalDose,'y'),'DisplayName',txt)
% end
% legend show
% xlim([0 120])
% xlabel('depths [mm]')
% ylabel('dose')

%%

files = dir('*.mat');

f = figure, hold on
for i = 1:2:numel(files)
    load(files(i).name,'resultGUI*')
    j = str2num(files(i).name(8:10));
    plot(matRad_calcIDD(resultGUI.physicalDose,'y'),'DisplayName','matRad','Color',matRad_getDefaultColor((i+1)/2),'LineWidth',1)
    txt = ['Energy = ',num2str(machine.data(j).energy),' air'];
    plot(matRad_calcIDD(resultGUI_MC.physicalDose,'y'),'-.','DisplayName',txt,'Color',matRad_getDefaultColor((i+1)/2),'LineWidth',1)
    
    load(files(i+1).name,'resultGUI*')
    txt2 = ['Energy = ',num2str(machine.data(j).energy),' vacuum'];
    plot(matRad_calcIDD(resultGUI_MC.physicalDose,'y'),'--','DisplayName',txt2,'Color',matRad_getDefaultColor((i+1)/2),'LineWidth',1)
end
legend show
xlim([0 120])
xlabel('depths [mm]')
ylabel('dose')
ylim([0 4])
title([pln.radiationMode,' ',pln.machine])
%%
i = 160;
figure, plot(machine.data(i).weight), hold on, plot(machine.data(i+1).weight)



%%
% resolutions = [1 3 5];
resolutions = [3 6];
figure
for i = resolutions
   load(['doseGrid',num2str(i),'.mat']) 
   plot(matRad_calcIDD(resultGUI.physicalDose,'y'),'--'), hold on, 
   plot(matRad_calcIDD(resultGUI_MC.physicalDose,'y'))
end
ylim([0 1])
legend({'1','2','3','4'})




% alpha = 0.022;
% p = 1.77;
% A = 12;
% Z = 6;
% A/Z^2 * alpha * E^p
% %%
% nw_energyRangeConv(88.83,A,Z)-2.89;


% %%
% function R = nw_energyRangeConv(E,A,Z)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % this function visualizes the energy to range conversion
% % by Niklas Wahl @ DKFZ 2019 -> n.wahl@dkfz.de
% % based on an orginial version by Mark Bangert DKFZ 2012 -> m.bangert@dkfz.de
% %
% % input argument
% % - E: optional energy [MeV] or vector of energies
% % define constants for range energy conversion
% alpha = 0.022;
% p     = 1.77;
% % get vector of energies if nothing provided
% if nargin < 1
%     E = 0:250;
% end
% % calculate ranges [MeV]
% R = A/Z^2 * alpha*E.^p;
% if numel(E) > 1
% % plot range energy conversion
%     figure; % opens new figure window
%     plot(E,R,'k');
% end
% % axis labels
% xlabel('Energy [MeV]');
% ylabel('Range [mm]');
% end