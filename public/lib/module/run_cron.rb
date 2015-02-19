#!/usr/bin/env ruby
# encoding: UTF-8
=begin

CRON
----

Module appelé par la cron-tab pour exécuter le cron quotidien (à minuit)

=end
MODE_CRON = true


def mainlog mess
  reflog.write "--- [#{Time.now}] #{mess}\n"
end

def log_error e
  log e.message + "\n" + e.backtrace.join("\n")
end
def reflog
  @reflog ||= File.open(log_path, 'a')
end
def log_path
  @log_path ||= File.expand_path( File.join('.', 'cron.log') )
end

begin
  
  File.unlink log_path if File.exist? log_path
  
  mainlog "-> #{__FILE__}"
  ##
  ## Se placer à la racine du site
  ##
  Dir.chdir(File.join('.', 'www')) do
    require './public/lib/module/cron'
    App::Cron::run
    App::Cron::result_to_admin
  end
  mainlog "<- #{__FILE__}"
  
rescue Exception => e
  log_error e
  begin
    dmail = {
      subject:    "Erreur au cours du cron-job",
      message:    "Une erreur est survenue au cours du cron (#{e.message}). Voir le détail complet de l'erreur dans le fichier `cron.lob' à la racine de l'hébergement (pas du site)."
    }
    send_mail_to_admin dmail
  rescue Exception => e
    log_error e
  end
end
