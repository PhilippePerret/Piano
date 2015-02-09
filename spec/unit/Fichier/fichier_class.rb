require "spec_helper"

describe "Class Fichier #{relative_path __FILE__}" do
  before :all do
    require_folder 'administration'
  end
  
  describe "::relative_path_of" do
    it 'répond' do
      expect(Fichier).to respond_to :relative_path_of
    end
    it 'retourne le bon path relatif au fichier' do
      path = "./data/pstore/connexions.pstore"
      res = Fichier::relative_path_of path
      expect(res).to eq("data/pstore/connexions.pstore")
      path = File.expand_path(path)
      res = Fichier::relative_path_of path
      expect(res).to eq("data/pstore/connexions.pstore")
    end
  end
end