require "spec_helper"
class File
  class << self
    def unlink_with_rescue path
      return unless exist? path
      FileUtils::mv path, path_rescue(path)
    end
    def retrieve_rescue path
      prescue = path_rescue(path)
      raise "Copie de secours introuvable (#{prescue})" unless File.exist? prescue
      File.unlink path if File.exist? path
      FileUtils::mv prescue, path
    end
    def path_rescue path
      "#{path}-rescue"
    end
  end
end

describe "Création/gestion de l'UID #{relative_path __FILE__}" do

  # Raccourci
  def pstore_rh
    @pstore_rh ||= app.pstore_readers_handlers
  end
  
  def remove_fichier_pointeurs
    File.unlink pstore_rh if File.exist? pstore_rh
  end
  def remove_fichier_readers
    File.unlink app.pstore_readers if File.exist? app.pstore_readers
  end
  def rescue_fichier_pointeurs
    File.unlink_with_rescue pstore_rh
  end
  def rescue_fichier_readers
    File.unlink_with_rescue app.pstore_readers
  end
  def retrieve_fichier_pointeurs
    File.retrieve_rescue pstore_rh
  end
  def retrieve_fichier_readers
    File.retrieve_rescue app.pstore_readers
  end
  def fichier_pointeurs_existe existe = true
    if existe
      expect(File).to be_exist pstore_rh
    else
      expect(File).not_to be_exist pstore_rh
    end
  end
  
  
  before :all do
    ##
    ## On détruit le fichier pointeur pour partir de rien
    ##
    rescue_fichier_pointeurs
    rescue_fichier_readers
  end
  
  after :all do
    retrieve_fichier_pointeurs
    retrieve_fichier_readers
  end
  
  let(:u) { @u }
  
  ##
  ## Test avec un utilisateur non trustable.
  ## Son UID ne doit pas être défini, et aucune donnée
  ## reader ne doit être enregistrées
  ##
  context 'Avec un user non trustable' do
    before :all do
      set_remote_ip nil
      @u = User::new
    end
    describe "L'instanciation" do
      it 'ne définit pas UID' do
        expect(u.uid).to eq(nil)
      end
      it 'ne crée pas de fichier pointeur' do
        fichier_pointeurs_existe false
      end
    end
  end
  
  ##
  ## Test avec un user trustable (il a une remote-adresse)
  ## Un nouvel UID doit lui être affecté et des pointeurs sont
  ## créés vers cet UID à partir de la remote adresse et de l’id
  ## de session.
  ##
  context 'Avec un user trustable' do
    before :all do
      remove_fichier_pointeurs
      remove_fichier_readers
      @ip = "127.1.2.3"
      set_remote_ip @ip
    end
    describe "L'instanciation" do
      before :all do
        @u = User::new
      end
      it 'définit un UID valide' do
        expect(u.uid).to_not eq(nil)
        expect(u.uid).to eq(1)
      end
      it 'crée le fichier readers' do
        expect(File).to be_exist app.pstore_readers
      end
      it 'crée le fichier pointeurs' do
        fichier_pointeurs_existe
      end
      it 'met le pointeur IP' do
        d = {@ip => 1}
        pstore_has_data pstore_rh, d, explode = true
      end
      it 'met le pointeur Session' do
        d = {app.session.id => 1}
        pstore_has_data pstore_rh, d, explode = true
      end
      it 'l’ID de session est enregistré dans les données du lecteur' do
        d = {session_id: app.session.id, uid: 1}
        pstore_has_data app.pstore_readers, d
      end
      it 'l’UID est enregistré dans les données du lecteur' do
        d = { 1 => { uid: 1 } }
        pstore_has_data app.pstore_readers, d, explode = true
      end
      it 'une nouvelle instanciation recupère le bon UID' do
        nu = User::new
        expect(nu.uid).to_not eq(nil)
        expect(nu.uid).to eq(1)
      end
    end
  end

  describe "Création des pointeurs de l'user" do
    
  end
  
end