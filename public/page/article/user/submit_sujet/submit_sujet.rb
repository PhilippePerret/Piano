# encoding: UTF-8


app.require_module 'sujets_soumis'

class App
  
  class NewSujet
    
    
    class << self
    
      attr_reader :art_titre
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
        
        param(:art_titre => "", :art_description => "")
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
          message:    "Admin, #{cu.pseudo} vient de soumettre un nouveau sujet : “#{art_titre}”.\n\n"+
          "Vous pouvez ramener le pstore “#{File.basename(app.pstore_new_sujets)}” en local pour le traiter."
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
        {
          titre:          art_titre,
          description:    art_description,
          created_at:     Time.now.to_i,
          submiter:       cu.id,
          submiter_type:  :membre,
          themes:         get_themes_in_cb.join(','),
          valided:        false
        }
      end
      
      def check_param_new_sujet_or_raise
        check_param_sujet
        raise NewSujetError, "Ce sujet existe déjà dans la liste des sujets en projet…" if sujet_existe?(art_titre)
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