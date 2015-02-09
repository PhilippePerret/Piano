# encoding: UTF-8
class User
  
  LEVEL_ADMINISTRATOR   = 128     # Tout privilège, dont destruction membres
  LEVEL_DEEP_REDACTOR   = 32      # Peut rédiger des articles de fond
  LEVEL_BLOG_REDACTOR   = 16      # Peut avoir son blog
  LEVEL_SUGGEST_IDEAS   =  8      # Peut suggérer des idées
  
  LEVEL_SENTINELLE  = LEVEL_SUGGEST_IDEAS
  LEVEL_REDACTOR    = LEVEL_DEEP_REDACTOR|LEVEL_BLOG_REDACTOR|LEVEL_SUGGEST_IDEAS
  LEVEL_CREATOR     = LEVEL_REDACTOR|LEVEL_ADMINISTRATOR
  
  GRADES = {
    creator:      {hname: "Créateur",   level: LEVEL_CREATOR},
    redactor:     {hname: "Rédacteur",  level: LEVEL_REDACTOR},
    sentinelle:   {hname: "Sentinelle", level: LEVEL_SENTINELLE},
    no_grade:     {hname: "Sans grade", level: 0}
  }
end