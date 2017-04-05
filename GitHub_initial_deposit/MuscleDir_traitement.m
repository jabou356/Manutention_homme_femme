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
export      =   1;   % o ou 1

%% Path
path.Datapath = [Path.ServerAddressE, 'Projet_IRSST_LeverCaisse\ElaboratedData\matrices\MuscleForceDir\'];
path.exportpath = [Path.ServerAddressE, 'Projet_IRSST_LeverCaisse\ElaboratedData\MuscleFocus\GroupData\GenModel\'];
alias.matname = dir([path.Datapath '*mat']);

%% load data
if useoldMuscleDir == 0
	for imat = length(alias.matname) : -1 : 1
		% load MuscleDir data
		load([path.Datapath alias.matname(imat).name]);
		
		disp(['Traitement de ' alias.matname(imat).name ' (' num2str(length(alias.matname) - imat+1) ' sur ' num2str(length(alias.matname)) ')'])
		
		% Choice of comparison (absolute or relative)
		for itrial=1:length(data)
			if strcmp(data(itrial).sexe,'H')
				data(itrial).sex=1;
			elseif strcmp(data(itrial).sexe,'F')
				data(itrial).sex=2;
			end
		end
		
		[data] = comparison_weight(data, comparaison);
		
		[data.nsujet] = deal(imat); % subject ID
		[data.name]=deal(alias.matname(imat).name);
		
		% compute MuscleDir
		bigstruct(imat).data = data;
		
		
		clearvars data
	end
	
	if export==1
		save([path.exportpath 'bigstructMuscleDir.mat'],'bigstruct')
	end
	
else
	disp('Loading, please wait.')
	load([path.exportpath 'bigstructMuscleDir.mat'])
end

bigstruct = [bigstruct.data];
spm.time  = linspace(0,100,4000);

for i=1:length(bigstruct)
	disp(['Now treating i=' num2str(i)])
	spm.sex(8*i-7:8*i) = deal(bigstruct(i).sex)';
	spm.name{8*i-7} = deal(bigstruct(i).name)';
	spm.height(8*i-7:8*i) = deal(bigstruct(i).hauteur)';
	spm.weight(8*i-7:8*i) = deal(bigstruct(i).poids)';
	spm.nsubject(8*i-7:8*i) = deal(bigstruct(i).nsujet)';
	spm.dIntmuscle(8*i-7:8*i) = [bigstruct(i).dIntMuscle];
	spm.imuscle(8*i-7:8*i) = 1:8;
	spm.dInt(:,:,8*i-7:8*i) = bigstruct(i).dInt;
end
	if export==1

save([path.exportpath 'spmMuscleDir.mat'],'spm')

	end

% 
% 
% for imuscle = 8:-1:1
% 	spm.comp = spm.dInt(:,:,spm.imuscle == imuscle & spm.height == 1); % by muscle
% 	
% 	% replace each NaN columns (muscle not recorded) by the means of other participants (same sex)
% 	spm.comp=clean_dataDInt(spm.comp);
% 	
% 	spm.emg(spm.muscle == imuscle,:)=spm.comp;
% 	%     % NaN remover
% 	%     [spm,deleted(imuscle)] = NaN_remover(spm,imuscle);
% 	%
% 	%     % SPM
% 	%     [result(imuscle).anova,result(imuscle).interaction,result(imuscle).mainA,result(imuscle).mainB] = ...
% 	%         SPM_EMG(spm.comp',spm.sex,spm.height,spm.nsubject,imuscle,spm.time,correctbonf);
% end
% 
% for imuscle = 13:-1:1
% 	spm.comp = spm.emg(spm.muscle == imuscle,:); % by muscle
% 	
% 	% replace each NaN columns (muscle not recorded) by the means of other participants (same sex)
% 	spm.comp=clean_dataSmallEMG(spm.comp');
% 	
% 	spm.emg(spm.muscle == imuscle,:)=spm.comp';
% 	%     % NaN remover
% 	%     [spm,deleted(imuscle)] = NaN_remover(spm,imuscle);
% 	%
% 	%     % SPM
% 	%     [result(imuscle).anova,result(imuscle).interaction,result(imuscle).mainA,result(imuscle).mainB] = ...
% 	%         SPM_EMG(spm.comp',spm.sex,spm.height,spm.nsubject,imuscle,spm.time,correctbonf);
% end
% 
% 
