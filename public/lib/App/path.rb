# encoding: UTF-8
=begin

Paths

=end
class App
  
  HOST_ONLINE =   "piano.alwaysdata.net"
  FULL_URL    =    "http://#{HOST_ONLINE}/"
  
  
  def relative_path path
    path.sub(/^#{folder}\//, '')
  end
  
  # ---------------------------------------------------------------------
  #
  #   Pstores principaux
  #
  # ---------------------------------------------------------------------
  
  def pstore_readers
    @pstore_readers ||= File.join(folder_pstore, 'readers.pstore')
  end
  alias :pstore_readers :pstore_readers
  
  def pstore_ip_to_uid
    @pstore_ip_to_uid ||= File.join(folder_pstore, 'ip_to_uid.pstore')
  end
  alias :pstore_ip_to_uid :pstore_ip_to_uid

  def pstore_last_times
    @pstore_last_times ||= File.join(folder_pstore, 'last_times.pstore')
  end
  def pstore_connexions
    @pstore_connexions ||= File.join(folder_pstore, 'connexions.pstore')
  end
  def pstore_connexions_courantes
    @pstore_connexions_courantes ||= File.join(folder_pstore, 'connexions_courantes.pstore')
  end
  def pstore_followers
    @pstore_followers ||= File.join(folder_pstore, 'followers.pstore')
  end
  
  ##
  # Pstore des sujets proposés
  def pstore_new_sujets
    @pstore_new_sujets ||= File.join(folder_pstore, 'submitted_subjects.pstore')
  end
  
  # ---------------------------------------------------------------------
  #
  #   Dossiers
  #
  # ---------------------------------------------------------------------

  # Folder contenant les pstore-sessions provisoires
  def folder_pstore_session
    @folder_pstore_session ||= File.join(folder_tmp, 'pstore_session')
  end

  # Sub-sub
  def folder_ticket
    @folder_ticket ||= File.join(folder_data, 'ticket')
  end
  def folder_image
    @folder_image ||= File.join(folder_page, 'img')
  end
  def folder_pstore
    @folder_pstore ||= File.join(folder_data, 'pstore')
  end
  def folder_module
    @folder_module ||= File.join(folder_public, 'lib', 'module')
  end
  def folder_library
    @folder_library ||= File.join(folder_public, 'lib', 'library')
  end
  # Sub
  def folder_page
    @folder_page ||= File.join(folder_public, 'page')
  end
  def folder_public
    @folder_public ||= File.join(folder, 'public')
  end
  def folder_data
    @folder_data ||= File.join(folder, 'data')
  end
  def folder_tmp
    @folder_tmp ||= File.join(folder, 'tmp')
  end
  # Main
  def folder
    @folder ||= File.expand_path('.')
  end
end