require "spec_helper"
=begin

Ce test vise à tester le bon déroulement de l’identification d’un membre.
En sachant que :
  - lorsqu’il arrive sur le site, le membre n’est pas forcément reconnu
    par son IP, s'il se connecte par un autre ordinateur ou une autre
    connexion.
    Dans le cas du même ordinateur, l’IP est reconnue, donc le bon lecteur
    est automatiquement attribué.
    Dans le cas d’un autre ordinateur, l’IP n’est pas reconnue (sauf si c'est
    l’ordinateur d’un reader existant)

    Dès qu’il est reconnu, les données du lecteur qu’il était doivent être  
    détruites (pointeur et data reader) SAUF si ce reader existait avant…
    NON : En fait, on va garder les données lecteurs en place, peu importe, mais
    il faut vérifier que les données lecteur, dans ce cas, ne soient pas 
    associées au membre.

=end
describe "Reader vers membre #{relative_path __FILE__}" do
  before :all do
    require_relative '../../_required'
    require_relative 'required'
    
    rescue_pstore_membres_and_table # pas de destruction
    rescue_and_unlink_fichier_pointeurs
    rescue_and_unlink_fichier_readers
    
    @mb_id    = nil
    @mb_data  = nil
    PStore::new(User::pstore).transaction do |ps|
      @mb_id = ps.roots.reject{|e| e == :last_id}.first
      @mb_data = ps[@mb_id]
    end
    puts "Premier ID-membre trouvé : #{@membre_id}".in_div
    puts "Données : #{@mb_data.inspect}".in_div
  end
  
  after :all do
    ##
    ## On remet en place les pstores précédents
    ##
    retrieve_pstore_membres_and_table
    retrieve_fichier_pointeurs
    retrieve_fichier_readers
  end
  
  context 'Avec un membre reconnu par son IP' do
    it 'est vrai' do
      expect(true).to eq(true)
    end
  end
  
  
  context 'avec un membre depuis un autre ordinateur inconnu (autre IP)' do
    
  end
  
  context 'avec un membre depuis l’ordinateur d’un reader existant (IP connue)' do
    # Dans ce cas, il ne faut pas associer le reader à ce membre
    #
  end
end