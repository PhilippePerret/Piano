# encoding: UTF-8

app.require_module 'sujets_soumis'
class App
  class NewSujet
    class << self
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes opération administration
      #
      # ---------------------------------------------------------------------
      
      # ---------------------------------------------------------------------
      #
      #   Opération
      #
      # ---------------------------------------------------------------------
      
      def edit
        sujet = new param(:art_id).to_i
        sujet.dispatch_in_param
      end
      
      def valider
        sujet = new param(:art_id).to_i
        sujet.set_valided
        
        ##
        ## Envoyer un mail au submitter
        ##
        submiter = User::get sujet.submiter.to_i
        submiter.send_mail(
          subject:        "Sujet d'article validé",
          message:        "#{submiter.pseudo},\n\n"+
          "J'ai le plaisir de vous annoncer que votre sujet “#{sujet.titre}” a été validé et a été placé sur la liste des articles à traiter.\n\n"+
          "Pour vous remercier, vous avez la possibilité de voter à nouveau pour l'ordre des articles en projet, même si vous l'avez déjà fait récemment.\n\n"+
          "Merci encore à vous pour la soumission de cet article !\n\n"+
          "Bien à vous\n\n"+
          "LCP"
        )
        ##
        ## On ré-initiliase la date de vote de l'user
        ##
        submiter.store_reader( :last_vote => nil )
        
        flash "Sujet validé. Le submitter a été prévenu et sa date de vote a été ré-initialisée."
      end
      
      def invalider
        sujet = new param(:art_id).to_i
        sujet.unset_valided
        flash "Sujet invalidé."
      end
      
      def soumettre_sujet
        sujet = new param(:art_id).to_i
        check_param_sujet
        sujet.set_values
        sujet.save
        if param(:sujet_to_article) == "on"
          ##
          ## Il faut valider l'article si ça n'est pas encore
          ## fait
          ##
          valider unless sujet.valided
          ##
          ## On peut transformer le sujet en article
          ##
          sujet.transform_to_article
        else
          flash "Sujet actualisé."
        end
      rescue NewSujetError => e
        error e.message
      rescue Exception => e
        error e.message
        debug e
      end
      
      
    end # << self App::NewSujet
    
  end
end