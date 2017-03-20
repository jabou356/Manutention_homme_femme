% Script used to compute muscle focus based on OpenSim output for the
%BodyKinematic analysis function (Local coordinates, velocity, NOT degrees)
%and from the muscle force direction toolbox: Muscle Force direction
%vectors, local coordinates, NOT degrees
clear all; clc; 


%% Define variables
% Body and muscles of interest. As in Blache 2015, I targeted the lines of
% action of muscles best matching the position of the electrodes
Body={'humerus'};
Muscle={'DELT3','DELT2','DELT1','INFSP','SUPSP', 'SUBSC',...
    'LAT1','PECM3' };



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
% load([Path.ServerAddressE '\Projet_IRSST_LeverCaisse\Jason\data\GroupData\dataEMG.mat']);
for isujet=length(GroupAlias.sujet):-1:1
    Alias=GroupAlias;
    SubjectPath
    name=Alias.sujet{isujet};
    name=name(end-3:end);
    

   
    MyModel=Model([Path.exportPath Alias.sujet{isujet} 'scaledNewMKR.osim']);
    MyJointSet=MyModel.getJointSet;
    MyGHJoint=MyJointSet.get('preshoulder1');
    GHJoint=MyGHJoint.get_location;    GHJoint=[GHJoint.get(0) GHJoint.get(1) GHJoint.get(2)];
    
%% Load analyzed data by RM (to get trialname, condition, start and end time
%etc.
load([Path.exportPath Alias.sujet{1,isujet} '.mat']);


%% Load model to get GH CoR position in child segment


%% Obtenir les onset et offset de force (beginning and end of trial)
for itrial=1:length(Data)-1

startKine=floor(Data(itrial).start);
stopKine=floor(Data(itrial).end);
MVTdurationKine=stopKine-startKine;

%% Load muscle path data
if exist([Path.MDresultpath Data(itrial).trialname '.mot_MuscleForceDirection_vectors.sto'],'file')==2    
LineOfAction = importdata([Path.MDresultpath Data(itrial).trialname '.mot_MuscleForceDirection_vectors.sto']);
MuscleAttachment = importdata([Path.MDresultpath Data(itrial).trialname '.mot_MuscleForceDirection_attachments.sto']);

%% Compute leverArm 
for imuscle = 1:length(Muscle)
    %Contains function does not exist before Matlab 2017a
   % DataColumn(:,imuscle)=find(contains(MuscleAttachment.colheaders,Muscle(imuscle))&contains(MuscleAttachment.colheaders,Body));
   for ichan=2:length(MuscleAttachment.colheaders)
       channame=MuscleAttachment.colheaders{ichan};
       ismuscle(ichan)=strcmp(channame(1:length(Muscle{imuscle})),Muscle{imuscle});
       isbody(ichan)=strcmp(channame(end-length(Body{1})+1:end),Body{1});
        
   end
   DataColumn(:,imuscle)=find(ismuscle+isbody==2);
    parallel(:,3*imuscle-2:3*imuscle)=MuscleAttachment.data(:,DataColumn(:,imuscle))-repmat(GHJoint,size(MuscleAttachment.data,1),1); %Vector parallel to muscle attachment and Origin (lever arm)
    
    Data(itrial).vecDir(:,:,imuscle)=LineOfAction.data(:,DataColumn(:,imuscle));
    Data(itrial).attach(:,:,imuscle)=MuscleAttachment.data(:,DataColumn(:,imuscle));
    
    % Gives axis around which the muscle rotate the humerus
    EffForceDir(:,:,imuscle)=cross(Data(itrial).vecDir(:,:,imuscle),parallel(:,3*imuscle-2:3*imuscle));
   
    % Get the norm of the vector at each time point. More efficient then
    % using the norm function inside a FOR loop
    temp=sqrt(sum(EffForceDir(:,:,imuscle).^2,2));
    temp=repmat(temp,1,3);
    
    %Gives the unit vector indicating the direction of the moment arm of
    %the muscle. Used in the equation in Blache 2015 (dm in equation 1)
    
    Data(itrial).d(:,:,imuscle)=EffForceDir(:,:,imuscle)./temp; 
    
end

 Data(itrial).dInt(:,:,:)=interp1(1:MVTdurationKine+1,Data(itrial).d(startKine:stopKine,:,:),1:(MVTdurationKine)/999:MVTdurationKine+1);
 
 clear LineOfAction MuscleAttachment EffForceDir verDir parallel temp DataColumn MVTdurationKine
end
end
Alias.dIntMuscle=Muscle;
MyModel.disownAllComponents();

save(['E:\Projet_IRSST_LeverCaisse\ElaboratedData\matrices\MuscleForceDir\' Alias.sujet{1,isujet} '.mat'],'Data','Alias')

clear MyModel MyJointSet MyGHJoint GHJoint Data Alias
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
% 