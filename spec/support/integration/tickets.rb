=begin
Méthodes support handy pour les tickets
=end
##
# Retourne les données du ticket de path +path
def data_ticket path
  Marshal::load( File.read path)
end