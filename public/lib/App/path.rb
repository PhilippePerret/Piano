# encoding: UTF-8
=begin

Paths

=end
class App
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
  alias :pstore_lecteurs :pstore_readers
  
  def pstore_readers_handlers
    @pstore_readers_handlers ||= File.join(folder_pstore, 'readers_handlers.pstore')
  end
  alias :pstore_pointeurs_lecteurs :pstore_readers_handlers

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
  
  # ---------------------------------------------------------------------
  #
  #   Dossiers
  #
  # ---------------------------------------------------------------------

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
  # Main
  def folder
    @folder ||= File.expand_path('.')
  end
end