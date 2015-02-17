require "spec_helper"

describe "Création/gestion de l'UID #{relative_path __FILE__}" do
  
  before :all do
    require_relative 'required'
    ##
    ## On détruit le fichier pointeur pour partir de rien
    ##
    rescue_and_unlink_fichier_pointeurs
    rescue_and_unlink_fichier_readers
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
      it 'ne définit pas UID pour l’user' do
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

  context 'Avec un user qui a un pointeur IP mais pas de données (cas d’erreur)' do
    before :all do
      remove_fichier_readers
      remove_fichier_pointeurs
      @ip = "127.0.1.2"
      set_remote_ip @ip
      save_pointeur @ip => 1
      @u = User::new
    end
    it 'le reader est créé' do
      expect(u.data_reader).to_not eq(nil)
    end
  end
  
  context 'Avec un user qui a un pointeur session mais pas de données (cas d’erreur)' do
    before :all do
      remove_fichier_readers
      remove_fichier_pointeurs
      @ip = "127.0.1.2"
      set_remote_ip @ip
      save_pointeur app.session.id => 1
      @u = User::new
    end
    it 'le reader est créé' do
      expect(u.data_reader).to_not eq(nil)
    end
  end
  
end