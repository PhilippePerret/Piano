require "spec_helper"

=begin

Test de la méthode d'instance <app>.opere qui traite les opérations "o"

=end
describe "app#opere #{relative_path __FILE__}" do
  let(:ap) { App::current }
  it 'répond' do
    expect(ap).to respond_to :opere
  end
  
  describe "app.form_o" do
    it 'répond' do
      expect(ap).to respond_to :form_o
    end
    describe 'retourne un code qui contient' do
      before :all do
        @code = form_o(button:"Télécharger", o: "download", o1: 'path/to/file.erb', article: "admin/membres")
      end
      let(:code) { @code }
      it 'un formulaire' do
        expect(code).to have_tag('form', with: {class: 'form_o'})
      end
      it 'la définition de l’article' do
        expect(code).to have_tag('form', with: {class: 'form_o'}) do
          with_tag('input', with: {type: 'hidden', name: 'article', value: 'admin/membres'})
        end
      end
      it 'la définition de l’opération' do
        expect(code).to have_tag('form', with: {class: 'form_o'}) do
          with_tag('input', with: {type: 'hidden', name: 'o', value: 'download'})
        end
      end
      it 'la définition de l’argument' do
        expect(code).to have_tag('form', with: {class: 'form_o'}) do
          with_tag('input', with: {type: 'hidden', name: 'o1', value: 'path/to/file.erb'})
        end
      end
      it 'le bon bouton submit' do
        expect(code).to have_tag('form', with: {class: 'form_o'}) do
          with_tag('input', with: {type: 'submit', value: 'Télécharger'})
        end
      end
    end
  end
end