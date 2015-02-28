# encoding: UTF-8
=begin

Classe DaylyWork
----------------
Confection d'une séance de travail

Note : en bas de ce module est définie la méthode `seance' pour utilisation
dans les vues.
=end
class DaylyWork
  
  TUNES = {
    'C' => {fr: 'DO majeur', maj: true, min: false},
    'F' => {fr: 'FA majeur', maj: true, min: false},
    'Bb' => {fr: 'SIb majeur', maj: true, min: false},
    'Eb' => {fr: 'MIb majeur', maj: true, min: false},
    'Ab' => {fr: 'LAb majeur', maj: true, min: false},
    'Db' => {fr: 'RÉb majeur', maj: true, min: false},
    'Gb' => {fr: 'SOLb majeur', maj: true, min: false},
    # ---
    'G' => {fr: 'SOL majeur', maj: true, min: false},
    'D' => {fr: 'RÉ majeur', maj: true, min: false},
    'A' => {fr: 'LA majeur', maj: true, min: false},
    'E' => {fr: 'MI majeur', maj: true, min: false},
    'B' => {fr: 'SI majeur', maj: true, min: false},
    'F#'=> {fr: 'FA# majeur', file: 'Fd', maj: true, min: false},
    # ---
    'Am' => {fr: 'LA mineur', maj: false, min: true},
    'Dm' => {fr: 'RÉ mineur', maj: false, min: true},
    'Gm' => {fr: 'SOL mineur', maj: false, min: true},
    'Cm' => {fr: 'DO mineur', maj: false, min: true},
    'Fm' => {fr: 'FA mineur', maj: false, min: true},
    'Bbm' => {fr: 'SIb mineur', maj: false, min: true},
    'Ebm' => {fr: 'MIb mineur', maj: false, min: true},
    # ---
    'Em' => {fr: 'MI mineur'},
    'Bm' => {fr: 'SI mineur'},
    'F#m' => {fr: 'FA# mineur', file: "Fdm"},
    'C#m' => {fr: 'DO# mineur', file: "Cdm"},
    'G#m' => {fr: 'SOL# mineur', file: "Gdm"}
  }
  class << self
    
    attr_accessor :current
    
    def exec_operation
      return unless self.respond_to?(param(:operation).to_sym)
      self.send param(:operation).to_sym
    end
    
    # ---------------------------------------------------------------------
    #
    #   Opérations
    #
    # ---------------------------------------------------------------------
    
    ##
    #
    # = main =
    #
    # Confection de la séance de travail
    #
    def confectionner_seance
      self.current = seance = new
      seance.confectionner
    end
    
    
    ##
    # Dossier contenant les ressources, dans ce dossier
    #
    def folder_ressources
      @folder_ressources ||= File.join('article', 'userc', 'dayly_work', 'ressources')
    end
  
    
  end # << self
  
  # ---------------------------------------------------------------------
  #
  #     Instance
  #
  # ---------------------------------------------------------------------
  def initialize
    
  end
  
  ##
  #
  # Méthode principale procédant à la confection de la séance
  #
  #
  def confectionner
    ##
    ## Récupérer les informations du follower/membre
    ##
    debug "tonalites_jouees : #{tonalites_jouees.inspect}"
    
  end
  
  ##
  #
  # Méthode principale qui enregistre cette session, donc qui
  # en prend compte dans les enregistrements.
  # Si la séance n'est pas enregistrée, on ne pourra pas savoir ce
  # qu'a fait le reader.
  #
  def consigner
    hdata = { 
      tune: param( :tune )
    }
    debug "hdata: #{hdata.inspect}"
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes primaires pour confectionner la séance
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # Tonalité pour la séance courante
  #
  def tune
    @tune ||= begin
      deja_jouees = tonalites_jouees
      tns = all_tunes_by_niveau.reject { |t| deja_jouees.include? t }
      tns = all_tunes_by_niveau if tns.empty?
      if tns.count > 1
        5.times { |iti| tns = tns.shuffle }
      end
      tns.first
    end
  end
  
  ##
  #
  # Les données de tonalité de la tonalité courante
  #
  def data_tune
    @data_tune ||= TUNES[tune]
  end
  
  # ---------------------------------------------------------------------
  #
  #    Méthodes d'état
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # @return true si c'est une tonalité majeure
  #
  def majeure?
    data_tune[:maj] == true
  end
  ##
  #
  # @return true si la tonalité courante est mineure
  #
  def mineure?
    data_tune[:min] == true
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes de données
  #
  # ---------------------------------------------------------------------
  
  ##
  # Niveau du reader (debutant, moyen ou expert)
  def niveau
    @niveau ||= param('user_niveau')
  end
  ##
  # Niveau comme nombre
  def niveau_i
    case niveau
    when 'debutant' then 1
    when 'moyen'    then 2
    when 'expert'   then 3
    end
  end
  
  ##
  #
  # @return la liste des tonalités déjà jouées (avant un cycle complet)
  #
  def tonalites_jouees
    @tonalites_jouees ||= get(:played_tunes, [])
  end
  
  ##
  #
  # Liste de toutes les tonalités possibles en fonction du niveau
  #
  def all_tunes_by_niveau
    # 1 : C F Bb  / G D / Em Dm Am
    # 2 : + Eb Ab  / A E / Gm Bm Cm Fm C#m
    # 3 : + Db Gb / B F# / F#m Bbm Ebm G#m D#m
    tunes = ["C", "F", "Bb", "G", "D"]
    tunes += ["Eb", "Ab", "A", "E", "Gm", "Bm", "Cm", "Fm", "C#m"] if niveau_i > 1
    tunes += ["Db", "Gb", "B", "F#", "F#m", "Bbm", "Ebm", "G#m", "D#m"] if niveau_i > 2
    tunes
  end
  
  
  def user
    @user || current_user
  end
  
  def get key, default_value = nil
    ppdestore( pstore_path, key ) || default_value
  end
  def set hdata
    ppstore pstore_path, hdata
  end
  
  ##
  #
  # Toutes les données de séances de travail
  #
  def data
    @data ||= begin
      h = {}
      PPStore::new(pstore_path).transaction do |ps|
        ps.roots.each { |k| h.merge! k => ps[k] }
      end
    end
  end
  
  # ---------------------------------------------------------------------
  #
  #     Méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # Retourne une tonalité non jouée
  #
  def unplayed_tune
    
  end
  
  # ---------------------------------------------------------------------
  #
  #     Méthodes d'helper
  #
  # ---------------------------------------------------------------------
  
  def tune_fr
    @tune_fr ||= data_tune[:fr]
  end
  
  #
  # @return l'image de la gamme de la tonalité courante
  #
  def tune_gamme
    img_name    = (data_tune[:file] || tune) + ".png"
    img_relpath = "tonalite/#{img_name}"
    app.image_icare img_relpath
  end
  
  ##
  #
  # @return l'image de l'enchainement type dans la tonalité
  # courante
  #
  def tune_enchainement_type_img
    img_name    = "#{data_tune[:file] || tune}-#{tune_enchainement_type(true)}.png"
    img_relpath = "tonalite/#{img_name}"
    app.image_icare img_relpath
  end
  
  def tune_enchainement_type as_file = false
    if as_file
      @tune_enchainement_type_as_file ||= (majeure? ? "I_II_V_I" : "I_IV_VII_I")
    else
      @tune_enchainement_type ||= (majeure? ? "I II V I" : "I IV VII I")
    end
  end
  # ---------------------------------------------------------------------
  #
  #   Méthodes paths
  #
  # ---------------------------------------------------------------------
  
  def pstore_path
    @pstore_path ||= File.join(app.folder_data, 'reader', "daylywork-#{user.uid}.pstore")
  end
end

##
#
# Raccourci "seance" pour les vues
#
def seance 
  @seance ||= DaylyWork::current
end