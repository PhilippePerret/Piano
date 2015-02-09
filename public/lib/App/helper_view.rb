# encoding: UTF-8

class App

  ##
  #
  # Pour construire une rangée de formulaire
  #
  # @usage      row("<libellé>", "<champ>")
  #
  #
  def row lib, val, options = nil
    options ||= {}
    if options.has_key? :class
      options[:class] = [options[:class]]
    else
      options = options.merge(class: [])
    end
    lib = '&nbsp;' if lib.nil? || lib == ""
    options[:class] << 'row'
    options[:class] = options[:class].join(' ').strip
    (lib.in_span(class: 'libelle')+val.in_span(class: 'value')).in_div(options)
  end
  
end