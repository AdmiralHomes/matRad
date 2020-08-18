%% for 3 energies niedrig mittel und high energy
%clear
matRad_rc
pln.radiationMode   = 'carbon';     % either photons / protons / carbon
pln.machine         = 'HITgantry';
load([pln.radiationMode,'_',pln.machine]);
load BOXPHANTOM_LUNG.mat

cd A:\matRad_Noa\topas\energyspreadHIT

energy = [machine.data(67).energy, ...
    machine.data(152).energy, ...
    machine.data(233).energy];

energySpread = [0, 1.5, 3, 4.5];
%%
for i = energy
    for j = energySpread
        if ~isfile(['energySpread_',num2str(j),'_',num2str(round(i)),'.mat'])
            [resultGUI,resultGUI_MC] = matRad_calcMC(ct,cst,pln,i,j);
            cd A:\matRad_Noa\topas\energyspreadHIT
            save(['energySpread_',num2str(10*j),'_',num2str(round(i)),'.mat'],'resultGUI*')
            clear resultGUI*
        end
    end
end

pause(10)
system('shutdown -s')
%%
% 
% for j = 1:length(energySpread)
%     for i = 1:length(energy)
%         load(['energySpread_',num2str(energySpread(j)),'_',num2str(round(energy(i))),'.mat'],'resultGUI*')
%         
%         matRadDose{j,i} = matRad_calcIDD(resultGUI.physicalDose,'y');
%         TopasDose{j,i} = matRad_calcIDD(resultGUI_MC.physicalDose,'y');
%     end
% end
% 
% %%
% 
% for i = 1:length(energy)
%     figure
%     plot(matRadDose{j,i},'DisplayName','matRad')
%     hold on
%     for j = 1:length(energySpread)
%         txt = ['EnergySpread = ',num2str(energySpread(j))];
%         plot(TopasDose{j,i},'DisplayName',txt)
%     end
%     legend show
%     title(['Energy = ',num2str(energy(i))])
% end

%%
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