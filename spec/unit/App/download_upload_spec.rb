require "spec_helper"

=begin

Note : Ces méthodes ne sont chargées qu'en mode offline (administration)

=end
describe "Méthode d'upload/download #{relative_path __FILE__}" do
  
  before :all do
    require_folder 'administration'
    @ap = App::new
  end
  let(:ap) { @ap }
  
  # #download
  describe "#download" do
    it 'répond' do
      expect(ap).to respond_to :download
    end
  end
  
  # #upload
  describe "#upload" do
    it 'répond' do
      expect(ap).to respond_to :upload
    end
  end
end