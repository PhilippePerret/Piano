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
  
  ##
  #
  # Adresse IP de l'user (identifié ou non)
  #
  # Consigne aussi cette connexion dans ips.pstore
  #
  def remote_ip
    @remote_ip ||= begin
      raddr   = ENV['REMOTE_ADDR']
      httpid  = ENV['HTTP_CLIENT_IP']
      httpx   = ENV['HTTP_X_FORWARDED_FOR']
      ip = raddr || httpid || httpx # TODO: affiner
      app.remember_ip ip
      ip
    end
  end

  # ---------------------------------------------------------------------
  #
  #   Méthodes d'état
  #
  # ---------------------------------------------------------------------
 
  ##
  #
  # @return TRUE si l'user peut voter pour les articles
  #
  #
  def can_vote_articles?
    last_time_vote = PStore::new(App::Article::pstore_votes).transaction do |ps|
      ps.fetch(remote_ip, nil)
    end
    return last_time_vote.nil? || (last_time_vote < (Time.now.to_i - 60.days))
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------


  def app
    @app ||= App::current
  end
  
end