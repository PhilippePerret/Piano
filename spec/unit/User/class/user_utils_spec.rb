require "spec_helper"

describe "Méthodes utilitaires User #{relative_path __FILE__}" do

  # ::upload
  describe "::upload" do
    it 'répond' do
      expect(User).to respond_to :upload
    end
  end
  
  # ::download
  describe "::download" do
    it 'répond' do
      expect(User).to respond_to :download
    end
  end
  
end