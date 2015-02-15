=begin

Méthodes handy pour les User

=end

##
#
# Ajoute un follower avec les données +du+
# +du+ doit définir :mail, :ip, :pseudo
def new_follower du
  unless du.has_key? :created_at
    du.merge! created_at: Time.now.to_i
  end
  PStore::new(app.pstore_followers).transaction do |ps|
    new_id = ps.fetch(:last_id, 0) + 1
    ps[:last_id] = new_id
    du.merge! id: new_id
    ps[du[:mail]] = du
  end
end