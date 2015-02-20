- spinner uniq (-> gabarit)
  > méthode UI.spinner_start UI.spinner_stop
  > Tout main_article doit devenir transparent
* [SCORE]
  - Bouton pour "nettoyer" le pstore : il passe en revue les src, les checks par curl et détruit celles qui n'existent plus.
  - un bouton pour renoncer et détruire l'image
  - Faire un module dans 'module' qui sera commun à la partie admin et à la partie commentaires
  - Faire un css commun
    > méthode app.require_optional_css (comme require_optional_js)
    > l'utiliser pour "score[.css]"
  - Implémenter la fonctionnalité dans les commentaires
    - Donner la balise "[score:<id de l image>]" à l'user pour qu'il la copie-colle dans le texte.
  - Expliquer dans le manuel comment on crée une image avec l'interface. 
    > Expliquer comment la modifier (en gardant simplement le même nom)
  - Pouvoir piocher une image existante, à commencer par celles de l'article courant

* L'AFFIXE de l'image doit être fourni par l'application, pas par l'user.
  Le DOSSIER => dossier de l'article
  
* Aperçu du commentaire écrit