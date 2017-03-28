%   Description: used to compute the EMG
%   Output:  gives emg struct
%   Functions: uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________
clear variables; close all; clc
%% load functions
if isempty(strfind(path, '\\10.89.24.15\e\Librairies\S2M_Lib\'))
    % S2M library
    loadS2MLib;
end

GenericPath;

%% Switch
comparaison =  '%';  % '=' (absolute) ou '%' (relative)
correctbonf =   1;   % 0 ou 1
useoldMuscleDir   =   0;   % 0 ou 1
export      =   0;   % o ou 1

%% Path
path.Datapath = [Path.ServerAddressE, 'Projet_IRSST_LeverCaisse\ElaboratedData\matrices\MuscleForceDir\'];
path.exportpath = [Path.ServerAddressE, 'Projet_IRSST_LeverCaisse\ElaboratedData\MuscleFocus\GroupData\'];
alias.matname = dir([path.Datapath '*mat']);

%% load data
if useoldMuscleDir == 0
    for imat = length(alias.matname) : -1 : 1
        % load MuscleDir data
        load([path.Datapath alias.matname(imat).name]);
        
        disp(['Traitement de ' alias.matname(imat).name ' (' num2str(length(alias.matname) - imat+1) ' sur ' num2str(length(alias.matname)) ')'])
        
        % Choice of comparison (absolute or relative)
		for itrial=1:length(data)
			if strcmp(data(trial).sexe,'H')
				data(trial.sex)=1;
			elseif strcmp(data(trial).sexe,'F')
				data(trial.sex)=2;
			end
		end
		
        [data] = comparison_weight(data, comparaison);
        
        [data.nsujet] = deal(imat); % subject ID
		[data.name]=deal(alias.matname(imat).name);
        
        % compute MuscleDir
        bigstruct(imat).data = data;
		
       
        clearvars data 
	end
 
bigstruct = [bigstruct.data];

for i=1:8:(length(bigstruct)*8)
spm.sex(i:i:7) = bigstruct(i).sex;
spm.name(i:i+7) = bigstruct(i).name;
spm.height(i:i+7) = bigstruct(i).hauteur;
spm.weight(i:i+7) = bigstruct(i).poids;
spm.nsubject(i:i+7) = [bigstruct.nsujet]';
spm.time(i:i+7,:)  = linspace(0,100,4000);
spm.dIntmuscle(i:i+7) = bigstruct(i).dIntMuscle;
spm.dInt = [bigstruct.dInt]';
spm.vecDir = [bigstruct.vecDir]';
spm.attach = [bigstruct.attach]';
spm.GHjrc = [bigstruct.GHjrc]';
spm.H = [squeeze(bigstruct.H(:,1,1))]';


    for imuscle = 8:-1:1
    spm.comp = spm.vecDir(spm.dIntmuscle == imuscle,:); % by muscle
    
    % replace each NaN columns (muscle not recorded) by the means of other participants (same sex)
    spm.comp=clean_data(spm.comp');
    
    spm.emg(spm.muscle == imuscle,:)=spm.comp';
%     % NaN remover
%     [spm,deleted(imuscle)] = NaN_remover(spm,imuscle);
%     
%     % SPM
%     [result(imuscle).anova,result(imuscle).interaction,result(imuscle).mainA,result(imuscle).mainB] = ...
%         SPM_EMG(spm.comp',spm.sex,spm.height,spm.nsubject,imuscle,spm.time,correctbonf);
    end

    for imuscle = 13:-1:1
    spm.comp = spm.emg(spm.muscle == imuscle,:); % by muscle
    
    % replace each NaN columns (muscle not recorded) by the means of other participants (same sex)
    spm.comp=clean_dataSmallEMG(spm.comp');
    
    spm.emg(spm.muscle == imuscle,:)=spm.comp';
%     % NaN remover
%     [spm,deleted(imuscle)] = NaN_remover(spm,imuscle);
%     
%     % SPM
%     [result(imuscle).anova,result(imuscle).interaction,result(imuscle).mainA,result(imuscle).mainB] = ...
%         SPM_EMG(spm.comp',spm.sex,spm.height,spm.nsubject,imuscle,spm.time,correctbonf);
end
    save('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\MuscleFocus\GroupData\bigstructEMG.mat','spm')
else
    disp('Loading, please wait.')
    load('\\10.89.24.15\e\Projet_IRSST_LeverCaisse\ElaboratedData\MuscleFocus\GroupData\bigstructEMG.mat')
end

