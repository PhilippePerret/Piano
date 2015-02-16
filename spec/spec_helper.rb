# encoding: UTF-8

URL_ONLINE_PRODUCTION     = "piano.alwaysdata.net"
URL_OFFLINE_DEVELOPPEMENT = "localhost/AlwaysData/Piano/index.rb"

if ARGV[1] == "--prod"
  MODE_PRODUCTION = true
else
  MODE_PRODUCTION = false
end

require 'capybara/rspec'
require 'rspec-html-matchers'

# Capybara.javascript_driver = :webkit
Capybara.javascript_driver = :selenium
Capybara.default_driver = :selenium


Dir["./spec/support/**/*.rb"].each {|f| require f}

# Toute les classes
require './public/lib/required'

class String
  # Pour les tests, il faut supprimer les balises dans les textes pour faire
  # des comparaisons
  def sans_balises
    self.gsub(/<([^>]*?)>/, '').gsub(/&nbsp;/, ' ')
  end
end


RSpec.configure do |config|
  
  MODE_TEST = true unless defined?(MODE_TEST) 
  

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Inclure les modules matchers

  
  config.before :all do |x|
    
    User::current = nil

  end
  
  config.before :each do |x|

  end
  
  config.after :all do

  end

  # À jouer au tout début des tests
  # -------------------------------
  config.before :suite do
    
  end
  
  # À jouer tout à la fin des tests
  # --------------------------------
  config.after :suite do
    
  end  
    
  #---------------------------------------------------------------------
  #   Tests
  #---------------------------------------------------------------------
  # Pour savoir où se trouve le fichier test, on peut ajouter dans le
  # premier describe : "<nom du test> (#{relative_path(__FILE__)})"
  def relative_path path
    name = File.basename(path)
    doss = File.basename(File.dirname(path))
    ddos = File.basename(File.dirname(File.dirname(path)))
    " (#{ddos}/#{doss}/#{name})"
  end
  
  
  # #---------------------------------------------------------------------
  # #   Méthodes de test
  # #---------------------------------------------------------------------
  # def debug str, options = nil
  #   App::Debug::add str, options
  # end
  
  #---------------------------------------------------------------------
  #   Méthodes utilitaires Feature
  #---------------------------------------------------------------------

  #---------------------------------------------------------------------
  #   Méthodes utilitaires
  #---------------------------------------------------------------------

  
  # Définir +user+ comme l'utilisateur courant, avec les options +options+
  # Pour le options, cf. apply_options_on_user ci-dessous
  def set_current_user user, options = nil
    options ||= {}
    User::current = user
    apply_options_on_user user, options
  end
   
  #---------------------------------------------------------------------
  # Méthodes pour les mails
  #---------------------------------------------------------------------

  # Vide le dossier des mails envoyés en local
  def reset_mails
    folder_mails = File.join('.', 'tmp', 'mails')
    FileUtils::rm_rf folder_mails if File.exists? folder_mails
  end
  # Retourne un {Array} de tous les mails envoyés en local
  def get_mails
    folder_mails = File.join('.', 'tmp', 'mails')
    mails = []
    Dir["#{folder_mails}/*.msh"].each do |path|
      mails << File.open(path, 'r'){ |f| Marshal.load(f) }
    end
    return mails
  end
  
  #---------------------------------------------------------------------
  # Méthodes pour les documents
  #---------------------------------------------------------------------
  # cf. support/handy_documents.rb
  
  # ---------------------------------------------------------------------
  #   Screenshots
  # ---------------------------------------------------------------------
  def shot name
    name = "#{Time.now.to_i}-#{name}"
    page.save_screenshot("./spec/screenshots/#{name}.png")
  end
  def empty_screenshot_folder
    p = './spec/screenshots'
    FileUtils::rm_rf p if File.exists? p
    Dir.mkdir( p, 0777 )
  end


  empty_screenshot_folder

end

