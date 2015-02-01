# encoding: UTF-8
=begin

Paths

=end
class App
  def relative_path path
    path.sub(/^#{folder}\//, '')
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