% Script used to compute muscle focus based on OpenSim output for the
%BodyKinematic analysis function (Local coordinates, velocity, NOT degrees)
%and from the muscle force direction toolbox: Muscle Force direction
%vectors, local coordinates, NOT degrees
clear all; clc; 


%% Define variables
% Body and muscles of interest. As in Blache 2015, I targeted the lines of
% action of muscles best matching the position of the electrodes
Body={'humerus'};
Muscle={'DELT3','DELT2','DELT1',...
    'LAT1','PECM2'};



%% Chargement des fonctions
if isempty(strfind(path, '\\bimec7-kinesio.kinesio.umontreal.ca\e\Librairies\S2M_Lib\'))
    % Librairie S2M
    cd('\\bimec7-kinesio.kinesio.umontreal.ca\e\Librairies\S2M_Lib\');
    S2MLibPicker;
end

% Fonctions locales
addpath(genpath('\\bimec7-kinesio.kinesio.umontreal.ca\e\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab'));
addpath('\\bimec7-kinesio.kinesio.umontreal.ca\e\Projet_IRSST_LeverCaisse\Codes\Kinematics\Cinematique\functions');
addpath('\\bimec7-kinesio.kinesio.umontreal.ca\e\Projet_IRSST_LeverCaisse\Codes\Jason');

%% Nom des sujets
Alias.sujet = sujets_validesJB;

for isujet=2%1:length(Alias.sujet)
Path.exportPath = ['\\bimec7-kinesio.kinesio.umontreal.ca\e\Projet_IRSST_LeverCaisse\Jason\data\' Alias.sujet{isujet} '\'];
    
%% Load analyzed data by RM (to get trialname, condition, start and end time
%etc.
Path.importRBDLPath = ['\\bimec7-kinesio.kinesio.umontreal.ca\e\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\cinematique\' Alias.sujet{isujet} '.mat'];
load(Path.importRBDLPath);%temp
DATA=temp;
clear temp

%% Obtenir les onset et offset de force (beginning and end of trial)
for trial=1:length(DATA)
    startKine=DATA(trial).start;
    stopKine=DATA(trial).end;
end
MVTdurationKine=stopKine-startKine;

%% Load muscle path data
for trial=1:length(DATA)
    Path.MDpath=[Path.exportPath,'MuscleDirection\'];
    Path.MDresultpath=[Path.MDpath,'result\'];
    
LineOfAction = importdata([Path.MDresultpath DATA(trial).trialname '_MuscleForceDirection_vectors.sto']);
MuscleAttachment = importdata([Path.MDresultpath DATA(trial).trialname '_MuscleForceDirection_attachments.sto']);

%% Compute leverArm 
for i = 1:length(Muscle)
    
    DataColumn(:,i)=find(contains(MuscleAttachment.colheaders,Muscle(i))&contains(MuscleAttachment.colheaders,Body));
    parallel(:,3*i-2:3*i)=MuscleAttachment.data(:,DataColumn(:,i)); %Vector parallel to muscle attachment and Origin (lever arm)
    
end



for i = 1:length(Muscle)
    
   DataColumn(:,i)=find(contains(LineOfAction.colheaders,Muscle(i))&contains(LineOfAction.colheaders,Body));
    
    vecDir(:,:,i)=LineOfAction.data(:,DataColumn(:,i));
    
    % Gives axis around which the muscle rotate the humerus
    EffForceDir(:,:,i)=cross(vecDir(:,:,i),parallel(:,3*i-2:3*i));
   
    % Get the norm of the vector at each time point. More efficient then
    % using the norm function inside a FOR loop
    temp=sqrt(sum(EffForceDir(:,:,i).^2,2));
    temp=repmat(temp,1,3);
    
    %Gives the unit vector indicating the direction of the moment arm of
    %the muscle. Used in the equation in Blache 2015 (dm in equation 1)
    
    d(:,:,i)=EffForceDir(:,:,i)./temp; 
    
end


 Data(trial).dInt(:,:,:)=interp1(1:MVTdurationKine+1,d(startKine:stopKine,:,:),1:(MVTdurationKine)/999:MVTdurationKine+1);
 Data(trial).dIntMuscle=Muscle;
end

clear LineOfAction MuscleAttachment
end
%% EMG
% 
% [filename, pathname]=uigetfile('*.mat','Go get you EMGdata file');
% EMGdata = load([pathname,filename]);
% 
% [filename, pathname]=uigetfile('*.mat','Go get you EMGlabel file');
% EMGlabel = load([pathname,filename]);
% 
% trial=4;
% 
% for i=1:length(EMGlabel.Col_assign)
% emglabel(i)=EMGlabel.Col_assign{1,i}(1,1); %Je n'arrive pas � utiliser cette organisation des donn�es de fa�on efficace...
% end
% 
% EMGmuscle={'Delt_post','Delt_med','Delt_ant','Infra','Supra','Subscap','Gd_dors_IM','Pec_IM'};
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
% %% Animation
% 
% 
% % 
% for i=1:648
% clf
% plot3([0 0],[0 5], [0 0],'k','linewidth',3)
% hold on
% plot3([0 d(i,1,1)],[0 d(i,2,1)], [0 d(i,3,1)],'r')
% plot3([0 vecDir(i,1,1)],[0 vecDir(i,2,1)], [0 vecDir(i,3,1)],'k:','linewidth',2)
% plot3([0 d(i,1,2)],[0 d(i,2,2)], [0 d(i,3,2)],'b')
% plot3([0 vecDir(i,1,2)],[0 vecDir(i,2,2)], [0 vecDir(i,3,2)],'k:','linewidth',2)
% plot3([0 d(i,1,3)],[0 d(i,2,3)], [0 d(i,3,3)],'g')
% plot3([0 vecDir(i,1,3)],[0 vecDir(i,2,3)], [0 vecDir(i,3,3)],'k:','linewidth',2)
% plot3([0 d(i,1,4)],[0 d(i,2,4)], [0 d(i,3,4)],'m')
% plot3([0 vecDir(i,1,4)],[0 vecDir(i,2,4)], [0 vecDir(i,3,4)],'k:','linewidth',2)
% plot3([0 d(i,1,5)],[0 d(i,2,5)], [0 d(i,3,5)],'c')
% plot3([0 vecDir(i,1,5)],[0 vecDir(i,2,5)], [0 vecDir(i,3,5)],'k:','linewidth',2)
% 
% view([0,5,0])
% drawnow
% end
%     
% 
