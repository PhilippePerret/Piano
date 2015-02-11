# encoding: UTF-8
=begin

Paths

=end
class App
  def relative_path path
    path.sub(/^#{folder}\//, '')
  end
  
  def pstore_last_times
    @pstore_last_times ||= File.join(folder, 'data', 'pstore', 'last_times.pstore')
  end
  def pstore_connexions
    @pstore_connexions ||= File.join(folder, 'data', 'pstore', 'connexions.pstore')
  end
  def pstore_connexions_courantes
    @pstore_connexions_courantes ||= File.join(folder, 'data', 'pstore', 'connexions_courantes.pstore')
  end
  def pstore_mailing
    @pstore_mailing ||= File.join(folder, 'data', 'pstore', 'mailing_list.pstore')
  end
  def folder_module
    @folder_module ||= File.join(folder, 'public', 'lib', 'module')
  end
  def folder_library
    @folder_library ||= File.join(folder, 'public', 'lib', 'library')
  end
  def folder
    @folder ||= File.expand_path('.')
  end
end