# encoding: UTF-8
=begin

Handy méthodes pour User

=end

def cu
  User::current || User::new
end
alias :current_user :cu