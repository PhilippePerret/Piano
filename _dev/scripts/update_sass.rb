require 'sass'

##
## Si true, on update directement ONLINE les fichiers modifiés
##
UPDATE_ONLINE = false

def uptodate? src
  @dest_path = File.join(File.dirname(src), File.basename(src, File.extname(src)) + ".css")
  return false unless File.exist? @dest_path
  File.stat(src).mtime < File.stat(@dest_path).mtime
end

data_compilation = {
  line_comments: false, # Pour indiquer les numéros de lignes et fichier source
  style: :compressed
}

file_list = []
puts "*** Début opération ***"
Dir["./public/page/**/*.sass"].each do |path_sass|
  next if uptodate? path_sass
  Sass::compile_file path_sass, @dest_path, data_compilation
  file_list << @dest_path
  puts "* TRAITÉ : #{path_sass}"
end

## Il faut updater online les fichiers modifiés
if UPDATE_ONLINE
  file_list.each do |path|
    puts "UPLOADÉ: #{path}"
  end
end

puts "*** Fin opération ***"