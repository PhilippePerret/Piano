# encoding: UTF-8
class Array
  
  # Construit un menu select à partir de la liste fournie
  #
  # Chaque élément (qui donnera un item de menu) peut être un array ou un
  # hash
  #
  # @param  params    Les paramètres envoyés pour définir le menu
  #         
  #     :key_title    Clé (ou indice) dans l'élément pour trouver le titre
  #     :key_value    Clé (ou indice) dans l'élément pour trouver la valeur à
  #                   donner à l'OPTION (value)
  #     :key_selected Clé (ou indice) à prendre pour trouver l'élément 
  #                   sélectionné
  #     :selected     Valeur que doit avoir la clé :key_selected de l'élément
  #                   pour être l'élément sélectionné
  #     :name         Le name à donner au select
  #     ... autre paramètres HTML à ajouter au SELECT
  #
  #
  # Par défaut, c'est un array d'arrays, ou le premier élément est le titre
  # à donner à l'option et le second élément est la valeur de l'option.
  # Mais on peut envoyer ce qu'on veut, pour en tirer ce qu'on veut en
  # définissant les attributs :key_title et :key_value dans params
  #
  # Pour des arrays, :key_title sera l'indice de l'élément à prendre comme 
  # titre et :key_value sera l'indice de l'élément à prendre comme valeur.
  # Pour des hashs, :key_title sera la clé de l'élément à prendre comme titre
  # et :key_value sera la clé de l'élément à prendre comme valeur.
  #
  def in_select params = nil
    
    is_hash   = self[0].class == Hash
    is_array  = !is_hash

    # La clé à utiliser pour trouver le titre
    # Par défaut :id
    key_title = params.delete(:key_title)
    key_title ||= ( is_array ? 1 : :id )
    # La clé à utiliser pour trouver la valeur
    # Par défaut :value
    key_value = params.delete(:key_value)
    key_value ||= ( is_array ? 0 : :value )
    # La clé à utiliser pour la sélection
    key_selected  = params.delete( :key_selected )
    key_selected ||= ( is_array ? 0 : :value )

    params[:name] = params[:id]   if params[:name].nil?
    params[:id]   = params[:name] if params[:id].nil?
    selected      = param( params[:name])
    
    self.collect do |ditem|
      ditem[key_title].in_option(value: ditem[key_value], selected: ditem[key_selected] == selected )
    end.join('').in_select(id: params[:id], name: params[:name], class: params[:class])
  end
end