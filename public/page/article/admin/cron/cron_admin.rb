# encoding: UTF-8
class App
  class CronAdmin
    class << self
      def init
        app.require_module 'cron'
      end
    
      def run_cron
        App::Cron::noop = param('cb_no_operation') == "on"
        App::Cron::no_date = true
        App::Cron::no_pref = true
        App::Cron::full_infos = param('cb_full_infos') == "on"
        App::Cron::run
      end
    end
  end
end