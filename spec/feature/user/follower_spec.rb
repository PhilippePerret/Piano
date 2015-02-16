require "spec_helper"

feature 'User Follower' do
  
  # let(:data_ticket_unsubscribe) { @data_ticket_unsubscribe }
  
  scenario 'Un visiteur peut rejoindre la section pour suivre le cercle' do
    go_home
    click_main_menu "Rester informé"
    page_has_no_title
    subtitle_is "Rester informé"
  end
  
  scenario 'Le visiteur peut s’inscrire comme follower' do
    ##
    ## On récupère le ticket courant pour trouver le
    ## nouveau
    ##
    current_tickets = Dir["./data/ticket/**"]
    
    go_home
    click_main_menu "Rester informé"
    subtitle_is "Rester informé"

    ##
    ## Le visiteur remplit le formulaire et le soumet
    ##
    pseudo  = "Pseudo de #{Time.now.to_i}"
    mail    = "unmail#{Time.now.to_i}@chez.lui"
    Tests::set_var :mail_follower => mail
    
    fill_form_with 'form_mailing_list', {
      'user_pseudo' => pseudo,
      'user_mail'   => mail,
      'user_mail_confirmation' => mail,
      'user_reponse' => "pianiste",
      :submit => true
    }
    
    shot 'after-subscribe'
    page_has_content "#{pseudo}, vous avez été ajouté à la mailing-list du Cercle pianistique."
    
    ##
    ## Le visiteur est enregistré comme follower
    ##
    pstore_has_data 'followers', {mail: mail, pseudo: pseudo}
    
    ##
    ## Le visiteur possède un ticket de s'inscription
    ##
    path_ticket_user = nil
    Dir["./data/ticket/**"].each do |path|
      next if current_tickets.include? path
      path_ticket_user = path
    end
    expect(path_ticket_user).to_not eq(nil)
    Tests::set_var :path_ticket_unsub => path_ticket_user
    @data_ticket_unsubscribe = data_ticket path_ticket_user
    pstore_has_data 'followers', {mail: mail, ti_unsub: @data_ticket_unsubscribe[:id], tp_unsub: @data_ticket_unsubscribe[:protection]}
    
  end
  
  scenario 'Le visiteur peut se désinscrire avec son ticket' do
    pticket       = Tests::get_var :path_ticket_unsub
    mail_follower = Tests::get_var :mail_follower
    
    ##
    ##
    ##
    data_ticket_unsubscribe = Marshal::load(File.read(pticket))
    
    ##
    ## Le ticket doit exister
    ##
    if MODE_PRODUCTION
      fticket = Fichier::new pticket
      expect(fticket).to be_distant_exists
    else
      expect(File).to be_exist pticket
    end
    
    
    
    ##
    ## Le follower existe dans la table des followers
    ##
    found = false
    PStore::new(app.pstore_followers).transaction do |ps|
      found = ps.fetch(mail_follower, :unfound) != :unfound
    end
    expect(found).to eq(true)

    href = "http://#{cu_url}?ti=#{data_ticket_unsubscribe[:id]}&tp=#{data_ticket_unsubscribe[:protection]}"
    visit href
    shot "after-unsubscribe"
    
    ##
    ## La page affiche le bon message
    ##
    page_has_content "Votre désinscription a bien été prise en compte. Désolé de ne plus vous compter parmi nous."

    ## 
    ## Le ticket a été détruit
    ##
    if MODE_PRODUCTION
      fticket = Fichier::new pticket
      expect(fichier_ticket).to_not be_distant_exists
    else
      expect(File).to_not be_exist pticket
    end
    
    ##
    ## Le follower existe dans la table des followers
    ##
    not_found = false
    PStore::new(app.pstore_followers).transaction do |ps|
      not_found = ps.fetch(mail_follower, :unfound) == :unfound
    end
    expect(not_found).to eq(true)
    
    ##
    ## Il faudrait vérifier dans la table des lecteurs et des pointeurs
    ##
    
  end
end