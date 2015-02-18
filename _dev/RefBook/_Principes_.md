#Principes

* La base du fonctionnement du site est l'`article`. Quelle que soit la page ou l'opération voulue, elle doit être définie dans un article, par le paramètre `article` contenant en valeur le path relatif depuis le dossier `./public/page/`.
  Si l'on veut atteindre la table des matières d'un dossier, il faut mettre en valeur le nom du dossier suivi de `/`. Dans ce cas, le dossier doit contenir un fichier `_tdm_.erb`
* Le dossier `public` contient tous les éléments updatables (= qui devront être synchronisés offline/online)&nbsp;;
* Seuls les scripts JS "*_mini.js" sont chargés
  Pour minifier un script, utiliser ./_dev/scripts/update_javascript.rb&nbsp;;
* Tout est "contenu", "géré" par une instance de la class `App` qu'on peut obtenir par : `App::current`
* Tous les articles sont définis dans le dossier `./public/page/article`. Pour faire référence à un article, il faut définir le paramètre `article` en mettant en valeur le path relatif depuis ce fichier.
  On peut utiliser la méthode d'helper (cf. lib/App/helper.rb) `link_to <path relatif>`
* Quand un dossier de même nom que l'affixe du fichier de la vue existe (même pour une vue insérée dans une autre), tous les éléments JS, CSS et RB de ce dossier sont chargés. Noter que pour les JS, ce sont seulement les fichiers qui se terminent par "_mini.js". Il faut toujours uglifier les javascripts grâce au script de développement prévu à cet effet.