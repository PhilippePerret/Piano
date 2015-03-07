# encoding: UTF-8
=begin

Méthodes utiles à l'analyse du prélude BWV 999

=end
def image_partielle offset, size = nil, positionning = false
  image('pratiques/bwv999/vierge.png', { 
    icare: true, offset: offset , size: size, 
    positionning: positionning, 
    center: true } )
end

def vue nom
  view (relpath_de_la_vue nom)
end
def relpath_de_la_vue nom
  "article/pratiques/analyse_bach_bwv999/#{nom}.erb"
end
def link_to_vue titre, nom
  link_to titre, "pratiques-analyse_bach_bwv999?pan=#{nom}"
end
def path_next_article
  cur_numero = param(:pan).to_i
  next_numero = (cur_numero + 1).to_s.rjust(3, '0')
  path = File.join('.','public', 'page', relpath_de_la_vue(next_numero) )
  if File.exist? path
    "pratiques-analyse_bach_bwv999?pan=#{next_numero}"
  else
    nil
  end
end
