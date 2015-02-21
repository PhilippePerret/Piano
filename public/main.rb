# encoding: UTF-8

begin

  # raise "SITE EN D&Eacute;BUGGAGE PENDANT UNE HEURE. Merci de votre patience."
  
  require './public/lib/required'

  ##
  ## On détruit la dernière session
  ##
  debug "[LV-1] !!! main.rb --> app.session.delete_last" if LEVEL_DEBUG > 0
  app.session.delete_last
    
  ##
  ## Si opération appelée par ticket
  ##
  debug "[LV-1] main.rb --> app.traite_ticket_if_any" if LEVEL_DEBUG > 0
  app.traite_ticket_if_any if param('ti').to_s != "" && param('tp').to_s != ""
    
  ##
  ## On récupère l'user courant ou on le crée si c'est une
  ## tout première connexion.
  ##
  debug "[LV-1] main.rb --> User::retrieve_current" if LEVEL_DEBUG > 0
  User::retrieve_current
    
  ##
  ## Une opération "o" est peut-être définie
  ##
  debug "[LV-1] main.rb --> app.oper" if LEVEL_DEBUG > 0
  app.opere

  ##
  ## On charge l'article avant de concevoir le code de la
  ## page pour avoir tous les éléments
  ##
  debug "[LV-1] main.rb --> app.article.load" if LEVEL_DEBUG > 0
  app.article.load

  # debug "Article précédent : #{app.session['last_article']}"
  # debug "Article courant : #{app.current_article}"
  # debug "ID Session : #{app.session.id}"

  ##
  ## On mémorise l'article actuellement affiché
  ##
  debug "[LV-1] main.rb --> app.session['last_article'] = #{app.article.id}" if LEVEL_DEBUG > 0
  app.session['last_article'] = app.article.id


  ##
  ## On crée la page finale
  ##
  debug "[LV-1] main.rb --> app.output" if LEVEL_DEBUG > 0
  app.output


  debug "[LV-1] <- main.rb !!!" if LEVEL_DEBUG > 0
  
rescue Exception => e
  require 'cgi'
  cgi = CGI::new('html4')
  cgi.out{ 
    cgi.head { }
    cgi.html {
      '<pre>' + 
      "#{e.message.gsub(/</,'&lt;')}\n\n" +
      # e.backtrace.join("\n") +
      '</pre>'
    } 
  }
end
