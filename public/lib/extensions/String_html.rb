# encoding: UTF-8
class String

  ##
  #
  # Épure le self en supprimant tout retour chariot et tous les
  # espaces superflus
  #
  #
  
  def epure_html
    str = self
    str.gsub!(/\n/,'')
    str.gsub!(/(\s)\s+/, '\1')
    
    ##
    ## On protège certaines espaces
    ## Les mots qui peuvent en avoir avant et après
    # with_spaces = ['a', 'span', 'i', 'em', 'b', 'strong', 'u', 'sup'].join('|')
    # str.gsub!(/\s\<(#{with_spaces})/, '_<\1')
    # str.gsub!(/\<\/(#{with_spaces})\>\s/, '</\1>_')

    @sans_espace ||= ['div', 'table', 'p', 'pre'].join('|')
    @reg_sans_espace_apres ||= /(\<(#{@sans_espace})\>)\s/
    @reg_sans_espace_avant ||= /\s(\<({@sans_espace})\>)/
    str.gsub!(@reg_sans_espace_apres, '\1')
    str.gsub!(@reg_sans_espace_avant, '\1')
    
    ##
    ## On déprotège les espaces
    ##
    # str.gsub!(/_\<(#{with_spaces})/, ' <\1')
    # str.gsub!(/\<\/(#{with_spaces})\>_/, '</\1> ')
    
    return str
  end
  
  class << self
    
    
    # Construction le code HTML de la balise d'ouverture de tabname +tag+ et 
    # d'attributs optionnels +attrs+
    # @note : Toutes les valeurs nil sont retirées
    def opened_tag tag, attrs = nil
      attrs ||= {}
      # Le style peut être fourni par un string ou un Hash
      if attrs[:style].class == Hash
        attrs[:style] = attrs[:style].collect do |prop, value|
          "#{prop}:#{value};"
        end.join('')
      end
      # Traitement attributs spéciaux
      if attrs.has_key? :display
        display = attrs.delete(:display)
        display = case display
        when false then "none"
        when true  then "block"
        else display
        end
        attrs[:style] ||= ""
        attrs[:style] << "display:#{display};"
      end
      attrs = unless attrs.empty?
        " " + attrs.reject{|k,v| v.nil?}.collect do |k,v|
          "#{k}=\"#{v}\""
        end.join(' ') 
      else
        ""
      end
      "<#{tag}#{attrs}>"
    end
  end
  

  # === Construction de balises HTML ===
  
  def as_span_libelle
    self.in_span(:class => 'libelle')
  end
  def as_span_value
    self.in_span(:class => 'value')
  end
  # Met le String dans une balise <tag> en mettant en attribut tous
  # les paramètres passés en argument.
  # @usage        <texte>.<tag>(<args)
  # @exemple      "Mon texte dans un div".in_div(:id => "mon_div", :class => "sa_class")
  # @params {attrs} attrs   Attributs optionnels de la balise
  # Méthode générique
  def html_balise tag, attrs = nil
    self.class.opened_tag(tag, attrs) + "#{self}</#{tag}>"
  end
  def in_h1       attrs = nil;  html_balise 'h1',       attrs end
  def in_h2       attrs = nil;  html_balise 'h2',       attrs end
  def in_h3       attrs = nil;  html_balise 'h3',       attrs end
  def in_div      attrs = nil;  html_balise 'div',      attrs end
  def in_pre      attrs = nil;  html_balise 'pre',      attrs end
  def in_span     attrs = nil;  html_balise 'span',     attrs end
  def in_p        attrs = nil;  html_balise 'p',        attrs end
  def in_ul       attrs = nil;  html_balise 'ul',       attrs end
  def in_ol       attrs = nil;  html_balise 'ol',       attrs end
  def in_li       attrs = nil;  html_balise 'li',       attrs end
  def in_label    attrs = nil;  html_balise 'label',    attrs end
  def in_section  attrs = nil;  html_balise 'section',  attrs end
  def in_table    attrs = nil;  html_balise 'table',    attrs end
  def in_tr       attrs = nil;  html_balise 'tr',       attrs end
  def in_td       attrs = nil;  html_balise 'td',       attrs end
  
  def in_dl       attrs = nil;  html_balise 'dl',       attrs end
  def in_dt       attrs = nil;  html_balise 'dt',       attrs end
  def in_dd       attrs = nil;  html_balise 'dd',       attrs end

  def in_a attrs = nil
    attrs ||= {}
    attrs.merge!( :href => 'javascript:void(0)' ) unless attrs.has_key?(:href)
    html_balise 'a', attrs
  end

  # Noter que pour générer de façon complexe un select, il faut
  # aller voir dans l'extension Array.
  def in_select attrs = nil;  html_balise 'select',   attrs end
  
  # Ajouter :file => true dans +attrs+ pour une formulaire avec upload fichier
  def in_form     attrs = nil
    attrs ||= {}
    attrs = attrs.merge( method: 'POST' ) unless attrs.has_key?(:method)
    if attrs.has_key?( :file ) && attrs[:file] == true
      attrs = attrs.merge(:enctype => 'multipart/form-data')
      attrs.delete(:file)
    end
    html_balise 'form', attrs 
  end
  def in_option   attrs = nil
    attrs ||= {}
    attrs[:selected] = "SELECTED" if attrs.delete(:selected) === true
    html_balise 'option',   attrs 
  end
  def in_input    attrs = nil
    attrs ||= {}
    attrs = attrs.merge( :value => self ) unless self == "" || attrs.has_key?(:value)
    self.class.opened_tag('input', attrs)[0..-2] + " />"
  end
  
  ##
  #
  # @return code pour une image
  #
  # +self+ est le path
  # +attrs+
  #   :center => true
  #       L'image sera placée dans un div centré. La classe .center doit être
  #       définie dans les CSS.
  #   :float  => 'left'/'rigth'
  #       L'image sera placée dans un div flottant à droite ou à gauche.
  #       Noter que la class 'div.air' sera ajoutée, qui doit définir l'air
  #       à laisser autour de l'image.
  #       Les classes 'fleft' et 'fright' doivent être définies.
  #   :legend => "<texte de la légende>"
  #       Si :legend est défini dans les attributs, l'image est retournée
  #       dans un cadre (non visible) avec une légende.
  #       Le style par défaut est 'img_legend' pour le DIV contenant la légende
  #       Le style par défaut pour le div contenant l'image et la légende
  #       est .img_cadre.
  #       On peut sur définir ces valeurs avec les propriétés attrs suivantes :
  #         legend_class:     Nouvelle class CSS pour le div légend
  #         div_class:        Nouvelle class CSS pour le div général
  #
  def in_image attrs = nil
    attrs ||= {}
    attrs.merge!( src: self ) unless self == "" || attrs.has_key?(:src)
    legend        = attrs.delete(:legend)
    if legend
      legend_class  = attrs.delete(:legend_class) || 'img_legend'
      div_class     = attrs.delete(:div_class)    || 'img_cadre'
    end
    centrer_image   = attrs.delete(:center)
    image_flottante = attrs.delete(:float)
    
    ##
    ## Le tag IMG
    ##
    tag_img = self.class.opened_tag('img', attrs)[0..-2] + ' />'
    
    ##
    ## S'il y a une légende
    ##
    tag = if legend
      div_legend = legend.in_div(class: legend_class)
      div_image  = tag_img.in_div
      (div_image + div_legend).in_div(class: div_class)
    else
      tag_img
    end
    
    ##
    ## Si l'image doit être centrée ou floattant
    ##
    if centrer_image
      tag.in_div(class: 'center')
    elsif image_flottante != nil
      tag.in_div(class: "air f#{image_flottante}")
    else
      tag
    end
  end
  alias :in_img :in_image
  
  def in_input_text attrs = nil
    attrs = attrs.merge(type: 'text')
    in_input attrs
  end
  def in_textarea attrs = nil
    html_balise 'textarea', attrs
  end
  # `self' est utilisé comme name, on ajouter "file_" avant pour l'identifiant
  def in_input_file attrs = nil
    attrs ||= {}
    attrs = attrs.merge(type: 'file', value: "")
    attrs = attrs.merge(name: self) unless attrs.has_key?( :name )
    unless attrs.has_key?( :id )
      attrs = attrs.merge :id => "file_" + (self == "" ? attrs[:name] : self)
    end
    attrs = attrs.merge(id: attrs[:id]) 
    in_input attrs
  end
  def in_password attrs = nil
    attrs = attrs.merge(type: 'password')
    in_input attrs
  end
  def in_radio attrs
    attrs = attrs.merge type: 'radio'
    self.in_checkbox attrs
  end
  def in_checkbox attrs
    is_radio = attrs[:type] == 'radio'
    label = attrs.delete(:label)
    label = self if label.nil?
    label_class = attrs.delete(:label_class)
    checked = attrs.delete(:checked)
    attrs = attrs.merge( :checked => "CHECKED" ) if checked === true
    unless attrs.has_key? :id
      prefix = attrs[:prefix] || (is_radio ? 'ra' : 'cb')
      suffix = attrs[:suffix] || (is_radio ? attrs[:value].as_normalized_id : '')
      attrs = attrs.merge(id: "#{prefix}_#{attrs[:name]}#{suffix}")
    end
    unless attrs.has_key? :type # arrive pour les radio
      attrs = attrs.merge(type: "checkbox")
    end
    
    # Class du span contenant le CB et le label
    attrs[:class] ||= []
    attrs[:class] = [attrs[:class]] if attrs[:class].class == String
    attrs[:class] << (is_radio ? 'ra' : 'cb')
    
    # Code retourné
    ("".in_input(attrs) +
    label.
      in_label(:for => attrs[:id], :class => label_class)).
      in_span(id: "div-#{attrs[:id]}", class: attrs[:class].join(' '))
  end
  def in_hidden attrs = nil
    self.in_input(attrs.merge :type => 'hidden') 
  end
  # Le String est le nom du bouton
  def in_submit attrs = nil; "".in_input((attrs||{}).merge :value => self, :type => 'submit') end

  def in_fieldset attrs = nil
    code =
    if attrs && attrs.has_key?(:legend)
      "<legend>#{attrs.delete(:legend)}</legend>" 
    else
      ""
    end + self
    self.class.opened_tag('fieldset', attrs) + code + "</fieldset>"
  end
  
  # Correspond à to_html mais seulement si le string ne commence pas par '<'
  def htmlize
    return self if self.strip.start_with? '<'
    str = self
    str = "<div>#{str}</div>"
    str.to_html
  end
  alias :htmalize :htmlize
  
  # Met les textes séparés par des doubles retours chariot dans des div
  def return_to_div
    self.split("\n\n").collect{|e| "<div>#{e}</div>"}.join("\n")
  end
  
  # Htmlize le string
  # TODO: Il faudrait vraiment améliorer ça
  def to_html
    str = self
    html, lines, iline, balises_ulol, current_ulol = "", [], 0, [], nil
    str.strip.each_line do |line|
      line = line.strip
      if line == ""
        lines[iline-1][:in] = '<div style="margin-bottom:1em;">'
      else
        case line[0]
        when "*"
          line = line[1..-1].strip
          balise_in = ""
          if current_ulol == 'ol'
            balise_in += '</ol>'
            current_ulol = balises_ulol.pop
          end
          if current_ulol != 'ul' 
            balise_in += '<ul>'
            balises_ulol << "ul"
            current_ulol = 'ul' 
          end
          balise_in += '<li>'
          balise_out = '</li>'
        when "."
          line = line[1..-1].strip
          balise_in = ""
          if current_ulol == 'ul'
            balise_in += '</ul>'
            current_ulol = balises_ulol.pop
          end
          if current_ulol != 'ol' 
            balise_in += '<ol>'
            balises_ulol << "ol"
            current_ulol = 'ol' 
          end
          balise_in += '<li>'
          balise_out = '</li>'
        else
          balise_in = ""
          if current_ulol
            balises_ulol.reverse.each{ |bal| balise_in += "</#{bal}>" }
            current_ulol, balises_ulol = nil, []
          end
          balise_in   += '<p>'
          balise_out  = '</p>'
        end
        lines << {:content => line, :in => balise_in, :out => balise_out}
        iline += 1
      end
    end
    fin = ""
    if current_ulol
      balises_ulol.reverse.each{ |bal| fin += "</#{bal}>" }
    end
    lines.each do |dline|
      html << "#{dline[:in]}#{dline[:content]}#{dline[:out]}\n"
    end
    html << fin
    "#{html}"
  end
  
end