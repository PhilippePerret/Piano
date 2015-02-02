# encoding: UTF-8
class App
  
  ##
  #
  # Procédure d'ajout d'un user à la mailing list
  #
  #
  def add_to_mailing_list
    check_value_add_mailing_list_or_raise
    
    ##
    ## On ajoute l'utilisateur dans le pstore des followers
    ##
    nombre_followers = PStore::new(pstore_mailing).transaction do |ps|
      last_id = ps.fetch(:last_id, 0) + 1
      ps[last_id]   = {mail: param(:user_mail), name: param(:user_name), created_at: Time.now.to_i}
      ps[:last_id]  = last_id
      ps.roots.count - 1
    end

    ##
    ## On avertit l'admin de la nouvelle inscription
    ##
    require_module 'mail'
    send_mail_to_admin(
      from:       param(:user_mail),
      subject:    "Nouveau follower pour le #{short_name}",
      message:   "Admin\n\nUn nouvel utilisateur s'est inscrit à la mailing list : #{param :user_mail}.\n\nRien à faire, c'est juste une information. Pour information aussi, le nombre de followers du site est actuellement de #{nombre_followers} personnes."
    )
    
  rescue Exception => e
    error e.message
  end
  
  ##
  #
  # Check les valeurs transmises pour l'ajout à la mailing list
  #
  def check_value_add_mailing_list_or_raise
    uname     = param(:user_name).strip
    umail     = param(:user_mail).strip
    umailconf = param(:user_mail_confirmation).strip
    ureponse  = param(:user_reponse).strip.downcase
    raise "Vous devez fournir un nom ou un pseudo." if uname == ""
    raise "Vous devez fournir votre mail, pour qu'on puisse vous avertir." if umail == ""
    raise "Vous devez fournir la confirmation de votre mail." if umailconf == ""
    raise "Votre confirmation de mail ne correspond pas… Merci de le vérifier." if umail != umailconf
    raise "Ce mail est déjà dans la mailing-list !" if mail_exists_in_mailing?(umail)
    unless ["un pianiste", "pianiste", "claviériste", "un claviériste", "clavieriste", "un clavieriste"].include? ureponse
      raise "Êtes-vous un robot ? Dans le cas contraire, merci de répondre correctement à la question anti-robot."
    end
  rescue Exception => e
    raise e
  end
  
  ##
  #
  # Vérifie que l'adresse n'existe pas déjà 
  #
  def mail_exists_in_mailing? mail
    found = false
    PStore::new(pstore_mailing).transaction do |ps|
      ps.roots.reject{|e| e == :last_id}.each do |id|
        if ps[id][:mail] == mail
          found = true
          break
        end
      end
    end
    return found
  end
end