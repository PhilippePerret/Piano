# encoding: UTF-8
=begin
Module administration pour la gestion des articles
=end
raise "Seulement en offline" unless app.offline?
class App
  class Article
    
    class << self
      
      def menu_etats
        @menu_etats ||= begin
          ETATS.collect do |etat, detat|
            detat[:hname].in_option(value: etat)
          end.join('').in_select(name: 'etat', onchange: "$.proxy(Articles,'onchange_etat', this)()")
        end
      end
      
    end # << self
    
    ##
    #
    # On surclasse la méthode as_li pour l'administration
    #
    #
    def as_li options = nil
      options ||= {}
      tit = get(:titre)
      tit = idpath if tit.to_s == ""
      votes = get :votes
      (
        div_buttons_edition +
        id.to_s.in_span(class: 'id') +
        tit.in_span(class: 'titre') +
        "#{votes}".in_span(class: 'cote') +
        self.class.menu_etats.in_span(class: 'etat', 'data-id' => id)
      ).in_li(id: "li-#{id}", 'data-id' => id, 'data-cote' => votes, 'data-etat' => get(:etat))
    end
    def div_buttons_edition
      c = ""
      c << "[rm data]".in_a(onclick: "$.proxy(Articles,'remove_data', this)()", 'data-id' => id)
      c.in_span(class: 'edit_btns')
    end
    
    
    ##
    #
    # Méthode qui récupère le titre de l'article s'il n'a pas
    # été défini
    #
    # Cette méthode est appelée quand on arrive sur la section
    # d'administration des articles
    #
    def define_titre_if_any
      return unless get(:titre).to_s == ""
      if File.exist? fullpath
        code = File.read(fullpath).force_encoding('utf-8')
        tit = code.match(/<h2>(.*?)<\/h2>/).to_a[1].to_s.strip
        if tit != ""
          set :titre => tit
          flash "Titre de #{idpath} mis à “#{tit}”"
        end
      else
        debug "= Fichier #{fullpath} introuvable. Impossible de récupérer son titre"
      end
    end
  end
end