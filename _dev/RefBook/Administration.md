#Administration

La partie administration fonctionne comme des articles normaux.

Ces articles sont définis dans&nbsp;:

    ./public/page/article/admin/

Pour la plupart, les méthodes sont des méthodes propres de `App` qui ne sont chargées QUE lorsque l'application est utilisée OFFLINE. Seules certaines opérations nécessitent d'être ONLINE. Mais la section administration locale peut travailler avec les données sur le serveur distant.

Les extensions propres de `App` sont définies dans&nbsp;:

    ./public/lib/administration/App
    # Ce dossier est chargé intégralement
    