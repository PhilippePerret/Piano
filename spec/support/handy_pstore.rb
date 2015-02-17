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
# Test l'existence d'une donnée dans un pstore.
#
# @syntaxe
#
#   pstore_has_data <pstore>, <data>[, <explode>[, <strict>]]
#
# Avec seulement DEUX argument (pstore et data), la méthode va
# chercher dans le pstore un Hash (et seulement un hash) qui 
# contient les données +data+.
#
# Si +explode+ est à TRUE, +data+ est considéré comme ayant en
# clé la root dans le pstore de la donnée à tester.
#     pstore_has_data monpstore, { 1 => {une: "valeur"} }, true
# … va tester la donnée root `1' et voir si cette donnée est un
# hash qui contient une: "valeur".
# Si +strict+ est TRUE (FALSE par défaut), alors la valeur doit être
# strictement égale.
#   pstore_has_data monpstore, { 1 => {une: "valeur"} }, true, true
# … produira une erreur si ps[1] n'est pas strictement égale à 
# {une: "valeur"}.
# En revanche, si +strict+ est FALSE, la méthode va seulement checker
# que la données ps[1] est bien un hash qui contient, entre autres valeurs,
# la clé 'une' avec la valeur "valeur".
#
def pstore_has_data pstore, data, explode = false, strict = false
  pstore.concat('.pstore') unless pstore.end_with? ".pstore"
  ok = true
  error = nil
  ps_path = File.exist?(pstore) ? pstore : pstore_path(pstore)
  File.exist?(ps_path) || raise( "Le pstore #{ps_path} devrait exister." )
  PStore::new(ps_path).transaction do |ps|
    if explode
      data.each do |k, v|
        if ps.fetch(k, :unfound) == :unfound
          error = "la clé #{k.inspect} est introuvable"
          ok = false
          break
        else
          if strict
            if ps[k] != v
              error = "La clé #{k.inspect} devrait avoir la valeur #{v.inspect}. Elle vaut #{ps[k].inspect}"
              ok = false
              break
            end
          else
            ##
            ## Mode non strict : si v est un hash, elle doit simplement
            ## contenir les valeurs fournies
            ##
            case v
            when Hash
              unless hash_contains ps[k], v
                error = "La valeur Hash de la clé #{k.inspect} devrait avoir les valeurs #{v.inspect}. Elle vaut #{ps[k].inspect}"
                ok = false
                break
              end
            when Array
              unless array_contains ps[k], v
                error = "La valeur Array de la clé #{k.inspect} devrait avoir les valeurs #{v.inspect}. Elle vaut #{ps[k].inspect}"
                ok = false
                break
              end
            else
              if ps[k] != v
                error = "La clé #{k.inspect} devrait avoir la valeur #{v.inspect}. Elle vaut #{ps[k].inspect}"
                ok = false
                break
              end
            end
          end
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
