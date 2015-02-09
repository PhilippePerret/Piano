# encoding: UTF-8
class User
  class << self
    
    
    def pstore
      @pstore ||= File.join(App::current.folder, 'data', 'pstore', 'membres.pstore')
    end
  end
end