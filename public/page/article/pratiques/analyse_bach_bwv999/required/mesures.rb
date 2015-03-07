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
  offset = case mes_x
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
  when 25 then [1640, 16]
  else [110, 310]
  end
  size = case mes_x
  when 1 then [300, 140]
  else
    [300, 140]
  end
  "Mesure #{mes_x}".in_div(class:'mes') + image_partielle( offset, size, positionning )
end
