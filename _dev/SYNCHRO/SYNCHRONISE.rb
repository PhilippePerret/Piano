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

SIMPLE_CHECK = true # mettre à faux pour procéder à la synchronisation


require_relative 'class_synchro'

Synchro::synchronize unless SIMPLE_CHECK
Synchro::check
