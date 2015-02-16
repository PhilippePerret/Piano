=begin

Handy méthodes pour l'intégration

=end

def cu_url
  @cu_url ||= begin
    MODE_PRODUCTION ? URL_ONLINE_PRODUCTION : URL_OFFLINE_DEVELOPPEMENT
  end
end

def go_home
  visit "http://#{cu_url}"
  page_has_logo
end

##
#
# Cliquer un lien principal, donc un lien se trouvant
# dans la table des matières gauche
#
def click_main_link titre_lien
  within("nav#main_buttons") do
    page.find("form.navlink > div.titre", text: titre_lien).click
  end
end
alias :click_main_menu :click_main_link