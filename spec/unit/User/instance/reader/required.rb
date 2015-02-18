# encoding: UTF-8

# Raccourci
def pstore_rh
  @pstore_rh ||= app.pstore_ip_to_uid
end

def remove_fichier_pointeurs
  File.unlink pstore_rh if File.exist? pstore_rh
end
def remove_fichier_readers
  File.unlink app.pstore_readers if File.exist? app.pstore_readers
end
def rescue_and_unlink_fichier_pointeurs
  File.unlink_with_rescue pstore_rh
end
def rescue_and_unlink_fichier_readers
  File.unlink_with_rescue app.pstore_readers
end
def retrieve_fichier_pointeurs
  File.retrieve_rescue pstore_rh
end
def retrieve_fichier_readers
  File.retrieve_rescue app.pstore_readers
end
def fichier_pointeurs_existe existe = true
  if existe
    expect(File).to be_exist pstore_rh
  else
    expect(File).not_to be_exist pstore_rh
  end
end

##
# Enregistre un pointeur
#
def save_pointeur hdata
  PStore::new(app.pstore_ip_to_uid).transaction do |ps|
    hdata.each { |k,v| ps[k] = v }
  end
end
