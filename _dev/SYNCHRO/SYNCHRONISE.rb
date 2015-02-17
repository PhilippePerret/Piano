=begin

Script permettant de synchroniser le site distant avec le site local.

NOTE
    * Pour fonctionner, on doit trouver à la racine du serveur (PAS DU SITE) le
      script `synchro.rb`.
    * On utilise la classe `Fichier` pour procéder à l'opération
    * Seul le dossier ./public est synchronisé
    * L'opération fonctionne en deux temps :
      1.  Elle procède à la comparaison des sites et fournit un code pour
          actualiser ce qui doit être actualisé
      2.  Elle procède à l'actualisation véritable
=end

SIMPLE_CHECK = false # mettre à faux pour procéder à la synchronisation

##
## Par prudence, on peut d'abord ne rien faire avec les fichiers
## serveurs qui n'existent pas en offline. Et les traiter dans un
## second temps
##
LONELY_ONLINE_DO_NOTHING = true

##
## Si true, détruit les fichiers serveurs qui n'existent pas
## en local
##
LONELY_ONLINE_REMOVE = (LONELY_ONLINE_DO_NOTHING == false) && true

require_relative 'class_synchro'

Synchro::synchronize unless SIMPLE_CHECK
Synchro::check
