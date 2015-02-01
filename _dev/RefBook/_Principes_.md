#Principes

* Le dossier `public` contient tous les éléments updatables (= qui devront être synchronisés offline/online)&nbsp;;
* Seuls les scripts JS "*_mini.js" sont chargés
  Pour minifier un script, utiliser ./_dev/scripts/update_javascript.rb&nbsp;;
* Tout est "contenu", "géré" par une instance de la class `App` qu'on peut obtenir par : `App::current`
* Tous les articles sont définis dans le dossier `./public/page/article`. Pour faire référence à un article, il faut définir le paramètre `article` en mettant en valeur le path relatif depuis ce fichier.
  On peut utiliser la méthode d'helper (cf. lib/App/helper.rb) `link_to <path relatif>`