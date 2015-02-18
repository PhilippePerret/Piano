# encoding: UTF-8
class App
  class Operation
    class << self
      
      ##
      #
      # Check du login
      #
      def check_login
        login_ok = false
        u = User::get_with_mail param('user_mail')
        unless u.nil?
          require 'digest/md5'
          raise 'user_password est inconnu' if param('user_password').to_s == ""
          raise 'cpassword est inconnu pour l’user' if u.cpassword.to_s == ""
          raise 'Le salt de l’user est inconnu' if u.get(:salt).to_s == ""
          cpwd = Digest::MD5.hexdigest("#{u.get(:password)}#{u.get(:salt)}")
          cpwd_checked = Digest::MD5.hexdigest("#{param('user_password')}#{u.get(:salt)}")
          # debug "[check_login] password : #{u.get(:password)} (dans pstore)"
          # debug "[check_login] password : #{param('user_password')} (donné)"
          # debug "[check_login] salt     : #{u.get(:salt)}"
          # debug "[check_login] cpassword: #{u.cpassword} (dans pstore)"
          # debug "[check_login] cpassword: #{cpwd} (recalculé avec donnée pstore)"
          # debug "[check_login] cpassword: #{cpwd_checked} (avec données fournies)"
          login_ok = cpwd == cpwd_checked
        end
        if login_ok
          u.login
          param('article' => param('na'))
        else
          error "Impossible de vous reconnaitre, merci de ré-essayer."
          param('article' => "user/login")
        end
      end

    end # << self App::Operation
  end # Operation
end # App