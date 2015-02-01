# encoding: UTF-8
=begin

Méthodes d'helper

Dans le vue ERB, on peut simplement les appeler par `<méthode name>`.

=end
class App
  
  ##
  #
  # Retourne un lien (<a>) vers l'article de path relatif +relpath_art+ dans
  # le dossiser `./public/page/article`.
  #
  # +options+
  #   form:       Si TRUE (par défaut), retourne un lien sous forme de 
  #               formulaire
  #
  def link_to titre, relpath_art, options = nil
    options ||= {}
    options.merge!(form: true) unless options.has_key?(:form)
    if options[:form]
      #
      # => Retourne un lien sous forme de formulaire
      #
      "<form class='alink' action='index.rb' method='POST' onclick='this.submit()'><input type='hidden' name='article' value='#{relpath_art}' />#{titre}</form>"
    else
      #
      # => Retourne un lien <a>
      #
      relpath_art = CGI::escape relpath_art
      "<a href='?article=#{relpath_art}'>#{titre}</a>"
    end
  end
  
  ##
  #
  # Retourne un lien textmate pour éditer l'article courant
  #
  #
  def link_offline_to_edit_article
    return "" if online?
    href  = "txmt://open/?url=file://#{article_full_path}"
    lk    = "<a href='#{href}'>[edit]</a>"
    "<div class='right small'>#{lk}</div>"
  end
  
end