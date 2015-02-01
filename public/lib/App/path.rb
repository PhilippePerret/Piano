# encoding: UTF-8
=begin

Paths

=end
class App
  def relative_path path
    path.sub(/^#{folder}\//, '')
  end
  def folder
    @folder ||= File.expand_path('.')
  end
end