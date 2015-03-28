# encoding: UTF-8
=begin

Ce script permet de réparer la table de correspondance entre les idpath et les
id des articles.

Elle est nécessaire car il persiste un problème au niveau de l'enregistrement
de l'idpath d'un article (l'endroit n'est pas encore trouvé).

Il permet aussi de corriger des titres et de supprimer des articles dans
articles.pstore.

Normalement, il peut être utilisé sans trop de risques.

NOTE IMPORTANTE : Il faut travailler sur les pstores 
  - articles_idpath_to_id.pstore
  - articles.pstore
qu'il faut ramener du site distant.

=end
require 'pstore'

##
## Liste des IDs des articles dont il faut forcer la destruction
## (data dans articles.pstore)
##
ARTICLES_TO_KILL = []

##
## Les articles dont il ne faut pas toucher le titre
##
ARTICLE_DONT_CHANGE_TITRE = [2]

unless ARTICLES_TO_KILL.nil? || ARTICLES_TO_KILL.empty?
  PStore::new('./data/pstore/articles.pstore').transaction do |ps|
    ARTICLES_TO_KILL.each do |id| 
      ps.delete id 
      puts "Data Article ID #{id} détruite"
    end
  end
end

def change_titre darticle, new_titre
  PStore::new('./data/pstore/articles.pstore').transaction do |ps|
    ps[darticle[:id]][:titre] = new_titre
  end
end

def data_article id
  PStore::new('./data/pstore/articles.pstore').transaction do |ps|
    ps.fetch id, nil
  end
end

##
#
# Retourne le titre dans l'article
#
def real_titre_in idpath
  path = File.join('.', 'public', 'page', 'article', "#{idpath}.erb")
  if File.exist? path
    code = File.read(path).force_encoding("utf-8")
    if code.index(/<h2>(.+?)<\/h2>/)
      code.match(/<h2>(.+?)<\/h2>/).to_a[1]
    elsif code.index(/<h3>(.+?)<\/h3>/)
      code.match(/<h3>(.+?)<\/h3>/).to_a[1]
    end
  else
    puts "### TITRE INTROUVABLE : ARTICLE INTROUVABLE (#{path})"
    nil
  end
end

pstore_path = File.join('.', 'data', 'pstore', 'articles_idpath_to_id.pstore')

liste_ids   = []
liste_paths = []
PStore::new(pstore_path).transaction do |ps|
  ps.roots.each do |key|
    case key
    when Fixnum
      
      liste_ids << key
      darticle  = data_article key
      if darticle.nil?
        puts "### IMPOSSIBLE DE TROUVER LES DATA DE L'ARTICLE #{key}"
        ##
        ## Destruction de cette donnée
        ##
        ps.delete key
      else
        idpath  = darticle[:idpath]
        titre   = darticle[:titre]
        ##
        ## Si l'IDPATH ne correspond pas à la valeur, la modifier
        ##
        if ps[key] != idpath
          puts "### L'IDPATH ne matche pas (pstore:) #{ps[key]} / (article:) #{idpath} (CORRIGÉ)"
          ps[key] = idpath
        end
        ##
        ## Si l'IDPATH de l'article n'existe pas dans ce pstore, on le crée
        ##
        if ps.fetch( idpath, nil ).nil?
          puts "### L'Idpath de l'article #{key} est inconnu : #{idpath} (AJOUTÉ)"
          ps[idpath] = key
        end
        
        unless ARTICLE_DONT_CHANGE_TITRE.include? key
          ##
          ## Si le TITRE de l'article est différent, il faut le corriger
          ##
          titre_article = real_titre_in idpath
          if titre_article != nil && titre != titre_article
            puts "### (article ##{key}) TITRE DIFFÉRENT : (pstore:) #{titre} / (article:) #{titre_article}"
            change_titre darticle, titre_article
            puts "Data : #{darticle.inspect}"
          end
        end
        # puts "\n*** ARTICLE #{key}"
        # puts "  Data: #{data_article(key).inspect}"
      end
    when String
      liste_paths << key
      ##
      ## Si cet idpath ne correspond à aucun article, il faut le supprimer
      ##
      fullpath = File.join('.', 'public', 'page', 'article', "#{key}.erb")
      unless File.exist? fullpath
        puts "### L'article #{fullpath} est inconnu => Destruction de la data"
        ps.delete key
      end
    end
  end
end

# puts "Liste des IDs : #{liste_ids.inspect}"
# puts "Liste des paths : #{liste_paths.inspect}"
