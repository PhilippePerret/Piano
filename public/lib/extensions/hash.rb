# encoding: UTF-8
# Extension de la class Hash

class Hash
  
  ##
  # Retourne le hash sous forme de array
  def to_array
    self.collect{|k,v| v}
  end
  
  # Merge profond simple
  def deep_merge hash
    merged = self
    hash.each do |k, v|
      if v.class == Hash
        merged = merged.merge( k => merged[k].deep_merge(v) )
      else
        merged = merged.merge k => v
      end
    end
    merged
  end
  
  # Pour un affichage plain (pas HTML), affiche le hash de façon lisible, chaque
  # clé passant à la ligne + des retraits.
  # @usage : puts <hash>.pretty_inspect
  # @param  retrait {Fixnum|String}
  #         Le retrait à appliquer à chaque donnée
  def pretty_inspect retrait = nil
    retrait = case retrait
    when Fixnum   then "  " * retrait
    when String   then retrait
    else ""
    end
    str = "{\n"
    self.each do |k, v|
      str += retrait + "#{k.inspect} => " +
      case v
      when Hash then "\n" + v.pretty_inspect(retrait + 1)
      else
        v.inspect
      end +
      "\n"
    end
    str + retrait + "}"
  end
  
  # Plutôt une méthode de débuggage : pour faire un affichage
  # plus lisible d'un Hash.
  def pretty_puts deep = 1
    self.collect do |key, value|
      '<div>' + ("&nbsp;&nbsp;"*deep) + "#{key.inspect} => " + 
      case value.class.to_s
      when "Hash" then value.pretty_puts(deep + 1)
      else
        value.inspect
      end +
      '</div>'
    end.join("")
  end
  
  # Remplace les "true", "false", "null" par true, false, nil
  def values_str_to_real
    self.each do |k,v|
      v = case v.class.to_s
      when 'Hash', 'Array' then v.values_str_to_real
      when 'String' then
        case v
        when "true" then true
        when "false" then false
        when "nil", "null" then nil
        else v
        end
      else v
      end
      self[k] = v
    end
  end
  
  # Permet de remplacer les clés 'string' par :string
  # Utile par exemple pour des données JSON récupérées
  def to_sym
    hash_ruby = {}
    self.each do |k, v|
      k = k.to_s[0..-3] if k.to_s.end_with? '[]'
      v_ruby =  case v.class.to_s
                  when 'Hash'   then v.to_sym
                  when 'Array'  then
                    v.collect do |e| 
                      case e.class.to_s
                        when 'Hash', 'Array' then e.to_sym
                        else e
                      end 
                    end
                  else v 
                end
      hash_ruby = hash_ruby.merge( k.to_sym => v_ruby )
    end
    hash_ruby
  end
end