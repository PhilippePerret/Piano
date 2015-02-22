require "spec_helper"

describe "PPStore #{relative_path __FILE__}" do
  
  def create_busy_file
    return if File.exists? path_busy_file
    File.open(path_busy_file, 'wb'){ |f| f.write Time.now }
  end
  def remove_busy_file
    File.unlink path_busy_file if File.exist? path_busy_file
  end
  def path_busy_file
    @path_busy_file ||= File.join('.', 'data', 'pstore', 'test.pstore-busy')
  end
  
  
  let(:pps) { @ppstore } # NE PAS UTILISER ppstore QUI EST UNE FONCTION
  
  it 'existe' do
    expect{PPStore}.to_not raise_error
  end
  
  # ---------------------------------------------------------------------
  #
  #   La class PPStore
  #
  # ---------------------------------------------------------------------
  
  # ---------------------------------------------------------------------
  #
  #   Les instances PPStore
  #
  # ---------------------------------------------------------------------
  describe "Instance PPStore" do
    before :all do
      @ppstore = PPStore::new 'data/pstore/test'
    end
    
    #path
    describe "#path" do
      before :all do
        @full_path = File.expand_path(File.join('.', 'data', 'pstore', 'test.pstore'))
      end
      it 'répond' do
        expect(pps).to respond_to :path
      end
      context 'avec un path fourni sans "./" et sans ".pstore"' do
        it 'retourne le path complet' do
          p = PPStore::new 'data/pstore/test'
          expect(p.path).to eq(@full_path)
        end
      end
      context 'avec un path fourni avec le "./" mais sans le ".pstore"' do
        it 'retourne le path complet' do
          p = PPStore::new './data/pstore/test'
          expect(p.path).to eq(@full_path)
        end
      end
      context 'avec un path relatif complet' do
        it 'retourne le path complet' do
          p = PPStore::new './data/pstore/test.pstore'
          expect(p.path).to eq(@full_path)
        end
      end
    end
    
    
    #set
    describe "#set" do
      it 'répond' do
        expect(pps).to respond_to :set
      end
      # Elle est testée en profondeur par la méthode ppstore
    end
    
    
    #get
    describe "#get" do
      it 'répond' do
        expect(pps).to respond_to :get
      end
      # Elle est testée en profondeur par la méthode ppdestore
    end
    
    
    #remove
    describe "#remove" do
      it 'répond' do
        expect(pps).to respond_to :remove
      end
      # Elle est testée en profondeur par la méthode ppstore_remove
    end
    
    
    #busy?
    describe "#locked?" do
      it 'répond' do
        expect(pps).to respond_to :busy?
      end
      context 'avec un pstore non occupé' do
        it 'retourne false' do
          expect(pps).to_not be_busy
        end
      end
      context 'avec un pstore occupé par un autre thread' do
        it 'retourne true' do
          th = Thread::new{
            ppstore 'data/pstore/test',{ une: "Donnée dans thread"}, 2
          }
          sleep 0.1
          expect(pps).to be_busy
          sleep 0.5 while th.alive?
          expect(pps).to_not be_busy
        end
      end
    end
    
    
    #set_busy
    describe "#set_busy" do
      after :all do
        remove_busy_file
      end
      it 'répond' do
        expect(pps).to respond_to :set_busy
      end
      it 'crée un fichier indiquant que le pstore est occupé' do
        expect(File).to_not be_exist path_busy_file
        pps.set_busy
        expect(File).to be_exist path_busy_file
      end
    end

    #unset_busy
    describe "#unset_busy" do
      after :all do
        remove_busy_file
      end
      it 'répond' do
        expect(pps).to respond_to :unset_busy
      end
      it 'détruit le fichier indiquant que le pstore est occupé' do
        create_busy_file
        expect(File).to be_exist path_busy_file
        pps.unset_busy
        expect(File).to_not be_exist path_busy_file
      end
    end
  end
  
  
  # ---------------------------------------------------------------------
  #
  #   Les fonctions principales
  #
  # ---------------------------------------------------------------------
  describe "La fonction ppstore" do
    before :all do
      @ppstore = PPStore::new 'data/pstore/test'
    end
    it 'répond' do
      expect{ppstore 'data/pstore/test', {une: "donnée"}}.to_not raise_error
    end
    context 'avec un PStore non bloqué' do
      it 'enregistre normalement une donnée' do
        @value = "Data à #{Time.now}"
        res = ppstore 'data/pstore/test', {data: @value}
        expect(res).to eq(true)
        val = PStore::new('./data/pstore/test.pstore').transaction do |ps|
          ps.fetch :data, nil
        end
        expect(val).to_not eq(nil)
        expect(val).to eq(@value)
      end
    end
    
    context 'avec un PStore occupé par un autre thread' do
      it 'enregistre correctement la donnée' do
        Thread::new {
          ppstore 'data/pstore/test', {data: "Donnée définie dans le thread"}, 2
        }
        sleep 0.1
        @expected = "Donnée définie HORS du thread"
        ppstore 'data/pstore/test', data: @expected
        expect(ppdestore 'data/pstore/test', :data).to eq(@expected)
        ppstore_remove 'data/pstore/test', :data
      end
      it 'enregistre la donnée en tenant compte de la donnée modifiée dans l’autre thread' do
        Thread::new {
          ppstore 'data/pstore/test', {data: 1}, 2
        }
        sleep 0.5
        expect(pps).to be_busy
        current_value = ppdestore 'data/pstore/test', {:data => 0}
        current_value = current_value[:data]
        ppstore 'data/pstore/test', data: (current_value + 1)
        sleep 1
        expect(ppdestore 'data/pstore/test', :data).to eq(2)
      end
    end
  end
  
  describe "La fonction ppdestore" do
    before :all do
      @ppstore = PPStore::new "data/pstore/test"
    end
    it 'répond' do
      expect{ppdestore 'data/pstore/test', :une}.to_not raise_error
    end
    it 'retourne la valeur demandée quand c’est une simple clé' do
      @value = "La valeur à #{Time.now}"
      ppstore 'data/pstore/test', data: @value
      res = ppdestore 'data/pstore/test', :data
      expect(res).to eq(@value)
    end
    it 'retourne la valeur demandée après le traitement par un autre thread' do
      @value = "La valeur HORS thread à #{Time.now}"
      ppstore 'data/pstore/test', data: @value
      Thread::new {
        sleep 0.2
        @value_in = "Valeur IN thread à #{Time.now}"
        ppstore 'data/pstore/test', {data: @value_in}, 2
      }
      sleep 0.2
      res = ppdestore 'data/pstore/test', :data
      expect(res).to_not eq(@value)
      expect(res).to start_with "Valeur IN thread"
    end
  end
  
end