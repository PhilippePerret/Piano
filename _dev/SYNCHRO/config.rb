# encoding: UTF-8
=begin

Fichier de configuration de la synchronisation

=end

##
## Adresse du serveur SSH
##
SERVEUR_SSH = "piano@ssh.alwaysdata.com"

##
## Le dossier de base pour la synchro.
##
## Si c'est 'public' par exemple, alors c'est le dossier './www/public/' qui
## sera testé
##
ROOT_FOLDER = 'public'

##
## Les extensions des fichiers à passer
##
EXCLUDED_EXTENTIONS = ['.sass']

##
## Les fins d'affixe à exclure
##
EXCLUDED_END_WITH = ['-draft']