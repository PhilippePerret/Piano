# encoding: UTF-8
class App
  class Operation
    class << self      
      
      ##
      #
      # Pour voter pour les articles EN PROJET
      #
      # Principe : les 20 premiers articles prennent des points de 20 à 1
      # et les autres n'ont rien.
      #
      # Note: Le vote ne peut être enregistré que si l'utilisateur n'a
      # pas encore voté. On le cherche dans la session et dans l'IP
      # Un user peut revoter après deux mois.
      #
      def vote_articles
        ##
        ## Est-ce que l'utilisateur peut vraiment voter ?
        ##
        unless cu.can_vote_articles?
          return error "Vous avez déjà voté pour l'ordre de ces articles."
        end
        
        ##
        ## On peut enregistrer les votes sur les articles
        ##
        ordre = param('o1').split('-').collect{|e| e.to_i}
        PPStore::new(App::Article::pstore).transaction do |ps|
          vote = 20
          ordre.each do |article_id|
            ps[article_id][:votes] += vote
            vote -= 1
            break if vote == 0
          end
        end
        
        ##
        ## On enregistre la date de dernier vote du reader
        ##
        cu.set_last_time_vote
        
        ##
        ## On avertit l'administration
        ##
        ## Mode sans erreur
        ##
        send_mail_to_admin(
          subject:      "Nouveau vote pour ordre des articles",
          message:      "Admin, je t'informe qu'un nouveau vote vient d'être effectué pour la liste des articles.\n\nJe te conseille de downloader le pstore pour voire le changement.\n\nVote effectué par le reader d'UID #{cu.uid}."
        ) rescue nil
        
        flash "Votre vote a bien été enregistré. Merci à vous."
      end
    end
  end
end