#Synopsis général

De façon très schématique&nbsp;:

    * L'application charge les librairies utiles
      -> ./public/lib/required.rb
    * Elle appelle la méthode qui va traiter les opérations « o »
      -> app.opere
    * Elle appelle la méthode `output` de l'instance App
      -> app.output
    * La méthode `output` charge la vue `gabarit.erb`
    * `gabarit.erb` charge les éléments de page dont `content.erb`
    * `content.erb` appelle la méthode `<app>#load_article` qui charge
      l'article demandé.

##Réflexions

Pour les méthodes de "traitement", on pourrait imaginer un appel, avant l'appel de `output` qui traite certaines opérations. Ces opérations serait définies par&nbsp;: 

    Variable          Description                 Exemple
    ---------------------------------------------------------------------
      o               Nom de l'opération          upload
      o1              Première donnée             path/to/file/to/upload.rb
      o2              Deuxième donnée opération   set_last_time