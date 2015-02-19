# encoding: UTF-8
=begin

Requiert tous les éléments par défaut

=end
require 'cgi'
require 'pstore'
require 'erb'

def require_folder fpath
  Dir["./public/lib/#{fpath}/**/*.rb"].each{|m| require m}
end

require_folder 'App'
require_folder 'Article'
require_folder '_User'
require_folder 'classes'
require_folder 'extensions'
app = App::new

##
## Si on est OFFLINE, on charge toutes les méthodes d'administration
##
if App.offline?
  require_folder 'administration'
end