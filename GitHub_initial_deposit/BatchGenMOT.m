clear; close all; clc

GenericPath


%% Nom des sujets
Alias.sujet = sujets_validesJB(Path.ServerAddressE);

for isujet = 1%length(Alias.sujet) : -1 : length(Alias.sujet)-4
    
    disp(['Traitement de ' cell2mat(Alias.sujet(isujet)) ' (' num2str(length(Alias.sujet) - isujet+1) ' sur ' num2str(length(Alias.sujet)) ')'])
        
SubjectPath
    % Import reconstruction
load([Path.exportPath Alias.sujet{1,isujet} '.mat'],'Data','Alias')
 

OpenSimMOTgeneratorJB
  
end
