require "spec_helper"

describe "Trustable User #{relative_path __FILE__}" do
  before :all do
    @u = User::new
  end
  let(:u) { @u }
  
  def init_all
    ENV['REMOTE_ADDR'] = nil
    ENV['HTTP_CLIENT_IP'] = nil
    ENV['HTTP_X_FORWARDED_FOR'] = nil
    @u.instance_variable_set('@is_trustable', nil)
    @u.instance_variable_set('@is_identified', nil)
    @u.instance_variable_set('@remote_ip', nil)
  end
  describe "Méthode #trustable?" do
    it 'répond' do
      expect(u).to respond_to :trustable?
    end
    
    context 'avec un User identifié' do
      before :all do
        init_all
        @u.instance_variable_set('@is_identified', true)
      end
      it 'retourne true' do
        expect(u).to be_trustable
      end
    end
    
    context 'avec un User qui possède un REMOTE_ADDR' do
      before :all do
        init_all
        ENV['REMOTE_ADDR'] = "127.0.0.7"
      end
      it 'retourne true' do
        expect(u).to be_trustable
      end
    end
    
    context 'avec un User qui possède un HTTP_CLIENT_IP' do
      before :all do
        init_all
        ENV['HTTP_CLIENT_IP'] = "un http client ip"
      end
      it 'retourne false (spoofable)' do
        expect(u).to_not be_trustable
      end
    end
    
    context 'avec un User qui possède un HTTP_X_FORWARDED_FOR' do
      before :all do
        init_all
        ENV['HTTP_X_FORWARDED_FOR'] = "127, see me"
      end
      it 'retourne false (spoofable)' do
        expect(u).to_not be_trustable
      end
    end
    
    context 'avec un User sans remote IP définissable et non identifié' do
      before :all do
        init_all
      end
      it 'retourne false' do
        expect(u).to_not be_trustable
      end
    end
  end
end