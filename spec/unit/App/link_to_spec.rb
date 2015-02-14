require "spec_helper"

describe "Méthodes d'helper pour les liens #{relative_path __FILE__}" do
  before :all do
    @ap = app
  end
  
  let(:ap) { @ap }
  let(:res) { @res }
  
  describe "Méthode #link_to" do
    it 'répond' do
      expect(ap).to respond_to :link_to
    end
    context 'avec un titre et un path en argument' do
      before :all do
        @titre = "Un titre à #{Time.now}"
        @res = app.link_to @titre, "path/pour/voir"
      end
      it 'retourne un formulaire' do
        expect(res).to have_tag('form', with: {class: "alink"})
      end
      it 'le formulaire contient le bon titre' do
        expect(res).to have_tag('form', with: {class: "alink"}) do
          with_tag('span', text: @titre)
        end
      end
      it 'le formulaire avec la bonne donnée article' do
        expect(res).to have_tag('form', with: {class: "alink"}) do
          with_tag('input', with: {type:'hidden', name:'article', value: "path/pour/voir"})
        end
      end
    end
  end
  
  describe "Méthodes #link_to_article" do
    it 'répond' do
      expect(ap).to respond_to :link_to_article
    end
    
    context 'avec un argument IDPATH' do
      before :all do
        @res = app.link_to_article 'theme/ni_pour_ni_contre/exercices_ou_pas'
      end
      describe "retourne un formulaire" do
        it 'conforme' do
          expect(res).to have_tag('form', with: {class: 'alink'})
        end
        it 'contenant le titre de l’article' do
          expect(res).to have_tag('form.alink') do
            with_tag('span', text: "Des exercices ou pas ?")
          end
        end
        it 'contenant le path en champ hidden' do
          expect(res).to have_tag('form.alink') do
            with_tag('input', with: {type:'hidden', value:"theme/ni_pour_ni_contre/exercices_ou_pas"})
          end
        end
      end
    end
    context 'avec un argument ID' do
      before :all do
        @res = app.link_to_article 12
      end
      describe "retourne un formulaire" do
        it 'conforme' do
          expect(res).to have_tag('form', with: {class: 'alink'})
        end
        it 'contenant le titre de l’article' do
          expect(res).to have_tag('form.alink') do
            with_tag('span', text: "Des exercices ou pas ?")
          end
        end
        it 'contenant le path en champ hidden' do
          expect(res).to have_tag('form.alink') do
            with_tag('input', with: {type:'hidden', value:"theme/ni_pour_ni_contre/exercices_ou_pas"})
          end
        end
      end
    end
    
    context 'avec l’option form à FALSE (lien a)' do
      before :all do
        @options = {form: false}
      end
      context 'avec un argument ID' do
        before :all do
          @res = app.link_to_article 12, @options
        end
        describe "retourne un formulaire" do
          it 'conforme' do
            expect(res).to have_tag('a')
          end
          it 'contenant le titre de l’article' do
            expect(res).to have_tag('a', text: "Des exercices ou pas ?")
          end
          it 'contenant le path en champ hidden' do
            expect(res).to have_tag('a', with:{ href: "?a=theme%2Fni_pour_ni_contre%2Fexercices_ou_pas"})
          end
        end
      end
      
    end
  end
end