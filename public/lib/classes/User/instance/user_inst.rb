# encoding: UTF-8
class User
  
  attr_reader :id
  
  def initialize user_id = nil
    @id = if user_id.to_s.strip == ""
      user_id = nil 
    else
      user_id.to_i
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
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes-propriétés volatiles
  #
  # ---------------------------------------------------------------------
  def remote_ip
    @remote_ip ||= begin
      raddr   = ENV['REMOTE_ADDR']
      httpid  = ENV['HTTP_CLIENT_IP']
      httpx   = ENV['HTTP_X_FORWARDED_FOR']
      raddr || httpid || httpx # TODO: affiner
    end
  end
  # ---------------------------------------------------------------------
  #
  #   Méthode d'helper
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # @Retourne le nom humain du grade
  #
  #
  def hgrade
    @hgrade ||= User::GRADES[grade][:hname]
  end
  
  ##
  #
  # @return l'user sous forme de LI
  #
  #
  def as_li params = nil
    (
      edit_button.in_span(class: 'btn_edit') +
      pseudo.in_span(class: 'pseudo') +
      hgrade.in_span(class: 'grade')
    ).in_li(class: 'membre')
  end
  
  ##
  #
  # @return le code d'un bouton pour éditer le membre
  #
  def edit_button
    return "" unless app.offline?
    "[edit]".in_a(href: "?article=admin/membres&user_id=#{id}")
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes de données
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # Méthode qui récupère les données du formulaire et les enregistre
  #
  #
  def get_and_save
    get_form_data
    check_data_or_raise
    @data = @new_data
    save
    app.flash "Nouvelles données enregistrées : #{data.inspect}"
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
    @data.merge!(:created_at => now) unless data.has_key? :created_at
    @data.merge!(:updated_at => now)
    PStore.new(User::pstore).transaction do |ps|
      ##
      ## Affecter une nouvelle ID s'il n'est pas défini
      ##
      if data[:id].to_s == ""
        new_id = ps.fetch(:last_id, 0) + 1
        ps[:last_id]  = new_id
        @data[:id]    = new_id
        @id           = new_id
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
          grade:        :no_grade,
          password:     nil,
          cpassword:    nil,
          created_at:   Time.now.to_i
        }
      end
    end
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------

  ##
  #
  # Récupère les données dans le formulaire
  #
  #
  def get_form_data
    @new_data = {}
    [:id, :pseudo, :mail, :grade, :blog, :site, :chaine_yt, :description].each do |key|
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
    h[:pseudo] != "" || (errors <<  "Le pseudo est requis.")
    h[:mail]   != "" || (errors << "Le mail est requis.")
    new_data_check_site( :site ) || (errors << "Le site #{h[:site]} ne semble pas exister.")
    new_data_check_site( :chaine_yt ) || (errors << "La chaine YouTube #{h[:site]} ne semble pas exister.")
    new_data_check_site( :blog ) || (errors << "Le blog #{h[:site]} ne semble pas exister.")
    h[:grade] != ""   || (errors << "Le grade doit être fourni.")
    @new_data[:grade] = @new_data[:grade].to_sym
    
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
      res = `curl --head http://#{url}`
      line1 = res.split("\n")[0]
      return false unless line1.to_s.match(/\b200\b/)
    end
    return true
  end

  def app
    @app ||= App::current
  end
  
end