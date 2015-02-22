# encoding: UTF-8
=begin

Requiert tous les éléments par défaut

=end
require 'cgi'
require 'pstore'
require 'erb'

class PStore
  alias :original_init :initialize
  def initialize path
    begin
      raise
    rescue Exception => e
      bt = e.backtrace[1]
      unless bt.index("PPStore.rb")
        debug "\n\nWARNING : PStore #{path} appelé\ndepuis #{e.backtrace[1]}"
        debug "---> Il faut utiliser les méthodes PPStore\n\n"
      end
    end
    original_init path
  end
end

require './public/lib/_config'

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