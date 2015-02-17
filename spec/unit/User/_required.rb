# encoding: UTF-8


def rescue_pstore_membres_and_table
  File.make_rescue User::pstore
  File.make_rescue User::table_mail_to_id
end
def rescue_and_unlink_pstore_membres_and_table
  File.unlink_with_rescue User::pstore
  File.unlink_with_rescue User::table_mail_to_id
end
def retrieve_pstore_membres_and_table
  File.retrieve_rescue User::pstore
  File.retrieve_rescue User::table_mail_to_id
end

def create_reader data
  PStore::new(app.pstore_readers).transaction do |ps|
    ps[data[:uid]] = data
  end
end