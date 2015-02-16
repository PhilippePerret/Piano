# encoding: UTF-8

begin

  require './public/lib/required'

  ##
  ## On détruit la dernière session
  ##
  app.session.delete_last
  
  ##
  ## Si opération appelée par ticket
  ##
  app.traite_ticket_if_any
  
  ##
  ## On essaie de reconnaitre le visiteur courant s'il
  ## est loggué
  ##
  User::retrieve_current
  
  ##
  ## Une opération "o" est peut-être définie
  ##
  app.opere

  ##
  ## On charge l'article avant de concevoir le code de la
  ## page pour avoir tous les éléments
  ##
  app.article.load

  # debug "Article précédent : #{app.session['last_article']}"
  # debug "Article courant : #{app.current_article}"
  # debug "ID Session : #{app.session.id}"

  ##
  ## On mémorise l'article actuellement affiché
  ##
  app.session['last_article'] = app.article.id

  ##
  ## On crée la page finale
  ##
  app.output

rescue Exception => e
  cgi = CGI::new('html4')
  cgi.out{ 
    cgi.head { }
    cgi.html {
      '<pre>' + 
      "ERREUR FATALE : #{e.message.gsub(/</,'&lt;')}\n\n" +
      e.backtrace.join("\n") +
      '</pre>'
    } 
  }
end
