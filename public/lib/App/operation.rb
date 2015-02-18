# encoding: UTF-8
=begin

Méthodes qui gèrent les opérations « o » (toutes les opérations qui ne
peuvent pas être gérées par les vues elles-même)

=end
class App
  
  ##
  #
  # Exécute une opération "o" (cf. RefBook)
  #
  def opere
    return if param('o').to_s == ""
    op = param('o').to_sym
    require_module "operation_o/#{op}"
    App::Operation::send op
  end
  
  ##
  #
  # Retourne un formulaire-boutton pour appeler l'opération
  #
  def form_o args
    o   = args.delete(:o)
    ox  = []
    (1..10).collect do |io|
      k = "o#{io}"
      k_sym = k.to_sym
      break unless args.has_key? k_sym
      ox << args[k_sym].in_hidden(name: k)
    end
    
    # Classe CSS du formulaire
    if args.has_key? :class
      args[:class] = [args[:class]] unless args[:class].class == Array
    else
      args[:class] ||= []
    end
    args[:class] << 'form_o'
    args[:class] = args[:class].join(' ')
    
    art = args.delete(:article).to_s.in_hidden(name: 'article')
    btn = (args.delete(:button) || args.delete(:titre)).in_submit(class: 'btn', onclick: args[:onclick])
    (o.in_hidden(name: 'o') + ox.join("") + art + btn).in_form(class: args[:class], id: args[:form_id])
  end

end