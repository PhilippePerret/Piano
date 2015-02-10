require "spec_helper"

describe "Test de l'opération de download #{relative_path __FILE__}" do
  let(:ap) { App::current }
  
  describe "#o_download" do
    it 'répond' do
      expect(App::Operation).to respond_to :download
    end
  end
  
  describe "appel de la méthode o_download par opere" do
    before :all do
      param('o' => "download")
    end
    it 'avec le paramètre `o` égale à `download`, appelle la méthode `o_download`' do
      allow(App::Operation).to receive(:download){ "Passé dans download" }
      res = ap.opere
      expect(res).to eq("Passé dans download")
    end
  end
  
  
  describe "Essai de la méthode en réel" do
    before :all do
      require_folder 'administration'
    end
    context 'sans argument défini' do
      before :all do
        param('o' => 'download', 'o1' => nil)
      end
      it 'produit une erreur' do
        ap.opere
        expect(ap).to have_error("Il faut définir le path du fichier à downloader (dans `o1')")
      end
    end
    context 'avec un argument défini valide' do
      before :all do
        param('o' => 'download', 'o1' => "data/pstore/connexions.pstore")
      end
      it 'elle peut rapatrier le fichier des connexions' do
        p = File.join('.', 'data', 'pstore', 'connexions.pstore')
        File.unlink p if File.exist? p
        expect(File).to_not be_exist p
        ap.opere
        sleep 1
        expect(File).to be_exist p
      end
    end
  end
  
end