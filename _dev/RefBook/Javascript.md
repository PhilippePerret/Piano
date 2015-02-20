#Javascript

* [Requérir un script “optional”](#require_optional_script)


<a name='require_optional_script'></a>
##Requérir un script “optional”

Pour charger un script optionnel (du dossier `js/optional`), utiliser la méthode&nbsp;:

    [app.]require_optional_js <scripts>

`<scripts>` peut être un rel-path unique ou un Array de rel-path à partir du dossier `./public/page/js/optional/`.
  
Le `rel-path` peut être fourni indifféremment par&nbsp;:

* Le rel-path exact, p.e. `sous_dossier/monscript_mini.js`
* Le rel-path sans extension, p.e. `sous_dossier/monscript_mini`
* Le rel-path sans _mini, p.e. `sous_dossier/monscript`

