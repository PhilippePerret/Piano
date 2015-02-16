
##
# Erreur si page ne contient pas le titre (h1) +titre+
def title_is titre
  expect(page).to have_css('section#content') do
    with_tag('div#main_article > h1', titre)
  end
end
##
# Erreur si la page a un titre h1
def page_has_no_title
  expect(page).to_not have_css('section#content > div#main_article > h1')
end

##
# Erreur si page ne contient pas le sous-titre (h2) +sous_titre+
def subtitle_is sous_titre
  expect(page).to have_css('section#content') do
    with_tag('div#main_article > h2', sous_titre)
  end
end
##
# Erreur si page contient un sous-titre h2
def page_has_no_subtitle
  expect(page).to_not have_css('section#content > div#main_article > h2')
end

##
# Erreur si la page ne contient pas le sous-titre H3 +titre+
# avec les arguments optionnels +args+ (souvent, id: et/ou class:)
def page_has_subsubtitle titre, args = nil
  args ||= {}
  bal = "h3"
  bal << "##{args[:id]}" if args.has_key? :id
  bal << ".#{args[:class]}" if args.has_key? :class
  expect(page).to have_css("section#content > div#main_article > #{bal}", titre)
end

def page_has_content texte
  expect(page).to have_content(texte)
end
##
#
# Vérifie que la page contient un logo conforme.
#
# Noter que cette méthode est appelée automatique par la
# méthode `go_home' donc qu'il est inutile de l'appeler
#
def page_has_logo
  expect(page).to have_css('section#header') do
    with_tag('div#app_name', "Le Cercle pianistique")
  end
end

