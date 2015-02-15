require "spec_helper"

describe "Statut de l'User #{relative_path __FILE__}" do
  before :all do
    ENV['REMOTE_ADDR'] = "124.1.2.3"
  end
  let(:u) { @u }

  describe "#membre?" do
    before :all do
      @u = User::new
    end
    it 'répond' do
      expect(u).to respond_to :membre?
    end
    context 'avec un membre' do
      before :all do
        @u = User::new 1
      end
      it 'retourne false' do
        expect(u).to be_membre
      end
    end
    
    context 'avec un follower' do
      before :all do
        umail = "mail#{Time.now.to_i}@chez.soi"
        new_follower(mail: umail, pseudo: "Pseudo#{Time.now.to_i}", ip: "124.1.2.3")
        @u = User::get_as_follower umail
      end
      it 'retourne true' do
        expect(u).to_not be_membre
      end
    end
    
    context 'avec un user quelconque' do
      before :all do
        @u = User::new
      end
      it 'retourne false' do
        expect(u).to_not be_membre
      end
    end
    
  end
  
  describe "#follower?" do
    before :all do
      @u = User::new
    end
    it 'répond' do
      expect(u).to respond_to :follower?
    end
    context 'avec un membre' do
      before :all do
        @u = User::new 1
      end
      it 'retourne false' do
        expect(u).to_not be_follower
      end
    end
    
    context 'avec un follower' do
      before :all do
        umail = "mail#{Time.now.to_i}@chez.soi"
        new_follower(mail: umail, pseudo: "Pseudo#{Time.now.to_i}", ip: "124.1.2.3")
        @u = User::get_as_follower umail
      end
      it 'retourne true' do
        expect(u).to be_follower
      end
    end
    
    context 'avec un user quelconque' do
      before :all do
        @u = User::new
      end
      it 'retourne false' do
        expect(u).to_not be_follower
      end
    end
    
  end
end