require "spec_helper"

describe "Opération d'upload #{relative_path __FILE__}" do
  
  describe "La méthode App::Operation::upload existe" do
    it 'répond' do
      expect(App::Operation).to respond_to :upload
    end
  end
  
  describe "upload" do
    before :all do
      require_folder 'administration'
    end
    context 'sans définition de la path dans o1' do
      before :all do
        param('o' => 'upload', 'o1' => nil)
      end
      it 'produit une erreur' do
        app.opere
        expect(app).to have_error "Il faut définir le path du fichier à uploader (dans `o1')"
      end
    end
    context 'avec un fichier inexistant' do
      before :all do
        param('o' => 'upload', 'o1' => "bad/path")
      end
      it 'produit une erreur' do
        app.opere
        expect(app).to have_error "Le fichier `bad/path' est introuvable."
      end
    end
    context 'avec de bons arguments' do
      before :all do
        param('o' => 'upload', 'o1' => 'data/pstore/last_times.pstore')
      end
      it 'upload le fichier voulu' do
        fichier = Fichier::new('data/pstore/last_times.pstore')
        fichier.remove_distant
        expect(fichier.distant_exists?).to eq(false)
        app.opere
        expect(fichier.distant_exists?).to eq(true)
      end
    end
  end
  
end