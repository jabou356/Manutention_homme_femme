# Manutention_homme_femme
Procesus d'analyse de données projet manutention Homme-Femme

Les codes dans ce repository sont utilisés afin d'analyser les données de manutention réalisées par des hommes et des femmes dans le laboratoire S2M. 

Systèmes utilisés: Matlab, OpenSim, Opensim libraries in Matlab, MuscleDirection toolbox in Opensim, S2M-RBDL toolbox in Matlab. 

Une partie du traitement de signal a été réalisée par RM avant l'entrée des données dans le processus (Cinématique inverse, EMG filtering, Event detection)

Les codes permettent:

-D'intégrer les CoR de l'épaule du modèle S2M-RBDL (Jackson 2012 / Michaud 2016) dans un modèle OpenSim
-D'écrire des fichiers .Mot à partir des coordonnées calculer par RM (modèle S2M-RBDL)
-D'écrire des fichiers .trc à partir des données reconstruites par RM (modèle S2M-RBDL)
-Ajuster le modèle générique OpenSim à partir du fichier .trc de l'essai statique du sujet "Scaling"
-Calculer la direction des muscles et les points d'insertion lors du mouvement à l'aide du MuscleDirection toolbox (scaled model + .mot)
-Calculer le Muscle Focus (EMG + Muscle direction + Point d'insertion)
