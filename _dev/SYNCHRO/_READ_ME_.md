#Synchro

Ce dossier permet de vérifier la synchronisation entre deux sites et les synchroniser (par SSH).

Il peut être utilisé dans n'importe quelle application à partir du moment où les requis suivants sont respectés.

##Requis

* Le script `synchro.rb` de ce dossier doit être placé à la racine du SERVEUR (PAS du site).
* Le site doit se trouver dans un dossier `www` à la racine du serveur.
* Définir dans le fichier `config.rb` les données pour le site à synchroniser.

##Checker la synchronisation

Afficher le fichier `SYNCHRONIZE.rb` et mettre SIMPLE_CHECK à `true`. Lancer le script.

##Synchroniser les deux sites

Afficher le fichier `SYNCHRONIZE.rb` et mettre SIMPLE_CHECK à `false`. Lancer le script.

##Développements

* Pouvoir passer un argument à `Synchro::synchronize` pour ne synchroniser qu'un dossier.
* Pouvoir décider s'il faut détruire ou downloader des fichiers qui ne se trouvent que sur le site distant. Pour le moment, ils sont downloadés automatiquement, ce qui n'est pas forcément idéal quand on modifie le nom d'un module et qu'on oublie de le détruire sur le site distant. D'autant que ses méthodes risquent de surclasser de nouvelles méthodes.