require "spec_helper"

describe "Vote de l'user #{relative_path __FILE__}" do
  before :all do
    @u = User::new
    ENV['REMOTE_ADDR'] = "127.1.2.54"
  end
  def pstore_vote
    @pstore_vote ||= File.join(app.folder_pstore, 'votes_articles.pstore')
  end
  def add_pstore_vote ip, time
    PStore::new(pstore_vote).transaction do |ps|
      ps[ip] = time
    end
  end
  def get_pstore_vote ip
    PStore::new(pstore_vote).transaction do |ps| ps[ip] end
  end
  def remove_pstore_vote ip
    PStore::new(pstore_vote).transaction do |ps|
      ps.delete ip
    end
  end
  let(:u) { @u }
  describe "Méthode #can_vote_articles?" do
    it 'répond' do
      expect(u).to respond_to :can_vote_articles?
    end
    context 's’il a déjà voté dans les deux mois' do
      before :all do
        @time_vote = Time.now.to_i - 3600
        add_pstore_vote @u.remote_ip, @time_vote
      end
      it 'retourne false' do
        expect(u).to_not be_can_vote_article
      end
      it 'ne modifie pas la donnée de vote' do
        res = get_pstore_vote u.remote_ip
        expect(res).to eq(@time_vote)
      end
    end
    context 's’il n’a pas encore voté' do
      before :all do
        @start_time = Time.now.to_i
        remove_pstore_vote @u.remote_ip
      end
      it 'retourne true' do
        expect(u).to be_can_vote_article
      end
    end
    context 's’il a voté il y a plus de deux mois' do
      before :all do
        @start_time = Time.now.to_i
        add_pstore_vote @u.remote_ip, Time.now.to_i - 61.days
      end
      it 'retourne true' do
        expect(u).to be_can_vote_article
      end
    end
  end
end