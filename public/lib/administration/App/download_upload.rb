# encoding: UTF-8
class App

  ##
  #
  # Méthode qui rapatrie le fichier online sur le site local
  #
  # +relpath+   Chemin relatif (depuis la racine de l'application)
  #
  def download relpath
    raise if offline?
    `scp -p piano@ssh.alwaysdata.com:www/#{relpath} ./#{relpath}`
  end
  
  ##
  #
  # Méthode qui actualise le fichier online d'après le fichier
  # local
  #
  # +relpath+   Chemin relatif (depuis la racine de l'application)
  #
  def upload relpath
    raise if offline?
    `scp -p ./#{relpath} piano@ssh.alwaysdata.com:www/#{relpath}`
  end
  
end