#Cron quotidien

* [Code dans le cron-tab](#code_crontab)
* [Édition de la cron-tab pour modifier les jobs cron](#editer_cron_tab)


<a name='code_crontab'></a>
##Code dans le cron-tab

Note : Afficher les caractères invisibles pour être sûr d'avoir des espaces uniques entre les données (est-ce vraiment indispensable ?).

    # Tous les jours
    0 0 * * * ruby /home/piano/www/public/lib/module/run_cron.rb
    
    # Toutes les heures (pour les tests)
    0 * * * * ruby /home/piano/www/public/lib/module/run_cron.rb

<a name='editer_cron_tab'></a>
##Édition de la cron-tab

Pour modifier la cron-tab, c'est-à-dire définir les cron-jobs à exécuter, ouvrir Terminal et taper&nbsp;:

    $ ssh piano@ssh.alwaysdata.com
    ssh> crontab -e