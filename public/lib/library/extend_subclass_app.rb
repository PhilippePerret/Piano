# encoding: UTF-8
=begin
Extension pour les sous-classes de App utilisées par la partie administration
pour que des sous-classes puissent utiliser de façon directe les méthodes
de l'application.

    class App
      current::require_library 'extend_subclass_app'
      
      class SouClass < ExtensionSubclassApp

=end
class ExtensionSubclassApp
  class << self
    def app
      @app ||= App::current
    end
    def require_module module_name; app.error module_name end
    def require_library lib;      app.require_library lib end
    def error mess_error;   app.error mess_error  end
    def flash mess;         app.flash mess        end
    def last_time key;      app.last_time key     end
    def set_last_time key, time = nil;  app.set_last_time key, time end
    def param key;          app.param key         end
    def name;               app.name              end
    def short_name;         app.short_name        end
    def online?;            app.online?           end
    def offline?;           app.offline?          end
    def upload relpath;     app.upload relpath    end
    def download relpath;   app.download relpath  end
    def row lib, fld, par = nil;  app.row lib, fld, par end
  end
end