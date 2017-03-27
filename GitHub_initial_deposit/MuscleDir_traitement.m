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


%% Switch
comparaison =  '%';  % '=' (absolute) ou '%' (relative)
correctbonf =   1;   % 0 ou 1
useoldMuscleDir   =   0;   % 0 ou 1
export      =   1;   % o ou 1

%% Path
path.Datapath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\MuscleForceDir\';
path.exportpath = '\\10.89.24.15\e\\Projet_IRSST_LeverCaisse\ElaboratedData\MuscleFocus\GroupData\';
alias.matname = dir([path.Datapath '*mat']);

%% load data
if useoldMuscleDir == 0
    for imat = length(alias.matname) : -1 : 1
        % load emg data
        load([path.Datapath alias.matname(imat).name]);
        
        disp(['Traitement de ' data(1).name ' (' num2str(length(alias.matname) - imat+1) ' sur ' num2str(length(alias.matname)) ')'])
        
        % Choice of comparison (absolute or relative)
        [data] = comparison_weight(data, comparaison);
        
        [data.nsujet] = deal(imat); % subject ID
        
        % compute MuscleDir
        bigstruct(imat).Data = Data;
		bigstruct(imat).nsujet=imat;
		bigstruc(imat).Alias=Alias;
       
        clearvars Data Alias
    end
    
bigstruct = [bigstruct.Data];
spm.sex = [bigstruct.sexe]';
spm.height = [bigstruct.hauteur]';
spm.weight = [bigstruct.poids]';
spm.nsubject = [bigstruct.nsujet]';
spm.time  = linspace(0,100,4000);
spm.dIntmuscle = repmat(bigstruct.Alias.dIntMuscl,1,length(bigstruct))';
spm.emg = [bigstruct.emg]';


    spm = isintra(bigstruct,spm); % NaN on intra muscle for participants without intra

    for imuscle = 13:-1:1
    spm.comp = spm.emg(spm.muscle == imuscle,:); % by muscle
    
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

ù