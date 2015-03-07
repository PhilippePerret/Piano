# encoding: UTF-8
=begin

Modules requis pour le travail pratique sur l'analyse musicale interactive
du prélude de Bach BWV 999

=end
self_folder = File.dirname(__FILE__)
Dir["#{self_folder}/required/**/*.rb"].each { |m| require m }