# encoding: UTF-8
class App
  
  def send_mail_to_admin data_mail
    require_library 'mail'
    require './data/secret/data_admin'
    data_mail.merge!(
      to:               DATA_ADMIN[:mail],
      force_offline:    true
    )
    Mail::new(data_mail).send
  end
  
end