# encoding: UTF-8
class NewSujetError < StandardError; end
class App
  
  class NewSujet
    
    LISTE_THEMES = [
      ["Donner des conseils", 'conseils'],
      ["Présenter une ou des techniques de jeu particulières", 'tech'],
      ["Expliquer un ou des points techniques", 'explitech'], 
      ["Expliquer un ou des points théoriques", 'explitheo'],
      ["Remettre les pendules à l'heure à propos d'un troll de forum…", 'pendheure']
    ]
    
    class << self
    
      attr_reader :art_sujet
      attr_reader :art_description
      
    
      def soumettre_sujet
        ##
        ## Les données doivent être valides
        ##
        check_param_new_sujet_or_raise
        
        ##
        ## On enregistre le nouveau sujet
        ##
        save_new_sujet
        
        ##
        ## On prévient l'administrateur
        ##
        avertir_admin
        
        param(:art_sujet => "", :art_description => "")
        flash "Merci pour cette suggestion de sujet, #{cu.pseudo} ! Elle sera étudiée avec le plus grand sérieux, et l'on vous fera part de la décision prise de le traiter ou non."
      rescue NewSujetError => e
        flash e.message
      rescue Exception => e
        debug e
        error e.message
      end
    
      ##
      #
      # Envoyer un mail à l'admin pour l'avertir
      #
      def avertir_admin
        send_mail_to_admin(
          subject:    "Nouveau sujet d'article proposé",
          message:    "Admin, #{cu.pseudo} vient de soumettre un nouveau sujet : “#{art_sujet}”.\n\nTu peux ramener le pstore “#{app.pstore_new_sujets}” en local pour le traiter."
        )
      end
      
      def save_new_sujet
        PStore::new(app.pstore_new_sujets).transaction do |ps|
          id = ps.fetch(:last_id, 0) + 1
          ps[:last_id] = id
          ps[id] = data_new_sujet
        end
      end
      
      ##
      #
      # Données enregistrées pour le nouveau sujet
      #
      def data_new_sujet
        liste_themes = LISTE_THEMES.collect do |duo|
          if param("cb_#{duo[1]}") == "on"
            duo[1]
          else
            nil
          end
        end.reject { |e| e.nil? }.join(',')
        {
          titre:          art_sujet,
          description:    art_description,
          created_at:     Time.now.to_i,
          submiter:       cu.id,
          submiter_type:  :membre,
          themes:         liste_themes,
          valided:        false
        }
      end
      
      def check_param_new_sujet_or_raise
        raise NewSujetError, "Vous ne pouvez pas soumettre de sujet !" unless cu.can_submit_subject?
        @art_sujet = param(:art_sujet).to_s.strip
        raise NewSujetError, "Il faut fournir un titre de sujet !" if art_sujet == ""
        @art_description = param(:art_description).to_s.strip 
        raise NewSujetError, "Merci de décrire un peu ce sujet." if @art_description == ""
        raise NewSujetError, "Ce sujet existe déjà dans la liste des sujets en projet…" if sujet_existe?
      end


      def sujet_existe?
        found = false
        PStore::new(app.pstore_new_sujets).transaction do |ps|
          ps.roots.collect do |root|
            next if root == :last_id
            if ps[root][:titre] == art_sujet
              found = true
              break
            end
          end
        end
        return found
      end
      
      
      # ---------------------------------------------------------------------
      #
      #     Méthodes d'helper
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # Retourne une liste UL des sujets déjà enregistrés
      #
      def liste_sujets_saved
        titres = PStore::new(app.pstore_new_sujets).transaction do |ps|
          ps.roots.collect do |root|
            next if root == :last_id
            ps[root][:titre]
          end
        end
        titres.collect do |titre|
          next if titre.nil? # :last_id
          titre.in_li
        end.join('').in_ul(style: 'list-style:none;')
      end
    end # << self App::NewSujet
    
  end # NewSujet
end