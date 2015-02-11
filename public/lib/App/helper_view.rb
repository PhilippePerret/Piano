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
  
  
  ##
  #
  # @return le code pour embedder une vidéo YouTube
  #
  def video_youtube code
    <<-HTML
<iframe width="560" height="315" src="https://www.youtube.com/embed/#{code}" frameborder="0" allowfullscreen></iframe>
    HTML
  end
end