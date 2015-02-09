require "spec_helper"

describe "Class User #{relative_path __FILE__}" do
  
  describe "Méthodes" do
    
    # ::pstore
    describe "::pstore" do
      it 'répond' do
        expect(User).to respond_to :pstore
      end
      it 'retourne le path au pstore des membres' do
        p = File.expand_path(File.join('.', 'data', 'pstore', 'membres.pstore'))
        expect(User::pstore).to eq(p)
      end
    end
  end
end