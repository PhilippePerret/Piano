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
  def pstore_ips
    @pstore_ips ||= File.join(folder_pstore, 'ips.pstore')
  end
  def pstore_last_times
    @pstore_last_times ||= File.join(folder_pstore, 'last_times.pstore')
  end
  def pstore_connexions
    @pstore_connexions ||= File.join(folder_pstore, 'connexions.pstore')
  end
  def pstore_connexions_courantes
    @pstore_connexions_courantes ||= File.join(folder_pstore, 'connexions_courantes.pstore')
  end
  def pstore_mailing
    @pstore_mailing ||= File.join(folder_pstore, 'mailing_list.pstore')
  end
  # ---------------------------------------------------------------------
  #
  #   Dossiers
  #
  # ---------------------------------------------------------------------
  def folder_image
    @folder_image ||= File.join(folder_page, 'img')
  end
  def folder_pstore
    @folder_pstore ||= File.join(folder, 'data', 'pstore')
  end
  def folder_module
    @folder_module ||= File.join(folder_public, 'lib', 'module')
  end
  def folder_library
    @folder_library ||= File.join(folder_public, 'lib', 'library')
  end
  
  def folder_page
    @folder_page ||= File.join(folder_public, 'page')
  end
  def folder_public
    @folder_public ||= File.join(folder, 'public')
  end
  def folder
    @folder ||= File.expand_path('.')
  end
end