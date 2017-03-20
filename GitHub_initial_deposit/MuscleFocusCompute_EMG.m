% EMG

clear all; clc;

%% Chargement des fonctions
if isempty(strfind(path, 'E:\Librairies\S2M_Lib\'))
    % Librairie S2M
    cd('E:\Librairies\S2M_Lib\');
    S2MLibPicker;
end

% Fonctions locales
addpath('E:\Projet_IRSST_LeverCaisse\Codes\Jason');
import org.opensim.modeling.*

GenericPath

%% Nom des sujets
GroupAlias.sujet = sujets_validesJB(Path.ServerAddressE);
data(1).mfEMGmuscle={'Delt_post','Delt_med','Delt_ant','Infra','Supra','Subscap','Gd_dors_IM','Pec_IM'};
data(1).mfEMGchan=[3 2 1 10 9 11 13 12];

% load([Path.ServerAddressE '\Projet_IRSST_LeverCaisse\Jason\data\GroupData\dataEMG.mat']);
for isujet=length(GroupAlias.sujet):-1:1
    SubjectPath
    
    Path.EMG=[Path.ServerAddressE '\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\EMG\' GroupAlias.sujet{isujet} '.mat'];
    load(Path.EMG)
    
    binlength=250*freq.emg/1000;
    
    if mod(binlenght,2)==0 %if bin length is an even number
        binlength=binlength+1;
    end
    for itrial=1:length(data)
        
        startEMG=floor(Data(itrial).start)*freq.emg/freq.camera;
        stopEMG=floor(Data(itrial).end)*freq.emg/freq.camera;
        MVTdurationEMG=stopEMG-startEMG;
        
        data(itrial).normemg=abs(data(itrial).emg)./repmat(MVC,size(data(itrial).emg,1),1);
        data(itrial).normRBIemg(1:floor(binlength/2),:)=mean(data(itrial).normemg(1:binlength,:),1);
        data(itrial).normRBIemg(ceiling(length(data(itrial).normemg)-binlength/2):length(data(itrial).normemg),:)=mean(data(itrial).normemg(end-binlength+1:end,:),1);
        
        
        for i=ceiling(binlength/2):floor(length(data(itrial).normemg)-binlength/2)
            data(itrial).normRBIemg(i,:)=mean(data(itrial).normemg(floor(i-binlength/2):ceiling(i+binlength/2),:),1);
        end
        
        Data(itrial).normRBIemgInt(:,:)=interp1(1:MVTdurationEMG+1,Data(itrial).normRBIemg(startEMG:stopEMG,:),1:(MVTdurationEMG)/999:MVTdurationEMG+1);
        
        
    end
    
end


%
%
%
% for i=1:length(EMGmuscle)
%     EMGchan(i)=find(contains(emglabel,EMGmuscle(i)));
%     EMGofInterest(:,i)=EMGdata.data(trial).EMGinterp(:,EMGchan(i));
%     numerator(:,:,i)=repmat(EMGofInterest(:,i),1,3).*EffForceDirinterp(:,:,i);
%     denominator(:,i)=EMGofInterest(:,i);
% end
%
% temp=sum(numerator,3);
% NUMERATOR=sqrt(sum(temp.^2,2));
% DENOMINATOR=sum(denominator,2);
% MuscleFocus=NUMERATOR./DENOMINATOR;
%
%% Animation
%
%
% %
% for i=1:583
% clf
% plot3([0 0],[0 5], [0 0],'k','linewidth',3)
% hold on
% plot3([0 Data(itrial).d(i,1,1)],[0 Data(itrial).d(i,2,1)], [0 Data(itrial).d(i,3,1)],'r')
% plot3([0 vecDir(i,1,1)],[0 vecDir(i,2,1)], [0 vecDir(i,3,1)],'k:','linewidth',2)
% plot3([0 Data(itrial).d(i,1,2)],[0 Data(itrial).d(i,2,2)], [0 Data(itrial).d(i,3,2)],'b')
% plot3([0 vecDir(i,1,2)],[0 vecDir(i,2,2)], [0 vecDir(i,3,2)],'k:','linewidth',2)
% plot3([0 Data(itrial).d(i,1,3)],[0 Data(itrial).d(i,2,3)], [0 Data(itrial).d(i,3,3)],'g')
% plot3([0 vecDir(i,1,3)],[0 vecDir(i,2,3)], [0 vecDir(i,3,3)],'k:','linewidth',2)
% plot3([0 Data(itrial).d(i,1,4)],[0 Data(itrial).d(i,2,4)], [0 Data(itrial).d(i,3,4)],'m')
% plot3([0 vecDir(i,1,4)],[0 vecDir(i,2,4)], [0 vecDir(i,3,4)],'k:','linewidth',2)
% plot3([0 Data(itrial).d(i,1,5)],[0 Data(itrial).d(i,2,5)], [0 Data(itrial).d(i,3,5)],'c')
% plot3([0 vecDir(i,1,5)],[0 vecDir(i,2,5)], [0 vecDir(i,3,5)],'k:','linewidth',2)
%
% view([0,5,0])
% drawnow
% end
% %