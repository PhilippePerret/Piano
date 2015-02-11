# encoding: UTF-8
class Fixnum
  DUREE_MINUTE  = 60
  DUREE_HEURE   = 60 * DUREE_MINUTE
  DUREE_JOUR    = 24 * DUREE_HEURE

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self

  end
  
  # ---------------------------------------------------------------------
  #   Instance 
  # ---------------------------------------------------------------------
  
  # Retourne la date correspondant au fixnum (quand c'est un timestamp)
  def as_date format = :dd_mm_yyyy
    format_str =
    case format
    when :dd_mm_yyyy  then "%d %m %Y"
    when :dd_mm_yy    then "%d %m %y"
    when :mm_yyyy     then "%m %Y"
    when :mm_yy       then "%m %y"
    when :d_mois_yyyy then return as_human_date
    when :d_mois_court_yyyy then return as_human_date false
    else
      nil
    end
    unless format_str.nil?
      Time.at(self).strftime(format_str)
    end
  end
  MOIS_LONG = ['','janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 
    'septembre', 'octobre', 'novembre', 'décembre']
  MOIS_COURT = ['','jan', 'fév', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 
    'sept', 'oct', 'nov', 'déc']
  def as_human_date mois_long = true, with_clock = false
    mois = mois_long ? MOIS_LONG[Time.at(self).month] : MOIS_COURT[Time.at(self).month]
    Time.at(self).strftime("%e #{mois} %Y#{with_clock ? ' - %H:%M' : ''}").strip
  end
  
  def as_horloge
    h = self / 3600
    r = self % 3600
    m = r / 60 ; m = "0#{m}" if m < 10
    s = r % 60 ; s = "0#{s}" if s < 10
    ho = "#{m} m #{s} s"
    ho.prepend("#{h} h ") unless h == 0
  end
  
  # @usage : <nombre>.day ou <nombre>.days
  # Retourne le nombre de secondes correspondantes
  def days
    self * DUREE_JOUR
  end
  alias :day :days
  
  def years
    self * DUREE_JOUR * 365
  end
  alias :year :years
  
end