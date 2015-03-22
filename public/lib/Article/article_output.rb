# encoding: UTF-8
=begin

Méthodes d'instance qui permettent de sortir le code HTML utile
pour un article.

=end
class App
  class Article
    
    ##
    #
    # Confection du contenu (@content) de l'article
    #
    # Méthode principal, appelée par la vue `content.erb', qui définit
    # le code de l'article et le place dans @content
    #
    def load
      @content = app.view( "article/#{base}" )
    end
    
    
    ##
    #
    # Méthode définissant le code du _body_.erb, appelée depuis un
    # fichier _body_.erb
    #
    #
    def body_content titre, options = nil
      options ||= {}
      c = ""
      c << infos_admin_article if offline?
      c << app.link_to_tdm unless tdm?
      c << titre.in_h1
      c << options[:sous_titre].in_h2 if options.has_key?(:sous_titre)
      c << view
      c << direct_link
      unless tdm? || en_projet?
        c << bottom_buttons
        c << section_comments unless article_admin?
      end
      return c
    end
    
    def bottom_buttons
      (
        bottom_link_to_next_article +
        app.link_to_tdm + 
        links_to_ancres_evaluation
      ).in_div(id:'botlkart')
    end
    
    ##
    #
    # Retourne un DIV avec les infos administrateur de l'article
    # courant, dont son ID
    #
    def infos_admin_article
      @infos_admin_article ||= begin
        c = ""
        c << "Article-id: #{id}"
        c.in_div(id: 'infos_admin_article')
      end
    end
    
    ##
    #
    # Return une section contenant le lien direct vers
    # la page à copier-coller
    #
    def direct_link
      return "" unless complete?
      (
        "Lien direct (à copier-coller dans un mail, une page web, etc.)".in_div +
        "<input type='text' value='#{FULL_URL}?a=#{CGI::escape idpath}' onfocus='this.select()' style='width:100%;font-size:11pt' />"
      ).in_div(class: 'directlk small')
    end
    
    
    ##
    #
    # Lien vers l'article suivant
    #
    def bottom_link_to_next_article
      return "" if article_admin?
      ne = self.next
      return "" unless ne
      p = ne.class == Hash ? ne[:path] : ne
      app.button_next(p, :inline => true).in_div(class: 'nextbtn fright')
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
      return "" if article_admin?
      links = []
      if cu.trustable? && cu.can_note_article?(id)
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
      "Noter".in_a(href: "#coter_article")
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
      "Commentaires (#{comments(valided: true).count})".in_a(href: "#lire_comments")
    end
    
    
    ##
    #
    # Méthode appelée par body_content ci-dessus retournant le 
    # code de l'article précisément demandé.
    #
    def view
      begin
        code_view = app.view "article/#{folder}/#{name}"
        code_view.prepend(alerte_when_audio_in_page) if code_view.index('</audio>')
        return code_view
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
    # @return une balise audio d'alerte qui s'affichera si le navigateur 
    # ne peut pas lire les fichiers audio.
    #
    def alerte_when_audio_in_page
      <<-HTML
<audio>
<div class='warning'>
Cet article contient des exemples audio, mais votre navigateur est trop ancien pour les entendre. Nous vous suggérons de l'actualiser pour profiter pleinement de cet article.
</div>
</audio>
      HTML
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
      tit = get(:titre) || titre_in_file
      tit = idpath if tit.to_s == ""
      (
        tit.to_s.in_span(class: 'titre') +
        (options[:votes] ? "#{get :votes}" : '').in_span(class: 'cote')
      ).in_li('data-id' => id)
    end
    
  end # Article
end # App