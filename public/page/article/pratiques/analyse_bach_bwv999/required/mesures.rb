# encoding: UTF-8
=begin

Définition des mesures

=end


##
## Positions (offsets) dans l'image générales
##
## Mettre le deuxième argument à TRUE pour pouvoir définir
## la portion de l'image à prendre.
##
def image_mesure mes_x, positionning = false
  
  ##
  ## Est-ce un intervalle de mesure (p.e. '1_7')
  ## ou une mesure seule ?
  ##
  ## Notes :
  ##    size    = [largeur, hauteur]
  ##    offset  = [top, left]
  ##
  if mes_x.to_s.index('_')
    mes_x, mes_y = mes_x.split('_')
    top_x, left_x = offsets_mesure mes_x.to_i
    top_y, left_y = offsets_mesure mes_y.to_i
    if top_x != top_y
      offset  = [top_x, 0]
      haut = top_x
      bas  = top_y + 140
      size    = [780, bas - haut]
    else
      offset  = [top_x, left_x]
      size    = [left_y - left_x + 300, 140]
    end
    legend  = "Mesures #{mes_x} à #{mes_y}"
  else
    offset  = offsets_mesure mes_x
    size    = sizes_mesure mes_x
    legend  = "Mesure #{mes_x}"
  end
  
  legend.in_div(class:'mes') + image_partielle( offset, size, positionning )
end

##
# Retourne la taille de l'image pour la mesure +mes+
#
def sizes_mesure mes
  case mes
  when 1 then [300, 140]
  else
    [300, 140]
  end
end
##
#
# Retourne l'offset (top, left) de la mesure de numéro +mes+
#
def offsets_mesure mes
  case mes
  when 1 then [110, 80] # top, left
  when 2 then [110, 310]
  when 3 then [110, 520]
  when 4 then [286, 40]
  when 5 then [288, 280]
  when 6 then [288, 490]
  when 7 then [476, 16]
  when 8 then [476, 266]
  when 9 then [476, 496]
  when 10 then [668, 16]
  when 11 then [668, 272]
  when 12 then [668, 492]
  when 13 then [858, 24]
  when 14 then [858, 284]
  when 15 then [858, 494]
  when 16 then [1050, 20]
  when 17 then [1050, 280]
  when 18 then [1050, 490]
  when 19 then [1238, 20]
  when 20 then [1238, 276]
  when 21 then [1238, 490]
  when 22 then [1440, 24]
  when 23 then [1440, 280]
  when 24 then [1440, 490]
  when 25 then [1640, 22]
  when 26 then [1640, 285]
  when 27 then [1640, 495]
  when 28 then [1852, 22]
  when 29 then [1852, 282]
  when 30 then [1852, 502]
  when 31 then [2052, 16]
  when 32 then [2052, 282]
  when 33 then [2052, 502]
  when 34 then [2244, 22]
  when 35 then [2244, 282]
  when 36 then [2244, 502]
  when 37 then [2434, 22]
  when 38 then [2434, 282]
  when 39 then [2434, 502]
  when 40 then [2649, 14]
  when 41 then [2649, 253]
  when 42 then [2649, 433]
  when 43 then [2649, 660]
  else [110, 310]
  end
end
