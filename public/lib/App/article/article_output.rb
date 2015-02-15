# encoding: UTF-8
=begin

Méthodes d'instance qui permettent de sortir le code HTML utile
pour un article.

=end
class App
  class Article
    
    
    ##
    #
    # Méthode définissant le code du _body_.erb, appelée depuis un
    # fichier _body_.erb
    #
    #
    def body_content titre, options = nil
      c = ""
      c << app.link_to_tdm unless tdm?
      c << titre.in_h1
      c << view
      unless tdm? || en_projet?
        c << (app.link_to_tdm + links_to_ancres_evaluation).in_div(style: 'margin-top:4em')
        c << section_comments
      end
      return c
    end
    
    ##
    #
    # Retourne le DIV contenant les liens sous l'article qui
    # permettent de se rendre aux sections des commentaires et
    # du vote de l'article.
    #
    # Note: Ces parties tiennent compte du fait que l'user
    # est trustable ou non
    #
    def links_to_ancres_evaluation
      links = []
      if cu.trustable?
        links << link_to_ancre_noter_article
        links << link_to_ancre_write_comments
      end
      links << link_to_ancre_comments if has_comments_valided?
      return "" if links.empty?
      links.join("&nbsp;.&nbsp;").in_div(class: 'small')
    end
    
    ##
    #
    # Lien vers ancre pour noter l'article
    # Note: Seulement si l'utilisateur est trustable
    #
    def link_to_ancre_noter_article
      return "" unless cu.trustable?
      "Noter l'article".in_a(href: "#coter_article")
    end
    
    ##
    #
    # Lien vers ancre pour laisser un commentaire sur l'article
    # Note: Seulement si l'utilisateur est trustable
    #
    def link_to_ancre_write_comments
      return "" unless cu.trustable?
      "Laisser un commentaire".in_a(href: "#comment_article")
    end
    
    ##
    #
    # Lien pour rejoindre les commentaires de l'article
    #
    def link_to_ancre_comments
      return "" unless has_comments_valided?
      "Lire les commentaires (#{comments(valided: true).count})".in_a(href: "#lire_comments")
    end
    
    
    ##
    #
    # Méthode appelée par body_content ci-dessus retournant le 
    # code de l'article précisément demandé.
    #
    def view
      begin
        app.view "article/#{folder}/#{name}"
      rescue RedirectError => e
        ##
        ## En cas de redirection par exemple
        ##
        ""
      rescue Exception => e
        raise e
      end
    end
    
    
    ##
    #
    # Retourne l'article dans un LI, avec les informations minimales.
    #
    # Noter que cette méthode est surclassées par une méthode administration
    # pour avoir des informations plus complètes et des boutons d'édition
    # de l'article
    #
    def as_li options = nil
      options ||= {}
      tit = get(:titre)
      tit = idpath if tit.to_s == ""
      (
        tit.in_span(class: 'titre') +
        (options[:votes] ? "#{get :votes}" : '').in_span(class: 'cote')
      ).in_li('data-id' => id)
    end
    
  end # Article
end # App