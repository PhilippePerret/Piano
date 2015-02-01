# encoding: UTF-8
=begin

Requiert tous les éléments par défaut

=end
require 'cgi'
require 'erb'

def require_folder fpath
  Dir["./public/lib/#{fpath}/**/*.rb"].each{|m| require m}
end

require_folder 'App'
require_folder 'extensions'
app = App::new