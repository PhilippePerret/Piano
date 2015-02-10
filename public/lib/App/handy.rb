# encoding: UTF-8
=begin

Handy méthodes
--------------
Fonctions raccourcis de méthodes de l'instance App courante

=end

def app
  @app ||= App::current
end

def offline?; app.offline?  end
def online?;  app.online?   end

def param arg
  App::current.param arg
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