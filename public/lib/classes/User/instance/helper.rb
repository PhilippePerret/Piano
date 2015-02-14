# encoding: UTF-8
=begin

Méthodes d'helper pour la class User (instances)

=end
class User
  
  ##
  #
  # Le membre comme description (pour la liste des membres)
  #
  #
  def as_description
    "<dt>#{pseudo}</dt>" + 
    infos_persos_in_dd +
    description_in_dd
  end
  
  def description_in_dd
    description.split("\n").collect do |p|
      "<dd>" + ERB.new(p).result(app.bind) + "</dd>"
    end.join("")
  end
  
  def hdescription
    description.split("\n").collect do |p|
      ERB.new(p).result(app.bind).in_p
    end.join("")
  end
  
  def infos_persos_in_dd
    c  = []
    c << ( blog ? blog_as_link("Blog") : "Blog".in_span(class: 'discret') )
    c << ( site ? site_as_link("Site") : "Site".in_span(class: 'discret') )
    c << ( chaine_yt ? chaine_yt_as_link("YouTube") : "YouTube".in_span(class: 'discret') )
    return c.join(' - ').in_dd(class: 'site')
  end
  
  ##
  #
  # @return un lien vers le site (ou "" si aucun site)
  #
  def site_as_link titre = nil
    return "" unless site
    (titre || site.to_s).in_a(target: '_blank', href: "http://#{site}")
  end
  
  ##
  #
  # @return un lien vers le blog (ou "" si aucun blog)
  #
  def blog_as_link titre = nil
    return "" unless blog
    (titre || blog.to_s).in_a(target: '_blank', href: "http://#{blog}")
  end
  
  ##
  #
  # @return un lien vers la chaine youtube (ou "")
  #
  def chaine_yt_as_link titre = nil
    return "" unless chaine_yt
    (titre || chaine_yt.to_s).in_a(target: '_blank', href: "http://#{chaine_yt}")
  end
  
  ##
  #
  # @Retourne le nom humain du grade
  #
  #
  def hgrade
    @hgrade ||= User::GRADES[grade][:hname]
  end
  
  ##
  #
  # @return l'user sous forme de LI
  #
  #
  def as_li params = nil
    (
      edit_button.in_span(class: 'btn_edit') +
      pseudo.in_span(class: 'pseudo') +
      hgrade.in_span(class: 'grade')
    ).in_li(class: 'membre')
  end
  
  ##
  #
  # @return le code d'un bouton pour éditer le membre
  #
  def edit_button
    return "" unless app.offline?
    "[edit]".in_a(href: "?article=admin/membres&user_id=#{id}")
  end
 
end