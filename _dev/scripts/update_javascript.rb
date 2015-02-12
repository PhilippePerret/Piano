require 'uglifier'

def uptodate? src
  @dest_path = File.join(File.dirname(src), File.basename(src, File.extname(src)) + "_mini.js")
  return false unless File.exist? @dest_path
  File.stat(src).mtime < File.stat(@dest_path).mtime
end

dir = File.join('.','public','page')

Dir.glob("#{dir}/**/*.js").reject{|p| p.end_with?('mini.js')}.each do |path|
  next if uptodate? path
  File.open(@dest_path,'wb'){|f| f.write Uglifier.new.compile(File.read(path)) }
  puts "* TRAITÉ : Fichier #{path}"
end
