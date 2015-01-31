require 'sass'

def uptodate? src
  @dest_path = File.join(File.dirname(src), File.basename(src, File.extname(src)) + ".css")
  return false unless File.exist? @dest_path
  File.stat(src).mtime < File.stat(@dest_path).mtime
end

data_compilation = {
  line_comments: false, # Pour indiquer les numéros de lignes et fichier source
  style: :compressed
}

Dir["./public/page/**/*.sass"].each do |path_sass|
  next if uptodate? path_sass
  Sass::compile_file path_sass, @dest_path, data_compilation
end