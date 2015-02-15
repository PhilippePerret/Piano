# encoding: UTF-8
=begin

Handy méthodes
--------------
Fonctions raccourcis de méthodes de l'instance App courante

=end

def app
  @app ||= App::current
end

def link_to tit, relp = nil, opts = nil
  app.link_to tit, relp, opts
end

def link_to_article path_or_id, options = nil
  app.link_to_article path_or_id, options
end

def offline?; app.offline?  end
def online?;  app.online?   end

def param arg
  App::current.param arg
end

def redirect_to idpath, next_article = nil
  if idpath.class == Symbol
    # => Un lien par raccourci
    dshortcut = App::Article::SHORTCUTS[idpath]
    idpath = dshortcut[:relpath]
  end
  param('na' => next_article) unless next_article.nil?
  app.article = idpath
  app.article.load
end

def flash arg
  App::current.flash arg
end

def error arg
  App::current.error arg
end

def debug arg
  App::current.debug arg
end

def form_o arg; app.form_o arg end

def rond_rouge
  @rond_rouge ||= "<img src='./public/page/img/pictos/rond-rouge.png' />"
end
def rond_vert
  @rond_vert ||= "<img src='./public/page/img/pictos/rond-vert.png' />"
end

def send_mail_to_admin datamail
  app.send_mail_to_admin datamail
end