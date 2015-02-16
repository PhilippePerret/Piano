##
#
# Remplissage d'un formulaire
#
# +form_id+   ID du formulaire à remplir
# +form_data+   Les données à mettre
#       En clé, le name du champ (ou l'id)
#       En value
#         Si c'est un STRING, c'est un champ de texte
#         Si c'est un HASH, défini :type (type du champ parmi :select,
#         :checkbox, etc.) et :value (valeur à donner)
#     Valeurs spéciales
#        :submit => true      Soumet le formulaire par un bouton submit
def fill_form_with form_id, form_data
  submit_it = form_data.delete(:submit)
  within("form##{form_id}") do
    form_data.each do |key, value|
      case value
      when String then fill_in key, with: value
      when Hash
        case value[:type]
        when :select    then choose(value[:value], from: key)
        when :checkbox  then value[:value] ? check(key) : uncheck(key)
        else
          puts "Pour le moment, je ne sais pas encore traiter les champs #{value[:type]}"
        end
      else
        puts "Dans fill_form_with, il faut que la valeur soit un String ou un Hash"
      end
    end
    page.find('input[type="submit"]').click if submit_it
  end
  shot "after-fill-form-#{form_id}"
end