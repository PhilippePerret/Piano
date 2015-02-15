# encoding: UTF-8
require 'digest/md5'
class User
  
  ##
  #
  # @return l'ID unique et absolu de l'user, qu'il soit membre,
  # follower ou autre
  # Cf. RefBook > User.md pour le détail
  #
  def uid
    if @uid === nil
      @uid = if false == trustable?
        nil
      else
        if membre?
          get_uid_with(id) || created_as_lecteur
        elsif follower?
          get_uid_with(mail) || created_as_lecteur
        else
          get_uid_with(remote_ip) || created_as_lecteur
        end
      end
      
      ##
      ## La première fois qu'on demande l'UID, il faut enregistrer
      ## l'id de session courante dans les données du lecteur si nécessaire
      ##
      ## Noter que la méthode en profite aussi pour faire quelques vérifications
      ## sur les pointeurs, et détruit celui d'après l'ancien session-id s'il
      ## existe.
      ##
      save_session_id
      
    end
    return @uid
  end
  
  ##
  #
  # Crée l'user comme lecteur et retourne son UID
  #
  def created_as_lecteur
    return nil unless trustable?
    ##
    ## Avant de le créer, il faut voir si ce n'est pas un
    ## user déjà connu, mais pas encore tout à fait identifié, par
    ## exemple un membre qui arrive sur le site, mais qui ne s'est
    ## pas encore identifié.
    ##
    uid_checked = get_uid_with app.session.id
    if uid_checked.nil?
      uid_checked = get_uid_with remote_ip
    end
    return uid_checked unless uid_checked.nil?

    ##
    ## ID qui sera consigné
    ##
    id_intbl = case true
    when membre?    then id
    when follower?  then mail
    else nil
    end
  
    ##
    ## Type de l'user
    ##
    type_intbl = case true
    when membre?    then :membre
    when follower?  then :follower
    else nil
    end
    
    new_uid = nil
    PStore::new(app.pstore_lecteurs).transaction do |ps|
      new_uid = ps.fetch(:last_uid, 0) + 1 
      ps[:last_uid] = new_uid

      ##
      ## Données enregistrées comme lecteur
      ## 
      ## Note : elle pourront être modifiées lorsque le simple user
      ## change de statut (-> follower -> membre)
      ##
      ps[new_uid] = {
        uid:            new_uid,
        type:           type_intbl,   # :membre, :follower ou nil
        id:             id_intbl,     # id (membre) mail (follower) ou nil
        membre:         membre?,
        follower:       follower?,
        last_connexion: Time.now.to_i,
        last_vote:      nil,
        articles_noted: []
      }
      debug "Création d'un nouveau lecteur : {"+
        ps[new_uid].collect{|k,v| "#{k.inspect} => #{v.inspect}"}.join("\n") + "}"
    end
    
    ##
    ## On crée les pointeurs
    ##
    create_pointeurs_to new_uid
    
    ##
    ## Si l'user est un membre, on enregistre son UID dans ses
    ## données
    ##
    if membre?
      set(:uid => new_uid) 
      debug "* Enregistrement de l'UID #{new_uid} dans les données du membres"
    end
    
    return new_uid
  end
  ##
  #
  # Attribue un UID unique et absolu pour l'user et LE RETOURNE
  #
  def create_pointeurs_to new_uid
    return nil unless trustable?
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|
      ps[id]              = new_uid if membre?
      ps[mail]            = new_uid if membre? || follower?
      ps[remote_ip]       = new_uid
      ps[app.session.id]  = new_uid unless app.session.nil? # tests
    end
  end
  
  ##
  #
  # Return l'UID de l'user, quel qu'il soit. Mais il faut utiliser
  # seulement la méthode-propriété `uid' qui créera l'user s'il
  # n'existe pas encore.
  #
  def get_uid_with uref
    return nil unless trustable?
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|
      ps.fetch(uref, nil)
    end
  end
  
  ##
  #
  # @return la valeur de la propriété +key+
  #
  #
  def get key
    data[key]
  end
  
  ##
  #
  # Définit des données de l'user
  #
  #
  def set hdata
    PStore.new(User::pstore).transaction do |ps|
      raise "User inconnu" unless ps.roots.include? id
      hdata.each do |k,v|
        ps[id][k] = v
        self.instance_variable_set("@#{k}", v)
      end
    end
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes propriétés
  #
  # ---------------------------------------------------------------------
  def pseudo;       @pseudo       ||= data[:pseudo]       end
  def mail;         @mail         ||= data[:mail]         end
  def grade;        @grade        ||= data[:grade]        end
  def blog;         @blog         ||= data[:blog]         end
  def chaine_yt;    @chaine_yt    ||= data[:chaine_yt]    end
  def site;         @site         ||= data[:site]         end
  def description;  @description  ||= data[:description]  end
  def password;     @password     ||= data[:password]     end
  def cpassword;    @cpassword    ||= data[:cpassword]    end
  def updated_at;   @updated_at   ||= data[:updated_at]   end
  def created_at;   @created_at   ||= data[:created_at]   end
  
  
  ##
  #
  # Méthode qui récupère les données du formulaire et les enregistre
  #
  #
  def get_and_save
    get_form_data
    check_data_or_raise
    @data = data.merge @new_data
    debug "@data après merge : {\n"+ @data.collect{|k,v| "#{k.inspect} => #{v.inspect}"}.join("\n") +"\n}"
    save
    debug "New data : {\n"+ data.collect{|k,v| "#{k.inspect} => #{v.inspect}"}.join("\n") +"\n}"
  rescue Exception => e
    app.error e.message
  end
  
  ##
  #
  # Enregistre les données
  #
  #
  def save
    now = Time.now.to_i
    data.merge!(:updated_at => now)
    PStore.new(User::pstore).transaction do |ps|
      ##
      ## Affecter une nouvelle ID s'il n'est pas défini
      ##
      if data[:id].to_s == ""
        new_id = ps.fetch(:last_id, 0) + 1
        ps[:last_id]  = new_id
        @data[:id]    = new_id
        @id           = new_id
        @data.merge! created_at: Time.now.to_i
      end
      ps[id] = data
    end
  end
  

  ##
  #
  # Retourne toutes les données du pstore
  #
  #
  def data
    @data ||= begin
      if @id.to_s != ""
        PStore::new(User::pstore).transaction do |ps|
          ps.fetch(@id, nil)
        end
      else
        {
          id:           nil,
          pseudo:       "",
          mail:         "",
          blog:         "",
          site:         "",
          chaine_yt:    "",
          description:  "",
          grade:        :veilleur,
          password:     nil,
          salt:         Time.now.to_i,
          cpassword:    nil,
          created_at:   nil
        }
      end
    end
  end
 
  ##
  #
  # Récupère les données dans le formulaire
  #
  #
  def get_form_data
    @new_data = {}
    [:id, :pseudo, :mail, :grade, :blog, :site, :chaine_yt, :description, :pwd, :new_password, :new_password_confirmation].each do |key|
      @new_data.merge! key => app.param("user_#{key}").strip
    end
  end
  
  ##
  #
  # Vérifie la validité des données
  #
  def check_data_or_raise
    h = @new_data
    errors = []
    h[:id] = h[:id].to_i
    h[:pseudo] != "" || (errors <<  "Le pseudo est requis.")
    h[:mail]   != "" || (errors << "Le mail est requis.")
    new_data_check_site( :site ) || (errors << "Le site #{h[:site]} ne semble pas exister.")
    new_data_check_site( :chaine_yt ) || (errors << "La chaine YouTube #{h[:chaine_yt]} ne semble pas exister.")
    new_data_check_site( :blog ) || (errors << "Le blog #{h[:blog]} ne semble pas exister.")
    h[:grade] != ""   || (errors << "Le grade doit être fourni.")
    @new_data[:grade] = @new_data[:grade].to_sym
    
    ##
    ## Le mot de passe a-t-il été modifié
    ##
    new_password_getted = false
    new_pwd = h.delete(:new_password)
    if new_pwd.to_s != ""
      ##
      ## Un changement de mot de passe
      ##
      new_pwd.length <= 40 || (errors << "Votre code doit faire 40 signes au plus.")
      new_pwd_conf = h.delete(:new_password_confirmation).to_s
      new_pwd == new_pwd_conf || (errors << "La confirmation du nouveau mot de passe ne correspond pas.")
      ## Tout est OK
      if errors.empty?
        @new_data.merge! :password => new_pwd
        debug "Nouveau mot de passe : #{@new_data[:password]}"
        new_password_getted = true
      end
    elsif h[:pwd].to_s != get(:password).to_s
      h.merge! :password => h[:pwd]
      new_password_getted = true
    end
    
    h.delete(:new_password_confirmation)
    h.delete(:pwd)
    
    ##
    ## Si le mot de passe a été modifié
    ##
    if new_password_getted && errors.empty?
      new_salt = Time.now.to_i
      @new_data.merge!( 
        :salt      => new_salt,
        :cpassword => Digest::MD5.hexdigest("#{@new_data[:password]}#{new_salt}")
        )
      # debug "Nouveau code : #{@new_data[:password]}"
      # debug "Nouveau salt mis à #{@new_data[:salt]}"
      # debug "Nouveau cpassword : #{@new_data[:cpassword]}"
    end    
    
    ##
    ## Résultat de l'opération
    ##
    if errors.empty?
      return true
    else
      mess_err = errors.collect{|m| m.in_div }.join("")
      raise mess_err
    end
  end
  

  def new_data_check_site key
    url = @new_data[key]
    if url == ""
      @new_data[key] = nil
    else
      url = url[8..-1] if url.start_with?('https')
      url = url[7..-1] if url.start_with?('http')
      @new_data[key] = url
      res = if key == :chaine_yt
        `curl --head https://#{url}`
      else
        `curl --head http://#{url}`
      end
      line1 = res.split("\n")[0]
      return false unless line1.to_s.match(/\b200\b/)
    end
    return true
  end
  
end