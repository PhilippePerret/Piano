#Les Opérations “O”

* [Formulaire pour appeler une opération “o”](#formulaire_operation_o)


J'appelle «Opérations “O”» les opérations qui peuvent être appelées par URL (formulaire ou lien) depuis n'importe quel article. Elles portent ce nom car elles sont définies par le paramètre `o`.

Ces opérations sont appelées par la méthode&nbsp;:

    # in ./public/lib/App/operation.rb
    <app>.opere

<a name='formulaire_operation_o'></a>
##Formulaire pour appeler une opération “o”

@syntaxe

    form_o(
      article:    "article/path",   # l'article vers lequel il faut retourner
      button:     "Nom bouton",     # Nom du bouton (ou titre:)
      o:          '<opération>',
      o1:         '<première argument>',
      ...
      oX:         '<10e argumnet>'
      --------------
        optionnel
      --------------
      form_id     ID du formulaire
      onclick:    La méthode javascript à appeler avant de soumettre le
                  formulaire (pour confirmation, vérification ou préparation
                  des données)
    )


* [Création d'une nouvelle opération “o”](#creation_new_operation)
<a name='creation_new_operation'></a>
##Création d'une nouvelle opération “o”

Pour créer une nouvelle opération “o”, il suffit de créer son fichier dans le dossier&nbsp;:

    ./public/lib/module/operation_o/

L'AFFIXE DU FICHIER doit avoir le même nom que la MÉTHODE dans le fichier.

###Nom de la méthode

La méthode doit avoir le même nom que le nom de l'opération.

Par exemple, l'opération&nbsp;:

    download

… sera définie dans le fichier&nbsp;:

    ./public/lib/module/operation_o/download.rb

… qui définira la méthode&nbsp;:

    # encoding: UTF-8
    class App
      class Operation
        class << self
    
          def download
            
            … son code …
          end
        end
      end
    end
    

###Définition des paramètres

On peut bien sûr utiliser n'importe quel nom de paramètre pour passer des valeurs à ces opérations, mais pour la cohérence on peut utiliser&nbsp;:

    oX

Par exemple, s'il y a deux arguments&nbsp;:

    o1 et o2

Ces paramètres sont bien sûr récupérés dans la méthode opération par&nbsp;:

    param('o1')
    et
    param('o2')
    