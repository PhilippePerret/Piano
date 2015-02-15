# encoding: UTF-8
class User
  class << self
    
    def table_mail_to_id
      @table_mail_to_id ||= File.join(app.folder_pstore, 'table_mail_to_id.pstore')
    end
    def pstore
      @pstore ||= File.join(app.folder_pstore, 'membres.pstore')
    end
  end
end