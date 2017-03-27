%% Chargement des fonctions
% WhereRU=menu('Where are you','At Home', 'At the Office');
% if WhereRU ==1
%     Path.ServerAddressE='\\bimec7-kinesio.kinesio.umontreal.ca\e';
%     Path.ServerAddressF='\\bimec7-kinesio.kinesio.umontreal.ca\f';   
% elseif WhereRU == 2
%     Path.ServerAddressE='E:';
%     Path.ServerAddressF='F:';
% end

Path.ServerAddressE=uigetfolder('Go get the E: path');
Path.ServerAddressF=uigetfolder('Go get the F: path');

if isempty(strfind(path, [Path.ServerAddressE, '\Librairies\S2M_Lib\']))
    % Librairie S2M
    cd([Path.ServerAddressE '\Librairies\S2M_Lib\']);
    S2MLibPicker;
end

% Fonctions locales
addpath(genpath([Path.ServerAddressE '\Projet_IRSST_LeverCaisse\Codes\Functions_Matlab']));
addpath([Path.ServerAddressE '\Projet_IRSST_LeverCaisse\Codes\Kinematics\Cinematique\functions']);
addpath([Path.ServerAddressE '\Projet_IRSST_LeverCaisse\Codes\Jason']);

%% Setup common paths
Path.OpensimSetupJB=[Path.ServerAddressE '\Projet_IRSST_LeverCaisse\Jason\OpenSimSetUpFiles\'];
Path.OpensimGenericModel=[Path.OpensimSetupJB,'GenericShoulderCoRAnatoJB.osim'];
Path.OpensimGenericScale=[Path.OpensimSetupJB,'Conf_scaling.xml'];
Path.OpensimGenericIK=[Path.OpensimSetupJB,'Conf_IK.xml'];
Path.OpensimGenericMD=[Path.OpensimSetupJB,'Conf_MD.xml'];