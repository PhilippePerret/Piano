require "spec_helper"

feature 'Test général des pages' do
  
  scenario 'Un visiteur rejoint le site et trouve une page conforme' do
    
    go_home
    
    page_has_no_title
    page_has_no_subtitle
    
  end
  
  scenario 'Un visiteur peut voir la page de la liste des membres' do
    go_home
    click_main_link "Membres du cercle"
    title_is "Le Cercle pianistique"
    subtitle_is "Les Membres du cercle"
    ["Administrateur", "Rédacteur", "Sentinelle", "Veilleur"].each do |grade|
      page_has_subsubtitle "Grade #{grade}", class: 'grade_title'
    end
  end
  
  scenario 'Un visiteur peut ' do
    
  end
end