#!/usr/bin/env ruby
# encoding: UTF-8
=begin

Ce script doit se trouver à la racine du SERVEUR

NOTES
  
  * Il est utilisé en local comme en distant. On sait qu'on est en local
    lorsque le dossier `www' n'existe pas
  * En distant, il retourne un Hash (marshalisé) contenant toutes la hiérarchie
    avec les dates de dernière modification.
  * En local, il place le même Hash dans $HIERARCHIE

=end
MODE_DISTANT = File.exist? './www'

CHECKED_FOLDER = 
case ARGV[0]
when nil then MODE_DISTANT ? './www' : '.'
else MODE_DISTANT ? File.join('.', 'www', ARGV[0]) : File.join('.', ARGV[0])
end

##
## Le décalage pour calculer la clé-dossier, pour qu'elle
## corresponde en local et en distant
##
OFFSET_FOLDER = MODE_DISTANT ? 6 : 2

result = {
  ok:               true,
  error:            nil,
  backtrace_error:  nil,
  files:            nil
}
@path = nil
files = {}
begin
  files.merge! CHECKED_FOLDER[OFFSET_FOLDER..-1] => {files: {}}
  Dir["#{CHECKED_FOLDER}/**/**"].each do |path|
    @path = path
    if File.directory? path
      files.merge! path[OFFSET_FOLDER..-1] => {files: {}}
    else
      fname = File.basename(path)
      files[File.dirname(path)[OFFSET_FOLDER..-1]][:files].merge! fname => {name: fname, mtime: File.stat(path).mtime.to_i}
    end
  end
  result[:files] = files
rescue Exception => e
  result[:error]            = "### ERROR avec le path : #{@path} : #{e.message}"
  result[:files]            = files
  result[:backtrace_error]  = e.backtrace
  result[:ok]               = false
end


if MODE_DISTANT
  STDOUT.write Marshal.dump(result)
else
  $HIERARCHIE = result
end
