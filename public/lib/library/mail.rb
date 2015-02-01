# encoding: UTF-8
require 'cgi'
require 'net/smtp'

# Class Mail - Class commune
# 
# Pour envoyer un mail.
# 
# REQUIRED
#   - ./data/secret/data_mail.rb
#   - Une class Mail propre à l'application définissant les méthodes DE CLASSE
#     Note : toutes ces méthodes sont optionnelles
#     before_subject  # Retourne le texte à ajouter avant le titre (subject)
#     send_offline    # Méthode traitement des données si on est offline (tests)
#     header          # L'entête de page
#     footer          # Le pied de page, après la signature
#     signature       # La signature (entre le message et le footer)
#     content_type    # Un autre content-type que html (défaut: html-utf8 content type)
#     body_style      # Style CSS du body
#     styles_css      # Contenu éventuel de la balise <style type="test/css"> - code CSS
# 
# USAGE
#         Mail.new(
#           :message => '<message>', :subject => 'subjet',
#           :from => 'from', :to => 'to', 
#         ).send
# 
#     @note:  <message>  au format HTML
# 
# 
class Mail

  require File.join('.', 'data', 'secret', 'data_mail.rb')

  DEFAUT_CONTENT_TYPE = '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>'

  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  
  class << self
    
    # Send the mail (don't call directly, use Mail.new(...) instead)
    # 
    # * PARAMS
    #   :mail::       Formated mail code
    #   :to::         Email address of the receiver
    #   :from::       Email address of the sender (me by default)
    # 
    def send mail, to, from
      Net::SMTP.start(
        MY_SMTP[:server], 
        MY_SMTP[:port], 
        'localhost',      # serveur From (sera à régler plus tard suivant
                          # online/offline)
        MY_SMTP[:user], 
        MY_SMTP[:password]
        ) do |smtp|
          smtp.send_message mail, from, to
      end
    end
    
    # En cas d'absence de sujet (subject)
    def no_subject
      "(sans sujet)"
    end
   
  
  end # /<< self
  
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------

  # Données transmises à l'instanciation
  attr_reader :data
  
  # Message in plain text
  # 
  attr_reader :message
  
  # Subject of the mail
  # 
  attr_reader :subject

  # Sender (name<email address>)
  # 
  attr_reader :from
  
  # Receiver (name<email address)
  # 
  attr_reader :to

  # Mail format (:html, :text, :both)
  #
  attr_reader :format
  
  # 
  
  # Initialize a new mail
  # 
  # * PARAMS
  #   :data::     Send data
  #               :from::       Sender
  #               :to::         Receiver
  #               :subject::    Subject of the mail
  #               :message::    Code of the message to send
  #               :force_offline    Si TRUE, envoie même en offline
  #               :formated     Si TRUE, le message est considéré comme formaté
  #               :format::     Si :text, le message est laissé en code brut (pas HTML)
  #               :data::       Data to use with type-messages. Every key will be turn into
  #                             its value.
  # 
  def initialize data = nil
    @data = data
    set data unless data.nil?
  end
  
  # Envoi le message
  def send
    if App::offline? && ( @force_offline != true ) && self.class.respond_to?(:send_offline)
      self.class.send_offline data.merge(subject: subject)
    else
      self.class.send message, to, from
    end    
  end
  
  def return_to_br_in_message?
    if defined? CORRECT_RETURN_IN_MESSAGE
      CORRECT_RETURN_IN_MESSAGE
    else
      true
    end
  end
  
  # Dispatch +data+ in instance
  # 
  def set data
    data.each do |k,v| 
      v = nil if v == ""
      instance_variable_set("@#{k}", v) 
    end
  end
  
  def message
    <<-EOM
From: <#{from}>
To: <#{to}>
MIME-Version: 1.0
Content-type: text/html; charset=UTF-8
Subject: #{subject}

#{code_html}
    EOM
  end

  ##
  ## Cette méthode ne semble pas fonctionner sur alwaysdata (mavaise
  ## version de CGI ? — pourtant, elle fonctionnement parfaitement pour
  ## construire la page)
  ##
  # def code_html
  #   cgi = CGI::new('html4')
  #   cgi.html {
  #     cgi.head { content_type + cgi.title { subject } + style_tag } +
  #     cgi.body { body }
  #   }
  # end

  def code_html
    <<-HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <meta http-equiv="Content-type" content="text/html; charset=utf-8">
  <title>#{subject}</title>
  #{style_tag}
</head>
<body>
  #{body}
</body>
</html>
    HTML
  end
  
  def body
    c = header + (message_formated + signature + footer).in_div(id: 'message_content')
    if Mail::respond_to?(:body_style)
      c.in_div(style: Mail::body_style)
    end
    return c
  end
  
  def message_formated
    return @message if @formated == true
    c = @message
    if return_to_br_in_message?
      if c.match("\n")
        c.gsub!(/\n/, '<br>')
        c.gsub!(/\r/, '')
      elsif c.match("\r")
        c.gsub!(/\r/, '<br>')
        c.gsub!(/\n/, '')
      end
    end
    c.in_div
  end
  
  def style_tag
    c = '<style type="text/css">'
    c << "body{#{Mail::body_style}}" if Mail::respond_to?(:body_style)
    c << Mail::styles_css if Mail::respond_to?(:styles_css)
    c << '</style>'
    c
  end
 
  def from;     @from     ||= MAIL_PHIL         end
  def to;       @to       ||= MAIL_PHIL         end
  def subject
    @subject ||= Mail::no_subject
    "#{header_subject}#{@subject}"
  end
  
  def content_type
    Mail::respond_to?(:content_type) ? Mail::content_type : Mail::DEFAUT_CONTENT_TYPE
  end
  def header_subject
    Mail::respond_to?(:before_subject) ? Mail::before_subject : ""
  end
  def header
    Mail::respond_to?(:header) ? Mail::header : ""
  end
  def signature
    @signature ||= begin
      Mail::respond_to?(:signature) ? Mail::signature : ""
    end
  end
  def footer
    Mail::respond_to?(:footer) ? Mail::footer : ""
  end
end
