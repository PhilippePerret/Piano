##
# Retourne le path au pstore de nom ou chemin relatif +pstore+
# note TODO: Cette méthode doit être propre à l'application, il
# faudrait la mettre ailleurs.
#
def pstore_path pstore
  File.join('.', 'data', 'pstore', pstore)
end

##
#
# Si +explode+ est true, on considère que chaque clé est une
# clé du pstore et que la valeur correspond exactement à la
# la valeur pstore[clé]. Sinon, on cherche une donnée Hash
# qui contient les data fournies
#
def pstore_has_data pstore, data, explode = false
  pstore.concat('.pstore') unless pstore.end_with? ".pstore"
  ok = true
  error = nil
  ps_path = pstore_path pstore
  File.exist?(ps_path) || raise( "Le pstore #{ps_path} devrait exister." )
  PStore::new(ps_path).transaction do |ps|
    if explode
      data.each do |k, v|
        if ps.fetch(k, :unfound) == :unfound
          error = "la clé #{k.inspect} est introuvable"
          ok = false
          break
        elsif ps[k] != v
          error = "La clé #{k.inspect} devrait avoir la valeur #{v.inspect}. Elle vaut #{ps[k].inspect}"
          ok = false
          break
        end
      end
    else
      # On cherche une valeur Hash qui contient les data
      # fournies
      ok = false
      ps.roots.each do |root|
        ps_data = ps[root]
        next unless ps_data.class == Hash
        if hash_contains( ps_data, data)
          ok = true
          break
        end
        break if ok
      end
    end
  end
  ok || begin
    mess_err = explode ? error : "Impossible de trouver une donnée Hash contenant #{data.inspect}"
    raise "#{mess_err} dans le pstore #{ps_path}"
  end
end

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