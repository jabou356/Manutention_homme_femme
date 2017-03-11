%   Description:
%       contribution_hauteur_preparation is used to compute the contribution of each
%       articulation to the height
%   Output:
%       contribution_hauteur_preparation gives matrix for input in SPM1D and GRAMM
%   Functions:
%       contribution_hauteur_preparation uses functions present in \\10.89.24.15\e\Project_IRSST_LeverCaisse\Codes\Functions_Matlab
%
%   Author:  Romain Martinez
%   email:   martinez.staps@gmail.com
%   Website: https://github.com/romainmartinez
%_____________________________________________________________________________

clear ; close all; clc

%% Chargement des fonctions

GenericPath
%% Interrupteurs
saveresults = 1;
writeopensim = 1;

%% Nom des sujets
Alias.sujet = sujets_validesJB(Path.ServerAddressE);

for isujet = length(Alias.sujet)-22   : -1 : 1
    
    disp(['Traitement de ' cell2mat(Alias.sujet(isujet)) ' (' num2str(length(Alias.sujet) - isujet+1) ' sur ' num2str(length(Alias.sujet)) ')'])
%     %% Chemin des fichiers
SubjectPath
    % Import reconstruction
    load([Path.exportPath, Alias.sujet{1,isujet} '.mat'], '-mat');
    
    
  %  Alias.Qnames    = dir([Path.importPath '*.Q*']);
    
    %% Ouverture et information du modèle
    % Ouverture du modèle
    Alias.model    = S2M_rbdl('new',Path.pathModel);
    % Noms et nombre de DoF
    Alias.nameDof  = S2M_rbdl('nameDof', Alias.model);
    Alias.nDof     = S2M_rbdl('nDof', Alias.model);
    % Noms et nombre de marqueurs
    Alias.nameTags = S2M_rbdl('nameTags', Alias.model);
    Alias.nTags    = S2M_rbdl('nTags', Alias.model);
    % Nom des segments
    Alias.nameBody = S2M_rbdl('nameBody', Alias.model);
    [Alias.segmentMarkers, Alias.segmentDoF] = segment_RBDL(2);
    %Frequence d'échantillonage
    Alias.frequency=100.00;
    
    %% Obtenir les onset et offset de force
 
    %% Sauvegarde de la matrice
    if saveresults == 1
        save([Path.exportPath Alias.sujet{1,isujet} '.mat'],'Data','Alias')
    end
    %clearvars data Data forceindex logical_cells
    Data=Data(length(Data)) %Je veux seulement conserver le dernier essai (static)
%     S2M_rbdl_AnimateModel(Alias.model, Data(1).Qdata.Q2)
    
    %Générer un fichier .trc pour Opensim
    if writeopensim == 1
    OpenSimTRCgeneratorJB 
    %OpenSimMOTgeneratorJB
    setupAndRunScale
    %setupAndRunIK
    %setupAndRunMuscleDirection
    end
    % Fermeture du model
    S2M_rbdl('delete', Alias.model);
end