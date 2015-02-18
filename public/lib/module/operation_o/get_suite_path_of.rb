# encoding: UTF-8
class App
  class Operation
    class << self      

      ##
      # Opération qui permet de fonctionner comme un shell bath pour
      # auto-compléter une path. Pour le moment, elle  n'est utilisée que
      # pour la validation des sujets soumis (admin/sujet_soumis/new_sujet.js)
      #
      def get_suite_path_of
        mess = []
        segpath = param('o1').strip
        mess << "segpath: #{segpath.inspect}"
        
        if segpath == ""
          dossier     = nil
          debut_name  = ""
        else
          offs = segpath.rindex('/')
          dossier     = segpath[0..offs-1]
          debut_name  = segpath[offs+1..-1]
          dossier = nil if dossier.to_s == ""
        end
        mess << "dossier : #{dossier.inspect}"
        mess << "debut_name: #{debut_name.inspect}"
        
        path_searched = "./public/page/article"
        path_searched << "/#{dossier}" unless dossier.nil?
        
        mess << "path_searched: #{path_searched}"

        names     = []
        dossiers  = []
        Dir["#{path_searched}/**"].each do |path|
          basename = File.basename path
          unless debut_name == ""
            if basename.start_with? debut_name
              names << basename
            end
          end
          dossiers << basename if File.directory?(path)
        end
        new_path = nil
        name = ""
        if names.count == 1
          name = "#{names.first}/"
        elsif names.count > 1
          ##
          ## Choisir les caractères communs
          ##
          first_name = names.shift
          (0..first_name.length-1).each do |ichar|
            c_comp = first_name[ichar]
            ok = true
            names.each do |n|
              if n[ichar] != c_comp
                ok = false
                break
              end
            end
            if ok
              name << c_comp
            else
              break
            end
          end
        end
        
        ##
        ## Compose le path
        ##
        new_path = ""
        new_path << "#{dossier}/" unless dossier.nil?
        new_path << name
        
        app.data_ajax = {
          unfound:        names.count == 0,
          path:           new_path,
          dossiers:       dossiers,
          path_searched:  path_searched,
          messages:       mess
        }
      end
      
    end # << self App::Operation
  end # Operation
end # App