# encoding: UTF-8
class App
  ##
  #
  # Requête appelée à la soumission d'une postulation de candidature
  #
  def postuler
    check_values_or_raise
    require_module 'mail'
    send_mail_to_admin(
      from:     param(:user_mail),
      subject:  "Postulation pour le Cercle pianistique",
      message:  compose_message_postuler
    )
  rescue Exception => e
    error e.message
  end
  
  ##
  #
  # Compose le message pour le mail
  #
  def compose_message_postuler
    <<-HTML
Admin, un nouveau candidat pour le #{short_name}.

Patronyme : #{param :user_patronyme}
Mail : #{param :user_mail}

Présentation : #{param :user_presentation}

Motivation : #{param :user_motivation}

Il faut lui donner une réponse sous 15 jours.
    HTML
  end
  
  ##
  #
  # Vérifie que les données soient conforment
  #
  def check_values_or_raise
    upatronyme = param(:user_patronyme).strip
    raise "Vous devez fournir vos noms et prénoms." if upatronyme == ""
    umail = param(:user_mail).strip
    raise "Vous devez fournir votre mail." if umail == ""
    umail_conf = param(:user_mail_confirmation).strip
    raise "Vous devez fournir la confirmation de votre mail" if umail_conf == ""
    raise "La confirmation de votre mail ne correspond pas" if umail != umail_conf
    upresentation = param(:user_presentation).strip
    raise "Vous devez vous présenter aux autres membres." if upresentation == ""
    raise "Votre présentation est un peu brève, non&nbsp;?" if upresentation.length < 100
    umotivation = param(:user_motivation).strip
    raise "Vous devez présenter les motivations qui vous guident." if umotivation == ""
    raise "Vos motivations ne sont pas suffisamment nombreuses…" if umotivation.length < 100
  rescue Exception => e
    raise e
  end
end