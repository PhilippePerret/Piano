
##
# Retourne true si le Hash +h+ contient les données +expected+
# La comparaison est stricte, toutes les données doivent être
# trouvées.
#
def hash_contains h, expected
  expected.each do |k, v|
    return false unless h[k] == v
  end
  return true
end