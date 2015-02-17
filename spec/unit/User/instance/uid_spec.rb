require "spec_helper"

describe "UID de lecteur #{relative_path __FILE__}" do
  before :all do
    @u = User::new
    @ip = "125.1.2.3"
    set_remote_ip @ip
  end
  
  let(:u) { @u }
  
  describe "Méthode #uid" do
    it 'répond' do
      expect(u).to respond_to :uid
    end
    
    context 'avec un membre' do
      before :all do
        @u = User::new 1
        set_remote_ip @u.get(:remote_ip)
      end
      it 'retourne l’UID unique du membre' do
        
      end
    end
    
    context 'avec un follower' do
      before :all do
        umail = "mail#{Time.now.to_i}@chez.lui"
        new_follower(pseudo: "Pseudo#{Time.now.to_i}", mail: umail, ip: @ip)
        @u = User::get_as_follower umail
      end
      it 'retourne l’UID unique du follower' do
        res = u.uid
        expect(res).to_not eq(nil)
        expect(res).to eq(12) # TODO: À RÉGLER
      end
    end
    
    context 'avec un utilisateur non membre et non follower mais trustable' do
      before :all do
        # TODO: Attribuer une REMOTE_ADDR unique
        @u = User::new
      end
      it 'retourne l’UID unique de l’user' do
        res = u.uid
        expect(res).not_to eq(nil)
        expect(res).to eq(12) # TODO: À RÉGLER
      end
    end
    
    context 'avec un utilisateur non trustable' do
      before :all do
        ENV['REMOTE_ADDR'] = nil
        @u = User::new
      end
      it 'retourne NIL' do
        expect(u.uid).to eq(nil)
      end
    end
  end
  
end