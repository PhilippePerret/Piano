require "spec_helper"

describe "Propriétés instance User #{relative_path __FILE__}" do
  before :all do
    @u = User::new
  end
  let(:u) { @u }
  
  describe "#remote_ip" do
    before :each do
      u.instance_variable_set('@remote_ip', nil)
    end
    it 'répond' do
      expect(u).to respond_to :remote_ip
    end
    context 'avec REMOTE_ADDR défini' do
      before :all do
        ENV['REMOTE_ADDR'] = '127.0.0.1'
      end
      it 'retourne l’adresse IP de l’utilisateur' do
        res = u.remote_ip
        expect(res).to_not eq(nil)
        expect(res).to eq('127.0.0.1')
      end
    end
    context 'avec HTTP_CLIENT_IP défini' do
      before :all do
        ENV['REMOTE_ADDR'] = nil
        ENV['HTTP_CLIENT_IP'] = '127.0.0.2'
      end
      it 'retourne une adresse IP' do
        res = u.remote_ip
        expect(res).to_not eq(nil)
        expect(res).to eq('127.0.0.2')
      end
    end
    context 'avec HTTP_X_FORWARDED_FOR défini' do
      before :all do
        ENV['REMOTE_ADDR'] = nil
        ENV['HTTP_CLIENT_IP'] = nil
        ENV['HTTP_X_FORWARDED_FOR'] = "127.0.0.3"
      end
      it 'retourne une adresse IP' do
        res = u.remote_ip
        expect(res).to_not eq(nil)
        expect(res).to eq("127.0.0.3")
      end
    end
    
  end
end