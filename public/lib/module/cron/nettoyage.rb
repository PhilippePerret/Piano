# encoding: UTF-8
=begin

Module cron de nettoyage du site

=end
class App
  class Cron
    class << self
      
      def clean_up
        log "\n\n-> clean_up"
        clean_up_logs
      end
      
      ##
      #
      # Nettoyage des logs
      #
      def clean_up_logs
        log "\n\n*** Nettoyage du dossier /tmp/log ***\n"
        log "INFO: Seuls sont détruits les logs de débug dont la date est pour"
        avanthier = Time.now.to_i - (2.days + 100)
        avanthier = Time.at(avanthier).strftime("%Y%m%d").to_i
        Dir["#{folder_log}/debug-*.log"].each do |path|
          logname = File.basename path
          log "- #{logname}"
          logday = logname.split(/[-\.]/)[1].to_i
          if logday < avanthier
            unless noop
              File.unlink path 
              m = "DESTRUCTION"
            else
              m = "sera détruit"
            end
            log "  * Vieux d'avant-hier => #{m}"
          else
            logsize = File.stat(path).size / 1000
            log "  = Trop jeune pour être détruit (taille: #{logsize}ko)"
          end
        end
      end
      
      def folder_log
        @folder_log ||= File.join(app.folder_tmp, 'log')
      end
    end
  end
end