# encoding: UTF-8
=begin

Noter que ces méthodes ne sont utilisables que pour un user reconnu
comme membre ou comme follower.

=end
require 'digest/md5'
class User
  
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
  # Définit des données du membre (dans le pstore membres.pstore)
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
  # Retourne le grade comme un nombre (bit)
  # Cf. user_constantes.rb pour les valeurs
  #
  def grade_as_level
    User::GRADES[grade][:level]
  end
  
  
  ##
  #
  # Méthode qui récupère les données du formulaire et les enregistre
  #
  # La méthode est appelée aussi bien par le membre identifié pour modifier
  # ses données que par l'administrateur pour enregistrer un nouveau membre
  # Si c'est un nouveau membre, il faut faire un traitement particulier.
  # Cf. la méthode create_as_new_membre dans le module 
  # ../article/admin/membres/membres.rb
  #
  #
  def get_and_save
    get_form_data
    check_data_or_raise
    @data = data.merge @new_data
    is_a_new_membre = @data[:id] == nil
    save
    debug "New data membre : {\n"+ data.collect{|k,v| "#{k.inspect} => #{v.inspect}"}.join("\n") +"\n}"
    create_as_new_membre if is_a_new_membre
  rescue Exception => e
    app.error e.message
  end
  
  ##
  #
  # Enregistre les données du membre
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
  # Si le membre n'existe pas encore, on retourne les données
  # par défaut.
  #
  #
  def data
    @data ||= begin
      if @id.to_s != ""
        ppdestore User::pstore, @id
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
    h[:id] = h[:id] == "" ? nil : h[:id].to_i
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