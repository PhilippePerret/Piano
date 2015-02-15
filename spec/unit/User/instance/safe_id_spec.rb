require "spec_helper"

describe "Safe ID de l'user #{relative_path __FILE__}" do
  before :all do
    @u = User::new
  end
  let(:u) { @u }
  
  
  before :each do
    @u.instance_variable_set('@safe_id', nil)
  end
  
  def init_all
    ENV['REMOTE_ADDR'] = nil
    ENV['HTTP_CLIENT_IP'] = nil
    ENV['HTTP_X_FORWARDED_FOR'] = nil
    @u.instance_variable_set('@is_trustable', nil)
    @u.instance_variable_set('@is_identified', nil)
    @u.instance_variable_set('@remote_ip', nil)
  end
  
  describe "Méthode #safe_id" do
    it 'répond' do
      expect(u).to respond_to :safe_id
    end
    
    context 'avec un User identifié' do
      before :all do
        @u = User::get(1)
        @u.instance_variable_set('@is_identified', true)
      end
      it 'retourne un hash conforme' do
        res = u.safe_id
        expect(res).to be_instance_of Hash
        expect(res).to eq({
          m: 1, f: 0, ref: u.id, ref_type: :id, id: "1-0-#{u.id}"
          })
      end
    end
    
    context 'avec un User follower' do
      before :all do
        ENV['REMOTE_ADDR'] = "124.1.2.3"
        umail = "sonmail@chez.lui"
        new_follower(mail: umail, pseudo: "Son Nom", ip: "124.1.2.3")
        @u = User::get_as_follower umail
      end
      it 'retourne un Hash valide' do
        res = u.safe_id
        expect(res).to be_instance_of Hash
        expect(res).to eq({
          m: 0, f: 1, ref: u.mail, ref_type: :mail, id: "0-1-#{u.mail}"
        })
      end
    end
    
    context 'avec un user non membre non follower possédant une adresse IP valide' do
      before :all do
        init_all
        ENV['REMOTE_ADDR'] = "127.0.0.2"
      end
      it 'retourne un Hash valide' do
        res = u.safe_id
        expect(res).to be_instance_of Hash
        expect(res).to eq({
          m: 0, f: 0, ref: ENV['REMOTE_ADDR'], ref_type: :ip, id: "0-0-#{ENV['REMOTE_ADDR']}"
        })
      end
    end
    
    
    context 'avec un User non trustable' do
      before :all do
        init_all
      end
      it 'retourne NIL' do
        expect(u.safe_id).to eq(nil)
      end
    end
    
  end
  
  
end