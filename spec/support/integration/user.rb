=begin
  Handy méthode pour user
=end


def set_remote_ip ip
  ENV['REMOTE_ADDR'] = ip
end
alias :set_remote_addr :set_remote_ip