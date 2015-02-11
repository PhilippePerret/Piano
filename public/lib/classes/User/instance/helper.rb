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
  
  def infos_persos_in_dd
    c  = []
    if blog
      url = "http://#{blog}"
      c << "Blog".in_a(target: '_blank', href: url)
    else
      c << "Blog".in_span(class: 'discret')
    end
    if site
      url = "http://#{site}"
      c << "Site".in_a(target: '_blank', href: url)
    else
      c << "Site".in_span(class: 'discret')
    end
    if chaine_yt
      url = "http://#{chaine_yt}"
      c << "YouTube".in_a(target: '_blank', href: url)
    else
      c << "YouTube".in_span(class: 'discret')
    end
    return c.join(' - ').in_dd(class: 'site')
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