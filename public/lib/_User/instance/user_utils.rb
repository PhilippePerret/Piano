# encoding: UTF-8
=begin

Méthodes d'instances User utilitaires

=end
class User
  
  ##
  #
  # Envoyer un mail à l'user
  #
  # Cette méthode est à utiliser lorsqu'on n'a qu'un seul mail
  # à envoyer, seulement à ce membre/follower
  #
  # +data_mail+ doit contenir au minium :
  #   :subject    Le sujet
  #   :message    Le message
  #
  def send_mail data_mail
    app.require_library 'mail'
    Mail::new(data_mail).send
  end  
  

  ##
  #
  # Procède au check d'un user-membre qui vient de s'identifier
  #
  #   * Vérifie les pointeurs pour l'UID
  #   * Vérifie que les données lecteurs soient valides
  #   * Pour un administrateur, vérifie s'il y a des opérations
  #     à effectuer
  #
  # TODO: Doit devenir OBSOLÈTE avec l'utilisation d'un pstore-session
  # provisoire unique.
  #
  def check_as_membre
    
    data_to_update = {}
    ##
    ## UID s'il n'est pas défini dans les données
    ##
    data_to_update.merge!( :uid => uid ) if get(:uid).nil?
    
    ##
    ## IP si elle n'est pas définie dans les données
    ##
    data_to_update.merge!( :remote_ip => remote_ip ) if get(:remote_ip).nil?
    
    ##
    ## Actualiser les données
    ##
    set data_to_update unless data_to_update.empty?
        
    ##
    ## Y a-t-il des opérations administrateur à faire
    ##
    if admin?
      # TODO:
      flash "Vous êtes reconnu comme Admin"
      debug "= TODO: Administrateur détecté (check des opérations à faire)"
    end
  end
  
end