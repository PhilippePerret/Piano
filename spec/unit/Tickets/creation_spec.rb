require "spec_helper"

describe "Création d'un ticket #{relative_path __FILE__}" do
  before :all do
    
  end
  after :all do
    p = File.join('.', 'data', 'ticket')
    FileUtils::rm_rf p
    Dir.mkdir(p, 0755)
  end
  
  let(:ap) { app }
  
  describe "méthode #new_ticket_with_code" do
    it 'répond' do
      expect(ap).to respond_to :new_ticket_with_code
    end
  end
  
  describe "Création d'un nouveau ticket" do
    before :all do
      @le_texte_returned = "J'ai exécuté le code à #{Time.now.to_i}"
      proc = "Proc::new { \"#{@le_texte_returned}\" }"
      @ticket = app.new_ticket_with_code proc
    end
    it 'a créé le fichier' do
      expect(File).to be_exist File.join('.', 'data', 'ticket', @ticket.id)
    end
    it 'a écrit le bon code dans le fichier' do
      p = File.join('.', 'data', 'ticket', @ticket.id)
      data = Marshal::load( File.read( p ) )
      expect(data).to have_key :proc
      expect(data[:proc]).to be_instance_of String
      expect(data).to have_key :protection
      expect(data[:protection]).to be_instance_of Fixnum
      expect(data[:protection]).to eq(@ticket.protection)
      expect(data).to have_key :id
      expect(data[:id]).to eq(@ticket.id)
    end
    it 'le code exécuté produit le bon résultat' do
      p = File.join('.', 'data', 'ticket', @ticket.id)
      data = Marshal::load( File.read( p ) )
      proc = eval(data[:proc])
      res = proc.call
      expect(res).to eq(@le_texte_returned)
      expect(proc).to be_instance_of Proc
    end
    it 'l’appel du ticket par l’application retourne le bon code' do
      param('ti' => @ticket.id, 'tp' => @ticket.protection)
      res = app.traite_ticket_if_any
      expect(res).to eq(@le_texte_returned)
    end
  end
  
end